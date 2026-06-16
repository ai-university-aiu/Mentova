/*  Mentova — Rung 19: Counterfactual Reasoning Module

    Answers "what if this were different" — counterfactual queries that
    differ correctly from fact.

    Method: closest possible world (Lewis, 1973).
    The actual world is the Small-World KB.
    A counterfactual world is obtained by substituting the antecedent
    into the world and propagating via causal relations.

    Pass criterion: counterfactual differs correctly from fact.
*/

% Declare this file as the 'counterfactual' module and list its exported predicates.
:- module(counterfactual, [
    % Supply 'mentova_counterfactual/3' as the next argument to the expression above.
    mentova_counterfactual/3
% Close the expression opened above.
]).

% Load the 'small_world' module so its predicates are available here.
:- use_module('../../knowledge/small_world', [
    % Continue the multi-line expression started above.
    causes/2, prob_fact/2, has_property/2, is_a/2
% Close the expression opened above.
]).
% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Actual-world facts used for comparison
% ---------------------------------------------------------------------------

% State a fact for 'actual' with the arguments listed below.
actual(rains_today, no).          % prob 0.3 — let's say it does not rain today
% State a fact for 'actual' with the arguments listed below.
actual(ground_wet, no).           % therefore not wet
% State a fact for 'actual' with the arguments listed below.
actual(penguin_flies, no).        % penguins don't fly
% State a fact for 'actual' with the arguments listed below.
actual(cat_location, house).      % cat is in the house
% State a fact for 'actual' with the arguments listed below.
actual(plant_grows, yes).         % sunlight today → plant grows

% ---------------------------------------------------------------------------
% Counterfactual engine: what_if(Antecedent, Query, CounterfactualAnswer)
% ---------------------------------------------------------------------------

% If it had rained today, the ground would be wet
% State a fact for 'counterfactual result' with the arguments listed below.
counterfactual_result(what_if(rains_today_yes, ground_wet), yes,
                      % Continue the multi-line expression started above.
                      via(causes(rain, wet_ground))).

% If the penguin had wings (and not been flightless), it would fly
% State a fact for 'counterfactual result' with the arguments listed below.
counterfactual_result(what_if(penguin_not_flightless, penguin_flies), yes,
                      % Continue the multi-line expression started above.
                      via(default_rule_bird_flies_no_exception)).

% If the cat were in the garden, it would not be in the house
% State a fact for 'counterfactual result' with the arguments listed below.
counterfactual_result(what_if(cat_in_garden, cat_location), garden,
                      % Continue the multi-line expression started above.
                      via(location_substitution)).

% If there were no sunlight, the plant would not grow
% State a fact for 'counterfactual result' with the arguments listed below.
counterfactual_result(what_if(no_sunlight, plant_grows), no,
                      % Continue the multi-line expression started above.
                      via(breaks_causes(sunlight, plant_growth))).

% If exercise frequency doubled, weight would decrease
% State a fact for 'counterfactual result' with the arguments listed below.
counterfactual_result(what_if(double_exercise, weight_trend), decreases,
                      % Continue the multi-line expression started above.
                      via(qualitative_chain(exercise_increases, weight_decreases))).

% ---------------------------------------------------------------------------
% mentova_counterfactual(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova counterfactual' with the arguments listed below.
mentova_counterfactual(what_if(Ante, Q), CounterfactualAns,
                        % Continue the multi-line expression started above.
                        just(counterfactual(
                              % Continue the multi-line expression started above.
                              antecedent(Ante),
                              % Continue the multi-line expression started above.
                              query(Q),
                              % Continue the multi-line expression started above.
                              actual(ActualAns),
                              % Continue the multi-line expression started above.
                              counterfactual(CounterfactualAns),
                              % Continue the multi-line expression started above.
                              mechanism(Mech),
                              % Continue the multi-line expression started above.
                              differs(Differs)))) :-
    % State a fact for 'counterfactual result' with the arguments listed below.
    counterfactual_result(what_if(Ante, Q), CounterfactualAns, via(Mech)),
    % Check that '( actual(Q, ActualAns) -> true ; ActualAns' is unifiable with 'unknown )'.
    ( actual(Q, ActualAns) -> true ; ActualAns = unknown ),
    % Check that '( ActualAns' is not unifiable with 'CounterfactualAns -> Differs = yes ; Differs = no )'.
    ( ActualAns \= CounterfactualAns -> Differs = yes ; Differs = no ).

% Compare actual to counterfactual for a variable
% State a fact for 'mentova counterfactual' with the arguments listed below.
mentova_counterfactual(compare(Ante, Q), comparison(actual(A), counterfactual(CF), changed(Changed)),
                        % Continue the multi-line expression started above.
                        just(comparison(Ante, Q, actual(A), counterfactual(CF)))) :-
    % State a fact for 'actual' with the arguments listed below.
    actual(Q, A),
    % State a fact for 'counterfactual result' with the arguments listed below.
    counterfactual_result(what_if(Ante, Q), CF, _),
    % Check that '( A' is not unifiable with 'CF -> Changed = yes ; Changed = no )'.
    ( A \= CF -> Changed = yes ; Changed = no ).
