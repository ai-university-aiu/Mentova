/*  Mentova — Live ARC-AGI-3 Environment Client

    Connects Mentova to the live ARC-AGI-3 game environments at the ARC Prize
    Foundation's agents API. It speaks the exact March-2026 protocol confirmed
    from the official toolkit:

      base URL   https://three.arcprize.org  (override with ARC_API_BASE)
      auth       header  X-API-Key: <ARC_API_KEY>
      games      GET  /api/games                 -> [ {game_id, ...}, ... ]
      scorecard  POST /api/scorecard/open        { tags, source_url, opaque }
                                                 -> { card_id }
                 POST /api/scorecard/close       { card_id }
                 (tags mark this as an AI agent, set only at open time; the
                  platform web UI cannot change a card's tags afterwards)
      reset      POST /api/cmd/RESET             { card_id, game_id, guid? }
      action     POST /api/cmd/ACTION1..ACTION7  { game_id, guid, x?, y? }
                 (ACTION1-5 simple, ACTION6 cell-select with x,y, ACTION7 undo)
      reply      { game_id, guid, frame, state, levels_completed,
                   available_actions, action_input }
      state      NOT_PLAYED | NOT_FINISHED | WIN | GAME_OVER

    Everything is guarded: with no key, or if the API is unreachable, every
    predicate fails cleanly so the caller falls back to the local stand-ins,
    and al_status/1 explains why. The base URL and key can also be set at
    runtime with al_configure/2 (used by the mock-server test and by an
    optional settings endpoint), so the client can be exercised end to end
    without the real key.

    Predicates:
      al_configure/2   -- +BaseUrl, +ApiKey  (set base and key at runtime)
      al_base/1        -- -BaseUrl
      al_key/1         -- -ApiKey             (env, file, or configured; fails if none)
      al_has_key/0     -- a key is available
      al_connect/1     -- -Result   (connected(N) | error(Reason))
      al_connected/0   -- a live session is open
      al_disconnect/0  -- forget the live session
      al_games/1       -- -Games    ( [ g(Id, Title), ... ] )
      al_reset/2       -- +GameId, -Frame2d
      al_act/3         -- +GameId, +Action, -Frame2d
      al_render/2      -- +GameId, -Frame2d   (last frame, resetting if fresh)
      al_actions/2     -- +GameId, -Actions
      al_solved/1      -- +GameId   (last state is WIN)
      al_state/2       -- +GameId, -State
      al_status/1      -- -Dict     (key_configured, connected, base, games, error)
*/

% Declare the live client module and its exports.
:- module(arc_agi_3_live, [
    % al_configure/2: set the base URL and API key at runtime.
    al_configure/2,
    % al_base/1: the API base URL.
    al_base/1,
    % al_key/1: the API key (fails if none is available).
    al_key/1,
    % al_has_key/0: a key is available.
    al_has_key/0,
    % al_connect/1: open a live session and list the games.
    al_connect/1,
    % al_connected/0: a live session is open.
    al_connected/0,
    % al_disconnect/0: close the scorecard and forget the live session.
    al_disconnect/0,
    % al_scorecard_open_body/1: the agent-tagged scorecard open request body.
    al_scorecard_open_body/1,
    % al_close_card/0: close the open scorecard on the server.
    al_close_card/0,
    % al_games/1: the live game environments.
    al_games/1,
    % al_game/2: query one live game by id.
    al_game/2,
    % al_reset/2: reset a live game and return its frame.
    al_reset/2,
    % al_act/3: apply one action to a live game.
    al_act/3,
    % al_render/2: the last frame of a live game.
    al_render/2,
    % al_actions/2: the actions a live game affords.
    al_actions/2,
    % al_solved/1: the live game's last state is WIN.
    al_solved/1,
    % al_state/2: the live game's last reported state.
    al_state/2,
    % al_status/1: the live connection status.
    al_status/1
]).

% Load the HTTP client and JSON codec.
:- use_module(library(http/http_open)).
% The JSON reader and writer.
:- use_module(library(http/json)).
% List helpers.
:- use_module(library(lists), [member/2, last/2]).

% ---------------------------------------------------------------------------
% Configuration
% ---------------------------------------------------------------------------

% al_base_/1: a runtime base-URL override.
:- dynamic al_base_/1.
% al_key_/1: a runtime API-key override.
:- dynamic al_key_/1.

% Define al_configure: set the base URL and API key at runtime.
al_configure(Base, Key) :-
    % Replace any previous base.
    retractall(al_base_(_)),
    % Record the base.
    assertz(al_base_(Base)),
    % Replace any previous key.
    retractall(al_key_(_)),
    % Record the key.
    assertz(al_key_(Key)).

% Define al_base: the API base URL — override, then environment, then default.
al_base(Base) :-
    % A runtime override wins.
    ( al_base_(B) -> Base = B
    % Else the environment variable.
    ; getenv('ARC_API_BASE', B), B \== '' -> Base = B
    % Else the public default.
    ; Base = 'https://three.arcprize.org'
    ).

% Define al_key: the API key — override, then environment, then key file.
al_key(Key) :-
    % A runtime override wins.
    ( al_key_(K), K \== '' -> Key = K
    % Else the environment variable.
    ; getenv('ARC_API_KEY', K), K \== '' -> Key = K
    % Else the first line of the key file, if present and non-empty.
    ; al_key_file(K), K \== '' -> Key = K
    ).

% al_key_file(-Key): read the first non-empty line of data/arc_api_key.txt.
al_key_file(Key) :-
    % The conventional key file path.
    File = 'data/arc_api_key.txt',
    % It must exist.
    exists_file(File),
    % Read its first line, guarded.
    catch(setup_call_cleanup(
        open(File, read, S),
        read_line_to_string(S, Line),
        close(S)), _, fail),
    % A real line, not end of file.
    string(Line),
    % Trim surrounding whitespace.
    normalize_space(atom(Key), Line),
    % It must be non-empty.
    Key \== ''.

% Define al_has_key: a key is available from any source.
al_has_key :-
    % There is a key.
    al_key(_).

% ---------------------------------------------------------------------------
% Session state
% ---------------------------------------------------------------------------

% al_card_/1: the open scorecard id.
:- dynamic al_card_/1.
% al_game_/2: (GameId, Title) — a live game environment.
:- dynamic al_game_/2.
% al_session_/5: (GameId, Guid, Frame2d, State, Actions) — per-game session.
:- dynamic al_session_/5.
% al_connected_/1: whether a live session is open.
:- dynamic al_connected_/1.
% al_error_/1: the last connection error, if any.
:- dynamic al_error_/1.

% Define al_connected: a live session is open.
al_connected :-
    % The connected flag is set.
    al_connected_(true).

% Define al_disconnect: close the scorecard on the server, then forget the
% live session and its games locally.
al_disconnect :-
    % Close the open scorecard on the server so the run is finalised, guarded.
    catch(al_close_card, _, true),
    % Drop the scorecard.
    retractall(al_card_(_)),
    % Drop the games.
    retractall(al_game_(_, _)),
    % Drop the sessions.
    retractall(al_session_(_, _, _, _, _)),
    % Clear the connected flag.
    retractall(al_connected_(_)).

% al_scorecard_open_body(-Body): the POST body for opening a scorecard. The tags
% mark this as an AI agent (never a human), and the opaque metadata identifies
% the agent, so results file under Mentova and are never confused with human
% play. Tags can only be set here, at open time; the ARC platform's web UI does
% not let a scorecard's tags be changed afterwards.
al_scorecard_open_body(
    _{ tags: ["agent", "mentova", "symbolic", "prologai"],
       % A link back to the agent's source, returned in the scorecard.
       source_url: "https://github.com/ai-university-aiu/Mentova",
       % Arbitrary identifying metadata: this is an AI agent, not a human.
       opaque: _{ agent: "Mentova",
                  kind: "ai_agent",
                  human: false,
                  engine: "PrologAI",
                  approach: "symbolic-causalontology" }
     }).

% Define al_close_card: close the currently open scorecard on the server, so the
% agent's run is finalised. Does nothing when no scorecard is open.
al_close_card :-
    % Only when a scorecard is open.
    ( al_card_(Card)
    % Post the close request with the card id; guarded so it never blocks.
    ->  catch(al_post('/api/scorecard/close', _{card_id: Card}, _), _, true)
    % No open scorecard: nothing to close.
    ;   true
    ).

% ---------------------------------------------------------------------------
% HTTP helpers — all guarded by the callers
% ---------------------------------------------------------------------------

% al_headers(-Headers): the request headers carrying the API key.
al_headers([request_header('X-API-Key' = Key),
            request_header('Accept' = 'application/json')]) :-
    % The key must be available.
    al_key(Key).

% al_get(+Path, -Json): GET a path and read the JSON reply.
al_get(Path, Json) :-
    % The base and full URL.
    al_base(Base), atom_concat(Base, Path, Url),
    % The auth headers.
    al_headers(H),
    % Open, read, and always close.
    setup_call_cleanup(
        http_open(Url, S, [timeout(12) | H]),
        json_read_dict(S, Json),
        close(S)).

% al_post(+Path, +BodyDict, -Json): POST a JSON body and read the JSON reply.
al_post(Path, BodyDict, Json) :-
    % The base and full URL.
    al_base(Base), atom_concat(Base, Path, Url),
    % The auth headers.
    al_headers(H),
    % Encode the body.
    with_output_to(string(Body), json_write_dict(current_output, BodyDict)),
    % Post, read, and always close.
    setup_call_cleanup(
        http_open(Url, S,
                  [ post(string('application/json', Body)), timeout(12) | H ]),
        json_read_dict(S, Json),
        close(S)).

% ---------------------------------------------------------------------------
% Connecting
% ---------------------------------------------------------------------------

% Define al_connect: open a scorecard, list the games, and record them.
al_connect(Result) :-
    % Any failure is reported honestly rather than thrown.
    catch(al_connect_(N), E, (retractall(al_error_(_)), assertz(al_error_(E)), fail))
    % Success reports the game count.
    ->  Result = connected(N)
    % Failure reports the recorded reason (or a generic one).
    ;   ( al_error_(E0) -> Result = error(E0) ; Result = error(unknown) ).

% al_connect_(-N): the connection work, which may throw.
al_connect_(N) :-
    % A key is required.
    ( al_has_key -> true ; throw(no_api_key) ),
    % List the games.
    al_get('/api/games', Games),
    % Open a fresh scorecard for this run, tagged as an AI agent (not a human)
    % so its results are filed under the agent, never mixed with human play.
    al_scorecard_open_body(Body),
    % Post the open request with the agent tags and identifying metadata.
    al_post('/api/scorecard/open', Body, Sc),
    % The scorecard id.
    ( get_dict(card_id, Sc, Card) -> true ; throw(no_card_id) ),
    % Forget any previous session.
    al_disconnect,
    % Record the scorecard.
    assertz(al_card_(Card)),
    % Record each game environment.
    forall(member(G, Games), al_record_game(G)),
    % Count them.
    aggregate_all(count, al_game_(_, _), N),
    % There must be at least one.
    N > 0,
    % Mark the session connected.
    assertz(al_connected_(true)),
    % Clear any stale error.
    retractall(al_error_(_)).

% al_record_game(+G): record one game from the /api/games entry.
al_record_game(G) :-
    % The game id is required.
    get_dict(game_id, G, Id0),
    % As an atom.
    ( atom(Id0) -> Id = Id0 ; atom_string(Id, Id0) ),
    % A title if present, else the id itself.
    ( get_dict(title, G, T0) -> ( atom(T0) -> Title = T0 ; atom_string(Title, T0) )
    ; Title = Id ),
    % Store it.
    assertz(al_game_(Id, Title)).

% Define al_games: the recorded live game environments.
al_games(Games) :-
    % One g(Id,Title) per recorded game.
    findall(g(Id, Title), al_game_(Id, Title), Games).

% Define al_game: query one recorded live game by id.
al_game(Id, Title) :-
    % Read the recorded game.
    al_game_(Id, Title).

% ---------------------------------------------------------------------------
% Playing a live game
% ---------------------------------------------------------------------------

% Define al_reset: reset a live game and return its current frame.
al_reset(GameId, Frame) :-
    % A scorecard must be open.
    al_card_(Card),
    % The base reset payload.
    Base0 = _{card_id: Card, game_id: GameId},
    % Carry a guid forward if one is known.
    ( al_session_(GameId, Guid, _, _, _), Guid \== none
    ->  Payload = Base0.put(guid, Guid)
    ;   Payload = Base0
    ),
    % Reset over HTTP, guarded.
    catch(al_post('/api/cmd/RESET', Payload, Resp), _, fail),
    % Store the reply and return the flattened frame.
    al_store(GameId, Resp, Frame).

% Define al_act: apply one action to a live game and return the next frame.
al_act(GameId, Action, Frame) :-
    % A guid from a prior reset is required.
    al_session_(GameId, Guid, _, _, _), Guid \== none,
    % The wire command name and any coordinates.
    al_action_name(Action, Cmd, XY),
    % The command path.
    atom_concat('/api/cmd/', Cmd, Path),
    % The base action payload.
    Base0 = _{game_id: GameId, guid: Guid},
    % Add coordinates for the cell-select action.
    ( XY = xy(X, Y) -> Payload = Base0.put(_{x: X, y: Y}) ; Payload = Base0 ),
    % Act over HTTP, guarded.
    catch(al_post(Path, Payload, Resp), _, fail),
    % Store the reply and return the flattened frame.
    al_store(GameId, Resp, Frame).

% al_store(+GameId, +Resp, -Frame): record the reply and flatten the frame.
al_store(GameId, Resp, Frame) :-
    % The new guid, or the old one if the reply omits it.
    ( get_dict(guid, Resp, G0), G0 \== null -> Guid = G0
    ; al_session_(GameId, GOld, _, _, _) -> Guid = GOld
    ; Guid = none ),
    % The reported state as an atom, defaulting to unknown.
    ( get_dict(state, Resp, S0) -> al_atomize(S0, State) ; State = 'NOT_FINISHED' ),
    % The available actions, mapped to Mentova action terms.
    ( get_dict(available_actions, Resp, AA) -> al_map_actions(AA, Actions)
    ; Actions = [action(1), action(2), action(3), action(4), action(5)] ),
    % The frame, flattened to a single two-dimensional grid.
    ( get_dict(frame, Resp, RawFrame) -> al_frame2d(RawFrame, Frame)
    ; Frame = [[0]] ),
    % Replace the session record.
    retractall(al_session_(GameId, _, _, _, _)),
    % Store the new one.
    assertz(al_session_(GameId, Guid, Frame, State, Actions)).

% Define al_render: the last frame of a live game, resetting if it is fresh.
al_render(GameId, Frame) :-
    % Use the cached frame when there is one.
    ( al_session_(GameId, _, Frame0, _, _) -> Frame = Frame0
    % Otherwise reset to obtain the first frame.
    ; al_reset(GameId, Frame)
    ).

% Define al_actions: the actions a live game affords.
al_actions(GameId, Actions) :-
    % From the last session, or the simple default set.
    ( al_session_(GameId, _, _, _, As), As \== [] -> Actions = As
    ; Actions = [action(1), action(2), action(3), action(4), action(5)]
    ).

% Define al_solved: the live game's last reported state is WIN.
al_solved(GameId) :-
    % The recorded state.
    al_session_(GameId, _, _, State, _),
    % It must be the winning state.
    ( State == 'WIN' ; State == "WIN" ).

% Define al_state: the live game's last reported state.
al_state(GameId, State) :-
    % Read it, or report none.
    ( al_session_(GameId, _, _, S, _) -> State = S ; State = none ).

% ---------------------------------------------------------------------------
% Mapping helpers
% ---------------------------------------------------------------------------

% al_action_name(?Action, ?Command, ?Coords): map a Mentova action to the wire.
% The five simple actions map to ACTION1..ACTION5.
al_action_name(action(N), Cmd, none) :-
    % A simple action number.
    integer(N), N >= 1, N =< 5,
    % Its command name.
    atom_concat('ACTION', N, Cmd).
% The cell-select maps to ACTION6 with coordinates.
al_action_name(select(X, Y), 'ACTION6', xy(X, Y)).
% Undo maps to ACTION7.
al_action_name(undo, 'ACTION7', none).

% al_map_actions(+Names, -Actions): map available_action names to Mentova terms.
al_map_actions(Names, Actions) :-
    % Map each name that we can play; drop RESET and anything unknown.
    findall(A,
        ( member(NameRaw, Names),
          al_atomize(NameRaw, Name),
          al_name_to_action(Name, A) ),
        Actions0),
    % Fall back to the simple set if nothing usable was reported.
    ( Actions0 == [] -> Actions = [action(1), action(2), action(3), action(4), action(5)]
    ; Actions = Actions0 ).

% al_name_to_action(+Name, -Action): one wire action name to a Mentova term.
% ACTION1..ACTION5 become the simple actions, with an INTEGER argument.
al_name_to_action('ACTION1', action(1)).
% The second simple action.
al_name_to_action('ACTION2', action(2)).
% The third simple action.
al_name_to_action('ACTION3', action(3)).
% The fourth simple action.
al_name_to_action('ACTION4', action(4)).
% The fifth simple action.
al_name_to_action('ACTION5', action(5)).
% ACTION6 becomes a centre click, a reasonable default target.
al_name_to_action('ACTION6', select(32, 32)).
% ACTION7 is the undo action, offered only by games that support it.
al_name_to_action('ACTION7', undo).

% al_atomize(+X, -Atom): coerce a string or atom to an atom.
al_atomize(X, X) :- atom(X), !.
% A string becomes an atom.
al_atomize(X, A) :- string(X), !, atom_string(A, X).
% Anything else is rendered.
al_atomize(X, A) :- term_to_atom(X, A).

% al_frame2d(+Raw, -Grid): flatten the reply's frame to one two-dimensional grid.
% A single two-dimensional grid (rows of integers) is used as is.
al_frame2d(Raw, Raw) :-
    % It is a list whose first row's first cell is an integer.
    Raw = [Row | _], Row = [Cell | _], integer(Cell), !.
% A stack of grids (a list of two-dimensional grids) uses the last grid.
al_frame2d(Raw, Grid) :-
    % It is a list whose first element is itself a grid.
    Raw = [G | _], G = [Row | _], is_list(Row), !,
    % The current frame is the last in the stack.
    last(Raw, Grid).
% Anything else degrades to a single empty cell.
al_frame2d(_, [[0]]).

% ---------------------------------------------------------------------------
% Status
% ---------------------------------------------------------------------------

% Define al_status: the live connection status, for the page and the report.
al_status(_{key_configured: HasKey, connected: Conn, base: Base,
            games: Games, error: ErrText}) :-
    % Whether a key is available.
    ( al_has_key -> HasKey = true ; HasKey = false ),
    % Whether a session is open.
    ( al_connected -> Conn = true ; Conn = false ),
    % The base URL.
    al_base(Base),
    % The recorded games as dicts.
    findall(_{id: Id, title: Title}, al_game_(Id, Title), Games),
    % The last error, if any.
    ( al_error_(E) -> term_to_atom(E, ErrText) ; ErrText = "none" ).

% Load aggregation for the game count.
:- use_module(library(aggregate), [aggregate_all/3]).
