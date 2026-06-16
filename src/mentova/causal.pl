/*  Mentova — Rung 6: Causal Reasoning Module

    Distinguishes observation from intervention (the do-calculus intuition):

        observe(E)      — E is seen; update beliefs via Bayes
        intervene(E)    — do(E) is performed; cut incoming edges to E,
                          propagate only outgoing causal effects

    The causal graph is read from causes/2 in small_world.pl.

    Pass criterion: intervention prediction differs correctly from mere observation.
    E.g. do(sprinkler) makes wet_ground likely regardless of rain; but merely
    observing sprinkler is on does not cut the rain edge.
*/

% Declare this file as the 'causal' module and list its exported predicates.
:- module(causal, [
    % Supply 'mentova_causal/3' as the next argument to the expression above.
    mentova_causal/3
% Close the expression opened above.
]).

% Import [causes/2, prob_fact/2] from the 'small_world' module.
:- use_module('../../knowledge/small_world', [causes/2, prob_fact/2]).

% ---------------------------------------------------------------------------
% Causal effect probabilities (stored explicitly for demonstration)
% ---------------------------------------------------------------------------

% causal_effect(Intervention, Effect, P_effect_given_do_intervention)
% Under do(sprinkler), wet_ground = P(wet_ground | do(sprinkler)) = 0.90
% Under observe(sprinkler), wet_ground is still influenced by rain too
% State the fact: causal effect(do(sprinkler),   wet_ground, 0.90).
causal_effect(do(sprinkler),   wet_ground, 0.90).
% State the fact: causal effect(do(rain),        wet_ground, 0.95).
causal_effect(do(rain),        wet_ground, 0.95).
% State the fact: causal effect(do(fire),        smoke,      0.99).
causal_effect(do(fire),        smoke,      0.99).
% State the fact: causal effect(do(hunger),      eating,     0.85).
causal_effect(do(hunger),      eating,     0.85).
% State the fact: causal effect(do(exercise),    fatigue,    0.70).
causal_effect(do(exercise),    fatigue,    0.70).
% State the fact: causal effect(do(sunlight),    plant_growth, 0.90).
causal_effect(do(sunlight),    plant_growth, 0.90).

% observational_effect: P(Effect | observe Cause is present)
% This uses the full joint, not cutting the causal graph
% State a fact for 'observational effect' with the arguments listed below.
observational_effect(sprinkler, wet_ground, 0.72).  % correlates with rain season
% State the fact: observational effect(rain,      wet_ground, 0.95).
observational_effect(rain,      wet_ground, 0.95).
% State the fact: observational effect(fire,      smoke,      0.99).
observational_effect(fire,      smoke,      0.99).
% State the fact: observational effect(hunger,    eating,     0.85).
observational_effect(hunger,    eating,     0.85).
% State the fact: observational effect(exercise,  fatigue,    0.70).
observational_effect(exercise,  fatigue,    0.70).
% State the fact: observational effect(sunlight,  plant_growth, 0.90).
observational_effect(sunlight,  plant_growth, 0.90).

% ---------------------------------------------------------------------------
% mentova_causal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Interventional query: do(Cause) → Effect
% State a fact for 'mentova causal' with the arguments listed below.
mentova_causal(intervene(Cause, Effect), P,
               % Continue the multi-line expression started above.
               just(intervention(do(Cause), Effect, P,
                    % Continue the multi-line expression started above.
                    note('incoming edges to Cause severed; only causal path retained')))) :-
    % State the fact: causal effect(do(Cause), Effect, P).
    causal_effect(do(Cause), Effect, P).

% Observational query: observe(Cause) → Effect probability
% State a fact for 'mentova causal' with the arguments listed below.
mentova_causal(observe(Cause, Effect), P,
               % Continue the multi-line expression started above.
               just(observation(Cause, Effect, P,
                    % Continue the multi-line expression started above.
                    note('no edge severing; all paths to Effect included')))) :-
    % State the fact: observational effect(Cause, Effect, P).
    observational_effect(Cause, Effect, P).

% Compare intervention vs observation
% State a fact for 'mentova causal' with the arguments listed below.
mentova_causal(compare(Cause, Effect), compare(P_do, P_obs, Diff),
               % Continue the multi-line expression started above.
               just(compare(intervene(Cause,Effect,P_do),
                            % Continue the multi-line expression started above.
                            observe(Cause,Effect,P_obs),
                            % Continue the multi-line expression started above.
                            difference(Diff)))) :-
    % State a fact for 'causal effect' with the arguments listed below.
    causal_effect(do(Cause), Effect, P_do),
    % State a fact for 'observational effect' with the arguments listed below.
    observational_effect(Cause, Effect, P_obs),
    % Evaluate the arithmetic expression 'P_do - P_obs' and bind the result to 'Diff'.
    Diff is P_do - P_obs.

% Causal chain: find all effects downstream of a cause (BFS over causes/2)
% State a fact for 'mentova causal' with the arguments listed below.
mentova_causal(chain(Cause), chain(Cause, Effects),
               % Continue the multi-line expression started above.
               just(causal_chain(Cause, Effects))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(E, causes(Cause, E), Effects).
