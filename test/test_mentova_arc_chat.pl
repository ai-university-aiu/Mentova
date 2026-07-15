/*  Mentova — mentova_arc_agi_3_chat Test Suite  (Acc_426)

    A genuine PLUnit suite for the human-guided ARC-AGI-3 chat module. It
    exercises the module's pure, deterministic, server-free surface: the
    clue-grounding table of Causalontology_v5 Section 10.4, the locksmith
    game's exact opening frame, the pluggable environment term, the game
    registry, and the mode/source defaults and switches. Every assertion
    is checked against a value computed by hand from the module's
    documented behaviour, so a regression in any of these predicates
    turns the suite red.

    Run with the full library path over every PrologAI pack plus the
    Mentova source directory:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do \
            LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_mentova_arc_chat.pl
*/

% Declare this file as a test module with no exports.
:- module(test_mentova_arc_chat, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(mentova_arc_chat)).

% Open the test block for mentova_arc_chat.
:- begin_tests(mentova_arc_chat).

% AC-MAC-001: a "looks like a key" clue grounds to a key-like label at its cell.
test(ground_key_label) :-
    % Grounding the key clue names the cell key-like.
    assertion(co_ground('That looks like a key', [2, 2], hint_label([2, 2], key_like))).

% AC-MAC-002: a "looks like a lock" clue grounds to a lock-like label at its cell.
test(ground_lock_label) :-
    % Grounding the lock clue names the cell lock-like.
    assertion(co_ground('that looks like a lock', [0, 4], hint_label([0, 4], lock_like))).

% AC-MAC-003: a "looks like a door" clue grounds to a traverse goal at its cell.
test(ground_door_goal) :-
    % Grounding the door clue sets the walk-through goal at the door cell.
    assertion(co_ground('That looks like a door, let us walk through it', [0, 4], hint_goal([0, 4], traverse))).

% AC-MAC-004: a "pick that up" clue grounds to raising the pickup action's priority.
test(ground_pickup_action) :-
    % Grounding the pickup suggestion yields the pickup action assertion.
    assertion(co_ground('Pick that up', [2, 2], hint_action(action(pickup)))).

% AC-MAC-005: a "that hurts" clue grounds to tagging the referenced cell preventive.
test(ground_preventive) :-
    % Grounding the hazard warning tags the cell as one to avoid.
    assertion(co_ground('That hurts', [3, 3], hint_preventive([3, 3]))).

% AC-MAC-006: a praise clue grounds to the reinforcement assertion.
test(ground_reinforce) :-
    % Grounding positive feedback yields the reinforcement assertion.
    assertion(co_ground('Good, that worked', none, hint_reinforce)).

% AC-MAC-007: an encouragement clue grounds to the continue no-op assertion.
test(ground_continue) :-
    % Grounding an encouragement yields the continue assertion.
    assertion(co_ground('keep going', none, hint_continue)).

% AC-MAC-008: text that is not a recognised clue is refused (grounding fails).
test(ground_refuses_ungroundable) :-
    % A clue with no mapping-table match does not ground.
    assertion(\+ co_ground('the weather is nice today', none, _)).

% AC-MAC-009: resetting the locksmith yields its exact documented opening frame.
test(game_reset_opening_frame) :-
    % Reset the locksmith game to its start.
    ma_game_reset(Frame),
    % The player (3) starts bottom-left, the key (4) is at (2,2), the door (8)
    % is locked at (0,4), and every other cell is empty (0).
    assertion(Frame == [[0, 0, 0, 0, 8], [0, 0, 0, 0, 0], [0, 0, 4, 0, 0], [0, 0, 0, 0, 0], [3, 0, 0, 0, 0]]).

% AC-MAC-010: the current frame after a reset equals the frame the reset returned.
test(game_frame_matches_reset) :-
    % Reset and capture the returned first frame.
    ma_game_reset(F0),
    % Read the current frame independently.
    ma_game_frame(F1),
    % The two renderings agree.
    assertion(F1 == F0).

% AC-MAC-011: rendering the locksmith environment locally equals its reset frame.
test(render_local_ls20_matches_reset) :-
    % Ensure the local game source is active.
    ma_set_source(local),
    % Reset and capture the first frame.
    ma_game_reset(F0),
    % Render the locksmith environment through the uniform dispatch.
    ma_render(ls20, F1),
    % The local render of ls20 is the current frame.
    assertion(F1 == F0).

% AC-MAC-012: the pluggable environment term names the four locksmith callbacks.
test(env_term_names_callbacks) :-
    % Read the environment descriptor.
    ma_env(E),
    % It is the arc3_harness quadruple of reset, act, actions, and solved.
    assertion(E == arc3_env(mentova_arc_chat:ma_game_reset, mentova_arc_chat:ma_env_act, mentova_arc_chat:ma_env_actions, mentova_arc_chat:ma_env_solved)).

% AC-MAC-013: with the local source active, the selected game defaults to the locksmith.
test(selected_game_defaults_ls20) :-
    % Ensure the local game source is active so the default is the locksmith.
    ma_set_source(local),
    % Read the selected game.
    ma_selected_game(Id),
    % It defaults to the locksmith environment.
    assertion(Id == ls20),
    % The registry gives that game a human-readable title.
    ma_game_info(Id, Title),
    % The title is an atom.
    assertion(atom(Title)).

% AC-MAC-014: the local source offers exactly the three stand-in environments, in order.
test(available_local_games) :-
    % Ensure the local game source is active.
    ma_set_source(local),
    % Collect every available game id in the active source.
    findall(GId, ma_available_game(GId, _), Ids),
    % The three local stand-ins are the locksmith, navigation, and signal games.
    assertion(Ids == [ls20, vc33, ft09]).

% AC-MAC-015: switching mode is observable through the mode reader.
test(mode_set_and_read) :-
    % Switch to solo mode.
    ma_set_mode(solo),
    % The mode reader now reports solo.
    ma_mode(M1),
    % Confirm the switch took effect.
    assertion(M1 == solo),
    % Switch back to guided mode.
    ma_set_mode(guided),
    % The mode reader now reports guided.
    ma_mode(M2),
    % Confirm the switch back took effect.
    assertion(M2 == guided).

% AC-MAC-016: switching the game source is observable through the source reader.
test(source_set_and_read) :-
    % Switch to the live game source.
    ma_set_source(live),
    % The source reader now reports live.
    ma_source(S1),
    % Confirm the switch took effect.
    assertion(S1 == live),
    % Switch back to the local game source.
    ma_set_source(local),
    % The source reader now reports local.
    ma_source(S2),
    % Confirm the switch back took effect.
    assertion(S2 == local).

% Close the test block for mentova_arc_chat.
:- end_tests(mentova_arc_chat).
