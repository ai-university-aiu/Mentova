/*  Mentova — ARC-AGI-1 Full Benchmark Demo  (Acc_71)

    Entry point for the full ARC-AGI-1 benchmark run.

    Loads all 400 public training tasks from data/arc_agi_1/arc_tasks.pl
    and runs them through Mentova's inductive reasoning engine.

    Run:
        swipl -l demos/arc_agi_benchmark.pl \
              -g "run_arc_agi_benchmark" -t halt
*/

% Declare this file as the arc_agi_benchmark module.
:- module(arc_agi_benchmark, [run_arc_agi_benchmark/0]).

% Register the PrologAI library path so packs can be found.
:- initialization(
    asserta(file_search_path(library, '/home/ccaitwo/PrologAI/packs/assessment/prolog'))
, now).
% Register the Mentova source path.
:- initialization(
    asserta(file_search_path(library, '/home/ccaitwo/Mentova/src/mentova'))
, now).

% Load the Mentova top-level interface.
:- use_module('../src/mentova/mentova').

% Load the ARC-AGI-1 task data (400 tasks as Prolog facts) into the global user module.
:- use_module('/home/ccaitwo/Mentova/data/arc_agi_1/arc_tasks.pl', [arc_agi_task/4]).

% Load the benchmark runner module.
:- use_module('../src/mentova/games/arc_benchmark').

% Define run_arc_agi_benchmark/0: the main entry point.
run_arc_agi_benchmark :-
    % Boot Mentova.
    mentova_boot,
    % Run the full benchmark and print the report.
    arc_benchmark_print.
