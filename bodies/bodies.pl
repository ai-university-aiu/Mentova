/*  Mentova — Body Configurations

    Mentova's enrolled bodies following the Mind-Body pattern (PrologAI PR 10).

    Bodies:
        game_body       — a game environment enrolled as a body (PR 45 / PR 44)
        robot_body      — a ROS 2 robot (physical or simulated) via PR 46
        text_body       — a text I/O body for the transparent reasoning assistant
*/

% Declare this file as the 'bodies' module and list its exported predicates.
:- module(bodies, [
    % Supply 'mentova_body/3' as the next argument to the expression above.
    mentova_body/3,
    % Supply 'enroll_bodies/0' as the next argument to the expression above.
    enroll_bodies/0
% Close the expression opened above.
]).

% mentova_body(BodyId, Type, Description)
% State the fact: mentova body(text_io,    text,   'Text I/O body — transparent reasoning assistant track').
mentova_body(text_io,    text,   'Text I/O body — transparent reasoning assistant track').
% State the fact: mentova body(game_env,   game,   'Game-as-body harness — Pokémon, ARC, Baba Is You').
mentova_body(game_env,   game,   'Game-as-body harness — Pokémon, ARC, Baba Is You').
% State the fact: mentova body(ros_robot,  robot,  'ROS 2 robot body — virtual first (Gazebo/Webots), then physical').
mentova_body(ros_robot,  robot,  'ROS 2 robot body — virtual first (Gazebo/Webots), then physical').

% Execute: enroll_bodies :-.
enroll_bodies :-
    % Verify that for every solution of the Condition, the Action also holds.
    forall(mentova_body(Id, Type, Desc),
           % Continue the multi-line expression started above.
           format("Enrolled body: ~w (~w) — ~w~n", [Id, Type, Desc])).
