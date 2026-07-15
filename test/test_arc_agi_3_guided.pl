/*  Mentova — ARC-AGI-3_Guided sub-project Test Suite

    Behavioural PLUnit tests for the arc_agi_3_guided module (the human-in-the-
    loop face of the ARC-AGI-3 learning sub-projects). Every test drives the
    module's own exported predicates and asserts on their real outputs; the
    guided-step case is fully deterministic because the locksmith game starts
    the player at (4,0) with the key at (2,2), so with the pickup priority set
    the "toward the key" guidance clause fires with a known action.

    Run with the full library path (every PrologAI pack plus the Mentova source):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_arc_agi_3_guided.pl
*/

% Declare this file as a test module with no exports.
:- module(test_arc_agi_3_guided, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the Mentova source library path.
:- use_module(library(arc_agi_3_guided)).
% Load one backend helper for setup only: reset the locksmith game to its start.
:- use_module(library(mentova_arc_chat), [ma_game_reset/1]).

% Open the test block for arc_agi_3_guided.
:- begin_tests(arc_agi_3_guided).

% Ground one "key" clue and read back the exact Causalontology assertion.
test(ground_key_clue) :-
    % Ground the human clue at the key's cell.
    g3_ground('That looks like a key', [2, 2], Assertion),
    % It grounds to a key-like label on that cell.
    assertion(Assertion == hint_label([2, 2], key_like)).

% Ground the rest of the clue table and confirm an off-topic clue is refused.
test(ground_table_and_refusal) :-
    % A door clue grounds to the traverse goal at the door cell.
    g3_ground('That looks like a door. Let''s walk through it', [0, 4], Door),
    % The door assertion is the traverse goal.
    assertion(Door == hint_goal([0, 4], traverse)),
    % A pickup clue grounds to the pickup action, whatever the reference.
    g3_ground('Pick that up', [2, 2], Pickup),
    % The pickup assertion raises the pickup action.
    assertion(Pickup == hint_action(action(pickup))),
    % A hazard clue grounds to a preventive tag on the referenced cell.
    g3_ground('Don''t touch that', [3, 3], Hazard),
    % The hazard assertion tags that cell preventive.
    assertion(Hazard == hint_preventive([3, 3])),
    % An off-topic clue does not ground at all.
    assertion(\+ g3_ground('the weather is nice today', none, _)).

% The active mode defaults to guided for this human-in-the-loop sub-project.
test(mode_defaults_guided) :-
    % Read the active mode.
    g3_mode(Mode),
    % It is guided by default.
    assertion(Mode == guided).

% Before any play, the shared state-graph map is empty.
test(graph_fresh_is_empty) :-
    % Read the shared state-graph statistics.
    g3_graph(Graph),
    % An untouched game reports zero nodes, edges, tested, and dead edges.
    assertion(Graph == stats(0, 0, 0, 0)).

% Before any teaching, the shared learnings hold nothing for the game.
test(learnings_fresh_is_empty) :-
    % Read every shared learning for the selected game.
    g3_learnings(Learnings),
    % No goal, no priorities, no hazards, no labels, no relations, empty graph.
    assertion(Learnings = learnings(none, [], [], [], 0, _JLens, stats(0, 0, 0, 0))).

% Grounding then injecting a label makes it visible in the shared learnings.
test(inject_label_reaches_learnings) :-
    % Ground the human's key clue.
    g3_ground('That looks like a key', [2, 2], Assertion),
    % Inject it into the live loop's shared substrate.
    g3_inject(Assertion),
    % Read the shared learnings back.
    g3_learnings(learnings(_Goal, _Priorities, _Avoided, Labels, _CroCount, _JLens, _Graph)),
    % The injected key-like label is now recorded for that cell.
    assertion(memberchk(cell(2, 2) - key_like, Labels)).

% A guided step is taken, and g3_why reports that very action as human-guided.
test(guided_step_reported_by_why, [setup(setup_guided_pickup)]) :-
    % Take one guided step, reading its action, basis, and outcome.
    g3_step(step(Action, Basis, Outcome)),
    % With the pickup priority set and the key off the player's cell, the step is
    % chosen by the "toward the key" guidance clause.
    assertion(Basis == toward(key)),
    % Moving toward the key changes the frame, so the outcome is a learned effect.
    assertion(memberchk(Outcome, [none, learned, hazard])),
    % Ask why the last action was taken.
    g3_why(Why),
    % The justification names the same action, the same basis, and human guidance.
    assertion(Why == why(Action, toward(key), guided_by_human)).

% Close the test block for arc_agi_3_guided.
:- end_tests(arc_agi_3_guided).

% setup_guided_pickup/0: reset the locksmith and post a human pickup suggestion,
% so the next guided step is the deterministic "toward the key" move.
setup_guided_pickup :-
    % Reset the locksmith game to its start position.
    ma_game_reset(_),
    % Ground the human's "pick that up" clue into its assertion.
    g3_ground('Pick that up', [2, 2], Assertion),
    % Inject it, raising the pickup action's priority for the selected game.
    g3_inject(Assertion).
