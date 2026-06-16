/*  Mentova — Rung 43: Intuitive Reasoning Module

    Implements fast, prototype-based pattern recognition.
    Intuitive reasoning bypasses full deliberation and instead matches
    an input profile to the closest prototype, returning a rapid answer.
    Pass criterion: given a feature profile, return the matching prototype
    and confidence without step-by-step deliberation.
*/

:- module(intuitive, [
    mentova_intuitive/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Prototypes: prototype(Category, FeatureList, Exemplar)
% ---------------------------------------------------------------------------

prototype(bird, [has_wings, has_feathers, can_fly, lays_eggs],      robin).
prototype(fish, [has_fins, breathes_water, cold_blooded, lays_eggs], salmon).
prototype(mammal, [warm_blooded, has_fur, live_birth, nurses_young], dog).
prototype(reptile, [cold_blooded, has_scales, lays_eggs, crawls],   lizard).
prototype(insect, [six_legs, has_exoskeleton, has_antennae],         ant).

prototype(fruit, [sweet, edible, has_seeds, grows_on_plant],         apple).
prototype(vegetable, [savoury, edible, not_sweet, grows_in_soil],    carrot).

prototype(vehicle, [has_wheels, carries_people, mechanical],         car).
prototype(aircraft, [has_wings, flies, carries_people],              aeroplane).
prototype(vessel, [floats, carries_cargo, on_water],                 ship).

% ---------------------------------------------------------------------------
% Feature match score: count matching features
% ---------------------------------------------------------------------------

match_score(Profile, ProtoFeatures, Score) :-
    include([F]>>(member(F, Profile)), ProtoFeatures, Matched),
    length(Matched, M),
    length(ProtoFeatures, Total),
    ( Total > 0 -> Score is M / Total ; Score is 0.0 ).

% ---------------------------------------------------------------------------
% Best match: highest score among all prototypes
% ---------------------------------------------------------------------------

best_match(Profile, Category, Exemplar, Score) :-
    findall(S-C-E,
            (prototype(C, PF, E), match_score(Profile, PF, S)),
            Triples),
    msort(Triples, Sorted),
    last(Sorted, Score-Category-Exemplar),
    Score > 0.0.

% ---------------------------------------------------------------------------
% Gut reaction: match on minimal cues (just 1-2 features)
% ---------------------------------------------------------------------------

gut_reaction(Profile, Category, Reason) :-
    member(F, Profile),
    prototype(Category, PF, _),
    member(F, PF), !,
    Reason = triggered_by(F).

% ---------------------------------------------------------------------------
% mentova_intuitive(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_intuitive(classify(Profile), match(Category, Exemplar, confidence(Score)),
                  just(intuitive(prototype_match(Profile),
                                  category(Category),
                                  exemplar(Exemplar),
                                  score(Score)))) :-
    best_match(Profile, Category, Exemplar, Score).

mentova_intuitive(gut(Profile), gut(Category, Reason),
                  just(intuitive(gut_reaction(Profile),
                                  category(Category),
                                  trigger(Reason)))) :-
    gut_reaction(Profile, Category, Reason).

mentova_intuitive(prototypes, all(Cats),
                  just(intuitive(available_prototypes, list(Cats)))) :-
    findall(C-E, prototype(C, _, E), Cats).

mentova_intuitive(match_detail(Profile, Category), detail(Category, Score, Matched),
                  just(intuitive(detail_match(Profile, Category),
                                  score(Score), matched(Matched)))) :-
    prototype(Category, PF, _),
    include([F]>>(member(F, Profile)), PF, Matched),
    length(Matched, M),
    length(PF, Total),
    Score is M / Total.
