/*  Mentova — Rung 15: Fuzzy Reasoning Module

    Answers with a degree of truth (fuzzy membership) rather than binary
    true/false. Supports:
      - Membership functions for named linguistic variables
      - Fuzzy AND (min), OR (max), NOT (1-x)
      - Defuzzification (centroid / weighted average label)

    Pass criterion: graded membership returned (e.g. "somewhat warm").
*/

% Declare this file as the 'fuzzy' module and list its exported predicates.
:- module(fuzzy, [
    % Supply 'mentova_fuzzy/3' as the next argument to the expression above.
    mentova_fuzzy/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Membership functions: membership(Variable, Value, LinguisticLabel, Degree)
% ---------------------------------------------------------------------------

% Temperature (°C)
% Define a clause for 'fuzzy membership': succeed when the following conditions hold.
fuzzy_membership(temperature, T, cold,      D) :- D is max(0.0, min(1.0, (15.0-T)/15.0)).
% Define a clause for 'fuzzy membership': succeed when the following conditions hold.
fuzzy_membership(temperature, T, cool,      D) :- D is max(0.0, min(1.0, 1.0 - abs(T-15.0)/10.0)).
% Define a clause for 'fuzzy membership': succeed when the following conditions hold.
fuzzy_membership(temperature, T, warm,      D) :- D is max(0.0, min(1.0, 1.0 - abs(T-25.0)/10.0)).
% Define a clause for 'fuzzy membership': succeed when the following conditions hold.
fuzzy_membership(temperature, T, hot,       D) :- D is max(0.0, min(1.0, (T-30.0)/15.0)).

% Speed (km/h)
% Define a clause for 'fuzzy membership': succeed when the following conditions hold.
fuzzy_membership(speed, V, slow,   D) :- D is max(0.0, min(1.0, (50.0-V)/50.0)).
% Define a clause for 'fuzzy membership': succeed when the following conditions hold.
fuzzy_membership(speed, V, medium, D) :- D is max(0.0, min(1.0, 1.0 - abs(V-80.0)/40.0)).
% Define a clause for 'fuzzy membership': succeed when the following conditions hold.
fuzzy_membership(speed, V, fast,   D) :- D is max(0.0, min(1.0, (V-100.0)/60.0)).

% Size (cm)
% Define a clause for 'fuzzy membership': succeed when the following conditions hold.
fuzzy_membership(size, S, small,  D) :- D is max(0.0, min(1.0, (30.0-S)/30.0)).
% Define a clause for 'fuzzy membership': succeed when the following conditions hold.
fuzzy_membership(size, S, medium, D) :- D is max(0.0, min(1.0, 1.0 - abs(S-60.0)/30.0)).
% Define a clause for 'fuzzy membership': succeed when the following conditions hold.
fuzzy_membership(size, S, large,  D) :- D is max(0.0, min(1.0, (S-80.0)/40.0)).

% ---------------------------------------------------------------------------
% Linguistic label for a degree
% ---------------------------------------------------------------------------

% Check that 'degree_label(D, very_high)  :- D' is greater than or equal to '0.8'.
degree_label(D, very_high)  :- D >= 0.8.
% Check that 'degree_label(D, high)       :- D' is greater than or equal to '0.6,  D < 0.8'.
degree_label(D, high)       :- D >= 0.6,  D < 0.8.
% Check that 'degree_label(D, somewhat)   :- D' is greater than or equal to '0.4,  D < 0.6'.
degree_label(D, somewhat)   :- D >= 0.4,  D < 0.6.
% Check that 'degree_label(D, low)        :- D' is greater than or equal to '0.2,  D < 0.4'.
degree_label(D, low)        :- D >= 0.2,  D < 0.4.
% Check that 'degree_label(D, very_low)   :- D' is greater than or equal to '0.0,  D < 0.2'.
degree_label(D, very_low)   :- D >= 0.0,  D < 0.2.

% ---------------------------------------------------------------------------
% mentova_fuzzy(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% membership(Variable, Value, Label): degree of Label membership
% State a fact for 'mentova fuzzy' with the arguments listed below.
mentova_fuzzy(membership(Var, Val, Label), degree(Label, D),
              % Continue the multi-line expression started above.
              just(fuzzy_membership(Var, Val, Label, D))) :-
    % State a fact for 'fuzzy membership' with the arguments listed below.
    fuzzy_membership(Var, Val, Label, D),
    % Check that 'D' is greater than '0.0'.
    D > 0.0.

% classify(Variable, Value): find the label with highest membership
% State a fact for 'mentova fuzzy' with the arguments listed below.
mentova_fuzzy(classify(Var, Val), best(Label, D, Linguistic),
              % Continue the multi-line expression started above.
              just(fuzzy_classify(Var, Val, best(Label, D), modifier(Linguistic)))) :-
    % Check that 'findall(D-L, (fuzzy_membership(Var, Val, L, D), D' is greater than '0.0), Pairs)'.
    findall(D-L, (fuzzy_membership(Var, Val, L, D), D > 0.0), Pairs),
    % Check that 'Pairs' is not unifiable with '[]'.
    Pairs \= [],
    % Sort list 'Pairs' into 'Sorted', keeping duplicates.
    msort(Pairs, Sorted),
    % Unify the second argument with the last element of list 'Sorted'.
    last(Sorted, D-Label),
    % State the fact: degree label(D, Linguistic).
    degree_label(D, Linguistic).

% fuzzy_and(D1, D2): min
% Define a clause for 'mentova fuzzy': succeed when the following conditions hold.
mentova_fuzzy(fuzzy_and(D1, D2), D, just(fuzzy_and(D1, D2, min(D)))) :-
    % State a fact for 'number' with the arguments listed below.
    number(D1), number(D2),
    % Evaluate the arithmetic expression 'min(D1, D2)' and bind the result to 'D'.
    D is min(D1, D2).

% fuzzy_or(D1, D2): max
% Define a clause for 'mentova fuzzy': succeed when the following conditions hold.
mentova_fuzzy(fuzzy_or(D1, D2), D, just(fuzzy_or(D1, D2, max(D)))) :-
    % State a fact for 'number' with the arguments listed below.
    number(D1), number(D2),
    % Evaluate the arithmetic expression 'max(D1, D2)' and bind the result to 'D'.
    D is max(D1, D2).

% fuzzy_not(D): 1 - D
% Define a clause for 'mentova fuzzy': succeed when the following conditions hold.
mentova_fuzzy(fuzzy_not(D), ND, just(fuzzy_not(D, complement(ND)))) :-
    % State a fact for 'number' with the arguments listed below.
    number(D),
    % Evaluate the arithmetic expression '1.0 - D' and bind the result to 'ND'.
    ND is 1.0 - D.

% Helper last/2
% Define a clause for 'last': succeed when the following conditions hold.
last([X], X) :- !.
% Define a clause for 'last': succeed when the following conditions hold.
last([_|T], X) :- last(T, X).
