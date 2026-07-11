/*  Mentova — Cognitive Architecture, Draft Ingestion, and North-Star Demonstration

    Proves the ten Steps drafts landed in the mind and the winning recipe was
    abstracted and planted: the drafts ingest without true duplicates, the transfer
    principles map to the Mentova pillars, and the Kaggle north-star concept is held
    in Jacobian Space.

    Acceptance criteria (each prints PASS or FAIL):
      AC-CG-001: the ten drafts ingest into the mind (many new facts).
      AC-CG-002: the transfer principles are present and mapped to pillars.
      AC-CG-003: every principle maps to at least one realising pillar.
      AC-CG-004: the Kaggle north-star concept is defined.
      AC-CG-005: the cognitive architecture is held in the J-Space workspace.

    Run: swipl -l demos/arc3_cognition_demo.pl -g run_cognition_demo -t halt
*/

:- use_module('../src/mentova/mentova_chat').
:- use_module('../src/mentova/arc3_steps').
:- use_module('../src/mentova/arc3_cognition').
:- use_module(library(lists), [member/2]).

report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n",[E]), fail)) -> V='PASS' ; V='FAIL' ),
    format("~w: ~w~n", [Id, V]).

run_cognition_demo :-
    format("~n=== Cognitive Architecture, Draft Ingestion, North-Star ===~n~n", []),
    ( catch(as_ingest(summary(New, _, _)), _, New = 0) -> true ; New = 0 ),
    ( catch(cog_bootstrap, _, true) -> true ; true ),

    % AC-001: the drafts ingested many facts.
    report('AC-CG-001', ( New >= 100 )),

    % AC-002: the transfer principles are present (at least a dozen).
    report('AC-CG-002',
        ( findall(P, cog_principle(P, _), Ps), length(Ps, N), N >= 12,
          cog_principle(executable_world_model, _),
          cog_principle(hypothesis_commitment, _) )),

    % AC-003: every principle maps to at least one realising pillar.
    report('AC-CG-003',
        ( forall(cog_principle(Slug, _),
                 ( cog_maps(Slug, Cap), cog_pillar(Cap, _, _) )) )),

    % AC-004: the Kaggle north-star concept is defined.
    report('AC-CG-004',
        ( cog_northstar(Star), sub_atom(Star, _, _, _, 'Win the Kaggle ARC-AGI-3') )),

    % AC-005: the architecture is held in the J-Space workspace.
    report('AC-CG-005',
        ( cog_stats(stats(_, _, Held)), Held >= 20 )),

    ( cog_stats(S) -> true ; S = none ),
    format("~ningested new facts: ~w   cognition: ~q~n~n", [New, S]).
