/*  Mentova — Rung 43: Intuitive Reasoning Module

    Implements fast, prototype-based pattern recognition.
    Intuitive reasoning bypasses full deliberation and instead matches
    an input profile to the closest prototype, returning a rapid answer.
    Pass criterion: given a feature profile, return the matching prototype
    and confidence without step-by-step deliberation.
*/

% Declare this file as the 'intuitive' module and list its exported predicates.
:- module(intuitive, [
    % Supply 'mentova_intuitive/3' as the next argument to the expression above.
    mentova_intuitive/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Prototypes: prototype(Category, FeatureList, Exemplar)
% ---------------------------------------------------------------------------

% State the fact: prototype(bird, [has_wings, has_feathers, can_fly, lays_eggs],      robin).
prototype(bird, [has_wings, has_feathers, can_fly, lays_eggs],      robin).
% State the fact: prototype(fish, [has_fins, breathes_water, cold_blooded, lays_eggs], salmon).
prototype(fish, [has_fins, breathes_water, cold_blooded, lays_eggs], salmon).
% State the fact: prototype(mammal, [warm_blooded, has_fur, live_birth, nurses_young], dog).
prototype(mammal, [warm_blooded, has_fur, live_birth, nurses_young], dog).
% State the fact: prototype(reptile, [cold_blooded, has_scales, lays_eggs, crawls],   lizard).
prototype(reptile, [cold_blooded, has_scales, lays_eggs, crawls],   lizard).
% State the fact: prototype(insect, [six_legs, has_exoskeleton, has_antennae],         ant).
prototype(insect, [six_legs, has_exoskeleton, has_antennae],         ant).

% State the fact: prototype(fruit, [sweet, edible, has_seeds, grows_on_plant],         apple).
prototype(fruit, [sweet, edible, has_seeds, grows_on_plant],         apple).
% State the fact: prototype(vegetable, [savoury, edible, not_sweet, grows_in_soil],    carrot).
prototype(vegetable, [savoury, edible, not_sweet, grows_in_soil],    carrot).

% State the fact: prototype(vehicle, [has_wheels, carries_people, mechanical],         car).
prototype(vehicle, [has_wheels, carries_people, mechanical],         car).
% State the fact: prototype(aircraft, [has_wings, flies, carries_people],              aeroplane).
prototype(aircraft, [has_wings, flies, carries_people],              aeroplane).
% State the fact: prototype(vessel, [floats, carries_cargo, on_water],                 ship).
prototype(vessel, [floats, carries_cargo, on_water],                 ship).

% ---------------------------------------------------------------------------
% Feature match score: count matching features
% ---------------------------------------------------------------------------

% Define a clause for 'match score': succeed when the following conditions hold.
match_score(Profile, ProtoFeatures, Score) :-
    % State a fact for 'include' with the arguments listed below.
    include([F]>>(member(F, Profile)), ProtoFeatures, Matched),
    % Unify 'M' with the number of elements in list 'Matched'.
    length(Matched, M),
    % Unify 'Total' with the number of elements in list 'ProtoFeatures'.
    length(ProtoFeatures, Total),
    % Check that '( Total' is greater than '0 -> Score is M / Total ; Score is 0.0 )'.
    ( Total > 0 -> Score is M / Total ; Score is 0.0 ).

% ---------------------------------------------------------------------------
% Best match: highest score among all prototypes
% ---------------------------------------------------------------------------

% Define a clause for 'best match': succeed when the following conditions hold.
best_match(Profile, Category, Exemplar, Score) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(S-C-E,
            % Continue the multi-line expression started above.
            (prototype(C, PF, E), match_score(Profile, PF, S)),
            % Supply 'Triples' as the next argument to the expression above.
            Triples),
    % Sort list 'Triples' into 'Sorted', keeping duplicates.
    msort(Triples, Sorted),
    % Unify the second argument with the last element of list 'Sorted'.
    last(Sorted, Score-Category-Exemplar),
    % Check that 'Score' is greater than '0.0'.
    Score > 0.0.

% ---------------------------------------------------------------------------
% Gut reaction: match on minimal cues (just 1-2 features)
% ---------------------------------------------------------------------------

% Define a clause for 'gut reaction': succeed when the following conditions hold.
gut_reaction(Profile, Category, Reason) :-
    % Succeed for each element 'F' that is a member of the list.
    member(F, Profile),
    % State a fact for 'prototype' with the arguments listed below.
    prototype(Category, PF, _),
    % Succeed for each element 'F' that is a member of the list.
    member(F, PF), !,
    % Check that 'Reason' is unifiable with 'triggered_by(F)'.
    Reason = triggered_by(F).

% ---------------------------------------------------------------------------
% mentova_intuitive(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova intuitive' with the arguments listed below.
mentova_intuitive(classify(Profile), match(Category, Exemplar, confidence(Score)),
                  % Continue the multi-line expression started above.
                  just(intuitive(prototype_match(Profile),
                                  % Continue the multi-line expression started above.
                                  category(Category),
                                  % Continue the multi-line expression started above.
                                  exemplar(Exemplar),
                                  % Continue the multi-line expression started above.
                                  score(Score)))) :-
    % State the fact: best match(Profile, Category, Exemplar, Score).
    best_match(Profile, Category, Exemplar, Score).

% State a fact for 'mentova intuitive' with the arguments listed below.
mentova_intuitive(gut(Profile), gut(Category, Reason),
                  % Continue the multi-line expression started above.
                  just(intuitive(gut_reaction(Profile),
                                  % Continue the multi-line expression started above.
                                  category(Category),
                                  % Continue the multi-line expression started above.
                                  trigger(Reason)))) :-
    % State the fact: gut reaction(Profile, Category, Reason).
    gut_reaction(Profile, Category, Reason).

% State a fact for 'mentova intuitive' with the arguments listed below.
mentova_intuitive(prototypes, all(Cats),
                  % Continue the multi-line expression started above.
                  just(intuitive(available_prototypes, list(Cats)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(C-E, prototype(C, _, E), Cats).

% State a fact for 'mentova intuitive' with the arguments listed below.
mentova_intuitive(match_detail(Profile, Category), detail(Category, Score, Matched),
                  % Continue the multi-line expression started above.
                  just(intuitive(detail_match(Profile, Category),
                                  % Continue the multi-line expression started above.
                                  score(Score), matched(Matched)))) :-
    % State a fact for 'prototype' with the arguments listed below.
    prototype(Category, PF, _),
    % State a fact for 'include' with the arguments listed below.
    include([F]>>(member(F, Profile)), PF, Matched),
    % Unify 'M' with the number of elements in list 'Matched'.
    length(Matched, M),
    % Unify 'Total' with the number of elements in list 'PF'.
    length(PF, Total),
    % Evaluate the arithmetic expression 'M / Total' and bind the result to 'Score'.
    Score is M / Total.
