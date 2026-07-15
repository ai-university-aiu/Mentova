/*  Mentova — Case-Based Reasoning Test Suite  (case_based)

    Genuine PLUnit coverage for src/mentova/case_based.pl, the Rung 24
    case-based reasoning module. The module is pure (its case library is
    compiled-in facts, so no lattice, server, or asserted state is needed):
    mentova_cbr/3 has two modes — solve(Features) adapts the single most
    similar past case, and retrieve(Features) returns the top-three ranked
    matches. Every expected value below is computed by hand from the eight
    case(Id, Problem, Solution, Features) facts and the feature-match
    similarity score, then asserted exactly.

    Run with the full library path (every PrologAI pack plus the Mentova src):
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" test/test_case_based.pl
*/

% Declare this file as a test module with no exports.
:- module(test_case_based, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(case_based)).

% Open the test block for case_based.
:- begin_tests(case_based).

% CBR-001: solve a flat car tyre with tools — the exact-match case wins.
test(solve_flat_car_with_tools) :-
    % Pose the query whose three features exactly match past case c1.
    mentova_cbr(solve([problem=flat, vehicle=car, tools=yes]), Solution, Just),
    % c1's solution change_tyre is retrieved and reused verbatim.
    assertion(Solution == change_tyre),
    % The justification names c1, its perfect similarity score of three, and the CBR cycle.
    assertion(Just == just(cbr(problem([problem=flat, vehicle=car, tools=yes]),
                               retrieved(c1, 3),
                               solution(change_tyre),
                               cycle(retrieve_reuse)))).

% CBR-002: a flat bicycle without tools adapts the closest bicycle case, not a car case.
test(solve_flat_bicycle_no_tools) :-
    % Pose a query matching past case c6 on all three features.
    mentova_cbr(solve([problem=flat, vehicle=bicycle, tools=no]), Solution, _),
    % c6's solution replace_tube is chosen over any car-tyre case.
    assertion(Solution == replace_tube).

% CBR-003: a lost hiker with a compass picks the compass case over the stream case.
test(solve_lost_with_compass) :-
    % Pose a query matching past case c8 on all three features.
    mentova_cbr(solve([problem=lost, terrain=forest, compass=yes]), Solution, BestScore),
    % c8's solution use_compass beats c7 (which shares only two features).
    assertion(Solution == use_compass),
    % The justification records the winning similarity score of three.
    assertion(BestScore == just(cbr(problem([problem=lost, terrain=forest, compass=yes]),
                                     retrieved(c8, 3),
                                     solution(use_compass),
                                     cycle(retrieve_reuse)))).

% CBR-004: retrieve returns exactly the top three ranked cases, best first, ties broken by case id.
test(retrieve_top_three_ranked) :-
    % Ask for the ranked retrieval for the flat-car-with-tools query.
    mentova_cbr(retrieve([problem=flat, vehicle=car, tools=yes]), cases(Retrieved), _),
    % The result is capped at three cases, ordered by descending score.
    assertion(Retrieved == [3-c1-change_tyre, 2-c5-patch_tube, 2-c2-call_service]),
    % Exactly three cases are returned when four or more scored above zero.
    assertion(length(Retrieved, 3)).

% CBR-005: retrieve returns fewer than three when fewer than three cases score above zero.
test(retrieve_fewer_than_three) :-
    % Ask for the ranked retrieval for the lost-in-forest-no-compass query.
    mentova_cbr(retrieve([problem=lost, terrain=forest, compass=no]), cases(Retrieved), Just),
    % Only c7 (score three) and c8 (score two) match; zero-score cases are excluded.
    assertion(Retrieved == [3-c7-follow_stream, 2-c8-use_compass]),
    % The justification wraps the same top-list under cbr_retrieve/2.
    assertion(Just == just(cbr_retrieve([problem=lost, terrain=forest, compass=no],
                                        top3([3-c7-follow_stream, 2-c8-use_compass])))).

% CBR-006: solve is deterministic — it commits to a single best case per query.
test(solve_is_deterministic) :-
    % Collect every solution solve offers for the flat-car query.
    findall(S, mentova_cbr(solve([problem=flat, vehicle=car, tools=yes]), S, _), Solutions),
    % There is exactly one, the unambiguous best match.
    assertion(Solutions == [change_tyre]).

% Close the test block for case_based.
:- end_tests(case_based).
