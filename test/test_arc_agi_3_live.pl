/*  Mentova — Live ARC-AGI-3 Environment Client Test Suite

    Behavioural PLUnit tests for the arc_agi_3_live module. Every test here is
    offline: it exercises the client's pure configuration, its agent-tagged
    scorecard body, its status dict, and its no-session default answers, none
    of which touch the network. The connect/reset/act path (which needs a live
    ARC-AGI-3 server and a real key) is deliberately not exercised, so the suite
    runs green anywhere.

    Run with the full library path:
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_arc_agi_3_live.pl
*/

% Declare this file as a test module with no exports.
:- module(test_arc_agi_3_live, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the live ARC-AGI-3 client module under test from the library path.
:- use_module(library(arc_agi_3_live)).

% Open the test block for arc_agi_3_live.
:- begin_tests(arc_agi_3_live).

% Configuring the client sets both the base URL and the key at runtime.
test(configure_sets_base_and_key) :-
    % Set a harmless local base and a dummy key at runtime.
    al_configure('http://127.0.0.1:9', 'k-test'),
    % The base URL now reads back the configured override.
    al_base(Base),
    % It is exactly the base we configured.
    assertion(Base == 'http://127.0.0.1:9'),
    % The key now reads back the configured override.
    al_key(Key),
    % It is exactly the key we configured.
    assertion(Key == 'k-test'),
    % A key being available, al_has_key succeeds.
    assertion(al_has_key).

% The scorecard open body tags the run as an AI agent, never a human.
test(scorecard_open_body_is_agent_tagged) :-
    % Read the scorecard open request body.
    al_scorecard_open_body(Body),
    % Its tags list marks this as the Mentova symbolic agent.
    get_dict(tags, Body, Tags),
    % The tags are exactly the four agent tags.
    assertion(Tags == ["agent", "mentova", "symbolic", "prologai"]),
    % Its opaque metadata block identifies the agent.
    get_dict(opaque, Body, Opaque),
    % The metadata records the kind as an AI agent.
    get_dict(kind, Opaque, Kind),
    % That kind is the ai_agent string.
    assertion(Kind == "ai_agent"),
    % The metadata's human flag is false.
    get_dict(human, Opaque, Human),
    % The run is explicitly not a human.
    assertion(Human == false).

% The status dict reports a configured key, no session, and the configured base.
test(status_reports_configured_and_disconnected) :-
    % Configure a local base and a dummy key.
    al_configure('http://127.0.0.1:9', 'k-test'),
    % Forget any prior session so the status is a clean disconnected one.
    al_disconnect,
    % Read the connection status dict.
    al_status(Status),
    % A key is configured.
    get_dict(key_configured, Status, HasKey),
    % So key_configured is true.
    assertion(HasKey == true),
    % No live session is open.
    get_dict(connected, Status, Conn),
    % So connected is false.
    assertion(Conn == false),
    % The status echoes the configured base URL.
    get_dict(base, Status, StatusBase),
    % Which is the base we configured.
    assertion(StatusBase == 'http://127.0.0.1:9'),
    % With no session, no games are recorded.
    get_dict(games, Status, Games),
    % So the games list is empty.
    assertion(Games == []).

% With no session for a game, its afforded actions default to the five simple ones.
test(actions_default_without_session) :-
    % Forget any prior session so no game has one.
    al_disconnect,
    % Ask which actions an unseen game affords.
    al_actions(some_unseen_game, Actions),
    % The answer is the simple default action set.
    assertion(Actions == [action(1), action(2), action(3), action(4), action(5)]).

% With no session for a game, its last state reads back as none.
test(state_none_without_session) :-
    % Forget any prior session so no game has one.
    al_disconnect,
    % Ask for the last reported state of an unseen game.
    al_state(some_unseen_game, State),
    % Having no session, the state is none.
    assertion(State == none).

% With no recorded progress, a game reports zero levels completed and zero to win.
test(progress_zero_without_record) :-
    % Forget any prior session and its progress records.
    al_disconnect,
    % Ask for the progress of an unseen game.
    al_progress(some_unseen_game, LevelsCompleted, WinLevels),
    % Having no record, the levels completed default to zero.
    assertion(LevelsCompleted == 0),
    % And the win threshold defaults to zero.
    assertion(WinLevels == 0).

% After disconnecting there is no session, so no games are listed and none are connected.
test(disconnect_clears_session) :-
    % Configure so a key is present but no games are recorded.
    al_configure('http://127.0.0.1:9', 'k-test'),
    % Forget any prior session.
    al_disconnect,
    % The recorded game list is now empty.
    al_games(GamesAfter),
    % So no games remain.
    assertion(GamesAfter == []),
    % And no live session is open.
    assertion(\+ al_connected).

% Close the test block for arc_agi_3_live.
:- end_tests(arc_agi_3_live).
