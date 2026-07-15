/*  Mentova — OODA Knowledge Test Suite

    A genuine PLUnit suite for the ooda_knowledge module, which holds John
    Boyd's OODA methodology (Observe, Orient, Decide, Act) as a skill in
    Mentova's Jacobian Space. The facts are distilled from papers/OODA.txt.

    Each test exercises an exported predicate against a value computed by hand
    from the module's documented behaviour: four phases, five ingredients of
    orientation, six principles, the hierarchical_planning mapping, substring
    recall, and the summary counts.

    Run with the full library path (every PrologAI pack plus the Mentova source):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
            -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_ooda_knowledge.pl
*/

% Declare this file as a test module with no exports.
:- module(test_ooda_knowledge, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(ooda_knowledge)).
% Load the membership helper used by several assertions.
:- use_module(library(lists), [memberchk/2]).

% Open the test block for ooda_knowledge.
:- begin_tests(ooda_knowledge).

% Boyd's four phases are exactly observe, orient, decide, and act.
test(phases_are_boyds_four) :-
    % Collect the distinct phase names (setof returns them sorted).
    setof(P, D^ooda_phase(P, D), Phases),
    % They are exactly Boyd's four canonical phases in standard order.
    assertion(Phases == [act, decide, observe, orient]).

% The orient phase is documented as the schwerpunkt (its main-effort focus).
test(orient_description_names_the_schwerpunkt) :-
    % Read the description text of the orient phase.
    ooda_phase(orient, Desc),
    % Lower-case it so the search is case-insensitive.
    downcase_atom(Desc, Lower),
    % The description calls orientation the schwerpunkt.
    assertion(sub_atom(Lower, _, _, _, schwerpunkt)).

% Orientation has exactly the five ingredients Boyd drew inside the Orient box.
test(five_orientation_ingredients) :-
    % Collect the distinct ingredient names.
    setof(I, D^ooda_orientation_ingredient(I, D), Ingredients),
    % There are exactly five ingredients of orientation.
    assertion(length(Ingredients, 5)),
    % The engine at the centre is analysis and synthesis.
    assertion(memberchk(analysis_and_synthesis, Ingredients)).

% The methodology names exactly six core principles.
test(six_core_principles) :-
    % Collect the distinct principle names.
    setof(Pr, D^ooda_principle(Pr, D), Principles),
    % There are exactly six core principles.
    assertion(length(Principles, 6)),
    % Orientation being the schwerpunkt is one of them.
    assertion(memberchk(orientation_is_schwerpunkt, Principles)).

% Each OODA phase maps onto the hierarchical_planning middle-layer step names.
test(hplan_mapping_of_observe_and_feedback) :-
    % Observe maps onto the see and observe steps.
    assertion(ooda_hplan_map(observe, [see, observe])),
    % The feedback phase maps onto the re-observe-and-update step.
    assertion(ooda_hplan_map(feedback, [reobserve_update])).

% Recall gathers every held concept whose key or text mentions the topic.
test(recall_finds_schwerpunkt_concepts) :-
    % Recall every concept mentioning the schwerpunkt.
    ooda_recall(schwerpunkt, Items),
    % Exactly two concepts mention it.
    assertion(length(Items, 2)),
    % The orient phase is one of them (matched inside its description text).
    assertion(memberchk(concept(phase, orient, _), Items)),
    % The orientation-is-schwerpunkt principle is the other (matched on its key).
    assertion(memberchk(concept(principle, orientation_is_schwerpunkt, _), Items)).

% Recall of a topic that appears nowhere returns the empty list.
test(recall_of_unknown_topic_is_empty) :-
    % Recall a topic present in none of the four fact families.
    ooda_recall(nonexistent_topic_zzz, Items),
    % No concept matches, so the list is empty.
    assertion(Items == []).

% The summary counts the phases, ingredients, principles, and held concepts.
test(stats_count_the_methodology) :-
    % Read the four-slot summary term.
    ooda_stats(stats(Phases, Ingredients, Principles, Held)),
    % There are four phases.
    assertion(Phases =:= 4),
    % There are five orientation ingredients.
    assertion(Ingredients =:= 5),
    % There are six principles.
    assertion(Principles =:= 6),
    % The held count is a non-negative integer (zero when jspace is absent).
    assertion((integer(Held), Held >= 0)).

% Holding the methodology in Jacobian Space is guarded and idempotent.
test(bootstrap_is_guarded_and_idempotent) :-
    % Bootstrapping succeeds even when the jspace pack is unavailable.
    assertion(ooda_bootstrap),
    % Running it a second time is safe and still succeeds.
    assertion(ooda_bootstrap).

% Close the test block for ooda_knowledge.
:- end_tests(ooda_knowledge).
