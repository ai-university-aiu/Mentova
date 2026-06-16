/*  Mentova — Rung 16: Qualitative Reasoning Module

    Predicts direction of change without numbers.
    Uses qualitative calculus: quantities are +, 0, -.
    Relations: increases(X,Y), decreases(X,Y), no_effect(X,Y).

    Pass criterion: rising/falling/more/less is correct.
*/

% Declare this file as the 'qualitative' module and list its exported predicates.
:- module(qualitative, [
    % Supply 'mentova_qualitative/3' as the next argument to the expression above.
    mentova_qualitative/3
% Close the expression opened above.
]).

% Import [causes/2] from the 'small_world' module.
:- use_module('../../knowledge/small_world', [causes/2]).
% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Qualitative causal relations
% increases(Cause, Effect): more of Cause → more of Effect
% decreases(Cause, Effect): more of Cause → less of Effect
% ---------------------------------------------------------------------------

% State the fact: increases(temperature,   evaporation).
increases(temperature,   evaporation).
% State the fact: increases(temperature,   pressure).
increases(temperature,   pressure).
% State the fact: increases(rainfall,      flood_risk).
increases(rainfall,      flood_risk).
% State the fact: increases(exercise,      fitness).
increases(exercise,      fitness).
% State the fact: increases(exercise,      fatigue).
increases(exercise,      fatigue).
% State the fact: increases(sunlight,      plant_growth).
increases(sunlight,      plant_growth).
% State the fact: increases(sunlight,      temperature).
increases(sunlight,      temperature).
% State the fact: increases(food_supply,   population).
increases(food_supply,   population).
% State the fact: increases(population,    waste).
increases(population,    waste).
% State the fact: increases(rainfall,      soil_moisture).
increases(rainfall,      soil_moisture).
% State the fact: increases(soil_moisture, plant_growth).
increases(soil_moisture, plant_growth).

% State the fact: decreases(temperature,   ice_thickness).
decreases(temperature,   ice_thickness).
% State the fact: decreases(exercise,      weight).
decreases(exercise,      weight).
% State the fact: decreases(rainfall,      drought_risk).
decreases(rainfall,      drought_risk).
% State the fact: decreases(food_supply,   hunger).
decreases(food_supply,   hunger).
% State the fact: decreases(antibiotics,   bacteria_count).
decreases(antibiotics,   bacteria_count).
% State the fact: decreases(sunscreen,     sunburn_risk).
decreases(sunscreen,     sunburn_risk).

% State the fact: no effect(temperature,   gravity).
no_effect(temperature,   gravity).
% State the fact: no effect(colour,        mass).
no_effect(colour,        mass).

% ---------------------------------------------------------------------------
% Qualitative multiplication table:
% Q(A*B): sign(A)*sign(B) -> sign(product)
% Signs: pos, zero, neg
% ---------------------------------------------------------------------------

% State the fact: qmult(pos, pos, pos).
qmult(pos, pos, pos).
% State the fact: qmult(pos, neg, neg).
qmult(pos, neg, neg).
% State the fact: qmult(neg, pos, neg).
qmult(neg, pos, neg).
% State the fact: qmult(neg, neg, pos).
qmult(neg, neg, pos).
% State the fact: qmult(zero, _, zero).
qmult(zero, _, zero).
% State the fact: qmult(_, zero, zero).
qmult(_, zero, zero).

% ---------------------------------------------------------------------------
% mentova_qualitative(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Direction: does increasing X increase or decrease Y?
% Define a clause for 'mentova qualitative': succeed when the following conditions hold.
mentova_qualitative(direction(X, Y), increases, just(increases(X, Y))) :-
    % State the fact: increases(X, Y).
    increases(X, Y).
% Define a clause for 'mentova qualitative': succeed when the following conditions hold.
mentova_qualitative(direction(X, Y), decreases, just(decreases(X, Y))) :-
    % State the fact: decreases(X, Y).
    decreases(X, Y).
% Define a clause for 'mentova qualitative': succeed when the following conditions hold.
mentova_qualitative(direction(X, Y), no_effect, just(no_effect(X, Y))) :-
    % State the fact: no effect(X, Y).
    no_effect(X, Y).

% Chain: X → Y → Z: what is the direction X has on Z (two hops)?
% State a fact for 'mentova qualitative' with the arguments listed below.
mentova_qualitative(chain(X, Y, Z), Direction,
                    % Continue the multi-line expression started above.
                    just(chain(X, via(Y), Z, inferred(Direction)))) :-
    % Check that '( increases(X, Y) -> S1' is unifiable with 'pos ; decreases(X, Y) -> S1 = neg ; S1 = zero )'.
    ( increases(X, Y) -> S1 = pos ; decreases(X, Y) -> S1 = neg ; S1 = zero ),
    % Check that '( increases(Y, Z) -> S2' is unifiable with 'pos ; decreases(Y, Z) -> S2 = neg ; S2 = zero )'.
    ( increases(Y, Z) -> S2 = pos ; decreases(Y, Z) -> S2 = neg ; S2 = zero ),
    % State a fact for 'qmult' with the arguments listed below.
    qmult(S1, S2, SR),
    % Check that '( SR' is unifiable with 'pos -> Direction = increases ; SR = neg -> Direction = decreases ; Direction = no_effect )'.
    ( SR = pos -> Direction = increases ; SR = neg -> Direction = decreases ; Direction = no_effect ).

% Compare: if X increases, which of A and B benefits more?
% State a fact for 'mentova qualitative' with the arguments listed below.
mentova_qualitative(compare_effect(X, A, B), Winner,
                    % Continue the multi-line expression started above.
                    just(compare_effect(X, A, B, winner(Winner)))) :-
    % Check that '( increases(X, A), increases(X, B) -> Winner' is unifiable with 'both'.
    ( increases(X, A), increases(X, B) -> Winner = both
    % Otherwise (else branch), perform the following action.
    ; increases(X, A), \+ increases(X, B) -> Winner = A
    % Otherwise (else branch), perform the following action.
    ; increases(X, B), \+ increases(X, A) -> Winner = B
    % Otherwise (else branch), perform the following action.
    ; Winner = neither
    % Close the expression opened above.
    ).

% Predict: if X goes up, what changes?
% State a fact for 'mentova qualitative' with the arguments listed below.
mentova_qualitative(predict(X, Direction), Changes,
                    % Continue the multi-line expression started above.
                    just(predict(X, Direction, changes(Changes)))) :-
    % Check that '( Direction' is unifiable with 'up ->'.
    ( Direction = up ->
        % Continue the multi-line expression started above.
        findall(E-increases, increases(X, E), RI),
        % Continue the multi-line expression started above.
        findall(E-decreases, decreases(X, E), RD),
        % Continue the multi-line expression started above.
        append(RI, RD, Changes0),
        % Continue the multi-line expression started above.
        ( Changes0 = [] -> Changes = [none] ; Changes = Changes0 )
    % Supply ';' as the next argument to the expression above.
    ;
        % Continue the multi-line expression started above.
        findall(E-decreases, increases(X, E), RI),
        % Continue the multi-line expression started above.
        findall(E-increases, decreases(X, E), RD),
        % Continue the multi-line expression started above.
        append(RI, RD, Changes0),
        % Continue the multi-line expression started above.
        ( Changes0 = [] -> Changes = [none] ; Changes = Changes0 )
    % Close the expression opened above.
    ).
