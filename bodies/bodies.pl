/*  Mentova — Body Configurations

    Mentova's enrolled bodies following the Mind-Body pattern (PrologAI PR 10).

    Bodies:
        game_body       — a game environment enrolled as a body (PR 45 / PR 44)
        robot_body      — a ROS 2 robot (physical or simulated) via PR 46
        text_body       — a text I/O body for the transparent reasoning assistant
*/

:- module(bodies, [
    mentova_body/3,
    enroll_bodies/0
]).

% mentova_body(BodyId, Type, Description)
mentova_body(text_io,    text,   'Text I/O body — transparent reasoning assistant track').
mentova_body(game_env,   game,   'Game-as-body harness — Pokémon, ARC, Baba Is You').
mentova_body(ros_robot,  robot,  'ROS 2 robot body — virtual first (Gazebo/Webots), then physical').

enroll_bodies :-
    forall(mentova_body(Id, Type, Desc),
           format("Enrolled body: ~w (~w) — ~w~n", [Id, Type, Desc])).
