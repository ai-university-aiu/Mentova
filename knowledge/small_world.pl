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

:- module(small_world, [
    is_a/2,
    part_of/2,
    causes/2,
    used_for/2,
    capable_of/2,
    has_property/2,
    at_location/2,
    motivated_by/2,
    has_prerequisite/2,
    default_rule/2,
    exception_rule/3,
    norm/2,
    modal_fact/3,
    prob_fact/2,
    observation/3,
    believes/3,
    scenario/2
]).

:- discontiguous is_a/2.
:- discontiguous has_property/2.
:- dynamic is_a/2.
:- dynamic has_property/2.

% ---------------------------------------------------------------------------
% LAYER 1 — TAXONOMIC BACKBONE (IsA, part_of)
% ---------------------------------------------------------------------------

is_a(canary,    bird).
is_a(penguin,   bird).
is_a(eagle,     bird).
is_a(robin,     bird).
is_a(bird,      animal).
is_a(cat,       animal).
is_a(dog,       animal).
is_a(salmon,    fish).
is_a(fish,      animal).
is_a(rose,      flower).
is_a(daisy,     flower).
is_a(flower,    plant).
is_a(oak,       tree).
is_a(tree,      plant).
is_a(plant,     living_thing).
is_a(animal,    living_thing).
is_a(apple,     fruit).
is_a(banana,    fruit).
is_a(fruit,     food).
is_a(bread,     food).
is_a(knife,     tool).
is_a(hammer,    tool).
is_a(chair,     furniture).
is_a(table,     furniture).
is_a(car,       vehicle).
is_a(bicycle,   vehicle).
is_a(water,     liquid).
is_a(milk,      liquid).

part_of(wing,   bird).
part_of(beak,   bird).
part_of(leaf,   tree).
part_of(root,   plant).
part_of(petal,  flower).
part_of(wheel,  car).
part_of(wheel,  bicycle).
part_of(seat,   chair).
part_of(leg,    table).
part_of(blade,  knife).

% ---------------------------------------------------------------------------
% LAYER 2 — COMMONSENSE RELATIONS (ConceptNet-style)
% ---------------------------------------------------------------------------

capable_of(bird,    fly).
capable_of(eagle,   hunt).
capable_of(dog,     bark).
capable_of(cat,     climb).
capable_of(salmon,  swim).
capable_of(car,     transport_people).
capable_of(knife,   cut).
capable_of(hammer,  drive_nail).

has_property(canary,  yellow).
has_property(rose,    red).
has_property(daisy,   white).
has_property(oak,     tall).
has_property(water,   transparent).
has_property(milk,    white).
has_property(penguin, flightless).
has_property(eagle,   large).

at_location(fish,     water).
at_location(bird,     sky).
at_location(penguin,  antarctica).
at_location(rose,     garden).
at_location(oak,      forest).
at_location(cat,      house).

causes(rain,        wet_ground).
causes(sprinkler,   wet_ground).
causes(fire,        smoke).
causes(hunger,      eating).
causes(exercise,    fatigue).
causes(illness,     fatigue).
causes(sunlight,    plant_growth).

used_for(knife,     cutting).
used_for(hammer,    building).
used_for(chair,     sitting).
used_for(car,       travelling).
used_for(water,     drinking).

motivated_by(eating,    hunger).
motivated_by(sleeping,  fatigue).
motivated_by(hunting,   hunger).

has_prerequisite(flying,    having_wings).
has_prerequisite(swimming,  being_in_water).
has_prerequisite(driving,   having_licence).

% ---------------------------------------------------------------------------
% LAYER 3 — AUTHORED RULE LAYER (defaults, exceptions, norms, modal facts)
% ---------------------------------------------------------------------------

% Default rules: Head :- Condition (defeasible)
default_rule(flies(X),      is_a(X, bird)).
default_rule(has_fur(X),    is_a(X, mammal)).
default_rule(edible(X),     is_a(X, fruit)).
default_rule(is_wet(X),     at_location(X, water)).

% Exception rules: exception(Head, ExceptionCondition, ExceptionNote)
exception_rule(flies(X),    has_property(X, flightless), penguin_exception).
exception_rule(flies(X),    is_a(X, fish),               fish_dont_fly).

% Norms (deontic)
norm(permitted,  eating_fruit).
norm(permitted,  drinking_water).
norm(forbidden,  harming_animal).
norm(obligatory, feeding_pet).

% Modal facts: modal(Agent, Modality, Proposition)
%   Modality: necessarily | possibly | contingently
modal_fact(world,  necessarily,   is_a(penguin, bird)).
modal_fact(world,  possibly,      rains_today).
modal_fact(world,  contingently,  cat_in_garden).

% Deliberate paraconsistent contradiction (for Rung 18)
has_property(tweety, flightless).   % Tweety is a penguin
is_a(tweety, bird).
% default_rule says birds fly; exception says flightless birds don't.
% Both "tweety flies" (from default) and "tweety does not fly" (from exception)
% are derivable — paraconsistent reasoning keeps them isolated.

% ---------------------------------------------------------------------------
% LAYER 4 — PROBABILISTIC AND STATISTICAL LAYER
% ---------------------------------------------------------------------------

% prob_fact(Proposition, Probability)
prob_fact(rains_today,           0.3).
prob_fact(rain,                  0.3).
prob_fact(sprinkler,             0.6).
prob_fact(exercise,              0.7).
prob_fact(illness,               0.2).
prob_fact(cat_in_garden,         0.6).
prob_fact(eagle_hunts_today,     0.7).
prob_fact(rose_blooms_in_june,   0.9).
prob_fact(salmon_jumps_upstream, 0.5).

% observation(Subject, Property, Count) — small observation table
observation(canary,  yellow,    47).
observation(canary,  green,      3).
observation(rose,    red,       82).
observation(rose,    white,     18).
observation(penguin, swims,     95).
observation(penguin, flies,      0).
observation(eagle,   hunts,     71).
observation(eagle,   rests,     29).

% ---------------------------------------------------------------------------
% LAYER 5 — AGENTS WITH BELIEFS (theory of mind)
% ---------------------------------------------------------------------------

% believes(Agent, Proposition, TruthValue)
% Sally-Anne false-belief scenario
believes(sally,  marble_in_basket,  true).
believes(anne,   marble_in_basket,  false).   % Anne moved it to the box
believes(anne,   marble_in_box,     true).
believes(sally,  marble_in_box,     false).   % Sally did not see the move

% A second character pair for epistemic reasoning
believes(alice,  water_is_safe,     true).
believes(bob,    water_is_safe,     false).   % Bob has different evidence

% ---------------------------------------------------------------------------
% LAYER 6 — SCENARIO LAYER
% ---------------------------------------------------------------------------

% Short story: causal and temporal thread
scenario(story, [
    event(1, cat_sees_bird),
    event(2, cat_chases_bird),
    event(3, bird_flies_away),
    event(4, cat_returns_home),
    causes(cat_sees_bird,   cat_chases_bird),
    causes(cat_chases_bird, bird_flies_away),
    causes(bird_flies_away, cat_returns_home)
]).

% Constraint puzzle: who owns which pet (simplified Zebra)
scenario(puzzle, [
    owner(alice, _PetA),
    owner(bob,   _PetB),
    owner(carol, _PetC),
    constraint(alice, not_owns, cat),
    constraint(bob,   owns,     dog),
    constraint(carol, not_owns, dog)
]).

% Two-agent strategic choice (Prisoner's Dilemma)
scenario(game, [
    agent(alice),
    agent(bob),
    action(cooperate),
    action(defect),
    payoff(cooperate, cooperate, 3, 3),
    payoff(cooperate, defect,    0, 5),
    payoff(defect,    cooperate, 5, 0),
    payoff(defect,    defect,    1, 1)
]).

% Values dilemma (moral reasoning)
scenario(dilemma, [
    situation(trolley_problem),
    option(pull_lever,    saves(5), harms(1)),
    option(do_nothing,    saves(0), harms(5)),
    value(minimise_harm),
    value(no_active_harm),
    tension(minimise_harm, no_active_harm)
]).
