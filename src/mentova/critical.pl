/*  Mentova — Rung 30: Critical Reasoning Module

    Evaluates a claim's support.
    Pass criterion: weakly-supported claim flagged with reasons.

    A claim is assessed for:
      - Evidence strength (how much evidence?)
      - Source quality (is the source reliable?)
      - Logical validity (does evidence support conclusion?)
      - Counter-evidence (is there opposing evidence?)
*/

:- module(critical, [
    mentova_critical/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Evidence base: evidence(ClaimId, Type, Weight)
%   Type: supporting | opposing | neutral
%   Weight: 0.0 - 1.0
% ---------------------------------------------------------------------------

% Well-supported claim: canaries are yellow
evidence_for(canary_yellow, e1, supporting, 0.94).  % 94% of observations
evidence_for(canary_yellow, e2, supporting, 0.80).  % has_property(canary, yellow)

% Weakly-supported claim: all eagles are large
evidence_for(all_eagles_large, e1, supporting, 0.60).  % some evidence
evidence_for(all_eagles_large, e2, opposing,   0.30).  % smaller species exist

% Unsupported claim: canaries can swim
evidence_for(canary_swims, e1, supporting, 0.05).   % almost no evidence
evidence_for(canary_swims, e2, opposing,   0.90).   % birds typically don't swim

% Source quality: source(ClaimId, SourceType, Reliability)
source_quality(canary_yellow,     observation_table, 0.95).
source_quality(all_eagles_large,  expert_opinion,    0.70).
source_quality(canary_swims,      rumour,            0.10).

% ---------------------------------------------------------------------------
% Evaluation thresholds
% ---------------------------------------------------------------------------

support_threshold(well_supported,    0.75).
support_threshold(moderately,        0.50).
support_threshold(weakly_supported,  0.30).
support_threshold(not_supported,     0.00).

% ---------------------------------------------------------------------------
% Evaluation logic
% ---------------------------------------------------------------------------

aggregate_support(ClaimId, NetSupport, SupportCount, OppositionCount) :-
    findall(W, evidence_for(ClaimId, _, supporting, W), SupportWeights),
    findall(W, evidence_for(ClaimId, _, opposing,   W), OppositionWeights),
    sum_list(SupportWeights, SumS),
    sum_list(OppositionWeights, SumO),
    length(SupportWeights, SupportCount),
    length(OppositionWeights, OppositionCount),
    ( SupportCount > 0 -> AvgS is SumS / SupportCount ; AvgS = 0 ),
    ( OppositionCount > 0 -> AvgO is SumO / OppositionCount ; AvgO = 0 ),
    NetSupport is AvgS - AvgO * 0.5.

sum_list([], 0).
sum_list([H|T], S) :- sum_list(T, S1), S is S1 + H.

grade_support(Net, well_supported)   :- Net >= 0.75.
grade_support(Net, moderately)       :- Net >= 0.50, Net < 0.75.
grade_support(Net, weakly_supported) :- Net >= 0.25, Net < 0.50.
grade_support(Net, not_supported)    :- Net < 0.25.

% ---------------------------------------------------------------------------
% mentova_critical(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_critical(evaluate(ClaimId), evaluation(ClaimId, Grade, Alert),
                  just(critical(claim(ClaimId),
                                 net_support(Net),
                                 supporting(SC), opposing(OC),
                                 grade(Grade),
                                 alert(Alert)))) :-
    aggregate_support(ClaimId, Net, SC, OC),
    grade_support(Net, Grade),
    ( member(Grade, [weakly_supported, not_supported])
    ->  Alert = flag(weak_claim, reasons([low_support(Net), opposition(OC)]))
    ;   Alert = none
    ).

mentova_critical(all_evidence(ClaimId), evidence_list(All),
                  just(evidence_dump(ClaimId, All))) :-
    findall(e(Type, Weight), evidence_for(ClaimId, _, Type, Weight), All).

mentova_critical(source_quality(ClaimId), source(Type, Reliability),
                  just(source_eval(ClaimId, Type, reliability(Reliability)))) :-
    source_quality(ClaimId, Type, Reliability).

mentova_critical(compare(ClaimA, ClaimB), better(Winner),
                  just(critical_compare(ClaimA, ClaimB, better(Winner)))) :-
    aggregate_support(ClaimA, NetA, _, _),
    aggregate_support(ClaimB, NetB, _, _),
    ( NetA > NetB -> Winner = ClaimA ; Winner = ClaimB ).
