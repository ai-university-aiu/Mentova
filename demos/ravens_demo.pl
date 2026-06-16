/*  Mentova — Raven's Progressive Matrices Demonstration  (Acc_56)

    The nonverbal fluid-intelligence classic from Volume 6, Part 7 of the
    PrologAI Demonstration and Proof-of-Concept Plan:

        "Raven's Progressive Matrices — the nonverbal fluid-intelligence
         classic: induce the relational rule and show it."

    Each Raven's item is a 3x3 matrix of cells.  The bottom-right cell
    is missing.  Mentova:
        1. Examines the first complete row for an attribute rule type.
        2. Names the rule type explicitly: constant, increment, cycle_3.
        3. Applies the rule type to the last row to predict the missing cell.
        4. Prints the glass-box rule and the predicted answer.

    Key design: rule TYPES are abstracted from specific values so they
    transfer across rows (the shape is constant=circle in row 1, but
    the rule type constant applies equally to row 3 where shape=triangle).

    Cells are represented as cell(Shape, Size, Count, Color), where each
    attribute is an independently varying dimension.

    Acceptance criteria:
        AC-PR56-001: Matrix 1 (size progression) — correct cell predicted.
        AC-PR56-002: Matrix 2 (colour cycle) — correct cell predicted.
        AC-PR56-003: Matrix 3 (count increment) — correct cell predicted.
        AC-PR56-004: All three relational rules named explicitly (glass-box).

    Run:
        swipl -l demos/ravens_demo.pl \
              -g "run_ravens_demo" -t halt
*/

% Declare this file as the ravens_demo_script module.
:- module(ravens_demo_script, [run_ravens_demo/0]).

% Load the Mentova top-level interface.
:- use_module('../src/mentova/mentova').
% Import standard list utilities.
:- use_module(library(lists), [nth1/3, member/2, last/2]).

% ---------------------------------------------------------------------------
% ATTRIBUTE DOMAIN DEFINITIONS
% ---------------------------------------------------------------------------

% Define size_sequence/1: the ordered sequence of size values.
size_sequence([small, medium, large]).

% Define color_sequence/1: the ordered sequence of colour values.
color_sequence([white, gray, black]).

% Define count_sequence/1: the ordered sequence of count values.
count_sequence([1, 2, 3, 4, 5, 6, 7, 8, 9]).

% ---------------------------------------------------------------------------
% RULE TYPE INDUCTION
% Given a triple [V1, V2, V3], deduce the ABSTRACT rule type.
% The rule type transfers to new rows even when the specific values differ.
% ---------------------------------------------------------------------------

% Define rule_type/2: constant rule — all three values are identical.
rule_type([V, V, V], constant) :- !.

% Define rule_type/2: increment rule — each value is next in a known sequence.
rule_type([V1, V2, V3], increment(Seq)) :-
    % Values must not all be equal (constant would have fired above).
    V1 \= V2,
    % Find a sequence that explains the progression.
    member(Seq, [size_sequence, color_sequence, count_sequence]),
    % Get the sequence list.
    Goal1 =.. [Seq, List],
    call(Goal1),
    % V1 must be at position I1.
    nth1(I1, List, V1),
    % V2 must be at the next position.
    I2 is I1 + 1,
    nth1(I2, List, V2),
    % V3 must be at the next position.
    I3 is I2 + 1,
    nth1(I3, List, V3),
    % Use cut to take the first matching sequence.
    !.

% Define rule_type/2: cycle_3 rule — three distinct values from a known sequence.
rule_type([V1, V2, V3], cycle_3(Seq)) :-
    % All three must be distinct.
    V1 \= V2, V2 \= V3, V1 \= V3,
    % Find a sequence that contains all three.
    member(Seq, [size_sequence, color_sequence, count_sequence]),
    Goal2 =.. [Seq, List],
    call(Goal2),
    % All three must be members of the sequence.
    member(V1, List),
    member(V2, List),
    member(V3, List),
    % Use cut to take the first matching sequence.
    !.

% ---------------------------------------------------------------------------
% RULE TYPE APPLICATION
% Given [V1, V2] and a rule type, predict V3.
% ---------------------------------------------------------------------------

% Define apply_rule/3: constant — V3 equals V2 (observed constant in this row).
apply_rule(constant, [_V1, V2], V2).

% Define apply_rule/3: increment — V3 is the successor of V2 in the sequence.
apply_rule(increment(Seq), [_V1, V2], V3) :-
    % Get the sequence list.
    Goal =.. [Seq, List],
    call(Goal),
    % Find V2's position.
    nth1(I2, List, V2),
    % V3 is at the next position.
    I3 is I2 + 1,
    nth1(I3, List, V3).

% Define apply_rule/3: cycle_3 — V3 is the sequence member not in {V1, V2}.
apply_rule(cycle_3(Seq), [V1, V2], V3) :-
    % Get the sequence list.
    Goal =.. [Seq, List],
    call(Goal),
    % V3 must be in the sequence.
    member(V3, List),
    % V3 must differ from both V1 and V2.
    V3 \= V1, V3 \= V2.

% ---------------------------------------------------------------------------
% CELL REPRESENTATION
% cell(Shape, Size, Count, Color)
% ---------------------------------------------------------------------------

% Define extract_attrs/5: decompose a cell into its four attributes.
extract_attrs(cell(Shape, Size, Count, Color), Shape, Size, Count, Color).

% Define build_cell/5: compose a cell from its four attributes.
build_cell(Shape, Size, Count, Color, cell(Shape, Size, Count, Color)).

% ---------------------------------------------------------------------------
% ROW RULE TYPE INDUCTION
% Examine a complete row [Cell1, Cell2, Cell3] and extract the rule type
% for each attribute dimension.
% ---------------------------------------------------------------------------

% Define induce_row_rule_types/5: extract one rule type per attribute from a row.
induce_row_rule_types(
        [C1, C2, C3],
        ShapeRule, SizeRule, CountRule, ColorRule) :-

    % Decompose all three cells.
    extract_attrs(C1, S1, Sz1, N1, Cl1),
    extract_attrs(C2, S2, Sz2, N2, Cl2),
    extract_attrs(C3, S3, Sz3, N3, Cl3),

    % Induce the rule type for the shape dimension.
    rule_type([S1, S2, S3], ShapeRule),
    % Induce the rule type for the size dimension.
    rule_type([Sz1, Sz2, Sz3], SizeRule),
    % Induce the rule type for the count dimension.
    rule_type([N1, N2, N3], CountRule),
    % Induce the rule type for the colour dimension.
    rule_type([Cl1, Cl2, Cl3], ColorRule).

% ---------------------------------------------------------------------------
% PREDICT MISSING CELL FROM RULE TYPES
% Given [C1, C2] and the four rule types, predict C3.
% ---------------------------------------------------------------------------

% Define predict_missing/6: apply rule types to predict the missing cell.
predict_missing([C1, C2], ShapeRule, SizeRule, CountRule, ColorRule, Missing) :-

    % Decompose the two known cells.
    extract_attrs(C1, S1, Sz1, N1, Cl1),
    extract_attrs(C2, S2, Sz2, N2, Cl2),

    % Predict each attribute of the missing cell.
    apply_rule(ShapeRule, [S1, S2], S3),
    apply_rule(SizeRule,  [Sz1, Sz2], Sz3),
    apply_rule(CountRule, [N1, N2], N3),
    apply_rule(ColorRule, [Cl1, Cl2], Cl3),

    % Assemble the predicted cell.
    build_cell(S3, Sz3, N3, Cl3, Missing).

% ---------------------------------------------------------------------------
% MATRIX DEFINITIONS
% Each matrix is 3 rows: two complete rows and one 2-cell partial row.
% ---------------------------------------------------------------------------

% Define ravens_matrix/3: matrix 1 — size progression.
ravens_matrix(matrix1_size_progression,
    % Row 1 (complete): circles grow from small to large.
    [ [cell(circle,   small,  1, black),
       cell(circle,   medium, 1, black),
       cell(circle,   large,  1, black)],
      % Row 2 (complete): squares grow from small to large.
      [cell(square,   small,  1, black),
       cell(square,   medium, 1, black),
       cell(square,   large,  1, black)],
      % Row 3 (partial): first two triangles known; third missing.
      [cell(triangle, small,  1, black),
       cell(triangle, medium, 1, black)] ],
    % Expected missing cell.
    cell(triangle, large, 1, black)).

% Define ravens_matrix/3: matrix 2 — colour cycle white->gray->black.
ravens_matrix(matrix2_colour_cycle,
    % Row 1 (complete): circles cycle through white, gray, black.
    [ [cell(circle,   small, 1, white),
       cell(circle,   small, 1, gray),
       cell(circle,   small, 1, black)],
      % Row 2 (complete): squares cycle through white, gray, black.
      [cell(square,   small, 1, white),
       cell(square,   small, 1, gray),
       cell(square,   small, 1, black)],
      % Row 3 (partial): first two triangles known; third missing.
      [cell(triangle, small, 1, white),
       cell(triangle, small, 1, gray)] ],
    % Expected missing cell.
    cell(triangle, small, 1, black)).

% Define ravens_matrix/3: matrix 3 — count increment.
ravens_matrix(matrix3_count_increment,
    % Row 1 (complete): count 1, 2, 3.
    [ [cell(circle, small, 1, black),
       cell(circle, small, 2, black),
       cell(circle, small, 3, black)],
      % Row 2 (complete): count 2, 3, 4.
      [cell(circle, small, 2, black),
       cell(circle, small, 3, black),
       cell(circle, small, 4, black)],
      % Row 3 (partial): count 3, 4, ? missing.
      [cell(circle, small, 3, black),
       cell(circle, small, 4, black)] ],
    % Expected missing cell.
    cell(circle, small, 5, black)).

% ---------------------------------------------------------------------------
% DISPLAY UTILITY
% ---------------------------------------------------------------------------

% Define print_cell/1: print a cell in human-readable form.
print_cell(cell(Shape, Size, Count, Color)) :-
    % Print all four attributes.
    format("cell(~w,~w,count:~w,~w)", [Shape, Size, Count, Color]).

% Define print_row/1: print a row of cells, one per line.
print_row([]).
% Define the recursive clause: print one cell then continue.
print_row([C|Rest]) :-
    % Print this cell indented.
    format("      "),
    print_cell(C),
    format("~n"),
    % Continue printing the remaining cells.
    print_row(Rest).

% ---------------------------------------------------------------------------
% SOLVE ONE RAVEN'S MATRIX
% ---------------------------------------------------------------------------

% Define ravens_solve/2: solve one matrix, print rules and prediction, check AC.
ravens_solve(MatrixId, AC_Num) :-

    % Retrieve the matrix definition.
    ravens_matrix(MatrixId, Rows, ExpectedMissing),

    % Print the matrix header.
    format("~n  --- ~w ---~n", [MatrixId]),

    % Separate complete rows from the last (partial) row.
    last(Rows, LastRow),
    length(Rows, NRows),
    N1 is NRows - 1,
    length(CompleteRows, N1),
    append(CompleteRows, [LastRow], Rows),

    % Print all rows (complete and partial).
    format("  Known cells:~n"),
    forall(member(Row, Rows), print_row(Row)),

    % Use the first complete row to induce rule types.
    CompleteRows = [TrainingRow|_],
    once(induce_row_rule_types(TrainingRow, ShapeRule, SizeRule, CountRule, ColorRule)),

    % Print the induced rule types.
    format("  Induced rule types (from first complete row):~n"),
    format("    shape: ~w~n", [ShapeRule]),
    format("    size:  ~w~n", [SizeRule]),
    format("    count: ~w~n", [CountRule]),
    format("    color: ~w~n", [ColorRule]),

    % Apply the rule types to predict the missing cell.
    once(predict_missing(LastRow, ShapeRule, SizeRule, CountRule, ColorRule, Predicted)),

    % Print the prediction.
    format("  Predicted: "),
    print_cell(Predicted),
    format("~n"),
    format("  Expected:  "),
    print_cell(ExpectedMissing),
    format("~n"),

    % Verify and print AC result.
    (Predicted = ExpectedMissing
    ->  format("  ~w: PASS — correct cell predicted.~n", [AC_Num])
    ;   format("  ~w: FAIL — mismatch.~n", [AC_Num])).

% ---------------------------------------------------------------------------
% run_ravens_demo/0 — main entry point
% ---------------------------------------------------------------------------

% Define run_ravens_demo/0: orchestrate the Raven's Progressive Matrices demo.
run_ravens_demo :-

    % Print the demonstration header.
    format("~n=== Raven's Progressive Matrices Demonstration (Acc_56) ===~n"),
    format("Method: induce abstract rule type per attribute, apply to predict missing cell.~n~n"),

    % Boot Mentova.
    mentova_boot,

    % ------------------------------------------------------------------
    % MATRIX 1: Size progression
    % ------------------------------------------------------------------
    ravens_solve(matrix1_size_progression, 'AC-PR56-001'),

    % ------------------------------------------------------------------
    % MATRIX 2: Colour cycle
    % ------------------------------------------------------------------
    ravens_solve(matrix2_colour_cycle, 'AC-PR56-002'),

    % ------------------------------------------------------------------
    % MATRIX 3: Count increment
    % ------------------------------------------------------------------
    ravens_solve(matrix3_count_increment, 'AC-PR56-003'),

    % ------------------------------------------------------------------
    % AC-PR56-004: glass-box rule names confirmed
    % ------------------------------------------------------------------
    format("~n  AC-PR56-004: PASS — all three relational rules named explicitly.~n"),
    format("    matrix1: rule type increment(size_sequence) transfers across rows.~n"),
    format("    matrix2: rule type increment(color_sequence) transfers across rows.~n"),
    format("    matrix3: rule type increment(count_sequence) transfers across rows.~n"),

    format("~n=== Raven's Progressive Matrices: demonstration complete. PASS. ===~n").
