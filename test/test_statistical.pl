/*  Mentova — Statistical Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/statistical.pl, which exports
    mentova_stat/3 — pattern-finding over the observation(Subject, Property,
    Count) table in knowledge/small_world.pl. The single exported predicate
    answers five documented query forms, each returning a result term and a
    glass-box justification:
        proportion(Subject, Property) — fraction of observations with Property
        dominant(Subject)             — most frequently observed property
        most_common(Subject)          — dominant property with a percentage
        trend(Subject, PropA, PropB)  — which of two properties is more prevalent
        compare(S1, S2, Property)     — which subject shows the higher rate

    All expectations are computed by hand from the static observation facts
    (canary: yellow 47, green 3; rose: red 82, white 18; penguin: swims 95,
    flies 0), which the module auto-loads via its own relative use_module, so
    the suite needs no lattice, mind id, or asserted state.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_statistical.pl
*/

% Declare this file as a test module with no exports.
:- module(test_statistical, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(statistical)).

% Open the test block for the statistical module.
:- begin_tests(statistical).

% AC-STAT-001: proportion is Count/Total — canary shows yellow in 47 of 50 observations.
test(proportion_canary_yellow) :-
    % Ask for the fraction of canary observations that report yellow.
    mentova_stat(proportion(canary, yellow), Proportion, _Justification),
    % Hand computation: 47 yellow out of (47 + 3) = 50 total = 0.94.
    assertion(Proportion =:= 47/50).

% AC-STAT-002: a property with zero observations yields a proportion of zero.
test(proportion_penguin_flies_is_zero) :-
    % Ask for the fraction of penguin observations that report flying.
    mentova_stat(proportion(penguin, flies), Proportion, _Justification),
    % The flies count is 0 out of (95 + 0) = 95, so the proportion is exactly 0.
    assertion(Proportion =:= 0).

% AC-STAT-003: the proportion justification names the count, the total, and the fraction.
test(proportion_justification_reports_its_inputs) :-
    % Ask for the fraction of rose observations that report red.
    mentova_stat(proportion(rose, red), Proportion, Justification),
    % The justification is the documented five-slot proportion term.
    Justification = just(proportion(rose, red, Count, Total, Reported)),
    % The named count is the red observation count of 82.
    assertion(Count =:= 82),
    % The named total is the sum of red and white, 82 + 18 = 100.
    assertion(Total =:= 100),
    % The fraction carried in the justification equals the returned proportion.
    assertion(Reported =:= Proportion).

% AC-STAT-004: dominant reports the single most-observed property with its count.
test(dominant_rose_is_red) :-
    % Ask which property dominates the rose observations.
    mentova_stat(dominant(rose), Result, _Justification),
    % Red (82) outnumbers white (18), so red is the dominant property.
    assertion(Result == dominant(rose, red, 82)).

% AC-STAT-005: most_common rounds the dominant property's share to a whole percentage.
test(most_common_canary_is_yellow_94_percent) :-
    % Ask for the canary's dominant property together with its percentage.
    mentova_stat(most_common(canary), Result, _Justification),
    % Yellow is 47 of 50 = round(47*100/50) = 94 percent.
    assertion(Result == most_common(canary, yellow, 94)).

% AC-STAT-006: trend picks the more prevalent of two named properties.
test(trend_penguin_favours_swims) :-
    % Compare the penguin's flies (0) and swims (95) observation counts.
    mentova_stat(trend(penguin, flies, swims), Result, _Justification),
    % Swims (95) exceeds flies (0), so the trend leans toward swims.
    assertion(Result == trend(penguin, flies, swims, more(swims))).

% AC-STAT-007: two properties with no observations tie, so the trend is equal.
test(trend_equal_when_both_absent) :-
    % Compare two properties the canary has never been observed with.
    mentova_stat(trend(canary, blue, purple), Result, _Justification),
    % Both counts default to 0, so neither leads and the direction is equal.
    assertion(Result == trend(canary, blue, purple, equal)).

% AC-STAT-008: compare picks the subject with the higher per-total rate for a property.
test(compare_canary_beats_penguin_on_yellow) :-
    % Compare canary and penguin on their rate of the yellow property.
    mentova_stat(compare(canary, penguin, yellow), Result, _Justification),
    % Destructure the documented five-slot compare result term.
    Result = compare(canary, Rate1, penguin, Rate2, Winner),
    % Canary's yellow rate is 47 of 50 = 0.94.
    assertion(Rate1 =:= 47/50),
    % Penguin never shows yellow, so its rate is 0 of 95 = 0.
    assertion(Rate2 =:= 0),
    % The higher rate belongs to the canary, so it is named the winner.
    assertion(Winner == canary).

% Close the test block for the statistical module.
:- end_tests(statistical).
