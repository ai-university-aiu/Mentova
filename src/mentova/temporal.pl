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

% Declare this file as the 'temporal' module and list its exported predicates.
:- module(temporal, [
    % Supply 'mentova_temporal/3' as the next argument to the expression above.
    mentova_temporal/3
% Close the expression opened above.
]).

% Import [member/2, nth1/3, append/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, nth1/3, append/3]).

% ---------------------------------------------------------------------------
% Temporal facts: events with timestamps (ticks)
% ---------------------------------------------------------------------------

% State the fact: event time(wake_up,        6).
event_time(wake_up,        6).
% State the fact: event time(breakfast,      7).
event_time(breakfast,      7).
% State the fact: event time(commute,        8).
event_time(commute,        8).
% State the fact: event time(work_starts,    9).
event_time(work_starts,    9).
% State the fact: event time(lunch,         12).
event_time(lunch,         12).
% State the fact: event time(work_ends,     17).
event_time(work_ends,     17).
% State the fact: event time(dinner,        19).
event_time(dinner,        19).
% State the fact: event time(sleep,         22).
event_time(sleep,         22).

% Duration in hours
% State the fact: event duration(sleep,        8).
event_duration(sleep,        8).
% State the fact: event duration(breakfast,    1).
event_duration(breakfast,    1).
% State the fact: event duration(commute,      1).
event_duration(commute,      1).
% State a fact for 'event duration' with the arguments listed below.
event_duration(work_starts,  8).  % work period
% State the fact: event duration(lunch,        1).
event_duration(lunch,        1).
% State the fact: event duration(dinner,       1).
event_duration(dinner,       1).

% Causal / narrative sequence
% State the fact: sequence([wake_up, breakfast, commute, work_starts, lunch, work_ends, dinner, sleep]).
sequence([wake_up, breakfast, commute, work_starts, lunch, work_ends, dinner, sleep]).

% ---------------------------------------------------------------------------
% Temporal relations
% ---------------------------------------------------------------------------

% Define a clause for 'happens before': succeed when the following conditions hold.
happens_before(E1, E2) :-
    % State a fact for 'event time' with the arguments listed below.
    event_time(E1, T1),
    % State a fact for 'event time' with the arguments listed below.
    event_time(E2, T2),
    % Check that 'T1' is less than 'T2'.
    T1 < T2.

% Define a clause for 'happens after': succeed when the following conditions hold.
happens_after(E1, E2) :- happens_before(E2, E1).

% Define a clause for 'happens between': succeed when the following conditions hold.
happens_between(E, E1, E2) :-
    % State a fact for 'event time' with the arguments listed below.
    event_time(E,  T),
    % State a fact for 'event time' with the arguments listed below.
    event_time(E1, T1),
    % State a fact for 'event time' with the arguments listed below.
    event_time(E2, T2),
    % Check that 'T' is greater than 'T1, T < T2'.
    T > T1, T < T2.

% Define a clause for 'time gap': succeed when the following conditions hold.
time_gap(E1, E2, Gap) :-
    % State a fact for 'event time' with the arguments listed below.
    event_time(E1, T1),
    % State a fact for 'event time' with the arguments listed below.
    event_time(E2, T2),
    % Evaluate the arithmetic expression 'abs(T2 - T1)' and bind the result to 'Gap'.
    Gap is abs(T2 - T1).

% Events in a time window
% Define a clause for 'events in window': succeed when the following conditions hold.
events_in_window(Start, End, Events) :-
    % Check that 'findall(E-T, (event_time(E, T), T' is greater than or equal to 'Start, T =< End), Events)'.
    findall(E-T, (event_time(E, T), T >= Start, T =< End), Events).

% ---------------------------------------------------------------------------
% mentova_temporal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova temporal' with the arguments listed below.
mentova_temporal(before(E1, E2), Answer,
                  % Continue the multi-line expression started above.
                  just(temporal(E1, before, E2, t1(T1), t2(T2), result(Answer)))) :-
    % State a fact for 'event time' with the arguments listed below.
    event_time(E1, T1), event_time(E2, T2),
    % Check that '( T1' is less than 'T2 -> Answer = yes ; Answer = no )'.
    ( T1 < T2 -> Answer = yes ; Answer = no ).

% State a fact for 'mentova temporal' with the arguments listed below.
mentova_temporal(after(E1, E2), Answer,
                  % Continue the multi-line expression started above.
                  just(temporal(E1, after, E2, t1(T1), t2(T2), result(Answer)))) :-
    % State a fact for 'event time' with the arguments listed below.
    event_time(E1, T1), event_time(E2, T2),
    % Check that '( T1' is greater than 'T2 -> Answer = yes ; Answer = no )'.
    ( T1 > T2 -> Answer = yes ; Answer = no ).

% State a fact for 'mentova temporal' with the arguments listed below.
mentova_temporal(between(E, E1, E2), Answer,
                  % Continue the multi-line expression started above.
                  just(temporal(E, between, E1, E2, result(Answer)))) :-
    % State a fact for 'event time' with the arguments listed below.
    event_time(E, T), event_time(E1, T1), event_time(E2, T2),
    % Check that '( T' is greater than 'T1, T < T2 -> Answer = yes ; Answer = no )'.
    ( T > T1, T < T2 -> Answer = yes ; Answer = no ).

% State a fact for 'mentova temporal' with the arguments listed below.
mentova_temporal(gap(E1, E2), Gap,
                  % Continue the multi-line expression started above.
                  just(temporal_gap(E1, E2, hours(Gap)))) :-
    % State the fact: time gap(E1, E2, Gap).
    time_gap(E1, E2, Gap).

% State a fact for 'mentova temporal' with the arguments listed below.
mentova_temporal(duration(E), D,
                  % Continue the multi-line expression started above.
                  just(event_duration(E, hours(D)))) :-
    % State the fact: event duration(E, D).
    event_duration(E, D).

% State a fact for 'mentova temporal' with the arguments listed below.
mentova_temporal(when(E), Time,
                  % Continue the multi-line expression started above.
                  just(event_time(E, tick(Time)))) :-
    % State the fact: event time(E, Time).
    event_time(E, Time).

% State a fact for 'mentova temporal' with the arguments listed below.
mentova_temporal(sequence_order(E1, E2), Order,
                  % Continue the multi-line expression started above.
                  just(sequence(E1, Order, E2))) :-
    % State a fact for 'sequence' with the arguments listed below.
    sequence(Seq),
    % Retrieve the element at the specified one-based position from the list.
    nth1(I1, Seq, E1),
    % Retrieve the element at the specified one-based position from the list.
    nth1(I2, Seq, E2),
    % Check that '( I1 < I2 -> Order = before ; I1' is greater than 'I2 -> Order = after ; Order = same )'.
    ( I1 < I2 -> Order = before ; I1 > I2 -> Order = after ; Order = same ).

% State a fact for 'mentova temporal' with the arguments listed below.
mentova_temporal(window(Start, End), Events,
                  % Continue the multi-line expression started above.
                  just(events_in_window(Start, End, Events))) :-
    % State the fact: events in window(Start, End, Events).
    events_in_window(Start, End, Events).
