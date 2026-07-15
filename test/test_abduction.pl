/*  Mentova — Abductive Reasoning Test Suite  (abduction module)

    Exercises mentova_abduce/4, inference to the best explanation, against
    the curated small_world knowledge base the module loads. Every expected
    value below is computed by hand from the module's documented scoring:
    Score is Prior * Likelihood, where Prior is prob_fact(H, P) or the 0.5
    default, and Likelihood is 1.0 when no observation-table row matches.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_abduction.pl
*/

% Declare this file as a test module with no exports.
:- module(test_abduction, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(abduction)).

% Open the test block for the abduction module.
:- begin_tests(abduction).

% AC-ABD-001: with competing causes, the higher-prior hypothesis wins.
test(competing_causes_higher_prior_wins) :-
    % Abduce the best explanation for a wet ground.
    mentova_abduce(wet_ground, Best, Score, _),
    % The winner is the sprinkler, whose prior 0.6 beats rain's 0.3.
    assertion(Best = explanation(sprinkler, _, _)),
    % Its score equals that prior times a unit likelihood.
    assertion(Score =:= 0.6).

% AC-ABD-002: the best explanation's embedded score equals the returned score.
test(best_carries_its_own_score) :-
    % Abduce the best explanation for a wet ground.
    mentova_abduce(wet_ground, Best, Score, _),
    % Read the score carried inside the explanation term.
    Best = explanation(_, InnerScore, _),
    % The two scores are the same number.
    assertion(InnerScore =:= Score).

% AC-ABD-003: all explanations are returned, sorted ascending by score.
test(all_explanations_sorted_ascending) :-
    % Abduce over both causes of a wet ground.
    mentova_abduce(wet_ground, _, _, AllExplns),
    % Both candidate causes are explained, binding each score for the checks below.
    AllExplns = [explanation(rain, RainScore, _),
                 explanation(sprinkler, SprinklerScore, _)],
    % Rain's score reflects its 0.3 prior.
    assertion(RainScore =:= 0.3),
    % The sprinkler's score reflects its 0.6 prior.
    assertion(SprinklerScore =:= 0.6),
    % The list is in non-decreasing score order.
    assertion(RainScore =< SprinklerScore).

% AC-ABD-004: an unknown-prior hypothesis falls back to the 0.5 default.
test(unknown_prior_defaults_to_half) :-
    % Abduce the best explanation for smoke.
    mentova_abduce(smoke, Best, Score, AllExplns),
    % Fire is the only cause of smoke.
    assertion(Best = explanation(fire, _, _)),
    % Fire has no prob_fact, so its score is the 0.5 default times unit likelihood.
    assertion(Score =:= 0.5),
    % The full list holds exactly that single explanation.
    assertion(AllExplns = [explanation(fire, _, _)]).

% AC-ABD-005: the evidence record names the causal link, prior, likelihood, and note.
test(evidence_record_is_transparent) :-
    % Abduce the best explanation for smoke.
    mentova_abduce(smoke, Best, _, _),
    % Unpack the evidence carried by the explanation, binding its parts for the checks below.
    Best = explanation(fire, _, Evidence),
    % With no observation-table row, the note is no_direct_observation and likelihood is unit.
    Evidence = evidence(cause(fire, smoke), prior(Prior),
                        likelihood(Likelihood), note(no_direct_observation)),
    % The recorded prior is the 0.5 default for a hypothesis with no prob_fact.
    assertion(Prior =:= 0.5),
    % The recorded likelihood is unit when no observation row matches.
    assertion(Likelihood =:= 1.0).

% AC-ABD-006: among two known-prior causes, the stronger prior is chosen.
test(strongest_known_prior_selected) :-
    % Abduce the best explanation for fatigue.
    mentova_abduce(fatigue, Best, Score, AllExplns),
    % Exercise beats illness because 0.7 exceeds 0.2.
    assertion(Best = explanation(exercise, _, _)),
    % The winning score is exercise's 0.7 prior.
    assertion(Score =:= 0.7),
    % Both causes appear, illness first because its score is lower.
    assertion(AllExplns = [explanation(illness, _, _),
                           explanation(exercise, _, _)]).

% AC-ABD-007: an observation with no known cause yields no explanation.
test(no_known_cause_fails) :-
    % There is no causes/2 fact for this made-up observation.
    assertion(\+ mentova_abduce(unicorn_dust, _, _, _)).

% Close the test block for the abduction module.
:- end_tests(abduction).
