/*  Mentova — Model-Based Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/model_based.pl, which exports
    mentova_model/3 — a single query predicate over four kinds of explicit
    model: linear models (output = slope*input + intercept), threshold
    models (above/below a cutoff), a state-transition machine, and a
    predicted-versus-observed comparison. Each query returns a result and a
    glass-box justification term.

    Every expected value below is hand-computed from the static model facts
    in the module (model_linear/3, model_threshold/4, transition/3,
    observed_output/3), so these are behavioural assertions, not smoke.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_model_based.pl
*/

% Declare this file as a test module with no exports.
:- module(test_model_based, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(model_based)).

% Open the test block for the model_based module.
:- begin_tests(model_based).

% AC-MODEL-001: the linear model applies output = slope*input + intercept and reports it.
test(linear_prediction_and_justification) :-
    % Query the temperature_to_evaporation linear model at input 10.
    mentova_model(predict_linear(temperature_to_evaporation, 10), Prediction, Justification),
    % Hand computation: slope 0.5 times input 10 plus intercept 2.0 equals 7.0.
    assertion(abs(Prediction - 7.0) < 1.0e-9),
    % The justification is the documented four-slot linear model_based term.
    Justification = just(model_based(temperature_to_evaporation, type(linear),
                                     input(ReportedInput), prediction(ReportedPrediction))),
    % The justification carries back the input that was queried.
    assertion(ReportedInput =:= 10),
    % The justification carries back the same prediction that was returned.
    assertion(ReportedPrediction =:= Prediction).

% AC-MODEL-002: every linear model matches its own slope-and-intercept arithmetic.
test(all_linear_models_match_their_arithmetic) :-
    % Consider each linear model paired with a query input and its hand-computed output.
    forall(member(Model-Input-Expected, [temperature_to_evaporation-10-7.0,
                                         sunlight_to_growth-5-4.5,
                                         exercise_to_caloric_deficit-4-200.0]),
           % The model's prediction equals the hand-computed value within tolerance.
           ( mentova_model(predict_linear(Model, Input), Prediction, _),
             assertion(abs(Prediction - Expected) < 1.0e-9) )).

% AC-MODEL-003: the threshold model returns the above-value at or over the cutoff, else the below-value.
test(threshold_model_switches_at_cutoff) :-
    % Infection spread has cutoff 5, above-value high, below-value low; input 6 is over the cutoff.
    mentova_model(predict_threshold(infection_spread, 6), Over, _),
    % Above the cutoff the model returns high.
    assertion(Over == high),
    % Input 3 is under the cutoff.
    mentova_model(predict_threshold(infection_spread, 3), Under, _),
    % Below the cutoff the model returns low.
    assertion(Under == low),
    % Input 5 sits exactly on the cutoff, which the module treats as "at or above".
    mentova_model(predict_threshold(infection_spread, 5), Boundary, _),
    % On the boundary the model still returns the above-value high.
    assertion(Boundary == high).

% AC-MODEL-004: a second threshold model uses its own cutoff and its own two outcome labels.
test(second_threshold_model_uses_its_own_labels) :-
    % Plant water need has cutoff 30, above-value critical, below-value adequate; input 40 is over.
    mentova_model(predict_threshold(plant_water_need, 40), Over, Justification),
    % Above the cutoff the model returns critical.
    assertion(Over == critical),
    % Input 10 is under the cutoff.
    mentova_model(predict_threshold(plant_water_need, 10), Under, _),
    % Below the cutoff the model returns adequate.
    assertion(Under == adequate),
    % The justification names this as a threshold-type model_based prediction.
    Justification = just(model_based(plant_water_need, type(threshold), input(40), prediction(critical))).

% AC-MODEL-005: the transition machine maps a state and an event to the documented next state.
test(state_transitions_follow_the_machine) :-
    % Consider each documented (state, event) pair with its hand-read next state.
    forall(member(State-Event-Next, [dry-rain-wet, wet-sunshine-drying,
                                     drying-sunshine-dry, dry-sprinkler-wet]),
           % The transition query returns exactly the machine's next state.
           ( mentova_model(predict_transition(State, Event), NextState, _),
             assertion(NextState == Next) )),
    % The justification for the dry-plus-rain step names the from-state, event, and to-state.
    mentova_model(predict_transition(dry, rain), _, Justification),
    % The transition justification is the documented from/event/to term.
    Justification = just(model_based(transition, from(dry), event(rain), to(wet))).

% AC-MODEL-006: comparing a prediction with a stored observation reports predicted, observed, and a match flag.
test(compare_with_observed_reports_match) :-
    % Temperature_to_evaporation at input 10 predicts 7.0 and was observed at 7.0.
    mentova_model(compare_with_observed(temperature_to_evaporation, 10), Comparison, _),
    % The comparison term carries the predicted value, the observed value, and the match verdict.
    Comparison = comparison(predicted(P), observed(O), match(Match)),
    % The predicted value equals the linear model's hand-computed 7.0.
    assertion(abs(P - 7.0) < 1.0e-9),
    % The observed value stored for this input is also 7.0.
    assertion(abs(O - 7.0) < 1.0e-9),
    % Predicted and observed agree within the module's one-unit tolerance, so the match is yes.
    assertion(Match == yes),
    % Sunlight_to_growth at input 5 predicts 4.5 and was observed at 4.5, another agreeing match.
    mentova_model(compare_with_observed(sunlight_to_growth, 5),
                  comparison(predicted(P2), observed(O2), match(Match2)), _),
    % The two sunlight values coincide.
    assertion(abs(P2 - O2) < 1.0e-9),
    % So the sunlight comparison also reports a match.
    assertion(Match2 == yes).

% Close the test block for the model_based module.
:- end_tests(model_based).
