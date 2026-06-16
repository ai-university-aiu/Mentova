/*  Mentova — Rung 38: Practical Reasoning Module

    Selects the best action to achieve a goal given available means.
    Implements means-ends analysis: find actions that reduce the gap
    between current state and goal state.
    Pass criterion: given a goal and a current state, return the best
    action sequence with means-ends justification.
*/

% Declare this file as the 'practical' module and list its exported predicates.
:- module(practical, [
    % Supply 'mentova_practical/3' as the next argument to the expression above.
    mentova_practical/3
% Close the expression opened above.
]).

% Import [member/2, subtract/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, subtract/3]).

% ---------------------------------------------------------------------------
% Action base: action(Name, Preconditions, Effects, Cost)
% ---------------------------------------------------------------------------

% State the fact: action(eat_food,         [has(food)],                [not_hungry],          1).
action(eat_food,         [has(food)],                [not_hungry],          1).
% State the fact: action(buy_food,         [has(money)],               [has(food)],           2).
action(buy_food,         [has(money)],               [has(food)],           2).
% State the fact: action(earn_money,       [has(job)],                 [has(money)],          3).
action(earn_money,       [has(job)],                 [has(money)],          3).
% State the fact: action(find_job,         [has(cv)],                  [has(job)],            4).
action(find_job,         [has(cv)],                  [has(job)],            4).
% State the fact: action(write_cv,         [has(skills)],              [has(cv)],             2).
action(write_cv,         [has(skills)],              [has(cv)],             2).

% State the fact: action(travel_to_work,   [has(transport)],           [at(work)],            1).
action(travel_to_work,   [has(transport)],           [at(work)],            1).
% State the fact: action(use_car,          [has(car), has(fuel)],      [has(transport)],      1).
action(use_car,          [has(car), has(fuel)],      [has(transport)],      1).
% State the fact: action(use_bus,          [has(bus_pass)],             [has(transport)],      1).
action(use_bus,          [has(bus_pass)],             [has(transport)],      1).
% State the fact: action(buy_bus_pass,     [has(money)],               [has(bus_pass)],       2).
action(buy_bus_pass,     [has(money)],               [has(bus_pass)],       2).

% State the fact: action(study,            [has(book)],                [has(skills)],         3).
action(study,            [has(book)],                [has(skills)],         3).
% State the fact: action(buy_book,         [has(money)],               [has(book)],           1).
action(buy_book,         [has(money)],               [has(book)],           1).

% State the fact: action(get_fit,          [has(running_shoes)],       [is(fit)],             2).
action(get_fit,          [has(running_shoes)],       [is(fit)],             2).
% State the fact: action(buy_shoes,        [has(money)],               [has(running_shoes)],  1).
action(buy_shoes,        [has(money)],               [has(running_shoes)],  1).

% ---------------------------------------------------------------------------
% Means-ends: find action that achieves a goal effect
% ---------------------------------------------------------------------------

% Define a clause for 'achieves': succeed when the following conditions hold.
achieves(ActionName, Effect) :-
    % State a fact for 'action' with the arguments listed below.
    action(ActionName, _, Effects, _),
    % Succeed for each element 'Effect' that is a member of the list.
    member(Effect, Effects).

% Simple backward chain: find sequence from current state to goal
% Returns list of steps needed
% Define a clause for 'plan backward': succeed when the following conditions hold.
plan_backward(State, Goal, [], _Visited) :-
    % Succeed for each element 'Goal' that is a member of the list.
    member(Goal, State), !.

% Define a clause for 'plan backward': succeed when the following conditions hold.
plan_backward(State, Goal, [Action|Rest], Visited) :-
    % Succeed only if 'member(Goal, State' cannot be proved (negation as failure).
    \+ member(Goal, State),
    % State a fact for 'achieves' with the arguments listed below.
    achieves(Action, Goal),
    % Succeed only if 'member(Action, Visited' cannot be proved (negation as failure).
    \+ member(Action, Visited),
    % State a fact for 'action' with the arguments listed below.
    action(Action, Pre, _, _),
    % State a fact for 'subtract' with the arguments listed below.
    subtract(Pre, State, Missing),
    % Check that 'Missing' is not unifiable with '[]'.
    Missing \= [],
    % Succeed for each element 'SubGoal' that is a member of the list.
    member(SubGoal, Missing),
    % State the fact: plan backward(State, SubGoal, Rest, [Action|Visited]).
    plan_backward(State, SubGoal, Rest, [Action|Visited]).

% Define a clause for 'plan backward': succeed when the following conditions hold.
plan_backward(State, Goal, [Action], _Visited) :-
    % Succeed only if 'member(Goal, State' cannot be proved (negation as failure).
    \+ member(Goal, State),
    % State a fact for 'achieves' with the arguments listed below.
    achieves(Action, Goal),
    % State a fact for 'action' with the arguments listed below.
    action(Action, Pre, _, _),
    % State the fact: subtract(Pre, State, []).
    subtract(Pre, State, []).

% ---------------------------------------------------------------------------
% Action selection: pick lowest-cost action that achieves the goal
% ---------------------------------------------------------------------------

% Define a clause for 'best action': succeed when the following conditions hold.
best_action(Goal, State, BestAction, Cost) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(C-A, (achieves(A, Goal),
                  % Continue the multi-line expression started above.
                  action(A, Pre, _, C),
                  % Continue the multi-line expression started above.
                  subtract(Pre, State, [])),
            % Supply 'Pairs' as the next argument to the expression above.
            Pairs),
    % Check that 'Pairs' is not unifiable with '[]'.
    Pairs \= [],
    % State the fact: msort(Pairs, [Cost-BestAction|_]).
    msort(Pairs, [Cost-BestAction|_]).

% ---------------------------------------------------------------------------
% mentova_practical(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova practical' with the arguments listed below.
mentova_practical(best_action(Goal, State), action(BestAction, cost(Cost)),
                  % Continue the multi-line expression started above.
                  just(practical(means_ends(goal(Goal), state(State),
                                             % Continue the multi-line expression started above.
                                             best_action(BestAction),
                                             % Continue the multi-line expression started above.
                                             cost(Cost))))) :-
    % State the fact: best action(Goal, State, BestAction, Cost).
    best_action(Goal, State, BestAction, Cost).

% State a fact for 'mentova practical' with the arguments listed below.
mentova_practical(achieves_what(Action), effects(Action, Effects),
                  % Continue the multi-line expression started above.
                  just(practical(action_effects(Action), effects(Effects)))) :-
    % State the fact: action(Action, _, Effects, _).
    action(Action, _, Effects, _).

% State a fact for 'mentova practical' with the arguments listed below.
mentova_practical(how_to(Goal, State), steps(Steps),
                  % Continue the multi-line expression started above.
                  just(practical(backward_chain(goal(Goal),
                                                % Continue the multi-line expression started above.
                                                state(State),
                                                % Continue the multi-line expression started above.
                                                steps(Steps))))) :-
    % State the fact: plan backward(State, Goal, Steps, []).
    plan_backward(State, Goal, Steps, []).

% State a fact for 'mentova practical' with the arguments listed below.
mentova_practical(what_actions, actions(Actions),
                  % Continue the multi-line expression started above.
                  just(practical(available_actions, list(Actions)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(A-C, action(A, _, _, C), Actions).
