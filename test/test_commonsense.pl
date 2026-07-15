/*  Mentova — Commonsense Reasoning Module Test Suite  (commonsense)

    Genuine PLUnit coverage for src/mentova/commonsense.pl, the Rung 11
    commonsense reasoning module. The module is pure: it answers everyday-
    knowledge questions by reading the compiled-in Small-World knowledge
    base (knowledge/small_world.pl), so no lattice, server, or asserted
    state is needed. Its single export mentova_commonsense(+Query, -Answer,
    -Justification) recognises eight query functors — what_is, what_can,
    where_is, used_for, what_causes, prerequisite, property_of, is_living —
    and every answer carries a glass-box just(...) provenance term.

    Every expected value below is computed by hand from the small_world
    facts (is_a/2, capable_of/2, at_location/2, used_for/2, causes/2,
    has_prerequisite/2, has_property/2) and the module's is_a chaining,
    then asserted exactly.

    Run with the full library path (every PrologAI pack plus the Mentova src):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_commonsense.pl
*/

% Declare this file as a test module with no exports.
:- module(test_commonsense, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(commonsense)).

% Open the test block for the commonsense module.
:- begin_tests(commonsense).

% CS-001: what_is classifies a canary as a bird directly from is_a/2.
test(what_is_classifies_direct) :-
    % Ask what a canary is.
    mentova_commonsense(what_is(canary), Answer, Justification),
    % The direct taxonomic parent of canary is bird.
    assertion(Answer == bird),
    % The justification is the documented is_a provenance term.
    assertion(Justification == just(is_a(canary, bird))).

% CS-002: what_is also classifies a manufactured object — a knife is a tool.
test(what_is_classifies_tool) :-
    % Ask what a knife is.
    mentova_commonsense(what_is(knife), Answer, _),
    % Its taxonomic parent in small_world is tool.
    assertion(Answer == tool).

% CS-003: what_can reads a directly-stored capability with a direct provenance path.
test(what_can_direct_capability) :-
    % Ask what a dog can do.
    mentova_commonsense(what_can(dog), Answer, Justification),
    % capable_of(dog, bark) is stored directly.
    assertion(Answer == bark),
    % The provenance names a direct path, not an inherited one.
    assertion(Justification == just(capable_of(dog, bark, via(direct)))).

% CS-004: what_can inherits a capability up the is_a chain when none is direct.
test(what_can_inherited_capability) :-
    % Ask what a canary can do, which has no direct capability.
    mentova_commonsense(what_can(canary), Answer, Justification),
    % A canary is a bird, and capable_of(bird, fly) is inherited.
    assertion(Answer == fly),
    % The provenance records the inheritance through the bird parent.
    assertion(Justification == just(capable_of(canary, fly, via(via_parent(bird))))).

% CS-005: where_is reads a directly-stored location with a direct provenance path.
test(where_is_direct_location) :-
    % Ask where a cat is typically found.
    mentova_commonsense(where_is(cat), Place, Justification),
    % at_location(cat, house) is stored directly.
    assertion(Place == house),
    % The provenance names a direct path.
    assertion(Justification == just(at_location(cat, house, via(direct)))).

% CS-006: where_is inherits a location up the is_a chain when none is direct.
test(where_is_inherited_location) :-
    % Ask where a canary is typically found, which has no direct location.
    mentova_commonsense(where_is(canary), Place, Justification),
    % A canary is a bird, and at_location(bird, sky) is inherited.
    assertion(Place == sky),
    % The provenance records the inheritance through the bird parent.
    assertion(Justification == just(at_location(canary, sky, via(via_parent(bird))))).

% CS-007: used_for returns the purpose stored for an artifact.
test(used_for_returns_purpose) :-
    % Ask what a knife is used for.
    mentova_commonsense(used_for(knife), Purpose, Justification),
    % used_for(knife, cutting) is the stored purpose.
    assertion(Purpose == cutting),
    % The justification is the documented used_for provenance term.
    assertion(Justification == just(used_for(knife, cutting))).

% CS-008: what_causes returns the effect stored for a cause.
test(what_causes_returns_effect) :-
    % Ask what fire causes.
    mentova_commonsense(what_causes(fire), Effect, Justification),
    % causes(fire, smoke) is the stored causal fact.
    assertion(Effect == smoke),
    % The justification is the documented causes provenance term.
    assertion(Justification == just(causes(fire, smoke))).

% CS-009: prerequisite returns the precondition stored for an action.
test(prerequisite_returns_precondition) :-
    % Ask what flying requires.
    mentova_commonsense(prerequisite(flying), Prereq, Justification),
    % has_prerequisite(flying, having_wings) is the stored precondition.
    assertion(Prereq == having_wings),
    % The justification is the documented has_prerequisite provenance term.
    assertion(Justification == just(has_prerequisite(flying, having_wings))).

% CS-010: property_of returns a property stored for a subject.
test(property_of_returns_property) :-
    % Ask what property a rose has.
    mentova_commonsense(property_of(rose), Prop, Justification),
    % has_property(rose, red) is the stored property.
    assertion(Prop == red),
    % The justification is the documented has_property provenance term.
    assertion(Justification == just(has_property(rose, red))).

% CS-011: is_living answers yes and returns the full is_a chain up to living_thing.
test(is_living_yes_with_chain) :-
    % Ask whether a canary is a living thing.
    mentova_commonsense(is_living(canary), Answer, Justification),
    % A canary reaches living_thing through bird then animal, so the answer is yes.
    assertion(Answer == yes),
    % The provenance carries the full ancestry chain ending at living_thing.
    assertion(Justification == just(is_living(canary, yes,
                                              via([canary, bird, animal, living_thing])))).

% CS-012: is_living answers no with an empty chain for a non-living object.
test(is_living_no_for_object) :-
    % Ask whether a knife is a living thing.
    mentova_commonsense(is_living(knife), Answer, Justification),
    % A knife is a tool and never reaches living_thing, so the answer is no.
    assertion(Answer == no),
    % The provenance carries an empty chain when nothing living was reached.
    assertion(Justification == just(is_living(knife, no, via([])))).

% CS-013: an unclassifiable subject yields no answer — the query fails cleanly.
test(what_is_top_of_hierarchy_fails, [fail]) :-
    % living_thing is the root of the taxonomy and has no is_a parent.
    mentova_commonsense(what_is(living_thing), _Answer, _Justification).

% Close the test block for the commonsense module.
:- end_tests(commonsense).
