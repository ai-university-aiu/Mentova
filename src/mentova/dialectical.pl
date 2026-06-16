/*  Mentova — Rung 31: Dialectical Reasoning Module

    Weighs pro-arguments against con-arguments for a proposition.
    Pass criterion: for a contested proposition, returns the side with
    stronger total weight and names the decisive arguments.
*/

:- module(dialectical, [
    mentova_dialectical/3
]).

:- use_module(library(lists), [member/2]).
:- use_module(library(aggregate), [aggregate_all/3]).

% ---------------------------------------------------------------------------
% Argument base: arg(Proposition, Side, Label, Weight)
% Side: pro | con
% ---------------------------------------------------------------------------

arg(nuclear_energy_good, pro,  economic_output,        0.8).
arg(nuclear_energy_good, pro,  low_carbon_emission,    0.9).
arg(nuclear_energy_good, pro,  reliable_baseload,      0.7).
arg(nuclear_energy_good, con,  waste_storage_risk,     0.8).
arg(nuclear_energy_good, con,  accident_potential,     0.7).
arg(nuclear_energy_good, con,  high_capital_cost,      0.5).

arg(remote_work_better, pro,   productivity_gain,      0.7).
arg(remote_work_better, pro,   no_commute,             0.8).
arg(remote_work_better, pro,   work_life_balance,      0.6).
arg(remote_work_better, con,   collaboration_loss,     0.6).
arg(remote_work_better, con,   isolation_risk,         0.5).
arg(remote_work_better, con,   management_difficulty,  0.4).

arg(ai_dangerous, pro,         job_displacement,       0.7).
arg(ai_dangerous, pro,         autonomous_weapons,     0.8).
arg(ai_dangerous, pro,         bias_amplification,     0.6).
arg(ai_dangerous, con,         medical_advances,       0.8).
arg(ai_dangerous, con,         productivity_gains,     0.7).
arg(ai_dangerous, con,         scientific_discovery,   0.6).

% ---------------------------------------------------------------------------
% Synthesis: highest-weight argument from winning side
% ---------------------------------------------------------------------------

synthesis(Prop, Side, Label) :-
    findall(W-L, arg(Prop, Side, L, W), Pairs),
    msort(Pairs, Sorted),
    last(Sorted, _-Label).

% ---------------------------------------------------------------------------
% mentova_dialectical(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_dialectical(debate(Prop), verdict(Winner, synthesis(SynLabel)),
                    just(dialectical(proposition(Prop),
                                     pro_score(ProScore),
                                     con_score(ConScore),
                                     winner(Winner),
                                     synthesis(SynLabel)))) :-
    aggregate_all(sum(W), arg(Prop, pro, _, W), ProScore),
    aggregate_all(sum(W), arg(Prop, con, _, W), ConScore),
    ( ProScore > ConScore -> Winner = pro ; Winner = con ),
    synthesis(Prop, Winner, SynLabel).

mentova_dialectical(pros(Prop), Props,
                    just(dialectical_pros(Prop, Props))) :-
    findall(L-W, arg(Prop, pro, L, W), Props).

mentova_dialectical(cons(Prop), Cons,
                    just(dialectical_cons(Prop, Cons))) :-
    findall(L-W, arg(Prop, con, L, W), Cons).
