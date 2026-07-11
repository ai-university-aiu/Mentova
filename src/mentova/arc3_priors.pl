/*  Mentova — ARC-AGI-3 Cross-Game Priors  (abstracted from the 25 guides)

    The 25 mentor guides in knowledge/arc3_games.pl are concrete and game-keyed:
    ls20 rings refill the timer, ka59 pieces push, su15 enemies kill. That is
    exactly right for a game we have seen. But the point of studying twenty-five
    games is to walk into the twenty-sixth already knowing how games TEND to work.
    This module reads across every a3_rel and a3_hazard fact and lifts them into a
    handful of generalizable ARCHETYPES — the recurring shapes of a mechanic —
    and the play PRIORS that follow from them. On a game we have never seen, the
    priors still apply: if perception (co_see) reports a shrinking bar, the
    resource-refill prior says "seek a collectible to top it up"; if it reports
    loose pieces next to the avatar, the pushable-block prior says "try shoving
    one".

    The abstraction is layered so nothing game-specific leaks into the general
    rules:
      - ap_cause_family/2 and ap_effect_family/2 map a concrete verb (step_on,
        refill, push, ...) to an abstract family (enter_tile, resource_restore,
        push, ...). This is the shared vocabulary.
      - ap_archetype/2 names each recurring mechanic and describes it.
      - ap_game_archetype/2 is GAME-KEYED: which archetypes a known game exhibits,
        derived from its own a3_rel/a3_hazard facts (never hard-coded).
      - ap_win_recipe/2 is GAME-KEYED: the abstracted "how this game is won".
      - ap_prior/3 and ap_generic_prior/3 are the GENERAL layer: the play advice
        an archetype (or a co_see role on an unseen game) implies. These carry no
        game id — they are meant to transfer.

    Loaded by arc3_knowledge.pl / the chat stack; queried by the Mentova solo
    player when it chooses an action, both for a known game (ap_game_archetype,
    ap_win_recipe) and for an unseen one (ap_generic_prior).
*/

% Declare this module and its cross-game prior interface.
:- module(arc3_priors, [
    % ap_cause_family/2: the abstract family of a concrete cause verb.
    ap_cause_family/2,
    % ap_effect_family/2: the abstract family of a concrete effect verb.
    ap_effect_family/2,
    % ap_archetype/2: a named recurring mechanic and its description.
    ap_archetype/2,
    % ap_game_archetype/2: which archetypes a known game exhibits (game-keyed).
    ap_game_archetype/2,
    % ap_game_archetypes/2: the de-duplicated list of a game's archetypes.
    ap_game_archetypes/2,
    % ap_win_recipe/2: the abstracted win condition of a known game (game-keyed).
    ap_win_recipe/2,
    % ap_resource_hazard/1: the depleting-resource hazard families.
    ap_resource_hazard/1,
    % ap_game_resource/2: the resource a known game depletes (game-keyed).
    ap_game_resource/2,
    % ap_prior/3: an archetype's generalizable play prior (priority, advice).
    ap_prior/3,
    % ap_generic_prior/3: a co_see role's generalizable prior on an unseen game.
    ap_generic_prior/3,
    % ap_priors_for_roles/2: the generic priors that apply to a set of roles.
    ap_priors_for_roles/2,
    % ap_stats/1: a summary of the abstracted priors, for demos and boot logs.
    ap_stats/1
]).

% The concrete game facts this module abstracts over.
:- use_module('../../knowledge/arc3_games').
% List helpers.
:- use_module(library(lists), [member/2, memberchk/2]).

% ===========================================================================
% SECTION 1 — the shared vocabulary: concrete verb -> abstract family
% ===========================================================================

% ap_cause_family(+Cause, -Family): the abstract family of a cause verb. A cause
% is how the player acts; the families are the handful of ways any game is driven.
% Stepping onto a tile.
ap_cause_family(step_on(_),        enter_tile).
% Pointing/clicking at a cell or object.
ap_cause_family(click(_),          point).
% Pressing a button/arrow/release.
ap_cause_family(press(_),          button).
% Moving the avatar into something (collision).
ap_cause_family(move_into(_),      collide).
% Touching / contacting an object.
ap_cause_family(contact(_),        collide).
% Two objects meeting.
ap_cause_family(meet(_, _),        collide).
% A cursor move that selects.
ap_cause_family(move(_),           steer).
% The passive pull of gravity.
ap_cause_family(gravity,           physics).
% A resource reaching zero (an event, not an action).
ap_cause_family(timer_zero,        resource_event).
% Every goal-condition cause (the board reaching the winning arrangement).
ap_cause_family(deliver(_, _),     goal_condition).
ap_cause_family(reach(_),          goal_condition).
ap_cause_family(match(_),          goal_condition).
ap_cause_family(arrange(_),        goal_condition).
ap_cause_family(order(_),          goal_condition).
ap_cause_family(cover(_),          goal_condition).
ap_cause_family(pair(_),           goal_condition).
ap_cause_family(assemble(_, _),    goal_condition).
ap_cause_family(align(_, _),       goal_condition).
ap_cause_family(fill(_),           goal_condition).
ap_cause_family(land(_, _),        goal_condition).
ap_cause_family(seat(_, _),        goal_condition).
ap_cause_family(reduce(_, _),      goal_condition).
ap_cause_family(merge(_),          goal_condition).
ap_cause_family(rewrite(_, _),     goal_condition).
ap_cause_family(execute(_),        goal_condition).
ap_cause_family(build(_),          goal_condition).
ap_cause_family(cast(_),           goal_condition).
ap_cause_family(reflect(_, _),     goal_condition).
ap_cause_family(delete(_),         goal_condition).

% ap_effect_family(+Effect, -Family): the abstract family of an effect verb. An
% effect is what the world does back; these families are what a caller reasons over.
% Winning the level.
ap_effect_family(win(_),                    goal_reached).
% Restoring a depleting resource.
ap_effect_family(refill(_),                 resource_restore).
ap_effect_family(refund(_),                 resource_restore).
% Cycling / changing a property to enable a match.
ap_effect_family(cycle(_),                  property_change).
ap_effect_family(change(_),                 property_change).
% Pushing a block (sokoban physics).
ap_effect_family(push(_),                   push).
ap_effect_family(shove(_),                  push).
% Selecting an object to act on next.
ap_effect_family(select(_),                 select).
% Toggling cells / barriers / instructions.
ap_effect_family(toggle(_),                 toggle).
ap_effect_family(build_or_destroy(_),       toggle).
ap_effect_family(set(_),                    toggle).
% Moving / transferring an object.
ap_effect_family(transfer(_),               relocate).
ap_effect_family(deliver(_),                relocate).
ap_effect_family(move(_),                   relocate).
ap_effect_family(remove(_),                 relocate).
% Ending or losing the game.
ap_effect_family(lose(_),                   death).
ap_effect_family(reset(_),                  setback).
% Transforming a piece's shape/colour/size.
ap_effect_family(reshape(_),                transform).
ap_effect_family(recolour(_),               transform).
ap_effect_family(resize(_),                 transform).
ap_effect_family(rotate(_),                 transform).
ap_effect_family(image(_),                  transform).
ap_effect_family(merge(_),                  transform).
ap_effect_family(connect(_),                transform).
ap_effect_family(transform(_),              transform).
% Emitting particles/paint.
ap_effect_family(pour(_),                   emit).
ap_effect_family(dispense(_),               emit).
ap_effect_family(cast(_),                   emit).
ap_effect_family(destroy(_),                emit).
ap_effect_family(teleport(_),               relocate).
ap_effect_family(pull(_),                   push).
ap_effect_family(act(_),                    toggle).
ap_effect_family(check(_),                  goal_reached).
ap_effect_family(grab_drop_or_delete(_),    select).

% ===========================================================================
% SECTION 2 — the archetypes: recurring mechanics and their descriptions
% ===========================================================================

% ap_archetype(?Name, ?Description): each recurring mechanic across the games.
ap_archetype(resource_refill,
    'A collectible restores a depleting meter (timer, budget, energy). When the meter is low, go collect one.').
ap_archetype(property_changer,
    'A tile or control cycles a property (colour, key, shape) so a piece can be made to match a target.').
ap_archetype(pushable_block,
    'Moving the avatar into a loose block shoves it — sokoban physics. Push blocks onto pads or out of the way.').
ap_archetype(select_then_place,
    'Click an object to select it, then click a destination to move or act on it. A two-click grammar.').
ap_archetype(toggle_field,
    'Clicking a cell toggles it (and sometimes its neighbours) between states, to reach a target pattern.').
ap_archetype(delivery_goal,
    'The level is won by bringing object(s) onto matching target(s): deliver, seat, land, pair, cover, assemble.').
ap_archetype(match_goal,
    'The level is won by making the board match a target pattern or image.').
ap_archetype(reach_goal,
    'The level is won by steering an avatar to a goal cell or flag.').
ap_archetype(reduce_goal,
    'The level is won by reducing or merging pieces to a target count (peg-solitaire, token-merge).').
ap_archetype(avoid_hazard,
    'Contact with a hazard object ends or damages the run. Keep the avatar off hazard cells.').
ap_archetype(program_execution,
    'Set a sequence of instructions, then execute it to transform a piece toward the target.').
ap_archetype(transform_shape,
    'Zones or walls reshape, recolour, or resize a piece as it passes; route the piece through the right ones.').

% ===========================================================================
% SECTION 3 — game-keyed: which archetypes each known game exhibits
% ===========================================================================

% ap_game_archetype(?Game, ?Archetype): a known game exhibits an archetype,
% derived from its OWN a3_rel / a3_hazard facts. Game-keyed; never hard-coded.
% A game with a refill/refund effect has the resource-refill mechanic.
ap_game_archetype(G, resource_refill) :-
    a3_rel(G, _, Effect), ap_effect_family(Effect, resource_restore).
% A game with a cycle/change effect has a property changer.
ap_game_archetype(G, property_changer) :-
    a3_rel(G, _, Effect), ap_effect_family(Effect, property_change).
% A game with a push/shove effect has pushable blocks.
ap_game_archetype(G, pushable_block) :-
    a3_rel(G, _, Effect), ap_effect_family(Effect, push).
% A game with a select effect uses the select-then-place grammar.
ap_game_archetype(G, select_then_place) :-
    a3_rel(G, _, Effect), ap_effect_family(Effect, select).
% A game with a toggle effect has a toggle field.
ap_game_archetype(G, toggle_field) :-
    a3_rel(G, _, Effect), ap_effect_family(Effect, toggle).
% A game won by delivering/seating/landing/pairing/covering/assembling.
ap_game_archetype(G, delivery_goal) :-
    a3_rel(G, Cause, win(_)),
    ( functor(Cause, F, _),
      memberchk(F, [deliver, seat, land, pair, cover, assemble, arrange]) ).
% A game won by matching a pattern/image.
ap_game_archetype(G, match_goal) :-
    a3_rel(G, Cause, win(_)), functor(Cause, match, _).
% A game won by reaching a goal cell.
ap_game_archetype(G, reach_goal) :-
    a3_rel(G, Cause, win(_)), functor(Cause, reach, _).
% A game won by reducing/merging to a target count.
ap_game_archetype(G, reduce_goal) :-
    a3_rel(G, Cause, win(_)),
    ( functor(Cause, F, _), memberchk(F, [reduce, merge]) ).
% A game with any hazard needs hazard avoidance.
ap_game_archetype(G, avoid_hazard) :-
    a3_hazard(G, _).
% A game with a program-execution effect.
ap_game_archetype(G, program_execution) :-
    a3_rel(G, execute(_), _).
% A game whose walls/zones reshape or recolour pieces.
ap_game_archetype(G, transform_shape) :-
    a3_rel(G, _, Effect), ap_effect_family(Effect, transform),
    functor(Effect, F, _), memberchk(F, [reshape, recolour, resize]).

% ap_game_archetypes(+Game, -Archetypes): the de-duplicated list for a game.
ap_game_archetypes(Game, Archetypes) :-
    % Every archetype the game exhibits, without duplicates.
    setof(A, ap_game_archetype(Game, A), Archetypes)
    % An unknown game simply has none.
    -> true ; Archetypes = [].

% ===========================================================================
% SECTION 4 — game-keyed: the abstracted win recipe and depleting resource
% ===========================================================================

% ap_win_recipe(+Game, -Recipe): the abstracted "how this game is won", as
% win_by(Family, Cause) where Family is the cause's abstract family. Game-keyed.
ap_win_recipe(Game, win_by(Family, Cause)) :-
    % The winning cause of the game.
    a3_rel(Game, Cause, win(_)),
    % Its abstract family.
    ( ap_cause_family(Cause, Family) -> true ; Family = goal_condition ).

% ap_resource_hazard(?Family): the hazard names that denote a depleting resource
% (as opposed to a contact death). These are the meters co_see should track.
ap_resource_hazard(timer_runs_out).
ap_resource_hazard(budget_runs_out).
ap_resource_hazard(energy_runs_out).
ap_resource_hazard(clock_runs_out).
ap_resource_hazard(counter_runs_out).
ap_resource_hazard(timer_wall_expires).
ap_resource_hazard(overflow).

% ap_game_resource(+Game, -Resource): the depleting resource a known game has,
% named by the meter it drains (timer, budget, energy, clock, counter). Game-keyed.
ap_game_resource(Game, Resource) :-
    % A resource-style hazard of the game.
    a3_hazard(Game, Hazard),
    ap_resource_hazard(Hazard),
    % Name the meter from the hazard: strip the "_runs_out" suffix, or map the
    % two irregular hazards by hand.
    ( atom_concat(Resource, '_runs_out', Hazard) -> true
    ; Hazard == timer_wall_expires -> Resource = timer
    ; Hazard == overflow           -> Resource = capacity
    ; Resource = Hazard ).

% ===========================================================================
% SECTION 5 — the general layer: the priors an archetype implies (transferable)
% ===========================================================================

% ap_prior(?Archetype, ?Priority, ?Advice): the generalizable play prior an
% archetype implies. Higher priority is consulted first. No game id — transferable.
ap_prior(avoid_hazard,       100,
    'Keep the avatar off hazard-coloured cells; never repeat a move that ended a run.').
ap_prior(resource_refill,     90,
    'Track every meter; when one is low, steer to a collectible/dot to refill before it empties.').
ap_prior(reach_goal,          80,
    'Identify the avatar (what moves under an action) and plan a path to the goal cell/flag.').
ap_prior(pushable_block,      75,
    'Move the avatar into a loose block to push it; aim pushes toward pads or clear lanes.').
ap_prior(delivery_goal,       75,
    'Carry each movable piece onto its matching target; solve one pairing at a time.').
ap_prior(select_then_place,   70,
    'Use the two-click grammar: click an object to select, then click its destination.').
ap_prior(property_changer,    65,
    'Use the changer tile/control to cycle a piece''s property until it matches the target.').
ap_prior(toggle_field,        60,
    'Toggle cells toward the target pattern; watch whether a click flips neighbours too.').
ap_prior(match_goal,          60,
    'Read the target pattern/image first, then transform the board to match it.').
ap_prior(reduce_goal,         55,
    'Reduce or merge pieces toward the target count; avoid moves that strand a piece.').
ap_prior(program_execution,   50,
    'Set the instruction sequence, then execute; adjust the program from the result.').
ap_prior(transform_shape,     50,
    'Route the piece through the zones/walls that reshape or recolour it toward the target.').

% ap_generic_prior(?Role, ?Priority, ?Advice): the generalizable prior a co_see
% object ROLE implies on a game we have never seen. This is how the twenty-five
% guides pay off on the twenty-sixth game: perception + these priors, no memory.
% A meter/life-bar is a resource — read it every step.
ap_generic_prior(meter,  95,
    'A bar/meter is present: read its length each step. If it shrinks it is a timer/budget/life — act before it empties and look for a collectible that refills it.').
% Single-cell dots are usually collectibles or targets — go touch one.
ap_generic_prior(dot,    80,
    'Single-cell dots are usually collectibles or targets: steer the avatar to the nearest untouched one to learn what it does.').
% Movable pieces — try pushing or selecting them.
ap_generic_prior(piece,  70,
    'Loose pieces are movable: try moving the avatar into one (push) or clicking it (select) to learn its behaviour.').
% Large fields are terrain/walls/goal-zones — map the boundary.
ap_generic_prior(field,  50,
    'A large block is terrain, a wall, or a goal-zone: note its boundary; the avatar likely cannot cross it, or must reach it.').

% ap_priors_for_roles(+Roles, -Priors): the generic priors that apply to a set of
% co_see roles, highest priority first. Roles is a list of role atoms (with dups
% allowed); the output is de-duplicated advice sorted by descending priority.
ap_priors_for_roles(Roles, Priors) :-
    % Every distinct (priority, role, advice) whose role appears in Roles.
    setof(P - prior(Role, Advice),
        ( ap_generic_prior(Role, P, Advice), memberchk(Role, Roles) ),
        Pairs)
    -> pairs_desc_(Pairs, Priors)
    ;  Priors = [].

% pairs_desc_(+KeyedPairs, -Values): drop the sort keys, highest key first.
pairs_desc_(Pairs, Values) :-
    % Sort ascending by priority.
    keysort(Pairs, Asc),
    % Reverse to descending.
    reverse(Asc, Desc),
    % Drop the keys.
    findall(V, member(_ - V, Desc), Values).

% ===========================================================================
% SECTION 6 — a summary, for demos and boot logs
% ===========================================================================

% ap_stats(-stats(Archetypes, GamePairs, GenericPriors)): a summary count.
ap_stats(stats(Archetypes, GamePairs, GenericPriors)) :-
    % How many named archetypes exist.
    aggregate_all(count, ap_archetype(_, _), Archetypes),
    % How many (game, archetype) facts were derived.
    aggregate_all(count, ap_game_archetype(_, _), GamePairs),
    % How many generic (role) priors exist.
    aggregate_all(count, ap_generic_prior(_, _, _), GenericPriors).

% Aggregation for the stats.
:- use_module(library(aggregate), [aggregate_all/3]).
% reverse/2 and findall/3 for the pair sorter.
:- use_module(library(lists), [reverse/2]).
