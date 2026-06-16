/*  Mentova — Rung 33: Modal Reasoning Module

    Evaluates modal claims: necessarily true, possibly true, contingent.
    Uses Kripke-style possible-world accessibility relations.
    Pass criterion: a necessarily-true claim is distinguished from a
    merely-possible claim with justification naming the accessible worlds.
*/

% Declare this file as the 'modal' module and list its exported predicates.
:- module(modal, [
    % Supply 'mentova_modal/3' as the next argument to the expression above.
    mentova_modal/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Worlds and accessibility: accessible(World, From)
% ---------------------------------------------------------------------------

% State the fact: world(actual).
world(actual).
% State the fact: world(w1).
world(w1).
% State the fact: world(w2).
world(w2).
% State the fact: world(w3).
world(w3).

% Each world is accessible from actual (reflexive, transitive system S5-like)
% State the fact: accessible(actual, actual).
accessible(actual, actual).
% State the fact: accessible(w1,     actual).
accessible(w1,     actual).
% State the fact: accessible(w2,     actual).
accessible(w2,     actual).
% State the fact: accessible(w3,     actual).
accessible(w3,     actual).
% State the fact: accessible(w2,     w1).
accessible(w2,     w1).
% State the fact: accessible(w3,     w2).
accessible(w3,     w2).

% ---------------------------------------------------------------------------
% Facts true in each world: holds(Fact, World)
% ---------------------------------------------------------------------------

% State the fact: holds(birds_fly,          actual).
holds(birds_fly,          actual).
% State the fact: holds(birds_fly,          w1).
holds(birds_fly,          w1).
% State the fact: holds(birds_fly,          w2).
holds(birds_fly,          w2).
% State the fact: holds(birds_fly,          w3).
holds(birds_fly,          w3).

% State the fact: holds(tweety_flies,       w1).
holds(tweety_flies,       w1).
% State the fact: holds(tweety_flies,       w2).
holds(tweety_flies,       w2).
% tweety_flies is NOT true in actual (tweety is flightless) or w3

% State the fact: holds(fire_is_hot,        actual).
holds(fire_is_hot,        actual).
% State the fact: holds(fire_is_hot,        w1).
holds(fire_is_hot,        w1).
% State the fact: holds(fire_is_hot,        w2).
holds(fire_is_hot,        w2).
% State the fact: holds(fire_is_hot,        w3).
holds(fire_is_hot,        w3).

% State the fact: holds(water_is_wet,       actual).
holds(water_is_wet,       actual).
% State the fact: holds(water_is_wet,       w1).
holds(water_is_wet,       w1).
% State the fact: holds(water_is_wet,       w2).
holds(water_is_wet,       w2).
% State the fact: holds(water_is_wet,       w3).
holds(water_is_wet,       w3).

% State the fact: holds(canary_is_yellow,   actual).
holds(canary_is_yellow,   actual).
% State the fact: holds(canary_is_yellow,   w1).
holds(canary_is_yellow,   w1).
% State the fact: holds(canary_is_yellow,   w2).
holds(canary_is_yellow,   w2).
% State the fact: holds(canary_is_yellow,   w3).
holds(canary_is_yellow,   w3).

% State the fact: holds(it_rains,           w1).
holds(it_rains,           w1).
% State the fact: holds(it_rains,           w3).
holds(it_rains,           w3).
% not in actual or w2

% ---------------------------------------------------------------------------
% Modal operators
% ---------------------------------------------------------------------------

% Necessarily P: P holds in all accessible worlds from W
% Define a clause for 'necessarily': succeed when the following conditions hold.
necessarily(P, World) :-
    % Verify that for every solution of the Condition, the Action also holds.
    forall(accessible(W2, World), holds(P, W2)).

% Possibly P: P holds in at least one accessible world from W
% Define a clause for 'possibly': succeed when the following conditions hold.
possibly(P, World) :-
    % State a fact for 'accessible' with the arguments listed below.
    accessible(W2, World),
    % State the fact: holds(P, W2).
    holds(P, W2).

% Contingent P: possibly true but not necessarily true
% Define a clause for 'contingent': succeed when the following conditions hold.
contingent(P, World) :-
    % State a fact for 'possibly' with the arguments listed below.
    possibly(P, World),
    % Succeed only if 'necessarily(P, World' cannot be proved (negation as failure).
    \+ necessarily(P, World).

% ---------------------------------------------------------------------------
% mentova_modal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova modal' with the arguments listed below.
mentova_modal(necessarily(P), true,
              % Continue the multi-line expression started above.
              just(modal(necessarily(P), worlds_checked(all_accessible),
                         % Continue the multi-line expression started above.
                         result(true)))) :-
    % State a fact for 'necessarily' with the arguments listed below.
    necessarily(P, actual), !.

% State a fact for 'mentova modal' with the arguments listed below.
mentova_modal(necessarily(P), false,
              % Continue the multi-line expression started above.
              just(modal(necessarily(P), worlds_checked(all_accessible),
                         % Continue the multi-line expression started above.
                         result(false)))) :-
    % Succeed only if 'necessarily(P, actual' cannot be proved (negation as failure).
    \+ necessarily(P, actual).

% State a fact for 'mentova modal' with the arguments listed below.
mentova_modal(possibly(P), true,
              % Continue the multi-line expression started above.
              just(modal(possibly(P), witness_world(W),
                         % Continue the multi-line expression started above.
                         result(true)))) :-
    % State a fact for 'accessible' with the arguments listed below.
    accessible(W, actual),
    % State a fact for 'holds' with the arguments listed below.
    holds(P, W), !.

% State a fact for 'mentova modal' with the arguments listed below.
mentova_modal(possibly(P), false,
              % Continue the multi-line expression started above.
              just(modal(possibly(P), worlds_checked(all_accessible),
                         % Continue the multi-line expression started above.
                         result(false)))) :-
    % Succeed only if 'possibly(P, actual' cannot be proved (negation as failure).
    \+ possibly(P, actual).

% State a fact for 'mentova modal' with the arguments listed below.
mentova_modal(contingent(P), true,
              % Continue the multi-line expression started above.
              just(modal(contingent(P), reason(possible_not_necessary),
                         % Continue the multi-line expression started above.
                         result(true)))) :-
    % State a fact for 'contingent' with the arguments listed below.
    contingent(P, actual), !.

% State a fact for 'mentova modal' with the arguments listed below.
mentova_modal(contingent(P), false,
              % Continue the multi-line expression started above.
              just(modal(contingent(P), reason(necessary_or_impossible),
                         % Continue the multi-line expression started above.
                         result(false)))) :-
    % Succeed only if 'contingent(P, actual' cannot be proved (negation as failure).
    \+ contingent(P, actual).

% State a fact for 'mentova modal' with the arguments listed below.
mentova_modal(classify(P), Class,
              % Continue the multi-line expression started above.
              just(modal(classify(P), classification(Class)))) :-
    % Check that '( necessarily(P, actual) -> Class' is unifiable with 'necessary'.
    ( necessarily(P, actual) -> Class = necessary
    % Otherwise (else branch), perform the following action.
    ; contingent(P, actual)  -> Class = contingent
    % Otherwise (else branch), perform the following action.
    ; possibly(P, actual)    -> Class = possible
    % Otherwise (else branch), perform the following action.
    ;                           Class = impossible
    % Close the expression opened above.
    ).
