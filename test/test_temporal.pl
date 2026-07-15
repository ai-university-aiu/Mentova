/*  Mentova — Temporal Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/temporal.pl, which exports
    mentova_temporal/3 — an event-ordering and duration reasoner over a
    built-in day-timeline knowledge base. Each query form (before, after,
    between, gap, duration, when, sequence_order, window) returns a result
    together with a glass-box justification term. Every expected value below
    is computed by hand from the module's baked-in facts:

      event_time:  wake_up 6, breakfast 7, commute 8, work_starts 9,
                   lunch 12, work_ends 17, dinner 19, sleep 22
      event_duration: sleep 8, breakfast 1, commute 1, work_starts 8,
                      lunch 1, dinner 1
      sequence: [wake_up, breakfast, commute, work_starts, lunch,
                 work_ends, dinner, sleep]

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_temporal.pl
*/

% Declare this file as a test module with no exports.
:- module(test_temporal, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(temporal)).

% Open the test block for the temporal module.
:- begin_tests(temporal).

% AC-TEMPORAL-001: before answers yes when the first event's tick precedes the second's.
test(before_yes_with_justified_ticks) :-
    % Ask whether wake_up (tick 6) happens before lunch (tick 12).
    mentova_temporal(before(wake_up, lunch), Answer, Justification),
    % Six precedes twelve, so the answer is yes.
    assertion(Answer == yes),
    % The justification carries both ticks and the yes verdict in its documented shape.
    assertion(Justification == just(temporal(wake_up, before, lunch, t1(6), t2(12), result(yes)))).

% AC-TEMPORAL-002: before answers no when the first event's tick does not precede the second's.
test(before_no_when_reversed) :-
    % Ask whether lunch (tick 12) happens before wake_up (tick 6).
    mentova_temporal(before(lunch, wake_up), Answer, _Justification),
    % Twelve does not precede six, so the answer is no.
    assertion(Answer == no).

% AC-TEMPORAL-003: after answers yes when the first event's tick follows the second's.
test(after_yes_with_justified_ticks) :-
    % Ask whether dinner (tick 19) happens after breakfast (tick 7).
    mentova_temporal(after(dinner, breakfast), Answer, Justification),
    % Nineteen follows seven, so the answer is yes.
    assertion(Answer == yes),
    % The justification carries both ticks and the yes verdict in its documented shape.
    assertion(Justification == just(temporal(dinner, after, breakfast, t1(19), t2(7), result(yes)))).

% AC-TEMPORAL-004: between answers yes only when the middle event's tick lies strictly inside the bounds.
test(between_respects_open_interval) :-
    % work_starts (tick 9) sits strictly between wake_up (6) and lunch (12).
    mentova_temporal(between(work_starts, wake_up, lunch), Inside, _),
    % Nine is greater than six and less than twelve, so it lies between.
    assertion(Inside == yes),
    % sleep (tick 22) sits outside the same wake_up-to-lunch window.
    mentova_temporal(between(sleep, wake_up, lunch), Outside, _),
    % Twenty-two exceeds twelve, so it does not lie between.
    assertion(Outside == no).

% AC-TEMPORAL-005: gap returns the absolute tick distance between two events.
test(gap_is_absolute_tick_distance) :-
    % Ask for the gap between wake_up (tick 6) and sleep (tick 22).
    mentova_temporal(gap(wake_up, sleep), Gap, Justification),
    % The absolute difference of six and twenty-two is sixteen hours.
    assertion(Gap =:= 16),
    % The justification reports the same sixteen-hour gap in its documented shape.
    assertion(Justification == just(temporal_gap(wake_up, sleep, hours(16)))),
    % The gap is symmetric, so reversing the arguments gives the same distance.
    mentova_temporal(gap(sleep, wake_up), ReverseGap, _),
    % Both orderings report sixteen hours.
    assertion(ReverseGap =:= 16).

% AC-TEMPORAL-006: duration returns the stored length of an event.
test(duration_reads_event_length) :-
    % Ask for the duration of sleep, which the knowledge base records as eight hours.
    mentova_temporal(duration(sleep), SleepHours, Justification),
    % The stored sleep duration is eight hours.
    assertion(SleepHours =:= 8),
    % The justification reports the same eight-hour duration in its documented shape.
    assertion(Justification == just(event_duration(sleep, hours(8)))),
    % Ask for the duration of lunch, which the knowledge base records as one hour.
    mentova_temporal(duration(lunch), LunchHours, _),
    % The stored lunch duration is one hour.
    assertion(LunchHours =:= 1).

% AC-TEMPORAL-007: when returns the tick at which an event occurs.
test(when_reads_event_tick) :-
    % Ask when lunch occurs; the knowledge base places it at tick twelve.
    mentova_temporal(when(lunch), Time, Justification),
    % The reported tick for lunch is twelve.
    assertion(Time =:= 12),
    % The justification wraps the same tick in its documented shape.
    assertion(Justification == just(event_time(lunch, tick(12)))).

% AC-TEMPORAL-008: sequence_order reports the narrative order of two events in the day's sequence.
test(sequence_order_before_after_same) :-
    % breakfast precedes dinner in the stored sequence (positions two and seven).
    once(mentova_temporal(sequence_order(breakfast, dinner), Forward, _)),
    % Position two comes before position seven, so the order is before.
    assertion(Forward == before),
    % Reversing the pair swaps the reported order.
    once(mentova_temporal(sequence_order(dinner, breakfast), Backward, _)),
    % Position seven comes after position two, so the order is after.
    assertion(Backward == after),
    % An event compared with itself occupies a single position.
    once(mentova_temporal(sequence_order(lunch, lunch), Self, _)),
    % One position against itself is neither before nor after, so the order is same.
    assertion(Self == same).

% AC-TEMPORAL-009: window collects every event whose tick falls in the inclusive range.
test(window_collects_inclusive_range) :-
    % Ask for all events between tick six and tick nine inclusive.
    mentova_temporal(window(6, 9), Events, _),
    % The four morning events fall in that inclusive window, in timeline order.
    assertion(Events == [wake_up-6, breakfast-7, commute-8, work_starts-9]).

% Close the test block for the temporal module.
:- end_tests(temporal).
