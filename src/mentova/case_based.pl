/*  Mentova — Rung 24: Case-Based Reasoning Module

    Solves by adapting a similar past case.
    Pass criterion: retrieved case yields correct adapted solution.

    CBR cycle: Retrieve → Reuse → Revise → Retain
*/

% Declare this file as the 'case_based' module and list its exported predicates.
:- module(case_based, [
    % Supply 'mentova_cbr/3' as the next argument to the expression above.
    mentova_cbr/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Case library: case(Id, Problem, Solution, Features)
% Features: list of feature=value pairs for similarity
% ---------------------------------------------------------------------------

% State the fact: past case(c1, fix_flat_tyre,      change_tyre,     [problem=flat, vehicle=car,    tools=yes]).
past_case(c1, fix_flat_tyre,      change_tyre,     [problem=flat, vehicle=car,    tools=yes]).
% State the fact: past case(c2, fix_flat_tyre,      call_service,    [problem=flat, vehicle=car,    tools=no]).
past_case(c2, fix_flat_tyre,      call_service,    [problem=flat, vehicle=car,    tools=no]).
% State the fact: past case(c3, engine_overheating, add_coolant,     [problem=hot,  vehicle=car,    coolant=low]).
past_case(c3, engine_overheating, add_coolant,     [problem=hot,  vehicle=car,    coolant=low]).
% State the fact: past case(c4, engine_overheating, stop_and_wait,   [problem=hot,  vehicle=car,    coolant=ok]).
past_case(c4, engine_overheating, stop_and_wait,   [problem=hot,  vehicle=car,    coolant=ok]).
% State the fact: past case(c5, flat_bicycle_tyre,  patch_tube,      [problem=flat, vehicle=bicycle,tools=yes]).
past_case(c5, flat_bicycle_tyre,  patch_tube,      [problem=flat, vehicle=bicycle,tools=yes]).
% State the fact: past case(c6, flat_bicycle_tyre,  replace_tube,    [problem=flat, vehicle=bicycle,tools=no]).
past_case(c6, flat_bicycle_tyre,  replace_tube,    [problem=flat, vehicle=bicycle,tools=no]).
% State the fact: past case(c7, lost_in_forest,     follow_stream,   [problem=lost, terrain=forest, compass=no]).
past_case(c7, lost_in_forest,     follow_stream,   [problem=lost, terrain=forest, compass=no]).
% State the fact: past case(c8, lost_in_forest,     use_compass,     [problem=lost, terrain=forest, compass=yes]).
past_case(c8, lost_in_forest,     use_compass,     [problem=lost, terrain=forest, compass=yes]).

% ---------------------------------------------------------------------------
% Similarity: count matching features
% ---------------------------------------------------------------------------

% Define a clause for 'similarity': succeed when the following conditions hold.
similarity(ProbFeatures, CaseFeatures, Score) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(1, (member(K=V, ProbFeatures), member(K=V, CaseFeatures)), Matches),
    % Unify 'Score' with the number of elements in list 'Matches'.
    length(Matches, Score).

% ---------------------------------------------------------------------------
% Best matching case
% ---------------------------------------------------------------------------

% Define a clause for 'best case': succeed when the following conditions hold.
best_case(ProbFeatures, BestId, BestSolution, BestScore) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Score-Id-Sol,
            % Continue the multi-line expression started above.
            ( past_case(Id, _, Sol, CaseFeats),
              % Continue the multi-line expression started above.
              similarity(ProbFeatures, CaseFeats, Score)
            % Close the expression opened above.
            ),
            % Supply 'All' as the next argument to the expression above.
            All),
    % Sort list 'All' into 'Sorted', keeping duplicates.
    msort(All, Sorted),
    % Unify the second argument with the last element of list 'Sorted'.
    last(Sorted, BestScore-BestId-BestSolution).

% Define a clause for 'last': succeed when the following conditions hold.
last([X], X) :- !.
% Define a clause for 'last': succeed when the following conditions hold.
last([_|T], X) :- last(T, X).

% ---------------------------------------------------------------------------
% mentova_cbr(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova cbr' with the arguments listed below.
mentova_cbr(solve(ProbFeatures), Solution,
             % Continue the multi-line expression started above.
             just(cbr(problem(ProbFeatures),
                       % Continue the multi-line expression started above.
                       retrieved(BestId, BestScore),
                       % Continue the multi-line expression started above.
                       solution(Solution),
                       % Continue the multi-line expression started above.
                       cycle(retrieve_reuse)))) :-
    % State the fact: best case(ProbFeatures, BestId, Solution, BestScore).
    best_case(ProbFeatures, BestId, Solution, BestScore).

% State a fact for 'mentova cbr' with the arguments listed below.
mentova_cbr(retrieve(ProbFeatures), cases(Retrieved),
             % Continue the multi-line expression started above.
             just(cbr_retrieve(ProbFeatures, top3(Retrieved)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Score-Id-Sol,
            % Continue the multi-line expression started above.
            ( past_case(Id, _, Sol, CF),
              % Continue the multi-line expression started above.
              similarity(ProbFeatures, CF, Score),
              % Continue the multi-line expression started above.
              Score > 0
            % Close the expression opened above.
            ),
            % Supply 'All' as the next argument to the expression above.
            All),
    % Sort list 'All' into 'Sorted', keeping duplicates.
    msort(All, Sorted),
    % State a fact for 'reverse' with the arguments listed below.
    reverse(Sorted, Ranked),
    % Check that '( length(Ranked, L), L' is greater than or equal to '3 -> length(Top3, 3), append(Top3, _, Ranked) ; Top3 = Ranked )'.
    ( length(Ranked, L), L >= 3 -> length(Top3, 3), append(Top3, _, Ranked) ; Top3 = Ranked ),
    % Check that 'Retrieved' is unifiable with 'Top3'.
    Retrieved = Top3.
