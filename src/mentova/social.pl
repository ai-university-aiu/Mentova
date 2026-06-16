/*  Mentova — Rung 42: Social Reasoning Module

    Reasons about social structures: roles, relationships, trust,
    group membership, and social norms.
    Pass criterion: given a social query, return the relationship type,
    trust level, and applicable norms with justification.
*/

:- module(social, [
    mentova_social/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Social roles: role(Agent, Role, Context)
% ---------------------------------------------------------------------------

social_role(alice,   teacher,    school).
social_role(bob,     student,    school).
social_role(carol,   principal,  school).
social_role(alice,   colleague,  workplace).
social_role(bob,     colleague,  workplace).
social_role(carol,   manager,    workplace).
social_role(alice,   parent,     family).
social_role(bob,     child,      family).

% ---------------------------------------------------------------------------
% Relationships: relation(A, B, Type, Strength)
% Strength: 1.0 (strong) to 0.0 (none)
% ---------------------------------------------------------------------------

relation(alice,  bob,   teacher_student, 0.8).
relation(alice,  carol, peer,            0.6).
relation(bob,    carol, student_manager, 0.5).
relation(alice,  bob,   family,          0.9).
relation(mentor, alice, mentor_mentee,   0.7).

% ---------------------------------------------------------------------------
% Trust: trust(A, B, Level)
% Level: high | medium | low
% ---------------------------------------------------------------------------

trust(alice,  carol, high).
trust(bob,    alice, high).
trust(bob,    carol, medium).
trust(alice,  mentor, high).
trust(mentor, alice,  medium).

% ---------------------------------------------------------------------------
% Group membership: group(GroupId, Members, Type)
% ---------------------------------------------------------------------------

group(school_staff,   [alice, carol],       professional).
group(classroom_1,    [alice, bob],         instructional).
group(family_unit,    [alice, bob],         family).
group(management,     [carol],              administrative).

% ---------------------------------------------------------------------------
% Social norms: norm(Role, Norm, Context)
% ---------------------------------------------------------------------------

social_norm(teacher,   prepare_lessons,    school).
social_norm(teacher,   treat_fairly,       school).
social_norm(student,   attend_class,       school).
social_norm(student,   respect_teacher,    school).
social_norm(manager,   evaluate_fairly,    workplace).
social_norm(colleague, collaborate,        workplace).
social_norm(parent,    provide_support,    family).
social_norm(child,     respect_parent,     family).

% ---------------------------------------------------------------------------
% mentova_social(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_social(role(Agent, Context), role(Agent, Role, Context),
               just(social(role_lookup(Agent, Context), role(Role)))) :-
    social_role(Agent, Role, Context), !.

mentova_social(relationship(A, B), relation(A, B, Type, Strength),
               just(social(relation_lookup(A, B),
                            type(Type), strength(Strength)))) :-
    relation(A, B, Type, Strength), !.
mentova_social(relationship(A, B), relation(B, A, Type, Strength),
               just(social(relation_lookup(A, B),
                            type(Type), strength(Strength)))) :-
    relation(B, A, Type, Strength), !.

mentova_social(trust(A, B), trust(A, B, Level),
               just(social(trust_lookup(A, B), level(Level)))) :-
    trust(A, B, Level), !.

mentova_social(trust(A, B), trust_unrecorded(A, B),
               just(social(trust_lookup(A, B), result(no_record)))) :-
    \+ trust(A, B, _).

mentova_social(group_of(Agent), groups(Agent, Gs),
               just(social(group_membership(Agent), list(Gs)))) :-
    findall(G-T, (group(G, Members, T), member(Agent, Members)), Gs).

mentova_social(norms_for(Role, Context), norms(Role, Context, Norms),
               just(social(norm_lookup(Role, Context), list(Norms)))) :-
    findall(N, social_norm(Role, N, Context), Norms).

mentova_social(who_is_in(Group), members(Group, Members, Type),
               just(social(group_lookup(Group), members(Members), type(Type)))) :-
    group(Group, Members, Type).
