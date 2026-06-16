/*  Mentova — Rung 30: Critical Reasoning Module

    Evaluates a claim's support.
    Pass criterion: weakly-supported claim flagged with reasons.

    A claim is assessed for:
      - Evidence strength (how much evidence?)
      - Source quality (is the source reliable?)
      - Logical validity (does evidence support conclusion?)
      - Counter-evidence (is there opposing evidence?)
*/

% Declare this file as the 'critical' module and list its exported predicates.
:- module(critical, [
    % Supply 'mentova_critical/3' as the next argument to the expression above.
    mentova_critical/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Evidence base: evidence(ClaimId, Type, Weight)
%   Type: supporting | opposing | neutral
%   Weight: 0.0 - 1.0
% ---------------------------------------------------------------------------

% Well-supported claim: canaries are yellow
% State a fact for 'evidence for' with the arguments listed below.
evidence_for(canary_yellow, e1, supporting, 0.94).  % 94% of observations
% State a fact for 'evidence for' with the arguments listed below.
evidence_for(canary_yellow, e2, supporting, 0.80).  % has_property(canary, yellow)

% Weakly-supported claim: all eagles are large
% State a fact for 'evidence for' with the arguments listed below.
evidence_for(all_eagles_large, e1, supporting, 0.60).  % some evidence
% State a fact for 'evidence for' with the arguments listed below.
evidence_for(all_eagles_large, e2, opposing,   0.30).  % smaller species exist

% Unsupported claim: canaries can swim
% State a fact for 'evidence for' with the arguments listed below.
evidence_for(canary_swims, e1, supporting, 0.05).   % almost no evidence
% State a fact for 'evidence for' with the arguments listed below.
evidence_for(canary_swims, e2, opposing,   0.90).   % birds typically don't swim

% Source quality: source(ClaimId, SourceType, Reliability)
% State the fact: source quality(canary_yellow,     observation_table, 0.95).
source_quality(canary_yellow,     observation_table, 0.95).
% State the fact: source quality(all_eagles_large,  expert_opinion,    0.70).
source_quality(all_eagles_large,  expert_opinion,    0.70).
% State the fact: source quality(canary_swims,      rumour,            0.10).
source_quality(canary_swims,      rumour,            0.10).

% ---------------------------------------------------------------------------
% Evaluation thresholds
% ---------------------------------------------------------------------------

% State the fact: support threshold(well_supported,    0.75).
support_threshold(well_supported,    0.75).
% State the fact: support threshold(moderately,        0.50).
support_threshold(moderately,        0.50).
% State the fact: support threshold(weakly_supported,  0.30).
support_threshold(weakly_supported,  0.30).
% State the fact: support threshold(not_supported,     0.00).
support_threshold(not_supported,     0.00).

% ---------------------------------------------------------------------------
% Evaluation logic
% ---------------------------------------------------------------------------

% Define a clause for 'aggregate support': succeed when the following conditions hold.
aggregate_support(ClaimId, NetSupport, SupportCount, OppositionCount) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(W, evidence_for(ClaimId, _, supporting, W), SupportWeights),
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(W, evidence_for(ClaimId, _, opposing,   W), OppositionWeights),
    % State a fact for 'sum list' with the arguments listed below.
    sum_list(SupportWeights, SumS),
    % State a fact for 'sum list' with the arguments listed below.
    sum_list(OppositionWeights, SumO),
    % Unify 'SupportCount' with the number of elements in list 'SupportWeights'.
    length(SupportWeights, SupportCount),
    % Unify 'OppositionCount' with the number of elements in list 'OppositionWeights'.
    length(OppositionWeights, OppositionCount),
    % Check that '( SupportCount' is greater than '0 -> AvgS is SumS / SupportCount ; AvgS = 0 )'.
    ( SupportCount > 0 -> AvgS is SumS / SupportCount ; AvgS = 0 ),
    % Check that '( OppositionCount' is greater than '0 -> AvgO is SumO / OppositionCount ; AvgO = 0 )'.
    ( OppositionCount > 0 -> AvgO is SumO / OppositionCount ; AvgO = 0 ),
    % Evaluate the arithmetic expression 'AvgS - AvgO * 0.5' and bind the result to 'NetSupport'.
    NetSupport is AvgS - AvgO * 0.5.

% State the fact: sum list([], 0).
sum_list([], 0).
% Define a clause for 'sum list': succeed when the following conditions hold.
sum_list([H|T], S) :- sum_list(T, S1), S is S1 + H.

% Check that 'grade_support(Net, well_supported)   :- Net' is greater than or equal to '0.75'.
grade_support(Net, well_supported)   :- Net >= 0.75.
% Check that 'grade_support(Net, moderately)       :- Net' is greater than or equal to '0.50, Net < 0.75'.
grade_support(Net, moderately)       :- Net >= 0.50, Net < 0.75.
% Check that 'grade_support(Net, weakly_supported) :- Net' is greater than or equal to '0.25, Net < 0.50'.
grade_support(Net, weakly_supported) :- Net >= 0.25, Net < 0.50.
% Check that 'grade_support(Net, not_supported)    :- Net' is less than '0.25'.
grade_support(Net, not_supported)    :- Net < 0.25.

% ---------------------------------------------------------------------------
% mentova_critical(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova critical' with the arguments listed below.
mentova_critical(evaluate(ClaimId), evaluation(ClaimId, Grade, Alert),
                  % Continue the multi-line expression started above.
                  just(critical(claim(ClaimId),
                                 % Continue the multi-line expression started above.
                                 net_support(Net),
                                 % Continue the multi-line expression started above.
                                 supporting(SC), opposing(OC),
                                 % Continue the multi-line expression started above.
                                 grade(Grade),
                                 % Continue the multi-line expression started above.
                                 alert(Alert)))) :-
    % State a fact for 'aggregate support' with the arguments listed below.
    aggregate_support(ClaimId, Net, SC, OC),
    % State a fact for 'grade support' with the arguments listed below.
    grade_support(Net, Grade),
    % Execute: ( member(Grade, [weakly_supported, not_supported]).
    ( member(Grade, [weakly_supported, not_supported])
    % If the condition above succeeded, perform the following action.
    ->  Alert = flag(weak_claim, reasons([low_support(Net), opposition(OC)]))
    % Otherwise (else branch), perform the following action.
    ;   Alert = none
    % Close the expression opened above.
    ).

% State a fact for 'mentova critical' with the arguments listed below.
mentova_critical(all_evidence(ClaimId), evidence_list(All),
                  % Continue the multi-line expression started above.
                  just(evidence_dump(ClaimId, All))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(e(Type, Weight), evidence_for(ClaimId, _, Type, Weight), All).

% State a fact for 'mentova critical' with the arguments listed below.
mentova_critical(source_quality(ClaimId), source(Type, Reliability),
                  % Continue the multi-line expression started above.
                  just(source_eval(ClaimId, Type, reliability(Reliability)))) :-
    % State the fact: source quality(ClaimId, Type, Reliability).
    source_quality(ClaimId, Type, Reliability).

% State a fact for 'mentova critical' with the arguments listed below.
mentova_critical(compare(ClaimA, ClaimB), better(Winner),
                  % Continue the multi-line expression started above.
                  just(critical_compare(ClaimA, ClaimB, better(Winner)))) :-
    % State a fact for 'aggregate support' with the arguments listed below.
    aggregate_support(ClaimA, NetA, _, _),
    % State a fact for 'aggregate support' with the arguments listed below.
    aggregate_support(ClaimB, NetB, _, _),
    % Check that '( NetA' is greater than 'NetB -> Winner = ClaimA ; Winner = ClaimB )'.
    ( NetA > NetB -> Winner = ClaimA ; Winner = ClaimB ).
