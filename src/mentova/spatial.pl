/*  Mentova — Rung 21: Spatial Reasoning Module

    Resolves containment and position using reference frames.
    Pass criterion: transitive location correct (cat on mat in kitchen).

    Supports:
      in(X, Y)        — X is contained in Y
      on(X, Y)        — X is on Y
      near(X, Y)      — X is near Y
      transitive_in   — compute full containment chain
*/

:- module(spatial, [
    mentova_spatial/3
]).

:- use_module(library(lists), [member/2, append/3]).
:- discontiguous mentova_spatial/3.

% ---------------------------------------------------------------------------
% Spatial facts (reference frame: house layout)
% ---------------------------------------------------------------------------

in(mat,    kitchen).
in(cat,    mat).          % cat is on the mat, in the kitchen
in(book,   shelf).
in(shelf,  library).
in(library,house).
in(kitchen,house).
in(fridge, kitchen).
in(food,   fridge).

on(cat,    mat).
on(cup,    table).
on(table,  kitchen).

near(cat,  fridge).
near(cup,  cat).

% ---------------------------------------------------------------------------
% Transitive containment: in_transitively(X, Y) — X is ultimately in Y
% ---------------------------------------------------------------------------

in_transitively(X, Y) :- in(X, Y).
in_transitively(X, Y) :- in(X, Mid), in_transitively(Mid, Y).

% ---------------------------------------------------------------------------
% mentova_spatial(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Direct containment
mentova_spatial(in(X, Y), yes, just(in(X, Y, direct))) :-
    in(X, Y).
mentova_spatial(in(X, Y), no, just(in(X, Y, not_directly))) :-
    \+ in(X, Y).

% Transitive containment with chain
mentova_spatial(where_is(X), Location,
                just(where_is(X, Location, chain(Chain)))) :-
    in_transitively(X, Location),
    \+ in_transitively(Location, _),  % Location is a top container
    containment_chain(X, Chain).

containment_chain(X, [X]) :- \+ in(X, _), !.
containment_chain(X, [X|Rest]) :-
    in(X, Parent),
    containment_chain(Parent, Rest).

% Full chain from X to ultimate container
mentova_spatial(chain(X), chain(X, Chain),
                just(containment_chain(X, Chain))) :-
    containment_chain(X, Chain).

% Is X in Y (transitively)?
mentova_spatial(in_trans(X, Y), Answer,
                just(transitive_in(X, Y, Answer, chain(Chain)))) :-
    ( in_transitively(X, Y)
    ->  Answer = yes, containment_chain(X, Chain0),
        ( member(Y, Chain0) -> Chain = Chain0 ; Chain = [X,'...',Y] )
    ;   Answer = no, Chain = []
    ).

% What is on X?
mentova_spatial(on_top_of(Y), Things,
                just(on(Things, Y))) :-
    findall(X, on(X, Y), Things).

% Is X near Y?
mentova_spatial(near(X, Y), Answer,
                just(near(X, Y, Answer))) :-
    ( near(X, Y) ; near(Y, X) )
    ->  Answer = yes
    ;   Answer = no.
