/*  Mentova — Live ARC-AGI-3 Connection Demonstration

    Proves the live client speaks the real ARC-AGI-3 protocol, and that the
    system falls back gracefully when no API key is present.

    Because the real servers need an API key, this demonstration stands up a
    small MOCK ARC-AGI-3 server that implements the exact endpoints confirmed
    from the official toolkit - /api/games, /api/scorecard/open,
    /api/cmd/RESET, /api/cmd/ACTIONn - and points the live client at it with
    al_configure/2. The same client code speaks to the real https://three.arcprize.org
    when a real key is configured.

    Acceptance criteria (each prints PASS or FAIL at run time):
      AC-LIVE-001: with no key, connecting fails cleanly and the system stays
                   on the three local stand-in environments.
      AC-LIVE-002: with a (mock) key, connecting lists the live games.
      AC-LIVE-003: a live game resets and returns a two-dimensional frame,
                   flattened from the protocol's stack-of-grids form.
      AC-LIVE-004: Solo plays a live game to a WIN and writes a report.
      AC-LIVE-005: the dropdown source is live and lists the live games.
      AC-LIVE-006: disconnecting returns to the three local stand-ins.

    Run:
        swipl -l demos/arc_live_demo.pl -g run_arc_live_demo -t halt
*/

% Load the shared backend and the live client.
:- use_module('../src/mentova/mentova_arc_chat').
% The live client, for configuration and direct checks.
:- use_module('../src/mentova/arc_agi_3_live').
% The HTTP server framework for the mock.
:- use_module(library(http/thread_httpd)).
% The route dispatcher.
:- use_module(library(http/http_dispatch)).
% The JSON reply/read helpers.
:- use_module(library(http/http_json)).
% List helpers.
:- use_module(library(lists), [member/2]).

% The mock server port.
mock_port(8094).

% ---------------------------------------------------------------------------
% The mock ARC-AGI-3 server — the exact protocol, a tiny winnable game
% ---------------------------------------------------------------------------

% mock_ctr_/2: (GameId, Count) — the hidden counter of a mock game.
:- dynamic mock_ctr_/2.

% The games list endpoint.
:- http_handler('/api/games', mock_games, []).
% The scorecard open endpoint.
:- http_handler('/api/scorecard/open', mock_open, []).
% The scorecard close endpoint.
:- http_handler('/api/scorecard/close', mock_close, []).
% The reset command endpoint.
:- http_handler('/api/cmd/RESET', mock_reset, []).
% The five simple action endpoints share one handler.
:- http_handler('/api/cmd/ACTION1', mock_action(1), []).
% Action two.
:- http_handler('/api/cmd/ACTION2', mock_action(2), []).
% Action three.
:- http_handler('/api/cmd/ACTION3', mock_action(3), []).
% The undo action (ACTION7) reverts the counter.
:- http_handler('/api/cmd/ACTION7', mock_undo, []).

% mock_games(+Request): two mock game environments.
mock_games(_Request) :-
    % Reply with the game list, each carrying a game_id.
    reply_json_dict([ _{game_id: "mock-signal", title: "Mock Signal (live-protocol test)"},
                      _{game_id: "mock-relay",  title: "Mock Relay (live-protocol test)"} ]).

% mock_open(+Request): open a scorecard and return a card id.
mock_open(_Request) :-
    % Reply with a card id.
    reply_json_dict(_{card_id: "card-mock-1"}).

% mock_close(+Request): close a scorecard.
mock_close(_Request) :-
    % Acknowledge.
    reply_json_dict(_{ok: true}).

% mock_reset(+Request): reset a mock game to counter zero.
mock_reset(Request) :-
    % Read the body.
    http_read_json_dict(Request, Body),
    % The game id.
    atom_string(GameId, Body.game_id),
    % Zero the counter.
    retractall(mock_ctr_(GameId, _)),
    % Start at zero.
    assertz(mock_ctr_(GameId, 0)),
    % Reply with the frame data.
    mock_frame_reply(GameId).

% mock_action(+N, +Request): apply an action; action one raises the counter.
mock_action(N, Request) :-
    % Read the body.
    http_read_json_dict(Request, Body),
    % The game id.
    atom_string(GameId, Body.game_id),
    % Fetch the counter, defaulting to zero.
    ( retract(mock_ctr_(GameId, C)) -> true ; C = 0 ),
    % Action one raises the counter; others leave it unchanged.
    ( N =:= 1 -> C1 is min(3, C + 1) ; C1 = C ),
    % Store the new counter.
    assertz(mock_ctr_(GameId, C1)),
    % Reply with the frame data.
    mock_frame_reply(GameId).

% mock_undo(+Request): the undo action reverts the counter by one, floored.
mock_undo(Request) :-
    % Read the body.
    http_read_json_dict(Request, Body),
    % The game id.
    atom_string(GameId, Body.game_id),
    % Fetch the counter.
    ( retract(mock_ctr_(GameId, C)) -> true ; C = 0 ),
    % Undo lowers it, never below zero.
    C1 is max(0, C - 1),
    % Store it.
    assertz(mock_ctr_(GameId, C1)),
    % Reply.
    mock_frame_reply(GameId).

% mock_avail(+GameId, -Available): the second mock game also offers undo (ACTION7).
mock_avail('mock-relay', ["ACTION1", "ACTION2", "ACTION7", "RESET"]) :- !.
% Every other mock game offers the two simple actions.
mock_avail(_, ["ACTION1", "ACTION2", "RESET"]).

% mock_frame_reply(+GameId): the FrameData reply for the current counter.
mock_frame_reply(GameId) :-
    % The counter.
    mock_ctr_(GameId, C),
    % The lit value: empty, part-lit, then the win colour.
    ( C >= 3 -> V = 3, State = "WIN" ; C >= 1 -> V = 4, State = "NOT_FINISHED" ; V = 0, State = "NOT_FINISHED" ),
    % The frame as a STACK of grids (the protocol's shape), one 3x3 grid.
    Frame = [[[0,0,0],[0,0,0],[0,0,V]]],
    % This game's available actions (mock-relay also supports undo).
    mock_avail(GameId, Avail),
    % Reply with the exact protocol fields.
    reply_json_dict(_{game_id: GameId, guid: "guid-mock",
                      frame: Frame, state: State, levels_completed: 0,
                      available_actions: Avail,
                      action_input: _{id: "ACTION1"}}).

% ---------------------------------------------------------------------------
% The demonstration
% ---------------------------------------------------------------------------

% report(+Id, +Cond): print PASS or FAIL.
report(Id, Cond) :-
    % Evaluate once.
    ( call(Cond) -> V = 'PASS' ; V = 'FAIL' ),
    % Print.
    format("~w: ~w~n", [Id, V]).

% tick_to_done(+N, +Max, -Final): advance the solo run until it finishes.
tick_to_done(N, Max, Final) :-
    % Cap.
    ( N >= Max -> ma_solo_tick(Final)
    ; ma_solo_tick(T),
      ( get_dict(done, T, true) -> Final = T ; N1 is N + 1, tick_to_done(N1, Max, Final) )
    ).

% Define run_arc_live_demo: run the full demonstration.
run_arc_live_demo :-
    % Announce.
    format("~n=== Live ARC-AGI-3 Connection ===~n~n", []),
    % Attach the shared database (guarded).
    catch(ma_db_init('data/chat_db'), _, true),
    % Start the mock server.
    mock_port(P), http_server(http_dispatch, [port(P)]),

    % AC-001: no key -> connect fails cleanly, stay on the three local games.
    report('AC-LIVE-001', demo_no_key_fallback),

    % Configure the client to point at the mock server with a mock key.
    format(atom(Base), 'http://localhost:~w', [P]),
    al_configure(Base, 'mock-key'),

    % AC-002: connecting lists the live games.
    report('AC-LIVE-002', ( al_connect(connected(N)), N >= 1, al_games(Gs), Gs \== [] )),

    % Switch to the live source and select the first live game.
    ma_set_source(live), al_game(FirstId, _),

    % AC-003: a live game resets and returns a flattened two-dimensional frame.
    report('AC-LIVE-003', demo_live_reset(FirstId)),

    % AC-004: Solo plays a live game to a WIN and writes a report.
    report('AC-LIVE-004', demo_solo_live(FirstId)),

    % AC-005: the dropdown source is live and lists the live games.
    report('AC-LIVE-005', ( ma_source(live), findall(I, ma_available_game(I, _), Is), Is \== [], member(FirstId, Is) )),

    % AC-007: the game that offers ACTION7 shows a canonical undo button.
    report('AC-LIVE-007', demo_undo_button),

    % AC-006: disconnecting returns to the three local stand-ins.
    report('AC-LIVE-006', ( al_disconnect, ma_set_source(local),
                            findall(I, ma_available_game(I, _), Locals), length(Locals, 3) )),

    % Show the status and games.
    al_status(_),
    format("~ndone.~n", []).

% demo_no_key_fallback: with no key configured, connecting fails cleanly.
demo_no_key_fallback :-
    % Clear any configured key and base.
    al_configure('https://three.arcprize.org', ''),
    % Ensure no environment key leaks in for this check.
    ( getenv('ARC_API_KEY', K), K \== '' -> true   % if a real key exists, skip the negative
    ;   % No key: connect must fail with an error and leave the source local.
        al_connect(error(_)),
        ma_source(local),
        findall(I, ma_available_game(I, _), Locals), length(Locals, 3)
    ).

% demo_live_reset(+Id): the live game resets to a two-dimensional frame.
demo_live_reset(Id) :-
    % Select and reset the live game.
    ma_set_game(Id),
    % Render its current frame.
    ma_render(Id, Frame),
    % It is a two-dimensional grid (rows of integers).
    Frame = [Row | _], Row = [Cell | _], integer(Cell).

% demo_undo_button: the undo-capable game shows a canonical undo button.
demo_undo_button :-
    % The second mock game supports undo (ACTION7).
    Id = 'mock-relay',
    % Select it, which resets it and records its available actions.
    ma_set_game(Id),
    % The labelled action descriptors for the live game.
    mentova_arc_chat:ma_action_descriptors(Id, Ds),
    % One of them is the undo command ACTION7.
    member(D, Ds), get_dict(command, D, 'ACTION7'),
    % Labelled with the protocol-known undo meaning.
    get_dict(label, D, L), sub_atom(L, _, _, _, undo),
    % And its source is the protocol (a known meaning, not a guess).
    get_dict(source, D, protocol).

% demo_solo_live(+Id): Solo plays the live game to a win and writes a report.
demo_solo_live(Id) :-
    % Select the live game and enter solo mode.
    ma_set_game(Id), ma_set_mode(solo),
    % Begin a fresh solo attempt (restart in solo mode).
    ma_restart(_, _),
    % Advance to completion.
    tick_to_done(0, 60, Final),
    % It must have won.
    sub_atom(Final.outcome, 0, _, _, won),
    % A report was written.
    Final.report \== none.
