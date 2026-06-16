/*  Mentova — Rung 28: Model-Based Reasoning Module

    Predicts from an explicit model.
    Pass criterion: model prediction matches observed behavior.

    A model is a set of equations or transition rules that map
    inputs to outputs. The prediction is compared to an observation.
*/

% Declare this file as the 'model_based' module and list its exported predicates.
:- module(model_based, [
    % Supply 'mentova_model/3' as the next argument to the expression above.
    mentova_model/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Models: model(Name, Type, Rules)
% ---------------------------------------------------------------------------

% Linear model: output = slope * input + intercept
% State the fact: model linear(temperature_to_evaporation, slope(0.5), intercept(2.0)).
model_linear(temperature_to_evaporation, slope(0.5), intercept(2.0)).
% State the fact: model linear(sunlight_to_growth, slope(0.8), intercept(0.5)).
model_linear(sunlight_to_growth, slope(0.8), intercept(0.5)).
% State the fact: model linear(exercise_to_caloric_deficit, slope(50.0), intercept(0.0)).
model_linear(exercise_to_caloric_deficit, slope(50.0), intercept(0.0)).

% Threshold model: if input >= threshold, output = high_val, else low_val
% State the fact: model threshold(infection_spread, threshold(5), above(high), below(low)).
model_threshold(infection_spread, threshold(5), above(high), below(low)).
% State the fact: model threshold(plant_water_need, threshold(30), above(critical), below(adequate)).
model_threshold(plant_water_need, threshold(30), above(critical), below(adequate)).

% Boolean gate models
% State the fact: model gate(sprinkler_or_rain_wet_ground, or,  [sprinkler, rain], wet_ground).
model_gate(sprinkler_or_rain_wet_ground, or,  [sprinkler, rain], wet_ground).
% State the fact: model gate(both_required,                and, [sunlight, water],  plant_grows).
model_gate(both_required,                and, [sunlight, water],  plant_grows).

% Transition model (state machine): state + input -> next_state
% State the fact: transition(dry,  rain,       wet).
transition(dry,  rain,       wet).
% State the fact: transition(wet,  sunshine,   drying).
transition(wet,  sunshine,   drying).
% State the fact: transition(drying, sunshine, dry).
transition(drying, sunshine, dry).
% State the fact: transition(dry,  sprinkler,  wet).
transition(dry,  sprinkler,  wet).

% ---------------------------------------------------------------------------
% Predictions
% ---------------------------------------------------------------------------

% Define a clause for 'predict linear': succeed when the following conditions hold.
predict_linear(ModelName, Input, Output) :-
    % State a fact for 'model linear' with the arguments listed below.
    model_linear(ModelName, slope(S), intercept(I)),
    % Evaluate the arithmetic expression 'S * Input + I' and bind the result to 'Output'.
    Output is S * Input + I.

% Define a clause for 'predict threshold': succeed when the following conditions hold.
predict_threshold(ModelName, Input, Output) :-
    % State a fact for 'model threshold' with the arguments listed below.
    model_threshold(ModelName, threshold(T), above(High), below(Low)),
    % Check that '( Input' is greater than or equal to 'T -> Output = High ; Output = Low )'.
    ( Input >= T -> Output = High ; Output = Low ).

% Define a clause for 'predict gate': succeed when the following conditions hold.
predict_gate(ModelName, InputValues, Output) :-
    % State a fact for 'model gate' with the arguments listed below.
    model_gate(ModelName, or, Inputs, Output) ->
        % Execute: ( member(V, Inputs), member(V-true, InputValues) -> true ; fail ).
        ( member(V, Inputs), member(V-true, InputValues) -> true ; fail )
    % Execute: ; model_gate(ModelName, and, Inputs, Output),.
    ; model_gate(ModelName, and, Inputs, Output),
      % Verify that for every solution of the Condition, the Action also holds.
      forall(member(I, Inputs), member(I-true, InputValues)).

% Define a clause for 'predict transition': succeed when the following conditions hold.
predict_transition(State, Event, NextState) :-
    % State the fact: transition(State, Event, NextState).
    transition(State, Event, NextState).

% ---------------------------------------------------------------------------
% Observations for comparison
% observed_output(Model, Input, ObservedOutput)
% ---------------------------------------------------------------------------

% State the fact: observed output(temperature_to_evaporation, 10, 7.0).
observed_output(temperature_to_evaporation, 10, 7.0).
% State the fact: observed output(temperature_to_evaporation, 20, 12.0).
observed_output(temperature_to_evaporation, 20, 12.0).
% State the fact: observed output(sunlight_to_growth, 5, 4.5).
observed_output(sunlight_to_growth, 5, 4.5).

% ---------------------------------------------------------------------------
% mentova_model(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova model' with the arguments listed below.
mentova_model(predict_linear(Model, Input), Prediction,
               % Continue the multi-line expression started above.
               just(model_based(Model, type(linear), input(Input), prediction(Prediction)))) :-
    % State the fact: predict linear(Model, Input, Prediction).
    predict_linear(Model, Input, Prediction).

% State a fact for 'mentova model' with the arguments listed below.
mentova_model(predict_threshold(Model, Input), Prediction,
               % Continue the multi-line expression started above.
               just(model_based(Model, type(threshold), input(Input), prediction(Prediction)))) :-
    % State the fact: predict threshold(Model, Input, Prediction).
    predict_threshold(Model, Input, Prediction).

% State a fact for 'mentova model' with the arguments listed below.
mentova_model(predict_transition(State, Event), NextState,
               % Continue the multi-line expression started above.
               just(model_based(transition, from(State), event(Event), to(NextState)))) :-
    % State the fact: predict transition(State, Event, NextState).
    predict_transition(State, Event, NextState).

% State a fact for 'mentova model' with the arguments listed below.
mentova_model(compare_with_observed(Model, Input), comparison(predicted(P), observed(O), match(Match)),
               % Continue the multi-line expression started above.
               just(model_comparison(Model, input(Input), predicted(P), observed(O), match(Match)))) :-
    % State a fact for 'predict linear' with the arguments listed below.
    predict_linear(Model, Input, P),
    % State a fact for 'observed output' with the arguments listed below.
    observed_output(Model, Input, O),
    % Evaluate the arithmetic expression 'abs(P - O)' and bind the result to 'Diff'.
    Diff is abs(P - O),
    % Check that '( Diff' is less than '1.0 -> Match = yes ; Match = no )'.
    ( Diff < 1.0 -> Match = yes ; Match = no ).
