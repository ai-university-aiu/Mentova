/*  Mentova — Draft-Document Ingestion Demonstration

    Proves the pipeline for the ARC-AGI-3_Steps_Draft documents: plain-text drafts
    become candidate facts, ingested through the nuanced doors with per-draft
    provenance, and a report says what was new, strengthened, or variant-flagged.

    Acceptance criteria (each prints PASS or FAIL):
      AC-DI-001: a draft parses into the expected facts, unparsed lines separated.
      AC-DI-002: a fresh draft ingests as all-new.
      AC-DI-003: re-ingesting the SAME draft strengthens (exact), adds nothing new.
      AC-DI-004: a near-duplicate draft (same facts, different id) is variant-flagged.
      AC-DI-005: the report surfaces each variant's delta (the nugget).
      AC-DI-006: an unrecognised line is reported, not silently dropped.

    Run:
        swipl -l demos/draft_ingest_demo.pl -g run_draft_demo -t halt
*/

% Load the full stack (causal_core, node_facts, lattice, jspace) + the pipeline.
:- use_module('../src/mentova/mentova_chat').
:- use_module('../src/mentova/draft_ingest').
:- use_module(library(lists), [member/2]).

% report(+Id, +Goal): print PASS or FAIL for one criterion.
report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> V = 'PASS' ; V = 'FAIL' ),
    format("~w: ~w~n", [Id, V]).

% A small draft using distinct predicates so it never collides with boot facts.
draft("game: dgame\nfoo(bar) => baz(qux)\nwidget(alpha, shiny)\nhazard: sky_falls\nthis is not a valid fact line").

% count_status(+Report, +Which, -N): how many results in the report have a status.
count_status(report(_, Results, _), Which, N) :-
    findall(1, ( member(result(_, S), Results), status_is(S, Which) ), L), length(L, N).
status_is(new, new) :- !.
status_is(exact(_), exact) :- !.
status_is(variant(_, _), variant) :- !.

% run_draft_demo: exercise the pipeline end to end.
run_draft_demo :-
    format("~n=== Draft-Document Ingestion ===~n~n", []),
    draft(D),

    % AC-001: parsing separates 3 facts (a CRO, a node-fact, a hazard) from 1
    % unrecognised line.
    report('AC-DI-001',
        ( di_parse(D, d_a, Facts, Unparsed),
          length(Facts, 3), length(Unparsed, 1) )),

    % AC-002: a fresh draft ingests as all-new.
    report('AC-DI-002',
        ( di_ingest_text(D, d_a, R1),
          count_status(R1, new, 3), count_status(R1, variant, 0) )),

    % AC-003: re-ingesting the SAME draft strengthens (exact), nothing new.
    report('AC-DI-003',
        ( di_ingest_text(D, d_a, R2),
          count_status(R2, exact, 3), count_status(R2, new, 0) )),

    % AC-004: a near-duplicate draft (same facts, different id) is variant-flagged.
    report('AC-DI-004',
        ( di_ingest_text(D, d_b, R3),
          count_status(R3, variant, 3), count_status(R3, new, 0) )),

    % AC-005: the report renders each variant's delta.
    report('AC-DI-005',
        ( di_ingest_text(D, d_c, R4), di_render_report(R4, Lines),
          member(L, Lines), sub_atom(L, _, _, _, 'VARIANT'),
          member(L2, Lines), sub_atom(L2, _, _, _, 'delta') )),

    % AC-006: the unrecognised line is reported.
    report('AC-DI-006',
        ( di_ingest_text(D, d_d, R5), di_render_report(R5, Lines2),
          member(U, Lines2), sub_atom(U, _, _, _, 'UNPARSED') )),

    % Show a sample report.
    ( di_ingest_text(D, d_show, RS), di_render_report(RS, Show) -> true ; Show = [] ),
    format("~nSample report:~n", []),
    forall(member(Ln, Show), format("~w~n", [Ln])),
    format("~n", []).
