/*  Mentova — sb26 game-specific solver (Phase B capability)

    The sb26 mechanic was cracked over the Mentor Bridge and level 1 was won live: the
    TOP row of bordered boxes spells the TARGET sequence (border colours, left->right),
    the BOTTOM row is the PALETTE (click a tile to select its colour), and the CENTRE
    framed red markers are the PLACEHOLDERS. The play is: for each placeholder in order,
    select the palette tile of the matching target colour, click the placeholder, then
    press ACTION5 to commit. This module encodes that procedure so the SOLO player can
    win sb26 level 1 itself (Phase B), executing it one action per choice.

    Action terms match the live client: an ACTION6 cell-click is select(Col,Row); the
    commit ACTION5 is action(5).

    Predicates:
      sb26_is_game/1        -- +GameId          (id names the sb26 environment)
      sb26_next_action/3    -- +Game, +Frame, -Action   (next action in the procedure)
      sb26_reset/1          -- +Game            (clear the plan for a fresh attempt)
*/

:- module(arc_sb26, [
    sb26_is_game/1,
    sb26_next_action/3,
    sb26_reset/1
]).

:- use_module(library(lists)).

% sb26_plan_/2: (Game, [Action|...]) — the queued actions for the current level.
:- dynamic sb26_plan_/2.

% sb26_is_game(+GameId): the id names the sb26 environment (bare or hash-suffixed).
sb26_is_game(GameId) :-
    atom(GameId), sub_atom(GameId, 0, 4, _, sb26).

% sb26_reset(+Game): clear any queued plan so the next attempt re-parses the board.
sb26_reset(Game) :- retractall(sb26_plan_(Game, _)).

% sb26_next_action(+Game, +Frame, -Action): the next action of the sb26 procedure.
% Pops the queued plan; when the queue is empty it re-parses the current board and
% builds the plan for this level (fill every placeholder to match the target, then
% commit). Fails if the board cannot be parsed (caller falls through).
sb26_next_action(Game, Frame, Action) :-
    ( sb26_plan_(Game, [A | Rest]), A \== []
    ->  Action = A,
        retractall(sb26_plan_(Game, _)),
        assertz(sb26_plan_(Game, Rest))
    ;   sb26_build_plan(Game, Frame, [A | Rest]),
        Action = A,
        retractall(sb26_plan_(Game, _)),
        assertz(sb26_plan_(Game, Rest))
    ).

% sb26_build_plan(+Game, +Frame, -Plan): parse target/palette/markers and produce the
% full action list for this level — a select+click pair per placeholder, then action(5).
sb26_build_plan(_Game, Frame, Plan) :-
    sb26_target(Frame, Target),
    Target \== [],
    sb26_palette(Frame, Pal),
    sb26_markers(Frame, Markers),
    Markers \== [],
    sb26_fill_actions(Markers, Target, Pal, Fill),
    Fill \== [],
    append(Fill, [action(5)], Plan).

% sb26_fill_actions(+Markers, +Target, +Pal, -Actions): for each marker i, a palette
% select of Target[i]'s tile then a click on the marker. Stops at the shorter of the
% two lists; a target colour with no palette tile is skipped safely.
sb26_fill_actions([], _, _, []).
sb26_fill_actions([_|_], [], _, []) :- !.
sb26_fill_actions([mk(MX, MY) | Ms], [T | Ts], Pal, Actions) :-
    (   member(pt(T, PX, PY), Pal)
    ->  Actions = [select(PX, PY), select(MX, MY) | Rest]
    ;   Actions = Rest ),
    sb26_fill_actions(Ms, Ts, Pal, Rest).

% ---------------------------------------------------------------------------
% BOARD PARSING
% ---------------------------------------------------------------------------

% sb26_target(+Frame, -Colours): the top box border row's colours, left->right. The
% border row is the row in the top band with the most colour runs of length >= 4
% (ignoring background 4 and box-interior grey 5).
sb26_target(Frame, Colours) :-
    sb26_best_row(Frame, 0, 15, [4,5], 4, _R, Runs),
    findall(C, member(run(C, _, _), Runs), Colours).

% sb26_palette(+Frame, -Pal): the bottom palette row as pt(Colour, X, Y) click points.
% The palette row is the row in the bottom band with the most runs of length >= 3
% (ignoring only background 4).
sb26_palette(Frame, Pal) :-
    sb26_best_row(Frame, 50, 62, [4], 3, R, Runs),
    findall(pt(C, X, R),
        ( member(run(C, C0, C1), Runs), X is (C0 + C1) // 2 ),
        Pal0),
    sb26_dedup_pal(Pal0, Pal).

% sb26_dedup_pal: keep the first click point per colour.
sb26_dedup_pal([], []).
sb26_dedup_pal([pt(C, X, Y) | T], [pt(C, X, Y) | R]) :-
    exclude([pt(C2,_,_)]>>(C2 == C), T, T2),
    sb26_dedup_pal(T2, R).

% sb26_markers(+Frame, -Markers): the centre placeholder markers as mk(X, Y), left->
% right, from the centre-band row with the most red(2) runs.
sb26_markers(Frame, Markers) :-
    sb26_best_red_row(Frame, 18, 49, R, Runs),
    findall(mk(X, R),
        ( member(run(2, C0, C1), Runs), X is (C0 + C1) // 2 ),
        Markers).

% sb26_best_row(+Frame, +R0, +R1, +Bg, +MinLen, -Row, -Runs): among rows R0..R1, the
% row whose runs (colour not in Bg, length >= MinLen) are most numerous, and its runs.
sb26_best_row(Frame, R0, R1, Bg, MinLen, Row, Runs) :-
    findall(N-r(R, Rs),
        ( between(R0, R1, R), sb26_row(Frame, R, RowCells),
          sb26_row_runs(RowCells, Bg, All),
          include([run(_,A,B)]>>(B - A + 1 >= MinLen), All, Rs),
          length(Rs, N) ),
        Scored),
    Scored \== [],
    sort(1, @>=, Scored, [_-r(Row, Runs) | _]).

% sb26_best_red_row(+Frame, +R0, +R1, -Row, -Runs): the row with the most red(2) runs.
sb26_best_red_row(Frame, R0, R1, Row, Runs) :-
    findall(N-r(R, Rs),
        ( between(R0, R1, R), sb26_row(Frame, R, RowCells),
          sb26_row_runs(RowCells, [0,1,3,4,5,6,7,8,9,10,11,12,13,14,15], Rs),
          length(Rs, N) ),
        Scored),
    Scored \== [],
    sort(1, @>=, Scored, [_-r(Row, Runs) | _]),
    Runs \== [].

% sb26_row(+Frame, +R, -Row): the R-th row of the frame as a list of cell colours.
sb26_row(Frame, R, Row) :- nth0(R, Frame, Row).

% sb26_row_runs(+Row, +Bg, -Runs): maximal runs run(Colour, Start, End) for colours not
% in Bg.
sb26_row_runs(Row, Bg, Runs) :- sb26_rr(Row, 0, Bg, Runs).

sb26_rr([], _, _, []).
sb26_rr([C | T], I, Bg, Runs) :-
    ( memberchk(C, Bg)
    ->  I1 is I + 1, sb26_rr(T, I1, Bg, Runs)
    ;   sb26_span([C | T], C, I, End, Rest),
        Runs = [run(C, I, End) | More],
        End1 is End + 1,
        sb26_rr(Rest, End1, Bg, More) ).

% sb26_span(+Tail, +Colour, +StartIdx, -EndIdx, -Rest): consume leading cells == Colour.
sb26_span([C | T], C, I, End, Rest) :- !, I1 is I + 1, sb26_span(T, C, I1, End, Rest).
sb26_span(Rest, _, I, End, Rest) :- End is I - 1.

:- use_module(library(yall)).
:- use_module(library(apply)).
