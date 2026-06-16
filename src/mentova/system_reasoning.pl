/*  Mentova — Rung 27: System Reasoning Module

    Reasons about how parts interact to produce whole-system behavior.
    Pass criterion: whole-behavior question answered from parts.

    A system is defined by:
      - Parts with roles
      - Interactions between parts
      - Emergent whole behaviors
*/

:- module(system_reasoning, [
    mentova_system/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% System definitions: system(Name, Parts, Interactions, Behaviors)
% ---------------------------------------------------------------------------

system_part(bicycle, wheel,   rolls).
system_part(bicycle, frame,   supports).
system_part(bicycle, pedal,   drives).
system_part(bicycle, chain,   transmits).
system_part(bicycle, brake,   stops).
system_part(bicycle, handlebar, steers).

system_part(plant,   roots,   absorbs_water).
system_part(plant,   stem,    transports).
system_part(plant,   leaf,    photosynthesises).
system_part(plant,   flower,  reproduces).

system_part(team,    leader,  decides).
system_part(team,    member,  executes).
system_part(team,    comms,   coordinates).

% Interactions: interaction(System, PartA, PartB, Effect)
interaction(bicycle, pedal, chain, drives_chain).
interaction(bicycle, chain, wheel, spins_wheel).
interaction(bicycle, wheel, frame, propels_frame).
interaction(plant,   roots, stem,  sends_water_up).
interaction(plant,   stem,  leaf,  delivers_water_to_leaf).
interaction(plant,   leaf,  plant, produces_glucose).

% Emergent behaviors: whole_behavior(System, Behavior, Mechanism)
whole_behavior(bicycle, moves_forward,
               [wheel(rolls), pedal(drives), chain(transmits)]).
whole_behavior(bicycle, can_stop,
               [brake(stops), wheel(decelerates)]).
whole_behavior(plant, grows,
               [leaf(photosynthesises), roots(absorbs), stem(transports)]).
whole_behavior(team, achieves_goal,
               [leader(decides), member(executes), comms(coordinates)]).

% ---------------------------------------------------------------------------
% mentova_system(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% What parts does a system have?
mentova_system(parts(Sys), Parts,
               just(system_parts(Sys, Parts))) :-
    findall(Part-Role, system_part(Sys, Part, Role), Parts).

% What does a part do?
mentova_system(role(Sys, Part), Role,
               just(part_role(Sys, Part, Role))) :-
    system_part(Sys, Part, Role).

% What behavior does the system exhibit?
mentova_system(behavior(Sys), Behavior,
               just(system_behavior(Sys, Behavior, mechanism(Mechanism)))) :-
    whole_behavior(Sys, Behavior, Mechanism).

% If a part fails, what behavior is lost?
mentova_system(if_fails(Sys, Part), Effects,
               just(failure_analysis(Sys, Part, lost_behaviors(Effects)))) :-
    findall(Beh,
            ( whole_behavior(Sys, Beh, Mechanism),
              member(Part, Mechanism)  % Part appears in mechanism
            ),
            Effects).

% Interaction chain: what does PartA → PartB → PartC produce?
mentova_system(trace(Sys, From, To), Effect,
               just(interaction_trace(Sys, From, To, effect(Effect)))) :-
    interaction(Sys, From, To, Effect).
