/*  Mentova — Rung 4: Probabilistic Reasoning Module

    Computes the likelihood of a query by combining weighted facts
    from the Small-World knowledge base.  The engine supports:

      * Direct weighted-fact lookup
      * Conjunction probability (independence assumption)
      * Disjunction probability (inclusion-exclusion, two terms)
      * Conditional probability P(A|B) = P(A ∧ B) / P(B)

    Every result carries a readable justification term.
*/

:- module(probabilistic, [
    mentova_prob/3
]).

:- use_module('../../knowledge/small_world', [prob_fact/2]).
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% mentova_prob(+Query, -Probability, -Justification)
% ---------------------------------------------------------------------------

% Direct look-up
mentova_prob(prob(Prop), P, just(direct(Prop, P))) :-
    prob_fact(Prop, P).

% Conjunction: P(A ∧ B) = P(A) × P(B)  [independence]
mentova_prob(and(A, B), P, just(conjunction(JA, JB))) :-
    mentova_prob(prob(A), PA, JA),
    mentova_prob(prob(B), PB, JB),
    P is PA * PB.

% Disjunction: P(A ∨ B) = P(A) + P(B) − P(A ∧ B)
mentova_prob(or(A, B), P, just(disjunction(JA, JB))) :-
    mentova_prob(prob(A), PA, JA),
    mentova_prob(prob(B), PB, JB),
    P is PA + PB - PA * PB.

% Conditional: P(A | B) = P(A ∧ B) / P(B),  P(B) > 0
mentova_prob(given(A, B), P, just(conditional(JA_and_B, JB))) :-
    mentova_prob(and(A, B), PAB, JA_and_B),
    mentova_prob(prob(B), PB, JB),
    PB > 0,
    P is PAB / PB.

% Complement: P(¬A) = 1 − P(A)
mentova_prob(not(A), P, just(complement(JA))) :-
    mentova_prob(prob(A), PA, JA),
    P is 1.0 - PA.
