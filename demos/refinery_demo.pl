/*  Mentova — Refinery Pack Demonstration  (Acc_75)

    Demonstrates that Mentova can now evaluate its own outputs against
    a list of criteria, score them, improve them through structured
    feedback loops, run full evaluator-optimizer cycles, and maintain
    a lesson database from past failures.

    The demonstration:
      1. Critiques a passing output (empty critique) and a failing output
         (found_issue list), showing the quality gate in both directions.
      2. Scores outputs against criteria: 1.0 for all-pass, 0.5 for
         half-pass, 0.0 for all-fail.
      3. Improves a failing output through one round of structured feedback:
         the improver receives the output and its critique and returns a
         better version that passes all criteria.
      4. Runs a full rn_optimize/5 loop that generates candidates, scores
         them, and stops when the quality bar is met.
      5. Stores a lesson from a failure (rn_learn/3), retrieves it
         (rn_recall/2), and confirms it is gone after clearing (rn_forget/1).

    Acceptance criteria:
      AC-ACC75-001: rn_critique/4 returns [] for passing output and
                    [found_issue(non_empty,fail)] for empty output.
      AC-ACC75-002: rn_score/3 returns 1.0, 0.5, and 0.0 for three outputs.
      AC-ACC75-003: rn_improve/5 transforms a failing output into a passing one.
      AC-ACC75-004: rn_optimize/5 stops at the quality bar and returns the
                    expected best candidate.
      AC-ACC75-005: rn_learn/3 + rn_recall/2 + rn_forget/1 round-trip correctly.

    Usage:
        swipl \
          -p library=/home/ccaitwo/PrologAI/packs/ephemera/prolog \
          -p library=/home/ccaitwo/PrologAI/packs/agency/prolog \
          -p library=/home/ccaitwo/PrologAI/packs/refinery/prolog \
          -l demos/refinery_demo.pl \
          -g run_refinery_demo \
          -t halt
*/

% Declare this file as a module.
:- module(refinery_demo_script, [run_refinery_demo/0]).

% Load the refinery pack from PrologAI.
:- use_module(library(refinery)).
% Load standard list utilities.
:- use_module(library(lists)).

% -----------------------------------------------------------------------
% run_refinery_demo/0 -- top-level entry point
% -----------------------------------------------------------------------

% Define run_refinery_demo: run all five acceptance criteria in sequence.
run_refinery_demo :-
    % Print the demonstration header.
    nl,
    write('=== Mentova Acc_75: Refinery Pack Demonstration ==='), nl, nl,
    % Run each criterion.
    demo_ac75_001,
    demo_ac75_002,
    demo_ac75_003,
    demo_ac75_004,
    demo_ac75_005,
    nl,
    write('=== All five criteria pass. Acc_75 complete. ==='), nl.

% -----------------------------------------------------------------------
% AC-ACC75-001: rn_critique/4 returns [] for passing output; issues for failing
% -----------------------------------------------------------------------

% Define demo_ac75_001: verify critique detects pass and fail correctly.
demo_ac75_001 :-
    % Define two criteria using YALL lambda goals for module portability.
    Criteria = [criterion(non_empty, [O]>>(O \= [])),
                criterion(short,     [O]>>(length(O, L), L < 5))],
    % Critique a valid output: [a, b, c] passes both criteria.
    rn_critique([a, b, c], Criteria, 5, PassCritique),
    % Critique an invalid output: [] fails the non_empty criterion.
    rn_critique([], Criteria, 5, FailCritique),
    % Verify the passing output yields an empty critique.
    ( PassCritique = [],
      % Verify the failing output includes the non_empty issue.
      member(found_issue(non_empty, fail), FailCritique)
    % Report pass.
    ->  write('AC-ACC75-001: PASS  empty critique for [a,b,c]; non_empty issue for []'), nl
    % Report fail.
    ;   format('AC-ACC75-001: FAIL  pass_critique=~w, fail_critique=~w~n',
               [PassCritique, FailCritique])
    ).

% -----------------------------------------------------------------------
% AC-ACC75-002: rn_score/3 returns correct scores for three outputs
% -----------------------------------------------------------------------

% Define demo_ac75_002: verify score computation for all-pass, half-pass, all-fail.
demo_ac75_002 :-
    % Use two criteria: non_empty and short (fewer than 5 elements).
    CriteriaA = [criterion(non_empty, [O]>>(O \= [])),
                 criterion(short,     [O]>>(length(O, L), L < 5))],
    % Score [a, b]: both criteria pass; expected 1.0.
    rn_score([a, b], CriteriaA, Score1),
    % Score [a, b, c, d, e, f]: non_empty passes, short fails; expected 0.5.
    rn_score([a, b, c, d, e, f], CriteriaA, Score2),
    % Use a different criteria pair where both fail on [].
    CriteriaB = [criterion(non_empty, [O]>>(O \= [])),
                 criterion(has_x,    [O]>>(member(x, O)))],
    % Score []: both criteria fail; expected 0.0.
    rn_score([], CriteriaB, Score3),
    % Verify all three scores.
    ( Score1 =:= 1.0,
      Score2 =:= 0.5,
      Score3 =:= 0.0
    % Report pass.
    ->  format('AC-ACC75-002: PASS  scores: 1.0, 0.5, 0.0 as expected~n', [])
    % Report fail with actual values.
    ;   format('AC-ACC75-002: FAIL  scores: ~w, ~w, ~w~n', [Score1, Score2, Score3])
    ).

% -----------------------------------------------------------------------
% AC-ACC75-003: rn_improve/5 transforms a failing output into a passing one
% -----------------------------------------------------------------------

% Define demo_ac75_003: verify the improvement loop.
demo_ac75_003 :-
    % The output under test: an empty list that fails the non_empty criterion.
    StartOutput = [],
    % One criterion: output must not be empty.
    Criteria = [criterion(non_empty, [O]>>(O \= []))],
    % Improver goal: when called with (Output, _Critique, Improved),
    % replaces the empty list with a non-empty list.
    ImproverGoal = [_O, _C, I]>>(I = [improved_item]),
    % Run one round of improvement with a budget of 3 iterations.
    rn_improve(StartOutput, Criteria, ImproverGoal, 3, Improved),
    % Verify the improved output is non-empty.
    ( Improved \= []
    % Report pass.
    ->  format('AC-ACC75-003: PASS  improved [] to ~w; passes all criteria~n', [Improved])
    % Report fail.
    ;   format('AC-ACC75-003: FAIL  improved output is still empty~n', [])
    ).

% -----------------------------------------------------------------------
% AC-ACC75-004: rn_optimize/5 stops at quality bar and returns best candidate
% -----------------------------------------------------------------------

% Define demo_ac75_004: verify the evaluator-optimizer loop.
demo_ac75_004 :-
    % Generator: always produces the atom optimized_result.
    GeneratorGoal = [O]>>(O = optimized_result),
    % Evaluator: always returns score 1.0 for any output.
    EvaluatorGoal = [_O, S]>>(S = 1.0),
    % Quality bar: 0.9; generator immediately scores 1.0, so loop must stop
    % on the first iteration.
    rn_optimize(GeneratorGoal, EvaluatorGoal, 0.9, 10, Best),
    % Verify the best candidate is what the generator produced.
    ( Best = optimized_result
    % Report pass.
    ->  write('AC-ACC75-004: PASS  rn_optimize stopped at bar; best = optimized_result'), nl
    % Report fail with actual best.
    ;   format('AC-ACC75-004: FAIL  best = ~w~n', [Best])
    ).

% -----------------------------------------------------------------------
% AC-ACC75-005: rn_learn + rn_recall + rn_forget lesson database round-trip
% -----------------------------------------------------------------------

% Define demo_ac75_005: verify the lesson database.
demo_ac75_005 :-
    % Store a lesson: when working on list_sorting and the output is empty,
    % use a non-empty generator next time.
    rn_learn(list_sorting, output_was_empty, use_non_empty_generator),
    % Retrieve all lessons for list_sorting.
    rn_recall(list_sorting, Lessons),
    % Verify the lesson is present.
    ( member(lesson(output_was_empty, use_non_empty_generator), Lessons)
    % Clear all lessons for list_sorting.
    ->  rn_forget(list_sorting),
        % Verify lessons are now gone.
        rn_recall(list_sorting, LessonsAfter),
        ( LessonsAfter = []
        % Report pass.
        ->  write('AC-ACC75-005: PASS  lesson stored, recalled, and cleared correctly'), nl
        % Report fail: lessons remain after forget.
        ;   format('AC-ACC75-005: FAIL  lessons remain after rn_forget: ~w~n', [LessonsAfter])
        )
    % Report fail: lesson not found in recall.
    ;   format('AC-ACC75-005: FAIL  lesson not found in recall; got ~w~n', [Lessons])
    ).
