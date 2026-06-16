/*  Mentova — Rung 22: Diagrammatic Reasoning Module

    Reads a small grid or layout and answers spatial pattern questions.
    The grid is a list of rows, each row a list of symbols.

    Pass criterion: spatial pattern correctly interpreted.
*/

:- module(diagrammatic, [
    mentova_diagrammatic/3
]).

:- use_module(library(lists), [member/2, nth1/3, append/3]).

% ---------------------------------------------------------------------------
% Grid representation: grid(Name, Rows)
% Rows: list of lists, row 1 is top
% ---------------------------------------------------------------------------

named_grid(example,
    [[o, o, x, o],
     [o, x, o, o],
     [x, o, o, x],
     [o, o, x, o]]).

named_grid(simple3x3,
    [[a, b, c],
     [d, e, f],
     [g, h, i]]).

named_grid(cross,
    [[o, x, o],
     [x, x, x],
     [o, x, o]]).

% ---------------------------------------------------------------------------
% Grid operations
% ---------------------------------------------------------------------------

grid_cell(Grid, Row, Col, Cell) :-
    nth1(Row, Grid, RowList),
    nth1(Col, RowList, Cell).

grid_dimensions(Grid, NRows, NCols) :-
    length(Grid, NRows),
    ( NRows > 0 -> nth1(1, Grid, Row1), length(Row1, NCols) ; NCols = 0 ).

% Count occurrences of a symbol
count_symbol([], _, 0).
count_symbol([Row|Rest], Sym, N) :-
    count_in_row(Row, Sym, N1),
    count_symbol(Rest, Sym, N2),
    N is N1 + N2.

count_in_row([], _, 0).
count_in_row([H|T], Sym, N) :-
    count_in_row(T, Sym, N1),
    ( H = Sym -> N is N1 + 1 ; N is N1 ).

% Find all positions of a symbol
find_symbol(Grid, Sym, Positions) :-
    findall(row(R)-col(C),
            ( nth1(R, Grid, Row), nth1(C, Row, Sym) ),
            Positions).

% Pattern: diagonal check (main diagonal of NxN grid is all same symbol?)
diagonal_pattern(Grid, Sym, Answer) :-
    grid_dimensions(Grid, N, N),  % square grid
    ( forall(between(1, N, I), grid_cell(Grid, I, I, Sym))
    ->  Answer = yes_diagonal(Sym)
    ;   Answer = no_diagonal
    ).

% Centre cell of an odd-dimensioned grid
centre_cell(Grid, Cell) :-
    grid_dimensions(Grid, N, N),
    N mod 2 =:= 1,
    Mid is (N + 1) // 2,
    grid_cell(Grid, Mid, Mid, Cell).

% ---------------------------------------------------------------------------
% mentova_diagrammatic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_diagrammatic(read_cell(GridName, R, C), Cell,
                      just(diagrammatic(GridName, cell(R,C), value(Cell)))) :-
    named_grid(GridName, Grid),
    grid_cell(Grid, R, C, Cell).

mentova_diagrammatic(count(GridName, Sym), Count,
                      just(diagrammatic(GridName, symbol(Sym), count(Count)))) :-
    named_grid(GridName, Grid),
    count_symbol(Grid, Sym, Count).

mentova_diagrammatic(find(GridName, Sym), Positions,
                      just(diagrammatic(GridName, symbol(Sym), positions(Positions)))) :-
    named_grid(GridName, Grid),
    find_symbol(Grid, Sym, Positions).

mentova_diagrammatic(dimensions(GridName), dims(R, C),
                      just(diagrammatic(GridName, dimensions(rows(R), cols(C))))) :-
    named_grid(GridName, Grid),
    grid_dimensions(Grid, R, C).

mentova_diagrammatic(diagonal(GridName, Sym), Answer,
                      just(diagrammatic(GridName, diagonal_check(Sym), Answer))) :-
    named_grid(GridName, Grid),
    diagonal_pattern(Grid, Sym, Answer).

mentova_diagrammatic(centre(GridName), Cell,
                      just(diagrammatic(GridName, centre_cell(Cell)))) :-
    named_grid(GridName, Grid),
    centre_cell(Grid, Cell).

mentova_diagrammatic(pattern(cross, centre_cross), Analysis,
                      just(diagrammatic(cross, pattern_analysis(Analysis)))) :-
    named_grid(cross, Grid),
    centre_cell(Grid, Centre),
    count_symbol(Grid, x, Count),
    Analysis = [centre(Centre), x_count(Count), shape(cross_pattern)].
