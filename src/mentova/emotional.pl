/*  Mentova — Rung 44: Emotional Reasoning Module

    Reasons about emotions using cognitive appraisal theory.
    Given a situation and an agent's goals, returns the likely emotion,
    intensity, and suggested response tendency.
    Pass criterion: correctly identifies the emotion resulting from a
    goal-relevant situation and names the appraisal dimensions.
*/

% Declare this file as the 'emotional' module and list its exported predicates.
:- module(emotional, [
    % Supply 'mentova_emotional/3' as the next argument to the expression above.
    mentova_emotional/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Appraisal rules: emotion(Situation, Goal, Outcome, Emotion, Intensity, Tendency)
% Appraisal dimensions: goal_congruent/goal_incongruent, certain/uncertain
% ---------------------------------------------------------------------------

% State the fact: emotion rule(goal_congruent,  certain,   joy,       high,   approach).
emotion_rule(goal_congruent,  certain,   joy,       high,   approach).
% State the fact: emotion rule(goal_congruent,  uncertain, hope,      medium, approach).
emotion_rule(goal_congruent,  uncertain, hope,      medium, approach).
% State the fact: emotion rule(goal_incongruent, certain,  sadness,   high,   withdrawal).
emotion_rule(goal_incongruent, certain,  sadness,   high,   withdrawal).
% State the fact: emotion rule(goal_incongruent, uncertain, fear,     high,   avoidance).
emotion_rule(goal_incongruent, uncertain, fear,     high,   avoidance).
% State the fact: emotion rule(goal_incongruent, certain,  anger,     high,   aggression).
emotion_rule(goal_incongruent, certain,  anger,     high,   aggression).
% State the fact: emotion rule(goal_congruent,  certain,   gratitude, medium, prosocial).
emotion_rule(goal_congruent,  certain,   gratitude, medium, prosocial).
% State the fact: emotion rule(goal_incongruent, uncertain, anxiety,  medium, vigilance).
emotion_rule(goal_incongruent, uncertain, anxiety,  medium, vigilance).

% Situation appraisals: appraisal(Situation, Agent, GoalCongruence, Certainty)
% State the fact: situation appraisal(win_competition,    alice, goal_congruent,   certain).
situation_appraisal(win_competition,    alice, goal_congruent,   certain).
% State the fact: situation appraisal(lose_competition,   alice, goal_incongruent, certain).
situation_appraisal(lose_competition,   alice, goal_incongruent, certain).
% State the fact: situation appraisal(uncertain_outcome,  alice, goal_congruent,   uncertain).
situation_appraisal(uncertain_outcome,  alice, goal_congruent,   uncertain).
% State the fact: situation appraisal(threat_detected,    bob,   goal_incongruent, uncertain).
situation_appraisal(threat_detected,    bob,   goal_incongruent, uncertain).
% State the fact: situation appraisal(insult_received,    bob,   goal_incongruent, certain).
situation_appraisal(insult_received,    bob,   goal_incongruent, certain).
% State the fact: situation appraisal(gift_received,      carol, goal_congruent,   certain).
situation_appraisal(gift_received,      carol, goal_congruent,   certain).
% State the fact: situation appraisal(friend_helps,       alice, goal_congruent,   certain).
situation_appraisal(friend_helps,       alice, goal_congruent,   certain).
% State the fact: situation appraisal(exam_tomorrow,      bob,   goal_incongruent, uncertain).
situation_appraisal(exam_tomorrow,      bob,   goal_incongruent, uncertain).
% State the fact: situation appraisal(pass_exam,          bob,   goal_congruent,   certain).
situation_appraisal(pass_exam,          bob,   goal_congruent,   certain).

% Valence: positive or negative
% State the fact: valence(joy,      positive).
valence(joy,      positive).
% State the fact: valence(hope,     positive).
valence(hope,     positive).
% State the fact: valence(sadness,  negative).
valence(sadness,  negative).
% State the fact: valence(fear,     negative).
valence(fear,     negative).
% State the fact: valence(anger,    negative).
valence(anger,    negative).
% State the fact: valence(gratitude, positive).
valence(gratitude, positive).
% State the fact: valence(anxiety,  negative).
valence(anxiety,  negative).

% ---------------------------------------------------------------------------
% Derive emotion from appraisal
% ---------------------------------------------------------------------------

% Define a clause for 'derive emotion': succeed when the following conditions hold.
derive_emotion(Situation, Agent, Emotion, Intensity, Tendency) :-
    % State a fact for 'situation appraisal' with the arguments listed below.
    situation_appraisal(Situation, Agent, GoalCong, Certainty),
    % State the fact: emotion rule(GoalCong, Certainty, Emotion, Intensity, Tendency).
    emotion_rule(GoalCong, Certainty, Emotion, Intensity, Tendency).

% ---------------------------------------------------------------------------
% mentova_emotional(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova emotional' with the arguments listed below.
mentova_emotional(appraise(Agent, Situation), emotion(Emotion, Intensity, Tendency),
                  % Continue the multi-line expression started above.
                  just(emotional(agent(Agent),
                                  % Continue the multi-line expression started above.
                                  situation(Situation),
                                  % Continue the multi-line expression started above.
                                  appraisal(GoalCong, Certainty),
                                  % Continue the multi-line expression started above.
                                  emotion(Emotion),
                                  % Continue the multi-line expression started above.
                                  intensity(Intensity),
                                  % Continue the multi-line expression started above.
                                  tendency(Tendency)))) :-
    % State a fact for 'situation appraisal' with the arguments listed below.
    situation_appraisal(Situation, Agent, GoalCong, Certainty),
    % State the fact: emotion rule(GoalCong, Certainty, Emotion, Intensity, Tendency).
    emotion_rule(GoalCong, Certainty, Emotion, Intensity, Tendency).

% State a fact for 'mentova emotional' with the arguments listed below.
mentova_emotional(valence(Emotion), valence(Emotion, Val),
                  % Continue the multi-line expression started above.
                  just(emotional(valence_lookup(Emotion), value(Val)))) :-
    % State a fact for 'valence' with the arguments listed below.
    valence(Emotion, Val), !.

% State a fact for 'mentova emotional' with the arguments listed below.
mentova_emotional(how_might_feel(Agent, Situation), emotion_profile(Emotion, Intensity, Valence),
                  % Continue the multi-line expression started above.
                  just(emotional(profile(Agent, Situation),
                                  % Continue the multi-line expression started above.
                                  emotion(Emotion),
                                  % Continue the multi-line expression started above.
                                  intensity(Intensity),
                                  % Continue the multi-line expression started above.
                                  valence(Valence)))) :-
    % State a fact for 'derive emotion' with the arguments listed below.
    derive_emotion(Situation, Agent, Emotion, Intensity, _),
    % State a fact for 'valence' with the arguments listed below.
    valence(Emotion, Valence), !.

% State a fact for 'mentova emotional' with the arguments listed below.
mentova_emotional(response_tendency(Agent, Situation), tendency(Tendency),
                  % Continue the multi-line expression started above.
                  just(emotional(tendency(Agent, Situation), result(Tendency)))) :-
    % State the fact: derive emotion(Situation, Agent, _, _, Tendency).
    derive_emotion(Situation, Agent, _, _, Tendency).

% State a fact for 'mentova emotional' with the arguments listed below.
mentova_emotional(situations_for(Agent), situations(Agent, Sits),
                  % Continue the multi-line expression started above.
                  just(emotional(situation_list(Agent), list(Sits)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(S, situation_appraisal(S, Agent, _, _), Sits).
