/*  Mentova — Verify-Before-Act Integration Demonstration

    Proves the solo player predicts a move fatal BEFORE trying it and deprioritises
    it, rather than only recalling the exact moves that already killed. Three ways:
    exact death memory, positional simulation onto a deadly colour, and co_verify's
    generalisation of a broadly-fatal action to a new state.

    Acceptance criteria (each prints PASS or FAIL):
      AC-VF-001: a deadly colour is learned from a hazard delta.
      AC-VF-002: stepping the avatar onto a deadly colour is predicted fatal.
      AC-VF-003: stepping onto a safe colour is NOT predicted fatal.
      AC-VF-004: a broadly-fatal non-movement action is predicted fatal in a new state.
      AC-VF-005: predicted-fatal actions are deprioritised to the back, not dropped.

    Run:
        swipl -l demos/arc3_verify_demo.pl -g run_verify_demo -t halt
*/

% Load the backend under test.
:- use_module('../src/mentova/mentova_arc_chat').
% co_verify, to seed the fatality model directly.
:- use_module(library(co_verify), [vb_reset/0, vb_note_fatal/3]).
% List helpers.
:- use_module(library(lists), [member/2, memberchk/2, last/2]).

% report(+Id, +Goal): print PASS or FAIL for one criterion.
report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> V = 'PASS' ; V = 'FAIL' ),
    format("~w: ~w~n", [Id, V]).

% A frame: an avatar (colour 5) at (1,1), a deadly enemy (colour 9) at (1,2) to its
% right, and open background (0) to its left at (1,0).
frame([
    [0,0,0,0],
    [0,5,9,0],
    [0,0,0,0],
    [0,0,0,0]
]).

% run_verify_demo: seed the world model and check the predictions.
run_verify_demo :-
    % Announce.
    format("~n=== Verify-Before-Act Integration ===~n~n", []),
    % A clean world model and a demo game.
    catch(vb_reset, _, true),
    G = vfdemo, frame(F),
    retractall(mentova_arc_chat:ma_deadly_colour_(G, _)),
    retractall(mentova_arc_chat:ma_avatar_(G, _, _)),
    retractall(mentova_arc_chat:ma_move_vec_(G, _, _, _)),
    % The avatar is at (1,1); action(3) moves it right (+0,+1), action(4) left.
    assertz(mentova_arc_chat:ma_avatar_(G, 1, 1)),
    assertz(mentova_arc_chat:ma_move_vec_(G, action(3), 0, 1)),
    assertz(mentova_arc_chat:ma_move_vec_(G, action(4), 0, -1)),

    % AC-001: a hazard delta that introduced colour 9 teaches that 9 is deadly.
    report('AC-VF-001',
        ( mentova_arc_chat:ma_learn_deadly(G, [changed(1, 2, 0, 9)]),
          mentova_arc_chat:ma_deadly_colour(G, 9) )),

    % AC-002: stepping RIGHT lands the avatar on the colour-9 enemy — predicted fatal.
    report('AC-VF-002',
        mentova_arc_chat:ma_predict_fatal(G, F, action(3))),

    % AC-003: stepping LEFT lands on background — NOT predicted fatal.
    report('AC-VF-003',
        \+ mentova_arc_chat:ma_predict_fatal(G, F, action(4))),

    % AC-004: a non-movement action fatal in two distinct states is predicted fatal
    % in a brand-new state, by co_verify's generalisation (the model feeds through).
    report('AC-VF-004',
        ( vb_note_fatal(G, s(one), action(6)),
          vb_note_fatal(G, s(two), action(6)),
          mentova_arc_chat:ma_predict_fatal(G, F, action(6)) )),

    % AC-005: deprioritising keeps the safe left step ahead and sends the fatal
    % right step to the back, dropping nothing.
    report('AC-VF-005',
        ( mentova_arc_chat:ma_deprioritise_fatal(G, F, [action(3), action(4)], Ranked),
          Ranked = [action(4), action(3)] )),

    format("~n", []).
