/*  Mentova — Rung 36: Procedural Reasoning Module

    Reasons about how to accomplish a goal through step-by-step procedures.
    Tracks preconditions and postconditions for each step.
    Pass criterion: given a goal, returns an ordered plan with each step's
    preconditions verified and postconditions listed.
*/

% Declare this file as the 'procedural' module and list its exported predicates.
:- module(procedural, [
    % Supply 'mentova_procedural/3' as the next argument to the expression above.
    mentova_procedural/3
% Close the expression opened above.
]).

% Import [member/2, append/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% Procedure base: procedure(Goal, Steps)
% Each step: step(N, Action, Pre, Post)
% ---------------------------------------------------------------------------

% State a fact for 'procedure' with the arguments listed below.
procedure(make_tea, [
    % Continue the multi-line expression started above.
    step(1, boil_water,      [has(water), has(kettle)],    [water_boiled]),
    % Continue the multi-line expression started above.
    step(2, get_cup,         [has(cup)],                   [cup_ready]),
    % Continue the multi-line expression started above.
    step(3, add_teabag,      [has(teabag), cup_ready],     [teabag_in_cup]),
    % Continue the multi-line expression started above.
    step(4, pour_water,      [water_boiled, teabag_in_cup],[tea_steeping]),
    % Continue the multi-line expression started above.
    step(5, wait_3_minutes,  [tea_steeping],               [tea_ready]),
    % Continue the multi-line expression started above.
    step(6, remove_teabag,   [tea_ready],                  [tea_complete])
% Close the expression opened above.
]).

% State a fact for 'procedure' with the arguments listed below.
procedure(change_tyre, [
    % Continue the multi-line expression started above.
    step(1, loosen_nuts,     [has(wrench), car_stopped],   [nuts_loose]),
    % Continue the multi-line expression started above.
    step(2, jack_up_car,     [has(jack), nuts_loose],      [car_jacked]),
    % Continue the multi-line expression started above.
    step(3, remove_wheel,    [car_jacked, nuts_loose],     [wheel_off]),
    % Continue the multi-line expression started above.
    step(4, mount_spare,     [has(spare), wheel_off],      [spare_on]),
    % Continue the multi-line expression started above.
    step(5, tighten_nuts,    [has(wrench), spare_on],      [nuts_tight]),
    % Continue the multi-line expression started above.
    step(6, lower_car,       [has(jack), nuts_tight],      [car_lowered])
% Close the expression opened above.
]).

% State a fact for 'procedure' with the arguments listed below.
procedure(plant_seed, [
    % Continue the multi-line expression started above.
    step(1, dig_hole,        [has(spade), has(soil)],      [hole_ready]),
    % Continue the multi-line expression started above.
    step(2, place_seed,      [has(seed), hole_ready],      [seed_placed]),
    % Continue the multi-line expression started above.
    step(3, cover_seed,      [seed_placed, has(soil)],     [seed_covered]),
    % Continue the multi-line expression started above.
    step(4, water_seed,      [seed_covered, has(water)],   [seed_watered]),
    % Continue the multi-line expression started above.
    step(5, wait_for_sprout, [seed_watered],               [sprouted])
% Close the expression opened above.
]).

% State a fact for 'procedure' with the arguments listed below.
procedure(bake_bread, [
    % Continue the multi-line expression started above.
    step(1, mix_ingredients, [has(flour), has(yeast), has(water)], [dough_mixed]),
    % Continue the multi-line expression started above.
    step(2, knead_dough,     [dough_mixed],                         [dough_kneaded]),
    % Continue the multi-line expression started above.
    step(3, let_rise,        [dough_kneaded],                       [dough_risen]),
    % Continue the multi-line expression started above.
    step(4, shape_loaf,      [dough_risen],                         [loaf_shaped]),
    % Continue the multi-line expression started above.
    step(5, bake,            [loaf_shaped, has(oven)],              [bread_baked])
% Close the expression opened above.
]).

% ---------------------------------------------------------------------------
% Execute plan: verify all steps and collect outcomes
% ---------------------------------------------------------------------------

% State the fact: execute plan([], _State, [], []).
execute_plan([], _State, [], []).
% Define a clause for 'execute plan': succeed when the following conditions hold.
execute_plan([step(N, Action, Pre, Post)|Rest], State, [done(N, Action, Post)|Done], FinalState) :-
    % Execute: ( forall(member(P, Pre), member(P, State)).
    ( forall(member(P, Pre), member(P, State))
    % If the condition above succeeded, perform the following action.
    -> append(State, Post, NewState)
    % Otherwise (else branch), perform the following action.
    ;  append(State, [], NewState)
    % Close the expression opened above.
    ),
    % State the fact: execute plan(Rest, NewState, Done, FinalState).
    execute_plan(Rest, NewState, Done, FinalState).

% ---------------------------------------------------------------------------
% mentova_procedural(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova procedural' with the arguments listed below.
mentova_procedural(plan_for(Goal), plan(Goal, Steps, N),
                   % Continue the multi-line expression started above.
                   just(procedural(goal(Goal), steps(Steps), count(N)))) :-
    % State a fact for 'procedure' with the arguments listed below.
    procedure(Goal, Steps),
    % Unify 'N' with the number of elements in list 'Steps'.
    length(Steps, N).

% State a fact for 'mentova procedural' with the arguments listed below.
mentova_procedural(execute(Goal, InitState), executed(Goal, Done, final_state(FinalSt)),
                   % Continue the multi-line expression started above.
                   just(procedural(execution(Goal),
                                   % Continue the multi-line expression started above.
                                   initial_state(InitState),
                                   % Continue the multi-line expression started above.
                                   steps_done(Done),
                                   % Continue the multi-line expression started above.
                                   final_state(FinalSt)))) :-
    % State a fact for 'procedure' with the arguments listed below.
    procedure(Goal, Steps),
    % State the fact: execute plan(Steps, InitState, Done, FinalSt).
    execute_plan(Steps, InitState, Done, FinalSt).

% State a fact for 'mentova procedural' with the arguments listed below.
mentova_procedural(step_n(Goal, N), step(N, Action, Pre, Post),
                   % Continue the multi-line expression started above.
                   just(procedural(step_lookup(Goal, N),
                                   % Continue the multi-line expression started above.
                                   action(Action),
                                   % Continue the multi-line expression started above.
                                   preconditions(Pre),
                                   % Continue the multi-line expression started above.
                                   postconditions(Post)))) :-
    % State a fact for 'procedure' with the arguments listed below.
    procedure(Goal, Steps),
    % Succeed for each element 'step(N, Action, Pre, Post)' that is a member of the list.
    member(step(N, Action, Pre, Post), Steps).

% State a fact for 'mentova procedural' with the arguments listed below.
mentova_procedural(what_goals, goals(Goals),
                   % Continue the multi-line expression started above.
                   just(procedural(available_goals, list(Goals)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(G, procedure(G, _), Goals).
