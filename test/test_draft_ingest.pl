/*  Mentova — Draft-Document Ingestion Test Suite

    Behavioural PLUnit tests for the draft_ingest module (src/mentova/draft_ingest.pl),
    the plain-text draft ingestion pipeline. Exercises the pure parser, the report
    renderer, the JSON-ready report, and the end-to-end text and file ingestion.

    Run with the full PrologAI library path plus the Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_draft_ingest.pl
*/

% Declare this file as a test module with no exports.
:- module(test_draft_ingest, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(draft_ingest)).
% Load list helpers for the assertions.
:- use_module(library(lists), [member/2, memberchk/2]).

% Open the test block for draft_ingest.
:- begin_tests(draft_ingest).

% AC-DI-001: a draft with no game context parses comments, node-facts, a cause-effect
% relation, and a hazard, and reports an unrecognised line rather than dropping it.
test(parse_relations_and_hazard_without_game_context) :-
    % A draft mixing two comment styles, a node-fact, a relation, a hazard, and junk.
    Text = "# comment line\n% another comment\nobject(ring, collectible)\npress(button) => light(on)\nhazard: touch(spike)\nthe weather is nice",
    % Parse the draft into candidate facts and unrecognised lines.
    di_parse(Text, draft_01, Facts, Unparsed),
    % The three content lines yield exactly these three candidate facts, in order.
    assertion(Facts == [ cfact(node, object, [ring, collectible]),
                         cfact(cro, [press(button)], [light(on)], sufficient, step),
                         cfact(cro, [touch(spike)], [ends(run)], preventive, hazard) ]),
    % The one prose line is reported as unparsed, never silently lost.
    assertion(Unparsed == ["the weather is nice"]).

% AC-DI-002: a game directive keys the following facts — the node-fact args are
% prefixed with the game and the relation cause becomes g(Game, Cause).
test(parse_game_context_keys_facts) :-
    % A draft that sets a game context before a node-fact and a relation.
    Text = "game: locksmith\nobject(ring)\npress(b_red) => light(red)",
    % Parse the draft.
    di_parse(Text, d2, Facts, Unparsed),
    % The node-fact is prefixed with the game and the relation cause is game-keyed.
    assertion(Facts == [ cfact(node, object, [locksmith, ring]),
                         cfact(cro, [g(locksmith, press(b_red))], [light(red)], sufficient, step) ]),
    % Nothing was unrecognised.
    assertion(Unparsed == []).

% AC-DI-003: the report renderer summarises the four statuses, flags the variant with
% its delta, and lists the unrecognised line under its section header.
test(render_report_summarises_and_flags) :-
    % A hand-built result set with one of each status.
    Results = [ result(cro([press(button)], [light(on)], sufficient), new),
                result(node(object, [ring]), exact(3)),
                result(cro([g(game, x)], [y], sufficient), variant(id7, [strength])),
                result(node(thing, [a]), error) ],
    % A report over those results with one unrecognised line.
    Report = report(draft_01, Results, ["some junk line"]),
    % Render the report to human-readable lines.
    di_render_report(Report, Lines),
    % The header names the draft.
    assertion(memberchk('Draft ingestion report: draft_01', Lines)),
    % The summary line counts each status exactly.
    assertion(memberchk('  candidate facts: 4   (new: 1, strengthened: 1, variant-flagged: 1, errors: 1)', Lines)),
    % The unrecognised-line tally is reported.
    assertion(memberchk('  unrecognised lines: 1', Lines)),
    % The single variant is flagged on its own detail line.
    assertion(( member(VLine, Lines), sub_atom(VLine, _, _, _, 'VARIANT') )),
    % The unrecognised line is echoed on its own detail line.
    assertion(( member(ULine, Lines), sub_atom(ULine, _, _, _, 'UNPARSED') )),
    % The whole report is exactly seven lines: three summary, two variant, two unparsed.
    assertion(( length(Lines, LineCount), LineCount =:= 7 )).

% AC-DI-004: the JSON-ready report carries the same counts and the draft id as text.
test(report_json_has_counts_and_draft) :-
    % The same hand-built result set as the render test.
    Results = [ result(cro([press(button)], [light(on)], sufficient), new),
                result(node(object, [ring]), exact(3)),
                result(cro([g(game, x)], [y], sufficient), variant(id7, [strength])),
                result(node(thing, [a]), error) ],
    % A report over those results with one unrecognised line.
    Report = report(draft_01, Results, ["some junk line"]),
    % Render the report as a JSON-ready dict.
    di_report_json(Report, Dict),
    % There are four candidate facts in total.
    get_dict(total, Dict, Total), assertion(Total == 4),
    % Exactly one was new.
    get_dict(new, Dict, NewN), assertion(NewN == 1),
    % Exactly one was an exact repeat, reported as strengthened.
    get_dict(strengthened, Dict, StrN), assertion(StrN == 1),
    % Exactly one was a near-duplicate variant.
    get_dict(variant_flagged, Dict, VarN), assertion(VarN == 1),
    % Exactly one errored.
    get_dict(errors, Dict, ErrN), assertion(ErrN == 1),
    % The draft id is carried as its text form.
    get_dict(draft, Dict, Draft), assertion(Draft == "draft_01").

% AC-DI-005: ingesting draft text end to end yields one result per parsed fact, each a
% well-formed result term, with the draft id and empty unparsed list preserved.
test(ingest_text_yields_one_result_per_fact) :-
    % A draft of exactly two clean content lines, one node-fact and one relation.
    di_ingest_text("object(ring)\npress(a) => b", draft_test, Report),
    % The report keeps the draft id, its results, and the unparsed lines.
    Report = report(DraftId, Results, Unparsed),
    % The draft id is preserved verbatim.
    assertion(DraftId == draft_test),
    % Both lines parsed cleanly, so nothing is unparsed.
    assertion(Unparsed == []),
    % There is exactly one ingestion result per parsed fact.
    assertion(( length(Results, ResultCount), ResultCount =:= 2 )),
    % Every result is a well-formed result(Fact, Status) term.
    assertion(forall(member(R, Results), R = result(_, _))).

% AC-DI-006: ingesting a draft file reads it, parses it, and returns the same
% structured report as ingesting its text directly.
test(ingest_file_reads_parses_and_reports) :-
    % Create a unique temporary file with an open write stream.
    tmp_file_stream(text, Path, Stream),
    % Write two clean draft lines into it.
    format(Stream, "object(ring)~npress(a) => b~n", []),
    % Close the stream so the file is flushed to disk.
    close(Stream),
    % Ingest the draft file into a structured report.
    di_ingest_file(Path, draft_file_test, report(Id, Results, Unparsed)),
    % The draft id is carried through from the call.
    assertion(Id == draft_file_test),
    % The two content lines parsed cleanly, so nothing is unparsed.
    assertion(Unparsed == []),
    % There is exactly one ingestion result per parsed fact.
    assertion(( length(Results, ResultCount), ResultCount =:= 2 )),
    % Remove the temporary draft file.
    delete_file(Path).

% Close the test block for draft_ingest.
:- end_tests(draft_ingest).
