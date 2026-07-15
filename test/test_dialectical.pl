/*  Mentova — Dialectical Reasoning Test Suite  (Rung 31)

    A genuine behavioural test for the 'dialectical' module. The module weighs
    pro-arguments against con-arguments for a contested proposition and reports
    the winning side, the decisive synthesis argument, and a glass-box
    justification carrying the two summed scores.

    Every assertion is computed by hand from the module's own argument base:
      nuclear_energy_good  pro = 0.8+0.9+0.7 = 2.4 ; con = 0.8+0.7+0.5 = 2.0
                           -> pro wins, synthesis = low_carbon_emission (0.9)
      remote_work_better   pro = 0.7+0.8+0.6 = 2.1 ; con = 0.6+0.5+0.4 = 1.5
                           -> pro wins, synthesis = no_commute (0.8)
      ai_dangerous         pro = 0.7+0.8+0.6 = 2.1 ; con = 0.8+0.7+0.6 = 2.1
                           -> tie, so the strict ">" test hands it to con,
                              synthesis = medical_advances (0.8)

    Run with the full PrologAI library path plus the Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_dialectical.pl
*/

% Declare this file as a test module with no exports.
:- module(test_dialectical, []).
% Load the PLUnit testing framework.
:- use_module(library(plunit)).
% Load the dialectical reasoning module under test.
:- use_module(library(dialectical)).

% Open the test block named 'dialectical'.
:- begin_tests(dialectical).

% A debate over nuclear energy names pro as the winner and low_carbon_emission as the synthesis.
test(debate_nuclear_verdict) :-
    % Run the debate query for the nuclear-energy proposition.
    mentova_dialectical(debate(nuclear_energy_good), Verdict, _Just),
    % The pro side outweighs the con side and the strongest pro argument is the synthesis.
    assertion(Verdict == verdict(pro, synthesis(low_carbon_emission))).

% The nuclear debate's justification carries pro_score 2.4 and con_score 2.0, with pro strictly ahead.
test(debate_nuclear_scores) :-
    % Run the debate query and keep the justification term.
    mentova_dialectical(debate(nuclear_energy_good), _Verdict, Just),
    % Bind the two summed scores out of the glass-box justification structure.
    Just = just(dialectical(proposition(nuclear_energy_good),
                            % Bind the summed pro and con scores out of the justification.
                            pro_score(ProScore), con_score(ConScore),
                            % Name the declared winner and the synthesis argument.
                            winner(pro), synthesis(low_carbon_emission))),
    % The pro total is 0.8+0.9+0.7, checked with a tolerance against floating-point drift.
    assertion(abs(ProScore - 2.4) < 1.0e-9),
    % The con total is exactly 0.8+0.7+0.5.
    assertion(abs(ConScore - 2.0) < 1.0e-9),
    % The winning side genuinely had the larger total weight.
    assertion(ProScore > ConScore).

% A debate over remote work names pro as the winner and no_commute as the synthesis.
test(debate_remote_verdict) :-
    % Run the debate query for the remote-work proposition.
    mentova_dialectical(debate(remote_work_better), Verdict, _Just),
    % Pro (2.1) beats con (1.5) and the strongest pro argument is no_commute (0.8).
    assertion(Verdict == verdict(pro, synthesis(no_commute))).

% A tie must fall to con, because the winner test is a strict pro > con comparison.
test(debate_tie_goes_to_con) :-
    % Run the debate query for the ai-dangerous proposition where both sides sum to 2.1.
    mentova_dialectical(debate(ai_dangerous), Verdict, Just),
    % With equal totals the strict comparison fails, so con is declared the winner.
    assertion(Verdict == verdict(con, synthesis(medical_advances))),
    % The justification records the two equal scores and con as the named winner.
    Just = just(dialectical(proposition(ai_dangerous),
                            % Bind the summed pro and con scores out of the justification.
                            pro_score(ProScore), con_score(ConScore),
                            % Name the declared winner and the synthesis argument.
                            winner(con), synthesis(medical_advances))),
    % Both sides carried exactly the same total weight.
    assertion(abs(ProScore - ConScore) < 1.0e-9).

% The pros query lists every pro argument of a proposition as label-weight pairs in fact order.
test(pros_nuclear) :-
    % Run the pros query for the nuclear-energy proposition.
    mentova_dialectical(pros(nuclear_energy_good), Props, _Just),
    % The three pro arguments come back with their exact weights and source order.
    assertion(Props == [economic_output-0.8, low_carbon_emission-0.9, reliable_baseload-0.7]).

% The cons query lists every con argument of a proposition as label-weight pairs in fact order.
test(cons_nuclear) :-
    % Run the cons query for the nuclear-energy proposition.
    mentova_dialectical(cons(nuclear_energy_good), Cons, _Just),
    % The three con arguments come back with their exact weights and source order.
    assertion(Cons == [waste_storage_risk-0.8, accident_potential-0.7, high_capital_cost-0.5]).

% Close the test block named 'dialectical'.
:- end_tests(dialectical).
