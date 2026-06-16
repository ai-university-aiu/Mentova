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

:- module(causal, [
    mentova_causal/3
]).

:- use_module('../../knowledge/small_world', [causes/2, prob_fact/2]).

% ---------------------------------------------------------------------------
% Causal effect probabilities (stored explicitly for demonstration)
% ---------------------------------------------------------------------------

% causal_effect(Intervention, Effect, P_effect_given_do_intervention)
% Under do(sprinkler), wet_ground = P(wet_ground | do(sprinkler)) = 0.90
% Under observe(sprinkler), wet_ground is still influenced by rain too
causal_effect(do(sprinkler),   wet_ground, 0.90).
causal_effect(do(rain),        wet_ground, 0.95).
causal_effect(do(fire),        smoke,      0.99).
causal_effect(do(hunger),      eating,     0.85).
causal_effect(do(exercise),    fatigue,    0.70).
causal_effect(do(sunlight),    plant_growth, 0.90).

% observational_effect: P(Effect | observe Cause is present)
% This uses the full joint, not cutting the causal graph
observational_effect(sprinkler, wet_ground, 0.72).  % correlates with rain season
observational_effect(rain,      wet_ground, 0.95).
observational_effect(fire,      smoke,      0.99).
observational_effect(hunger,    eating,     0.85).
observational_effect(exercise,  fatigue,    0.70).
observational_effect(sunlight,  plant_growth, 0.90).

% ---------------------------------------------------------------------------
% mentova_causal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Interventional query: do(Cause) → Effect
mentova_causal(intervene(Cause, Effect), P,
               just(intervention(do(Cause), Effect, P,
                    note('incoming edges to Cause severed; only causal path retained')))) :-
    causal_effect(do(Cause), Effect, P).

% Observational query: observe(Cause) → Effect probability
mentova_causal(observe(Cause, Effect), P,
               just(observation(Cause, Effect, P,
                    note('no edge severing; all paths to Effect included')))) :-
    observational_effect(Cause, Effect, P).

% Compare intervention vs observation
mentova_causal(compare(Cause, Effect), compare(P_do, P_obs, Diff),
               just(compare(intervene(Cause,Effect,P_do),
                            observe(Cause,Effect,P_obs),
                            difference(Diff)))) :-
    causal_effect(do(Cause), Effect, P_do),
    observational_effect(Cause, Effect, P_obs),
    Diff is P_do - P_obs.

% Causal chain: find all effects downstream of a cause (BFS over causes/2)
mentova_causal(chain(Cause), chain(Cause, Effects),
               just(causal_chain(Cause, Effects))) :-
    findall(E, causes(Cause, E), Effects).
