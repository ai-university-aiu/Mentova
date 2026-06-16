/*  Mentova — Attention Schema Demonstration Script  (PR 42)

    Demonstrates the PrologAI Attention Schema (PR 42) integrated into Mentova.

    The demonstration:
      1. Boots Mentova (loads all 48 rungs + global workspace + attention schema).
      2. Activates the schema subscriber on the workspace broadcast channel.
      3. Seeds the APEX_MIND nexus with 5 node_facts.
      4. Runs 30 workspace cycles for AC-PR42-001.
      5. Scores schema prediction accuracy vs the chance baseline.
      6. Disables the schema and runs 5 more cycles for AC-PR42-002.
      7. Verifies workspace continues (not halted) while prediction degrades.
      8. Re-enables the schema and shows prediction resumes.
      9. Prints the full glass-box schema report.

    Usage:
        swipl -l demos/attention_schema_demo.pl -g "run_schema_demo" -t halt

    Pass criterion:
        AC-PR42-001: schema accuracy >= chance baseline after 30 cycles.
        AC-PR42-002: workspace runs 5 cycles with schema disabled;
                     prediction returns no_prediction while disabled.
*/

% Declare this file as a module so it can be loaded cleanly.
:- module(attention_schema_demo_script, [run_schema_demo/0]).

% Load standard list utilities.
:- use_module(library(lists)).
% Load Mentova — all 48 rungs, global workspace, attention schema.
:- use_module('../src/mentova/mentova').
% Load the attention schema integration directly for the demo predicates.
:- use_module('../src/mentova/attention_schema').

% Define a clause for 'run_schema_demo': boot Mentova then run the schema demonstration.
run_schema_demo :-
    % Boot Mentova (enrolls bodies, loads constitution, activates workspace).
    mentova_boot,
    % Run the full attention schema demonstration.
    schema_demo.
