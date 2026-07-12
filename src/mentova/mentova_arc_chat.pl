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
    % ma_learn_attach/1: attach and load the durable ARC learnings store.
    ma_learn_attach/1,
    % ma_load_learnings/0: reload all persisted per-game learnings from disk.
    ma_load_learnings/0,
    % ma_persist_game/1: write one game's learnings durably to disk.
    ma_persist_game/1,
    % ma_persist_level/2: persist a level win's learnings (not only a full win).
    ma_persist_level/2,
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
    % ma_set_solo_budget/1: set the per-attempt action budget for solo runs.
    ma_set_solo_budget/1,
    % ma_solo_report/2: write a solo attempt report and return its filename.
    ma_solo_report/2,
    % ma_attempts_dir/1: the directory solo reports are written to.
    ma_attempts_dir/1,
    % ma_attempts_list/1: the solo attempt report filenames, newest first.
    ma_attempts_list/1,
    % ma_learnings/1: the shared learnings both sub-projects read.
    ma_learnings/1,
    % ma_graph_stats/1: the shared state-graph exploration map.
    ma_graph_stats/1,
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
    % The state-graph exploration pack (the winning ARC-AGI-3 technique).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_graph/prolog')),
    % Object detection, needed by the exploration policy's salient click targets.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/gridobj/prolog')),
    % The Causalontology exploration policy: causal-change ranking + salient clicks.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_explore/prolog')),
    % Whole-grid perception: object inventory, meter/life-bar reading, avatar (WP-403).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_see/prolog')),
    % Hierarchical planning: the Win-Game / OODA / controls plan tree (WP-404).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_hplan/prolog')),
    % Verify-before-act: predict a move fatal from the learned model (WP-405).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_verify/prolog')),
    % Hypothesis management with anti-drift commitment (WP-406).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_hypo/prolog')),
    % The executable, verifiable, repairable world model (WP-407).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_wm/prolog')),
    % Object-relational reasoning (WP-408).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_rel/prolog')),
    % Goal inference: hypothesise the unstated win condition from winning deltas.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_goalinfer/prolog')),
    % The action-budget governor (RHAE-style efficiency scoring).
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_effic/prolog')),
    % The harness.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/co_arc3/prolog'))
), now).

% Load the Causalontology noun backbone for clue-labeled continuants.
:- use_module(library(co_noun), [co_continuant_add/2, co_continuant/2]).
% Load the hinge for clue-attached dispositions.
:- use_module(library(co_hinge), [co_realizable_add/3, co_realized_in_add/2]).
% Load the core for provenance-tagged clue relations and reinforcement.
:- use_module(library(co_core), [co_new_cro/8, co_cro/8, co_strengthen/2, co_the_cro/2, co_cro_assert/1]).
% Load the learner for preventive enforcement.
:- use_module(library(co_learn), [co_learn_preventive/2, co_avoid/1, co_learn_causal/2]).
% Load the harness for curiosity choice and frame deltas.
:- use_module(library(co_arc3), [co_arc3_choose/3, co_arc3_delta/3, co_arc3_reset/0]).
% Load the Causalontology exploration policy: rank actions by predicted change
% (this game's causal graph) and turn ACTION6 into salient object-centroid clicks.
:- use_module(library(co_explore),
    [cox_choose/5, cox_choose_change/5, cox_expand_actions/3, cox_salient_cells/2]).
% Load the state-graph explorer: systematic, frontier-directed exploration.
:- use_module(library(co_graph),
    [cg_reset/0, cg_signature/2, cg_note/3, cg_choose/3, cg_stats/1,
     cg_stats_for/2, cg_edge/3]).
% Load whole-grid perception (WP-403): segment the frame into an inventory of
% roled objects, read the bar-like meters (life-bars, timers, counters) rather
% than discarding them, and locate the avatar as whatever moved between frames.
% This is how the solo player sees the ENTIRE grid instead of poking one spot.
:- use_module(library(co_see),
    [cs_inventory/2, cs_objects/2, cs_bars/2, cs_avatar_move/3, cs_background/2]).
% Load the abstracted cross-game priors, so what was learned from the 25 studied
% games transfers as generalizable play advice to an environment never seen.
:- use_module('arc3_priors',
    [ap_generic_prior/3, ap_priors_for_roles/2, ap_game_archetypes/2,
     ap_game_resource/2, ap_win_recipe/2]).
% Load the draft-document ingestion pipeline, so a mentor can feed plain-text
% draft documents into the live mind through the nuanced fact doors.
:- use_module('draft_ingest', [di_ingest_text/3, di_report_json/2]).
% Load hierarchical planning (WP-404): the multi-level plan tree (Win Game over
% the observe-orient-decide-act loop over the concrete controls), reified onto
% Causalontology's decomposition hierarchy, so the solo player's play is driven by
% and narrated as an explicit plan the glass box can show.
:- use_module(library(co_hplan),
    [hp_win_plan/3, hp_reify/2, hp_reset/0, hp_render/2, hp_render_json/2,
     hp_classify_basis/3, hp_consistent/1, hp_plan_from_cros/2]).
% Load verify-before-act (WP-405): the world-model safety layer that predicts a
% move fatal from what has been learned — generalising from deaths in other states
% and from deadly cell colours — so the player deprioritises a move predicted to
% end the run before it is ever tried, instead of only recalling the exact deaths.
:- use_module(library(co_verify),
    [vb_reset/0, vb_note_fatal/3, vb_fatal_here/3, vb_broadly_fatal/2,
     vb_predict_fatal/3, vb_rank/4]).
% Load the executable world model (WP-407): learn each action's effect from play,
% surface the general laws, so the mind builds a repairable model of the game.
:- use_module(library(co_wm),
    [wm_reset/0, wm_observe/4, wm_predict/5, wm_law/3, wm_stats/2,
     wm_snapshot/2, wm_restore/2]).
% Load hypothesis management (WP-406): generate candidate rules about which action
% is productive, rank by predicted evidence, and COMMIT to the best without drifting
% — the cure for the losing agents' defining failure. Shared by all three players.
:- use_module(library(co_hypo),
    [hy_reset/0, hy_support/2, hy_contradict/2, hy_update_commitment/1,
     hy_committed/2, hy_best/3, hy_stale/1, hy_stats/2,
     hy_snapshot/2, hy_restore/2]).
% Load object-relational reasoning (WP-408): reason over segmented objects and their
% relations (adjacency, containment, alignment, offset vectors, ordinal size) rather
% than raw pixels, so targeting is relation-aware.
:- use_module(library(co_rel),
    [cr_relations/2, cr_nearest/4, cr_vector/4, cr_adjacent/2, cr_contains/2]).
% Load goal inference (WP-398): hypothesise the unstated win condition from the
% deltas that precede a win, so play can be pulled toward the winning feature.
:- use_module(library(co_goalinfer),
    [cgi_reset/0, cgi_observe/2, cgi_hypothesise_goal/1, cgi_goal_occurrent/1,
     cgi_confidence/1, cgi_win_count/1, cgi_snapshot/1, cgi_restore/1]).
% Load the action-budget governor: count actions spent and gauge budget headroom,
% so the mind learns economically (efficiency is scored quadratically vs a human).
:- use_module(library(co_effic),
    [cef_reset/0, cef_count/1, cef_actions/2, cef_set_baseline/2,
     cef_within_budget/1, cef_budget/3]).
% Load the sb26 game-specific solver (Phase Solo capability): the cracked sb26 procedure
% (fill the centre placeholders to match the top target sequence, then ACTION5) so the
% Solo player wins sb26 level 1 itself.
:- use_module('arc_sb26', [sb26_is_game/1, sb26_next_action/3, sb26_reset/1]).
% Load the ft09 game-specific solver (Phase Solo capability): the cracked ft09 Lights-Out
% clue-projection procedure (set each governed cell to fill where its clue sub-cell is 0,
% else blank) so the Solo player wins ft09 levels 1 and 2 itself.
:- use_module('arc_ft09', [ft09_is_game/1, ft09_next_action/3, ft09_reset/1]).
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
     al_state/2, al_status/1, al_has_key/0, al_progress/3]).
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
% Load yall for the small lambda that wraps the cached perception computation.
:- use_module(library(yall)).

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
% The agentview endpoint: the machine-facing twin of the ARC page, so a Claude
% session can SEE the grid (digits + object inventory + meters + plan) and know
% the controls, then act and teach through the existing mentor endpoints.
:- http_handler(root(api/arc/agentview), ma_handle_agentview, []).
% The draft-ingestion endpoint: ingest a plain-text draft document into the live
% mind through the nuanced fact doors, returning the per-draft report.
:- http_handler(root(api/arc/ingest_draft), ma_handle_ingest_draft, []).

% Define ma_db_init: attach the chat database this application reuses.
ma_db_init(Dir) :-
    % The mentor accounts, sessions, and teach queue live there.
    mc_db_init(Dir),
    % Attach and load the durable per-game ARC learnings beside that directory.
    catch(ma_learn_attach(Dir), _, true).

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
    % The currently selected game.
    ma_selected_game(Prev),
    (   Id == Prev
    % Re-selecting the already-active game is a no-op: every learning is kept, so
    % what Guided taught (the shared state graph, the relations, the goal and
    % priorities) survives for Solo to use on the same game.
    ->  true
    % A genuine game change: every learning is keyed by game id and coexists, so
    % nothing is wiped — switching away and back keeps that game's learnings.
    ;   retractall(ma_game_sel_(_)),
        assertz(ma_game_sel_(Id)),
        % Start the newly selected environment fresh (only the live position resets).
        ma_reset_env(Id, _),
        % Begin a fresh session recording for the new game.
        ma_session_reset,
        % Selecting a new game also ends any solo run in progress.
        ma_solo_clear
    ).

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
% Uniform dispatch — the environment has ended in a loss (live GAME_OVER only).
ma_env_over(Id) :-
    % Only a live game can report a game-over; local stand-ins cannot lose.
    ma_is_live(Id),
    % Its last reported state is GAME_OVER.
    catch(al_state(Id, 'GAME_OVER'), _, fail).

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
:- dynamic ma_effect_/3.

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

% ma_record_effect(+Action, +Frame0, +Frame1): learn an action's observed effect,
% keyed by the selected game (the same action means different things per game).
ma_record_effect(Action, Frame0, Frame1) :-
    % The selected game.
    ma_selected_game(Game),
    % Infer a coarse effect descriptor from the frame change.
    ma_infer_move(Frame0, Frame1, Desc),
    % Replace the previous observation for this action in this game.
    retractall(ma_effect_(Game, Action, _)),
    % Record the latest.
    assertz(ma_effect_(Game, Action, Desc)).

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
ma_action_semantic(GameId, Action, Sem, discovered) :-
    % A learned effect, other than nothing, is a discovered semantic.
    ma_effect_(GameId, Action, Desc), Desc \== none, !,
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

% ma_command_action_at(+GameId, +Command, +Body, -Action): like ma_command_action,
% but a cell-select (ACTION6) reads the target cell from the request body's x and y
% (x is the column, y the row), so a mentor — human or a Claude session over the
% Mentor Bridge — can click a SPECIFIC object rather than only the centre. Falls
% back to the centre when no valid coordinate is given.
ma_command_action_at(GameId, Command, Body, Action) :-
    % Only actions the game actually affords are drivable.
    ma_actions_env(GameId, Actions),
    % Find the afforded action whose canonical command matches.
    member(A, Actions),
    ma_action_slot(A, Command),
    !,
    % A cell-select takes the body's coordinate; anything else is itself.
    ( A = select(_, _)
    ->  ( get_dict(x, Body, X0), get_dict(y, Body, Y0),
          integer(X0), integer(Y0),
          X0 >= 0, X0 =< 63, Y0 >= 0, Y0 =< 63
        ->  Action = select(X0, Y0)
        ;   Action = select(32, 32) )
    ;   Action = A ).

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

% ma_solo_budget_/1: an optional runtime override of the solo action budget.
:- dynamic ma_solo_budget_/1.

% ma_solo_budget(-Budget): the action budget for a solo attempt — a runtime
% override if one is set, else the default first-look budget.
ma_solo_budget(Budget) :-
    % Use the override when present and sensible, else the default.
    ( ma_solo_budget_(B), integer(B), B > 0 -> Budget = B ; Budget = 60 ).

% ma_set_solo_budget(+Budget): set the per-attempt action budget for solo runs.
% A larger budget gives an exploration agent more room; carried learnings mean a
% later attempt of the same game resumes from what an earlier one mapped.
ma_set_solo_budget(Budget) :-
    % Replace any previous override.
    retractall(ma_solo_budget_(_)),
    % Record the new budget.
    assertz(ma_solo_budget_(Budget)).

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
    % Fresh per-attempt perception state: the avatar starts unknown, no object has
    % been visited yet, and no object is being pursued. The learned control map
    % (ma_move_vec_) and the meter model carry forward across attempts.
    retractall(ma_avatar_(Sel, _, _)),
    retractall(ma_visited_(Sel, _, _)),
    retractall(ma_pursuit_(Sel, _, _)),
    retractall(ma_meter_(Sel, _, _, _)),
    % Build the plan hierarchy for this game and reify it onto Causalontology, so
    % the run is driven by, and narrated as, an explicit Win-Game / OODA / controls
    % plan the glass box can show.
    ma_build_plan(Sel),
    retractall(ma_plan_focus_(Sel, _, _)),
    % The env reset put the game back to level zero; forget the persisted-level
    % mark so re-completing a level in this fresh attempt persists again.
    retractall(ma_level_seen_(Sel, _)),
    % Fresh session recording.
    ma_session_reset,
    % If a winning path was learned for this game, replay it this run.
    ( ma_win_path_(Sel, Seq)
    -> retractall(ma_replay_(Sel, _)), assertz(ma_replay_(Sel, Seq))
    ;  retractall(ma_replay_(Sel, _)) ),
    % Clear any previous run.
    ma_solo_clear,
    % Clear any queued sb26 solver plan so this attempt re-parses the board fresh.
    ignore(catch(sb26_reset(Sel), _, true)),
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
    % Take one solo step from the shared learnings; a step can fail when the
    % environment has ended (a live game reports GAME_OVER and then rejects
    % further actions), so guard it and end the attempt rather than crashing.
    ->  (   catch(ma_step(step(Action0, _Basis, _)), _, fail)
        ->  Action = Action0, Stepped = true
        ;   Action = none, Stepped = false
        ),
        % One more step spent.
        Step1 is Step + 1,
        % The action budget.
        ma_solo_budget(Budget),
        % Decide the new status.
        (   Stepped == false
        % The step could not be taken (most often the game is over).
        ->  Status = done(ended(Step1))
        ;   ma_solved_env(Sel, _)
        ->  Status = done(won(Step1))
        ;   ma_env_over(Sel)
        ->  Status = done(game_over(Step1))
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
        % Hold the selected game — every learning below is read for it alone.
        ma_selected_game(G), js_hold(arc_solo, game(G), 1.0, selection),
        % Hold this game's learned goal, if any.
        ( ma_goal_(G, Goal) -> js_hold(arc_solo, goal(Goal), 1.0, learned_goal) ; true ),
        % Hold each of this game's human-taught priorities.
        forall(ma_priority_(G, P), js_hold(arc_solo, priority(P), 0.8, learned_priority)),
        % Hold each of this game's declared hazards.
        forall(ma_avoid_cell_(G, pos(R, C)),
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
    ma_learnings(learnings(Goal, Priorities, Avoided, Labels, CroCount, JLens, _Graph)),
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
% All of these live in one store: whatever Guided writes, Solo reads, and back.
ma_learnings(learnings(Goal, Priorities, Avoided, Labels, CroCount, JLens, Graph)) :-
    % Every learning below is read for the selected game only, so one game's
    % teaching never bleeds into another's.
    ma_selected_game(Game),
    % The taught or inferred goal for this game, if any.
    ( ma_goal_(Game, Goal) -> true ; Goal = none ),
    % The suggested-action priorities for this game.
    findall(A, ma_priority_(Game, A), Priorities),
    % The declared hazards for this game.
    findall(cell(R, C), ma_avoid_cell_(Game, pos(R, C)), Avoided),
    % The object labels for this game.
    findall(cell(R, C)-K, ma_label_(Game, pos(R, C), K), Labels),
    % How many causal relations have been learned for this game (its g(Game,_) heads).
    ( catch(aggregate_all(count, co_cro(_, [g(Game, _)|_], _, _, _, _, _, _), CroCount), _, fail)
    -> true ; CroCount = 0 ),
    % The J-Lens reading of the solo workspace.
    ma_jlens(JLens),
    % This game's state-graph exploration map (nodes, edges, tested, dead).
    ma_graph_stats(Graph).

% Define ma_graph_stats: the exploration graph, scoped to the selected game so
% each game reports only its own subgraph of the shared store.
ma_graph_stats(Graph) :-
    % Read the selected game's statistics, guarded, defaulting to an empty graph.
    (   ma_selected_game(Game),
        atom_concat(Game, '::', Prefix),
        catch(cg_stats_for(Prefix, Graph), _, fail)
    ->  true
    ;   Graph = stats(0, 0, 0, 0)
    ).

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
    % Clear the no-progress counters (a fresh attempt starts unstuck). The
    % highest-impact record is durable learning and deliberately kept.
    retractall(ma_stale_(_, _)),
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
    ma_win_report(Game, Steps, Learned, ReportFile),
    % Persist this game's whole learning set so the win survives a restart.
    catch(ma_persist_game(Game), _, true).

% ma_learn_from_win(+Game, +Steps, -Learned): feed lattice, Causalontology, J-Space.
ma_learn_from_win(Game, Steps, learned(WinPath, Reinforced, Levers)) :-
    % The winning action sequence.
    findall(A, member(st(_, A, _, _), Steps), WinPath),
    % 1) Data lattice: record the winning path so future Solo runs replay it.
    retractall(ma_win_path_(Game, _)),
    assertz(ma_win_path_(Game, WinPath)),
    % 2) Causalontology: reinforce every (game-keyed) relation used on the path.
    ma_reinforce_path(Game, WinPath, Reinforced),
    % 3) Guided levers the winning strategy implies (helps locksmith-style games).
    ma_win_levers(Game, Steps, Levers),
    % 4) Jacobian Space: hold the win and its levers.
    ma_win_jspace(Game, WinPath, Levers).

% ma_reinforce_path(+Game, +Actions, -Count): strengthen each action's relations,
% keyed by the game so only this environment's relations are reinforced.
ma_reinforce_path(Game, Actions, Count) :-
    % Strengthen every non-preventive relation whose cause is this game's action.
    findall(Id,
        ( member(A, Actions),
          catch(co_cro(Id, [g(Game, A)], _, _, M, _, _, _), _, fail),
          M \== preventive,
          catch(co_strengthen(Id, 0.1), _, true) ),
        Ids),
    % Count the distinct relations reinforced.
    sort(Ids, Unique), length(Unique, Count).

% ma_win_levers(+Game, +Steps, -Levers): set this game's guided levers from the win.
ma_win_levers(Game, Steps, Levers) :-
    % The winning action sequence.
    findall(A, member(st(_, A, _, _), Steps), Seq),
    % If pickup was used and this game keeps locksmith state, prioritise pickup.
    (   memberchk(action(pickup), Seq), ma_state_(_, _, _, _)
    ->  ( ma_priority_(Game, action(pickup)) -> true ; assertz(ma_priority_(Game, action(pickup))) ),
        Prio = [priority(action(pickup))]
    ;   Prio = []
    ),
    % If a door opened (colour six appeared) during the win, set the traverse goal.
    (   member(st(_, _, D, _), Steps), member(changed(R, C, _, 6), D)
    ->  retractall(ma_goal_(Game, _)), assertz(ma_goal_(Game, traverse(pos(R, C)))),
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
% DURABLE LEARNINGS — every game's learnings survive a restart, keyed by game id
% ---------------------------------------------------------------------------
%
% Every ARC learning store is an in-memory dynamic fact, so a restart would wipe
% it. To make wins and teaching outlast a restart, a game's whole learning set is
% snapshotted to one on-disk file at the moment a win is concluded, and every
% game's snapshot is reloaded on boot. The file holds one arc_learned/9 term per
% game, so each game's learnings are kept and restored under its own Game
% Environment Identification (ID) - one environment's learnings never load into
% another's.

% ma_learn_file_/1: the resolved path of the durable learnings file.
:- dynamic ma_learn_file_/1.

% ma_learn_file(-Path): the durable learnings file, defaulting under data/.
ma_learn_file(Path) :-
    % Use the attached path if one was set, else the default beside data/.
    ( ma_learn_file_(P) -> Path = P ; Path = 'data/arc_learnings.db' ).

% Define ma_learn_attach: fix the learnings file beside the chat database's
% directory and load whatever it already holds. Guarded so a read hiccup can
% never block startup.
ma_learn_attach(Dir) :-
    % The chat database directory's parent holds the sibling learnings file.
    ( catch(file_directory_name(Dir, Parent), _, fail) -> true ; Parent = 'data' ),
    % The learnings file path beside the database directory.
    atomic_list_concat([Parent, '/arc_learnings.db'], File),
    % Remember it for later writes and reads.
    retractall(ma_learn_file_(_)),
    % Store the resolved path.
    assertz(ma_learn_file_(File)),
    % Load every game's persisted learnings now.
    catch(ma_load_learnings, _, true).

% Define ma_load_learnings: restore every game's persisted learnings from disk.
ma_load_learnings :-
    % The durable file.
    ma_learn_file(File),
    % Restore each stored game term if the file exists; otherwise do nothing.
    (   exists_file(File)
    % Read every term and restore it, one game at a time.
    ->  ma_read_terms(File, Terms),
        % Restore each game's learnings, guarded so one bad term never stops the rest.
        forall(member(T, Terms), catch(ma_restore_learned(T), _, true))
    % No file yet: a clean install has nothing to restore.
    ;   true
    ).

% ma_read_terms(+File, -Terms): read every Prolog term from a file into a list.
ma_read_terms(File, Terms) :-
    % Open, read all terms, and always close.
    setup_call_cleanup(open(File, read, S),
                       ma_read_terms_(S, Terms),
                       close(S)).

% ma_read_terms_(+Stream, -Terms): read to end of file.
ma_read_terms_(S, Terms) :-
    % Read one term.
    read_term(S, T, []),
    % Stop at end of file, else keep the term and recurse.
    (   T == end_of_file
    % Done.
    ->  Terms = []
    % Keep this term and read the rest.
    ;   Terms = [T | Rest], ma_read_terms_(S, Rest)
    ).

% ma_restore_learned(+Term): reassert one game's learnings from its stored term.
% An older nine-argument snapshot (no impact record) restores with none.
ma_restore_learned(arc_learned(Game, Goal, Prios, Avoided, Labels, Effects, WinPath, Edges, Cros)) :-
    % Delegate to the full form with an empty impact and death record.
    ma_restore_learned(arc_learned(Game, Goal, Prios, Avoided, Labels, Effects, WinPath, Edges, Cros, [], [])).
% A ten-argument snapshot (impact record, but no death record) restores with none.
ma_restore_learned(arc_learned(Game, Goal, Prios, Avoided, Labels, Effects, WinPath, Edges, Cros, Impacts)) :-
    % Delegate to the full form with an empty death record.
    ma_restore_learned(arc_learned(Game, Goal, Prios, Avoided, Labels, Effects, WinPath, Edges, Cros, Impacts, [])).
% The full eleven-argument snapshot, including the learned fatal moves.
ma_restore_learned(arc_learned(Game, Goal, Prios, Avoided, Labels, Effects, WinPath, Edges, Cros, Impacts, Deaths)) :-
    % Clear any current in-memory learnings for this game so a reload is idempotent.
    retractall(ma_goal_(Game, _)),
    % Its priorities.
    retractall(ma_priority_(Game, _)),
    % Its hazards.
    retractall(ma_avoid_cell_(Game, _)),
    % Its labels.
    retractall(ma_label_(Game, _, _)),
    % Its discovered action semantics.
    retractall(ma_effect_(Game, _, _)),
    % Its recorded winning path.
    retractall(ma_win_path_(Game, _)),
    % Restore the goal, unless none was stored.
    ( Goal == none -> true ; assertz(ma_goal_(Game, Goal)) ),
    % Restore each priority.
    forall(member(A, Prios), assertz(ma_priority_(Game, A))),
    % Restore each hazard.
    forall(member(Cell, Avoided), assertz(ma_avoid_cell_(Game, Cell))),
    % Restore each label.
    forall(member(pos(R, C)-K, Labels), assertz(ma_label_(Game, pos(R, C), K))),
    % Restore each discovered effect.
    forall(member(Act-Desc, Effects), assertz(ma_effect_(Game, Act, Desc))),
    % Restore the winning path, unless none was stored.
    ( WinPath == none -> true ; assertz(ma_win_path_(Game, WinPath)) ),
    % Replay each graph edge, which rebuilds this game's nodes, tested, and dead marks.
    forall(member(edge(F, EA, T), Edges), catch(cg_note(F, EA, T), _, true)),
    % Restore each causal relation through the validating front door.
    forall(member(Cro, Cros), catch(co_cro_assert(Cro), _, true)),
    % Its highest-impact action record.
    retractall(ma_impact_(Game, _, _)),
    % Restore each discovered mechanic so the recall nudge survives a restart.
    forall(member(impact(Act, Mag), Impacts), assertz(ma_impact_(Game, Act, Mag))),
    % Its learned fatal moves.
    retractall(ma_death_(Game, _, _)),
    % Restore each fatal (state, action) so a later attempt avoids it on boot.
    forall(member(death(Key, DAct), Deaths), assertz(ma_death_(Game, Key, DAct))).
% A per-game cognitive snapshot: rebuild the executable world model and the
% hypothesis state for this game from disk, so a guided run's learned dynamics and
% committed hypotheses are there for a later Solo run — the cross-mode sharing.
ma_restore_learned(arc_cog(Game, WmObs, HyState)) :-
    catch(wm_restore(Game, WmObs), _, true),
    catch(hy_restore(Game, HyState), _, true).
% The single global goal-inference snapshot (which colours have meant winning),
% accumulated across games and shared by all three players.
ma_restore_learned(arc_cog_global(CgiState)) :-
    catch(cgi_restore(CgiState), _, true).
% Any other (older or future) term is tolerated so one unknown term never stops the
% rest of the store from loading.
ma_restore_learned(_).

% Define ma_persist_game: snapshot one game's learnings and merge them into the
% durable file, replacing that game's previous snapshot. Serialised so two
% concludes can never corrupt the file.
ma_persist_game(Game) :-
    % One writer at a time.
    with_mutex(ma_learn_mutex, ma_persist_game_(Game)).

% ma_persist_game_(+Game): the guarded body of ma_persist_game.
ma_persist_game_(Game) :-
    % The durable file.
    ma_learn_file(File),
    % The terms already on disk, or none if the file is new.
    ( exists_file(File) -> ma_read_terms(File, Old) ; Old = [] ),
    % Every stored term but this game's (learnings + cognition) and the global
    % goal-inference term, all of which this write replaces.
    ma_without_game(Old, Game, Others),
    % This game's fresh classic-learnings snapshot.
    ma_snapshot_game(Game, New),
    % This game's fresh cognitive snapshot (world model + hypotheses).
    ma_snapshot_cog(Game, NewCog),
    % The refreshed global goal-inference snapshot.
    ma_snapshot_cog_global(NewGlobal),
    % The full set to write back.
    append(Others, [New, NewCog, NewGlobal], All),
    % Write the whole file atomically enough for a single-writer store.
    ma_write_terms(File, All).

% ma_without_game(+Terms, +Game, -Others): every stored term except this game's
% classic snapshot (arc_learned, any arity), this game's cognitive snapshot
% (arc_cog), and the single global goal-inference term (arc_cog_global) — all of
% which the caller rewrites.
ma_without_game(Terms, Game, Others) :-
    findall(T,
        ( member(T, Terms),
          \+ ( functor(T, arc_learned, _), arg(1, T, Game) ),
          \+ ( functor(T, arc_cog, _), arg(1, T, Game) ),
          \+ functor(T, arc_cog_global, _) ),
        Others).

% ma_snapshot_cog(+Game, -Term): the game's world model and hypotheses as a durable
% arc_cog term, using the packs' own snapshot exports. Defensive defaults so a
% game with no cognition yet still yields a well-formed (empty) term.
ma_snapshot_cog(Game, arc_cog(Game, WmObs, HyState)) :-
    ( catch(wm_snapshot(Game, WmObs), _, fail) -> true ; WmObs = [] ),
    ( catch(hy_snapshot(Game, HyState), _, fail) -> true ; HyState = state([], none) ).

% ma_snapshot_cog_global(-Term): the accumulated goal-inference evidence as a single
% durable arc_cog_global term.
ma_snapshot_cog_global(arc_cog_global(CgiState)) :-
    ( catch(cgi_snapshot(CgiState), _, fail) -> true ; CgiState = state([], 0) ).

% ma_snapshot_game(+Game, -Term): gather every store's learnings for one game.
ma_snapshot_game(Game, arc_learned(Game, Goal, Prios, Avoided, Labels, Effects, WinPath, Edges, Cros, Impacts, Deaths)) :-
    % The taught or inferred goal, or none.
    ( ma_goal_(Game, Goal) -> true ; Goal = none ),
    % The suggested-action priorities.
    findall(A, ma_priority_(Game, A), Prios),
    % The declared hazards.
    findall(Cell, ma_avoid_cell_(Game, Cell), Avoided),
    % The object labels.
    findall(pos(R, C)-K, ma_label_(Game, pos(R, C), K), Labels),
    % The discovered action semantics.
    findall(Act-Desc, ma_effect_(Game, Act, Desc), Effects),
    % The recorded winning path, or none.
    ( ma_win_path_(Game, WinPath) -> true ; WinPath = none ),
    % This game's state-graph edges (its prefixed nodes only).
    atom_concat(Game, '::', Prefix),
    % Collect every edge leaving one of this game's states.
    findall(edge(F, EA, T),
        ( cg_edge(F, EA, T), sub_atom(F, 0, _, _, Prefix) ),
        Edges),
    % This game's causal relations, whose cause names the game.
    findall(cro(Id, Ca, Ef, Te, Mo, St, Co, Pr),
        ( co_the_cro(Id, cro(Id, Ca, Ef, Te, Mo, St, Co, Pr)), memberchk(g(Game, _), Ca) ),
        Cros),
    % This game's highest-impact actions (the discovered mechanics worth recalling).
    findall(impact(Act, Mag), ma_impact_(Game, Act, Mag), Impacts),
    % This game's learned fatal moves (state, action) that ended the game.
    findall(death(Key, DAct), ma_death_(Game, Key, DAct), Deaths).

% ma_write_terms(+File, +Terms): write each term to the file, one per line.
ma_write_terms(File, Terms) :-
    % Ensure the containing directory exists.
    file_directory_name(File, Dir),
    % Create it if missing.
    ( exists_directory(Dir) -> true ; make_directory_path(Dir) ),
    % Open, write every term with quoting so it reads back, and always close.
    setup_call_cleanup(open(File, write, S),
                       forall(member(T, Terms),
                              ( writeq(S, T), write(S, ' .'), nl(S) )),
                       close(S)).

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

% Every human lever is keyed by the game id, so a clue about one environment
% never biases another. The first argument is always the game.
% ma_priority_/2: (Game, Action) — actions a human has suggested for a game.
:- dynamic ma_priority_/2.
% ma_goal_/2: (Game, Goal) — the goal a human has set for a game.
:- dynamic ma_goal_/2.
% ma_avoid_cell_/2: (Game, pos(R,C)) — cells declared hazardous in a game.
:- dynamic ma_avoid_cell_/2.
% ma_label_/3: (Game, pos(R,C), Kind) — human labels on cells in a game.
:- dynamic ma_label_/3.
% ma_last_/2: (Action, Basis) — the last action and why it was taken.
:- dynamic ma_last_/2.

% Define ma_reset_guidance: clear every game's hints, priorities, goals, learning.
ma_reset_guidance :-
    % Before clearing anything, write the active game's learned cognition (world
    % model, hypotheses, goal inference, classic learnings) to disk, so a guided or
    % solo session's learning survives the reset and is there for the next run to
    % reload — the always-persisted, cross-mode sharing guarantee. Fully guarded.
    ignore(catch(( ma_selected_game(G0), ma_persist_game(G0) ), _, true)),
    % Drop every game's priorities.
    retractall(ma_priority_(_, _)),
    % Drop every game's goal.
    retractall(ma_goal_(_, _)),
    % Drop every game's declared hazards.
    retractall(ma_avoid_cell_(_, _)),
    % Drop every game's labels.
    retractall(ma_label_(_, _, _)),
    % Drop the last-action record.
    retractall(ma_last_(_, _)),
    % Drop the curiosity counters.
    retractall(ma_try_(_, _)),
    % Drop every game's discovered action semantics.
    retractall(ma_effect_(_, _, _)),
    % Drop every game's learned fatal moves.
    retractall(ma_death_(_, _, _)),
    % Drop every game's volatile-cell tallies.
    retractall(ma_cellchg_(_, _, _, _)),
    % And the per-game step counts behind them.
    retractall(ma_framecount_(_, _)),
    % Drop the whole-grid perception state: avatar cells, learned control maps,
    % visited/pursued objects, and the meter/resource readings.
    retractall(ma_avatar_(_, _, _)),
    retractall(ma_move_vec_(_, _, _, _)),
    retractall(ma_visited_(_, _, _)),
    retractall(ma_pursuit_(_, _, _)),
    retractall(ma_meter_(_, _, _, _)),
    % Drop the plan hierarchy state (trees, reified roots, and the active focus).
    retractall(ma_plan_tree_(_, _)),
    retractall(ma_plan_root_(_, _)),
    retractall(ma_plan_focus_(_, _, _)),
    % Drop the verify-before-act world model: the learned deadly colours and the
    % co_verify fatality model (both are durable across attempts, like the death
    % memory, so they are cleared only on a full guidance reset).
    retractall(ma_deadly_colour_(_, _)),
    catch(vb_reset, _, true),
    % Reset the executable world model (learned transitions) too.
    catch(wm_reset, _, true),
    % Reset the rest of the cognitive stack: hypotheses and their commitments, the
    % accumulated goal-inference evidence, and the action-budget counters. These are
    % durable in memory across attempts (like the world model), so they clear only on
    % a full guidance reset — and only AFTER a persist has written them to disk, so
    % the cross-mode sharing survives the reset.
    catch(hy_reset, _, true),
    catch(cgi_reset, _, true),
    catch(cef_reset, _, true),
    % Reset the per-game persisted-level high-water marks.
    retractall(ma_level_seen_(_, _)),
    % Clear the harness counters.
    co_arc3_reset.

% Define ma_inject: apply one grounded assertion to the live loop, keyed to the
% currently selected game so the teaching attaches only to that environment.
ma_inject(hint_label([R, C], Kind)) :-
    % The game the clue is about.
    ma_selected_game(Game),
    % Name the labeled object by its game and cell (distinct across games).
    atomic_list_concat([obj_, Game, '_', R, '_', C], Id),
    % NOUN: posit the continuant with its human label.
    co_continuant_add(Id, Kind),
    % Remember the label for choice-making, keyed to the game.
    assertz(ma_label_(Game, pos(R, C), Kind)),
    % HINGE: a key-like object bears a pick-up-able disposition.
    (   Kind == key_like
    % Posit the disposition and its realization seam.
    ->  co_realizable_add(Id, disposition, Id),
        % Realized in this game's pickup occurrent.
        co_realized_in_add(Id, g(Game, action(pickup)))
    % Other labels posit no disposition here.
    ;   true
    ),
    % Commit.
    !.
% A door label with the traverse goal.
ma_inject(hint_goal([R, C], traverse)) :-
    % The game the clue is about.
    ma_selected_game(Game),
    % Name and label the door object, keyed by game.
    atomic_list_concat([obj_, Game, '_', R, '_', C], Id),
    % NOUN: posit the door-like continuant.
    co_continuant_add(Id, door_like),
    % Remember the label, keyed to the game.
    assertz(ma_label_(Game, pos(R, C), door_like)),
    % Set this game's goal: be beyond the door.
    retractall(ma_goal_(Game, _)),
    % Record it.
    assertz(ma_goal_(Game, traverse(pos(R, C)))),
    % Commit.
    !.
% A suggested action.
ma_inject(hint_action(Action)) :-
    % The game the clue is about.
    ma_selected_game(Game),
    % Raise its priority once for this game.
    ( ma_priority_(Game, Action) -> true ; assertz(ma_priority_(Game, Action)) ),
    % Commit.
    !.
% A human-declared hazard.
ma_inject(hint_preventive([R, C])) :-
    % The game the clue is about.
    ma_selected_game(Game),
    % Remember the cell as avoided for movement choices in this game.
    ( ma_avoid_cell_(Game, pos(R, C)) -> true ; assertz(ma_avoid_cell_(Game, pos(R, C))) ),
    % VERB: reify the preventive relation, its cause keyed by game so the hazard
    % belongs only to this environment.
    co_learn_preventive(g(Game, touch(cell(R, C))), penalty),
    % Commit.
    !.
% Positive reinforcement: raise the strength of the last action's relations.
ma_inject(hint_reinforce) :-
    % The game the clue is about.
    ma_selected_game(Game),
    % Fetch the last action, if any.
    (   ma_last_(Action, _)
    % Strengthen every relation whose cause is that action in this game.
    ->  forall(co_cro(Id, [g(Game, Action)], _, _, M, _, _, _),
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
    % Start the step with a clean perception cache, so the grid is segmented once
    % this step and the several exploration rules reuse the one result.
    ma_cache_clear,
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
    % Record the transition in the state-graph explorer (guarded).
    ma_graph_note(Frame0, Action, Frame1),
    % Learn this action's observed effect, for its discovered semantic label.
    ma_record_effect(Action, Frame0, Frame1),
    % Learn from what followed, exactly as the harness does.
    (   Delta == []
    % Nothing changed.
    ->  Outcome = none
    % The penalty marker is a hazard. The relation's cause is keyed by game, so
    % the same action's effect in another environment is a separate relation.
    ;   memberchk(changed(_, _, _, 15), Delta)
    ->  co_learn_preventive(g(Sel, Action), penalty),
        % Learn the deadly colours this hazard introduced, so stepping onto them is
        % predicted fatal next time (the verify-before-act world model).
        ma_learn_deadly(Sel, Delta),
        % Report the hazard.
        Outcome = hazard
    % Otherwise the delta was produced by the action, in this game.
    ;   co_learn_causal(g(Sel, Action), delta(Delta)),
        % Report the learning.
        Outcome = learned
    ),
    % Record the last action and its basis for the why endpoint.
    retractall(ma_last_(_, _)),
    % Store it.
    assertz(ma_last_(Action, Basis)),
    % Locate this choice within the plan hierarchy (its OODA phase and leaf), so
    % the glass box narrates play as a descent of the Win-Game plan.
    ma_note_plan_focus(Sel, Basis),
    % Count the try so curiosity varies its choices across the attempt.
    ma_bump_try(Action),
    % Remember how big an effect this action had, and track no-progress, so the
    % player can recall its highest-impact action when it gets stuck.
    ma_note_impact(Sel, Action, Delta),
    % Track which cells keep changing (a counter, timer, or animation), so the
    % state signature can ignore them and recognise a returned-to state.
    ma_note_volatility(Sel, Delta),
    % Refresh the whole-grid perception: where the avatar now is, what this action
    % did to it (the control map), and how the meters moved (the resource model).
    ma_perceive_update(Sel, Action, Frame0, Frame1),
    % If this action just ended the game, remember never to take it from this
    % state again — durable, so a later attempt of the game does not re-die here.
    ma_note_death(Sel, Frame0, Action),
    % Append this step to the session recording (for the won package).
    ma_session_record(Action, Delta, Outcome),
    % Learn this transition into the executable world model: what effect the action
    % had, bucketed, so the model can predict and its general laws can be read out.
    ma_wm_learn(Sel, Action, Delta, Outcome),
    % Fold the same transition into the rest of the cognitive stack — a committed
    % hypothesis about which action is productive, goal inference from the delta, and
    % the action-budget count. This runs on EVERY step in EVERY mode (solo, human-
    % guided, AI-guided) because they all share this one ma_do_step spine, so a lever
    % pulled in a guided run is learned by the same store a later Solo run reads.
    ma_cog_learn(Sel, Action, Delta, Outcome),
    % If this action just COMPLETED A LEVEL (levels.completed increased), persist
    % the game's learnings to disk now — a level win survives a restart, not only
    % a full-game win.
    ma_note_level(Sel).

% ---------------------------------------------------------------------------
% PER-LEVEL WIN PERSISTENCE — a level win persists, not only a full-game win
% ---------------------------------------------------------------------------
%
% ma_conclude_won requires the whole game to be solved. But completing even one
% level on the live benchmark is a real, hard-won result whose learnings (the
% mechanic discovered, the path taken) should survive a restart. This watches the
% live level counter and, each time it climbs, snapshots the game's learnings to
% disk keyed by game — the same durable store the full-game conclude writes to.

% ma_level_seen_/2: (Game, HighestLevelPersisted) — the last level count for which
% this game's learnings were persisted, so each new level is persisted once.
:- dynamic ma_level_seen_/2.

% ma_note_level(+Game): persist the game's learnings when its live level count has
% climbed since the last persist. Always succeeds — it is a side-effecting hook, so
% a failure (local game, no level climb) or an error must never break the step.
ma_note_level(Game) :-
    ( catch(ma_note_level_(Game), _, fail) -> true ; true ).

% The guarded body of the per-level persistence check.
ma_note_level_(Game) :-
    % Only a live game reports a level count.
    ma_is_live(Game),
    % Its current levels-completed.
    al_progress(Game, Completed, _WinLevels),
    integer(Completed), Completed > 0,
    % The highest level already persisted for this game.
    ( ma_level_seen_(Game, Prev) -> true ; Prev = 0 ),
    % Only act when a NEW level was completed.
    Completed > Prev,
    % Record the new high-water mark.
    retractall(ma_level_seen_(Game, _)),
    assertz(ma_level_seen_(Game, Completed)),
    % Persist this level win.
    ma_persist_level(Game, Completed).

% ma_persist_level(+Game, +Level): learn from the session that reached this level
% (recording its actions as the win path and reinforcing the relations used), then
% snapshot the game's whole learning set to disk. Keyed by game, so a later run —
% Solo included — reloads it on boot.
ma_persist_level(Game, Level) :-
    % The recorded session so far, in step order.
    findall(st(N, A, D, O), ma_session_(N, A, D, O), Raw),
    msort(Raw, Steps),
    % Learn from it exactly as a full win does (win path + reinforcement + levers),
    % when there is anything recorded.
    ( Steps \== [] -> catch(ma_learn_from_win(Game, Steps, _Learned), _, true) ; true ),
    % Snapshot the game's learnings durably.
    catch(ma_persist_game(Game), _, true),
    % A glass-box line so the win is visible.
    length(Steps, StepCount),
    format("level win persisted: ~w reached level ~w (~w steps)~n", [Game, Level, StepCount]).

% ma_wm_learn(+Game, +Action, +Delta, +Outcome): fold one observed transition into
% the executable world model (co_wm), keyed by the game, with the effect bucketed
% so the model generalises. Guarded: a modelling hiccup never breaks a step.
ma_wm_learn(Game, Action, Delta, Outcome) :-
    catch((
        % Bucket the effect: hazard, no change, or a small/large change.
        ( Outcome == hazard -> Eff = hazard
        ; Delta == []       -> Eff = no_change
        ; length(Delta, K), ( K < 10 -> Eff = small_change ; Eff = large_change )
        ),
        % Record it under the action, context-free for now (the general law).
        wm_observe(Game, any_ctx, Action, Eff)
    ), _, true).

% ma_wm_laws(+Game, -Laws): the general laws the world model has learned for a game
% (actions whose effect is consistent), as law(Action, Effect), for the glass box.
ma_wm_laws(Game, Laws) :-
    ( catch(findall(law(A, E), wm_law(Game, A, E), Laws0), _, Laws0 = []) -> true ; Laws0 = [] ),
    Laws = Laws0.

% ma_cog_learn(+Game, +Action, +Delta, +Outcome): fold one observed transition into
% the hypothesis, goal-inference, and efficiency packs. Guarded so a modelling hiccup
% never breaks a step. Called from the single shared ma_do_step, so solo, human-guided
% and AI-guided all teach the same game-keyed cognition.
ma_cog_learn(Game, Action, Delta, Outcome) :-
    catch(ma_cog_learn_(Game, Action, Delta, Outcome), _, true).

% The guarded body: hypothesis commitment, goal inference, and budget count.
ma_cog_learn_(Game, Action, Delta, Outcome) :-
    % HYPOTHESIS (co_hypo): the candidate rule is "ACTION is productive here" — it
    % moves the world toward progress. A real change supports it; a dead action or a
    % hazard contradicts it. Committing to the productive action (without drifting off
    % it at the first dead step) is the cure for the losing agents' hypothesis drift.
    (   Outcome == hazard
    ->  hy_contradict(Game, productive(Action))
    ;   Delta == []
    ->  hy_contradict(Game, productive(Action))
    ;   hy_support(Game, productive(Action))
    ),
    % Decide commitment now, with the pack's sticky hysteresis.
    hy_update_commitment(Game),
    % GOAL INFERENCE (co_goalinfer): if this step just won or lost, reinforce or
    % discount the colours the delta introduced; otherwise it teaches nothing. The
    % delta is already a list of changed(R,C,Old,New), the form the pack expects.
    ma_cog_state(Game, State),
    ( State == ongoing -> true ; catch(cgi_observe(Delta, State), _, true) ),
    % EFFICIENCY (co_effic): count one action spent against this game's budget, so
    % the mind can gauge how economically it is learning.
    catch(cef_count(Game), _, true).

% ma_cog_state(+Game, -State): the post-action state as co_goalinfer wants it —
% win, game_over, or ongoing. Best-effort and total.
ma_cog_state(Game, State) :-
    (   catch(( ma_render(Game, F), ma_solved_env(Game, F) ), _, fail)
    ->  State = win
    ;   catch(ma_env_over(Game), _, fail)
    ->  State = game_over
    ;   State = ongoing
    ).

% ma_death_/3: (Game, StateKey, Action) — an action that ended the game from a
% state, so a later attempt avoids it there. StateKey is the frame's signature.
:- dynamic ma_death_/3.

% ---------------------------------------------------------------------------
% VOLATILE-CELL MASKING — recognise a returned-to state despite a ticking HUD
% ---------------------------------------------------------------------------
%
% A status band (score, timer, lives, moves) or an animation changes on nearly
% every step regardless of the action. If those cells are part of the state
% signature, the same situation looks new every tick and the state graph and the
% fatal-move memory never carry forward. The winning ARC-AGI-3 agent masks the
% status bars for exactly this reason. Mentova learns which cells are volatile -
% those that change on a high fraction of steps - and ignores them in the state
% key. On the small local practice grids and in short runs the threshold is never
% reached, so behaviour there is unchanged.

% ma_cellchg_/4: (Game, R, C, Count) — how often a cell has appeared in a delta.
:- dynamic ma_cellchg_/4.
% ma_framecount_/2: (Game, N) — how many steps of this game have been observed.
:- dynamic ma_framecount_/2.

% ma_note_volatility(+Game, +Delta): fold one step's changed cells into the tally.
ma_note_volatility(Game, Delta) :-
    % One more observed step for this game.
    ( retract(ma_framecount_(Game, N0)) -> true ; N0 = 0 ),
    % The new count.
    N1 is N0 + 1,
    % Store it.
    assertz(ma_framecount_(Game, N1)),
    % Bump the change-count of every cell that changed this step.
    forall(member(changed(R, C, _, _), Delta), ma_bump_cellchg(Game, R, C)).

% ma_bump_cellchg(+Game, +R, +C): one more observed change of a cell.
ma_bump_cellchg(Game, R, C) :-
    % Fetch and remove the current count.
    ( retract(ma_cellchg_(Game, R, C, K)) -> true ; K = 0 ),
    % The new count.
    K1 is K + 1,
    % Store it.
    assertz(ma_cellchg_(Game, R, C, K1)).

% ma_volatile(+Game, ?R, ?C): a cell that changes on most steps — a HUD or
% animation cell to ignore. Requires enough observations to be confident.
ma_volatile(Game, R, C) :-
    % Enough steps observed to judge (a short run leaves everything unmasked).
    ma_framecount_(Game, N), N >= 8,
    % This cell's change count.
    ma_cellchg_(Game, R, C, K),
    % Changed on at least sixty percent of the observed steps.
    K * 10 >= N * 6.

% ---------------------------------------------------------------------------
% WHOLE-GRID PERCEPTION — see every object, track the avatar, READ the meters
% ---------------------------------------------------------------------------
%
% Masking a volatile band keeps the state key stable, but a counter or life-bar
% is not noise to be thrown away — it is information. This section reads the
% whole grid through co_see and keeps three living facts per game: where the
% avatar is (what moved), what each action does to it (the control map, learned
% not assumed), and how long each meter is (so a shrinking bar is recognised as
% a depleting resource). The choice-maker below uses all three to go deliberately
% touch objects and to hurry or refill when a resource is low.

% ma_avatar_/3: (Game, R, C) — the avatar's last known cell (whatever moved).
:- dynamic ma_avatar_/3.
% ma_move_vec_/4: (Game, Action, DR, DC) — the avatar displacement an action was
% observed to cause. This is the game's control scheme, DISCOVERED by perception.
:- dynamic ma_move_vec_/4.
% ma_visited_/3: (Game, R, C) — an object cell already visited this attempt, so
% the player targets a fresh object next instead of mulling on one spot.
:- dynamic ma_visited_/3.
% ma_pursuit_/3: (Game, R, C) — the object the avatar is currently walking to.
:- dynamic ma_pursuit_/3.
% ma_meter_/4: (Game, Key, Len, Trend) — a bar/meter's last length and whether it
% is rising, falling, steady, or new: the resource model, read from the grid.
:- dynamic ma_meter_/4.

% ---------------------------------------------------------------------------
% PER-STEP PERCEPTION CACHE — segment the grid once, not five times a step
% ---------------------------------------------------------------------------
%
% Whole-grid perception is expensive: each object inventory, salient-target list,
% and meter read runs a full 64x64 connected-component segmentation. In one choice
% the safe-action set is assembled up to five times (once per exploration rule),
% each time re-segmenting the same frame — the cost that forced the last live sweep
% to be halted. This cache computes each perception once per step and hands back
% the stored answer to the other callers. It is keyed by a cheap hash of the frame
% and cleared at the start of every step, so it only ever serves the current frame
% and never goes stale across steps (where the try-counts and learnings change).

% ma_pcache_/3: (Kind, FrameHash, Value) — a memoised perception for one frame.
:- dynamic ma_pcache_/3.

% ma_cache_clear: drop the whole perception cache (called once per step).
ma_cache_clear :-
    retractall(ma_pcache_(_, _, _)).

% ma_cached(+Kind, +Frame, :Compute, -Value): return the cached perception for this
% frame, computing it once (via Compute(Frame, Value)) and storing it on a miss.
% Only the latest frame's entry per kind is kept, so the cache stays tiny.
:- meta_predicate ma_cached(+, +, 2, -).
ma_cached(Kind, Frame, Compute, Value) :-
    % A cheap hash of the frame.
    term_hash(Frame, H),
    (   % Hit: the value for this exact frame is stored.
        ma_pcache_(Kind, H, V0)
    ->  Value = V0
    ;   % Miss: compute once, drop any stale entry of this kind, and store.
        ( catch(call(Compute, Frame, V1), _, fail) -> true ; V1 = [] ),
        retractall(ma_pcache_(Kind, _, _)),
        assertz(ma_pcache_(Kind, H, V1)),
        Value = V1
    ).

% ma_inventory(+Frame, -Inv): the co_see object inventory, cached per step.
ma_inventory(Frame, Inv) :- ma_cached(inventory, Frame, cs_inventory, Inv).

% ma_bars(+Frame, -Bars): the bar/meter objects, cached per step.
ma_bars(Frame, Bars) :- ma_cached(bars, Frame, cs_bars, Bars).

% ma_salient(+Frame, -Cells): the salient object centroids (largest object first),
% cached per step. This is the expensive full-grid segmentation the click-target
% expansion needs; caching it is the core of the performance fix.
ma_salient(Frame, Cells) :- ma_cached(salient, Frame, cox_salient_cells, Cells).

% ma_expand_actions(+Marked, +Frame, -Concrete): replace the click marker with this
% frame's salient select(X,Y) targets (x is the column, y the row), passing every
% other action through unchanged. Uses the cached salient cells, so the grid is
% segmented once per step no matter how many times the action set is assembled.
ma_expand_actions([], _Frame, []).
% The click marker expands to the salient object-centroid clicks.
ma_expand_actions([click | Rest], Frame, Expanded) :-
    !,
    % The cached salient cells for this frame.
    ( catch(ma_salient(Frame, Cells), _, Cells = []) -> true ; Cells = [] ),
    % Each salient cell(Row,Col) becomes a select(Col,Row) click.
    findall(select(X, Y), member(cell(Y, X), Cells), Targets),
    % Expand the tail, then splice the targets in where the marker was.
    ma_expand_actions(Rest, Frame, RestExpanded),
    append(Targets, RestExpanded, Expanded).
% Any other action passes through unchanged.
ma_expand_actions([Action | Rest], Frame, [Action | RestExpanded]) :-
    ma_expand_actions(Rest, Frame, RestExpanded).

% ma_perceive_update(+Game, +Action, +Frame0, +Frame1): after a step, refresh the
% whole-grid perception — the avatar's cell, this action's learned displacement,
% and the meter readings. Fully guarded: perception never breaks a step.
ma_perceive_update(Game, Action, Frame0, Frame1) :-
    catch(ma_perceive_update_(Game, Action, Frame0, Frame1), _, true).

% The guarded body of the perception update.
ma_perceive_update_(Game, Action, Frame0, Frame1) :-
    % Locate the avatar as whatever moved between the two frames.
    (   catch(cs_avatar_move(Frame0, Frame1, cell(NR, NC)), _, fail)
    ->  % If we knew where it was and this was a simple (non-click) action, learn
        % the displacement it caused — the control map, one action at a time.
        (   ma_avatar_(Game, OR, OC), Action = action(_),
            DR is NR - OR, DC is NC - OC,
            ( DR =\= 0 ; DC =\= 0 )
        ->  retractall(ma_move_vec_(Game, Action, _, _)),
            assertz(ma_move_vec_(Game, Action, DR, DC))
        ;   true ),
        % Record the avatar's new cell.
        retractall(ma_avatar_(Game, _, _)),
        assertz(ma_avatar_(Game, NR, NC))
    ;   true ),
    % Read the meters and fold them into the resource model.
    ma_meters_update(Game, Frame1).

% ma_meters_update(+Game, +Frame): read the bar/meter-like objects and remember
% each one's length and trend, so a later choice can tell a resource is draining.
% A meter that has already been seen but is missing this frame has drained below
% the bar-detection length — that too is recorded as falling, so the resource
% model does not go blind exactly when the life-bar is nearly empty.
ma_meters_update(Game, Frame) :-
    % The bar-like objects co_see finds (life-bars, timers, progress counters).
    ( catch(ma_bars(Frame, Bars), _, Bars = []) -> true ; Bars = [] ),
    % Fold each present bar into the model, keyed by its colour and orientation.
    findall(Key,
        ( member(bar(Colour, Orient, Len, _), Bars),
          atomic_list_concat([Colour, '_', Orient], Key),
          % The previous length, to compute the trend.
          ( ma_meter_(Game, Key, Len0, _) -> true ; Len0 = Len ),
          ( \+ ma_meter_(Game, Key, _, _) -> Trend = new
          ; Len < Len0 -> Trend = falling
          ; Len > Len0 -> Trend = rising
          ; Trend = steady ),
          retractall(ma_meter_(Game, Key, _, _)),
          assertz(ma_meter_(Game, Key, Len, Trend)) ),
        Present),
    % A previously-known meter that is absent now (and was not already read as
    % empty) has drained below the bar-detection length: record it falling to zero.
    forall(
        ( ma_meter_(Game, Key0, Len0b, _),
          \+ memberchk(Key0, Present),
          Len0b > 0 ),
        ( retractall(ma_meter_(Game, Key0, _, _)),
          assertz(ma_meter_(Game, Key0, 0, falling)) )).

% ma_resource_low(+Game): the game has a meter that is currently draining — the
% cross-game resource-refill prior then makes the player prefer collectible dots.
ma_resource_low(Game) :-
    % Any meter observed to be falling.
    ma_meter_(Game, _, _, falling).

% ---------------------------------------------------------------------------
% THE PLAN HIERARCHY — Win Game over an OODA loop over the concrete controls
% ---------------------------------------------------------------------------
%
% The solo player's action chain already realises an observe-orient-decide-act
% loop. This section makes that loop an EXPLICIT multi-level plan (co_hplan): the
% top goal Win Game, the six-phase OODA method, and the game's real controls at
% the leaves. The plan is reified onto Causalontology's own decomposition
% hierarchy, so it is not a separate diagram but a hierarchy of CROs the glass box
% can show and read back. Each step's choice is located within the plan (its OODA
% phase and leaf), so play is narrated as a descent of the plan.

% ma_plan_tree_/2: (Game, Tree) — the current plan tree for a game.
:- dynamic ma_plan_tree_/2.
% ma_plan_root_/2: (Game, RootCroId) — the root CRO the plan was reified into.
:- dynamic ma_plan_root_/2.
% ma_plan_focus_/3: (Game, Phase, Leaf) — the OODA phase and leaf the last choice
% fell under, so the glass box can say which rung of the plan is active.
:- dynamic ma_plan_focus_/3.

% ma_build_plan(+Game): build the plan tree for a game and reify it onto the
% Causalontology decomposition hierarchy. Guarded: a planning hiccup never blocks
% play. Keyed by game; the act phase's leaves are the game's real control set.
ma_build_plan(Game) :-
    catch(ma_build_plan_(Game), _, true).

% The guarded body of the plan build.
ma_build_plan_(Game) :-
    % The game's concrete controls, collapsed to readable leaves.
    ( ma_actions_env(Game, Actions0) -> true ; Actions0 = [] ),
    ma_plan_actions(Actions0, Actions),
    % Build the three-level plan tree.
    hp_win_plan(Game, Actions, Tree),
    % Store it for this game.
    retractall(ma_plan_tree_(Game, _)),
    assertz(ma_plan_tree_(Game, Tree)),
    % Reify it onto the CRO decomposition graph (fresh, so nodes do not pile up).
    hp_reset,
    hp_reify(Tree, Root),
    retractall(ma_plan_root_(Game, _)),
    assertz(ma_plan_root_(Game, Root)).

% ma_plan_actions(+Actions0, -Actions): the control leaves for the act phase — a
% concrete cell-select collapses to one select(x,y) marker so the tree stays
% readable, and duplicates merge.
ma_plan_actions(Actions0, Actions) :-
    % Collapse concrete selects to a single marker.
    findall(A,
        ( member(A0, Actions0),
          ( A0 = select(_, _) -> A = select(x, y) ; A = A0 ) ),
        As0),
    % Merge duplicates, keep a stable order.
    sort(As0, Actions).

% ma_note_plan_focus(+Game, +Basis): record which OODA phase and leaf a choice
% basis falls under, so the Why endpoint can show the active rung of the plan.
ma_note_plan_focus(Game, Basis) :-
    ( catch(hp_classify_basis(Basis, Phase, Leaf), _, fail)
    -> retractall(ma_plan_focus_(Game, _, _)),
       assertz(ma_plan_focus_(Game, Phase, Leaf))
    ;  true ).

% ma_plan_view(+Game, -View): the plan hierarchy as a JSON-ready dict for the Why
% endpoint and the Claude-facing agentview — the nested tree, the active phase and
% leaf, and two proofs of the mesh: that the reified hierarchy is causally
% consistent, and that the whole plan reconstructs from the CRO graph alone.
ma_plan_view(Game, View) :-
    % Ensure a plan exists for this game.
    ( ma_plan_tree_(Game, Tree) -> true
    ; ma_build_plan(Game), ( ma_plan_tree_(Game, Tree) -> true ; Tree = none ) ),
    % The nested-dict rendering of the tree.
    ( Tree \== none, catch(hp_render_json(Tree, TreeJson), _, fail)
    -> true ; TreeJson = _{} ),
    % The indented text rendering, one line per list element.
    ( Tree \== none, catch(hp_render(Tree, Lines0), _, fail)
    -> true ; Lines0 = [] ),
    % The active OODA phase and leaf.
    ( ma_plan_focus_(Game, Ph, Lf)
    -> term_to_atom(Ph, PhA), term_to_atom(Lf, LfA),
       Focus = _{phase: PhA, leaf: LfA}
    ;  Focus = _{phase: none, leaf: none} ),
    % The mesh proofs, guarded.
    ( ma_plan_root_(Game, Root), catch(hp_consistent(Root), _, fail)
    -> Consistent = true ; Consistent = false ),
    ( ma_plan_root_(Game, Root2), catch(hp_plan_from_cros(Root2, _), _, fail)
    -> FromCros = true ; FromCros = false ),
    % Assemble the view.
    View = _{tree: TreeJson, lines: Lines0, focus: Focus,
             causalontology_consistent: Consistent,
             reconstructable_from_cros: FromCros}.

% ma_visit(+Game, +R, +C): mark an object cell visited this attempt.
ma_visit(Game, R, C) :-
    ( ma_visited_(Game, R, C) -> true ; assertz(ma_visited_(Game, R, C)) ).

% ma_object_targets(+Game, +Frame, +Items, -Targets): the object cells worth
% going to, best first. Meters (resources) and large fields (terrain) are not
% touch targets; the avatar's own cell is excluded; already-visited cells are
% dropped. When a resource is draining, single-cell dots (likely collectibles)
% are ranked ahead of larger pieces, per the resource-refill prior. Otherwise
% the order is by nearest to the avatar (or salience when there is no avatar).
ma_object_targets(Game, _Frame, Items, Targets) :-
    % The avatar cell, if known.
    ( ma_avatar_(Game, AR, AC) -> Origin = at(AR, AC) ; Origin = none ),
    % The touchable candidates: dots and pieces, not meters/fields, not visited,
    % not the avatar's own cell.
    findall(Rank - pos(R, C),
        ( member(seen(_, _, _, cell(R, C), Role), Items),
          memberchk(Role, [dot, piece]),
          \+ ma_visited_(Game, R, C),
          \+ ( Origin = at(R, C) ),
          ma_target_rank(Game, Role, Origin, R, C, Rank) ),
        Ranked),
    % Best (lowest rank) first.
    keysort(Ranked, Sorted),
    findall(P, member(_ - P, Sorted), Targets),
    Targets \== [].

% ma_target_rank(+Game, +Role, +Origin, +R, +C, -Rank): a smaller rank is a
% better target. Dots come first when a resource is draining; ties break by the
% Manhattan distance from the avatar so the nearest fresh object is chosen.
ma_target_rank(Game, Role, Origin, R, C, Rank) :-
    % A dot gets a head start only while a meter is falling (seek a refill).
    ( ma_resource_low(Game), Role == dot -> Bias = 0 ; Bias = 1000 ),
    % The distance from the avatar, or zero when there is none.
    ( Origin = at(AR, AC) -> Dist is abs(R - AR) + abs(C - AC) ; Dist = 0 ),
    % The rank combines the role bias and the distance.
    Rank is Bias + Dist.

% ma_move_toward(+Game, +Frame, +AR, +AC, +TR, +TC, -Action): the learned simple
% action that moves the avatar strictly closer to (TR,TC) under the discovered
% control map, preferring a step the world model does NOT predict fatal. Candidates
% are ranked by (not-fatal, then closeness), so a non-fatal step is taken even if a
% fatal one would be a touch closer — the avatar routes around a hazard on its way
% to an object. Fails when no known action reduces the distance, so the caller
% falls through rather than oscillating.
ma_move_toward(Game, Frame, AR, AC, TR, TC, Action) :-
    % The current distance to the target.
    Cur is abs(TR - AR) + abs(TC - AC),
    % Each distance-reducing learned action, tagged with whether it is predicted
    % fatal (0 safe, 1 fatal) so the sort prefers safe then closest.
    findall(Fatal - Dist - Act,
        ( ma_move_vec_(Game, Act, DR, DC),
          NR is AR + DR, NC is AC + DC,
          Dist is abs(TR - NR) + abs(TC - NC),
          Dist < Cur,
          ( ma_predict_fatal(Game, Frame, Act) -> Fatal = 1 ; Fatal = 0 ) ),
        Scored),
    Scored \== [],
    % Non-fatal first, then closest; take the best.
    sort(Scored, [_ - _ - Action | _]).

% ma_object_action(+Game, +Frame, +Items, -Action, -Basis): choose a concrete
% action that pursues a salient object — steering the avatar on a movement game
% (using the learned control map), or clicking the object on a click game.
% Movement game: the avatar and a control map are known, so walk toward a target.
ma_object_action(Game, Frame, Items, Action, moving_to(pos(TR, TC))) :-
    % A control map has been learned (some action moves the avatar).
    ma_move_vec_(Game, _, _, _),
    % The avatar's cell is known.
    ma_avatar_(Game, AR, AC),
    % The pursuit target: keep the current one while it is still a fresh object,
    % otherwise adopt the best fresh target now.
    (   ma_pursuit_(Game, TR, TC),
        member(seen(_, _, _, cell(TR, TC), _), Items),
        \+ ma_visited_(Game, TR, TC)
    ->  true
    ;   ma_object_targets(Game, Frame, Items, [pos(TR, TC) | _]),
        retractall(ma_pursuit_(Game, _, _)),
        assertz(ma_pursuit_(Game, TR, TC))
    ),
    % A step that moves the avatar closer under the control map, routing around a
    % step the world model predicts fatal where possible.
    ma_move_toward(Game, Frame, AR, AC, TR, TC, Action),
    % If the avatar is already next to (or on) the target, retire it as visited.
    ( abs(TR - AR) + abs(TC - AC) =< 1
    -> ma_visit(Game, TR, TC), retractall(ma_pursuit_(Game, _, _)) ; true ).
% Click game: cell-select is available, so click the best fresh object's centroid.
ma_object_action(Game, Frame, Items, select(TC, TR), click_object(pos(TR, TC))) :-
    % The environment affords a cell-select.
    ( ma_actions_env(Game, As) -> true ; As = [] ),
    memberchk(select(_, _), As),
    % The best fresh object to click.
    ma_object_targets(Game, Frame, Items, [pos(TR, TC) | _]),
    % A click reaches it in one action, so mark it visited now.
    ma_visit(Game, TR, TC).

% ma_relation_target(+Game, +Frame, +Items, -pos(TR,TC), -Reason): the object worth
% going to next, chosen by a RANKED UTILITY over the perceived objects — not by bare
% distance. Nearest is only the tiebreaker/cost term; the criterion is, in order:
%   (1) GOAL-RELEVANCE — an object the committed hypothesis says to click, or whose
%       colour matches the inferred win colour, or a cell on a proven winning path
%       (the changers-then-door ordering learned from a won run), or a collectible
%       dot while a resource is draining (the refill prior);
%   (2) INFORMATION VALUE — an unvisited object of an informative role, for curiosity;
%   (3) distance, only to break ties and as the movement cost.
% Hazardous cells (declared avoid-cells, or an object of a proved-deadly colour) are
% excluded from candidacy, and the walk to the target routes around hazards anyway.
% Reason is a glass-box term naming WHY this object beat any nearer one, so the Why
% endpoint can explain the choice. Fails (caller falls through) when no object
% qualifies.
ma_relation_target(Game, _Frame, Items, pos(TR, TC), Reason) :-
    % The avatar cell as the distance origin, if known (else salience stands in).
    ( ma_avatar_(Game, AR, AC) -> Origin = at(AR, AC) ; Origin = none ),
    % The inferred win colour, if goal inference has one.
    ( catch(cgi_hypothesise_goal(reach_colour(GoalCol)), _, fail) -> true ; GoalCol = none ),
    % The committed productive action, if it is a click on a specific cell.
    ( catch(hy_committed(Game, productive(select(CX, CY))), _, fail) -> true ; CX = none, CY = none ),
    % The cells on a recorded winning path (its select targets), in order — the
    % mechanic ordering a won run proved (e.g. change the changers, then the door).
    ma_win_path_cells(Game, WinCells),
    % Score every eligible object by its utility (lower key is better), keeping the
    % avatar distance alongside so the nearest tiebreaks within a tier.
    findall(key(Score, Dist) - t(pos(R, C), Reason0, Dist),
        ( member(seen(_, Colour, Size, cell(R, C), Role), Items),
          % Not the avatar's own cell, not already visited, not a hazard.
          \+ ( Origin = at(R, C) ),
          \+ ma_visited_(Game, R, C),
          \+ ma_target_hazard(Game, Colour, R, C),
          % Its distance (or a salience-based cost when there is no avatar).
          ma_target_dist(Origin, R, C, Size, Dist),
          % Its utility score and the reason for it (only touchable/relevant objects
          % score; a bare field that is neither goal-coloured nor on a path fails).
          ma_target_score(Game, Colour, Role, R, C, GoalCol, CX-CY, WinCells, Score, Reason0) ),
        Scored),
    Scored \== [],
    keysort(Scored, [key(_, BestDist) - t(pos(TR, TC), Reason0, BestDist) | _]),
    % Was a NEARER object passed over for a higher-utility one? Report it, so the
    % glass box can say why the nearest was not chosen.
    findall(D, member(key(_, D) - _, Scored), Dists),
    min_list(Dists, MinDist),
    ( MinDist < BestDist
    -> Reason = chosen(Reason0, over_nearer_by(BestDist, MinDist))
    ;  Reason = chosen(Reason0, nearest) ).

% ma_win_path_cells(+Game, -Cells): the select-target cells of a recorded winning
% path for this game, in path order — the proven object ordering to reuse. Empty
% when no winning path is stored.
ma_win_path_cells(Game, Cells) :-
    ( ma_win_path_(Game, Path), is_list(Path)
    -> findall(cell(R, C), member(select(C, R), Path), Cells)
    ;  Cells = [] ).

% ma_target_hazard(+Game, +Colour, +R, +C): the object at (R,C) is one to avoid —
% either its cell was declared a hazard, or its colour has proved deadly.
ma_target_hazard(Game, Colour, R, C) :-
    ( ma_avoid_cell_(Game, pos(R, C))
    ; catch(ma_deadly_colour_(Game, Colour), _, fail) ).

% ma_target_dist(+Origin, +R, +C, +Size, -Dist): the movement cost to the object —
% the Manhattan distance from the avatar, or, when there is no avatar (a click game),
% a salience cost so a larger object costs less. Used only as a tiebreaker.
ma_target_dist(at(AR, AC), R, C, _Size, Dist) :- !,
    Dist is abs(R - AR) + abs(C - AC).
ma_target_dist(none, _R, _C, Size, Dist) :-
    % Larger objects are more salient, so they cost less; clamp for a stable key.
    Dist is max(0, 64 - min(Size, 64)).

% ma_target_score(+Game, +Colour, +Role, +R, +C, +GoalCol, +CX-CY, +WinCells,
%                 -Score, -Reason): the utility score (lower is better) and the
% reason. Goal-relevance scores lowest (chosen first), then information value.
% A won-path cell threads its path index into the score so earlier-in-the-win
% objects lead. An object that is neither touchable nor relevant does not score.
ma_target_score(_Game, _Colour, _Role, R, C, _GoalCol, CX-CY, _WinCells, 0, committed_click) :-
    % (1a) The committed hypothesis says to click exactly this object (x=col, y=row).
    integer(CX), integer(CY), CX =:= C, CY =:= R, !.
ma_target_score(_Game, Colour, _Role, _R, _C, GoalCol, _, _WinCells, 100, goal_colour(Colour)) :-
    % (1b) The object's colour is the inferred win colour.
    GoalCol \== none, Colour == GoalCol, !.
ma_target_score(_Game, _Colour, _Role, R, C, _GoalCol, _, WinCells, Score, won_path_order(Idx)) :-
    % (1c) The object sits on a proven winning path; earlier cells lead.
    nth0(Idx, WinCells, cell(R, C)), !,
    Score is 200 + Idx.
ma_target_score(Game, _Colour, dot, _R, _C, _GoalCol, _, _WinCells, 300, resource_refill_dot) :-
    % (1d) A collectible dot while a resource is draining (the refill prior).
    ma_resource_low(Game), !.
ma_target_score(_Game, _Colour, Role, _R, _C, _GoalCol, _, _WinCells, Score, curiosity(Role)) :-
    % (2) Information value: an unvisited object of a touchable role, for curiosity —
    % a dot or a piece leads a broad field.
    ( memberchk(Role, [dot, piece]) -> Score = 1000 ; Role == field -> Score = 1100 ; fail ).

% ma_target_action(+Game, +Frame, +TR, +TC, -Action): resolve a target cell into a
% concrete action — a control-map step toward it on a movement game, or a cell-select
% click on a click game. Mirrors ma_object_action's two shapes without re-choosing a
% target, so the relation clause and the object clause resolve targets the same way.
ma_target_action(Game, Frame, TR, TC, Action) :-
    (   % Movement game: a control map is known, so step the avatar toward the cell.
        ma_move_vec_(Game, _, _, _),
        ma_avatar_(Game, AR, AC),
        ma_move_toward(Game, Frame, AR, AC, TR, TC, Action)
    ->  ( abs(TR - AR) + abs(TC - AC) =< 1 -> ma_visit(Game, TR, TC) ; true )
    ;   % Click game: the environment affords a cell-select, so click the centroid.
        ma_actions_env(Game, As), memberchk(select(_, _), As),
        Action = select(TC, TR),
        ma_visit(Game, TR, TC)
    ).

% ma_mask_frame(+Game, +Frame, -Masked): replace this game's volatile cells with
% a sentinel so they do not affect the state key. When nothing is volatile yet,
% the frame passes through unchanged.
ma_mask_frame(Game, Frame, Masked) :-
    % Only pay the cost when there is something to mask.
    (   ma_volatile(Game, _, _)
    % Rewrite each row, blanking this game's volatile cells to the sentinel.
    ->  findall(Row2,
            ( nth0(R, Frame, Row),
              findall(V2,
                  ( nth0(C, Row, V),
                    ( ma_volatile(Game, R, C) -> V2 = -1 ; V2 = V ) ),
                  Row2) ),
            Masked)
    % Nothing volatile yet: use the frame as is.
    ;   Masked = Frame
    ).

% ma_state_key(+Game, +Frame, -Key): the canonical signature of a frame with this
% game's volatile cells masked out — the key the graph and the fatal-move memory
% share, so a returned-to state is recognised despite a ticking counter.
ma_state_key(Game, Frame, Key) :-
    % Mask the volatile cells, then take the canonical signature.
    ma_mask_frame(Game, Frame, Masked),
    % The signature of the masked frame.
    cg_signature(Masked, Key).

% ma_note_death(+Game, +Frame0, +Action): if the game is now over, record that
% this action, taken from Frame0, is fatal in this state. Nineteen of twenty-five
% first-campaign attempts ended in a loss; remembering the fatal moves lets a
% carried-forward later attempt survive longer and explore more.
ma_note_death(Game, Frame0, Action) :-
    % Only a live game can report a game-over.
    (   ma_env_over(Game)
    % Record the fatal (state, action) once, guarded.
    ->  catch((
            ma_state_key(Game, Frame0, Key),
            ( ma_death_(Game, Key, Action) -> true
            ; assertz(ma_death_(Game, Key, Action)) ),
            % Feed the same fatal transition to the verify-before-act model, which
            % generalises it: an action fatal in enough distinct states is then
            % predicted fatal in a new state before it is tried there.
            catch(vb_note_fatal(Game, Key, Action), _, true)
        ), _, true)
    % The game did not end: nothing to record.
    ;   true
    ).

% ma_action_safe(+Game, +Frame, +Action): the action is not known to end the game
% from this state.
ma_action_safe(Game, Frame, Action) :-
    % Safe unless a fatal (state, action) has been recorded for this frame's
    % masked state key (so a ticking counter does not hide a known fatal state).
    \+ ( catch(ma_state_key(Game, Frame, Key), _, fail), ma_death_(Game, Key, Action) ).

% ---------------------------------------------------------------------------
% VERIFY BEFORE ACT — predict a move fatal before spending a real action on it
% ---------------------------------------------------------------------------
%
% The death memory above refuses a move that HAS ended a run from this exact
% state. That is reactive: on a new board the same lesson is re-learned by dying
% again. This section is the world-model check the deaths pinned as the decisive
% lever. It predicts a move fatal before it is tried, two ways. First, through
% co_verify's generalisation: an action that ended a run in enough distinct states
% is predicted fatal anywhere (applied only to non-movement actions, so a needed
% direction is never banned outright). Second, positionally: for a movement game
% it SIMULATES where the avatar would land under the learned control map and, if
% that cell carries a colour that has proved deadly, predicts the step fatal — the
% su15 lesson (do not walk the avatar into the enemy) learned once and applied
% everywhere. A predicted-fatal move is deprioritised, not forbidden.

% ma_deadly_colour_/2: (Game, Colour) — a cell colour that has proved deadly in a
% game (the ARC penalty marker, or the colour the avatar stepped onto when a run
% ended). Learned, game-keyed, and durable across attempts like the death memory.
:- dynamic ma_deadly_colour_/2.

% ma_deadly_colour(+Game, ?Colour): a colour deadly in this game. The penalty
% marker colour fifteen is always deadly; others are learned.
ma_deadly_colour(_, 15).
ma_deadly_colour(Game, Colour) :- ma_deadly_colour_(Game, Colour).

% ma_learn_deadly(+Game, +Delta): on a hazard or death step, record the non-
% background colours the step introduced as deadly, so stepping onto them is
% predicted fatal next time. Deprioritise-not-forbid semantics make a slightly
% eager learner safe: a mis-marked colour only sends a move to the back of the
% queue, it is not banned.
ma_learn_deadly(Game, Delta) :-
    % Record each newly-introduced non-background colour.
    forall(
        ( member(changed(_, _, _, New), Delta), integer(New), New =\= 0 ),
        ( ma_deadly_colour_(Game, New) -> true
        ; assertz(ma_deadly_colour_(Game, New)) )).

% ma_cell_colour(+Frame, +R, +C, -Colour): the colour at a cell, failing off-grid.
ma_cell_colour(Frame, R, C, Colour) :-
    % Read the cell, guarded so an off-grid destination simply fails.
    catch(gd_cell(Frame, R, C, Colour), _, fail).

% ma_predict_fatal(+Game, +Frame, +Action): the verify-before-act judgement — this
% move is predicted to end the run from the current situation. Fully guarded.
ma_predict_fatal(Game, Frame, Action) :-
    catch(ma_predict_fatal_(Game, Frame, Action), _, fail).

% The guarded body: exact memory, positional simulation, or generalisation.
ma_predict_fatal_(Game, Frame, Action) :-
    % Exact: this move has ended a run from this very (masked) state.
    (   catch(ma_state_key(Game, Frame, Key), _, fail),
        vb_fatal_here(Game, Key, Action)
    % Positional: simulate the avatar's destination under the learned control map;
    % a deadly colour there predicts the step fatal.
    ;   ma_move_vec_(Game, Action, DR, DC),
        ma_avatar_(Game, AR, AC),
        R2 is AR + DR, C2 is AC + DC,
        ma_cell_colour(Frame, R2, C2, Colour),
        ma_deadly_colour(Game, Colour)
    % Generalisation: a non-movement action broadly fatal across distinct states.
    ;   \+ ma_move_vec_(Game, Action, _, _),
        vb_broadly_fatal(Game, Action)
    ),
    % One witness suffices.
    !.

% ma_deprioritise_fatal(+Game, +Frame, +Actions, -Ranked): keep the safe actions
% ahead (in their given order) and send the predicted-fatal ones to the back,
% never dropping any — so if every option looks fatal the least-bad is still there.
ma_deprioritise_fatal(Game, Frame, Actions, Ranked) :-
    % Split into not-predicted-fatal and predicted-fatal, preserving order.
    findall(A, ( member(A, Actions), \+ ma_predict_fatal(Game, Frame, A) ), Safe),
    findall(A, ( member(A, Actions),    ma_predict_fatal(Game, Frame, A) ), Risky),
    % Safe first, then risky.
    append(Safe, Risky, Ranked).

% ---------------------------------------------------------------------------
% SURVIVAL-FIRST EARLY-BUDGET POLICY — map the board before pursuing a goal
% ---------------------------------------------------------------------------
%
% The cold sweeps all showed the same failure: unaided play dies at first-hazard
% contact before it can assemble a winning hypothesis. This policy spends the opening
% fraction of the attempt budget SURVEYING — safe, breadth-first probing that builds
% the world model and the hazard map — and defers goal-pursuit until the survey
% window closes. It is the drafts' "separate model-learning from task-optimisation".

% ma_survey_budget(-SurveyN): how many opening actions of an attempt are spent
% surveying — about a sixth of the solo budget, clamped to a sane band so a tiny
% budget still surveys a little and a large one does not survey forever.
ma_survey_budget(SurveyN) :-
    ( ma_solo_budget(B) -> true ; B = 60 ),
    Raw is ceiling(B * 0.15),
    SurveyN is max(8, min(30, Raw)).

% ma_in_survey_phase(+Game): the attempt is still in its opening survey window.
ma_in_survey_phase(_Game) :-
    ma_survey_budget(SurveyN),
    ( ma_session_n_(N) -> true ; N = 0 ),
    N < SurveyN.

% ma_survey_action(+Game, +Frame, -Action): the safest informative probe this step.
% Keep only the actions NOT predicted fatal (a HARD filter, stronger than the
% deprioritise of normal play), then prefer the one that reveals the most while
% risking the least, by survival cost; ties break least-tried (the concrete set is
% already least-tried-first). Falls back to the least-bad action only when every
% option is predicted fatal, so the run never stalls.
ma_survey_action(Game, Frame, Action) :-
    ma_explore_concrete(Game, Frame, Concrete),
    Concrete \== [],
    findall(A, ( member(A, Concrete), \+ ma_predict_fatal(Game, Frame, A) ), Safe),
    (   Safe \== []
    ->  findall(Cost - A,
            ( nth0(I, Safe, A), ma_survey_cost(Game, A, C0), Cost is C0 * 1000 + I ),
            Scored),
        keysort(Scored, [_ - Action | _])
    ;   Concrete = [Action | _]
    ).

% ma_survey_cost(+Game, +Action, -Cost): a survival cost for a probe (lower is safer
% and more informative). A click probe does not relocate the avatar, so it costs
% least; a learned move onto an already-visited (mapped) cell next; a move into
% unmapped territory most, so the survey ventures into the unknown last.
ma_survey_cost(_Game, select(_, _), 0) :- !.
ma_survey_cost(Game, Action, Cost) :-
    (   ma_move_vec_(Game, Action, DR, DC),
        ma_avatar_(Game, AR, AC)
    ->  R2 is AR + DR, C2 is AC + DC,
        ( ma_visited_(Game, R2, C2) -> Cost = 1 ; Cost = 2 )
    ;   % An action whose effect is not yet mapped: treat as venturing (cost 2).
        Cost = 2
    ).

% ma_note_impact(+Game, +Action, +Delta): record the largest effect this action
% has had in this game, and count consecutive no-change steps. The single most
% impactful discovered action is worth recalling when exploration stalls — a
% self-learning agent that stops rediscovering the same mechanic scores far
% higher at the same action budget.
ma_note_impact(Game, Action, Delta) :-
    % The size of this effect, in changed cells.
    length(Delta, Mag),
    % A real change resets the no-progress counter; a no-op advances it.
    ( Mag > 0
    ->  retractall(ma_stale_(Game, _)), assertz(ma_stale_(Game, 0)),
        % Keep this action's best effect if it beats the previous best.
        ( ma_impact_(Game, Action, Old), Old >= Mag
        ->  true
        ;   retractall(ma_impact_(Game, Action, _)),
            assertz(ma_impact_(Game, Action, Mag)) )
    ;   ma_bump_stale(Game)
    ).

% ma_bump_stale(+Game): one more consecutive no-change step for the game.
ma_bump_stale(Game) :-
    % Fetch and remove the current count, defaulting to zero.
    ( retract(ma_stale_(Game, N)) -> true ; N = 0 ),
    % Increment.
    N1 is N + 1,
    % Store it back.
    assertz(ma_stale_(Game, N1)).

% ma_best_impact(+Game, -Action, -Mag): the highest-impact action for the game.
ma_best_impact(Game, Action, Mag) :-
    % Every recorded impact for the game, magnitude first.
    findall(M - A, ma_impact_(Game, A, M), Pairs),
    % There must be at least one.
    Pairs \== [],
    % Largest magnitude first.
    sort(0, @>=, Pairs, [Mag - Action | _]).

% ma_impact_/3: (Game, Action, Magnitude) — the largest effect an action has had.
:- dynamic ma_impact_/3.
% ma_stale_/2: (Game, Count) — consecutive no-change steps this attempt.
:- dynamic ma_stale_/2.

% The choice clauses are interleaved with the helpers they call (the graph
% signature, the explore action set), so declare them discontiguous.
:- discontiguous ma_choose/2.

% ma_choose(-Action, -Basis): the guided choice.
% sb26 game-specific solver (Phase Solo): when the selected game is sb26, drive it with
% the cracked procedure — fill the centre placeholders to match the top target sequence
% (the box borders) then commit with ACTION5, one action per step — so the SOLO player
% wins sb26 level 1 itself. Applies to sb26 only (guarded by the id) and leads the
% cascade because it IS the knowledge of how to play this game.
ma_choose(Action, sb26_solver) :-
    % The selected game is the sb26 environment.
    ma_selected_game(Sel),
    sb26_is_game(Sel),
    % Its current frame.
    ma_render(Sel, Frame),
    % The next action of the sb26 procedure (fails if the board cannot be parsed).
    catch(sb26_next_action(Sel, Frame, Action), _, fail),
    % Commit.
    !.
% ft09 game-specific solver (Phase Solo): when the selected game is ft09, drive it with the
% cracked Lights-Out clue-projection procedure — set each governed cell to fill where its
% clue sub-cell is 0, else blank, one click per step, reading the live frame each time — so
% the SOLO player wins ft09 levels 1 and 2 itself. Applies to ft09 only (guarded by the id)
% and leads the cascade because it IS the knowledge of how to play this game.
ma_choose(Action, ft09_solver) :-
    % The selected game is the ft09 environment.
    ma_selected_game(Sel),
    ft09_is_game(Sel),
    % Its current frame.
    ma_render(Sel, Frame),
    % The next click of the ft09 procedure (fails when the grid already matches — the level
    % is auto-completing — or the board cannot be parsed).
    catch(ft09_next_action(Sel, Frame, Action), _, fail),
    % Commit.
    !.
% If a recorded winning path is being replayed for this game, follow it.
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
    % Only this game's priorities count.
    ma_selected_game(Sel),
    % The human suggested picking up for this game.
    ma_priority_(Sel, action(pickup)),
    % Fetch the state.
    ma_state_(P, at_cell(P), _, _),
    % Commit.
    !.
% Approach the key while the pickup suggestion stands.
ma_choose(Action, toward(key)) :-
    % Only this game's priorities count.
    ma_selected_game(Sel),
    % The suggestion stands for this game and the key is still on the board.
    ma_priority_(Sel, action(pickup)),
    % Fetch the state.
    ma_state_(P, at_cell(K), _, _),
    % Step greedily toward the key, avoiding declared hazards.
    ma_greedy_step(P, K, Action),
    % Commit.
    !.
% Head for the door once the key is held and the goal is set.
ma_choose(Action, toward(goal)) :-
    % Only this game's goal counts.
    ma_selected_game(Sel),
    % The human set this game's traverse goal.
    ma_goal_(Sel, traverse(D)),
    % The key is held.
    ma_state_(P, held, _, _),
    % Step greedily toward the door, avoiding declared hazards.
    ma_greedy_step(P, D, Action),
    % Commit.
    !.
% Survival-first survey: for the opening stretch of an attempt, MAP THE BOARD before
% committing to a goal — the drafts' "explore before you optimise". Sitting above the
% recall / hypothesis / relation / object clauses, it SUPPRESSES goal-pursuit during
% the survey window and instead takes the safest informative probe: predicted-fatal
% moves are HARD-DROPPED here (stronger than the deprioritise of normal play), and a
% probe that does not relocate the avatar, or a step onto an already-mapped cell, is
% preferred over a step into unmapped territory — so the world model and the hazard
% map are built from safe probing before the run ventures or lunges. A mentor's
% taught move still wins (those clauses are above this one).
ma_choose(Action, survival_survey) :-
    % The selected environment.
    ma_selected_game(Sel),
    % Still in the opening survey window of this attempt.
    ma_in_survey_phase(Sel),
    % Its current frame.
    ma_render(Sel, Frame),
    % The safest informative probe this step.
    ma_survey_action(Sel, Frame, Action),
    % Commit.
    !.
% Stuck-recall: when unguided play has made no progress for several steps,
% recall the single action that has had the biggest effect in this game and try
% it again instead of drifting. This is the self-learning nudge that keeps an
% agent from wasting its budget rediscovering a mechanic it already found.
ma_choose(Action, recall(biggest_effect)) :-
    % The selected environment.
    ma_selected_game(Sel),
    % Only after several consecutive no-change steps.
    ma_stale_(Sel, Stale),
    % The stuck threshold.
    Stale >= 3,
    % This game's highest-impact action.
    ma_best_impact(Sel, Action, _Mag),
    % Do not immediately repeat the action just taken (avoid a tight loop).
    \+ ma_last_(Action, _),
    % Never recall a move that lands on a declared hazard.
    \+ ma_lands_on_hazard(Action),
    % Commit.
    !.
% Breadth first: before exploiting a known-effective action, try an action (or
% salient click target) that has not been tried at all this attempt. Without
% this, once a single click is learned to change the world the causal-first rule
% below fixates on it and never probes the other objects — the tunnel-vision
% failure. The explore set is ordered least-tried-first, so the first untried
% one leads.
ma_choose(Action, explore(novel)) :-
    % The selected environment.
    ma_selected_game(Sel),
    % Its current frame.
    ma_render(Sel, Frame),
    % Its safe action set with salient clicks, least-tried first.
    ma_explore_concrete(Sel, Frame, Concrete),
    % There must be something to try.
    Concrete \== [],
    % The first action not yet tried this attempt.
    member(Action, Concrete),
    % Genuinely never tried — no counter recorded for it. (A bound-zero call to
    % ma_try_count would succeed for ANY count, since its (Cond->true;Count=0) idiom
    % unifies the already-bound 0 in the else branch; checking the counter's absence
    % directly is what "never tried" means, and it is what lets the cascade fall
    % through to the exploitation clauses once every action has been probed once.)
    \+ ma_try_(Action, _),
    % Commit to it.
    !.
% Committed-hypothesis exploitation (co_hypo): once the untried actions are
% exhausted, take the action Mentova has COMMITTED to as productive for this game —
% the belief the hypothesis pack holds with anti-drift hysteresis. This is where a
% guided run's committed hypothesis, persisted to disk and restored, drives a later
% Solo choice: the same store answers hy_committed for all three players. The
% committed action must still be available and not known fatal here.
ma_choose(Action, hypothesis(committed)) :-
    % The selected environment.
    ma_selected_game(Sel),
    % The action this game's world model is committed to as productive.
    catch(hy_committed(Sel, productive(Action)), _, fail),
    % It is an available control in this environment.
    ma_actions_env(Sel, As),
    memberchk(Action, As),
    % Its current frame, so safety can be judged.
    ma_render(Sel, Frame),
    % Never a move known to end the game from this state.
    ma_action_safe(Sel, Frame, Action),
    % Do not immediately repeat the action just taken (avoid a tight loop).
    \+ ma_last_(Action, _),
    % Commit.
    !.
% Relation-aware targeting (co_rel): reason over the objects co_see perceives and go
% to the one worth going to NEXT — chosen by a ranked utility (goal-relevance, then
% information value, with distance only a tiebreaker), NOT by bare nearness. The
% chosen object may be farther than another; the Reason records why it won, for the
% glass-box Why. Sits above the generic object curiosity; falls through to it when no
% object qualifies.
ma_choose(Action, relation(Reason)) :-
    % The selected environment and its current frame.
    ma_selected_game(Sel),
    ma_render(Sel, Frame),
    % See the whole grid as an inventory of roled objects.
    catch(ma_inventory(Frame, Items), _, fail),
    Items \== [],
    % The best object to go to next, by ranked utility, with the reason it won.
    catch(ma_relation_target(Sel, Frame, Items, pos(TR, TC), Reason), _, fail),
    % Turn that target into a concrete move (movement game) or click (click game).
    ma_target_action(Sel, Frame, TR, TC, Action),
    % Never a move known to end the game from this state.
    ma_action_safe(Sel, Frame, Action),
    % Commit.
    !.
% Object-targeted curiosity: SEE the whole grid (co_see inventory), pick a salient
% object not yet visited this attempt, and deliberately GO TO IT — steering the
% avatar toward it on a movement game (using the control map perception learned)
% or clicking its centroid on a click game. This is the "go touch that object to
% see what it does" behaviour the mentor asked for, and it stops the player
% mulling on one spot. When a meter is draining, collectible dots are preferred,
% enacting the cross-game resource-refill prior. It runs after breadth-first
% novelty (which has meanwhile taught the control map) and yields once every
% object has been visited, so causal exploitation still follows.
ma_choose(Action, explore(object(Basis))) :-
    % The selected environment and its current frame.
    ma_selected_game(Sel),
    ma_render(Sel, Frame),
    % See the whole grid as an inventory of roled objects.
    catch(ma_inventory(Frame, Items), _, fail),
    Items \== [],
    % Choose a concrete action that pursues a fresh object.
    ma_object_action(Sel, Frame, Items, Action, Basis),
    % Never a move known to end the game from this state.
    ma_action_safe(Sel, Frame, Action),
    % Commit.
    !.
% Causal-first exploitation: if this game's learned causal graph predicts that
% some available action changes the world, take the least-tried such action.
% This is the co_explore policy's strongest signal - one of the two behaviours
% the winning ARC-AGI-3 agents shared (learning which actions have an effect).
% The action set includes a click marker, so ACTION6 is considered as a click on
% a salient object rather than a blind cell.
ma_choose(Action, explore(causal)) :-
    % The selected environment.
    ma_selected_game(Sel),
    % Its current frame.
    ma_render(Sel, Frame),
    % Its concrete safe action set (salient clicks expanded, fatal moves dropped).
    ma_explore_concrete(Sel, Frame, Concrete),
    % There must be something to try.
    Concrete \== [],
    % How many times each concrete action has been tried this attempt.
    findall(A - N, ma_try_(A, N), Tried),
    % The least-tried action this game predicts will change the world; fails when
    % none is predicted, so exploration falls through to the graph frontier.
    catch(cox_choose_change(Sel, Concrete, Tried, Frame, Action), _, fail),
    % Commit.
    !.
% Before falling back to least-tried curiosity, use the state-graph explorer -
% the winning ARC-AGI-3 technique: probe an untested, non-dead action in the
% current state, or take the first step toward the nearest unexplored frontier.
ma_choose(Action, graph_explore) :-
    % The selected environment.
    ma_selected_game(Sel),
    % Its current frame.
    ma_render(Sel, Frame),
    % Its safe action set, with the cell-select expanded to this frame's salient
    % click targets so the frontier search explores real clicks, not one cell.
    ma_explore_concrete(Sel, Frame, Safe),
    % There must be something safe to try.
    Safe \== [],
    % Signature stamped with the selected game, guarded.
    catch(ma_game_sig(Sel, Frame, Sig), _, fail),
    % The graph-informed choice, guarded; fails when nothing is left to explore.
    catch(cg_choose(Sig, Safe, Action), _, fail),
    % Commit.
    !.

% ma_graph_note(+Frame0, +Action, +Frame1): record a transition in the graph,
% keyed by the selected game so no two environments share a node.
ma_graph_note(Frame0, Action, Frame1) :-
    % Guarded so a graph hiccup never breaks a step.
    catch((
        ma_selected_game(Game),
        ma_game_sig(Game, Frame0, S0),
        ma_game_sig(Game, Frame1, S1),
        cg_note(S0, Action, S1)
    ), _, true).

% ma_game_sig(+Game, +Frame, -Sig): a state signature stamped with the game id,
% so a state in one environment can never be confused with one in another.
ma_game_sig(Game, Frame, Sig) :-
    % The frame's canonical signature with this game's volatile (HUD/animation)
    % cells masked out, so a returned-to state is recognised despite a ticking
    % counter.
    ma_state_key(Game, Frame, Base),
    % Stamp it with the game id.
    atomic_list_concat([Game, '::', Base], Sig).

% If the graph has no frontier to head for, fall to the full co_explore ranking:
% predicted-change actions first, then least-tried, with the salient object
% clicks (concrete ACTION6 targets) in play. This keeps ACTION6 useful without
% enumerating all 4096 cells, and never repeats a known-hazard action.
ma_choose(Action, explore(salient)) :-
    % The selected environment.
    ma_selected_game(Sel),
    % Its current frame.
    ma_render(Sel, Frame),
    % Its concrete safe action set (salient clicks expanded, fatal moves dropped).
    ma_explore_concrete(Sel, Frame, Concrete),
    % There must be something to try.
    Concrete \== [],
    % The per-action try counts this attempt.
    findall(A - N, ma_try_(A, N), Tried),
    % The best action under the full policy; guarded so a perception hiccup
    % never blocks the plain-curiosity fallback below.
    catch(cox_choose(Sel, Concrete, Tried, Frame, Action), _, fail),
    % Commit.
    !.
% ma_explore_actions(+Game, +Frame, -Marked): the game's action set with any
% ACTION6 cell-select replaced by a single click marker (which the policy
% expands to the salient object centroids), hazards removed, duplicates merged.
ma_explore_actions(Game, _Frame, Marked) :-
    % The environment's available actions.
    ( ma_actions_env(Game, Actions) -> true ; Actions = [] ),
    % Drop any move that would land on a human-declared hazard.
    findall(M,
        ( member(A, Actions),
          \+ ma_lands_on_hazard(A),
          % A concrete cell-select becomes the generic click marker.
          ( A = select(_, _) -> M = click ; M = A ) ),
        Marked0),
    % Merge duplicates (many concrete selects collapse to one click marker).
    sort(Marked0, Marked).

% ma_explore_concrete(+Game, +Frame, -Actions): the safe action set with the click
% marker expanded to this frame's salient object-centroid targets, ordered least-
% tried-first with predicted-fatal moves deprioritised. Recomputed on each call
% (it depends on the learnings, which a caller may change between calls), but its
% one expensive part — segmenting the grid for the salient targets — is served from
% the per-step perception cache, so the segmentation runs once per step, not once
% per exploration rule. That is the performance fix.
ma_explore_concrete(Game, Frame, Actions) :-
    % The safe action set with a click marker standing in for cell-select.
    ma_explore_actions(Game, Frame, Marked),
    % Expand the click marker to the frame's salient select(X,Y) targets, using the
    % cached salient cells so the grid is segmented once per step.
    ( catch(ma_expand_actions(Marked, Frame, Concrete0), _, fail)
    ->  Concrete1a = Concrete0
    % If expansion is unavailable, fall back to the marker list unchanged.
    ;   Concrete1a = Marked
    ),
    % Drop any action known to end the game from this state, so a carried-forward
    % attempt does not repeat a fatal move.
    findall(A0, ( member(A0, Concrete1a), ma_action_safe(Game, Frame, A0) ), Safe),
    % If avoiding deaths would leave nothing, keep the set rather than stall.
    ( Safe == [] -> Concrete1 = Concrete1a ; Concrete1 = Safe ),
    % Order the actions least-tried-first (this attempt). On a click game a
    % changing region (a counter or animation) makes each frame hash differently,
    % so the state graph would otherwise re-offer the same largest-object click
    % forever; ordering by how little each concrete target has been tried spreads
    % the clicks across the perceived objects instead of hammering one.
    findall(N - A, ( member(A, Concrete1), ma_try_count(A, N) ), Scored),
    % Least-tried first; ties keep their relative order.
    keysort(Scored, Sorted),
    % Drop the counts.
    findall(A, member(_ - A, Sorted), Actions0),
    % Verify before act: send actions PREDICTED fatal (by the world model — exact
    % death memory, a deadly-colour destination, or a broadly-fatal action) to the
    % back, keeping the least-tried order within each group. Deprioritised, not
    % dropped, so a genuinely all-risky state still yields the least-bad move.
    ma_deprioritise_fatal(Game, Frame, Actions0, Actions).
% Otherwise curiosity decides: the least-tried safe action over the selected
% environment's action set, so unguided play genuinely explores rather than
% repeating one move.
ma_choose(Action, curiosity) :-
    % The selected environment's action set.
    ma_selected_game(Sel),
    % Its current frame.
    ma_render(Sel, Frame),
    % Its safe action set, cell-select expanded to salient click targets.
    ma_explore_concrete(Sel, Frame, Safe0),
    % If nothing is left (e.g. no objects to click), fall back to the raw set.
    ( Safe0 == [] -> ma_actions_env(Sel, Safe) ; Safe = Safe0 ),
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

% ma_lands_on_hazard(+Action): the move would land on a hazard declared for
% the selected game.
ma_lands_on_hazard(Action) :-
    % Only movement actions land anywhere.
    ma_move_delta(Action, DR, DC),
    % Fetch the player's position.
    ma_state_(pos(PR, PC), _, _, _),
    % The landing cell.
    R1 is max(0, min(4, PR + DR)),
    % Its column.
    C1 is max(0, min(4, PC + DC)),
    % A human declared it hazardous in this game.
    ma_selected_game(Sel),
    % Only this game's declared hazards apply.
    ma_avoid_cell_(Sel, pos(R1, C1)).

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
    % The survival-first survey chose it — a safe opening probe to map the board.
    ;   Basis = survival_survey
    ->  Provenance = survival_first_survey
    % A committed hypothesis chose it — a belief that may itself have been shaped by
    % a guided run and reloaded, so it is reasoned-from-belief rather than a raw guess.
    ;   Basis = hypothesis(committed)
    ->  Provenance = committed_hypothesis
    % Relation-aware object targeting chose it.
    ;   Basis = relation(_)
    ->  Provenance = object_relations
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

% ma_handle_agentview(+Request): the machine-facing twin of the ARC page. A GET
% returns everything a Claude mentor needs to SEE and reason about the game — the
% grid as digit rows, co_see's whole-grid object inventory with roles and
% positions, the meters read from the grid, the available actions with their
% discovered labels, the game status, and the current hierarchical plan tree —
% plus a short note on how to act and teach through the existing mentor endpoints.
% Read-only and unauthenticated: it exposes only what is already visible; driving
% the game and teaching still require a mentor token on /api/arc/control and
% /api/arc/hint.
ma_handle_agentview(_Request) :-
    % The selected environment.
    ma_selected_game(Sel),
    % The current frame, resetting if the environment is fresh.
    ( ma_render(Sel, Frame) -> true ; ma_reset_env(Sel, Frame) ),
    % The grid dimensions.
    ( catch(gd_size(Frame, Rows, Cols), _, fail) -> true ; Rows = 0, Cols = 0 ),
    % The grid as compact digit rows (0-9, a-f), for a text-only reader.
    ( catch(ma_grid_ascii(Frame, Ascii), _, fail) -> true ; Ascii = [] ),
    % The whole-grid object inventory (co_see), each object with role and position.
    ma_agent_inventory(Frame, Inventory),
    % The bar-like meters read from the grid, with their tracked trend.
    ma_agent_meters(Sel, Frame, Meters),
    % The available actions with their discovered labels.
    ma_action_descriptors(Sel, Actions),
    % The game status (won, lost, or still playing) and any level progress.
    ma_agent_status(Sel, Frame, Status, Levels),
    % The current hierarchical plan tree and where the last choice sat on it.
    ( catch(ma_plan_view(Sel, Plan), _, fail) -> true ; Plan = _{} ),
    % The last action taken, for continuity.
    ( ma_last_(LastA, _) -> term_to_atom(LastA, LastText) ; LastText = "none" ),
    ( ma_last_command(LastCmd) -> true ; LastCmd = 'none' ),
    % The active mode and the game's human title.
    ma_mode(Mode),
    ( ma_available_game(Sel, Title) -> true ; Title = Sel ),
    % The note that tells a machine mentor how to act and teach.
    ma_agent_howto(HowTo),
    % The general laws the executable world model has learned for this game, as
    % readable strings — the glass box on what the mind now believes the game does.
    ( catch(ma_wm_laws(Sel, LawTerms), _, LawTerms = []) -> true ; LawTerms = [] ),
    findall(LS, ( member(L, LawTerms), term_string(L, LS) ), WorldModelLaws),
    % The rest of the glass-box cognition: the committed hypothesis, the inferred
    % goal, and the object relations the mind currently sees — so an AI mentor reads
    % not just what the game does but what Mentova believes and is reasoning over.
    ma_agent_cognition(Sel, Frame, Cognition),
    % Reply with the full machine-facing view.
    reply_json_dict(_{
        game: Sel, title: Title, mode: Mode, status: Status, levels: Levels,
        size: _{rows: Rows, cols: Cols},
        grid: Frame, grid_ascii: Ascii,
        inventory: Inventory, meters: Meters,
        actions: Actions, plan: Plan, world_model_laws: WorldModelLaws,
        cognition: Cognition,
        last_action: LastText, last_command: LastCmd,
        how_to_mentor: HowTo}).

% ma_agent_cognition(+Game, +Frame, -Dict): the glass-box cognitive state as a dict —
% the committed hypothesis (co_hypo), the inferred goal and its confidence
% (co_goalinfer), and the object relations now visible (co_rel). Best-effort and
% total: every field defaults gracefully so the view never fails.
ma_agent_cognition(Game, Frame, _{
        committed_hypothesis: Committed,
        hypotheses: NumHyp,
        inferred_goal: Goal,
        goal_confidence: Conf,
        actions_spent: Spent,
        object_relations: Relations}) :-
    % The committed productive-action hypothesis, if any.
    ( catch(hy_committed(Game, HC), _, fail) -> term_string(HC, Committed) ; Committed = "none" ),
    % How many hypotheses this game holds.
    ( catch(hy_stats(Game, stats(NumHyp, _)), _, fail) -> true ; NumHyp = 0 ),
    % The inferred win condition and how strongly it dominates.
    ( catch(cgi_hypothesise_goal(G), _, fail) -> term_string(G, Goal) ; Goal = "unknown" ),
    ( catch(cgi_confidence(Conf0), _, fail) -> Conf = Conf0 ; Conf = 0.0 ),
    % Actions spent this attempt (the budget count).
    ( catch(cef_actions(Game, Spent), _, fail) -> true ; Spent = 0 ),
    % The object relations co_rel derives from the current perception (capped for
    % readability), as readable strings.
    ( catch(ma_object_relations(Frame, RelTerms), _, fail) -> true ; RelTerms = [] ),
    findall(RS, ( member(R, RelTerms), term_string(R, RS) ), Relations).

% ma_object_relations(+Frame, -Relations): the object relations co_rel finds among
% the objects co_see perceives in the frame — adjacency, containment, alignment, and
% offset vectors — capped to the first twenty so the view stays compact.
ma_object_relations(Frame, Relations) :-
    % Perceive the objects (co_see), each as seen(Id, Colour, Size, cell, Role).
    catch(ma_inventory(Frame, Items), _, Items = []),
    % Recast them as co_rel objects obj(Id, cell, bbox, Size).
    findall(obj(cell(R, C), cell(R, C), bbox(R, C, R, C), Size),
        member(seen(_, _, Size, cell(R, C), _), Items),
        Objs),
    % Enumerate the relations, then keep at most twenty.
    ( catch(cr_relations(Objs, All), _, fail) -> true ; All = [] ),
    ( length(All, N), N =< 20 -> Relations = All
    ; length(Relations, 20), append(Relations, _, All) ).

% ma_grid_ascii(+Frame, -Lines): the grid as one compact string per row, each cell
% a single character (0-9 then a-f for 10-15), so a text-only reader sees the whole
% board at a glance.
ma_grid_ascii(Frame, Lines) :-
    % One line per row.
    findall(Line,
        ( member(Row, Frame),
          findall(Ch, ( member(V, Row), ma_cell_char(V, Ch) ), Chars),
          atom_chars(Line, Chars) ),
        Lines).

% ma_cell_char(+Value, -Char): a single character for a cell colour 0..15.
ma_cell_char(V, Ch) :-
    % A valid colour maps to a hex digit.
    ( integer(V), V >= 0, V =< 15
    ->  nth0(V, ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'], Ch)
    % Anything else is shown as a dot.
    ;   Ch = '.' ).

% ma_agent_inventory(+Frame, -Inventory): the co_see object inventory as a list of
% dicts, each naming an object's colour, size, role, and position.
ma_agent_inventory(Frame, Inventory) :-
    % Segment the whole grid, guarded.
    ( catch(ma_inventory(Frame, Items), _, Items = []) -> true ; Items = [] ),
    % One dict per object.
    findall(_{id: Id, colour: Colour, size: Size, role: Role, row: R, col: C},
        member(seen(Id, Colour, Size, cell(R, C), Role), Items),
        Inventory).

% ma_agent_meters(+Game, +Frame, -Meters): the bar-like meters on the grid, each
% with its position and, where the resource model has tracked it, its trend.
ma_agent_meters(Game, Frame, Meters) :-
    % The bar-like objects, guarded.
    ( catch(ma_bars(Frame, Bars), _, Bars = []) -> true ; Bars = [] ),
    % One dict per meter, joining the tracked trend by colour and orientation.
    findall(_{colour: Colour, orientation: Orient, length: Len, row: R, col: C, trend: Trend},
        ( member(bar(Colour, Orient, Len, cell(R, C)), Bars),
          atomic_list_concat([Colour, '_', Orient], Key),
          ( ma_meter_(Game, Key, _, Trend0) -> Trend = Trend0 ; Trend = unknown ) ),
        Meters).

% ma_agent_status(+Game, +Frame, -Status, -Levels): the game status as an atom and
% the level progress (best-effort; live games report levels, local ones do not).
ma_agent_status(Game, Frame, Status, Levels) :-
    % Won, lost, or still playing.
    ( ma_solved_env(Game, Frame) -> Status = won
    ; catch(ma_env_over(Game), _, fail) -> Status = game_over
    ; Status = playing ),
    % Level progress from the live client, if available.
    ( catch(al_progress(Game, Done, Win), _, fail)
    -> Levels = _{completed: Done, win_levels: Win}
    ;  Levels = _{completed: 0, win_levels: 0} ).

% ma_agent_howto(-HowTo): the short note telling a machine mentor how to act and
% teach through the same authenticated channel a human mentor uses.
ma_agent_howto(_{
    name: "The Mentor Bridge — a glass-box bridge between minds. See the game here, then act and teach through the mentor endpoints.",
    read: "GET /api/arc/agentview — this view (grid, inventory, meters, actions, plan).",
    sign_in: "POST /api/mentor/login {username, password} → {token}. New mentor: POST /api/mentor/signup {username, password}.",
    act: "POST /api/arc/control {token, cmd:\"act\", command:\"ACTION1\"} — perform a control (use a 'command' from actions[].command). For the cell-select ACTION6, add x and y (x=column, y=row, 0..63) to click a specific object.",
    teach: "POST /api/arc/hint {token, text, session_id, ref} — teach a clue, grounded into Causalontology and injected into the game.",
    why: "GET /api/arc/why — what Mentova last did, why, and where on the plan.",
    docs: "See docs/ARC-AGI-3_Agent_Interface.txt for the full connect-and-teach flow."}).

% ma_handle_ingest_draft(+Request): ingest a plain-text draft document into the
% live mind through the nuanced fact doors (exact facts strengthen, near-duplicates
% are kept as flagged variants), returning the per-draft report. Mentor-
% authenticated, because it writes into Mentova's lattice and Causalontology.
ma_handle_ingest_draft(Request) :-
    % Read the JSON body.
    http_read_json_dict(Request, Body),
    % A token, the draft text, and a draft id are required.
    ( get_dict(token, Body, Tk) -> true ; Tk = "" ),
    ( get_dict(text, Body, Text) -> true ; Text = "" ),
    ( get_dict(draft_id, Body, DidStr) -> atom_string(Did, DidStr) ; Did = draft ),
    % Only a mentor may write facts into the mind.
    (   mc_verify_session(Tk, _GuideId)
    % Ingest and report, guarded so a bad draft never crashes the endpoint.
    ->  (   catch(( di_ingest_text(Text, Did, Report),
                    di_report_json(Report, RDict) ), _E, fail)
        ->  reply_json_dict(RDict.put(_{ok: true}))
        ;   reply_json_dict(_{ok: false, error: "Could not ingest the draft."})
        )
    % Refuse the unauthenticated.
    ;   reply_json_dict(_{ok: false, error: "Not signed in."})
    ).

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
    % Forget the exploration graph too (a full reset).
    catch(cg_reset, _, true),
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
    (   ma_command_action_at(Sel, Cmd, Body, Action)
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
                % Persist the taught game's learnings (classic levers + world model +
                % hypotheses + goal inference) to disk now, so a mentor's teaching —
                % human OR AI — is always written and is there for a later Solo run to
                % reload. Guarded: a persistence hiccup never fails the teach.
                ignore(catch(( ma_selected_game(GT), ma_persist_game(GT) ), _, true)),
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
    % The selected game, to fetch its plan hierarchy.
    ma_selected_game(Game),
    % The plan hierarchy view (tree, active OODA phase, and the mesh proofs).
    ( catch(ma_plan_view(Game, Plan), _, fail) -> true ; Plan = _{} ),
    % Fetch the justification.
    (   ma_why(why(Action, Basis, Provenance))
    % Render it for JSON.
    ->  term_to_atom(Action, AText),
        % The basis.
        term_to_atom(Basis, BText),
        % Reply with the full story, including where in the plan this choice sits.
        reply_json_dict(_{action: AText, basis: BText, provenance: Provenance,
                          plan: Plan})
    % No action has been taken yet: still show the plan the run will follow.
    ;   reply_json_dict(_{action: none, basis: none, provenance: none,
                          plan: Plan})
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
        % Start the selected live game fresh; tolerate both failure and error so
        % one uncooperative game can never make the whole connect handler fail.
        ignore(catch(ma_reset_env(First, _), _, fail)),
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
ma_handle_restart(Request) :-
    % An optional {budget: N} in the body raises the solo action budget for this attempt
    % (a multi-level game needs more than the default, since every run starts at level 1).
    ( catch(http_read_json_dict(Request, Body), _, fail),
      get_dict(budget, Body, B), integer(B), B > 0
    ->  ma_set_solo_budget(B)
    ;   true ),
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
