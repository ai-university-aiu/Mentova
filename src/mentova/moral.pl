/*  Mentova — Rung 48: Moral Reasoning Module

    The final rung of Mentova's 48-rung reasoning ladder.
    Evaluates moral dilemmas from multiple ethical frameworks:
    utilitarian (maximise welfare), deontological (rule-based),
    and virtue-based (character excellence).
    Pass criterion: given a moral dilemma, return the verdict of each
    framework and the integrated moral judgement.
*/

% Declare this file as the 'moral' module and list its exported predicates.
:- module(moral, [
    % Supply 'mentova_moral/3' as the next argument to the expression above.
    mentova_moral/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Moral dilemmas: dilemma(Id, Description, Options, StakeholderImpacts)
% Option impact: option(Name, HarmCount, BenefitCount, RuleBroken, Virtuous)
% ---------------------------------------------------------------------------

% State a fact for 'dilemma' with the arguments listed below.
dilemma(trolley_problem,
        % Continue the multi-line expression started above.
        'A runaway trolley will kill five people. Pulling a lever diverts it to kill one.',
        % Continue the multi-line expression started above.
        [pull_lever, do_nothing],
        % Continue the multi-line expression started above.
        [
            % Continue the multi-line expression started above.
            option(pull_lever,   1, 5, none,               false),
            % Continue the multi-line expression started above.
            option(do_nothing,   5, 0, none,               true)
        % Close the expression opened above.
        ]).

% State a fact for 'dilemma' with the arguments listed below.
dilemma(lying_to_protect,
        % Continue the multi-line expression started above.
        'Lying to a murderer to protect an innocent person hiding in your home.',
        % Continue the multi-line expression started above.
        [lie, tell_truth],
        % Continue the multi-line expression started above.
        [
            % Continue the multi-line expression started above.
            option(lie,         0, 1, breaks(rule_do_not_lie), true),
            % Continue the multi-line expression started above.
            option(tell_truth,  1, 0, none,                    false)
        % Close the expression opened above.
        ]).

% State a fact for 'dilemma' with the arguments listed below.
dilemma(doctors_dilemma,
        % Continue the multi-line expression started above.
        'A doctor can save five patients by sacrificing one healthy patient for organs.',
        % Continue the multi-line expression started above.
        [harvest_organs, refuse],
        % Continue the multi-line expression started above.
        [
            % Continue the multi-line expression started above.
            option(harvest_organs, 1, 5, breaks(rule_do_not_harm_innocent), false),
            % Continue the multi-line expression started above.
            option(refuse,         5, 0, none,                               true)
        % Close the expression opened above.
        ]).

% State a fact for 'dilemma' with the arguments listed below.
dilemma(whistleblowing,
        % Continue the multi-line expression started above.
        'An employee discovers corporate fraud but reporting will cost colleagues their jobs.',
        % Continue the multi-line expression started above.
        [report, stay_silent],
        % Continue the multi-line expression started above.
        [
            % Continue the multi-line expression started above.
            option(report,       many, 1, none,              true),
            % Continue the multi-line expression started above.
            option(stay_silent,  0, many, breaks(rule_honesty), false)
        % Close the expression opened above.
        ]).

% ---------------------------------------------------------------------------
% Utilitarian analysis: pick option with best net welfare (most benefit - least harm)
% harm/benefit are counts; we treat 1 unit harm > 0 units benefit as worse
% ---------------------------------------------------------------------------

% Define a clause for 'utilitarian verdict': succeed when the following conditions hold.
utilitarian_verdict(DilemmaId, BestOption) :-
    % State a fact for 'dilemma' with the arguments listed below.
    dilemma(DilemmaId, _, _, Options),
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Net-Opt,
            % Continue the multi-line expression started above.
            (member(option(Opt, H, B, _, _), Options),
             % Continue the multi-line expression started above.
             numeric_val(H, HN),
             % Continue the multi-line expression started above.
             numeric_val(B, BN),
             % Continue the multi-line expression started above.
             Net is BN - HN),
            % Supply 'Pairs' as the next argument to the expression above.
            Pairs),
    % Sort list 'Pairs' into 'Sorted', keeping duplicates.
    msort(Pairs, Sorted),
    % Unify the second argument with the last element of list 'Sorted'.
    last(Sorted, _-BestOption).

% Define a clause for 'numeric val': succeed when the following conditions hold.
numeric_val(X, X) :- number(X), !.
% Define a clause for 'numeric val': succeed when the following conditions hold.
numeric_val(many, 10) :- !.
% State the fact: numeric val(_, 0).
numeric_val(_, 0).

% ---------------------------------------------------------------------------
% Deontological analysis: pick option that breaks no rule (if possible)
% ---------------------------------------------------------------------------

% Define a clause for 'deontological verdict': succeed when the following conditions hold.
deontological_verdict(DilemmaId, BestOption) :-
    % State a fact for 'dilemma' with the arguments listed below.
    dilemma(DilemmaId, _, _, Options),
    % Succeed for each element 'option(BestOption, _, _, none, _)' that is a member of the list.
    member(option(BestOption, _, _, none, _), Options), !.

% Define a clause for 'deontological verdict': succeed when the following conditions hold.
deontological_verdict(DilemmaId, conflict) :-
    % State a fact for 'dilemma' with the arguments listed below.
    dilemma(DilemmaId, _, _, Options),
    % Succeed only if 'member(option(_, _, _, none, _), Options' cannot be proved (negation as failure).
    \+ member(option(_, _, _, none, _), Options).

% ---------------------------------------------------------------------------
% Virtue ethics: pick the virtuous option
% ---------------------------------------------------------------------------

% Define a clause for 'virtue verdict': succeed when the following conditions hold.
virtue_verdict(DilemmaId, BestOption) :-
    % State a fact for 'dilemma' with the arguments listed below.
    dilemma(DilemmaId, _, _, Options),
    % Succeed for each element 'option(BestOption, _, _, _, true)' that is a member of the list.
    member(option(BestOption, _, _, _, true), Options), !.

% Define a clause for 'virtue verdict': succeed when the following conditions hold.
virtue_verdict(DilemmaId, no_virtuous_option) :-
    % State a fact for 'dilemma' with the arguments listed below.
    dilemma(DilemmaId, _, _, Options),
    % Succeed only if 'member(option(_, _, _, _, true), Options' cannot be proved (negation as failure).
    \+ member(option(_, _, _, _, true), Options).

% ---------------------------------------------------------------------------
% Integrated judgement: plurality vote across 3 frameworks
% ---------------------------------------------------------------------------

% Define a clause for 'integrated judgement': succeed when the following conditions hold.
integrated_judgement(DilemmaId, Judgement) :-
    % State a fact for 'utilitarian verdict' with the arguments listed below.
    utilitarian_verdict(DilemmaId, U),
    % State a fact for 'deontological verdict' with the arguments listed below.
    deontological_verdict(DilemmaId, D),
    % State a fact for 'virtue verdict' with the arguments listed below.
    virtue_verdict(DilemmaId, V),
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(O, member(O, [U, D, V]), Votes),
    % Sort list 'Votes' into 'Sorted', keeping duplicates.
    msort(Votes, Sorted),
    % State the fact: count best(Sorted, Judgement).
    count_best(Sorted, Judgement).

% Define a clause for 'count best': succeed when the following conditions hold.
count_best(Sorted, Best) :-
    % Unify the second argument with the last element of list 'Sorted'.
    last(Sorted, Last),
    % Sort list 'Sorted' into 'S2', keeping duplicates.
    msort(Sorted, S2),
    % State a fact for 'reverse' with the arguments listed below.
    reverse(S2, [Last|_]),
    % Check that 'Best' is unifiable with 'Last'.
    Best = Last.

% ---------------------------------------------------------------------------
% mentova_moral(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova moral' with the arguments listed below.
mentova_moral(analyse(DilemmaId), moral_analysis(DilemmaId,
                                                   % Continue the multi-line expression started above.
                                                   utilitarian(U),
                                                   % Continue the multi-line expression started above.
                                                   deontological(D),
                                                   % Continue the multi-line expression started above.
                                                   virtue(V),
                                                   % Continue the multi-line expression started above.
                                                   integrated(I)),
              % Continue the multi-line expression started above.
              just(moral(dilemma(DilemmaId),
                          % Continue the multi-line expression started above.
                          utilitarian_verdict(U),
                          % Continue the multi-line expression started above.
                          deontological_verdict(D),
                          % Continue the multi-line expression started above.
                          virtue_verdict(V),
                          % Continue the multi-line expression started above.
                          integrated_judgement(I)))) :-
    % State a fact for 'utilitarian verdict' with the arguments listed below.
    utilitarian_verdict(DilemmaId, U),
    % State a fact for 'deontological verdict' with the arguments listed below.
    deontological_verdict(DilemmaId, D),
    % State a fact for 'virtue verdict' with the arguments listed below.
    virtue_verdict(DilemmaId, V),
    % State the fact: integrated judgement(DilemmaId, I).
    integrated_judgement(DilemmaId, I).

% State a fact for 'mentova moral' with the arguments listed below.
mentova_moral(utilitarian(DilemmaId), verdict(U),
              % Continue the multi-line expression started above.
              just(moral(utilitarian(DilemmaId), verdict(U)))) :-
    % State the fact: utilitarian verdict(DilemmaId, U).
    utilitarian_verdict(DilemmaId, U).

% State a fact for 'mentova moral' with the arguments listed below.
mentova_moral(deontological(DilemmaId), verdict(D),
              % Continue the multi-line expression started above.
              just(moral(deontological(DilemmaId), verdict(D)))) :-
    % State the fact: deontological verdict(DilemmaId, D).
    deontological_verdict(DilemmaId, D).

% State a fact for 'mentova moral' with the arguments listed below.
mentova_moral(virtue(DilemmaId), verdict(V),
              % Continue the multi-line expression started above.
              just(moral(virtue(DilemmaId), verdict(V)))) :-
    % State the fact: virtue verdict(DilemmaId, V).
    virtue_verdict(DilemmaId, V).

% State a fact for 'mentova moral' with the arguments listed below.
mentova_moral(what_dilemmas, dilemmas(List),
              % Continue the multi-line expression started above.
              just(moral(available_dilemmas, list(List)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Id, dilemma(Id, _, _, _), List).

% State a fact for 'mentova moral' with the arguments listed below.
mentova_moral(describe(DilemmaId), description(DilemmaId, Desc),
              % Continue the multi-line expression started above.
              just(moral(dilemma_description(DilemmaId), desc(Desc)))) :-
    % State the fact: dilemma(DilemmaId, Desc, _, _).
    dilemma(DilemmaId, Desc, _, _).
