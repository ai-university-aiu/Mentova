/*  Mentova — Rung 15: Fuzzy Reasoning Module

    Answers with a degree of truth (fuzzy membership) rather than binary
    true/false. Supports:
      - Membership functions for named linguistic variables
      - Fuzzy AND (min), OR (max), NOT (1-x)
      - Defuzzification (centroid / weighted average label)

    Pass criterion: graded membership returned (e.g. "somewhat warm").
*/

:- module(fuzzy, [
    mentova_fuzzy/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Membership functions: membership(Variable, Value, LinguisticLabel, Degree)
% ---------------------------------------------------------------------------

% Temperature (°C)
fuzzy_membership(temperature, T, cold,      D) :- D is max(0.0, min(1.0, (15.0-T)/15.0)).
fuzzy_membership(temperature, T, cool,      D) :- D is max(0.0, min(1.0, 1.0 - abs(T-15.0)/10.0)).
fuzzy_membership(temperature, T, warm,      D) :- D is max(0.0, min(1.0, 1.0 - abs(T-25.0)/10.0)).
fuzzy_membership(temperature, T, hot,       D) :- D is max(0.0, min(1.0, (T-30.0)/15.0)).

% Speed (km/h)
fuzzy_membership(speed, V, slow,   D) :- D is max(0.0, min(1.0, (50.0-V)/50.0)).
fuzzy_membership(speed, V, medium, D) :- D is max(0.0, min(1.0, 1.0 - abs(V-80.0)/40.0)).
fuzzy_membership(speed, V, fast,   D) :- D is max(0.0, min(1.0, (V-100.0)/60.0)).

% Size (cm)
fuzzy_membership(size, S, small,  D) :- D is max(0.0, min(1.0, (30.0-S)/30.0)).
fuzzy_membership(size, S, medium, D) :- D is max(0.0, min(1.0, 1.0 - abs(S-60.0)/30.0)).
fuzzy_membership(size, S, large,  D) :- D is max(0.0, min(1.0, (S-80.0)/40.0)).

% ---------------------------------------------------------------------------
% Linguistic label for a degree
% ---------------------------------------------------------------------------

degree_label(D, very_high)  :- D >= 0.8.
degree_label(D, high)       :- D >= 0.6,  D < 0.8.
degree_label(D, somewhat)   :- D >= 0.4,  D < 0.6.
degree_label(D, low)        :- D >= 0.2,  D < 0.4.
degree_label(D, very_low)   :- D >= 0.0,  D < 0.2.

% ---------------------------------------------------------------------------
% mentova_fuzzy(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% membership(Variable, Value, Label): degree of Label membership
mentova_fuzzy(membership(Var, Val, Label), degree(Label, D),
              just(fuzzy_membership(Var, Val, Label, D))) :-
    fuzzy_membership(Var, Val, Label, D),
    D > 0.0.

% classify(Variable, Value): find the label with highest membership
mentova_fuzzy(classify(Var, Val), best(Label, D, Linguistic),
              just(fuzzy_classify(Var, Val, best(Label, D), modifier(Linguistic)))) :-
    findall(D-L, (fuzzy_membership(Var, Val, L, D), D > 0.0), Pairs),
    Pairs \= [],
    msort(Pairs, Sorted),
    last(Sorted, D-Label),
    degree_label(D, Linguistic).

% fuzzy_and(D1, D2): min
mentova_fuzzy(fuzzy_and(D1, D2), D, just(fuzzy_and(D1, D2, min(D)))) :-
    number(D1), number(D2),
    D is min(D1, D2).

% fuzzy_or(D1, D2): max
mentova_fuzzy(fuzzy_or(D1, D2), D, just(fuzzy_or(D1, D2, max(D)))) :-
    number(D1), number(D2),
    D is max(D1, D2).

% fuzzy_not(D): 1 - D
mentova_fuzzy(fuzzy_not(D), ND, just(fuzzy_not(D, complement(ND)))) :-
    number(D),
    ND is 1.0 - D.

% Helper last/2
last([X], X) :- !.
last([_|T], X) :- last(T, X).
