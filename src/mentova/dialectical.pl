/*  Mentova — Rung 31: Dialectical Reasoning Module

    Weighs pro-arguments against con-arguments for a proposition.
    Pass criterion: for a contested proposition, returns the side with
    stronger total weight and names the decisive arguments.
*/

% Declare this file as the 'dialectical' module and list its exported predicates.
:- module(dialectical, [
    % Supply 'mentova_dialectical/3' as the next argument to the expression above.
    mentova_dialectical/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).
% Import [aggregate_all/3] from the built-in 'aggregate' library.
:- use_module(library(aggregate), [aggregate_all/3]).

% ---------------------------------------------------------------------------
% Argument base: arg(Proposition, Side, Label, Weight)
% Side: pro | con
% ---------------------------------------------------------------------------

% State the fact: arg(nuclear_energy_good, pro,  economic_output,        0.8).
arg(nuclear_energy_good, pro,  economic_output,        0.8).
% State the fact: arg(nuclear_energy_good, pro,  low_carbon_emission,    0.9).
arg(nuclear_energy_good, pro,  low_carbon_emission,    0.9).
% State the fact: arg(nuclear_energy_good, pro,  reliable_baseload,      0.7).
arg(nuclear_energy_good, pro,  reliable_baseload,      0.7).
% State the fact: arg(nuclear_energy_good, con,  waste_storage_risk,     0.8).
arg(nuclear_energy_good, con,  waste_storage_risk,     0.8).
% State the fact: arg(nuclear_energy_good, con,  accident_potential,     0.7).
arg(nuclear_energy_good, con,  accident_potential,     0.7).
% State the fact: arg(nuclear_energy_good, con,  high_capital_cost,      0.5).
arg(nuclear_energy_good, con,  high_capital_cost,      0.5).

% State the fact: arg(remote_work_better, pro,   productivity_gain,      0.7).
arg(remote_work_better, pro,   productivity_gain,      0.7).
% State the fact: arg(remote_work_better, pro,   no_commute,             0.8).
arg(remote_work_better, pro,   no_commute,             0.8).
% State the fact: arg(remote_work_better, pro,   work_life_balance,      0.6).
arg(remote_work_better, pro,   work_life_balance,      0.6).
% State the fact: arg(remote_work_better, con,   collaboration_loss,     0.6).
arg(remote_work_better, con,   collaboration_loss,     0.6).
% State the fact: arg(remote_work_better, con,   isolation_risk,         0.5).
arg(remote_work_better, con,   isolation_risk,         0.5).
% State the fact: arg(remote_work_better, con,   management_difficulty,  0.4).
arg(remote_work_better, con,   management_difficulty,  0.4).

% State the fact: arg(ai_dangerous, pro,         job_displacement,       0.7).
arg(ai_dangerous, pro,         job_displacement,       0.7).
% State the fact: arg(ai_dangerous, pro,         autonomous_weapons,     0.8).
arg(ai_dangerous, pro,         autonomous_weapons,     0.8).
% State the fact: arg(ai_dangerous, pro,         bias_amplification,     0.6).
arg(ai_dangerous, pro,         bias_amplification,     0.6).
% State the fact: arg(ai_dangerous, con,         medical_advances,       0.8).
arg(ai_dangerous, con,         medical_advances,       0.8).
% State the fact: arg(ai_dangerous, con,         productivity_gains,     0.7).
arg(ai_dangerous, con,         productivity_gains,     0.7).
% State the fact: arg(ai_dangerous, con,         scientific_discovery,   0.6).
arg(ai_dangerous, con,         scientific_discovery,   0.6).

% ---------------------------------------------------------------------------
% Synthesis: highest-weight argument from winning side
% ---------------------------------------------------------------------------

% Define a clause for 'synthesis': succeed when the following conditions hold.
synthesis(Prop, Side, Label) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(W-L, arg(Prop, Side, L, W), Pairs),
    % Sort list 'Pairs' into 'Sorted', keeping duplicates.
    msort(Pairs, Sorted),
    % Unify the second argument with the last element of list 'Sorted'.
    last(Sorted, _-Label).

% ---------------------------------------------------------------------------
% mentova_dialectical(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova dialectical' with the arguments listed below.
mentova_dialectical(debate(Prop), verdict(Winner, synthesis(SynLabel)),
                    % Continue the multi-line expression started above.
                    just(dialectical(proposition(Prop),
                                     % Continue the multi-line expression started above.
                                     pro_score(ProScore),
                                     % Continue the multi-line expression started above.
                                     con_score(ConScore),
                                     % Continue the multi-line expression started above.
                                     winner(Winner),
                                     % Continue the multi-line expression started above.
                                     synthesis(SynLabel)))) :-
    % Aggregate solutions using 'sum' and bind the result to a single value.
    aggregate_all(sum(W), arg(Prop, pro, _, W), ProScore),
    % Aggregate solutions using 'sum' and bind the result to a single value.
    aggregate_all(sum(W), arg(Prop, con, _, W), ConScore),
    % Check that '( ProScore' is greater than 'ConScore -> Winner = pro ; Winner = con )'.
    ( ProScore > ConScore -> Winner = pro ; Winner = con ),
    % State the fact: synthesis(Prop, Winner, SynLabel).
    synthesis(Prop, Winner, SynLabel).

% State a fact for 'mentova dialectical' with the arguments listed below.
mentova_dialectical(pros(Prop), Props,
                    % Continue the multi-line expression started above.
                    just(dialectical_pros(Prop, Props))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(L-W, arg(Prop, pro, L, W), Props).

% State a fact for 'mentova dialectical' with the arguments listed below.
mentova_dialectical(cons(Prop), Cons,
                    % Continue the multi-line expression started above.
                    just(dialectical_cons(Prop, Cons))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(L-W, arg(Prop, con, L, W), Cons).
