/*  Mentova — Counterfactual Reasoning Test Suite  (Rung 19)

    Behavioural PLUnit suite for src/mentova/counterfactual.pl, which answers
    "what if this were different" by the closest-possible-world method
    (Lewis, 1973): substitute the antecedent and propagate via causal
    relations, then compare the counterfactual answer to the actual world.

    The module exports one predicate, mentova_counterfactual/3, which serves
    two query shapes — what_if(Antecedent, Query) yielding an answer plus a
    glass-box justification, and compare(Antecedent, Query) yielding an
    actual/counterfactual/changed triple. Both shapes are exercised here on
    the module's five documented worked examples.

    Run with the full library path:
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" test/test_counterfactual.pl
*/

% Declare this file as a test module with no exports.
:- module(test_counterfactual, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the counterfactual module under test from the library path.
:- use_module(library(counterfactual)).

% Open the test block for the counterfactual module.
:- begin_tests(counterfactual).

% AC-CF-001: had it rained, the ground would be wet, differing from the dry actual world.
test(what_if_rain_makes_ground_wet) :-
    % Ask what the ground would be if it had rained today.
    mentova_counterfactual(what_if(rains_today_yes, ground_wet), Answer, Justification),
    % The counterfactual answer is that the ground is wet.
    assertion(Answer == yes),
    % The justification records the dry actual world, the wet counterfactual, the rain mechanism, and that they differ.
    assertion(Justification == just(counterfactual(
                                     % Name the rain antecedent that was substituted.
                                     antecedent(rains_today_yes),
                                     % Name the query this counterfactual answers.
                                     query(ground_wet),
                                     % Record the actual world's dry ground value.
                                     actual(no),
                                     % Record the counterfactual world's wet ground value.
                                     counterfactual(yes),
                                     % Name the causal mechanism connecting rain to wet ground.
                                     mechanism(causes(rain, wet_ground)),
                                     % Confirm the counterfactual value differs from the actual value.
                                     differs(yes)))).

% AC-CF-002: had the cat been in the garden, its location would be garden, not the actual house.
test(what_if_cat_moves_to_garden) :-
    % Ask where the cat would be if it were in the garden.
    mentova_counterfactual(what_if(cat_in_garden, cat_location), Answer, Justification),
    % The counterfactual location is the garden.
    assertion(Answer == garden),
    % The justification carries the actual house, the counterfactual garden, the substitution mechanism, and a difference.
    assertion(Justification == just(counterfactual(
                                     % Name the antecedent that places the cat in the garden.
                                     antecedent(cat_in_garden),
                                     % Name the query this counterfactual answers.
                                     query(cat_location),
                                     % Record the actual world's house location.
                                     actual(house),
                                     % Record the counterfactual world's garden location.
                                     counterfactual(garden),
                                     % Name the location-substitution mechanism.
                                     mechanism(location_substitution),
                                     % Confirm the counterfactual location differs from the actual location.
                                     differs(yes)))).

% AC-CF-003: a query with no actual-world fact reports the actual value as unknown yet still differs.
test(what_if_unknown_actual_when_no_fact) :-
    % Ask the weight trend if exercise were doubled, a query the actual world does not record.
    mentova_counterfactual(what_if(double_exercise, weight_trend), Answer, Justification),
    % The counterfactual trend is decreasing.
    assertion(Answer == decreases),
    % With no matching actual fact the actual slot is unknown, and unknown differs from decreases.
    assertion(Justification == just(counterfactual(
                                     % Name the doubled-exercise antecedent.
                                     antecedent(double_exercise),
                                     % Name the query this counterfactual answers.
                                     query(weight_trend),
                                     % Record that the actual world has no matching fact for this query.
                                     actual(unknown),
                                     % Record the counterfactual world's decreasing weight trend.
                                     counterfactual(decreases),
                                     % Name the qualitative causal chain from more exercise to less weight.
                                     mechanism(qualitative_chain(exercise_increases, weight_decreases)),
                                     % Confirm the counterfactual value differs from the unknown actual value.
                                     differs(yes)))).

% AC-CF-004: removing the cause breaks the effect — no sunlight means the plant would not grow.
test(what_if_no_sunlight_stops_plant) :-
    % Ask whether the plant would grow with no sunlight.
    mentova_counterfactual(what_if(no_sunlight, plant_grows), Answer, Justification),
    % The counterfactual answer is that it does not grow.
    assertion(Answer == no),
    % The justification names the cause-breaking mechanism and that the answer flips from the growing actual world.
    assertion(Justification == just(counterfactual(
                                     % Name the no-sunlight antecedent.
                                     antecedent(no_sunlight),
                                     % Name the query this counterfactual answers.
                                     query(plant_grows),
                                     % Record the actual world's growing plant.
                                     actual(yes),
                                     % Record the counterfactual world's non-growing plant.
                                     counterfactual(no),
                                     % Name the cause-breaking mechanism between sunlight and plant growth.
                                     mechanism(breaks_causes(sunlight, plant_growth)),
                                     % Confirm the counterfactual value differs from the actual value.
                                     differs(yes)))).

% AC-CF-005: the compare shape reports actual, counterfactual, and that the value changed.
test(compare_reports_actual_and_change) :-
    % Compare the actual and counterfactual ground state for the rain antecedent.
    mentova_counterfactual(compare(rains_today_yes, ground_wet), Result, Justification),
    % The comparison pairs the dry actual world with the wet counterfactual and flags the change.
    assertion(Result == comparison(actual(no), counterfactual(yes), changed(yes))),
    % The justification echoes the antecedent, query, and both values.
    assertion(Justification == just(comparison(rains_today_yes, ground_wet, actual(no), counterfactual(yes)))).

% AC-CF-006: the compare shape also handles the cat's relocation from house to garden.
test(compare_cat_relocation) :-
    % Compare the actual and counterfactual cat location for the garden antecedent.
    mentova_counterfactual(compare(cat_in_garden, cat_location), Result, _),
    % The actual house becomes the counterfactual garden, a change.
    assertion(Result == comparison(actual(house), counterfactual(garden), changed(yes))).

% AC-CF-007: compare requires an actual-world fact, so it fails for a query the world never records.
test(compare_needs_actual_fact, [fail]) :-
    % Comparing a query with no actual/2 fact has no solution and must fail.
    mentova_counterfactual(compare(double_exercise, weight_trend), _, _).

% Close the test block for the counterfactual module.
:- end_tests(counterfactual).
