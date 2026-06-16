/*  Mentova — Raven's Progressive Matrices Driver

    Raven's Progressive Matrices (RPM) is a nonverbal test of fluid intelligence
    created by John C. Raven (1936).  The standard form presents a 3x3 matrix
    of figures with one cell missing; the subject must select the correct figure
    from six or eight answer choices by inducing the underlying relational rule.

    This driver encodes two toy RPM-style matrices as Prolog node_facts and
    uses Mentova's inductive and relational reasoning to solve them.

    Each matrix cell is a symbol term describing the visual figure.
    Each figure has: shape(Shape), size(Size), colour(Colour), count(N).

    Predicates exposed to game_body.pl:
        ravens(observe, GameId, Frame)                          — current matrix
        ravens(act,     GameId, Action, Result)                 — select an option
        ravens(reason,  GameId, Frame, Step, Type, Action, Just) — induce and select

    Standalone predicates:
        ravens_task/3       — TaskId, Matrix8, Options
        ravens_expected/2   — TaskId, CorrectOptionIndex
        ravens_solve/3      — TaskId, SelectedOption, Justification
*/

% Declare this file as the 'ravens' module, making its predicates available to other modules.
:- module(ravens, [
    % Supply 'ravens/3' for the observe interface.
    ravens/3,
    % Supply 'ravens/4' for the act interface.
    ravens/4,
    % Supply 'ravens/7' for the reason interface.
    ravens/7,
    % Supply 'ravens_task/3' as the next argument to the expression above.
    ravens_task/3,
    % Supply 'ravens_expected/2' as the next argument to the expression above.
    ravens_expected/2,
    % Supply 'ravens_solve/3' as the next argument to the expression above.
    ravens_solve/3,
    % Supply 'ravens_set_task/2' as the next argument to the expression above.
    ravens_set_task/2
% Close the expression opened above.
]).

% Load the built-in 'lists' library so member, nth1, length, and numlist are available.
:- use_module(library(lists), [member/2, nth1/3, numlist/3]).

% Allow 'ravens_task/3' clauses to appear at non-consecutive positions in this file.
:- discontiguous ravens_task/3.
% Allow 'ravens_expected/2' clauses to appear at non-consecutive positions in this file.
:- discontiguous ravens_expected/2.

% Declare 'ravens_current_task/2' as dynamic so a game instance can be bound to a task.
:- dynamic ravens_current_task/2.  % GameId, TaskId
% Declare 'ravens_selection/2' as dynamic so the player's selection can be stored.
:- dynamic ravens_selection/2.     % GameId, OptionIndex

% ---------------------------------------------------------------------------
% Figure representation
%
% figure(shape(Shape), size(Size), colour(Colour), count(N))
%   Shape  : circle | square | triangle | diamond
%   Size   : small | medium | large
%   Colour : black | white | grey
%   Count  : 1 | 2 | 3
% ---------------------------------------------------------------------------

% ---------------------------------------------------------------------------
% RPM Task Library
%
% Matrix is a list of 8 cells (row-major, left-to-right, top-to-bottom).
% The 9th cell (position 9, bottom-right) is the missing one to be inferred.
% Options is a list of 6 candidate figures for the missing cell.
% ---------------------------------------------------------------------------

% TASK 1 — "size progression": each row increases size left-to-right.
% Row 1: small, medium, large (all black circles)
% Row 2: small, medium, large (all white circles)
% Row 3: small, medium, ? (all grey circles — answer: large grey circle)
% State the fact: ravens_task 'size_progression' has this 8-cell matrix and 6 options.
ravens_task(size_progression,
    % The 8 known cells of the 3x3 matrix (the 9th is missing).
    [ figure(shape(circle), size(small),  colour(black), count(1)),
      figure(shape(circle), size(medium), colour(black), count(1)),
      figure(shape(circle), size(large),  colour(black), count(1)),
      figure(shape(circle), size(small),  colour(white), count(1)),
      figure(shape(circle), size(medium), colour(white), count(1)),
      figure(shape(circle), size(large),  colour(white), count(1)),
      figure(shape(circle), size(small),  colour(grey),  count(1)),
      figure(shape(circle), size(medium), colour(grey),  count(1))
    ],
    % The six answer options; the correct one is option 1.
    [ figure(shape(circle), size(large),  colour(grey),  count(1)),
      figure(shape(circle), size(small),  colour(grey),  count(1)),
      figure(shape(square), size(large),  colour(grey),  count(1)),
      figure(shape(circle), size(large),  colour(black), count(1)),
      figure(shape(circle), size(medium), colour(grey),  count(1)),
      figure(shape(circle), size(large),  colour(white), count(1))
    ]
).
% State the fact: the correct answer for 'size_progression' is option 1.
ravens_expected(size_progression, 1).

% TASK 2 — "count progression": each row increases count left-to-right.
% Row 1: 1, 2, 3 (small black squares)
% Row 2: 1, 2, 3 (small white squares)
% Row 3: 1, 2, ? (small grey squares — answer: 3 grey squares)
% State the fact: ravens_task 'count_progression' has this 8-cell matrix and 6 options.
ravens_task(count_progression,
    % The 8 known cells of the 3x3 matrix.
    [ figure(shape(square), size(small), colour(black), count(1)),
      figure(shape(square), size(small), colour(black), count(2)),
      figure(shape(square), size(small), colour(black), count(3)),
      figure(shape(square), size(small), colour(white), count(1)),
      figure(shape(square), size(small), colour(white), count(2)),
      figure(shape(square), size(small), colour(white), count(3)),
      figure(shape(square), size(small), colour(grey),  count(1)),
      figure(shape(square), size(small), colour(grey),  count(2))
    ],
    % The six answer options; the correct one is option 3.
    [ figure(shape(square), size(small), colour(white), count(3)),
      figure(shape(square), size(small), colour(black), count(3)),
      figure(shape(square), size(small), colour(grey),  count(3)),
      figure(shape(circle), size(small), colour(grey),  count(3)),
      figure(shape(square), size(large), colour(grey),  count(3)),
      figure(shape(square), size(small), colour(grey),  count(2))
    ]
).
% State the fact: the correct answer for 'count_progression' is option 3.
ravens_expected(count_progression, 3).

% ---------------------------------------------------------------------------
% Rule induction: ravens_induce_rule/3
%
% Given the 8 known cells of a matrix, induce the transformation rule.
% The matrix is read row-by-row: cells 1-3 are row 1, 4-6 are row 2, 7-9 are row 3.
% We check the three row-level rules in order.
%
% ravens_induce_rule(+Matrix8, -Rule, -Justification)
% ---------------------------------------------------------------------------

% Define a clause for 'ravens_induce_rule': try candidate rules against the known matrix.
ravens_induce_rule(Matrix8, Rule, Justification) :-
    % Try each candidate rule.
    member(Rule, [size_increases_across_row, count_increases_across_row,
                  colour_cycles_across_rows, shape_constant]),
    % Verify the rule explains the known rows.
    ravens_rule_holds(Rule, Matrix8),
    % Build the justification.
    Justification = just(ravens_induction, rule(Rule),
                         verified_on_rows(1, 2),
                         method(search_and_verify)).

% Define a clause for 'ravens_rule_holds' for size_increases_across_row.
ravens_rule_holds(size_increases_across_row, Matrix8) :-
    % Check that in each of the first two rows, size increases across columns.
    nth1(1, Matrix8, figure(_, size(S1), _, _)),
    nth1(2, Matrix8, figure(_, size(S2), _, _)),
    nth1(3, Matrix8, figure(_, size(S3), _, _)),
    % Verify size increases: small < medium < large.
    size_order(S1, S2), size_order(S2, S3),
    % Verify the same pattern holds in the second row.
    nth1(4, Matrix8, figure(_, size(S4), _, _)),
    nth1(5, Matrix8, figure(_, size(S5), _, _)),
    nth1(6, Matrix8, figure(_, size(S6), _, _)),
    size_order(S4, S5), size_order(S5, S6),
    % Verify the partial third row follows the same pattern.
    nth1(7, Matrix8, figure(_, size(S7), _, _)),
    nth1(8, Matrix8, figure(_, size(S8), _, _)),
    size_order(S7, S8).

% Define a clause for 'ravens_rule_holds' for count_increases_across_row.
ravens_rule_holds(count_increases_across_row, Matrix8) :-
    % Check that count increases across each row.
    nth1(1, Matrix8, figure(_, _, _, count(C1))),
    nth1(2, Matrix8, figure(_, _, _, count(C2))),
    nth1(3, Matrix8, figure(_, _, _, count(C3))),
    C1 < C2, C2 < C3,
    nth1(4, Matrix8, figure(_, _, _, count(C4))),
    nth1(5, Matrix8, figure(_, _, _, count(C5))),
    nth1(6, Matrix8, figure(_, _, _, count(C6))),
    C4 < C5, C5 < C6,
    nth1(7, Matrix8, figure(_, _, _, count(C7))),
    nth1(8, Matrix8, figure(_, _, _, count(C8))),
    C7 < C8.

% Define a clause for 'ravens_rule_holds' for colour_cycles_across_rows.
ravens_rule_holds(colour_cycles_across_rows, Matrix8) :-
    % Check that each row has a constant colour that changes row to row.
    nth1(1, Matrix8, figure(_, _, colour(Co1), _)),
    nth1(2, Matrix8, figure(_, _, colour(Co1), _)),
    nth1(3, Matrix8, figure(_, _, colour(Co1), _)),
    nth1(4, Matrix8, figure(_, _, colour(Co2), _)),
    Co1 \= Co2.

% Define a clause for 'ravens_rule_holds' for shape_constant.
ravens_rule_holds(shape_constant, Matrix8) :-
    % Check that all known cells have the same shape.
    nth1(1, Matrix8, figure(shape(Sh), _, _, _)),
    forall(member(F, Matrix8), F = figure(shape(Sh), _, _, _)).

% Define a clause for 'size_order': small < medium.
size_order(small, medium).
% Define a clause for 'size_order': medium < large.
size_order(medium, large).
% Define a clause for 'size_order': small < large (transitive).
size_order(small, large).

% ---------------------------------------------------------------------------
% ravens_predict_missing/3 — predict the missing 9th cell from the rule
%
% ravens_predict_missing(+Rule, +Matrix8, -Predicted)
% ---------------------------------------------------------------------------

% Define a clause for 'ravens_predict_missing' for size_increases_across_row.
ravens_predict_missing(size_increases_across_row, Matrix8, Predicted) :-
    % The missing cell is row 3, col 3: it should have the largest size.
    % Get the colour and shape from row 3 (cells 7 and 8 define them).
    nth1(7,  Matrix8, figure(shape(Sh), _, colour(Co), _)),
    % The size of the third column is always large (from the rule).
    Predicted = figure(shape(Sh), size(large), colour(Co), count(1)).

% Define a clause for 'ravens_predict_missing' for count_increases_across_row.
ravens_predict_missing(count_increases_across_row, Matrix8, Predicted) :-
    % Get the shape, size, and colour from the partial third row.
    nth1(7, Matrix8, figure(shape(Sh), size(Sz), colour(Co), _)),
    % Get the count of cell 8 to know what cell 9 should be.
    nth1(8, Matrix8, figure(_, _, _, count(C8))),
    % The next count in the sequence is C8 + 1.
    C9 is C8 + 1,
    % Build the predicted missing cell.
    Predicted = figure(shape(Sh), size(Sz), colour(Co), count(C9)).

% ---------------------------------------------------------------------------
% ravens_select_option/3 — find the option matching the predicted figure
%
% ravens_select_option(+Options, +Predicted, -OptionIndex)
% ---------------------------------------------------------------------------

% Define a clause for 'ravens_select_option': find which option matches the prediction.
ravens_select_option(Options, Predicted, OptionIndex) :-
    % Search through the options list.
    nth1(OptionIndex, Options, Predicted).

% ---------------------------------------------------------------------------
% ravens_solve/3  — induce the rule, predict the missing cell, select the option
% ---------------------------------------------------------------------------

% Define a clause for 'ravens_solve': solve a Raven's task with glass-box justification.
ravens_solve(TaskId, SelectedOption, Justification) :-
    % Load the task's matrix and options.
    ravens_task(TaskId, Matrix8, Options),
    % Induce the transformation rule from the 8 known cells.
    ravens_induce_rule(Matrix8, Rule, InductionJust),
    % Predict the missing 9th cell using the induced rule.
    ravens_predict_missing(Rule, Matrix8, Predicted),
    % Find which option matches the predicted cell.
    ravens_select_option(Options, Predicted, OptionIndex),
    % The selected option is the figure at OptionIndex.
    nth1(OptionIndex, Options, SelectedOption),
    % Build the full glass-box justification.
    Justification = just(ravens_solve, TaskId,
                         induction(InductionJust),
                         predicted(Predicted),
                         selected(option(OptionIndex), SelectedOption)).

% ---------------------------------------------------------------------------
% Driver interface — called by game_body.pl via =.. dispatch
% ---------------------------------------------------------------------------

% Define a clause for 'ravens/4 observe': return the current matrix frame.
ravens(observe, GameId, Frame) :-
    % Look up which task this game instance is running.
    ( ravens_current_task(GameId, TaskId)
    ->  ravens_task(TaskId, Matrix8, Options),
        Frame = ravens_frame(task(TaskId), matrix(Matrix8), options(Options))
    ;   Frame = ravens_frame(no_task_loaded, GameId)
    ).

% Define a clause for 'ravens/4 act': record the player's option selection.
ravens(act, GameId, select_option(N), Result) :-
    % Store the selection.
    retractall(ravens_selection(GameId, _)),
    % Assert the new selection.
    assertz(ravens_selection(GameId, N)),
    % Verify against the expected answer if a task is active.
    ( ravens_current_task(GameId, TaskId)
    ->  ravens_expected(TaskId, Correct),
        ( N =:= Correct
        ->  Result = pass(TaskId, option(N), correct)
        ;   Result = fail(TaskId, selected(N), expected(Correct))
        )
    ;   Result = selection_recorded(GameId, N)
    ).

% Define a clause for 'ravens/4 reason': induce the rule and select the best option.
ravens(reason, GameId, _Frame, _StepN, inductive, Action, Justification) :-
    % Look up the current task.
    ravens_current_task(GameId, TaskId),
    % Solve the task.
    ravens_solve(TaskId, SelectedOption, SolveJust),
    % The action is to select the option number.
    ravens_task(TaskId, _, Options),
    nth1(OptionIndex, Options, SelectedOption),
    Action = select_option(OptionIndex),
    Justification = SolveJust.

% ---------------------------------------------------------------------------
% Helper: set the active task for a game instance
% ---------------------------------------------------------------------------

% Define a clause for 'ravens_set_task': associate a game instance with a task.
ravens_set_task(GameId, TaskId) :-
    % Remove any previous task association.
    retractall(ravens_current_task(GameId, _)),
    % Assert the new task association.
    assertz(ravens_current_task(GameId, TaskId)).
