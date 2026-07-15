/*  Mentova — Diagrammatic Reasoning Module Test Suite

    Behavioural PLUnit tests for the single exported predicate
    mentova_diagrammatic/3 of src/mentova/diagrammatic.pl. The module reads
    three built-in named grids — example (4x4), simple3x3 (3x3), and cross
    (3x3) — and answers spatial pattern queries: read a cell, count a symbol,
    find every position of a symbol, report grid dimensions, check a diagonal,
    read the centre of an odd grid, and analyse the cross pattern. Each query
    returns a result and a glass-box justification term.

    Every expected value below is computed by hand from the fixed grids in the
    module, so the tests fail if that behaviour ever changes.

    Run with the full PrologAI library path plus the Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_diagrammatic.pl
*/

% Declare this file as the test module with no exports.
:- module(test_diagrammatic, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the diagrammatic reasoning module under test from the library path.
:- use_module(library(diagrammatic)).

% Open the test block for the diagrammatic module.
:- begin_tests(diagrammatic).

% AC-DIAG-001: reading a cell returns its symbol and a cell-value justification.
test(read_cell_returns_symbol_and_justification) :-
    % Read row 2, column 3 of simple3x3, whose row 2 is [d, e, f].
    mentova_diagrammatic(read_cell(simple3x3, 2, 3), Cell, Justification),
    % The third symbol of the second row is f.
    assertion(Cell == f),
    % The justification names the grid, the cell coordinates, and the value read.
    assertion(Justification == just(diagrammatic(simple3x3, cell(2, 3), value(f)))).

% AC-DIAG-002: reading a cell from a second grid confirms the table is genuinely queried.
test(read_cell_on_example_grid) :-
    % Read row 3, column 1 of example, whose row 3 is [x, o, o, x].
    mentova_diagrammatic(read_cell(example, 3, 1), Cell, _),
    % The first symbol of the third row is x.
    assertion(Cell == x).

% AC-DIAG-003: counting a symbol sums it across every row of the grid.
test(count_symbol_across_all_rows) :-
    % Count the x symbols in example: rows contribute 1, 1, 2, and 1.
    mentova_diagrammatic(count(example, x), ExampleX, JustExample),
    % The four rows total five x symbols.
    assertion(ExampleX =:= 5),
    % The justification names the grid, the symbol, and the count.
    assertion(JustExample == just(diagrammatic(example, symbol(x), count(5)))),
    % Count the x symbols in cross: rows contribute 1, 3, and 1.
    mentova_diagrammatic(count(cross, x), CrossX, _),
    % The cross has five x symbols forming its plus shape.
    assertion(CrossX =:= 5),
    % Count the o symbols in cross: rows contribute 2, 0, and 2.
    mentova_diagrammatic(count(cross, o), CrossO, _),
    % The four corners of the cross are the only o symbols.
    assertion(CrossO =:= 4).

% AC-DIAG-004: finding a symbol lists every position in row-major order.
test(find_symbol_lists_all_positions_in_row_major_order) :-
    % Find every x in the cross grid.
    mentova_diagrammatic(find(cross, x), Positions, Justification),
    % The positions are enumerated row by row, then column by column within each row.
    assertion(Positions == [row(1)-col(2),
                            row(2)-col(1), row(2)-col(2), row(2)-col(3),
                            row(3)-col(2)]),
    % There are exactly five such positions, matching the earlier count.
    assertion(length(Positions, 5)),
    % The justification names the grid, the symbol, and the positions list.
    assertion(Justification == just(diagrammatic(cross, symbol(x), positions(Positions)))).

% AC-DIAG-005: dimensions report the row and column counts of a grid.
test(dimensions_report_rows_and_columns) :-
    % Ask for the dimensions of simple3x3.
    mentova_diagrammatic(dimensions(simple3x3), Small, JustSmall),
    % The simple grid is three rows by three columns.
    assertion(Small == dims(3, 3)),
    % The justification names the grid and its rows and columns.
    assertion(JustSmall == just(diagrammatic(simple3x3, dimensions(rows(3), cols(3))))),
    % Ask for the dimensions of example.
    mentova_diagrammatic(dimensions(example), Big, _),
    % The example grid is four rows by four columns.
    assertion(Big == dims(4, 4)).

% AC-DIAG-006: the centre of an odd-sized grid is its middle cell.
test(centre_of_odd_grid_is_middle_cell) :-
    % The centre of simple3x3 is the middle cell, whose row 2 is [d, e, f].
    mentova_diagrammatic(centre(simple3x3), SimpleCentre, JustSimple),
    % The middle cell of the three-by-three grid is e.
    assertion(SimpleCentre == e),
    % The justification names the grid and the centre cell.
    assertion(JustSimple == just(diagrammatic(simple3x3, centre_cell(e)))),
    % The centre of the cross grid sits at the intersection of the plus.
    mentova_diagrammatic(centre(cross), CrossCentre, _),
    % The middle cell of the cross is x.
    assertion(CrossCentre == x).

% AC-DIAG-007: an even-sized grid has no single centre cell, so the query fails.
test(centre_of_even_grid_has_no_answer, [fail]) :-
    % The example grid is four by four, so no middle cell exists and this must fail.
    mentova_diagrammatic(centre(example), _Cell, _Justification).

% AC-DIAG-008: a diagonal of mixed symbols is reported as no_diagonal.
test(diagonal_of_mixed_diagonal_is_no_diagonal) :-
    % The cross diagonal reads o, x, o, so it is not uniformly o.
    mentova_diagrammatic(diagonal(cross, o), CrossAnswer, JustCross),
    % A non-uniform diagonal yields the no_diagonal verdict.
    assertion(CrossAnswer == no_diagonal),
    % The justification carries the same verdict alongside the grid and symbol checked.
    assertion(JustCross == just(diagrammatic(cross, diagonal_check(o), no_diagonal))),
    % The example diagonal reads o, x, o, o, so it too is not uniformly o.
    mentova_diagrammatic(diagonal(example, o), ExampleAnswer, _),
    % Its verdict is likewise no_diagonal.
    assertion(ExampleAnswer == no_diagonal).

% AC-DIAG-009: the cross-pattern analysis reports the centre, the x count, and the shape.
test(pattern_analysis_of_cross) :-
    % Run the built-in centre-cross pattern analysis over the cross grid.
    mentova_diagrammatic(pattern(cross, centre_cross), Analysis, Justification),
    % The analysis reports the centre cell x, the five x symbols, and the cross shape.
    assertion(Analysis == [centre(x), x_count(5), shape(cross_pattern)]),
    % The justification wraps the same analysis under the cross grid.
    assertion(Justification == just(diagrammatic(cross, pattern_analysis(Analysis)))).

% Close the test block for the diagrammatic module.
:- end_tests(diagrammatic).
