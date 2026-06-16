/*  Mentova — Rung 24: Case-Based Reasoning Module

    Solves by adapting a similar past case.
    Pass criterion: retrieved case yields correct adapted solution.

    CBR cycle: Retrieve → Reuse → Revise → Retain
*/

:- module(case_based, [
    mentova_cbr/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Case library: case(Id, Problem, Solution, Features)
% Features: list of feature=value pairs for similarity
% ---------------------------------------------------------------------------

past_case(c1, fix_flat_tyre,      change_tyre,     [problem=flat, vehicle=car,    tools=yes]).
past_case(c2, fix_flat_tyre,      call_service,    [problem=flat, vehicle=car,    tools=no]).
past_case(c3, engine_overheating, add_coolant,     [problem=hot,  vehicle=car,    coolant=low]).
past_case(c4, engine_overheating, stop_and_wait,   [problem=hot,  vehicle=car,    coolant=ok]).
past_case(c5, flat_bicycle_tyre,  patch_tube,      [problem=flat, vehicle=bicycle,tools=yes]).
past_case(c6, flat_bicycle_tyre,  replace_tube,    [problem=flat, vehicle=bicycle,tools=no]).
past_case(c7, lost_in_forest,     follow_stream,   [problem=lost, terrain=forest, compass=no]).
past_case(c8, lost_in_forest,     use_compass,     [problem=lost, terrain=forest, compass=yes]).

% ---------------------------------------------------------------------------
% Similarity: count matching features
% ---------------------------------------------------------------------------

similarity(ProbFeatures, CaseFeatures, Score) :-
    findall(1, (member(K=V, ProbFeatures), member(K=V, CaseFeatures)), Matches),
    length(Matches, Score).

% ---------------------------------------------------------------------------
% Best matching case
% ---------------------------------------------------------------------------

best_case(ProbFeatures, BestId, BestSolution, BestScore) :-
    findall(Score-Id-Sol,
            ( past_case(Id, _, Sol, CaseFeats),
              similarity(ProbFeatures, CaseFeats, Score)
            ),
            All),
    msort(All, Sorted),
    last(Sorted, BestScore-BestId-BestSolution).

last([X], X) :- !.
last([_|T], X) :- last(T, X).

% ---------------------------------------------------------------------------
% mentova_cbr(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_cbr(solve(ProbFeatures), Solution,
             just(cbr(problem(ProbFeatures),
                       retrieved(BestId, BestScore),
                       solution(Solution),
                       cycle(retrieve_reuse)))) :-
    best_case(ProbFeatures, BestId, Solution, BestScore).

mentova_cbr(retrieve(ProbFeatures), cases(Retrieved),
             just(cbr_retrieve(ProbFeatures, top3(Retrieved)))) :-
    findall(Score-Id-Sol,
            ( past_case(Id, _, Sol, CF),
              similarity(ProbFeatures, CF, Score),
              Score > 0
            ),
            All),
    msort(All, Sorted),
    reverse(Sorted, Ranked),
    ( length(Ranked, L), L >= 3 -> length(Top3, 3), append(Top3, _, Ranked) ; Top3 = Ranked ),
    Retrieved = Top3.
