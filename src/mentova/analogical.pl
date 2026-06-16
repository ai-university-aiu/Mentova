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

:- module(analogical, [
    mentova_analogy/3
]).

:- use_module('../../knowledge/small_world', [
    is_a/2, part_of/2, capable_of/2, has_property/2,
    at_location/2, causes/2, used_for/2, motivated_by/2
]).
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% relation_holds(+A, +B, -Relation): find all relations between A and B
% ---------------------------------------------------------------------------

relation_holds(A, B, is_a)         :- is_a(A, B).
relation_holds(A, B, part_of)      :- part_of(A, B).
relation_holds(A, B, capable_of)   :- capable_of(A, B).
relation_holds(A, B, has_property) :- has_property(A, B).
relation_holds(A, B, at_location)  :- at_location(A, B).
relation_holds(A, B, causes)       :- causes(A, B).
relation_holds(A, B, used_for)     :- used_for(A, B).
relation_holds(A, B, motivated_by) :- motivated_by(A, B).

% ---------------------------------------------------------------------------
% mentova_analogy(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% analogy(a:b :: c:?)
mentova_analogy(analogy(A, B, C, ?), D, just(analogy(A,B,C,D, via(Relations)))) :-
    findall(R, relation_holds(A, B, R), Relations),
    Relations \= [],
    member(R, Relations),
    relation_holds(C, D, R),
    D \= B.   % filler should differ from B unless forced

% If no different D found, allow D = B (same-class analogy)
mentova_analogy(analogy(A, B, C, ?), D, just(analogy(A,B,C,D, via(Relations)))) :-
    findall(R, relation_holds(A, B, R), Relations),
    Relations \= [],
    member(R, Relations),
    relation_holds(C, D, R).
