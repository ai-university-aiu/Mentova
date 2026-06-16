/*  Mentova — Rung 38: Practical Reasoning Module

    Selects the best action to achieve a goal given available means.
    Implements means-ends analysis: find actions that reduce the gap
    between current state and goal state.
    Pass criterion: given a goal and a current state, return the best
    action sequence with means-ends justification.
*/

:- module(practical, [
    mentova_practical/3
]).

:- use_module(library(lists), [member/2, subtract/3]).

% ---------------------------------------------------------------------------
% Action base: action(Name, Preconditions, Effects, Cost)
% ---------------------------------------------------------------------------

action(eat_food,         [has(food)],                [not_hungry],          1).
action(buy_food,         [has(money)],               [has(food)],           2).
action(earn_money,       [has(job)],                 [has(money)],          3).
action(find_job,         [has(cv)],                  [has(job)],            4).
action(write_cv,         [has(skills)],              [has(cv)],             2).

action(travel_to_work,   [has(transport)],           [at(work)],            1).
action(use_car,          [has(car), has(fuel)],      [has(transport)],      1).
action(use_bus,          [has(bus_pass)],             [has(transport)],      1).
action(buy_bus_pass,     [has(money)],               [has(bus_pass)],       2).

action(study,            [has(book)],                [has(skills)],         3).
action(buy_book,         [has(money)],               [has(book)],           1).

action(get_fit,          [has(running_shoes)],       [is(fit)],             2).
action(buy_shoes,        [has(money)],               [has(running_shoes)],  1).

% ---------------------------------------------------------------------------
% Means-ends: find action that achieves a goal effect
% ---------------------------------------------------------------------------

achieves(ActionName, Effect) :-
    action(ActionName, _, Effects, _),
    member(Effect, Effects).

% Simple backward chain: find sequence from current state to goal
% Returns list of steps needed
plan_backward(State, Goal, [], _Visited) :-
    member(Goal, State), !.

plan_backward(State, Goal, [Action|Rest], Visited) :-
    \+ member(Goal, State),
    achieves(Action, Goal),
    \+ member(Action, Visited),
    action(Action, Pre, _, _),
    subtract(Pre, State, Missing),
    Missing \= [],
    member(SubGoal, Missing),
    plan_backward(State, SubGoal, Rest, [Action|Visited]).

plan_backward(State, Goal, [Action], _Visited) :-
    \+ member(Goal, State),
    achieves(Action, Goal),
    action(Action, Pre, _, _),
    subtract(Pre, State, []).

% ---------------------------------------------------------------------------
% Action selection: pick lowest-cost action that achieves the goal
% ---------------------------------------------------------------------------

best_action(Goal, State, BestAction, Cost) :-
    findall(C-A, (achieves(A, Goal),
                  action(A, Pre, _, C),
                  subtract(Pre, State, [])),
            Pairs),
    Pairs \= [],
    msort(Pairs, [Cost-BestAction|_]).

% ---------------------------------------------------------------------------
% mentova_practical(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_practical(best_action(Goal, State), action(BestAction, cost(Cost)),
                  just(practical(means_ends(goal(Goal), state(State),
                                             best_action(BestAction),
                                             cost(Cost))))) :-
    best_action(Goal, State, BestAction, Cost).

mentova_practical(achieves_what(Action), effects(Action, Effects),
                  just(practical(action_effects(Action), effects(Effects)))) :-
    action(Action, _, Effects, _).

mentova_practical(how_to(Goal, State), steps(Steps),
                  just(practical(backward_chain(goal(Goal),
                                                state(State),
                                                steps(Steps))))) :-
    plan_backward(State, Goal, Steps, []).

mentova_practical(what_actions, actions(Actions),
                  just(practical(available_actions, list(Actions)))) :-
    findall(A-C, action(A, _, _, C), Actions).
