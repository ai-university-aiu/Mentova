/*  Mentova — Rung 45: Motivational Reasoning Module

    Reasons about motivations, drives, and goal hierarchies.
    Based on a need/drive hierarchy (Maslow-inspired) plus
    agent-specific goal-urgency profiles.
    Pass criterion: given an agent and current state, return the
    most urgent unsatisfied need with its motivational justification.
*/

:- module(motivational, [
    mentova_motivational/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Need hierarchy: need(Level, Name, Description)
% Level: 1 (most basic) to 5 (highest)
% ---------------------------------------------------------------------------

need(1, physiological,  'basic survival: food, water, shelter, sleep').
need(2, safety,         'security, order, stability, freedom from fear').
need(3, belonging,      'love, friendship, connection, group membership').
need(4, esteem,         'respect, achievement, recognition, status').
need(5, self_actualise, 'growth, purpose, meaning, full potential').

% ---------------------------------------------------------------------------
% Agent needs: satisfied(Agent, NeedLevel)
% If NOT in this table → need is unsatisfied
% ---------------------------------------------------------------------------

satisfied(alice, 1).  % physiological satisfied
satisfied(alice, 2).  % safety satisfied
satisfied(alice, 3).  % belonging satisfied
% alice lacks esteem and self_actualise

satisfied(bob, 1).    % physiological satisfied
% bob lacks safety, belonging, esteem, self_actualise

satisfied(mentor, 1).
satisfied(mentor, 2).
satisfied(mentor, 3).
satisfied(mentor, 4).
satisfied(mentor, 5).  % all satisfied

% ---------------------------------------------------------------------------
% Drives: drive(Agent, Drive, Urgency)
% Urgency: high | medium | low
% ---------------------------------------------------------------------------

drive(alice,  achieve_recognition,  high).
drive(alice,  deepen_relationships, medium).
drive(alice,  learn_new_skills,     medium).

drive(bob,    find_safety,          high).
drive(bob,    make_friends,         high).
drive(bob,    earn_income,          high).

drive(mentor, share_knowledge,      high).
drive(mentor, explore_ideas,        medium).

% ---------------------------------------------------------------------------
% Most urgent unsatisfied need
% ---------------------------------------------------------------------------

most_urgent_need(Agent, NeedLevel, NeedName, Desc) :-
    findall(L-N-D,
            (need(L, N, D), \+ satisfied(Agent, L)),
            Unsatisfied),
    Unsatisfied \= [],
    msort(Unsatisfied, [NeedLevel-NeedName-Desc|_]).

% ---------------------------------------------------------------------------
% mentova_motivational(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_motivational(top_drive(Agent), drive(Agent, Drive, Urgency),
                     just(motivational(agent(Agent),
                                        top_drive(Drive),
                                        urgency(Urgency)))) :-
    findall(U-D, drive(Agent, D, U), Pairs),
    Pairs \= [],
    msort(Pairs, Sorted),
    last(Sorted, _-TopDrive),
    member(TopDrive-Urg, [high-high, medium-medium, low-low]),
    drive(Agent, TopDrive, Urg),
    Drive = TopDrive,
    Urgency = Urg.

mentova_motivational(top_drive(Agent), drive(Agent, Drive, Urgency),
                     just(motivational(agent(Agent),
                                        top_drive(Drive),
                                        urgency(Urgency)))) :-
    findall(Pr-D, (drive(Agent, D, U),
                   (U=high -> Pr=3 ; U=medium -> Pr=2 ; Pr=1)),
            Pairs),
    msort(Pairs, Sorted),
    last(Sorted, _-Drive),
    drive(Agent, Drive, Urgency).

mentova_motivational(urgent_need(Agent), need(NeedLevel, NeedName, Desc),
                     just(motivational(agent(Agent),
                                        urgent_need(NeedLevel, NeedName),
                                        desc(Desc)))) :-
    most_urgent_need(Agent, NeedLevel, NeedName, Desc).

mentova_motivational(urgent_need(Agent), all_satisfied(Agent),
                     just(motivational(agent(Agent),
                                        result(all_needs_satisfied)))) :-
    \+ most_urgent_need(Agent, _, _, _).

mentova_motivational(all_drives(Agent), drives(Agent, Drives),
                     just(motivational(agent(Agent),
                                        all_drives(Drives)))) :-
    findall(D-U, drive(Agent, D, U), Drives).

mentova_motivational(satisfied_needs(Agent), satisfied_list(Agent, Levels),
                     just(motivational(agent(Agent),
                                        satisfied_needs(Levels)))) :-
    findall(L-N, (satisfied(Agent, L), need(L, N, _)), Levels).
