/*  Mentova — Rung 39: Teleological Reasoning Module

    Reasons about the purposes and final causes of objects and processes.
    Answers "what is X for?" by consulting a purpose/function knowledge base.
    Pass criterion: for any artifact or organ, return its purpose with
    the supporting teleological chain.
*/

% Declare this file as the 'teleological' module and list its exported predicates.
:- module(teleological, [
    % Supply 'mentova_teleological/3' as the next argument to the expression above.
    mentova_teleological/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Purpose base: purpose(Entity, For, Chain)
% Chain: the teleological derivation (what serving the purpose enables)
% ---------------------------------------------------------------------------

% State a fact for 'purpose' with the arguments listed below.
purpose(heart,           pump_blood,
        % Continue the multi-line expression started above.
        serves(circulatory_system, enables(oxygen_delivery, enables(cell_survival)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(lungs,           exchange_gas,
        % Continue the multi-line expression started above.
        serves(respiratory_system, enables(oxygenation_of_blood, enables(energy_production)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(eyes,            detect_light,
        % Continue the multi-line expression started above.
        serves(visual_system, enables(navigation, enables(predator_avoidance)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(roots,           absorb_water_and_nutrients,
        % Continue the multi-line expression started above.
        serves(plant_vascular_system, enables(photosynthesis, enables(plant_growth)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(wings,           enable_flight,
        % Continue the multi-line expression started above.
        serves(locomotion_system, enables(predator_escape, enables(migration)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(hammer,          drive_nails,
        % Continue the multi-line expression started above.
        serves(construction_task, enables(joining_materials, enables(structure_building)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(knife,           cut_material,
        % Continue the multi-line expression started above.
        serves(food_preparation, enables(cutting_food, enables(meal_preparation)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(key,             unlock_door,
        % Continue the multi-line expression started above.
        serves(security_system, enables(controlled_access, enables(privacy)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(school,          educate_children,
        % Continue the multi-line expression started above.
        serves(social_system, enables(skill_development, enables(societal_function)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(hospital,        treat_illness,
        % Continue the multi-line expression started above.
        serves(healthcare_system, enables(recovery, enables(productivity)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(money,           medium_of_exchange,
        % Continue the multi-line expression started above.
        serves(economic_system, enables(trade, enables(specialisation)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(constitution,    govern_society,
        % Continue the multi-line expression started above.
        serves(legal_system, enables(rights_protection, enables(social_order)))).

% State a fact for 'purpose' with the arguments listed below.
purpose(fire,            provide_heat_and_light,
        % Continue the multi-line expression started above.
        serves(survival_function, enables(warmth, enables(cooking)))).

% ---------------------------------------------------------------------------
% Instrumental chain: why is X done? (to achieve Y, which enables Z)
% ---------------------------------------------------------------------------

% Define a clause for 'instrumental chain': succeed when the following conditions hold.
instrumental_chain(Entity, PurposeAtom, Chain) :-
    % State the fact: purpose(Entity, PurposeAtom, Chain).
    purpose(Entity, PurposeAtom, Chain).

% What ultimately does X serve?
% Define a clause for 'ultimate purpose': succeed when the following conditions hold.
ultimate_purpose(Entity, Ultimate) :-
    % State the fact: purpose(Entity, _, serves(_, enables(_, enables(Ultimate)))).
    purpose(Entity, _, serves(_, enables(_, enables(Ultimate)))).

% ---------------------------------------------------------------------------
% mentova_teleological(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova teleological' with the arguments listed below.
mentova_teleological(purpose_of(Entity), purpose(Entity, For, Chain),
                     % Continue the multi-line expression started above.
                     just(teleological(entity(Entity),
                                        % Continue the multi-line expression started above.
                                        purpose(For),
                                        % Continue the multi-line expression started above.
                                        chain(Chain)))) :-
    % State a fact for 'purpose' with the arguments listed below.
    purpose(Entity, For, Chain), !.

% State a fact for 'mentova teleological' with the arguments listed below.
mentova_teleological(purpose_of(Entity), no_purpose_recorded(Entity),
                     % Continue the multi-line expression started above.
                     just(teleological(entity(Entity), result(unknown)))) :-
    % Succeed only if 'purpose(Entity, _, _' cannot be proved (negation as failure).
    \+ purpose(Entity, _, _).

% State a fact for 'mentova teleological' with the arguments listed below.
mentova_teleological(ultimate_goal(Entity), ultimate(Entity, Ultimate),
                     % Continue the multi-line expression started above.
                     just(teleological(entity(Entity),
                                        % Continue the multi-line expression started above.
                                        ultimate_goal(Ultimate)))) :-
    % State a fact for 'ultimate purpose' with the arguments listed below.
    ultimate_purpose(Entity, Ultimate), !.

% State a fact for 'mentova teleological' with the arguments listed below.
mentova_teleological(what_serves(Purpose), entities(Purpose, Entities),
                     % Continue the multi-line expression started above.
                     just(teleological(serves_query(Purpose), list(Entities)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(E, purpose(E, Purpose, _), Entities).

% State a fact for 'mentova teleological' with the arguments listed below.
mentova_teleological(why(Entity), why(Entity, Because, Chain),
                     % Continue the multi-line expression started above.
                     just(teleological(why_query(Entity),
                                        % Continue the multi-line expression started above.
                                        because(Because),
                                        % Continue the multi-line expression started above.
                                        chain(Chain)))) :-
    % State a fact for 'purpose' with the arguments listed below.
    purpose(Entity, Because, Chain), !.
