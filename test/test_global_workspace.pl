/*  Mentova — In-file PLUnit suite for the 'global_workspace' module
    (Global Workspace Integration — Specification PR 18 + PR 32).

    Drives the module's exported predicates end to end and asserts on their
    real computed outputs (behavioural, not smoke):

      workspace_report/1          — the glass-box report term whose cycles_run
                                    and broadcast_history mirror the log.
      workspace_last_broadcast/3  — the most recent logged broadcast, and a
                                    clean failure when the log is empty.
      workspace_seed/1            — anchors + kindles a list of items into the
                                    default nexus without emitting a broadcast.
      workspace_run_cycle/1       — runs manual cognitive cycles: a safe no-op
                                    when no coalition wins, and — once a fresh
                                    live fact is seeded and the module's own
                                    logger is subscribed — a real broadcast
                                    that increments the cycle counter and fills
                                    the report and last-broadcast views.

    Run (from the Mentova repo root), with every PrologAI pack plus the
    Mentova source on the library path:
      LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
      swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
        -g "run_tests, halt" -t "halt(1)" test/test_global_workspace.pl
*/

% Declare this file as the 'test_global_workspace' module, exporting nothing.
:- module(test_global_workspace, []).
% Load the built-in PLUnit test framework.
:- use_module(library(plunit)).
% Load the Mentova module under test so its exported predicates are available.
:- use_module(library(global_workspace)).
% Import the Lattice open door used to stand up a fresh store per test.
:- use_module(library(lattice),    [lattice_open/2]).
% Import the anchoring-target setter so writes land in the test's own nexus.
:- use_module(library(node_facts), [set_default_nexus/1]).
% Import the broadcast-subscribe door so the module's logger can be wired in.
:- use_module(library(workspace),  [workspace_broadcast_subscribe/1]).
% Import gensym so each test opens a uniquely named nexus.
:- use_module(library(gensym),     [gensym/2]).

% reset_gw_state/0: clear the module's broadcast log and counter, drop subscribers.
reset_gw_state :-
    % Remove every logged broadcast record left by an earlier test.
    retractall(global_workspace:ws_broadcast_log(_, _, _, _)),
    % Remove the cycle counter fact.
    retractall(global_workspace:ws_cycle_counter(_)),
    % Reinstall the counter at zero.
    assertz(global_workspace:ws_cycle_counter(0)),
    % Drop any broadcast subscribers so a stray cycle logs nothing.
    retractall(workspace:broadcast_subscriber(_)).

% fresh_nexus/1: open a uniquely named nexus, make it default, reset workspace state.
fresh_nexus(Nexus) :-
    % Mint a unique nexus name so repeated opens never collide.
    gensym('locus://test_gw/', Name),
    % Open that in-memory nexus and bind its handle.
    lattice_open(Name, Nexus),
    % Route all subsequent anchor_node writes into this nexus.
    set_default_nexus(Nexus),
    % Clear coalition salience scores carried over from another run.
    retractall(workspace:coalition_salience(_, _)),
    % Clear coalition content mappings carried over from another run.
    retractall(workspace:coalition_content(_, _)),
    % Clear habituation broadcast counts carried over from another run.
    retractall(workspace:coalition_broadcast_count(_, _)),
    % Clear top-down pins carried over from another run.
    retractall(workspace:pinned_item(_, _)),
    % Reset the salience floor low so a novel coalition reliably wins a cycle.
    retractall(workspace:salience_floor(_)),
    % Install the low floor value.
    assertz(workspace:salience_floor(0.01)),
    % Reset the coalition id counter so generated ids are deterministic.
    retractall(workspace:coalition_id_counter(_)),
    % Install the fresh counter seed.
    assertz(workspace:coalition_id_counter(0)).

% Open the 'global_workspace' test block.
:- begin_tests(global_workspace).

% workspace_report on a fresh log reports zero cycles and an empty history.
test(report_reflects_fresh_state) :-
    % Start from a cleared log and a zeroed counter.
    reset_gw_state,
    % Build the glass-box report from the current workspace state.
    workspace_report(Report),
    % The report is the documented three-part term.
    Report = workspace_report(cycles_run(Cycles), broadcast_history(History), attention_economy(_)),
    % No cycle has broadcast yet, so the run count is exactly zero.
    assertion(Cycles == 0),
    % With nothing logged, the broadcast history is the empty list.
    assertion(History == []).

% workspace_last_broadcast fails cleanly when no broadcast has been logged.
test(last_broadcast_fails_on_empty_log) :-
    % Start from a cleared log.
    reset_gw_state,
    % With an empty log the max-cycle aggregate has no solution, so the query fails.
    assertion(\+ workspace_last_broadcast(_, _, _)).

% workspace_seed anchors a list of items into the nexus and emits no broadcast.
test(seed_stores_items_without_broadcasting) :-
    % Start from a cleared log and counter.
    reset_gw_state,
    % Stand up a fresh default nexus for the anchored facts.
    fresh_nexus(_),
    % The empty-list base case succeeds trivially.
    assertion(workspace_seed([])),
    % A two-item seed runs the recursive clause and its neighbor-link branch.
    assertion(workspace_seed([item(is_a, [bird, animal], []), item(capable_of, [bird, flies], [])])),
    % Read the report back after seeding.
    workspace_report(workspace_report(cycles_run(Cycles), _, _)),
    % Seeding anchors and kindles facts but never runs a cycle, so the counter is zero.
    assertion(Cycles == 0).

% workspace_run_cycle is a safe no-op when no coalition can win.
test(run_cycle_is_a_safe_noop_without_a_winner) :-
    % Start from a cleared log, a zeroed counter, and no subscribers.
    reset_gw_state,
    % Stand up a fresh, empty default nexus so no coalition forms.
    fresh_nexus(_),
    % The zero-cycle base case succeeds immediately via its cut.
    assertion(workspace_run_cycle(0)),
    % Three manual cycles over an empty nexus run without error.
    assertion(workspace_run_cycle(3)),
    % Read the report back after the empty cycles.
    workspace_report(workspace_report(cycles_run(Cycles), broadcast_history(History), _)),
    % An empty nexus yields no winner, so the counter is untouched.
    assertion(Cycles == 0),
    % And the broadcast history stays empty.
    assertion(History == []).

% A seeded live fact plus the module's own subscriber makes a cycle broadcast,
% incrementing the counter and filling the report and last-broadcast views.
test(cycle_broadcasts_logs_and_reports) :-
    % Start from a cleared log, a zeroed counter, and no subscribers.
    reset_gw_state,
    % Stand up a fresh default nexus with a low salience floor.
    fresh_nexus(_),
    % Subscribe the module's own broadcast logger, exactly as workspace_boot would.
    workspace_broadcast_subscribe(global_workspace:ws_log_broadcast),
    % Seed a single fresh, novel fact so exactly one coalition can form.
    workspace_seed([item(percept, [alarm], [])]),
    % Run one manual cognitive cycle over the seeded nexus.
    workspace_run_cycle(1),
    % The winning coalition was broadcast, so the logger incremented the counter.
    global_workspace:ws_cycle_counter(Count),
    % Exactly one broadcast has been recorded.
    assertion(Count =:= 1),
    % The most recent broadcast is retrievable through the exported reader.
    assertion(workspace_last_broadcast(_, _, _)),
    % Read the last broadcast's cycle number, coalition id, and relation.
    workspace_last_broadcast(CycleN, CoalitionId, Relation),
    % It is the first (and only) logged cycle.
    assertion(CycleN =:= 1),
    % A coalition id atom was assigned to the winner.
    assertion(atom(CoalitionId)),
    % The winning coalition carries the seeded 'percept' relation.
    assertion(Relation == percept),
    % Read the glass-box report back after the broadcast.
    workspace_report(workspace_report(cycles_run(RCycles), broadcast_history(Hist), _)),
    % The report now mirrors the log: exactly one cycle has run.
    assertion(RCycles =:= 1),
    % And the broadcast history is no longer empty.
    assertion(Hist \== []).

% Close the 'global_workspace' test block.
:- end_tests(global_workspace).
