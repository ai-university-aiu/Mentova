/*  Mentova — arc_ft09 (ft09 "Functional Tiles" solver) Test Suite

    Behavioural PLUnit suite for the ft09 game solver at
    src/mentova/arc_ft09.pl. The solver is a pure, stateless reader of a
    live ARC frame (a list-of-rows colour grid): given a frame it names the
    single next click that fixes the first tile violating one of its local
    3x3 relational clue constraints, and it fails once every constrained tile
    already satisfies its clues. No lattice, nexus, server, or game data file
    is needed, so every check below drives real inputs to real outputs.

    The two exercised frames are hand-built 5x11 boards holding one CLUE cell
    (columns 0..4) and one solid TILE cell (columns 6..10), separated by a
    one-pixel background gutter (colour 4). The clue's sampled 3x3 pattern is
    [[1,1,1],[1,1,0],[1,1,1]]: its centre colour (nRq) is 1, and its right
    border pixel is 0 (dark), which imposes "the tile to my right must EQUAL
    1" on the tile cell.

      - In the violating frame the tile is colour 3, so it breaks the eq(1)
        constraint; colour 1 is in the palette, so the fix is reachable and
        the solver clicks the tile centre — pixel (Col=8, Row=2).
      - In the satisfied frame the tile is already colour 1, so no constraint
        is violated and the solver produces no action.

    Run with the full library path (every PrologAI pack plus the Mentova
    source):
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" test/test_arc_ft09.pl
*/

% Declare this file as a test module with no exports.
:- module(test_arc_ft09, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(arc_ft09)).

% ft09_violating_frame(-Frame): a 5x11 board whose single solid tile (colour
% 3, columns 6..10) breaks the clue's eq(1) constraint and is fixable.
ft09_violating_frame(
    % Row 0: clue colour 1, gutter 4, tile colour 3.
    [[1,1,1,1,1,4,3,3,3,3,3],
     % Row 1: same layout.
     [1,1,1,1,1,4,3,3,3,3,3],
     % Row 2: the 0 at column 4 is the clue's right-border DARK pixel.
     [1,1,1,1,0,4,3,3,3,3,3],
     % Row 3: same layout.
     [1,1,1,1,1,4,3,3,3,3,3],
     % Row 4: same layout.
     [1,1,1,1,1,4,3,3,3,3,3]]).

% ft09_satisfied_frame(-Frame): the same board but the tile is already colour
% 1, so it satisfies the clue's eq(1) constraint and needs no click.
ft09_satisfied_frame(
    % Row 0: clue colour 1, gutter 4, tile already colour 1.
    [[1,1,1,1,1,4,1,1,1,1,1],
     % Row 1: same layout.
     [1,1,1,1,1,4,1,1,1,1,1],
     % Row 2: the 0 at column 4 is the clue's right-border DARK pixel.
     [1,1,1,1,0,4,1,1,1,1,1],
     % Row 3: same layout.
     [1,1,1,1,1,4,1,1,1,1,1],
     % Row 4: same layout.
     [1,1,1,1,1,4,1,1,1,1,1]]).

% Open the test block for arc_ft09.
:- begin_tests(arc_ft09).

% AC-FT09-001: a hyphen-suffixed ft09 id is recognised as the ft09 game.
test(is_game_accepts_ft09_prefix) :-
    % The live ids carry a hyphenated suffix after the "ft09" prefix.
    assertion(ft09_is_game('ft09-locksmith-a1')).

% AC-FT09-002: the bare four-character atom "ft09" is recognised.
test(is_game_accepts_bare_ft09) :-
    % The prefix check accepts the exact four-character name.
    assertion(ft09_is_game(ft09)).

% AC-FT09-003: an id for a different game is rejected.
test(is_game_rejects_other_game) :-
    % A non-ft09 prefix must not match.
    assertion(\+ ft09_is_game('vc33-demo')).

% AC-FT09-004: a non-atom argument is rejected (the atom/1 guard).
test(is_game_rejects_non_atom) :-
    % An integer is not an atom, so the guard fails.
    assertion(\+ ft09_is_game(42)).

% AC-FT09-005: reset is a stateless no-op that always succeeds.
test(reset_succeeds) :-
    % The solver keeps no per-game state, so reset simply succeeds.
    assertion(ft09_reset('ft09-locksmith-a1')).

% AC-FT09-006: a tile violating its eq(1) clue is clicked at its centre.
test(next_action_clicks_violating_tile) :-
    % The board whose tile (colour 3) breaks the clue's eq(1) rule.
    ft09_violating_frame(Frame),
    % Ask the solver for the single next click.
    ft09_next_action('ft09-locksmith-a1', Frame, Action),
    % The click lands on the tile cell's centre pixel: column 8, row 2.
    assertion(Action == select(8, 2)).

% AC-FT09-007: the chosen action is deterministic (exactly one solution).
test(next_action_is_deterministic) :-
    % The same violating board.
    ft09_violating_frame(Frame),
    % Collect every action the solver could return.
    findall(A, ft09_next_action('ft09-locksmith-a1', Frame, A), Actions),
    % There is exactly one, and it is the tile-centre click.
    assertion(Actions == [select(8, 2)]).

% AC-FT09-008: when every constrained tile already satisfies its clue, the
% solver offers no action (the level is solved / auto-completing).
test(next_action_none_when_satisfied) :-
    % The board whose tile is already colour 1 (satisfies eq(1)).
    ft09_satisfied_frame(Frame),
    % With nothing to fix, the solver fails rather than clicking.
    assertion(\+ ft09_next_action('ft09-locksmith-a1', Frame, _)).

% AC-FT09-009: an empty frame yields no action (no cells to act on).
test(next_action_none_on_empty_frame) :-
    % A frame with no cells cannot produce a click.
    assertion(\+ ft09_next_action('ft09-locksmith-a1', [], _)).

% Close the test block for arc_ft09.
:- end_tests(arc_ft09).
