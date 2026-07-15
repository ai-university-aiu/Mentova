/*  Mentova — ARC-AGI-3_Solo Test Suite

    Behavioural PLUnit suite for the arc_agi_3_solo module, the named face of
    the unaided ARC-AGI-3 play sub-project. Its predicates delegate to the
    shared mentova_arc_chat backend; these tests drive that surface directly
    against the default local locksmith stand-in (game ls20), asserting real
    outputs computed by hand from the module's documented behaviour.

    Run with the full library path (every PrologAI pack plus the Mentova source):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_arc_agi_3_solo.pl
*/

% Declare this file as a test module with no exports.
:- module(test_arc_agi_3_solo, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load filesystem helpers, used to isolate the solo report write in a temp dir.
:- use_module(library(filesex)).
% Load the module under test from the library path.
:- use_module(library(arc_agi_3_solo)).

% Track the solo report files that already exist before the suite runs.
:- dynamic solo_reports_before/1.

% Record the pre-existing solo attempt reports so cleanup deletes only new ones.
s3_hermetic_setup :-
    % Read the current solo report basenames (empty if none or on error).
    ( catch(s3_attempts(Before), _, Before = []) -> true ; Before = [] ),
    % Replace any stale baseline record.
    retractall(solo_reports_before(_)),
    % Store the baseline for the cleanup step.
    assertz(solo_reports_before(Before)).

% Delete every solo report this suite created, so the test leaves the tree clean.
s3_hermetic_cleanup :-
    % Read the solo report basenames now present after the tests.
    ( catch(s3_attempts(After), _, After = []) -> true ; After = [] ),
    % Retrieve the baseline recorded at setup.
    ( solo_reports_before(Before) -> true ; Before = [] ),
    % The reports created during the suite are those not in the baseline.
    subtract(After, Before, Created),
    % Delete each created report from the solo attempts directory.
    forall(member(F, Created),
           % Build the relative path and remove the file, ignoring errors.
           ( atom_concat('ARC-AGI-3_Solo_Attempts/', F, Path),
             catch(delete_file(Path), _, true) )).

% Open the test block, recording and cleaning solo reports so it is hermetic.
:- begin_tests(arc_agi_3_solo, [setup(s3_hermetic_setup), cleanup(s3_hermetic_cleanup)]).

% s3_start begins a solo attempt and s3_mode then reports the solo mode.
test(s3_start_activates_solo_mode) :-
    % Begin a fresh solo attempt on the selected environment.
    s3_start,
    % Read the active mode after starting.
    s3_mode(Mode),
    % Starting a solo attempt makes solo the active mode.
    assertion(Mode == solo).

% s3_learnings reports the seven-slot learnings term; untaught, the human-set
% fields are empty and the counts are non-negative.
test(s3_learnings_report_untaught_shape) :-
    % Begin a fresh solo attempt so the shared learnings are readable.
    s3_start,
    % Read all shared learnings the sub-project uses.
    s3_learnings(Learnings),
    % The learnings are the documented seven-slot term.
    Learnings = learnings(Goal, Priorities, Avoided, Labels, CroCount, JLens, Graph),
    % No human taught a goal, so the goal is none.
    assertion(Goal == none),
    % No human-suggested priorities were given, so the list is empty.
    assertion(Priorities == []),
    % No hazards were declared, so the avoided-cell list is empty.
    assertion(Avoided == []),
    % No objects were labelled, so the label list is empty.
    assertion(Labels == []),
    % The count of learned causal relations is a non-negative integer.
    assertion((integer(CroCount), CroCount >= 0)),
    % The Jacobian-Lens reading is a list of held concepts.
    assertion(is_list(JLens)),
    % The state-graph slot is the four-number stats term.
    assertion(Graph = stats(_, _, _, _)).

% s3_graph returns the same state-graph stats term the learnings expose,
% since both read the one shared store for the selected game.
test(s3_graph_mirrors_learnings_graph_slot) :-
    % Begin a fresh solo attempt.
    s3_start,
    % Read the graph directly through the sub-project's graph accessor.
    s3_graph(Graph),
    % The graph is the four-number stats term (nodes, edges, tested, dead).
    Graph = stats(Nodes, Edges, Tested, Dead),
    % Every field of the stats term is a non-negative integer.
    assertion((integer(Nodes), Nodes >= 0, integer(Edges), Edges >= 0,
               integer(Tested), Tested >= 0, integer(Dead), Dead >= 0)),
    % Read the learnings' own graph slot from the same shared store.
    s3_learnings(learnings(_, _, _, _, _, _, LearningsGraph)),
    % The two accessors agree, confirming one shared exploration map.
    assertion(Graph == LearningsGraph).

% s3_attempts returns a proper list of stamped solo report filenames.
test(s3_attempts_returns_report_filename_list) :-
    % Read the solo attempt report filenames, newest first.
    s3_attempts(Files),
    % The result is a proper list.
    assertion(is_list(Files)),
    % Every listed file is an atom naming a stamped plain-text report.
    assertion(forall(member(F, Files),
                     (atom(F), atom_concat('ARC-AGI-3_Solo_', _, F),
                      atom_concat(_, '.txt', F)))).

% s3_tick advances one solo step and returns a telemetry dict for the run;
% the report write is confined to a throwaway directory so the test is hermetic.
test(s3_tick_advances_one_solo_step) :-
    % Run the tick inside a temporary working directory, always restoring after.
    setup_call_cleanup(
        % Make a fresh temp directory and enter it, remembering the old cwd.
        ( tmp_file(arc_solo_test, Dir), make_directory(Dir), working_directory(Old, Dir) ),
        % Start a solo attempt, take one step, and check the telemetry.
        ( s3_start,
          % Advance the solo run one step and capture the telemetry.
          s3_tick(Telemetry),
          % The telemetry is a dict.
          assertion(is_dict(Telemetry)),
          % The first tick is step one.
          assertion(get_dict(step, Telemetry, 1)),
          % The step is played on the default local locksmith stand-in.
          assertion(get_dict(game, Telemetry, ls20)),
          % The done flag is a boolean.
          ( get_dict(done, Telemetry, Done), assertion((Done == true ; Done == false)) ),
          % The telemetry carries a rendered frame.
          assertion(get_dict(frame, Telemetry, _)),
          % The telemetry names the run outcome.
          assertion(get_dict(outcome, Telemetry, _)) ),
        % Restore the old working directory and discard the temp directory.
        ( working_directory(_, Old), catch(delete_directory_and_contents(Dir), _, true) )
    ).

% Close the test block for arc_agi_3_solo.
:- end_tests(arc_agi_3_solo).
