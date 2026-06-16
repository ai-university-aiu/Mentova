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

% Declare this file as the 'abduction' module and list its exported predicates.
:- module(abduction, [
    % Supply 'mentova_abduce/4' as the next argument to the expression above.
    mentova_abduce/4
% Close the expression opened above.
]).

% Import [member/2, last/2] from the built-in 'lists' library.
:- use_module(library(lists),  [member/2, last/2]).
% Load the 'small_world' module so its predicates are available here.
:- use_module('../../knowledge/small_world',
              % Continue the multi-line expression started above.
              [causes/2, prob_fact/2, observation/3]).

% ---------------------------------------------------------------------------
% mentova_abduce/4
%
%   Observation  — the fact to be explained, e.g. wet_ground
%   Best         — explanation(Hypothesis, Score, Evidence)
%   Score        — numeric score of the best hypothesis
%   AllExplns    — list of all explanation/3 terms, scored and sorted
% ---------------------------------------------------------------------------

% Define a clause for 'mentova abduce': succeed when the following conditions hold.
mentova_abduce(Observation, Best, Score, AllExplns) :-
    % Step 1: find all causal hypotheses
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(H, causes(H, Observation), Candidates),
    % Check that 'Candidates' is not unifiable with '[]'.
    Candidates \= [],
    % Step 2: score each candidate
    % State a fact for 'maplist' with the arguments listed below.
    maplist(score_hypothesis(Observation), Candidates, Scored),
    % Step 3: sort ascending; best is last
    % Sort list 'Scored' into 'SortedAsc', keeping duplicates.
    msort(Scored, SortedAsc),
    % Unify the second argument with the last element of list 'SortedAsc'.
    last(SortedAsc, Score-Best),
    % Build full list for transparency
    % State the fact: maplist([_S-E, E]>>true, SortedAsc, AllExplns).
    maplist([_S-E, E]>>true, SortedAsc, AllExplns).

% Define a clause for 'score hypothesis': succeed when the following conditions hold.
score_hypothesis(Observation, H, Score-explanation(H, Score, Evidence)) :-
    % Prior probability
    % Check that '( prob_fact(H, Prior) -> true ; Prior' is unifiable with '0.5 )'.
    ( prob_fact(H, Prior) -> true ; Prior = 0.5 ),
    % Likelihood from observation table (if available)
    % Execute: ( observation(H, Observation, Count),.
    ( observation(H, Observation, Count),
      % Continue the multi-line expression started above.
      TotalObs is Count + 1
    % If the condition above succeeded, perform the following action.
    ->  Likelihood is Count / TotalObs,
        % Continue the multi-line expression started above.
        LikelihoodNote = observed(Count)
    % Otherwise (else branch), perform the following action.
    ;   Likelihood = 1.0,
        % Continue the multi-line expression started above.
        LikelihoodNote = no_direct_observation
    % Close the expression opened above.
    ),
    % Evaluate the arithmetic expression 'Prior * Likelihood' and bind the result to 'Score'.
    Score is Prior * Likelihood,
    % Check that 'Evidence' is unifiable with 'evidence(cause(H, Observation), prior(Prior)'.
    Evidence = evidence(cause(H, Observation), prior(Prior),
                        % Continue the multi-line expression started above.
                        likelihood(Likelihood), note(LikelihoodNote)).
