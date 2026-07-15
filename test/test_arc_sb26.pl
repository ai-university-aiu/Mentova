/*  Mentova — arc_sb26 sb26 Solver Test Suite

    Genuine PLUnit coverage for src/mentova/arc_sb26.pl, the game-specific
    solver for the sb26 environment (Phase Solo). The module exports three
    predicates:
      sb26_is_game/1     -- recognises an sb26 game id (bare or hash-suffixed);
      sb26_next_action/3 -- the next action of the win procedure for a frame;
      sb26_reset/1       -- clears the queued plan for a fresh attempt.

    The sb26 mechanic: the TOP band's box-border row spells the target colour
    sequence, the BOTTOM band is the palette (one tile per colour), and the
    CENTRE band's red runs are the placeholder markers. The solver parses the
    frame and queues, per marker in order, a palette select of the matching
    target colour then a click on the marker, and finally the ACTION5 commit.

    These tests drive a hand-built 63-row frame whose bands are:
      target row 5  -> border runs of colours 6, 7, 8;
      marker row 30 -> three red runs centred at columns 2, 6, 10;
      palette row 60-> tiles for 6, 7, 8 centred at columns 3, 8, 13.
    The expected plan, worked out by hand from the module's documented
    behaviour, is:
      [select(3,60), select(2,30), select(8,60), select(6,30),
       select(13,60), select(10,30), action(5)].

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_arc_sb26.pl
*/

% Declare this file as a test module with no exports.
:- module(test_arc_sb26, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(arc_sb26)).
% Load list helpers for numlist.
:- use_module(library(lists)).
% Load maplist for building the fixture frame.
:- use_module(library(apply)).

% ---------------------------------------------------------------------------
% FIXTURE — a hand-built, solvable sb26 board
% ---------------------------------------------------------------------------

% sb26_bg_row(-Row): a 20-cell all-background row (colour 4 is the sb26 background).
sb26_bg_row([4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4]).

% sb26_target_row(-Row): a top-band border row whose three runs of length 4 spell colours 6, 7, 8.
sb26_target_row([4,4,6,6,6,6,4,4,7,7,7,7,4,4,8,8,8,8,4,4]).

% sb26_marker_row(-Row): a centre-band row with three red(2) runs centred at columns 2, 6, 10.
sb26_marker_row([4,4,2,2,4,4,2,2,4,4,2,2,4,4,4,4,4,4,4,4]).

% sb26_palette_row(-Row): a bottom-band row with runs of length 3 for colours 6, 7, 8 centred at columns 3, 8, 13.
sb26_palette_row([4,4,6,6,6,4,4,7,7,7,4,4,8,8,8,4,4,4,4,4]).

% sb26_pick_row(+Bg,+Target,+Marker,+Palette,+Index,-Row): choose the right row for each band index.
% Row index 5 is the top target-border row.
sb26_pick_row(_Bg, Target, _Marker, _Palette, 5, Target) :- !.
% Row index 30 is the centre placeholder-marker row.
sb26_pick_row(_Bg, _Target, Marker, _Palette, 30, Marker) :- !.
% Row index 60 is the bottom palette row.
sb26_pick_row(_Bg, _Target, _Marker, Palette, 60, Palette) :- !.
% Every other row is plain background.
sb26_pick_row(Bg, _Target, _Marker, _Palette, _Index, Bg).

% sb26_test_frame(-Frame): the full 63-row solvable board assembled from the band rows.
sb26_test_frame(Frame) :-
    % The all-background filler row.
    sb26_bg_row(Bg),
    % The top border row that spells target colours 6, 7, 8.
    sb26_target_row(Target),
    % The centre row carrying the three red placeholder markers.
    sb26_marker_row(Marker),
    % The bottom palette row offering tiles for 6, 7, 8.
    sb26_palette_row(Palette),
    % The 63 row indices 0..62.
    numlist(0, 62, Indices),
    % Assemble the frame, placing each special row at its band index.
    maplist(sb26_pick_row(Bg, Target, Marker, Palette), Indices, Frame).

% sb26_empty_frame(-Frame): a 63-row all-background board with no parseable bands.
sb26_empty_frame(Frame) :-
    % The all-background filler row.
    sb26_bg_row(Bg),
    % Sixty-three rows make up the frame.
    length(Frame, 63),
    % Every row is the plain background row.
    maplist(=(Bg), Frame).

% ---------------------------------------------------------------------------
% TESTS
% ---------------------------------------------------------------------------

% Open the test block for the arc_sb26 module.
:- begin_tests(arc_sb26).

% AC-SB26-001: sb26_is_game accepts a bare and a hash-suffixed sb26 id and rejects others.
test(is_game_recognises_sb26_ids) :-
    % The bare environment id is recognised.
    assertion(sb26_is_game(sb26)),
    % A hash-suffixed id is recognised because its first four characters are sb26.
    assertion(sb26_is_game('sb26_deadbeef')),
    % An unrelated game id is not recognised.
    assertion(\+ sb26_is_game(other_game)),
    % A non-atom (a number) is not recognised.
    assertion(\+ sb26_is_game(123)).

% AC-SB26-002: on a fresh plan the first action selects the palette tile for the first target colour.
test(first_action_selects_first_palette_tile) :-
    % Clear any queued plan so the board is re-parsed.
    sb26_reset(sb26),
    % Build the solvable board.
    sb26_test_frame(Frame),
    % Ask for the first action of the win procedure.
    sb26_next_action(sb26, Frame, Action),
    % Target colour 6's palette tile sits at column 3 of palette row 60.
    assertion(Action == select(3, 60)).

% AC-SB26-003: the full procedure is a select+click pair per marker, then the ACTION5 commit.
test(full_procedure_matches_hand_trace) :-
    % Clear any queued plan for a clean parse.
    sb26_reset(sb26),
    % Build the solvable board.
    sb26_test_frame(Frame),
    % First: select the palette tile for target colour 6.
    sb26_next_action(sb26, Frame, A1),
    % Second: click the first red marker.
    sb26_next_action(sb26, Frame, A2),
    % Third: select the palette tile for target colour 7.
    sb26_next_action(sb26, Frame, A3),
    % Fourth: click the second red marker.
    sb26_next_action(sb26, Frame, A4),
    % Fifth: select the palette tile for target colour 8.
    sb26_next_action(sb26, Frame, A5),
    % Sixth: click the third red marker.
    sb26_next_action(sb26, Frame, A6),
    % Seventh: press ACTION5 to commit the level.
    sb26_next_action(sb26, Frame, A7),
    % Collect the seven actions in order.
    Actions = [A1, A2, A3, A4, A5, A6, A7],
    % Each select+click pair fills one marker with its target colour, then ACTION5 commits.
    assertion(Actions == [select(3, 60), select(2, 30),
                          select(8, 60), select(6, 30),
                          select(13, 60), select(10, 30),
                          action(5)]).

% AC-SB26-004: sb26_reset discards the queued plan so the next call re-parses from the top.
test(reset_restarts_the_plan) :-
    % Clear any queued plan.
    sb26_reset(sb26),
    % Build the solvable board.
    sb26_test_frame(Frame),
    % Take the first action, queuing the remaining six.
    sb26_next_action(sb26, Frame, First),
    % Advance one more step into the queued plan.
    sb26_next_action(sb26, Frame, _Second),
    % Reset clears the remaining queue.
    sb26_reset(sb26),
    % The next call re-parses the board and starts the plan over.
    sb26_next_action(sb26, Frame, Again),
    % The restarted plan opens with the documented first action.
    assertion(First == select(3, 60)),
    % And the post-reset action equals that same opening action.
    assertion(Again == First).

% AC-SB26-005: a board with no target/marker/palette bands cannot be parsed, so no action is produced.
test(unparseable_frame_yields_no_action, [fail]) :-
    % Clear any queued plan for this id.
    sb26_reset(sb26_blank),
    % Build an all-background board with no parseable bands.
    sb26_empty_frame(Frame),
    % No plan can be built, so the call fails rather than inventing an action.
    sb26_next_action(sb26_blank, Frame, _Action).

% Close the test block for the arc_sb26 module.
:- end_tests(arc_sb26).
