/*  Mentova — Rung 29: Heuristic Reasoning Module

    Reaches a good-enough answer quickly, within a budget.
    Pass criterion: heuristic answer is within bound under a budget.

    Implements:
      - Greedy search with a budget (max steps)
      - A* heuristic estimate
      - Satisficing: first answer within tolerance
*/

:- module(heuristic, [
    mentova_heuristic/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Problem: route from A to B on a small map
% edge(From, To, Cost)
% ---------------------------------------------------------------------------

edge(a, b, 1).
edge(a, c, 4).
edge(b, c, 2).
edge(b, d, 5).
edge(c, d, 1).
edge(d, e, 3).
edge(c, e, 6).

% Heuristic estimate: straight-line distance to goal (hand-coded)
h_estimate(a, e, 6).
h_estimate(b, e, 5).
h_estimate(c, e, 4).
h_estimate(d, e, 3).
h_estimate(e, e, 0).

% ---------------------------------------------------------------------------
% Greedy best-first search (budget = max nodes expanded)
% ---------------------------------------------------------------------------

greedy_search(Start, Goal, Budget, Path, Cost) :-
    greedy_([(0, [Start])], Goal, Budget, RevPath, Cost),
    reverse(RevPath, Path).

greedy_([(_, [Goal|Rest])|_], Goal, _, [Goal|Rest], 0) :- !.
greedy_(_, _, 0, [], infinity) :- !.
greedy_([(_, [H|Path])|Open], Goal, Budget, FinalPath, TotalCost) :-
    Budget > 0,
    findall(H2-Cost2, edge(H, H2, Cost2), Edges),
    expand_greedy(Edges, Goal, [H|Path], NewNodes),
    append(Open, NewNodes, Open2),
    msort(Open2, Open3),
    Budget2 is Budget - 1,
    greedy_(Open3, Goal, Budget2, FinalPath, TotalCost).

expand_greedy([], _, _, []).
expand_greedy([Next-_|Rest], Goal, Path, Nodes) :-
    ( member(Next, Path)
    ->  expand_greedy(Rest, Goal, Path, Nodes)
    ;   h_estimate(Next, Goal, H),
        expand_greedy(Rest, Goal, Path, RestNodes),
        Nodes = [(H, [Next|Path])|RestNodes]
    ).

% ---------------------------------------------------------------------------
% Satisficing: first solution within tolerance of optimal
% ---------------------------------------------------------------------------

% Exact shortest path for comparison
shortest_path(Start, Goal, Path, Cost) :-
    shortest_([(0, 0, [Start])], Goal, Path, Cost).

shortest_([(_, Cost, [Goal|R])|_], Goal, Path, Cost) :-
    !,
    reverse([Goal|R], Path).
shortest_([(_, CostSoFar, [H|Path])|Open], Goal, FinalPath, FinalCost) :-
    findall(FCost-NewCost-[N,H|Path],
            ( edge(H, N, EC), \+ member(N, [H|Path]),
              NewCost is CostSoFar + EC,
              h_estimate(N, Goal, H2),
              FCost is NewCost + H2
            ),
            Expansions),
    append(Open, Expansions, Open2),
    msort(Open2, Open3),
    shortest_(Open3, Goal, FinalPath, FinalCost).

% ---------------------------------------------------------------------------
% mentova_heuristic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_heuristic(greedy(Start, Goal, Budget), result(Path, within_budget),
                   just(heuristic_search(greedy, start(Start), goal(Goal),
                                          budget(Budget), path(Path)))) :-
    greedy_search(Start, Goal, Budget, Path, _).

mentova_heuristic(within_bound(Start, Goal, Tolerance), result(Path, Cost, bounded(yes)),
                   just(heuristic(start(Start), goal(Goal),
                                   tolerance(Tolerance), path(Path), cost(Cost)))) :-
    shortest_path(Start, Goal, Path, Cost),
    ( Cost =< Tolerance -> true ; fail ).

mentova_heuristic(satisfice(Start, Goal), result(Path, cost(Cost), good_enough),
                   just(satisficing(Start, Goal, path(Path), cost(Cost)))) :-
    shortest_path(Start, Goal, Path, Cost).

mentova_heuristic(h_estimate(Node, Goal), estimate(H),
                   just(heuristic_estimate(Node, Goal, H))) :-
    h_estimate(Node, Goal, H).
