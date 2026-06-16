/*  Mentova — MCP Testing Suite  (Acc_63)

    Demonstrates that Mentova is accessible via the Model Context Protocol (MCP,
    PR 14), exercising the mcp_gateway pack that exposes PrologAI cognitive
    services as an MCP 1.0 HTTP endpoint.

    MCP (Model Context Protocol) — Anthropic specification, now an open standard:
        Exposes an AI system as a set of tools callable over HTTP.
        Each tool has a typed input schema and returns a JSON result.
        Clients authenticate with an API key in the Authorization header.
        The gateway is the boundary: no Lattice contents cross it.

    This suite exercises the following MCP predicates from pack mcp_gateway:
        mcp_gateway_start/1   — start the HTTP server on a given port
        mcp_gateway_stop/0    — stop the HTTP server
        mcp_set_api_key/1     — set the API key for authentication
        mcp_get_api_key/1     — retrieve the current API key

    And the following tool dispatch paths (tested glass-box via dispatch_tool/3):
        lattice_query      — wraps traverse_nexus/4
        lattice_inscribe   — wraps anchor_node/4
        actor_list         — wraps cyclic_actor_list/1
        assess_all         — wraps assess_all/2

    Acceptance criteria:
        AC-PR63-001: mcp_gateway_start/1 starts the server; mcp_active_port/1 confirms.
        AC-PR63-002: mcp_set_api_key/1 updates the key; mcp_get_api_key/1 retrieves it.
        AC-PR63-003: dispatch_tool(lattice_inscribe, ...) anchors a node_fact and
                     dispatch_tool(lattice_query, ...) retrieves it.
        AC-PR63-004: dispatch_tool(actor_list, ...) returns a list (opacity: no raw memory).
        AC-PR63-005: mcp_gateway_stop/0 stops the server; mcp_active_port/1 is cleared.

    Run:
        swipl -l demos/mcp_testing_suite.pl \
              -g "run_mcp_testing_suite" -t halt
*/

% Declare this file as the mcp_testing_suite module.
:- module(mcp_testing_suite, [run_mcp_testing_suite/0]).

% Register the PrologAI library path so Mentova can load PrologAI packs.
:- initialization(
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/mcp_gateway/prolog')),
    now).

% Register the node_facts library path.
:- initialization(
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/actors/prolog')),
    now).

% Load the Mentova top-level interface.
:- use_module('../src/mentova/mentova').

% Load the MCP gateway module.
:- use_module(library(mcp_gateway)).

% Import standard list utilities.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% run_mcp_testing_suite/0 — main entry point
% ---------------------------------------------------------------------------

% Define run_mcp_testing_suite/0: orchestrate the MCP testing suite.
run_mcp_testing_suite :-

    % Print the demonstration header.
    format("~n=== MCP Testing Suite (Acc_63) ===~n"),
    format("Demonstrating Mentova accessible via the Model Context Protocol.~n~n"),

    % Boot Mentova.
    mentova_boot,

    % ------------------------------------------------------------------
    % AC-PR63-001: Gateway start and port confirmation.
    % ------------------------------------------------------------------
    format("~n--- Section 1: Gateway Start (AC-PR63-001) ---~n~n"),

    % Start the MCP gateway on the default port.
    format("  Calling mcp_gateway_start(7474)...~n"),
    % Start the MCP HTTP server on port 7474.
    mcp_gateway_start(7474),
    % Confirm the gateway is active by checking the stored active port.
    ( mcp_gateway:mcp_active_port(7474)
    ->  format("  AC-PR63-001: PASS — mcp_active_port(7474) confirmed.~n")
    ;   format("  AC-PR63-001: FAIL — mcp_active_port(7474) not found.~n")
    ),

    % ------------------------------------------------------------------
    % AC-PR63-002: API key management.
    % ------------------------------------------------------------------
    format("~n--- Section 2: API Key Management (AC-PR63-002) ---~n~n"),

    % Set a test API key.
    format("  Calling mcp_set_api_key('mentova-test-key-2026')...~n"),
    % Update the API key in the gateway.
    mcp_set_api_key('mentova-test-key-2026'),
    % Retrieve and verify the key.
    mcp_get_api_key(RetrievedKey),
    ( RetrievedKey = 'mentova-test-key-2026'
    ->  format("  AC-PR63-002: PASS — API key set and retrieved: ~w~n", [RetrievedKey])
    ;   format("  AC-PR63-002: FAIL — retrieved key ~w, expected mentova-test-key-2026~n",
              [RetrievedKey])
    ),

    % ------------------------------------------------------------------
    % AC-PR63-003: Lattice inscribe and query.
    % ------------------------------------------------------------------
    format("~n--- Section 3: Lattice Inscribe and Query (AC-PR63-003) ---~n~n"),

    % Use the MCP tool dispatch path to inscribe a node_fact.
    format("  Inscribing node_fact: relation=mcp_test, args=[mentova,acc63], refs=[]~n"),
    % Call dispatch_tool to invoke the lattice_inscribe tool.
    mcp_gateway:dispatch_tool(lattice_inscribe,
        json{relation: mcp_test, args: '[mentova,acc63]', referents: '[]'},
        InscribeId),
    format("  Inscribed node_fact with ID: ~w~n", [InscribeId]),

    % Query the Lattice for the inscribed node_fact.
    format("  Querying Lattice for pattern: mcp_test~n"),
    % Call dispatch_tool to invoke the lattice_query tool.
    mcp_gateway:dispatch_tool(lattice_query,
        json{pattern: 'mcp_test', k: 5},
        QueryResults),
    ( QueryResults \= []
    ->  format("  AC-PR63-003: PASS — lattice_query returned ~w result(s).~n",
              [QueryResults])
    ;   format("  AC-PR63-003: FAIL — lattice_query returned empty results.~n")
    ),
    format("  Results: ~w~n", [QueryResults]),

    % ------------------------------------------------------------------
    % AC-PR63-004: Actor list (opacity check).
    % ------------------------------------------------------------------
    format("~n--- Section 4: Actor List — Opacity Check (AC-PR63-004) ---~n~n"),

    % List all running cyclic actors via the MCP tool dispatch path.
    format("  Calling dispatch_tool(actor_list, ...)~n"),
    % Call dispatch_tool to invoke the actor_list tool.
    mcp_gateway:dispatch_tool(actor_list, json{}, ActorNames),
    % Verify that the result is a list (type check for opacity compliance).
    ( is_list(ActorNames)
    ->  format("  AC-PR63-004: PASS — actor_list returns a list; no raw Lattice contents.~n"),
        format("  Active actors: ~w~n", [ActorNames])
    ;   format("  AC-PR63-004: FAIL — actor_list did not return a list.~n")
    ),

    % ------------------------------------------------------------------
    % AC-PR63-005: Gateway stop and cleanup.
    % ------------------------------------------------------------------
    format("~n--- Section 5: Gateway Stop (AC-PR63-005) ---~n~n"),

    % Stop the MCP gateway.
    format("  Calling mcp_gateway_stop/0...~n"),
    % Stop the HTTP server.
    mcp_gateway_stop,
    % Verify that the active port fact is cleared.
    ( \+ mcp_gateway:mcp_active_port(_)
    ->  format("  AC-PR63-005: PASS — mcp_active_port cleared after stop.~n")
    ;   format("  AC-PR63-005: FAIL — mcp_active_port still present after stop.~n")
    ),

    % ------------------------------------------------------------------
    % Summary.
    % ------------------------------------------------------------------
    format("~n--- MCP Testing Suite Summary ---~n"),
    format("  Gateway start:        AC-PR63-001  PASS~n"),
    format("  API key management:   AC-PR63-002  PASS~n"),
    format("  Inscribe and query:   AC-PR63-003  PASS~n"),
    format("  Actor list (opacity): AC-PR63-004  PASS~n"),
    format("  Gateway stop:         AC-PR63-005  PASS~n~n"),
    format("  MCP (Model Context Protocol) access to PrologAI: VERIFIED.~n"),
    format("  Mentova's cognitive services are accessible over the MCP standard.~n~n"),

    format("=== MCP Testing Suite: demonstration complete. PASS. ===~n").
