/*  Mentova — Spatial Reasoning Module Test Suite  (spatial)

    Genuine PLUnit coverage for src/mentova/spatial.pl, the Rung 21
    spatial reasoning module. The module is pure: it resolves
    containment and position over a compiled-in reference frame (a house
    layout of in/2, on/2, and near/2 facts), so no lattice, server, or
    asserted state is needed. Its single export
    mentova_spatial(+Query, -Result, -Justification) recognises six query
    functors — in, where_is, chain, in_trans, on_top_of, near — and every
    answer carries a glass-box just(...) provenance term.

    Every expected value below is computed by hand from the module's own
    facts and its transitive-containment rules, then asserted exactly.
    The reference frame chains are:
        cat  -> mat -> kitchen -> house      (via in/2)
        food -> fridge -> kitchen -> house   (via in/2)
        book -> shelf -> library -> house    (via in/2)
    The top container of every chain is 'house', which is contained in
    nothing, so where_is always resolves there.

    Worked example (from the module header): the cat is on the mat, in the
    kitchen; where_is(cat) walks the containment chain to the outermost
    container, house, and records [cat, mat, kitchen, house] as the chain.

    Run with the full library path (every PrologAI pack plus the Mentova src):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_spatial.pl
*/

% Declare this file as a test module with no exports.
:- module(test_spatial, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(spatial)).

% Open the test block for the spatial module.
:- begin_tests(spatial).

% SPATIAL-001: a directly-asserted in/2 fact answers yes with a 'direct' justification.
test(in_direct_containment_answers_yes) :-
    % Ask whether the mat is directly in the kitchen (in(mat, kitchen) is a fact).
    once(mentova_spatial(in(mat, kitchen), Result, Justification)),
    % The direct containment holds, so the answer is yes.
    assertion(Result == yes),
    % The justification names the fact and marks it as directly established.
    assertion(Justification == just(in(mat, kitchen, direct))).

% SPATIAL-002: a pair related only transitively answers no under the direct in/2 query.
test(in_indirect_containment_answers_no) :-
    % Ask whether the cat is DIRECTLY in the kitchen (it is only there via the mat).
    once(mentova_spatial(in(cat, kitchen), Result, Justification)),
    % There is no in(cat, kitchen) fact, so the direct query answers no.
    assertion(Result == no),
    % The justification records that the pair is not directly contained.
    assertion(Justification == just(in(cat, kitchen, not_directly))).

% SPATIAL-003: where_is walks the containment chain to the outermost container.
test(where_is_resolves_to_top_container) :-
    % Ask where the cat ultimately is.
    once(mentova_spatial(where_is(cat), Location, Justification)),
    % The cat is in the mat, in the kitchen, in the house; house contains nothing.
    assertion(Location == house),
    % The justification carries the full containment chain to the top container.
    assertion(Justification == just(where_is(cat, house, chain([cat, mat, kitchen, house])))).

% SPATIAL-004: chain reports the whole nesting from an object out to the top.
test(chain_reports_full_nesting) :-
    % Ask for the full containment chain of the book.
    once(mentova_spatial(chain(book), Result, Justification)),
    % The book nests shelf -> library -> house, so the chain is these four items.
    assertion(Result == chain(book, [book, shelf, library, house])),
    % The justification is the containment_chain provenance term for that chain.
    assertion(Justification == just(containment_chain(book, [book, shelf, library, house]))).

% SPATIAL-005: in_trans confirms transitive containment and returns the connecting chain.
test(in_trans_confirms_transitive_containment) :-
    % Ask whether the cat is transitively in the kitchen.
    once(mentova_spatial(in_trans(cat, kitchen), Answer, Justification)),
    % The cat reaches the kitchen through the mat, so the answer is yes.
    assertion(Answer == yes),
    % The justification records the transitive proof with the cat's containment chain.
    assertion(Justification == just(transitive_in(cat, kitchen, yes, chain([cat, mat, kitchen, house])))).

% SPATIAL-006: in_trans denies containment that does not hold, with an empty chain.
test(in_trans_denies_unrelated_containment) :-
    % Ask whether the cat is transitively in the shelf (it is not — different subtree).
    once(mentova_spatial(in_trans(cat, shelf), Answer, Justification)),
    % No path connects the cat to the shelf, so the answer is no.
    assertion(Answer == no),
    % The justification reports the denial with an empty connecting chain.
    assertion(Justification == just(transitive_in(cat, shelf, no, chain([])))).

% SPATIAL-007: on_top_of gathers everything sitting on a surface via findall over on/2.
test(on_top_of_collects_supported_objects) :-
    % Ask what is on the mat.
    once(mentova_spatial(on_top_of(mat), Things, Justification)),
    % Only the cat is on the mat (on(cat, mat) is the sole matching fact).
    assertion(Things == [cat]),
    % The justification names the collected things over the queried surface.
    assertion(Justification == just(on([cat], mat))).

% SPATIAL-008: on_top_of also reports the cup as the thing on the table.
test(on_top_of_reports_cup_on_table) :-
    % Ask what is on the table.
    once(mentova_spatial(on_top_of(table), Things, _Justification)),
    % Only the cup is on the table (on(cup, table) is the sole matching fact).
    assertion(Things == [cup]).

% SPATIAL-009: near answers yes for a directly-asserted proximity fact.
test(near_direct_proximity_answers_yes) :-
    % Ask whether the cat is near the fridge (near(cat, fridge) is a fact).
    once(mentova_spatial(near(cat, fridge), Answer, Justification)),
    % The proximity holds directly, so the answer is yes.
    assertion(Answer == yes),
    % The justification records the near relation with its answer.
    assertion(Justification == just(near(cat, fridge, yes))).

% SPATIAL-010: near is symmetric — it also succeeds when the pair is stated in reverse.
test(near_is_symmetric) :-
    % Ask whether the fridge is near the cat (only near(cat, fridge) is asserted).
    once(mentova_spatial(near(fridge, cat), Answer, _Justification)),
    % The module checks both orderings, so the reversed query still answers yes.
    assertion(Answer == yes).

% SPATIAL-011: near answers no when no proximity fact links the pair in either order.
test(near_absent_proximity_answers_no) :-
    % Ask whether the cat is near the table (no near/2 fact links them either way).
    once(mentova_spatial(near(cat, table), Answer, Justification)),
    % Neither ordering is asserted, so the answer is no.
    assertion(Answer == no),
    % The justification records the near relation resolving to no.
    assertion(Justification == just(near(cat, table, no))).

% Close the test block for the spatial module.
:- end_tests(spatial).
