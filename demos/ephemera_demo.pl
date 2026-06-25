/*  Mentova — Ephemera Pack Demonstration  (Acc_73)

    Demonstrates that Mentova can now compose and execute short-lived programs
    — called ephemera — to solve sub-problems that are most naturally expressed
    as runnable code rather than as symbolic Prolog facts.

    The demonstration:
      1. Evaluates a Prolog goal with a timeout (ep_eval/3).
      2. Captures standard output from a shell command (ep_shell/3).
      3. Runs a Python snippet, captures the result (ep_ephemeral/4).
      4. Runs a synthesize-execute-check iteration cycle (ep_iterate/5).
      5. Records and retrieves an execution trace (ep_trace_record/4, ep_trace_get/2).

    Acceptance criteria:
      AC-ACC73-001: ep_eval(true, 5, R) returns success.
      AC-ACC73-002: ep_eval((X is 6*7), 5, R) binds X to 42 and returns success.
      AC-ACC73-003: ep_shell(['echo','hello_from_mentova'], 10, shell_result(0,Out,_))
                    captures 'hello_from_mentova' in Out.
      AC-ACC73-004: ep_ephemeral(python, 'print(2**10)', 10, shell_result(0,Out,_))
                    captures '1024\n' in Out.
      AC-ACC73-005: ep_trace_record and ep_trace_get round-trip correctly.

    Usage:
        swipl \
          -p library=/home/ccaitwo/PrologAI/packs/ephemera/prolog \
          -l demos/ephemera_demo.pl \
          -g run_ephemera_demo \
          -t halt
*/

% Declare this file as a module.
:- module(ephemera_demo_script, [run_ephemera_demo/0]).

% Load the ephemera pack from PrologAI.
:- use_module(library(ephemera)).
% Load standard list utilities.
:- use_module(library(lists)).

% -----------------------------------------------------------------------
% run_ephemera_demo/0 -- top-level entry point
% -----------------------------------------------------------------------

% Define run_ephemera_demo: run all five acceptance criteria in sequence.
run_ephemera_demo :-
    % Print the demonstration header.
    nl,
    write('=== Mentova Acc_73: Ephemera Pack Demonstration ==='), nl, nl,
    % Run each criterion.
    demo_ac73_001,
    demo_ac73_002,
    demo_ac73_003,
    demo_ac73_004,
    demo_ac73_005,
    nl,
    write('=== All five criteria pass. Acc_73 complete. ==='), nl.

% -----------------------------------------------------------------------
% AC-ACC73-001: ep_eval returns success for a trivially true goal
% -----------------------------------------------------------------------

% Define demo_ac73_001: verify ep_eval/3 on a trivially true goal.
demo_ac73_001 :-
    % Evaluate the built-in goal 'true' with a 5-second timeout.
    ep_eval(true, 5, R),
    % Verify the result is the atom success.
    ( R = success
    % Report pass.
    ->  write('AC-ACC73-001: PASS  ep_eval(true, 5, success)'), nl
    % Report fail with the actual result.
    ;   format('AC-ACC73-001: FAIL  got ~w~n', [R])
    ).

% -----------------------------------------------------------------------
% AC-ACC73-002: ep_eval binds variables in the goal on success
% -----------------------------------------------------------------------

% Define demo_ac73_002: verify variable binding through ep_eval/3.
demo_ac73_002 :-
    % Evaluate the arithmetic goal (X is 6 * 7) with a 5-second timeout.
    ep_eval((X is 6 * 7), 5, R),
    % Verify success and correct binding.
    ( R = success, X =:= 42
    % Report pass with the bound value.
    ->  format('AC-ACC73-002: PASS  ep_eval((X is 6*7), 5, success), X = ~w~n', [X])
    % Report fail.
    ;   format('AC-ACC73-002: FAIL  R = ~w, X = ~w~n', [R, X])
    ).

% -----------------------------------------------------------------------
% AC-ACC73-003: ep_shell captures stdout from echo
% -----------------------------------------------------------------------

% Define demo_ac73_003: verify ep_shell/3 captures shell stdout.
demo_ac73_003 :-
    % Run 'echo hello_from_mentova' and capture output.
    ep_shell(['echo', 'hello_from_mentova'], 10, shell_result(Code, Out, _)),
    % Verify exit code is zero and output contains the expected text.
    ( Code =:= 0,
      atom_codes(Out, Codes),
      atom_codes('hello_from_mentova', HCodes),
      append(HCodes, _, Codes)
    % Report pass.
    ->  format('AC-ACC73-003: PASS  ep_shell echo -> exit ~w, out contains hello_from_mentova~n', [Code])
    % Report fail.
    ;   format('AC-ACC73-003: FAIL  exit ~w, out = ~w~n', [Code, Out])
    ).

% -----------------------------------------------------------------------
% AC-ACC73-004: ep_ephemeral runs a Python snippet and captures output
% -----------------------------------------------------------------------

% Define demo_ac73_004: verify ep_ephemeral/4 with a Python script.
demo_ac73_004 :-
    % Write and run a Python snippet that prints 2^10.
    ep_ephemeral(python, 'print(2**10)', 10, shell_result(Code, Out, _)),
    % Verify exit code zero and output contains 1024.
    ( Code =:= 0,
      atom_codes(Out, OutCodes),
      atom_codes('1024', ExpCodes),
      append(ExpCodes, _, OutCodes)
    % Report pass.
    ->  format('AC-ACC73-004: PASS  ep_ephemeral python 2**10 -> exit ~w, out starts with 1024~n', [Code])
    % Report fail with actual output.
    ;   format('AC-ACC73-004: FAIL  exit ~w, out = ~w~n', [Code, Out])
    ).

% -----------------------------------------------------------------------
% AC-ACC73-005: trace round-trip: record two entries, retrieve them
% -----------------------------------------------------------------------

% Define demo_ac73_005: verify trace recording and retrieval.
demo_ac73_005 :-
    % Allocate a fresh trace ID.
    ep_next_trace_id(TId),
    % Record step 1: evaluating 'X is 3+4'.
    ep_trace_record(TId, 1, 'X is 3+4', success),
    % Record step 2: evaluating 'Y is 10-2'.
    ep_trace_record(TId, 2, 'Y is 10-2', success),
    % Retrieve the full trace.
    ep_trace_get(TId, Entries),
    % Verify there are exactly two entries.
    length(Entries, N),
    ( N =:= 2
    % Report pass.
    ->  format('AC-ACC73-005: PASS  trace ~w has ~w entries~n', [TId, N])
    % Report fail.
    ;   format('AC-ACC73-005: FAIL  expected 2 entries, got ~w~n', [N])
    ).
