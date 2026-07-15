%% Declare this file as a test-only module that exports nothing.
:- module(test_arc_golden, []).

%% Load the PLUnit test framework.
:- use_module(library(plunit)).
%% Load the module under test — the Golden Game Environment Reference loader.
:- use_module(library(arc_golden)).
%% Load list helpers used by the assertions.
:- use_module(library(lists)).
%% Load the file reader used by the independent line-count oracle.
:- use_module(library(readutil), [read_file_to_string/3]).

%% present_game(-Game): a real ARC-AGI-3 game whose golden reference file is on disk.
present_game(ls20).

%% nonempty_trimmed_atom(+X): X is an atom whose string form is non-empty and already trimmed.
nonempty_trimmed_atom(X) :-
    %% It must be an atom, since the loader turns each kept line into an atom.
    atom(X),
    %% View it as a string for the trim comparison.
    atom_string(X, S),
    %% Trim the same padding the loader trims: space, tab, and carriage return.
    split_string(S, "", "\s\t\r", [Trimmed]),
    %% The value is already trimmed, so trimming changes nothing.
    Trimmed == S,
    %% And it is not the empty string, because the loader drops blank lines.
    S \== "".

%% Open the arc_golden test suite.
:- begin_tests(arc_golden).

%% agp_golden_file/2 builds the exact <dir>/<game>.txt path for a real game.
test(golden_file_exact_path) :-
    %% Take a real game that has a golden file on disk.
    present_game(Game),
    %% Ask the loader for that game's golden reference file path.
    agp_golden_file(Game, Path),
    %% The path is exactly the golden directory, a slash, the game name, and the .txt suffix.
    assertion(Path == '/home/ccaitwo/ARC-AGI-3/ls20.txt').

%% agp_golden_file/2 is pure path construction — it succeeds for any atom, present on disk or not.
test(golden_file_pure_construction) :-
    %% Use a game identifier for which no golden file exists.
    agp_golden_file(zz99_not_a_game, Path),
    %% The path is still assembled by concatenation, independent of the file existing.
    assertion(Path == '/home/ccaitwo/ARC-AGI-3/zz99_not_a_game.txt').

%% agp_golden_lines/2 returns the file's non-empty lines, trimmed and in order.
test(golden_lines_nonempty_and_filtered) :-
    %% Take the present game.
    present_game(Game),
    %% Read the golden lines through the loader.
    agp_golden_lines(Game, Lines),
    %% At least one line comes back.
    assertion(Lines \== []),
    %% Every returned line is a non-empty, already-trimmed atom.
    assertion(forall(member(L, Lines), nonempty_trimmed_atom(L))),
    %% Independently read the raw file to count its physical newline-split lines.
    agp_golden_file(Game, Path),
    %% Slurp the whole file as a string.
    read_file_to_string(Path, Str, []),
    %% Split the raw text on newlines with no trimming, to include blank lines.
    split_string(Str, "\n", "", Raw),
    %% Count the raw physical lines.
    length(Raw, RawCount),
    %% Count the lines the loader kept.
    length(Lines, KeptCount),
    %% The loader dropped the blank lines, so it kept strictly fewer than the raw split.
    assertion(KeptCount < RawCount),
    %% And it kept a non-empty body of guidance text.
    assertion(KeptCount > 0).

%% agp_golden_lines/2 fails for a game with no golden file, since it guards on the file existing.
test(golden_lines_missing_fails) :-
    %% Reading lines for a game that has no file on disk must fail rather than throw.
    assertion(\+ agp_golden_lines(no_such_game_qq, _)).

%% agp_load_golden/1 is fail-safe: it succeeds for a present game and a missing one alike.
test(load_golden_one_is_failsafe) :-
    %% Loading a present game's golden reference succeeds.
    present_game(Game),
    %% The one-argument loader succeeds for the real game.
    assertion(agp_load_golden(Game)),
    %% And it still succeeds for a game with no file — the loader is guarded end to end.
    assertion(agp_load_golden(no_such_game_qq)).

%% agp_load_golden/2 returns a non-negative held-line count, and exactly zero for a missing game.
test(load_golden_two_count) :-
    %% A present game yields an integer count of zero or more concepts held.
    present_game(Game),
    %% Load it and read back the count.
    agp_load_golden(Game, Count),
    %% The count is an integer.
    assertion(integer(Count)),
    %% The count is never negative.
    assertion(Count >= 0),
    %% A game with no file holds nothing, so its count is exactly zero.
    agp_load_golden(no_such_game_qq, Zero),
    %% Confirm the missing-game count is zero.
    assertion(Zero == 0).

%% Close the arc_golden test suite.
:- end_tests(arc_golden).
