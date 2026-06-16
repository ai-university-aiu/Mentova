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

% Declare this file as the 'bayesian' module and list its exported predicates.
:- module(bayesian, [
    % Supply 'mentova_bayes/4' as the next argument to the expression above.
    mentova_bayes/4
% Close the expression opened above.
]).

% ---------------------------------------------------------------------------
% Built-in Bayesian knowledge: priors and likelihoods
% ---------------------------------------------------------------------------

% prior(Hypothesis, PriorProbability)
% State the fact: prior(rain,     0.3).
prior(rain,     0.3).
% State the fact: prior(sprinkler,0.6).
prior(sprinkler,0.6).
% State the fact: prior(illness,  0.2).
prior(illness,  0.2).
% State the fact: prior(exercise, 0.7).
prior(exercise, 0.7).

% likelihood(Evidence, Hypothesis, P(Evidence|Hypothesis))
% State the fact: likelihood(wet_ground, rain,     0.95).
likelihood(wet_ground, rain,     0.95).
% State the fact: likelihood(wet_ground, sprinkler,0.90).
likelihood(wet_ground, sprinkler,0.90).
% State the fact: likelihood(fatigue,    illness,  0.80).
likelihood(fatigue,    illness,  0.80).
% State the fact: likelihood(fatigue,    exercise, 0.70).
likelihood(fatigue,    exercise, 0.70).
% State a fact for 'likelihood' with the arguments listed below.
likelihood(wet_ground, no_rain,  0.10).   % P(wet_ground | ¬rain)
% State a fact for 'likelihood' with the arguments listed below.
likelihood(fatigue,    no_illness, 0.30). % P(fatigue | ¬illness)

% ---------------------------------------------------------------------------
% mentova_bayes(+Hypothesis, +Evidence, -Posterior, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova bayes' with the arguments listed below.
mentova_bayes(H, E, Posterior, just(bayes(H, E,
                                          % Continue the multi-line expression started above.
                                          prior(H, PH),
                                          % Continue the multi-line expression started above.
                                          likelihood(E, H, PEH),
                                          % Continue the multi-line expression started above.
                                          likelihood(E, neg_H, PEnH),
                                          % Continue the multi-line expression started above.
                                          posterior(Posterior)))) :-
    % State a fact for 'prior' with the arguments listed below.
    prior(H, PH),
    % State a fact for 'likelihood' with the arguments listed below.
    likelihood(E, H, PEH),
    % P(E|¬H): look for a stored negation likelihood, else use complement heuristic
    % Check that '( likelihood(E, neg_H_key(H), PEnH0) -> PEnH' is unifiable with 'PEnH0'.
    ( likelihood(E, neg_H_key(H), PEnH0) -> PEnH = PEnH0
    % Otherwise (else branch), perform the following action.
    ; neg_hyp_likelihood(E, H, PEnH)
    % Close the expression opened above.
    ),
    % Evaluate the arithmetic expression '1.0 - PH' and bind the result to 'PnH'.
    PnH is 1.0 - PH,
    % Evaluate the arithmetic expression 'PEH * PH + PEnH * PnH' and bind the result to 'PE'.
    PE  is PEH * PH + PEnH * PnH,
    % Check that '( PE' is numerically equal to '0.0'.
    ( PE =:= 0.0
    % If the condition above succeeded, perform the following action.
    -> Posterior = undefined
    % Otherwise (else branch), perform the following action.
    ;  Posterior is (PEH * PH) / PE
    % Close the expression opened above.
    ).

% Derive P(E|¬H) from stored complement key if available, else use default
% Define a clause for 'neg hyp likelihood': succeed when the following conditions hold.
neg_hyp_likelihood(wet_ground, rain, 0.10) :- !.
% Define a clause for 'neg hyp likelihood': succeed when the following conditions hold.
neg_hyp_likelihood(wet_ground, sprinkler, 0.20) :- !.
% Define a clause for 'neg hyp likelihood': succeed when the following conditions hold.
neg_hyp_likelihood(fatigue, illness, 0.30) :- !.
% Define a clause for 'neg hyp likelihood': succeed when the following conditions hold.
neg_hyp_likelihood(fatigue, exercise, 0.20) :- !.
% State a fact for 'neg hyp likelihood' with the arguments listed below.
neg_hyp_likelihood(_, _, 0.10).   % conservative default
