/*  Mentova — ft09 game-specific solver (Phase Solo)

    ft09 ("Functional Tiles") is a click-only constraint puzzle. Its TRUE mechanic — read
    from the engine source (ft09.py step() + win-check), recorded in the golden file's WEB
    RESEARCH ADDENDUM (2026-07-12) — is NOT a fill-projection. Clues do NOT combine into one
    target pattern; each clue is a LOCAL RELATIONAL CONSTRAINT on the 8 tiles adjacent to
    the clue's own board position, and ALL clues must hold at once (a plain conjunction).

    Per clue: the clue's CENTRE colour is nRq (the required reference colour). For each of
    its 8 border pixels (its 3x3 pattern minus the centre): a DARK pixel (value 0) requires
    the adjacent tile's colour to EQUAL nRq; a LIT pixel (non-zero) requires it to DIFFER
    from nRq; no tile at that position is unconstrained. Clicking a plain tile cycles ONLY
    that tile through the level palette. (Functional tiles — printed patterns marked with
    colour-6 pixels — cycle neighbours when clicked; they are an EFFICIENCY lever, not a
    requirement: every tile is directly clickable, so self-clicking each violating tile
    always wins the level. This solver forgoes functional tiles for a simple, always-correct
    self-click solve.)

    Why the earlier fill-projection won L1/L2: there the clue centre nRq happened to equal
    the "fill" colour and the palette was 2-colour, so "border 0 => fill" coincided with the
    true "border 0 => equal nRq". It broke the moment nRq != fill or the palette held three
    colours (L3+). This solver implements the true rule and generalises to all six levels.

    REACTIVE: ft09_next_action/3 recomputes from the CURRENT live frame every call and
    returns the single click for the first solid tile that VIOLATES one of its clue
    constraints and is SATISFIABLE (a palette colour meets all its constraints). Clicking
    cycles that tile; because tiles are independent given the fixed clues, fixing each
    violating tile converges to the global conjunction and the level auto-completes. When no
    violating tile remains the predicate fails, so the level's completion and the next level
    are picked up on the following calls with no per-level reset. Contradictory or
    unconstrained tiles are skipped (no thrash).

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

% List utilities (member/2, nth0/3, append/3, exclude/3, sort/2).
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
% REACTIVE CHOICE  (true per-clue relational-constraint conjunction)
% ---------------------------------------------------------------------------

% ft09_next_action(+Game, +Frame, -Action): choose the single next click. Read the scene
% (tiles + constraint clues), infer the palette, and click the first solid tile that
% violates a clue constraint and can be fixed. Fails when every constrained tile already
% satisfies its clues (the level is solved / auto-completing), letting the caller fall
% through.
ft09_next_action(_Game, Frame, select(Col, Row)) :-
    % All 6x6 cell blocks on the board.
    ft09_cells(Frame, Cells),
    % There must be at least one cell to act on.
    Cells \== [],
    % Cluster the cells into their separate grids.
    ft09_groups(Cells, Groups),
    % Classify every cell into solid tiles and constraint clues, tagged by grid.
    ft09_scene(Frame, Groups, Tiles, Clues),
    % The level palette — the colours a click cycles a tile through.
    ft09_palette(Tiles, Clues, Palette),
    % The first constrained tile that currently violates a clue and is fixable.
    ft09_first_fix(Tiles, Clues, Palette, Box),
    % Commit to that tile.
    !,
    % The click lands on the tile's centre pixel.
    ft09_box_centre(Box, Col, Row).

% ft09_scene(+Frame, +Groups, -Tiles, -Clues): classify every lattice cell of every grid.
% Tiles are the solid (single-colour) cells; Clues are the printed CONSTRAINT patterns.
% Each item carries its grid index G so constraints stay local to one grid.
ft09_scene(Frame, Groups, Tiles, Clues) :-
    % Solid cells become tile(G, RI, CI, Box, Colour).
    findall(tile(G, RI, CI, Box, V),
        ( nth0(G, Groups, Group),
          ft09_lattice(Group, Ys, Xs),
          nth0(RI, Ys, CY), nth0(CI, Xs, CX),
          ft09_cell_box(Group, CY, CX, Box),
          ft09_classify(Frame, Box, solid(V)) ),
        Tiles),
    % Printed constraint cells become clue(G, RI, CI, nRq, Pat).
    findall(clue(G, RI, CI, NRq, Pat),
        ( nth0(G, Groups, Group),
          ft09_lattice(Group, Ys, Xs),
          nth0(RI, Ys, CY), nth0(CI, Xs, CX),
          ft09_cell_box(Group, CY, CX, Box),
          ft09_classify(Frame, Box, clue(Pat)),
          ft09_constraint_clue(Pat, NRq) ),
        Clues).

% ft09_constraint_clue(+Pat, -NRq): a printed pattern is a CONSTRAINT clue when its centre
% sub-cell is a real palette colour (not a marker 0/2/6 nor background 4/5) and it carries
% no colour-6 pixel (a colour-6 pattern is a FUNCTIONAL tile, which this solver ignores).
ft09_constraint_clue(Pat, NRq) :-
    % The centre sub-cell is nRq.
    nth0(1, Pat, MidRow), nth0(1, MidRow, NRq),
    % It must be a real colour, not a marker or background.
    \+ member(NRq, [0, 2, 4, 5, 6]),
    % The pattern must contain no functional-tile marker (colour 6).
    \+ ( member(PRow, Pat), member(6, PRow) ).

% ft09_palette(+Tiles, +Clues, -Palette): the level palette — the distinct real colours
% among the solid tiles and the clue centres (markers and background excluded).
ft09_palette(Tiles, Clues, Palette) :-
    % Tile colours.
    findall(V, member(tile(_, _, _, _, V), Tiles), Vs),
    % Clue centre colours (each is a palette colour a tile may be required to equal).
    findall(N, member(clue(_, _, _, N, _), Clues), Ns),
    % Pool them.
    append(Vs, Ns, All0),
    % Drop any marker/background values that slipped in.
    exclude([X]>>member(X, [0, 2, 4, 5, 6]), All0, All),
    % Distinct, sorted.
    sort(All, Palette).

% ft09_first_fix(+Tiles, +Clues, +Palette, -Box): the box of the first solid tile that is
% constrained, currently violates a constraint, and is satisfiable by some palette colour.
ft09_first_fix(Tiles, Clues, Palette, Box) :-
    % Scan tiles in order (grid, then row, then column).
    member(tile(G, RI, CI, Box, V), Tiles),
    % Its constraints from the clues that govern it.
    ft09_tile_constraints(G, RI, CI, Clues, Cons),
    % The tile must be governed by at least one clue.
    Cons \== [],
    % Its current colour must violate some constraint.
    \+ ft09_satisfies(V, Cons),
    % And a palette colour must exist that meets all constraints (else clicking cannot fix
    % it — skip rather than thrash on an unsatisfiable tile).
    ft09_satisfiable(Palette, Cons),
    % First such tile wins.
    !.

% ft09_tile_constraints(+G, +RI, +CI, +Clues, -Cons): the eq/neq constraints imposed on the
% tile at (RI,CI) in grid G by every clue in the same grid whose 3x3 block covers it. The
% border pixel at the tile's offset from the clue decides: 0 (dark) => eq(nRq), else neq.
ft09_tile_constraints(G, RI, CI, Clues, Cons) :-
    % Every governing clue's constraint on this tile.
    findall(Con,
        ( member(clue(G, GR, GC, NRq, Pat), Clues),
          DR is RI - GR, DR >= -1, DR =< 1,
          DC is CI - GC, DC >= -1, DC =< 1,
          \+ ( DR =:= 0, DC =:= 0 ),
          PR is DR + 1, PC is DC + 1,
          nth0(PR, Pat, PRow), nth0(PC, PRow, Sub),
          ( Sub =:= 0 -> Con = eq(NRq) ; Con = neq(NRq) ) ),
        Cons).

% ft09_satisfies(+Colour, +Cons): the colour meets every constraint.
ft09_satisfies(V, Cons) :-
    % No constraint is violated.
    forall(member(Con, Cons), ft09_con_ok(V, Con)).

% ft09_con_ok(+Colour, +Con): one constraint holds for the colour.
ft09_con_ok(V, eq(N))  :- V =:= N.
ft09_con_ok(V, neq(N)) :- V =\= N.

% ft09_satisfiable(+Palette, +Cons): some palette colour meets every constraint.
ft09_satisfiable(Palette, Cons) :-
    % A witnessing colour exists.
    member(C, Palette), ft09_satisfies(C, Cons), !.

% ft09_box_centre(+Box, -Col, -Row): the centre pixel of a cell box, as (Col=x, Row=y).
ft09_box_centre(box(R0, C0, R1, C1), Col, Row) :-
    % The column centre is the x coordinate of the click.
    Col is (C0 + C1) // 2,
    % The row centre is the y coordinate of the click.
    Row is (R0 + R1) // 2.

% ---------------------------------------------------------------------------
% CELL DETECTION
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

% ft09_cell_box(+Group, +CY, +CX, -Box): the group cell that actually sits AT the lattice
% point (CY,CX). Fails when no cell is there — essential on the DIAMOND-shaped grids (L3-L6)
% whose lattice is a full rectangle with holes: without this guard an empty lattice position
% would be mapped to the nearest real cell, inventing a phantom tile that duplicates a real
% one with contradictory constraints and makes it oscillate forever.
ft09_cell_box(Group, CY, CX, box(R0,C0,R1,C1)) :-
    % Distance from every cell centre to the lattice point.
    findall(D - box(R0,C0,R1,C1),
        ( member(box(R0,C0,R1,C1), Group),
          MY is (R0+R1)//2, MX is (C0+C1)//2,
          D is abs(MY-CY) + abs(MX-CX) ),
        Ds),
    % The nearest cell.
    keysort(Ds, [Dmin - Box | _]),
    % A real cell must actually lie at this lattice point (well under one cell pitch, ~8px);
    % a diamond hole's nearest cell is a full pitch away, so this rejects the holes.
    Dmin =< 4,
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
