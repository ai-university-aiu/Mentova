/*  Mentova — Non-Monotonic (Defeasible) Reasoning Test Suite

    Behavioural PLUnit suite for the 'nonmonotonic' module
    (src/mentova/nonmonotonic.pl, Rung 17). Exercises the single
    exported predicate mentova_defeasible/3 across its four dispatch
    forms — conclusion via query/1, conclusion via a bare proposition,
    exception listing, and the exception check — with expected values
    computed by hand from the small_world knowledge base
    (knowledge/small_world.pl):

      default_rule(flies(X),   is_a(X, bird)).
      exception_rule(flies(X), has_property(X, flightless), penguin_exception).
      exception_rule(flies(X), is_a(X, fish),               fish_dont_fly).

      is_a(canary, bird).    is_a(penguin, bird).    is_a(salmon, fish).
      has_property(penguin, flightless).

    So a canary flies (default holds, no exception), a penguin does not
    (default withdrawn by the flightless exception), and a salmon never
    triggers the bird default at all (condition not met).

    Run with the full library path over every PrologAI pack plus the
    Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_nonmonotonic.pl
*/

% Declare this file as a test module with no exports.
:- module(test_nonmonotonic, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(nonmonotonic)).

% Open the test block for nonmonotonic.
:- begin_tests(nonmonotonic).

% AC-NM-001: a canary satisfies the bird default with no exception, so flight holds.
test(canary_flies_default_holds) :-
    % Ask whether a canary flies, wrapped in the query/1 form, taking the first (deterministic) solution.
    once(mentova_defeasible(query(flies(canary)), Result, Just)),
    % The default rule fires and no exception withdraws it.
    assertion(Result == holds(default)),
    % The justification names the bird default, the absence of any exception, and the flies conclusion.
    assertion(Just == just(defeasible(flies(canary), default(bird_flies), no_exception_found, conclusion(flies)))).

% AC-NM-002: a penguin is a flightless bird, so the flight default is withdrawn by the named exception.
test(penguin_flight_withdrawn_by_exception) :-
    % Ask whether a penguin flies, taking the first (deterministic) solution.
    once(mentova_defeasible(query(flies(penguin)), Result, Just)),
    % The bird default is overridden by the flightless exception, named penguin_exception.
    assertion(Result == withdrawn(exception(penguin_exception))),
    % The justification records the exception and the does-not-fly conclusion.
    assertion(Just == just(defeasible(flies(penguin), default(bird_flies), exception(penguin_exception), conclusion(does_not_fly)))).

% AC-NM-003: a salmon is not a bird, so the flight default never applies at all.
test(salmon_flight_not_applicable) :-
    % Ask whether a salmon flies, taking the first (deterministic) solution.
    once(mentova_defeasible(query(flies(salmon)), Result, Just)),
    % The bird default's condition is not met, so the conclusion is not_applicable.
    assertion(Result == not_applicable),
    % The justification records that the default's condition was not met.
    assertion(Just == just(defeasible(flies(salmon), default(bird_flies), condition_not_met))).

% AC-NM-004: the bare-proposition form (no query/1 wrapper) reaches the same conclusion.
test(bare_proposition_form_matches_query_form) :-
    % Ask about a canary flying without the query/1 wrapper, taking the first (deterministic) solution.
    once(mentova_defeasible(flies(canary), Result, _Just)),
    % The bare form dispatches to the same defeasible conclusion, so the default holds.
    assertion(Result == holds(default)).

% AC-NM-005: listing the exceptions for flies/1 returns both authored exception rules.
test(exceptions_listing_returns_both_rules) :-
    % Request every exception rule that can withdraw a flies/1 conclusion.
    mentova_defeasible(exceptions(flies(_)), Result, _Just),
    % Unwrap the returned exception list.
    Result = exceptions(List),
    % There are exactly two authored exception rules for flight.
    assertion(length(List, 2)),
    % The flightless exception is present.
    assertion(memberchk(exc(penguin_exception, _), List)),
    % The fish exception is present.
    assertion(memberchk(exc(fish_dont_fly, _), List)).

% AC-NM-006: the exception check confirms a penguin is an exception to flight, naming it.
test(is_exception_yes_for_penguin) :-
    % Ask whether a penguin is an exception to the flies/1 default.
    mentova_defeasible(is_exception(flies(penguin), penguin), Answer, _Just),
    % The flightless exception applies, so the answer names it.
    assertion(Answer == yes_exception(penguin_exception)).

% AC-NM-007: the exception check reports no exception for an ordinary flying bird.
test(is_exception_no_for_canary) :-
    % Ask whether a canary is an exception to the flies/1 default.
    mentova_defeasible(is_exception(flies(canary), canary), Answer, _Just),
    % No exception rule matches a canary, so the answer is no_exception.
    assertion(Answer == no_exception).

% Close the test block for nonmonotonic.
:- end_tests(nonmonotonic).
