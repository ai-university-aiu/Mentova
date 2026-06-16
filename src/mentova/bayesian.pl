/*  Mentova — Rung 5: Bayesian Reasoning Module

    Updates a prior belief on new evidence using Bayes' theorem:

        P(H|E) = P(E|H) * P(H) / P(E)

    where P(E) = P(E|H)*P(H) + P(E|¬H)*P(¬H).

    The knowledge base supplies:
        prior(H, P)             prior probability of hypothesis H
        likelihood(E, H, P)     P(E | H) — likelihood of evidence given hypothesis

    Every result carries a justification that names the prior,
    the likelihoods, and the posterior.
*/

:- module(bayesian, [
    mentova_bayes/4
]).

% ---------------------------------------------------------------------------
% Built-in Bayesian knowledge: priors and likelihoods
% ---------------------------------------------------------------------------

% prior(Hypothesis, PriorProbability)
prior(rain,     0.3).
prior(sprinkler,0.6).
prior(illness,  0.2).
prior(exercise, 0.7).

% likelihood(Evidence, Hypothesis, P(Evidence|Hypothesis))
likelihood(wet_ground, rain,     0.95).
likelihood(wet_ground, sprinkler,0.90).
likelihood(fatigue,    illness,  0.80).
likelihood(fatigue,    exercise, 0.70).
likelihood(wet_ground, no_rain,  0.10).   % P(wet_ground | ¬rain)
likelihood(fatigue,    no_illness, 0.30). % P(fatigue | ¬illness)

% ---------------------------------------------------------------------------
% mentova_bayes(+Hypothesis, +Evidence, -Posterior, -Justification)
% ---------------------------------------------------------------------------

mentova_bayes(H, E, Posterior, just(bayes(H, E,
                                          prior(H, PH),
                                          likelihood(E, H, PEH),
                                          likelihood(E, neg_H, PEnH),
                                          posterior(Posterior)))) :-
    prior(H, PH),
    likelihood(E, H, PEH),
    % P(E|¬H): look for a stored negation likelihood, else use complement heuristic
    ( likelihood(E, neg_H_key(H), PEnH0) -> PEnH = PEnH0
    ; neg_hyp_likelihood(E, H, PEnH)
    ),
    PnH is 1.0 - PH,
    PE  is PEH * PH + PEnH * PnH,
    ( PE =:= 0.0
    -> Posterior = undefined
    ;  Posterior is (PEH * PH) / PE
    ).

% Derive P(E|¬H) from stored complement key if available, else use default
neg_hyp_likelihood(wet_ground, rain, 0.10) :- !.
neg_hyp_likelihood(wet_ground, sprinkler, 0.20) :- !.
neg_hyp_likelihood(fatigue, illness, 0.30) :- !.
neg_hyp_likelihood(fatigue, exercise, 0.20) :- !.
neg_hyp_likelihood(_, _, 0.10).   % conservative default
