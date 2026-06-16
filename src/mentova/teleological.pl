/*  Mentova — Rung 39: Teleological Reasoning Module

    Reasons about the purposes and final causes of objects and processes.
    Answers "what is X for?" by consulting a purpose/function knowledge base.
    Pass criterion: for any artifact or organ, return its purpose with
    the supporting teleological chain.
*/

:- module(teleological, [
    mentova_teleological/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Purpose base: purpose(Entity, For, Chain)
% Chain: the teleological derivation (what serving the purpose enables)
% ---------------------------------------------------------------------------

purpose(heart,           pump_blood,
        serves(circulatory_system, enables(oxygen_delivery, enables(cell_survival)))).

purpose(lungs,           exchange_gas,
        serves(respiratory_system, enables(oxygenation_of_blood, enables(energy_production)))).

purpose(eyes,            detect_light,
        serves(visual_system, enables(navigation, enables(predator_avoidance)))).

purpose(roots,           absorb_water_and_nutrients,
        serves(plant_vascular_system, enables(photosynthesis, enables(plant_growth)))).

purpose(wings,           enable_flight,
        serves(locomotion_system, enables(predator_escape, enables(migration)))).

purpose(hammer,          drive_nails,
        serves(construction_task, enables(joining_materials, enables(structure_building)))).

purpose(knife,           cut_material,
        serves(food_preparation, enables(cutting_food, enables(meal_preparation)))).

purpose(key,             unlock_door,
        serves(security_system, enables(controlled_access, enables(privacy)))).

purpose(school,          educate_children,
        serves(social_system, enables(skill_development, enables(societal_function)))).

purpose(hospital,        treat_illness,
        serves(healthcare_system, enables(recovery, enables(productivity)))).

purpose(money,           medium_of_exchange,
        serves(economic_system, enables(trade, enables(specialisation)))).

purpose(constitution,    govern_society,
        serves(legal_system, enables(rights_protection, enables(social_order)))).

purpose(fire,            provide_heat_and_light,
        serves(survival_function, enables(warmth, enables(cooking)))).

% ---------------------------------------------------------------------------
% Instrumental chain: why is X done? (to achieve Y, which enables Z)
% ---------------------------------------------------------------------------

instrumental_chain(Entity, PurposeAtom, Chain) :-
    purpose(Entity, PurposeAtom, Chain).

% What ultimately does X serve?
ultimate_purpose(Entity, Ultimate) :-
    purpose(Entity, _, serves(_, enables(_, enables(Ultimate)))).

% ---------------------------------------------------------------------------
% mentova_teleological(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_teleological(purpose_of(Entity), purpose(Entity, For, Chain),
                     just(teleological(entity(Entity),
                                        purpose(For),
                                        chain(Chain)))) :-
    purpose(Entity, For, Chain), !.

mentova_teleological(purpose_of(Entity), no_purpose_recorded(Entity),
                     just(teleological(entity(Entity), result(unknown)))) :-
    \+ purpose(Entity, _, _).

mentova_teleological(ultimate_goal(Entity), ultimate(Entity, Ultimate),
                     just(teleological(entity(Entity),
                                        ultimate_goal(Ultimate)))) :-
    ultimate_purpose(Entity, Ultimate), !.

mentova_teleological(what_serves(Purpose), entities(Purpose, Entities),
                     just(teleological(serves_query(Purpose), list(Entities)))) :-
    findall(E, purpose(E, Purpose, _), Entities).

mentova_teleological(why(Entity), why(Entity, Because, Chain),
                     just(teleological(why_query(Entity),
                                        because(Because),
                                        chain(Chain)))) :-
    purpose(Entity, Because, Chain), !.
