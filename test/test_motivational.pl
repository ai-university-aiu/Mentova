/*  Mentova — Motivational Reasoning Test Suite  (Rung 45)

    Genuine behavioural coverage for src/mentova/motivational.pl. The module
    is a pure need/drive knowledge base (Maslow-inspired) with one exported
    predicate, mentova_motivational/3, that dispatches on the query term. Each
    test drives a documented query with a known agent and asserts the exact
    Result and Justification computed by hand from the module's facts.

    Run with the full PrologAI pack library path plus the Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
          -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_motivational.pl
*/

% Declare this file as a test module with no exports.
:- module(test_motivational, []).
% Load the PLUnit testing framework.
:- use_module(library(plunit)).
% Load the module under test by its library name.
:- use_module(library(motivational)).

% Open the motivational reasoning test block.
:- begin_tests(motivational).

% The top drive for alice is her highest-urgency drive, achieve_recognition (high).
test(top_drive_alice) :-
    % Ask the module for alice's top drive, taking the first documented solution.
    once(mentova_motivational(top_drive(alice), Result, Just)),
    % The result names the winning drive with its urgency.
    assertion(Result == drive(alice, achieve_recognition, high)),
    % The justification records agent, drive, and urgency.
    assertion(Just == just(motivational(agent(alice),
                                        top_drive(achieve_recognition),
                                        urgency(high)))).

% The top drive for the mentor is share_knowledge, the only high-urgency drive.
test(top_drive_mentor) :-
    % Ask the module for the mentor's top drive, taking the first documented solution.
    once(mentova_motivational(top_drive(mentor), Result, _)),
    % share_knowledge outranks the medium explore_ideas.
    assertion(Result == drive(mentor, share_knowledge, high)).

% Alice has satisfied levels 1 to 3, so her most urgent need is level 4, esteem.
test(urgent_need_alice) :-
    % Ask the module for alice's most urgent unsatisfied need, first solution.
    once(mentova_motivational(urgent_need(alice), Result, Just)),
    % The lowest unsatisfied level is esteem at level 4.
    assertion(Result == need(4, esteem, 'respect, achievement, recognition, status')),
    % The justification carries the level, name, and description.
    assertion(Just == just(motivational(agent(alice),
                                        urgent_need(4, esteem),
                                        desc('respect, achievement, recognition, status')))).

% Bob has satisfied only level 1, so his most urgent need is level 2, safety.
test(urgent_need_bob) :-
    % Ask the module for bob's most urgent unsatisfied need, first solution.
    once(mentova_motivational(urgent_need(bob), Result, _)),
    % The lowest unsatisfied level for bob is safety at level 2.
    assertion(Result == need(2, safety, 'security, order, stability, freedom from fear')).

% The mentor has every level satisfied, so the query reports all_satisfied.
test(urgent_need_mentor_all_satisfied) :-
    % Ask the module for the mentor's most urgent unsatisfied need, first solution.
    once(mentova_motivational(urgent_need(mentor), Result, Just)),
    % With nothing unsatisfied the result flags the mentor as fully satisfied.
    assertion(Result == all_satisfied(mentor)),
    % The justification declares all needs satisfied.
    assertion(Just == just(motivational(agent(mentor),
                                        result(all_needs_satisfied)))).

% Listing all of alice's drives returns each drive paired with its urgency.
test(all_drives_alice) :-
    % Ask the module for the full drive list for alice, first solution.
    once(mentova_motivational(all_drives(alice), Result, _)),
    % The list holds every drive fact for alice in declaration order.
    assertion(Result == drives(alice, [achieve_recognition-high,
                                       deepen_relationships-medium,
                                       learn_new_skills-medium])).

% Listing alice's satisfied needs pairs each satisfied level with its need name.
test(satisfied_needs_alice) :-
    % Ask the module for alice's satisfied-need levels, first solution.
    once(mentova_motivational(satisfied_needs(alice), Result, _)),
    % Levels 1 to 3 map to physiological, safety, and belonging.
    assertion(Result == satisfied_list(alice, [1-physiological,
                                               2-safety,
                                               3-belonging])).

% Close the motivational reasoning test block.
:- end_tests(motivational).
