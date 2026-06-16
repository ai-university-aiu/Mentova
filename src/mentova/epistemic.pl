/*  Mentova — Rung 34: Epistemic Reasoning Module

    Reasons about what agents know, believe, and are ignorant of.
    Uses the Small-World believes/3 facts and adds explicit knowledge facts.
    Pass criterion: correctly distinguish what is known from what is merely
    believed, and identify ignorance of a proposition.
*/

:- module(epistemic, [
    mentova_epistemic/3
]).

:- use_module(library(lists), [member/2]).
:- use_module('../../knowledge/small_world', [believes/3]).

% ---------------------------------------------------------------------------
% Explicit knowledge facts: knows(Agent, Fact, Confidence)
% Distinction: knows = justified true belief; believes = may be unjustified
% ---------------------------------------------------------------------------

knows(mentor, birds_have_feathers,    1.0).
knows(mentor, canary_is_bird,         1.0).
knows(mentor, water_boils_at_100c,    1.0).
knows(mentor, fire_is_hot,            1.0).

knows(alice,  canary_is_yellow,       0.9).
knows(alice,  tweety_is_canary,       0.8).
knows(alice,  cats_eat_birds,         0.7).

knows(bob,    dogs_bark,              1.0).
knows(bob,    cats_meow,              1.0).

% Ignorance: agent has no knowledge or belief about a proposition
ignorant(Agent, Fact) :-
    \+ knows(Agent, Fact, _),
    \+ believes(Agent, Fact, _).

% ---------------------------------------------------------------------------
% Common knowledge (all agents know P)
% ---------------------------------------------------------------------------

all_agents([mentor, alice, bob]).

common_knowledge(Fact) :-
    all_agents(Agents),
    forall(member(A, Agents), knows(A, Fact, _)).

% ---------------------------------------------------------------------------
% mentova_epistemic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_epistemic(knows(Agent, Fact), knows(Agent, Fact, Conf),
                  just(epistemic(knowledge(Agent, Fact), confidence(Conf)))) :-
    knows(Agent, Fact, Conf), !.

mentova_epistemic(knows(Agent, Fact), does_not_know(Agent, Fact),
                  just(epistemic(knowledge(Agent, Fact), status(no_knowledge_fact)))) :-
    \+ knows(Agent, Fact, _).

mentova_epistemic(believes(Agent, Fact), believes(Agent, Fact, Conf),
                  just(epistemic(belief(Agent, Fact), confidence(Conf)))) :-
    believes(Agent, Fact, Conf), !.

mentova_epistemic(believes(Agent, Fact), does_not_believe(Agent, Fact),
                  just(epistemic(belief(Agent, Fact), status(no_belief_fact)))) :-
    \+ believes(Agent, Fact, _).

mentova_epistemic(ignorant(Agent, Fact), ignorant(Agent, Fact),
                  just(epistemic(ignorance(Agent, Fact),
                                  reason(no_knowledge_or_belief)))) :-
    ignorant(Agent, Fact), !.

mentova_epistemic(ignorant(Agent, Fact), not_ignorant(Agent, Fact),
                  just(epistemic(ignorance_check(Agent, Fact),
                                  result(has_knowledge_or_belief)))) :-
    \+ ignorant(Agent, Fact).

mentova_epistemic(common_knowledge(Fact), common(Fact),
                  just(epistemic(common_knowledge(Fact),
                                  agents_checked(all)))) :-
    common_knowledge(Fact), !.

mentova_epistemic(common_knowledge(Fact), not_common(Fact),
                  just(epistemic(common_knowledge(Fact),
                                  result(not_universally_known)))) :-
    \+ common_knowledge(Fact).

mentova_epistemic(what_does(Agent, know), knowledge(Agent, Facts),
                  just(epistemic(knowledge_inventory(Agent), facts(Facts)))) :-
    findall(F-C, knows(Agent, F, C), Facts).

% false_belief(+Agent, +Prop): agent believes Prop=true but another agent believes Prop=false
% This is the Sally-Anne test: Sally believes marble_in_basket=true;
% Anne (who moved it) believes marble_in_basket=false.
mentova_epistemic(false_belief(Agent, Prop), false_belief(Agent, Prop, their_belief(V), others_differ),
                  just(epistemic(false_belief_test(Agent, Prop),
                                  agent_believes(V),
                                  note('Agent holds belief others contradict')))) :-
    believes(Agent, Prop, V),
    findall(O-OV, (believes(O, Prop, OV), O \= Agent, OV \= V), Dissenters),
    Dissenters \= [].
