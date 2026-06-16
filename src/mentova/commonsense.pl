/*  Mentova — Rung 11: Commonsense Reasoning Module

    Answers everyday-knowledge questions using the Small-World knowledge base
    and a set of commonsense inference rules.

    Every answer carries a provenance: the fact or rule chain that produced it.

    Pass criterion: answer matches common sense with provenance.
*/

:- module(commonsense, [
    mentova_commonsense/3
]).

:- use_module('../../knowledge/small_world', [
    is_a/2, capable_of/2, has_property/2, at_location/2,
    used_for/2, causes/2, motivated_by/2, has_prerequisite/2
]).
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Commonsense inference rules (everyday knowledge)
% ---------------------------------------------------------------------------

% can_do(X, Action): X can perform Action (directly or via is_a chain)
can_do(X, Action) :-
    capable_of(X, Action),
    provenance(can_do(X, Action), direct(capable_of(X, Action))).
can_do(X, Action) :-
    is_a(X, Parent),
    capable_of(Parent, Action).

% needs_to_be(X, Place): X needs to be in Place to do something typical
needs_to_be(X, Place) :-
    at_location(X, Place).
needs_to_be(X, Place) :-
    is_a(X, Parent),
    at_location(Parent, Place).

% what_does(X, Action) — what is X typically used for
what_does(X, Action) :-
    used_for(X, Action).
what_does(X, Action) :-
    capable_of(X, Action).

% if_then(Cond, Effect) — commonsense conditional
if_then(Cond, Effect) :-
    causes(Cond, Effect).

% provenance/2 — dummy for meta-annotation (not stored, just for docs)
provenance(_, _) :- true.

% ---------------------------------------------------------------------------
% mentova_commonsense(+Query, -Answer, -Justification)
% ---------------------------------------------------------------------------

% What is X? (classification)
mentova_commonsense(what_is(X), Answer, just(is_a(X, Answer))) :-
    is_a(X, Answer).

% What can X do?
mentova_commonsense(what_can(X), Answer, just(capable_of(X, Answer, via(Path)))) :-
    ( capable_of(X, Answer)
    ->  Path = direct
    ;   is_a(X, Parent), capable_of(Parent, Answer), Path = via_parent(Parent)
    ).

% Where is X typically found?
mentova_commonsense(where_is(X), Place, just(at_location(X, Place, via(Path)))) :-
    ( at_location(X, Place)
    ->  Path = direct
    ;   is_a(X, Parent), at_location(Parent, Place), Path = via_parent(Parent)
    ).

% What is X used for?
mentova_commonsense(used_for(X), Purpose, just(used_for(X, Purpose))) :-
    used_for(X, Purpose).

% What does X cause?
mentova_commonsense(what_causes(X), Effect, just(causes(X, Effect))) :-
    causes(X, Effect).

% What does X need to happen?
mentova_commonsense(prerequisite(X), Prereq, just(has_prerequisite(X, Prereq))) :-
    has_prerequisite(X, Prereq).

% What property does X have?
mentova_commonsense(property_of(X), Prop, just(has_property(X, Prop))) :-
    has_property(X, Prop).

% Is X a living thing?
mentova_commonsense(is_living(X), Answer, just(is_living(X, Answer, via(Chain)))) :-
    ( is_living_thing(X, Chain)
    ->  Answer = yes
    ;   Answer = no, Chain = []
    ).

is_living_thing(X, [X, living_thing]) :-
    is_a(X, living_thing).
is_living_thing(X, [X|Chain]) :-
    is_a(X, Parent),
    is_living_thing(Parent, Chain).
