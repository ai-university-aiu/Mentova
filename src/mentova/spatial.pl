/*  Mentova — Rung 21: Spatial Reasoning Module

    Resolves containment and position using reference frames.
    Pass criterion: transitive location correct (cat on mat in kitchen).

    Supports:
      in(X, Y)        — X is contained in Y
      on(X, Y)        — X is on Y
      near(X, Y)      — X is near Y
      transitive_in   — compute full containment chain
*/

% Declare this file as the 'spatial' module and list its exported predicates.
:- module(spatial, [
    % Supply 'mentova_spatial/3' as the next argument to the expression above.
    mentova_spatial/3
% Close the expression opened above.
]).

% Import [member/2, append/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, append/3]).
% Allow 'mentova_spatial/3' clauses to appear at non-consecutive positions in this file.
:- discontiguous mentova_spatial/3.

% ---------------------------------------------------------------------------
% Spatial facts (reference frame: house layout)
% ---------------------------------------------------------------------------

% State the fact: in(mat,    kitchen).
in(mat,    kitchen).
% State a fact for 'in' with the arguments listed below.
in(cat,    mat).          % cat is on the mat, in the kitchen
% State the fact: in(book,   shelf).
in(book,   shelf).
% State the fact: in(shelf,  library).
in(shelf,  library).
% State the fact: in(library,house).
in(library,house).
% State the fact: in(kitchen,house).
in(kitchen,house).
% State the fact: in(fridge, kitchen).
in(fridge, kitchen).
% State the fact: in(food,   fridge).
in(food,   fridge).

% State the fact: on(cat,    mat).
on(cat,    mat).
% State the fact: on(cup,    table).
on(cup,    table).
% State the fact: on(table,  kitchen).
on(table,  kitchen).

% State the fact: near(cat,  fridge).
near(cat,  fridge).
% State the fact: near(cup,  cat).
near(cup,  cat).

% ---------------------------------------------------------------------------
% Transitive containment: in_transitively(X, Y) — X is ultimately in Y
% ---------------------------------------------------------------------------

% Define a clause for 'in transitively': succeed when the following conditions hold.
in_transitively(X, Y) :- in(X, Y).
% Define a clause for 'in transitively': succeed when the following conditions hold.
in_transitively(X, Y) :- in(X, Mid), in_transitively(Mid, Y).

% ---------------------------------------------------------------------------
% mentova_spatial(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Direct containment
% Define a clause for 'mentova spatial': succeed when the following conditions hold.
mentova_spatial(in(X, Y), yes, just(in(X, Y, direct))) :-
    % State the fact: in(X, Y).
    in(X, Y).
% Define a clause for 'mentova spatial': succeed when the following conditions hold.
mentova_spatial(in(X, Y), no, just(in(X, Y, not_directly))) :-
    % Succeed only if 'in(X, Y' cannot be proved (negation as failure).
    \+ in(X, Y).

% Transitive containment with chain
% State a fact for 'mentova spatial' with the arguments listed below.
mentova_spatial(where_is(X), Location,
                % Continue the multi-line expression started above.
                just(where_is(X, Location, chain(Chain)))) :-
    % State a fact for 'in transitively' with the arguments listed below.
    in_transitively(X, Location),
    % Succeed only if 'in_transitively(Location, _),  % Location is a top container' cannot be proved (negation as failure).
    \+ in_transitively(Location, _),  % Location is a top container
    % State the fact: containment chain(X, Chain).
    containment_chain(X, Chain).

% Define a clause for 'containment chain': succeed when the following conditions hold.
containment_chain(X, [X]) :- \+ in(X, _), !.
% Define a clause for 'containment chain': succeed when the following conditions hold.
containment_chain(X, [X|Rest]) :-
    % State a fact for 'in' with the arguments listed below.
    in(X, Parent),
    % State the fact: containment chain(Parent, Rest).
    containment_chain(Parent, Rest).

% Full chain from X to ultimate container
% State a fact for 'mentova spatial' with the arguments listed below.
mentova_spatial(chain(X), chain(X, Chain),
                % Continue the multi-line expression started above.
                just(containment_chain(X, Chain))) :-
    % State the fact: containment chain(X, Chain).
    containment_chain(X, Chain).

% Is X in Y (transitively)?
% State a fact for 'mentova spatial' with the arguments listed below.
mentova_spatial(in_trans(X, Y), Answer,
                % Continue the multi-line expression started above.
                just(transitive_in(X, Y, Answer, chain(Chain)))) :-
    % Execute: ( in_transitively(X, Y).
    ( in_transitively(X, Y)
    % If the condition above succeeded, perform the following action.
    ->  Answer = yes, containment_chain(X, Chain0),
        % Continue the multi-line expression started above.
        ( member(Y, Chain0) -> Chain = Chain0 ; Chain = [X,'...',Y] )
    % Otherwise (else branch), perform the following action.
    ;   Answer = no, Chain = []
    % Close the expression opened above.
    ).

% What is on X?
% State a fact for 'mentova spatial' with the arguments listed below.
mentova_spatial(on_top_of(Y), Things,
                % Continue the multi-line expression started above.
                just(on(Things, Y))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(X, on(X, Y), Things).

% Is X near Y?
% State a fact for 'mentova spatial' with the arguments listed below.
mentova_spatial(near(X, Y), Answer,
                % Continue the multi-line expression started above.
                just(near(X, Y, Answer))) :-
    % Execute: ( near(X, Y) ; near(Y, X) ).
    ( near(X, Y) ; near(Y, X) )
    % Check that '->  Answer' is unifiable with 'yes'.
    ->  Answer = yes
    % Check that ';   Answer' is unifiable with 'no'.
    ;   Answer = no.
