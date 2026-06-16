/*  Mentova — Rung 27: System Reasoning Module

    Reasons about how parts interact to produce whole-system behavior.
    Pass criterion: whole-behavior question answered from parts.

    A system is defined by:
      - Parts with roles
      - Interactions between parts
      - Emergent whole behaviors
*/

% Declare this file as the 'system_reasoning' module and list its exported predicates.
:- module(system_reasoning, [
    % Supply 'mentova_system/3' as the next argument to the expression above.
    mentova_system/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% System definitions: system(Name, Parts, Interactions, Behaviors)
% ---------------------------------------------------------------------------

% State the fact: system part(bicycle, wheel,   rolls).
system_part(bicycle, wheel,   rolls).
% State the fact: system part(bicycle, frame,   supports).
system_part(bicycle, frame,   supports).
% State the fact: system part(bicycle, pedal,   drives).
system_part(bicycle, pedal,   drives).
% State the fact: system part(bicycle, chain,   transmits).
system_part(bicycle, chain,   transmits).
% State the fact: system part(bicycle, brake,   stops).
system_part(bicycle, brake,   stops).
% State the fact: system part(bicycle, handlebar, steers).
system_part(bicycle, handlebar, steers).

% State the fact: system part(plant,   roots,   absorbs_water).
system_part(plant,   roots,   absorbs_water).
% State the fact: system part(plant,   stem,    transports).
system_part(plant,   stem,    transports).
% State the fact: system part(plant,   leaf,    photosynthesises).
system_part(plant,   leaf,    photosynthesises).
% State the fact: system part(plant,   flower,  reproduces).
system_part(plant,   flower,  reproduces).

% State the fact: system part(team,    leader,  decides).
system_part(team,    leader,  decides).
% State the fact: system part(team,    member,  executes).
system_part(team,    member,  executes).
% State the fact: system part(team,    comms,   coordinates).
system_part(team,    comms,   coordinates).

% Interactions: interaction(System, PartA, PartB, Effect)
% State the fact: interaction(bicycle, pedal, chain, drives_chain).
interaction(bicycle, pedal, chain, drives_chain).
% State the fact: interaction(bicycle, chain, wheel, spins_wheel).
interaction(bicycle, chain, wheel, spins_wheel).
% State the fact: interaction(bicycle, wheel, frame, propels_frame).
interaction(bicycle, wheel, frame, propels_frame).
% State the fact: interaction(plant,   roots, stem,  sends_water_up).
interaction(plant,   roots, stem,  sends_water_up).
% State the fact: interaction(plant,   stem,  leaf,  delivers_water_to_leaf).
interaction(plant,   stem,  leaf,  delivers_water_to_leaf).
% State the fact: interaction(plant,   leaf,  plant, produces_glucose).
interaction(plant,   leaf,  plant, produces_glucose).

% Emergent behaviors: whole_behavior(System, Behavior, Mechanism)
% State a fact for 'whole behavior' with the arguments listed below.
whole_behavior(bicycle, moves_forward,
               % Continue the multi-line expression started above.
               [wheel(rolls), pedal(drives), chain(transmits)]).
% State a fact for 'whole behavior' with the arguments listed below.
whole_behavior(bicycle, can_stop,
               % Continue the multi-line expression started above.
               [brake(stops), wheel(decelerates)]).
% State a fact for 'whole behavior' with the arguments listed below.
whole_behavior(plant, grows,
               % Continue the multi-line expression started above.
               [leaf(photosynthesises), roots(absorbs), stem(transports)]).
% State a fact for 'whole behavior' with the arguments listed below.
whole_behavior(team, achieves_goal,
               % Continue the multi-line expression started above.
               [leader(decides), member(executes), comms(coordinates)]).

% ---------------------------------------------------------------------------
% mentova_system(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% What parts does a system have?
% State a fact for 'mentova system' with the arguments listed below.
mentova_system(parts(Sys), Parts,
               % Continue the multi-line expression started above.
               just(system_parts(Sys, Parts))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Part-Role, system_part(Sys, Part, Role), Parts).

% What does a part do?
% State a fact for 'mentova system' with the arguments listed below.
mentova_system(role(Sys, Part), Role,
               % Continue the multi-line expression started above.
               just(part_role(Sys, Part, Role))) :-
    % State the fact: system part(Sys, Part, Role).
    system_part(Sys, Part, Role).

% What behavior does the system exhibit?
% State a fact for 'mentova system' with the arguments listed below.
mentova_system(behavior(Sys), Behavior,
               % Continue the multi-line expression started above.
               just(system_behavior(Sys, Behavior, mechanism(Mechanism)))) :-
    % State the fact: whole behavior(Sys, Behavior, Mechanism).
    whole_behavior(Sys, Behavior, Mechanism).

% If a part fails, what behavior is lost?
% State a fact for 'mentova system' with the arguments listed below.
mentova_system(if_fails(Sys, Part), Effects,
               % Continue the multi-line expression started above.
               just(failure_analysis(Sys, Part, lost_behaviors(Effects)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Beh,
            % Continue the multi-line expression started above.
            ( whole_behavior(Sys, Beh, Mechanism),
              % Continue the multi-line expression started above.
              member(Part, Mechanism)  % Part appears in mechanism
            % Close the expression opened above.
            ),
            % Supply 'Effects' as the next argument to the expression above.
            Effects).

% Interaction chain: what does PartA → PartB → PartC produce?
% State a fact for 'mentova system' with the arguments listed below.
mentova_system(trace(Sys, From, To), Effect,
               % Continue the multi-line expression started above.
               just(interaction_trace(Sys, From, To, effect(Effect)))) :-
    % State the fact: interaction(Sys, From, To, Effect).
    interaction(Sys, From, To, Effect).
