/*  Mentova — Pokémon Driver (Stub)

    This is the stub driver for the Pokémon Red / Emerald flagship demonstration.
    A full implementation requires an emulator bridge connecting Mentova to
    a Game Boy (Color / Advance) emulator via its RAM map and input API.

    WHAT A FULL IMPLEMENTATION REQUIRES
    ------------------------------------
    Emulator:    mGBA (https://mgba.io) or BizHawk, with a Lua scripting socket
                 or Python binding that can read RAM and inject button presses.

    RAM map:     Pokémon Red RAM map (https://datacrystal.tcrf.net/wiki/Pok%C3%A9mon_Red)
                 Addresses for: player position, map ID, battle state, party HP,
                 item inventory, flag bytes (story progress).

    Bridge:      A small Python process running alongside the emulator that:
                 (1) reads RAM at each frame and writes a percept to a Unix socket
                 (2) listens for button commands on the same socket and injects them

    Mentova side: this driver module reads percepts from the socket via
                 SWI-Prolog's socket library and writes button commands back.

    ARCHITECTURE
    ------------
    The bridge is a herald in the Mind-Body pattern (PR 10):
        emulator → bridge → relay_percept(game_env_pokemon, Signal) → Mentova
        Mentova  → game_act(game_env_pokemon, press(Button), ...) → bridge → emulator

    This maps onto Volume 6, Part 6, Track B (the embodied robot track), where
    the emulator plays the role of the virtual robot and the bridge is the ROS 2
    herald — except here the bridge speaks a much simpler socket protocol.

    STUB INTERFACE
    --------------
    All predicates below succeed with stub results so that game_body.pl
    can exercise the harness machinery without a live emulator.
*/

% Declare this file as the 'pokemon' module, making its predicates available to other modules.
:- module(pokemon, [
    % Supply 'pokemon/3' for the observe interface.
    pokemon/3,
    % Supply 'pokemon/4' for the act interface.
    pokemon/4,
    % Supply 'pokemon/7' for the reason interface.
    pokemon/7,
    % Supply 'pokemon_stub_frame/1' as the next argument to the expression above.
    pokemon_stub_frame/1
% Close the expression opened above.
]).

% Load the built-in 'lists' library so member is available.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Stub game state
% ---------------------------------------------------------------------------

% Define a clause for 'pokemon_stub_frame': return a representative stub frame.
pokemon_stub_frame(
    % A stub frame representing an early game state in Pokémon Red.
    pokemon_frame(
        % Current map: Pallet Town.
        map(pallet_town),
        % Player's grid position.
        player_pos(pos(5, 8)),
        % Party: one Charmander at level 5 with 19/19 HP.
        party([pokemon(charmander, level(5), hp(19,19))]),
        % No active battle.
        battle(none),
        % Objective: go north to Route 1.
        objective(go_north_to_route_1),
        % Note that this is a stub and not connected to a real emulator.
        note(stub_no_emulator_connected)
    )
).

% ---------------------------------------------------------------------------
% Driver interface — stub implementations
% ---------------------------------------------------------------------------

% Define a clause for 'pokemon/4 observe': return a stub frame.
pokemon(observe, GameId, Frame) :-
    % Return a stub frame explaining this is a demonstration stub.
    pokemon_stub_frame(StubFrame),
    % Wrap the stub frame with the game instance ID.
    Frame = pokemon_stub(GameId, StubFrame,
                         note('Full implementation requires mGBA emulator bridge.')).

% Define a clause for 'pokemon/4 act': accept any button press as a stub action.
pokemon(act, GameId, press(Button), Result) :-
    % Accept any button press and return a stub confirmation.
    member(Button, [a, b, start, select, up, down, left, right]),
    % Return a stub result noting the emulator is not connected.
    Result = stub_result(GameId, pressed(Button),
                         note('Would relay to emulator bridge in full implementation.')).

% Define a clause for 'pokemon/4 reason': return a heuristic stub action.
pokemon(reason, GameId, _Frame, StepN, heuristic, Action, Justification) :-
    % Choose a stub action based on the step number to simulate navigation.
    member(StepN-Button, [0-up, 1-up, 2-up, 3-right, 4-up, 5-a]),
    % The stub action is a button press.
    Action = press(Button),
    % Explain that this is a heuristic stub, not real game reasoning.
    Justification = just(pokemon_stub, GameId, step(StepN),
                         heuristic_action(Button),
                         note('Real Pokémon reasoning requires emulator bridge.'),
                         next_step('Build mGBA Lua bridge, read RAM map, relay percepts.')).

% Default: if no step-to-button mapping matches, press A.
pokemon(reason, GameId, _Frame, _StepN, heuristic, press(a), Justification) :-
    % Fall back to pressing A as a default heuristic action.
    Justification = just(pokemon_stub, GameId,
                         default_action(press_a),
                         note('Default stub action when no step mapping matches.')).
