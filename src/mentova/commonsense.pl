/*  Mentova — Rung 11: Commonsense Reasoning Module

    Answers everyday-knowledge questions using the Small-World knowledge base
    and a set of commonsense inference rules.

    Every answer carries a provenance: the fact or rule chain that produced it.

    Pass criterion: answer matches common sense with provenance.
*/

% Declare this file as the 'commonsense' module and list its exported predicates.
:- module(commonsense, [
    % Supply 'mentova_commonsense/3' as the next argument to the expression above.
    mentova_commonsense/3
% Close the expression opened above.
]).

% Load the 'small_world' module so its predicates are available here.
:- use_module('../../knowledge/small_world', [
    % Continue the multi-line expression started above.
    is_a/2, capable_of/2, has_property/2, at_location/2,
    % Continue the multi-line expression started above.
    used_for/2, causes/2, motivated_by/2, has_prerequisite/2
% Close the expression opened above.
]).
% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Commonsense inference rules (everyday knowledge)
% ---------------------------------------------------------------------------

% can_do(X, Action): X can perform Action (directly or via is_a chain)
% Define a clause for 'can do': succeed when the following conditions hold.
can_do(X, Action) :-
    % State a fact for 'capable of' with the arguments listed below.
    capable_of(X, Action),
    % State the fact: provenance(can_do(X, Action), direct(capable_of(X, Action))).
    provenance(can_do(X, Action), direct(capable_of(X, Action))).
% Define a clause for 'can do': succeed when the following conditions hold.
can_do(X, Action) :-
    % State a fact for 'is a' with the arguments listed below.
    is_a(X, Parent),
    % State the fact: capable of(Parent, Action).
    capable_of(Parent, Action).

% needs_to_be(X, Place): X needs to be in Place to do something typical
% Define a clause for 'needs to be': succeed when the following conditions hold.
needs_to_be(X, Place) :-
    % State the fact: at location(X, Place).
    at_location(X, Place).
% Define a clause for 'needs to be': succeed when the following conditions hold.
needs_to_be(X, Place) :-
    % State a fact for 'is a' with the arguments listed below.
    is_a(X, Parent),
    % State the fact: at location(Parent, Place).
    at_location(Parent, Place).

% what_does(X, Action) — what is X typically used for
% Define a clause for 'what does': succeed when the following conditions hold.
what_does(X, Action) :-
    % State the fact: used for(X, Action).
    used_for(X, Action).
% Define a clause for 'what does': succeed when the following conditions hold.
what_does(X, Action) :-
    % State the fact: capable of(X, Action).
    capable_of(X, Action).

% if_then(Cond, Effect) — commonsense conditional
% Define a clause for 'if then': succeed when the following conditions hold.
if_then(Cond, Effect) :-
    % State the fact: causes(Cond, Effect).
    causes(Cond, Effect).

% provenance/2 — dummy for meta-annotation (not stored, just for docs)
% Define a clause for 'provenance': succeed when the following conditions hold.
provenance(_, _) :- true.

% ---------------------------------------------------------------------------
% mentova_commonsense(+Query, -Answer, -Justification)
% ---------------------------------------------------------------------------

% What is X? (classification)
% Define a clause for 'mentova commonsense': succeed when the following conditions hold.
mentova_commonsense(what_is(X), Answer, just(is_a(X, Answer))) :-
    % State the fact: is a(X, Answer).
    is_a(X, Answer).

% What can X do?
% Define a clause for 'mentova commonsense': succeed when the following conditions hold.
mentova_commonsense(what_can(X), Answer, just(capable_of(X, Answer, via(Path)))) :-
    % Execute: ( capable_of(X, Answer).
    ( capable_of(X, Answer)
    % If the condition above succeeded, perform the following action.
    ->  Path = direct
    % Otherwise (else branch), perform the following action.
    ;   is_a(X, Parent), capable_of(Parent, Answer), Path = via_parent(Parent)
    % Close the expression opened above.
    ).

% Where is X typically found?
% Define a clause for 'mentova commonsense': succeed when the following conditions hold.
mentova_commonsense(where_is(X), Place, just(at_location(X, Place, via(Path)))) :-
    % Execute: ( at_location(X, Place).
    ( at_location(X, Place)
    % If the condition above succeeded, perform the following action.
    ->  Path = direct
    % Otherwise (else branch), perform the following action.
    ;   is_a(X, Parent), at_location(Parent, Place), Path = via_parent(Parent)
    % Close the expression opened above.
    ).

% What is X used for?
% Define a clause for 'mentova commonsense': succeed when the following conditions hold.
mentova_commonsense(used_for(X), Purpose, just(used_for(X, Purpose))) :-
    % State the fact: used for(X, Purpose).
    used_for(X, Purpose).

% What does X cause?
% Define a clause for 'mentova commonsense': succeed when the following conditions hold.
mentova_commonsense(what_causes(X), Effect, just(causes(X, Effect))) :-
    % State the fact: causes(X, Effect).
    causes(X, Effect).

% What does X need to happen?
% Define a clause for 'mentova commonsense': succeed when the following conditions hold.
mentova_commonsense(prerequisite(X), Prereq, just(has_prerequisite(X, Prereq))) :-
    % State the fact: has prerequisite(X, Prereq).
    has_prerequisite(X, Prereq).

% What property does X have?
% Define a clause for 'mentova commonsense': succeed when the following conditions hold.
mentova_commonsense(property_of(X), Prop, just(has_property(X, Prop))) :-
    % State the fact: has property(X, Prop).
    has_property(X, Prop).

% Is X a living thing?
% Define a clause for 'mentova commonsense': succeed when the following conditions hold.
mentova_commonsense(is_living(X), Answer, just(is_living(X, Answer, via(Chain)))) :-
    % Execute: ( is_living_thing(X, Chain).
    ( is_living_thing(X, Chain)
    % If the condition above succeeded, perform the following action.
    ->  Answer = yes
    % Otherwise (else branch), perform the following action.
    ;   Answer = no, Chain = []
    % Close the expression opened above.
    ).

% Define a clause for 'is living thing': succeed when the following conditions hold.
is_living_thing(X, [X, living_thing]) :-
    % State the fact: is a(X, living_thing).
    is_a(X, living_thing).
% Define a clause for 'is living thing': succeed when the following conditions hold.
is_living_thing(X, [X|Chain]) :-
    % State a fact for 'is a' with the arguments listed below.
    is_a(X, Parent),
    % State the fact: is living thing(Parent, Chain).
    is_living_thing(Parent, Chain).
