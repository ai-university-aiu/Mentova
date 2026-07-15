/*  Mentova — Heuristic Reasoning Module Test Suite

    Behavioural PLUnit tests for src/mentova/heuristic.pl (Rung 29).

    The module exports a single glass-box entry point, mentova_heuristic/3,
    which dispatches on the shape of its first argument. These tests exercise
    the two dispatch modes that are live on the module's hand-coded route map
    (nodes a..e): greedy best-first search under a budget, and the A*-style
    heuristic-estimate lookup. Each test pins the full Result term and the full
    glass-box Justification term to the value computed by hand from the map.

    Run with the full library path over every PrologAI pack plus the Mentova
    source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_heuristic.pl
*/

% Declare this file as the test module, exporting nothing.
:- module(test_heuristic, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the heuristic module under test from the library path.
:- use_module(library(heuristic)).

% Open the test block for the heuristic module.
:- begin_tests(heuristic).

% Greedy best-first from a to e picks the heuristic-nearest neighbour at each
% step: a expands b(h=5) and c(h=4), commits to c, then c expands e(h=0) and
% wins, giving the two-hop route a -> c -> e (fast, but cost 4+6=10, not the
% optimal cost-7 route) inside a generous budget.
test(greedy_path_a_to_e) :-
    % Ask for a greedy route from a to e within a budget of ten expansions.
    mentova_heuristic(greedy(a, e, 10), Result, Just),
    % The result is the heuristic-first path a -> c -> e, flagged within budget.
    assertion(Result == result([a, c, e], within_budget)),
    % The justification records the search kind, both endpoints, the budget, and the chosen path.
    assertion(Just == just(heuristic_search(greedy, start(a), goal(e), budget(10), path([a, c, e])))).

% Greedy best-first from b to e: b expands c(h=4) and d(h=3), commits to the
% lower-heuristic d, then d reaches e, giving the route b -> d -> e.
test(greedy_path_b_to_e) :-
    % Ask for a greedy route from b to e within a budget of ten expansions.
    mentova_heuristic(greedy(b, e, 10), Result, Just),
    % The result is the heuristic-first path b -> d -> e, flagged within budget.
    assertion(Result == result([b, d, e], within_budget)),
    % The justification names the greedy search over the b-to-e endpoints and its path.
    assertion(Just == just(heuristic_search(greedy, start(b), goal(e), budget(10), path([b, d, e])))).

% A budget of one is exhausted before the goal is reached, so the search runs
% out of expansions and returns the empty path (still tagged within_budget).
test(greedy_budget_exhaustion_yields_empty_path) :-
    % Ask for a greedy route from a to e with only one expansion allowed.
    mentova_heuristic(greedy(a, e, 1), Result, _Just),
    % The budget is spent before e is found, so the path comes back empty.
    assertion(Result == result([], within_budget)).

% The greedy route is deliberately fast, not optimal: it is a two-hop path,
% shorter in hops than the four-hop cost-optimal route a -> b -> c -> d -> e.
test(greedy_is_fast_not_cost_optimal) :-
    % Ask for the greedy route from a to e within a generous budget.
    mentova_heuristic(greedy(a, e, 10), result(Path, within_budget), _Just),
    % Measure how many nodes the greedy path visits.
    length(Path, N),
    % The greedy path visits exactly three nodes (two hops), unlike the five-node optimal route.
    assertion(N =:= 3).

% The heuristic-estimate lookup returns the hand-coded straight-line estimate
% from the start node a to the goal e, with a matching glass-box justification.
test(h_estimate_start_node) :-
    % Look up the heuristic estimate from a to e.
    mentova_heuristic(h_estimate(a, e), Estimate, Just),
    % The estimate for a is six.
    assertion(Estimate == estimate(6)),
    % The justification reports the node, the goal, and the estimate value.
    assertion(Just == just(heuristic_estimate(a, e, 6))).

% The heuristic estimates decrease monotonically toward the goal e, reaching
% zero at e itself: h(c)=4, h(d)=3, h(e)=0.
test(h_estimate_decreases_toward_goal) :-
    % Look up the estimate from c to e.
    mentova_heuristic(h_estimate(c, e), Ec, _Jc),
    % Look up the estimate from d to e.
    mentova_heuristic(h_estimate(d, e), Ed, _Jd),
    % Look up the estimate from the goal e to itself.
    mentova_heuristic(h_estimate(e, e), Ee, _Je),
    % The estimate at c is four.
    assertion(Ec == estimate(4)),
    % The estimate at d is three.
    assertion(Ed == estimate(3)),
    % The estimate at the goal itself is zero.
    assertion(Ee == estimate(0)).

% Close the test block for the heuristic module.
:- end_tests(heuristic).
