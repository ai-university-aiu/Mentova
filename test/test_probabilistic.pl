/*  Mentova — Probabilistic Reasoning Test Suite  (Rung 4)

    A genuine behavioural PLUnit suite for src/mentova/probabilistic.pl. The
    module is pure — it needs no mind id, no lattice, and no asserted state — but
    it reads weighted facts from the Small-World knowledge base (prob_fact/2,
    loaded transitively through the module under test). Each test calls the
    single exported predicate mentova_prob/3 with a known query and asserts both
    the Probability and the glass-box Justification, computed by hand from the
    module's documented combination rules and these two Small-World weights:
        prob_fact(rain,      0.3)
        prob_fact(sprinkler, 0.6)

    Run with the full library path (every PrologAI pack plus the Mentova source):
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" test/test_probabilistic.pl
*/

%% Declare this file as a test module with no exports.
:- module(test_probabilistic, []).
%% Load the PLUnit test framework.
:- use_module(library(plunit)).
%% Load the probabilistic reasoning module under test from the library path.
:- use_module(library(probabilistic)).

%% Open the test block for the probabilistic module.
:- begin_tests(probabilistic).

%% AC-PROB-001: a direct query returns the weighted fact's probability verbatim.
test(direct_lookup_returns_fact_weight) :-
    %% Ask for the probability of the atomic proposition 'rain'.
    mentova_prob(prob(rain), P, Justification),
    %% Small-World records prob_fact(rain, 0.3), so the probability is 0.3.
    assertion(abs(P - 0.3) < 1.0e-9),
    %% The justification names the direct look-up that produced the weight.
    assertion(Justification == just(direct(rain, 0.3))).

%% AC-PROB-002: an unknown proposition has no weighted fact and simply fails.
test(unknown_proposition_fails) :-
    %% There is no prob_fact/2 for this proposition, so the query must fail.
    assertion(\+ mentova_prob(prob(no_such_proposition), _, _)).

%% AC-PROB-003: conjunction multiplies the two weights under independence.
test(conjunction_is_product) :-
    %% Ask for the joint probability of 'rain' and 'sprinkler'.
    mentova_prob(and(rain, sprinkler), P, Justification),
    %% P(rain and sprinkler) = 0.3 * 0.6 = 0.18 under the independence assumption.
    assertion(abs(P - 0.18) < 1.0e-9),
    %% The justification nests the two direct look-ups under a conjunction.
    assertion(Justification == just(conjunction(just(direct(rain, 0.3)),
                                                just(direct(sprinkler, 0.6))))).

%% AC-PROB-004: disjunction applies two-term inclusion-exclusion.
test(disjunction_is_inclusion_exclusion) :-
    %% Ask for the probability that 'rain' or 'sprinkler' holds.
    mentova_prob(or(rain, sprinkler), P, Justification),
    %% P(rain or sprinkler) = 0.3 + 0.6 - 0.3*0.6 = 0.9 - 0.18 = 0.72.
    assertion(abs(P - 0.72) < 1.0e-9),
    %% The justification nests the two direct look-ups under a disjunction.
    assertion(Justification == just(disjunction(just(direct(rain, 0.3)),
                                                just(direct(sprinkler, 0.6))))).

%% AC-PROB-005: conditional divides the joint by the condition's probability.
test(conditional_divides_joint_by_condition) :-
    %% Ask for P(rain given sprinkler).
    mentova_prob(given(rain, sprinkler), P, Justification),
    %% P(rain|sprinkler) = P(rain and sprinkler)/P(sprinkler) = 0.18/0.6 = 0.3.
    assertion(abs(P - 0.3) < 1.0e-9),
    %% The justification carries the joint's proof and the condition's look-up.
    assertion(Justification == just(conditional(
                  just(conjunction(just(direct(rain, 0.3)),
                                   just(direct(sprinkler, 0.6)))),
                  just(direct(sprinkler, 0.6))))).

%% AC-PROB-006: complement is one minus the proposition's probability.
test(complement_is_one_minus_probability) :-
    %% Ask for the probability that 'rain' does not hold.
    mentova_prob(not(rain), P, Justification),
    %% P(not rain) = 1.0 - 0.3 = 0.7.
    assertion(abs(P - 0.7) < 1.0e-9),
    %% The justification wraps the direct look-up in a complement.
    assertion(Justification == just(complement(just(direct(rain, 0.3))))).

%% Close the test block for the probabilistic module.
:- end_tests(probabilistic).
