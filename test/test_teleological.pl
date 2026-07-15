/*  Mentova — Teleological Reasoning Test Suite  (Rung 39)

    Behavioural PLUnit tests for the pure 'teleological' reasoning module,
    which answers "what is X for?" from a static purpose knowledge base.

    Run with the full library path (every PrologAI pack plus the Mentova
    source directory on the library path):
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_teleological.pl
*/

% Declare this file as a test module.
:- module(test_teleological, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(teleological)).

% Open the test block for teleological.
:- begin_tests(teleological).

% AC-TEL-001: purpose_of a known entity returns its purpose and chain.
test(purpose_of_known_entity) :-
    % Ask what the heart is for.
    mentova_teleological(purpose_of(heart), Result, Just),
    % The result names the heart's purpose and full teleological chain.
    assertion(Result == purpose(heart, pump_blood,
                                serves(circulatory_system,
                                       enables(oxygen_delivery, enables(cell_survival))))),
    % The justification records the entity, its purpose atom, and the chain.
    assertion(Just == just(teleological(entity(heart),
                                        purpose(pump_blood),
                                        chain(serves(circulatory_system,
                                                     enables(oxygen_delivery, enables(cell_survival))))))).

% AC-TEL-002: purpose_of an unknown entity reports no purpose recorded.
test(purpose_of_unknown_entity) :-
    % Ask what an entity absent from the base is for.
    mentova_teleological(purpose_of(quark), Result, Just),
    % The result is the explicit no-purpose sentinel for that entity.
    assertion(Result == no_purpose_recorded(quark)),
    % The justification marks the result as unknown.
    assertion(Just == just(teleological(entity(quark), result(unknown)))).

% AC-TEL-003: ultimate_goal returns the deepest end the entity serves.
test(ultimate_goal_deepest_end) :-
    % Ask for the ultimate goal the heart serves.
    mentova_teleological(ultimate_goal(heart), Result, Just),
    % The deepest enable in the heart's chain is cell survival.
    assertion(Result == ultimate(heart, cell_survival)),
    % The justification names that ultimate goal.
    assertion(Just == just(teleological(entity(heart), ultimate_goal(cell_survival)))).

% AC-TEL-004: ultimate_goal works for an artifact as well as an organ.
test(ultimate_goal_artifact) :-
    % Ask for the ultimate goal a hammer serves.
    mentova_teleological(ultimate_goal(hammer), Result, _Just),
    % The deepest enable in the hammer's chain is structure building.
    assertion(Result == ultimate(hammer, structure_building)).

% AC-TEL-005: what_serves collects every entity that fulfils a purpose.
test(what_serves_collects_entities) :-
    % Ask which entities exist to pump blood.
    mentova_teleological(what_serves(pump_blood), Result, Just),
    % Exactly the heart serves that purpose.
    assertion(Result == entities(pump_blood, [heart])),
    % The justification lists the collected entities.
    assertion(Just == just(teleological(serves_query(pump_blood), list([heart])))).

% AC-TEL-006: what_serves returns an empty list for an unrecorded purpose.
test(what_serves_empty_for_unknown_purpose) :-
    % Ask which entities serve a purpose the base never records.
    mentova_teleological(what_serves(nonexistent_purpose), Result, _Just),
    % The findall-backed query never fails and yields the empty list.
    assertion(Result == entities(nonexistent_purpose, [])).

% AC-TEL-007: why explains an entity by its reason and supporting chain.
test(why_explains_entity) :-
    % Ask why a hammer is used.
    mentova_teleological(why(hammer), Result, Just),
    % The reason is to drive nails, with the construction chain attached.
    assertion(Result == why(hammer, drive_nails,
                            serves(construction_task,
                                   enables(joining_materials, enables(structure_building))))),
    % The justification records the why-query, the reason, and the chain.
    assertion(Just == just(teleological(why_query(hammer),
                                        because(drive_nails),
                                        chain(serves(construction_task,
                                                     enables(joining_materials, enables(structure_building))))))).

% Close the test block for teleological.
:- end_tests(teleological).
