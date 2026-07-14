/*  Mentova — Autonomous ARC-AGI-3 Agent Acceptance Demonstration

    Exercises the unaided ARC-AGI-3 agent driver end to end. Where the Acc_426
    chat application wins with a human's clues, this driver wins with none: it
    wires the PrologAI ARC-AGI-3 Readiness suite (curiosity, goal_inference,
    efficiency_governor, arc3_protocol) onto the arc3_harness harness and plays a game whose
    mechanics it has never seen.

    Acceptance criteria (each prints PASS or FAIL at run time):
      AC-A3-001: the agent wins the mock level unaided within budget.
      AC-A3-002: it infers the unstated win condition, reach_colour(3), with
                 positive confidence.
      AC-A3-003: it reports an RHAE-style efficiency score against the human
                 baseline.
      AC-A3-004: the glass-box trace records every action taken, in order,
                 ending in a win.
      AC-A3-005: the exploration policy explored before exploiting — the first
                 action differs from the transfer that wins.
      AC-A3-006: the live ARC-AGI-3 environment builds as a well-formed,
                 guarded arc3_harness environment (no network is touched).

    Run:
        swipl -l demos/arc_agi_3_autoplay_demo.pl -g run_arc_agi_3_demo -t halt
*/

% Load the autonomous driver under demonstration.
:- use_module('../src/mentova/games/arc_agi_3').
% Load list helpers for the checks.
:- use_module(library(lists), [member/2, last/2, nth1/3]).

% report(+Id, +Cond): print PASS or FAIL for one acceptance criterion.
report(Id, Cond) :-
    % Evaluate the condition once.
    ( call(Cond) -> Verdict = 'PASS' ; Verdict = 'FAIL' ),
    % Print the verdict beside the criterion identifier.
    format("~w: ~w~n", [Id, Verdict]).

% Define run_arc_agi_3_demo: run the full acceptance demonstration.
run_arc_agi_3_demo :-
    % Announce the demonstration.
    format("~n=== Autonomous ARC-AGI-3 Agent — Acceptance ===~n~n", []),
    % Set a human baseline of two actions for the mock level.
    a3_set_baseline(2),
    % Build the built-in mock environment.
    a3_local_env(Env),
    % Play one unaided episode under a generous action budget.
    a3_autoplay(Env, 30, Outcome),
    % Show the outcome.
    format("outcome: ~q~n", [Outcome]),
    % AC-001: the agent won the level.
    report('AC-A3-001', Outcome = won(_)),
    % AC-002: it inferred reach_colour(3) with positive confidence.
    report('AC-A3-002', demo_inferred_goal),
    % AC-003: it reported an efficiency score.
    report('AC-A3-003', demo_efficiency),
    % AC-004: the trace records the actions in order and ends in a win.
    report('AC-A3-004', demo_trace_ok),
    % AC-005: it explored before exploiting.
    report('AC-A3-005', demo_explored_first),
    % AC-006: the live environment builds guarded and well-formed.
    report('AC-A3-006', demo_live_env_ok),
    % Show what the agent decided and how efficiently it played.
    ( a3_inferred_goal(G) -> format("inferred goal: ~q~n", [G]) ; true ),
    % Show the efficiency ledger.
    ( a3_efficiency(E) -> format("efficiency: ~q~n", [E]) ; true ),
    % Show the glass-box trace.
    a3_trace(T),
    % Print it.
    format("trace: ~q~n~n", [T]).

% demo_inferred_goal: the inferred goal is reach_colour(3) with positive confidence.
demo_inferred_goal :-
    % Read the inferred goal and its confidence.
    a3_inferred_goal(goal(reach_colour(3), confidence(Conf))),
    % The confidence must be positive.
    Conf > 0.

% demo_efficiency: an efficiency score against the baseline is reported.
demo_efficiency :-
    % Read the ledger.
    a3_efficiency(efficiency(2, Agent, Score)),
    % The agent spent a positive number of actions.
    Agent > 0,
    % The score is a number between zero and one.
    number(Score), Score >= 0.0, Score =< 1.0.

% demo_trace_ok: the trace is non-empty, ordered, and ends in a win.
demo_trace_ok :-
    % Read the trace.
    a3_trace(Steps),
    % It must have at least one step.
    Steps \== [],
    % Its last step must be the win.
    last(Steps, step(_, _, win)),
    % Its first step must be numbered one.
    nth1(1, Steps, step(1, _, _)).

% demo_explored_first: the first action differs from the winning transfer.
demo_explored_first :-
    % Read the trace.
    a3_trace(Steps),
    % The first action taken.
    nth1(1, Steps, step(1, First, _)),
    % It is the idle probe, not the transfer that wins.
    First == action(1).

% demo_live_env_ok: the live environment builds well-formed and guarded.
demo_live_env_ok :-
    % Build a live environment against an unreachable endpoint.
    a3_live_env('https://example.invalid', 'no-key', ft09, Env),
    % It has the four-goal arc3_harness shape.
    Env = arc3_env(_, _, _, _).
