% ARC-AGI-2 Public Evaluation Tasks — populated by tools/arc_agi2_to_prolog.py
% when JSON task files are downloaded to this directory.
% Format: arc2_task(TaskId, TrainingPairs, TestInput, TestOutput).
% TaskId: quoted atom (e.g. '00576224').
% TrainingPairs: list of pair(InputGrid, OutputGrid) terms.
% TestInput: one grid (2D list of integer color values 0-9).
% TestOutput: one grid (2D list of integer color values 0-9).

% Declare the module and export arc2_task/4.
:- module(arc_tasks_2, [arc2_task/4]).

% Allow arc2_task/4 facts to appear at non-consecutive positions in the file.
:- discontiguous arc2_task/4.

% ---------------------------------------------------------------------------
% HOW TO POPULATE THIS FILE
% ---------------------------------------------------------------------------
% 1. Download the ARC-AGI-2 public evaluation set JSON files.
% 2. Place them in /home/ccaitwo/Mentova/data/arc_agi_2/tasks/
% 3. Run: python3 tools/arc_agi2_to_prolog.py
%    to generate arc2_task/4 facts and append them here.
% ---------------------------------------------------------------------------
% EXAMPLE STUB (illustrates the format; not a real task):
%
% arc2_task('example_task_id',
%     [pair([[0,1],[1,0]], [[1,0],[0,1]]),
%      pair([[0,2],[2,0]], [[2,0],[0,2]])],
%     [[0,3],[3,0]],
%     [[3,0],[0,3]]).
% ---------------------------------------------------------------------------
