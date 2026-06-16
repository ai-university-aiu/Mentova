/*  Mentova — Rung 34: Epistemic Reasoning Module

    Reasons about what agents know, believe, and are ignorant of.
    Uses the Small-World believes/3 facts and adds explicit knowledge facts.
    Pass criterion: correctly distinguish what is known from what is merely
    believed, and identify ignorance of a proposition.
*/

% Declare this file as the 'epistemic' module and list its exported predicates.
:- module(epistemic, [
    % Supply 'mentova_epistemic/3' as the next argument to the expression above.
    mentova_epistemic/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).
% Import [believes/3] from the 'small_world' module.
:- use_module('../../knowledge/small_world', [believes/3]).

% ---------------------------------------------------------------------------
% Explicit knowledge facts: knows(Agent, Fact, Confidence)
% Distinction: knows = justified true belief; believes = may be unjustified
% ---------------------------------------------------------------------------

% State the fact: knows(mentor, birds_have_feathers,    1.0).
knows(mentor, birds_have_feathers,    1.0).
% State the fact: knows(mentor, canary_is_bird,         1.0).
knows(mentor, canary_is_bird,         1.0).
% State the fact: knows(mentor, water_boils_at_100c,    1.0).
knows(mentor, water_boils_at_100c,    1.0).
% State the fact: knows(mentor, fire_is_hot,            1.0).
knows(mentor, fire_is_hot,            1.0).

% State the fact: knows(alice,  canary_is_yellow,       0.9).
knows(alice,  canary_is_yellow,       0.9).
% State the fact: knows(alice,  tweety_is_canary,       0.8).
knows(alice,  tweety_is_canary,       0.8).
% State the fact: knows(alice,  cats_eat_birds,         0.7).
knows(alice,  cats_eat_birds,         0.7).

% State the fact: knows(bob,    dogs_bark,              1.0).
knows(bob,    dogs_bark,              1.0).
% State the fact: knows(bob,    cats_meow,              1.0).
knows(bob,    cats_meow,              1.0).

% Ignorance: agent has no knowledge or belief about a proposition
% Define a clause for 'ignorant': succeed when the following conditions hold.
ignorant(Agent, Fact) :-
    % Succeed only if 'knows(Agent, Fact, _' cannot be proved (negation as failure).
    \+ knows(Agent, Fact, _),
    % Succeed only if 'believes(Agent, Fact, _' cannot be proved (negation as failure).
    \+ believes(Agent, Fact, _).

% ---------------------------------------------------------------------------
% Common knowledge (all agents know P)
% ---------------------------------------------------------------------------

% State the fact: all agents([mentor, alice, bob]).
all_agents([mentor, alice, bob]).

% Define a clause for 'common knowledge': succeed when the following conditions hold.
common_knowledge(Fact) :-
    % State a fact for 'all agents' with the arguments listed below.
    all_agents(Agents),
    % Verify that for every solution of the Condition, the Action also holds.
    forall(member(A, Agents), knows(A, Fact, _)).

% ---------------------------------------------------------------------------
% mentova_epistemic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova epistemic' with the arguments listed below.
mentova_epistemic(knows(Agent, Fact), knows(Agent, Fact, Conf),
                  % Continue the multi-line expression started above.
                  just(epistemic(knowledge(Agent, Fact), confidence(Conf)))) :-
    % State a fact for 'knows' with the arguments listed below.
    knows(Agent, Fact, Conf), !.

% State a fact for 'mentova epistemic' with the arguments listed below.
mentova_epistemic(knows(Agent, Fact), does_not_know(Agent, Fact),
                  % Continue the multi-line expression started above.
                  just(epistemic(knowledge(Agent, Fact), status(no_knowledge_fact)))) :-
    % Succeed only if 'knows(Agent, Fact, _' cannot be proved (negation as failure).
    \+ knows(Agent, Fact, _).

% State a fact for 'mentova epistemic' with the arguments listed below.
mentova_epistemic(believes(Agent, Fact), believes(Agent, Fact, Conf),
                  % Continue the multi-line expression started above.
                  just(epistemic(belief(Agent, Fact), confidence(Conf)))) :-
    % State a fact for 'believes' with the arguments listed below.
    believes(Agent, Fact, Conf), !.

% State a fact for 'mentova epistemic' with the arguments listed below.
mentova_epistemic(believes(Agent, Fact), does_not_believe(Agent, Fact),
                  % Continue the multi-line expression started above.
                  just(epistemic(belief(Agent, Fact), status(no_belief_fact)))) :-
    % Succeed only if 'believes(Agent, Fact, _' cannot be proved (negation as failure).
    \+ believes(Agent, Fact, _).

% State a fact for 'mentova epistemic' with the arguments listed below.
mentova_epistemic(ignorant(Agent, Fact), ignorant(Agent, Fact),
                  % Continue the multi-line expression started above.
                  just(epistemic(ignorance(Agent, Fact),
                                  % Continue the multi-line expression started above.
                                  reason(no_knowledge_or_belief)))) :-
    % State a fact for 'ignorant' with the arguments listed below.
    ignorant(Agent, Fact), !.

% State a fact for 'mentova epistemic' with the arguments listed below.
mentova_epistemic(ignorant(Agent, Fact), not_ignorant(Agent, Fact),
                  % Continue the multi-line expression started above.
                  just(epistemic(ignorance_check(Agent, Fact),
                                  % Continue the multi-line expression started above.
                                  result(has_knowledge_or_belief)))) :-
    % Succeed only if 'ignorant(Agent, Fact' cannot be proved (negation as failure).
    \+ ignorant(Agent, Fact).

% State a fact for 'mentova epistemic' with the arguments listed below.
mentova_epistemic(common_knowledge(Fact), common(Fact),
                  % Continue the multi-line expression started above.
                  just(epistemic(common_knowledge(Fact),
                                  % Continue the multi-line expression started above.
                                  agents_checked(all)))) :-
    % State a fact for 'common knowledge' with the arguments listed below.
    common_knowledge(Fact), !.

% State a fact for 'mentova epistemic' with the arguments listed below.
mentova_epistemic(common_knowledge(Fact), not_common(Fact),
                  % Continue the multi-line expression started above.
                  just(epistemic(common_knowledge(Fact),
                                  % Continue the multi-line expression started above.
                                  result(not_universally_known)))) :-
    % Succeed only if 'common_knowledge(Fact' cannot be proved (negation as failure).
    \+ common_knowledge(Fact).

% State a fact for 'mentova epistemic' with the arguments listed below.
mentova_epistemic(what_does(Agent, know), knowledge(Agent, Facts),
                  % Continue the multi-line expression started above.
                  just(epistemic(knowledge_inventory(Agent), facts(Facts)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(F-C, knows(Agent, F, C), Facts).

% false_belief(+Agent, +Prop): agent believes Prop=true but another agent believes Prop=false
% This is the Sally-Anne test: Sally believes marble_in_basket=true;
% Anne (who moved it) believes marble_in_basket=false.
% State a fact for 'mentova epistemic' with the arguments listed below.
mentova_epistemic(false_belief(Agent, Prop), false_belief(Agent, Prop, their_belief(V), others_differ),
                  % Continue the multi-line expression started above.
                  just(epistemic(false_belief_test(Agent, Prop),
                                  % Continue the multi-line expression started above.
                                  agent_believes(V),
                                  % Continue the multi-line expression started above.
                                  note('Agent holds belief others contradict')))) :-
    % State a fact for 'believes' with the arguments listed below.
    believes(Agent, Prop, V),
    % Check that 'findall(O-OV, (believes(O, Prop, OV), O' is not unifiable with 'Agent, OV \= V), Dissenters)'.
    findall(O-OV, (believes(O, Prop, OV), O \= Agent, OV \= V), Dissenters),
    % Check that 'Dissenters' is not unifiable with '[]'.
    Dissenters \= [].
