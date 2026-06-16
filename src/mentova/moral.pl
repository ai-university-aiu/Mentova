/*  Mentova — Rung 48: Moral Reasoning Module

    The final rung of Mentova's 48-rung reasoning ladder.
    Evaluates moral dilemmas from multiple ethical frameworks:
    utilitarian (maximise welfare), deontological (rule-based),
    and virtue-based (character excellence).
    Pass criterion: given a moral dilemma, return the verdict of each
    framework and the integrated moral judgement.
*/

:- module(moral, [
    mentova_moral/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Moral dilemmas: dilemma(Id, Description, Options, StakeholderImpacts)
% Option impact: option(Name, HarmCount, BenefitCount, RuleBroken, Virtuous)
% ---------------------------------------------------------------------------

dilemma(trolley_problem,
        'A runaway trolley will kill five people. Pulling a lever diverts it to kill one.',
        [pull_lever, do_nothing],
        [
            option(pull_lever,   1, 5, none,               false),
            option(do_nothing,   5, 0, none,               true)
        ]).

dilemma(lying_to_protect,
        'Lying to a murderer to protect an innocent person hiding in your home.',
        [lie, tell_truth],
        [
            option(lie,         0, 1, breaks(rule_do_not_lie), true),
            option(tell_truth,  1, 0, none,                    false)
        ]).

dilemma(doctors_dilemma,
        'A doctor can save five patients by sacrificing one healthy patient for organs.',
        [harvest_organs, refuse],
        [
            option(harvest_organs, 1, 5, breaks(rule_do_not_harm_innocent), false),
            option(refuse,         5, 0, none,                               true)
        ]).

dilemma(whistleblowing,
        'An employee discovers corporate fraud but reporting will cost colleagues their jobs.',
        [report, stay_silent],
        [
            option(report,       many, 1, none,              true),
            option(stay_silent,  0, many, breaks(rule_honesty), false)
        ]).

% ---------------------------------------------------------------------------
% Utilitarian analysis: pick option with best net welfare (most benefit - least harm)
% harm/benefit are counts; we treat 1 unit harm > 0 units benefit as worse
% ---------------------------------------------------------------------------

utilitarian_verdict(DilemmaId, BestOption) :-
    dilemma(DilemmaId, _, _, Options),
    findall(Net-Opt,
            (member(option(Opt, H, B, _, _), Options),
             numeric_val(H, HN),
             numeric_val(B, BN),
             Net is BN - HN),
            Pairs),
    msort(Pairs, Sorted),
    last(Sorted, _-BestOption).

numeric_val(X, X) :- number(X), !.
numeric_val(many, 10) :- !.
numeric_val(_, 0).

% ---------------------------------------------------------------------------
% Deontological analysis: pick option that breaks no rule (if possible)
% ---------------------------------------------------------------------------

deontological_verdict(DilemmaId, BestOption) :-
    dilemma(DilemmaId, _, _, Options),
    member(option(BestOption, _, _, none, _), Options), !.

deontological_verdict(DilemmaId, conflict) :-
    dilemma(DilemmaId, _, _, Options),
    \+ member(option(_, _, _, none, _), Options).

% ---------------------------------------------------------------------------
% Virtue ethics: pick the virtuous option
% ---------------------------------------------------------------------------

virtue_verdict(DilemmaId, BestOption) :-
    dilemma(DilemmaId, _, _, Options),
    member(option(BestOption, _, _, _, true), Options), !.

virtue_verdict(DilemmaId, no_virtuous_option) :-
    dilemma(DilemmaId, _, _, Options),
    \+ member(option(_, _, _, _, true), Options).

% ---------------------------------------------------------------------------
% Integrated judgement: plurality vote across 3 frameworks
% ---------------------------------------------------------------------------

integrated_judgement(DilemmaId, Judgement) :-
    utilitarian_verdict(DilemmaId, U),
    deontological_verdict(DilemmaId, D),
    virtue_verdict(DilemmaId, V),
    findall(O, member(O, [U, D, V]), Votes),
    msort(Votes, Sorted),
    count_best(Sorted, Judgement).

count_best(Sorted, Best) :-
    last(Sorted, Last),
    msort(Sorted, S2),
    reverse(S2, [Last|_]),
    Best = Last.

% ---------------------------------------------------------------------------
% mentova_moral(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_moral(analyse(DilemmaId), moral_analysis(DilemmaId,
                                                   utilitarian(U),
                                                   deontological(D),
                                                   virtue(V),
                                                   integrated(I)),
              just(moral(dilemma(DilemmaId),
                          utilitarian_verdict(U),
                          deontological_verdict(D),
                          virtue_verdict(V),
                          integrated_judgement(I)))) :-
    utilitarian_verdict(DilemmaId, U),
    deontological_verdict(DilemmaId, D),
    virtue_verdict(DilemmaId, V),
    integrated_judgement(DilemmaId, I).

mentova_moral(utilitarian(DilemmaId), verdict(U),
              just(moral(utilitarian(DilemmaId), verdict(U)))) :-
    utilitarian_verdict(DilemmaId, U).

mentova_moral(deontological(DilemmaId), verdict(D),
              just(moral(deontological(DilemmaId), verdict(D)))) :-
    deontological_verdict(DilemmaId, D).

mentova_moral(virtue(DilemmaId), verdict(V),
              just(moral(virtue(DilemmaId), verdict(V)))) :-
    virtue_verdict(DilemmaId, V).

mentova_moral(what_dilemmas, dilemmas(List),
              just(moral(available_dilemmas, list(List)))) :-
    findall(Id, dilemma(Id, _, _, _), List).

mentova_moral(describe(DilemmaId), description(DilemmaId, Desc),
              just(moral(dilemma_description(DilemmaId), desc(Desc)))) :-
    dilemma(DilemmaId, Desc, _, _).
