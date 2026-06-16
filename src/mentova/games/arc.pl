/*  Mentova — ARC-AGI Driver  (Abstraction and Reasoning Corpus)

    Drives Mentova on Abstraction and Reasoning Corpus tasks.

    ARC-AGI (Abstraction and Reasoning Corpus for Artificial General Intelligence)
    is a benchmark created by Francois Chollet (2019).  Each task presents several
    (input_grid, output_grid) training pairs and one test input grid.  The system
    must induce the transformation rule from the training pairs and apply it to
    the test input — with no pretraining on the corpus.

    This driver encodes three toy ARC-style tasks as Prolog node_facts and uses
    Mentova's inductive reasoning to solve them.  All grids are represented as
    lists of rows; each row is a list of colour integers (0 = black, 1-9 = colours).

    Predicates exposed to game_body.pl:
        arc(observe, GameId, Frame)          — return current task frame
        arc(act,     GameId, Action, Result) — apply a proposed grid
        arc(reason,  GameId, Frame, Step,    — induce rule, propose output
                     QueryType, Action, Just)

    Standalone predicates:
        arc_task/3          — TaskId, TrainingPairs, TestInput
        arc_expected/2      — TaskId, ExpectedOutput (for verification)
        arc_solve/3         — TaskId, ProposedGrid, Justification
        arc_verify/3        — TaskId, ProposedGrid, Verdict
*/

% Declare this file as the 'arc' module, making its predicates available to other modules.
:- module(arc, [
    % Supply 'arc/3' for the observe interface (arc(observe, GameId, Frame)).
    arc/3,
    % Supply 'arc/4' for the act interface (arc(act, GameId, Action, Result)).
    arc/4,
    % Supply 'arc/7' for the reason interface (arc(reason, GameId, Frame, StepN, Type, Action, Just)).
    arc/7,
    % Supply 'arc_task/3' as the next argument to the expression above.
    arc_task/3,
    % Supply 'arc_expected/2' as the next argument to the expression above.
    arc_expected/2,
    % Supply 'arc_solve/3' as the next argument to the expression above.
    arc_solve/3,
    % Supply 'arc_verify/3' as the next argument to the expression above.
    arc_verify/3,
    % Supply 'arc_set_task/2' as the next argument to the expression above.
    arc_set_task/2
% Close the expression opened above.
]).

% Load the built-in 'lists' library so member, nth1, length, numlist, and select are available.
:- use_module(library(lists), [member/2, nth1/3, numlist/3, select/3]).
% Load the built-in 'apply' library so maplist is available.
:- use_module(library(apply), [maplist/2, maplist/3]).

% Allow 'arc_task/3' to appear at non-consecutive positions in this file.
:- discontiguous arc_task/3.
% Allow 'arc_expected/2' to appear at non-consecutive positions in this file.
:- discontiguous arc_expected/2.

% Declare 'arc_current_task/2' as dynamic so it can be set at game enrollment time.
:- dynamic arc_current_task/2.     % GameId, TaskId
% Declare 'arc_proposed/2' as dynamic so proposed outputs can be stored.
:- dynamic arc_proposed/2.         % GameId, ProposedGrid

% ---------------------------------------------------------------------------
% ARC Task Library
%
% Each task has:
%   arc_task(TaskId, TrainingPairs, TestInput)
%       TrainingPairs = list of pair(InputGrid, OutputGrid)
%       TestInput     = InputGrid
%   arc_expected(TaskId, ExpectedOutput)
%
% Grids: list of rows; each row is a list of colour integers.
% Colours: 0=black, 1=blue, 2=red, 3=green, 4=yellow, 5=grey, 6=fuchsia, 7=orange
% ---------------------------------------------------------------------------

% TASK 1 — "recolor": replace every non-black cell with a fixed colour.
% The training pairs show that all coloured (non-zero) cells become colour 2 (red).
% State the fact: arc task 'recolor_to_red' has the given training pairs and test input.
arc_task(recolor_to_red,
    % Training pair 1: single blue cell becomes single red cell.
    [ pair([[0,1,0],[0,0,0],[0,0,0]],
           [[0,2,0],[0,0,0],[0,0,0]]),
      % Training pair 2: two yellow cells become two red cells.
      pair([[0,0,4],[0,4,0],[0,0,0]],
           [[0,0,2],[0,2,0],[0,0,0]]),
      % Training pair 3: three orange cells become three red cells.
      pair([[7,0,0],[0,0,7],[0,7,0]],
           [[2,0,0],[0,0,2],[0,2,0]])
    ],
    % Test input: an L-shaped pattern in colour 3 (green).
    [[3,0,0],[3,0,0],[3,3,0]]
).
% State the fact: the expected output for 'recolor_to_red' replaces green with red.
arc_expected(recolor_to_red, [[2,0,0],[2,0,0],[2,2,0]]).

% TASK 2 — "horizontal_flip": mirror the grid left-to-right.
% State the fact: arc task 'horizontal_flip' has the given training pairs and test input.
arc_task(horizontal_flip,
    % Training pair 1: single cell on left appears on right after flip.
    [ pair([[1,0,0],[0,0,0],[0,0,0]],
           [[0,0,1],[0,0,0],[0,0,0]]),
      % Training pair 2: two cells swap sides.
      pair([[2,0,3],[0,0,0],[0,0,0]],
           [[3,0,2],[0,0,0],[0,0,0]]),
      % Training pair 3: diagonal becomes anti-diagonal.
      pair([[4,0,0],[0,4,0],[0,0,4]],
           [[0,0,4],[0,4,0],[4,0,0]])
    ],
    % Test input: an asymmetric pattern to be flipped.
    [[1,2,0],[0,0,3],[4,0,0]]
).
% State the fact: the expected output for 'horizontal_flip' is the left-right mirror.
arc_expected(horizontal_flip, [[0,2,1],[3,0,0],[0,0,4]]).

% TASK 3 — "fill_border": set all border cells to colour 5 (grey), keep interior.
% State the fact: arc task 'fill_border' has the given training pairs and test input.
arc_task(fill_border,
    % Training pair 1: a 3x3 grid — all 8 border cells become grey (5).
    [ pair([[0,0,0],[0,1,0],[0,0,0]],
           [[5,5,5],[5,1,5],[5,5,5]]),
      % Training pair 2: the interior cell keeps its value.
      pair([[0,0,0],[0,3,0],[0,0,0]],
           [[5,5,5],[5,3,5],[5,5,5]]),
      % Training pair 3: a different interior value is preserved.
      pair([[0,0,0],[0,7,0],[0,0,0]],
           [[5,5,5],[5,7,5],[5,5,5]])
    ],
    % Test input: a 3x3 grid with colour 2 (red) in the center.
    [[0,0,0],[0,2,0],[0,0,0]]
).
% State the fact: the expected output fills the border with grey around red center.
arc_expected(fill_border, [[5,5,5],[5,2,5],[5,5,5]]).

% ---------------------------------------------------------------------------
% Primitive grid transformations
% arc_grid_transform(+Rule, +InputGrid, -OutputGrid)
% ---------------------------------------------------------------------------

% Define a clause for 'arc_grid_transform' — recolor_nonblack(C) replaces all non-zero cells with C.
arc_grid_transform(recolor_nonblack(C), InputGrid, OutputGrid) :-
    % Apply the recolor transformation to each row of the grid.
    maplist([InRow, OutRow]>>(
        % For each row, recolor each cell that is not black (0).
        maplist([In, Out]>>(
            % If the cell is black, keep it black; otherwise replace with colour C.
            ( In =:= 0 -> Out = 0 ; Out = C )
        % Apply to every cell in the row.
        ), InRow, OutRow)
    % Apply to every row in the grid.
    ), InputGrid, OutputGrid).

% Define a clause for 'arc_grid_transform' — horizontal_flip mirrors each row left-to-right.
arc_grid_transform(horizontal_flip, InputGrid, OutputGrid) :-
    % Reverse each row to produce the horizontally flipped grid.
    maplist([InRow, OutRow]>>(reverse(InRow, OutRow)), InputGrid, OutputGrid).

% Define a clause for 'arc_fill_border': set all border cells of a grid to colour C.
arc_fill_border(C, InputGrid, OutputGrid) :-
    % Get the number of rows.
    length(InputGrid, NRows),
    % Get the first row to determine the number of columns.
    InputGrid = [FirstRow|_],
    % Get the number of columns from the first row.
    length(FirstRow, NCols),
    % Transform the grid row by row using explicit recursion (avoids nested lambda issues).
    arc_fill_border_rows(C, InputGrid, 1, NRows, NCols, OutputGrid).

% Define a clause for 'arc_fill_border_rows': base case — no more rows to process.
arc_fill_border_rows(_, _, Row, NRows, _, []) :-
    % Succeed with empty output when we have processed all NRows rows.
    Row > NRows.
% Define a clause for 'arc_fill_border_rows': recursive case — process one row then recurse.
arc_fill_border_rows(C, InputGrid, Row, NRows, NCols, [OutRow|Rest]) :-
    % Ensure this row index is within bounds.
    Row =< NRows,
    % Get the input row at this position.
    nth1(Row, InputGrid, InRow),
    % Transform this row cell by cell.
    arc_fill_border_row(C, InRow, 1, NCols, Row, NRows, OutRow),
    % Advance to the next row.
    NextRow is Row + 1,
    % Recurse for the remaining rows.
    arc_fill_border_rows(C, InputGrid, NextRow, NRows, NCols, Rest).

% Define a clause for 'arc_fill_border_row': base case — no more cells in this row.
arc_fill_border_row(_, [], _, _, _, _, []).
% Define a clause for 'arc_fill_border_row': recursive case — process one cell then recurse.
arc_fill_border_row(C, [InCell|RestIn], Col, NCols, Row, NRows, [OutCell|RestOut]) :-
    % If this is a border position (first/last row or column), set the cell to colour C; else copy input.
    ( ( Row =:= 1 ; Row =:= NRows ; Col =:= 1 ; Col =:= NCols )
    ->  OutCell = C
    ;   OutCell = InCell
    ),
    % Advance to the next column index.
    NextCol is Col + 1,
    % Recurse for the remaining cells in this row.
    arc_fill_border_row(C, RestIn, NextCol, NCols, Row, NRows, RestOut).

% ---------------------------------------------------------------------------
% Rule induction: arc_induce_rule/3
%
% Given a list of training pairs, find the simplest transformation rule
% that explains all of them.  Checks candidate rules in order of complexity.
% arc_induce_rule(+TrainingPairs, -Rule, -Justification)
% ---------------------------------------------------------------------------

% Define a clause for 'arc_induce_rule': try each candidate rule against all training pairs.
arc_induce_rule(TrainingPairs, Rule, Justification) :-
    % Try each candidate transformation rule in order of simplest to most complex.
    member(Rule, [
        % Try recoloring all non-black cells to each possible colour.
        recolor_nonblack(1), recolor_nonblack(2), recolor_nonblack(3),
        recolor_nonblack(4), recolor_nonblack(5), recolor_nonblack(6),
        recolor_nonblack(7), recolor_nonblack(8), recolor_nonblack(9),
        % Try horizontal mirror.
        horizontal_flip,
        % Try border fill with each possible colour.
        fill_border(5), fill_border(1), fill_border(2)
    ]),
    % Verify this rule reproduces every output in the training pairs.
    forall(
        % For each training pair.
        member(pair(InGrid, OutGrid), TrainingPairs),
        % The rule applied to InGrid must produce exactly OutGrid.
        arc_apply_rule(Rule, InGrid, OutGrid)
    ),
    % Build the justification explaining which rule was induced and why.
    length(TrainingPairs, NPairs),
    Justification = just(arc_induction, rule(Rule),
                         verified_on(NPairs, training_pairs),
                         method(search_and_verify)).

% ---------------------------------------------------------------------------
% arc_apply_rule/3  — apply a named rule to a grid
% ---------------------------------------------------------------------------

% Define a clause for 'arc_apply_rule' for the recolor_nonblack family of rules.
arc_apply_rule(recolor_nonblack(C), InGrid, OutGrid) :-
    % Apply the recolor transformation and check that the result matches OutGrid.
    arc_grid_transform(recolor_nonblack(C), InGrid, Computed),
    % Verify the computed output matches the expected output.
    Computed = OutGrid.

% Define a clause for 'arc_apply_rule' for the horizontal_flip rule.
arc_apply_rule(horizontal_flip, InGrid, OutGrid) :-
    % Apply horizontal flip and verify the result.
    arc_grid_transform(horizontal_flip, InGrid, Computed),
    % Check equality.
    Computed = OutGrid.

% Define a clause for 'arc_apply_rule' for the fill_border family of rules.
arc_apply_rule(fill_border(C), InGrid, OutGrid) :-
    % Apply border fill and verify the result.
    arc_fill_border(C, InGrid, Computed),
    % Check equality.
    Computed = OutGrid.

% ---------------------------------------------------------------------------
% arc_solve/3  — solve a task: induce the rule and apply it to the test input
%
%   TaskId        — the arc_task identifier
%   ProposedGrid  — the proposed output for the test input
%   Justification — glass-box justification naming the induced rule
% ---------------------------------------------------------------------------

% Define a clause for 'arc_solve': induce the transformation rule and apply it to the test input.
arc_solve(TaskId, ProposedGrid, Justification) :-
    % Look up the task's training pairs and test input.
    arc_task(TaskId, TrainingPairs, TestInput),
    % Induce the transformation rule from the training pairs.
    arc_induce_rule(TrainingPairs, Rule, InductionJust),
    % Apply the induced rule to the test input to produce the proposed output.
    arc_apply_rule(Rule, TestInput, ProposedGrid),
    % Build the full justification combining induction and application.
    Justification = just(arc_solve, TaskId,
                         induced(Rule, InductionJust),
                         applied_to(TestInput),
                         produced(ProposedGrid)).

% ---------------------------------------------------------------------------
% arc_verify/3  — compare proposed output against the known expected output
% ---------------------------------------------------------------------------

% Define a clause for 'arc_verify': check whether the proposed grid matches the expected output.
arc_verify(TaskId, ProposedGrid, Verdict) :-
    % Look up the expected output for this task.
    arc_expected(TaskId, Expected),
    % Compare the proposed grid to the expected output.
    ( ProposedGrid = Expected
    % If they match, the verdict is pass.
    ->  Verdict = pass(TaskId, correct_output)
    % If they differ, the verdict is fail with the expected output shown.
    ;   Verdict = fail(TaskId, expected(Expected), got(ProposedGrid))
    ).

% ---------------------------------------------------------------------------
% Driver interface — called by game_body.pl via =.. (univ) dispatch
% ---------------------------------------------------------------------------

% Define a clause for 'arc/4 observe': return the current task frame for a game instance.
arc(observe, GameId, Frame) :-
    % Look up which task this game instance is running.
    ( arc_current_task(GameId, TaskId)
    % If a task is registered, build the full frame.
    ->  arc_task(TaskId, TrainingPairs, TestInput),
        Frame = arc_frame(task(TaskId), training(TrainingPairs), test_input(TestInput))
    % If no task is registered, return an idle frame.
    ;   Frame = arc_frame(no_task_loaded, GameId)
    ).

% Define a clause for 'arc/4 act': apply a proposed output grid.
arc(act, GameId, propose_output(Grid), Result) :-
    % Store the proposed grid for this game instance.
    retractall(arc_proposed(GameId, _)),
    % Assert the new proposed grid.
    assertz(arc_proposed(GameId, Grid)),
    % Look up the current task to verify the proposal.
    ( arc_current_task(GameId, TaskId)
    % If a task is active, verify the proposed output.
    ->  arc_verify(TaskId, Grid, Verdict),
        Result = Verdict
    % If no task is active, just record the proposal.
    ;   Result = proposal_recorded(GameId, Grid)
    ).

% Define a clause for 'arc/4 reason': induce the rule and produce an action.
arc(reason, GameId, _Frame, _StepN, inductive, Action, Justification) :-
    % Look up the current task for this game instance.
    arc_current_task(GameId, TaskId),
    % Solve the task using inductive reasoning.
    arc_solve(TaskId, ProposedGrid, SolveJust),
    % The action is to propose the solved output grid.
    Action = propose_output(ProposedGrid),
    % The justification explains the full inductive chain.
    Justification = SolveJust.

% ---------------------------------------------------------------------------
% Helper: set the active task for a game instance
% ---------------------------------------------------------------------------

% Define a clause for 'arc_set_task': associate a game instance with a task.
arc_set_task(GameId, TaskId) :-
    % Remove any previous task association.
    retractall(arc_current_task(GameId, _)),
    % Assert the new task association.
    assertz(arc_current_task(GameId, TaskId)).
