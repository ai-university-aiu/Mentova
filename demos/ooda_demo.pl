/*  Mentova — OODA Methodology Skill Demonstration

    Proves that Mentova holds John Boyd's OODA loop as a skill it can reason about,
    in Jacobian Space, and that the methodology maps onto co_hplan's middle layer.

    Acceptance criteria (each prints PASS or FAIL):
      AC-OO-001: the four OODA phases are known.
      AC-OO-002: the five ingredients of orientation are known.
      AC-OO-003: the implicit-guidance principle is known (the expert's fast path).
      AC-OO-004: orientation is recorded as the schwerpunkt.
      AC-OO-005: each OODA phase maps onto co_hplan's middle-layer phases.
      AC-OO-006: the methodology is held as concepts in the J-Space workspace.
      AC-OO-007: recall answers a query about tempo.

    Run:
        swipl -l demos/ooda_demo.pl -g run_ooda_demo -t halt
*/

% Load the full stack (so jspace is available for the held-skill check).
:- use_module('../src/mentova/mentova_chat').
% The module under test.
:- use_module('../src/mentova/ooda_knowledge').
% List helpers.
:- use_module(library(lists), [member/2, memberchk/2]).

% report(+Id, +Goal): print PASS or FAIL for one criterion.
report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> V = 'PASS' ; V = 'FAIL' ),
    format("~w: ~w~n", [Id, V]).

% run_ooda_demo: hold the methodology and check it landed and maps to co_hplan.
run_ooda_demo :-
    % Announce.
    format("~n=== OODA Methodology as a Held Skill ===~n~n", []),
    % Hold it (idempotent).
    ( catch(ooda_bootstrap, _, true) -> true ; true ),

    % AC-001: the four phases are known.
    report('AC-OO-001',
        ( ooda_phase(observe, _), ooda_phase(orient, _),
          ooda_phase(decide, _), ooda_phase(act, _) )),

    % AC-002: the five ingredients of orientation are known.
    report('AC-OO-002',
        ( findall(I, ooda_orientation_ingredient(I, _), Is), length(Is, 5) )),

    % AC-003: the implicit-guidance principle (Orient straight to Act) is known.
    report('AC-OO-003',
        ( ooda_principle(implicit_guidance_and_control, Text),
          sub_atom(Text, _, _, _, 'bypassing Decide') )),

    % AC-004: orientation is the schwerpunkt.
    report('AC-OO-004',
        ( ooda_principle(orientation_is_schwerpunkt, T2),
          sub_atom(T2, _, _, _, 'main thing') )),

    % AC-005: each OODA phase maps onto co_hplan's middle-layer phases.
    report('AC-OO-005',
        ( ooda_hplan_map(observe, [see, observe]),
          ooda_hplan_map(orient, [orient]),
          ooda_hplan_map(act, [act]),
          ooda_hplan_map(feedback, [reobserve_update]) )),

    % AC-006: the methodology is held as concepts in J-Space.
    report('AC-OO-006',
        ( ooda_stats(stats(_, _, _, Held)), Held >= 15 )),

    % AC-007: recall answers a query about tempo.
    report('AC-OO-007',
        ( ooda_recall(tempo, Items), Items \== [] )),

    % Show the summary.
    ( ooda_stats(S) -> true ; S = none ),
    format("~nOODA skill: ~q~n~n", [S]).
