/*  Mentova — Fuzzy Reasoning Test Suite  (Rung 15)

    A genuine behavioural PLUnit suite for src/mentova/fuzzy.pl. The module is
    pure — it needs no mind id, no lattice, and no asserted facts — so each test
    calls the single exported predicate mentova_fuzzy/3 with known inputs and
    asserts the graded-truth Result and glass-box Justification computed by hand
    from the module's documented membership functions.

    Run with the full library path (every PrologAI pack plus the Mentova source):
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" test/test_fuzzy.pl
*/

%% Declare this file as a test module with no exports.
:- module(test_fuzzy, []).
%% Load the PLUnit test framework.
:- use_module(library(plunit)).
%% Load the fuzzy reasoning module under test from the library path.
:- use_module(library(fuzzy)).

%% Open the test block for the fuzzy module.
:- begin_tests(fuzzy).

%% AC-FUZZY-001: membership returns the graded degree of a linguistic label.
test(membership_returns_graded_degree) :-
    %% Ask for the 'warm' membership of 20 degrees Celsius.
    mentova_fuzzy(membership(temperature, 20, warm), Result, Justification),
    %% The warm curve peaks at 25 and falls 0.1 per degree, so 20 gives 0.5.
    assertion(Result == degree(warm, 0.5)),
    %% The justification names the membership fact that produced the degree.
    assertion(Justification == just(fuzzy_membership(temperature, 20, warm, 0.5))).

%% AC-FUZZY-002: a zero-degree membership is refused (the D > 0.0 guard).
test(zero_membership_is_refused) :-
    %% At 20 degrees the 'hot' curve is below zero and clamps to 0.0.
    assertion(\+ mentova_fuzzy(membership(temperature, 20, hot), _, _)).

%% AC-FUZZY-003: classify picks the single best label at a clean peak.
test(classify_picks_single_peak) :-
    %% Classify 25 degrees Celsius across all temperature labels (first solution).
    once(mentova_fuzzy(classify(temperature, 25), Result, _)),
    %% Only 'warm' has non-zero membership there, and it peaks at 1.0.
    assertion(Result == best(warm, 1.0, very_high)).

%% AC-FUZZY-004: classify breaks a tie by standard term order (last after msort).
test(classify_breaks_tie_by_order) :-
    %% At 20 degrees both 'cool' and 'warm' score 0.5 (take the first solution).
    once(mentova_fuzzy(classify(temperature, 20), Result, _)),
    %% msort then last selects 'warm' (cool @< warm), labelled 'somewhat'.
    assertion(Result == best(warm, 0.5, somewhat)).

%% AC-FUZZY-005: fuzzy AND is the minimum of two degrees.
test(fuzzy_and_is_minimum) :-
    %% Combine two degrees with fuzzy conjunction.
    mentova_fuzzy(fuzzy_and(0.75, 0.25), Result, Justification),
    %% The conjunction takes the smaller degree.
    assertion(Result == 0.25),
    %% The justification records the min operation.
    assertion(Justification == just(fuzzy_and(0.75, 0.25, min(0.25)))).

%% AC-FUZZY-006: fuzzy OR is the maximum of two degrees.
test(fuzzy_or_is_maximum) :-
    %% Combine two degrees with fuzzy disjunction.
    mentova_fuzzy(fuzzy_or(0.75, 0.25), Result, Justification),
    %% The disjunction takes the larger degree.
    assertion(Result == 0.75),
    %% The justification records the max operation.
    assertion(Justification == just(fuzzy_or(0.75, 0.25, max(0.75)))).

%% AC-FUZZY-007: fuzzy NOT is the complement one-minus-the-degree.
test(fuzzy_not_is_complement) :-
    %% Negate a single degree of truth.
    mentova_fuzzy(fuzzy_not(0.25), Result, Justification),
    %% The complement of 0.25 is 0.75.
    assertion(Result == 0.75),
    %% The justification records the complement operation.
    assertion(Justification == just(fuzzy_not(0.25, complement(0.75)))).

%% Close the test block for the fuzzy module.
:- end_tests(fuzzy).
