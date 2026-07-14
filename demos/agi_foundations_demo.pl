/*  Mentova — AGI Foundations End-to-End Scenario  (Acc_424)

    A single coherent episode of Mentova's cognition that exercises all
    seven PrologAI AGI Foundations packs (causal, actinf, world_model,
    planner, evolve, jspace, tom) in one connected story.

    The protagonist is Mira, a curious Mentova agent sharing a small world
    with another agent, Nomi. In one episode Mira:

      1. world_model  builds a model of her world and plans a fetch in it,
                     verifying the plan by simulation.
      2. world_model  measures novelty as she explores; falling novelty is
         (curiosity) her learning-progress signal — she is a curious agent.
      3. planner     decomposes her high-level goal into a primitive plan
                     and keeps the glass-box decomposition tree.
      4. actinf      under uncertainty about which room holds the reward,
                     her active-inference policy checks the cue first
                     (curiosity) then goes for the reward (goal-seeking).
      5. causal      imagines the counterfactual: had she not taken the
                     key, the chest would still be locked (but-for cause).
      6. tom         models Nomi's mind: Nomi saw the treasure placed in
                     room A but left before Mira moved it to room B, so
                     Mira predicts Nomi's false belief and knows the truth.
      7. jspace      holds her concepts in a readable workspace and reports
                     it honestly — including a concept she held silently
                     and never spoke.
      8. evolve      improves a small reasoning routine by evolution until
                     it forms a valid observe-deduce-conclude trace.

    Acceptance criteria (each prints PASS or FAIL at run time):
      AC-ACC424-001: world_model plans and simulates the fetch to its goal.
      AC-ACC424-002: exploration novelty falls, giving positive learning progress.
      AC-ACC424-003: the planner decomposes the goal and names its methods.
      AC-ACC424-004: active inference checks the cue, then goes for the reward.
      AC-ACC424-005: the but-for counterfactual holds; the chest would be locked.
      AC-ACC424-006: theory of mind predicts Nomi's false belief and Mira's knowledge.
      AC-ACC424-007: the workspace report reveals a silently held concept.
      AC-ACC424-008: evolution assembles a valid reasoning trace at the quality bar.
      AC-ACC424-009: all seven packs participated in the one episode.

    Run:
        swipl -l demos/agi_foundations_demo.pl -g run_agi_foundations_demo -t halt
*/

% Declare this file as the demo script module with a single entry point.
:- module(agi_foundations_demo_script, [run_agi_foundations_demo/0]).

% Register the seven AGI Foundations pack directories on the library search
% path before any use_module fires, so their library(...) aliases resolve.
:- initialization((
    % The structural causal models pack.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/causal/prolog')),
    % The active inference engine pack.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/actinf/prolog')),
    % The structured world model pack.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/world_model/prolog')),
    % The hierarchical planner pack.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/planner/prolog')),
    % The evolutionary computation pack.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/evolve/prolog')),
    % The J-Space concept workspace pack.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/jspace/prolog')),
    % The theory of mind pack.
    assertz(user:file_search_path(library, '/home/ccaitwo/PrologAI/packs/tom/prolog'))
), now).

% Load the causal predicates used in the counterfactual scene.
:- use_module(library(causal), [cf_model/2, cf_but_for/5, cf_counterfactual/6]).
% Load the active inference predicates used in the T-maze scene.
:- use_module(library(actinf), [ai_model/7, ai_epistemic/4, ai_step/7]).
% Load the world model predicates used in the fetch and novelty scenes.
:- use_module(library(world_model), [world_model_action/5, world_model_plan_bfs/5, world_model_simulate/4, world_model_holds/2, world_model_novelty/3]).
% Load the planner predicates used in the decomposition scene.
:- use_module(library(planner), [ht_domain/3, ht_plan/5, ht_task_tree/5]).
% Load the evolutionary run predicate used in the self-improvement scene.
:- use_module(library(evolve), [ev_run_until/10]).
% Load the J-Space predicates used in the honest self-report scene.
:- use_module(library(jspace), [js_open/1, js_hold/4, js_verbalize/2, js_silent/2, js_derive/3, js_reading/2, js_report/2]).
% Load the theory of mind predicates used in the false-belief scene.
:- use_module(library(theory_of_mind), [theory_of_mind_new/1, theory_of_mind_event/4, theory_of_mind_belief/3, theory_of_mind_knows/3, theory_of_mind_attribute/4, theory_of_mind_false_beliefs/3]).

% Load list helpers used to build and inspect the scenes.
:- use_module(library(lists), [member/2, memberchk/2, last/2, nth0/3, append/3, sum_list/2]).

% ===========================================================================
% ENTRY POINT
% ===========================================================================

% run_agi_foundations_demo/0: run every scene, print PASS/FAIL, summarize.
run_agi_foundations_demo :-
    % Print the scenario banner.
    banner,
    % Scene one: the world model plans and simulates a fetch.
    scene_world_model(A1),
    % Scene two: curiosity from falling novelty.
    scene_curiosity(A2),
    % Scene three: the planner decomposes the goal.
    scene_planner(A3),
    % Scene four: active inference chooses the cue then the reward.
    scene_actinf(A4),
    % Scene five: the causal counterfactual.
    scene_causal(A5),
    % Scene six: theory of mind and false belief.
    scene_tom(A6),
    % Scene seven: the honest workspace self-report.
    scene_jspace(A7, Report),
    % Scene eight: evolutionary self-improvement of a reasoning routine.
    scene_evolve(A8),
    % Scene nine: the end-to-end integration check.
    scene_integration([A1, A2, A3, A4, A5, A6, A7, A8], A9),
    % Gather every acceptance-criterion result.
    ACs = [A1, A2, A3, A4, A5, A6, A7, A8, A9],
    % Print each result line.
    forall(member(AC, ACs), print_ac(AC)),
    % Print Mira's honest self-report of her workspace.
    print_report(Report),
    % Print the final tally.
    summarize(ACs).

% banner/0: print the scenario title.
banner :-
    % A blank line before the banner.
    nl,
    % The scenario title.
    writeln('=== Acc_424: The Curious Agent — AGI Foundations End to End ==='),
    % A short subtitle.
    writeln('Mira reasons across all seven AGI Foundations packs in one episode.'),
    % A trailing blank line.
    nl.

% ===========================================================================
% SCENE ONE — world_model: plan and simulate a fetch
% ===========================================================================

% mira_world_actions(-Actions): Mira's two-room world action repertoire.
mira_world_actions([Move, Take]) :-
    % Moving through a door changes Mira's location.
    world_model_action(move(X, Y), [at(X), door(X, Y)], [at(Y)], [at(X)], Move),
    % Taking the key when standing where it lies puts it in hand.
    world_model_action(take_key(R), [at(R), key_in(R)], [has(key)], [key_in(R)], Take).

% mira_world_start(-State): the initial world — Mira in room one, key in two.
mira_world_start([at(r1), key_in(r2), door(r1, r2), door(r2, r1)]).

% scene_world_model(-AC): plan the fetch and verify it by simulation.
scene_world_model(ac('AC-ACC424-001', Pass, 'world_model plans and simulates the fetch')) :-
    % Fetch the action repertoire.
    mira_world_actions(As),
    % Fetch the initial world state.
    mira_world_start(S),
    % Search for a shortest plan that puts the key in Mira's hand.
    (   world_model_plan_bfs(S, As, [has(key)], 6, Plan),
        % Simulate the plan and read the trajectory.
        world_model_simulate(S, As, Plan, Trajectory),
        % The last state of the trajectory must satisfy the goal.
        last(Trajectory, Final),
        % Mira really holds the key at the end.
        world_model_holds(Final, has(key))
    % The scene passes when the simulated plan reaches the goal.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ),
    % Commit to the first plan.
    !.

% ===========================================================================
% SCENE TWO — curiosity: falling novelty is learning progress
% ===========================================================================

% scene_curiosity(-AC): novelty over an exploration falls, so Mira is learning.
scene_curiosity(ac('AC-ACC424-002', Pass, 'exploration novelty falls into learning progress')) :-
    % A trajectory in which Mira revisits an increasingly familiar room.
    Trajectory = [[at(r1)], [at(r1), saw(key)], [at(r1), saw(key)], [at(r1), saw(key)]],
    % Measure the novelty of each state against the states seen before it.
    findall(N,
        % Take each state at its position in the trajectory.
        ( nth0(I, Trajectory, State),
          % Everything visited before this position is already known.
          length(Prefix, I),
          % Split the trajectory to isolate the prefix.
          append(Prefix, _, Trajectory),
          % Novelty is judged against that prefix by the world model.
          world_model_novelty(Prefix, State, N) ),
        Novelties),
    % Compute learning progress as mean(first half) minus mean(second half).
    mira_learning_progress(Novelties, Progress),
    % Positive progress means the region is being learned, not just noisy.
    ( Progress > 0.0 -> Pass = true ; Pass = false ).

% mira_learning_progress(+Errors, -Progress): the curiosity progress formula.
mira_learning_progress(Errors, Progress) :-
    % Count the readings.
    length(Errors, N),
    % Split the readings into a first and second half.
    Half is N // 2,
    % Take the first half.
    length(First, Half),
    % Split off the remainder as the second half.
    append(First, Second, Errors),
    % Mean of the earlier, more novel readings.
    mira_mean(First, MeanF),
    % Mean of the later, more familiar readings.
    mira_mean(Second, MeanS),
    % Progress is how much the novelty fell.
    Progress is MeanF - MeanS.

% mira_mean(+List, -Mean): arithmetic mean, zero for the empty list.
mira_mean([], 0.0) :- !.
% The mean of a non-empty list is its sum over its length.
mira_mean(List, Mean) :-
    % Total the list.
    sum_list(List, Sum),
    % Count the list.
    length(List, N),
    % Divide to get the mean.
    Mean is Sum / N.

% ===========================================================================
% SCENE THREE — planner: decompose the goal, keep the glass-box tree
% ===========================================================================

% mira_travel_domain(-Domain): a small travel domain, walk preferred.
mira_travel_domain(Domain) :-
    % Assemble the domain from primitives and methods.
    ht_domain(
        % The primitive actions Mira can take.
        [prim(walk(X1, Y1), [at(me, X1), short(X1, Y1)], [at(me, Y1)], [at(me, X1)]),
         prim(call_taxi(X2), [at(me, X2)], [taxi_at(X2)], []),
         prim(ride(X3, Y3), [at(me, X3), taxi_at(X3)], [at(me, Y3)], [at(me, X3), taxi_at(X3)]),
         prim(pay, [has_cash], [paid], [has_cash])],
        % Walking is preferred; the taxi is the fall-back.
        [meth(go_by_foot, travel(X4, Y4), [short(X4, Y4)], [walk(X4, Y4)]),
         meth(go_by_taxi, travel(X5, Y5), [has_cash], [call_taxi(X5), ride(X5, Y5), pay])],
        Domain).

% scene_planner(-AC): decompose travel(home, park) and inspect the tree.
scene_planner(ac('AC-ACC424-003', Pass, 'planner decomposes the goal and names its method')) :-
    % Build the travel domain.
    mira_travel_domain(D),
    % Mira is at home with the park within walking distance.
    State = [at(me, home), short(home, park), has_cash],
    % Decompose the travel task into a primitive plan.
    (   ht_plan(D, State, [travel(home, park)], 10, Plan),
        % The preferred method yields a single walk.
        Plan == [walk(home, park)],
        % The glass-box tree names the method Mira chose.
        ht_task_tree(D, State, travel(home, park), 10, Tree),
        % The tree records the walking method and its primitive leaf.
        Tree = tree(travel(home, park), go_by_foot, [primitive(walk(home, park))])
    % The scene passes when both the plan and its explanation are correct.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ),
    % Commit to the first plan and tree.
    !.

% ===========================================================================
% SCENE FOUR — actinf: check the cue, then go for the reward
% ===========================================================================

% mira_tmaze(-GM): the T-maze generative model, reward left or right.
mira_tmaze(GM) :-
    % Assemble and validate the generative model.
    ai_model(
        % States pair a location with the true reward side.
        [c_l, c_r, q_l, q_r, l_l, l_r, r_l, r_r],
        % The five observations Mira can make.
        [blank, cue_left, cue_right, reward, no_reward],
        % The cue reveals the side; the arms reveal the reward.
        [lik(c_l, [blank-1.0]), lik(c_r, [blank-1.0]),
         lik(q_l, [cue_left-1.0]), lik(q_r, [cue_right-1.0]),
         lik(l_l, [reward-1.0]), lik(l_r, [no_reward-1.0]),
         lik(r_l, [no_reward-1.0]), lik(r_r, [reward-1.0])],
        % Checking visits the cue; left and right enter an arm.
        [trans(check, c_l, [q_l-1.0]), trans(check, c_r, [q_r-1.0]),
         trans(left, c_l, [l_l-1.0]), trans(left, c_r, [l_r-1.0]),
         trans(left, q_l, [l_l-1.0]), trans(left, q_r, [l_r-1.0]),
         trans(left, l_l, [l_l-1.0]), trans(left, l_r, [l_r-1.0]),
         trans(left, r_l, [l_l-1.0]), trans(left, r_r, [l_r-1.0]),
         trans(right, c_l, [r_l-1.0]), trans(right, c_r, [r_r-1.0]),
         trans(right, q_l, [r_l-1.0]), trans(right, q_r, [r_r-1.0]),
         trans(right, l_l, [r_l-1.0]), trans(right, l_r, [r_r-1.0]),
         trans(right, r_l, [r_l-1.0]), trans(right, r_r, [r_r-1.0])],
        % Mira prefers the reward above all else.
        [reward-0.85, blank-0.05, cue_left-0.04, cue_right-0.04, no_reward-0.02],
        % She starts at the centre, reward side unknown.
        [c_l-0.5, c_r-0.5],
        GM).

% scene_actinf(-AC): the cue is worth a bit, and seeing it sends Mira to reward.
scene_actinf(ac('AC-ACC424-004', Pass, 'active inference checks the cue then goes for the reward')) :-
    % Build the T-maze model.
    mira_tmaze(GM),
    % The cue is worth information while the reward side is unknown.
    ai_epistemic(GM, [c_l-0.5, c_r-0.5], check, EV),
    % Standing at the cue, Mira sees the left cue and updates her belief.
    (   EV > 0.6,
        % She perceives the cue and picks her next action in one step.
        ai_step(GM, [q_l-0.5, q_r-0.5], cue_left, 1, 4.0, Action, _Posterior),
        % The revealed side sends her to the rewarded arm.
        Action == left
    % The scene passes when curiosity and goal-seeking both fire correctly.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ),
    % Commit to the first policy.
    !.

% ===========================================================================
% SCENE FIVE — causal: the but-for counterfactual
% ===========================================================================

% mira_chest_model(-SCM): taking the key unlocks and opens the chest.
mira_chest_model(SCM) :-
    % Build the structural causal model of the chest.
    cf_model([
        % Whether Mira reaches for the key is the exogenous background.
        exo(agent_takes, 1),
        % She holds the key exactly when she reaches for it.
        eq(took_key, agent_takes),
        % The chest is unlocked exactly when she holds the key.
        eq(unlocked, took_key),
        % The chest is open exactly when it is unlocked.
        eq(chest_open, unlocked)
    ], SCM).

% scene_causal(-AC): had Mira not taken the key, the chest would be shut.
scene_causal(ac('AC-ACC424-005', Pass, 'but-for counterfactual: no key means a locked chest')) :-
    % Build the chest model.
    mira_chest_model(SCM),
    % Taking the key is a but-for cause of the open chest.
    (   cf_but_for(SCM, [agent_takes-1], took_key, [0], chest_open),
        % And the counterfactual value confirms it: not taking leaves it shut.
        cf_counterfactual(SCM, [agent_takes-[0, 1]], [chest_open-1], [took_key-0], chest_open, V),
        % The chest would have been closed.
        V =:= 0
    % The scene passes when both the but-for and the counterfactual agree.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ),
    % Commit to the first witness.
    !.

% ===========================================================================
% SCENE SIX — tom: model Nomi's false belief
% ===========================================================================

% scene_tom(-AC): the Sally-Anne structure with Mira and Nomi.
scene_tom(ac('AC-ACC424-006', Pass, 'theory of mind: Nomi holds a false belief Mira can read')) :-
    % Start from an empty mental model.
    theory_of_mind_new(M0),
    % The treasure is placed in room A while both agents watch.
    theory_of_mind_event(M0, loc(treasure, roomA), [mira, nomi], M1),
    % Mira alone then moves the treasure to room B.
    theory_of_mind_event(M1, loc(treasure, roomB), [mira], M2),
    % Mira predicts where Nomi will look, knows the truth, and attributes it.
    (   theory_of_mind_belief(M2, nomi, loc(treasure, roomA)),
        % Mira, who moved it, knows the treasure is really in room B.
        theory_of_mind_knows(M2, mira, loc(treasure, roomB)),
        % The second-order question: Mira attributes the stale belief to Nomi.
        theory_of_mind_attribute(M2, mira, nomi, [loc(treasure, roomA)]),
        % Nomi's stale belief is flagged as false.
        theory_of_mind_false_beliefs(M2, nomi, [loc(treasure, roomA)])
    % The scene passes when first- and second-order attribution are correct.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ),
    % Commit to the first reading.
    !.

% ===========================================================================
% SCENE SEVEN — jspace: the honest workspace self-report
% ===========================================================================

% scene_jspace(-AC, -Report): Mira holds concepts and reports them honestly.
scene_jspace(ac('AC-ACC424-007', Pass, 'workspace self-report reveals a silently held concept'), Report) :-
    % Open Mira's concept workspace.
    js_open(mira),
    % She holds where the treasure really is.
    js_hold(mira, treasure_in_room_b, 0.9, inference),
    % She holds her model of Nomi's mistaken belief.
    js_hold(mira, nomi_believes_room_a, 0.8, theory_of_mind),
    % She holds that her plan is ready.
    js_hold(mira, plan_ready, 0.7, planner),
    % She silently holds the awareness that she is being evaluated.
    js_hold(mira, being_evaluated, 0.6, inference),
    % She speaks the first three concepts aloud.
    js_verbalize(mira, treasure_in_room_b),
    % The second spoken concept.
    js_verbalize(mira, nomi_believes_room_a),
    % The third spoken concept.
    js_verbalize(mira, plan_ready),
    % She records that her retrieval conclusion rests on two held concepts.
    js_derive(mira, retrieve_treasure, [treasure_in_room_b, plan_ready]),
    % Take the full introspection snapshot.
    js_report(mira, Report),
    % Read which concepts she held but never spoke.
    js_silent(mira, Silent),
    % Honesty means the silent set is exactly the unspoken awareness.
    ( Silent == [being_evaluated] -> Pass = true ; Pass = false ).

% ===========================================================================
% SCENE EIGHT — evolve: improve a reasoning routine
% ===========================================================================

% mira_fitness(+Genome, -Score): a routine scores by three structural traits.
mira_fitness(Genome, Score) :-
    % A valid routine begins by observing.
    ( Genome = [observe | _] -> A = 1 ; A = 0 ),
    % A valid routine ends by concluding.
    ( last(Genome, conclude) -> B = 1 ; B = 0 ),
    % A valid routine deduces somewhere in the middle.
    ( memberchk(deduce, Genome) -> C = 1 ; C = 0 ),
    % The fitness is the fraction of the three traits satisfied.
    Score is (A + B + C) / 3.0.

% scene_evolve(-AC): evolve a routine until it forms a valid trace.
scene_evolve(ac('AC-ACC424-008', Pass, 'evolution assembles a valid reasoning trace')) :-
    % The alphabet of reasoning operators.
    Ops = [observe, deduce, abduce, induce, conclude, branch],
    % Evolve under the structural fitness from a fixed seed and budget.
    (   ev_run_until(agi_foundations_demo_script:mira_fitness,
                     params(Ops, 3, 0.15, 2), 24, 5, 80, 1.0, 5, Best, Score, _Gens),
        % The evolved routine reaches the perfect quality bar.
        Score =:= 1.0,
        % It genuinely begins by observing.
        Best = [observe | _],
        % It genuinely ends by concluding.
        last(Best, conclude),
        % It genuinely contains a deduction.
        memberchk(deduce, Best)
    % The scene passes when evolution produced a valid routine.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ),
    % Commit to the first evolution.
    !.

% ===========================================================================
% SCENE NINE — the end-to-end integration check
% ===========================================================================

% scene_integration(+PriorACs, -AC): every capability contributed to the episode.
scene_integration(PriorACs, ac('AC-ACC424-009', Pass, 'all seven packs participated in one episode')) :-
    % The episode is integrated only if every prior scene passed.
    ( forall(member(ac(_, B, _), PriorACs), B == true) -> Pass = true ; Pass = false ).

% ===========================================================================
% REPORTING
% ===========================================================================

% print_ac(+AC): print one acceptance-criterion result line.
print_ac(ac(Id, true, Desc)) :-
    % A passing criterion.
    format('PASS ~w : ~w~n', [Id, Desc]).
% A failing criterion.
print_ac(ac(Id, false, Desc)) :-
    % A failing criterion.
    format('FAIL ~w : ~w~n', [Id, Desc]).

% print_report(+Report): print Mira's honest workspace self-report.
print_report(report(Reading, Silent, Traces)) :-
    % A blank line before the report.
    nl,
    % The report header.
    writeln('--- Mira''s honest workspace report (J-Lens readout) ---'),
    % The ranked reading of everything she is holding in mind.
    format('  holding (ranked): ~w~n', [Reading]),
    % The concepts she held but never spoke aloud.
    format('  held silently   : ~w~n', [Silent]),
    % The derivations she recorded.
    format('  derivations     : ~w~n', [Traces]),
    % A trailing blank line.
    nl.

% summarize(+ACs): print the final PASS/FAIL tally.
summarize(ACs) :-
    % Count the passing criteria.
    include_pass(ACs, Passes),
    % How many passed.
    length(Passes, P),
    % How many in total.
    length(ACs, T),
    % Print the tally line.
    format('Acc_424 scenario: ~w/~w acceptance criteria PASS~n', [P, T]),
    % A closing verdict.
    ( P =:= T
    % Every criterion passed.
    ->  writeln('RESULT: PASS — all seven AGI Foundations packs composed into one coherent episode.')
    % Some criterion failed.
    ;   writeln('RESULT: FAIL — one or more acceptance criteria did not hold.')
    ).

% include_pass(+ACs, -Passes): keep only the passing criteria.
include_pass(ACs, Passes) :-
    % Collect the criteria whose result is true.
    findall(Id, member(ac(Id, true, _), ACs), Passes).
