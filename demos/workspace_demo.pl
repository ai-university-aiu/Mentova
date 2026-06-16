/*  Mentova — Global Workspace Demonstration Script

    Demonstrates the PrologAI Global Workspace Cycle (PR 18) and
    Attention Economy (PR 32) integrated into Mentova.

    The demonstration:
      1. Boots Mentova.
      2. Opens the APEX_MIND nexus and installs the attention arbiter.
      3. Seeds 5 node_facts: one objective, two cognition facts, two emotion facts.
      4. Verifies AC-PR18-001: the higher-salience coalition wins.
      5. Runs 5 workspace cycles, printing each broadcast winner with salience.
      6. Reports attention economy metrics after wages and rent.
      7. Checks for habituation (AC-PR18-002): repeated winners get penalized.
      8. Prints the glass-box workspace report.

    Usage:
        swipl -l demos/workspace_demo.pl -g "run_workspace_demo" -t halt

    Pass criterion:
        AC-PR18-001: coalition_high (salience 0.9) beats coalition_low (0.4).
        At least one workspace cycle runs and broadcasts a winner.
        Glass-box report returned with cycles_run, broadcast_history, attention_economy.
*/

% Declare this file as a module so it can be loaded cleanly.
:- module(workspace_demo_script, [run_workspace_demo/0]).

% Load standard list utilities.
:- use_module(library(lists)).
% Load Mentova bootstrap — this loads all 48 reasoning modules and the global workspace.
:- use_module('../src/mentova/mentova').
% Load the global workspace integration directly for the demo predicates.
:- use_module('../src/mentova/global_workspace').

% Define a clause for 'run_workspace_demo': boot Mentova and run the workspace demonstration.
run_workspace_demo :-
    % Boot Mentova to load constitution, bodies, and the 48-rung ladder.
    mentova_boot,
    % Run the global workspace demonstration.
    workspace_demo.
