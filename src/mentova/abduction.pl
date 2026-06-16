/*  Mentova — Abductive Reasoning Module  (Rung 3)

    Abduction is inference to the best explanation: given an observation O,
    find the hypothesis H that best explains O.

    Strategy:
        1. Collect all candidate hypotheses H such that causes(H, O) holds
           in the background knowledge.
        2. Score each H by its prior probability prob_fact(H, P) if known,
           or a neutral default of 0.5 if unknown.
        3. If an observation count is available, compute a simple likelihood
           weight: observed_count / (observed_count + unobserved_count).
        4. Return the best-scoring H together with its full evidence record:
           the causal link, the prior, and any supporting observations.

    Predicates:
        mentova_abduce/4  — +Observation, -Best, -Score, -AllExplained
*/

:- module(abduction, [
    mentova_abduce/4
]).

:- use_module(library(lists),  [member/2, last/2]).
:- use_module('../../knowledge/small_world',
              [causes/2, prob_fact/2, observation/3]).

% ---------------------------------------------------------------------------
% mentova_abduce/4
%
%   Observation  — the fact to be explained, e.g. wet_ground
%   Best         — explanation(Hypothesis, Score, Evidence)
%   Score        — numeric score of the best hypothesis
%   AllExplns    — list of all explanation/3 terms, scored and sorted
% ---------------------------------------------------------------------------

mentova_abduce(Observation, Best, Score, AllExplns) :-
    % Step 1: find all causal hypotheses
    findall(H, causes(H, Observation), Candidates),
    Candidates \= [],
    % Step 2: score each candidate
    maplist(score_hypothesis(Observation), Candidates, Scored),
    % Step 3: sort ascending; best is last
    msort(Scored, SortedAsc),
    last(SortedAsc, Score-Best),
    % Build full list for transparency
    maplist([_S-E, E]>>true, SortedAsc, AllExplns).

score_hypothesis(Observation, H, Score-explanation(H, Score, Evidence)) :-
    % Prior probability
    ( prob_fact(H, Prior) -> true ; Prior = 0.5 ),
    % Likelihood from observation table (if available)
    ( observation(H, Observation, Count),
      TotalObs is Count + 1
    ->  Likelihood is Count / TotalObs,
        LikelihoodNote = observed(Count)
    ;   Likelihood = 1.0,
        LikelihoodNote = no_direct_observation
    ),
    Score is Prior * Likelihood,
    Evidence = evidence(cause(H, Observation), prior(Prior),
                        likelihood(Likelihood), note(LikelihoodNote)).
