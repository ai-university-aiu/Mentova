/*  Mentova — Procedural Reasoning Test Suite  (Rung 36)

    Behavioural PLUnit tests for the 'procedural' module, which reasons about
    how to accomplish a goal through an ordered plan of steps, each carrying
    preconditions and postconditions.

    Run with the full PrologAI library path plus the Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_procedural.pl
*/

% Declare this file as a test module with no exports.
:- module(test_procedural, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(procedural)).

% Open the test block for the procedural module.
:- begin_tests(procedural).

% AC-PROC-001: plan_for returns the goal's ordered steps and their count.
test(plan_for_make_tea_count_and_first_step) :-
    % Ask for the plan for the make_tea goal.
    mentova_procedural(plan_for(make_tea), Result, _Just),
    % The result names the goal, carries the step list, and its length.
    Result = plan(make_tea, Steps, N),
    % The make_tea procedure has exactly six steps.
    assertion(N == 6),
    % The reported step list is exactly as long as the count says.
    assertion(length(Steps, 6)),
    % The first step is boiling the water, with its documented pre/postconditions.
    assertion(Steps = [step(1, boil_water, [has(water), has(kettle)], [water_boiled]) | _]).

% AC-PROC-002: the justification mirrors the goal, steps, and count.
test(plan_for_justification_is_glass_box) :-
    % Ask for the plan for the make_tea goal, keeping the justification.
    mentova_procedural(plan_for(make_tea), plan(make_tea, Steps, N), Just),
    % The justification restates the goal, the same step list, and the same count.
    assertion(Just == just(procedural(goal(make_tea), steps(Steps), count(N)))).

% AC-PROC-003: a different goal has its own, different step count.
test(plan_for_bake_bread_has_five_steps) :-
    % Ask for the plan for the bake_bread goal.
    mentova_procedural(plan_for(bake_bread), plan(bake_bread, _Steps, N), _Just),
    % The bake_bread procedure has exactly five steps, not six.
    assertion(N == 5).

% AC-PROC-004: what_goals lists every procedure the module knows, in order.
test(what_goals_lists_all_four_procedures) :-
    % Ask for the catalogue of available goals.
    mentova_procedural(what_goals, Result, _Just),
    % The result wraps the list of goal names.
    Result = goals(Goals),
    % All four procedures appear, in their declaration order.
    assertion(Goals == [make_tea, change_tyre, plant_seed, bake_bread]).

% AC-PROC-005: step_n retrieves a single named step with its conditions.
test(step_n_third_make_tea_step) :-
    % Ask for the third step of the make_tea procedure, taking the one solution.
    once(mentova_procedural(step_n(make_tea, 3), Result, _Just)),
    % That step adds the teabag, gated on having a teabag and a ready cup.
    assertion(Result == step(3, add_teabag, [has(teabag), cup_ready], [teabag_in_cup])).

% AC-PROC-006: step_n backtracks over every step index of a goal.
test(step_n_enumerates_all_step_indices) :-
    % Collect every step index step_n yields for the change_tyre procedure.
    findall(N, mentova_procedural(step_n(change_tyre, N), _R, _J), Indices),
    % The six change_tyre steps are enumerated one through six in order.
    assertion(Indices == [1, 2, 3, 4, 5, 6]).

% AC-PROC-007: execute reports every step's outcome for a fully-provisioned start.
test(execute_make_tea_reports_all_outcomes) :-
    % Start with every consumable the make_tea steps require.
    Init = [has(water), has(kettle), has(cup), has(teabag)],
    % Execute the make_tea procedure from that starting state.
    mentova_procedural(execute(make_tea, Init), Result, _Just),
    % The execution report is the outcome record for the goal.
    Result = executed(make_tea, Done, FinalState),
    % Spell out the outcome list: each step's index, action, and postconditions.
    Expected = [ done(1, boil_water,     [water_boiled]),
                 done(2, get_cup,        [cup_ready]),
                 done(3, add_teabag,     [teabag_in_cup]),
                 done(4, pour_water,     [tea_steeping]),
                 done(5, wait_3_minutes, [tea_ready]),
                 done(6, remove_teabag,  [tea_complete]) ],
    % Every step is reported, in order, with its documented postconditions.
    assertion(Done == Expected),
    % The module threads its final state from the base clause, so it is empty.
    assertion(FinalState == final_state([])).

% Close the test block for the procedural module.
:- end_tests(procedural).
