/*  Mentova — Track A Demonstration Script

    Runs the complete Track A: Transparent Reasoning Assistant demonstration.

    Track A is the no-hardware practical track from Volume 6, Part 6 of the
    PrologAI Demonstration Plan. It exercises Mentova over two expert
    ontologies — the Gene Ontology (GO) and the Disease Ontology (DO) —
    each loaded in its own scope, with cross-scope queries linking them.

    Usage:
        swipl -l demos/track_a_demo.pl -g "run_track_a" -t halt

    Pass criterion:
        All 10 demonstration queries return answers with human-readable
        justification chains built from named node_facts.
*/

% Declare this file as the 'track_a_demo_script' module, making its predicates available to other modules.
:- module(track_a_demo_script, [run_track_a/0]).

% Load the built-in 'lists' library so its predicates are available here.
:- use_module(library(lists)).
% Load the Mentova bootstrap so that all 48 reasoning modules are available.
:- use_module('../src/mentova/mentova').
% Load the Track A module so that GO, DO, and cross-scope queries are available.
:- use_module('../src/mentova/track_a').

% Define a clause for 'run_track_a': boot Mentova then execute the Track A demonstration.
run_track_a :-
    % Boot Mentova — enroll bodies, load constitution, load Small-World KB.
    mentova_boot,
    % Write a header announcing the Track A practical track demonstration.
    format("~n=== Track A: Transparent Reasoning Assistant (Volume 6, Part 6) ===~n"),
    % Write a description of what Track A demonstrates.
    format("Glass-box expert reasoning over Gene Ontology + Disease Ontology scopes.~n"),
    % Run the full Track A demonstration via the track_a module.
    track_a_demo.
