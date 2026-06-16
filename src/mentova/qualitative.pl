/*  Mentova — Rung 16: Qualitative Reasoning Module

    Predicts direction of change without numbers.
    Uses qualitative calculus: quantities are +, 0, -.
    Relations: increases(X,Y), decreases(X,Y), no_effect(X,Y).

    Pass criterion: rising/falling/more/less is correct.
*/

:- module(qualitative, [
    mentova_qualitative/3
]).

:- use_module('../../knowledge/small_world', [causes/2]).
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Qualitative causal relations
% increases(Cause, Effect): more of Cause → more of Effect
% decreases(Cause, Effect): more of Cause → less of Effect
% ---------------------------------------------------------------------------

increases(temperature,   evaporation).
increases(temperature,   pressure).
increases(rainfall,      flood_risk).
increases(exercise,      fitness).
increases(exercise,      fatigue).
increases(sunlight,      plant_growth).
increases(sunlight,      temperature).
increases(food_supply,   population).
increases(population,    waste).
increases(rainfall,      soil_moisture).
increases(soil_moisture, plant_growth).

decreases(temperature,   ice_thickness).
decreases(exercise,      weight).
decreases(rainfall,      drought_risk).
decreases(food_supply,   hunger).
decreases(antibiotics,   bacteria_count).
decreases(sunscreen,     sunburn_risk).

no_effect(temperature,   gravity).
no_effect(colour,        mass).

% ---------------------------------------------------------------------------
% Qualitative multiplication table:
% Q(A*B): sign(A)*sign(B) -> sign(product)
% Signs: pos, zero, neg
% ---------------------------------------------------------------------------

qmult(pos, pos, pos).
qmult(pos, neg, neg).
qmult(neg, pos, neg).
qmult(neg, neg, pos).
qmult(zero, _, zero).
qmult(_, zero, zero).

% ---------------------------------------------------------------------------
% mentova_qualitative(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Direction: does increasing X increase or decrease Y?
mentova_qualitative(direction(X, Y), increases, just(increases(X, Y))) :-
    increases(X, Y).
mentova_qualitative(direction(X, Y), decreases, just(decreases(X, Y))) :-
    decreases(X, Y).
mentova_qualitative(direction(X, Y), no_effect, just(no_effect(X, Y))) :-
    no_effect(X, Y).

% Chain: X → Y → Z: what is the direction X has on Z (two hops)?
mentova_qualitative(chain(X, Y, Z), Direction,
                    just(chain(X, via(Y), Z, inferred(Direction)))) :-
    ( increases(X, Y) -> S1 = pos ; decreases(X, Y) -> S1 = neg ; S1 = zero ),
    ( increases(Y, Z) -> S2 = pos ; decreases(Y, Z) -> S2 = neg ; S2 = zero ),
    qmult(S1, S2, SR),
    ( SR = pos -> Direction = increases ; SR = neg -> Direction = decreases ; Direction = no_effect ).

% Compare: if X increases, which of A and B benefits more?
mentova_qualitative(compare_effect(X, A, B), Winner,
                    just(compare_effect(X, A, B, winner(Winner)))) :-
    ( increases(X, A), increases(X, B) -> Winner = both
    ; increases(X, A), \+ increases(X, B) -> Winner = A
    ; increases(X, B), \+ increases(X, A) -> Winner = B
    ; Winner = neither
    ).

% Predict: if X goes up, what changes?
mentova_qualitative(predict(X, Direction), Changes,
                    just(predict(X, Direction, changes(Changes)))) :-
    ( Direction = up ->
        findall(E-increases, increases(X, E), RI),
        findall(E-decreases, decreases(X, E), RD),
        append(RI, RD, Changes0),
        ( Changes0 = [] -> Changes = [none] ; Changes = Changes0 )
    ;
        findall(E-decreases, increases(X, E), RI),
        findall(E-increases, decreases(X, E), RD),
        append(RI, RD, Changes0),
        ( Changes0 = [] -> Changes = [none] ; Changes = Changes0 )
    ).
