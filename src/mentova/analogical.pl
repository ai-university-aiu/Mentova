/*  Mentova — Rung 8: Analogical Reasoning Module

    Completes A-to-B-as-C-to-? mappings by structure mapping over
    the knowledge base.

    Method:
      1. Find the relation(s) R such that R(A, B) holds.
      2. Find X such that R(C, X) holds.
      3. Return X as the analogical completion.

    If multiple relations connect A to B, all are tried and results
    ranked by the number of shared relation types.

    Pass criterion: correct filler returns by structure mapping.
    Example: canary:bird :: eagle:? → answer: bird (both are is_a relations)
    Example: knife:cut :: hammer:? → answer: drive_nail (via capable_of)
*/

% Declare this file as the 'analogical' module and list its exported predicates.
:- module(analogical, [
    % Supply 'mentova_analogy/3' as the next argument to the expression above.
    mentova_analogy/3
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
% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% relation_holds(+A, +B, -Relation): find all relations between A and B
% ---------------------------------------------------------------------------

% Define a clause for 'relation holds': succeed when the following conditions hold.
relation_holds(A, B, is_a)         :- is_a(A, B).
% Define a clause for 'relation holds': succeed when the following conditions hold.
relation_holds(A, B, part_of)      :- part_of(A, B).
% Define a clause for 'relation holds': succeed when the following conditions hold.
relation_holds(A, B, capable_of)   :- capable_of(A, B).
% Define a clause for 'relation holds': succeed when the following conditions hold.
relation_holds(A, B, has_property) :- has_property(A, B).
% Define a clause for 'relation holds': succeed when the following conditions hold.
relation_holds(A, B, at_location)  :- at_location(A, B).
% Define a clause for 'relation holds': succeed when the following conditions hold.
relation_holds(A, B, causes)       :- causes(A, B).
% Define a clause for 'relation holds': succeed when the following conditions hold.
relation_holds(A, B, used_for)     :- used_for(A, B).
% Define a clause for 'relation holds': succeed when the following conditions hold.
relation_holds(A, B, motivated_by) :- motivated_by(A, B).

% ---------------------------------------------------------------------------
% mentova_analogy(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% analogy(a:b :: c:?)
% Define a clause for 'mentova analogy': succeed when the following conditions hold.
mentova_analogy(analogy(A, B, C, ?), D, just(analogy(A,B,C,D, via(Relations)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(R, relation_holds(A, B, R), Relations),
    % Check that 'Relations' is not unifiable with '[]'.
    Relations \= [],
    % Succeed for each element 'R' that is a member of the list.
    member(R, Relations),
    % State a fact for 'relation holds' with the arguments listed below.
    relation_holds(C, D, R),
    % Check that 'D' is not unifiable with 'B.   % filler should differ from B unless forced'.
    D \= B.   % filler should differ from B unless forced

% If no different D found, allow D = B (same-class analogy)
% Define a clause for 'mentova analogy': succeed when the following conditions hold.
mentova_analogy(analogy(A, B, C, ?), D, just(analogy(A,B,C,D, via(Relations)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(R, relation_holds(A, B, R), Relations),
    % Check that 'Relations' is not unifiable with '[]'.
    Relations \= [],
    % Succeed for each element 'R' that is a member of the list.
    member(R, Relations),
    % State the fact: relation holds(C, D, R).
    relation_holds(C, D, R).
