/*  Mentova — Autonomous ARC-AGI-3 Agent Driver

    The mentova_arc_agi_3_chat application (Acc_426) plays an ARC-AGI-3-style
    game with a human giving clues. This driver is its unaided sibling: it
    plays with no human at all. It wires the PrologAI ARC-AGI-3 Readiness suite
    (WP-397 through WP-400) onto the arc3_harness harness so Mentova can, on its
    own, explore an unknown interactive environment, work out what winning
    means, spend its actions frugally, and speak the live protocol exactly —
    the four things the ARC-AGI-3 benchmark actually measures.

    What each pack contributes to one turn:
      curiosity   ranks the environment's actions best-first — an action the
                   causal graph predicts will change the frame beats a dead
                   one, ties break to the least-tried, hazards are never
                   chosen — and expands the ACTION6 cell-select to a few
                   object-centroid clicks instead of thousands of blind cells.
      causal_core /    the harness induces a reified causal relation from each
      causal_learning     frame delta and tags a penalty delta preventive.
      goal_inference watches the frame changes before a win and hypothesises the
                   unstated win condition, with a confidence reading.
      efficiency_governor     counts the actions spent and scores the run against a human
                   baseline the way the benchmark does.
      arc3_protocol for a live run, packages the exact March-2026 REST protocol
                   as the environment the loop plays.

    Two environments ship here. a3_local_env/1 is a self-contained mock — a
    tiny "raise the counter to win" game whose mechanics the agent has never
    seen — so the whole autonomous loop runs and is tested offline. a3_live_env/4
    wraps arc3_protocol's guarded adapter for the real benchmark; it never
    load-bears a test.

    Driver interface for game_body.pl (the Game-as-a-Body harness):
      arc_agi_3(observe, GameId, Frame)               current frame
      arc_agi_3(act,     GameId, Action, Result)      apply one action
      arc_agi_3(reason,  GameId, Frame, StepN,        recommend an action by the
                         QueryType, Action, Just)     exploration policy, glass-box

    Autonomous predicates:
      a3_reset/0            -- clear the agent and the mock game
      a3_local_env/1        -- -Env   (the built-in mock environment)
      a3_live_env/4         -- +BaseUrl, +ApiKey, +GameId, -Env  (the live one)
      a3_set_baseline/1     -- +HumanActions  (the efficiency baseline)
      a3_autoplay/3         -- +Env, +Budget, -Outcome  (the unaided episode)
      a3_inferred_goal/1    -- -Goal  (what the agent decided winning means)
      a3_efficiency/1       -- -Report  (the RHAE-style ledger of the last run)
      a3_trace/1            -- -Steps   (the glass-box episode trace)
*/

% Declare this file as the autonomous ARC-AGI-3 driver module.
:- module(arc_agi_3, [
    % arc_agi_3/3: the observe interface for game_body.
    arc_agi_3/3,
    % arc_agi_3/4: the act interface for game_body.
    arc_agi_3/4,
    % arc_agi_3/7: the reason interface for game_body.
    arc_agi_3/7,
    % a3_reset/0: clear the agent and the mock game.
    a3_reset/0,
    % a3_local_env/1: the built-in mock environment.
    a3_local_env/1,
    % a3_live_env/4: the guarded live environment.
    a3_live_env/4,
    % a3_set_baseline/1: set the human efficiency baseline.
    a3_set_baseline/1,
    % a3_autoplay/3: the unaided episode loop.
    a3_autoplay/3,
    % a3_inferred_goal/1: the win condition the agent inferred.
    a3_inferred_goal/1,
    % a3_efficiency/1: the efficiency ledger of the last run.
    a3_efficiency/1,
    % a3_trace/1: the glass-box episode trace.
    a3_trace/1
]).

% Register the PrologAI pack directories before any use_module fires.
:- initialization((
    % The grid pack for frames and diffs.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/grid/prolog')),
    % The object detector the exploration policy uses for click targets.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/gridobj/prolog')),
    % The noun backbone the Causalontology core rests on.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/noun_backbone/prolog')),
    % The realizable hinge.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/realizable_hinge/prolog')),
    % The Causalontology core.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/causal_core/prolog')),
    % The interventional learner.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/causal_learning/prolog')),
    % The planner.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_plan/prolog')),
    % The perceive-learn-plan-act harness.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/arc3_harness/prolog')),
    % The exploration policy (WP-397).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/curiosity/prolog')),
    % The goal inference (WP-398).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/goal_inference/prolog')),
    % The efficiency governor (WP-399).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/efficiency_governor/prolog')),
    % The protocol vocabulary and live adapter (WP-400).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/arc3_protocol/prolog'))
), now).

% Load the harness for frame deltas and its reset.
:- use_module(library(arc3_harness), [arc3_harness_delta/3, arc3_harness_reset/0]).
% Load the learner for causal induction and preventive tagging.
:- use_module(library(causal_learning), [causal_learning_causal/2, causal_learning_preventive/2, causal_learning_reset/0]).
% Load the exploration policy.
:- use_module(library(curiosity),
    [curiosity_reset/0, curiosity_choose/4, curiosity_mark_seen/1, curiosity_would_loop/1]).
% Load the goal inference.
:- use_module(library(goal_inference),
    [goal_inference_reset/0, goal_inference_observe/2, goal_inference_hypothesise_goal/1, goal_inference_confidence/1]).
% Load the efficiency governor.
:- use_module(library(efficiency_governor),
    [efficiency_governor_reset/0, efficiency_governor_count/1, efficiency_governor_actions/2, efficiency_governor_set_baseline/2,
     efficiency_governor_baseline/2, efficiency_governor_level_score/3]).
% Load the protocol adapter for the live environment.
:- use_module(library(arc3_protocol), [arc3_protocol_env/4]).
% Load grid cell access for the mock win test.
:- use_module(library(grid), [gd_cell/4]).
% Load list helpers.
:- use_module(library(lists), [member/2, memberchk/2]).

% ---------------------------------------------------------------------------
% Agent state
% ---------------------------------------------------------------------------

% a3_tries_/2: (Action, Count) — the agent's own curiosity counters.
:- dynamic a3_tries_/2.
% a3_last_action_/1: the action taken on the most recent turn.
:- dynamic a3_last_action_/1.
% a3_trace_/1: step(N, Action, State) — the glass-box episode trace.
:- dynamic a3_trace_/1.
% a3_mock_level_/1: the hidden level counter of the built-in mock game.
:- dynamic a3_mock_level_/1.
% a3_baseline_/1: the human efficiency baseline, kept across episode resets.
:- dynamic a3_baseline_/1.

% Define a3_reset: clear the agent and every pack's episode state.
a3_reset :-
    % Drop the agent's curiosity counters.
    retractall(a3_tries_(_, _)),
    % Drop the last action.
    retractall(a3_last_action_(_)),
    % Drop the trace.
    retractall(a3_trace_(_)),
    % Reset the harness.
    arc3_harness_reset,
    % Reset the learner.
    causal_learning_reset,
    % Reset the exploration memory.
    curiosity_reset,
    % Reset the goal inference.
    goal_inference_reset,
    % Reset the efficiency governor (clears counters and baselines).
    efficiency_governor_reset,
    % Re-apply the configured human baseline so it survives the reset.
    ( a3_baseline_(H) -> efficiency_governor_set_baseline(mock, H) ; true ).

% ---------------------------------------------------------------------------
% The built-in mock game — hidden mechanics the agent must discover
% ---------------------------------------------------------------------------
% A three-by-three world. A hidden counter rises when the transfer action
% (action(5)) is pressed and the idle action (action(1)) does nothing. Only
% the bottom-right cell reflects progress: empty at counter zero, part-lit
% (colour four) at counter one, and lit to the goal colour three at counter
% two, where the level is won. Nothing tells the agent any of this.

% a3_mock_render(+Level, -Frame): render the mock state as a grid.
a3_mock_render(Level, [[0, 0, 0], [0, 0, 0], [0, 0, Goal]]) :-
    % The goal cell is empty, then part-lit, then lit as the counter rises.
    ( Level >= 2 -> Goal = 3 ; Level >= 1 -> Goal = 4 ; Goal = 0 ).

% a3_mock_reset(-Frame0): reset the mock game to counter zero.
a3_mock_reset(Frame0) :-
    % Forget any previous counter.
    retractall(a3_mock_level_(_)),
    % Start the counter at zero.
    assertz(a3_mock_level_(0)),
    % Render the starting frame.
    a3_mock_render(0, Frame0).

% a3_mock_act(+Action, -Frame1): apply one action to the mock game.
% The transfer action raises the counter, capped at two.
a3_mock_act(action(5), Frame1) :-
    % Read and remove the current counter.
    retract(a3_mock_level_(L)),
    % Raise it, but never past two.
    L1 is min(2, L + 1),
    % Store the new counter.
    assertz(a3_mock_level_(L1)),
    % Render the new frame.
    a3_mock_render(L1, Frame1),
    % Commit to this clause for the transfer action.
    !.
% Any other action leaves the counter unchanged.
a3_mock_act(_Action, Frame1) :-
    % Read the current counter.
    a3_mock_level_(L),
    % Render the unchanged frame.
    a3_mock_render(L, Frame1).

% a3_mock_actions(-Actions): the actions the mock game affords.
a3_mock_actions([action(1), action(5)]).

% a3_mock_solved(+Frame): the level is won when the goal cell is colour three.
a3_mock_solved(Frame) :-
    % Read the bottom-right cell.
    gd_cell(Frame, 2, 2, 3).

% Define a3_local_env: the built-in mock as a pluggable arc3_harness environment.
a3_local_env(arc3_env(
    % The reset goal.
    arc_agi_3:a3_mock_reset,
    % The act goal.
    arc_agi_3:a3_mock_act,
    % The actions goal.
    arc_agi_3:a3_mock_actions,
    % The win test.
    arc_agi_3:a3_mock_solved)).

% Define a3_live_env: the guarded live ARC-AGI-3 environment.
a3_live_env(BaseUrl, ApiKey, GameId, Env) :-
    % Delegate to the protocol adapter, which speaks the exact API.
    arc3_protocol_env(BaseUrl, ApiKey, GameId, Env).

% ---------------------------------------------------------------------------
% The efficiency baseline
% ---------------------------------------------------------------------------

% Define a3_set_baseline: set the human action baseline for scoring.
a3_set_baseline(Human) :-
    % Remember it so it survives an episode reset.
    retractall(a3_baseline_(_)),
    % Store the configured baseline.
    assertz(a3_baseline_(Human)),
    % Record it against the single mock level identifier.
    efficiency_governor_set_baseline(mock, Human).

% ---------------------------------------------------------------------------
% The autonomous episode loop
% ---------------------------------------------------------------------------

% Define a3_autoplay: play one episode unaided under an action budget.
a3_autoplay(Env, Budget, Outcome) :-
    % Start from a clean agent and pack state.
    a3_reset,
    % Unpack the reset goal.
    Env = arc3_env(ResetGoal, _, _, _),
    % Reset the environment and receive the first frame.
    call(ResetGoal, Frame0),
    % Remember the starting state so a return to it is a loop.
    curiosity_mark_seen(Frame0),
    % Run the recursion from step zero.
    a3_loop(Env, Frame0, 0, Budget, Outcome).

% a3_loop(+Env, +Frame, +Steps, +Budget, -Outcome): the episode recursion.
a3_loop(Env, Frame, Steps, Budget, Outcome) :-
    % Unpack the win test.
    Env = arc3_env(_, _, _, SolvedGoal),
    % Decide the state of the episode.
    (   call(SolvedGoal, Frame)
    % Already won on entry (a zero-length win).
    ->  Outcome = won(Steps)
    % The budget is spent without a win.
    ;   Steps >= Budget
    ->  Outcome = budget_exhausted
    % Otherwise take one autonomous turn and continue.
    ;   a3_turn(Env, Frame, Frame1, Action, State),
        % One more action has been spent.
        Steps1 is Steps + 1,
        % Record the turn, with the action taken, in the glass-box trace.
        assertz(a3_trace_(step(Steps1, Action, State))),
        (   State == win
        % A win ends the episode with the step count.
        ->  Outcome = won(Steps1)
        % Otherwise recurse on the new frame.
        ;   a3_loop(Env, Frame1, Steps1, Budget, Outcome)
        )
    ).

% a3_turn(+Env, +Frame, -Frame1, -Action, -State): one observe-choose-act-learn turn.
a3_turn(arc3_env(_, ActGoal, ActionsGoal, SolvedGoal), Frame, Frame1, Action, State) :-
    % Ask the environment which actions it affords.
    call(ActionsGoal, Actions),
    % Gather the agent's own try counts.
    a3_tries_list(Tried),
    % Let the exploration policy choose the next action.
    curiosity_choose(Actions, Tried, Frame, Action),
    % Count the try.
    a3_bump_try(Action),
    % Remember it for the justification endpoint.
    retractall(a3_last_action_(_)),
    % Store the last action.
    assertz(a3_last_action_(Action)),
    % Perform the action and receive the next frame.
    call(ActGoal, Action, Frame1),
    % The change between the frames is the observed effect.
    arc3_harness_delta(Frame, Frame1, Delta),
    % Learn from the effect.
    a3_learn(Action, Delta),
    % Spend one action against the efficiency budget.
    efficiency_governor_count(mock),
    % Classify the resulting state for goal inference.
    (   call(SolvedGoal, Frame1)
    % A win.
    ->  State = win
    % A penalty delta is a loss signal.
    ;   memberchk(changed(_, _, _, 15), Delta)
    ->  State = game_over
    % Otherwise the episode is still going.
    ;   State = ongoing
    ),
    % Feed the delta and state to the goal inferencer.
    goal_inference_observe(Delta, State),
    % Remember the new state unless it is a state already seen (a loop).
    ( curiosity_would_loop(Frame1) -> true ; curiosity_mark_seen(Frame1) ).

% a3_learn(+Action, +Delta): induce a relation or tag a hazard from the delta.
a3_learn(_Action, []) :- !.
% A penalty marker in the delta makes the action a hazard.
a3_learn(Action, Delta) :-
    % Detect the penalty colour among the changes.
    memberchk(changed(_, _, _, 15), Delta),
    % Tag the action preventive so it is never chosen again.
    causal_learning_preventive(Action, penalty),
    % Commit to the hazard clause.
    !.
% Otherwise the delta is the effect the action produced.
a3_learn(Action, Delta) :-
    % Induce a causal relation from the action to its effect.
    causal_learning_causal(Action, delta(Delta)).

% a3_tries_list(-Tried): the agent's try counts as an Action-Count list.
a3_tries_list(Tried) :-
    % Collect every counter.
    findall(A-N, a3_tries_(A, N), Tried).

% a3_bump_try(+Action): increment the agent's counter for an action.
a3_bump_try(Action) :-
    % Fetch and remove the current count, defaulting to zero.
    ( retract(a3_tries_(Action, N)) -> true ; N = 0 ),
    % Increment it.
    N1 is N + 1,
    % Store it back.
    assertz(a3_tries_(Action, N1)).

% ---------------------------------------------------------------------------
% Reading the run back
% ---------------------------------------------------------------------------

% Define a3_inferred_goal: the win condition the agent inferred, with confidence.
a3_inferred_goal(goal(Goal, confidence(Conf))) :-
    % The goal inferencer's best hypothesis.
    goal_inference_hypothesise_goal(Goal),
    % Its confidence.
    goal_inference_confidence(Conf).

% Define a3_efficiency: the RHAE-style ledger of the last run.
a3_efficiency(efficiency(Human, Agent, Score)) :-
    % Read how many actions the agent spent.
    efficiency_governor_actions(mock, Agent),
    % Read the human baseline if one was set.
    (   efficiency_governor_baseline(mock, Human)
    % A known baseline yields a numeric score.
    ->  efficiency_governor_level_score(Human, Agent, Score)
    % An unknown baseline leaves the human and score unknown.
    ;   Human = unknown, Score = unknown
    ).

% Define a3_trace: the glass-box episode trace in step order.
a3_trace(Steps) :-
    % Collect the recorded steps.
    findall(step(N, A, S), a3_trace_(step(N, A, S)), Unsorted),
    % Order them by step number.
    msort(Unsorted, Steps).

% ---------------------------------------------------------------------------
% The game_body.pl driver interface
% ---------------------------------------------------------------------------

% arc_agi_3(observe, +GameId, -Frame): the current mock frame.
arc_agi_3(observe, _GameId, Frame) :-
    % Ensure the mock game has a counter, starting one if needed.
    ( a3_mock_level_(L) -> true ; a3_mock_reset(_), a3_mock_level_(L) ),
    % Render the current frame.
    a3_mock_render(L, Frame).

% arc_agi_3(act, +GameId, +Action, -Result): apply one action to the mock.
arc_agi_3(act, _GameId, Action, frame(Frame1)) :-
    % Apply the action and return the new frame as the result.
    a3_mock_act(Action, Frame1).

% arc_agi_3(reason, +GameId, +Frame, +StepN, +QueryType, -Action, -Just):
% recommend the next action by the exploration policy, glass-box.
arc_agi_3(reason, _GameId, Frame, _StepN, _QueryType, Action,
          just(exploration_policy, chose(Action))) :-
    % The actions the mock affords.
    a3_mock_actions(Actions),
    % The agent's current try counts.
    a3_tries_list(Tried),
    % Let the exploration policy choose.
    curiosity_choose(Actions, Tried, Frame, Action).
