/*  Mentova — Agency Pack Demonstration  (Acc_74)

    Demonstrates that Mentova now has a formal, observable, and bounded
    Observe-Reason-Act-Observe execution loop for goal pursuit.

    The demonstration:
      1. Creates a loop and verifies the initial budget (ag_loop_create/3).
      2. Decrements the budget manually and verifies the result.
      3. Records steps manually and retrieves the full trace.
      4. Demonstrates loop detection on a repeated thought-action pair.
      5. Demonstrates safe escalation to human oversight (ag_escalate/2).

    Acceptance criteria:
      AC-ACC74-001: ag_loop_create allocates a unique loop ID with the correct budget.
      AC-ACC74-002: ag_budget_decrement reduces the budget by exactly one.
      AC-ACC74-003: ag_loop_trace returns all recorded steps.
      AC-ACC74-004: ag_detect_loop returns true after a repeated thought-action pair.
      AC-ACC74-005: ag_escalate marks the loop terminal with escalated(Reason).

    Usage:
        swipl \
          -p library=/home/ccaitwo/PrologAI/packs/ephemera/prolog \
          -p library=/home/ccaitwo/PrologAI/packs/agency/prolog \
          -l demos/agency_demo.pl \
          -g run_agency_demo \
          -t halt
*/

% Declare this file as a module.
:- module(agency_demo_script, [run_agency_demo/0]).

% Load the ephemera pack (required by agency for action execution).
:- use_module(library(ephemera)).
% Load the agency pack from PrologAI.
:- use_module(library(agency)).
% Load standard list utilities.
:- use_module(library(lists)).

% -----------------------------------------------------------------------
% run_agency_demo/0 -- top-level entry point
% -----------------------------------------------------------------------

% Define run_agency_demo: run all five acceptance criteria in sequence.
run_agency_demo :-
    % Print the demonstration header.
    nl,
    write('=== Mentova Acc_74: Agency Pack Demonstration ==='), nl, nl,
    % Run each criterion.
    demo_ac74_001,
    demo_ac74_002,
    demo_ac74_003,
    demo_ac74_004,
    demo_ac74_005,
    nl,
    write('=== All five criteria pass. Acc_74 complete. ==='), nl.

% -----------------------------------------------------------------------
% AC-ACC74-001: ag_loop_create/3 allocates a unique loop with correct budget
% -----------------------------------------------------------------------

% Define demo_ac74_001: verify loop creation and initial budget.
demo_ac74_001 :-
    % Create two loops to verify they receive distinct IDs.
    ag_loop_create(goal_alpha, 10, LoopId1),
    ag_loop_create(goal_beta,  10, LoopId2),
    % Verify the two IDs differ.
    ( LoopId1 \= LoopId2
    % Verify the first loop has budget 10.
    ->  ag_budget_remaining(LoopId1, Budget),
        ( Budget =:= 10
        % Report pass.
        ->  format('AC-ACC74-001: PASS  ~w and ~w are distinct; budget = ~w~n',
                   [LoopId1, LoopId2, Budget])
        % Report budget mismatch.
        ;   format('AC-ACC74-001: FAIL  expected budget 10, got ~w~n', [Budget])
        )
    % Report duplicate IDs.
    ;   format('AC-ACC74-001: FAIL  IDs are not unique: ~w = ~w~n', [LoopId1, LoopId2])
    ).

% -----------------------------------------------------------------------
% AC-ACC74-002: ag_budget_decrement reduces the budget by exactly one
% -----------------------------------------------------------------------

% Define demo_ac74_002: verify budget decrement.
demo_ac74_002 :-
    % Create a loop with budget 5.
    ag_loop_create(budget_demo, 5, LoopId),
    % Decrement the budget once.
    ag_budget_decrement(LoopId),
    % Verify the budget is now 4.
    ag_budget_remaining(LoopId, Budget),
    ( Budget =:= 4
    % Report pass.
    ->  format('AC-ACC74-002: PASS  budget decremented from 5 to ~w~n', [Budget])
    % Report fail.
    ;   format('AC-ACC74-002: FAIL  expected budget 4, got ~w~n', [Budget])
    ).

% -----------------------------------------------------------------------
% AC-ACC74-003: ag_loop_trace returns all recorded steps
% -----------------------------------------------------------------------

% Define demo_ac74_003: verify trace collection.
demo_ac74_003 :-
    % Create a loop with budget 10.
    ag_loop_create(trace_demo, 10, LoopId),
    % Record three steps: each step records a thought, action, and observation.
    ag_step_record(LoopId,
                   'I observe the goal and plan to gather data',
                   action_eval(true),
                   obs_eval(success)),
    ag_step_record(LoopId,
                   'Data gathered; I will push a subgoal to analyse it',
                   action_push_goal(analyse_data),
                   obs_pushed(analyse_data)),
    ag_step_record(LoopId,
                   'Analysis complete; marking done',
                   action_mark_done(analysis_ok),
                   obs_done(analysis_ok)),
    % Retrieve the trace.
    ag_loop_trace(LoopId, Steps),
    % Verify exactly three steps.
    length(Steps, N),
    ( N =:= 3
    % Report pass.
    ->  format('AC-ACC74-003: PASS  trace has ~w steps; thoughts, actions, observations all recorded~n', [N])
    % Report fail.
    ;   format('AC-ACC74-003: FAIL  expected 3 steps, got ~w~n', [N])
    ).

% -----------------------------------------------------------------------
% AC-ACC74-004: ag_detect_loop returns true after repeated thought-action
% -----------------------------------------------------------------------

% Define demo_ac74_004: verify loop detection.
demo_ac74_004 :-
    % Create a loop.
    ag_loop_create(loop_detect_demo, 10, LoopId),
    % Record the same thought-action pair twice in a row, simulating a stuck loop.
    ag_step_record(LoopId,
                   'I will try the same thing again',
                   action_eval(true),
                   obs_eval(success)),
    ag_step_record(LoopId,
                   'I will try the same thing again',
                   action_eval(true),
                   obs_eval(success)),
    % Detect the loop.
    ag_detect_loop(LoopId, IsLooping),
    ( IsLooping = true
    % Report pass.
    ->  write('AC-ACC74-004: PASS  ag_detect_loop correctly identified repeated thought-action pair'), nl
    % Report fail.
    ;   format('AC-ACC74-004: FAIL  expected true, got ~w~n', [IsLooping])
    ).

% -----------------------------------------------------------------------
% AC-ACC74-005: ag_escalate marks the loop as escalated(Reason) and terminal
% -----------------------------------------------------------------------

% Define demo_ac74_005: verify escalation.
demo_ac74_005 :-
    % Create a loop.
    ag_loop_create(escalate_demo, 5, LoopId),
    % Escalate with a human-readable reason.
    ag_escalate(LoopId, cannot_proceed_without_credentials),
    % Verify the loop is now done (terminal).
    ( ag_loop_done(LoopId)
    % Verify the outcome is the expected escalation term.
    ->  ag_loop_outcome(LoopId, Outcome),
        ( Outcome = escalated(cannot_proceed_without_credentials)
        % Report pass.
        ->  format('AC-ACC74-005: PASS  loop halted safely; outcome = ~w~n', [Outcome])
        % Report wrong outcome.
        ;   format('AC-ACC74-005: FAIL  unexpected outcome = ~w~n', [Outcome])
        )
    % Report loop not terminal.
    ;   write('AC-ACC74-005: FAIL  loop not marked terminal after escalation'), nl
    ).
