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

:- module(statistical, [
    mentova_stat/3
]).

:- use_module('../../knowledge/small_world', [observation/3]).
:- use_module(library(lists), [member/2]).
:- use_module(library(aggregate), [aggregate_all/3]).

% ---------------------------------------------------------------------------
% Helper: total count for a subject
% ---------------------------------------------------------------------------

total_count(Subject, Total) :-
    aggregate_all(sum(C), observation(Subject, _, C), Total).

% ---------------------------------------------------------------------------
% mentova_stat(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% proportion(Subject, Property): fraction of observations with Property
mentova_stat(proportion(Subject, Property), Proportion,
             just(proportion(Subject, Property, Count, Total, Proportion))) :-
    observation(Subject, Property, Count),
    total_count(Subject, Total),
    Total > 0,
    Proportion is Count / Total.

% dominant(Subject): most frequently observed property
mentova_stat(dominant(Subject), dominant(Subject, BestProp, BestCount),
             just(dominant(Subject, BestProp, BestCount, out_of(Total)))) :-
    findall(C-P, observation(Subject, P, C), Pairs),
    Pairs \= [],
    msort(Pairs, Sorted),
    last(Sorted, BestCount-BestProp),
    total_count(Subject, Total).

% most_common(Subject): dominant property with percentage
mentova_stat(most_common(Subject), most_common(Subject, BestProp, Pct),
             just(most_common(Subject, BestProp, BestCount, total(Total), pct(Pct)))) :-
    findall(C-P, observation(Subject, P, C), Pairs),
    Pairs \= [],
    msort(Pairs, Sorted),
    last(Sorted, BestCount-BestProp),
    total_count(Subject, Total),
    Total > 0,
    Pct is round(BestCount * 100 / Total).

% trend(Subject): compare two properties — which is more prevalent
mentova_stat(trend(Subject, PropA, PropB), trend(Subject, PropA, PropB, Direction),
             just(trend(Subject, PropA, CountA, PropB, CountB, Direction))) :-
    ( observation(Subject, PropA, CountA) -> true ; CountA = 0 ),
    ( observation(Subject, PropB, CountB) -> true ; CountB = 0 ),
    ( CountA > CountB  -> Direction = more(PropA)
    ; CountA < CountB  -> Direction = more(PropB)
    ;                     Direction = equal
    ).

% compare(S1, S2, Property): which subject has higher rate for property
mentova_stat(compare(S1, S2, Property), compare(S1, Rate1, S2, Rate2, Winner),
             just(compare(S1, Property, Rate1, S2, Property, Rate2, Winner))) :-
    ( observation(S1, Property, C1) -> true ; C1 = 0 ),
    ( observation(S2, Property, C2) -> true ; C2 = 0 ),
    total_count(S1, T1), T1 > 0, Rate1 is C1 / T1,
    total_count(S2, T2), T2 > 0, Rate2 is C2 / T2,
    ( Rate1 > Rate2 -> Winner = S1 ; Rate1 < Rate2 -> Winner = S2 ; Winner = equal ).

% Helper predicate — last element of list
last([X], X) :- !.
last([_|T], X) :- last(T, X).
