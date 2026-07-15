/*  Mentova — Causal Reasoning Module Test Suite

    Behavioural PLUnit tests for the single exported predicate
    mentova_causal/3 of src/mentova/causal.pl. The module distinguishes
    intervention (do-calculus, incoming edges severed) from mere
    observation (all paths retained), compares the two, and walks the
    causes/2 graph from knowledge/small_world.pl for causal chains.

    Run with the full PrologAI library path plus the Mentova source:
        swipl <libs> -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" test/test_causal.pl
*/

% Declare this file as the test module with no exports.
:- module(test_causal, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the causal reasoning module under test.
:- use_module(library(causal)).

% Open the test block for the causal module.
:- begin_tests(causal).

% An interventional query returns the stored do-effect probability with its glass-box justification.
test(intervention_probability_and_justification) :-
    % Query the effect of intervening on the sprinkler, taking the single answer.
    once(mentova_causal(intervene(sprinkler, wet_ground), P, J)),
    % The severed-graph effect of do(sprinkler) on wet ground is 0.90.
    assertion(P =:= 0.90),
    % The justification names the intervention, records the severed graph, and carries the probability.
    assertion(J == just(intervention(do(sprinkler), wet_ground, 0.90,
                        note('incoming edges to Cause severed; only causal path retained')))).

% An observational query returns the stored correlational probability with its glass-box justification.
test(observation_probability_and_justification) :-
    % Query the effect of merely observing the sprinkler, taking the single answer.
    once(mentova_causal(observe(sprinkler, wet_ground), P, J)),
    % Observing the sprinkler correlates with wet ground at 0.72.
    assertion(P =:= 0.72),
    % The justification names the observation, keeps all paths, and carries the probability.
    assertion(J == just(observation(sprinkler, wet_ground, 0.72,
                        note('no edge severing; all paths to Effect included')))).

% Intervention and observation give different sprinkler numbers — the whole do-calculus point.
test(intervention_differs_from_observation) :-
    % The interventional probability of do(sprinkler), taking the single answer.
    once(mentova_causal(intervene(sprinkler, wet_ground), PDo, _)),
    % The observational probability of merely seeing the sprinkler on, taking the single answer.
    once(mentova_causal(observe(sprinkler, wet_ground), PObs, _)),
    % Cutting the incoming edges lifts the effect above the mere correlation.
    assertion(PDo > PObs).

% The compare query reports both probabilities and their signed difference.
test(compare_reports_difference) :-
    % Compare intervention against observation for the sprinkler, taking the single answer.
    once(mentova_causal(compare(sprinkler, wet_ground), compare(PDo, PObs, Diff), _)),
    % The do-side of the comparison is 0.90.
    assertion(PDo =:= 0.90),
    % The observe-side of the comparison is 0.72.
    assertion(PObs =:= 0.72),
    % The difference is the do-side minus the observe-side, about 0.18.
    assertion(abs(Diff - 0.18) < 1.0e-9).

% A second interventional pair confirms the effect table is genuinely queried, not a single hard-coded answer.
test(intervention_fire_smoke) :-
    % Query the effect of intervening to start a fire, taking the single answer.
    once(mentova_causal(intervene(fire, smoke), P, _)),
    % Starting a fire almost certainly produces smoke at 0.99.
    assertion(P =:= 0.99).

% The chain query walks causes/2 to list every downstream effect of a cause.
test(causal_chain_from_causes) :-
    % Ask for everything rain causes in the small world, taking the single answer.
    once(mentova_causal(chain(rain), chain(rain, Effects), _)),
    % Rain causes exactly wet ground in the knowledge base.
    assertion(Effects == [wet_ground]).

% Close the test block for the causal module.
:- end_tests(causal).
