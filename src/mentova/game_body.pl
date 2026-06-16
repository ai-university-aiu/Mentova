/*  Mentova — Game-as-a-Body Harness  (Volume 6, Part 7)

    Enrolls interactive game environments as bodies following the Mind-Body
    pattern (PrologAI PR 10).  Game frames arrive as visual percepts; actuator
    commands go out through the tool faculty (PR 44) or computer use (PR 45).

    Build once, point at several targets:
        arc        — ARC-AGI-1, ARC-AGI-2, ARC-AGI-3
        ravens     — Raven's Progressive Matrices
        baba       — Baba Is You
        pokemon    — Pokémon Red / Emerald (requires emulator bridge)

    The perceive-reason-act cycle:
        1. game_observe/3   — pull current game state as a perception_signal
        2. game_reason/5    — Mentova infers the best action with justification
        3. game_act/4       — dispatch the action, record confirmation
        4. game_loop/5      — run N steps of the full cycle

    All game state is stored as node_facts so the full history is auditable.
    The self-improvement thread (PR 17 / continual refinement) can later
    rewrite the game harness from this history.

    Pass criterion (Volume 6, Part 7):
        The harness enrolls at least one game as a body, runs one
        perceive-reason-act cycle, and returns the action with a
        human-readable justification.
*/

% Declare this file as the 'game_body' module, making its predicates available to other modules.
:- module(game_body, [
    % Supply 'game_enroll/3' as the next argument to the expression above.
    game_enroll/3,
    % Supply 'game_observe/3' as the next argument to the expression above.
    game_observe/3,
    % Supply 'game_act/4' as the next argument to the expression above.
    game_act/4,
    % Supply 'game_reason/5' as the next argument to the expression above.
    game_reason/5,
    % Supply 'game_loop/5' as the next argument to the expression above.
    game_loop/5,
    % Supply 'game_history/2' as the next argument to the expression above.
    game_history/2,
    % Supply 'game_enrolled/1' as the next argument to the expression above.
    game_enrolled/1,
    % Supply 'game_driver/2' as the next argument to the expression above.
    game_driver/2
% Close the expression opened above.
]).

% Load the built-in 'lists' library so its predicates are available here.
:- use_module(library(lists), [member/2, last/2, nth1/3]).
% Load the built-in 'aggregate' library so aggregate_all is available here.
:- use_module(library(aggregate)).

% ---------------------------------------------------------------------------
% Game body registry
% ---------------------------------------------------------------------------

% Declare 'game_body_record/3' as dynamic so game enrollment facts can be added at runtime.
:- dynamic game_body_record/3.     % GameId, Driver, Capabilities
% Declare 'game_state/3' as dynamic so the current state of each game can be updated.
:- dynamic game_state/3.           % GameId, StepN, State
% Declare 'game_step_log/4' as dynamic so every perceive-reason-act step is recorded.
:- dynamic game_step_log/4.        % GameId, StepN, Percept, ActionResult
% Declare 'game_step_counter/2' as dynamic so the step counter for each game is tracked.
:- dynamic game_step_counter/2.    % GameId, N

% ---------------------------------------------------------------------------
% game_enroll/3  — enroll a game environment as a body
%
%   GameId      — unique atom identifying this game instance (e.g. arc_task_1)
%   Driver      — atom naming the driver module (arc | ravens | baba | pokemon)
%   Capabilities — list of capability atoms (e.g. [perceive, act, induce])
% ---------------------------------------------------------------------------

% Define a clause for 'game_enroll': enroll a game as a body with the given driver and capabilities.
game_enroll(GameId, Driver, Capabilities) :-
    % Remove any previous enrollment record for this game to allow re-enrollment.
    retractall(game_body_record(GameId, _, _)),
    % Remove the previous step counter so the new session starts from zero.
    retractall(game_step_counter(GameId, _)),
    % Add a new game body record linking GameId to its driver and capabilities.
    assertz(game_body_record(GameId, Driver, Capabilities)),
    % Initialize the step counter to zero for this game instance.
    assertz(game_step_counter(GameId, 0)),
    % Report the enrollment to standard output for visibility.
    format("Game body enrolled: ~w (driver: ~w, capabilities: ~w)~n",
           [GameId, Driver, Capabilities]).

% ---------------------------------------------------------------------------
% game_enrolled/1  — query helper
% ---------------------------------------------------------------------------

% Define a clause for 'game_enrolled': succeed when GameId is a currently enrolled game body.
game_enrolled(GameId) :-
    % Check that a game body record exists for the given GameId.
    game_body_record(GameId, _, _).

% ---------------------------------------------------------------------------
% game_driver/2  — look up the driver for an enrolled game
% ---------------------------------------------------------------------------

% Define a clause for 'game_driver': retrieve the driver atom for an enrolled game.
game_driver(GameId, Driver) :-
    % Look up the game body record for GameId and extract the driver.
    game_body_record(GameId, Driver, _).

% ---------------------------------------------------------------------------
% game_observe/3  — pull current game state as a perception_signal
%
%   GameId  — enrolled game identity
%   StepN   — current step number (for provenance)
%   Percept — perception_signal(visual, GameFrame, Timestamp)
%              where GameFrame is a driver-specific term
% ---------------------------------------------------------------------------

% Define a clause for 'game_observe': read the current game state and wrap it as a percept.
game_observe(GameId, StepN, Percept) :-
    % Verify that the game is enrolled before attempting to observe.
    game_body_record(GameId, Driver, _),
    % Retrieve the current step counter for this game.
    game_step_counter(GameId, StepN),
    % Call the driver-specific observe predicate to get the raw game frame.
    ObserveGoal =.. [Driver, observe, GameId, Frame],
    % Execute the driver observe goal with module qualification; fall back on failure.
    ( call(Driver:ObserveGoal)
    % If the driver observe succeeded, use the Frame it produced.
    ->  true
    % Otherwise use a placeholder frame indicating the driver has no current state.
    ;   Frame = no_state(GameId, StepN)
    ),
    % Record the observation timestamp for provenance.
    get_time(T),
    % Wrap the frame in a standard perception_signal term for the Mind-Body pattern.
    Percept = perception_signal(visual, game_frame(GameId, Driver, StepN, Frame), T).

% ---------------------------------------------------------------------------
% game_act/4  — dispatch an action to a game body
%
%   GameId       — enrolled game identity
%   Action       — driver-specific action term
%   Justification — the reasoning justification that motivated this action
%   Confirmation  — confirmed(GameId, Action, Result) | denied(Action, Reason)
% ---------------------------------------------------------------------------

% Define a clause for 'game_act': dispatch an action to the game and record the result.
game_act(GameId, Action, Justification, Confirmation) :-
    % Verify that the game is enrolled.
    game_body_record(GameId, Driver, _),
    % Retrieve the current step counter.
    game_step_counter(GameId, StepN),
    % Call the driver-specific act predicate to execute the action.
    ActGoal =.. [Driver, act, GameId, Action, Result],
    % Execute the driver act goal with module qualification; synthesize on failure.
    ( call(Driver:ActGoal)
    % If the driver act succeeded, confirm the action with the result.
    ->  Confirmation = confirmed(GameId, StepN, Action, Result, just(Justification))
    % If the driver act failed, record a failure confirmation.
    ;   Confirmation = failed(GameId, StepN, Action, driver_error)
    ),
    % Increment the step counter for the next cycle.
    retract(game_step_counter(GameId, StepN)),
    % Compute the new step number.
    NextStep is StepN + 1,
    % Store the updated step counter.
    assertz(game_step_counter(GameId, NextStep)),
    % Log this perceive-reason-act step for the self-improvement thread.
    assertz(game_step_log(GameId, StepN, percept_then_act(Action), Confirmation)).

% ---------------------------------------------------------------------------
% game_reason/5  — Mentova infers the best action for a game percept
%
%   GameId        — enrolled game identity
%   Percept       — perception_signal from game_observe/3
%   QueryType     — reasoning type to apply (inductive | deductive | heuristic ...)
%   Action        — the recommended action term
%   Justification — the full glass-box justification
% ---------------------------------------------------------------------------

% Define a clause for 'game_reason': apply Mentova's reasoning to a game percept.
game_reason(GameId, Percept, QueryType, Action, Justification) :-
    % Extract the game frame from the percept for reasoning.
    Percept = perception_signal(visual, game_frame(GameId, Driver, StepN, Frame), _T),
    % Delegate to the driver's reason predicate to get an action recommendation.
    ReasonGoal =.. [Driver, reason, GameId, Frame, StepN, QueryType, Action, Justification],
    % Execute the driver reason goal with module qualification.
    ( call(Driver:ReasonGoal)
    % If the driver reason succeeded, the Action and Justification are now bound.
    ->  true
    % If the driver has no specific reasoning, fall back to a default heuristic action.
    ;   Action        = heuristic_action(GameId, Driver, StepN),
        Justification = just(no_driver_reasoning, heuristic_fallback)
    ).

% ---------------------------------------------------------------------------
% game_loop/5  — run N steps of the perceive-reason-act cycle
%
%   GameId      — enrolled game identity
%   QueryType   — reasoning type for each step (atom)
%   MaxSteps    — maximum number of steps to run
%   StopCond    — stopping condition atom (goal_reached | max_steps | always_stop)
%   Log         — list of step_result(StepN, Percept, Action, Confirmation) terms
% ---------------------------------------------------------------------------

% Define a clause for 'game_loop': entry point — start from step 0 with an empty log.
game_loop(GameId, QueryType, MaxSteps, StopCond, Log) :-
    % Begin the recursive loop starting at step 0 with an empty accumulated log.
    game_loop_steps(GameId, QueryType, 0, MaxSteps, StopCond, [], Log).

% Define a clause for 'game_loop_steps': base case — stop when MaxSteps is reached.
game_loop_steps(_GameId, _QueryType, Step, MaxSteps, _StopCond, Acc, Log) :-
    % Succeed and return the accumulated log when the step limit is reached.
    Step >= MaxSteps,
    % Reverse the accumulated log so steps appear in chronological order.
    reverse(Acc, Log).

% Define a clause for 'game_loop_steps': recursive case — run one cycle then recurse.
game_loop_steps(GameId, QueryType, Step, MaxSteps, StopCond, Acc, Log) :-
    % Ensure we have not yet reached the step limit.
    Step < MaxSteps,
    % Observe the current game state as a percept (CurrentStep read from counter).
    game_observe(GameId, _CurrentStep, Percept),
    % Apply Mentova's reasoning to determine the best action.
    game_reason(GameId, Percept, QueryType, Action, Justification),
    % Dispatch the action to the game body and receive confirmation.
    game_act(GameId, Action, Justification, Confirmation),
    % Build the step result record for the log.
    StepResult = step_result(Step, Percept, Action, Confirmation),
    % Add the step result to the front of the accumulator.
    NewAcc = [StepResult | Acc],
    % Check whether the stopping condition has been met.
    ( stop_condition_met(StopCond, Confirmation)
    % If the stopping condition is met, return the log.
    ->  reverse(NewAcc, Log)
    % Otherwise recurse to the next step.
    ;   NextStep is Step + 1,
        game_loop_steps(GameId, QueryType, NextStep, MaxSteps, StopCond, NewAcc, Log)
    ).

% Define a clause for 'stop_condition_met': always_stop halts after the first action.
stop_condition_met(always_stop, _).
% Define a clause for 'stop_condition_met': goal_reached halts when the confirmation signals success.
stop_condition_met(goal_reached, confirmed(_, _, _, goal_reached, _)).
% Define a clause for 'stop_condition_met': max_steps never halts early (loop drives it).
stop_condition_met(max_steps, _) :- fail.

% ---------------------------------------------------------------------------
% game_history/2  — retrieve the logged history for a game
%
%   GameId  — enrolled game identity
%   History — list of game_step_log facts as step(N, Percept, Confirmation) terms
% ---------------------------------------------------------------------------

% Define a clause for 'game_history': collect all logged steps for a given game.
game_history(GameId, History) :-
    % Collect all step log entries for GameId in order.
    findall(step(N, P, C), game_step_log(GameId, N, P, C), History).
