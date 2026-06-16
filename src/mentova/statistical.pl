/*  Mentova — Rung 7: Statistical Reasoning Module

    Finds patterns in the observation table stored in small_world.pl.
    observation(Subject, Property, Count) gives observation counts.

    Supported analyses:
      * dominant(Subject)  — which property is most frequently observed
      * trend(Subject)     — rising/falling/stable between two properties
      * proportion(Subject, Property) — fraction of observations with property
      * most_common(Subject, Property, Pct) — top property with percentage
      * compare(S1, S2, Property) — which subject shows higher rate for property

    Pass criterion: reported trend matches the data.
*/

% Declare this file as the 'statistical' module and list its exported predicates.
:- module(statistical, [
    % Supply 'mentova_stat/3' as the next argument to the expression above.
    mentova_stat/3
% Close the expression opened above.
]).

% Import [observation/3] from the 'small_world' module.
:- use_module('../../knowledge/small_world', [observation/3]).
% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).
% Import [aggregate_all/3] from the built-in 'aggregate' library.
:- use_module(library(aggregate), [aggregate_all/3]).

% ---------------------------------------------------------------------------
% Helper: total count for a subject
% ---------------------------------------------------------------------------

% Define a clause for 'total count': succeed when the following conditions hold.
total_count(Subject, Total) :-
    % Aggregate solutions using 'sum' and bind the result to a single value.
    aggregate_all(sum(C), observation(Subject, _, C), Total).

% ---------------------------------------------------------------------------
% mentova_stat(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% proportion(Subject, Property): fraction of observations with Property
% State a fact for 'mentova stat' with the arguments listed below.
mentova_stat(proportion(Subject, Property), Proportion,
             % Continue the multi-line expression started above.
             just(proportion(Subject, Property, Count, Total, Proportion))) :-
    % State a fact for 'observation' with the arguments listed below.
    observation(Subject, Property, Count),
    % State a fact for 'total count' with the arguments listed below.
    total_count(Subject, Total),
    % Check that 'Total' is greater than '0'.
    Total > 0,
    % Evaluate the arithmetic expression 'Count / Total' and bind the result to 'Proportion'.
    Proportion is Count / Total.

% dominant(Subject): most frequently observed property
% State a fact for 'mentova stat' with the arguments listed below.
mentova_stat(dominant(Subject), dominant(Subject, BestProp, BestCount),
             % Continue the multi-line expression started above.
             just(dominant(Subject, BestProp, BestCount, out_of(Total)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(C-P, observation(Subject, P, C), Pairs),
    % Check that 'Pairs' is not unifiable with '[]'.
    Pairs \= [],
    % Sort list 'Pairs' into 'Sorted', keeping duplicates.
    msort(Pairs, Sorted),
    % Unify the second argument with the last element of list 'Sorted'.
    last(Sorted, BestCount-BestProp),
    % State the fact: total count(Subject, Total).
    total_count(Subject, Total).

% most_common(Subject): dominant property with percentage
% State a fact for 'mentova stat' with the arguments listed below.
mentova_stat(most_common(Subject), most_common(Subject, BestProp, Pct),
             % Continue the multi-line expression started above.
             just(most_common(Subject, BestProp, BestCount, total(Total), pct(Pct)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(C-P, observation(Subject, P, C), Pairs),
    % Check that 'Pairs' is not unifiable with '[]'.
    Pairs \= [],
    % Sort list 'Pairs' into 'Sorted', keeping duplicates.
    msort(Pairs, Sorted),
    % Unify the second argument with the last element of list 'Sorted'.
    last(Sorted, BestCount-BestProp),
    % State a fact for 'total count' with the arguments listed below.
    total_count(Subject, Total),
    % Check that 'Total' is greater than '0'.
    Total > 0,
    % Evaluate the arithmetic expression 'round(BestCount * 100 / Total)' and bind the result to 'Pct'.
    Pct is round(BestCount * 100 / Total).

% trend(Subject): compare two properties — which is more prevalent
% State a fact for 'mentova stat' with the arguments listed below.
mentova_stat(trend(Subject, PropA, PropB), trend(Subject, PropA, PropB, Direction),
             % Continue the multi-line expression started above.
             just(trend(Subject, PropA, CountA, PropB, CountB, Direction))) :-
    % Check that '( observation(Subject, PropA, CountA) -> true ; CountA' is unifiable with '0 )'.
    ( observation(Subject, PropA, CountA) -> true ; CountA = 0 ),
    % Check that '( observation(Subject, PropB, CountB) -> true ; CountB' is unifiable with '0 )'.
    ( observation(Subject, PropB, CountB) -> true ; CountB = 0 ),
    % Check that '( CountA' is greater than 'CountB  -> Direction = more(PropA)'.
    ( CountA > CountB  -> Direction = more(PropA)
    % Otherwise (else branch), perform the following action.
    ; CountA < CountB  -> Direction = more(PropB)
    % Otherwise (else branch), perform the following action.
    ;                     Direction = equal
    % Close the expression opened above.
    ).

% compare(S1, S2, Property): which subject has higher rate for property
% State a fact for 'mentova stat' with the arguments listed below.
mentova_stat(compare(S1, S2, Property), compare(S1, Rate1, S2, Rate2, Winner),
             % Continue the multi-line expression started above.
             just(compare(S1, Property, Rate1, S2, Property, Rate2, Winner))) :-
    % Check that '( observation(S1, Property, C1) -> true ; C1' is unifiable with '0 )'.
    ( observation(S1, Property, C1) -> true ; C1 = 0 ),
    % Check that '( observation(S2, Property, C2) -> true ; C2' is unifiable with '0 )'.
    ( observation(S2, Property, C2) -> true ; C2 = 0 ),
    % Check that 'total_count(S1, T1), T1' is greater than '0, Rate1 is C1 / T1'.
    total_count(S1, T1), T1 > 0, Rate1 is C1 / T1,
    % Check that 'total_count(S2, T2), T2' is greater than '0, Rate2 is C2 / T2'.
    total_count(S2, T2), T2 > 0, Rate2 is C2 / T2,
    % Check that '( Rate1' is greater than 'Rate2 -> Winner = S1 ; Rate1 < Rate2 -> Winner = S2 ; Winner = equal )'.
    ( Rate1 > Rate2 -> Winner = S1 ; Rate1 < Rate2 -> Winner = S2 ; Winner = equal ).

% Helper predicate — last element of list
% Define a clause for 'last': succeed when the following conditions hold.
last([X], X) :- !.
% Define a clause for 'last': succeed when the following conditions hold.
last([_|T], X) :- last(T, X).
