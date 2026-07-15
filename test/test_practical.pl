/*  Mentova — Practical Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/practical.pl, which exports
    mentova_practical/3 — means-ends action selection over a built-in
    action base action(Name, Preconditions, Effects, Cost). The single
    exported predicate answers four documented query forms, each returning
    a result and a glass-box justification term:
      - achieves_what(Action) -> effects(Action, Effects)
      - best_action(Goal, State) -> action(BestAction, cost(Cost))
                 (lowest-cost action whose effects meet Goal and whose
                  preconditions are all satisfied by State)
      - how_to(Goal, State) -> steps(Steps)   (backward chain to Goal)
      - what_actions -> actions(Actions)       (the whole action base)

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_practical.pl
*/

% Declare this file as a test module with no exports.
:- module(test_practical, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load memberchk/2 for the membership checks in the assertions (length/2 is a builtin).
:- use_module(library(lists), [memberchk/2]).
% Load the module under test from the library path.
:- use_module(library(practical)).

% Open the test block for the practical module.
:- begin_tests(practical).

% AC-PRACTICAL-001: achieves_what returns the action's documented effect list.
test(achieves_what_reports_effects) :-
    % Ask what the eat_food action achieves.
    mentova_practical(achieves_what(eat_food), Result, Justification),
    % The action(eat_food, [has(food)], [not_hungry], 1) fact names [not_hungry] as its effect.
    assertion(Result == effects(eat_food, [not_hungry])),
    % The justification restates the action and its effects verbatim.
    assertion(Justification == just(practical(action_effects(eat_food), effects([not_hungry])))).

% AC-PRACTICAL-002: best_action picks the sole achiever whose preconditions the state meets.
test(best_action_single_achiever) :-
    % The only action whose effects contain not_hungry is eat_food, needing has(food).
    mentova_practical(best_action(not_hungry, [has(food)]), Result, Justification),
    % With has(food) in the state, eat_food is applicable at its cost of 1.
    assertion(Result == action(eat_food, cost(1))),
    % The justification records the goal, state, chosen action, and cost.
    assertion(Justification == just(practical(means_ends(goal(not_hungry),
                                                         state([has(food)]),
                                                         best_action(eat_food),
                                                         cost(1))))).

% AC-PRACTICAL-003: best_action filters candidates by whether the state meets their preconditions.
test(best_action_filters_on_preconditions) :-
    % Two actions achieve has(transport): use_car (needs car+fuel) and use_bus (needs bus_pass).
    % With only car and fuel in the state, use_bus is inapplicable, so use_car must be chosen.
    mentova_practical(best_action(has(transport), [has(car), has(fuel)]), Result, _),
    % use_car is the applicable achiever, at its cost of 1.
    assertion(Result == action(use_car, cost(1))).

% AC-PRACTICAL-004: best_action fails when no achiever's preconditions are satisfied.
test(best_action_fails_without_means) :-
    % has(food) is achieved only by buy_food, which requires has(money).
    % An empty state satisfies no preconditions, so best_action must fail outright.
    assertion(\+ mentova_practical(best_action(has(food), []), _, _)).

% AC-PRACTICAL-005: how_to backward-chains a single applicable action into a one-step plan.
test(how_to_single_step_plan) :-
    % From a state holding has(money), buy_food alone reaches the has(food) goal.
    % Take the first plan the backward chainer produces.
    once(mentova_practical(how_to(has(food), [has(money)]), Result, Justification)),
    % The returned plan is exactly the one step buy_food.
    assertion(Result == steps([buy_food])),
    % The justification records the goal, starting state, and the derived steps.
    assertion(Justification == just(practical(backward_chain(goal(has(food)),
                                                             state([has(money)]),
                                                             steps([buy_food]))))).

% AC-PRACTICAL-006: how_to chains through a missing precondition to build a multi-step plan.
test(how_to_multi_step_backward_chain) :-
    % Reaching not_hungry from has(money) needs eat_food, whose has(food) precondition
    % is itself produced by buy_food, so the backward chain yields both steps in order.
    once(mentova_practical(how_to(not_hungry, [has(money)]), Result, _)),
    % The plan is eat_food (the goal action) followed by buy_food (its enabling step).
    assertion(Result == steps([eat_food, buy_food])).

% AC-PRACTICAL-007: what_actions enumerates the entire built-in action base with costs.
test(what_actions_lists_the_full_base) :-
    % Request the full action inventory as name-cost pairs.
    mentova_practical(what_actions, actions(Actions), Justification),
    % Measure how many actions the base defines.
    length(Actions, N),
    % The module defines thirteen actions.
    assertion(N =:= 13),
    % Spot-check that a representative action appears with its documented cost of 1.
    assertion(memberchk(eat_food-1, Actions)),
    % The buy_bus_pass action costs 2.
    assertion(memberchk(buy_bus_pass-2, Actions)),
    % The buy_shoes action costs 1.
    assertion(memberchk(buy_shoes-1, Actions)),
    % The justification carries the same list under the available_actions label.
    assertion(Justification == just(practical(available_actions, list(Actions)))).

% Close the test block for the practical module.
:- end_tests(practical).
