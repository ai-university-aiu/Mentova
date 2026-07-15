/*  Mentova — Social Reasoning Module Test Suite  (test_social)

    Behavioural PLUnit suite for src/mentova/social.pl. The module is a pure
    reasoning module: it carries its own social facts (roles, relationships,
    trust, groups, norms) and exports mentova_social/3, a query dispatcher that
    returns a Result term and a glass-box just(...) justification. Every test
    below drives one query form with fixed inputs and asserts the exact Result
    (and, where load-bearing, the justification) computed by hand from the
    module's asserted facts.

    Run with the full library path over every PrologAI pack plus the Mentova
    source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" test/test_social.pl
*/

% Declare this file as a test module exporting nothing.
:- module(test_social, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(social)).

% Open the test block for the social module.
:- begin_tests(social).

% AC-SOCIAL-001: a role query returns the agent's role in a context, with a role_lookup justification.
test(role_lookup_teacher) :-
    % Ask for alice's role in the school context.
    mentova_social(role(alice, school), Result, Just),
    % The result names alice as the teacher at school.
    assertion(Result == role(alice, teacher, school)),
    % The justification records that this came from a role lookup returning the teacher role.
    assertion(Just == just(social(role_lookup(alice, school), role(teacher)))).

% AC-SOCIAL-002: a relationship query returns the first-direction relation with its type and strength.
test(relationship_forward) :-
    % Ask for the relationship from alice to bob.
    mentova_social(relationship(alice, bob), Result, Just),
    % The first asserted relation alice->bob is the teacher_student bond at strength 0.8.
    assertion(Result == relation(alice, bob, teacher_student, 0.8)),
    % The justification names the relation lookup, its type, and its strength.
    assertion(Just == just(social(relation_lookup(alice, bob), type(teacher_student), strength(0.8)))).

% AC-SOCIAL-003: a relationship query is symmetric — the reverse direction still finds the stored relation.
test(relationship_reverse) :-
    % Ask for the relationship from bob to alice, which is not stored in that order.
    mentova_social(relationship(bob, alice), Result, _Just),
    % The second clause finds the alice->bob teacher_student relation instead of failing.
    assertion(Result == relation(alice, bob, teacher_student, 0.8)).

% AC-SOCIAL-004: a trust query returns the recorded trust level, with a level justification.
test(trust_recorded) :-
    % Ask whether alice trusts carol.
    mentova_social(trust(alice, carol), Result, Just),
    % The recorded level of alice's trust in carol is high.
    assertion(Result == trust(alice, carol, high)),
    % The justification reports the trust lookup returning the high level.
    assertion(Just == just(social(trust_lookup(alice, carol), level(high)))).

% AC-SOCIAL-005: a trust query with no stored record reports trust_unrecorded via negation as failure.
test(trust_unrecorded) :-
    % Ask whether carol trusts bob, a pair with no trust fact (only bob->carol is stored).
    mentova_social(trust(carol, bob), Result, Just),
    % With no record, the module reports the pair as unrecorded rather than failing.
    assertion(Result == trust_unrecorded(carol, bob)),
    % The justification reports the trust lookup finding no record.
    assertion(Just == just(social(trust_lookup(carol, bob), result(no_record)))).

% AC-SOCIAL-006: a group-membership query collects every group an agent belongs to, as Group-Type pairs.
test(group_membership) :-
    % Ask which groups alice belongs to.
    mentova_social(group_of(alice), Result, _Just),
    % alice is a member of school_staff, classroom_1, and family_unit, each tagged with its type.
    assertion(Result == groups(alice, [school_staff-professional, classroom_1-instructional, family_unit-family])).

% AC-SOCIAL-007: a group-membership query for an agent in no groups returns the empty list, not failure.
test(group_membership_none) :-
    % Ask which groups the mentor agent belongs to (the mentor appears only in relations and trust).
    mentova_social(group_of(mentor), Result, _Just),
    % findall never fails, so an agent in no group yields an empty membership list.
    assertion(Result == groups(mentor, [])).

% AC-SOCIAL-008: a norms query lists every norm attached to a role in a context.
test(norms_for_teacher) :-
    % Ask for the norms a teacher must follow at school.
    mentova_social(norms_for(teacher, school), Result, _Just),
    % A teacher at school is expected to prepare lessons and treat students fairly.
    assertion(Result == norms(teacher, school, [prepare_lessons, treat_fairly])).

% AC-SOCIAL-009: a group-lookup query returns the members and type of a named group.
test(who_is_in_group) :-
    % Ask who is in classroom_1.
    mentova_social(who_is_in(classroom_1), Result, Just),
    % classroom_1 is an instructional group containing alice and bob.
    assertion(Result == members(classroom_1, [alice, bob], instructional)),
    % The justification names the group lookup, its members, and its type.
    assertion(Just == just(social(group_lookup(classroom_1), members([alice, bob]), type(instructional)))).

% Close the test block for the social module.
:- end_tests(social).
