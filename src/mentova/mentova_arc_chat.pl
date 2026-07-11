/*  Mentova — mentova_arc_agi_3_chat: Human-Guided Learning over ARC-AGI-3  (Acc_426)

    The application of Causalontology_v5, Section 10: a split screen whose
    upper region shows an ARC-style game being played and whose lower region
    is a chat in which a human guide gives clues — "that looks like a key,"
    "pick that up," "that looks like a door; let's walk through it," "don't
    touch that" — which Mentova grounds into Causalontology assertions and
    learns from, so that on later runs it plays with less help.

    It extends the existing Mentova chat exactly as Appendix D prescribes:
    the guiding human is a mentor (chat_db's mc_verify_session), each clue is
    a proposed fact routed through the teach queue (mc_propose_fact) with a
    game-play auto-approve (mc_approve_fact), and a justification endpoint
    shows why Mentova took its last action. The game loop is the co_arc3
    machinery of the PrologAI Causalontology suite, and hints bias exactly
    the levers Section 10.4 names: a posited continuant labels an object, a
    suggested action raises its priority, a posited goal is handed to the
    planner, and a preventive tag is enforced like a self-learned hazard.

    The built-in game is locksmith-flavored (ls20's theme, chosen in
    Section 10.1 precisely because its keys, locks, and doors match the
    clue examples): a five-by-five world with a player, a key, a locked
    door, and a hidden trap. Values: 0 empty, 3 player, 4 key, 8 locked
    door, 6 open door, 15 the penalty marker.

    Routes (extending the chat's route table):
      GET  /arc              the split-screen page
      GET  /api/arc/frame    current frame + status as JSON
      POST /api/arc/control  {token, cmd: reset | step | auto, budget}
      POST /api/arc/hint     {token, text, ref: [R, C]} -> grounded clue
      GET  /api/arc/why      why Mentova took the last action

    Safety and honesty (Section 10.6): hint text passes a safety check; a
    human-declared hazard is enforced exactly as a self-learned one; and a
    clue is high-confidence but defeasible — provenance marks it
    human-originated, so guidance and discovery stay distinguishable.

    Run the server:
      swipl -l src/mentova/mentova_arc_chat.pl \
            -g "ma_db_init('data/chat_db'), ma_start_server(8090)" -t halt

    Predicates:
      ma_db_init/1        -- attach the chat database (mentor auth + queue)
      ma_start_server/1   -- start the HTTP server on a port
      ma_stop_server/1    -- stop it
      ma_game_reset/1     -- reset the game, returning the first frame
      ma_game_frame/1     -- the current frame
      ma_env/1            -- the game as a pluggable co_arc3 environment
      co_ground/3         -- natural-language clue -> Causalontology assertion
      ma_inject/1         -- bias the live loop with a grounded assertion
      ma_step/1           -- one guided loop step, with its basis recorded
      ma_auto/2           -- run steps until won or budget exhausted
      ma_why/1            -- why Mentova took the last action
      ma_reset_guidance/0 -- clear hints, priorities, goals, and learning
*/

% Declare this file as the arc chat module and list its exports.
:- module(mentova_arc_chat, [
    % ma_db_init/1: attach the chat database.
    ma_db_init/1,
    % ma_start_server/1: start the HTTP server.
    ma_start_server/1,
    % ma_stop_server/1: stop the HTTP server.
    ma_stop_server/1,
    % ma_game_reset/1: reset the locksmith game.
    ma_game_reset/1,
    % ma_game_frame/1: the current frame.
    ma_game_frame/1,
    % ma_env/1: the game as a co_arc3 environment.
    ma_env/1,
    % co_ground/3: clue text to Causalontology assertion.
    co_ground/3,
    % ma_inject/1: bias the loop with a grounded assertion.
    ma_inject/1,
    % ma_step/1: one guided loop step.
    ma_step/1,
    % ma_auto/2: run to a win or a budget.
    ma_auto/2,
    % ma_why/1: the justification of the last action.
    ma_why/1,
    % ma_reset_guidance/0: clear all guidance and learning.
    ma_reset_guidance/0,
    % ma_mode/1: the active mode (guided | solo).
    ma_mode/1,
    % ma_set_mode/1: switch the active mode.
    ma_set_mode/1,
    % ma_selected_game/1: the selected game environment id.
    ma_selected_game/1,
    % ma_set_game/1: select a game environment.
    ma_set_game/1,
    % ma_game_info/2: a game environment id and its human title.
    ma_game_info/2,
    % ma_render/2: render the current frame of a selected environment.
    ma_render/2,
    % ma_restart/2: restart the selected environment in the active mode.
    ma_restart/2,
    % ma_solo_tick/1: advance the solo run one step, with telemetry.
    ma_solo_tick/1,
    % ma_solo_report/2: write a solo attempt report and return its filename.
    ma_solo_report/2,
    % ma_attempts_dir/1: the directory solo reports are written to.
    ma_attempts_dir/1,
    % ma_attempts_list/1: the solo attempt report filenames, newest first.
    ma_attempts_list/1,
    % ma_learnings/1: the shared learnings both sub-projects read.
    ma_learnings/1,
    % ma_source/1: the active game source (local | live).
    ma_source/1,
    % ma_set_source/1: switch the active game source.
    ma_set_source/1,
    % ma_available_game/2: a game environment in the active source.
    ma_available_game/2
]).

% Register the PrologAI Causalontology pack directories before any
% use_module fires (Form A self-contained loading).
:- initialization((
    % The grid pack for frames and diffs.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/grid/prolog')),
    % The Causalontology core.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_core/prolog')),
    % The hinge.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_hinge/prolog')),
    % The noun backbone.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_noun/prolog')),
    % The interventional learner.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_learn/prolog')),
    % The planner.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_plan/prolog')),
    % The Jacobian Space (J-Space) concept workspace the solo run holds learnings in.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/jspace/prolog')),
    % The harness.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_arc3/prolog'))
), now).

% Load the Causalontology noun backbone for clue-labeled continuants.
:- use_module(library(co_noun), [co_continuant_add/2, co_continuant/2]).
% Load the hinge for clue-attached dispositions.
:- use_module(library(co_hinge), [co_realizable_add/3, co_realized_in_add/2]).
% Load the core for provenance-tagged clue relations and reinforcement.
:- use_module(library(co_core), [co_new_cro/8, co_cro/8, co_strengthen/2]).
% Load the learner for preventive enforcement.
:- use_module(library(co_learn), [co_learn_preventive/2, co_avoid/1, co_learn_causal/2]).
% Load the harness for curiosity choice and frame deltas.
:- use_module(library(co_arc3), [co_arc3_choose/3, co_arc3_delta/3, co_arc3_reset/0]).
% Load grid measurement for inferring an action's observed effect (its semantic).
:- use_module(library(grid), [gd_diff/3, gd_colors/2, gd_size/3, gd_cell/4]).
% Load list arithmetic for the centroid computation.
:- use_module(library(lists), [sum_list/2]).
% Load the Jacobian Space workspace so the solo run holds its learnings in J-Space.
:- use_module(library(jspace), [js_open/1, js_hold/4, js_reading/2]).
% Load the live ARC-AGI-3 client so the dropdown can offer the real environments.
:- use_module('arc_agi_3_live',
    [al_connect/1, al_connected/0, al_disconnect/0, al_game/2, al_games/1,
     al_render/2, al_reset/2, al_act/3, al_actions/2, al_solved/1,
     al_status/1, al_has_key/0]).
% Load the chat database: mentor auth and the teach queue.
:- use_module('chat_db', [mc_db_init/1, mc_verify_session/2, mc_propose_fact/4, mc_approve_fact/2]).
% Load the HTTP server framework, exactly as the chat uses it.
:- use_module(library(http/thread_httpd)).
% Load the route dispatcher.
:- use_module(library(http/http_dispatch)).
% Load the JSON request and reply helpers.
:- use_module(library(http/http_json)).
% Load the parameter reader for GET endpoints.
:- use_module(library(http/http_parameters)).
% Load list helpers.
:- use_module(library(lists), [member/2, memberchk/2]).
% Load aggregation for counting learned relations.
:- use_module(library(aggregate), [aggregate_all/3]).

% ---------------------------------------------------------------------------
% ROUTES
% ---------------------------------------------------------------------------

% The split-screen page.
:- http_handler(root(arc), ma_handle_page, []).
% The current frame as JSON.
:- http_handler(root(api/arc/frame), ma_handle_frame, []).
% The control endpoint: reset, step, auto.
:- http_handler(root(api/arc/control), ma_handle_control, []).
% The clue endpoint: ground and inject a human hint.
:- http_handler(root(api/arc/hint), ma_handle_hint, []).
% The justification endpoint: why the last action.
:- http_handler(root(api/arc/why), ma_handle_why, []).
% The mode endpoint: read or switch Guided/Solo.
:- http_handler(root(api/arc/mode), ma_handle_mode, []).
% The game list endpoint: the selectable ARC-AGI-3 environments.
:- http_handler(root(api/arc/games), ma_handle_games, []).
% The selection endpoint: choose the active game environment.
:- http_handler(root(api/arc/select), ma_handle_select, []).
% The restart endpoint: restart the selected environment in the active mode.
:- http_handler(root(api/arc/restart), ma_handle_restart, []).
% The solo telemetry endpoint: advance one solo step and report what happened.
:- http_handler(root(api/arc/solo/tick), ma_handle_solo_tick, []).
% The attempts list endpoint: the solo report filenames as JSON.
:- http_handler(root(api/arc/attempts), ma_handle_attempts, []).
% The attempt view endpoint: one solo report as plain text.
:- http_handler(root(api/arc/attempts/view), ma_handle_attempt_view, []).
% The attempts record page: the separate listing page.
:- http_handler(root(arc/attempts), ma_handle_attempts_page, []).
% The live status endpoint: the live connection state.
:- http_handler(root(api/arc/live/status), ma_handle_live_status, []).
% The live connect endpoint: connect the real ARC-AGI-3 environments.
:- http_handler(root(api/arc/live/connect), ma_handle_live_connect, []).
% The live disconnect endpoint: return to the local stand-ins.
:- http_handler(root(api/arc/live/disconnect), ma_handle_live_disconnect, []).
% The actions endpoint: the labelled action panel for the selected game.
:- http_handler(root(api/arc/actions), ma_handle_actions, []).
% The conclude endpoint: learn from a won game, then restart it.
:- http_handler(root(api/arc/conclude), ma_handle_conclude, []).

% Define ma_db_init: attach the chat database this application reuses.
ma_db_init(Dir) :-
    % The mentor accounts, sessions, and teach queue live there.
    mc_db_init(Dir).

% Define ma_start_server: start the threaded HTTP server.
ma_start_server(Port) :-
    % The same server framework as the existing chat.
    http_server(http_dispatch, [port(Port)]).

% Define ma_stop_server: stop the server on a port.
ma_stop_server(Port) :-
    % Stop it, tolerating an already-stopped server.
    catch(http_stop_server(Port, []), _, true).

% ---------------------------------------------------------------------------
% THE LOCKSMITH GAME — keys, locks, and doors, plus one hidden trap
% ---------------------------------------------------------------------------

% ma_state_/4: (PlayerPos, KeyState, DoorOpen, TrapFlash) — the game state.
% KeyState is at(R, C) or held; TrapFlash marks a penalty frame.
:- dynamic ma_state_/4.

% The fixed board: where things start.
ma_start_pos(pos(4, 0)).
% The key's starting cell.
ma_key_pos(pos(2, 2)).
% The door's cell.
ma_door_pos(pos(0, 4)).
% The hidden trap's cell.
ma_trap_pos(pos(3, 3)).

% Define ma_game_reset: back to the start; the first frame is returned.
ma_game_reset(Frame) :-
    % Clear the state.
    retractall(ma_state_(_, _, _, _)),
    % Fetch the starting position.
    ma_start_pos(P),
    % Fetch the key's cell.
    ma_key_pos(K),
    % The door starts locked and no trap is flashing.
    assertz(ma_state_(P, at_cell(K), false, false)),
    % Render the first frame.
    ma_game_frame(Frame).

% Define ma_game_frame: render the state as a five-by-five grid.
ma_game_frame(Frame) :-
    % Fetch the state.
    ma_state_(pos(PR, PC), KeyState, DoorOpen, TrapFlash),
    % Fetch the fixed cells.
    ma_door_pos(pos(DR, DC)),
    % The trap's cell.
    ma_trap_pos(pos(TR, TC)),
    % Render row by row.
    findall(Row,
        % Each of the five rows.
        ( between(0, 4, R),
          % Render the cells of this row.
          findall(V,
              % Each of the five columns.
              ( between(0, 4, C),
                % Decide the value of this cell.
                ma_cell_value(R, C, PR, PC, KeyState, DR, DC, DoorOpen,
                              TR, TC, TrapFlash, V) ),
              Row) ),
        Frame).

% ma_cell_value(...): the rendering rules, first match wins.
ma_cell_value(R, C, _, _, _, _, _, _, TR, TC, true, 15) :-
    % A flashing trap shows the penalty marker.
    R == TR, C == TC, !.
% An open door renders over everything else: the player has walked through.
ma_cell_value(R, C, _, _, _, DR, DC, true, _, _, _, 6) :-
    % The door's cell, once opened.
    R == DR, C == DC, !.
% The player.
ma_cell_value(R, C, PR, PC, _, _, _, _, _, _, _, 3) :-
    % The player's cell.
    R == PR, C == PC, !.
% The key, while it lies on the board.
ma_cell_value(R, C, _, _, at_cell(pos(R, C)), _, _, _, _, _, _, 4) :- !.
% The door, open or locked.
ma_cell_value(R, C, _, _, _, DR, DC, DoorOpen, _, _, _, V) :-
    % The door's cell.
    R == DR, C == DC, !,
    % Open shows six; locked shows eight.
    ( DoorOpen == true -> V = 6 ; V = 8 ).
% Everything else is empty.
ma_cell_value(_, _, _, _, _, _, _, _, _, _, _, 0).

% ma_move_delta(+Action, -DR, -DC): the four movement actions.
ma_move_delta(action(up), -1, 0).
% Down.
ma_move_delta(action(down), 1, 0).
% Left.
ma_move_delta(action(left), 0, -1).
% Right.
ma_move_delta(action(right), 0, 1).

% ma_env_act(+Action, -Frame1): the game's hidden mechanics.
ma_env_act(Action, Frame1) :-
    % Fetch the state, clearing any trap flash from the last turn.
    retract(ma_state_(pos(PR, PC), KeyState, DoorOpen, _)),
    % Decide what the action does.
    (   ma_move_delta(Action, DR, DC)
    % A movement action.
    ->  R1 is max(0, min(4, PR + DR)),
        % The candidate column.
        C1 is max(0, min(4, PC + DC)),
        % Fetch the special cells.
        ma_trap_pos(Trap),
        % The door's cell.
        ma_door_pos(Door),
        % Resolve the move.
        (   pos(R1, C1) == Trap
        % Stepping onto the trap hurts: bounce back, flash the marker.
        ->  assertz(ma_state_(pos(PR, PC), KeyState, DoorOpen, true))
        % Moving onto the locked door without the key is blocked.
        ;   pos(R1, C1) == Door, DoorOpen == false, KeyState \== held
        ->  assertz(ma_state_(pos(PR, PC), KeyState, DoorOpen, false))
        % Moving onto the door with the key opens it — the win.
        ;   pos(R1, C1) == Door, KeyState == held
        ->  assertz(ma_state_(pos(R1, C1), held, true, false))
        % An ordinary move.
        ;   assertz(ma_state_(pos(R1, C1), KeyState, DoorOpen, false))
        )
    % The pickup action takes the key when standing on it.
    ;   Action == action(pickup)
    ->  (   KeyState == at_cell(pos(PR, PC))
        % Standing on the key: take it.
        ->  assertz(ma_state_(pos(PR, PC), held, DoorOpen, false))
        % Otherwise nothing happens.
        ;   assertz(ma_state_(pos(PR, PC), KeyState, DoorOpen, false))
        )
    % Any other action does nothing.
    ;   assertz(ma_state_(pos(PR, PC), KeyState, DoorOpen, false))
    ),
    % Render the resulting frame.
    ma_game_frame(Frame1).

% ma_env_actions(-Actions): the game's small action set.
ma_env_actions([action(up), action(down), action(left), action(right), action(pickup)]).

% ma_env_solved(+Frame): the door shows open — the level is won.
ma_env_solved(Frame) :-
    % An open door renders as six.
    member(Row, Frame),
    % Somewhere in the frame.
    memberchk(6, Row).

% Define ma_env: the game as a pluggable co_arc3 environment.
ma_env(arc3_env(mentova_arc_chat:ma_game_reset,
                mentova_arc_chat:ma_env_act,
                mentova_arc_chat:ma_env_actions,
                mentova_arc_chat:ma_env_solved)).

% ---------------------------------------------------------------------------
% GAME ENVIRONMENT REGISTRY — the dropdown's selectable environments
% ---------------------------------------------------------------------------
% Three local ARC-AGI-3-style environments, each a working co_arc3 game. The
% locksmith (ls20) is the fully-guided one; navigate (vc33) and signal (ft09)
% are additional environments the solo player can attempt. Every environment
% offers a uniform interface: render, reset, act, actions, and solved.

% ma_game_info(?Id, ?Title): a game environment id and its human-readable title.
ma_game_info(ls20, 'Locksmith — find the key, open the door (ls20 theme)').
% The navigation environment.
ma_game_info(vc33, 'Navigate — steer the avatar to the goal cell (vc33 theme)').
% The signal environment.
ma_game_info(ft09, 'Signal — raise the counter to complete the level (ft09 theme)').

% ma_game_sel_/1: the selected game environment id.
:- dynamic ma_game_sel_/1.

% Define ma_selected_game: the selected environment, defaulting per source.
ma_selected_game(Id) :-
    % Read the selection, or fall back to the active source's default.
    ( ma_game_sel_(Id) -> true ; ma_default_game(Id) ).

% Define ma_set_game: select a game environment and reset it to its start.
ma_set_game(Id) :-
    % The id must be available in the active source.
    ma_available_game(Id, _),
    % Replace any previous selection.
    retractall(ma_game_sel_(_)),
    % Record the new selection.
    assertz(ma_game_sel_(Id)),
    % A different game has its own action semantics: forget the discovered ones.
    retractall(ma_effect_(_, _)),
    % Start the newly selected environment fresh.
    ma_reset_env(Id, _),
    % Begin a fresh session recording for the new game.
    ma_session_reset,
    % Selecting a game also ends any solo run in progress.
    ma_solo_clear.

% Uniform dispatch — render the current frame, routing to live or local.
ma_render(Id, Frame) :-
    % A live game renders from the live client; a local one from its state.
    ( ma_is_live(Id) -> al_render(Id, Frame) ; ma_local_render(Id, Frame) ).
% Uniform dispatch — reset, routing to live or local.
ma_reset_env(Id, Frame) :-
    % Reset the live game or the local one.
    ( ma_is_live(Id) -> al_reset(Id, Frame) ; ma_local_reset(Id, Frame) ).
% Uniform dispatch — act, routing to live or local.
ma_act_env(Id, Action, Frame) :-
    % Act on the live game or the local one.
    ( ma_is_live(Id) -> al_act(Id, Action, Frame) ; ma_local_act(Id, Action, Frame) ).
% Uniform dispatch — actions, routing to live or local.
ma_actions_env(Id, Actions) :-
    % The live game's actions or the local one's.
    ( ma_is_live(Id) -> al_actions(Id, Actions) ; ma_local_actions(Id, Actions) ).
% Uniform dispatch — solved, routing to live or local.
ma_solved_env(Id, Frame) :-
    % The live game's win test or the local one's.
    ( ma_is_live(Id) -> al_solved(Id) ; ma_local_solved(Id, Frame) ).

% ma_is_live(+Id): the id names a live game and the live source is active.
ma_is_live(Id) :-
    % The live source must be selected.
    ma_source(live),
    % And the id must be one of the fetched live games.
    al_game(Id, _).

% Local render dispatch — the locksmith renders from its own state.
ma_local_render(ls20, Frame) :- ma_game_frame(Frame).
% The navigation environment renders from the avatar position.
ma_local_render(vc33, Frame) :- ma_nav_render(Frame).
% The signal environment renders from the counter.
ma_local_render(ft09, Frame) :- ma_sig_render(Frame).

% Local reset dispatch — the locksmith reset also clears its state.
ma_local_reset(ls20, Frame) :- ma_game_reset(Frame).
% The navigation reset places the avatar at the start.
ma_local_reset(vc33, Frame) :- ma_nav_reset(Frame).
% The signal reset zeroes the counter.
ma_local_reset(ft09, Frame) :- ma_sig_reset(Frame).

% Local act dispatch — the locksmith mechanics.
ma_local_act(ls20, Action, Frame) :- ma_env_act(Action, Frame).
% The navigation mechanics.
ma_local_act(vc33, Action, Frame) :- ma_nav_act(Action, Frame).
% The signal mechanics.
ma_local_act(ft09, Action, Frame) :- ma_sig_act(Action, Frame).

% Local action-set dispatch — the locksmith action set.
ma_local_actions(ls20, As) :- ma_env_actions(As).
% The navigation action set: the four moves.
ma_local_actions(vc33, [action(up), action(down), action(left), action(right)]).
% The signal action set: increment or idle.
ma_local_actions(ft09, [action(pickup), action(up)]).

% Local solved dispatch — the locksmith is solved when the door is open.
ma_local_solved(ls20, Frame) :- ma_env_solved(Frame).
% Navigation is solved when the avatar is on the goal.
ma_local_solved(vc33, _) :- ma_nav_(R, C), ma_nav_goal(GR, GC), R =:= GR, C =:= GC.
% Signal is solved when the counter reaches two.
ma_local_solved(ft09, _) :- ma_sig_(L), L >= 2.

% ma_source_/1: the active game source (local stand-ins or live environments).
:- dynamic ma_source_/1.

% ma_source(?Source): the active source, defaulting to the local stand-ins.
ma_source(Source) :-
    % Read it, or fall back to local.
    ( ma_source_(Source) -> true ; Source = local ).

% ma_set_source(+Source): switch between the local and live game sources.
ma_set_source(Source) :-
    % Only the two sources are valid.
    memberchk(Source, [local, live]),
    % Replace the previous source.
    retractall(ma_source_(_)),
    % Record it.
    assertz(ma_source_(Source)).

% ma_available_game(?Id, ?Title): a game environment in the active source.
ma_available_game(Id, Title) :-
    % Live games when connected live; the three local stand-ins otherwise.
    ( ma_source(live) -> al_game(Id, Title) ; ma_game_info(Id, Title) ).

% ma_default_game(-Id): the default selection for the active source.
ma_default_game(Id) :-
    % The first live game when live, else the locksmith.
    ( ma_source(live), al_game(Live, _) -> Id = Live ; Id = ls20 ), !.

% ---------------------------------------------------------------------------
% ACTION LABELS — canonical protocol names, with discovered/assumed semantics
% ---------------------------------------------------------------------------
% ARC-AGI-3 does not reveal what each action does; the true names are ACTION1
% through ACTION7. A directional word like "up" is only ever a guess (for a
% live game) or the design of one of our local stand-ins. So the panel is
% labelled by the canonical command, and any semantic is shown as discovered
% (learned by playing, marked with a "?") or as the local stand-in's own
% design, or left unknown.

% ma_effect_/2: (Action, Descriptor) — the last observed effect of an action.
:- dynamic ma_effect_/2.

% ma_action_slot(?Action, ?Command): map an action term to its canonical command.
% The local stand-ins' directional actions occupy ACTION1..ACTION5 by convention.
ma_action_slot(action(up), 'ACTION1').
% Down.
ma_action_slot(action(down), 'ACTION2').
% Left.
ma_action_slot(action(left), 'ACTION3').
% Right.
ma_action_slot(action(right), 'ACTION4').
% Pickup.
ma_action_slot(action(pickup), 'ACTION5').
% A live simple action already carries its number.
ma_action_slot(action(N), Cmd) :- integer(N), atom_concat('ACTION', N, Cmd).
% The cell-select action is ACTION6.
ma_action_slot(select(_, _), 'ACTION6').
% Undo is ACTION7.
ma_action_slot(undo, 'ACTION7').

% ma_local_semantic(?Action, ?Word): the design semantic of a local stand-in action.
ma_local_semantic(action(up), up).
% Down.
ma_local_semantic(action(down), down).
% Left.
ma_local_semantic(action(left), left).
% Right.
ma_local_semantic(action(right), right).
% Pickup.
ma_local_semantic(action(pickup), pickup).

% ma_record_effect(+Action, +Frame0, +Frame1): learn an action's observed effect.
ma_record_effect(Action, Frame0, Frame1) :-
    % Infer a coarse effect descriptor from the frame change.
    ma_infer_move(Frame0, Frame1, Desc),
    % Replace the previous observation for this action.
    retractall(ma_effect_(Action, _)),
    % Record the latest.
    assertz(ma_effect_(Action, Desc)).

% ma_infer_move(+Frame0, +Frame1, -Desc): a coarse effect from the frame change.
ma_infer_move(Frame0, Frame1, Desc) :-
    % The differing cells.
    gd_diff(Frame0, Frame1, Diffs),
    (   Diffs == []
    % Nothing changed.
    ->  Desc = none
    % A dominant object shifted: report the direction.
    ;   ma_centroid_shift(Frame0, Frame1, DR, DC), (DR =\= 0 ; DC =\= 0)
    ->  ( DR < 0, DC =:= 0 -> Desc = up
        ; DR > 0, DC =:= 0 -> Desc = down
        ; DC < 0, DR =:= 0 -> Desc = left
        ; DC > 0, DR =:= 0 -> Desc = right
        ; Desc = moves )
    % Otherwise cells changed without a clean translation.
    ;   Desc = changes
    ).

% ma_centroid_shift(+F0, +F1, -DR, -DC): the shift of the most-moved colour.
ma_centroid_shift(F0, F1, DR, DC) :-
    % The colours present in the first frame, minus the background.
    gd_colors(F0, Colours),
    % Score each colour's centroid displacement.
    findall(Mag-(dr(R) - dc(C)),
        ( member(Col, Colours), Col =\= 0,
          ma_colour_centroid(F0, Col, R0, C0),
          ma_colour_centroid(F1, Col, R1, C1),
          R is R1 - R0, C is C1 - C0,
          Mag is abs(R) + abs(C) ),
        Scored),
    % There must be some motion.
    Scored \== [],
    % The largest displacement wins.
    sort(0, @>=, Scored, [_-(dr(DR) - dc(DC)) | _]),
    % It must be a real shift.
    ( DR =\= 0 ; DC =\= 0 ).

% ma_colour_centroid(+Frame, +Colour, -R, -C): the rounded centroid of a colour.
ma_colour_centroid(Frame, Colour, R, C) :-
    % Measure the frame.
    gd_size(Frame, Rows, Cols),
    % Bounds.
    MaxR is Rows - 1, MaxC is Cols - 1,
    % Cells of the colour.
    findall(RR-CC,
        ( between(0, MaxR, RR), between(0, MaxC, CC), gd_cell(Frame, RR, CC, Colour) ),
        Cells),
    % It must appear.
    Cells \== [],
    % Sum rows and columns.
    findall(RR, member(RR-_, Cells), RRs), findall(CC, member(_-CC, Cells), CCs),
    length(Cells, N), sum_list(RRs, SR), sum_list(CCs, SC),
    % Rounded means.
    R is round(SR / N), C is round(SC / N).

% ma_action_descriptors(+GameId, -Descriptors): the labelled action panel.
ma_action_descriptors(GameId, Descriptors) :-
    % The actions the game affords.
    ( ma_actions_env(GameId, Actions) -> true ; Actions = [] ),
    % One descriptor per action, ordered by canonical command.
    findall(Cmd-_{command: Cmd, semantic: Sem, source: Src, label: Label},
        ( member(A, Actions),
          ma_action_slot(A, Cmd),
          ma_action_semantic(GameId, A, Sem, Src),
          ma_action_label(Cmd, Sem, Src, Label) ),
        Pairs0),
    % Order and de-duplicate by command.
    sort(1, @<, Pairs0, Pairs),
    % Drop the sort keys.
    findall(D, member(_-D, Pairs), Descriptors).

% ma_action_semantic(+GameId, +Action, -Semantic, -Source): the best semantic.
% ACTION7 is the undo action by protocol whenever a game offers it — a known
% meaning, not a per-game guess.
ma_action_semantic(_GameId, undo, undo, protocol) :- !.
% Otherwise a learned effect is a discovered semantic.
ma_action_semantic(_GameId, Action, Sem, discovered) :-
    % A learned effect, other than nothing, is a discovered semantic.
    ma_effect_(Action, Desc), Desc \== none, !,
    % Use it.
    Sem = Desc.
ma_action_semantic(_GameId, Action, Sem, assumed) :-
    % For a local stand-in, its own design semantic, still only an assumption.
    ma_source(local), ma_local_semantic(Action, Sem), !.
% Otherwise the semantic is genuinely unknown.
ma_action_semantic(_GameId, _Action, none, unknown).

% ma_action_label(+Command, +Semantic, +Source, -Label): the button text.
% An unknown action shows only its canonical command.
ma_action_label(Cmd, none, _, Cmd) :- !.
% A protocol-known semantic (undo) is shown plainly, without a question mark.
ma_action_label(Cmd, Sem, protocol, Label) :- !,
    % Compose "ACTIONk (sem)".
    format(atom(Label), '~w (~w)', [Cmd, Sem]).
% A discovered or assumed semantic is shown with a question mark: it is a guess.
ma_action_label(Cmd, Sem, _Source, Label) :-
    % Compose "ACTIONk (sem?)".
    format(atom(Label), '~w (~w?)', [Cmd, Sem]).

% ma_last_command(-Command): the canonical command of the last action taken.
ma_last_command(Cmd) :-
    % The last action.
    ma_last_(Action, _),
    % Its canonical command.
    ( ma_action_slot(Action, Cmd) -> true ; Cmd = 'none' ).

% ma_command_action(+GameId, +Command, -Action): the action a canonical command
% names in the selected game, so a mentor can drive the game by pressing a
% button. The cell-select ACTION6 defaults to the centre of the grid.
ma_command_action(GameId, Command, Action) :-
    % Only actions the game actually affords are drivable.
    ma_actions_env(GameId, Actions),
    % Find the afforded action whose canonical command matches.
    member(A, Actions),
    ma_action_slot(A, Command),
    !,
    % A cell-select needs a coordinate; default to the centre.
    ( A = select(_, _) -> Action = select(32, 32) ; Action = A ).

% ---- The navigation environment (vc33) ----

% ma_nav_/2: the avatar's (Row, Col).
:- dynamic ma_nav_/2.
% The avatar starts at the top-left.
ma_nav_start(0, 0).
% The goal is the bottom-right.
ma_nav_goal(4, 4).

% ma_nav_reset(-Frame): place the avatar at the start and render.
ma_nav_reset(Frame) :-
    % Forget any previous position.
    retractall(ma_nav_(_, _)),
    % Read the start.
    ma_nav_start(R, C),
    % Place the avatar.
    assertz(ma_nav_(R, C)),
    % Render.
    ma_nav_render(Frame).

% ma_nav_render(-Frame): a five-by-five grid with the avatar and the goal.
ma_nav_render(Frame) :-
    % The avatar position.
    ma_nav_(AR, AC),
    % The goal position.
    ma_nav_goal(GR, GC),
    % Build the grid row by row.
    findall(Row,
        ( between(0, 4, R),
          findall(V,
              ( between(0, 4, C), ma_nav_cell(R, C, AR, AC, GR, GC, V) ),
              Row) ),
        Frame).

% ma_nav_cell(...): the avatar takes precedence, then the goal, then empty.
ma_nav_cell(R, C, AR, AC, _, _, 3) :- R =:= AR, C =:= AC, !.
% The goal cell.
ma_nav_cell(R, C, _, _, GR, GC, 4) :- R =:= GR, C =:= GC, !.
% Empty otherwise.
ma_nav_cell(_, _, _, _, _, _, 0).

% ma_nav_act(+Action, -Frame): move the avatar, clamped to the grid.
ma_nav_act(Action, Frame) :-
    % Read the position.
    retract(ma_nav_(R, C)),
    % Apply the directional displacement, clamped.
    ( ma_move_delta(Action, DR, DC)
    ->  R1 is max(0, min(4, R + DR)), C1 is max(0, min(4, C + DC))
    ;   R1 = R, C1 = C
    ),
    % Store the new position.
    assertz(ma_nav_(R1, C1)),
    % Render.
    ma_nav_render(Frame).

% ---- The signal environment (ft09) ----

% ma_sig_/1: the hidden counter.
:- dynamic ma_sig_/1.

% ma_sig_reset(-Frame): zero the counter and render.
ma_sig_reset(Frame) :-
    % Forget the old counter.
    retractall(ma_sig_(_)),
    % Start at zero.
    assertz(ma_sig_(0)),
    % Render.
    ma_sig_render(Frame).

% ma_sig_render(-Frame): a three-by-three grid whose corner lights with the counter.
ma_sig_render([[0,0,0],[0,0,0],[0,0,Goal]]) :-
    % Read the counter.
    ma_sig_(L),
    % Empty, then part-lit, then lit as the counter rises.
    ( L >= 2 -> Goal = 3 ; L >= 1 -> Goal = 4 ; Goal = 0 ).

% ma_sig_act(+Action, -Frame): the pickup action raises the counter.
ma_sig_act(action(pickup), Frame) :-
    % Read and remove the counter.
    retract(ma_sig_(L)),
    % Raise it, capped at two.
    L1 is min(2, L + 1),
    % Store it back.
    assertz(ma_sig_(L1)),
    % Render.
    ma_sig_render(Frame),
    % Commit.
    !.
% Any other action leaves the counter unchanged.
ma_sig_act(_Action, Frame) :-
    % Just re-render the unchanged state.
    ma_sig_render(Frame).

% ---------------------------------------------------------------------------
% MODE — Guided versus Solo
% ---------------------------------------------------------------------------

% ma_mode_/1: the active mode.
:- dynamic ma_mode_/1.

% Define ma_mode: the active mode, defaulting to guided.
ma_mode(Mode) :-
    % Read the mode, or fall back to guided.
    ( ma_mode_(Mode) -> true ; Mode = guided ).

% Define ma_set_mode: switch the active mode; entering solo ends any old run.
ma_set_mode(Mode) :-
    % Only the two known modes are allowed.
    memberchk(Mode, [guided, solo]),
    % Replace the previous mode.
    retractall(ma_mode_(_)),
    % Record it.
    assertz(ma_mode_(Mode)),
    % Switching mode clears any solo run in progress.
    ma_solo_clear.

% ---------------------------------------------------------------------------
% ARC-AGI-3_Solo — unaided play from the shared learnings, moment to moment
% ---------------------------------------------------------------------------

% ma_solo_/2: (Step, Status) — Status is running or done(Outcome).
:- dynamic ma_solo_/2.
% ma_solo_trace_/2: (Step, Action) — the moment-to-moment record for the report.
:- dynamic ma_solo_trace_/2.
% ma_solo_reported_/1: the filename of the report already written for this run.
:- dynamic ma_solo_reported_/1.

% ma_solo_budget(-Budget): the action budget for a solo attempt.
ma_solo_budget(60).

% Define ma_solo_clear: abandon any solo run state (without a report).
ma_solo_clear :-
    % Drop the run.
    retractall(ma_solo_(_, _)),
    % Drop the trace.
    retractall(ma_solo_trace_(_, _)),
    % Drop the reported flag.
    retractall(ma_solo_reported_(_)).

% Define ma_solo_start: begin a fresh solo attempt on the selected environment,
% keeping every learning (relations, goal, priorities, hazards, J-Space) intact.
ma_solo_start :-
    % The selected environment.
    ma_selected_game(Sel),
    % Reset only the game position — the learnings persist.
    ma_reset_env(Sel, _),
    % Fresh curiosity counters for this attempt.
    retractall(ma_try_(_, _)),
    % Fresh session recording.
    ma_session_reset,
    % If a winning path was learned for this game, replay it this run.
    ( ma_win_path_(Sel, Seq)
    -> retractall(ma_replay_(Sel, _)), assertz(ma_replay_(Sel, Seq))
    ;  retractall(ma_replay_(Sel, _)) ),
    % Clear any previous run.
    ma_solo_clear,
    % Seed the J-Space workspace with the learnings this run will use.
    ma_solo_seed_jspace,
    % Begin at step zero, running.
    assertz(ma_solo_(0, running)).

% Define ma_solo_tick: advance the solo run one step and report telemetry.
ma_solo_tick(Telemetry) :-
    % The selected environment.
    ma_selected_game(Sel),
    % Advance only while the run is live.
    (   ma_solo_(Step, running)
    % Take one solo step from the shared learnings.
    ->  ma_step(step(Action, _Basis, _)),
        % One more step spent.
        Step1 is Step + 1,
        % The action budget.
        ma_solo_budget(Budget),
        % Decide the new status.
        (   ma_solved_env(Sel, _)
        ->  Status = done(won(Step1))
        ;   Step1 >= Budget
        ->  Status = done(budget_exhausted(Step1))
        ;   Status = running
        ),
        % Store the updated run.
        retractall(ma_solo_(_, _)),
        % Record it.
        assertz(ma_solo_(Step1, Status)),
        % Record the step for the report.
        assertz(ma_solo_trace_(Step1, Action)),
        % On completion, write exactly one report.
        (   Status = done(_), \+ ma_solo_reported_(_)
        ->  ma_solo_report(RepFile, _), assertz(ma_solo_reported_(RepFile))
        ;   ( ma_solo_reported_(RepFile) -> true ; RepFile = none )
        ),
        % Build the telemetry.
        ma_solo_telemetry(Sel, Step1, Action, Status, RepFile, Telemetry)
    % A finished or absent run reports its final frame without advancing.
    ;   ma_solo_final_telemetry(Sel, Telemetry)
    ).

% ma_solo_telemetry(+Sel, +Step, +Action, +Status, +RepFile, -T): a live tick.
ma_solo_telemetry(Sel, Step, Action, Status, RepFile, T) :-
    % Render the current frame.
    ( ma_render(Sel, Frame) -> true ; ma_reset_env(Sel, Frame) ),
    % The action taken, as an atom for the record.
    term_to_atom(Action, AText),
    % Its canonical command, for the button light-up.
    ( ma_action_slot(Action, Command) -> true ; Command = 'none' ),
    % The labelled action panel for this game.
    ma_action_descriptors(Sel, Actions),
    % Whether the run is finished.
    ( Status = running -> Done = false, OutText = "running"
    ; Status = done(Outcome) -> Done = true, term_to_atom(Outcome, OutText)
    ),
    % The game's human title.
    ( ma_available_game(Sel, Title) -> true ; Title = Sel ),
    % Assemble the telemetry dict.
    T = _{frame: Frame, action: AText, command: Command, actions: Actions,
          step: Step, done: Done, outcome: OutText, report: RepFile,
          game: Sel, title: Title}.

% ma_solo_final_telemetry(+Sel, -T): telemetry when no step is taken.
ma_solo_final_telemetry(Sel, T) :-
    % Render the current frame, resetting if the environment is fresh.
    ( ma_render(Sel, Frame) -> true ; ma_reset_env(Sel, Frame) ),
    % Report the last outcome and report, if any.
    (   ma_solo_(Step, done(Outcome))
    ->  term_to_atom(Outcome, OutText), Done = true,
        ( ma_solo_reported_(RepFile) -> true ; RepFile = none )
    ;   Step = 0, OutText = "idle", Done = false, RepFile = none
    ),
    % The labelled action panel for this game.
    ma_action_descriptors(Sel, Actions),
    % The game's human title.
    ( ma_available_game(Sel, Title) -> true ; Title = Sel ),
    % Assemble the telemetry.
    T = _{frame: Frame, action: "none", command: 'none', actions: Actions,
          step: Step, done: Done, outcome: OutText, report: RepFile,
          game: Sel, title: Title}.

% ma_solo_seed_jspace: hold the run's learnings as concepts in J-Space.
ma_solo_seed_jspace :-
    % Guarded so a missing workspace can never break a run.
    catch((
        % Open the solo workspace.
        js_open(arc_solo),
        % Hold the selected game.
        ma_selected_game(G), js_hold(arc_solo, game(G), 1.0, selection),
        % Hold the learned goal, if any.
        ( ma_goal_(Goal) -> js_hold(arc_solo, goal(Goal), 1.0, learned_goal) ; true ),
        % Hold each human-taught priority.
        forall(ma_priority_(P), js_hold(arc_solo, priority(P), 0.8, learned_priority)),
        % Hold each declared hazard.
        forall(ma_avoid_cell_(pos(R, C)),
               js_hold(arc_solo, avoid(cell(R, C)), 0.8, learned_hazard))
    ), _, true).

% ma_jlens(-Reading): the J-Lens readout of the solo workspace.
ma_jlens(Reading) :-
    % Guarded, empty when the workspace is unavailable.
    ( catch(js_reading(arc_solo, Reading), _, fail) -> true ; Reading = [] ).

% ---------------------------------------------------------------------------
% RESTART — works in both modes, on the selected environment
% ---------------------------------------------------------------------------

% Define ma_restart: restart the selected environment in the active mode.
ma_restart(Mode, Reply) :-
    % The active mode.
    ma_mode(Mode),
    % The selected environment.
    ma_selected_game(Sel),
    (   Mode == solo
    % Solo restart: finalise any unreported run, then begin a fresh attempt.
    ->  ( ma_solo_(_, _), \+ ma_solo_reported_(_)
        ->  catch((ma_solo_report(_, _)), _, true) ; true ),
        ma_solo_start,
        Reply = _{ok: true, mode: solo, game: Sel, did: restart}
    % Guided restart: reset the game position but keep every learning.
    ;   ma_reset_env(Sel, _),
        retractall(ma_last_(_, _)),
        retractall(ma_try_(_, _)),
        % Fresh session recording for the new guided attempt.
        ma_session_reset,
        Reply = _{ok: true, mode: guided, game: Sel, did: restart}
    ).

% ---------------------------------------------------------------------------
% SOLO ATTEMPT REPORTS — the date-and-time-stamped record
% ---------------------------------------------------------------------------

% Define ma_attempts_dir: the directory solo reports are written to.
ma_attempts_dir('ARC-AGI-3_Solo_Attempts').

% Define ma_solo_report: write one solo attempt report; return its filename.
ma_solo_report(File, Path) :-
    % The directory, created if missing.
    ma_attempts_dir(Dir),
    % Ensure the directory exists.
    ( exists_directory(Dir) -> true ; make_directory_path(Dir) ),
    % A safe date-and-time stamp for the filename.
    get_time(Now),
    % Format the stamp as year-month-day_hour-minute-second.
    format_time(atom(Stamp), '%Y-%m-%d_%H-%M-%S', Now),
    % The report filename.
    atomic_list_concat(['ARC-AGI-3_Solo_', Stamp, '.txt'], File),
    % The full path.
    atomic_list_concat([Dir, '/', File], Path),
    % Compose the report text.
    ma_report_text(Now, Text),
    % Write it as plain text.
    setup_call_cleanup(
        open(Path, write, Stream),
        write(Stream, Text),
        close(Stream)).

% ma_report_text(+Now, -Text): the plain-text body of a solo attempt report.
ma_report_text(Now, Text) :-
    % A readable timestamp for the body.
    format_time(atom(When), '%Y-%m-%d %H:%M:%S', Now),
    % The selected environment and its title (live or local, else the id).
    ma_selected_game(Game),
    % Its title from the active source, falling back to the id.
    ( ma_available_game(Game, Title) -> true ; Title = Game ),
    % The run outcome, if the run has one.
    ( ma_solo_(Steps, done(Outcome)) -> true
    ; ma_solo_(Steps, _) -> Outcome = interrupted
    ; Steps = 0, Outcome = none ),
    % The moment-to-moment action trace.
    findall(N-A, ma_solo_trace_(N, A), Pairs0),
    % In step order.
    msort(Pairs0, Pairs),
    % Render the trace lines.
    ma_trace_lines(Pairs, TraceText),
    % The learnings the run drew on.
    ma_learnings(learnings(Goal, Priorities, Avoided, Labels, CroCount, JLens)),
    % Render the outcome as text.
    term_to_atom(Outcome, OutcomeText),
    % Render the goal.
    term_to_atom(Goal, GoalText),
    % Render the priorities.
    term_to_atom(Priorities, PrioText),
    % Render the avoided cells.
    term_to_atom(Avoided, AvoidText),
    % Render the labels.
    term_to_atom(Labels, LabelText),
    % Render the J-Lens reading.
    term_to_atom(JLens, JLensText),
    % Assemble the whole report.
    format(atom(Text),
'ARC-AGI-3 Solo Attempt Report~n~nWhen: ~w~nGame environment: ~w (~w)~nMode: solo (no human direction)~nOutcome: ~w~nSteps taken: ~w~n~nWhat Mentova did, moment to moment:~n~w~nLearnings drawn from the shared data lattice, Causalontology, and J-Space:~n  Inferred or taught goal: ~w~n  Suggested-action priorities: ~w~n  Declared hazards to avoid: ~w~n  Object labels: ~w~n  Causal relations known (count): ~w~n  J-Space (Jacobian Lens) reading: ~w~n~nNote: this was a solo attempt using only the accumulated learnings; no human guidance was given during the run. No benchmark score is claimed.~n',
        [When, Game, Title, OutcomeText, Steps, TraceText,
         GoalText, PrioText, AvoidText, LabelText, CroCount, JLensText]).

% ma_trace_lines(+Pairs, -Text): render the step-action trace as text lines.
ma_trace_lines([], '  (no steps taken)\n').
% A non-empty trace.
ma_trace_lines(Pairs, Text) :-
    % There is at least one step.
    Pairs = [_ | _],
    % Render each step on its own line.
    findall(Line,
        ( member(N-A, Pairs),
          term_to_atom(A, AT),
          format(atom(Line), '  step ~w: ~w~n', [N, AT]) ),
        Lines),
    % Join the lines.
    atomic_list_concat(Lines, Text).

% Define ma_attempts_list: the solo report filenames, newest first.
ma_attempts_list(Files) :-
    % The directory.
    ma_attempts_dir(Dir),
    % When it exists, list its text reports.
    (   exists_directory(Dir)
    ->  directory_files(Dir, Entries),
        % Keep only the stamped report files.
        findall(F,
            ( member(F, Entries),
              atom_concat('ARC-AGI-3_Solo_', _, F),
              atom_concat(_, '.txt', F) ),
            Reports),
        % Newest first: the timestamp sorts lexically, so reverse the sort.
        sort(0, @>=, Reports, Files)
    % No directory yet means no reports.
    ;   Files = []
    ).

% ---------------------------------------------------------------------------
% SHARED LEARNINGS — what both sub-projects can see and read
% ---------------------------------------------------------------------------

% Define ma_learnings: the shared learnings the Guided and Solo modules read.
ma_learnings(learnings(Goal, Priorities, Avoided, Labels, CroCount, JLens)) :-
    % The taught or inferred goal, if any.
    ( ma_goal_(Goal) -> true ; Goal = none ),
    % The suggested-action priorities.
    findall(A, ma_priority_(A), Priorities),
    % The declared hazards.
    findall(cell(R, C), ma_avoid_cell_(pos(R, C)), Avoided),
    % The object labels.
    findall(cell(R, C)-K, ma_label_(pos(R, C), K), Labels),
    % How many causal relations have been learned.
    ( catch(aggregate_all(count, co_cro(_, _, _, _, _, _, _, _), CroCount), _, fail)
    -> true ; CroCount = 0 ),
    % The J-Lens reading of the solo workspace.
    ma_jlens(JLens).

% ---------------------------------------------------------------------------
% SESSION RECORDING and the WON PACKAGE — learning from a complete winning game
% ---------------------------------------------------------------------------

% ma_session_/4: (Step, Action, Delta, Outcome) — every step of the current session.
:- dynamic ma_session_/4.
% ma_session_n_/1: the session step counter.
:- dynamic ma_session_n_/1.
% ma_win_path_/2: (GameId, ActionSequence) — a recorded winning action sequence.
:- dynamic ma_win_path_/2.
% ma_replay_/2: (GameId, RemainingActions) — a winning path being replayed.
:- dynamic ma_replay_/2.

% ma_session_reset/0: begin a fresh session recording.
ma_session_reset :-
    % Clear the recorded steps.
    retractall(ma_session_(_, _, _, _)),
    % Clear the counter.
    retractall(ma_session_n_(_)),
    % Start at zero.
    assertz(ma_session_n_(0)).

% ma_session_record(+Action, +Delta, +Outcome): append one step to the session.
ma_session_record(Action, Delta, Outcome) :-
    % Fetch and remove the counter, defaulting to zero.
    ( retract(ma_session_n_(N)) -> true ; N = 0 ),
    % Next step number.
    N1 is N + 1,
    % Store the counter back.
    assertz(ma_session_n_(N1)),
    % Record the step.
    assertz(ma_session_(N1, Action, Delta, Outcome)).

% ma_wins_dir/1: the directory won-session packages are written to.
ma_wins_dir('ARC-AGI-3_Won_Sessions').

% Define ma_conclude_won: learn from the won session and write a package.
% Fails if the selected game is not currently won or nothing was recorded.
ma_conclude_won(won_package(Game, StepCount, ReportFile, Learned)) :-
    % The selected game.
    ma_selected_game(Game),
    % Its current frame.
    ( ma_render(Game, Frame) -> true ; ma_reset_env(Game, Frame) ),
    % It must be won.
    ma_solved_env(Game, Frame),
    % The recorded session, in step order.
    findall(st(N, A, D, O), ma_session_(N, A, D, O), Raw),
    % Ordered.
    msort(Raw, Steps),
    % How many steps.
    length(Steps, StepCount),
    % There must be something to learn from.
    StepCount > 0,
    % Feed the learning stores.
    ma_learn_from_win(Game, Steps, Learned),
    % Write the package to disk.
    ma_win_report(Game, Steps, Learned, ReportFile).

% ma_learn_from_win(+Game, +Steps, -Learned): feed lattice, Causalontology, J-Space.
ma_learn_from_win(Game, Steps, learned(WinPath, Reinforced, Levers)) :-
    % The winning action sequence.
    findall(A, member(st(_, A, _, _), Steps), WinPath),
    % 1) Data lattice: record the winning path so future Solo runs replay it.
    retractall(ma_win_path_(Game, _)),
    assertz(ma_win_path_(Game, WinPath)),
    % 2) Causalontology: reinforce every relation used on the winning path.
    ma_reinforce_path(WinPath, Reinforced),
    % 3) Guided levers the winning strategy implies (helps locksmith-style games).
    ma_win_levers(Game, Steps, Levers),
    % 4) Jacobian Space: hold the win and its levers.
    ma_win_jspace(Game, WinPath, Levers).

% ma_reinforce_path(+Actions, -Count): strengthen each action's relations.
ma_reinforce_path(Actions, Count) :-
    % Strengthen every non-preventive relation whose cause is a path action.
    findall(Id,
        ( member(A, Actions),
          catch(co_cro(Id, [A], _, _, M, _, _, _), _, fail),
          M \== preventive,
          catch(co_strengthen(Id, 0.1), _, true) ),
        Ids),
    % Count the distinct relations reinforced.
    sort(Ids, Unique), length(Unique, Count).

% ma_win_levers(+Game, +Steps, -Levers): set guided levers from the win.
ma_win_levers(_Game, Steps, Levers) :-
    % The winning action sequence.
    findall(A, member(st(_, A, _, _), Steps), Seq),
    % If pickup was used and this game keeps locksmith state, prioritise pickup.
    (   memberchk(action(pickup), Seq), ma_state_(_, _, _, _)
    ->  ( ma_priority_(action(pickup)) -> true ; assertz(ma_priority_(action(pickup))) ),
        Prio = [priority(action(pickup))]
    ;   Prio = []
    ),
    % If a door opened (colour six appeared) during the win, set the traverse goal.
    (   member(st(_, _, D, _), Steps), member(changed(R, C, _, 6), D)
    ->  retractall(ma_goal_(_)), assertz(ma_goal_(traverse(pos(R, C)))),
        Goal = [goal(traverse(pos(R, C)))]
    ;   Goal = []
    ),
    % The levers that were set.
    append(Prio, Goal, Levers).

% ma_win_jspace(+Game, +WinPath, +Levers): hold the win in the Jacobian Space.
ma_win_jspace(Game, WinPath, Levers) :-
    % Guarded so a workspace hiccup never blocks concluding.
    catch((
        js_open(arc_won),
        length(WinPath, L),
        js_hold(arc_won, won(Game, steps(L)), 1.0, win),
        forall(member(Lv, Levers), js_hold(arc_won, Lv, 0.9, win_lever))
    ), _, true).

% ma_win_report(+Game, +Steps, +Learned, -File): write the won package to disk.
ma_win_report(Game, Steps, Learned, File) :-
    % The wins directory, created if missing.
    ma_wins_dir(Dir),
    ( exists_directory(Dir) -> true ; make_directory_path(Dir) ),
    % A date-and-time stamp.
    get_time(Now),
    format_time(atom(Stamp), '%Y-%m-%d_%H-%M-%S', Now),
    % The filename and path.
    atomic_list_concat(['ARC-AGI-3_Won_', Game, '_', Stamp, '.txt'], File),
    atomic_list_concat([Dir, '/', File], Path),
    % Compose and write the text.
    ma_win_report_text(Game, Steps, Learned, Now, Text),
    setup_call_cleanup(open(Path, write, S), write(S, Text), close(S)).

% ma_win_report_text(+Game, +Steps, +Learned, +Now, -Text): the package body.
ma_win_report_text(Game, Steps, learned(WinPath, Reinforced, Levers), Now, Text) :-
    format_time(atom(When), '%Y-%m-%d %H:%M:%S', Now),
    ( ma_available_game(Game, Title) -> true ; Title = Game ),
    % The step-by-step lines.
    findall(Line,
        ( member(st(N, A, D, O), Steps),
          term_to_atom(A, AT), term_to_atom(D, DT),
          format(atom(Line), '  step ~w: ~w -> ~w (delta ~w)~n', [N, AT, O, DT]) ),
        Lines),
    atomic_list_concat(Lines, StepText),
    length(WinPath, PathLen),
    term_to_atom(WinPath, PathText),
    term_to_atom(Levers, LeverText),
    format(atom(Text),
'ARC-AGI-3 Won Session Package~n~nWhen: ~w~nGame environment: ~w (~w)~nOutcome: WON~nSteps: ~w~n~nComplete winning game session, step by step:~n~w~nWhat Mentova learned from this win (fed into its learning stores):~n  Data lattice - winning action path recorded for replay (~w actions): ~w~n  Causalontology - relations reinforced on the winning path: ~w~n  Guided levers set from the win: ~w~n  Jacobian Space (J-Space) - the win and its levers are held in the arc_won workspace.~n~nEffect: a future Solo run of this game replays this winning path, and the reinforced relations and levers bias play toward the win. No benchmark score is claimed.~n',
        [When, Game, Title, PathLen, StepText, PathLen, PathText, Reinforced, LeverText]).

% ---------------------------------------------------------------------------
% CLUE GROUNDING (Section 10.4) — the small, auditable mapping
% ---------------------------------------------------------------------------

% Define co_ground: a natural-language clue and a clicked reference become
% one Causalontology assertion. The reference is [R, C] or none.
co_ground(Text, Ref, Assertion) :-
    % Normalize the clue text.
    downcase_atom(Text, T),
    % Match the clue against the mapping table, in order.
    (   sub_atom(T, _, _, _, 'looks like a key')
    % A key label: posit a key-like continuant at the reference.
    ->  Assertion = hint_label(Ref, key_like)
    % A lock label.
    ;   sub_atom(T, _, _, _, 'looks like a lock')
    % Posit a lock-like continuant.
    ->  Assertion = hint_label(Ref, lock_like)
    % A door label, with the walk-through goal.
    ;   sub_atom(T, _, _, _, 'looks like a door')
    % Posit the door and set the traverse goal.
    ->  Assertion = hint_goal(Ref, traverse)
    % A pickup suggestion.
    ;   sub_atom(T, _, _, _, 'pick that up')
    % Raise the pickup action's priority.
    ->  Assertion = hint_action(action(pickup))
    % A hazard declaration.
    ;   ( sub_atom(T, _, _, _, 'don''t touch that')
        % Either phrasing of the warning.
        ; sub_atom(T, _, _, _, 'that hurts') )
    % Tag the referenced cell preventive.
    ->  Assertion = hint_preventive(Ref)
    % Positive reinforcement.
    ;   ( sub_atom(T, _, _, _, good)
        % Either phrasing of the praise.
        ; sub_atom(T, _, _, _, 'that worked') )
    % Raise the strength of the relations on the last path.
    ->  Assertion = hint_reinforce
    % An encouragement to continue is a no-op assertion.
    ;   sub_atom(T, _, _, _, 'keep going')
    % Nothing to ground; the loop simply continues.
    ->  Assertion = hint_continue
    % Anything else is not a groundable clue.
    ;   fail
    ).

% ---------------------------------------------------------------------------
% HINT INJECTION — biasing the live loop
% ---------------------------------------------------------------------------

% ma_priority_/1: actions a human has suggested.
:- dynamic ma_priority_/1.
% ma_goal_/1: the goal a human has set.
:- dynamic ma_goal_/1.
% ma_avoid_cell_/1: cells a human has declared hazardous.
:- dynamic ma_avoid_cell_/1.
% ma_label_/2: (pos(R,C), Kind) — human labels on cells.
:- dynamic ma_label_/2.
% ma_last_/2: (Action, Basis) — the last action and why it was taken.
:- dynamic ma_last_/2.

% Define ma_reset_guidance: clear hints, priorities, goals, and learning.
ma_reset_guidance :-
    % Drop the priorities.
    retractall(ma_priority_(_)),
    % Drop the goal.
    retractall(ma_goal_(_)),
    % Drop the declared hazards.
    retractall(ma_avoid_cell_(_)),
    % Drop the labels.
    retractall(ma_label_(_, _)),
    % Drop the last-action record.
    retractall(ma_last_(_, _)),
    % Drop the curiosity counters.
    retractall(ma_try_(_, _)),
    % Drop the discovered action semantics.
    retractall(ma_effect_(_, _)),
    % Clear the harness counters.
    co_arc3_reset.

% Define ma_inject: apply one grounded assertion to the live loop.
ma_inject(hint_label([R, C], Kind)) :-
    % Name the labeled object by its cell.
    atomic_list_concat([obj_, R, '_', C], Id),
    % NOUN: posit the continuant with its human label.
    co_continuant_add(Id, Kind),
    % Remember the label for choice-making.
    assertz(ma_label_(pos(R, C), Kind)),
    % HINGE: a key-like object bears a pick-up-able disposition.
    (   Kind == key_like
    % Posit the disposition and its realization seam.
    ->  co_realizable_add(Id, disposition, Id),
        % Realized in the pickup occurrent.
        co_realized_in_add(Id, action(pickup))
    % Other labels posit no disposition here.
    ;   true
    ),
    % Commit.
    !.
% A door label with the traverse goal.
ma_inject(hint_goal([R, C], traverse)) :-
    % Name and label the door object.
    atomic_list_concat([obj_, R, '_', C], Id),
    % NOUN: posit the door-like continuant.
    co_continuant_add(Id, door_like),
    % Remember the label.
    assertz(ma_label_(pos(R, C), door_like)),
    % Set the goal: be beyond the door.
    retractall(ma_goal_(_)),
    % Record it.
    assertz(ma_goal_(traverse(pos(R, C)))),
    % Commit.
    !.
% A suggested action.
ma_inject(hint_action(Action)) :-
    % Raise its priority once.
    ( ma_priority_(Action) -> true ; assertz(ma_priority_(Action)) ),
    % Commit.
    !.
% A human-declared hazard.
ma_inject(hint_preventive([R, C])) :-
    % Remember the cell as avoided for movement choices.
    ( ma_avoid_cell_(pos(R, C)) -> true ; assertz(ma_avoid_cell_(pos(R, C))) ),
    % VERB: reify the preventive relation exactly as a self-learned hazard,
    % provenance marking the human origin.
    co_learn_preventive(touch(cell(R, C)), penalty),
    % Commit.
    !.
% Positive reinforcement: raise the strength of the last action's relations.
ma_inject(hint_reinforce) :-
    % Fetch the last action, if any.
    (   ma_last_(Action, _)
    % Strengthen every relation whose cause is that action.
    ->  forall(co_cro(Id, [Action], _, _, M, _, _, _),
               % Preventive relations are not reinforced.
               ( M == preventive -> true ; co_strengthen(Id, 0.1) ))
    % No last action: nothing to reinforce.
    ;   true
    ),
    % Commit.
    !.
% The continue hint changes nothing.
ma_inject(hint_continue).

% ---------------------------------------------------------------------------
% THE GUIDED LOOP — human priorities first, then the goal, then curiosity
% ---------------------------------------------------------------------------

% ma_step(-Report): one loop step; the basis of the choice is recorded.
ma_step(Report) :-
    % Choose the action and remember why.
    ma_choose(Action, Basis),
    % Perform and learn from it.
    ma_do_step(Action, Basis, Report).

% ma_do_step(+Action, +Basis, -Report): perform a specific action and learn,
% shared by the automatic step (ma_step) and the mentor's manual action.
ma_do_step(Action, Basis, step(Action, Basis, Outcome)) :-
    % The selected environment.
    ma_selected_game(Sel),
    % The frame before the action, resetting if the environment is fresh.
    ( ma_render(Sel, Frame0) -> true ; ma_reset_env(Sel, Frame0) ),
    % Doing: perform it on the selected environment.
    ma_act_env(Sel, Action, Frame1),
    % The observed effect is the frame delta.
    co_arc3_delta(Frame0, Frame1, Delta),
    % Learn this action's observed effect, for its discovered semantic label.
    ma_record_effect(Action, Frame0, Frame1),
    % Learn from what followed, exactly as the harness does.
    (   Delta == []
    % Nothing changed.
    ->  Outcome = none
    % The penalty marker is a hazard.
    ;   memberchk(changed(_, _, _, 15), Delta)
    ->  co_learn_preventive(Action, penalty),
        % Report the hazard.
        Outcome = hazard
    % Otherwise the delta was produced by the action.
    ;   co_learn_causal(Action, delta(Delta)),
        % Report the learning.
        Outcome = learned
    ),
    % Record the last action and its basis for the why endpoint.
    retractall(ma_last_(_, _)),
    % Store it.
    assertz(ma_last_(Action, Basis)),
    % Count the try so curiosity varies its choices across the attempt.
    ma_bump_try(Action),
    % Append this step to the session recording (for the won package).
    ma_session_record(Action, Delta, Outcome).

% ma_choose(-Action, -Basis): the guided choice.
% First: if a recorded winning path is being replayed for this game, follow it.
% This is how a concluded win teaches future Solo runs — they replay the win.
ma_choose(Action, replay(win)) :-
    % The selected game.
    ma_selected_game(G),
    % There is a next action to replay.
    ma_replay_(G, [Action | Rest]),
    % Commit to replaying it.
    !,
    % Advance the replay cursor.
    retractall(ma_replay_(G, _)),
    % Store the remaining path.
    assertz(ma_replay_(G, Rest)).
% Otherwise, the human suggested picking up and Mentova stands on the key.
ma_choose(action(pickup), human_hint(pickup)) :-
    % The human suggested picking up, and Mentova stands on the key.
    ma_priority_(action(pickup)),
    % Fetch the state.
    ma_state_(P, at_cell(P), _, _),
    % Commit.
    !.
% Approach the key while the pickup suggestion stands.
ma_choose(Action, toward(key)) :-
    % The suggestion stands and the key is still on the board.
    ma_priority_(action(pickup)),
    % Fetch the state.
    ma_state_(P, at_cell(K), _, _),
    % Step greedily toward the key, avoiding declared hazards.
    ma_greedy_step(P, K, Action),
    % Commit.
    !.
% Head for the door once the key is held and the goal is set.
ma_choose(Action, toward(goal)) :-
    % The human set the traverse goal.
    ma_goal_(traverse(D)),
    % The key is held.
    ma_state_(P, held, _, _),
    % Step greedily toward the door, avoiding declared hazards.
    ma_greedy_step(P, D, Action),
    % Commit.
    !.
% Otherwise curiosity decides: the least-tried safe action over the selected
% environment's action set, so unguided play genuinely explores rather than
% repeating one move.
ma_choose(Action, curiosity) :-
    % The selected environment's action set.
    ma_selected_game(Sel),
    % Its actions.
    ma_actions_env(Sel, Actions),
    % Keep only moves that do not land on a human-declared hazard.
    findall(A, ( member(A, Actions), \+ ma_lands_on_hazard(A) ), Safe0),
    % If every action is hazardous, fall back to the full set rather than stall.
    ( Safe0 == [] -> Safe = Actions ; Safe = Safe0 ),
    % Score each safe action by how often it has been tried this attempt.
    findall(N-A, ( member(A, Safe), ma_try_count(A, N) ), Scored),
    % There must be something to choose.
    Scored \== [],
    % Least-tried first (ties break by standard order).
    keysort(Scored, [_-Action | _]).

% ma_try_/2: (Action, Count) — the curiosity counter for the current attempt.
:- dynamic ma_try_/2.

% ma_try_count(+Action, -Count): the try count, zero when untried.
ma_try_count(Action, Count) :-
    % Read the counter, defaulting to zero.
    ( ma_try_(Action, Count) -> true ; Count = 0 ).

% ma_bump_try(+Action): increment the curiosity counter for an action.
ma_bump_try(Action) :-
    % Fetch and remove the current count.
    ( retract(ma_try_(Action, N)) -> true ; N = 0 ),
    % Increment.
    N1 is N + 1,
    % Store it back.
    assertz(ma_try_(Action, N1)).

% ma_greedy_step(+From, +To, -Action): one step toward a target, never onto
% a human-declared hazard cell.
ma_greedy_step(pos(R0, C0), pos(R1, C1), Action) :-
    % Candidate actions in target-reducing order.
    findall(A, ma_step_toward(R0, C0, R1, C1, A), Candidates),
    % Take the first candidate that lands safely.
    member(Action, Candidates),
    % It must not land on a declared hazard.
    \+ ma_lands_on_hazard(Action),
    % Commit.
    !.

% ma_step_toward(+R0, +C0, +R1, +C1, -Action): target-reducing moves.
ma_step_toward(R0, _, R1, _, action(up)) :- R1 < R0.
% Downward.
ma_step_toward(R0, _, R1, _, action(down)) :- R1 > R0.
% Leftward.
ma_step_toward(_, C0, _, C1, action(left)) :- C1 < C0.
% Rightward.
ma_step_toward(_, C0, _, C1, action(right)) :- C1 > C0.

% ma_lands_on_hazard(+Action): the move would land on a declared hazard.
ma_lands_on_hazard(Action) :-
    % Only movement actions land anywhere.
    ma_move_delta(Action, DR, DC),
    % Fetch the player's position.
    ma_state_(pos(PR, PC), _, _, _),
    % The landing cell.
    R1 is max(0, min(4, PR + DR)),
    % Its column.
    C1 is max(0, min(4, PC + DC)),
    % A human declared it hazardous.
    ma_avoid_cell_(pos(R1, C1)).

% Define ma_auto: run steps until the level is won or the budget is spent.
ma_auto(Budget, Outcome) :-
    % Count the steps taken.
    ma_auto_(0, Budget, Outcome).

% ma_auto_(+Steps, +Budget, -Outcome): the loop.
ma_auto_(Steps, Budget, Outcome) :-
    % Fetch the current frame.
    ma_game_frame(Frame),
    % Decide the state of the episode.
    (   ma_env_solved(Frame)
    % The level is won.
    ->  Outcome = won(Steps)
    % The budget is spent.
    ;   Steps >= Budget
    ->  Outcome = budget_exhausted
    % Otherwise take one step and continue.
    ;   ma_step(_),
        % One more step spent.
        Steps1 is Steps + 1,
        % Continue.
        ma_auto_(Steps1, Budget, Outcome)
    ).

% Define ma_why: the justification of the last action — which lever chose
% it, and whether that lever was human guidance or Mentova's own discovery.
ma_why(why(Action, Basis, Provenance)) :-
    % Fetch the last action and its basis.
    ma_last_(Action, Basis),
    % Name the provenance of the basis.
    (   Basis = human_hint(_)
    % A human suggestion chose it.
    ->  Provenance = guided_by_human
    % Approaching a human-labeled target.
    ;   Basis = toward(_)
    ->  Provenance = guided_by_human
    % Curiosity chose it.
    ;   Provenance = discovered_alone
    ).

% ---------------------------------------------------------------------------
% SAFETY — the hint text check (Section 10.6)
% ---------------------------------------------------------------------------

% ma_hint_safe(+Text): the clue text passes the safety keyword check,
% mirroring the chat's mc_is_unsafe convention.
ma_hint_safe(Text) :-
    % Normalize.
    downcase_atom(Text, T),
    % None of the unsafe keywords may appear.
    \+ ( member(Bad, [kill, hurt_you, suicide, weapon, drug]),
         % Test each keyword.
         sub_atom(T, _, _, _, Bad) ).

% ---------------------------------------------------------------------------
% HTTP HANDLERS
% ---------------------------------------------------------------------------

% ma_handle_page(+Request): serve the split-screen page from the assets,
% with a plain-text fallback so the route never breaks.
ma_handle_page(Request) :-
    % Serve the asset file when it exists.
    (   exists_file('assets/arc/arc.html')
    % Reply with the split-screen page.
    ->  http_reply_file('assets/arc/arc.html', [unsafe(true)], Request)
    % Otherwise a plain-text pointer keeps the route alive.
    ;   format('Content-type: text/plain~n~n'),
        % Name the API routes.
        format('Mentova ARC chat. Use /api/arc/frame, /api/arc/control, /api/arc/hint, /api/arc/why.~n')
    ).

% ma_handle_frame(+Request): the current frame and status as JSON, for the
% selected environment, with the active mode, game, and last action.
ma_handle_frame(_Request) :-
    % The selected environment.
    ma_selected_game(Sel),
    % The current frame, resetting the environment if it is fresh.
    ( ma_render(Sel, Frame) -> true ; ma_reset_env(Sel, Frame) ),
    % Won or still playing?
    ( ma_solved_env(Sel, Frame) -> Status = won ; Status = playing ),
    % The active mode.
    ma_mode(Mode),
    % The last action taken, for the button light-up (none if none yet).
    ( ma_last_(LastA, _) -> term_to_atom(LastA, LastText) ; LastText = "none" ),
    % The canonical command of the last action, for the light-up.
    ( ma_last_command(LastCmd) -> true ; LastCmd = 'none' ),
    % The labelled action panel for this game (canonical names + semantics).
    ma_action_descriptors(Sel, Actions),
    % The game's human title (honest fallback to the id for unknown live games).
    ( ma_available_game(Sel, Title) -> true ; Title = Sel ),
    % Reply with the full view.
    reply_json_dict(_{frame: Frame, status: Status, mode: Mode,
                      game: Sel, title: Title, last_action: LastText,
                      last_command: LastCmd, actions: Actions}).

% ma_handle_control(+Request): reset, step, or auto, mentor-authenticated.
ma_handle_control(Request) :-
    % Read the JSON body.
    http_read_json_dict(Request, Body),
    % The token and command are required.
    _{token: Tk, cmd: Cmd} :< Body,
    % Only a mentor may drive the game.
    (   mc_verify_session(Tk, _GuideId)
    % Dispatch the command.
    ->  ma_control(Cmd, Body, Reply),
        % Answer.
        reply_json_dict(Reply)
    % Refuse the unauthenticated.
    ;   reply_json_dict(_{ok: false, error: "Not signed in."})
    ).

% ma_control(+Cmd, +Body, -Reply): the control commands.
ma_control("reset", _, _{ok: true, did: reset}) :-
    % Reset the game and the guidance.
    ma_game_reset(_),
    % Clear guidance and learning counters.
    ma_reset_guidance,
    % Begin a fresh session recording.
    ma_session_reset,
    % Commit.
    !.
% One step.
ma_control("step", _, _{ok: true, did: step, action: AText, basis: BText}) :-
    % Take one guided step.
    ma_step(step(Action, Basis, _)),
    % Render the action for JSON.
    term_to_atom(Action, AText),
    % Render the basis for JSON.
    term_to_atom(Basis, BText),
    % Commit.
    !.
% An auto run under a budget.
ma_control("auto", Body, _{ok: true, did: auto, outcome: OText}) :-
    % The budget defaults to forty.
    ( get_dict(budget, Body, Budget0), integer(Budget0) -> Budget = Budget0 ; Budget = 40 ),
    % Run to a win or the budget.
    ma_auto(Budget, Outcome),
    % Render the outcome for JSON.
    term_to_atom(Outcome, OText),
    % Commit.
    !.
% A mentor's manual action: perform a specific canonical action on the game.
ma_control("act", Body, Reply) :-
    % The requested canonical command, e.g. "ACTION1".
    ( get_dict(command, Body, CmdStr) -> atom_string(Cmd, CmdStr) ; Cmd = '' ),
    % The selected game.
    ma_selected_game(Sel),
    (   ma_command_action(Sel, Cmd, Action)
    % The action is afforded: perform it as a manual step and report it.
    ->  ma_do_step(Action, manual, step(_, _, Outcome)),
        term_to_atom(Action, AText),
        term_to_atom(Outcome, OText),
        Reply = _{ok: true, did: act, command: Cmd, action: AText, outcome: OText}
    % Not an available action in this game.
    ;   Reply = _{ok: false, error: "That action is not available in this game."}
    ),
    % Commit.
    !.
% Anything else is unknown.
ma_control(_, _, _{ok: false, error: "Unknown command."}).

% ma_handle_hint(+Request): ground and inject a human clue, exactly as the
% specification's pseudocode prescribes (Section 10.4).
ma_handle_hint(Request) :-
    % Read the JSON body.
    http_read_json_dict(Request, Body),
    % Token, text, and session are required; ref may be a clicked cell.
    _{token: Tk, text: Text, session_id: Sid} :< Body,
    % The clicked reference, or none.
    ( get_dict(ref, Body, Ref0) -> Ref = Ref0 ; Ref = none ),
    % Only a mentor may guide.
    (   mc_verify_session(Tk, GuideId)
    % The safety check remains in force on all human text.
    ->  (   ma_hint_safe(Text)
        % Ground the clue into a Causalontology assertion.
        ->  (   co_ground(Text, Ref, Assertion)
            % Route it through the teach queue with game-play auto-approve.
            ->  term_to_atom(Assertion, FactAtom),
                % The review queue types its session as an atom.
                atom_string(SidAtom, Sid),
                % Propose the clue as a fact.
                mc_propose_fact(FactAtom, GuideId, SidAtom, QId),
                % Auto-approve: a clue biases a run, not permanent knowledge.
                mc_approve_fact(QId, GuideId),
                % Bias the live loop.
                ma_inject(Assertion),
                % Answer with the grounding.
                term_to_atom(Assertion, AText),
                % Reply.
                reply_json_dict(_{ok: true, grounded: AText})
            % An ungroundable clue is reported honestly.
            ;   reply_json_dict(_{ok: false, error: "I could not ground that clue."})
            )
        % Unsafe text is declined gently.
        ;   reply_json_dict(_{ok: false, error: "That message cannot be used here."})
        )
    % Refuse the unauthenticated.
    ;   reply_json_dict(_{ok: false, error: "Not signed in."})
    ).

% ma_handle_why(+Request): why Mentova took the last action.
ma_handle_why(_Request) :-
    % Fetch the justification.
    (   ma_why(why(Action, Basis, Provenance))
    % Render it for JSON.
    ->  term_to_atom(Action, AText),
        % The basis.
        term_to_atom(Basis, BText),
        % Reply with the full story.
        reply_json_dict(_{action: AText, basis: BText, provenance: Provenance})
    % No action has been taken yet.
    ;   reply_json_dict(_{action: none, basis: none, provenance: none})
    ).

% ma_handle_mode(+Request): read the mode (GET) or switch it (POST).
ma_handle_mode(Request) :-
    % The HTTP method.
    memberchk(method(Method), Request),
    (   Method == post
    % A POST switches the mode.
    ->  http_read_json_dict(Request, Body),
        % The requested mode as an atom.
        ( get_dict(mode, Body, MStr) -> atom_string(Mode, MStr) ; Mode = guided ),
        % Apply it if valid.
        ( catch(ma_set_mode(Mode), _, fail)
        ->  reply_json_dict(_{ok: true, mode: Mode})
        ;   reply_json_dict(_{ok: false, error: "Unknown mode."})
        )
    % A GET reports the current mode and game.
    ;   ma_mode(Mode), ma_selected_game(Game),
        reply_json_dict(_{ok: true, mode: Mode, game: Game})
    ).

% ma_handle_games(+Request): the selectable environments as JSON, from the
% active source (live when connected, otherwise the local stand-ins).
ma_handle_games(_Request) :-
    % The current selection.
    ma_selected_game(Sel),
    % One entry per available environment in the active source.
    findall(_{id: Id, title: Title, selected: IsSel},
        ( ma_available_game(Id, Title),
          ( Id == Sel -> IsSel = true ; IsSel = false ) ),
        Games),
    % The active source and whether a live key is configured or connected.
    ma_source(Source),
    % Whether a key is present.
    ( al_has_key -> HasKey = true ; HasKey = false ),
    % Whether the live session is open.
    ( al_connected -> Conn = true ; Conn = false ),
    % Reply.
    reply_json_dict(_{ok: true, games: Games, selected: Sel,
                      source: Source, key_configured: HasKey, connected: Conn}).

% ma_handle_live_status(+Request): the live connection status as JSON.
ma_handle_live_status(_Request) :-
    % Delegate to the live client's status.
    al_status(Status),
    % Reply.
    reply_json_dict(Status).

% ma_handle_actions(+Request): the labelled action panel for the selected game.
ma_handle_actions(_Request) :-
    % The selected environment.
    ma_selected_game(Sel),
    % Its labelled action descriptors.
    ma_action_descriptors(Sel, Actions),
    % Reply.
    reply_json_dict(_{ok: true, game: Sel, actions: Actions}).

% ma_handle_conclude(+Request): learn from a won game, write the package, restart.
ma_handle_conclude(_Request) :-
    (   ma_conclude_won(won_package(Game, StepCount, Report, learned(WinPath, Reinforced, Levers)))
    % Concluded a win: report what was learned, then restart the environment.
    ->  length(WinPath, PathLen),
        length(Levers, LeverCount),
        catch(ma_restart(_, _), _, true),
        reply_json_dict(_{ok: true, game: Game, steps: StepCount, report: Report,
                          learned: _{win_path_actions: PathLen,
                                     relations_reinforced: Reinforced,
                                     levers_set: LeverCount}})
    % Nothing to conclude.
    ;   reply_json_dict(_{ok: false,
                          error: "The game is not won yet, or there is no session to conclude."})
    ).

% ma_handle_live_connect(+Request): attempt to connect the live environments.
ma_handle_live_connect(_Request) :-
    % Try to connect.
    al_connect(Result),
    (   Result = connected(N)
    % On success switch to the live source and select the first live game.
    ->  ma_set_source(live),
        retractall(ma_game_sel_(_)),
        ma_default_game(First), assertz(ma_game_sel_(First)),
        % Start the selected live game fresh.
        catch(ma_reset_env(First, _), _, true),
        % End any solo run from before.
        ma_solo_clear,
        % Report success with the status.
        al_status(Status),
        reply_json_dict(Status.put(_{ok: true, connected_games: N}))
    % On failure stay local and report why.
    ;   Result = error(Reason),
        term_to_atom(Reason, RText),
        al_status(Status),
        reply_json_dict(Status.put(_{ok: false, error: RText}))
    ).

% ma_handle_live_disconnect(+Request): drop the live session, back to local.
ma_handle_live_disconnect(_Request) :-
    % Forget the live session.
    al_disconnect,
    % Switch back to the local stand-ins.
    ma_set_source(local),
    % Select the local default and reset it.
    retractall(ma_game_sel_(_)),
    % The local default.
    ma_default_game(Local), assertz(ma_game_sel_(Local)),
    % Reset it.
    catch(ma_reset_env(Local, _), _, true),
    % End any solo run.
    ma_solo_clear,
    % Reply.
    reply_json_dict(_{ok: true, source: local, game: Local}).

% ma_handle_select(+Request): choose the active game environment.
ma_handle_select(Request) :-
    % Read the body.
    http_read_json_dict(Request, Body),
    % The requested game as an atom.
    ( get_dict(game, Body, GStr) -> atom_string(Game, GStr) ; Game = ls20 ),
    % Apply it if registered.
    ( catch(ma_set_game(Game), _, fail)
    ->  reply_json_dict(_{ok: true, game: Game})
    ;   reply_json_dict(_{ok: false, error: "Unknown game."})
    ).

% ma_handle_restart(+Request): restart the selected environment in the active mode.
ma_handle_restart(_Request) :-
    % Restart, honouring the active mode.
    ma_restart(_Mode, Reply),
    % Reply.
    reply_json_dict(Reply).

% ma_handle_solo_tick(+Request): advance the solo run one step, with telemetry.
ma_handle_solo_tick(_Request) :-
    % Only advance in solo mode; guided mode returns an idle tick.
    (   ma_mode(solo)
    ->  ma_solo_tick(T)
    ;   ma_selected_game(Sel), ma_solo_final_telemetry(Sel, T)
    ),
    % Reply with the telemetry.
    reply_json_dict(T).

% ma_handle_attempts(+Request): the solo report filenames as JSON, newest first.
ma_handle_attempts(_Request) :-
    % The report filenames.
    ma_attempts_list(Files),
    % Reply.
    reply_json_dict(_{ok: true, attempts: Files}).

% ma_handle_attempt_view(+Request): serve one solo report as plain text.
ma_handle_attempt_view(Request) :-
    % Read the requested filename parameter.
    http_parameters(Request, [file(File, [atom])]),
    % The reports directory.
    ma_attempts_dir(Dir),
    % Reject any filename that is not a plain stamped report (no path traversal).
    (   atom_concat('ARC-AGI-3_Solo_', _, File),
        atom_concat(_, '.txt', File),
        \+ sub_atom(File, _, _, _, '/'),
        \+ sub_atom(File, _, _, _, '..')
    % Safe: serve the file as plain text.
    ->  atomic_list_concat([Dir, '/', File], Path),
        ( exists_file(Path)
        ->  http_reply_file(Path, [mime_type('text/plain; charset=UTF-8'), unsafe(true)], Request)
        ;   format('Content-type: text/plain~n~n'), format('Report not found.~n')
        )
    % Unsafe: refuse.
    ;   format('Content-type: text/plain~n~n'), format('Invalid report name.~n')
    ).

% ma_handle_attempts_page(+Request): serve the solo attempts record page.
ma_handle_attempts_page(Request) :-
    % Serve the listing page from the assets when it exists.
    (   exists_file('assets/arc/attempts.html')
    ->  http_reply_file('assets/arc/attempts.html', [unsafe(true)], Request)
    % Otherwise a plain-text pointer keeps the route alive.
    ;   format('Content-type: text/plain~n~n'),
        format('Solo attempts are listed by /api/arc/attempts.~n')
    ).
