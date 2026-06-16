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

% Declare this file as the 'relational' module and list its exported predicates.
:- module(relational, [
    % Supply 'mentova_relational/3' as the next argument to the expression above.
    mentova_relational/3
% Close the expression opened above.
]).

% Load the 'small_world' module so its predicates are available here.
:- use_module('../../knowledge/small_world', [
    % Continue the multi-line expression started above.
    is_a/2, part_of/2, capable_of/2, has_property/2,
    % Continue the multi-line expression started above.
    at_location/2, causes/2, used_for/2, motivated_by/2
% Close the expression opened above.
]).
% Import [member/2, append/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% step(+X, -Y, -Rel): one relational step from X to Y via named Rel
% ---------------------------------------------------------------------------

% Define a clause for 'step': succeed when the following conditions hold.
step(X, Y, is_a)         :- is_a(X, Y).
% Define a clause for 'step': succeed when the following conditions hold.
step(X, Y, part_of)      :- part_of(X, Y).
% Define a clause for 'step': succeed when the following conditions hold.
step(X, Y, capable_of)   :- capable_of(X, Y).
% Define a clause for 'step': succeed when the following conditions hold.
step(X, Y, has_property) :- has_property(X, Y).
% Define a clause for 'step': succeed when the following conditions hold.
step(X, Y, at_location)  :- at_location(X, Y).
% Define a clause for 'step': succeed when the following conditions hold.
step(X, Y, causes)       :- causes(X, Y).
% Define a clause for 'step': succeed when the following conditions hold.
step(X, Y, used_for)     :- used_for(X, Y).
% Define a clause for 'step': succeed when the following conditions hold.
step(X, Y, motivated_by) :- motivated_by(X, Y).

% ---------------------------------------------------------------------------
% multi_hop/4: X -Rel1-> Mid -Rel2-> End
% ---------------------------------------------------------------------------

% Define a clause for 'multi hop': succeed when the following conditions hold.
multi_hop(X, Rel1, Rel2, Mid, End) :-
    % State a fact for 'step' with the arguments listed below.
    step(X, Mid, Rel1),
    % State the fact: step(Mid, End, Rel2).
    step(Mid, End, Rel2).

% ---------------------------------------------------------------------------
% related_path/4: find a path from X to Y within MaxDepth steps
% ---------------------------------------------------------------------------

% Define a clause for 'related path': succeed when the following conditions hold.
related_path(X, Y, Path, MaxDepth) :-
    % Check that 'MaxDepth' is greater than '0'.
    MaxDepth > 0,
    % State the fact: related path (X, Y, [X], Path, MaxDepth).
    related_path_(X, Y, [X], Path, MaxDepth).

% Check that 'related_path_(Y, Y, Visited, Visited, _) :- Visited' is not unifiable with '[_]'.
related_path_(Y, Y, Visited, Visited, _) :- Visited \= [_].
% Define a clause for 'related path ': succeed when the following conditions hold.
related_path_(X, Y, Visited, Path, Depth) :-
    % Check that 'Depth' is greater than '0'.
    Depth > 0,
    % State a fact for 'step' with the arguments listed below.
    step(X, Mid, _),
    % Succeed only if 'member(Mid, Visited' cannot be proved (negation as failure).
    \+ member(Mid, Visited),
    % Evaluate the arithmetic expression 'Depth - 1' and bind the result to 'Depth1'.
    Depth1 is Depth - 1,
    % State the fact: related path (Mid, Y, [Mid|Visited], Path, Depth1).
    related_path_(Mid, Y, [Mid|Visited], Path, Depth1).

% ---------------------------------------------------------------------------
% mentova_relational(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Two-hop: X -R1-> Mid -R2-> End
% State a fact for 'mentova relational' with the arguments listed below.
mentova_relational(two_hop(X, R1, R2), End,
                   % Continue the multi-line expression started above.
                   just(two_hop(X, R1, Mid, R2, End))) :-
    % State the fact: multi hop(X, R1, R2, Mid, End).
    multi_hop(X, R1, R2, Mid, End).

% Three-hop: X -R1-> Mid1 -R2-> Mid2 -R3-> End
% State a fact for 'mentova relational' with the arguments listed below.
mentova_relational(three_hop(X, R1, R2, R3), End,
                   % Continue the multi-line expression started above.
                   just(three_hop(X, R1, Mid1, R2, Mid2, R3, End))) :-
    % State a fact for 'step' with the arguments listed below.
    step(X, Mid1, R1),
    % State a fact for 'step' with the arguments listed below.
    step(Mid1, Mid2, R2),
    % State the fact: step(Mid2, End, R3).
    step(Mid2, End, R3).

% Specific relational question: does X relate to Z via any 2-hop path through a given mid-rel?
% State a fact for 'mentova relational' with the arguments listed below.
mentova_relational(path2(X, R1, R2), path(X,Mid,End),
                   % Continue the multi-line expression started above.
                   just(path(X, R1, Mid, R2, End))) :-
    % State a fact for 'step' with the arguments listed below.
    step(X, Mid, R1),
    % State the fact: step(Mid, End, R2).
    step(Mid, End, R2).

% Common: find Z such that Rel(X, Z) and Rel(Y, Z) — shared target
% State a fact for 'mentova relational' with the arguments listed below.
mentova_relational(common(X, Y, Rel), Zs,
                   % Continue the multi-line expression started above.
                   just(common(X, Y, Rel, Zs))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Z, (step(X, Z, Rel), step(Y, Z, Rel)), Zs),
    % Check that 'Zs' is not unifiable with '[]'.
    Zs \= [].

% Is X an ancestor of Y in is_a chain?
% State a fact for 'mentova relational' with the arguments listed below.
mentova_relational(ancestor(X, Y), yes,
                   % Continue the multi-line expression started above.
                   just(ancestor(X, Y, chain(Chain)))) :-
    % State the fact: is a path(X, Y, Chain).
    is_a_path(X, Y, Chain).

% Define a clause for 'is a path': succeed when the following conditions hold.
is_a_path(X, Y, [X, Y]) :- is_a(X, Y).
% Define a clause for 'is a path': succeed when the following conditions hold.
is_a_path(X, Y, [X|Rest]) :-
    % State a fact for 'is a' with the arguments listed below.
    is_a(X, Mid),
    % State the fact: is a path(Mid, Y, Rest).
    is_a_path(Mid, Y, Rest).
