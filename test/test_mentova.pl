/*  Mentova — Bootstrap Entry Point Test Suite

    Genuine PLUnit coverage for src/mentova/mentova.pl, the Synthetic Mind's
    top-level module. It exports two predicates:

      mentova_boot/0    — wake Mentova: enroll bodies, count the constitution,
                          boot the global workspace and attention schema.
      mentova_query/3   — mentova_query(+QueryType, +Query, -answer(Result,Just))
                          the glass-box query router. Its early clauses answer
                          directly from the Small-World knowledge base:
                            deductive is_a/2  -> answer(yes, just(X,is_a,C,chain(Chain)))
                            deductive capable_of/2 -> via_isa or direct
                            defeasible flies/1 -> default holds, or exception fires
                            probabilistic prob/1 -> the weighted fact's probability
                            epistemic believes/2 -> the stored truth value.

    Every expected value below is computed by hand from the facts in
    knowledge/small_world.pl, so a change in behaviour fails the suite loudly.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_mentova.pl
*/

% Declare this file as a test module with no exports.
:- module(test_mentova, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(mentova)).

% Open the test block for the mentova module.
:- begin_tests(mentova).

% AC-MENTOVA-001: the documented boot entry point runs to completion.
test(boot_entry_point_runs) :-
    % Wake Mentova, capturing its banner so the test log stays clean.
    with_output_to(string(_Banner), mentova_boot).

% AC-MENTOVA-002: a direct IsA fact yields a two-node justification chain.
test(deductive_isa_direct_chain) :-
    % Ask whether a canary is a bird — a single direct is_a/2 fact.
    once(mentova_query(deductive, is_a(canary, bird), Answer)),
    % The hand-computed answer names the direct one-hop chain [canary, bird].
    assertion(Answer == answer(yes, just(canary, is_a, bird, chain([canary, bird])))).

% AC-MENTOVA-003: a transitive IsA question walks the full taxonomic chain.
test(deductive_isa_multihop_chain) :-
    % Ask whether a canary is an animal — reachable only through bird.
    once(mentova_query(deductive, is_a(canary, animal), Answer)),
    % The chain is canary -> bird -> animal, exactly as the backbone links them.
    assertion(Answer == answer(yes, just(canary, is_a, animal, chain([canary, bird, animal])))).

% AC-MENTOVA-004: an inherited capability is justified via_isa through the parent.
test(deductive_capable_of_via_isa) :-
    % Ask whether a canary can fly — no direct fact, but bird capable_of fly.
    once(mentova_query(deductive, capable_of(canary, fly), Answer)),
    % The router inherits the capability from bird and tags it via_isa.
    assertion(Answer == answer(yes, just(canary, capable_of, fly, via_isa))).

% AC-MENTOVA-005: a directly stated capability is justified as direct.
test(deductive_capable_of_direct) :-
    % Ask whether an eagle can hunt — a direct capable_of/2 fact, not inherited.
    once(mentova_query(deductive, capable_of(eagle, hunt), Answer)),
    % The router finds the direct fact and tags the justification direct.
    assertion(Answer == answer(yes, just(eagle, capable_of, hunt, direct))).

% AC-MENTOVA-006: the flies default holds for a bird with no exception.
test(defeasible_default_holds) :-
    % Ask defeasibly whether a canary flies — birds fly by default.
    once(mentova_query(defeasible, flies(canary), Answer)),
    % No exception applies to a canary, so the default rule bird_flies stands.
    assertion(Answer == answer(yes, just(default(bird_flies)))).

% AC-MENTOVA-007: the flies default is defeated by the flightless exception.
test(defeasible_exception_fires) :-
    % Ask defeasibly whether a penguin flies — a flightless bird.
    once(mentova_query(defeasible, flies(penguin), Answer)),
    % The penguin_exception overrides the default, so the answer is no.
    assertion(Answer == answer(no, just(exception(penguin_exception)))).

% AC-MENTOVA-008: a probabilistic query returns the stored weighted-fact probability.
test(probabilistic_weighted_fact) :-
    % Ask for the probability of rains_today — a weighted fact in the KB.
    once(mentova_query(probabilistic, prob(rains_today), Answer)),
    % The stored probability is 0.3, carried with a weighted_fact justification.
    assertion(Answer == answer(0.3, just(weighted_fact(rains_today)))).

% AC-MENTOVA-009: an epistemic query reports a believed-true proposition.
test(epistemic_belief_true) :-
    % Ask what sally believes about the marble being in the basket.
    once(mentova_query(epistemic, believes(sally, marble_in_basket), Answer)),
    % Sally holds this belief as true in the Sally-Anne scenario.
    assertion(Answer == answer(true, just(belief(sally, marble_in_basket)))).

% AC-MENTOVA-010: an epistemic query reports a believed-false proposition.
test(epistemic_belief_false) :-
    % Ask what bob believes about the water being safe.
    once(mentova_query(epistemic, believes(bob, water_is_safe), Answer)),
    % Bob holds this belief as false, given his different evidence.
    assertion(Answer == answer(false, just(belief(bob, water_is_safe)))).

% Close the test block for the mentova module.
:- end_tests(mentova).
