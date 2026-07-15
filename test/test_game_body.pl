/*  Mentova — Game-as-a-Body Harness Test Suite

    Genuine PLUnit coverage for src/mentova/game_body.pl (Volume 6, Part 7),
    the harness that enrolls interactive game environments as bodies under the
    Mind-Body pattern and runs the perceive-reason-act cycle. The module
    exports game_enroll/3, game_observe/3, game_act/4, game_reason/5,
    game_loop/5, game_history/2, game_enrolled/1, and game_driver/2, and
    dispatches every observe/reason/act to a driver module named by the
    enrollment (Driver:Driver(observe,...) at arity 3, act at arity 4, reason
    at arity 7).

    The suite installs a deterministic mock driver at load time, then drives
    the full cycle with real assertions on the produced percepts, actions,
    confirmations, step counter, history log, and loop stopping conditions.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_game_body.pl
*/

% Declare this file as a test module with no exports.
:- module(test_game_body, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(game_body)).

% game_body_test_install_driver/0 installs a deterministic mock driver the harness can dispatch to.
game_body_test_install_driver :-
    % An observe call returns a frame term that carries the game id back verbatim.
    assertz(( mock_driver:mock_driver(observe, GameId, frame(GameId)) )),
    % An act call always confirms with the fixed result atom 'ok', whatever the action.
    assertz(( mock_driver:mock_driver(act, _ActGameId, _Action, ok) )),
    % A reason call names the action and justification after the step number it was given.
    assertz(( mock_driver:mock_driver(reason, _ReasonGameId, _Frame, StepN, _QueryType,
                                      step_action(StepN), just_step(StepN)) )).

% Install the mock driver once, at load time, before the test block opens.
:- game_body_test_install_driver.

% Open the test block for the game_body module.
:- begin_tests(game_body).

% AC-GAMEBODY-001: enrolling a game registers it as a body and records its driver.
test(enroll_registers_body_and_driver) :-
    % Enroll a game whose driver is the installed mock and with three capabilities.
    game_enroll(enroll_g, mock_driver, [perceive, act, induce]),
    % The enrolled game is now reported as a live game body.
    assertion(game_enrolled(enroll_g)),
    % The driver lookup returns exactly the driver the enrollment named.
    game_driver(enroll_g, Driver),
    % That driver is the mock driver atom.
    assertion(Driver == mock_driver),
    % A game that was never enrolled is not reported as a body.
    assertion(\+ game_enrolled(never_enrolled_game)).

% AC-GAMEBODY-002: observing a fresh game wraps the driver frame in a step-0 perception signal.
test(observe_wraps_frame_as_percept) :-
    % Enroll a fresh game to observe.
    game_enroll(observe_g, mock_driver, [perceive]),
    % Observe the current game state as a percept, binding the reported step number.
    game_observe(observe_g, StepN, Percept),
    % A freshly enrolled game is observed at step zero (its counter starts at zero).
    assertion(StepN == 0),
    % The percept is a visual perception_signal wrapping the driver frame, game id, driver, and step.
    assertion(Percept = perception_signal(visual,
                                          game_frame(observe_g, mock_driver, 0, frame(observe_g)),
                                          _Timestamp)).

% AC-GAMEBODY-003: reasoning over a percept returns the driver's recommended action and justification.
test(reason_returns_driver_action_and_justification) :-
    % Enroll a fresh game to reason about.
    game_enroll(reason_g, mock_driver, [perceive]),
    % Observe it to obtain a percept to reason over.
    game_observe(reason_g, _StepN, Percept),
    % Apply the harness reasoning with an inductive query type.
    game_reason(reason_g, Percept, inductive, Action, Justification),
    % The mock driver names the action after the step number carried in the percept (zero here).
    assertion(Action == step_action(0)),
    % The mock driver names the justification after that same step number.
    assertion(Justification == just_step(0)).

% AC-GAMEBODY-004: acting confirms with the driver result, advances the step counter, and logs the step.
test(act_confirms_advances_counter_and_logs) :-
    % Enroll a fresh game to act on.
    game_enroll(act_g, mock_driver, [act]),
    % Dispatch an action with a caller-supplied justification.
    game_act(act_g, my_action, my_justification, Confirmation),
    % The confirmation carries the game id, step zero, the action, the driver result, and the justification.
    assertion(Confirmation = confirmed(act_g, 0, my_action, ok, just(my_justification))),
    % Observing again shows the step counter advanced to one after the act.
    game_observe(act_g, StepAfter, _Percept),
    % The counter is now one, proving game_act incremented it.
    assertion(StepAfter == 1),
    % The history holds exactly the one logged step, keyed to step zero with the percept-then-act marker.
    game_history(act_g, History),
    % That single entry records the step number, the action wrapper, and the confirmation verbatim.
    assertion(History = [step(0, percept_then_act(my_action),
                              confirmed(act_g, 0, my_action, ok, just(my_justification)))]).

% AC-GAMEBODY-005: the loop under max_steps runs exactly MaxSteps perceive-reason-act cycles.
test(loop_runs_max_steps) :-
    % Enroll a fresh game to loop over.
    game_enroll(loop_g, mock_driver, [perceive, act]),
    % Run three cycles with the max_steps stopping condition (committing to the first, deterministic result).
    once(game_loop(loop_g, inductive, 3, max_steps, Log)),
    % The log holds one step_result per cycle, so exactly three entries.
    length(Log, Len),
    % There are three recorded steps.
    assertion(Len == 3),
    % The step_result step numbers run zero, one, two in chronological order.
    assertion(Log = [step_result(0, _, _, _),
                     step_result(1, _, _, _),
                     step_result(2, _, _, _)]),
    % Every cycle produced a successful confirmation from the driver's 'ok' result.
    forall(member(step_result(_, _, _, C), Log),
           % Each confirmation is a success keyed to this game with result 'ok'.
           assertion(C = confirmed(loop_g, _, _, ok, _))).

% AC-GAMEBODY-006: the always_stop condition halts the loop after a single cycle.
test(loop_stops_on_always_stop) :-
    % Enroll a fresh game to loop over.
    game_enroll(stop_g, mock_driver, [perceive, act]),
    % Run with a budget of five but the always_stop condition, which halts after the first action.
    game_loop(stop_g, inductive, 5, always_stop, Log),
    % Only the single first cycle is recorded despite the larger budget.
    assertion(Log = [step_result(0, _, _, _)]).

% Close the test block for the game_body module.
:- end_tests(game_body).
