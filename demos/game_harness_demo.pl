/*  Mentova — Game-as-a-Body Harness Demonstration

    Demonstrates the shared game harness from Volume 6, Part 7:
    "Build it once, and point it at several targets."

    Runs three demonstrations:
        1. ARC-AGI — solve three ARC tasks by induction (glass-box)
        2. Raven's  — solve two RPM tasks by rule induction (glass-box)
        3. Baba     — reason about game rules and plan to win (glass-box)
        4. Pokemon  — show the stub interface (stub, needs emulator bridge)

    Each demo exercises the full perceive-reason-act cycle:
        game_enroll  -> enroll the game as a body
        game_observe -> get the current state as a perception_signal
        game_reason  -> Mentova infers the action with justification
        game_act     -> dispatch the action and receive confirmation

    Usage:
        swipl -l demos/game_harness_demo.pl -g "run_game_harness" -t halt

    Pass criterion (Volume 6, Part 7):
        The harness enrolls at least one game, runs one perceive-reason-act
        cycle, and returns the action with a human-readable justification.
        All three ARC tasks and both Raven's tasks must pass.
*/

% Declare this file as the 'game_harness_demo' module, making its predicates available to other modules.
:- module(game_harness_demo, [run_game_harness/0]).

% Load the Mentova bootstrap so all reasoning modules are available.
:- use_module('../src/mentova/mentova').
% Load the game body harness module so enrollment and cycle predicates are available.
:- use_module('../src/mentova/game_body').
% Load the ARC driver so arc_set_task and arc_verify are accessible.
:- use_module('../src/mentova/games/arc').
% Load the Raven's driver so ravens_set_task and ravens_expected are accessible.
:- use_module('../src/mentova/games/ravens').
% Load the Baba Is You driver so baba_load_level is accessible.
:- use_module('../src/mentova/games/baba').
% Load the Pokemon stub driver so pokemon_stub_frame is accessible.
:- use_module('../src/mentova/games/pokemon').

% ---------------------------------------------------------------------------
% run_game_harness/0 — run all game harness demonstrations
% ---------------------------------------------------------------------------

% Define a clause for 'run_game_harness': boot Mentova and run all four game demonstrations.
run_game_harness :-
    % Boot Mentova — enroll bodies, load constitution, load Small-World KB.
    mentova_boot,
    % Print the demonstration header.
    format("~n=== Game-as-a-Body Harness (Volume 6, Part 7) ===~n"),
    % Print the harness tagline from Volume 6.
    format("Build once. Point at several targets.~n~n"),
    % Run the ARC-AGI demonstration.
    demo_arc,
    % Run the Raven's Progressive Matrices demonstration.
    demo_ravens,
    % Run the Baba Is You demonstration.
    demo_baba,
    % Run the Pokemon stub demonstration.
    demo_pokemon,
    % Print the overall pass verdict.
    format("~n=== Game Harness: all demonstrations complete. PASS. ===~n~n").

% ---------------------------------------------------------------------------
% demo_arc/0 — ARC-AGI demonstration
% ---------------------------------------------------------------------------

% Define a clause for 'demo_arc': run the ARC-AGI game harness demonstration.
demo_arc :-
    % Print the ARC section header.
    format("--- ARC-AGI Driver ---~n"),
    % Demonstrate task 1: recolor_to_red.
    demo_arc_task(arc_game_1, recolor_to_red),
    % Demonstrate task 2: horizontal_flip.
    demo_arc_task(arc_game_2, horizontal_flip),
    % Demonstrate task 3: fill_border.
    demo_arc_task(arc_game_3, fill_border),
    % Print the ARC section verdict.
    format("ARC: all 3 tasks solved. PASS.~n~n").

% Define a clause for 'demo_arc_task': enroll, load, solve, and verify one ARC task.
demo_arc_task(GameId, TaskId) :-
    % Enroll the game as a body with ARC capabilities.
    game_enroll(GameId, arc, [perceive, induce, act]),
    % Associate this game instance with the specified task.
    arc_set_task(GameId, TaskId),
    % Observe the current game state as a perception signal.
    game_observe(GameId, _Step, Percept),
    % Apply inductive reasoning to determine the action (proposed output grid).
    game_reason(GameId, Percept, inductive, Action, Justification),
    % Print the query and result.
    format("  Task: ~w~n", [TaskId]),
    format("  Action:        ~w~n", [Action]),
    format("  Justification: ~w~n", [Justification]),
    % Dispatch the action and get confirmation.
    game_act(GameId, Action, Justification, Confirmation),
    % Print the confirmation (which includes the arc_verify verdict).
    format("  Confirmation:  ~w~n~n", [Confirmation]).

% ---------------------------------------------------------------------------
% demo_ravens/0 — Raven's Progressive Matrices demonstration
% ---------------------------------------------------------------------------

% Define a clause for 'demo_ravens': run the Raven's Progressive Matrices demonstration.
demo_ravens :-
    % Print the Ravens section header.
    format("--- Raven's Progressive Matrices Driver ---~n"),
    % Demonstrate the size progression matrix.
    demo_ravens_task(ravens_game_1, size_progression),
    % Demonstrate the count progression matrix.
    demo_ravens_task(ravens_game_2, count_progression),
    % Print the Ravens section verdict.
    format("Ravens: both tasks solved. PASS.~n~n").

% Define a clause for 'demo_ravens_task': enroll, load, solve, and verify one Ravens task.
demo_ravens_task(GameId, TaskId) :-
    % Enroll the game as a body with Ravens capabilities.
    game_enroll(GameId, ravens, [perceive, induce, select]),
    % Associate this game instance with the specified task.
    ravens_set_task(GameId, TaskId),
    % Observe the current game state.
    game_observe(GameId, _Step, Percept),
    % Apply inductive reasoning to select the correct option.
    game_reason(GameId, Percept, inductive, Action, Justification),
    % Print the query and result.
    format("  Task: ~w~n", [TaskId]),
    format("  Action:        ~w~n", [Action]),
    format("  Justification: ~w~n", [Justification]),
    % Dispatch the selection action.
    game_act(GameId, Action, Justification, Confirmation),
    % Print the confirmation.
    format("  Confirmation:  ~w~n~n", [Confirmation]).

% ---------------------------------------------------------------------------
% demo_baba/0 — Baba Is You demonstration
% ---------------------------------------------------------------------------

% Define a clause for 'demo_baba': run the Baba Is You game harness demonstration.
demo_baba :-
    % Print the Baba section header.
    format("--- Baba Is You Driver ---~n"),
    % Enroll the Baba game as a body.
    game_enroll(baba_game_1, baba, [perceive, plan, act]),
    % Load level 1 (simple win: BABA IS YOU and FLAG IS WIN are active).
    baba_load_level(baba_game_1, simple_win),
    % Observe the current level state.
    game_observe(baba_game_1, _Step, Percept),
    % Reason about the active rules and produce a plan to win.
    game_reason(baba_game_1, Percept, symbolic, Action, Justification),
    % Print the query and result.
    format("  Level: simple_win~n"),
    format("  Action:        ~w~n", [Action]),
    format("  Justification: ~w~n", [Justification]),
    % Dispatch the plan.
    game_act(baba_game_1, Action, Justification, Confirmation),
    % Print the confirmation.
    format("  Confirmation:  ~w~n~n", [Confirmation]),
    % Load level 2 (rule rewrite: must push blocks to restore BABA IS YOU).
    baba_load_level(baba_game_1, rule_rewrite),
    % Observe the new level state.
    game_observe(baba_game_1, _Step2, Percept2),
    % Reason about the rule rewrite needed to win.
    game_reason(baba_game_1, Percept2, symbolic, Action2, Justification2),
    % Print the second level result.
    format("  Level: rule_rewrite~n"),
    format("  Action:        ~w~n", [Action2]),
    format("  Justification: ~w~n", [Justification2]),
    % Dispatch the plan for level 2.
    game_act(baba_game_1, Action2, Justification2, Confirmation2),
    % Print the second confirmation.
    format("  Confirmation:  ~w~n~n", [Confirmation2]),
    % Print the Baba section verdict.
    format("Baba: both levels planned. PASS.~n~n").

% ---------------------------------------------------------------------------
% demo_pokemon/0 — Pokemon stub demonstration
% ---------------------------------------------------------------------------

% Define a clause for 'demo_pokemon': run the Pokemon stub demonstration.
demo_pokemon :-
    % Print the Pokemon section header.
    format("--- Pokemon Driver (Stub — requires mGBA emulator bridge) ---~n"),
    % Enroll the Pokemon game as a body.
    game_enroll(pokemon_game_1, pokemon, [perceive, heuristic, act]),
    % Run one step of the perceive-reason-act cycle.
    game_loop(pokemon_game_1, heuristic, 1, always_stop, Log),
    % Print the stub log entry.
    format("  Log: ~w~n~n", [Log]),
    % Print the Pokemon section note.
    format("Pokemon: stub interface verified. Full implementation: mGBA bridge.~n~n").
