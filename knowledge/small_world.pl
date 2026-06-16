/*  Mentova — Small-World Commonsense Knowledge Base

    A curated, toy-sized knowledge base covering all 48 reasoning types.
    All facts are node_facts; every answer carries a readable justification.

    Layers:
        1. Taxonomic backbone      (IsA, part_of — from WordNet)
        2. Commonsense relations   (from ConceptNet)
        3. Authored rule layer     (defaults, exceptions, norms, modal facts)
        4. Probabilistic layer     (weighted facts, observation table)
        5. Agents-with-beliefs     (characters for theory of mind)
        6. Scenario layer          (story, puzzle, two-agent choice, dilemma)
*/

% Declare this file as the 'small_world' module and list its exported predicates.
:- module(small_world, [
    % Supply 'is_a/2' as the next argument to the expression above.
    is_a/2,
    % Supply 'part_of/2' as the next argument to the expression above.
    part_of/2,
    % Supply 'causes/2' as the next argument to the expression above.
    causes/2,
    % Supply 'used_for/2' as the next argument to the expression above.
    used_for/2,
    % Supply 'capable_of/2' as the next argument to the expression above.
    capable_of/2,
    % Supply 'has_property/2' as the next argument to the expression above.
    has_property/2,
    % Supply 'at_location/2' as the next argument to the expression above.
    at_location/2,
    % Supply 'motivated_by/2' as the next argument to the expression above.
    motivated_by/2,
    % Supply 'has_prerequisite/2' as the next argument to the expression above.
    has_prerequisite/2,
    % Supply 'default_rule/2' as the next argument to the expression above.
    default_rule/2,
    % Supply 'exception_rule/3' as the next argument to the expression above.
    exception_rule/3,
    % Supply 'norm/2' as the next argument to the expression above.
    norm/2,
    % Supply 'modal_fact/3' as the next argument to the expression above.
    modal_fact/3,
    % Supply 'prob_fact/2' as the next argument to the expression above.
    prob_fact/2,
    % Supply 'observation/3' as the next argument to the expression above.
    observation/3,
    % Supply 'believes/3' as the next argument to the expression above.
    believes/3,
    % Supply 'scenario/2' as the next argument to the expression above.
    scenario/2
% Close the expression opened above.
]).

% Allow 'is_a/2' clauses to appear at non-consecutive positions in this file.
:- discontiguous is_a/2.
% Allow 'has_property/2' clauses to appear at non-consecutive positions in this file.
:- discontiguous has_property/2.
% Declare 'is_a/2' as dynamic — its facts may be added or removed at runtime.
:- dynamic is_a/2.
% Declare 'has_property/2' as dynamic — its facts may be added or removed at runtime.
:- dynamic has_property/2.

% ---------------------------------------------------------------------------
% LAYER 1 — TAXONOMIC BACKBONE (IsA, part_of)
% ---------------------------------------------------------------------------

% State the fact: is a(canary,    bird).
is_a(canary,    bird).
% State the fact: is a(penguin,   bird).
is_a(penguin,   bird).
% State the fact: is a(eagle,     bird).
is_a(eagle,     bird).
% State the fact: is a(robin,     bird).
is_a(robin,     bird).
% State the fact: is a(bird,      animal).
is_a(bird,      animal).
% State the fact: is a(cat,       animal).
is_a(cat,       animal).
% State the fact: is a(dog,       animal).
is_a(dog,       animal).
% State the fact: is a(salmon,    fish).
is_a(salmon,    fish).
% State the fact: is a(fish,      animal).
is_a(fish,      animal).
% State the fact: is a(rose,      flower).
is_a(rose,      flower).
% State the fact: is a(daisy,     flower).
is_a(daisy,     flower).
% State the fact: is a(flower,    plant).
is_a(flower,    plant).
% State the fact: is a(oak,       tree).
is_a(oak,       tree).
% State the fact: is a(tree,      plant).
is_a(tree,      plant).
% State the fact: is a(plant,     living_thing).
is_a(plant,     living_thing).
% State the fact: is a(animal,    living_thing).
is_a(animal,    living_thing).
% State the fact: is a(apple,     fruit).
is_a(apple,     fruit).
% State the fact: is a(banana,    fruit).
is_a(banana,    fruit).
% State the fact: is a(fruit,     food).
is_a(fruit,     food).
% State the fact: is a(bread,     food).
is_a(bread,     food).
% State the fact: is a(knife,     tool).
is_a(knife,     tool).
% State the fact: is a(hammer,    tool).
is_a(hammer,    tool).
% State the fact: is a(chair,     furniture).
is_a(chair,     furniture).
% State the fact: is a(table,     furniture).
is_a(table,     furniture).
% State the fact: is a(car,       vehicle).
is_a(car,       vehicle).
% State the fact: is a(bicycle,   vehicle).
is_a(bicycle,   vehicle).
% State the fact: is a(water,     liquid).
is_a(water,     liquid).
% State the fact: is a(milk,      liquid).
is_a(milk,      liquid).

% State the fact: part of(wing,   bird).
part_of(wing,   bird).
% State the fact: part of(beak,   bird).
part_of(beak,   bird).
% State the fact: part of(leaf,   tree).
part_of(leaf,   tree).
% State the fact: part of(root,   plant).
part_of(root,   plant).
% State the fact: part of(petal,  flower).
part_of(petal,  flower).
% State the fact: part of(wheel,  car).
part_of(wheel,  car).
% State the fact: part of(wheel,  bicycle).
part_of(wheel,  bicycle).
% State the fact: part of(seat,   chair).
part_of(seat,   chair).
% State the fact: part of(leg,    table).
part_of(leg,    table).
% State the fact: part of(blade,  knife).
part_of(blade,  knife).

% ---------------------------------------------------------------------------
% LAYER 2 — COMMONSENSE RELATIONS (ConceptNet-style)
% ---------------------------------------------------------------------------

% State the fact: capable of(bird,    fly).
capable_of(bird,    fly).
% State the fact: capable of(eagle,   hunt).
capable_of(eagle,   hunt).
% State the fact: capable of(dog,     bark).
capable_of(dog,     bark).
% State the fact: capable of(cat,     climb).
capable_of(cat,     climb).
% State the fact: capable of(salmon,  swim).
capable_of(salmon,  swim).
% State the fact: capable of(car,     transport_people).
capable_of(car,     transport_people).
% State the fact: capable of(knife,   cut).
capable_of(knife,   cut).
% State the fact: capable of(hammer,  drive_nail).
capable_of(hammer,  drive_nail).

% State the fact: has property(canary,  yellow).
has_property(canary,  yellow).
% State the fact: has property(rose,    red).
has_property(rose,    red).
% State the fact: has property(daisy,   white).
has_property(daisy,   white).
% State the fact: has property(oak,     tall).
has_property(oak,     tall).
% State the fact: has property(water,   transparent).
has_property(water,   transparent).
% State the fact: has property(milk,    white).
has_property(milk,    white).
% State the fact: has property(penguin, flightless).
has_property(penguin, flightless).
% State the fact: has property(eagle,   large).
has_property(eagle,   large).

% State the fact: at location(fish,     water).
at_location(fish,     water).
% State the fact: at location(bird,     sky).
at_location(bird,     sky).
% State the fact: at location(penguin,  antarctica).
at_location(penguin,  antarctica).
% State the fact: at location(rose,     garden).
at_location(rose,     garden).
% State the fact: at location(oak,      forest).
at_location(oak,      forest).
% State the fact: at location(cat,      house).
at_location(cat,      house).

% State the fact: causes(rain,        wet_ground).
causes(rain,        wet_ground).
% State the fact: causes(sprinkler,   wet_ground).
causes(sprinkler,   wet_ground).
% State the fact: causes(fire,        smoke).
causes(fire,        smoke).
% State the fact: causes(hunger,      eating).
causes(hunger,      eating).
% State the fact: causes(exercise,    fatigue).
causes(exercise,    fatigue).
% State the fact: causes(illness,     fatigue).
causes(illness,     fatigue).
% State the fact: causes(sunlight,    plant_growth).
causes(sunlight,    plant_growth).

% State the fact: used for(knife,     cutting).
used_for(knife,     cutting).
% State the fact: used for(hammer,    building).
used_for(hammer,    building).
% State the fact: used for(chair,     sitting).
used_for(chair,     sitting).
% State the fact: used for(car,       travelling).
used_for(car,       travelling).
% State the fact: used for(water,     drinking).
used_for(water,     drinking).

% State the fact: motivated by(eating,    hunger).
motivated_by(eating,    hunger).
% State the fact: motivated by(sleeping,  fatigue).
motivated_by(sleeping,  fatigue).
% State the fact: motivated by(hunting,   hunger).
motivated_by(hunting,   hunger).

% State the fact: has prerequisite(flying,    having_wings).
has_prerequisite(flying,    having_wings).
% State the fact: has prerequisite(swimming,  being_in_water).
has_prerequisite(swimming,  being_in_water).
% State the fact: has prerequisite(driving,   having_licence).
has_prerequisite(driving,   having_licence).

% ---------------------------------------------------------------------------
% LAYER 3 — AUTHORED RULE LAYER (defaults, exceptions, norms, modal facts)
% ---------------------------------------------------------------------------

% Default rules: Head :- Condition (defeasible)
% State the fact: default rule(flies(X),      is_a(X, bird)).
default_rule(flies(X),      is_a(X, bird)).
% State the fact: default rule(has_fur(X),    is_a(X, mammal)).
default_rule(has_fur(X),    is_a(X, mammal)).
% State the fact: default rule(edible(X),     is_a(X, fruit)).
default_rule(edible(X),     is_a(X, fruit)).
% State the fact: default rule(is_wet(X),     at_location(X, water)).
default_rule(is_wet(X),     at_location(X, water)).

% Exception rules: exception(Head, ExceptionCondition, ExceptionNote)
% State the fact: exception rule(flies(X),    has_property(X, flightless), penguin_exception).
exception_rule(flies(X),    has_property(X, flightless), penguin_exception).
% State the fact: exception rule(flies(X),    is_a(X, fish),               fish_dont_fly).
exception_rule(flies(X),    is_a(X, fish),               fish_dont_fly).

% Norms (deontic)
% State the fact: norm(permitted,  eating_fruit).
norm(permitted,  eating_fruit).
% State the fact: norm(permitted,  drinking_water).
norm(permitted,  drinking_water).
% State the fact: norm(forbidden,  harming_animal).
norm(forbidden,  harming_animal).
% State the fact: norm(obligatory, feeding_pet).
norm(obligatory, feeding_pet).

% Modal facts: modal(Agent, Modality, Proposition)
%   Modality: necessarily | possibly | contingently
% State the fact: modal fact(world,  necessarily,   is_a(penguin, bird)).
modal_fact(world,  necessarily,   is_a(penguin, bird)).
% State the fact: modal fact(world,  possibly,      rains_today).
modal_fact(world,  possibly,      rains_today).
% State the fact: modal fact(world,  contingently,  cat_in_garden).
modal_fact(world,  contingently,  cat_in_garden).

% Deliberate paraconsistent contradiction (for Rung 18)
% State a fact for 'has property' with the arguments listed below.
has_property(tweety, flightless).   % Tweety is a penguin
% State the fact: is a(tweety, bird).
is_a(tweety, bird).
% default_rule says birds fly; exception says flightless birds don't.
% Both "tweety flies" (from default) and "tweety does not fly" (from exception)
% are derivable — paraconsistent reasoning keeps them isolated.

% ---------------------------------------------------------------------------
% LAYER 4 — PROBABILISTIC AND STATISTICAL LAYER
% ---------------------------------------------------------------------------

% prob_fact(Proposition, Probability)
% State the fact: prob fact(rains_today,           0.3).
prob_fact(rains_today,           0.3).
% State the fact: prob fact(rain,                  0.3).
prob_fact(rain,                  0.3).
% State the fact: prob fact(sprinkler,             0.6).
prob_fact(sprinkler,             0.6).
% State the fact: prob fact(exercise,              0.7).
prob_fact(exercise,              0.7).
% State the fact: prob fact(illness,               0.2).
prob_fact(illness,               0.2).
% State the fact: prob fact(cat_in_garden,         0.6).
prob_fact(cat_in_garden,         0.6).
% State the fact: prob fact(eagle_hunts_today,     0.7).
prob_fact(eagle_hunts_today,     0.7).
% State the fact: prob fact(rose_blooms_in_june,   0.9).
prob_fact(rose_blooms_in_june,   0.9).
% State the fact: prob fact(salmon_jumps_upstream, 0.5).
prob_fact(salmon_jumps_upstream, 0.5).

% observation(Subject, Property, Count) — small observation table
% State the fact: observation(canary,  yellow,    47).
observation(canary,  yellow,    47).
% State the fact: observation(canary,  green,      3).
observation(canary,  green,      3).
% State the fact: observation(rose,    red,       82).
observation(rose,    red,       82).
% State the fact: observation(rose,    white,     18).
observation(rose,    white,     18).
% State the fact: observation(penguin, swims,     95).
observation(penguin, swims,     95).
% State the fact: observation(penguin, flies,      0).
observation(penguin, flies,      0).
% State the fact: observation(eagle,   hunts,     71).
observation(eagle,   hunts,     71).
% State the fact: observation(eagle,   rests,     29).
observation(eagle,   rests,     29).

% ---------------------------------------------------------------------------
% LAYER 5 — AGENTS WITH BELIEFS (theory of mind)
% ---------------------------------------------------------------------------

% believes(Agent, Proposition, TruthValue)
% Sally-Anne false-belief scenario
% State the fact: believes(sally,  marble_in_basket,  true).
believes(sally,  marble_in_basket,  true).
% State a fact for 'believes' with the arguments listed below.
believes(anne,   marble_in_basket,  false).   % Anne moved it to the box
% State the fact: believes(anne,   marble_in_box,     true).
believes(anne,   marble_in_box,     true).
% State a fact for 'believes' with the arguments listed below.
believes(sally,  marble_in_box,     false).   % Sally did not see the move

% A second character pair for epistemic reasoning
% State the fact: believes(alice,  water_is_safe,     true).
believes(alice,  water_is_safe,     true).
% State a fact for 'believes' with the arguments listed below.
believes(bob,    water_is_safe,     false).   % Bob has different evidence

% ---------------------------------------------------------------------------
% LAYER 6 — SCENARIO LAYER
% ---------------------------------------------------------------------------

% Short story: causal and temporal thread
% State a fact for 'scenario' with the arguments listed below.
scenario(story, [
    % Continue the multi-line expression started above.
    event(1, cat_sees_bird),
    % Continue the multi-line expression started above.
    event(2, cat_chases_bird),
    % Continue the multi-line expression started above.
    event(3, bird_flies_away),
    % Continue the multi-line expression started above.
    event(4, cat_returns_home),
    % Continue the multi-line expression started above.
    causes(cat_sees_bird,   cat_chases_bird),
    % Continue the multi-line expression started above.
    causes(cat_chases_bird, bird_flies_away),
    % Continue the multi-line expression started above.
    causes(bird_flies_away, cat_returns_home)
% Close the expression opened above.
]).

% Constraint puzzle: who owns which pet (simplified Zebra)
% State a fact for 'scenario' with the arguments listed below.
scenario(puzzle, [
    % Continue the multi-line expression started above.
    owner(alice, _PetA),
    % Continue the multi-line expression started above.
    owner(bob,   _PetB),
    % Continue the multi-line expression started above.
    owner(carol, _PetC),
    % Continue the multi-line expression started above.
    constraint(alice, not_owns, cat),
    % Continue the multi-line expression started above.
    constraint(bob,   owns,     dog),
    % Continue the multi-line expression started above.
    constraint(carol, not_owns, dog)
% Close the expression opened above.
]).

% Two-agent strategic choice (Prisoner's Dilemma)
% State a fact for 'scenario' with the arguments listed below.
scenario(game, [
    % Continue the multi-line expression started above.
    agent(alice),
    % Continue the multi-line expression started above.
    agent(bob),
    % Continue the multi-line expression started above.
    action(cooperate),
    % Continue the multi-line expression started above.
    action(defect),
    % Continue the multi-line expression started above.
    payoff(cooperate, cooperate, 3, 3),
    % Continue the multi-line expression started above.
    payoff(cooperate, defect,    0, 5),
    % Continue the multi-line expression started above.
    payoff(defect,    cooperate, 5, 0),
    % Continue the multi-line expression started above.
    payoff(defect,    defect,    1, 1)
% Close the expression opened above.
]).

% Values dilemma (moral reasoning)
% State a fact for 'scenario' with the arguments listed below.
scenario(dilemma, [
    % Continue the multi-line expression started above.
    situation(trolley_problem),
    % Continue the multi-line expression started above.
    option(pull_lever,    saves(5), harms(1)),
    % Continue the multi-line expression started above.
    option(do_nothing,    saves(0), harms(5)),
    % Continue the multi-line expression started above.
    value(minimise_harm),
    % Continue the multi-line expression started above.
    value(no_active_harm),
    % Continue the multi-line expression started above.
    tension(minimise_harm, no_active_harm)
% Close the expression opened above.
]).
