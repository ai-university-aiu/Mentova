/*  Mentova — ARC-AGI-3 Cross-Game Priors Test Suite  (arc3_priors)

    Behavioural PLUnit suite for src/mentova/arc3_priors.pl. The module is a
    pure reasoning layer: it abstracts the concrete, game-keyed a3_rel / a3_hazard
    facts of knowledge/arc3_games.pl into cause/effect families, named archetypes,
    game-keyed archetype/win/resource derivations, and transferable play priors.
    Every expected value below is computed by hand from the module's documented
    behaviour and the Locksmith (ls20) facts in arc3_games.pl.

    Run with every PrologAI pack plus the Mentova source on the library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
            -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_arc3_priors.pl
*/

% Declare this file as a test module with no exports.
:- module(test_arc3_priors, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(arc3_priors)).
% Load list helpers for extracting roles from the sorted prior list.
:- use_module(library(lists), [member/2]).

% Open the test block for arc3_priors.
:- begin_tests(arc3_priors).

% AC-AP-001: concrete cause verbs map to their abstract families.
test(cause_family_maps_concrete_verbs) :-
    % Stepping onto a tile is the enter_tile family.
    assertion(ap_cause_family(step_on(changer), enter_tile)),
    % Pressing a button/arrow is the button family.
    assertion(ap_cause_family(press(arrow), button)),
    % Moving into an object is the collide family.
    assertion(ap_cause_family(move_into(piece), collide)),
    % A delivery goal-condition cause is the goal_condition family.
    assertion(ap_cause_family(deliver(matching_key, target), goal_condition)).

% AC-AP-002: concrete effect verbs map to their abstract families.
test(effect_family_maps_concrete_verbs) :-
    % Winning a level is the goal_reached family.
    assertion(ap_effect_family(win(level), goal_reached)),
    % Refilling a meter is the resource_restore family.
    assertion(ap_effect_family(refill(timer), resource_restore)),
    % Shoving a block is the push family.
    assertion(ap_effect_family(shove(block), push)),
    % Losing the game is the death family.
    assertion(ap_effect_family(lose(game), death)).

% AC-AP-003: the archetype catalogue holds exactly the twelve named mechanics.
test(archetype_catalogue_has_twelve) :-
    % Collect every named archetype.
    findall(Name, ap_archetype(Name, _), Names),
    % There are twelve of them.
    assertion(length(Names, 12)),
    % The resource-refill archetype carries a non-empty prose description.
    ap_archetype(resource_refill, Desc),
    % Its description is an atom.
    assertion(atom(Desc)).

% AC-AP-004: Locksmith (ls20) exhibits exactly its five derived archetypes.
test(locksmith_exhibits_expected_archetypes) :-
    % Read the de-duplicated archetype list for the game.
    ap_game_archetypes(ls20, Archetypes),
    % ls20 has a hazard, a delivery win, a changer, a pusher, and a refill ring.
    assertion(Archetypes == [avoid_hazard, delivery_goal, property_changer, pushable_block, resource_refill]).

% AC-AP-005: Locksmith's win recipe abstracts its delivery win.
test(locksmith_win_recipe) :-
    % Collect every win recipe the game derives.
    findall(WR, ap_win_recipe(ls20, WR), Recipes),
    % ls20 is won by delivering the matching key, a goal_condition cause.
    assertion(Recipes == [win_by(goal_condition, deliver(matching_key, target))]).

% AC-AP-006: Locksmith's depleting resource is named from its timer hazard.
test(locksmith_depletes_the_timer) :-
    % The "_runs_out" suffix is stripped to name the meter.
    assertion(ap_game_resource(ls20, timer)),
    % The timer hazard is recognised as a depleting-resource family.
    assertion(ap_resource_hazard(timer_runs_out)).

% AC-AP-007: archetype priors are ranked so avoidance is consulted before refill.
test(archetype_priors_are_priority_ranked) :-
    % Hazard avoidance is the top prior at priority one hundred.
    ap_prior(avoid_hazard, HazardPriority, _),
    % Resource refill sits just below it at priority ninety.
    ap_prior(resource_refill, RefillPriority, _),
    % The avoidance priority is exactly one hundred.
    assertion(HazardPriority =:= 100),
    % The refill priority is exactly ninety.
    assertion(RefillPriority =:= 90),
    % Avoidance therefore outranks refill.
    assertion(HazardPriority > RefillPriority).

% AC-AP-008: generic role priors are de-duplicated and sorted highest-priority-first.
test(generic_priors_for_roles_sorted_descending) :-
    % Ask for the priors of a role set with a duplicate meter role.
    ap_priors_for_roles([field, meter, meter, piece], Priors),
    % Peel out just the role atoms in the returned order.
    findall(Role, member(prior(Role, _), Priors), Roles),
    % meter(95) then piece(70) then field(50), each role once.
    assertion(Roles == [meter, piece, field]).

% AC-AP-009: the stats summary counts the catalogue and derived pairs.
test(stats_summarize_the_catalogue) :-
    % Read the one-shot summary triple.
    ap_stats(stats(Archetypes, GamePairs, GenericPriors)),
    % Twelve named archetypes.
    assertion(Archetypes =:= 12),
    % Four generic role priors.
    assertion(GenericPriors =:= 4),
    % At least one (game, archetype) pair was derived from the game facts.
    assertion(GamePairs > 0).

% Close the test block for arc3_priors.
:- end_tests(arc3_priors).
