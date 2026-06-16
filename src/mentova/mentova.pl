/*  Mentova — Bootstrap Entry Point

    Mentova is a Synthetic Mind written in PrologAI.
    This module loads the foundational knowledge, constitution, and bodies,
    and exposes the top-level reasoning predicates.

    Usage:
        swipl -l src/mentova/mentova.pl -g "mentova_boot" -t halt
*/

:- module(mentova, [
    mentova_boot/0,
    mentova_query/3
]).

:- use_module('../../knowledge/small_world').
:- use_module('../../constitution/constitution').
:- use_module('../../bodies/bodies').

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% mentova_boot/0 — initialise Mentova
% ---------------------------------------------------------------------------

mentova_boot :-
    format("~n=== Mentova is waking up ===~n"),
    format("Platform : PrologAI~n"),
    format("Mind     : Mentova~n"),
    format("~n"),
    enroll_bodies,
    aggregate_all(count, constitutional_principle(_, _), NPrinciples),
    aggregate_all(count, registered_overseer(_, _),      NOverseers),
    format("~nConstitution: ~w principles, ~w overseer(s)~n",
           [NPrinciples, NOverseers]),
    format("Knowledge: Small-World Commonsense loaded~n"),
    format("~nMentova is ready. Born at Rung 1 — transparent deduction.~n~n").

% ---------------------------------------------------------------------------
% mentova_query/3 — top-level glass-box query
%
%   +QueryType: deductive | defeasible | probabilistic | ...
%   +Query:     the query term
%   -Result:    answer(Conclusion, Justification)
% ---------------------------------------------------------------------------

mentova_query(deductive, is_a(X, Class), answer(yes, just(X, is_a, Class, chain(Chain)))) :-
    is_a_chain(X, Class, Chain).
mentova_query(deductive, capable_of(X, Cap), answer(yes, just(X, capable_of, Cap, via_isa))) :-
    is_a(X, Parent), capable_of(Parent, Cap).
mentova_query(deductive, capable_of(X, Cap), answer(yes, just(X, capable_of, Cap, direct))) :-
    capable_of(X, Cap).
mentova_query(defeasible, flies(X), answer(Answer, Justification)) :-
    ( default_rule(flies(X), is_a(X, bird)),
      is_a(X, bird)
    ->  ( exception_rule(flies(X), Cond, Note),
          call(Cond)
        ->  Answer = no,
            Justification = just(exception(Note))
        ;   Answer = yes,
            Justification = just(default(bird_flies))
        )
    ;   Answer = no,
        Justification = just(not_a_bird)
    ).
mentova_query(probabilistic, prob(Prop), answer(Prob, just(weighted_fact(Prop)))) :-
    prob_fact(Prop, Prob).
mentova_query(epistemic, believes(Agent, Prop), answer(Value, just(belief(Agent, Prop)))) :-
    believes(Agent, Prop, Value).

% is_a_chain(+X, +Class, -Chain): find transitive IsA chain
is_a_chain(X, Class, [X, Class]) :-
    is_a(X, Class).
is_a_chain(X, Class, [X | Rest]) :-
    is_a(X, Mid),
    is_a_chain(Mid, Class, Rest).
