/*  Mentova — Rung 28: Model-Based Reasoning Module

    Predicts from an explicit model.
    Pass criterion: model prediction matches observed behavior.

    A model is a set of equations or transition rules that map
    inputs to outputs. The prediction is compared to an observation.
*/

:- module(model_based, [
    mentova_model/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Models: model(Name, Type, Rules)
% ---------------------------------------------------------------------------

% Linear model: output = slope * input + intercept
model_linear(temperature_to_evaporation, slope(0.5), intercept(2.0)).
model_linear(sunlight_to_growth, slope(0.8), intercept(0.5)).
model_linear(exercise_to_caloric_deficit, slope(50.0), intercept(0.0)).

% Threshold model: if input >= threshold, output = high_val, else low_val
model_threshold(infection_spread, threshold(5), above(high), below(low)).
model_threshold(plant_water_need, threshold(30), above(critical), below(adequate)).

% Boolean gate models
model_gate(sprinkler_or_rain_wet_ground, or,  [sprinkler, rain], wet_ground).
model_gate(both_required,                and, [sunlight, water],  plant_grows).

% Transition model (state machine): state + input -> next_state
transition(dry,  rain,       wet).
transition(wet,  sunshine,   drying).
transition(drying, sunshine, dry).
transition(dry,  sprinkler,  wet).

% ---------------------------------------------------------------------------
% Predictions
% ---------------------------------------------------------------------------

predict_linear(ModelName, Input, Output) :-
    model_linear(ModelName, slope(S), intercept(I)),
    Output is S * Input + I.

predict_threshold(ModelName, Input, Output) :-
    model_threshold(ModelName, threshold(T), above(High), below(Low)),
    ( Input >= T -> Output = High ; Output = Low ).

predict_gate(ModelName, InputValues, Output) :-
    model_gate(ModelName, or, Inputs, Output) ->
        ( member(V, Inputs), member(V-true, InputValues) -> true ; fail )
    ; model_gate(ModelName, and, Inputs, Output),
      forall(member(I, Inputs), member(I-true, InputValues)).

predict_transition(State, Event, NextState) :-
    transition(State, Event, NextState).

% ---------------------------------------------------------------------------
% Observations for comparison
% observed_output(Model, Input, ObservedOutput)
% ---------------------------------------------------------------------------

observed_output(temperature_to_evaporation, 10, 7.0).
observed_output(temperature_to_evaporation, 20, 12.0).
observed_output(sunlight_to_growth, 5, 4.5).

% ---------------------------------------------------------------------------
% mentova_model(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_model(predict_linear(Model, Input), Prediction,
               just(model_based(Model, type(linear), input(Input), prediction(Prediction)))) :-
    predict_linear(Model, Input, Prediction).

mentova_model(predict_threshold(Model, Input), Prediction,
               just(model_based(Model, type(threshold), input(Input), prediction(Prediction)))) :-
    predict_threshold(Model, Input, Prediction).

mentova_model(predict_transition(State, Event), NextState,
               just(model_based(transition, from(State), event(Event), to(NextState)))) :-
    predict_transition(State, Event, NextState).

mentova_model(compare_with_observed(Model, Input), comparison(predicted(P), observed(O), match(Match)),
               just(model_comparison(Model, input(Input), predicted(P), observed(O), match(Match)))) :-
    predict_linear(Model, Input, P),
    observed_output(Model, Input, O),
    Diff is abs(P - O),
    ( Diff < 1.0 -> Match = yes ; Match = no ).
