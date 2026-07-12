/*  Mentova — ft09 game-specific solver (Phase Solo, levels 1-2)

    ft09 is a click-only "Functional Tiles" / Lights-Out puzzle. Its mechanic was
    cracked over the Mentor Bridge: the board holds one or more 3x3-ish grids of 6x6
    colour cells; each grid has a fixed CLUE cell (a 3x3 mini-pattern of colours
    0/2/<fill>). A clue governs the 3x3 block of cells centred on it: each cell must be
    the FILL colour where the clue's corresponding sub-cell is 0, else the BLANK colour.
    Clicking a cell toggles it between blank and fill. The level auto-completes when the
    working grid matches its clue (there is no verify button).

    This module encodes that projection rule so the SOLO player wins ft09 levels 1 and 2
    itself. The FILL colour is read from the clue's centre sub-cell (8 or 12), so no live
    probe is needed. Levels 3+ use an overlapping-clue rule not yet decoded; on those the
    projection may not complete the level and the solver simply produces its best clicks.

    Action terms match the live client: an ACTION6 cell-click is select(Col, Row).

    STATUS: WORK IN PROGRESS — NOT yet wired into ma_choose. Cell detection and grid
    clustering now match the reference Python solver ft09_solver.py (which wins ft09
    levels 1-2): on L1 it finds the 4x4 working-grid lattice correctly. The remaining gap
    is in the CLUE PROJECTION detail — this module's ft09_target takes the first governing
    clue, while the working Python solver's projection over the 4x4 two-clue layout differs,
    so the plan lands ~3 clicks instead of the exact winning set. A final debugging pass to
    reconcile ft09_target with the Python solver's per-cell projection (and confirm live
    that Solo wins L1+L2) is what remains. Until then this module is intentionally NOT
    loaded/wired, so it cannot cause the solo player to misclick. Proven reference solver:
    /home/ccaitwo/claude_work_summaries/ARC-AGI-3_Observations/ft09_solver.py.

    Predicates:
      ft09_is_game/1      -- +GameId
      ft09_next_action/3  -- +Game, +Frame, -Action
      ft09_reset/1        -- +Game
*/

:- module(arc_ft09, [
    ft09_is_game/1,
    ft09_next_action/3,
    ft09_reset/1
]).

:- use_module(library(lists)).

% ft09_plan_/2: (Game, [Action|...]) queued clicks for the current level.
:- dynamic ft09_plan_/2.

ft09_is_game(GameId) :- atom(GameId), sub_atom(GameId, 0, 4, _, ft09).

ft09_reset(Game) :- retractall(ft09_plan_(Game, _)).

% ft09_next_action(+Game, +Frame, -Action): pop the queued plan; when empty, rebuild it
% from the current frame (the next level). Fails when no click is needed (level solved).
ft09_next_action(Game, Frame, Action) :-
    ( ft09_plan_(Game, [A | Rest])
    ->  Action = A, retractall(ft09_plan_(Game, _)), assertz(ft09_plan_(Game, Rest))
    ;   ft09_build_plan(Frame, [A | Rest]),
        Action = A, retractall(ft09_plan_(Game, _)), assertz(ft09_plan_(Game, Rest))
    ).

% ---------------------------------------------------------------------------
% PLAN
% ---------------------------------------------------------------------------

% ft09_build_plan(+Frame, -Clicks): detect the grids, pick the working one, and produce
% one select(Col,Row) click per cell whose colour must change to match the projection.
ft09_build_plan(Frame, Clicks) :-
    ft09_cells(Frame, Cells),
    Cells \== [],
    ft09_groups(Cells, Groups),
    member(Group, Groups),
    ft09_group_plan(Frame, Group, Clicks),
    Clicks \== [],
    !.

% ft09_group_plan(+Frame, +Group, -Clicks): for one grid, classify its cells, project the
% clue(s), and list the clicks needed. Fails (caller tries the next group) if the grid has
% no clue or is already solved.
ft09_group_plan(Frame, Group, Clicks) :-
    ft09_lattice(Group, Ys, Xs),
    findall(cinfo(RI, CI, CY, CX, Kind),
        ( nth0(RI, Ys, CY), nth0(CI, Xs, CX),
          ft09_cell_box(Group, CY, CX, Box),
          ft09_classify(Frame, Box, Kind) ),
        Cs),
    % clue cells and their patterns.
    findall(clue(RI, CI, Pat), member(cinfo(RI, CI, _, _, clue(Pat)), Cs), Clues),
    Clues \== [],
    % fill colour = the (non 0/2) colour in a clue's centre sub-cell.
    ft09_fill_colour(Clues, Fill),
    % blank colour = the most common solid non-background cell colour.
    findall(V, ( member(cinfo(_, _, _, _, solid(V)), Cs), V =\= 4 ), Solids),
    Solids \== [],
    ft09_most_common(Solids, Blank),
    % the clicks: each active, non-clue cell whose colour differs from its target.
    findall(select(CX, CY),
        ( member(cinfo(RI, CI, CY, CX, solid(V)), Cs),
          V =\= 4,
          ft09_target(RI, CI, Clues, Fill, Blank, Target),
          V =\= Target ),
        Clicks).

% ft09_target(+RI, +CI, +Clues, +Fill, +Blank, -Target): the projection target for a cell
% — Fill where a governing clue's sub-cell is 0, else Blank. (Single-clue levels; the
% first governing clue decides, which is correct for levels 1-2.)
ft09_target(RI, CI, Clues, Fill, Blank, Target) :-
    ( member(clue(GR, GC, Pat), Clues),
      DR is RI - GR, DC is CI - GC,
      DR >= -1, DR =< 1, DC >= -1, DC =< 1,
      PR is DR + 1, PC is DC + 1,
      nth0(PR, Pat, Row), nth0(PC, Row, Sub)
    ->  ( Sub =:= 0 -> Target = Fill ; Target = Blank )
    ;   Target = Blank ).

% ft09_fill_colour(+Clues, -Fill): the fill colour = a clue centre sub-cell value that is
% not 0 or 2 (i.e. 8 or 12).
ft09_fill_colour(Clues, Fill) :-
    member(clue(_, _, Pat), Clues),
    nth0(1, Pat, Mid), nth0(1, Mid, Fill),
    Fill =\= 0, Fill =\= 2, !.
ft09_fill_colour(_, 8).

% ---------------------------------------------------------------------------
% CELL DETECTION
% ---------------------------------------------------------------------------

ft09_isbg(4).
ft09_isbg(5).

ft09_at(Frame, R, C, V) :- nth0(R, Frame, Row), nth0(C, Row, V).

% ft09_cells(+Frame, -Cells): all 6x6-ish cell blocks as box(R0,C0,R1,C1). A cell's
% top-left has a background cell above and to the left (gutter), and the block is 4..8 wide
% and tall.
ft09_cells(Frame, Cells) :-
    findall(box(R, C, R1, C1),
        ( between(0, 57, R), between(0, 57, C),
          ft09_cell_here(Frame, R, C, R1, C1) ),
        Cells).

ft09_cell_here(Frame, R, C, R1, C1) :-
    ft09_at(Frame, R, C, V), \+ ft09_isbg(V),
    ( R =:= 0 -> true ; R0 is R - 1, ft09_at(Frame, R0, C, Va), ft09_isbg(Va) ),
    ( C =:= 0 -> true ; C0 is C - 1, ft09_at(Frame, R, C0, Vl), ft09_isbg(Vl) ),
    % real cells are ~6x6 colour blocks (matches the reference Python solver: 4..8).
    ft09_run_right(Frame, R, C, W), W >= 4, W =< 8,
    ft09_run_down(Frame, R, C, H), H >= 4, H =< 8,
    R1 is R + H - 1, C1 is C + W - 1.

ft09_run_right(Frame, R, C, W) :- ft09_rr(Frame, R, C, 0, W).
ft09_rr(Frame, R, C, Acc, W) :-
    ( ft09_at(Frame, R, C, V), \+ ft09_isbg(V)
    ->  C1 is C + 1, A1 is Acc + 1, ft09_rr(Frame, R, C1, A1, W)
    ;   W = Acc ).

ft09_run_down(Frame, R, C, H) :- ft09_rd(Frame, R, C, 0, H).
ft09_rd(Frame, R, C, Acc, H) :-
    ( ft09_at(Frame, R, C, V), \+ ft09_isbg(V)
    ->  R1 is R + 1, A1 is Acc + 1, ft09_rd(Frame, R1, C, A1, H)
    ;   H = Acc ).

% ft09_groups(+Cells, -Groups): cluster cells into grids by proximity (cell centres within
% 9 in both axes are the same grid).
ft09_groups(Cells, Groups) :-
    ft09_group_(Cells, [], Groups).
ft09_group_([], Acc, Acc).
ft09_group_([Cell | Rest], Acc0, Groups) :-
    ( select(G, Acc0, Acc1), ft09_near_group(Cell, G)
    ->  ft09_group_(Rest, [[Cell | G] | Acc1], Groups)
    ;   ft09_group_(Rest, [[Cell] | Acc0], Groups) ).

ft09_near_group(Cell, Group) :- member(Other, Group), ft09_near(Cell, Other).
ft09_near(box(R0,C0,R1,C1), box(S0,D0,S1,D1)) :-
    CY1 is (R0+R1)//2, CX1 is (C0+C1)//2, CY2 is (S0+S1)//2, CX2 is (D0+D1)//2,
    abs(CY1-CY2) =< 9, abs(CX1-CX2) =< 9.

% ft09_lattice(+Group, -Ys, -Xs): the sorted, de-duplicated cell-centre rows and cols.
ft09_lattice(Group, Ys, Xs) :-
    findall(CY, ( member(box(R0,_,R1,_), Group), CY is (R0+R1)//2 ), Ys0),
    findall(CX, ( member(box(_,C0,_,C1), Group), CX is (C0+C1)//2 ), Xs0),
    ft09_dedup(Ys0, Ys), ft09_dedup(Xs0, Xs).

ft09_dedup(L0, L) :- sort(L0, S), ft09_dd(S, L).
ft09_dd([], []).
ft09_dd([X], [X]) :- !.
ft09_dd([A, B | T], R) :- ( B - A =< 3 -> ft09_dd([A | T], R) ; R = [A | R1], ft09_dd([B | T], R1) ).

% ft09_cell_box(+Group, +CY, +CX, -Box): the group cell whose centre is nearest (CY,CX).
ft09_cell_box(Group, CY, CX, box(R0,C0,R1,C1)) :-
    findall(D - box(R0,C0,R1,C1),
        ( member(box(R0,C0,R1,C1), Group),
          MY is (R0+R1)//2, MX is (C0+C1)//2,
          D is abs(MY-CY) + abs(MX-CX) ),
        Ds),
    keysort(Ds, [_ - Box | _]),
    Box = box(R0,C0,R1,C1).

% ft09_classify(+Frame, +Box, -Kind): solid(Colour) if the cell is one colour, else
% clue(Pat) with Pat the 3x3 sub-pattern sampled at the cell's 2px sub-lattice.
ft09_classify(Frame, box(R0,C0,R1,C1), Kind) :-
    findall(V, ( between(R0, R1, R), between(C0, C1, C), ft09_at(Frame, R, C, V) ), Px),
    sort(Px, Distinct),
    ( Distinct = [One] -> Kind = solid(One)
    ; findall(RowVals,
        ( member(A, [0,1,2]), RA is R0 + 2*A,
          findall(SV, ( member(B, [0,1,2]), CB is C0 + 2*B, ft09_at(Frame, RA, CB, SV) ), RowVals) ),
        Pat),
      Kind = clue(Pat) ).

% ft09_most_common(+List, -X): the most frequent element.
ft09_most_common(List, X) :-
    msort(List, Sorted),
    ft09_runs(Sorted, Runs),
    keysort(Runs, KS), last(KS, _ - X).
ft09_runs([], []).
ft09_runs([H | T], Runs) :- ft09_runs_(T, H, 1, Runs).
ft09_runs_([], V, N, [N - V]).
ft09_runs_([H | T], V, N, Runs) :-
    ( H == V -> N1 is N + 1, ft09_runs_(T, V, N1, Runs)
    ; Runs = [N - V | R1], ft09_runs_(T, H, 1, R1) ).
