/*  Mentova — Rung 23: Temporal Reasoning Module

    Answers ordering and duration questions.
    Pass criterion: before-and-after is correct.

    Supports:
      before(E1, E2)     — E1 happens before E2
      after(E1, E2)      — E1 happens after E2
      duration(E, D)     — duration of event E
      sequence(...)      — ordered event sequence
      between(E, E1, E2) — E is temporally between E1 and E2
*/

:- module(temporal, [
    mentova_temporal/3
]).

:- use_module(library(lists), [member/2, nth1/3, append/3]).

% ---------------------------------------------------------------------------
% Temporal facts: events with timestamps (ticks)
% ---------------------------------------------------------------------------

event_time(wake_up,        6).
event_time(breakfast,      7).
event_time(commute,        8).
event_time(work_starts,    9).
event_time(lunch,         12).
event_time(work_ends,     17).
event_time(dinner,        19).
event_time(sleep,         22).

% Duration in hours
event_duration(sleep,        8).
event_duration(breakfast,    1).
event_duration(commute,      1).
event_duration(work_starts,  8).  % work period
event_duration(lunch,        1).
event_duration(dinner,       1).

% Causal / narrative sequence
sequence([wake_up, breakfast, commute, work_starts, lunch, work_ends, dinner, sleep]).

% ---------------------------------------------------------------------------
% Temporal relations
% ---------------------------------------------------------------------------

happens_before(E1, E2) :-
    event_time(E1, T1),
    event_time(E2, T2),
    T1 < T2.

happens_after(E1, E2) :- happens_before(E2, E1).

happens_between(E, E1, E2) :-
    event_time(E,  T),
    event_time(E1, T1),
    event_time(E2, T2),
    T > T1, T < T2.

time_gap(E1, E2, Gap) :-
    event_time(E1, T1),
    event_time(E2, T2),
    Gap is abs(T2 - T1).

% Events in a time window
events_in_window(Start, End, Events) :-
    findall(E-T, (event_time(E, T), T >= Start, T =< End), Events).

% ---------------------------------------------------------------------------
% mentova_temporal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_temporal(before(E1, E2), Answer,
                  just(temporal(E1, before, E2, t1(T1), t2(T2), result(Answer)))) :-
    event_time(E1, T1), event_time(E2, T2),
    ( T1 < T2 -> Answer = yes ; Answer = no ).

mentova_temporal(after(E1, E2), Answer,
                  just(temporal(E1, after, E2, t1(T1), t2(T2), result(Answer)))) :-
    event_time(E1, T1), event_time(E2, T2),
    ( T1 > T2 -> Answer = yes ; Answer = no ).

mentova_temporal(between(E, E1, E2), Answer,
                  just(temporal(E, between, E1, E2, result(Answer)))) :-
    event_time(E, T), event_time(E1, T1), event_time(E2, T2),
    ( T > T1, T < T2 -> Answer = yes ; Answer = no ).

mentova_temporal(gap(E1, E2), Gap,
                  just(temporal_gap(E1, E2, hours(Gap)))) :-
    time_gap(E1, E2, Gap).

mentova_temporal(duration(E), D,
                  just(event_duration(E, hours(D)))) :-
    event_duration(E, D).

mentova_temporal(when(E), Time,
                  just(event_time(E, tick(Time)))) :-
    event_time(E, Time).

mentova_temporal(sequence_order(E1, E2), Order,
                  just(sequence(E1, Order, E2))) :-
    sequence(Seq),
    nth1(I1, Seq, E1),
    nth1(I2, Seq, E2),
    ( I1 < I2 -> Order = before ; I1 > I2 -> Order = after ; Order = same ).

mentova_temporal(window(Start, End), Events,
                  just(events_in_window(Start, End, Events))) :-
    events_in_window(Start, End, Events).
