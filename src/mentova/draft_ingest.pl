/*  Mentova — Draft-Document Ingestion Pipeline

    Turns a plain-text draft document into candidate facts, carries each through the
    NUANCED fact doors (co_new_cro_nuanced for relations, anchor_node_nuanced for
    node-facts, plus a J-Space hold), and emits a per-draft ingestion report saying
    exactly what was new, what was an exact repeat (strengthened), and what was a
    near-duplicate variant — with the delta that flags the difference. Every fact
    carries the draft's identity as its provenance, so when two drafts assert the
    same core fact with a subtle difference, both are kept and the difference is
    surfaced rather than merged away.

    This is the one-command entry for the ARC-AGI-3_Steps_Draft documents:
        swipl -g "draft_ingest:di_run('path/to/draft.txt', draft_01), halt" \
              src/mentova/mentova_chat.pl

    ACCEPTED PLAIN-TEXT SYNTAX (lenient; unrecognised lines are reported, not lost):
      # ... or % ...        a comment (ignored)
      game: <id>            set the current game context for following facts
      <cause> => <effect>   a cause-effect relation (a CRO)
      hazard: <state>       a hazardous state (a preventive relation to ends(run))
      <relation>(<args>)    a node-fact, e.g.  object(ring, collectible)
    A relation line under a game context is game-keyed (cause becomes g(Game,Cause);
    node-fact args are prefixed with the game).

    Predicates:
      di_run/2               -- +Path, +DraftId          (ingest a file, print report)
      di_ingest_file/3       -- +Path, +DraftId, -Report
      di_ingest_text/3       -- +Text, +DraftId, -Report
      di_parse/4             -- +Text, +DraftId, -Facts, -Unparsed
      di_render_report/2     -- +Report, -Lines
*/

% Declare this module and its ingestion interface.
:- module(draft_ingest, [
    % di_run/2: the one command — ingest a draft file and print the report.
    di_run/2,
    % di_ingest_file/3: ingest a draft file, returning the structured report.
    di_ingest_file/3,
    % di_ingest_text/3: ingest draft text directly.
    di_ingest_text/3,
    % di_parse/4: parse draft text into candidate facts and unrecognised lines.
    di_parse/4,
    % di_render_report/2: render a report as human-readable lines.
    di_render_report/2,
    % di_report_json/2: render a report as a JSON-ready dict (for the endpoint).
    di_report_json/2
]).

% The stores this pipeline drives (co_core, node_facts, lattice, jspace) are called
% module-qualified and guarded, NOT use_module'd here, because their library paths
% may not be registered yet when this file is loaded as a dependency — the same
% robust pattern arc3_knowledge uses.
% Text and list helpers (standard libraries, always available).
:- use_module(library(readutil), [read_file_to_string/3]).
:- use_module(library(lists), [member/2, append/3]).
:- use_module(library(aggregate), [aggregate_all/3]).

% ===========================================================================
% SECTION 1 — parsing plain text into candidate facts
% ===========================================================================

% A candidate fact is one of:
%   cfact(cro,  Causes, Effects, Modality, Cite)   -- a relation
%   cfact(node, Relation, Args)                     -- a node-fact

% di_parse(+Text, +DraftId, -Facts, -Unparsed): split the draft into candidate
% facts and the lines that were not recognised (reported, never silently dropped).
di_parse(Text, _DraftId, Facts, Unparsed) :-
    % Split into lines.
    split_string(Text, "\n", "", RawLines),
    % Parse line by line, threading the current game context.
    di_parse_lines(RawLines, none, Facts, Unparsed).

% di_parse_lines(+Lines, +Game, -Facts, -Unparsed): fold over the lines.
di_parse_lines([], _, [], []).
di_parse_lines([Line0 | Rest], Game0, Facts, Unparsed) :-
    % Trim surrounding whitespace.
    normalize_space(string(Line), Line0),
    % Classify this line.
    (   di_skip(Line)
    % A blank or comment: skip, keep the context.
    ->  di_parse_lines(Rest, Game0, Facts, Unparsed)
    ;   di_line(Line, Game0, Game1, LineFacts)
    % A recognised line: collect its facts, carry the (possibly new) context.
    ->  append(LineFacts, RestFacts, Facts),
        di_parse_lines(Rest, Game1, RestFacts, Unparsed)
    % Unrecognised: record the raw line for the report.
    ;   Unparsed = [Line | RestUn],
        di_parse_lines(Rest, Game0, Facts, RestUn)
    ).

% di_skip(+Line): a blank line or a comment.
di_skip("") :- !.
di_skip(Line) :- sub_string(Line, 0, 1, _, "#"), !.
di_skip(Line) :- sub_string(Line, 0, 1, _, "%"), !.

% di_line(+Line, +Game0, -Game1, -Facts): recognise one content line and yield the
% candidate facts it contains, updating the game context where the line sets it.
% A game directive: "game: <id>".
di_line(Line, _Game0, Game1, []) :-
    di_key_value(Line, "game", Value), !,
    di_atom(Value, Game1).
% A hazard directive: "hazard: <state>" — a preventive relation to ends(run).
di_line(Line, Game, Game, [cfact(cro, [Cause], [ends(run)], preventive, hazard)]) :-
    di_key_value(Line, "hazard", Value), !,
    di_term(Value, State),
    di_game_cause(Game, State, Cause).
% A cause-effect relation: "<cause> => <effect>".
di_line(Line, Game, Game, [cfact(cro, [Cause], [Effect], sufficient, step)]) :-
    di_split_arrow(Line, LeftS, RightS), !,
    di_term(LeftS, LeftT), di_term(RightS, Effect),
    di_game_cause(Game, LeftT, Cause).
% A node-fact: a term "<relation>(<args>)".
di_line(Line, Game, Game, [cfact(node, Relation, Args)]) :-
    di_term(Line, Term),
    compound(Term), !,
    Term =.. [Relation | Args0],
    di_game_args(Game, Args0, Args).

% di_key_value(+Line, +Key, -Value): true when Line is "Key: Value".
di_key_value(Line, Key, Value) :-
    string_concat(Key, ":", Prefix),
    string_concat(Prefix, Rest, Line),
    normalize_space(string(Value), Rest).

% di_split_arrow(+Line, -Left, -Right): split "A => B" on the first "=>".
di_split_arrow(Line, Left, Right) :-
    sub_string(Line, Before, _, After, "=>"), !,
    sub_string(Line, 0, Before, _, LeftRaw),
    sub_string(Line, _, After, 0, RightRaw),
    normalize_space(string(Left), LeftRaw),
    normalize_space(string(Right), RightRaw).

% di_term(+String, -Term): read a Prolog term from a string, atoms unquoted.
di_term(String, Term) :-
    ( catch(term_string(Term0, String), _, fail) -> Term = Term0
    ; atom_string(Term, String) ).

% di_atom(+String, -Atom): the string as an atom.
di_atom(String, Atom) :- atom_string(Atom, String).

% di_game_cause(+Game, +Cause, -Keyed): game-key a cause when a game context is set.
di_game_cause(none, Cause, Cause) :- !.
di_game_cause(Game, Cause, g(Game, Cause)).

% di_game_args(+Game, +Args0, -Args): prefix a node-fact's args with the game.
di_game_args(none, Args, Args) :- !.
di_game_args(Game, Args, [Game | Args]).

% ===========================================================================
% SECTION 2 — ingesting candidate facts through the nuanced doors
% ===========================================================================

% di_ingest_text(+Text, +DraftId, -Report): parse and ingest draft text.
di_ingest_text(Text, DraftId, report(DraftId, Results, Unparsed)) :-
    % Ensure a nexus is open for anchoring node-facts.
    di_open_nexus,
    % Parse into candidate facts.
    di_parse(Text, DraftId, Facts, Unparsed),
    % Ingest each, collecting its outcome.
    findall(Result,
        ( member(F, Facts), di_ingest_one(F, DraftId, Result) ),
        Results),
    % Hold the draft's concepts in a J-Space workspace (best effort).
    di_hold_jspace(DraftId, Facts).

% di_ingest_file(+Path, +DraftId, -Report): read a draft file and ingest it.
di_ingest_file(Path, DraftId, Report) :-
    read_file_to_string(Path, Text, []),
    di_ingest_text(Text, DraftId, Report).

% di_open_nexus: open (or reuse) the drafts nexus and make it the anchor target.
di_open_nexus :-
    catch(( lattice:lattice_open('locus://mentova/drafts', N),
            node_facts:set_default_nexus(N) ), _, true).

% di_ingest_one(+CFact, +DraftId, -Result): drive one candidate fact through the
% nuanced door, tagging it with the draft's provenance. Result records the fact and
% its status (new | exact | variant with deltas).
% A relation: carry the draft as provenance so cross-draft near-duplicates are seen.
di_ingest_one(cfact(cro, Causes, Effects, Modality, Kind), DraftId,
              result(cro(Causes, Effects, Modality), Status)) :-
    catch(
        co_core:co_new_cro_nuanced(Causes, Effects, temporal(0, 0, instant), Modality,
            0.80, [kind(Kind)], prov(draft, draft(DraftId), 0.80), _Id, Status),
        _, Status = error).
% A node-fact: carry the draft as a referent, so cross-draft near-duplicates vary
% only in that referent and are flagged as variants.
di_ingest_one(cfact(node, Relation, Args), DraftId,
              result(node(Relation, Args), Status)) :-
    catch(
        node_facts:anchor_node_nuanced(Relation, Args, [draft(DraftId)], _Id, Status),
        _, Status = error).

% di_hold_jspace(+DraftId, +Facts): hold each candidate as a concept in the draft's
% J-Space workspace, best effort.
di_hold_jspace(DraftId, Facts) :-
    catch((
        jspace:js_open(draft(DraftId)),
        forall(member(F, Facts),
            ( di_concept(F, Concept),
              catch(jspace:js_hold(draft(DraftId), Concept, 0.8, draft(DraftId)), _, true) ))
    ), _, true).

% di_concept(+CFact, -Concept): the J-Space concept term for a candidate fact.
di_concept(cfact(cro, Causes, Effects, _, _), relation(Causes, Effects)).
di_concept(cfact(node, Relation, Args), node(Relation, Args)).

% ===========================================================================
% SECTION 3 — the per-draft ingestion report
% ===========================================================================

% di_render_report(+Report, -Lines): a human-readable per-draft report, one atom
% per line, summarising new / strengthened / variant-flagged facts and listing the
% variant deltas and any unparsed lines.
di_render_report(report(DraftId, Results, Unparsed), Lines) :-
    % Partition the results by status.
    di_count(Results, new, NewN),
    di_count(Results, exact, ExactN),
    di_count(Results, variant, VarN),
    di_count(Results, error, ErrN),
    length(Results, Total),
    length(Unparsed, UnN),
    % The header and summary lines.
    format(atom(H0), 'Draft ingestion report: ~w', [DraftId]),
    format(atom(H1), '  candidate facts: ~w   (new: ~w, strengthened: ~w, variant-flagged: ~w, errors: ~w)',
           [Total, NewN, ExactN, VarN, ErrN]),
    format(atom(H2), '  unrecognised lines: ~w', [UnN]),
    % One detail line per variant-flagged fact, with its delta.
    findall(VLine,
        ( member(result(Fact, variant(_, Deltas)), Results),
          di_fact_label(Fact, FL),
          format(atom(VLine), '  VARIANT  ~w   delta: ~w', [FL, Deltas]) ),
        VLines),
    % One line per unparsed line.
    findall(ULine,
        ( member(U, Unparsed), format(atom(ULine), '  UNPARSED ~w', [U]) ),
        ULines),
    % Assemble, with section headers only when there is content.
    ( VLines == [] -> VSect = [] ; VSect = ['  --- near-duplicate variants flagged for attention ---' | VLines] ),
    ( ULines == [] -> USect = [] ; USect = ['  --- lines not recognised (tune the parser) ---' | ULines] ),
    append([[H0, H1, H2], VSect, USect], Lines).

% di_count(+Results, +Which, -N): count results whose status is Which.
di_count(Results, Which, N) :-
    aggregate_all(count, ( member(result(_, S), Results), di_status_is(S, Which) ), N).

% di_status_is(+Status, +Which): classify a status.
di_status_is(new, new) :- !.
di_status_is(exact(_), exact) :- !.
di_status_is(variant(_, _), variant) :- !.
di_status_is(error, error) :- !.
di_status_is(_, _) :- fail.

% di_fact_label(+Fact, -Label): a short label for a fact in the report.
di_fact_label(cro(Causes, Effects, Modality), Label) :-
    format(atom(Label), '~w => ~w [~w]', [Causes, Effects, Modality]).
di_fact_label(node(Relation, Args), Label) :-
    format(atom(Label), '~w(~w)', [Relation, Args]).

% di_report_json(+Report, -Dict): the same report as a JSON-ready dict, for the
% ingestion endpoint — counts, the flagged variants with their deltas as text, the
% unrecognised lines, and the full rendered lines.
di_report_json(report(DraftId, Results, Unparsed), Dict) :-
    di_count(Results, new, NewN),
    di_count(Results, exact, ExactN),
    di_count(Results, variant, VarN),
    di_count(Results, error, ErrN),
    length(Results, Total),
    % The variants as {fact, delta} dicts.
    findall(_{fact: FL, delta: DL},
        ( member(result(Fact, variant(_, Deltas)), Results),
          di_fact_label(Fact, FA), term_string(FA, FL),
          term_string(Deltas, DL) ),
        Variants),
    % The rendered text lines, as strings.
    di_render_report(report(DraftId, Results, Unparsed), Lines),
    findall(S, ( member(L, Lines), term_string(L, S) ), LineStrs),
    % The draft id as text.
    term_string(DraftId, DraftText),
    % Assemble.
    Dict = _{draft: DraftText, total: Total, new: NewN, strengthened: ExactN,
             variant_flagged: VarN, errors: ErrN, unparsed: Unparsed,
             variants: Variants, lines: LineStrs}.

% ===========================================================================
% SECTION 4 — the one command
% ===========================================================================

% di_run(+Path, +DraftId): ingest a draft file and print its report to the console.
di_run(Path, DraftId) :-
    di_ingest_file(Path, DraftId, Report),
    di_render_report(Report, Lines),
    forall(member(L, Lines), format("~w~n", [L])).
