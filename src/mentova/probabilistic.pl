/*  Mentova — Rung 4: Probabilistic Reasoning Module

    Computes the likelihood of a query by combining weighted facts
    from the Small-World knowledge base.  The engine supports:

      * Direct weighted-fact lookup
      * Conjunction probability (independence assumption)
      * Disjunction probability (inclusion-exclusion, two terms)
      * Conditional probability P(A|B) = P(A ∧ B) / P(B)

    Every result carries a readable justification term.
*/

% Declare this file as the 'probabilistic' module and list its exported predicates.
:- module(probabilistic, [
    % Supply 'mentova_prob/3' as the next argument to the expression above.
    mentova_prob/3
% Close the expression opened above.
]).

% Import [prob_fact/2] from the 'small_world' module.
:- use_module('../../knowledge/small_world', [prob_fact/2]).
% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% mentova_prob(+Query, -Probability, -Justification)
% ---------------------------------------------------------------------------

% Direct look-up
% Define a clause for 'mentova prob': succeed when the following conditions hold.
mentova_prob(prob(Prop), P, just(direct(Prop, P))) :-
    % State the fact: prob fact(Prop, P).
    prob_fact(Prop, P).

% Conjunction: P(A ∧ B) = P(A) × P(B)  [independence]
% Define a clause for 'mentova prob': succeed when the following conditions hold.
mentova_prob(and(A, B), P, just(conjunction(JA, JB))) :-
    % State a fact for 'mentova prob' with the arguments listed below.
    mentova_prob(prob(A), PA, JA),
    % State a fact for 'mentova prob' with the arguments listed below.
    mentova_prob(prob(B), PB, JB),
    % Evaluate the arithmetic expression 'PA * PB' and bind the result to 'P'.
    P is PA * PB.

% Disjunction: P(A ∨ B) = P(A) + P(B) − P(A ∧ B)
% Define a clause for 'mentova prob': succeed when the following conditions hold.
mentova_prob(or(A, B), P, just(disjunction(JA, JB))) :-
    % State a fact for 'mentova prob' with the arguments listed below.
    mentova_prob(prob(A), PA, JA),
    % State a fact for 'mentova prob' with the arguments listed below.
    mentova_prob(prob(B), PB, JB),
    % Evaluate the arithmetic expression 'PA + PB - PA * PB' and bind the result to 'P'.
    P is PA + PB - PA * PB.

% Conditional: P(A | B) = P(A ∧ B) / P(B),  P(B) > 0
% Define a clause for 'mentova prob': succeed when the following conditions hold.
mentova_prob(given(A, B), P, just(conditional(JA_and_B, JB))) :-
    % State a fact for 'mentova prob' with the arguments listed below.
    mentova_prob(and(A, B), PAB, JA_and_B),
    % State a fact for 'mentova prob' with the arguments listed below.
    mentova_prob(prob(B), PB, JB),
    % Check that 'PB' is greater than '0'.
    PB > 0,
    % Evaluate the arithmetic expression 'PAB / PB' and bind the result to 'P'.
    P is PAB / PB.

% Complement: P(¬A) = 1 − P(A)
% Define a clause for 'mentova prob': succeed when the following conditions hold.
mentova_prob(not(A), P, just(complement(JA))) :-
    % State a fact for 'mentova prob' with the arguments listed below.
    mentova_prob(prob(A), PA, JA),
    % Evaluate the arithmetic expression '1.0 - PA' and bind the result to 'P'.
    P is 1.0 - PA.
