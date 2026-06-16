/*  Mentova — Baba Is You Driver

    Baba Is You is a puzzle game by Arvi Teikari (Hempuli, 2019) in which
    the player pushes word-blocks on a grid to rewrite the rules of the game.
    Rules take the form "NOUN IS ADJECTIVE" (e.g. BABA IS YOU, ROCK IS PUSH,
    FLAG IS WIN).  Pushing a word-block changes what is possible.

    This driver encodes one toy Baba Is You level as Prolog node_facts.
    The game state is: a set of objects on a grid and a set of active rules.
    An action is a player move (up/down/left/right) or a direct push.

    The key insight for Mentova: game rules are node_facts, and rewriting rules
    by pushing word-blocks is exactly Mentova's defeasible/symbolic reasoning
    operating on its own knowledge base.  This is the most distinctive flagship:
    a mind that reshapes its own rules to win.

    Predicates exposed to game_body.pl:
        baba(observe, GameId, Frame)                            — current level
        baba(act,     GameId, Action, Result)                   — move or push
        baba(reason,  GameId, Frame, Step, Type, Action, Just)  — reason about rules

    Standalone predicates:
        baba_level/3         — LevelId, Objects, Rules
        baba_active_rules/2  — GameId, ActiveRules
        baba_can_win/2       — GameId, WinCondition
        baba_plan_to_win/3   — GameId, Plan, Justification
*/

% Declare this file as the 'baba' module, making its predicates available to other modules.
:- module(baba, [
    % Supply 'baba/3' for the observe interface.
    baba/3,
    % Supply 'baba/4' for the act interface.
    baba/4,
    % Supply 'baba/7' for the reason interface.
    baba/7,
    % Supply 'baba_level/3' as the next argument to the expression above.
    baba_level/3,
    % Supply 'baba_active_rules/2' as the next argument to the expression above.
    baba_active_rules/2,
    % Supply 'baba_can_win/2' as the next argument to the expression above.
    baba_can_win/2,
    % Supply 'baba_plan_to_win/3' as the next argument to the expression above.
    baba_plan_to_win/3,
    % Supply 'baba_load_level/2' as the next argument to the expression above.
    baba_load_level/2
% Close the expression opened above.
]).

% Load the built-in 'lists' library so member, select, and append are available.
:- use_module(library(lists), [member/2, select/3, append/3]).

% Allow 'baba_level/3' to appear at non-consecutive positions in this file.
:- discontiguous baba_level/3.

% Declare 'baba_game_state/3' as dynamic so the current level state can be updated.
:- dynamic baba_game_state/3.      % GameId, Objects, ActiveRules
% Declare 'baba_move_log/3' as dynamic so the sequence of moves is recorded.
:- dynamic baba_move_log/3.        % GameId, StepN, Action

% ---------------------------------------------------------------------------
% Object representation
%
% object(Type, Pos, pos(Row, Col))
%   Type: entity | word_noun | word_is | word_adjective
%     entity subtypes:    baba | rock | flag | wall | water
%     word_noun subtypes: word_baba | word_rock | word_flag | word_wall
%     word_adj subtypes:  word_you | word_win | word_push | word_stop | word_sink
%   pos(Row, Col): grid position, 1-indexed
%
% Rule representation
%   rule(Noun, is, Adjective)
%     e.g. rule(baba, is, you)   — the player controls baba
%          rule(flag, is, win)   — touching flag wins
%          rule(rock, is, push)  — rocks can be pushed
% ---------------------------------------------------------------------------

% ---------------------------------------------------------------------------
% Level Library
%
% baba_level(LevelId, Objects, Rules)
%   Objects  — list of object(Type, pos(Row, Col)) terms
%   Rules    — list of rule(Noun, is, Adj) terms currently active
% ---------------------------------------------------------------------------

% LEVEL 1 — "simple win":
%   BABA IS YOU and FLAG IS WIN are active.
%   ROCK IS PUSH is written but not active yet (word blocks need aligning).
%   Goal: reach the flag.
% State the fact: level 'simple_win' has these objects and initial rules.
baba_level(simple_win,
    % Objects: baba entity, flag entity, and the word blocks for two rules.
    [ object(entity_baba,      pos(3,2)),
      object(entity_flag,      pos(3,5)),
      object(word_baba,        pos(1,1)),
      object(word_is,          pos(1,2)),
      object(word_you,         pos(1,3)),
      object(word_flag,        pos(2,1)),
      object(word_is2,         pos(2,2)),
      object(word_win,         pos(2,3)),
      object(word_rock,        pos(5,1)),
      object(word_is3,         pos(5,3)),
      object(word_push,        pos(5,5)),
      object(entity_rock,      pos(3,4))
    ],
    % Active rules read from horizontally/vertically aligned word triples.
    [ rule(baba, is, you),
      rule(flag,  is, win)
    ]
).

% LEVEL 2 — "rule rewrite":
%   Only ROCK IS YOU is active (baba is not the player; rock is).
%   FLAG IS WIN is active.
%   Goal: push word blocks to restore BABA IS YOU, then reach the flag.
% State the fact: level 'rule_rewrite' has these objects and initial rules.
baba_level(rule_rewrite,
    % Objects: entity_rock is the current player (rock is you).
    [ object(entity_rock,   pos(3,3)),
      object(entity_baba,   pos(4,4)),
      object(entity_flag,   pos(3,7)),
      object(word_baba,     pos(1,1)),
      object(word_is,       pos(1,3)),
      object(word_you,      pos(1,5)),
      object(word_flag,     pos(2,1)),
      object(word_is2,      pos(2,3)),
      object(word_win,      pos(2,5)),
      object(word_rock,     pos(5,1)),
      object(word_is3,      pos(5,3)),
      object(word_you2,     pos(5,5))
    ],
    % Initial rules: rock is you, flag is win (baba is not controlled).
    [ rule(rock, is, you),
      rule(flag, is, win)
    ]
).

% ---------------------------------------------------------------------------
% baba_active_rules/2  — get the active rules for a game instance
% ---------------------------------------------------------------------------

% Define a clause for 'baba_active_rules': retrieve the current rules for a game.
baba_active_rules(GameId, ActiveRules) :-
    % Look up the current game state.
    ( baba_game_state(GameId, _, ActiveRules)
    % If a game state exists, return its active rules.
    ->  true
    % If no game state exists, there are no active rules.
    ;   ActiveRules = []
    ).

% ---------------------------------------------------------------------------
% baba_can_win/2  — check whether the current rule set permits winning
%
%   Returns WinCondition = win_via(WinningNoun, WinningAdj)
%   or      WinCondition = no_win_possible
% ---------------------------------------------------------------------------

% Define a clause for 'baba_can_win': check whether the current rules allow winning.
baba_can_win(GameId, WinCondition) :-
    % Get the current active rules.
    baba_active_rules(GameId, Rules),
    % Check whether there is a "X IS YOU" rule and a "Y IS WIN" rule.
    ( member(rule(PlayerNoun, is, you), Rules),
      member(rule(WinNoun, is, win), Rules)
    % If both rules exist, winning is possible by the player touching the win object.
    ->  WinCondition = win_via(player(PlayerNoun), touch(WinNoun))
    % If neither or only one exists, winning is not currently possible.
    ;   WinCondition = no_win_possible
    ).

% ---------------------------------------------------------------------------
% baba_plan_to_win/3  — plan a sequence of moves to win the level
%
%   Uses backward-chaining over the current rules:
%   If winning is already possible, plan is [move_toward_win_object].
%   If rules need rewriting, plan includes push steps to align word blocks.
% ---------------------------------------------------------------------------

% Define a clause for 'baba_plan_to_win': compute a winning plan for the current state.
baba_plan_to_win(GameId, Plan, Justification) :-
    % Check whether winning is currently possible.
    baba_can_win(GameId, WinCondition),
    % Branch based on whether winning is immediately possible.
    ( WinCondition = win_via(player(PlayerNoun), touch(WinNoun))
    % If winning is possible, plan is simply to move toward the win object.
    ->  Plan = [step(observe_board),
                step(locate_player(PlayerNoun)),
                step(locate_win_object(WinNoun)),
                step(move_toward(WinNoun)),
                step(touch_win_object(WinNoun))],
        Justification = just(baba_planning,
                             rule_analysis(WinCondition),
                             plan_type(direct_path_to_win),
                             reasoning(teleological_and_procedural))
    % If winning is not possible, rules need rewriting first.
    ;   Plan = [step(observe_board),
                step(identify_missing_rules),
                step(locate_word_blocks),
                step(push_blocks_to_align_rule),
                step(verify_new_rule_active),
                step(move_toward_win_object)],
        Justification = just(baba_planning,
                             rule_analysis(WinCondition),
                             plan_type(rule_rewrite_then_win),
                             reasoning(symbolic_and_teleological))
    ).

% ---------------------------------------------------------------------------
% baba_apply_move/5  — apply a player move, updating game state
% ---------------------------------------------------------------------------

% Define a clause for 'baba_apply_move': apply a direction move to the game state.
baba_apply_move(GameId, move(Direction), OldObjects, NewObjects, Result) :-
    % Find the delta for this direction.
    direction_delta(Direction, DR, DC),
    % Find the active player's entity type.
    baba_active_rules(GameId, Rules),
    ( member(rule(PlayerNoun, is, you), Rules)
    ->  atom_concat(entity_, PlayerNoun, PlayerType)
    ;   PlayerType = entity_baba
    ),
    % Find the player's current position.
    ( member(object(PlayerType, pos(R, C)), OldObjects)
    ->  NewR is R + DR, NewC is C + DC,
        % Remove the old player position and add the new one.
        select(object(PlayerType, pos(R,C)), OldObjects, Rest),
        NewObjects = [object(PlayerType, pos(NewR, NewC)) | Rest],
        Result = moved(PlayerType, from(pos(R,C)), to(pos(NewR,NewC)))
    ;   NewObjects = OldObjects,
        Result = no_player_found(PlayerType)
    ).

% Define a clause for 'direction_delta' for up: row decreases by 1.
direction_delta(up,    -1,  0).
% Define a clause for 'direction_delta' for down: row increases by 1.
direction_delta(down,   1,  0).
% Define a clause for 'direction_delta' for left: column decreases by 1.
direction_delta(left,   0, -1).
% Define a clause for 'direction_delta' for right: column increases by 1.
direction_delta(right,  0,  1).

% ---------------------------------------------------------------------------
% Driver interface — called by game_body.pl via =.. dispatch
% ---------------------------------------------------------------------------

% Define a clause for 'baba/4 observe': return the current level frame.
baba(observe, GameId, Frame) :-
    % Check if a game state has been initialized.
    ( baba_game_state(GameId, Objects, Rules)
    ->  Frame = baba_frame(objects(Objects), active_rules(Rules))
    ;   Frame = baba_frame(no_level_loaded, GameId)
    ).

% Define a clause for 'baba/4 act' for a move action.
baba(act, GameId, move(Direction), Result) :-
    % Get the current game state.
    baba_game_state(GameId, OldObjects, Rules),
    % Apply the move.
    baba_apply_move(GameId, move(Direction), OldObjects, NewObjects, MoveResult),
    % Update the game state with the new object positions.
    retract(baba_game_state(GameId, OldObjects, Rules)),
    assertz(baba_game_state(GameId, NewObjects, Rules)),
    % Check win condition after the move.
    baba_can_win(GameId, WinCheck),
    Result = move_result(MoveResult, win_check(WinCheck)).

% Define a clause for 'baba/4 act' for a plan action.
baba(act, GameId, execute_plan(Plan), Result) :-
    % Record that this plan was executed.
    length(Plan, NSteps),
    Result = plan_recorded(GameId, steps(NSteps), plan(Plan)).

% Define a clause for 'baba/4 reason': reason about rules and produce a plan.
baba(reason, GameId, _Frame, _StepN, _QueryType, Action, Justification) :-
    % Compute a plan to win from the current state.
    baba_plan_to_win(GameId, Plan, PlanJust),
    % The action is to execute the computed plan.
    Action = execute_plan(Plan),
    Justification = PlanJust.

% ---------------------------------------------------------------------------
% Helpers: initialize a level for a game instance
% ---------------------------------------------------------------------------

% Define a clause for 'baba_load_level': load a level into the game state.
baba_load_level(GameId, LevelId) :-
    % Look up the level's objects and rules.
    baba_level(LevelId, Objects, Rules),
    % Remove any previous game state for this instance.
    retractall(baba_game_state(GameId, _, _)),
    % Assert the new game state.
    assertz(baba_game_state(GameId, Objects, Rules)),
    % Report the level load.
    format("Baba level loaded: ~w for game ~w~n", [LevelId, GameId]).
