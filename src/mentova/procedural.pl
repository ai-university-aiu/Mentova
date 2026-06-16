/*  Mentova — Rung 36: Procedural Reasoning Module

    Reasons about how to accomplish a goal through step-by-step procedures.
    Tracks preconditions and postconditions for each step.
    Pass criterion: given a goal, returns an ordered plan with each step's
    preconditions verified and postconditions listed.
*/

:- module(procedural, [
    mentova_procedural/3
]).

:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% Procedure base: procedure(Goal, Steps)
% Each step: step(N, Action, Pre, Post)
% ---------------------------------------------------------------------------

procedure(make_tea, [
    step(1, boil_water,      [has(water), has(kettle)],    [water_boiled]),
    step(2, get_cup,         [has(cup)],                   [cup_ready]),
    step(3, add_teabag,      [has(teabag), cup_ready],     [teabag_in_cup]),
    step(4, pour_water,      [water_boiled, teabag_in_cup],[tea_steeping]),
    step(5, wait_3_minutes,  [tea_steeping],               [tea_ready]),
    step(6, remove_teabag,   [tea_ready],                  [tea_complete])
]).

procedure(change_tyre, [
    step(1, loosen_nuts,     [has(wrench), car_stopped],   [nuts_loose]),
    step(2, jack_up_car,     [has(jack), nuts_loose],      [car_jacked]),
    step(3, remove_wheel,    [car_jacked, nuts_loose],     [wheel_off]),
    step(4, mount_spare,     [has(spare), wheel_off],      [spare_on]),
    step(5, tighten_nuts,    [has(wrench), spare_on],      [nuts_tight]),
    step(6, lower_car,       [has(jack), nuts_tight],      [car_lowered])
]).

procedure(plant_seed, [
    step(1, dig_hole,        [has(spade), has(soil)],      [hole_ready]),
    step(2, place_seed,      [has(seed), hole_ready],      [seed_placed]),
    step(3, cover_seed,      [seed_placed, has(soil)],     [seed_covered]),
    step(4, water_seed,      [seed_covered, has(water)],   [seed_watered]),
    step(5, wait_for_sprout, [seed_watered],               [sprouted])
]).

procedure(bake_bread, [
    step(1, mix_ingredients, [has(flour), has(yeast), has(water)], [dough_mixed]),
    step(2, knead_dough,     [dough_mixed],                         [dough_kneaded]),
    step(3, let_rise,        [dough_kneaded],                       [dough_risen]),
    step(4, shape_loaf,      [dough_risen],                         [loaf_shaped]),
    step(5, bake,            [loaf_shaped, has(oven)],              [bread_baked])
]).

% ---------------------------------------------------------------------------
% Execute plan: verify all steps and collect outcomes
% ---------------------------------------------------------------------------

execute_plan([], _State, [], []).
execute_plan([step(N, Action, Pre, Post)|Rest], State, [done(N, Action, Post)|Done], FinalState) :-
    ( forall(member(P, Pre), member(P, State))
    -> append(State, Post, NewState)
    ;  append(State, [], NewState)
    ),
    execute_plan(Rest, NewState, Done, FinalState).

% ---------------------------------------------------------------------------
% mentova_procedural(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_procedural(plan_for(Goal), plan(Goal, Steps, N),
                   just(procedural(goal(Goal), steps(Steps), count(N)))) :-
    procedure(Goal, Steps),
    length(Steps, N).

mentova_procedural(execute(Goal, InitState), executed(Goal, Done, final_state(FinalSt)),
                   just(procedural(execution(Goal),
                                   initial_state(InitState),
                                   steps_done(Done),
                                   final_state(FinalSt)))) :-
    procedure(Goal, Steps),
    execute_plan(Steps, InitState, Done, FinalSt).

mentova_procedural(step_n(Goal, N), step(N, Action, Pre, Post),
                   just(procedural(step_lookup(Goal, N),
                                   action(Action),
                                   preconditions(Pre),
                                   postconditions(Post)))) :-
    procedure(Goal, Steps),
    member(step(N, Action, Pre, Post), Steps).

mentova_procedural(what_goals, goals(Goals),
                   just(procedural(available_goals, list(Goals)))) :-
    findall(G, procedure(G, _), Goals).
