/*  Mentova — Observe_Game_Play_Run Test Suite

    Behavioural PLUnit tests for the observe_game_play module, which runs a Solo
    attempt on one local ARC-AGI-3-style game while recording a per-step
    observation trace, analyses that trace into a structured mentor report, and
    writes the notes to disk. The tests drive the four exported predicates
    (ogp_run/3, ogp_run/2, ogp_trace/1, ogp_notes_file/1) on the self-contained
    locksmith environment (ls20) and assert the module's documented cross-predicate
    invariants: the report's step count equals the trace length, the choice-basis
    tally sums to the step count, every diagnostic pairs one-to-one with a
    candidate intervention, and the notes file lands on disk keyed to the game.

    Run with the full PrologAI pack library path plus the Mentova source:
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" test/test_observe_game_play.pl
*/

% Declare this file as a test module with no exports.
:- module(test_observe_game_play, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the Mentova source library path.
:- use_module(library(observe_game_play)).
% Load list helpers for sum_list/2 used to check the basis tally.
:- use_module(library(lists)).

% Open the test block for observe_game_play.
:- begin_tests(observe_game_play).

% AC-OGP-001: ogp_run/3 returns a report/8 keyed to the game, whose step count
% equals the length of the recorded trace.
test(run_returns_report_keyed_to_the_game) :-
    % Observe a Solo attempt on the local locksmith game under a small budget.
    ogp_run(ls20, 8, Report),
    % Unpack the structured report, naming only the fields this test inspects.
    Report = report(Game, Outcome, Steps, _Bases, _Stuck, _Cog, _Missing, _Interventions),
    % The report is keyed to the game that was observed.
    assertion(Game == ls20),
    % The observed step count is a non-negative integer.
    assertion(integer(Steps)),
    % And it is not negative.
    assertion(Steps >= 0),
    % The outcome is a ground text (an atom for a finished run, a string otherwise).
    assertion((atom(Outcome) ; string(Outcome))),
    % Read back the per-step trace of the same run.
    ogp_trace(Trace),
    % Measure its length.
    length(Trace, TraceLen),
    % The report's step count is exactly the number of trace records.
    assertion(Steps == TraceLen).

% AC-OGP-002: the trace is a keysorted list of well-formed obs/5 records, and the
% choice-basis distribution tallies to one entry per step.
test(trace_records_are_well_formed_and_sorted) :-
    % Observe a fresh Solo attempt.
    ogp_run(ls20, 8, Report),
    % Name the step count and the basis distribution from the report.
    Report = report(_, _, Steps, Bases, Stuck, _, _, _),
    % Read the per-step trace.
    ogp_trace(Trace),
    % The trace is a proper list.
    assertion(is_list(Trace)),
    % Every record is a Step-obs(Action,Basis,Provenance,Stale,Outcome) pair.
    forall(member(Step - Obs, Trace),
           % The key is an integer step and the value is a five-argument obs term.
           ( assertion(integer(Step)), assertion(Obs = obs(_, _, _, _, _)) )),
    % The trace is already ordered by step: re-keysorting leaves it unchanged.
    keysort(Trace, ResortedTrace),
    % Sortedness holds.
    assertion(Trace == ResortedTrace),
    % Collect the per-basis counts from the distribution.
    findall(Count, member(_ - Count, Bases), Counts),
    % Sum them.
    sum_list(Counts, BasisTotal),
    % Every step contributes exactly one basis, so the tally sums to the step count.
    assertion(BasisTotal == Steps),
    % The stuck picture is a stuck(MaxStale,AtStep) term.
    Stuck = stuck(MaxStale, AtStep),
    % The peak staleness is a non-negative integer.
    assertion(integer(MaxStale)),
    % And it is not negative.
    assertion(MaxStale >= 0),
    % The step at which it peaked is an integer.
    assertion(integer(AtStep)).

% AC-OGP-003: every diagnostic flag maps to exactly one candidate mentoring line,
% and the end-cognition counts are well-formed.
test(diagnostics_pair_one_to_one_with_interventions) :-
    % Observe a Solo attempt.
    ogp_run(ls20, 8, Report),
    % Name the cognition, the missing-diagnostics list, and the interventions.
    Report = report(_, _, _, _, _, cog(_, Laws, _, Deaths), Missing, Interventions),
    % The diagnostics form a list.
    assertion(is_list(Missing)),
    % The interventions form a list.
    assertion(is_list(Interventions)),
    % Count the diagnostics.
    length(Missing, MissingCount),
    % Count the interventions.
    length(Interventions, InterventionCount),
    % Each diagnostic yields exactly one candidate mentoring line, so the counts match.
    assertion(MissingCount == InterventionCount),
    % The world-model law count is a non-negative integer.
    assertion(integer(Laws)),
    % And it is not negative.
    assertion(Laws >= 0),
    % The death count is a non-negative integer.
    assertion(integer(Deaths)),
    % And it is not negative.
    assertion(Deaths >= 0).

% AC-OGP-004: ogp_run/3 writes durable mentor notes to disk, and ogp_notes_file/1
% reports the path of the file just written, keyed to the game.
test(notes_are_written_to_disk) :-
    % Observe a Solo attempt, which analyses the trace and writes the notes.
    ogp_run(ls20, 8, _Report),
    % Ask where the last notes were written.
    ogp_notes_file(Path),
    % The path is an atom.
    assertion(atom(Path)),
    % The notes file exists on disk.
    assertion(exists_file(Path)),
    % Its name carries the observed game's id.
    assertion(sub_atom(Path, _, _, _, ls20)).

% AC-OGP-005: ogp_run/2 observes a run at the current solo budget and produces a
% fresh, self-consistent report whose trace is reset to that run alone.
test(run_at_current_solo_budget) :-
    % Set a small current solo budget so the arity-two run stays bounded and fast.
    mentova_arc_chat:ma_set_solo_budget(6),
    % Observe a Solo attempt at the current budget (no explicit budget argument).
    ogp_run(ls20, Report),
    % Name the game and step count from the report.
    Report = report(Game, _, Steps, _, _, _, _, _),
    % The report is keyed to the observed game.
    assertion(Game == ls20),
    % The step count is a non-negative integer.
    assertion(integer(Steps)),
    % And it is not negative.
    assertion(Steps >= 0),
    % Read back the trace, which the run cleared and rebuilt for itself.
    ogp_trace(Trace),
    % Measure its length.
    length(Trace, TraceLen),
    % The trace reflects exactly this run, so its length equals the reported steps.
    assertion(Steps == TraceLen).

% Close the test block for observe_game_play.
:- end_tests(observe_game_play).
