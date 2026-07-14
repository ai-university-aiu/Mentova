/*  Mentova — ARC-AGI-3 Human-Step Solo Controller (in J-Space)

    This is Mentova attempting an ARC-AGI-3 environment solo, the way a human
    does: not with an undifferentiated per-turn loop, but by walking the
    six-phase, thirty-micro-step human ladder — orient, probe and model, infer
    the goal, plan, execute and monitor, transfer — and keeping the step it is
    currently on live in the Jacobian Space (J-Space) workspace, so the
    Jacobian Lens reads out the whole human process as it plays.

    It uses the PrologAI human_steps pack for the ladder, the J-Space holding, and
    the discrete action-response Jacobian, and efficiency_governor for the efficiency
    score. The game is a small navigation environment (the clearest home for
    the Jacobian): a five-by-five grid with a controllable avatar (colour three)
    and a goal cell (colour four); the four actions move the avatar up, down,
    left, and right, and the level is won when the avatar reaches the goal.

    The controller plays the human way:
      Phase I   orient — observe the opening frame and the actions.
      Phase II  probe — try each action once, assemble the Jacobian, and read
                off which object it controls (the avatar).
      Phase III goal — locate the goal cell.
      Phase IV  plan — descend the Jacobian goal-gradient into a route.
      Phase V   execute — run the route under the efficiency governor to a win.
      Phase VI  transfer — note the carry-forward for the next level.
    At every phase the current human step is held in J-Space; hs3_jlens/2
    reads the process back.

    Predicates:
      hs3_nav_env/1   -- -Env    (the navigation environment as a arc3_harness quad)
      hs3_play/2      -- +Space, -Result   (play the game solo, walking the ladder)
      hs3_jlens/2     -- +Space, -Reading  (the J-Lens readout of the process)
*/

% Declare this file as the human-step solo controller module.
:- module(arc_agi_3_human_steps, [
    % hs3_nav_env/1: the navigation environment.
    hs3_nav_env/1,
    % hs3_play/2: play the game solo by walking the human ladder in J-Space.
    hs3_play/2,
    % hs3_jlens/2: the J-Lens readout of the process.
    hs3_jlens/2
]).

% Register the PrologAI pack directories before any use_module fires.
:- initialization((
    % The grid pack.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/grid/prolog')),
    % The object detector.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/gridobj/prolog')),
    % The J-Space concept workspace (Jacobian Space and Lens).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/jacobian_space/prolog')),
    % The efficiency governor.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/efficiency_governor/prolog')),
    % The human-step ladder and Jacobian.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/human_steps/prolog'))
), now).

% Load the human-step ladder, J-Space holding, and the Jacobian.
:- use_module(library(human_steps),
    [human_steps_reset/1, human_steps_enter/2, human_steps_reading/2, human_steps_ladder/1,
     human_steps_controllable/2, human_steps_jacobian/3, human_steps_goal_gradient/4]).
% Load the efficiency governor for the execution score.
:- use_module(library(efficiency_governor),
    [efficiency_governor_reset/0, efficiency_governor_set_baseline/2, efficiency_governor_count/1, efficiency_governor_actions/2, efficiency_governor_level_score/3]).
% Load list helpers.
:- use_module(library(lists), [member/2, numlist/3, reverse/2]).

% ---------------------------------------------------------------------------
% The navigation environment
% ---------------------------------------------------------------------------

% hs3_pos_/2: the avatar's current (Row, Col).
:- dynamic hs3_pos_/2.

% hs3_goal_cell(-R, -C): the fixed goal cell, bottom-right of the grid.
hs3_goal_cell(4, 4).
% hs3_start_cell(-R, -C): the fixed start cell, top-left of the grid.
hs3_start_cell(0, 0).
% hs3_dim(-N): the grid is five cells each way (indices zero to four).
hs3_dim(4).

% hs3_render(+R, +C, -Frame): render a five-by-five frame with avatar and goal.
hs3_render(R, C, Frame) :-
    % The goal cell.
    hs3_goal_cell(GR, GC),
    % The grid indices zero to four.
    numlist(0, 4, Ix),
    % Build one row per index.
    findall(Row,
        % Enumerate the rows.
        ( member(Ri, Ix),
          % Build the row's cells.
          findall(V,
              ( member(Ci, Ix), hs3_cellval(Ri, Ci, R, C, GR, GC, V) ),
              Row) ),
        Frame).

% hs3_cellval(+Ri, +Ci, +AvR, +AvC, +GR, +GC, -Value): the colour of one cell.
% The avatar (colour three) takes precedence, so a win still shows the avatar.
hs3_cellval(Ri, Ci, AvR, AvC, _, _, 3) :- Ri =:= AvR, Ci =:= AvC, !.
% The goal cell is colour four.
hs3_cellval(Ri, Ci, _, _, GR, GC, 4) :- Ri =:= GR, Ci =:= GC, !.
% Everything else is background.
hs3_cellval(_, _, _, _, _, _, 0).

% hs3_reset(-Frame0): place the avatar at the start and render.
hs3_reset(Frame0) :-
    % Forget any previous position.
    retractall(hs3_pos_(_, _)),
    % The start cell.
    hs3_start_cell(R, C),
    % Place the avatar there.
    assertz(hs3_pos_(R, C)),
    % Render the opening frame.
    hs3_render(R, C, Frame0).

% hs3_act(+Action, -Frame1): move the avatar and render, clamped to the grid.
hs3_act(Action, Frame1) :-
    % Read the current position.
    retract(hs3_pos_(R, C)),
    % The grid bound.
    hs3_dim(Max),
    % Apply the action's displacement.
    hs3_move(Action, R, C, R1, C1, Max),
    % Store the new position.
    assertz(hs3_pos_(R1, C1)),
    % Render the new frame.
    hs3_render(R1, C1, Frame1).

% hs3_move(+Action, +R, +C, -R1, -C1, +Max): clamp a directional move.
% Action one moves up (row minus one, not below zero).
hs3_move(action(1), R, C, R1, C, _) :- R1 is max(0, R - 1).
% Action two moves down (row plus one, not past the bound).
hs3_move(action(2), R, C, R1, C, Max) :- R1 is min(Max, R + 1).
% Action three moves left (column minus one, not below zero).
hs3_move(action(3), R, C, R, C1, _) :- C1 is max(0, C - 1).
% Action four moves right (column plus one, not past the bound).
hs3_move(action(4), R, C, R, C1, Max) :- C1 is min(Max, C + 1).

% hs3_actions(-Actions): the four directional actions.
hs3_actions([action(1), action(2), action(3), action(4)]).

% hs3_solved(+_Frame): the level is won when the avatar is on the goal.
hs3_solved(_Frame) :-
    % Read the avatar position.
    hs3_pos_(R, C),
    % Read the goal.
    hs3_goal_cell(GR, GC),
    % They must coincide.
    R =:= GR, C =:= GC.

% Define hs3_nav_env: the navigation environment as a arc3_harness quadruple.
hs3_nav_env(arc3_env(
    % The reset goal.
    arc_agi_3_human_steps:hs3_reset,
    % The act goal.
    arc_agi_3_human_steps:hs3_act,
    % The actions goal.
    arc_agi_3_human_steps:hs3_actions,
    % The win test.
    arc_agi_3_human_steps:hs3_solved)).

% ---------------------------------------------------------------------------
% Walking the human-step ladder, solo, in J-Space
% ---------------------------------------------------------------------------

% Define hs3_play: play the navigation game by walking the human ladder.
hs3_play(Space, result(Outcome, actions(Actions), score(Score),
                       controllable(Ctrl), goal(cell(GR, GC)), plan(Plan))) :-
    % Open the J-Space workspace at the first human step.
    human_steps_reset(Space),
    % The navigation environment.
    hs3_nav_env(Env),
    % Phase I — orient: hold the remaining orientation steps.
    hs3_hold(Space, ['I.2', 'I.3']),
    % Phase II — probe: hold the exploration steps.
    hs3_hold(Space, ['II.1','II.2','II.3','II.4','II.5','II.6','II.7','II.8']),
    % Try each action once and assemble the transitions.
    hs3_probe(Env, Transitions),
    % Read off which object the agent controls (the avatar).
    human_steps_controllable(Transitions, Ctrl),
    % Build the discrete action-response Jacobian for it.
    human_steps_jacobian(Transitions, Ctrl, Jacobian),
    % Phase III — goal: hold the goal-inference steps.
    hs3_hold(Space, ['III.1','III.2','III.3','III.4','III.5','III.6']),
    % Locate the goal cell.
    hs3_goal_cell(GR, GC),
    % Phase IV — plan: hold the planning steps.
    hs3_hold(Space, ['IV.1','IV.2','IV.3','IV.4']),
    % The avatar's start cell.
    hs3_start_cell(FR, FC),
    % Descend the goal gradient into a route.
    hs3_plan(Jacobian, cell(FR, FC), cell(GR, GC), Plan),
    % Phase V — execute: hold the execution steps.
    hs3_hold(Space, ['V.1','V.2','V.3','V.4','V.5']),
    % Run the route under the efficiency governor.
    hs3_execute(Env, Plan, Outcome, Actions, Score),
    % Phase VI — transfer: hold the carry-forward steps.
    hs3_hold(Space, ['VI.1','VI.2','VI.3','VI.4']).

% hs3_hold(+Space, +StepIds): hold each step in J-Space, in order.
hs3_hold(Space, StepIds) :-
    % Enter every listed step, decaying the earlier ones as it goes.
    forall(member(S, StepIds), human_steps_enter(Space, S)).

% hs3_probe(+Env, -Transitions): try each action once from the start.
hs3_probe(arc3_env(Reset, Act, Actions, _), Transitions) :-
    % The available actions.
    call(Actions, As),
    % One transition per action, each from a fresh reset.
    findall(t(A, F0, F1),
        % Take each action.
        ( member(A, As),
          % Reset to the start and read the frame.
          call(Reset, F0),
          % Apply the action and read the next frame.
          call(Act, A, F1) ),
        Transitions).

% hs3_plan(+Jacobian, +From, +Goal, -Plan): greedy descent of the goal gradient.
hs3_plan(Jacobian, cell(FR, FC), cell(GR, GC), Plan) :-
    % Simulate from the start, capped so a stall cannot loop forever.
    hs3_descend(Jacobian, FR, FC, GR, GC, 0, 40, [], Rev),
    % The route was accumulated in reverse.
    reverse(Rev, Plan).

% hs3_descend(+Jac, +R, +C, +GR, +GC, +Step, +Cap, +Acc, -Plan): the recursion.
% The goal is reached.
hs3_descend(_, R, C, GR, GC, _, _, Acc, Acc) :- R =:= GR, C =:= GC, !.
% The step cap is hit.
hs3_descend(_, _, _, _, _, Step, Cap, Acc, Acc) :- Step >= Cap, !.
% Otherwise take the gradient's best action and continue.
hs3_descend(Jac, R, C, GR, GC, Step, Cap, Acc, Plan) :-
    % The best action from here by the goal gradient.
    human_steps_goal_gradient(Jac, cell(R, C), cell(GR, GC), [Best | _]),
    % Its modelled displacement.
    member(jac(Best, DR, DC), Jac),
    % The grid bound.
    hs3_dim(Max),
    % The simulated next cell, clamped like the real environment.
    R1 is max(0, min(Max, R + DR)),
    % The simulated next column.
    C1 is max(0, min(Max, C + DC)),
    % Guard against a clamped no-progress step.
    (   R1 =:= R, C1 =:= C
    % No progress means stop with what we have.
    ->  Plan = Acc
    % Otherwise record the action and continue.
    ;   Step1 is Step + 1,
        hs3_descend(Jac, R1, C1, GR, GC, Step1, Cap, [Best | Acc], Plan)
    ).

% hs3_execute(+Env, +Plan, -Outcome, -Actions, -Score): run the route, scored.
hs3_execute(Env, Plan, Outcome, Actions, Score) :-
    % Unpack the reset goal.
    Env = arc3_env(Reset, _, _, _),
    % Clear the efficiency counters.
    efficiency_governor_reset,
    % The human baseline is the shortest route length (Manhattan distance).
    efficiency_governor_set_baseline(nav, 8),
    % Reset the environment to the start.
    call(Reset, _),
    % Run the plan until the win.
    hs3_run(Env, Plan, Outcome),
    % How many actions were spent.
    efficiency_governor_actions(nav, Actions),
    % The efficiency score against the human baseline.
    efficiency_governor_level_score(8, Actions, Score).

% hs3_run(+Env, +Plan, -Outcome): execute actions, stopping at the win.
% A win at the current state ends execution.
hs3_run(arc3_env(_, _, _, Solved), _, won) :- call(Solved, _), !.
% An exhausted plan without a win ends unfinished.
hs3_run(_, [], unfinished) :- !.
% Otherwise perform the next action and continue.
hs3_run(Env, [A | As], Outcome) :-
    % Unpack the act goal.
    Env = arc3_env(_, Act, _, _),
    % Perform the action.
    call(Act, A, _F1),
    % Count it against the efficiency budget.
    efficiency_governor_count(nav),
    % Continue with the rest of the plan.
    hs3_run(Env, As, Outcome).

% Define hs3_jlens: the J-Lens readout of the human process in the workspace.
hs3_jlens(Space, Reading) :-
    % Delegate to the ladder's reading, which reads the Jacobian Lens.
    human_steps_reading(Space, Reading).
