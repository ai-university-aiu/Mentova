/*  Mentova — Rung 33: Modal Reasoning Module

    Evaluates modal claims: necessarily true, possibly true, contingent.
    Uses Kripke-style possible-world accessibility relations.
    Pass criterion: a necessarily-true claim is distinguished from a
    merely-possible claim with justification naming the accessible worlds.
*/

:- module(modal, [
    mentova_modal/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Worlds and accessibility: accessible(World, From)
% ---------------------------------------------------------------------------

world(actual).
world(w1).
world(w2).
world(w3).

% Each world is accessible from actual (reflexive, transitive system S5-like)
accessible(actual, actual).
accessible(w1,     actual).
accessible(w2,     actual).
accessible(w3,     actual).
accessible(w2,     w1).
accessible(w3,     w2).

% ---------------------------------------------------------------------------
% Facts true in each world: holds(Fact, World)
% ---------------------------------------------------------------------------

holds(birds_fly,          actual).
holds(birds_fly,          w1).
holds(birds_fly,          w2).
holds(birds_fly,          w3).

holds(tweety_flies,       w1).
holds(tweety_flies,       w2).
% tweety_flies is NOT true in actual (tweety is flightless) or w3

holds(fire_is_hot,        actual).
holds(fire_is_hot,        w1).
holds(fire_is_hot,        w2).
holds(fire_is_hot,        w3).

holds(water_is_wet,       actual).
holds(water_is_wet,       w1).
holds(water_is_wet,       w2).
holds(water_is_wet,       w3).

holds(canary_is_yellow,   actual).
holds(canary_is_yellow,   w1).
holds(canary_is_yellow,   w2).
holds(canary_is_yellow,   w3).

holds(it_rains,           w1).
holds(it_rains,           w3).
% not in actual or w2

% ---------------------------------------------------------------------------
% Modal operators
% ---------------------------------------------------------------------------

% Necessarily P: P holds in all accessible worlds from W
necessarily(P, World) :-
    forall(accessible(W2, World), holds(P, W2)).

% Possibly P: P holds in at least one accessible world from W
possibly(P, World) :-
    accessible(W2, World),
    holds(P, W2).

% Contingent P: possibly true but not necessarily true
contingent(P, World) :-
    possibly(P, World),
    \+ necessarily(P, World).

% ---------------------------------------------------------------------------
% mentova_modal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_modal(necessarily(P), true,
              just(modal(necessarily(P), worlds_checked(all_accessible),
                         result(true)))) :-
    necessarily(P, actual), !.

mentova_modal(necessarily(P), false,
              just(modal(necessarily(P), worlds_checked(all_accessible),
                         result(false)))) :-
    \+ necessarily(P, actual).

mentova_modal(possibly(P), true,
              just(modal(possibly(P), witness_world(W),
                         result(true)))) :-
    accessible(W, actual),
    holds(P, W), !.

mentova_modal(possibly(P), false,
              just(modal(possibly(P), worlds_checked(all_accessible),
                         result(false)))) :-
    \+ possibly(P, actual).

mentova_modal(contingent(P), true,
              just(modal(contingent(P), reason(possible_not_necessary),
                         result(true)))) :-
    contingent(P, actual), !.

mentova_modal(contingent(P), false,
              just(modal(contingent(P), reason(necessary_or_impossible),
                         result(false)))) :-
    \+ contingent(P, actual).

mentova_modal(classify(P), Class,
              just(modal(classify(P), classification(Class)))) :-
    ( necessarily(P, actual) -> Class = necessary
    ; contingent(P, actual)  -> Class = contingent
    ; possibly(P, actual)    -> Class = possible
    ;                           Class = impossible
    ).
