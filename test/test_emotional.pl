/*  Mentova — Emotional Reasoning Test Suite  (Rung 44)

    Behavioural PLUnit suite for the pure appraisal-theory module
    src/mentova/emotional.pl. Every expected value below is computed by
    hand from the module's own emotion_rule/5, situation_appraisal/4, and
    valence/2 facts; no live server, network, or game data is required.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" test/test_emotional.pl
*/

% Declare this file as a test module that exports nothing.
:- module(test_emotional, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the emotional module under test from the library path.
:- use_module(library(emotional)).

% Open the test block for the emotional module.
:- begin_tests(emotional).

% A single goal_congruent + uncertain appraisal derives hope, with the glass-box justification.
test(appraise_uncertain_outcome_is_hope) :-
    % Appraise alice facing an uncertain outcome.
    mentova_emotional(appraise(alice, uncertain_outcome), Result, Justification),
    % The one matching emotion rule (goal_congruent, uncertain) yields hope / medium / approach.
    assertion(Result == emotion(hope, medium, approach)),
    % The justification names the agent, situation, appraisal dimensions, and derived emotion.
    assertion(Justification == just(emotional(agent(alice),
                                              situation(uncertain_outcome),
                                              appraisal(goal_congruent, uncertain),
                                              emotion(hope),
                                              intensity(medium),
                                              tendency(approach)))).

% An ambiguous appraisal backtracks over every matching emotion rule.
test(appraise_backtracks_over_ambiguous_rules) :-
    % Collect every emotion Bob's uncertain threat could produce (goal_incongruent, uncertain).
    findall(emotion(E, I, T),
            mentova_emotional(appraise(bob, threat_detected), emotion(E, I, T), _),
            Emotions),
    % The fear rule is one admissible reading.
    assertion(memberchk(emotion(fear, high, avoidance), Emotions)),
    % The anxiety rule is the other admissible reading.
    assertion(memberchk(emotion(anxiety, medium, vigilance), Emotions)),
    % Exactly those two rules match, so the solution set has two members.
    length(Emotions, Count),
    % Confirm the count is two.
    assertion(Count =:= 2).

% A valence lookup of a negative emotion returns its polarity and a justification.
test(valence_lookup_negative) :-
    % Look up the valence of anger.
    mentova_emotional(valence(anger), Result, Justification),
    % Anger is a negative emotion.
    assertion(Result == valence(anger, negative)),
    % The justification records the lookup and the value.
    assertion(Justification == just(emotional(valence_lookup(anger), value(negative)))).

% A valence lookup of a positive emotion returns positive polarity.
test(valence_lookup_positive) :-
    % Look up the valence of joy.
    mentova_emotional(valence(joy), Result, _),
    % Joy is a positive emotion.
    assertion(Result == valence(joy, positive)).

% how_might_feel deterministically profiles a goal-congruent win as high positive joy.
test(how_might_feel_win_is_positive_joy) :-
    % Profile how alice might feel on winning the competition (goal_congruent, certain).
    mentova_emotional(how_might_feel(alice, win_competition), Result, _),
    % The first matching rule gives joy / high, and joy has positive valence.
    assertion(Result == emotion_profile(joy, high, positive)).

% how_might_feel profiles a goal-incongruent loss as high negative sadness.
test(how_might_feel_loss_is_negative_sadness) :-
    % Profile how alice might feel on losing the competition (goal_incongruent, certain).
    mentova_emotional(how_might_feel(alice, lose_competition), Result, _),
    % The first matching rule gives sadness / high, and sadness has negative valence.
    assertion(Result == emotion_profile(sadness, high, negative)).

% response_tendency reads the action tendency from a single-rule appraisal.
test(response_tendency_uncertain_outcome_is_approach) :-
    % Ask for alice's response tendency toward an uncertain outcome.
    mentova_emotional(response_tendency(alice, uncertain_outcome), Result, _),
    % The hope rule (the only match) carries an approach tendency.
    assertion(Result == tendency(approach)).

% situations_for lists exactly the situations registered for each agent, in file order.
test(situations_for_lists_all_situations) :-
    % Gather every situation appraised for alice.
    mentova_emotional(situations_for(alice), AliceResult, _),
    % Alice's four situations appear in declaration order.
    assertion(AliceResult == situations(alice,
                                        [win_competition, lose_competition,
                                         uncertain_outcome, friend_helps])),
    % Gather every situation appraised for bob.
    mentova_emotional(situations_for(bob), BobResult, _),
    % Bob's four situations appear in declaration order.
    assertion(BobResult == situations(bob,
                                      [threat_detected, insult_received,
                                       exam_tomorrow, pass_exam])).

% An appraisal of an unregistered situation has no reading and fails cleanly.
test(unknown_situation_has_no_appraisal, [fail]) :-
    % There is no situation_appraisal fact for this situation, so the query must fail.
    mentova_emotional(appraise(alice, no_such_situation), _, _).

% Close the test block for the emotional module.
:- end_tests(emotional).
