/*  Mentova — Rung 44: Emotional Reasoning Module

    Reasons about emotions using cognitive appraisal theory.
    Given a situation and an agent's goals, returns the likely emotion,
    intensity, and suggested response tendency.
    Pass criterion: correctly identifies the emotion resulting from a
    goal-relevant situation and names the appraisal dimensions.
*/

:- module(emotional, [
    mentova_emotional/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Appraisal rules: emotion(Situation, Goal, Outcome, Emotion, Intensity, Tendency)
% Appraisal dimensions: goal_congruent/goal_incongruent, certain/uncertain
% ---------------------------------------------------------------------------

emotion_rule(goal_congruent,  certain,   joy,       high,   approach).
emotion_rule(goal_congruent,  uncertain, hope,      medium, approach).
emotion_rule(goal_incongruent, certain,  sadness,   high,   withdrawal).
emotion_rule(goal_incongruent, uncertain, fear,     high,   avoidance).
emotion_rule(goal_incongruent, certain,  anger,     high,   aggression).
emotion_rule(goal_congruent,  certain,   gratitude, medium, prosocial).
emotion_rule(goal_incongruent, uncertain, anxiety,  medium, vigilance).

% Situation appraisals: appraisal(Situation, Agent, GoalCongruence, Certainty)
situation_appraisal(win_competition,    alice, goal_congruent,   certain).
situation_appraisal(lose_competition,   alice, goal_incongruent, certain).
situation_appraisal(uncertain_outcome,  alice, goal_congruent,   uncertain).
situation_appraisal(threat_detected,    bob,   goal_incongruent, uncertain).
situation_appraisal(insult_received,    bob,   goal_incongruent, certain).
situation_appraisal(gift_received,      carol, goal_congruent,   certain).
situation_appraisal(friend_helps,       alice, goal_congruent,   certain).
situation_appraisal(exam_tomorrow,      bob,   goal_incongruent, uncertain).
situation_appraisal(pass_exam,          bob,   goal_congruent,   certain).

% Valence: positive or negative
valence(joy,      positive).
valence(hope,     positive).
valence(sadness,  negative).
valence(fear,     negative).
valence(anger,    negative).
valence(gratitude, positive).
valence(anxiety,  negative).

% ---------------------------------------------------------------------------
% Derive emotion from appraisal
% ---------------------------------------------------------------------------

derive_emotion(Situation, Agent, Emotion, Intensity, Tendency) :-
    situation_appraisal(Situation, Agent, GoalCong, Certainty),
    emotion_rule(GoalCong, Certainty, Emotion, Intensity, Tendency).

% ---------------------------------------------------------------------------
% mentova_emotional(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_emotional(appraise(Agent, Situation), emotion(Emotion, Intensity, Tendency),
                  just(emotional(agent(Agent),
                                  situation(Situation),
                                  appraisal(GoalCong, Certainty),
                                  emotion(Emotion),
                                  intensity(Intensity),
                                  tendency(Tendency)))) :-
    situation_appraisal(Situation, Agent, GoalCong, Certainty),
    emotion_rule(GoalCong, Certainty, Emotion, Intensity, Tendency).

mentova_emotional(valence(Emotion), valence(Emotion, Val),
                  just(emotional(valence_lookup(Emotion), value(Val)))) :-
    valence(Emotion, Val), !.

mentova_emotional(how_might_feel(Agent, Situation), emotion_profile(Emotion, Intensity, Valence),
                  just(emotional(profile(Agent, Situation),
                                  emotion(Emotion),
                                  intensity(Intensity),
                                  valence(Valence)))) :-
    derive_emotion(Situation, Agent, Emotion, Intensity, _),
    valence(Emotion, Valence), !.

mentova_emotional(response_tendency(Agent, Situation), tendency(Tendency),
                  just(emotional(tendency(Agent, Situation), result(Tendency)))) :-
    derive_emotion(Situation, Agent, _, _, Tendency).

mentova_emotional(situations_for(Agent), situations(Agent, Sits),
                  just(emotional(situation_list(Agent), list(Sits)))) :-
    findall(S, situation_appraisal(S, Agent, _, _), Sits).
