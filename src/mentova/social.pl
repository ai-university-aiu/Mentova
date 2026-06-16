/*  Mentova — Rung 42: Social Reasoning Module

    Reasons about social structures: roles, relationships, trust,
    group membership, and social norms.
    Pass criterion: given a social query, return the relationship type,
    trust level, and applicable norms with justification.
*/

% Declare this file as the 'social' module and list its exported predicates.
:- module(social, [
    % Supply 'mentova_social/3' as the next argument to the expression above.
    mentova_social/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Social roles: role(Agent, Role, Context)
% ---------------------------------------------------------------------------

% State the fact: social role(alice,   teacher,    school).
social_role(alice,   teacher,    school).
% State the fact: social role(bob,     student,    school).
social_role(bob,     student,    school).
% State the fact: social role(carol,   principal,  school).
social_role(carol,   principal,  school).
% State the fact: social role(alice,   colleague,  workplace).
social_role(alice,   colleague,  workplace).
% State the fact: social role(bob,     colleague,  workplace).
social_role(bob,     colleague,  workplace).
% State the fact: social role(carol,   manager,    workplace).
social_role(carol,   manager,    workplace).
% State the fact: social role(alice,   parent,     family).
social_role(alice,   parent,     family).
% State the fact: social role(bob,     child,      family).
social_role(bob,     child,      family).

% ---------------------------------------------------------------------------
% Relationships: relation(A, B, Type, Strength)
% Strength: 1.0 (strong) to 0.0 (none)
% ---------------------------------------------------------------------------

% State the fact: relation(alice,  bob,   teacher_student, 0.8).
relation(alice,  bob,   teacher_student, 0.8).
% State the fact: relation(alice,  carol, peer,            0.6).
relation(alice,  carol, peer,            0.6).
% State the fact: relation(bob,    carol, student_manager, 0.5).
relation(bob,    carol, student_manager, 0.5).
% State the fact: relation(alice,  bob,   family,          0.9).
relation(alice,  bob,   family,          0.9).
% State the fact: relation(mentor, alice, mentor_mentee,   0.7).
relation(mentor, alice, mentor_mentee,   0.7).

% ---------------------------------------------------------------------------
% Trust: trust(A, B, Level)
% Level: high | medium | low
% ---------------------------------------------------------------------------

% State the fact: trust(alice,  carol, high).
trust(alice,  carol, high).
% State the fact: trust(bob,    alice, high).
trust(bob,    alice, high).
% State the fact: trust(bob,    carol, medium).
trust(bob,    carol, medium).
% State the fact: trust(alice,  mentor, high).
trust(alice,  mentor, high).
% State the fact: trust(mentor, alice,  medium).
trust(mentor, alice,  medium).

% ---------------------------------------------------------------------------
% Group membership: group(GroupId, Members, Type)
% ---------------------------------------------------------------------------

% State the fact: group(school_staff,   [alice, carol],       professional).
group(school_staff,   [alice, carol],       professional).
% State the fact: group(classroom_1,    [alice, bob],         instructional).
group(classroom_1,    [alice, bob],         instructional).
% State the fact: group(family_unit,    [alice, bob],         family).
group(family_unit,    [alice, bob],         family).
% State the fact: group(management,     [carol],              administrative).
group(management,     [carol],              administrative).

% ---------------------------------------------------------------------------
% Social norms: norm(Role, Norm, Context)
% ---------------------------------------------------------------------------

% State the fact: social norm(teacher,   prepare_lessons,    school).
social_norm(teacher,   prepare_lessons,    school).
% State the fact: social norm(teacher,   treat_fairly,       school).
social_norm(teacher,   treat_fairly,       school).
% State the fact: social norm(student,   attend_class,       school).
social_norm(student,   attend_class,       school).
% State the fact: social norm(student,   respect_teacher,    school).
social_norm(student,   respect_teacher,    school).
% State the fact: social norm(manager,   evaluate_fairly,    workplace).
social_norm(manager,   evaluate_fairly,    workplace).
% State the fact: social norm(colleague, collaborate,        workplace).
social_norm(colleague, collaborate,        workplace).
% State the fact: social norm(parent,    provide_support,    family).
social_norm(parent,    provide_support,    family).
% State the fact: social norm(child,     respect_parent,     family).
social_norm(child,     respect_parent,     family).

% ---------------------------------------------------------------------------
% mentova_social(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova social' with the arguments listed below.
mentova_social(role(Agent, Context), role(Agent, Role, Context),
               % Continue the multi-line expression started above.
               just(social(role_lookup(Agent, Context), role(Role)))) :-
    % State a fact for 'social role' with the arguments listed below.
    social_role(Agent, Role, Context), !.

% State a fact for 'mentova social' with the arguments listed below.
mentova_social(relationship(A, B), relation(A, B, Type, Strength),
               % Continue the multi-line expression started above.
               just(social(relation_lookup(A, B),
                            % Continue the multi-line expression started above.
                            type(Type), strength(Strength)))) :-
    % State a fact for 'relation' with the arguments listed below.
    relation(A, B, Type, Strength), !.
% State a fact for 'mentova social' with the arguments listed below.
mentova_social(relationship(A, B), relation(B, A, Type, Strength),
               % Continue the multi-line expression started above.
               just(social(relation_lookup(A, B),
                            % Continue the multi-line expression started above.
                            type(Type), strength(Strength)))) :-
    % State a fact for 'relation' with the arguments listed below.
    relation(B, A, Type, Strength), !.

% State a fact for 'mentova social' with the arguments listed below.
mentova_social(trust(A, B), trust(A, B, Level),
               % Continue the multi-line expression started above.
               just(social(trust_lookup(A, B), level(Level)))) :-
    % State a fact for 'trust' with the arguments listed below.
    trust(A, B, Level), !.

% State a fact for 'mentova social' with the arguments listed below.
mentova_social(trust(A, B), trust_unrecorded(A, B),
               % Continue the multi-line expression started above.
               just(social(trust_lookup(A, B), result(no_record)))) :-
    % Succeed only if 'trust(A, B, _' cannot be proved (negation as failure).
    \+ trust(A, B, _).

% State a fact for 'mentova social' with the arguments listed below.
mentova_social(group_of(Agent), groups(Agent, Gs),
               % Continue the multi-line expression started above.
               just(social(group_membership(Agent), list(Gs)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(G-T, (group(G, Members, T), member(Agent, Members)), Gs).

% State a fact for 'mentova social' with the arguments listed below.
mentova_social(norms_for(Role, Context), norms(Role, Context, Norms),
               % Continue the multi-line expression started above.
               just(social(norm_lookup(Role, Context), list(Norms)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(N, social_norm(Role, N, Context), Norms).

% State a fact for 'mentova social' with the arguments listed below.
mentova_social(who_is_in(Group), members(Group, Members, Type),
               % Continue the multi-line expression started above.
               just(social(group_lookup(Group), members(Members), type(Type)))) :-
    % State the fact: group(Group, Members, Type).
    group(Group, Members, Type).
