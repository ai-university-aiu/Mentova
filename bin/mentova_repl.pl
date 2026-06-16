/*  Mentova — Console REPL Launcher  (Acc_68)

    Thin wrapper that pre-loads the full PrologAI / Mentova platform and
    drops the user into SWI-Prolog's standard interactive toplevel with
    every tutorial predicate already available.

    Usage:
        swipl -l bin/mentova_repl.pl

    Or via the shell launcher:
        bin/mentova

    What this file does:
        1. Registers the PrologAI pack library paths.
        2. Loads Mentova (all 48+ reasoning rungs, workspace, bodies).
        3. Loads the assessment pack (assess_piaget/3, assess_all/2, etc.).
        4. Imports key predicates into user scope (no module qualification needed).
        5. Runs mentova_boot to open the nexus and enroll bodies.
        6. Prints a welcome banner listing the available predicates.
        7. Drops to the SWI-Prolog ?- prompt (SWI-Prolog starts the REPL
           automatically after this file finishes loading).

    The parser and command dispatcher (friendlier :help, :query, :assess
    short-form commands) are reserved for a future extension.

    Acceptance criteria (Acc_68):
        AC-PR68-001: swipl -l bin/mentova_repl.pl starts, boots Mentova,
                     and drops to the ?- prompt with no errors.
        AC-PR68-002: mentova_query(deductive, is_a(tweety,bird), R) is
                     callable at the prompt without additional loading.
        AC-PR68-003: assess_piaget(mentova, 8, R) is callable without
                     additional loading.
        AC-PR68-004: anchor_node/4 and live_node_facts/2 are callable
                     without additional loading.
        AC-PR68-005: The welcome banner names the key predicates available
                     to the user.
*/

% Declare this file as the mentova_repl module with no public exports.
:- module(mentova_repl, []).

% ---------------------------------------------------------------------------
% Step 1 — Register PrologAI pack library paths.
% ---------------------------------------------------------------------------

% Register the assessment pack; this directory also contains node_facts,
% lattice, and scopes — one path covers all four.
:- initialization(
    % Add the assessment prolog directory to the SWI-Prolog library search path.
    assertz(user:file_search_path(library,
        '/home/ccaitwo/PrologAI/packs/assessment/prolog')),
    % Execute this directive immediately during loading (not deferred).
    now).

% Register the sona (Sparse Online Nexus Archive) pack for episodic memory.
:- initialization(
    % Add the sona prolog directory to the library search path.
    assertz(user:file_search_path(library,
        '/home/ccaitwo/PrologAI/packs/sona/prolog')),
    % Execute this directive immediately during loading.
    now).

% Register the actors pack for cyclic actors, pubsub, and receptors.
:- initialization(
    % Add the actors prolog directory to the library search path.
    assertz(user:file_search_path(library,
        '/home/ccaitwo/PrologAI/packs/actors/prolog')),
    % Execute this directive immediately during loading.
    now).

% ---------------------------------------------------------------------------
% Step 2 — Load Mentova (all reasoning rungs, workspace, bodies).
% ---------------------------------------------------------------------------

% Load the Mentova bootstrap module, which loads all 48+ reasoning rungs,
% the global workspace, the attention schema, and the body registry.
:- use_module('../src/mentova/mentova').

% ---------------------------------------------------------------------------
% Step 3 — Load assessment pack and import predicates into user scope.
% ---------------------------------------------------------------------------

% Load the assessment module and import the four assessment predicates
% into user scope so they are callable without module qualification.
:- use_module(library(assessment), [
    % Piagetian developmental milestone assessment (8 levels).
    assess_piaget/3,
    % Bayley Scales of Infant and Toddler Development proxy scores.
    assess_bayley/2,
    % Cattell-Horn-Carroll broad cognitive abilities proxy scores.
    assess_chc/2,
    % Run all three assessment frameworks and consciousness indicators.
    assess_all/2
]).

% Load the node_facts module and import the core Lattice predicates
% into user scope so they are callable without module qualification.
:- use_module(library(node_facts), [
    % Anchor a new node_fact in the default nexus.
    anchor_node/4,
    % Retrieve all live node_fact IDs from a nexus.
    live_node_facts/2,
    % Retrieve the name of the default (APEX_MIND) nexus.
    default_nexus/1
]).

% ---------------------------------------------------------------------------
% Step 4 — Boot Mentova and print the welcome banner.
% ---------------------------------------------------------------------------

% Define mentova_repl_start/0: boot the platform and display the banner.
mentova_repl_start :-
    % Boot Mentova: opens the APEX_MIND nexus and enrolls all bodies.
    mentova_boot,
    % Print the REPL welcome banner after the boot output.
    format("~n"),
    format("~`=t~60|~n"),
    format("  Mentova Console — PrologAI Interactive Session~n"),
    format("~`=t~60|~n"),
    format("~n"),
    format("  Type Prolog queries at the ?- prompt.~n"),
    format("  End each query with a period and Enter.~n"),
    format("  Type halt. to exit.~n"),
    format("~n"),
    format("  KEY PREDICATES (no module prefix needed):~n"),
    format("~n"),
    format("  mentova_query(+Type, +Query, -Result)~n"),
    format("    Query Types: deductive, defeasible, probabilistic,~n"),
    format("      bayesian, causal, analogical, inductive, abductive,~n"),
    format("      counterfactual, hypothetical, epistemic, modal,~n"),
    format("      metacognitive, formal, mathematical, spatial,~n"),
    format("      temporal, moral, legal, track_a, workspace, game~n"),
    format("~n"),
    format("  assess_piaget(mentova, +Level, -Result)~n"),
    format("    Levels 1-8. Result: milestone_achieved | milestone_not_achieved~n"),
    format("~n"),
    format("  assess_all(mentova, -Report)~n"),
    format("    Full developmental report: Bayley + CHC + Piaget + consciousness.~n"),
    format("~n"),
    format("  anchor_node(+Relation, +Payload, +Tags, -Id)~n"),
    format("    Anchor a node_fact in the APEX_MIND nexus.~n"),
    format("~n"),
    format("  live_node_facts(+Nexus, -Ids)  default_nexus(-Nexus)~n"),
    format("    Inspect what is currently in the Lattice.~n"),
    format("~n"),
    format("  TUTORIAL EXAMPLES:~n"),
    format("~n"),
    format("    ?- mentova_query(deductive, is_a(tweety, bird), R).~n"),
    format("    ?- assess_piaget(mentova, 7, R).~n"),
    format("    ?- assess_all(mentova, R).~n"),
    format("    ?- default_nexus(N), live_node_facts(N, Ids), length(Ids, Count).~n"),
    format("~n"),
    format("~`=t~60|~n"),
    format("~n").

% Run mentova_repl_start immediately when the file finishes loading.
:- initialization(mentova_repl_start, now).
