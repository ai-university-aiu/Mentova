/*  Mentova — Rung 22: Diagrammatic Reasoning Module

    Reads a small grid or layout and answers spatial pattern questions.
    The grid is a list of rows, each row a list of symbols.

    Pass criterion: spatial pattern correctly interpreted.
*/

% Declare this file as the 'diagrammatic' module and list its exported predicates.
:- module(diagrammatic, [
    % Supply 'mentova_diagrammatic/3' as the next argument to the expression above.
    mentova_diagrammatic/3
% Close the expression opened above.
]).

% Import [member/2, nth1/3, append/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, nth1/3, append/3]).

% ---------------------------------------------------------------------------
% Grid representation: grid(Name, Rows)
% Rows: list of lists, row 1 is top
% ---------------------------------------------------------------------------

% State a fact for 'named grid' with the arguments listed below.
named_grid(example,
    % Continue the multi-line expression started above.
    [[o, o, x, o],
     % Continue the multi-line expression started above.
     [o, x, o, o],
     % Continue the multi-line expression started above.
     [x, o, o, x],
     % Continue the multi-line expression started above.
     [o, o, x, o]]).

% State a fact for 'named grid' with the arguments listed below.
named_grid(simple3x3,
    % Continue the multi-line expression started above.
    [[a, b, c],
     % Continue the multi-line expression started above.
     [d, e, f],
     % Continue the multi-line expression started above.
     [g, h, i]]).

% State a fact for 'named grid' with the arguments listed below.
named_grid(cross,
    % Continue the multi-line expression started above.
    [[o, x, o],
     % Continue the multi-line expression started above.
     [x, x, x],
     % Continue the multi-line expression started above.
     [o, x, o]]).

% ---------------------------------------------------------------------------
% Grid operations
% ---------------------------------------------------------------------------

% Define a clause for 'grid cell': succeed when the following conditions hold.
grid_cell(Grid, Row, Col, Cell) :-
    % Retrieve the element at the specified one-based position from the list.
    nth1(Row, Grid, RowList),
    % Retrieve the element at the specified one-based position from the list.
    nth1(Col, RowList, Cell).

% Define a clause for 'grid dimensions': succeed when the following conditions hold.
grid_dimensions(Grid, NRows, NCols) :-
    % Unify 'NRows' with the number of elements in list 'Grid'.
    length(Grid, NRows),
    % Check that '( NRows' is greater than '0 -> nth1(1, Grid, Row1), length(Row1, NCols) ; NCols = 0 )'.
    ( NRows > 0 -> nth1(1, Grid, Row1), length(Row1, NCols) ; NCols = 0 ).

% Count occurrences of a symbol
% State the fact: count symbol([], _, 0).
count_symbol([], _, 0).
% Define a clause for 'count symbol': succeed when the following conditions hold.
count_symbol([Row|Rest], Sym, N) :-
    % State a fact for 'count in row' with the arguments listed below.
    count_in_row(Row, Sym, N1),
    % State a fact for 'count symbol' with the arguments listed below.
    count_symbol(Rest, Sym, N2),
    % Evaluate the arithmetic expression 'N1 + N2' and bind the result to 'N'.
    N is N1 + N2.

% State the fact: count in row([], _, 0).
count_in_row([], _, 0).
% Define a clause for 'count in row': succeed when the following conditions hold.
count_in_row([H|T], Sym, N) :-
    % State a fact for 'count in row' with the arguments listed below.
    count_in_row(T, Sym, N1),
    % Check that '( H' is unifiable with 'Sym -> N is N1 + 1 ; N is N1 )'.
    ( H = Sym -> N is N1 + 1 ; N is N1 ).

% Find all positions of a symbol
% Define a clause for 'find symbol': succeed when the following conditions hold.
find_symbol(Grid, Sym, Positions) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(row(R)-col(C),
            % Continue the multi-line expression started above.
            ( nth1(R, Grid, Row), nth1(C, Row, Sym) ),
            % Supply 'Positions' as the next argument to the expression above.
            Positions).

% Pattern: diagonal check (main diagonal of NxN grid is all same symbol?)
% Define a clause for 'diagonal pattern': succeed when the following conditions hold.
diagonal_pattern(Grid, Sym, Answer) :-
    % State a fact for 'grid dimensions' with the arguments listed below.
    grid_dimensions(Grid, N, N),  % square grid
    % Execute: ( forall(between(1, N, I), grid_cell(Grid, I, I, Sym)).
    ( forall(between(1, N, I), grid_cell(Grid, I, I, Sym))
    % If the condition above succeeded, perform the following action.
    ->  Answer = yes_diagonal(Sym)
    % Otherwise (else branch), perform the following action.
    ;   Answer = no_diagonal
    % Close the expression opened above.
    ).

% Centre cell of an odd-dimensioned grid
% Define a clause for 'centre cell': succeed when the following conditions hold.
centre_cell(Grid, Cell) :-
    % State a fact for 'grid dimensions' with the arguments listed below.
    grid_dimensions(Grid, N, N),
    % Check that 'N mod 2' is numerically equal to '1'.
    N mod 2 =:= 1,
    % Evaluate the arithmetic expression '(N + 1) // 2' and bind the result to 'Mid'.
    Mid is (N + 1) // 2,
    % State the fact: grid cell(Grid, Mid, Mid, Cell).
    grid_cell(Grid, Mid, Mid, Cell).

% ---------------------------------------------------------------------------
% mentova_diagrammatic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova diagrammatic' with the arguments listed below.
mentova_diagrammatic(read_cell(GridName, R, C), Cell,
                      % Continue the multi-line expression started above.
                      just(diagrammatic(GridName, cell(R,C), value(Cell)))) :-
    % State a fact for 'named grid' with the arguments listed below.
    named_grid(GridName, Grid),
    % State the fact: grid cell(Grid, R, C, Cell).
    grid_cell(Grid, R, C, Cell).

% State a fact for 'mentova diagrammatic' with the arguments listed below.
mentova_diagrammatic(count(GridName, Sym), Count,
                      % Continue the multi-line expression started above.
                      just(diagrammatic(GridName, symbol(Sym), count(Count)))) :-
    % State a fact for 'named grid' with the arguments listed below.
    named_grid(GridName, Grid),
    % State the fact: count symbol(Grid, Sym, Count).
    count_symbol(Grid, Sym, Count).

% State a fact for 'mentova diagrammatic' with the arguments listed below.
mentova_diagrammatic(find(GridName, Sym), Positions,
                      % Continue the multi-line expression started above.
                      just(diagrammatic(GridName, symbol(Sym), positions(Positions)))) :-
    % State a fact for 'named grid' with the arguments listed below.
    named_grid(GridName, Grid),
    % State the fact: find symbol(Grid, Sym, Positions).
    find_symbol(Grid, Sym, Positions).

% State a fact for 'mentova diagrammatic' with the arguments listed below.
mentova_diagrammatic(dimensions(GridName), dims(R, C),
                      % Continue the multi-line expression started above.
                      just(diagrammatic(GridName, dimensions(rows(R), cols(C))))) :-
    % State a fact for 'named grid' with the arguments listed below.
    named_grid(GridName, Grid),
    % State the fact: grid dimensions(Grid, R, C).
    grid_dimensions(Grid, R, C).

% State a fact for 'mentova diagrammatic' with the arguments listed below.
mentova_diagrammatic(diagonal(GridName, Sym), Answer,
                      % Continue the multi-line expression started above.
                      just(diagrammatic(GridName, diagonal_check(Sym), Answer))) :-
    % State a fact for 'named grid' with the arguments listed below.
    named_grid(GridName, Grid),
    % State the fact: diagonal pattern(Grid, Sym, Answer).
    diagonal_pattern(Grid, Sym, Answer).

% State a fact for 'mentova diagrammatic' with the arguments listed below.
mentova_diagrammatic(centre(GridName), Cell,
                      % Continue the multi-line expression started above.
                      just(diagrammatic(GridName, centre_cell(Cell)))) :-
    % State a fact for 'named grid' with the arguments listed below.
    named_grid(GridName, Grid),
    % State the fact: centre cell(Grid, Cell).
    centre_cell(Grid, Cell).

% State a fact for 'mentova diagrammatic' with the arguments listed below.
mentova_diagrammatic(pattern(cross, centre_cross), Analysis,
                      % Continue the multi-line expression started above.
                      just(diagrammatic(cross, pattern_analysis(Analysis)))) :-
    % State a fact for 'named grid' with the arguments listed below.
    named_grid(cross, Grid),
    % State a fact for 'centre cell' with the arguments listed below.
    centre_cell(Grid, Centre),
    % State a fact for 'count symbol' with the arguments listed below.
    count_symbol(Grid, x, Count),
    % Check that 'Analysis' is unifiable with '[centre(Centre), x_count(Count), shape(cross_pattern)]'.
    Analysis = [centre(Centre), x_count(Count), shape(cross_pattern)].
