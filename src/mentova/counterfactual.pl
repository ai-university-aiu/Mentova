/*  Mentova — Rung 19: Counterfactual Reasoning Module

    Answers "what if this were different" — counterfactual queries that
    differ correctly from fact.

    Method: closest possible world (Lewis, 1973).
    The actual world is the Small-World KB.
    A counterfactual world is obtained by substituting the antecedent
    into the world and propagating via causal relations.

    Pass criterion: counterfactual differs correctly from fact.
*/

:- module(counterfactual, [
    mentova_counterfactual/3
]).

:- use_module('../../knowledge/small_world', [
    causes/2, prob_fact/2, has_property/2, is_a/2
]).
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Actual-world facts used for comparison
% ---------------------------------------------------------------------------

actual(rains_today, no).          % prob 0.3 — let's say it does not rain today
actual(ground_wet, no).           % therefore not wet
actual(penguin_flies, no).        % penguins don't fly
actual(cat_location, house).      % cat is in the house
actual(plant_grows, yes).         % sunlight today → plant grows

% ---------------------------------------------------------------------------
% Counterfactual engine: what_if(Antecedent, Query, CounterfactualAnswer)
% ---------------------------------------------------------------------------

% If it had rained today, the ground would be wet
counterfactual_result(what_if(rains_today_yes, ground_wet), yes,
                      via(causes(rain, wet_ground))).

% If the penguin had wings (and not been flightless), it would fly
counterfactual_result(what_if(penguin_not_flightless, penguin_flies), yes,
                      via(default_rule_bird_flies_no_exception)).

% If the cat were in the garden, it would not be in the house
counterfactual_result(what_if(cat_in_garden, cat_location), garden,
                      via(location_substitution)).

% If there were no sunlight, the plant would not grow
counterfactual_result(what_if(no_sunlight, plant_grows), no,
                      via(breaks_causes(sunlight, plant_growth))).

% If exercise frequency doubled, weight would decrease
counterfactual_result(what_if(double_exercise, weight_trend), decreases,
                      via(qualitative_chain(exercise_increases, weight_decreases))).

% ---------------------------------------------------------------------------
% mentova_counterfactual(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_counterfactual(what_if(Ante, Q), CounterfactualAns,
                        just(counterfactual(
                              antecedent(Ante),
                              query(Q),
                              actual(ActualAns),
                              counterfactual(CounterfactualAns),
                              mechanism(Mech),
                              differs(Differs)))) :-
    counterfactual_result(what_if(Ante, Q), CounterfactualAns, via(Mech)),
    ( actual(Q, ActualAns) -> true ; ActualAns = unknown ),
    ( ActualAns \= CounterfactualAns -> Differs = yes ; Differs = no ).

% Compare actual to counterfactual for a variable
mentova_counterfactual(compare(Ante, Q), comparison(actual(A), counterfactual(CF), changed(Changed)),
                        just(comparison(Ante, Q, actual(A), counterfactual(CF)))) :-
    actual(Q, A),
    counterfactual_result(what_if(Ante, Q), CF, _),
    ( A \= CF -> Changed = yes ; Changed = no ).
