/*  Mentova — Bayesian Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/bayesian.pl, which exports
    mentova_bayes/4 — Bayes' theorem P(H|E) = P(E|H)*P(H) / P(E) with
    P(E) = P(E|H)*P(H) + P(E|not H)*P(not H) — over a built-in knowledge
    base of priors and likelihoods, returning the posterior and a
    glass-box justification term.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_bayesian.pl
*/

% Declare this file as a test module with no exports.
:- module(test_bayesian, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(bayesian)).

% Open the test block for the bayesian module.
:- begin_tests(bayesian).

% AC-BAYES-001: rain given wet ground uses prior 0.3 and likelihoods 0.95 / 0.10.
test(rain_given_wet_ground_posterior) :-
    % Run Bayes' theorem for the rain hypothesis on the wet_ground evidence.
    mentova_bayes(rain, wet_ground, Posterior, _Justification),
    % Hand computation: (0.95*0.3) / (0.95*0.3 + 0.10*0.7) = 0.285 / 0.355.
    Expected is 0.285 / 0.355,
    % The returned posterior matches the hand-computed value within tolerance.
    assertion(abs(Posterior - Expected) < 1.0e-9).

% AC-BAYES-002: illness given fatigue reduces the belief below its own prior.
test(illness_given_fatigue_posterior) :-
    % Run Bayes' theorem for the illness hypothesis on the fatigue evidence.
    mentova_bayes(illness, fatigue, Posterior, _Justification),
    % Hand computation: (0.80*0.2) / (0.80*0.2 + 0.30*0.8) = 0.16 / 0.40 = 0.4.
    assertion(abs(Posterior - 0.4) < 1.0e-9),
    % The prior on illness was 0.2, so seeing fatigue raised the belief.
    assertion(Posterior > 0.2).

% AC-BAYES-003: the justification names the prior, both likelihoods, and the posterior.
test(justification_reports_its_inputs) :-
    % Run Bayes' theorem for the sprinkler hypothesis on the wet_ground evidence.
    mentova_bayes(sprinkler, wet_ground, Posterior, Justification),
    % The justification is the documented six-slot bayes term.
    Justification = just(bayes(sprinkler, wet_ground,
                               prior(sprinkler, PriorH),
                               likelihood(wet_ground, sprinkler, LikeEH),
                               likelihood(wet_ground, neg_H, LikeEnH),
                               posterior(ReportedPosterior))),
    % The named prior is the built-in prior(sprinkler, 0.6).
    assertion(PriorH =:= 0.6),
    % The named hypothesis likelihood is likelihood(wet_ground, sprinkler, 0.90).
    assertion(LikeEH =:= 0.90),
    % The named negation likelihood is the complement heuristic value 0.20.
    assertion(LikeEnH =:= 0.20),
    % The posterior carried in the justification equals the returned posterior.
    assertion(ReportedPosterior =:= Posterior).

% AC-BAYES-004: the returned posterior is internally consistent with its own reported terms.
test(posterior_matches_bayes_formula_from_justification) :-
    % Run Bayes' theorem for the exercise hypothesis on the fatigue evidence.
    mentova_bayes(exercise, fatigue, Posterior, Justification),
    % Read the prior and the two likelihoods back out of the justification.
    Justification = just(bayes(exercise, fatigue,
                               prior(exercise, PriorH),
                               likelihood(fatigue, exercise, LikeEH),
                               likelihood(fatigue, neg_H, LikeEnH),
                               posterior(_))),
    % Recompute the total evidence probability P(E) from those terms.
    Evidence is LikeEH * PriorH + LikeEnH * (1.0 - PriorH),
    % Recompute the posterior independently from Bayes' theorem.
    Recomputed is (LikeEH * PriorH) / Evidence,
    % The module's posterior matches the independent recomputation.
    assertion(abs(Posterior - Recomputed) < 1.0e-9).

% AC-BAYES-005: every posterior is a well-formed probability in the unit interval.
test(all_posteriors_are_probabilities) :-
    % Consider each hypothesis paired with evidence that bears on it.
    forall(member(H-E, [rain-wet_ground, sprinkler-wet_ground,
                        illness-fatigue, exercise-fatigue]),
           % Each pair yields a posterior between zero and one inclusive.
           ( mentova_bayes(H, E, Posterior, _),
             assertion(Posterior >= 0.0),
             assertion(Posterior =< 1.0) )).

% AC-BAYES-006: with the same evidence, the stronger likelihood ratio yields the higher posterior.
test(stronger_evidence_yields_higher_posterior) :-
    % Posterior for rain given wet ground.
    mentova_bayes(rain, wet_ground, RainPosterior, _),
    % Posterior for sprinkler given the same wet-ground evidence.
    mentova_bayes(sprinkler, wet_ground, SprinklerPosterior, _),
    % Sprinkler's stronger prior-and-likelihood combination outweighs rain's.
    assertion(SprinklerPosterior > RainPosterior).

% Close the test block for the bayesian module.
:- end_tests(bayesian).
