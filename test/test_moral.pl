/*  Mentova — Moral Reasoning Test Suite  (Rung 48)

    Behavioural PLUnit suite for the pure 'moral' reasoning module. The module
    exports one dispatcher, mentova_moral(+Query, -Result, -Justification), which
    answers six documented query forms over four hand-coded ethical dilemmas.
    Every expected value below is computed by hand from the module's own facts:
    utilitarian = argmax(Benefit - Harm) with 'many' scored as ten;
    deontological = the first option that breaks no rule;
    virtue = the first option flagged virtuous.

    Run with the full library path (every PrologAI pack plus the Mentova source):
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_moral.pl
*/

% Declare this file as a test module that exports nothing.
:- module(test_moral, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the moral reasoning module under test from the library path.
:- use_module(library(moral)).

% Open the test block for the moral module.
:- begin_tests(moral).

% AC-MORAL-001: what_dilemmas lists the four dilemmas in source order.
test(what_dilemmas_lists_all_four) :-
    % Ask the module which dilemmas it knows about.
    mentova_moral(what_dilemmas, dilemmas(List), Just),
    % The list is exactly the four dilemma ids, in declaration order.
    assertion(List == [trolley_problem, lying_to_protect, doctors_dilemma, whistleblowing]),
    % The justification names the available-dilemmas query and echoes the list.
    assertion(Just == just(moral(available_dilemmas, list(List)))).

% AC-MORAL-002: describe returns the stored English description verbatim.
test(describe_returns_description) :-
    % Ask for the trolley problem's description.
    mentova_moral(describe(trolley_problem), description(trolley_problem, Desc), Just),
    % The description is the exact stored sentence.
    assertion(Desc == 'A runaway trolley will kill five people. Pulling a lever diverts it to kill one.'),
    % The justification carries the same description under a dilemma-description tag.
    assertion(Just == just(moral(dilemma_description(trolley_problem), desc(Desc)))).

% AC-MORAL-003: the utilitarian framework maximises net welfare.
test(utilitarian_picks_best_net_welfare) :-
    % Ask for the utilitarian verdict on the trolley problem.
    mentova_moral(utilitarian(trolley_problem), verdict(U), Just),
    % pull_lever nets 5-1=4 against do_nothing's 0-5=-5, so it wins.
    assertion(U == pull_lever),
    % The justification records the utilitarian query and its verdict.
    assertion(Just == just(moral(utilitarian(trolley_problem), verdict(pull_lever)))).

% AC-MORAL-004: 'many' is scored as ten, so silence beats reporting on welfare.
test(utilitarian_scores_many_as_ten) :-
    % Ask for the utilitarian verdict on whistleblowing.
    mentova_moral(utilitarian(whistleblowing), verdict(U), _Just),
    % report nets 1-10=-9 while stay_silent nets 10-0=10, so silence wins on raw welfare.
    assertion(U == stay_silent).

% AC-MORAL-005: the deontological framework prefers the rule-abiding option.
test(deontological_prefers_rule_abiding) :-
    % Ask for the deontological verdict on lying to protect an innocent.
    mentova_moral(deontological(lying_to_protect), verdict(D), Just),
    % lie breaks rule_do_not_lie, so the rule-abiding tell_truth is chosen.
    assertion(D == tell_truth),
    % The justification records the deontological query and its verdict.
    assertion(Just == just(moral(deontological(lying_to_protect), verdict(tell_truth)))).

% AC-MORAL-006: the virtue framework picks the option flagged virtuous.
test(virtue_picks_virtuous_option) :-
    % Ask for the virtue verdict on lying to protect an innocent.
    mentova_moral(virtue(lying_to_protect), verdict(V), _Just),
    % lie is the option marked virtuous here, so it is the virtue verdict.
    assertion(V == lie).

% AC-MORAL-007: analyse fuses all three frameworks into one integrated judgement.
test(analyse_integrates_three_frameworks) :-
    % Ask for the full moral analysis of the trolley problem.
    mentova_moral(analyse(trolley_problem), Result, _Just),
    % Utilitarian and deontological both pick pull_lever; virtue picks do_nothing;
    % the integrated judgement resolves to pull_lever.
    assertion(Result == moral_analysis(trolley_problem,
                                       utilitarian(pull_lever),
                                       deontological(pull_lever),
                                       virtue(do_nothing),
                                       integrated(pull_lever))).

% Close the test block for the moral module.
:- end_tests(moral).
