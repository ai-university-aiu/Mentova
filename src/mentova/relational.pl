/*  Mentova — Rung 9: Relational Reasoning Module

    Answers queries that depend on multi-hop relational structure:
    traversing chains of named relations across the knowledge graph.

    Supported query forms:
      path(X, Y, RelList)    — find a relational path from X to Y using RelList
      multi_hop(X, R1, R2)   — X -R1-> Mid -R2-> Y; return Y
      related(X, Y)          — is X related to Y by any chain (BFS, depth-limited)
      common(X, Y)           — find entities Z related to both X and Y by same relation

    Pass criterion: multi-hop relational query resolves correctly.
*/

:- module(relational, [
    mentova_relational/3
]).

:- use_module('../../knowledge/small_world', [
    is_a/2, part_of/2, capable_of/2, has_property/2,
    at_location/2, causes/2, used_for/2, motivated_by/2
]).
:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% step(+X, -Y, -Rel): one relational step from X to Y via named Rel
% ---------------------------------------------------------------------------

step(X, Y, is_a)         :- is_a(X, Y).
step(X, Y, part_of)      :- part_of(X, Y).
step(X, Y, capable_of)   :- capable_of(X, Y).
step(X, Y, has_property) :- has_property(X, Y).
step(X, Y, at_location)  :- at_location(X, Y).
step(X, Y, causes)       :- causes(X, Y).
step(X, Y, used_for)     :- used_for(X, Y).
step(X, Y, motivated_by) :- motivated_by(X, Y).

% ---------------------------------------------------------------------------
% multi_hop/4: X -Rel1-> Mid -Rel2-> End
% ---------------------------------------------------------------------------

multi_hop(X, Rel1, Rel2, Mid, End) :-
    step(X, Mid, Rel1),
    step(Mid, End, Rel2).

% ---------------------------------------------------------------------------
% related_path/4: find a path from X to Y within MaxDepth steps
% ---------------------------------------------------------------------------

related_path(X, Y, Path, MaxDepth) :-
    MaxDepth > 0,
    related_path_(X, Y, [X], Path, MaxDepth).

related_path_(Y, Y, Visited, Visited, _) :- Visited \= [_].
related_path_(X, Y, Visited, Path, Depth) :-
    Depth > 0,
    step(X, Mid, _),
    \+ member(Mid, Visited),
    Depth1 is Depth - 1,
    related_path_(Mid, Y, [Mid|Visited], Path, Depth1).

% ---------------------------------------------------------------------------
% mentova_relational(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Two-hop: X -R1-> Mid -R2-> End
mentova_relational(two_hop(X, R1, R2), End,
                   just(two_hop(X, R1, Mid, R2, End))) :-
    multi_hop(X, R1, R2, Mid, End).

% Three-hop: X -R1-> Mid1 -R2-> Mid2 -R3-> End
mentova_relational(three_hop(X, R1, R2, R3), End,
                   just(three_hop(X, R1, Mid1, R2, Mid2, R3, End))) :-
    step(X, Mid1, R1),
    step(Mid1, Mid2, R2),
    step(Mid2, End, R3).

% Specific relational question: does X relate to Z via any 2-hop path through a given mid-rel?
mentova_relational(path2(X, R1, R2), path(X,Mid,End),
                   just(path(X, R1, Mid, R2, End))) :-
    step(X, Mid, R1),
    step(Mid, End, R2).

% Common: find Z such that Rel(X, Z) and Rel(Y, Z) — shared target
mentova_relational(common(X, Y, Rel), Zs,
                   just(common(X, Y, Rel, Zs))) :-
    findall(Z, (step(X, Z, Rel), step(Y, Z, Rel)), Zs),
    Zs \= [].

% Is X an ancestor of Y in is_a chain?
mentova_relational(ancestor(X, Y), yes,
                   just(ancestor(X, Y, chain(Chain)))) :-
    is_a_path(X, Y, Chain).

is_a_path(X, Y, [X, Y]) :- is_a(X, Y).
is_a_path(X, Y, [X|Rest]) :-
    is_a(X, Mid),
    is_a_path(Mid, Y, Rest).
