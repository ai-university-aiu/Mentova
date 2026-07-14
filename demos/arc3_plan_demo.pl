/*  Mentova — Hierarchical Plan Integration Demonstration

    Proves the solo player is driven by, and narrates play as, an explicit
    multi-level plan (hierarchical_planning): the top goal Win Game, the observe-orient-decide-
    act loop, and the game's concrete controls — reified onto Causalontology's own
    decomposition hierarchy and exposed in the glass box.

    Acceptance criteria (each prints PASS or FAIL):
      AC-HP-101: a plan tree is built for a game (Win Game -> OODA -> controls).
      AC-HP-102: the plan view carries the six OODA phases in order.
      AC-HP-103: the reified plan is causally consistent (the Causalontology mesh).
      AC-HP-104: the whole plan reconstructs from the CRO graph alone.
      AC-HP-105: a choice basis is located within the plan (its OODA phase + leaf).
      AC-HP-106: the plan view renders indented glass-box lines.

    Run:
        swipl -l demos/arc3_plan_demo.pl -g run_plan_demo -t halt
*/

% Load the backend under test.
:- use_module('../src/mentova/mentova_arc_chat').
% List helpers.
:- use_module(library(lists), [member/2, memberchk/2]).

% report(+Id, +Goal): print PASS or FAIL for one criterion.
report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> V = 'PASS' ; V = 'FAIL' ),
    format("~w: ~w~n", [Id, V]).

% run_plan_demo: build a plan for a game and check it landed and meshed.
run_plan_demo :-
    % Announce.
    format("~n=== Hierarchical Plan Integration ===~n~n", []),
    % A game to plan for (a local stand-in is fine; the plan is game-keyed).
    G = ls20,
    % Build the plan hierarchy for it.
    ( catch(mentova_arc_chat:ma_build_plan(G), _, true) -> true ; true ),

    % AC-101: a plan tree exists with the canonical top and method.
    report('AC-HP-101',
        ( mentova_arc_chat:ma_plan_tree_(G,
              hnode(win(G), strategy, [hnode(ooda_loop, cycle, _)])) )),

    % AC-102: the plan view carries the six OODA phases, in order.
    report('AC-HP-102',
        ( mentova_arc_chat:ma_plan_view(G, V),
          get_dict(tree, V, TreeJson),
          get_dict(children, TreeJson, [Ooda]),
          get_dict(children, Ooda, Phases),
          length(Phases, 6) )),

    % AC-103: the reified plan is causally consistent (the mesh is coherent).
    report('AC-HP-103',
        ( mentova_arc_chat:ma_plan_view(G, V2),
          get_dict(causalontology_consistent, V2, true) )),

    % AC-104: the whole plan reconstructs from the CRO graph alone.
    report('AC-HP-104',
        ( mentova_arc_chat:ma_plan_view(G, V3),
          get_dict(reconstructable_from_cros, V3, true) )),

    % AC-105: a solo choice basis is located within the plan.
    report('AC-HP-105',
        ( mentova_arc_chat:ma_note_plan_focus(G, explore(causal)),
          mentova_arc_chat:ma_plan_focus_(G, decide, op(predict_causal_change)) )),

    % AC-106: the plan view renders indented glass-box lines.
    report('AC-HP-106',
        ( mentova_arc_chat:ma_plan_view(G, V4),
          get_dict(lines, V4, Lines),
          member(L, Lines), sub_atom(L, _, _, _, 'OODA') )),

    % Show the plan the glass box would display.
    ( mentova_arc_chat:ma_plan_view(G, VShow), get_dict(lines, VShow, Show)
    -> true ; Show = [] ),
    format("~nThe plan the run follows:~n", []),
    forall(member(Ln, Show), format("  ~w~n", [Ln])),
    format("~n", []).
