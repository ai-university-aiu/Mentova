/*  Mentova — ARC-AGI-3_Guided sub-project

    One of the two ARC-AGI-3 learning sub-projects. ARC-AGI-3_Guided is the
    human-in-the-loop side: it uses the ARC-AGI-3 Chat page to receive guidance
    from a human, grounds each clue into a Causalontology assertion, injects it
    into the live game loop, and takes glass-box steps whose basis it records.
    Everything it learns lands in the shared substrate - the data lattice
    (node facts), the Causalontology relations, the human-set goal, priorities,
    and hazards, the Jacobian Space (J-Space), and the shared state-exploration
    graph (co_graph) which Guided play builds and Solo reads - which the companion
    sub-project ARC-AGI-3_Solo reads back and plays from unaided.

    This module is the named face of that sub-project. Its predicates delegate
    to the shared mentova_arc_chat backend so that both sub-projects operate on
    exactly the same learnings, and g3_learnings/1 exposes those learnings for
    inspection.

    Predicates:
      g3_ground/3     -- +Text, +Ref, -Assertion   (ground one human clue)
      g3_inject/1     -- +Assertion                 (bias the live loop)
      g3_step/1       -- -Report                    (one guided step, glass-box)
      g3_why/1        -- -Why                        (why the last action)
      g3_mode/1       -- -Mode                       (the active mode)
      g3_learnings/1  -- -Learnings                  (all shared learnings)
*/

% Declare the Guided sub-project module and its exports.
:- module(arc_agi_3_guided, [
    % g3_ground/3: ground one human clue into a Causalontology assertion.
    g3_ground/3,
    % g3_inject/1: bias the live loop with a grounded assertion.
    g3_inject/1,
    % g3_step/1: one guided loop step, glass-box.
    g3_step/1,
    % g3_why/1: why Mentova took its last action.
    g3_why/1,
    % g3_mode/1: the active mode.
    g3_mode/1,
    % g3_learnings/1: all shared learnings, seen and read.
    g3_learnings/1,
    % g3_graph/1: the shared state-graph exploration map.
    g3_graph/1
]).

% Load the shared ARC-AGI-3 chat backend both sub-projects operate on.
:- use_module('mentova_arc_chat',
    [co_ground/3, ma_inject/1, ma_step/1, ma_why/1, ma_mode/1,
     ma_learnings/1, ma_graph_stats/1]).

% Define g3_ground: ground one human clue, delegating to the shared backend.
g3_ground(Text, Ref, Assertion) :-
    % The chat backend's grounding table.
    co_ground(Text, Ref, Assertion).

% Define g3_inject: bias the live loop with a grounded assertion.
g3_inject(Assertion) :-
    % The chat backend's injection.
    ma_inject(Assertion).

% Define g3_step: take one guided step, glass-box.
g3_step(Report) :-
    % The chat backend's guided step.
    ma_step(Report).

% Define g3_why: why Mentova took its last action.
g3_why(Why) :-
    % The chat backend's justification.
    ma_why(Why).

% Define g3_mode: the active mode.
g3_mode(Mode) :-
    % The shared mode.
    ma_mode(Mode).

% Define g3_learnings: all shared learnings, seen and read by this sub-project.
g3_learnings(Learnings) :-
    % The shared learnings the Solo sub-project also reads.
    ma_learnings(Learnings).

% Define g3_graph: the shared state-graph exploration map (co_graph). Guided play
% builds this graph as the human drives and teaches, and Solo reads the very same
% graph — there is one store, not one per mode.
g3_graph(Graph) :-
    % The shared graph statistics.
    ma_graph_stats(Graph).
