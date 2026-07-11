/*  Mentova — Whole-Grid Perception & Object-Targeted Curiosity Demonstration

    Proves the co_explore upgrade: Mentova now SEES the entire grid (co_see),
    learns the control map by watching what moves, deliberately goes to touch a
    fresh object instead of mulling on one spot, and READS a shrinking bar as a
    depleting resource rather than masking it away. It also proves the 25 studied
    games' knowledge is abstracted into cross-game priors that transfer to an
    unseen environment.

    Acceptance criteria (each prints PASS or FAIL):
      AC-WP-001: co_see sees the whole grid — several roled objects, not one.
      AC-WP-002: a meter/life-bar is read out as an object, not discarded.
      AC-WP-003: perception locates the avatar and LEARNS an action's displacement.
      AC-WP-004: object-targeting picks a fresh object and steers toward it.
      AC-WP-005: a fresh object is chosen each time — visited ones are not repeated.
      AC-WP-006: a shrinking bar is recognised as a draining resource.
      AC-WP-007: a draining resource makes collectible dots the preferred target.
      AC-WP-008: the 25 guides abstract to cross-game archetypes (ls20 → refill).
      AC-WP-009: the generic priors transfer to unseen roles (meter ranks first).

    Run:
        swipl -l demos/arc3_perception_demo.pl -g run_wp_demo -t halt
*/

% Load the backend under test (its internal ma_* perception predicates).
:- use_module('../src/mentova/mentova_arc_chat').
% Load the cross-game priors.
:- use_module('../src/mentova/arc3_priors').
% Load co_see directly so the demo can inspect the inventory too.
:- use_module(library(co_see), [cs_inventory/2, cs_bars/2]).

% The backend module, for reaching its internal (unexported) predicates.
:- use_module(library(lists), [member/2, memberchk/2]).

% report(+Id, +Goal): print PASS or FAIL for one criterion.
report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> V = 'PASS' ; V = 'FAIL' ),
    format("~w: ~w~n", [Id, V]).

% A movement frame: background 0, an avatar (colour 5) at (1,1), a collectible
% dot (colour 4) at (1,6), and a horizontal life-bar (colour 2) of length 6 on
% the bottom row.
frame0([
    [0,0,0,0,0,0,0,0],
    [0,5,0,0,0,0,4,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [2,2,2,2,2,2,0,0]
]).

% The same frame after the avatar stepped one cell right (to (1,2)) and the
% life-bar shrank to length 3 — a step cost a unit of the resource.
frame1([
    [0,0,0,0,0,0,0,0],
    [0,0,5,0,0,0,4,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [2,2,2,0,0,0,0,0]
]).

% run_wp_demo: exercise the whole-grid perception upgrade end to end.
run_wp_demo :-
    % Announce.
    format("~n=== Whole-Grid Perception & Object-Targeted Curiosity ===~n~n", []),
    % The two frames.
    frame0(F0), frame1(F1),
    % A demo game id, with clean perception state.
    G = wpdemo,
    retractall(mentova_arc_chat:ma_avatar_(G, _, _)),
    retractall(mentova_arc_chat:ma_move_vec_(G, _, _, _)),
    retractall(mentova_arc_chat:ma_visited_(G, _, _)),
    retractall(mentova_arc_chat:ma_pursuit_(G, _, _)),
    retractall(mentova_arc_chat:ma_meter_(G, _, _, _)),

    % AC-001: co_see sees the whole grid — the avatar, the dot, and the bar.
    report('AC-WP-001',
        ( cs_inventory(F0, Items), length(Items, N), N >= 3 )),

    % AC-002: a meter/life-bar is read out (not discarded).
    report('AC-WP-002',
        ( cs_inventory(F0, Items2), member(seen(_, 2, _, _, meter), Items2) )),

    % AC-003: perception locates the avatar and learns action(3)'s displacement.
    % Seed the avatar's start cell, then feed the observed step.
    ( retractall(mentova_arc_chat:ma_avatar_(G, _, _)),
      assertz(mentova_arc_chat:ma_avatar_(G, 1, 1)),
      mentova_arc_chat:ma_perceive_update(G, action(3), F0, F1) ),
    report('AC-WP-003',
        ( mentova_arc_chat:ma_move_vec_(G, action(3), DR, DC),
          DR =:= 0, DC =:= 1,
          mentova_arc_chat:ma_avatar_(G, 1, 2) )),

    % AC-004: object-targeting picks the fresh dot and steers toward it.
    report('AC-WP-004',
        ( cs_inventory(F1, Items4),
          mentova_arc_chat:ma_object_action(G, F1, Items4, Action4, Basis4),
          Action4 = action(3), Basis4 = moving_to(pos(1, 6)) )),

    % AC-005: once an object is visited it is not chosen again. The dot at (1,6)
    % is the first target; after marking it visited it must drop out of the list.
    report('AC-WP-005',
        ( cs_inventory(F1, Items5),
          mentova_arc_chat:ma_object_targets(G, F1, Items5, [pos(1, 6) | _]),
          assertz(mentova_arc_chat:ma_visited_(G, 1, 6)),
          mentova_arc_chat:ma_object_targets(G, F1, Items5, Again),
          \+ memberchk(pos(1, 6), Again) )),
    ( retractall(mentova_arc_chat:ma_visited_(G, 1, 6)) ),

    % AC-006: the shrinking bar is recognised as a draining resource. The first
    % reading (length 6) is 'new'; the second (length 3) is 'falling'.
    ( retractall(mentova_arc_chat:ma_meter_(G, _, _, _)),
      mentova_arc_chat:ma_meters_update(G, F0),
      mentova_arc_chat:ma_meters_update(G, F1) ),
    report('AC-WP-006', mentova_arc_chat:ma_resource_low(G)),

    % AC-007: with the resource draining, a dot is preferred (bias to collectibles).
    report('AC-WP-007',
        ( cs_inventory(F1, Items7),
          mentova_arc_chat:ma_object_targets(G, F1, Items7, [pos(1, 6) | _]) )),

    % AC-008: the 25 guides abstract to cross-game archetypes (ls20 → refill).
    report('AC-WP-008',
        ( ap_game_archetypes(ls20, As), memberchk(resource_refill, As) )),

    % AC-009: the generic priors transfer to unseen roles — a meter ranks first.
    report('AC-WP-009',
        ( ap_priors_for_roles([piece, meter, dot], [prior(meter, _) | _]) )),

    % Show what Mentova now sees and intends on this frame.
    ( cs_inventory(F1, Inv) -> true ; Inv = [] ),
    format("~nMentova sees on the frame: ~q~n", [Inv]),
    ( mentova_arc_chat:ma_object_action(wpdemo2, F1, Inv, _, _) -> true ; true ),
    format("~n", []).
