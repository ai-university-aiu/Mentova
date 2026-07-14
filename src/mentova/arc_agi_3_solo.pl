/*  Mentova — ARC-AGI-3_Solo sub-project

    The second of the two ARC-AGI-3 learning sub-projects. ARC-AGI-3_Solo takes
    everything the guided sessions taught - the learnings in the data lattice,
    the Causalontology relations, the human-set goal, priorities, and hazards,
    the Jacobian Space (J-Space), and the shared state-exploration graph
    (state_graph) that Guided built - and runs the ARC-AGI-3 game environments
    with no direct human direction. It plays moment to moment, and each attempt
    ends in a date-and-time-stamped plain-text report in the solo attempts
    directory.

    This module is the named face of that sub-project. Its predicates delegate
    to the shared mentova_arc_chat backend so that ARC-AGI-3_Solo reads exactly
    the same learnings ARC-AGI-3_Guided wrote, and s3_learnings/1 exposes those
    learnings for inspection.

    Predicates:
      s3_start/0       -- begin a fresh solo attempt on the selected game
      s3_tick/1        -- -Telemetry   (advance one solo step, moment to moment)
      s3_report/2      -- -File, -Path (write a solo attempt report)
      s3_attempts/1    -- -Files       (the solo report filenames, newest first)
      s3_mode/1        -- -Mode        (the active mode)
      s3_learnings/1   -- -Learnings   (all shared learnings, read and used)
*/

% Declare the Solo sub-project module and its exports.
:- module(arc_agi_3_solo, [
    % s3_start/0: begin a fresh solo attempt.
    s3_start/0,
    % s3_tick/1: advance one solo step, with telemetry.
    s3_tick/1,
    % s3_report/2: write a solo attempt report.
    s3_report/2,
    % s3_attempts/1: the solo report filenames, newest first.
    s3_attempts/1,
    % s3_mode/1: the active mode.
    s3_mode/1,
    % s3_learnings/1: all shared learnings, read and used.
    s3_learnings/1,
    % s3_graph/1: the shared state-graph exploration map.
    s3_graph/1
]).

% Load the shared ARC-AGI-3 chat backend both sub-projects operate on.
:- use_module('mentova_arc_chat',
    [ma_restart/2, ma_solo_tick/1, ma_solo_report/2,
     ma_attempts_list/1, ma_mode/1, ma_learnings/1, ma_set_mode/1,
     ma_graph_stats/1]).

% Define s3_start: begin a fresh solo attempt on the selected environment.
s3_start :-
    % Ensure the solo mode is active.
    ma_set_mode(solo),
    % Restart in solo mode, which begins a fresh attempt from the learnings.
    ma_restart(_Mode, _Reply).

% Define s3_tick: advance the solo run one step, with telemetry.
s3_tick(Telemetry) :-
    % The shared solo telemetry step.
    ma_solo_tick(Telemetry).

% Define s3_report: write a solo attempt report and return its filename.
s3_report(File, Path) :-
    % The shared report writer.
    ma_solo_report(File, Path).

% Define s3_attempts: the solo report filenames, newest first.
s3_attempts(Files) :-
    % The shared attempts listing.
    ma_attempts_list(Files).

% Define s3_mode: the active mode.
s3_mode(Mode) :-
    % The shared mode.
    ma_mode(Mode).

% Define s3_learnings: all shared learnings, read and used by this sub-project.
s3_learnings(Learnings) :-
    % The same shared learnings ARC-AGI-3_Guided wrote.
    ma_learnings(Learnings).

% Define s3_graph: the shared state-graph exploration map (state_graph). Solo reads
% the very same graph Guided built as the human taught, and adds to it as it
% plays unaided — one store, shared by both sub-projects.
s3_graph(Graph) :-
    % The shared graph statistics.
    ma_graph_stats(Graph).
