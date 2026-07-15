/*  Mentova — Relational Reasoning Module Test Suite  (relational)

    Genuine PLUnit coverage for src/mentova/relational.pl, the Rung 9
    relational reasoning module. The module is pure: it answers multi-hop
    relational queries by traversing named-relation chains over the
    compiled-in Small-World knowledge base (knowledge/small_world.pl), so
    no lattice, server, or asserted state is needed. Its single export
    mentova_relational(+Query, -Result, -Justification) recognises five
    query functors — two_hop, three_hop, path2, common, ancestor — and
    every answer carries a glass-box just(...) provenance term.

    Every expected value below is computed by hand from the small_world
    facts (is_a/2, capable_of/2) and confirmed against the module before
    being asserted exactly. The traversal is deterministic here because
    each fact chosen has a single matching clause at every step.

    Worked example (from the module header): a two-hop query walks
    step(X, Mid, R1) then step(Mid, End, R2); with is_a(canary, bird) and
    is_a(bird, animal), two_hop(canary, is_a, is_a) yields End = animal
    and the path is recorded in the justification.

    Run with the full library path (every PrologAI pack plus the Mentova src):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_relational.pl
*/

% Declare this file as a test module with no exports.
:- module(test_relational, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(relational)).

% Open the test block for the relational module.
:- begin_tests(relational).

% REL-001: two_hop walks two is_a steps and returns the far end with its path.
test(two_hop_two_is_a_steps) :-
    % Take the first solution: the entity two is_a steps up from a canary.
    once(mentova_relational(two_hop(canary, is_a, is_a), End, Justification)),
    % canary is_a bird and bird is_a animal, so the far end is animal.
    assertion(End == animal),
    % The justification records the whole two-hop path through the bird midpoint.
    assertion(Justification == just(two_hop(canary, is_a, bird, is_a, animal))).

% REL-002: two_hop crosses relation kinds — is_a then capable_of finds an inherited ability.
test(two_hop_crosses_relations) :-
    % Take the first solution for what a canary can do by taxonomy then capability.
    once(mentova_relational(two_hop(canary, is_a, capable_of), End, Justification)),
    % canary is_a bird and bird capable_of fly, so the far end is fly.
    assertion(End == fly),
    % The justification names the bird midpoint and both relations used.
    assertion(Justification == just(two_hop(canary, is_a, bird, capable_of, fly))).

% REL-003: three_hop walks three is_a steps up the taxonomy to living_thing.
test(three_hop_three_is_a_steps) :-
    % Take the first solution: the entity three is_a steps up from a canary.
    once(mentova_relational(three_hop(canary, is_a, is_a, is_a), End, Justification)),
    % canary -> bird -> animal -> living_thing, so the far end is living_thing.
    assertion(End == living_thing),
    % The justification records both midpoints and every relation on the path.
    assertion(Justification == just(three_hop(canary, is_a, bird, is_a, animal, is_a, living_thing))).

% REL-004: path2 returns the explicit path(X, Mid, End) triple, not just the end.
test(path2_returns_path_triple) :-
    % Take the first two-hop path from a canary via is_a then capable_of.
    once(mentova_relational(path2(canary, is_a, capable_of), Result, Justification)),
    % The result is the whole path: canary through bird to fly.
    assertion(Result == path(canary, bird, fly)),
    % The justification names both relations that formed the path.
    assertion(Justification == just(path(canary, is_a, bird, capable_of, fly))).

% REL-005: common finds the shared target reached by both entities under one relation.
test(common_shared_is_a_target) :-
    % Ask what canary and penguin have in common under the is_a relation.
    mentova_relational(common(canary, penguin, is_a), Zs, Justification),
    % Both a canary and a penguin are birds, so bird is the shared target.
    assertion(Zs == [bird]),
    % The justification carries the pair, the relation, and the shared list.
    assertion(Justification == just(common(canary, penguin, is_a, [bird]))).

% REL-006: ancestor confirms an indirect is_a ancestry and returns the full chain.
test(ancestor_indirect_chain) :-
    % Take the first proof that a canary is an is_a ancestor-of animal.
    once(mentova_relational(ancestor(canary, animal), Answer, Justification)),
    % canary reaches animal through bird, so the answer is yes.
    assertion(Answer == yes),
    % The justification carries the full is_a chain from canary to animal.
    assertion(Justification == just(ancestor(canary, animal, chain([canary, bird, animal])))).

% REL-007: ancestor confirms a direct is_a parent with a two-element chain.
test(ancestor_direct_chain) :-
    % Take the first proof that a canary is directly an is_a ancestor-of bird.
    once(mentova_relational(ancestor(canary, bird), Answer, Justification)),
    % is_a(canary, bird) holds directly, so the answer is yes.
    assertion(Answer == yes),
    % The direct chain has just the two endpoints.
    assertion(Justification == just(ancestor(canary, bird, chain([canary, bird])))).

% REL-008: a two_hop query with no continuing step fails cleanly rather than erroring.
test(two_hop_dead_end_fails, [fail]) :-
    % A rose is_a flower, but a flower has no capable_of edge to continue the hop.
    mentova_relational(two_hop(rose, is_a, capable_of), _End, _Justification).

% Close the test block for the relational module.
:- end_tests(relational).
