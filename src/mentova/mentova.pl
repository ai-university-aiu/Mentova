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
:- use_module(induction).
:- use_module(abduction).
:- use_module(probabilistic).
:- use_module(bayesian).
:- use_module(causal).

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

% Rung 6 — causal: predict effect of intervention vs observation
mentova_query(causal, CausalQuery, answer(Result, Just)) :-
    mentova_causal(CausalQuery, Result, Just).

% Rung 5 — bayesian: update belief on new evidence
mentova_query(bayesian, update(H, E), answer(Posterior, Just)) :-
    mentova_bayes(H, E, Posterior, Just).

% Rung 4 — probabilistic: compute query likelihood
mentova_query(probabilistic, ProbQuery, answer(P, Just)) :-
    mentova_prob(ProbQuery, P, Just).

% Rung 3 — abductive: best explanation for an observation
mentova_query(abductive, explain(Obs),
              answer(Best, just(abduction(Obs), all_explanations(All)))) :-
    mentova_abduce(Obs, Best, _Score, All).

% Rung 2 — inductive: induce a rule from examples, verify on held-out cases
mentova_query(inductive, induce(Pos, Neg, BG, HeldOut),
              answer(rule(Rule), just(induced(Rule), verified(HeldOut, Results)))) :-
    mentova_induce(Pos, Neg, BG, Rule),
    Rule = (Head :- Body),
    maplist([Ex, Ex-Verdict]>>(
        copy_term(Head-Body, Ex-BodyInst),
        ( call(BodyInst) -> Verdict = pass ; Verdict = fail )
    ), HeldOut, Results).

% is_a_chain(+X, +Class, -Chain): find transitive IsA chain
is_a_chain(X, Class, [X, Class]) :-
    is_a(X, Class).
is_a_chain(X, Class, [X | Rest]) :-
    is_a(X, Mid),
    is_a_chain(Mid, Class, Rest).
