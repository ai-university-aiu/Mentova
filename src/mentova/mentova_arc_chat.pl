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
    ma_reset_guidance/0
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
ma_step(step(Action, Basis, Outcome)) :-
    % The frame before the action.
    ma_game_frame(Frame0),
    % Choose the action and remember why.
    ma_choose(Action, Basis),
    % Doing: perform it.
    ma_env_act(Action, Frame1),
    % The observed effect is the frame delta.
    co_arc3_delta(Frame0, Frame1, Delta),
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
    assertz(ma_last_(Action, Basis)).

% ma_choose(-Action, -Basis): the guided choice.
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
% Otherwise curiosity decides, exactly as in the autonomous harness.
ma_choose(Action, curiosity) :-
    % The game's action set.
    ma_env_actions(Actions),
    % Keep only moves that do not land on a human-declared hazard.
    findall(A, ( member(A, Actions), \+ ma_lands_on_hazard(A) ), Safe),
    % The harness's least-tried choice over the safe set.
    co_arc3_choose(Safe, none, Action).

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

% ma_handle_frame(+Request): the current frame and status as JSON.
ma_handle_frame(_Request) :-
    % Fetch the frame.
    ma_game_frame(Frame),
    % Won or still playing?
    ( ma_env_solved(Frame) -> Status = won ; Status = playing ),
    % Reply.
    reply_json_dict(_{frame: Frame, status: Status}).

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
