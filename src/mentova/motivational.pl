/*  Mentova — Rung 45: Motivational Reasoning Module

    Reasons about motivations, drives, and goal hierarchies.
    Based on a need/drive hierarchy (Maslow-inspired) plus
    agent-specific goal-urgency profiles.
    Pass criterion: given an agent and current state, return the
    most urgent unsatisfied need with its motivational justification.
*/

% Declare this file as the 'motivational' module and list its exported predicates.
:- module(motivational, [
    % Supply 'mentova_motivational/3' as the next argument to the expression above.
    mentova_motivational/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Need hierarchy: need(Level, Name, Description)
% Level: 1 (most basic) to 5 (highest)
% ---------------------------------------------------------------------------

% State the fact: need(1, physiological,  'basic survival: food, water, shelter, sleep').
need(1, physiological,  'basic survival: food, water, shelter, sleep').
% State the fact: need(2, safety,         'security, order, stability, freedom from fear').
need(2, safety,         'security, order, stability, freedom from fear').
% State the fact: need(3, belonging,      'love, friendship, connection, group membership').
need(3, belonging,      'love, friendship, connection, group membership').
% State the fact: need(4, esteem,         'respect, achievement, recognition, status').
need(4, esteem,         'respect, achievement, recognition, status').
% State the fact: need(5, self_actualise, 'growth, purpose, meaning, full potential').
need(5, self_actualise, 'growth, purpose, meaning, full potential').

% ---------------------------------------------------------------------------
% Agent needs: satisfied(Agent, NeedLevel)
% If NOT in this table → need is unsatisfied
% ---------------------------------------------------------------------------

% State a fact for 'satisfied' with the arguments listed below.
satisfied(alice, 1).  % physiological satisfied
% State a fact for 'satisfied' with the arguments listed below.
satisfied(alice, 2).  % safety satisfied
% State a fact for 'satisfied' with the arguments listed below.
satisfied(alice, 3).  % belonging satisfied
% alice lacks esteem and self_actualise

% State a fact for 'satisfied' with the arguments listed below.
satisfied(bob, 1).    % physiological satisfied
% bob lacks safety, belonging, esteem, self_actualise

% State the fact: satisfied(mentor, 1).
satisfied(mentor, 1).
% State the fact: satisfied(mentor, 2).
satisfied(mentor, 2).
% State the fact: satisfied(mentor, 3).
satisfied(mentor, 3).
% State the fact: satisfied(mentor, 4).
satisfied(mentor, 4).
% State a fact for 'satisfied' with the arguments listed below.
satisfied(mentor, 5).  % all satisfied

% ---------------------------------------------------------------------------
% Drives: drive(Agent, Drive, Urgency)
% Urgency: high | medium | low
% ---------------------------------------------------------------------------

% State the fact: drive(alice,  achieve_recognition,  high).
drive(alice,  achieve_recognition,  high).
% State the fact: drive(alice,  deepen_relationships, medium).
drive(alice,  deepen_relationships, medium).
% State the fact: drive(alice,  learn_new_skills,     medium).
drive(alice,  learn_new_skills,     medium).

% State the fact: drive(bob,    find_safety,          high).
drive(bob,    find_safety,          high).
% State the fact: drive(bob,    make_friends,         high).
drive(bob,    make_friends,         high).
% State the fact: drive(bob,    earn_income,          high).
drive(bob,    earn_income,          high).

% State the fact: drive(mentor, share_knowledge,      high).
drive(mentor, share_knowledge,      high).
% State the fact: drive(mentor, explore_ideas,        medium).
drive(mentor, explore_ideas,        medium).

% ---------------------------------------------------------------------------
% Most urgent unsatisfied need
% ---------------------------------------------------------------------------

% Define a clause for 'most urgent need': succeed when the following conditions hold.
most_urgent_need(Agent, NeedLevel, NeedName, Desc) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(L-N-D,
            % Continue the multi-line expression started above.
            (need(L, N, D), \+ satisfied(Agent, L)),
            % Supply 'Unsatisfied' as the next argument to the expression above.
            Unsatisfied),
    % Check that 'Unsatisfied' is not unifiable with '[]'.
    Unsatisfied \= [],
    % State the fact: msort(Unsatisfied, [NeedLevel-NeedName-Desc|_]).
    msort(Unsatisfied, [NeedLevel-NeedName-Desc|_]).

% ---------------------------------------------------------------------------
% mentova_motivational(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova motivational' with the arguments listed below.
mentova_motivational(top_drive(Agent), drive(Agent, Drive, Urgency),
                     % Continue the multi-line expression started above.
                     just(motivational(agent(Agent),
                                        % Continue the multi-line expression started above.
                                        top_drive(Drive),
                                        % Continue the multi-line expression started above.
                                        urgency(Urgency)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(U-D, drive(Agent, D, U), Pairs),
    % Check that 'Pairs' is not unifiable with '[]'.
    Pairs \= [],
    % Sort list 'Pairs' into 'Sorted', keeping duplicates.
    msort(Pairs, Sorted),
    % Unify the second argument with the last element of list 'Sorted'.
    last(Sorted, _-TopDrive),
    % Succeed for each element 'TopDrive-Urg, [high-high, medium-medium' that is a member of the list.
    member(TopDrive-Urg, [high-high, medium-medium, low-low]),
    % State a fact for 'drive' with the arguments listed below.
    drive(Agent, TopDrive, Urg),
    % Check that 'Drive' is unifiable with 'TopDrive'.
    Drive = TopDrive,
    % Check that 'Urgency' is unifiable with 'Urg'.
    Urgency = Urg.

% State a fact for 'mentova motivational' with the arguments listed below.
mentova_motivational(top_drive(Agent), drive(Agent, Drive, Urgency),
                     % Continue the multi-line expression started above.
                     just(motivational(agent(Agent),
                                        % Continue the multi-line expression started above.
                                        top_drive(Drive),
                                        % Continue the multi-line expression started above.
                                        urgency(Urgency)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Pr-D, (drive(Agent, D, U),
                   % Continue the multi-line expression started above.
                   (U=high -> Pr=3 ; U=medium -> Pr=2 ; Pr=1)),
            % Supply 'Pairs' as the next argument to the expression above.
            Pairs),
    % Sort list 'Pairs' into 'Sorted', keeping duplicates.
    msort(Pairs, Sorted),
    % Unify the second argument with the last element of list 'Sorted'.
    last(Sorted, _-Drive),
    % State the fact: drive(Agent, Drive, Urgency).
    drive(Agent, Drive, Urgency).

% State a fact for 'mentova motivational' with the arguments listed below.
mentova_motivational(urgent_need(Agent), need(NeedLevel, NeedName, Desc),
                     % Continue the multi-line expression started above.
                     just(motivational(agent(Agent),
                                        % Continue the multi-line expression started above.
                                        urgent_need(NeedLevel, NeedName),
                                        % Continue the multi-line expression started above.
                                        desc(Desc)))) :-
    % State the fact: most urgent need(Agent, NeedLevel, NeedName, Desc).
    most_urgent_need(Agent, NeedLevel, NeedName, Desc).

% State a fact for 'mentova motivational' with the arguments listed below.
mentova_motivational(urgent_need(Agent), all_satisfied(Agent),
                     % Continue the multi-line expression started above.
                     just(motivational(agent(Agent),
                                        % Continue the multi-line expression started above.
                                        result(all_needs_satisfied)))) :-
    % Succeed only if 'most_urgent_need(Agent, _, _, _' cannot be proved (negation as failure).
    \+ most_urgent_need(Agent, _, _, _).

% State a fact for 'mentova motivational' with the arguments listed below.
mentova_motivational(all_drives(Agent), drives(Agent, Drives),
                     % Continue the multi-line expression started above.
                     just(motivational(agent(Agent),
                                        % Continue the multi-line expression started above.
                                        all_drives(Drives)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(D-U, drive(Agent, D, U), Drives).

% State a fact for 'mentova motivational' with the arguments listed below.
mentova_motivational(satisfied_needs(Agent), satisfied_list(Agent, Levels),
                     % Continue the multi-line expression started above.
                     just(motivational(agent(Agent),
                                        % Continue the multi-line expression started above.
                                        satisfied_needs(Levels)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(L-N, (satisfied(Agent, L), need(L, N, _)), Levels).
