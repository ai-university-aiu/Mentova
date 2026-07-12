/*  Mentova — ft09 game-specific solver (Phase Solo, levels 1-2)

    ft09 is a click-only "Functional Tiles" / Lights-Out puzzle. Its mechanic was
    cracked over the Mentor Bridge: the board holds one or more grids of 6x6 colour
    cells; each grid has one or more fixed CLUE cells (a 3x3 mini-pattern of colours
    0/2/<fill> sampled on the cell's 2px sub-lattice). A clue governs the 3x3 block of
    cells centred on it: each governed cell must be the FILL colour where the clue's
    corresponding sub-cell is 0, else the BLANK colour. Clicking a cell toggles it; the
    level AUTO-COMPLETES when the working grid matches its clue projection (no verify
    button). The fill colour is the clue's centre sub-cell (8 on L1, 12 on L2); the blank
    colour is the grid's most common solid cell colour.

    This module is REACTIVE, mirroring the proven reference solver
    (/home/ccaitwo/claude_work_summaries/ARC-AGI-3_Observations/ft09_solver.py, which wins
    ft09 levels 1-2 live). Rather than build a fragile one-shot plan from a single frame,
    ft09_next_action/3 recomputes from the CURRENT frame every call and returns the single
    click that moves the working grid toward its target — the top-left-most governed cell
    whose colour differs from its projected target. Clicking cell-by-cell, re-reading the
    live frame each step, reproduces the reference solver's "click until target" loop and
    naturally handles colour cycling and advancing from one level to the next. When no
    governed cell is out of place the predicate fails, so the level's auto-completion and
    the next level are picked up on the following calls with no per-level reset.

    Faithful to the reference solver on two points the earlier one-shot draft got wrong:
      * cells NO clue governs are SKIPPED (not forced to blank), and
      * when clues overlap, the LAST governing clue decides (last-clue-wins).
    These are correct for levels 1-2 (non/lightly-overlapping clues). Level 3+ overlap the
    clues heavily and need a GF(2)/parity resolution not yet decoded; on those the
    projection is a best guess and may not complete the level, but it cannot crash.

    Action terms match the live client: an ACTION6 cell-click is select(Col, Row) with
    Col the x (column) and Row the y (row).

    Predicates:
      ft09_is_game/1      -- +GameId
      ft09_next_action/3  -- +Game, +Frame, -Action
      ft09_reset/1        -- +Game
*/

% Declare the module and the three predicates the player calls.
:- module(arc_ft09, [
    ft09_is_game/1,
    ft09_next_action/3,
    ft09_reset/1
]).

% List utilities (member/2, nth0/3, last/2, msort/2, keysort/2).
:- use_module(library(lists)).

% ft09_is_game(+GameId): true when the id names the ft09 environment (prefix "ft09").
ft09_is_game(GameId) :-
    % It must be an atom.
    atom(GameId),
    % Whose first four characters are "ft09" (the ids carry a hyphenated suffix).
    sub_atom(GameId, 0, 4, _, ft09).

% ft09_reset(+Game): the solver is stateless (it reads the live frame each call), so a
% reset has nothing to undo. Kept for interface parity with the other game solvers.
ft09_reset(_Game).

% ---------------------------------------------------------------------------
% REACTIVE CHOICE
% ---------------------------------------------------------------------------

% ft09_next_action(+Game, +Frame, -Action): choose the single next click. Detect the cell
% grids, and for the first grid that still has a governed cell off its projected target,
% return select(Col,Row) at that cell's centre. Fails when every governed cell already
% matches (the level is solved / auto-completing), letting the caller fall through.
ft09_next_action(_Game, Frame, select(Col, Row)) :-
    % Read all 6x6 cell blocks on the board.
    ft09_cells(Frame, Cells),
    % There must be at least one cell to act on.
    Cells \== [],
    % Cluster the cells into their separate grids.
    ft09_groups(Cells, Groups),
    % Take the first grid that has a governed cell off target.
    member(Group, Groups),
    % Find that cell's bounding box (fails for solved / clueless grids).
    ft09_group_mismatch(Frame, Group, Box),
    % Commit to this grid and cell.
    !,
    % The click lands on the cell's centre pixel.
    ft09_box_centre(Box, Col, Row).

% ft09_group_mismatch(+Frame, +Group, -Box): the box of the first governed cell in the grid
% whose current colour differs from its clue-projected target. Fails if the grid has no
% clue, no solid cells, or is already fully matched (a reference grid contributes none).
ft09_group_mismatch(Frame, Group, Box) :-
    % Build the target for every governed cell in the grid.
    ft09_group_targets(Frame, Group, Targets),
    % Pick a cell whose live colour and target disagree.
    member(target(Box, Cur, Want), Targets),
    % Only a genuine mismatch counts.
    Cur =\= Want.

% ft09_group_targets(+Frame, +Group, -Targets): classify the grid's cells, read its clues,
% fill and blank colours, and produce target(Box, Cur, Target) for each GOVERNED solid cell
% (ungoverned cells are skipped, matching the reference solver's want()==None case).
ft09_group_targets(Frame, Group, Targets) :-
    % The grid's sorted, de-duplicated cell-centre rows and columns.
    ft09_lattice(Group, Ys, Xs),
    % Classify each lattice cell as a solid colour or a 3x3 clue pattern.
    findall(cinfo(RI, CI, Box, Kind),
        ( nth0(RI, Ys, CY), nth0(CI, Xs, CX),
          ft09_cell_box(Group, CY, CX, Box),
          ft09_classify(Frame, Box, Kind) ),
        Cs),
    % Gather the clue cells with their grid positions and 3x3 patterns.
    findall(clue(RI, CI, Pat), member(cinfo(RI, CI, _, clue(Pat)), Cs), Clues),
    % A grid with no clue is not a puzzle grid — reject it.
    Clues \== [],
    % The fill colour is a clue centre sub-cell that is not 0 or 2 (8 or 12).
    ft09_fill_colour(Clues, Fill),
    % Collect the solid cell colours to find the blank colour.
    findall(V, member(cinfo(_, _, _, solid(V)), Cs), Solids),
    % A grid with no solid cell has nothing to set — reject it.
    Solids \== [],
    % The blank colour is the most common solid cell colour.
    ft09_most_common(Solids, Blank),
    % For each governed solid cell, its live colour and its projected target.
    findall(target(Box, V, Target),
        ( member(cinfo(RI, CI, Box, solid(V)), Cs),
          ft09_want(RI, CI, Clues, Want),
          ( Want =:= 0 -> Target = Fill ; Target = Blank ) ),
        Targets).

% ft09_want(+RI, +CI, +Clues, -Want): the sub-cell value of the LAST clue that governs cell
% (RI,CI) — the 3x3 block centred on each clue. Fails when no clue governs the cell, so the
% caller skips it (the reference solver's want()==None). Last-clue-wins mirrors the
% reference solver's dict-overwrite order for overlapping clues.
ft09_want(RI, CI, Clues, Want) :-
    % Every clue whose 3x3 block covers this cell, in clue order.
    findall(Sub,
        ( member(clue(GR, GC, Pat), Clues),
          DR is RI - GR, DR >= -1, DR =< 1,
          DC is CI - GC, DC >= -1, DC =< 1,
          PR is DR + 1, PC is DC + 1,
          nth0(PR, Pat, PatRow), nth0(PC, PatRow, Sub) ),
        Subs),
    % The cell must be governed by at least one clue.
    Subs \== [],
    % The last governing clue decides.
    last(Subs, Want).

% ft09_box_centre(+Box, -Col, -Row): the centre pixel of a cell box, as (Col=x, Row=y).
ft09_box_centre(box(R0, C0, R1, C1), Col, Row) :-
    % The column centre is the x coordinate of the click.
    Col is (C0 + C1) // 2,
    % The row centre is the y coordinate of the click.
    Row is (R0 + R1) // 2.

% ---------------------------------------------------------------------------
% CELL DETECTION  (unchanged — matches the reference Python solver's detection)
% ---------------------------------------------------------------------------

% ft09_isbg(+V): the background / gutter colours.
ft09_isbg(4).
ft09_isbg(5).

% ft09_at(+Frame, +R, +C, -V): the colour at row R, column C of the frame.
ft09_at(Frame, R, C, V) :-
    % Index the row.
    nth0(R, Frame, Row),
    % Index the column within the row.
    nth0(C, Row, V).

% ft09_cells(+Frame, -Cells): all 6x6-ish cell blocks as box(R0,C0,R1,C1). A cell's
% top-left has a background cell above and to the left (a gutter), and the block is 4..8
% wide and tall.
ft09_cells(Frame, Cells) :-
    % Every top-left corner that opens a valid cell block.
    findall(box(R, C, R1, C1),
        ( between(0, 57, R), between(0, 57, C),
          ft09_cell_here(Frame, R, C, R1, C1) ),
        Cells).

% ft09_cell_here(+Frame, +R, +C, -R1, -C1): (R,C) is the top-left of a 4..8 square cell.
ft09_cell_here(Frame, R, C, R1, C1) :-
    % The corner is non-background.
    ft09_at(Frame, R, C, V), \+ ft09_isbg(V),
    % A gutter (or the edge) sits above it.
    ( R =:= 0 -> true ; R0 is R - 1, ft09_at(Frame, R0, C, Va), ft09_isbg(Va) ),
    % A gutter (or the edge) sits to its left.
    ( C =:= 0 -> true ; C0 is C - 1, ft09_at(Frame, R, C0, Vl), ft09_isbg(Vl) ),
    % The block runs 4..8 cells to the right.
    ft09_run_right(Frame, R, C, W), W >= 4, W =< 8,
    % The block runs 4..8 cells down.
    ft09_run_down(Frame, R, C, H), H >= 4, H =< 8,
    % The WHOLE block must be free of background — a real cell is a solid block of one
    % colour or a clue over 0/2/fill, never containing gutter/frame background (4/5). This
    % rejects framed-grid corner blobs (frame colour + background) that would otherwise be
    % mis-detected as a cell and pollute the working grid's lattice and clue reading.
    ft09_block_clean(Frame, R, C, W, H),
    % Its bottom-right corner.
    R1 is R + H - 1, C1 is C + W - 1.

% ft09_block_clean(+Frame, +R, +C, +W, +H): true when every pixel of the WxH block at (R,C)
% is non-background (no colour 4 or 5 inside).
ft09_block_clean(Frame, R, C, W, H) :-
    % There is no interior pixel that is a background colour.
    \+ ( RM is R + H - 1, between(R, RM, RR),
         CM is C + W - 1, between(C, CM, CC),
         ft09_at(Frame, RR, CC, V), ft09_isbg(V) ).

% ft09_run_right(+Frame, +R, +C, -W): width of the non-background run starting at (R,C).
ft09_run_right(Frame, R, C, W) :-
    % Accumulate from zero.
    ft09_rr(Frame, R, C, 0, W).
ft09_rr(Frame, R, C, Acc, W) :-
    % While the cell is non-background, step right and count.
    ( ft09_at(Frame, R, C, V), \+ ft09_isbg(V)
    ->  C1 is C + 1, A1 is Acc + 1, ft09_rr(Frame, R, C1, A1, W)
    ;   W = Acc ).

% ft09_run_down(+Frame, +R, +C, -H): height of the non-background run starting at (R,C).
ft09_run_down(Frame, R, C, H) :-
    % Accumulate from zero.
    ft09_rd(Frame, R, C, 0, H).
ft09_rd(Frame, R, C, Acc, H) :-
    % While the cell is non-background, step down and count.
    ( ft09_at(Frame, R, C, V), \+ ft09_isbg(V)
    ->  R1 is R + 1, A1 is Acc + 1, ft09_rd(Frame, R1, C, A1, H)
    ;   H = Acc ).

% ft09_groups(+Cells, -Groups): cluster cells into grids by proximity (cell centres within
% 9 in both axes are the same grid).
ft09_groups(Cells, Groups) :-
    % Grow clusters one cell at a time.
    ft09_group_(Cells, [], Groups).
ft09_group_([], Acc, Acc).
ft09_group_([Cell | Rest], Acc0, Groups) :-
    % Join an existing near cluster, or start a new one.
    ( select(G, Acc0, Acc1), ft09_near_group(Cell, G)
    ->  ft09_group_(Rest, [[Cell | G] | Acc1], Groups)
    ;   ft09_group_(Rest, [[Cell] | Acc0], Groups) ).

% ft09_near_group(+Cell, +Group): the cell is near some member of the group.
ft09_near_group(Cell, Group) :-
    % Any member close enough joins them.
    member(Other, Group), ft09_near(Cell, Other).
ft09_near(box(R0,C0,R1,C1), box(S0,D0,S1,D1)) :-
    % Compare cell centres within 9 on both axes.
    CY1 is (R0+R1)//2, CX1 is (C0+C1)//2, CY2 is (S0+S1)//2, CX2 is (D0+D1)//2,
    abs(CY1-CY2) =< 9, abs(CX1-CX2) =< 9.

% ft09_lattice(+Group, -Ys, -Xs): the sorted, de-duplicated cell-centre rows and columns.
ft09_lattice(Group, Ys, Xs) :-
    % Row centres.
    findall(CY, ( member(box(R0,_,R1,_), Group), CY is (R0+R1)//2 ), Ys0),
    % Column centres.
    findall(CX, ( member(box(_,C0,_,C1), Group), CX is (C0+C1)//2 ), Xs0),
    % De-duplicate coordinates that are within 3px of each other.
    ft09_dedup(Ys0, Ys), ft09_dedup(Xs0, Xs).

% ft09_dedup(+L0, -L): sort and collapse coordinates within 3px into one.
ft09_dedup(L0, L) :-
    % Sort first so near values are adjacent.
    sort(L0, S), ft09_dd(S, L).
ft09_dd([], []).
ft09_dd([X], [X]) :- !.
ft09_dd([A, B | T], R) :-
    % Merge B into A when they are within 3px; else keep A and continue.
    ( B - A =< 3 -> ft09_dd([A | T], R) ; R = [A | R1], ft09_dd([B | T], R1) ).

% ft09_cell_box(+Group, +CY, +CX, -Box): the group cell whose centre is nearest (CY,CX).
ft09_cell_box(Group, CY, CX, box(R0,C0,R1,C1)) :-
    % Distance from every cell centre to the lattice point.
    findall(D - box(R0,C0,R1,C1),
        ( member(box(R0,C0,R1,C1), Group),
          MY is (R0+R1)//2, MX is (C0+C1)//2,
          D is abs(MY-CY) + abs(MX-CX) ),
        Ds),
    % The nearest cell wins.
    keysort(Ds, [_ - Box | _]),
    % Bind the box's corners.
    Box = box(R0,C0,R1,C1).

% ft09_classify(+Frame, +Box, -Kind): solid(Colour) if the cell is one colour, else
% clue(Pat) with Pat the 3x3 sub-pattern sampled at the cell's 2px sub-lattice.
ft09_classify(Frame, box(R0,C0,R1,C1), Kind) :-
    % Every pixel colour in the cell.
    findall(V, ( between(R0, R1, R), between(C0, C1, C), ft09_at(Frame, R, C, V) ), Px),
    % The distinct colours present.
    sort(Px, Distinct),
    % One colour is a solid cell; more than one is a clue pattern.
    ( Distinct = [One] -> Kind = solid(One)
    ; findall(RowVals,
        ( member(A, [0,1,2]), RA is R0 + 2*A,
          findall(SV, ( member(B, [0,1,2]), CB is C0 + 2*B, ft09_at(Frame, RA, CB, SV) ), RowVals) ),
        Pat),
      Kind = clue(Pat) ).

% ft09_fill_colour(+Clues, -Fill): the fill colour = a clue centre sub-cell value that is
% not 0 or 2 (i.e. 8 or 12).
ft09_fill_colour(Clues, Fill) :-
    % A clue whose centre sub-cell is a fill colour.
    member(clue(_, _, Pat), Clues),
    % The centre sub-cell (row 1, column 1 of the 3x3).
    nth0(1, Pat, Mid), nth0(1, Mid, Fill),
    % It must be a fill colour, not background/clue-marker 0 or 2.
    Fill =\= 0, Fill =\= 2, !.
% Default fill when no clue centre reveals it.
ft09_fill_colour(_, 8).

% ft09_most_common(+List, -X): the most frequent element.
ft09_most_common(List, X) :-
    % Sort so equal values group together.
    msort(List, Sorted),
    % Count each run.
    ft09_runs(Sorted, Runs),
    % The longest run's value is the most common.
    keysort(Runs, KS), last(KS, _ - X).
ft09_runs([], []).
ft09_runs([H | T], Runs) :-
    % Start counting from the first element.
    ft09_runs_(T, H, 1, Runs).
ft09_runs_([], V, N, [N - V]).
ft09_runs_([H | T], V, N, Runs) :-
    % Extend the current run or close it and open the next.
    ( H == V -> N1 is N + 1, ft09_runs_(T, V, N1, Runs)
    ; Runs = [N - V | R1], ft09_runs_(T, H, 1, R1) ).
