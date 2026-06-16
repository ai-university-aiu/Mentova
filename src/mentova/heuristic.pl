/*  Mentova — Rung 29: Heuristic Reasoning Module

    Reaches a good-enough answer quickly, within a budget.
    Pass criterion: heuristic answer is within bound under a budget.

    Implements:
      - Greedy search with a budget (max steps)
      - A* heuristic estimate
      - Satisficing: first answer within tolerance
*/

% Declare this file as the 'heuristic' module and list its exported predicates.
:- module(heuristic, [
    % Supply 'mentova_heuristic/3' as the next argument to the expression above.
    mentova_heuristic/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Problem: route from A to B on a small map
% edge(From, To, Cost)
% ---------------------------------------------------------------------------

% State the fact: edge(a, b, 1).
edge(a, b, 1).
% State the fact: edge(a, c, 4).
edge(a, c, 4).
% State the fact: edge(b, c, 2).
edge(b, c, 2).
% State the fact: edge(b, d, 5).
edge(b, d, 5).
% State the fact: edge(c, d, 1).
edge(c, d, 1).
% State the fact: edge(d, e, 3).
edge(d, e, 3).
% State the fact: edge(c, e, 6).
edge(c, e, 6).

% Heuristic estimate: straight-line distance to goal (hand-coded)
% State the fact: h estimate(a, e, 6).
h_estimate(a, e, 6).
% State the fact: h estimate(b, e, 5).
h_estimate(b, e, 5).
% State the fact: h estimate(c, e, 4).
h_estimate(c, e, 4).
% State the fact: h estimate(d, e, 3).
h_estimate(d, e, 3).
% State the fact: h estimate(e, e, 0).
h_estimate(e, e, 0).

% ---------------------------------------------------------------------------
% Greedy best-first search (budget = max nodes expanded)
% ---------------------------------------------------------------------------

% Define a clause for 'greedy search': succeed when the following conditions hold.
greedy_search(Start, Goal, Budget, Path, Cost) :-
    % State a fact for 'greedy ' with the arguments listed below.
    greedy_([(0, [Start])], Goal, Budget, RevPath, Cost),
    % State the fact: reverse(RevPath, Path).
    reverse(RevPath, Path).

% Define a clause for 'greedy ': succeed when the following conditions hold.
greedy_([(_, [Goal|Rest])|_], Goal, _, [Goal|Rest], 0) :- !.
% Define a clause for 'greedy ': succeed when the following conditions hold.
greedy_(_, _, 0, [], infinity) :- !.
% Define a clause for 'greedy ': succeed when the following conditions hold.
greedy_([(_, [H|Path])|Open], Goal, Budget, FinalPath, TotalCost) :-
    % Check that 'Budget' is greater than '0'.
    Budget > 0,
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(H2-Cost2, edge(H, H2, Cost2), Edges),
    % State a fact for 'expand greedy' with the arguments listed below.
    expand_greedy(Edges, Goal, [H|Path], NewNodes),
    % Unify the third argument with the concatenation of the first two lists.
    append(Open, NewNodes, Open2),
    % Sort list 'Open2' into 'Open3', keeping duplicates.
    msort(Open2, Open3),
    % Evaluate the arithmetic expression 'Budget - 1' and bind the result to 'Budget2'.
    Budget2 is Budget - 1,
    % State the fact: greedy (Open3, Goal, Budget2, FinalPath, TotalCost).
    greedy_(Open3, Goal, Budget2, FinalPath, TotalCost).

% State the fact: expand greedy([], _, _, []).
expand_greedy([], _, _, []).
% Define a clause for 'expand greedy': succeed when the following conditions hold.
expand_greedy([Next-_|Rest], Goal, Path, Nodes) :-
    % Execute: ( member(Next, Path).
    ( member(Next, Path)
    % If the condition above succeeded, perform the following action.
    ->  expand_greedy(Rest, Goal, Path, Nodes)
    % Otherwise (else branch), perform the following action.
    ;   h_estimate(Next, Goal, H),
        % Continue the multi-line expression started above.
        expand_greedy(Rest, Goal, Path, RestNodes),
        % Continue the multi-line expression started above.
        Nodes = [(H, [Next|Path])|RestNodes]
    % Close the expression opened above.
    ).

% ---------------------------------------------------------------------------
% Satisficing: first solution within tolerance of optimal
% ---------------------------------------------------------------------------

% Exact shortest path for comparison
% Define a clause for 'shortest path': succeed when the following conditions hold.
shortest_path(Start, Goal, Path, Cost) :-
    % State the fact: shortest ([(0, 0, [Start])], Goal, Path, Cost).
    shortest_([(0, 0, [Start])], Goal, Path, Cost).

% Define a clause for 'shortest ': succeed when the following conditions hold.
shortest_([(_, Cost, [Goal|R])|_], Goal, Path, Cost) :-
    % Commit to this clause — discard all remaining choice points (cut).
    !,
    % State the fact: reverse([Goal|R], Path).
    reverse([Goal|R], Path).
% Define a clause for 'shortest ': succeed when the following conditions hold.
shortest_([(_, CostSoFar, [H|Path])|Open], Goal, FinalPath, FinalCost) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(FCost-NewCost-[N,H|Path],
            % Continue the multi-line expression started above.
            ( edge(H, N, EC), \+ member(N, [H|Path]),
              % Continue the multi-line expression started above.
              NewCost is CostSoFar + EC,
              % Continue the multi-line expression started above.
              h_estimate(N, Goal, H2),
              % Continue the multi-line expression started above.
              FCost is NewCost + H2
            % Close the expression opened above.
            ),
            % Supply 'Expansions' as the next argument to the expression above.
            Expansions),
    % Unify the third argument with the concatenation of the first two lists.
    append(Open, Expansions, Open2),
    % Sort list 'Open2' into 'Open3', keeping duplicates.
    msort(Open2, Open3),
    % State the fact: shortest (Open3, Goal, FinalPath, FinalCost).
    shortest_(Open3, Goal, FinalPath, FinalCost).

% ---------------------------------------------------------------------------
% mentova_heuristic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova heuristic' with the arguments listed below.
mentova_heuristic(greedy(Start, Goal, Budget), result(Path, within_budget),
                   % Continue the multi-line expression started above.
                   just(heuristic_search(greedy, start(Start), goal(Goal),
                                          % Continue the multi-line expression started above.
                                          budget(Budget), path(Path)))) :-
    % State the fact: greedy search(Start, Goal, Budget, Path, _).
    greedy_search(Start, Goal, Budget, Path, _).

% State a fact for 'mentova heuristic' with the arguments listed below.
mentova_heuristic(within_bound(Start, Goal, Tolerance), result(Path, Cost, bounded(yes)),
                   % Continue the multi-line expression started above.
                   just(heuristic(start(Start), goal(Goal),
                                   % Continue the multi-line expression started above.
                                   tolerance(Tolerance), path(Path), cost(Cost)))) :-
    % State a fact for 'shortest path' with the arguments listed below.
    shortest_path(Start, Goal, Path, Cost),
    % Check that '( Cost' is less than or equal to 'Tolerance -> true ; fail )'.
    ( Cost =< Tolerance -> true ; fail ).

% State a fact for 'mentova heuristic' with the arguments listed below.
mentova_heuristic(satisfice(Start, Goal), result(Path, cost(Cost), good_enough),
                   % Continue the multi-line expression started above.
                   just(satisficing(Start, Goal, path(Path), cost(Cost)))) :-
    % State the fact: shortest path(Start, Goal, Path, Cost).
    shortest_path(Start, Goal, Path, Cost).

% State a fact for 'mentova heuristic' with the arguments listed below.
mentova_heuristic(h_estimate(Node, Goal), estimate(H),
                   % Continue the multi-line expression started above.
                   just(heuristic_estimate(Node, Goal, H))) :-
    % State the fact: h estimate(Node, Goal, H).
    h_estimate(Node, Goal, H).
