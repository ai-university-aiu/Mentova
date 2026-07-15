/*  Mentova — Attention Schema Test Suite  (src/mentova/attention_schema.pl)

    Behavioural PLUnit coverage for the mentova_attention_schema module — the
    workspace-side attention schema (Specification PR 42). Three of the four
    exported predicates are exercised with real assertions on their outputs:

      schema_boot/0          — the subscriber boots deterministically.
      schema_score_recent/1  — logged predictions are scored against logged
                               actuals; accuracy and the 1/distinct-winners
                               chance baseline are checked by hand-computed
                               values across empty, perfect, half, and miss
                               cases.
      schema_report/1        — the glass-box report term is assembled from the
                               recorded winners, habituation, predictions,
                               status, and the embedded recent score.

    The scoring predicate returns accuracy as an integer when a division is
    exact (2/2 -> 1, 0/2 -> 0), so every numeric check uses arithmetic (=:=)
    rather than unification.

    Run with the full PrologAI library path plus the Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_attention_schema.pl
*/

% Declare this file as a test module with no exports.
:- module(test_attention_schema, []).
% Load the PLUnit testing framework.
:- use_module(library(plunit)).
% Load list helpers for member/2 used by the setup helper.
:- use_module(library(lists)).
% Load the Mentova attention schema module under test.
:- use_module(library(attention_schema)).

% Replace the module's logged predictions and actuals with a known set for scoring.
set_schema_logs(Preds, Acts) :-
    % Clear any previously logged predictions from the module's private log.
    retractall(mentova_attention_schema:schema_predictions_log(_, _)),
    % Clear any previously logged actuals from the module's private log.
    retractall(mentova_attention_schema:schema_actuals(_, _)),
    % Assert each Cycle-Winner pair as a logged prediction.
    forall(member(Cycle-Winner, Preds),
           assertz(mentova_attention_schema:schema_predictions_log(Cycle, Winner))),
    % Assert each Cycle-Winner pair as a logged actual.
    forall(member(Cycle-Winner, Acts),
           assertz(mentova_attention_schema:schema_actuals(Cycle, Winner))).

% Clear the attention_schema namespace that schema_report reads its winners, habituation, and predictions from.
reset_report_facts :-
    % Remove any recorded winner facts.
    retractall(attention_schema:schema_winner(_, _, _)),
    % Remove any recorded habituation facts.
    retractall(attention_schema:schema_habituation(_, _)),
    % Remove any recorded prediction facts.
    retractall(attention_schema:schema_prediction(_, _)),
    % Remove the enabled flag so the status defaults to disabled.
    retractall(attention_schema:schema_enabled).

% Open the attention_schema test block.
:- begin_tests(attention_schema).

% Booting the attention schema subscriber succeeds deterministically.
test(schema_boot_succeeds) :-
    % Call schema_boot once, capturing its banner so test output stays clean.
    with_output_to(string(_), once(schema_boot)).

% Booting twice is safe: the second call still succeeds without error.
test(schema_boot_repeatable) :-
    % Boot once, capturing the banner.
    with_output_to(string(_), once(schema_boot)),
    % Boot again, capturing the banner, and require success.
    with_output_to(string(_), once(schema_boot)).

% With no predictions or actuals logged, the recent score is zero accuracy and zero chance.
test(score_empty_is_zero) :-
    % Start from an empty prediction and actuals log.
    set_schema_logs([], []),
    % Score the (empty) recent history.
    schema_score_recent(score(Accuracy, Chance)),
    % An empty history yields zero accuracy.
    assertion(Accuracy =:= 0.0),
    % An empty history yields a zero chance baseline.
    assertion(Chance =:= 0.0).

% Two predictions that both match their actuals over two distinct winners score full accuracy against a one-in-two chance baseline.
test(score_perfect_two_winners) :-
    % Log two predictions that both match the actual winners.
    set_schema_logs([5-objective, 6-emotion], [5-objective, 6-emotion]),
    % Score the recent history.
    schema_score_recent(score(Accuracy, Chance)),
    % Both of two predictions hit, so accuracy is one.
    assertion(Accuracy =:= 1.0),
    % Two distinct winners were seen, so the chance baseline is one half.
    assertion(Chance =:= 0.5).

% One of two predictions matches, so accuracy is one half against the same one-in-two chance baseline.
test(score_half_hit) :-
    % Log two predictions where only the first matches its actual.
    set_schema_logs([5-objective, 6-emotion], [5-objective, 6-cognition]),
    % Score the recent history.
    schema_score_recent(score(Accuracy, Chance)),
    % One of two predictions hit, so accuracy is one half.
    assertion(Accuracy =:= 0.5),
    % Two distinct winners were seen, so the chance baseline is one half.
    assertion(Chance =:= 0.5).

% No prediction matches and four distinct winners were seen, so accuracy is zero against a one-in-four chance baseline.
test(score_no_hits_four_winners) :-
    % Log two predictions that match none of four distinct actual winners.
    set_schema_logs([1-guess, 2-guess], [1-objective, 2-emotion, 3-is_a, 4-capable_of]),
    % Score the recent history.
    schema_score_recent(score(Accuracy, Chance)),
    % No prediction hit, so accuracy is zero.
    assertion(Accuracy =:= 0.0),
    % Four distinct winners were seen, so the chance baseline is one quarter.
    assertion(Chance =:= 0.25).

% schema_report assembles a glass-box report term from the recorded winners, habituation, predictions, status, and embedded score.
test(report_assembles_enabled) :-
    % Clear the report namespace before populating it.
    reset_report_facts,
    % Mark the schema enabled so the report status reads enabled.
    assertz(attention_schema:schema_enabled),
    % Record the first winner (cycle one, objective, salience 0.7).
    assertz(attention_schema:schema_winner(1, objective, 0.7)),
    % Record the second winner (cycle two, emotion, salience 0.5).
    assertz(attention_schema:schema_winner(2, emotion, 0.5)),
    % Record one habituation entry for the objective relation.
    assertz(attention_schema:schema_habituation(objective, 0.3)),
    % Record one prediction for cycle three.
    assertz(attention_schema:schema_prediction(3, objective)),
    % Log a perfect two-of-two prediction history so the embedded score is known.
    set_schema_logs([5-objective, 6-emotion], [5-objective, 6-emotion]),
    % Assemble the report.
    schema_report(Report),
    % Destructure the assembled report term.
    Report = attention_schema_report(
        cycles_seen(Cycles),
        schema_status(Status),
        recent_winners(Winners),
        habituation_state(Habituation),
        predictions(Predictions),
        prediction_score(score(Accuracy, Chance))),
    % The cycles-seen field is an integer count.
    assertion(integer(Cycles)),
    % The status reflects the enabled flag.
    assertion(Status == enabled),
    % The winners list preserves the two recorded winners in order.
    assertion(Winners == [winner(1, objective, 0.7), winner(2, emotion, 0.5)]),
    % The habituation list holds the single recorded entry.
    assertion(Habituation == [habituation(objective, 0.3)]),
    % The predictions list holds the single recorded prediction.
    assertion(Predictions == [prediction(3, objective)]),
    % The embedded accuracy is one (both logged predictions hit).
    assertion(Accuracy =:= 1.0),
    % The embedded chance baseline is one half (two distinct winners).
    assertion(Chance =:= 0.5).

% When the schema is disabled, the report status reads disabled while the recorded winner is still reported.
test(report_status_disabled) :-
    % Clear the report namespace, leaving the enabled flag unset.
    reset_report_facts,
    % Record a single winner without marking the schema enabled.
    assertz(attention_schema:schema_winner(1, objective, 0.7)),
    % Use an empty score history so the embedded score is zero.
    set_schema_logs([], []),
    % Assemble the report.
    schema_report(Report),
    % Destructure the fields the disabled case checks.
    Report = attention_schema_report(
        _,
        schema_status(Status),
        recent_winners(Winners),
        _,
        _,
        prediction_score(score(Accuracy, Chance))),
    % With no enabled flag the status is disabled.
    assertion(Status == disabled),
    % The recorded winner is still reported.
    assertion(Winners == [winner(1, objective, 0.7)]),
    % The empty history scores zero accuracy.
    assertion(Accuracy =:= 0.0),
    % The empty history scores a zero chance baseline.
    assertion(Chance =:= 0.0).

% Close the attention_schema test block.
:- end_tests(attention_schema).
