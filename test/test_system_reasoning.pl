/*  Mentova — System Reasoning Test Suite

    Behavioural PLUnit tests for the system_reasoning module, which answers
    whole-system-behaviour questions from parts, interactions, and emergent
    behaviours through the single exported predicate mentova_system/3.

    Run with the full library path (every PrologAI pack plus Mentova src):
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
            -g "run_tests, halt" -t "halt(1)" test/test_system_reasoning.pl
*/

% Declare this file as a test module with no exports.
:- module(test_system_reasoning, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(system_reasoning)).

% Open the test block for system_reasoning.
:- begin_tests(system_reasoning).

% AC-SR-001: parts(bicycle) returns every Part-Role pair in fact order.
test(parts_of_bicycle) :-
    % Ask which parts and roles make up the bicycle system.
    mentova_system(parts(bicycle), Parts, Just),
    % The six bicycle parts come back paired with their roles, in fact order.
    assertion(Parts == [wheel-rolls, frame-supports, pedal-drives,
                        chain-transmits, brake-stops, handlebar-steers]),
    % The justification echoes the system name and the same part list.
    assertion(Just == just(system_parts(bicycle,
                        [wheel-rolls, frame-supports, pedal-drives,
                         chain-transmits, brake-stops, handlebar-steers]))).

% AC-SR-002: parts(plant) returns the four plant parts with their roles.
test(parts_of_plant) :-
    % Ask which parts and roles make up the plant system.
    mentova_system(parts(plant), Parts, _),
    % The four plant parts come back paired with their roles, in fact order.
    assertion(Parts == [roots-absorbs_water, stem-transports,
                        leaf-photosynthesises, flower-reproduces]).

% AC-SR-003: role(bicycle, brake) reports the brake's role as stopping.
test(role_of_brake) :-
    % Ask what the brake does in the bicycle system, taking the first answer.
    once(mentova_system(role(bicycle, brake), Role, Just)),
    % The brake's role is to stop.
    assertion(Role == stops),
    % The justification names the system, part, and role.
    assertion(Just == just(part_role(bicycle, brake, stops))).

% AC-SR-004: behavior(bicycle) enumerates every emergent whole behaviour.
test(behaviors_of_bicycle) :-
    % Collect every whole-system behaviour the bicycle exhibits.
    findall(B, mentova_system(behavior(bicycle), B, _), Behaviors),
    % The bicycle both moves forward and can stop, in fact order.
    assertion(Behaviors == [moves_forward, can_stop]).

% AC-SR-005: if_fails names only behaviours whose mechanism uses the failed part.
test(if_fails_wheel_loses_forward_motion) :-
    % Ask which behaviours are lost when the rolling wheel fails.
    mentova_system(if_fails(bicycle, wheel(rolls)), Lost, _),
    % Only forward motion depends on the rolling wheel.
    assertion(Lost == [moves_forward]).

% AC-SR-006: if_fails distinguishes a stopping part from a driving part.
test(if_fails_brake_loses_stopping) :-
    % Ask which behaviours are lost when the stopping brake fails.
    mentova_system(if_fails(bicycle, brake(stops)), Lost, _),
    % Only the ability to stop depends on the brake.
    assertion(Lost == [can_stop]).

% AC-SR-007: trace reports the effect of one part acting on another.
test(trace_pedal_drives_chain) :-
    % Ask what the pedal produces when it acts on the chain.
    mentova_system(trace(bicycle, pedal, chain), Effect, Just),
    % The pedal drives the chain.
    assertion(Effect == drives_chain),
    % The justification records the interaction and its effect.
    assertion(Just == just(interaction_trace(bicycle, pedal, chain,
                        effect(drives_chain)))).

% AC-SR-008: trace works across a different system's interactions too.
test(trace_roots_send_water_up_plant) :-
    % Ask what the roots produce when they act on the stem.
    mentova_system(trace(plant, roots, stem), Effect, _),
    % The roots send water up the stem.
    assertion(Effect == sends_water_up).

% Close the test block for system_reasoning.
:- end_tests(system_reasoning).
