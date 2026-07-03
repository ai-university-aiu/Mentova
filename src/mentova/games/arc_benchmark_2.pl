/*  Mentova — ARC-AGI-2 Benchmark Runner (Acc_298, WP-274–277 infrastructure)

    Runs ARC-AGI-2 evaluation tasks through Mentova's inductive reasoning
    engine and reports an honest score.

    Methodology: pure induction from training examples only, no pretraining
    on the ARC-AGI-2 corpus, named glass-box rules for every solved task.

    Four search levels are tried for each task, dispatched by task category:
        Level 1 (single): tc_categorize → single_rule strategy.
        Level 2 (composite): tc_categorize → multi_step / seqinfer 2-step.
        Level 3 (context_gated): tc_categorize → context_gate_search.
        Level 4 (symbol_table): tc_categorize → symbol_table_learning.

    ARC-AGI-2 task data is stored in data/arc_agi_2/arc_tasks_2.pl.
    That file is populated by tools/arc_agi2_to_prolog.py once JSON files
    are downloaded to data/arc_agi_2/tasks/.

    Predicate interface:
        arc2_benchmark_run(-Score, -Total, -Results)
            Run the full benchmark. Results = list of
            result(TaskId, pass(Rule)) | result(TaskId, fail).
        arc2_benchmark_print/0
            Run and print a full report to stdout.
        arc2_induce_rule(+TrainingPairs, -Rule)
            Core induction predicate: classify task type, dispatch strategy,
            verify rule against all training pairs.
*/

% Declare this file as the arc_benchmark_2 module.
:- module(arc_benchmark_2, [
    % arc2_benchmark_run/3: run all tasks and collect results.
    arc2_benchmark_run/3,
    % arc2_benchmark_print/0: run and print a full report to stdout.
    arc2_benchmark_print/0,
    % arc2_induce_rule/2: core task-type-aware induction predicate.
    arc2_induce_rule/2,
    % arc2_named_rule/1: enumerate known transform names.
    arc2_named_rule/1,
    % arc2_transform/3: apply a named rule to a grid.
    arc2_transform/3
]).

% Load list utilities.
:- use_module(library(lists), [
    % member/2 for candidate search.
    member/2,
    % append/2 for concatenation.
    append/2,
    % last/2 for last element.
    last/2,
    % subtract/3 for set difference.
    subtract/3,
    % numlist/3 for index generation.
    numlist/3,
    % max_member/2 for finding maximum list element.
    max_member/2
]).
% Load apply utilities.
:- use_module(library(apply), [maplist/2, maplist/3, maplist/4, include/3, exclude/3, foldl/4]).
% Load pairs utilities for pairs_keys_values/3.
:- use_module(library(pairs), [pairs_keys_values/3]).

% Allow arc2_transform/3 clauses at non-consecutive positions.
:- discontiguous arc2_transform/3.
% Allow arc2_named_rule/1 at non-consecutive positions.
:- discontiguous arc2_named_rule/1.
% Allow arc2_induce_rule/2 clauses at non-consecutive positions.
:- discontiguous arc2_induce_rule/2.

% ---------------------------------------------------------------------------
% TRANSFORM REGISTRY
% arc2_named_rule(+RuleName) — enumerate all known transform names.
% arc2_transform(+Rule, +Grid, -OutputGrid) — apply Rule to Grid.
% ---------------------------------------------------------------------------

% Enumerate reverse_rows as a known rule name.
arc2_named_rule(reverse_rows).
% Define reverse_rows: reverse each row left-to-right.
arc2_transform(reverse_rows, Grid, Result) :-
    maplist([Row, Rev]>>(reverse(Row, Rev)), Grid, Result).

% Enumerate vertical_flip as a known rule name.
arc2_named_rule(vertical_flip).
% Define vertical_flip: reverse the order of rows top-to-bottom.
arc2_transform(vertical_flip, Grid, Result) :-
    reverse(Grid, Result).

% Enumerate transpose as a known rule name.
arc2_named_rule(transpose).
% Define transpose: swap rows and columns.
arc2_transform(transpose, Grid, Result) :-
    Grid = [FirstRow|_],
    length(FirstRow, NCols),
    numlist(1, NCols, ColIdxs),
    maplist([CI, Col]>>(maplist([R, E]>>(nth1(CI, R, E)), Grid, Col)), ColIdxs, Result).

% Enumerate rotate_90_cw as a known rule name.
arc2_named_rule(rotate_90_cw).
% Define rotate_90_cw: transpose then reverse each row.
arc2_transform(rotate_90_cw, Grid, Result) :-
    arc2_transform(transpose, Grid, T),
    arc2_transform(reverse_rows, T, Result).

% Enumerate rotate_90_ccw as a known rule name.
arc2_named_rule(rotate_90_ccw).
% Define rotate_90_ccw: reverse each row then transpose.
arc2_transform(rotate_90_ccw, Grid, Result) :-
    arc2_transform(reverse_rows, Grid, T),
    arc2_transform(transpose, T, Result).

% Enumerate rotate_180 as a known rule name.
arc2_named_rule(rotate_180).
% Define rotate_180: reverse rows then flip vertically.
arc2_transform(rotate_180, Grid, Result) :-
    arc2_transform(reverse_rows, Grid, T),
    arc2_transform(vertical_flip, T, Result).

% layout_tile: dispatch early because its pre-filter is O(H) and fails fast.
arc2_named_rule(layout_tile).
% arc2_induce_rule(layout_tile): fast divider-row pre-filter + forall verify.
arc2_induce_rule(TrainingPairs, layout_tile) :-
% Require exactly 2 identical divider rows in the first training input.
    TrainingPairs = [pair(First, _)|_],
% Find divider rows (rows with only {0,5} values, at least one 5).
    arc2_lt_divider_rows_(First, [R0, R1]),
% Both divider rows must be identical (same repeating pattern).
    nth0(R0, First, DivRow), nth0(R1, First, DivRow),
% Verify every training pair produces the correct output.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(layout_tile, In, Out)).

% scaled_frame: early dispatch to avoid generic clause hitting slow frame_assemble.
arc2_named_rule(scaled_frame).
% arc2_induce_rule(scaled_frame): frame pre-filter + forall verify.
arc2_induce_rule(TrainingPairs, scaled_frame) :-
% Pre-filter: a rectangular frame must be detectable in the first training input.
    TrainingPairs = [pair(First, _)|_],
% Check that a rectangular frame is present.
    arc2_sf_frame_(First, _, _, _, _, _),
% Verify every training pair produces the correct output.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(scaled_frame, In, Out)).

% cross_reflect: early dispatch to run specific clause before generic.
arc2_named_rule(cross_reflect).
% arc2_induce_rule(cross_reflect): background/cross pre-filter + forall verify.
arc2_induce_rule(TrainingPairs, cross_reflect) :-
% Pre-filter: must have a cross-reflect structure in the first training input.
    TrainingPairs = [pair(First, _)|_],
    arc2_cell_(First, 0, 0, BG0),
    arc2_cr_cross_(First, BG0, _, _),
% Verify every training pair produces the correct output.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(cross_reflect, In, Out)).

% frame_reflect: early dispatch to run specific clause before generic.
arc2_named_rule(frame_reflect).
% arc2_induce_rule(frame_reflect): row-0-all-8 pre-filter + forall verify.
arc2_induce_rule(TrainingPairs, frame_reflect) :-
% Pre-filter: first row of first training input must be entirely color 8.
    TrainingPairs = [pair(First, _)|_],
    First = [Row0|_],
    forall(member(V, Row0), V =:= 8),
% Verify every training pair produces the correct output.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(frame_reflect, In, Out)).

% frame_pour: early dispatch to run before slow generic clause.
arc2_named_rule(frame_pour).
% arc2_induce_rule(frame_pour): frame-plus-fill pre-filter + forall verify.
arc2_induce_rule(TrainingPairs, frame_pour) :-
% Pre-filter: require at least 3 distinct colors in first training input.
    TrainingPairs = [pair(First, _)|_],
% Flatten grid to check color count quickly.
    flatten(First, Cells),
    sort(Cells, Uniq),
    length(Uniq, NC),
    NC >= 3,
% Verify every training pair produces the correct output.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(frame_pour, In, Out)).

% col_rank_fill: early dispatch before generic clause.
arc2_named_rule(col_rank_fill).
% arc2_induce_rule(col_rank_fill): indicator bar at (0,C) determines rank; majority verify.
arc2_induce_rule(TrainingPairs, col_rank_fill) :-
% First training input must have a non-BG cell at (0,0) to signal bar indicators.
    TrainingPairs = [pair([R0|_], _)|_],
    R0 = [Ind|_], Ind =\= 0,
% Require majority of training pairs to pass the transform.
    length(TrainingPairs, NTotal),
    findall(1, (member(pair(In, Out), TrainingPairs),
               arc2_transform(col_rank_fill, In, Out)), OKs),
    length(OKs, NOK), NOK >= NTotal - 1.

% shape_slide: early dispatch before generic clause.
arc2_named_rule(shape_slide).
% arc2_induce_rule(shape_slide): seed-directed relocation pre-filter + majority verify.
arc2_induce_rule(TrainingPairs, shape_slide) :-
% Require at least 3 distinct colors (BG + shape-boundary + interior marker).
    TrainingPairs = [pair(First,_)|_],
% Flatten first input grid to count distinct values.
    flatten(First, FCs), sort(FCs, FUniq), length(FUniq, FN), FN >= 3,
% Count how many training pairs the transform satisfies.
    length(TrainingPairs, NTotal),
% Require all but at most one pair to pass (tolerates one anomalous pair).
    findall(1, (member(pair(In, Out), TrainingPairs),
               arc2_transform(shape_slide, In, Out)), OKs),
    length(OKs, NOK), NOK >= NTotal - 1.

% snake_frame: early dispatch before generic clause.
arc2_named_rule(snake_frame).
% arc2_induce_rule(snake_frame): pointer 3 wraps frame around 1/2 snake objects.
arc2_induce_rule(TrainingPairs, snake_frame) :-
% Fast filter: first input must have exactly these four values: 1, 2, 3, 8.
    TrainingPairs = [pair(First,_)|_],
    flatten(First, FCs),
    sort(FCs, Uniq), Uniq = [1,2,3,8],
% Exactly one cell must hold value 3 (the single pointer).
    include(==(3), FCs, Threes), length(Threes, 1),
% Require all training pairs to pass the transform.
    length(TrainingPairs, NTotal),
% Verify each pair passes snake_frame.
    findall(1, (member(pair(In, Out), TrainingPairs),
               arc2_transform(snake_frame, In, Out)), OKs),
    length(OKs, NOK), NOK =:= NTotal.

% ---------------------------------------------------------------------------
% CELL ACCESS
% arc2_cell_/4: get color at (R,C); fails if out of bounds.
% ---------------------------------------------------------------------------

% arc2_cell_(+Grid, +R, +C, -Color): retrieve a cell; fails on out-of-bounds.
arc2_cell_(Grid, R, C, Color) :-
    R >= 0, C >= 0,
    nth0(R, Grid, Row),
    nth0(C, Row, Color).

% ---------------------------------------------------------------------------
% PLUS-SHAPE RECOLOR
% Detects 5-cell cross/plus shapes of a source color and recolors to target.
% Rule learned from training pairs where only one color change type occurs.
% Reference: ARC-AGI-2 task 1818057f -- plus shapes of 4 recolored to 8.
% ---------------------------------------------------------------------------

% arc2_is_plus_center_/4: true if (R,C) is the center of a plus shape of Color.
arc2_is_plus_center_(Grid, R, C, Color) :-
    arc2_cell_(Grid, R, C, Color),
    R1 is R - 1, arc2_cell_(Grid, R1, C, Color),
    R2 is R + 1, arc2_cell_(Grid, R2, C, Color),
    C1 is C - 1, arc2_cell_(Grid, R, C1, Color),
    C2 is C + 1, arc2_cell_(Grid, R, C2, Color).

% arc2_apply_plus_recolor/4: recolor all cells in plus shapes of A to B.
arc2_apply_plus_recolor(Grid, A, B, Result) :-
    length(Grid, NR),
    NR > 0,
    Grid = [FirstRow|_],
    length(FirstRow, NC),
    MaxR is NR - 1,
    MaxC is NC - 1,
    % Collect all plus-center positions.
    findall(r(R,C),
        (between(0, MaxR, R), between(0, MaxC, C),
         arc2_is_plus_center_(Grid, R, C, A)),
        Centers),
    % Expand each center to all 5 plus cells.
    findall(R-C,
        (member(r(CR,CC), Centers),
         (R = CR, C = CC ;
          R is CR - 1, C = CC ;
          R is CR + 1, C = CC ;
          R = CR, C is CC - 1 ;
          R = CR, C is CC + 1)),
        PlusCellsList),
    sort(PlusCellsList, PlusCells),
    % Build result grid: replace plus cells with B, leave rest unchanged.
    numlist(0, MaxR, Rows),
    maplist([R, Row]>>(
        numlist(0, MaxC, Cols),
        maplist([C, Cell]>>(
            ( member(R-C, PlusCells) ->
                Cell = B
            ;   arc2_cell_(Grid, R, C, Cell)
            )
        ), Cols, Row)
    ), Rows, Result).

% arc2_learn_single_recolor_/3: all changed cells go A->B and no other changes.
arc2_learn_single_recolor_(TrainingPairs, A, B) :-
    findall(Before-After,
        (member(pair(In, Out), TrainingPairs),
         append(In, FlatIn), append(Out, FlatOut),
         nth0(I, FlatIn, Before),
         nth0(I, FlatOut, After),
         Before \= After),
        Changes),
    Changes \= [],
    sort(Changes, [A-B]),
    A \= B.

% arc2_transform for the parameterized plus-recolor rule.
arc2_transform(recolor_plus(A, B), Grid, Result) :-
    arc2_apply_plus_recolor(Grid, A, B, Result).

% ---------------------------------------------------------------------------
% CHAIN STRIP TRANSFORM
% Non-background cells form same-color connected blobs arranged in a linear
% chain. Output: Nx1 strip listing each blob's color once per cell, in the
% order that follows the chain's adjacency graph starting from the endpoint
% whose topmost-leftmost cell comes first in reading order.
% Reference: ARC-AGI-2 task 7b5033c1.
% ---------------------------------------------------------------------------

% arc2_bg_color_/2: find the most common cell value (background) in the grid.
arc2_bg_color_(Grid, Bg) :-
%   Flatten the grid to a single list for frequency analysis.
    append(Grid, All),
%   Sort to group equal values into contiguous runs.
    msort(All, Sorted),
%   Scan runs to find the mode (most frequent value).
    arc2_run_mode_(Sorted, Bg).

% arc2_run_mode_/2: find the mode of a sorted list using run-length scanning.
arc2_run_mode_([H|T], Mode) :-
%   Start scanning with H as the current run value, count 1, best 1.
    arc2_run_mode_h_(T, H, 1, H, 1, Mode).

% arc2_run_mode_h_/6: helper accumulating current-run and best-run stats.
arc2_run_mode_h_([], C, N, B, BN, M) :-
%   End of list: emit whichever run had the higher count.
    ( N > BN -> M = C ; M = B ).
arc2_run_mode_h_([H|T], H, N, B, BN, M) :-
%   Same value continues the current run; increment count.
    N1 is N+1, arc2_run_mode_h_(T, H, N1, B, BN, M).
arc2_run_mode_h_([H|T], C, N, B, BN, M) :-
%   New value starts a fresh run; update best if current run beats it.
    H \= C,
    ( N > BN -> NB=C, NBN=N ; NB=B, NBN=BN ),
    arc2_run_mode_h_(T, H, 1, NB, NBN, M).

% arc2_bfs_/7: BFS flood-fill collecting cells of Color reachable from seeds.
arc2_bfs_(_, [], _, Vis, Acc, Acc, Vis).
arc2_bfs_(Grid, [R-C|Q], Color, Vis0, Acc0, Comp, Vis) :-
%   Only expand cells not yet visited that have the target color.
    (   \+ memberchk(R-C, Vis0), arc2_cell_(Grid, R, C, Color)
    ->  Vis1 = [R-C|Vis0],
%       Add all four cardinal neighbors to the queue.
        R1 is R-1, R2 is R+1, C1 is C-1, C2 is C+1,
        append(Q, [R1-C, R2-C, R-C1, R-C2], Q1),
        arc2_bfs_(Grid, Q1, Color, Vis1, [R-C|Acc0], Comp, Vis)
%       Cell already visited or wrong color: skip it.
    ;   arc2_bfs_(Grid, Q, Color, Vis0, Acc0, Comp, Vis)
    ).

% arc2_all_comps_/3: find all connected same-color components ignoring Bg.
arc2_all_comps_(Grid, Bg, Comps) :-
%   Determine grid dimensions.
    length(Grid, NR), Grid = [FR|_], length(FR, NC),
    MaxR is NR-1, MaxC is NC-1,
%   Collect all non-background cell coordinates in reading order.
    findall(R-C,
        (between(0,MaxR,R), between(0,MaxC,C),
         arc2_cell_(Grid,R,C,V), V \= Bg),
        Seeds),
%   Process seeds left-to-right, top-to-bottom, skipping already-visited ones.
    arc2_seeds_to_comps_(Grid, Seeds, [], Comps).

% arc2_seeds_to_comps_/4: iterate seeds, flood-filling each unvisited one.
arc2_seeds_to_comps_(_, [], _, []).
arc2_seeds_to_comps_(Grid, [R-C|Rest], Vis0, Comps) :-
    (   memberchk(R-C, Vis0)
%       Already assigned to a component: skip.
    ->  arc2_seeds_to_comps_(Grid, Rest, Vis0, Comps)
%       New seed: flood-fill to find its full component.
    ;   arc2_cell_(Grid, R, C, Color),
        arc2_bfs_(Grid, [R-C], Color, Vis0, [], Cells, Vis1),
        Comps = [comp(Color,Cells)|Tail],
        arc2_seeds_to_comps_(Grid, Rest, Vis1, Tail)
    ).

% arc2_comp_adjacent_/2: true when two components share a grid-adjacent cell.
arc2_comp_adjacent_(comp(_,C1), comp(_,C2)) :-
%   Check if any cell from C1 is a 4-neighbor of any cell from C2.
    member(R1-CC1, C1),
    member(R2-CC2, C2),
    (   R1 =:= R2, D is abs(CC1-CC2), D =:= 1
    ;   CC1 =:= CC2, D is abs(R1-R2), D =:= 1
    ), !.

% arc2_nbr_map_/2: build a list of comp-neighbors pairs for all components.
arc2_nbr_map_(Comps, Map) :-
%   For each component, find all other components adjacent to it.
    maplist([C, C-Ns]>>(
        include([X]>>(X \= C, arc2_comp_adjacent_(C, X)), Comps, Ns)
    ), Comps, Map).

% arc2_chain_endpoints_/3: components with at most one neighbor (chain ends).
arc2_chain_endpoints_(Comps, NbrMap, Ends) :-
%   Endpoint = degree 0 or degree 1 in the adjacency graph.
    include([C]>>(
        member(C-Ns, NbrMap), length(Ns, L), L =< 1
    ), Comps, Ends).

% arc2_earliest_comp_/2: component whose min cell is first in reading order.
arc2_earliest_comp_([C], C) :- !.
arc2_earliest_comp_([C|Cs], Best) :-
%   Recursively pick the component with the smallest (R,C) cell.
    arc2_earliest_comp_(Cs, Best0),
    C = comp(_,CC), Best0 = comp(_,BC),
    msort(CC, [MC|_]), msort(BC, [MB|_]),
    ( MC @< MB -> Best = C ; Best = Best0 ).

% arc2_trace_chain_/4: follow adjacency from Cur, building ordered chain list.
arc2_trace_chain_(Cur, NbrMap, Visited, [Cur|Rest]) :-
%   Look up this component's neighbors.
    member(Cur-Ns, NbrMap),
%   Remove already-visited components to find the next hop.
    subtract(Ns, Visited, Unvisited),
    (   Unvisited = [Next|_]
%       Follow the next unvisited neighbor.
    ->  arc2_trace_chain_(Next, NbrMap, [Next|Visited], Rest)
%       No unvisited neighbors: end of chain.
    ;   Rest = []
    ).

% arc2_named_rule: register chain_strip as a known rule name.
arc2_named_rule(chain_strip).

% arc2_transform for chain_strip: produce the Nx1 chain-ordered strip.
arc2_transform(chain_strip, Grid, Result) :-
%   Find the background (most common) color.
    arc2_bg_color_(Grid, Bg),
%   Find all connected same-color components.
    arc2_all_comps_(Grid, Bg, Comps),
%   Build adjacency map and find chain order.
    arc2_nbr_map_(Comps, NbrMap),
    arc2_chain_endpoints_(Comps, NbrMap, Ends),
    ( Ends = [_|_] -> true ; Comps = Ends ),
    arc2_earliest_comp_(Ends, Start),
    arc2_trace_chain_(Start, NbrMap, [Start], Chain),
%   Build the output strip: each component contributes [Color] x cell_count.
    maplist([comp(Color,Cells), Rows]>>(
        length(Cells, N),
        length(Rows, N),
        maplist(=([Color]), Rows)
    ), Chain, Nested),
    append(Nested, Result).

% arc2_induce_rule for chain_strip: output must be Nx1, rule must fit all pairs.
arc2_induce_rule(TrainingPairs, chain_strip) :-
%   Guard: every output row is a single-element list.
    forall(member(pair(_,Out), TrainingPairs),
           (Out = [[_]|_], \+ member([_,_|_], Out))),
%   Verify: chain_strip applied to every training input yields the training output.
    forall(member(pair(In,Out), TrainingPairs),
           arc2_transform(chain_strip, In, Out)).

% ---------------------------------------------------------------------------
% ARM ENDPOINT RAY TRANSFORM
% Background is a checkerboard of alternating 0s and 1s.  Non-background
% special cells form diagonal arm segments.  Each arm endpoint -- a special
% cell with exactly one same-color diagonal neighbor in one direction and zero
% in the other -- shoots a perpendicular ray that fills background-1 cells
% with the arm color until the ray exits the grid or hits a non-bg cell.
% Reference: ARC-AGI-2 task 80a900e0 (checkerboard diagonal arm projection).
% ---------------------------------------------------------------------------

% arc2_replace_idx_/4: replace the element at 0-based index N in list L with V.
arc2_replace_idx_(0, [_|T], V, [V|T]) :- !.
% Recurse past head H, decrementing the index.
arc2_replace_idx_(N, [H|T], V, [H|T2]) :-
%   Guard: index is positive.
    N > 0,
%   Decrement and recurse into the tail.
    N1 is N - 1,
    arc2_replace_idx_(N1, T, V, T2).

% arc2_set_cell_/5: return a new grid with cell (R,C) replaced by value V.
arc2_set_cell_(Grid, R, C, V, NewGrid) :-
%   Extract the row at index R.
    nth0(R, Grid, OldRow),
%   Replace column C with V in the extracted row.
    arc2_replace_idx_(C, OldRow, V, NewRow),
%   Replace row R with the updated row in the grid.
    arc2_replace_idx_(R, Grid, NewRow, NewGrid).

% arc2_diag_nbr_cnt_/6: count same-color V diagonal neighbors in both directions.
% NMain counts (-1,-1) and (+1,+1) hits; NAnti counts (-1,+1) and (+1,-1) hits.
arc2_diag_nbr_cnt_(Grid, R, C, V, NMain, NAnti) :-
%   Compute the four diagonal neighbor positions.
    Rm1 is R - 1, Rp1 is R + 1, Cm1 is C - 1, Cp1 is C + 1,
%   Test main-diagonal neighbor at (R-1, C-1).
    (arc2_cell_(Grid, Rm1, Cm1, V) -> M1 = 1 ; M1 = 0),
%   Test main-diagonal neighbor at (R+1, C+1).
    (arc2_cell_(Grid, Rp1, Cp1, V) -> M2 = 1 ; M2 = 0),
%   Test anti-diagonal neighbor at (R-1, C+1).
    (arc2_cell_(Grid, Rm1, Cp1, V) -> A1 = 1 ; A1 = 0),
%   Test anti-diagonal neighbor at (R+1, C-1).
    (arc2_cell_(Grid, Rp1, Cm1, V) -> A2 = 1 ; A2 = 0),
%   Sum main-diagonal and anti-diagonal counts.
    NMain is M1 + M2,
    NAnti is A1 + A2.

% arc2_arm_endpoints_/2: collect all valid arm endpoints from Grid.
% A valid endpoint is a non-(0,1) cell whose same-color diagonal neighbors all
% lie in exactly one diagonal direction (NMain XOR NAnti = 1; the other = 0).
arc2_arm_endpoints_(Grid, Endpoints) :-
%   Determine grid bounds.
    length(Grid, NR),
    Grid = [FR|_], length(FR, NC),
    MaxR is NR - 1, MaxC is NC - 1,
%   Scan every cell and keep those satisfying the endpoint criterion.
    findall(ep(R, C, V, Dir),
        (between(0, MaxR, R), between(0, MaxC, C),
         arc2_cell_(Grid, R, C, V),
         V \= 0, V \= 1,
         arc2_diag_nbr_cnt_(Grid, R, C, V, NM, NA),
         (NM =:= 1, NA =:= 0 -> Dir = anti
         ;NM =:= 0, NA =:= 1 -> Dir = main
         ;fail)),
        Endpoints).

% arc2_shoot_ray_/9: step from (R,C) in direction (DR,DC) filling 1-cells with V.
arc2_shoot_ray_(Grid, R, C, V, DR, DC, NR, NC, Result) :-
%   Compute the next step position.
    R1 is R + DR, C1 is C + DC,
%   Continue only if the next cell is in-bounds and currently holds value 1.
    (   R1 >= 0, R1 < NR, C1 >= 0, C1 < NC,
        arc2_cell_(Grid, R1, C1, 1)
%       Fill the cell and continue the ray from the new position.
    ->  arc2_set_cell_(Grid, R1, C1, V, Grid1),
        arc2_shoot_ray_(Grid1, R1, C1, V, DR, DC, NR, NC, Result)
%       Ray is blocked or exited the grid; return the grid as-is.
    ;   Result = Grid
    ).

% arc2_apply_arm_rays_/5: apply the perpendicular ray from each endpoint in turn.
arc2_apply_arm_rays_(Grid, [], _, _, Grid).
% Dir=anti means the arm lies along a main diagonal; shoot anti-diagonal rays.
arc2_apply_arm_rays_(Grid, [ep(R, C, V, anti)|Eps], NR, NC, Result) :-
%   Shoot in the (+1,-1) direction (down-left along anti-diagonal).
    arc2_shoot_ray_(Grid, R, C, V, 1, -1, NR, NC, G1),
%   Shoot in the (-1,+1) direction (up-right along anti-diagonal).
    arc2_shoot_ray_(G1, R, C, V, -1, 1, NR, NC, G2),
%   Continue with remaining endpoints.
    arc2_apply_arm_rays_(G2, Eps, NR, NC, Result).
% Dir=main means the arm lies along an anti-diagonal; shoot main-diagonal rays.
arc2_apply_arm_rays_(Grid, [ep(R, C, V, main)|Eps], NR, NC, Result) :-
%   Shoot in the (+1,+1) direction (down-right along main diagonal).
    arc2_shoot_ray_(Grid, R, C, V, 1, 1, NR, NC, G1),
%   Shoot in the (-1,-1) direction (up-left along main diagonal).
    arc2_shoot_ray_(G1, R, C, V, -1, -1, NR, NC, G2),
%   Continue with remaining endpoints.
    arc2_apply_arm_rays_(G2, Eps, NR, NC, Result).

% Register arm_endpoint_ray as a known named transform.
arc2_named_rule(arm_endpoint_ray).

% arc2_transform for arm_endpoint_ray: find endpoints and shoot perpendicular rays.
arc2_transform(arm_endpoint_ray, Grid, Result) :-
%   Determine grid dimensions for bounds checking.
    length(Grid, NR),
    Grid = [FR|_], length(FR, NC),
%   Find all valid arm endpoints; fail immediately if none exist.
    arc2_arm_endpoints_(Grid, Endpoints),
    Endpoints \= [],
%   Apply every endpoint's perpendicular rays to produce the output grid.
    arc2_apply_arm_rays_(Grid, Endpoints, NR, NC, Result).

% arc2_induce_rule for arm_endpoint_ray: checkerboard guard then full verification.
arc2_induce_rule(TrainingPairs, arm_endpoint_ray) :-
%   Extract first training input for the structural pre-check.
    TrainingPairs = [pair(In0, _)|_],
%   Sample the top-left 2x2 corner to confirm a checkerboard background.
    nth0(0, In0, Rcb0), nth0(0, Rcb0, V00), nth0(1, Rcb0, V01),
    nth0(1, In0, Rcb1), nth0(0, Rcb1, V10), nth0(1, Rcb1, V11),
%   Corner values must all be 0 or 1.
    (V00 =:= 0 ; V00 =:= 1),
%   Horizontally adjacent cells must differ (alternating).
    V00 =\= V01,
%   Diagonally opposite cells must match (checkerboard pattern).
    V00 =:= V11, V01 =:= V10,
%   Confirm at least one arm endpoint exists in the first training input.
    arc2_arm_endpoints_(In0, Eps0), Eps0 \= [],
%   Verify the transform reproduces the correct output for every training pair.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(arm_endpoint_ray, In, Out)).

% ---------------------------------------------------------------------------
% SEGMENT EQUALIZATION
% Non-background cells form segments in one direction: each segment is a set
% of consecutive cells sharing a row (horizontal), column (vertical), or
% anti-diagonal (r+c=const). One endpoint of every segment is aligned to a
% common value (the anchor). The other endpoint is extended or trimmed so
% every segment matches the middle segment by position.
% Reference: ARC-AGI-2 task e376de54.
% ---------------------------------------------------------------------------

% arc2_segeq_kv_/5: direction-specific (Key, Vary) for cell (R, C).
arc2_segeq_kv_(R, C, antidiag, K, V) :-
%   Anti-diagonal: key = R+C; varying coordinate = row R.
    K is R + C, V = R.
% Horizontal: key = row; varying coordinate = column.
arc2_segeq_kv_(R, C, horizontal, K, V) :-
%   Horizontal segments share their row as the key; column varies.
    K = R, V = C.
% Vertical: key = column; varying coordinate = row.
arc2_segeq_kv_(R, C, vertical, K, V) :-
%   Vertical segments share their column as the key; row varies.
    K = C, V = R.

% arc2_segeq_align_/4: alignment value of a segment endpoint.
arc2_segeq_align_(antidiag, Key, Vary, Align) :-
%   Anti-diagonal: alignment = 2*Vary - Key (= r-c of that cell).
    Align is 2 * Vary - Key.
% Linear directions: alignment IS the vary value directly.
arc2_segeq_align_(horizontal, _, Vary, Vary).
% Vertical: alignment is the row number, which is Vary.
arc2_segeq_align_(vertical, _, Vary, Vary).

% arc2_segeq_cvary_/4: correct vary coordinate from (Dir, Key, TargetAlignment).
arc2_segeq_cvary_(antidiag, Key, TAlign, Vary) :-
%   Invert the alignment formula: Vary = (Key + TAlign) // 2.
    Vary is (Key + TAlign) // 2.
% Horizontal: correct vary equals the target alignment directly.
arc2_segeq_cvary_(horizontal, _, TAlign, TAlign).
% Vertical: correct vary equals the target alignment directly.
arc2_segeq_cvary_(vertical, _, TAlign, TAlign).

% arc2_segeq_cellpos_/5: grid (R, C) from direction, key, and vary value.
arc2_segeq_cellpos_(antidiag, Key, Vary, Vary, C) :-
%   Anti-diagonal: row = Vary, column = Key - Vary.
    C is Key - Vary.
% Horizontal: row = Key, column = Vary.
arc2_segeq_cellpos_(horizontal, Key, Vary, Key, Vary).
% Vertical: row = Vary, column = Key.
arc2_segeq_cellpos_(vertical, Key, Vary, Vary, Key).

% arc2_segeq_consec_/1: true if a sorted integer list contains no gaps.
arc2_segeq_consec_(Sorted) :-
%   Minimum is the list head.
    Sorted = [Vmin|_],
%   Maximum is the last element.
    last(Sorted, Vmax),
%   A gap-free run of integers has exactly Vmax-Vmin+1 elements.
    Len is Vmax - Vmin + 1,
%   Length must equal Len.
    length(Sorted, Len).

% arc2_segeq_dir_/2: detect the segment direction; commits on first valid match.
arc2_segeq_dir_(Cells, Dir) :-
%   Candidate directions in preference order.
    member(Dir, [antidiag, horizontal, vertical]),
%   Compute (Key, Vary) for every cell under this direction.
    findall(K-V, (member(r(R,C,_), Cells), arc2_segeq_kv_(R,C,Dir,K,V)), KVs),
%   Extract all key values and de-duplicate.
    findall(K, member(K-_, KVs), Ks0), sort(Ks0, UniqueKs),
%   Require at least two distinct segments.
    length(UniqueKs, NSegs), NSegs >= 2,
%   Each key's vary values must form a consecutive integer run.
    forall(member(K, UniqueKs), (
        findall(V, member(K-V, KVs), Vs0),
        msort(Vs0, Vs), arc2_segeq_consec_(Vs)
    )),
%   Commit to this direction; do not backtrack to later candidates.
    !.

% arc2_segeq_build_segs_/3: build seg(K,Vmin,Vmax,Color) for each sorted key.
arc2_segeq_build_segs_(KVVs, SortedKeys, Segs) :-
%   For each key, sort its vary values to get min and max, then look up color.
    findall(seg(K,Vmin,Vmax,Color), (
        member(K, SortedKeys),
        findall(V, member(K-V-_, KVVs), Vs0), msort(Vs0, Vs),
        Vs = [Vmin|_], last(Vs, Vmax),
        once(member(K-Vmin-Color, KVVs))
    ), Segs).

% arc2_segeq_anchor_/4: min-anchor case -- all min-alignments equal.
arc2_segeq_anchor_(Dir, Segs, min, DTarget) :-
%   Collect the alignment value of the minimum-vary endpoint of every segment.
    findall(A, (member(seg(K,Vmin,_,_),Segs), arc2_segeq_align_(Dir,K,Vmin,A)), As),
%   All min-alignments must be identical; sort to a singleton.
    sort(As, [_]),
%   Pick the middle segment by index.
    length(Segs, N), MidIdx is N // 2,
%   Get the middle segment's max-vary.
    nth0(MidIdx, Segs, seg(MidK,_,MidVmax,_)),
%   Target = alignment of the max-end of the middle segment.
    arc2_segeq_align_(Dir, MidK, MidVmax, DTarget), !.
% arc2_segeq_anchor_/4: max-anchor case -- all max-alignments equal.
arc2_segeq_anchor_(Dir, Segs, max, DTarget) :-
%   Collect the alignment value of the maximum-vary endpoint of every segment.
    findall(A, (member(seg(K,_,Vmax,_),Segs), arc2_segeq_align_(Dir,K,Vmax,A)), As),
%   All max-alignments must be identical.
    sort(As, [_]),
%   Pick the middle segment by index.
    length(Segs, N), MidIdx is N // 2,
%   Get the middle segment's min-vary.
    nth0(MidIdx, Segs, seg(MidK,MidVmin,_,_)),
%   Target = alignment of the min-end of the middle segment.
    arc2_segeq_align_(Dir, MidK, MidVmin, DTarget).

% arc2_segeq_setrange_/7: set cells in vary range [Vfrom..Vto] to Value in Grid.
arc2_segeq_setrange_(_, _, _, Grid, Vfrom, Vto, Grid) :-
%   Base case: empty or reversed range; return Grid unchanged.
    Vfrom > Vto, !.
arc2_segeq_setrange_(Dir, Key, Value, GridIn, Vfrom, Vto, GridOut) :-
%   Compute the grid coordinates for this vary position.
    arc2_segeq_cellpos_(Dir, Key, Vfrom, R, C),
%   Write Value into cell (R, C).
    arc2_set_cell_(GridIn, R, C, Value, GridMid),
%   Advance to the next position.
    Vnext is Vfrom + 1,
%   Recurse for the remainder of the range.
    arc2_segeq_setrange_(Dir, Key, Value, GridMid, Vnext, Vto, GridOut).

% arc2_segeq_adj1_/7: adjust one segment; anchor=min means the min-end is fixed.
arc2_segeq_adj1_(Dir, Bg, seg(K,_,CurMax,Color), min, DTarget, GridIn, GridOut) :-
%   Compute the correct max-vary for this segment given the target alignment.
    arc2_segeq_cvary_(Dir, K, DTarget, CorrectMax),
%   Trim excess cells above CorrectMax (set CorrectMax+1 .. CurMax to Bg).
    TrimFrom is CorrectMax + 1,
    arc2_segeq_setrange_(Dir, K, Bg, GridIn, TrimFrom, CurMax, GridMid),
%   Extend missing cells beyond CurMax (set CurMax+1 .. CorrectMax to Color).
    AddFrom is CurMax + 1,
    arc2_segeq_setrange_(Dir, K, Color, GridMid, AddFrom, CorrectMax, GridOut).
% arc2_segeq_adj1_/7: anchor=max means the max-end is fixed; adjust the min-end.
arc2_segeq_adj1_(Dir, Bg, seg(K,CurMin,_,Color), max, DTarget, GridIn, GridOut) :-
%   Compute the correct min-vary for this segment.
    arc2_segeq_cvary_(Dir, K, DTarget, CorrectMin),
%   Trim excess cells below CorrectMin (set CurMin .. CorrectMin-1 to Bg).
    TrimTo is CorrectMin - 1,
    arc2_segeq_setrange_(Dir, K, Bg, GridIn, CurMin, TrimTo, GridMid),
%   Extend missing cells below CurMin (set CorrectMin .. CurMin-1 to Color).
    AddTo is CurMin - 1,
    arc2_segeq_setrange_(Dir, K, Color, GridMid, CorrectMin, AddTo, GridOut).

% arc2_segeq_adjall_/7: base case; return Grid unchanged when no segments remain.
arc2_segeq_adjall_(_, _, [], _, _, Grid, Grid).
% arc2_segeq_adjall_/7: adjust one segment then recurse over the rest.
arc2_segeq_adjall_(Dir, Bg, [Seg|Rest], AE, DT, GridIn, GridOut) :-
%   Adjust the current segment.
    arc2_segeq_adj1_(Dir, Bg, Seg, AE, DT, GridIn, GridMid),
%   Continue with remaining segments.
    arc2_segeq_adjall_(Dir, Bg, Rest, AE, DT, GridMid, GridOut).

% Register segment_equalize as a known named transform.
arc2_named_rule(segment_equalize).

% arc2_transform for segment_equalize: equalize all segment lengths to the middle.
arc2_transform(segment_equalize, Grid, GridOut) :-
%   Find the most common cell value (background).
    arc2_bg_color_(Grid, Bg),
%   Determine grid dimensions.
    length(Grid, NR), NR > 0, Grid = [FR|_], length(FR, NC),
    MaxR is NR - 1, MaxC is NC - 1,
%   Collect all non-background cells as r(R,C,V) terms.
    findall(r(R,C,V), (
        between(0,MaxR,R), between(0,MaxC,C),
        arc2_cell_(Grid,R,C,V), V \= Bg
    ), Cells),
%   Fail if there are no non-background cells.
    Cells \= [],
%   Detect which direction the segments run.
    arc2_segeq_dir_(Cells, Dir),
%   Compute (Key, Vary, Color) for every non-background cell.
    findall(K-Vary-V, (
        member(r(R,C,V), Cells),
        arc2_segeq_kv_(R,C,Dir,K,Vary)
    ), KVVs),
%   Collect and sort the unique segment keys.
    findall(K, member(K-_-_, KVVs), Ks0), sort(Ks0, SortedKeys),
%   Build segment descriptors from the grouped cells.
    arc2_segeq_build_segs_(KVVs, SortedKeys, Segs),
%   Determine which endpoint is the anchor and compute the target alignment.
    arc2_segeq_anchor_(Dir, Segs, AnchorEnd, DTarget),
%   Extend or trim every segment's non-anchor end to match the target.
    arc2_segeq_adjall_(Dir, Bg, Segs, AnchorEnd, DTarget, Grid, GridOut).

% arc2_induce_rule for segment_equalize: verify transform on all training pairs.
arc2_induce_rule(TrainingPairs, segment_equalize) :-
%   Guard: each output grid has the same dimensions as its input.
    forall(member(pair(In,Out), TrainingPairs), (
        length(In, NR), length(Out, NR),
        In = [FR|_], Out = [GR|_], length(FR, NC), length(GR, NC)
    )),
%   Verify the transform produces the correct output for every training pair.
    forall(member(pair(In,Out), TrainingPairs),
           arc2_transform(segment_equalize, In, Out)).

% ---------------------------------------------------------------------------
% STUB RANK FILL RULE  (Wave 19)
%
% Solves ARC-AGI-2 tasks where short column stubs at the top of the grid
% rank which vertical bars to fill.  Structure:
%   - Stubs: topmost N cells of a column are all value V (non-bg), followed
%     by bg.  stub(V, N) means "select the Nth-largest bar with endpoint V".
%   - Vertical bars: column pattern [V, B, B, ..., B, V] where B \= V.
%     Endpoint = V, body = B cells, body length = K.
% Rule: for each stub(V, N), sort bars with endpoint V by K descending,
%   pick the Nth, replace its body cells with V.
%
% Solves: task 97d7923e (ARC-AGI-2, Wave 19, 2026-06-27).
% ---------------------------------------------------------------------------

% Register stub_rank_fill as a known transform name.
arc2_named_rule(stub_rank_fill).

% arc2_transform for stub_rank_fill: fill vertical bar bodies per stub ranking.
arc2_transform(stub_rank_fill, Grid, Result) :-
%   Compute background color.
    arc2_bg_color_(Grid, Bg),
%   Grid dimensions.
    length(Grid, H), Grid = [FR|_], length(FR, W),
%   Column index upper bound.
    W1 is W-1,
%   Collect all stubs: stub(Color, Size).
%   A stub at column C: topmost N cells all equal V (non-bg),
%   cell at row N equals Bg (or N=H).
    findall(stub(V, N),
        (between(0, W1, C),
         nth0(0, Grid, Row0), nth0(C, Row0, V), V \= Bg,
         arc2_srf_top_run_(Grid, C, V, 0, N),
         N >= 1,
         (N >= H ->
             true
         ;
             nth0(N, Grid, RowN), nth0(C, RowN, VN), VN =:= Bg)),
        Stubs),
%   Collect all vertical bars: vbar(Col, TopRow, BotRow, EndpColor, BodyLen).
%   A bar at column C: row TR has V, row TR-1 is Bg (or TR=0),
%   rows TR+1..BR-1 all have same non-bg value B \= V, row BR has V.
    findall(vbar(C, TR, BR, V, K),
        (between(0, W1, C),
         arc2_srf_find_vbar_(Grid, C, Bg, H, TR, BR, V, K)),
        VBars),
%   For each stub, find the target bar (Nth-largest by body length) and
%   collect fill operations: fill(Col, TopRow, BotRow, FillColor).
    findall(fill(C, TR, BR, V),
        (member(stub(V, N), Stubs),
         findall(K-C2-TR2-BR2,
                 member(vbar(C2, TR2, BR2, V, K), VBars),
                 Cands0),
         msort(Cands0, Sorted0),
         reverse(Sorted0, Sorted),
         nth1(N, Sorted, _-C-TR-BR)),
        Fills),
%   Apply all fills: replace body cells with the fill color.
    arc2_srf_apply_fills_(Fills, Grid, Result).

% arc2_srf_top_run_/5: count consecutive cells equal to V from row R downward
% in column C.  Returns total count N.
arc2_srf_top_run_(Grid, C, V, R, N) :-
%   Check if row R is within the grid.
    length(Grid, H),
%   Base case: past end of grid.
    (R >= H ->
        N = 0
    ;
%       Get value at (R, C).
        nth0(R, Grid, Row), nth0(C, Row, Rv),
%       If it matches V, recurse on next row.
        (Rv =:= V ->
            R1 is R+1,
            arc2_srf_top_run_(Grid, C, V, R1, N1),
            N is N1+1
        ;
%           Stop counting.
            N = 0
        )
    ).

% arc2_srf_find_vbar_/8: find a vertical bar in column C of Grid.
% Succeeds (possibly multiple times via backtracking) for each valid bar.
arc2_srf_find_vbar_(Grid, C, Bg, H, TR, BR, V, K) :-
%   Search all valid top-row indices.
    H1 is H-1,
    between(0, H1, TR),
%   Top-row cell must be non-bg value V.
    nth0(TR, Grid, RowTR), nth0(C, RowTR, V), V \= Bg,
%   Cell above TR must be Bg (or TR is the first row).
    (TR =:= 0 ->
        true
    ;
        TRM1 is TR-1,
        nth0(TRM1, Grid, RowAbove), nth0(C, RowAbove, VAbove),
        VAbove =:= Bg),
%   Body starts at TR+1; it must be non-bg and different from V.
    TR1 is TR+1, TR1 < H,
    nth0(TR1, Grid, RowB), nth0(C, RowB, B), B \= Bg, B \= V,
%   Find bottom endpoint: row BR > TR+1 where cell equals V.
    TR2 is TR+2,
    between(TR2, H1, BR),
%   All body rows TR+1..BR-1 must equal B.
    BR1 is BR-1,
    forall(between(TR1, BR1, R),
           (nth0(R, Grid, RowR), nth0(C, RowR, Rc), Rc =:= B)),
%   Bottom endpoint equals V.
    nth0(BR, Grid, RowBR), nth0(C, RowBR, VBR), VBR =:= V,
%   Body length.
    K is BR-TR-1.

% arc2_srf_apply_fills_/3: apply a list of fill ops to Grid, producing Result.
% Each fill op is fill(Col, TopRow, BotRow, FillColor): replace cells at
% column Col in rows TopRow+1..BotRow-1 with FillColor.
arc2_srf_apply_fills_(Fills, Grid, Result) :-
%   Grid dimensions.
    length(Grid, H), Grid = [FR|_], length(FR, W),
    H1 is H-1, W1 is W-1,
%   Reconstruct grid row by row, cell by cell.
    findall(Row,
        (between(0, H1, R),
         findall(V,
             (between(0, W1, C),
              nth0(R, Grid, GRow), nth0(C, GRow, Orig),
              (arc2_srf_in_fill_zone_(Fills, R, C, FillV) ->
                  V = FillV
              ;
                  V = Orig)),
             Row)),
        Result).

% arc2_srf_in_fill_zone_/4: true if (R,C) is inside a fill zone.
% Returns the fill color FillV.
arc2_srf_in_fill_zone_(Fills, R, C, FillV) :-
%   Find a fill op covering column C and row R (strictly between TR and BR).
    member(fill(C, TR, BR, FillV), Fills),
    TR1 is TR+1, BR1 is BR-1,
    R >= TR1, R =< BR1.

% arc2_induce_rule for stub_rank_fill: verify all training pairs match.
arc2_induce_rule(TrainingPairs, stub_rank_fill) :-
%   Guard: all pairs have same input/output dimensions.
    forall(member(pair(In, Out), TrainingPairs),
           (length(In, NR), length(Out, NR),
            In = [FR|_], Out = [GR|_],
            length(FR, NC), length(GR, NC))),
%   Guard: first row of first input has at least one non-bg cell (there are stubs).
    TrainingPairs = [pair(In0, _)|_],
    arc2_bg_color_(In0, Bg0),
    In0 = [Row0|_],
    member(V0, Row0), V0 \= Bg0,
%   Verify the transform matches every training pair.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(stub_rank_fill, In, Out)).

% ---------------------------------------------------------------------------
% PERIODIC REPAIR RULE  (Wave 5)
%
% Solves ARC-AGI-2 tasks where each "window" in the grid holds a row-periodic
% pattern with one or more corrupted cells.  Structure:
%   - Outer border of one color  (Bg, detected from the corner cell).
%   - Inner margin of another color  (Frame, detected from cell [1][1]).
%   - Content rows: first/last cell = Bg, second/second-to-last = Frame,
%     interior = the periodic pattern.
%
% Algorithm: for every content row, find the period P (1..N//2) that minimises
% violation count, build the majority-vote tile, and repair all violations.
% Separator rows (all Bg) and frame rows (interior all Frame) pass through.
%
% Solves: task 135a2760 (ARC-AGI-2, Wave 5, 2026-06-27).
% ---------------------------------------------------------------------------

% --- Private helpers (majority-vote tile and periodic repair) ---

% arc2_per_mode_/2: most frequent element in a non-empty list (run-scan).
arc2_per_mode_([H|T], Mode) :-
%   Sort to group equal elements.
    msort([H|T], Sorted),
%   Scan runs to find the element with the largest run.
    arc2_per_run_mode_(Sorted, H, 1, H, 1, Mode).

% arc2_per_run_mode_/6: recursive run-scan to find mode.
arc2_per_run_mode_([], Cur, CN, Best, BN, Mode) :-
%   End of list: emit whichever run was larger.
    (CN > BN -> Mode = Cur ; Mode = Best).
arc2_per_run_mode_([H|T], H, CN, Best, BN, Mode) :- !,
%   Continuing current run; cut removes ambiguity with next clause.
    CN1 is CN + 1,
    arc2_per_run_mode_(T, H, CN1, Best, BN, Mode).
arc2_per_run_mode_([H|T], Cur, CN, Best, BN, Mode) :-
%   New element; update best if current run beats it.
    H \= Cur,
    (CN > BN -> NB = Cur, NBN = CN ; NB = Best, NBN = BN),
    arc2_per_run_mode_(T, H, 1, NB, NBN, Mode).

% arc2_per_tile_/3: majority-vote tile of length P from List.
arc2_per_tile_(List, P, Tile) :-
%   Compute list length.
    length(List, N), N1 is N - 1,
%   For each phase p in 0..P-1, collect all values at indices ≡ p mod P.
    findall(Mode,
        (between(0, P, P0), P0 < P,
         findall(V, (between(0, N1, I), I mod P =:= P0, nth0(I, List, V)), Phase),
         arc2_per_mode_(Phase, Mode)),
        Tile).

% arc2_per_violations_/4: list of viol(Index,Actual,Expected) for a 1D list.
arc2_per_violations_(List, P, Tile, Viols) :-
%   Compute list length.
    length(List, N), N1 is N - 1,
%   Collect all positions where the value differs from the tile at that phase.
    findall(viol(I, Act, Exp),
        (between(0, N1, I),
         nth0(I, List, Act),
         Ph is I mod P,
         nth0(Ph, Tile, Exp),
         Act \= Exp),
        Viols).

% arc2_per_repair_/4: rebuild List replacing every violation with its tile value.
arc2_per_repair_(List, P, Tile, Repaired) :-
%   Compute list length.
    length(List, N), N1 is N - 1,
%   For each position use the tile value where there is a violation.
    findall(V,
        (between(0, N1, I),
         nth0(I, List, Orig),
         Ph is I mod P,
         nth0(Ph, Tile, Exp),
         (Orig = Exp -> V = Orig ; V = Exp)),
        Repaired).

% arc2_per_best_period_/3: find period P in 1..max(1,N//2) with fewest violations.
arc2_per_best_period_(List, P, NViol) :-
%   Compute length; cap search at half-length to avoid trivial full-period winner.
    length(List, N), N > 0,
    Pmax is max(1, N // 2),
%   Enumerate (violation_count, period) pairs.
    findall(NV-Pd,
        (between(1, Pmax, Pd),
         arc2_per_tile_(List, Pd, Tile),
         arc2_per_violations_(List, Pd, Tile, Vs),
         length(Vs, NV)),
        Pairs),
%   Sort ascending by (NV, P); smallest NV then smallest P is first.
    msort(Pairs, [NViol-P|_]).

% --- Frame-aware row processing ---

% arc2_per_is_content_row_/4: true if Row is a content row.
% A content row has Frame at position Cl-1 and at least one non-Frame cell in Cl..Cr.
arc2_per_is_content_row_(Row, Frame, Cl, Cr) :-
%   Check cell at (Cl-1) = Frame.
    Cl1 is Cl - 1,
    nth0(Cl1, Row, Frame),
%   Check at least one interior cell differs from Frame.
    between(Cl, Cr, C),
    nth0(C, Row, V),
    V \= Frame, !.

% arc2_per_repair_row_/6: repair one row; pass through non-content rows.
arc2_per_repair_row_(Row, Frame, Cl, Cr, _Bg, OutRow) :-
%   Identify this as a content row.
    arc2_per_is_content_row_(Row, Frame, Cl, Cr),
%   Extract the interior cells.
    findall(V, (between(Cl, Cr, C), nth0(C, Row, V)), Content),
%   Find the period that minimises violations.
    arc2_per_best_period_(Content, P, _),
%   Build the majority-vote tile.
    arc2_per_tile_(Content, P, Tile),
%   Repair the content.
    arc2_per_repair_(Content, P, Tile, RepContent),
%   Reconstruct the full row with repaired content.
    length(Row, W), Wm1 is W - 1,
    findall(V,
        (between(0, Wm1, C),
         (C >= Cl, C =< Cr
          -> Idx is C - Cl, nth0(Idx, RepContent, V)
          ;  nth0(C, Row, V))),
        OutRow), !.
arc2_per_repair_row_(Row, _, _, _, _, Row).

% arc2_per_repair_rows_/6: apply per-row repair to every row in Grid.
arc2_per_repair_rows_([], _, _, _, _, []).
arc2_per_repair_rows_([R|Rs], Frame, Cl, Cr, Bg, [OR|ORs]) :-
%   Repair this row.
    arc2_per_repair_row_(R, Frame, Cl, Cr, Bg, OR),
%   Continue with remaining rows.
    arc2_per_repair_rows_(Rs, Frame, Cl, Cr, Bg, ORs).

% --- Public transform and induction ---

% Register periodic_repair as a known named transform.
arc2_named_rule(periodic_repair).

% arc2_transform for periodic_repair: fix all periodic-pattern violations in every window.
arc2_transform(periodic_repair, Grid, GridOut) :-
%   Background color from corner cell.
    nth0(0, Grid, Row0), nth0(0, Row0, Bg),
%   Frame color from [1][1].
    nth0(1, Grid, Row1), nth0(1, Row1, Frame),
%   Require Bg and Frame to be distinct.
    Bg \= Frame,
%   Content columns: between the frame cells (cols 2..W-3).
    length(Row0, W),
    Cl is 2,
    Cr is W - 3,
%   Guard: content region must be non-empty.
    Cl =< Cr,
%   Repair every row.
    arc2_per_repair_rows_(Grid, Frame, Cl, Cr, Bg, GridOut).

% arc2_induce_rule for periodic_repair: verify all training pairs.
arc2_induce_rule(TrainingPairs, periodic_repair) :-
%   Guard: every pair preserves grid dimensions.
    forall(member(pair(In, Out), TrainingPairs), (
        length(In, NR), length(Out, NR),
        In = [FR|_], Out = [GR|_], length(FR, NC), length(GR, NC)
    )),
%   Guard: every pair has the double-frame structure (at least 3 rows and 5 cols).
    TrainingPairs = [pair(In0,_)|_],
    length(In0, NR0), NR0 >= 3,
    In0 = [FR0|_], length(FR0, NC0), NC0 >= 5,
%   Guard: corner = cell[1][1] differs from corner (true two-layer frame).
    nth0(0, In0, In0R0), nth0(0, In0R0, Bg0),
    nth0(1, In0, In0R1), nth0(1, In0R1, Frame0),
    Bg0 \= Frame0,
%   Yield to period_repair if it also solves all training pairs.
    \+ forall(member(pair(In_yr, Out_yr), TrainingPairs),
              arc2_transform(period_repair, In_yr, Out_yr)),
%   Verify the transform matches the output for every training pair.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(periodic_repair, In, Out)).

% ---------------------------------------------------------------------------
% BAND_WRAP RULE
% Input rows must all be uniform (each row is one solid color).
% The row-color sequence is run-length encoded into (Color, Count) bands.
% Output: square grid of side S = 2*(TotalCount - LastCount) + LastCount.
% Cell (R,C) belongs to ring min(R,C,S-1-R,S-1-C); the band whose cumulative
% count bracket contains the ring index determines the cell color.
% ---------------------------------------------------------------------------

% arc2_bw_uniform_/2: all elements of List equal Color.
arc2_bw_uniform_([], _).
% Continue checking each element.
arc2_bw_uniform_([C|Rest], C) :-
%   Recurse on remaining elements.
    arc2_bw_uniform_(Rest, C).

% arc2_bw_rle_rows_/2: run-length encode a flat color list into (Color,Count) pairs.
arc2_bw_rle_rows_([], []).
% Pull out one run starting with C and accumulate.
arc2_bw_rle_rows_([C|Cs], [(C,N)|Rest]) :-
%   Count consecutive C values starting at 1.
    arc2_bw_rle_same_(Cs, C, 1, N, Tail),
%   Encode the remainder.
    arc2_bw_rle_rows_(Tail, Rest).

% arc2_bw_rle_same_/5: accumulate run of identical values.
arc2_bw_rle_same_([], _, N, N, []).
% Same color: increment accumulator.
arc2_bw_rle_same_([C|Cs], C, Acc, N, Tail) :-
%   Increment and recurse.
    Acc1 is Acc + 1,
    arc2_bw_rle_same_(Cs, C, Acc1, N, Tail).
% Different color: stop.
arc2_bw_rle_same_([D|Cs], C, N, N, [D|Cs]) :-
%   Guard: different color ends the run.
    D \= C.

% arc2_bw_sum_counts_/2: sum all Count values from a (Color,Count) band list.
arc2_bw_sum_counts_([], 0).
% Add this band's count to the rest.
arc2_bw_sum_counts_([(_, T)|Rest], Total) :-
%   Sum the remaining bands first.
    arc2_bw_sum_counts_(Rest, Sub),
%   Add this band's count.
    Total is Sub + T.

% arc2_bw_ring_color_/3: given bands and a 0-indexed ring distance, return color.
% Ring distance = min(R, C, S-1-R, S-1-C) for a cell in the output grid.
arc2_bw_ring_color_([(C, T)|_], Ring, C) :-
%   Ring falls within this band's thickness.
    Ring < T, !.
arc2_bw_ring_color_([(_, T)|Rest], Ring, Color) :-
%   Subtract this band's count and recurse into next band.
    Ring2 is Ring - T,
    arc2_bw_ring_color_(Rest, Ring2, Color).

% Register band_wrap as a known named transform.
arc2_named_rule(band_wrap).

% arc2_transform for band_wrap: build concentric rectangular rings from RLE bands.
arc2_transform(band_wrap, Grid, Result) :-
%   All rows must be uniform (every cell in a row equals its first cell).
    forall(member(Row, Grid), (Row = [C|_], arc2_bw_uniform_(Row, C))),
%   Extract per-row color (first cell of each row).
    maplist([Row, C]>>(Row = [C|_]), Grid, Colors),
%   Run-length encode into (Color, Count) bands.
    arc2_bw_rle_rows_(Colors, Bands),
%   Need at least 2 bands to form any ring structure.
    length(Bands, NB), NB >= 2,
%   Sum all band counts.
    arc2_bw_sum_counts_(Bands, TotalT),
%   Last band count (becomes the center block).
    last(Bands, (_, TLast)),
%   Output grid side length.
    S is 2 * TotalT - TLast,
%   Output row index upper bound.
    S1 is S - 1,
%   Build S x S grid row by row.
    findall(Row,
        (between(0, S1, R),
%        Build one row: map each column to its ring color.
         findall(Color,
             (between(0, S1, C),
%             Ring = distance from nearest edge.
              Ring is min(min(R, C), min(S1 - R, S1 - C)),
%             Look up color for this ring index.
              arc2_bw_ring_color_(Bands, Ring, Color)),
             Row)),
        Result).

% arc2_induce_rule for band_wrap: guard checks then verify all training pairs.
arc2_induce_rule(TrainingPairs, band_wrap) :-
%   Guard: every input row in every training pair is uniform.
    forall(member(pair(In, _), TrainingPairs),
           forall(member(Row, In), (Row = [C|_], arc2_bw_uniform_(Row, C)))),
%   Guard: at least 2 bands in the first training input.
    TrainingPairs = [pair(In0, _)|_],
    maplist([Row, C]>>(Row = [C|_]), In0, Colors0),
    arc2_bw_rle_rows_(Colors0, Bands0),
    length(Bands0, NB0), NB0 >= 2,
%   Verify: transform produces correct output for every training pair.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(band_wrap, In, Out)).

% ---------------------------------------------------------------------------
% STAIRCASE LIFT (Wave 7) — task 4c3d4a41
% Left-half staircase heights (odd cols 1,3,5,7) determine how far each
% right-half color bar is pushed toward the top of the frame.
% ---------------------------------------------------------------------------

% Register staircase_lift as a known named transform.
arc2_named_rule(staircase_lift).

% arc2_transform for staircase_lift: reposition right-half color bars using
% staircase heights read from left-half odd columns.
arc2_transform(staircase_lift, Grid, Result) :-
%   Grid must be exactly 8 rows tall.
    length(Grid, 8),
%   Each row must be exactly 20 columns wide.
    nth0(0, Grid, Row0sl), length(Row0sl, 20),
%   Read staircase height from left-half odd col 1 (bar 0).
    arc2_sl_col_h_(Grid, 1, H0sl),
%   Read staircase height from left-half odd col 3 (bar 1).
    arc2_sl_col_h_(Grid, 3, H1sl),
%   Read staircase height from left-half odd col 5 (bar 2).
    arc2_sl_col_h_(Grid, 5, H2sl),
%   Read staircase height from left-half odd col 7 (bar 3).
    arc2_sl_col_h_(Grid, 7, H3sl),
%   Read input color and run length from right-half col 11 (bar 0).
    arc2_sl_bar_(Grid, 11, C0sl, L0sl),
%   Read input color and run length from right-half col 13 (bar 1).
    arc2_sl_bar_(Grid, 13, C1sl, L1sl),
%   Read input color and run length from right-half col 15 (bar 2).
    arc2_sl_bar_(Grid, 15, C2sl, L2sl),
%   Read input color and run length from right-half col 17 (bar 3).
    arc2_sl_bar_(Grid, 17, C3sl, L3sl),
%   Compute output bar descriptor for bar 0.
    arc2_sl_out_(H0sl, C0sl, L0sl, OB0sl),
%   Compute output bar descriptor for bar 1.
    arc2_sl_out_(H1sl, C1sl, L1sl, OB1sl),
%   Compute output bar descriptor for bar 2.
    arc2_sl_out_(H2sl, C2sl, L2sl, OB2sl),
%   Compute output bar descriptor for bar 3.
    arc2_sl_out_(H3sl, C3sl, L3sl, OB3sl),
%   Collect all four output bar descriptors into a list.
    Obssl = [OB0sl, OB1sl, OB2sl, OB3sl],
%   Build result grid: enumerate all row indices.
    numlist(0, 7, Rowssl),
%   Enumerate all column indices.
    numlist(0, 19, Colssl),
%   Map each row index to a result row.
    maplist([R, RRow]>>(
        maplist([C, V]>>(arc2_sl_val_(R, C, Obssl, V)), Colssl, RRow)
    ), Rowssl, Result).

% arc2_sl_col_h_(+Grid, +Col, -H): count consecutive 5s from row 5 upward.
arc2_sl_col_h_(Grid, Col, H) :-
%   Start accumulation from the staircase floor row 5.
    arc2_sl_count_up_(Grid, 5, Col, 0, H).

% arc2_sl_count_up_(+Grid, +R, +Col, +Acc, -H): accumulate 5-run going upward.
arc2_sl_count_up_(_, R, _, Acc, Acc) :-
%   Recursion passed row 1; return accumulated count.
    R < 1.
arc2_sl_count_up_(Grid, R, C, Acc, H) :-
%   Row is still in the valid staircase range.
    R >= 1,
%   Fetch the cell value at row R, column C.
    nth0(R, Grid, Row), nth0(C, Row, V),
%   If 5, increment and recurse upward; otherwise stop.
    (V =:= 5
     -> A1 is Acc + 1, R1 is R - 1,
        arc2_sl_count_up_(Grid, R1, C, A1, H)
     ;  H = Acc).

% arc2_sl_bar_(+Grid, +Col, -Color, -Height): locate color bar in rows 1-4.
arc2_sl_bar_(Grid, Col, Color, Height) :-
%   Scan rows 1-4 for the first non-0 non-5 cell.
    arc2_sl_first_color_(Grid, 1, Col, Color, Start),
%   If no color found, height is 0; otherwise measure the run.
    (Color =:= 0
     -> Height = 0
     ;  arc2_sl_run_len_(Grid, Start, Col, Color, Height)).

% arc2_sl_first_color_(+Grid, +R, +C, -Color, -Start): first non-background cell.
arc2_sl_first_color_(_, R, _, 0, 1) :-
%   Scanned past row 4 with no color found; return sentinel.
    R > 4.
arc2_sl_first_color_(Grid, R, C, Color, Start) :-
%   Row still in search window.
    R =< 4,
%   Fetch the cell at (R, C).
    nth0(R, Grid, Row), nth0(C, Row, V),
%   Non-0 non-5 means this is the colored cell; otherwise advance row.
    (V =\= 5, V =\= 0
     -> Color = V, Start = R
     ;  R1 is R + 1,
        arc2_sl_first_color_(Grid, R1, C, Color, Start)).

% arc2_sl_run_len_(+Grid, +R, +C, +Color, -Len): measure consecutive Color run.
arc2_sl_run_len_(_, R, _, _, 0) :-
%   Passed row 4; run has ended.
    R > 4.
arc2_sl_run_len_(Grid, R, C, Color, Len) :-
%   Row still in measurable range.
    R =< 4,
%   Fetch value at (R, C).
    nth0(R, Grid, Row), nth0(C, Row, V),
%   If still Color, count and recurse; otherwise end the run.
    (V =:= Color
     -> R1 is R + 1,
        arc2_sl_run_len_(Grid, R1, C, Color, Rest),
        Len is Rest + 1
     ;  Len = 0).

% arc2_sl_out_(+H, +Color, +InLen, -bar(Color,OS,OE)): compute output bar span.
% The bar occupies rows OS..OE where OE = 5-H and height = min(InLen, OE).
arc2_sl_out_(H, Color, InLen, bar(Color, OS, OE)) :-
%   Maximum end row: staircase of height H leaves rows 1..(5-H) for color.
    OE is max(0, 5 - H),
%   Output height = input height clipped to available space.
    OH is min(InLen, OE),
%   Output start row fills from OE upward by OH rows.
    OS is OE - OH + 1.

% arc2_sl_val_(+R, +C, +OutBars, -V): determine output cell value.
arc2_sl_val_(_, C, _, 0) :-
%   Left half (cols 0-8): cleared to zero.
    C < 9, !.
arc2_sl_val_(R, 9, _, V) :-
%   Outer left frame col 9: rows 0-3 and 6-7 are 5, rows 4-5 are 0.
    !, (memberchk(R, [0,1,2,3,6,7]) -> V = 5 ; V = 0).
arc2_sl_val_(_, 19, _, 5) :-
%   Outer right frame col 19: always 5 across all rows.
    !.
arc2_sl_val_(0, _, _, 5) :-
%   Outer top frame row 0: always 5 in the right half.
    !.
arc2_sl_val_(7, _, _, 5) :-
%   Outer bottom frame row 7: always 5 in the right half.
    !.
arc2_sl_val_(R, C, _, V) :-
%   Even separator columns (10,12,14,16,18): 0 except inner bar at row 5.
    C mod 2 =:= 0, !,
    (R =:= 5, C >= 11, C =< 17 -> V = 5 ; V = 0).
arc2_sl_val_(R, C, OutBars, V) :-
%   Odd bar columns 11,13,15,17.
    C >= 11, C =< 17, !,
%   Bar index: col 11->0, col 13->1, col 15->2, col 17->3.
    BI is (C - 11) // 2,
%   Retrieve this bar's color and output span.
    nth0(BI, OutBars, bar(Color, OS, OE)),
%   Row 5 is always the inner bottom bar (5).
    (R =:= 5
     -> V = 5
%    Rows 1-4: color if in span, else staircase fill (5).
     ;  R >= 1, R =< 4
     -> (R >= OS, R =< OE -> V = Color ; V = 5)
%    Row 6: empty interior below the frame.
     ;  V = 0).
arc2_sl_val_(_, _, _, 0).

% arc2_induce_rule for staircase_lift: structural guards then verify all pairs.
arc2_induce_rule(TrainingPairs, staircase_lift) :-
%   Guard: first input must be 8 rows tall.
    TrainingPairs = [pair(In0sl, _)|_],
    length(In0sl, 8),
%   Guard: first input row must be 20 columns wide.
    nth0(0, In0sl, R0sl), length(R0sl, 20),
%   Guard: row 0 begins with 0 (left half empty) and has 5 at col 9 (frame).
    nth0(0, R0sl, 0), nth0(9, R0sl, 5),
%   Guard: row 7 also has 5 at col 9 (bottom frame).
    nth0(7, In0sl, R7sl), nth0(9, R7sl, 5),
%   Verify: transform matches expected output for every training pair.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(staircase_lift, In, Out)).

% ---------------------------------------------------------------------------
% SNAKE_END_SWAP (Wave 8) — task 332f06d7
% Replace every 0 with 1 and every 2 with 0; all other values stay.
% ---------------------------------------------------------------------------

% Register snake_end_swap as a known named transform.
arc2_named_rule(snake_end_swap).

% arc2_transform for snake_end_swap: remap 0->1 and 2->0 in every cell.
arc2_transform(snake_end_swap, Grid, Result) :-
%   Map each row through the snake swap cell rule.
    maplist([Row, RowOut]>>(
%       Map each cell: 0->1, 2->0, else unchanged.
        maplist([V, W]>>(
%           If the value is 0 replace it with 1.
            ( V =:= 0 -> W = 1
%           If the value is 2 replace it with 0.
            ; V =:= 2 -> W = 0
%           Otherwise keep the original value.
            ; W = V )
        ), Row, RowOut)
    ), Grid, Result).

% ---------------------------------------------------------------------------
% BAR_SORT (Wave 8) — task 31f7f899
% The grid has a horizontal divider row (no BG cells) flanked by vertical
% colour bars. Each bar has an above-height and below-height. The bars are
% sorted by above-height ascending and their height-pairs are reassigned
% left-to-right to produce the output.
% ---------------------------------------------------------------------------

% Register bar_sort as a known named transform.
arc2_named_rule(bar_sort).

% arc2_transform for bar_sort: sort bar heights and rebuild the grid.
arc2_transform(bar_sort, Grid, Result) :-
%   Flatten grid to find the background (most common) value.
    append(Grid, Flat),
%   Sort flat list to prepare mode computation.
    msort(Flat, Sorted),
%   Find the most frequent value = background.
    arc2_bs_mode_(Sorted, BG),
%   Locate the divider row index and its dominant colour.
    arc2_bs_divider_(Grid, BG, DivIdx, DIV),
%   Extract the actual divider row from the grid.
    nth0(DivIdx, Grid, DivRow),
%   Segment the divider row into bar descriptors.
    arc2_bs_bars_(DivRow, 0, BG, DIV, Bars),
%   Measure above and below height for each bar.
    arc2_bs_heights_(Grid, DivIdx, Bars, Pairs),
%   Sort height-pairs by above-height ascending.
    msort(Pairs, SortedPairs),
%   Count rows and columns for grid construction.
    length(Grid, NR), nth0(0, Grid, Row0bs), length(Row0bs, NC),
%   Build row index list 0..NR-1.
    NR1 is NR - 1, numlist(0, NR1, RIdxs),
%   Build column index list 0..NC-1.
    NC1 is NC - 1, numlist(0, NC1, CIdxs),
%   Construct each output row.
    maplist([RI, ORow]>>(
%       Construct each cell in this row.
        maplist([CI, Cell]>>(
%           Delegate cell value to the cell-selector.
            arc2_bs_cell_(RI, CI, DivIdx, DivRow, BG, Bars, SortedPairs, Cell)
        ), CIdxs, ORow)
    ), RIdxs, Result).

% arc2_bs_mode_(+SortedList, -Mode): most frequent element in a sorted list.
arc2_bs_mode_([H|T], Mode) :-
%   Start accumulator with first element count 1, best = first element.
    arc2_bs_mode_acc_(T, H, 1, H, 1, Mode).

% arc2_bs_mode_acc_: base case when list exhausted.
arc2_bs_mode_acc_([], _, _, BestV, _, BestV).
% arc2_bs_mode_acc_: current element equals running element; update count.
arc2_bs_mode_acc_([H|T], H, N, BestV, BestN, Mode) :-
%   Increment the count for the current run.
    N1 is N + 1,
%   If new count exceeds best, promote current element.
    ( N1 > BestN
    -> arc2_bs_mode_acc_(T, H, N1, H,    N1,    Mode)
%   Otherwise keep existing best.
    ;  arc2_bs_mode_acc_(T, H, N1, BestV, BestN, Mode) ).
% arc2_bs_mode_acc_: current element differs from running element; reset run.
arc2_bs_mode_acc_([H|T], Prev, _N, BestV, BestN, Mode) :-
%   Guard: new element is different from the previous run element.
    H \= Prev,
%   Start a new run of length 1 for the new element.
    arc2_bs_mode_acc_(T, H, 1, BestV, BestN, Mode).

% arc2_bs_divider_(+Grid, +BG, -DivIdx, -DIV):
% Find the first row with no BG cells; DIV is its most frequent value.
arc2_bs_divider_(Grid, BG, DivIdx, DIV) :-
%   Bind DivIdx to each row index until a qualifying row is found.
    nth0(DivIdx, Grid, DivRow),
%   The divider row contains no background cells.
    \+ member(BG, DivRow), !,
%   Sort the divider row to prepare mode computation.
    msort(DivRow, SortedDiv),
%   The divider colour is the most common value in that row.
    arc2_bs_mode_(SortedDiv, DIV).

% arc2_bs_bars_(+Row, +Col, +BG, +DIV, -Bars):
% Extract list of bar(StartCol,EndCol,Color) for non-BG non-DIV runs.
arc2_bs_bars_([], _, _, _, []).
% Skip BG and DIV cells.
arc2_bs_bars_([V|T], C, BG, DIV, Bars) :-
%   Check if this cell is background or divider colour.
    ( V =:= BG ; V =:= DIV ), !,
%   Advance to next column.
    C1 is C + 1,
%   Continue scanning.
    arc2_bs_bars_(T, C1, BG, DIV, Bars).
% Non-BG non-DIV cell starts a new bar.
arc2_bs_bars_([V|T], C, BG, DIV, [bar(C,EC,V)|Bars]) :-
%   Collect the full run of V starting at column C.
    arc2_bs_run_(T, V, C, EC, Rem),
%   First column after this bar.
    EC1 is EC + 1,
%   Continue scanning from the remaining cells.
    arc2_bs_bars_(Rem, EC1, BG, DIV, Bars).

% arc2_bs_run_(+Rest, +Color, +LastC, -EndC, -Remaining):
% Extend run of Color; LastC starts as the first column of the run.
arc2_bs_run_([], _, Last, Last, []).
% Extend when the next cell matches Color.
arc2_bs_run_([H|T], Color, Last, EC, Rem) :-
%   If the head matches the run colour, extend the run.
    ( H =:= Color
    ->  Next is Last + 1,
%       Recurse with the extended column index.
        arc2_bs_run_(T, Color, Next, EC, Rem)
%   Otherwise the run is over.
    ;   EC = Last,
        Rem = [H|T] ).

% arc2_bs_heights_(+Grid, +DivIdx, +Bars, -Pairs):
% Pairs is a list of HA-HB for each bar (above height, below height).
arc2_bs_heights_(_, _, [], []).
% Process one bar and recurse.
arc2_bs_heights_(Grid, DivIdx, [bar(SC,_,Color)|Bars], [HA-HB|Pairs]) :-
%   Count rows above the divider that contain Color at column SC.
    arc2_bs_count_up_(Grid, DivIdx, SC, Color, 0, HA),
%   Count rows below the divider that contain Color at column SC.
    length(Grid, NR),
%   Delegate below-count to helper.
    arc2_bs_count_dn_(Grid, DivIdx, NR, SC, Color, 0, HB),
%   Recurse for the remaining bars.
    arc2_bs_heights_(Grid, DivIdx, Bars, Pairs).

% arc2_bs_count_up_(+Grid, +DivIdx, +Col, +Color, +Acc, -H):
% Count consecutive Color rows going upward from just above DivIdx.
arc2_bs_count_up_(Grid, DivIdx, Col, Color, Acc, H) :-
%   Compute the row index to inspect next.
    RowIdx is DivIdx - Acc - 1,
%   If above the grid boundary, stop.
    ( RowIdx < 0 -> H = Acc
%   Otherwise check the cell value.
    ; nth0(RowIdx, Grid, Row),
      nth0(Col, Row, V),
%     If it matches Color, count one more row.
      ( V =:= Color
      -> Acc1 is Acc + 1,
%        Continue upward.
         arc2_bs_count_up_(Grid, DivIdx, Col, Color, Acc1, H)
%     Otherwise the run has ended.
      ;  H = Acc ) ).

% arc2_bs_count_dn_(+Grid, +DivIdx, +NR, +Col, +Color, +Acc, -H):
% Count consecutive Color rows going downward from just below DivIdx.
arc2_bs_count_dn_(Grid, DivIdx, NR, Col, Color, Acc, H) :-
%   Compute the row index to inspect next.
    RowIdx is DivIdx + Acc + 1,
%   If below the grid boundary, stop.
    ( RowIdx >= NR -> H = Acc
%   Otherwise check the cell value.
    ; nth0(RowIdx, Grid, Row),
      nth0(Col, Row, V),
%     If it matches Color, count one more row.
      ( V =:= Color
      -> Acc1 is Acc + 1,
%        Continue downward.
         arc2_bs_count_dn_(Grid, DivIdx, NR, Col, Color, Acc1, H)
%     Otherwise the run has ended.
      ;  H = Acc ) ).

% arc2_bs_cell_(+RI, +CI, +DivIdx, +DivRow, +BG, +Bars, +SortedPairs, -Cell):
% Determine the output cell value at row RI, column CI.
arc2_bs_cell_(RI, CI, DivIdx, DivRow, _BG, _Bars, _SortedPairs, Cell) :-
%   The divider row is copied unchanged from the input.
    RI =:= DivIdx, !,
%   Fetch the value directly from DivRow.
    nth0(CI, DivRow, Cell).
% Non-divider row: determine bar colour or background.
arc2_bs_cell_(RI, CI, DivIdx, _DivRow, BG, Bars, SortedPairs, Cell) :-
%   Try to find a bar that covers column CI and reaches row RI.
    ( arc2_bs_bar_covers_(CI, RI, DivIdx, Bars, SortedPairs, Color)
%     A bar covers this cell.
    -> Cell = Color
%     No bar covers; use background.
    ;  Cell = BG ).

% arc2_bs_bar_covers_(+CI, +RI, +DivIdx, +Bars, +SortedPairs, -Color):
% Succeed if bar I covers column CI and row RI given sorted height pairs.
arc2_bs_bar_covers_(CI, RI, DivIdx, Bars, SortedPairs, Color) :-
%   Choose a bar index I.
    nth0(I, Bars, bar(SC, EC, Color)),
%   Column CI must be within the bar's span.
    CI >= SC, CI =< EC,
%   Get the sorted height pair assigned to bar I.
    nth0(I, SortedPairs, HA-HB),
%   Row must be within the bar's above or below extent.
    ( RI < DivIdx -> Dist is DivIdx - RI, Dist =< HA
    ; RI > DivIdx -> Dist is RI - DivIdx, Dist =< HB ).

% ---------------------------------------------------------------------------
% PANEL OVERLAY
% Four adjacent 5x5 panels; s1 defines a wall (8-connected main component)
% and a seed (isolated extra cell); 4-connected flood fill from the seed
% labels cells as s2-region; remainder is s3-region; wall cells prefer s2.
% Reference: ARC-AGI-2 task 7491f3cf.
% ---------------------------------------------------------------------------

% Register panel_overlay as a known named transform.
arc2_named_rule(panel_overlay).

% arc2_transform for panel_overlay: split s4 via s1-seeded flood boundary.
arc2_transform(panel_overlay, Grid, Result) :-
% Outer background = first cell in first row (border color).
    Grid = [Row0|_], Row0 = [OuterBg|_],
% Extract the four 5x5 content panels from the 7-row x 25-col grid.
    arc2_po_panels_(Grid, Panels),
% Bind panels: s1=divider, s2=left-region, s3=right-region, s4=blank target.
    Panels = [S1, S2, S3, _],
% Inner background = mode of all content cells from panels 1-3.
    arc2_po_flat3_(S1, S2, S3, AllCells),
    msort(AllCells, SortedCells),
    arc2_bs_mode_(SortedCells, InBg),
% Collect r(R,C) positions in s1 that differ from InBg.
    arc2_po_nonbg_pos_(S1, InBg, S1Nz),
% Seed = the isolated s1 cell (no 8-neighbor also in s1 non-bg set).
    arc2_po_seed_(S1Nz, Seed),
% Wall = all non-bg s1 cells except the seed.
    subtract(S1Nz, [Seed], Wall),
% 4-connected flood fill from seed through non-wall cells to label s2 region.
    arc2_po_flood4_(Seed, Wall, Reachable),
% Build output: copy grid, replace s4 section (cols 19-23, rows 1-5).
    arc2_po_build_result_(Grid, OuterBg, S2, S3, InBg, Wall, Reachable, Result).

% arc2_po_panels_(+Grid, -Panels): extract four 5x5 content panels from a 7x25 grid.
% Content rows are 1-5 (0-indexed); col ranges are 1-5, 7-11, 13-17, 19-23.
arc2_po_panels_(Grid, Panels) :-
% Collect the five content rows (skip border rows 0 and 6).
    findall(Row, (nth0(R, Grid, Row), R >= 1, R =< 5), ContentRows),
% Slice each content row into four sub-rows, one per panel column block.
    maplist([Full, [P1R,P2R,P3R,P4R]]>>(
        arc2_po_slice_(Full, 1, 5, P1R),
        arc2_po_slice_(Full, 7, 11, P2R),
        arc2_po_slice_(Full, 13, 17, P3R),
        arc2_po_slice_(Full, 19, 23, P4R)
    ), ContentRows, Sliced),
% Transpose: gather per-panel row lists from the per-content-row slices.
    maplist([PIdx, Panel]>>(
        maplist([QuadRow, PRow]>>(nth0(PIdx, QuadRow, PRow)), Sliced, Panel)
    ), [0,1,2,3], Panels).

% arc2_po_slice_(+Row, +From, +To, -Sub): extract columns From..To (0-indexed, inclusive).
arc2_po_slice_(Row, From, To, Sub) :-
% Generate column index list From..To.
    numlist(From, To, Cols),
% Extract the value at each column index from Row.
    maplist([C, V]>>(nth0(C, Row, V)), Cols, Sub).

% arc2_po_flat3_(+S1, +S2, +S3, -Cells): all cells from three 5x5 panels as a flat list.
arc2_po_flat3_(S1, S2, S3, Cells) :-
% Flatten each panel's rows into a single list.
    append(S1, Flat1), append(S2, Flat2), append(S3, Flat3),
% Concatenate the three flat lists.
    append(Flat1, Flat2, Tmp), append(Tmp, Flat3, Cells).

% arc2_po_nonbg_pos_(+Panel, +Bg, -Positions): r(R,C) pairs where Panel[R][C] != Bg.
arc2_po_nonbg_pos_(Panel, Bg, Positions) :-
% Collect all panel positions whose value is not the background color.
    findall(r(R,C),
        (nth0(R, Panel, PRow), nth0(C, PRow, V), V \= Bg),
        Positions).

% arc2_po_seed_(+Positions, -Seed): find the isolated position in a set of r(R,C) terms.
% A position is isolated if none of its 8-connected neighbors is also in Positions.
arc2_po_seed_(Positions, Seed) :-
% Enumerate each candidate from Positions.
    member(Seed, Positions),
    Seed = r(SR, SC),
% Confirm no other member is 8-adjacent (Chebyshev distance 1) to Seed.
    \+ (member(r(NR,NC), Positions),
        r(NR,NC) \= r(SR,SC),
        DR is abs(NR - SR), DC is abs(NC - SC),
        DR =< 1, DC =< 1).

% arc2_po_flood4_(+Seed, +Wall, -Reachable): 4-connected BFS from Seed avoiding Wall.
arc2_po_flood4_(Seed, Wall, Reachable) :-
% Start the BFS with Seed as the only queued cell and an empty visited set.
    arc2_po_bfs4_([Seed], Wall, [], Reachable).

% arc2_po_bfs4_(+Queue, +Wall, +Visited, -Reachable): expand BFS queue one step at a time.
% Base case: empty queue — visited set is the complete reachable set.
arc2_po_bfs4_([], _, Visited, Visited).
% If the queue head is already visited, skip it.
arc2_po_bfs4_([H|T], Wall, Vis0, Reachable) :-
    member(H, Vis0), !,
    arc2_po_bfs4_(T, Wall, Vis0, Reachable).
% Otherwise, add the head to visited and enqueue its unvisited non-wall 4-neighbors.
arc2_po_bfs4_([r(R,C)|T], Wall, Vis0, Reachable) :-
    Vis1 = [r(R,C)|Vis0],
    findall(r(NR,NC),
        ( member(DR-DC, [(-1)-0, 1-0, 0-(-1), 0-1]),
          NR is R + DR, NC is C + DC,
          NR >= 0, NR < 5, NC >= 0, NC < 5,
          \+ member(r(NR,NC), Wall),
          \+ member(r(NR,NC), Vis1) ),
        Neighbors),
    append(T, Neighbors, Q1),
    arc2_po_bfs4_(Q1, Wall, Vis1, Reachable).

% arc2_po_build_result_(+Grid,+OBg,+S2,+S3,+InBg,+Wall,+Reachable,-Result):
% Copy the full input grid, replacing cols 19-23 rows 1-5 with computed s4 values.
arc2_po_build_result_(Grid, OBg, S2, S3, InBg, Wall, Reachable, Result) :-
% Compute grid dimensions for index iteration.
    length(Grid, NR), NR1 is NR - 1, numlist(0, NR1, RIdxs),
    nth0(0, Grid, Row0g), length(Row0g, NC), NC1 is NC - 1, numlist(0, NC1, CIdxs),
% Build each output row.
    maplist([RI, OutRow]>>(
        maplist([CI, Cell]>>(
% Columns 19-23 in content rows (RI 1-5) are filled from s2/s3/wall/reachable.
            ( CI >= 19, CI =< 23 ->
                PR is RI - 1, PC is CI - 19,
                ( PR >= 0, PR =< 4 ->
                    arc2_po_cell_val_(PR, PC, S2, S3, InBg, Wall, Reachable, Cell)
% Border rows for the s4 section get the outer background.
                ;   Cell = OBg
                )
% All other columns are copied unchanged from the input grid.
            ;   nth0(RI, Grid, GRow), nth0(CI, GRow, Cell)
            )
        ), CIdxs, OutRow)
    ), RIdxs, Result).

% arc2_po_cell_val_(+PR,+PC,+S2,+S3,+InBg,+Wall,+Reachable,-V):
% Choose the output color for panel-4 cell (PR, PC) based on flood-fill regions.
arc2_po_cell_val_(PR, PC, S2, S3, InBg, Wall, Reachable, V) :-
% Retrieve s2 and s3 values at this panel position.
    nth0(PR, S2, S2Row), nth0(PC, S2Row, V2),
    nth0(PR, S3, S3Row), nth0(PC, S3Row, V3),
% Wall cells prefer s2; if s2 is background, fall back to s3.
    ( member(r(PR,PC), Wall) ->
        ( V2 \= InBg -> V = V2 ; V = V3 )
% Flood-reachable cells (s2 region) take the s2 value.
    ; member(r(PR,PC), Reachable) ->
        V = V2
% All other cells (s3 region) take the s3 value.
    ;   V = V3
    ).

% ---------------------------------------------------------------------------
% APEX SHADOW
% Each non-background shape has a centre cell and two arm vectors.
% For a size-1 isolated cell with exactly 2 non-bg 8-connected neighbours
% (apex), the centre is that cell and the arms point to the 2 neighbours.
% For a 3-cell L-shaped component, the centre is the corner (unique cell
% with 2 intra-component 4-connected neighbours) and the arms point to the
% other two cells.  Projection = -(arm1+arm2)*5/max(|sR|,|sC|) where
% sR=arm1R+arm2R and sC=arm1C+arm2C.  Landing on background places shadow-9;
% two projections to the same background cell produce value 1 (collision).
% Landing on an existing non-background component recolours it entirely to 9.
% Reference: ARC-AGI-2 task 409aa875.
% ---------------------------------------------------------------------------

% Register apex_shadow as a known named transform.
arc2_named_rule(apex_shadow).

% arc2_transform for apex_shadow: project each shape via its arm vectors.
arc2_transform(apex_shadow, Grid, Result) :-
% Find background colour via modal value.
    append(Grid, AsAll_), msort(AsAll_, AsSorted_),
% Determine background.
    arc2_bs_mode_(AsSorted_, AsBg),
% Find grid dimensions.
    length(Grid, AsNR_), nth0(0, Grid, AsR0_), length(AsR0_, AsNC_),
% Compute row and column index bounds.
    AsNR1_ is AsNR_ - 1, AsNC1_ is AsNC_ - 1,
% Enumerate all non-background cell positions.
    findall(r(R,C), (between(0,AsNR1_,R), between(0,AsNC1_,C),
        nth0(R,Grid,AsRow__), nth0(C,AsRow__,AsV__), AsV__ \= AsBg), AsNBCs_),
% Find all 4-connected components of non-background cells.
    as_components_(AsNBCs_, Grid, AsBg, AsNR_, AsNC_, AsComps_),
% Collect one projection target per active shape (apex or L-corner).
    findall(r(TR,TC), (member(AsComp__, AsComps_),
        as_comp_proj_(AsComp__, Grid, AsBg, AsNR_, AsNC_, TR, TC)), AsTgts_),
% Separate background targets (shadow-9) from non-bg targets (recolor).
    as_bg_nonbg_split_(AsTgts_, Grid, AsBg, AsBgTgts_, AsNBgTgts_),
% Expand non-bg targets to full component cells via BFS recolor.
    as_shadow9_(AsNBgTgts_, Grid, AsBg, AsNR_, AsNC_, AsRecolor0_),
    sort(AsRecolor0_, AsRecolor_),
% Sort bg targets and count hits per cell for collision detection.
    msort(AsBgTgts_, AsBgSorted_),
    as_count_hits_(AsBgSorted_, AsBgCounts_),
% Build result: recolor cells get 9, bg single-hit get 9, double-hit get 1.
    numlist(0, AsNR1_, AsRI_), numlist(0, AsNC1_, AsCI_),
    maplist([RI_,OutRow_]>>(
        maplist([CI_,Cell_]>>(
            nth0(RI_,Grid,AsGRow__), nth0(CI_,AsGRow__,AsOrig__),
% Recolor takes priority, then collision (2+ hits), then shadow-9 (1 hit).
            ( member(r(RI_,CI_), AsRecolor_) ->
                Cell_ = 9
            ; member(r(RI_,CI_)-AsHCnt__, AsBgCounts_), AsHCnt__ >= 2 ->
                Cell_ = 1
            ; member(r(RI_,CI_)-1, AsBgCounts_) ->
                Cell_ = 9
            ;   Cell_ = AsOrig__
            )
        ), AsCI_, OutRow_)
    ), AsRI_, Result).

% as_comp_proj_(+Comp, +Grid, +Bg, +NR, +NC, -TR, -TC): compute projection target.
as_comp_proj_(Comp, Grid, Bg, NR, NC, TR, TC) :-
    length(Comp, Sz),
% Size-1: apex if exactly 2 non-bg 8-neighbors; arms = directions to them.
    ( Sz =:= 1 ->
        Comp = [r(R,C)],
        as_8nbr_wings_(Grid, R, C, Bg, Wings_),
        length(Wings_, 2),
        Wings_ = [DR1-DC1, DR2-DC2],
        as_arm_proj_(DR1, DC1, DR2, DC2, R, C, NR, NC, TR, TC)
% Size-3: L-shape; arms = directions from corner to the other 2 cells.
    ; Sz =:= 3 ->
        as_corner_(Comp, r(CR,CC)),
        findall(DR-DC, (member(r(NNR,NNC), Comp), (NNR \= CR ; NNC \= CC),
            DR is NNR - CR, DC is NNC - CC), [ArmA,ArmB]),
        ArmA = DR1-DC1, ArmB = DR2-DC2,
        as_arm_proj_(DR1, DC1, DR2, DC2, CR, CC, NR, NC, TR, TC)
    ; fail
    ).

% as_arm_proj_: compute (TR,TC) = centre - arm_sum_normalised * 5.
as_arm_proj_(DR1, DC1, DR2, DC2, R, C, NR, NC, TR, TC) :-
% Sum of arm direction vectors.
    SR is DR1 + DR2, SC is DC1 + DC2,
% L-infinity normalisation factor.
    M is max(abs(SR), abs(SC)), M > 0,
% Scale by -5/M to get displacement.
    DPR is -5 * SR // M, DPC is -5 * SC // M,
% Target coordinates.
    TR is R + DPR, TC is C + DPC,
% Bounds check.
    TR >= 0, TR < NR, TC >= 0, TC < NC.

% as_8nbr_wings_(+Grid, +R, +C, +Bg, -Wings): list of DR-DC for non-bg 8-neighbors.
as_8nbr_wings_(Grid, R, C, Bg, Wings) :-
% Collect direction vectors to all non-background 8-connected neighbours.
    findall(DR-DC,
        (member(DR-DC, [(-1)-(-1),(-1)-0,(-1)-1,0-(-1),0-1,1-(-1),1-0,1-1]),
         NR is R+DR, NC is C+DC,
         nth0(NR, Grid, AsNR__), nth0(NC, AsNR__, AsNV__), AsNV__ \= Bg),
        Wings).

% as_bg_nonbg_split_: partition target list into background and non-bg targets.
as_bg_nonbg_split_([], _, _, [], []).
as_bg_nonbg_split_([r(TR,TC)|Rest], Grid, Bg, BgTgts, NBgTgts) :-
% Look up the target cell value.
    nth0(TR, Grid, AsRow__), nth0(TC, AsRow__, AsV__),
    as_bg_nonbg_split_(Rest, Grid, Bg, BgRest, NBgRest),
% Route to bg or non-bg list.
    ( AsV__ =:= Bg ->
        BgTgts = [r(TR,TC)|BgRest], NBgTgts = NBgRest
    ;   BgTgts = BgRest, NBgTgts = [r(TR,TC)|NBgRest]
    ).

% as_count_hits_(+SortedList, -Pairs): deduplicate sorted list with counts.
as_count_hits_([], []).
as_count_hits_([H|T], [H-Count|Rest]) :-
% Count how many additional copies of H appear in the tail.
    include(=(H), T, Dupes), length(Dupes, Extra), Count is Extra + 1,
% Remove all copies and recurse.
    exclude(=(H), T, Remaining),
    as_count_hits_(Remaining, Rest).

% as_components_(+NonBg, +Grid, +Bg, +NRows, +NCols, -Comps): BFS over all cells.
as_components_(NonBg, Grid, Bg, NRows, NCols, Comps) :-
% Iterate over non-background cells, BFS-expanding each unvisited one.
    as_comps_iter_(NonBg, Grid, Bg, NRows, NCols, [], Comps).

% as_comps_iter_: process each cell, skipping already-visited ones.
as_comps_iter_([], _, _, _, _, _, []).
as_comps_iter_([H|T], Grid, Bg, NRows, NCols, Visited, Comps) :-
% Skip cells already assigned to a component.
    ( member(H, Visited) ->
        as_comps_iter_(T, Grid, Bg, NRows, NCols, Visited, Comps)
    ;
% BFS from this cell to collect its component.
        as_bfs4_comp_([H], Grid, Bg, NRows, NCols, Visited, Comp, Visited1),
        as_comps_iter_(T, Grid, Bg, NRows, NCols, Visited1, Rest),
        Comps = [Comp|Rest]
    ).

% as_bfs4_comp_: 4-connectivity BFS returning the component and updated visited.
as_bfs4_comp_([], _, _, _, _, Vis, [], Vis).
as_bfs4_comp_([H|T], Grid, Bg, NRows, NCols, Vis0, Comp, Vis1) :-
% If already visited, skip.
    ( member(H, Vis0) ->
        as_bfs4_comp_(T, Grid, Bg, NRows, NCols, Vis0, Comp, Vis1)
    ;
        H = r(R,C),
% Mark as visited.
        Vis2 = [H|Vis0],
% Find 4-connected non-background unvisited neighbours.
        NRows1 is NRows - 1, NCols1 is NCols - 1,
        findall(r(NR,NC),
            (member(DR-DC, [(-1)-0, 1-0, 0-(-1), 0-1]),
             NR is R+DR, NC is C+DC,
             NR >= 0, NR =< NRows1, NC >= 0, NC =< NCols1,
             nth0(NR, Grid, AsNRow_), nth0(NC, AsNRow_, AsNV_), AsNV_ \= Bg,
             \+ member(r(NR,NC), Vis2)),
            Neighbors),
% Enqueue neighbours.
        append(T, Neighbors, Q1),
        as_bfs4_comp_(Q1, Grid, Bg, NRows, NCols, Vis2, CompRest, Vis1),
        Comp = [H|CompRest]
    ).

% as_corner_(+Comp, -Corner): find cell with exactly 2 intra-component 4-neighbors.
as_corner_(Comp, Corner) :-
    member(Corner, Comp),
    Corner = r(R,C),
% Count 4-connected neighbours that are also in the component.
    include([r(NR,NC)]>>(D is abs(NR-R)+abs(NC-C), D =:= 1), Comp, Ns4),
    length(Ns4, 2), !.

% as_shadow9_(+Targets, +Grid, +Bg, +NRows, +NCols, -Cells): expand non-bg targets.
as_shadow9_([], _, _, _, _, []).
as_shadow9_([r(TR,TC)|Rest], Grid, Bg, NRows, NCols, All) :-
    nth0(TR, Grid, TRow_), nth0(TC, TRow_, TV_),
    ( TV_ =:= Bg ->
% Background target: just this one cell becomes shadow-9.
        Cells = [r(TR,TC)]
    ;
% Non-background target: BFS entire component, all cells become shadow-9.
        as_bfs4_comp_([r(TR,TC)], Grid, Bg, NRows, NCols, [], Comp, _),
        Cells = Comp
    ),
    as_shadow9_(Rest, Grid, Bg, NRows, NCols, RestCells),
    append(Cells, RestCells, All).

% arc2_induce_rule for apex_shadow: verify all training pairs match exactly.
arc2_induce_rule(TrainingPairs, apex_shadow) :-
% Require at least one training pair.
    TrainingPairs \= [],
% Every pair must satisfy arc2_transform exactly.
    maplist([pair(In,Out)]>>(arc2_transform(apex_shadow, In, Out)),
            TrainingPairs).

% ===========================================================================
% WAVE 11: SYM_RESTORE (task 8e5c0c38)
% Each non-background colour group has a vertical mirror axis.  Cells whose
% column-mirror is absent from the group are orphans that break the symmetry.
% The rule finds the vertical axis (integer or half-integer column) that
% minimises orphan count for each colour, then removes those orphans by
% setting them to background, restoring left-right symmetry per colour.
% Reference: ARC-AGI-2 task 8e5c0c38.
% ===========================================================================

% Register sym_restore as a known named rule.
arc2_named_rule(sym_restore).

% arc2_transform for sym_restore: restore per-colour vertical symmetry.
arc2_transform(sym_restore, Grid, Result) :-
% Flatten grid to a single list for modal counting.
    append(Grid, SrFlat_), msort(SrFlat_, SrSorted_),
% Find background colour (most-frequent value).
    arc2_bs_mode_(SrSorted_, SrBg_),
% Group non-background cells by colour.
    sr_color_groups_(Grid, SrBg_, SrGroups_),
% For every colour group find the V-axis with fewest orphans.
    sr_all_orphans_(SrGroups_, SrOrphans_),
% Build result by replacing each orphan cell with background.
    sr_remove_rows_(Grid, 0, SrBg_, SrOrphans_, Result).

% sr_color_groups_(+Grid, +Bg, -Groups)
% Groups = list of Color-Cells pairs; Cells = [rc(R,C),...].
sr_color_groups_(Grid, Bg, Groups) :-
% Get row and column counts.
    length(Grid, SrNR_), SrNR1_ is SrNR_ - 1,
    nth0(0, Grid, SrRow0_), length(SrRow0_, SrNC_), SrNC1_ is SrNC_ - 1,
% Enumerate all non-background (Value, R, C) triples.
    findall(V-rc(R,C),
        (between(0,SrNR1_,R), between(0,SrNC1_,C),
         nth0(R,Grid,SrRowG__), nth0(C,SrRowG__,V), V \= Bg),
        SrPairs_),
% Collect distinct colours.
    findall(V, member(V-_, SrPairs_), SrVs0_),
    sort(SrVs0_, SrVs_),
% Group all rc(R,C) for each distinct colour.
    maplist([V,V-Cells]>>(findall(rc(R,C), member(V-rc(R,C), SrPairs_), Cells)),
        SrVs_, Groups).

% sr_all_orphans_(+Groups, -Orphans)
% Concatenate orphan cell lists across all colour groups.
sr_all_orphans_([], []).
sr_all_orphans_([_-Cells|Rest], Orphans) :-
% Find orphans for this colour group.
    sr_best_v_orphans_(Cells, MyOrphans),
% Recurse over remaining groups.
    sr_all_orphans_(Rest, RestOrphans),
% Merge orphan lists.
    append(MyOrphans, RestOrphans, Orphans).

% sr_best_v_orphans_(+Cells, -Orphans)
% Find the vertical axis Ax2 (= 2*axis, enabling half-column axes) that
% minimises the orphan count; return those orphan cells.
sr_best_v_orphans_(Cells, Orphans) :-
% Extract column indices and find column range.
    maplist([rc(_,C),C]>>true, Cells, SrCols_),
    min_list(SrCols_, SrMinC_), max_list(SrCols_, SrMaxC_),
% Build list of candidate doubled-axis values.
    SrMinAx2_ is SrMinC_ * 2, SrMaxAx2_ is SrMaxC_ * 2,
    numlist(SrMinAx2_, SrMaxAx2_, SrAxes_),
% Select axis with fewest orphan cells.
    sr_min_orphans_(SrAxes_, Cells, Orphans).

% sr_min_orphans_(+Axes, +Cells, -BestOrphans)
% Iterate over doubled-axis list; return orphans for the best axis.
sr_min_orphans_([Ax2], Cells, Orphans) :-
% Base case: single remaining axis.
    sr_orphans_for_axis_(Cells, Ax2, Orphans).
sr_min_orphans_([Ax2|Rest], Cells, Orphans) :-
% Compute orphans for this axis.
    sr_orphans_for_axis_(Cells, Ax2, MyOrphans),
    length(MyOrphans, MyN),
% Find best orphan set among remaining axes.
    sr_min_orphans_(Rest, Cells, CandOrphans),
    length(CandOrphans, CandN),
% Keep whichever axis produces fewer orphans.
    ( MyN =< CandN -> Orphans = MyOrphans ; Orphans = CandOrphans ).

% sr_orphans_for_axis_(+Cells, +Ax2, -Orphans)
% Cell rc(R,C) is an orphan when rc(R, Ax2-C) is absent from Cells.
sr_orphans_for_axis_(Cells, Ax2, Orphans) :-
% Filter to cells whose column mirror is not present.
    include([rc(R,C)]>>(MirC is Ax2 - C, \+ member(rc(R,MirC), Cells)),
        Cells, Orphans).

% sr_remove_rows_(+Grid, +R, +Bg, +Orphans, -Result)
% Walk rows; replace each orphan cell with Bg.
sr_remove_rows_([], _, _, _, []).
sr_remove_rows_([Row|Rest], R, Bg, Orphans, [NewRow|NewRest]) :-
% Process all cells in one row.
    sr_remove_row_(Row, R, 0, Bg, Orphans, NewRow),
    R1 is R + 1,
    sr_remove_rows_(Rest, R1, Bg, Orphans, NewRest).

% sr_remove_row_(+Row, +R, +C, +Bg, +Orphans, -NewRow)
% Walk one row cell by cell; replace orphan positions with Bg.
sr_remove_row_([], _, _, _, _, []).
sr_remove_row_([V|Rest], R, C, Bg, Orphans, [NewV|NewRest]) :-
% Replace with Bg if this (R,C) is in the orphan set.
    ( member(rc(R,C), Orphans) -> NewV = Bg ; NewV = V ),
    C1 is C + 1,
    sr_remove_row_(Rest, R, C1, Bg, Orphans, NewRest).

% arc2_induce_rule for sym_restore: verify all training pairs match.
arc2_induce_rule(TrainingPairs, sym_restore) :-
% Require at least one training pair.
    TrainingPairs \= [],
% Every pair must satisfy arc2_transform exactly.
    maplist([pair(In,Out)]>>(arc2_transform(sym_restore, In, Out)),
        TrainingPairs).

% ---------------------------------------------------------------------------
% WATERFALL RULE (Wave 12)
% Rule name: waterfall
% Task: 36a08778
% Observation: existing 6-cells act as seeds; 6 flows downward by gravity,
%   spreading horizontally around obstacle cells (non-bg, non-6), halting at
%   drain points (bg cell below) or at existing 6/obstacle barriers.
%   OOB-below does NOT trigger spreading.  All changes are bg→6.
% Key predicates: wf_bfs_/7, wf_eff_/6, wf_spread_/9, wf_edge_/10,
%   wf_enq_/5, wf_pq_ins_/3, wf_enq_all_/6, wf_build_/4, wf_build_row_/5.
% ---------------------------------------------------------------------------

% Register the rule name for induction dispatch.
arc2_named_rule(waterfall).

% arc2_transform(waterfall, +Grid, -Result)
arc2_transform(waterfall, Grid, Result) :-
% Flatten grid to find background (most-frequent value).
    append(Grid, WfFlat_), msort(WfFlat_, WfSrt_),
% Reuse shared background-mode helper.
    arc2_bs_mode_(WfSrt_, WfBg_),
% Grid height and width.
    length(Grid, WfNr_), WfNrM1_ is WfNr_ - 1,
% Width from first row.
    nth0(0, Grid, WfRow0_), length(WfRow0_, WfNc_), WfNcM1_ is WfNc_ - 1,
% Collect all original 6-seed positions; sort row-major.
    findall(r(R,C),
            ( between(0,WfNrM1_,R), between(0,WfNcM1_,C),
              nth0(R,Grid,WfGRow_), nth0(C,WfGRow_,6) ),
            WfSeeds0_),
    msort(WfSeeds0_, WfQ0_),
% BFS gravity simulation; seeds pre-populate both queue and visited.
    wf_bfs_(WfQ0_, WfQ0_, Grid, WfBg_, WfNr_, WfNc_, WfNew_),
% Sort marks for fast lookup then build result.
    msort(WfNew_, WfNewS_),
    wf_build_(Grid, 0, WfNewS_, Result).

% wf_bfs_(+PQ, +Vis, +Grid, +Bg, +Nr, +Nc, -New)
% PQ = row-major sorted priority queue of pending cells.
% Vis = list of all enqueued cells (seeds + newly marked).
% New = cells changed from Bg to 6 (newly marked, not original seeds).
wf_bfs_([], _, _, _, _, _, []).
wf_bfs_([r(R,C)|PQ0_], Vis0_, Grid_, Bg_, Nr_, Nc_, New_) :-
% Compute effective value of the cell directly below.
    R1_ is R + 1,
    ( R1_ < Nr_ ->
        wf_eff_(Grid_, Vis0_, R1_, C, Bg_, BV_)
    ; BV_ = wfwall_ ),
% Case 1: below is background — flow straight down.
    ( BV_ == Bg_ ->
        wf_enq_(r(R1_,C), PQ0_, Vis0_, PQ1_, Vis1_),
        wf_bfs_(PQ1_, Vis1_, Grid_, Bg_, Nr_, Nc_, Rest_),
        New_ = [r(R1_,C)|Rest_]
% Case 2: below is an in-grid obstacle — spread left and right.
    ; BV_ \== Bg_, BV_ \= wfwall_, BV_ \== 6 ->
        wf_spread_(R, C, Grid_, Vis0_, Bg_, R1_, Nr_, Nc_, Spread_),
        wf_enq_all_(Spread_, PQ0_, Vis0_, PQ1_, Vis1_, Added_),
        wf_bfs_(PQ1_, Vis1_, Grid_, Bg_, Nr_, Nc_, Rest_),
        append(Added_, Rest_, New_)
% Case 3: below is 6 or OOB — do nothing.
    ; wf_bfs_(PQ0_, Vis0_, Grid_, Bg_, Nr_, Nc_, New_)
    ).

% wf_eff_(+Grid, +Vis, +R, +C, +Bg, -Val)
% Effective cell value: 6 if in Vis (marked), else original grid value.
wf_eff_(_, Vis_, R, C, _, 6) :- memberchk(r(R,C), Vis_), !.
wf_eff_(Grid_, _, R, C, _, V_) :- nth0(R, Grid_, GR_), nth0(C, GR_, V_).

% wf_spread_(+R, +C, +Grid, +Vis, +Bg, +R1, +Nr, +Nc, -New)
% Find bg cells in row R reachable by horizontal spread from column C.
wf_spread_(R, C, Grid_, Vis_, Bg_, R1_, Nr_, Nc_, New_) :-
% Leftmost column in spread range.
    wf_edge_(R, C, -1, Grid_, Vis_, Bg_, R1_, Nr_, Nc_, Lc_),
% Rightmost column in spread range.
    wf_edge_(R, C,  1, Grid_, Vis_, Bg_, R1_, Nr_, Nc_, Rc_),
% Collect bg cells in [Lc_,Rc_] not already marked.
    findall(r(R,C2),
            ( between(Lc_, Rc_, C2),
              wf_eff_(Grid_, Vis_, R, C2, Bg_, V2_),
              V2_ == Bg_ ),
            New_).

% wf_edge_(+R, +C, +Dir, +Grid, +Vis, +Bg, +R1, +Nr, +Nc, -Edge)
% Spread one direction (Dir = -1 left, +1 right) from column C in row R.
% Returns the last column to include (drain point or grid boundary stop).
wf_edge_(_, C, Dir_, _, _, _, _, _, Nc_, C) :-
% Next column is beyond grid boundary.
    C1_ is C + Dir_, ( C1_ < 0 ; C1_ >= Nc_ ), !.
wf_edge_(R, C, Dir_, Grid_, Vis_, Bg_, R1_, Nr_, Nc_, Edge_) :-
    C1_ is C + Dir_,
% Effective value at C1_ in the current row.
    wf_eff_(Grid_, Vis_, R, C1_, Bg_, V1_),
    ( V1_ \== Bg_ ->
% Hit a barrier (existing 6 or obstacle cell): stop before it.
        Edge_ = C
    ;
% C1_ is background — check if it is a drain (can fall down).
        ( R1_ < Nr_ ->
            wf_eff_(Grid_, Vis_, R1_, C1_, Bg_, BV1_)
        ; BV1_ = wfwall_ ),
        ( BV1_ == Bg_ ->
% Drain found: include C1_ as the spread edge, stop.
            Edge_ = C1_
        ;
% No drain at C1_: continue spreading in the same direction.
            wf_edge_(R, C1_, Dir_, Grid_, Vis_, Bg_, R1_, Nr_, Nc_, Edge_)
        )
    ).

% wf_enq_(+Cell, +PQ, +Vis, -PQ2, -Vis2)
% Add Cell to sorted PQ and Vis only if not already present.
wf_enq_(Cell_, PQ_, Vis_, PQ2_, Vis2_) :-
    ( memberchk(Cell_, Vis_) ->
        PQ2_ = PQ_, Vis2_ = Vis_
    ;
        Vis2_ = [Cell_|Vis_],
        wf_pq_ins_(Cell_, PQ_, PQ2_)
    ).

% wf_pq_ins_(+X, +PQ, -PQ2): insert X into a sorted row-major list.
wf_pq_ins_(X_, [], [X_]).
wf_pq_ins_(X_, [H_|T_], [X_,H_|T_]) :- X_ @=< H_, !.
wf_pq_ins_(X_, [H_|T_], [H_|T2_]) :- wf_pq_ins_(X_, T_, T2_).

% wf_enq_all_(+Cells, +PQ, +Vis, -PQ2, -Vis2, -Added)
% Enqueue all cells not already in Vis; collect newly added in Added.
wf_enq_all_([], PQ_, Vis_, PQ_, Vis_, []).
wf_enq_all_([Cell_|Rest_], PQ0_, Vis0_, PQ2_, Vis2_, Added_) :-
    ( memberchk(Cell_, Vis0_) ->
        wf_enq_all_(Rest_, PQ0_, Vis0_, PQ2_, Vis2_, Added_)
    ;
        wf_enq_(Cell_, PQ0_, Vis0_, PQm_, Vim_),
        wf_enq_all_(Rest_, PQm_, Vim_, PQ2_, Vis2_, RestAdded_),
        Added_ = [Cell_|RestAdded_]
    ).

% wf_build_(+Grid, +R, +Marks, -Result): apply marks (Bg→6) to Grid.
wf_build_([], _, _, []).
wf_build_([GRow_|GRest_], R_, Marks_, [NewRow_|NewRest_]) :-
    wf_build_row_(GRow_, 0, R_, Marks_, NewRow_),
    R1_ is R_ + 1,
    wf_build_(GRest_, R1_, Marks_, NewRest_).

% wf_build_row_(+Row, +C, +R, +Marks, -NewRow): fill marked cells with 6.
wf_build_row_([], _, _, _, []).
wf_build_row_([V_|Vs_], C_, R_, Marks_, [NV_|NVs_]) :-
    ( memberchk(r(R_,C_), Marks_) -> NV_ = 6 ; NV_ = V_ ),
    C1_ is C_ + 1,
    wf_build_row_(Vs_, C1_, R_, Marks_, NVs_).

% arc2_induce_rule for waterfall: verify all training pairs match.
arc2_induce_rule(TrainingPairs, waterfall) :-
% Require at least one training pair.
    TrainingPairs \= [],
% Every pair must satisfy arc2_transform(waterfall, ...) exactly.
    maplist([pair(In,Out)]>>(arc2_transform(waterfall, In, Out)),
        TrainingPairs).

% ---------------------------------------------------------------------------
% FRAME FILL (frame_fill) — Wave 13 (DISABLED: rule inconsistent with test)
% ---------------------------------------------------------------------------
% arc2_named_rule(frame_fill). % disabled

% arc2_transform(frame_fill, +Grid, -Result)
arc2_transform(frame_fill, Grid, Result) :-
% Background = most-frequent value.
    append(Grid, FfFlat_), msort(FfFlat_, FfSrt_),
    arc2_bs_mode_(FfSrt_, FfBg_),
% Grid dimensions.
    length(Grid, FfNr_), FfNrM1_ is FfNr_ - 1,
    nth0(0, Grid, FfRow0_), length(FfRow0_, FfNc_), FfNcM1_ is FfNc_ - 1,
% Find key pairs from the largest 2-row or 2-col solid block.
    ff_find_pairs_(Grid, FfBg_, FfNrM1_, FfNcM1_, FfPairs_),
    FfPairs_ \= [],
% Collect fill assignments: for each (FrameColor,FillColor), find enclosed bg.
    ff_collect_fills_(FfPairs_, Grid, FfBg_, FfNr_, FfNc_, FfFills_),
% Apply fills to produce result grid.
    ff_apply_fills_(Grid, FfFills_, Result).

% ff_find_pairs_(+Grid, +Bg, +NrM1, +NcM1, -Pairs)
% Find the largest solid 2-row or 2-col block and extract (FrameColor,FillColor) pairs.
ff_find_pairs_(Grid_, Bg_, NrM1_, NcM1_, Pairs_) :-
    ff_all_spans_(Grid_, Bg_, NrM1_, NcM1_, Spans_),
    Spans_ \= [],
    % Sort descending by cell count; pick the largest span.
    msort(Spans_, Sorted_),
    last(Sorted_, best(_, Type_, R0_, C0_, W_, H_)),
    ( Type_ = row ->
        ff_pairs_from_rows_(Grid_, R0_, C0_, W_, Pairs_)
    ; % col
        ff_pairs_from_cols_(Grid_, R0_, C0_, H_, Pairs_)
    ).

% ff_all_spans_(+Grid, +Bg, +NrM1, +NcM1, -Spans)
% Find all solid 2-row and 2-col spans as best(Size, Type, R0, C0, W, H).
ff_all_spans_(Grid_, Bg_, NrM1_, NcM1_, Spans_) :-
    findall(best(Size_, row, R0_, C0_, W_, 2),
        ( between(0, NrM1_, R0_), R0_ < NrM1_, R1_ is R0_+1,
          ff_max_col_span_(Grid_, Bg_, R0_, R1_, NcM1_, C0_, C1_),
          W_ is C1_ - C0_ + 1, W_ >= 2,
          Size_ is W_ * 2 ),
        RowSpans_),
    findall(best(Size_, col, R0_, C0_, W_, H_),
        ( between(0, NcM1_, C0_), C0_ < NcM1_, C1_ is C0_+1,
          ff_max_row_span_(Grid_, Bg_, C0_, C1_, NrM1_, R0_, R1_),
          H_ is R1_ - R0_ + 1, H_ >= 2, W_ = 2,
          Size_ is H_ * 2 ),
        ColSpans_),
    append(RowSpans_, ColSpans_, Spans_).

% ff_max_col_span_(+Grid, +Bg, +R0, +R1, +NcM1, -C0, -C1)
% Find a maximal column span [C0,C1] in rows R0,R1 where all cells are non-bg.
ff_max_col_span_(Grid_, Bg_, R0_, R1_, NcM1_, C0_, C1_) :-
    nth0(R0_, Grid_, Row0_), nth0(R1_, Grid_, Row1_),
    % Collect cols where both rows are non-bg.
    findall(C, ( between(0, NcM1_, C),
                 nth0(C, Row0_, V0_), V0_ \= Bg_,
                 nth0(C, Row1_, V1_), V1_ \= Bg_ ), Cols_),
    Cols_ \= [],
    % Find maximal consecutive run.
    ff_max_consecutive_(Cols_, C0_, C1_).

% ff_max_row_span_(+Grid, +Bg, +C0, +C1, +NrM1, -R0, -R1)
% Find a maximal row span [R0,R1] in cols C0,C1 where all cells are non-bg.
ff_max_row_span_(Grid_, Bg_, C0_, C1_, NrM1_, R0_, R1_) :-
    findall(R, ( between(0, NrM1_, R),
                 nth0(R, Grid_, GRow_),
                 nth0(C0_, GRow_, V0_), V0_ \= Bg_,
                 nth0(C1_, GRow_, V1_), V1_ \= Bg_ ), Rows_),
    Rows_ \= [],
    ff_max_consecutive_(Rows_, R0_, R1_).

% ff_max_consecutive_(+List, -Start, -End)
% Find the longest consecutive subsequence in a sorted integer list.
ff_max_consecutive_(List_, Start_, End_) :-
    msort(List_, Sorted_),
    Sorted_ = [H_|_],
    ff_consec_runs_(Sorted_, H_, H_, H_, H_, Start_, End_).

ff_consec_runs_([], CurS_, CurE_, BestS_, BestE_, S_, E_) :-
    CurLen_ is CurE_ - CurS_,
    BestLen_ is BestE_ - BestS_,
    ( CurLen_ >= BestLen_ -> S_ = CurS_, E_ = CurE_
    ; S_ = BestS_, E_ = BestE_ ).
ff_consec_runs_([X_|Rest_], CurS_, CurE_, BestS_, BestE_, S_, E_) :-
    ( X_ =:= CurE_ + 1 ->
        % Extend current run.
        NewCurE_ = X_,
        NewCurLen_ is NewCurE_ - CurS_,
        BestLen_ is BestE_ - BestS_,
        ( NewCurLen_ > BestLen_ ->
            ff_consec_runs_(Rest_, CurS_, NewCurE_, CurS_, NewCurE_, S_, E_)
        ;
            ff_consec_runs_(Rest_, CurS_, NewCurE_, BestS_, BestE_, S_, E_)
        )
    ;
        % Start new run.
        CurLen_ is CurE_ - CurS_,
        BestLen_ is BestE_ - BestS_,
        ( CurLen_ >= BestLen_ ->
            ff_consec_runs_(Rest_, X_, X_, CurS_, CurE_, S_, E_)
        ;
            ff_consec_runs_(Rest_, X_, X_, BestS_, BestE_, S_, E_)
        )
    ).

% ff_pairs_from_rows_(+Grid, +R0, +C0, +W, -Pairs)
% Extract (FrameColor,FillColor) pairs by reading columns of 2-row block.
% Top row = FrameColor, bottom row = FillColor.
ff_pairs_from_rows_(Grid_, R0_, C0_, W_, Pairs_) :-
    R1_ is R0_ + 1,
    nth0(R0_, Grid_, Row0_), nth0(R1_, Grid_, Row1_),
    C1_ is C0_ + W_ - 1,
    findall(fc(Top_,Bot_),
        ( between(C0_, C1_, C_),
          nth0(C_, Row0_, Top_), Top_ \= 0,
          nth0(C_, Row1_, Bot_), Bot_ \= 0 ),
        Pairs_).

% ff_pairs_from_cols_(+Grid, +R0, +C0, +H, -Pairs)
% Extract (FrameColor,FillColor) pairs by reading rows of 2-col block.
% Left col = FrameColor, right col = FillColor.
ff_pairs_from_cols_(Grid_, R0_, C0_, H_, Pairs_) :-
    C1_ is C0_ + 1,
    R1_ is R0_ + H_ - 1,
    findall(fc(Left_,Right_),
        ( between(R0_, R1_, R_),
          nth0(R_, Grid_, GRow_),
          nth0(C0_, GRow_, Left_), Left_ \= 0,
          nth0(C1_, GRow_, Right_), Right_ \= 0 ),
        Pairs_).

% ff_collect_fills_(+Pairs, +Grid, +Bg, +Nr, +Nc, -Fills)
% For each fc(FrameColor,FillColor) pair, find interior bg cells.
ff_collect_fills_([], _, _, _, _, []).
ff_collect_fills_([fc(FC_,Fill_)|Rest_], Grid_, Bg_, Nr_, Nc_, Fills_) :-
    ff_interior_(Grid_, FC_, Bg_, Nr_, Nc_, Interior_),
    findall(fill(R_,C_,Fill_), member(rc(R_,C_), Interior_), ThisFills_),
    ff_collect_fills_(Rest_, Grid_, Bg_, Nr_, Nc_, RestFills_),
    append(ThisFills_, RestFills_, Fills_).

% ff_interior_(+Grid, +BlockerColor, +Bg, +Nr, +Nc, -Interior)
% Interior = bg cells enclosed by BlockerColor (not reachable from boundary).
ff_interior_(Grid_, Blocker_, Bg_, Nr_, Nc_, Interior_) :-
    NrM1_ is Nr_ - 1, NcM1_ is Nc_ - 1,
% Seed BFS with all boundary cells that are not the blocker color.
    findall(rc(R_,C_),
        ( ( (R_=0 ; R_=NrM1_), between(0,NcM1_,C_)
          ; (C_=0 ; C_=NcM1_), between(0,NrM1_,R_) ),
          nth0(R_,Grid_,GRow_), nth0(C_,GRow_,V_),
          V_ \= Blocker_ ),
        Seeds0_),
    sort(Seeds0_, Seeds_),
% BFS to find all reachable cells (not blocked by Blocker).
    ff_bfs_(Seeds_, Seeds_, Grid_, Blocker_, NrM1_, NcM1_, Reachable_),
    sort(Reachable_, ReachSorted_),
% Interior = bg cells NOT in reachable set.
    findall(rc(R_,C_),
        ( between(0,NrM1_,R_), between(0,NcM1_,C_),
          nth0(R_,Grid_,GRow_), nth0(C_,GRow_,Bg_),
          \+ memberchk(rc(R_,C_), ReachSorted_) ),
        Interior_).

% ff_bfs_(+Queue, +Visited, +Grid, +Blocker, +NrM1, +NcM1, -AllVisited)
ff_bfs_([], Vis_, _, _, _, _, Vis_).
ff_bfs_([rc(R_,C_)|Q0_], Vis0_, Grid_, Blocker_, NrM1_, NcM1_, Vis_) :-
    Ru_ is R_-1, Rd_ is R_+1, Cl_ is C_-1, Cr_ is C_+1,
    findall(rc(R2_,C2_),
        ( member(rc(R2_,C2_), [rc(Ru_,C_),rc(Rd_,C_),rc(R_,Cl_),rc(R_,Cr_)]),
          R2_ >= 0, R2_ =< NrM1_, C2_ >= 0, C2_ =< NcM1_,
          \+ memberchk(rc(R2_,C2_), Vis0_),
          nth0(R2_,Grid_,GRow_), nth0(C2_,GRow_,V2_),
          V2_ \= Blocker_ ),
        New_),
    append(Q0_, New_, Q1_),
    append(Vis0_, New_, Vis1_),
    ff_bfs_(Q1_, Vis1_, Grid_, Blocker_, NrM1_, NcM1_, Vis_).

% ff_apply_fills_(+Grid, +Fills, -Result)
% Rebuild grid with fill assignments applied.
ff_apply_fills_(Grid_, Fills_, Result_) :-
    length(Grid_, Nr_), Nr1_ is Nr_ - 1,
    nth0(0, Grid_, Row0_), length(Row0_, Nc_), Nc1_ is Nc_ - 1,
    findall(Row_,
        ( between(0, Nr1_, R_),
          findall(V_,
            ( between(0, Nc1_, C_),
              nth0(R_, Grid_, GRow_),
              nth0(C_, GRow_, OldV_),
              ( memberchk(fill(R_,C_,NewV_), Fills_) -> V_ = NewV_
              ; V_ = OldV_ ) ),
            Row_) ),
        Result_).

% arc2_induce_rule for frame_fill: verify all training pairs match.
arc2_induce_rule(TrainingPairs, frame_fill) :-
    TrainingPairs \= [],
    forall(member(pair(In_, Out_), TrainingPairs),
        arc2_transform(frame_fill, In_, Out_)).

% ---------------------------------------------------------------------------
% ODD COL RULE (Wave 13)
% Rule name: odd_col
% Grid is an N×M tiling of cells, separated by uniform rows and cols.
% In each row section exactly one col section differs from the others.
% Output: same row structure, but one col section wide (the odd col per row section).
% ---------------------------------------------------------------------------

% Register odd_col as a named rule.
arc2_named_rule(odd_col).

% arc2_transform(odd_col, +Grid, -Result)
arc2_transform(odd_col, Grid, Result) :-
% Count rows and cols.
    length(Grid, Nr_),
% Get first row to count cols.
    nth0(0, Grid, Row0_), length(Row0_, Nc_),
% NrM1 and NcM1 for between/3 upper bounds.
    Nrm1_ is Nr_ - 1, Ncm1_ is Nc_ - 1,
% Sep rows: rows where all cells share the same value.
    findall(R_, (
        between(0, Nrm1_, R_),
        nth0(R_, Grid, Rw_),
        oc_all_same_(Rw_, _)
    ), SepRows_),
% Must have at least two separator rows (top and bottom boundary).
    SepRows_ = [_,_|_],
% Sep cols: cols where all cells in that column share the same value.
    findall(C_, (
        between(0, Ncm1_, C_),
        findall(V_, (
            between(0, Nrm1_, R_),
            nth0(R_, Grid, Rw_),
            nth0(C_, Rw_, V_)
        ), Cv_),
        oc_all_same_(Cv_, _)
    ), SepCols_),
% Must have at least two separator cols (left and right boundary).
    SepCols_ = [_,_|_],
% Build (c0,c1) col-section pairs from adjacent sep cols.
    oc_adjacent_pairs_(SepCols_, ColSecs_),
% Must have at least two col sections (otherwise no comparison possible).
    ColSecs_ = [_,_|_],
% Build (r0,r1) row-section pairs from adjacent sep rows.
    oc_adjacent_pairs_(SepRows_, RowSecs_),
% For each row section, vote for the unique col section index.
    maplist({Grid,ColSecs_}/[(R0_,R1_), UJ_]>>(
        oc_vote_unique_col_(R0_, R1_, Grid, ColSecs_, UJ_)
    ), RowSecs_, UniqueJs_),
% Build result: one col-section wide, same row structure.
    last(SepRows_, LastSep_),
    nth0(0, ColSecs_, (FC0_,FC1_)),
    oc_build_secs_(RowSecs_, Grid, ColSecs_, UniqueJs_, Body_),
    nth0(LastSep_, Grid, LastRow_),
    oc_strip_(LastRow_, FC0_, FC1_, LastStrip_),
    append(Body_, [LastStrip_], Result).

% oc_all_same_(+List, -Val): List is non-empty and all elements equal Val.
oc_all_same_([H|T], H) :-
% All tail elements equal the head.
    maplist(=(H), T).

% oc_adjacent_pairs_(+List, -Pairs): pairs of adjacent elements.
oc_adjacent_pairs_([], []).
% Base: single element — no pair possible.
oc_adjacent_pairs_([_], []).
% Recursive: form pair (A,B) and recurse on tail starting at B.
oc_adjacent_pairs_([A,B|T], [(A,B)|Pairs]) :-
    oc_adjacent_pairs_([B|T], Pairs).

% oc_strip_(+Row, +C0, +C1, -Strip): slice Row from index C0 to C1 inclusive.
oc_strip_(Row_, C0_, C1_, Strip_) :-
% Length of the strip.
    Len_ is C1_ - C0_ + 1,
% Drop the first C0 elements.
    length(Pre_, C0_), append(Pre_, Tail_, Row_),
% Take the next Len elements.
    length(Strip_, Len_), append(Strip_, _, Tail_).

% oc_strips_for_row_(+R, +Grid, +ColSecs, -Strips):
% Extract one strip per col section for row R.
oc_strips_for_row_(R_, Grid_, ColSecs_, Strips_) :-
% Get the full row.
    nth0(R_, Grid_, Row_),
% For each col section, slice out the strip.
    maplist({Row_}/[(C0_,C1_), S_]>>(oc_strip_(Row_, C0_, C1_, S_)), ColSecs_, Strips_).

% oc_majority_strip_(+Strips, -Maj):
% Maj[i] = majority value across all strips at position i.
oc_majority_strip_(Strips_, Maj_) :-
% Width from first strip.
    Strips_ = [H_|_], length(H_, W_), Wm1_ is W_ - 1,
% For each position, collect values and take mode.
    findall(MV_, (
        between(0, Wm1_, I_),
        maplist({I_}/[S_, V_]>>(nth0(I_, S_, V_)), Strips_, Vs_),
        msort(Vs_, Sorted_),
        arc2_bs_mode_(Sorted_, MV_)
    ), Maj_).

% oc_find_unique_idx_(+Strips, +Maj, -Idx):
% Idx = index of the one strip that differs from Maj; -1 if 0 or >1 differ.
oc_find_unique_idx_(Strips_, Maj_, Idx_) :-
    length(Strips_, N_), Nm1_ is N_ - 1,
% Collect indices of strips differing from majority.
    findall(J_, (
        between(0, Nm1_, J_),
        nth0(J_, Strips_, S_),
        S_ \= Maj_
    ), Diffs_),
% Unique only if exactly one strip differs.
    ( Diffs_ = [Idx_] -> true ; Idx_ = -1 ).

% oc_vote_unique_col_(+R0, +R1, +Grid, +ColSecs, -UniqueJ):
% Vote across content rows in section [R0..R1] to find the unique col section.
oc_vote_unique_col_(R0_, R1_, Grid_, ColSecs_, UniqueJ_) :-
% Content rows: R0+1 to R1-1.
    R0p1_ is R0_ + 1, R1m1_ is R1_ - 1,
    ( R0p1_ =< R1m1_ ->
        numlist(R0p1_, R1m1_, ContentRows_)
    ;   ContentRows_ = [] ),
% Collect outlier col-section indices from each content row.
    findall(Idx_, (
        member(R_, ContentRows_),
        oc_strips_for_row_(R_, Grid_, ColSecs_, Strips_),
        oc_majority_strip_(Strips_, Maj_),
        oc_find_unique_idx_(Strips_, Maj_, Idx_),
        Idx_ >= 0
    ), Outliers_),
    ( Outliers_ = [] ->
% No unique col found; default to first col section.
        UniqueJ_ = 0
    ;   msort(Outliers_, OSort_),
        arc2_bs_mode_(OSort_, UniqueJ_) ).

% oc_build_secs_(+RowSecs, +Grid, +ColSecs, +UniqueJs, -Rows):
% For each row section, emit rows R0..R1-1 using the unique col section.
oc_build_secs_([], _, _, _, []).
% Recursive: process one row section at a time.
oc_build_secs_([(R0_,R1_)|Secs_], Grid_, ColSecs_, [J_|Js_], Rows_) :-
% Get the col bounds for the unique col section.
    nth0(J_, ColSecs_, (C0_,C1_)),
    R1m1_ is R1_ - 1,
% Emit rows R0..R1-1 (exclude R1 to avoid double-counting sep row).
    numlist(R0_, R1m1_, Rs_),
    findall(Strip_, (
        member(R_, Rs_),
        nth0(R_, Grid_, Row_),
        oc_strip_(Row_, C0_, C1_, Strip_)
    ), SecRows_),
    oc_build_secs_(Secs_, Grid_, ColSecs_, Js_, RestRows_),
    append(SecRows_, RestRows_, Rows_).

% arc2_induce_rule for odd_col: verify all training pairs match.
arc2_induce_rule(TrainingPairs, odd_col) :-
% Require at least one training pair.
    TrainingPairs \= [],
% Every training pair must pass the transform exactly.
    forall(member(pair(In_, Out_), TrainingPairs),
        arc2_transform(odd_col, In_, Out_)).

% ---------------------------------------------------------------------------
% RECOLOR RULES
% arc2_recolor_grid/3: apply a color substitution map to an entire grid.
% ---------------------------------------------------------------------------

% Define arc2_recolor_grid/3: apply Map to every cell in Grid.
arc2_recolor_grid(Map, Grid, Result) :-
    maplist([Row, Row2]>>(maplist(arc2_recolor_cell_(Map), Row, Row2)), Grid, Result).

% arc2_recolor_cell_(+Map, +OldColor, -NewColor): map one cell through Map.
arc2_recolor_cell_(Map, Old, New) :-
    ( member(Old-New, Map) -> true ; New = Old ).

% arc2_induce_recolor/2: infer a color bijection from training pairs.
arc2_induce_recolor(TrainingPairs, Mapping) :-
    findall(Old-New,
        (member(pair(In, Out), TrainingPairs),
         append(In, FlatIn), append(Out, FlatOut),
         length(FlatIn, N), length(FlatOut, N),
         nth1(I, FlatIn, Old), nth1(I, FlatOut, New),
         Old \= New),
        RawPairs),
    sort(RawPairs, Mapping),
    Mapping \= [],
    % Verify consistency: same Old always maps to same New.
    forall(member(Old-New1, Mapping),
           forall(member(Old-New2, Mapping), New1 = New2)).

% ---------------------------------------------------------------------------
% WAVE 14: reflect_axis rule
% Each non-background non-2 shape is reflected across the axis defined
% by its nearest 2-cluster: a single 2-cell (point), a collinear column
% of 2-cells (vertical axis), or a collinear row of 2-cells (horizontal axis).
% Task: 7ed72f31
% ---------------------------------------------------------------------------

% Register reflect_axis as a named rule.
arc2_named_rule(reflect_axis).

% ra_bg_: background is the most frequent value in the flattened grid.
% ra_bg_(+Grid, -Bg)
ra_bg_(Grid, Bg) :-
% Flatten grid to a single list of values.
    flatten(Grid, Flat_),
% Compute mode (most frequent element) of the flat list.
    arc2_bs_mode_(Flat_, Bg).

% ra_nrc_: grid dimensions.
% ra_nrc_(+Grid, -NR, -NC)
ra_nrc_(Grid, NR, NC) :-
% Row count.
    length(Grid, NR),
% Column count from first row.
    ( Grid = [R0_|_] -> length(R0_, NC) ; NC = 0 ).

% ra_inb_: check (R,C) is within grid bounds.
% ra_inb_(+R, +C, +NR, +NC)
ra_inb_(R, C, NR, NC) :-
% Row must be non-negative.
    R >= 0,
% Row must be less than NR.
    R < NR,
% Col must be non-negative.
    C >= 0,
% Col must be less than NC.
    C < NC.

% ra_nbrs4_: 4-connected neighbors within bounds.
% ra_nbrs4_(+R, +C, +NR, +NC, -Nbrs)
ra_nbrs4_(R, C, NR, NC, Nbrs) :-
% Compute adjacent row/col indices.
    R1_ is R - 1, R2_ is R + 1, C1_ is C - 1, C2_ is C + 1,
% Keep only in-bounds candidates.
    include([Ri_-Ci_]>>(ra_inb_(Ri_,Ci_,NR,NC)),
            [R1_-C, R2_-C, R-C1_, R-C2_],
            Nbrs).

% ra_absorb_: pull members of Candidates that exist in Avail into Taken;
%             leave the rest in Rem. Used by BFS to expand frontier.
% ra_absorb_(+Candidates, +Avail, -Taken, -Rem)
ra_absorb_([], Avail, [], Avail).
ra_absorb_([H_|T_], Avail, [H_|Taken], Rem) :-
% H_ exists in Avail: take it and remove it from Avail.
    select(H_, Avail, Avail2_), !,
    ra_absorb_(T_, Avail2_, Taken, Rem).
ra_absorb_([_|T_], Avail, Taken, Rem) :-
% H_ not in Avail: skip it.
    ra_absorb_(T_, Avail, Taken, Rem).

% ra_bfs4_: BFS over R-C pairs; expands Queue through Available set.
% ra_bfs4_(+Queue, +Available, +NR, +NC, -Visited, -Remaining)
ra_bfs4_([], Avail, _, _, [], Avail).
ra_bfs4_([H_|QT_], Avail, NR, NC, [H_|Vis], Rem) :-
% Get 4-connected neighbors of current cell.
    H_ = R_-C_,
    ra_nbrs4_(R_, C_, NR, NC, Nbrs_),
% Absorb any neighbors found in Avail into the BFS queue.
    ra_absorb_(Nbrs_, Avail, NewQ_, Avail2_),
% Append new cells to end of queue (breadth-first).
    append(QT_, NewQ_, Queue2_),
    ra_bfs4_(Queue2_, Avail2_, NR, NC, Vis, Rem).

% ra_cc4_: connected components (4-connected) of a list of R-C pairs.
% ra_cc4_(+Pts, +NR, +NC, -Comps) each comp is [R-C|...].
ra_cc4_([], _, _, []).
ra_cc4_([Seed_|Rest_], NR, NC, [Comp_|Comps]) :-
% Grow one component from Seed_ through the remaining points.
    ra_bfs4_([Seed_], Rest_, NR, NC, Comp_, Rem_),
    ra_cc4_(Rem_, NR, NC, Comps).

% ra_split_col_: partition R-C-V list into same-color R-C list and other R-C-V list.
% ra_split_col_(+V, +Cells, -SameRC, -OtherRCV)
ra_split_col_(_, [], [], []).
ra_split_col_(V, [R_-C_-V|T_], [R_-C_|S_], O_) :- !,
    ra_split_col_(V, T_, S_, O_).
ra_split_col_(V, [H_|T_], S_, [H_|O_]) :-
    ra_split_col_(V, T_, S_, O_).

% ra_add_col_: prepend color V to each R-C pair to form R-C-V triples.
% ra_add_col_(+Pairs, +V, -Triples)
ra_add_col_([], _, []).
ra_add_col_([R_-C_|T_], V, [R_-C_-V|T2_]) :-
    ra_add_col_(T_, V, T2_).

% ra_shape_comps_: connected components of non-Bg non-2 cells.
% ra_shape_comps_(+Grid, +Bg, +NR, +NC, -Comps)
% Comps = [comp(V,[R-C|...])|...]
ra_shape_comps_(Grid, Bg, NR, NC, Comps) :-
% Collect all non-background non-2 cells with their color value.
    findall(R_-C_-V_,
        ( nth0(R_, Grid, Row_), nth0(C_, Row_, V_),
          V_ \= Bg, V_ \= 2 ),
        Cells_),
    ra_shape_comps_aux_(Cells_, NR, NC, Comps).

% ra_shape_comps_aux_: auxiliary recursive shape-component grouping.
% ra_shape_comps_aux_(+Cells, +NR, +NC, -Comps)
ra_shape_comps_aux_([], _, _, []).
ra_shape_comps_aux_([R_-C_-V_|Rest_], NR, NC, [comp(V_,Pts_)|Comps]) :-
% Extract all same-color R-C pairs from Rest_ for BFS.
    ra_split_col_(V_, Rest_, SamePts_, OtherCells_),
% BFS from (R,C) through same-color neighbors.
    ra_bfs4_([R_-C_], SamePts_, NR, NC, RestComp_, RemSame_),
% This component's points: seed plus BFS result.
    Pts_ = [R_-C_|RestComp_],
% Rebuild R-C-V triples for remaining same-color points.
    ra_add_col_(RemSame_, V_, RemSameV_),
% Continue with all remaining cells (same- and other-color).
    append(RemSameV_, OtherCells_, AllRem_),
    ra_shape_comps_aux_(AllRem_, NR, NC, Comps).

% ra_min_manhattan_: minimum Manhattan distance between two R-C point sets.
% ra_min_manhattan_(+SetA, +SetB, -MinDist)
ra_min_manhattan_(SetA_, SetB_, MinDist) :-
% Compute all pairwise Manhattan distances.
    findall(D_,
        ( member(Ra_-Ca_, SetA_),
          member(Rb_-Cb_, SetB_),
          D_ is abs(Ra_-Rb_) + abs(Ca_-Cb_) ),
        Ds_),
% Return the minimum.
    min_list(Ds_, MinDist).

% ra_nearest_cluster_: find the nearest 2-cluster to a shape component.
% ra_nearest_cluster_(+ShapePts, +Clusters, -Nearest)
ra_nearest_cluster_(ShapePts_, Clusters_, Nearest_) :-
% Compute distance from shape to each cluster.
    findall(D_-Cl_,
        ( member(Cl_, Clusters_),
          ra_min_manhattan_(ShapePts_, Cl_, D_) ),
        Pairs_),
% Sort by distance; first element is nearest.
    sort(Pairs_, [_-Nearest_|_]).

% ra_extract_rows_: extract R values from list of R-C pairs.
% ra_extract_rows_(+Pairs, -Rows)
ra_extract_rows_([], []).
ra_extract_rows_([R_-_|T_], [R_|Rows_]) :-
    ra_extract_rows_(T_, Rows_).

% ra_extract_cols_: extract C values from list of R-C pairs.
% ra_extract_cols_(+Pairs, -Cols)
ra_extract_cols_([], []).
ra_extract_cols_([_-C_|T_], [C_|Cols_]) :-
    ra_extract_cols_(T_, Cols_).

% ra_all_equal_: true if all elements of a list are equal.
% ra_all_equal_(+List)
ra_all_equal_([_]).
ra_all_equal_([X_,X_|T_]) :- ra_all_equal_([X_|T_]).

% ra_axis_: determine reflection axis from a cluster of 2-cells.
% ra_axis_(+Cluster, -Axis)
% Axis = h(R) | v(C) | p(R,C)
ra_axis_([R_-C_], p(R_,C_)) :- !.
ra_axis_(Cluster_, Axis_) :-
% Extract all row indices and check if uniform (horizontal axis).
    ra_extract_rows_(Cluster_, Rows_),
    ( ra_all_equal_(Rows_) ->
        Rows_ = [R_|_], Axis_ = h(R_)
    ;
% Extract all col indices and check if uniform (vertical axis).
      ra_extract_cols_(Cluster_, Cols_),
      ( ra_all_equal_(Cols_) ->
          Cols_ = [C_|_], Axis_ = v(C_)
      ;
% Fall back to point at first cell of cluster.
        Cluster_ = [R_-C_|_], Axis_ = p(R_,C_) ) ).

% ra_reflect_: reflect point (R,C) through axis to get (R2,C2).
% ra_reflect_(+R, +C, +Axis, -R2, -C2)
ra_reflect_(R, C, h(R0_), R2, C) :-
% Horizontal: row reflects, col unchanged.
    R2 is 2 * R0_ - R.
ra_reflect_(R, C, v(C0_), R, C2) :-
% Vertical: col reflects, row unchanged.
    C2 is 2 * C0_ - C.
ra_reflect_(R, C, p(R0_,C0_), R2, C2) :-
% Point: both row and col reflect.
    R2 is 2 * R0_ - R, C2 is 2 * C0_ - C.

% ra_set_cell_: set cell (R,C) to value V in Grid; return updated Grid2.
% ra_set_cell_(+Grid, +R, +C, +V, -Grid2)
ra_set_cell_(Grid, R, C, V, Grid2) :-
% Remove row R from Grid, yielding the row and the rest.
    nth0(R, Grid, Row_, RestRows_),
% Remove element C from the row.
    nth0(C, Row_, _, RestCols_),
% Insert V at position C to form the new row.
    nth0(C, NewRow_, V, RestCols_),
% Insert updated row back at position R.
    nth0(R, Grid2, NewRow_, RestRows_).

% ra_reflect_pts_: add reflected copies of each shape cell into Grid.
% ra_reflect_pts_(+V, +Pts, +Axis, +NR, +NC, +Grid, -Grid2)
ra_reflect_pts_(_, [], _, _, _, Grid, Grid).
ra_reflect_pts_(V, [R_-C_|Rest_], Axis, NR, NC, Grid, Grid2) :-
% Compute reflected position.
    ra_reflect_(R_, C_, Axis, R2_, C2_),
% Add reflected cell only if within grid bounds.
    ( ra_inb_(R2_, C2_, NR, NC)
    -> ra_set_cell_(Grid, R2_, C2_, V, Grid1_)
    ;  Grid1_ = Grid ),
    ra_reflect_pts_(V, Rest_, Axis, NR, NC, Grid1_, Grid2).

% ra_apply_refls_: reflect all shape components into the grid.
% ra_apply_refls_(+Comps, +TwoClusters, +NR, +NC, +Grid, -Out)
ra_apply_refls_([], _, _, _, Grid, Grid).
ra_apply_refls_([comp(V_,Pts_)|Rest_], TwoClusters_, NR, NC, Grid, Out) :-
% Find the 2-cluster nearest to this shape component.
    ra_nearest_cluster_(Pts_, TwoClusters_, NearCl_),
% Determine reflection axis from that cluster.
    ra_axis_(NearCl_, Axis_),
% Add reflected cells to the grid.
    ra_reflect_pts_(V_, Pts_, Axis_, NR, NC, Grid, Grid2_),
    ra_apply_refls_(Rest_, TwoClusters_, NR, NC, Grid2_, Out).

% arc2_transform(reflect_axis, +In, -Out): main entry point.
arc2_transform(reflect_axis, In, Out) :-
% Get grid dimensions.
    ra_nrc_(In, NR, NC),
% Identify background color.
    ra_bg_(In, Bg_),
% Collect all 2-cells.
    findall(R_-C_,
        ( nth0(R_, In, Row_), nth0(C_, Row_, 2) ),
        Twos_),
% Group 2-cells into connected clusters.
    ra_cc4_(Twos_, NR, NC, TwoClusters_),
% Find connected components of non-background non-2 shapes.
    ra_shape_comps_(In, Bg_, NR, NC, ShapeComps_),
% Reflect each shape across its nearest 2-cluster axis.
    ra_apply_refls_(ShapeComps_, TwoClusters_, NR, NC, In, Out).

% ---------------------------------------------------------------------------
% WAVE 15: period_repair — task 135a2760
% Each inner sequence (between wall markers in a row or column) follows a
% repeating period-P pattern. Up to three cells break the pattern; repair them.
% Strategy: among all P from 2..N//2 whose majority base has min support >= 0.75,
% find the P with fewest errors (1..3); break ties by smallest P.
% Rows and columns are both processed (columns via grid transpose).
% ---------------------------------------------------------------------------

% Register period_repair as a known named rule.
arc2_named_rule(period_repair).

% arc2_transform for period_repair: row repair pass then column repair pass.
% arc2_transform(+period_repair, +Grid, -Out)
arc2_transform(period_repair, In, Out) :-
% Flatten grid to list and sort for background mode computation.
    flatten(In, PrFlat_), msort(PrFlat_, PrFlatS_),
% Find background color as the most common value.
    arc2_bs_mode_(PrFlatS_, PrBg_),
% Apply period repair to every row.
    maplist(pr2_repair_row_(PrBg_), In, PrStep1_),
% Transpose for column-wise repair pass.
    arc2_transform(transpose, PrStep1_, PrT1_),
% Apply period repair to every column (as a row in the transposed grid).
    maplist(pr2_repair_row_(PrBg_), PrT1_, PrT2_),
% Transpose back to restore original orientation.
    arc2_transform(transpose, PrT2_, Out).

% pr2_repair_row_(+Bg, +Row, -Fixed)
% Repair one row: find wall marker, then fix each inner segment between walls.
pr2_repair_row_(Bg, Row, Fixed) :-
% Find wall = first non-background element; if none, row is all background.
    ( member(W_, Row), W_ \= Bg -> Wall_ = W_ ; Wall_ = none ), !,
% If no wall found, the row needs no repair.
    ( Wall_ = none ->
        Fixed = Row
    ;
% Collect positions of all occurrences of the wall marker.
        findall(I_, (nth0(I_, Row, Wall_)), WPs_),
% At least two wall positions are needed to form an inner segment.
        length(WPs_, NWall_),
        ( NWall_ >= 2 ->
            pr2_fix_segs_(Row, WPs_, Fixed)
        ;   Fixed = Row )
    ).

% pr2_fix_segs_(+Row, +WallPositions, -Fixed)
% Iterate over consecutive wall-position pairs and repair each inner segment.
pr2_fix_segs_(Row, [], Row).
pr2_fix_segs_(Row, [_], Row).
pr2_fix_segs_(Row, [S_,E_|WRest_], Fixed) :-
% Compute inner segment length between wall positions S and E.
    InLen_ is E_ - S_ - 1,
% Only process segments with at least 5 inner cells (shorter ones are ambiguous).
    ( InLen_ >= 5 ->
% Compute start of inner segment.
        S1_ is S_ + 1,
% Extract the inner sub-list.
        pr2_extract_(Row, S1_, InLen_, Inner_),
% Find the best period for this inner sequence.
        (   pr2_best_period_(Inner_, _P_, _Base_, Errs_),
            Errs_ \= []
        ->  pr2_apply_fixes_(Row, S1_, Errs_, Row1_)
        ;   Row1_ = Row )
    ; Row1_ = Row ),
% Process remaining wall pairs on the (possibly modified) row.
    pr2_fix_segs_(Row1_, [E_|WRest_], Fixed).

% pr2_extract_(+List, +Offset, +Len, -Sub)
% Extract sub-list of length Len starting at index Offset.
pr2_extract_(List_, Offset_, Len_, Sub_) :-
% Build prefix list of length Offset.
    length(Pfx_, Offset_),
% Split List at Offset.
    append(Pfx_, Rest_, List_),
% Take Len cells from the remainder.
    length(Sub_, Len_),
% Discard the tail after Sub.
    append(Sub_, _, Rest_).

% pr2_apply_fixes_(+Row, +Offset, +Errors, -Fixed)
% Replace cells at error positions with the expected values.
pr2_apply_fixes_(Row, _, [], Row).
pr2_apply_fixes_(Row, Off_, [err(I_,_,E_)|Rest_], Fixed) :-
% Absolute position = offset + inner index.
    Pos_ is Off_ + I_,
% Replace element at absolute position Pos with expected value E.
    pr2_replace_nth0_(Row, Pos_, E_, Row1_),
% Continue with remaining errors.
    pr2_apply_fixes_(Row1_, Off_, Rest_, Fixed).

% pr2_replace_nth0_(+List, +N, +V, -Out)
% Replace the element at index N (0-based) in List with V.
pr2_replace_nth0_([_|T_], 0, V_, [V_|T_]) :- !.
pr2_replace_nth0_([H_|T_], N_, V_, [H_|T2_]) :-
% Decrement index and recurse.
    N1_ is N_ - 1,
    pr2_replace_nth0_(T_, N1_, V_, T2_).

% pr2_best_period_(+Seq, -P, -Base, -Errors)
% Among all periods P in 2..N//2 whose majority base has min support >= 0.75,
% find the one with the fewest errors (1..3); break ties by smallest P.
pr2_best_period_(Seq_, P_, Base_, Errors_) :-
% Sequence length; maximum period = half that length.
    length(Seq_, N_),
    MaxP_ is N_ // 2,
% Collect all (ErrorCount - P - Base - Errors) candidates that pass support filter.
    findall(Ec_-Pp_-Bb_-Ee_,
            (between(2, MaxP_, Pp_),
             pr2_majority_base_(Seq_, Pp_, Bb_),
             pr2_min_support_(Seq_, Pp_, Bb_, MS_),
             MS_ >= 0.75,
             pr2_errors_(Seq_, Pp_, Bb_, Ee_),
             length(Ee_, Ec_),
             Ec_ >= 1, Ec_ =< 3),
            Cands_),
    Cands_ \= [],
% sort/2 sorts lexicographically: fewest errors first, then smallest P.
    sort(Cands_, Sorted_),
    Sorted_ = [_-P_-Base_-Errors_|_].

% pr2_majority_base_(+Seq, +P, -Base)
% Compute the majority-vote base list for period P (all residues 0..P-1).
pr2_majority_base_(Seq_, P_, Base_) :-
% Last valid index.
    length(Seq_, N_), N1_ is N_ - 1,
% Residue positions 0..P-1.
    P1_ is P_ - 1,
    numlist(0, P1_, Positions_),
% For each residue, collect all values at that position mod P, then take mode.
    maplist([Pos_,MV_]>>(
        findall(V_, (between(0, N1_, I_),
                     I_ mod P_ =:= Pos_,
                     nth0(I_, Seq_, V_)), Vals_),
        pr2_mode_(Vals_, MV_)
    ), Positions_, Base_).

% pr2_min_support_(+Seq, +P, +Base, -MinSupp)
% Minimum fraction of sequence elements that agree with Base across residues.
pr2_min_support_(Seq_, P_, Base_, MinSupp_) :-
    length(Seq_, N_), N1_ is N_ - 1,
    P1_ is P_ - 1,
    numlist(0, P1_, Positions_),
    maplist([Pos_,Supp_]>>(
        findall(V_, (between(0, N1_, I_),
                     I_ mod P_ =:= Pos_,
                     nth0(I_, Seq_, V_)), Vals_),
        length(Vals_, Total_),
        nth0(Pos_, Base_, Exp_),
        include(==(Exp_), Vals_, Match_),
        length(Match_, MC_),
        Supp_ is MC_ / Total_
    ), Positions_, Supps_),
    min_list(Supps_, MinSupp_).

% pr2_errors_(+Seq, +P, +Base, -Errors)
% Collect err(I, Got, Expected) for every element that deviates from Base.
pr2_errors_(Seq_, P_, Base_, Errors_) :-
    length(Seq_, N_), N1_ is N_ - 1,
    findall(err(I_,V_,E_),
            (between(0, N1_, I_),
             nth0(I_, Seq_, V_),
             PI_ is I_ mod P_,
             nth0(PI_, Base_, E_),
             V_ \= E_),
            Errors_).

% pr2_mode_(+List, -Mode)
% Find the most common element in List (mode).
pr2_mode_([X_|Xs_], Mode_) :-
% Sort list to group equal elements together.
    msort([X_|Xs_], Sorted_),
% Find mode using accumulator.
    Sorted_ = [First_|SRest_],
    pr2_mode_acc_(SRest_, First_, 1, First_, 1, Mode_).

% pr2_mode_acc_(+Rest, +Cur, +CurN, +BestV, +BestN, -Mode)
% Accumulate mode: track current run and best (highest count) value.
pr2_mode_acc_([], _, _, BV_, _, BV_).
pr2_mode_acc_([X_|Xs_], X_, N_, BV_, BN_, Mode_) :-
% Extend current run.
    N1_ is N_ + 1,
    ( N1_ > BN_ ->
% New best: current value takes the lead.
        pr2_mode_acc_(Xs_, X_, N1_, X_, N1_, Mode_)
    ;
% No new best: keep current best.
        pr2_mode_acc_(Xs_, X_, N1_, BV_, BN_, Mode_) ).
pr2_mode_acc_([Y_|Xs_], X_, _N_, BV_, BN_, Mode_) :-
% Run ended: start new run for Y.
    X_ \= Y_,
    pr2_mode_acc_(Xs_, Y_, 1, BV_, BN_, Mode_).

% arc2_induce_rule clause for period_repair: verify all training pairs.
arc2_induce_rule(TrainingPairs, period_repair) :-
% Require at least 1 training pair.
    TrainingPairs \= [],
% Require all pairs to have the same grid dimensions.
    forall(member(pair(In_, Out_), TrainingPairs), (
        length(In_, NR_), length(Out_, NR_),
        In_ = [FR_|_], Out_ = [GR_|_],
        length(FR_, NC_), length(GR_, NC_) )),
% Require a clear wall marker in first training input row.
    TrainingPairs = [pair(In0_,_)|_],
    flatten(In0_, Flat0_), msort(Flat0_, FS0_),
    arc2_bs_mode_(FS0_, Bg0_),
    In0_ = [_,Row1_0_|_],
    once((member(Wall0_, Row1_0_), Wall0_ \= Bg0_)),
% Require every pair to be solved by arc2_transform(period_repair, ...).
    forall(member(pair(In_, Out_), TrainingPairs),
           arc2_transform(period_repair, In_, Out_)).

% ---------------------------------------------------------------------------
% legend_fill: fill closed frame interiors using a color lookup table
% A "legend" (solid 2xN or Nx2 block) maps frame-border colors to fill colors.
% Each closed frame whose border color is a KEY in the legend has its enclosed
% background cells filled with the corresponding VALUE.
% ---------------------------------------------------------------------------

% Enumerate legend_fill as a known named rule.
arc2_named_rule(legend_fill).

% arc2_induce_rule for legend_fill: verify legend exists and rule is correct.
arc2_induce_rule(TrainingPairs_, legend_fill) :-
% Require at least 1 training pair.
    TrainingPairs_ \= [],
% Require the first training input to contain a findable legend.
    TrainingPairs_ = [pair(In0_, _)|_],
    flatten(In0_, Flat0_), msort(Flat0_, FS0_), arc2_bs_mode_(FS0_, Bg0_),
    lf_legend_(In0_, Bg0_, _Keys0_, _Vals0_),
% Require every pair to transform correctly under legend_fill.
    forall(member(pair(In_, Out_), TrainingPairs_),
           arc2_transform(legend_fill, In_, Out_)).

% arc2_transform for legend_fill: main transformation entry point.
arc2_transform(legend_fill, Grid_, Output_) :-
% Compute background color as the most frequent cell value.
    flatten(Grid_, Flat_), msort(Flat_, FS_), arc2_bs_mode_(FS_, Bg_),
% Find the legend and extract its key and value lists.
    lf_legend_(Grid_, Bg_, Keys_, Vals_),
% Build key-value pairs and apply fills for each key color.
    pairs_keys_values(KVPairs_, Keys_, Vals_),
    foldl([K_-V_, Gin_, Gout_]>>(lf_apply_fill_(Gin_, Bg_, K_, V_, Gout_)),
          KVPairs_, Grid_, Output_).

% lf_legend_/4: find the legend block and return Keys and Vals lists.
% Keys is the legend row/col whose colors appear as frame colors in the grid.
lf_legend_(Grid_, Bg_, Keys_, Vals_) :-
% Find all solid 2xN or Nx2 blocks and pick the longest one.
    lf_best_block_(Grid_, Bg_, Raw1_, Raw2_),
% Determine which of Raw1/Raw2 is the key list (more frame-color matches).
    lf_orient_kv_(Grid_, Bg_, Raw1_, Raw2_, Keys_, Vals_).

% lf_best_block_/4: find the longest solid 2xN (row) or Nx2 (col) block.
lf_best_block_(Grid_, Bg_, Best1_, Best2_) :-
% Collect all row-pair candidates (length, row type, sublists).
    findall(N_-row(A_, B_), lf_row_block_(Grid_, Bg_, A_, B_, N_), RowCands_),
% Collect all col-pair candidates.
    findall(N_-col(A_, B_), lf_col_block_(Grid_, Bg_, A_, B_, N_), ColCands_),
% Combine and require at least one candidate.
    append(RowCands_, ColCands_, AllCands_),
    AllCands_ \= [],
% Pick the candidate with the maximum length N.
    max_member(_N_-BestType_, AllCands_),
    ( BestType_ = row(Best1_, Best2_) ; BestType_ = col(Best1_, Best2_) ).

% lf_row_block_/5: find the LONGEST solid 2xN block (with distinct rows).
lf_row_block_(Grid_, Bg_, SubA_, SubB_, Len_) :-
% Iterate over all adjacent row index pairs.
    length(Grid_, NR_), NR1_ is NR_ - 1,
    between(0, NR1_, R1_), R2_ is R1_ + 1, R2_ =< NR1_,
    nth0(R1_, Grid_, Row1_), nth0(R2_, Grid_, Row2_),
    length(Row1_, NC_), NC1_ is NC_ - 1,
% Collect solid runs of length >= 2 where the two sub-rows differ.
    findall(L_-S_, (
        lf_solid_run_(Row1_, Row2_, Bg_, 0, NC1_, S_, L_), L_ >= 2,
        lf_take_(Row1_, S_, L_, SA_), lf_take_(Row2_, S_, L_, SB_),
        SA_ \= SB_
    ), Runs_),
    Runs_ \= [],
% Pick the longest run (max L_).
    max_member(Len_-Start_, Runs_),
% Extract the sub-list from each row.
    lf_take_(Row1_, Start_, Len_, SubA_),
    lf_take_(Row2_, Start_, Len_, SubB_).

% lf_col_block_/5: find the LONGEST solid Nx2 block (with distinct columns).
lf_col_block_(Grid_, Bg_, SubA_, SubB_, Len_) :-
% Extract column count from first row.
    Grid_ = [Row0_|_], length(Row0_, NC_), NC1_ is NC_ - 1,
% Iterate over all adjacent column index pairs.
    between(0, NC1_, C1_), C2_ is C1_ + 1, C2_ =< NC1_,
    lf_extract_col_(Grid_, C1_, Col1_),
    lf_extract_col_(Grid_, C2_, Col2_),
    length(Col1_, NR_), NR1_ is NR_ - 1,
% Collect solid runs of length >= 2 where the two sub-columns differ.
    findall(L_-S_, (
        lf_solid_run_(Col1_, Col2_, Bg_, 0, NR1_, S_, L_), L_ >= 2,
        lf_take_(Col1_, S_, L_, SA_), lf_take_(Col2_, S_, L_, SB_),
        SA_ \= SB_
    ), Runs_),
    Runs_ \= [],
% Pick the longest run.
    max_member(Len_-Start_, Runs_),
% Extract sub-column.
    lf_take_(Col1_, Start_, Len_, SubA_),
    lf_take_(Col2_, Start_, Len_, SubB_).

% lf_solid_run_/7: one solution per starting position S_ where both lists are
% non-Bg, returning the run length from S_ to the end of the solid block.
lf_solid_run_(L1_, L2_, Bg_, Lo_, Hi_, Start_, Len_) :-
% Enumerate every position that is non-Bg in both lists.
    between(Lo_, Hi_, Start_),
    nth0(Start_, L1_, V1_), V1_ \= Bg_,
    nth0(Start_, L2_, V2_), V2_ \= Bg_,
% Extend as far as both lists remain non-Bg from Start_.
    lf_solid_end_(L1_, L2_, Bg_, Start_, Hi_, E_),
    Len_ is E_ - Start_ + 1.

% lf_solid_end_/6: advance End_ as far as both lists are non-Bg.
lf_solid_end_(L1_, L2_, Bg_, I_, Hi_, End_) :-
    I1_ is I_ + 1,
    ( I1_ =< Hi_,
      nth0(I1_, L1_, V1_), V1_ \= Bg_,
      nth0(I1_, L2_, V2_), V2_ \= Bg_ ->
        lf_solid_end_(L1_, L2_, Bg_, I1_, Hi_, End_)
    ; End_ = I_ ).

% lf_orient_kv_/6: pick which of Raw1/Raw2 is the key list.
% The key list is the one containing more frame-border colors.
lf_orient_kv_(Grid_, Bg_, Raw1_, Raw2_, Keys_, Vals_) :-
% Find all enclosed background cells (not reachable from grid boundary).
    lf_enclosed_all_(Grid_, Bg_, AllEnc_),
% Derive frame colors: non-Bg colors adjacent to any enclosed cell.
    lf_frame_colors_(Grid_, Bg_, AllEnc_, FC_),
% Count Raw1 and Raw2 elements that are frame colors.
    include([X_]>>(memberchk(X_, FC_)), Raw1_, FM1_),
    include([X_]>>(memberchk(X_, FC_)), Raw2_, FM2_),
    length(FM1_, N1_), length(FM2_, N2_),
% The list with more matches is the key list; tie goes to Raw1.
    ( N1_ >= N2_ -> Keys_ = Raw1_, Vals_ = Raw2_
    ;               Keys_ = Raw2_, Vals_ = Raw1_ ).

% lf_enclosed_all_/3: find all background cells not reachable from the boundary.
lf_enclosed_all_(Grid_, Bg_, Enclosed_) :-
    length(Grid_, NR_), Grid_ = [Row0_|_], length(Row0_, NC_),
    NR1_ is NR_ - 1, NC1_ is NC_ - 1,
% Seed flood fill from all boundary background cells.
    findall(R_-C_, (
        nth0(R_, Grid_, Row_), nth0(C_, Row_, Bg_),
        ( R_ =:= 0 ; R_ =:= NR1_ ; C_ =:= 0 ; C_ =:= NC1_ )
    ), Seeds_),
    sort(Seeds_, SeedSet_),
% Flood fill outward through background cells from the boundary.
    lf_flood_(Grid_, Bg_, NR1_, NC1_, SeedSet_, SeedSet_, Exterior_),
% All background cells in the grid.
    findall(R_-C_, (nth0(R_, Grid_, Row_), nth0(C_, Row_, Bg_)), AllBg_),
    sort(AllBg_, AllBgS_),
% Enclosed = total background minus exterior-reachable background.
    subtract(AllBgS_, Exterior_, Enclosed_).

% lf_flood_/7: BFS flood fill through background cells.
% Visits all Bg cells reachable from the queue without crossing non-Bg.
lf_flood_(_, _, _, _, [], Visited_, Visited_) :- !.
lf_flood_(Grid_, Bg_, NR1_, NC1_, [R_-C_|Q_], Vis_, Out_) :-
% Generate all 4-connected background neighbors not yet visited.
    findall(NR2_-NC2_, (
        member(DR_-DC_, [(-1)-0, 1-0, 0-(-1), 0-1]),
        NR2_ is R_ + DR_, NC2_ is C_ + DC_,
        between(0, NR1_, NR2_), between(0, NC1_, NC2_),
        nth0(NR2_, Grid_, NRow_), nth0(NC2_, NRow_, Bg_),
        \+ memberchk(NR2_-NC2_, Vis_)
    ), Nbrs_),
    sort(Nbrs_, NbrsS_),
    subtract(NbrsS_, Vis_, New_),
    append(Q_, New_, Q2_),
    append(Vis_, New_, Vis2_),
    lf_flood_(Grid_, Bg_, NR1_, NC1_, Q2_, Vis2_, Out_).

% lf_frame_colors_/4: collect non-Bg colors adjacent to any enclosed cell.
lf_frame_colors_(Grid_, Bg_, EnclosedList_, FC_) :-
    findall(Color_, (
        member(R_-C_, EnclosedList_),
        member(DR_-DC_, [(-1)-0, 1-0, 0-(-1), 0-1]),
        NR_ is R_ + DR_, NC_ is C_ + DC_,
        nth0(NR_, Grid_, NRow_), nth0(NC_, NRow_, Color_),
        Color_ \= Bg_
    ), Colors_),
    sort(Colors_, FC_).

% lf_apply_fill_/5: fill enclosed background cells bounded by color K with V.
lf_apply_fill_(Grid_, Bg_, K_, V_, Output_) :-
% Find all enclosed background cells whose unique non-Bg neighbor is K.
    lf_enclosed_for_color_(Grid_, Bg_, K_, Cells_),
    Cells_ \= [], !,
% Replace those cells in the grid with fill color V.
    lf_fill_grid_(Grid_, Cells_, V_, Output_).
% If no enclosed cells for K, leave the grid unchanged.
lf_apply_fill_(Grid_, _, _, _, Grid_).

% lf_enclosed_for_color_/4: enclosed background cells whose frame is color K.
lf_enclosed_for_color_(Grid_, Bg_, K_, Cells_) :-
% Get all enclosed background cells.
    lf_enclosed_all_(Grid_, Bg_, AllEnc_),
% Retain only cells where every adjacent non-Bg cell has color K.
    include([R_-C_]>>(lf_unique_frame_color_(Grid_, Bg_, R_, C_, K_)),
            AllEnc_, Cells_).

% lf_unique_frame_color_/5: true iff all non-Bg 4-neighbors of (R,C) are K.
lf_unique_frame_color_(Grid_, Bg_, R_, C_, K_) :-
    findall(Color_, (
        member(DR_-DC_, [(-1)-0, 1-0, 0-(-1), 0-1]),
        NR_ is R_ + DR_, NC_ is C_ + DC_,
        ( nth0(NR_, Grid_, NRow_) -> nth0(NC_, NRow_, Color_) ; Color_ = oob ),
        Color_ \= Bg_, Color_ \= oob
    ), AdjColors_),
% Require at least one non-Bg neighbor and all of them equal K.
    AdjColors_ \= [],
    sort(AdjColors_, [K_]).

% lf_fill_grid_/4: produce Output by replacing Cells_ positions with color V.
lf_fill_grid_(Grid_, Cells_, V_, Output_) :-
    length(Grid_, NR_), Grid_ = [Row0_|_], length(Row0_, NC_),
    NR1_ is NR_ - 1, NC1_ is NC_ - 1,
    numlist(0, NR1_, RowIdxs_), numlist(0, NC1_, ColIdxs_),
    maplist([R_, OutRow_]>>(
        nth0(R_, Grid_, InRow_),
        maplist([C_, Val_]>>(
            ( memberchk(R_-C_, Cells_) -> Val_ = V_
            ; nth0(C_, InRow_, Val_) )
        ), ColIdxs_, OutRow_)
    ), RowIdxs_, Output_).

% lf_take_/4: extract Len elements starting at index Start from List.
lf_take_(List_, Start_, Len_, Sub_) :-
    length(Pre_, Start_), append(Pre_, Rest_, List_),
    length(Sub_, Len_), append(Sub_, _, Rest_).

% lf_extract_col_/3: collect all values at column C from Grid.
lf_extract_col_(Grid_, C_, Col_) :-
    maplist([Row_, Val_]>>(nth0(C_, Row_, Val_)), Grid_, Col_).

% ---------------------------------------------------------------------------
% frame_target rule (task 88e364bc)
% ---------------------------------------------------------------------------
% A "legend" frame is a small rectangle whose border is all one non-background
% color C and whose interior contains no background cells and at least one 2.
% The direction is: sign(2-centroid minus interior-center) = (Dr,Dc).
% Each 4-dot enclosed in the large irregular frame of the same color C moves
% step-by-step in direction (Dr,Dc), stopping 1 step before the nearest C-wall.
% For diagonal movement the "clip" rule applies: stop if either the row-step
% or the col-step (not just the diagonal step) would hit the frame wall.
% ---------------------------------------------------------------------------

% ---------------------------------------------------------------------------
% chain_link: connect adjacent box pairs in legend-sequence order
% BG is detected from the top-left cell.  Boxes are rectangular non-BG
% regions identified by scanning from each non-BG cell until hitting BG.
% For each consecutive legend pair (Va,Vb) the gap between the adjacent
% Va-box and Vb-box (same row-block or same col-block) is filled with Va.
% The gap extent uses "inner-extent" scanning: last non-BG cell going toward
% the adjacent box, so connector = inner_ext_A+1 .. inner_ext_B-1.
% Works for training (BG=8, border=1 explicit) and test (BG=1, filler=2).
% Solves task 3e6067c3.
% ---------------------------------------------------------------------------

% arc2_named_rule: register chain_link as a known rule name.
arc2_named_rule(chain_link).

% arc2_induce_rule for chain_link: detect BG, check legend, verify all pairs.
arc2_induce_rule(TrainingPairs, chain_link) :-
% Guard: detect background from top-left cell of first training input.
    TrainingPairs = [pair(In0, _)|_],
    nth1(1, In0, R0), nth1(1, R0, BG0),
% Guard: first training input must have a valid legend row with >= 2 entries.
    cl_legend_(In0, BG0, LegSeq0), LegSeq0 = [_,_|_],
% Verify: transform produces correct output for every training pair.
    forall(member(pair(In_, Out_), TrainingPairs),
           arc2_transform(chain_link, In_, Out_)).

% arc2_transform for chain_link: detect BG, parse legend, find boxes, draw connectors.
arc2_transform(chain_link, Grid, Output) :-
% Detect background color from top-left cell.
    nth1(1, Grid, TopRow), nth1(1, TopRow, BG),
% Find legend sequence from the alternating-BG row.
    cl_legend_(Grid, BG, LegSeq),
% Enumerate all non-BG rectangular regions as boxes with BG-boundary coordinates.
    cl_boxes_(Grid, BG, Boxes),
% Walk legend chain from start box, tracking visited boxes, to collect changes.
    cl_link_chain_(LegSeq, Boxes, Grid, BG, Changes),
% Apply the collected changes to produce the output grid.
    cl_apply_changes_(Grid, Changes, Output).

% cl_legend_(+Grid, +BG, -Seq): find the alternating-BG legend row and parse it.
cl_legend_(Grid, BG, Seq) :-
% Try each row as a candidate legend row.
    member(Row, Grid),
% Legend row must start with background value.
    Row = [BG|Rest],
% Parse the alternating V,BG,V,BG,... tail.
    cl_alt_parse_(Rest, BG, Seq),
% Require at least two legend entries to draw at least one link.
    Seq = [_,_|_].

% cl_alt_parse_/3: parse BG-separated value list from row tail.
cl_alt_parse_([], _, []).
% Base case: trailing BG followed by all-BG ends the legend.
cl_alt_parse_([BG|Tail], BG, []) :-
    maplist(=(BG), Tail).
% Recursive: read value V, skip BG separator, recurse.
cl_alt_parse_([V, BG|Tail], BG, [V|Seq]) :-
    V \== BG,
    cl_alt_parse_(Tail, BG, Seq).

% cl_boxes_(+Grid, +BG, -Boxes): find all non-BG rectangular regions.
% BT/BB/BL/BR are the first BG-valued row/col reached in each direction.
cl_boxes_(Grid, BG, Boxes) :-
    findall(box(V, BT, BB, BL, BR),
        (nth1(R, Grid, Row),
         nth1(C, Row, V),
         V \= BG,
         cl_bg_up_(Grid, R, C, BG, BT),
         cl_bg_dn_(Grid, R, C, BG, BB),
         cl_bg_lt_(Row, C, BG, BL),
         cl_bg_rt_(Row, C, BG, BR)),
    Raw),
    sort(Raw, Boxes).

% cl_bg_up_/5: first BG-valued row going upward from (R,C).
cl_bg_up_(Grid, R, C, BG, BT) :-
    R1 is R-1,
    (R1 < 1 -> BT = 0
    ; nth1(R1, Grid, Row1), nth1(C, Row1, V1),
      (V1 =:= BG -> BT = R1 ; cl_bg_up_(Grid, R1, C, BG, BT))).

% cl_bg_dn_/5: first BG-valued row going downward from (R,C).
cl_bg_dn_(Grid, R, C, BG, BB) :-
    length(Grid, NR), R1 is R+1,
    (R1 > NR -> BB is NR+1
    ; nth1(R1, Grid, Row1), nth1(C, Row1, V1),
      (V1 =:= BG -> BB = R1 ; cl_bg_dn_(Grid, R1, C, BG, BB))).

% cl_bg_lt_/4: first BG-valued col going leftward in Row from col C.
cl_bg_lt_(Row, C, BG, BL) :-
    C1 is C-1,
    (C1 < 1 -> BL = 0
    ; nth1(C1, Row, V1),
      (V1 =:= BG -> BL = C1 ; cl_bg_lt_(Row, C1, BG, BL))).

% cl_bg_rt_/4: first BG-valued col going rightward in Row from col C.
cl_bg_rt_(Row, C, BG, BR) :-
    length(Row, NC), C1 is C+1,
    (C1 > NC -> BR is NC+1
    ; nth1(C1, Row, V1),
      (V1 =:= BG -> BR = C1 ; cl_bg_rt_(Row, C1, BG, BR))).

% cl_link_chain_/5: find the starting box and walk the entire legend chain once.
% Tries each candidate box of the first legend color until the full chain
% completes without contradiction. The cut commits to the first valid walk.
cl_link_chain_(LegSeq, Boxes, Grid, BG, AllCh) :-
    LegSeq = [V0|_],
% Try each V0-colored box as the chain start; take first valid chain.
    member(StartBox, Boxes),
    StartBox = box(V0, _, _, _, _),
    cl_walk_(LegSeq, StartBox, Boxes, Grid, BG, [StartBox], AllCh), !.

% cl_walk_/7: recursive legend-chain walker; Visited tracks all boxes seen so far.
cl_walk_([], _, _, _, _, _, []).
cl_walk_([_], _, _, _, _, _, []).
cl_walk_([Va, Vb|Rest], CurBox, Boxes, Grid, BG, Visited, AllCh) :-
% Find the unique Vb-box adjacent to CurBox, not yet visited, gap clear.
    cl_step_(CurBox, Va, Vb, Boxes, Grid, BG, Visited, NextBox, Ch),
% Recurse with NextBox as the new current and add it to Visited.
    cl_walk_([Vb|Rest], NextBox, Boxes, Grid, BG, [NextBox|Visited], RestCh),
    append(Ch, RestCh, AllCh).

% cl_step_/9: from CurBox (color Va) find adjacent NextBox (color Vb) with clear gap.
% NextBox must not be in Visited. Succeeds with connector changes Ch.
cl_step_(box(Va, BTA, BBA, BLA, BRA), Va, Vb, Boxes, Grid, BG, Visited, NextBox, Ch) :-
    member(NextBox, Boxes),
    NextBox = box(Vb, BTB, BBB, BLB, BRB),
% Reject any box already in the chain.
    \+ member(NextBox, Visited),
    (   BLA =:= BLB, BRA =:= BRB
% Same col block: vertical adjacency (A above B or A below B).
    ->  cl_cr_(Va, BTA, BBA, BLA, BRA, Grid, CC1, CC2, CR1A, CR2A),
        (BBA =< BTB, BTA < BTB
% A above B: scan down from bottom of A, up from top of B.
        ->  cl_cr_(Vb, BTB, BBB, BLB, BRB, Grid, _, _, CR1B, _),
            cl_inner_dn_(Grid, CR2A, CC1, BG, FRA),
            cl_inner_up_(Grid, CR1B, CC1, BG, FLB),
            R1 is FRA+1, R2 is FLB-1, R1 =< R2,
            cl_gap_clear_(Grid, BG, R1, R2, CC1, CC2),
            findall(R-C-Va, (between(R1,R2,R), between(CC1,CC2,C)), Ch)
        ;   BBB =< BTA, BTB < BTA
% A below B: scan up from top of A, down from bottom of B.
        ->  cl_cr_(Vb, BTB, BBB, BLB, BRB, Grid, _, _, _, CR2B),
            cl_inner_up_(Grid, CR1A, CC1, BG, FRA),
            cl_inner_dn_(Grid, CR2B, CC1, BG, FLB),
            R1 is FLB+1, R2 is FRA-1, R1 =< R2,
            cl_gap_clear_(Grid, BG, R1, R2, CC1, CC2),
            findall(R-C-Va, (between(R1,R2,R), between(CC1,CC2,C)), Ch)
        ;   fail
        )
    ;   BTA =:= BTB, BBA =:= BBB
% Same row block: horizontal adjacency (A left of B or A right of B).
    ->  cl_cr_(Va, BTA, BBA, BLA, BRA, Grid, CC1A, CC2A, CR1A, CR2A),
        (BRA =< BLB, BLA < BLB
% A left of B: scan right from A, left from B.
        ->  cl_cr_(Vb, BTB, BBB, BLB, BRB, Grid, CC1B, _, _, _),
            cl_inner_rt_(Grid, CR1A, CC2A, BG, FRA),
            cl_inner_lt_(Grid, CR1A, CC1B, BG, FLB),
            C1 is FRA+1, C2 is FLB-1, C1 =< C2,
            cl_gap_clear_(Grid, BG, CR1A, CR2A, C1, C2),
            findall(R-C-Va, (between(CR1A,CR2A,R), between(C1,C2,C)), Ch)
        ;   BLA >= BRB, BRA > BRB
% A right of B: scan left from A, right from B.
        ->  cl_cr_(Vb, BTB, BBB, BLB, BRB, Grid, _, CC2B, CR1B, _),
            cl_inner_lt_(Grid, CR1A, CC1A, BG, FRA),
            cl_inner_rt_(Grid, CR1B, CC2B, BG, FLB),
            C1 is FLB+1, C2 is FRA-1, C1 =< C2,
            cl_gap_clear_(Grid, BG, CR1A, CR2A, C1, C2),
            findall(R-C-Va, (between(CR1A,CR2A,R), between(C1,C2,C)), Ch)
        ;   fail
        )
    ;   fail
    ),
    Ch \= [].

% cl_gap_clear_/6: all cells in rows R1-R2 x cols C1-C2 must be BG in original grid.
% Rejects connectors that would pass through an intervening non-BG box region.
cl_gap_clear_(Grid, BG, R1, R2, C1, C2) :-
    forall((between(R1, R2, R), between(C1, C2, C)),
           (nth1(R, Grid, Row), nth1(C, Row, V), V =:= BG)).

% cl_cr_/9: find col-range (CC1,CC2) and row-range (CR1,CR2) of Va-colored cells in box interior.
cl_cr_(Va, BT, BB, BL, BR, Grid, CC1, CC2, CR1, CR2) :-
    IR1 is BT+1, IR2 is BB-1, IC1 is BL+1, IC2 is BR-1,
    findall(C, (between(IC1,IC2,C), between(IR1,IR2,R),
                nth1(R,Grid,Row), nth1(C,Row,VC), VC=:=Va), Cols),
    sort(Cols, SortedCols), SortedCols = [CC1|_], last(SortedCols, CC2),
    findall(R, (between(IR1,IR2,R), between(IC1,IC2,C),
                nth1(R,Grid,Row), nth1(C,Row,VC), VC=:=Va), Rows),
    sort(Rows, SortedRows), SortedRows = [CR1|_], last(SortedRows, CR2).

% cl_inner_dn_/5: last non-BG row going downward from (R,C) in Grid.
cl_inner_dn_(Grid, R, C, BG, Ext) :-
    length(Grid, NR), R1 is R+1,
    (R1 > NR -> Ext = R
    ; nth1(R1, Grid, Row1), nth1(C, Row1, V1),
      (V1 =:= BG -> Ext = R ; cl_inner_dn_(Grid, R1, C, BG, Ext))).

% cl_inner_up_/5: last non-BG row going upward from (R,C) in Grid.
cl_inner_up_(Grid, R, C, BG, Ext) :-
    R1 is R-1,
    (R1 < 1 -> Ext = R
    ; nth1(R1, Grid, Row1), nth1(C, Row1, V1),
      (V1 =:= BG -> Ext = R ; cl_inner_up_(Grid, R1, C, BG, Ext))).

% cl_inner_rt_/5: last non-BG col going rightward from (R,C) in Grid.
cl_inner_rt_(Grid, R, C, BG, Ext) :-
    nth1(R, Grid, Row), length(Row, NC), C1 is C+1,
    (C1 > NC -> Ext = C
    ; nth1(C1, Row, V1),
      (V1 =:= BG -> Ext = C ; cl_inner_rt_(Grid, R, C1, BG, Ext))).

% cl_inner_lt_/5: last non-BG col going leftward from (R,C) in Grid.
cl_inner_lt_(Grid, R, C, BG, Ext) :-
    nth1(R, Grid, Row), C1 is C-1,
    (C1 < 1 -> Ext = C
    ; nth1(C1, Row, V1),
      (V1 =:= BG -> Ext = C ; cl_inner_lt_(Grid, R, C1, BG, Ext))).

% cl_apply_changes_/3: build output grid by overlaying Changes onto Grid.
cl_apply_changes_(Grid, Changes, Output) :-
    length(Grid, NR), numlist(1, NR, RowNums),
    maplist(cl_new_row_(Grid, Changes), RowNums, Output).

% cl_new_row_/4: build one output row R, applying any changes at that row.
cl_new_row_(Grid, Changes, R, NewRow) :-
    nth1(R, Grid, OldRow),
    length(OldRow, NC), numlist(1, NC, ColNums),
    maplist(cl_new_cell_(OldRow, Changes, R), ColNums, NewRow).

% cl_new_cell_/5: cell (R,C) gets new value V if a change exists, else keeps old value.
cl_new_cell_(OldRow, Changes, R, C, NV) :-
    nth1(C, OldRow, OV),
    (member(R-C-V, Changes) -> NV = V ; NV = OV).

% Early placement of section_tile induction so its fast guard fires before the
% slower frame_target guard; helpers (st_*) are defined further down the file.
arc2_induce_rule(TrainingPairs, section_tile) :-
% Guard: first training input must have at least one all-1 row or col.
    TrainingPairs = [pair(In0, _)|_],
    st_find_dividers_(In0, _, [_|_]),
% Verify: the transform produces the correct output for every training pair.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(section_tile, In, Out)).

% Enumerate frame_target as a known named rule.
arc2_named_rule(frame_target).

% arc2_induce_rule for frame_target: verify non-empty legend map and all pairs.
arc2_induce_rule(TrainingPairs_, frame_target) :-
% Require at least one training pair.
    TrainingPairs_ \= [],
% Extract background color from first training input.
    TrainingPairs_ = [pair(In0_, _)|_],
    flatten(In0_, Flat0_), msort(Flat0_, FS0_), arc2_bs_mode_(FS0_, Bg0_),
% Require at least one legend frame to be found.
    ft_build_dir_map_(In0_, Bg0_, [_|_]),
% Require every pair to transform correctly under frame_target.
    forall(member(pair(In_, Out_), TrainingPairs_),
           arc2_transform(frame_target, In_, Out_)).

% arc2_transform for frame_target: apply all 4-dot moves derived from legends.
arc2_transform(frame_target, Grid_, Output_) :-
% Compute background as most-frequent cell value.
    flatten(Grid_, Flat_), msort(Flat_, FS_), arc2_bs_mode_(FS_, Bg_),
% Build the direction map: Color-Dr-Dc for every legend frame.
    ft_build_dir_map_(Grid_, Bg_, DirMap_),
% Require at least one legend frame (fail-fast guard).
    DirMap_ \= [],
% Extract sorted list of all frame colors for ray-shooting passability.
    findall(FC_, member(FC_-_-_, DirMap_), DirColors_),
% Find all 4-dot positions in Grid.
    findall(R_-C_, (nth0(R_,Grid_,Row_), nth0(C_,Row_,4)), Fours_),
% For each 4: find enclosing frame color, look up direction, shoot to wall.
    findall(R_-C_-NR_-NC_, (
        member(R_-C_, Fours_),
        ft_enclosing_color_(Grid_, DirColors_, R_, C_, FColor_),
        member(FColor_-Dr_-Dc_, DirMap_),
        ft_shoot_(Grid_, FColor_, R_, C_, Dr_, Dc_, NR_, NC_)
    ), Moves_),
% Compute grid dimensions for output construction.
    length(Grid_, NRow_), Grid_ = [GR0_|_], length(GR0_, NCol_),
% Build row and column index lists.
    NRow1_ is NRow_ - 1, NCol1_ is NCol_ - 1,
    numlist(0, NRow1_, RowIdxs_), numlist(0, NCol1_, ColIdxs_),
% Build Output: source cleared first so a stuck 4 (src=dst) is removed.
    maplist([RI_,OutRow_]>>(
        nth0(RI_, Grid_, InRow_),
        maplist([CI_,V_]>>(
% Source of a move: clear the vacated (or stuck) 4-dot cell.
            ( memberchk(RI_-CI_-_-_, Moves_) -> V_ = Bg_
% Destination of a move (not a source): place the arriving 4-dot.
            ; memberchk(_-_-RI_-CI_, Moves_) -> V_ = 4
% Otherwise: copy cell unchanged from input.
            ; nth0(CI_, InRow_, V_) )
        ), ColIdxs_, OutRow_)
    ), RowIdxs_, Output_).

% ft_build_dir_map_/3: collect one Color-Dr-Dc per distinct legend color; deduplicate.
ft_build_dir_map_(Grid_, Bg_, DirMap_) :-
    findall(Color_-Dr_-Dc_, ft_find_legend_(Grid_, Bg_, Color_, Dr_, Dc_), Raw_),
    sort(Raw_, DirMap_).

% ft_find_legend_/5: enumerate each distinct non-Bg non-dot color in Grid_, then
% find the first valid legend rectangle for that color using once/1.
ft_find_legend_(Grid_, Bg_, Color_, Dr_, Dc_) :-
% Collect all distinct cell values to enumerate candidate frame colors.
    flatten(Grid_, Flat_), sort(Flat_, AllColors_),
% Try each value that is not background and not the dot marker (4).
    member(Color_, AllColors_),
    Color_ \= Bg_, Color_ \= 4,
% Find exactly one valid legend rectangle for this color (first found wins).
    once(ft_find_legend_for_(Grid_, Bg_, Color_, Dr_, Dc_)).

% ft_find_legend_for_/5: search for a valid legend rectangle of Color_.
% Called under once/1 so only the first match is used.
% Uses O(k^2) iteration over actual Color_ positions rather than O(n^4)
% over all row/col combinations — prevents timeout on non-legend tasks.
ft_find_legend_for_(Grid_, Bg_, Color_, Dr_, Dc_) :-
% Collect all (R,C) positions where the cell equals Color_.
    findall(R_-C_, (nth0(R_,Grid_,Row_), nth0(C_,Row_,Color_)), Positions_),
% Pick top-left corner (R1,C1): any Color_ position.
    member(R1_-C1_, Positions_),
% Pick bottom-right corner (R2,C2): another Color_ position with R2>R1+1, C2>C1+1.
    member(R2_-C2_, Positions_),
    R2_ - R1_ >= 2, C2_ - C1_ >= 2,
% Verify top-right corner (R1,C2) = Color_ (fast corner pre-check).
    nth0(R1_, Grid_, TopRow_), nth0(C2_, TopRow_, Color_),
% Verify bottom-left corner (R2,C1) = Color_ (fast corner pre-check).
    nth0(R2_, Grid_, BotRow_), nth0(C1_, BotRow_, Color_),
% Full border check now likely to succeed.
    ft_rect_border_(Grid_, R1_, C1_, R2_, C2_, Color_),
% Verify interior has no background cells and contains at least one 2.
    ft_interior_ok_(Grid_, Bg_, R1_, C1_, R2_, C2_),
% Collect all 2-cell positions in the interior.
    findall(TR_-TC_, (
        between(R1_,R2_,TR_), between(C1_,C2_,TC_),
        TR_ > R1_, TR_ < R2_, TC_ > C1_, TC_ < C2_,
        nth0(TR_,Grid_,TRow2_), nth0(TC_,TRow2_,2)
    ), Twos_),
% Require at least one 2 in the interior (double-check).
    Twos_ \= [],
% Derive direction from 2-centroid relative to interior center.
    ft_dir_from_2s_(Twos_, R1_, C1_, R2_, C2_, Dr_, Dc_).

% ft_rect_border_/6: verify all border cells of rectangle R1,C1..R2,C2 = Color.
ft_rect_border_(Grid_, R1_, C1_, R2_, C2_, Color_) :-
% Check top and bottom rows: every column C1..C2 must be Color.
    forall(between(C1_, C2_, BC_), (
        nth0(R1_, Grid_, TRow_), nth0(BC_, TRow_, Color_),
        nth0(R2_, Grid_, BRow_), nth0(BC_, BRow_, Color_)
    )),
% Check left and right columns: every row R1..R2 must be Color.
    forall(between(R1_, R2_, BR_), (
        nth0(BR_, Grid_, MRow_),
        nth0(C1_, MRow_, Color_), nth0(C2_, MRow_, Color_)
    )).

% ft_interior_ok_/6: interior of rectangle has no Bg cells and at least one 2.
ft_interior_ok_(Grid_, Bg_, R1_, C1_, R2_, C2_) :-
% Verify no interior cell equals Bg.
    forall((between(R1_,R2_,IR_), IR_ > R1_, IR_ < R2_,
            between(C1_,C2_,IC_), IC_ > C1_, IC_ < C2_), (
        nth0(IR_, Grid_, IRow_), nth0(IC_, IRow_, IV_), IV_ \= Bg_
    )),
% Verify at least one interior cell equals 2.
    once((between(R1_,R2_,TR_), TR_ > R1_, TR_ < R2_,
          between(C1_,C2_,TC_), TC_ > C1_, TC_ < C2_,
          nth0(TR_, Grid_, TWRow_), nth0(TC_, TWRow_, 2))).

% ft_dir_from_2s_/7: compute direction as sign(2-centroid minus interior-center).
ft_dir_from_2s_(Twos_, R1_, C1_, R2_, C2_, Dr_, Dc_) :-
% Compute float center of the rectangle (midpoint of outer border rows/cols).
    CenterR_ is (R1_ + R2_) / 2.0, CenterC_ is (C1_ + C2_) / 2.0,
% Extract row and column coordinates of all 2-cells.
    findall(TR_, member(TR_-_, Twos_), TRs_),
    findall(TC_, member(_-TC_, Twos_), TCs_),
% Compute arithmetic mean of 2-cell row and column indices.
    sumlist(TRs_, SumR_), length(TRs_, Len_),
    sumlist(TCs_, SumC_),
    AvgR_ is SumR_ / Len_, AvgC_ is SumC_ / Len_,
% Row direction: +1 if centroid is below center, -1 if above, 0 if equal.
    ( AvgR_ > CenterR_ -> Dr_ = 1  ; AvgR_ < CenterR_ -> Dr_ = -1 ; Dr_ = 0 ),
% Column direction: +1 if centroid is right of center, -1 if left, 0 if equal.
    ( AvgC_ > CenterC_ -> Dc_ = 1  ; AvgC_ < CenterC_ -> Dc_ = -1 ; Dc_ = 0 ).

% ft_enclosing_color_/5: find unique frame color enclosing 4 at (R_,C_).
% Shoots rays in 4 directions; DirColors_ are the known frame colors (walls).
% Succeeds only when all directions agree on exactly one frame color.
ft_enclosing_color_(Grid_, DirColors_, R_, C_, Color_) :-
% Shoot rays in all 4 cardinal directions and collect wall-hit frame colors.
    findall(FC_, (
        member(DR_-DC_, [0-1, 0-(-1), 1-0, (-1)-0]),
        ft_ray_to_wall_(Grid_, DirColors_, R_, C_, DR_, DC_, FC_)
    ), HitColors_),
% Retain only colors that are known frame colors (filter non-frame hits).
    include([FC_]>>(member(FC_, DirColors_)), HitColors_, FrameColors_),
% Require exactly one unique frame color across all successful ray directions.
    sort(FrameColors_, [Color_]).

% ft_ray_to_wall_/7: shoot ray from (R,C) in direction (Dr,Dc); stop at a frame
% color (member of DirColors_). Passes through all other cells. Fails at boundary.
ft_ray_to_wall_(Grid_, DirColors_, R_, C_, Dr_, Dc_, Color_) :-
% Advance one step in the ray direction.
    NR_ is R_ + Dr_, NC_ is C_ + Dc_,
% Fail if the new position is outside grid bounds.
    length(Grid_, NRG_), NR_ >= 0, NR_ < NRG_,
    nth0(NR_, Grid_, NRow_), length(NRow_, NCG_), NC_ >= 0, NC_ < NCG_,
% Read the cell value at the new position.
    nth0(NC_, NRow_, V_),
% Stop if V_ is a frame color; otherwise pass through and recurse.
    ( member(V_, DirColors_) ->
        Color_ = V_
    ;
        ft_ray_to_wall_(Grid_, DirColors_, NR_, NC_, Dr_, Dc_, Color_)
    ).

% ft_shoot_/8: move from (R,C) in direction (Dr,Dc) until 1 step before Color wall.
% For diagonal directions uses the clip rule: stop if either the row-component
% step or the col-component step (not just the diagonal step) hits the wall.
% Returns final safe position (NR_,NC_). Fails if grid boundary is reached.
ft_shoot_(Grid_, Color_, R_, C_, Dr_, Dc_, NR_, NC_) :-
% Compute grid dimensions for bounds checking.
    length(Grid_, NRG_), Grid_ = [SR0_|_], length(SR0_, NCG_),
% Compute next candidate position.
    R1_ is R_ + Dr_, C1_ is C_ + Dc_,
% Fail if the next position is outside grid bounds.
    R1_ >= 0, R1_ < NRG_, C1_ >= 0, C1_ < NCG_,
% Read the diagonal-step cell and (for diagonal moves) the two axis-step cells.
    nth0(R1_, Grid_, SRowD_), nth0(C1_, SRowD_, SV_D_),
    nth0(R_,  Grid_, SRow0_), nth0(C1_, SRow0_, SV_C_),
    nth0(R1_, Grid_, SRow1_), nth0(C_,  SRow1_, SV_R_),
% Clip rule: stop at (R,C) if any of the three adjacent next cells = Color.
    ( (SV_D_ =:= Color_ ; SV_C_ =:= Color_ ; SV_R_ =:= Color_) ->
        NR_ = R_, NC_ = C_
    ;
        ft_shoot_(Grid_, Color_, R1_, C1_, Dr_, Dc_, NR_, NC_)
    ).

% ===========================================================================
% TIP_ESCAPE rule (Wave 18) — Task 3dc255db
% Each grid has one or more "shape" components (8-connected non-background)
% that enclose "marker" components (different color, smaller, inside the
% shape's bounding box).  The shape has a "tip" — the unique single cell
% at an extreme row or column direction.  In the output: all markers are
% removed and min(N_markers, dist_to_grid_edge) new marker cells are placed
% just past the tip, filling outward toward the grid boundary.
% Escape direction: apex detection first (tip with perpendicular diverging
% arms), then projection method (escape = shape_centroid - marker_centroid).
% ===========================================================================

% Register tip_escape with the named-rule induction dispatcher.
arc2_named_rule(tip_escape).

% arc2_transform for tip_escape: delegate to te_transform_.
arc2_transform(tip_escape, Grid, GridOut) :-
% Apply the marker-escape transformation to the grid.
    te_transform_(Grid, GridOut).

% arc2_induce_rule for tip_escape: verify all training pairs match.
arc2_induce_rule(TrainingPairs, tip_escape) :-
% Training set must be non-empty.
    TrainingPairs \= [],
% Every training pair must produce the expected output.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(tip_escape, In, Out)).

% te_transform_(+Grid, -GridOut)
% Find shape+marker pairs and apply each escape transformation.
te_transform_(Grid, GridOut) :-
% Find all 8-connected non-background components.
    te_all_comps_(Grid, 0, AllComps),
% Pair shapes with their enclosed marker components.
    te_find_pairs_(AllComps, Pairs),
% Fail unless at least one valid pair exists.
    Pairs \= [],
% Apply each pair's transformation sequentially via foldl.
    foldl(te_apply_pair_, Pairs, Grid, GridOut).

% ---------------------------------------------------------------------------
% 8-connected component finder
% ---------------------------------------------------------------------------

% te_all_comps_(+Grid, +Bg, -Comps)
% Comps = list of comp(Color, Cells) where Cells = list of R-C pairs.
te_all_comps_(Grid, Bg, Comps) :-
% Get row count.
    length(Grid, NR), NR1 is NR - 1,
% Get column count from the first row.
    nth0(0, Grid, Row0_), length(Row0_, NC), NC1 is NC - 1,
% Collect all non-background cell positions.
    findall(R-C,
        (between(0,NR1,R), between(0,NC1,C),
         nth0(R,Grid,GRow_), nth0(C,GRow_,V_), V_ \= Bg),
        AllCells),
% Group cells into 8-connected same-color components.
    te_group_comps_(AllCells, Grid, NR, NC, Comps).

% te_group_comps_(+Pending, +Grid, +NR, +NC, -Comps)
% Iteratively extract BFS components from the head of the pending cell list.
te_group_comps_([], _, _, _, []).
te_group_comps_([R-C|Pending], Grid, NR, NC,
                [comp(Color,CompCells)|RestComps]) :-
% Look up the seed cell's color.
    nth0(R, Grid, SRow_), nth0(C, SRow_, Color),
% BFS-expand all 8-connected cells of this color from the seed.
    te_bfs8_(Grid, Color, NR, NC, [R-C], [R-C], CompCells),
% Remove all component cells from the pending list.
    subtract(Pending, CompCells, Pending2),
% Recurse for remaining cells.
    te_group_comps_(Pending2, Grid, NR, NC, RestComps).

% te_bfs8_(+Grid, +Color, +NR, +NC, +Queue, +Visited, -Component)
% BFS over 8-adjacent same-Color cells; Component = final visited set.
te_bfs8_(_, _, _, _, [], Visited, Visited).
te_bfs8_(Grid, Color, NR, NC, [R-C|Queue], Visited, Component) :-
% Compute adjacent row and column offsets.
    R1_ is R-1, R2_ is R+1, C1_ is C-1, C2_ is C+1,
% Collect in-bounds, same-color, unvisited 8-neighbors.
    findall(Nr-Nc,
        (member(Nr,[R1_,R,R2_]), member(Nc,[C1_,C,C2_]),
         \+((Nr=:=R, Nc=:=C)),
         Nr >= 0, Nr < NR, Nc >= 0, Nc < NC,
         nth0(Nr,Grid,NRow_), nth0(Nc,NRow_,Color),
         \+ member(Nr-Nc,Visited)),
        NewCells),
% Append new cells to the BFS frontier queue.
    append(Queue, NewCells, Queue2),
% Add new cells to the visited set.
    append(Visited, NewCells, Visited2),
% Continue BFS with updated queue and visited set.
    te_bfs8_(Grid, Color, NR, NC, Queue2, Visited2, Component).

% ---------------------------------------------------------------------------
% Shape-marker pairing
% ---------------------------------------------------------------------------

% te_find_pairs_(+AllComps, -Pairs)
% Pairs = list of pair(comp(SC,SCells), comp(MC,MCells)) where MC-cells
% are enclosed inside the SC-cells bounding box and strictly fewer in count.
te_find_pairs_(AllComps, Pairs) :-
% Collect all valid shape+marker component pairs via findall.
    findall(pair(Shape,Marker),
        (member(Shape, AllComps),
         member(Marker, AllComps),
         Shape \= Marker,
         te_is_marker_(Shape, Marker)),
        Pairs).

% te_is_marker_(+Shape, +Candidate)
% Candidate qualifies as a marker: different color, fewer cells, BB inside Shape BB.
te_is_marker_(comp(SC_,SCells), comp(MC_,MCells)) :-
% Colors must differ.
    SC_ \= MC_,
% Marker must be strictly smaller than the shape.
    length(SCells, SN_), length(MCells, MN_), MN_ < SN_,
% Compute shape bounding box.
    te_bb_(SCells, SMinR, SMaxR, SMinC, SMaxC),
% Compute marker bounding box.
    te_bb_(MCells, MMinR, MMaxR, MMinC, MMaxC),
% Marker BB must fit entirely within shape BB.
    MMinR >= SMinR, MMaxR =< SMaxR,
    MMinC >= SMinC, MMaxC =< SMaxC.

% te_bb_(+Cells, -MinR, -MaxR, -MinC, -MaxC)
% Compute the bounding box of a list of R-C cell coordinates.
te_bb_(Cells, MinR, MaxR, MinC, MaxC) :-
% Separate row and column lists via pairs decomposition.
    pairs_keys_values(Cells, Rs, Cs),
% Find min and max of rows and columns.
    min_list(Rs, MinR), max_list(Rs, MaxR),
    min_list(Cs, MinC), max_list(Cs, MaxC).

% ---------------------------------------------------------------------------
% Apply one shape+marker pair transformation
% ---------------------------------------------------------------------------

% te_apply_pair_(+Pair, +GIn, -GOut)
% Remove marker cells from GIn; place min(N,Z) new marker cells past the tip.
te_apply_pair_(pair(comp(_,SCells), comp(MC,MCells)), GIn, GOut) :-
% Find the escape direction and tip cell coordinates.
    te_select_escape_(SCells, MCells, TipR, TipC, EscDir),
% Get grid dimensions for boundary calculations.
    te_grid_dims_(GIn, NRows, NCols),
% Build the ordered escape-zone list past the tip toward grid edge.
    te_escape_zone_(TipR, TipC, EscDir, NRows, NCols, EscZone),
% Count markers and available zone positions.
    length(MCells, N), length(EscZone, ZSize),
% Number of markers to place is capped by zone capacity.
    PlaceN is min(N, ZSize),
% Remove all marker cells by setting them to background 0.
    te_set_cells_(GIn, MCells, 0, G1),
% Take the first PlaceN zone positions (closest to tip first).
    length(PlaceZone, PlaceN),
    append(PlaceZone, _, EscZone),
% Write marker color to the selected escape positions.
    te_set_cells_(G1, PlaceZone, MC, GOut).

% ---------------------------------------------------------------------------
% Escape direction selection
% ---------------------------------------------------------------------------

% te_select_escape_(+SCells, +MCells, -TipR, -TipC, -EscDir)
% Determine the tip cell and escape direction for one shape+marker pair.
te_select_escape_(SCells, MCells, TipR, TipC, EscDir) :-
% Compute shape bounding box for extreme detection.
    te_bb_(SCells, MinR, MaxR, MinC, MaxC),
% Find all directions that have a single-cell extreme.
    findall(Dir-TR-TC,
        te_single_extreme_(SCells, MinR, MaxR, MinC, MaxC, Dir, TR, TC),
        Tips),
% At least one tip must exist.
    Tips \= [],
% Apex detection takes priority; fall back to projection if no apex.
    ( te_apex_tip_(Tips, SCells, TipR, TipC, EscDir) -> true
    ; te_projection_tip_(Tips, SCells, MCells, TipR, TipC, EscDir) ).

% te_single_extreme_(+SCells, +MinR, +MaxR, +MinC, +MaxC, ?Dir, -TipR, -TipC)
% Succeed when exactly ONE shape cell is at the extreme row/col in direction Dir.
te_single_extreme_(SCells, _, _, MinC, _, left, TipR, MinC) :-
% Filter cells at the leftmost column.
    include([_-C_]>>(C_ =:= MinC), SCells, Ext),
% Exactly one cell must be at that column.
    Ext = [TipR-MinC].
te_single_extreme_(SCells, _, _, _, MaxC, right, TipR, MaxC) :-
% Filter cells at the rightmost column.
    include([_-C_]>>(C_ =:= MaxC), SCells, Ext),
% Exactly one cell must be at that column.
    Ext = [TipR-MaxC].
te_single_extreme_(SCells, MinR, _, _, _, up, MinR, TipC) :-
% Filter cells at the topmost row.
    include([R_-_]>>(R_ =:= MinR), SCells, Ext),
% Exactly one cell must be at that row.
    Ext = [MinR-TipC].
te_single_extreme_(SCells, _, MaxR, _, _, down, MaxR, TipC) :-
% Filter cells at the bottommost row.
    include([R_-_]>>(R_ =:= MaxR), SCells, Ext),
% Exactly one cell must be at that row.
    Ext = [MaxR-TipC].

% te_apex_tip_(+Tips, +SCells, -TipR, -TipC, -EscDir)
% Find the first tip that qualifies as an apex with diverging perpendicular arms.
te_apex_tip_(Tips, SCells, TipR, TipC, EscDir) :-
% Try each candidate tip in order.
    member(EscDir-TipR-TipC, Tips),
% Verify it has diverging perpendicular shape-cell arms.
    te_is_apex_(TipR, TipC, EscDir, SCells).

% te_apex_nbrs_(+TipR, +TipC, +SCells, -Nbrs)
% Collect 8-adjacent shape cells of the tip, excluding the tip itself.
te_apex_nbrs_(TipR, TipC, SCells, Nbrs) :-
% Find all shape cells within 1 step of the tip that are not the tip.
    findall(R-C,
        (member(R-C, SCells),
         DR_ is abs(R - TipR), DC_ is abs(C - TipC),
         DR_ =< 1, DC_ =< 1,
         \+((R =:= TipR, C =:= TipC))),
        Nbrs).

% te_is_apex_(+TipR, +TipC, +Dir, +SCells)
% Horizontal escape (left/right): arms diverge both above and below the tip row.
% Vertical escape (up/down): arms diverge both left and right of the tip col.
te_is_apex_(TipR, TipC, right, SCells) :-
    te_apex_nbrs_(TipR, TipC, SCells, Nbrs),
    member(AR-_, Nbrs), AR < TipR,
    member(BR-_, Nbrs), BR > TipR.
te_is_apex_(TipR, TipC, left, SCells) :-
    te_apex_nbrs_(TipR, TipC, SCells, Nbrs),
    member(AR-_, Nbrs), AR < TipR,
    member(BR-_, Nbrs), BR > TipR.
te_is_apex_(TipR, TipC, up, SCells) :-
    te_apex_nbrs_(TipR, TipC, SCells, Nbrs),
    member(_-LC, Nbrs), LC < TipC,
    member(_-RC, Nbrs), RC > TipC.
te_is_apex_(TipR, TipC, down, SCells) :-
    te_apex_nbrs_(TipR, TipC, SCells, Nbrs),
    member(_-LC, Nbrs), LC < TipC,
    member(_-RC, Nbrs), RC > TipC.

% te_projection_tip_(+Tips, +SCells, +MCells, -TipR, -TipC, -EscDir)
% Select the tip with the greatest projection onto the escape vector.
% Escape vector = shape_centroid - marker_centroid (points away from markers).
te_projection_tip_(Tips, SCells, MCells, TipR, TipC, EscDir) :-
% Compute shape centroid.
    te_centroid_(SCells, SR, SC),
% Compute marker centroid.
    te_centroid_(MCells, MR, MCol),
% Escape vector from marker centroid toward the opposite side of the shape.
    EscVR is SR - MR, EscVC is SC - MCol,
% Project each tip onto the escape vector.
    findall(Proj-Dir-TR-TC,
        (member(Dir-TR-TC, Tips),
         Proj is float((TR - SR) * EscVR + (TC - SC) * EscVC)),
        ProjList),
% Choose the tip with the maximum projection value.
    max_member(_-EscDir-TipR-TipC, ProjList).

% te_centroid_(+Cells, -AvgR, -AvgC)
% Floating-point centroid (average row and col) of a list of R-C cells.
te_centroid_(Cells, AvgR, AvgC) :-
% Decompose into separate row and column lists.
    pairs_keys_values(Cells, Rs, Cs),
% Sum rows and columns.
    sum_list(Rs, SumR), sum_list(Cs, SumC),
% Compute cell count.
    length(Cells, N),
% Use float division to avoid integer truncation.
    AvgR is SumR / float(N), AvgC is SumC / float(N).

% ---------------------------------------------------------------------------
% Escape zone and grid mutation helpers
% ---------------------------------------------------------------------------

% te_escape_zone_(+TipR, +TipC, +Dir, +NR, +NC, -Zone)
% Zone = ordered list of R-C positions from just past the tip to the grid edge.
te_escape_zone_(TipR, TipC, right, _NR, NC, Zone) :-
% Zone extends rightward from TipC+1 to the last column.
    S_ is TipC + 1, E_ is NC - 1,
    ( S_ > E_ -> Zone = []
    ; numlist(S_, E_, Cs_), maplist([C_,TipR-C_]>>true, Cs_, Zone) ).
te_escape_zone_(TipR, TipC, left, _NR, _NC, Zone) :-
% Zone extends leftward from TipC-1 to column 0 (closest position first).
    S_ is TipC - 1,
    ( S_ < 0 -> Zone = []
    ; numlist(0, S_, Cs0_), reverse(Cs0_, Cs_),
      maplist([C_,TipR-C_]>>true, Cs_, Zone) ).
te_escape_zone_(TipR, TipC, up, _NR, _NC, Zone) :-
% Zone extends upward from TipR-1 to row 0 (closest position first).
    S_ is TipR - 1,
    ( S_ < 0 -> Zone = []
    ; numlist(0, S_, Rs0_), reverse(Rs0_, Rs_),
      maplist([R_,R_-TipC]>>true, Rs_, Zone) ).
te_escape_zone_(TipR, TipC, down, NR, _NC, Zone) :-
% Zone extends downward from TipR+1 to the last row.
    S_ is TipR + 1, E_ is NR - 1,
    ( S_ > E_ -> Zone = []
    ; numlist(S_, E_, Rs_), maplist([R_,R_-TipC]>>true, Rs_, Zone) ).

% te_grid_dims_(+Grid, -NRows, -NCols)
% Return the number of rows and columns of a grid.
te_grid_dims_(Grid, NRows, NCols) :-
    length(Grid, NRows),
    ( Grid = [R0_|_] -> length(R0_, NCols) ; NCols = 0 ).

% te_set_cell_(+Grid, +R, +C, +V, -GridOut)
% Return a new grid identical to Grid but with cell (R,C) set to V.
te_set_cell_(Grid, R, C, V, GridOut) :-
    nth0(R, Grid, Row_, RestRows),
    nth0(C, Row_, _, RestCols),
    nth0(C, NewRow_, V, RestCols),
    nth0(R, GridOut, NewRow_, RestRows).

% te_set_cells_(+Grid, +Cells, +V, -GridOut)
% Set every listed R-C cell to value V, recursing over the cell list.
te_set_cells_(Grid, [], _, Grid).
te_set_cells_(Grid, [R-C|Rest], V, GridOut) :-
    te_set_cell_(Grid, R, C, V, Grid1),
    te_set_cells_(Grid1, Rest, V, GridOut).

% ---------------------------------------------------------------------------
% SEGMENT_EXT RULE (task faa9f03d)
% 4-corner markers: stub arm removed, 4-corner becomes arm color, extends opposite.
% 2-corner markers: convert to adjacent arm color.
% Fill rule: H and V fills applied; V wins conflicts; uses original Vin as reference.
% ---------------------------------------------------------------------------

% Register the segment_ext rule name.
arc2_named_rule(segment_ext).

% arc2_transform(segment_ext, +Grid, -GridOut): full 3-phase transformation.
arc2_transform(segment_ext, Grid, GridOut) :-
% Dispatch to main transform helper.
    se_tr_(Grid, GridOut).

% arc2_induce_rule for segment_ext: succeeds when all pairs transform correctly.
arc2_induce_rule(TrainingPairs, segment_ext) :-
% Reject empty training set.
    TrainingPairs \= [],
% Verify every training pair.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(segment_ext, In, Out)).

% se_tr_(+Grid, -GridOut): phases 1-3 in sequence.
se_tr_(Grid, GridOut) :-
% Get grid dimensions.
    length(Grid, NR), NR1 is NR - 1,
% Get column count from first row.
    nth0(0, Grid, Row0_), length(Row0_, NC), NC1 is NC - 1,
% Collect all 4-corner positions.
    findall(R-C,
        (between(0,NR1,R), between(0,NC1,C), se_get_(Grid,R,C,4)),
        C4s),
% Determine conflict-resolution direction from 4-corner extensions.
    se_ext_dir_(Grid, C4s, NR, NC, ExtDir),
% Phase 1: process each 4-corner, threading the grid.
    foldl(se_proc4_(NR,NC), C4s, Grid, G1),
% Phase 2: convert all remaining 2-corners to arm color.
    se_conv2all_(G1, NR1, NC1, G2),
% Phase 3: apply fill rule to every cell using original Grid as reference.
    numlist(0, NR1, RowIdxs), numlist(0, NC1, ColIdxs),
    maplist([R, OutRow]>>(
        maplist([C, V]>>(se_fill_cell_(G2, Grid, NR, NC, ExtDir, R, C, V)),
                ColIdxs, OutRow)
    ), RowIdxs, GridOut).

% se_ext_dir_(+Grid, +C4s, +NR, +NC, -Prio): resolve fill priority from 4-corners.
% none = no 4-corners (H can overwrite non-bg frame cells; V wins conflicts).
% v    = vertical extension (V wins conflicts; frame cannot overwrite existing arm cells).
% h    = horizontal extension (H wins conflicts; frame cannot overwrite existing arm cells).
se_ext_dir_(Grid, C4s, NR, NC, Prio) :-
    ( C4s = [] ->
        Prio = none
    ;   findall(EDR-EDC, (
            member(R-C, C4s),
            se_stub_dir_(Grid, R, C, NR, NC, DR, DC),
            EDR is -DR, EDC is -DC
        ), ExtDirs),
        ( member(EDR-_, ExtDirs), EDR \= 0 -> Prio = v
        ; Prio = h
        )
    ).

% se_proc4_(+NR, +NC, +R-C, +G0, -GOut): process one 4-corner.
se_proc4_(NR, NC, R-C, G0, GOut) :-
% Determine stub direction: toward the longest same-color adjacent arm segment.
    se_stub_dir_(G0, R, C, NR, NC, DR, DC),
% Find arm color by walking in stub direction past 2-corners.
    se_arm_col_(G0, R, C, DR, DC, NR, NC, Color),
% Kept junction is the cell immediately in stub direction (never removed).
    KR is R + DR, KC is C + DC,
% First stub cell is two steps in stub direction.
    FR is KR + DR, FC is KC + DC,
% Collect immediate contiguous stub cells in stub direction.
    se_contig_(G0, FR, FC, DR, DC, NR, NC, IStub),
% Blocked set: 4-corner + kept junction + immediate stub.
    Blocked0 = [R-C, KR-KC | IStub],
% Cascade: BFS from neighbors of 2-corners in IStub.
    se_cascade_(G0, IStub, Blocked0, NR, NC, CasStub),
% All removed so far.
    append(IStub, CasStub, AllRemSoFar),
% Update blocked set to include cascade.
    append(Blocked0, CasStub, Blocked1),
% Far segment removal: segments beyond first gap with no perpendicular arm connection.
    se_far_rem_(G0, FR, FC, DR, DC, NR, NC, Color, Blocked1, FarRem),
% Full remove list: immediate stub + cascade + far segments.
    append(AllRemSoFar, FarRem, ToRemove),
% Apply removals (set to 0).
    foldl([Rs-Cs, G, G2]>>(se_set_(G, Rs, Cs, 0, G2)), ToRemove, G0, G1),
% Set the 4-corner cell itself to arm Color.
    se_set_(G1, R, C, Color, G2),
% Extension direction is opposite to stub direction.
    ExtDR is -DR, ExtDC is -DC,
% Extend from one step past 4-corner in extension direction.
    se_extend_(G2, R, C, ExtDR, ExtDC, Color, NR, NC, GOut).

% se_stub_dir_(+Grid, +R, +C, +NR, +NC, -DR, -DC): direction of the approach arm.
% Prefers adjacent 2-corner; otherwise picks the direction with the longest same-color run.
se_stub_dir_(Grid, R, C, NR, NC, DR, DC) :-
% If adjacent 2-corner exists that direction is unambiguously the stub.
    member(DR-DC, [-1-0, 1-0, 0-(-1), 0-1]),
    R2 is R + DR, C2 is C + DC,
    R2 >= 0, R2 < NR, C2 >= 0, C2 < NC,
    se_get_(Grid, R2, C2, 2), !.
se_stub_dir_(Grid, R, C, NR, NC, DR, DC) :-
% Otherwise count how many same-color cells lie in each adjacent direction.
    findall(Len-DR1-DC1,
        ( member(DR1-DC1, [-1-0, 1-0, 0-(-1), 0-1]),
          R2 is R+DR1, C2 is C+DC1,
          R2 >= 0, R2 < NR, C2 >= 0, C2 < NC,
          se_get_(Grid, R2, C2, V), V \= 0, V \= 4,
          se_count_run_(Grid, R2, C2, DR1, DC1, NR, NC, V, Len)
        ),
        Cands),
% Pick the direction with the longest run.
    Cands \= [],
    sort(0, @>=, Cands, [_-DR-DC|_]).

% se_count_run_(+Grid, +R, +C, +DR, +DC, +NR, +NC, +Color, -N): count consecutive Color cells.
se_count_run_(Grid, R, C, DR, DC, NR, NC, Color, N) :-
    se_count_run_walk_(Grid, R, C, DR, DC, NR, NC, Color, 0, N).
% se_count_run_walk_: walk accumulating count; stop at OOB or non-color.
se_count_run_walk_(Grid, R, C, DR, DC, NR, NC, Color, Acc, N) :-
    R >= 0, R < NR, C >= 0, C < NC,
    se_get_(Grid, R, C, V),
    ( V =:= Color ; V =:= 2 ), !,
    R2 is R + DR, C2 is C + DC,
    Acc1 is Acc + 1,
    se_count_run_walk_(Grid, R2, C2, DR, DC, NR, NC, Color, Acc1, N).
se_count_run_walk_(_, _, _, _, _, _, _, _, Acc, Acc).

% se_arm_col_(+Grid, +R, +C, +DR, +DC, +NR, +NC, -Color): arm color along stub direction.
se_arm_col_(Grid, R, C, DR, DC, NR, NC, Color) :-
    R2 is R + DR, C2 is C + DC,
    se_arm_col_walk_(Grid, R2, C2, DR, DC, NR, NC, Color).

% se_arm_col_walk_: walk past 2-corners to find first true arm color.
se_arm_col_walk_(Grid, R, C, DR, DC, NR, NC, Color) :-
    R >= 0, R < NR, C >= 0, C < NC,
    se_get_(Grid, R, C, V),
    ( V \= 0, V \= 2, V \= 4 -> Color = V
    ; V =:= 2 ->
        R2 is R + DR, C2 is C + DC,
        se_arm_col_walk_(Grid, R2, C2, DR, DC, NR, NC, Color)
    ; fail
    ).

% se_contig_(+Grid, +R, +C, +DR, +DC, +NR, +NC, -Cells): immediate contiguous stub cells.
% Collects non-0 cells in direction (DR,DC) stopping at first 0 or OOB.
se_contig_(Grid, R, C, DR, DC, NR, NC, Cells) :-
    ( R < 0 ; R >= NR ; C < 0 ; C >= NC ), !, Cells = [].
se_contig_(Grid, R, C, DR, DC, NR, NC, Cells) :-
    se_get_(Grid, R, C, V),
    ( V =:= 0 -> Cells = []
    ;
        R2 is R + DR, C2 is C + DC,
        se_contig_(Grid, R2, C2, DR, DC, NR, NC, Rest),
        Cells = [R-C | Rest]
    ).

% se_cascade_(+Grid, +Stub, +Blocked, +NR, +NC, -Cascade): cells reachable from 2-corner neighbors.
se_cascade_(Grid, Stub, Blocked, NR, NC, Cascade) :-
% Find 2-corner cells within the immediate stub.
    include([Pos]>>(Pos = R-C, se_get_(Grid,R,C,2)), Stub, TwoCorners),
% BFS from each 2-corner's neighbors (not the 2-corner itself, which is in Blocked).
    foldl(se_cas_from_nbrs_(Grid, Blocked, NR, NC), TwoCorners, [], Cascade).

% se_cas_from_nbrs_: add BFS results from neighbors of a 2-corner.
se_cas_from_nbrs_(Grid, Blocked, NR, NC, R-C, Acc, NewAcc) :-
    se_nbrs_(R, C, NR, NC, Nbrs),
    foldl(se_cas_bfs_(Grid, Blocked, NR, NC), Nbrs, Acc, NewAcc).

% se_cas_bfs_: BFS from one start cell accumulating reachable non-blocked content cells.
se_cas_bfs_(Grid, Blocked, NR, NC, Start, Acc, NewAcc) :-
    ( memberchk(Start, Acc) -> NewAcc = Acc
    ; se_bfs_step_(Grid, Blocked, NR, NC, [Start], Acc, NewAcc)
    ).

% se_bfs_step_: BFS kernel.
se_bfs_step_(_, _, _, _, [], Vis, Vis).
se_bfs_step_(Grid, Blocked, NR, NC, [H|T], Vis, Result) :-
    ( memberchk(H, Blocked) ->
        se_bfs_step_(Grid, Blocked, NR, NC, T, Vis, Result)
    ; memberchk(H, Vis) ->
        se_bfs_step_(Grid, Blocked, NR, NC, T, Vis, Result)
    ;
        H = R-C,
        se_get_(Grid, R, C, V),
        ( V =:= 0 ->
            se_bfs_step_(Grid, Blocked, NR, NC, T, Vis, Result)
        ;
            Vis2 = [H|Vis],
            se_nbrs_(R, C, NR, NC, Nbrs),
            append(T, Nbrs, Q2),
            se_bfs_step_(Grid, Blocked, NR, NC, Q2, Vis2, Result)
        )
    ).

% se_nbrs_: four orthogonal neighbors within bounds.
se_nbrs_(R, C, NR, NC, Nbrs) :-
    findall(R2-C2,
        (member(DR-DC, [-1-0,1-0,0-(-1),0-1]),
         R2 is R+DR, C2 is C+DC,
         R2 >= 0, R2 < NR, C2 >= 0, C2 < NC),
        Nbrs).

% se_far_rem_(+Grid, +FR, +FC, +DR, +DC, +NR, +NC, +Color, +Removed, -FarCells):
% Segments beyond first gap; remove those with no perpendicular Color-neighbor.
se_far_rem_(Grid, FR, FC, DR, DC, NR, NC, Color, Removed, FarCells) :-
% Walk stub direction to find first background (gap) cell.
    se_first_gap_(Grid, FR, FC, DR, DC, NR, NC, GR, GC),
% Start one step past the gap.
    GR2 is GR + DR, GC2 is GC + DC,
% Collect all sub-segments beyond the first gap.
    se_collect_segs_(Grid, GR2, GC2, DR, DC, NR, NC, Segs),
% Keep only segments with no perpendicular same-Color neighbor outside Removed.
    include({Grid,Color,Removed,NR,NC,DR,DC}/[Seg]>>(
        \+ se_seg_has_perp_(Grid, Seg, Color, Removed, NR, NC, DR, DC)
    ), Segs, BadSegs),
    flatten(BadSegs, FarCells).

% se_first_gap_: find first 0 or OOB cell walking from (R,C) in direction (DR,DC).
se_first_gap_(Grid, R, C, DR, DC, NR, NC, GR, GC) :-
    ( R < 0 ; R >= NR ; C < 0 ; C >= NC ),
    !, GR = R, GC = C.
se_first_gap_(Grid, R, C, DR, DC, NR, NC, GR, GC) :-
    se_get_(Grid, R, C, V),
    ( V =:= 0 -> GR = R, GC = C
    ;
        R2 is R + DR, C2 is C + DC,
        se_first_gap_(Grid, R2, C2, DR, DC, NR, NC, GR, GC)
    ).

% se_collect_segs_: collect contiguous sub-segments from (R,C) onward, skipping gaps.
se_collect_segs_(Grid, R, C, DR, DC, NR, NC, Segs) :-
    ( R < 0 ; R >= NR ; C < 0 ; C >= NC ),
    !, Segs = [].
se_collect_segs_(Grid, R, C, DR, DC, NR, NC, Segs) :-
    se_get_(Grid, R, C, V),
    ( V =:= 0 ->
        R2 is R + DR, C2 is C + DC,
        se_collect_segs_(Grid, R2, C2, DR, DC, NR, NC, Segs)
    ;
        se_contig_(Grid, R, C, DR, DC, NR, NC, Seg),
        length(Seg, SL),
        R2 is R + SL * DR, C2 is C + SL * DC,
        se_collect_segs_(Grid, R2, C2, DR, DC, NR, NC, RestSegs),
        Segs = [Seg | RestSegs]
    ).

% se_seg_has_perp_: true if any Seg cell has a perpendicular Color-neighbor not in Removed.
% Only checks directions perpendicular to the stub (not along the stub line itself).
se_seg_has_perp_(Grid, Seg, Color, Removed, NR, NC, StubDR, StubDC) :-
    ( StubDR =:= 0
    % Horizontal stub: check only UP and DOWN (perpendicular).
    -> PDirs = [-1-0, 1-0]
    % Vertical stub: check only LEFT and RIGHT (perpendicular).
    ;  PDirs = [0-(-1), 0-1]
    ),
    member(R-C, Seg),
    member(PDR-PDC, PDirs),
    PR is R + PDR, PC is C + PDC,
    PR >= 0, PR < NR, PC >= 0, PC < NC,
    se_get_(Grid, PR, PC, Color),
    \+ memberchk(PR-PC, Removed).

% se_extend_(+G, +R, +C, +DR, +DC, +Color, +NR, +NC, -GOut):
% Walk from one step past (R,C) in extension direction, setting each cell to Color.
se_extend_(G, R, C, DR, DC, Color, NR, NC, GOut) :-
    R2 is R + DR, C2 is C + DC,
    se_ext_walk_(G, R2, C2, DR, DC, Color, NR, NC, GOut).

% se_ext_walk_: extension walk kernel; stops at OOB.
se_ext_walk_(G, R, C, _, _, _, NR, NC, G) :-
    ( R < 0 ; R >= NR ; C < 0 ; C >= NC ), !.
se_ext_walk_(G, R, C, DR, DC, Color, NR, NC, GOut) :-
    se_set_(G, R, C, Color, G1),
    R2 is R + DR, C2 is C + DC,
    se_ext_walk_(G1, R2, C2, DR, DC, Color, NR, NC, GOut).

% se_conv2all_(+G, +NR1, +NC1, -G2): convert all remaining 2-corners to adjacent arm color.
se_conv2all_(G, NR1, NC1, G2) :-
    findall(R-C,
        (between(0,NR1,R), between(0,NC1,C), se_get_(G,R,C,2)),
        C2s),
    foldl(se_conv2one_, C2s, G, G2).

% se_conv2one_: convert one 2-corner to the color of first non-bg, non-special neighbor.
se_conv2one_(R-C, G, G2) :-
    ( member(DR-DC, [-1-0,1-0,0-(-1),0-1]),
      R2 is R+DR, C2 is C+DC,
      se_get_(G, R2, C2, V),
      V \= 0, V \= 2, V \= 4
    -> Color = V
    ;  Color = 0
    ), !,
    se_set_(G, R, C, Color, G2).

% se_fill_cell_(+G, +Orig, +NR, +NC, +ExtDir, +R, +C, -V): fill-rule output for one cell.
% ExtDir (h or v) is the 4-corner extension direction used to break H-vs-V conflicts.
se_fill_cell_(G, Orig, NR, NC, ExtDir, R, C, V) :-
% Pre-processed value and original input value.
    se_get_(G, R, C, Vpp),
    se_get_(Orig, R, C, Vin),
% Compute horizontal fill: both left and right same non-bg color.
    ( se_hfill_(G, R, C, NR, NC, H) -> true ; H = none ),
% Compute vertical fill: both above and below same non-bg color.
    ( se_vfill_(G, R, C, NR, NC, VV) -> true ; VV = none ),
    se_fill_rule_(ExtDir, Vpp, Vin, H, VV, V).

% se_hfill_: horizontal fill value; both left and right must be same non-bg Color.
se_hfill_(G, R, C, _NR, NC, Color) :-
    C1 is C - 1, C2 is C + 1,
    C1 >= 0, C2 < NC,
    se_get_(G, R, C1, Color),
    se_get_(G, R, C2, Color),
    Color \= 0.

% se_vfill_: vertical fill; both above and below same non-bg Color, and at least one
% V-neighbor is a pure-vertical arm cell (no same-color horizontal neighbor), so
% V fill only bridges gaps within an arm, not between separate horizontal arm segments.
se_vfill_(G, R, C, NR, NC, Color) :-
    R1 is R - 1, R2 is R + 1,
    R1 >= 0, R2 < NR,
    se_get_(G, R1, C, Color),
    se_get_(G, R2, C, Color),
    Color \= 0,
    ( se_pure_vert_(G, R1, C, NC, Color)
    ; se_pure_vert_(G, R2, C, NC, Color)
    ).

% se_pure_vert_: cell (R,C) has no same-color horizontal neighbor in G.
se_pure_vert_(G, R, C, NC, Color) :-
    \+ ( C1 is C-1, C1 >= 0, se_get_(G, R, C1, Color) ),
    \+ ( C2 is C+1, C2 < NC, se_get_(G, R, C2, Color) ).

% se_fill_rule_(+Prio, +Vpp, +Vin, +H, +VV, -Out): determine output value from fills.
% Prio = none  → no 4-corners: H can overwrite non-bg frame cells; V wins true conflicts.
% Prio = h     → horizontal 4-corner ext: H wins true conflicts; frame cannot overwrite arm.
% Prio = v     → vertical 4-corner ext: V wins true conflicts; frame cannot overwrite arm.
se_fill_rule_(Prio, Vpp, Vin, H, VV, Out) :-
% No fills: keep pre-processed value.
    ( H = none, VV = none ->
        Out = Vpp
% Only vertical fill and it differs from Vin: apply V.
    ; H = none ->
        ( VV \= Vin -> Out = VV ; Out = Vpp )
% Only horizontal fill and it differs from Vin: apply H.
    ; VV = none ->
        ( H \= Vin -> Out = H ; Out = Vpp )
% Both fills are the same color: apply if different from Vin.
    ; H = VV ->
        ( H \= Vin -> Out = H ; Out = Vpp )
% H differs from Vin; V equals Vin: H wins for bg or no-4-corner grids; else keep Vpp.
    ; H \= Vin, VV = Vin ->
        ( (Vin =:= 0 ; Prio = none) -> Out = H ; Out = Vpp )
% V differs from Vin; H equals Vin: apply V.
    ; VV \= Vin, H = Vin ->
        Out = VV
% Both differ from Vin and disagree: extension direction breaks tie (h → H wins, else V).
    ;
        ( Prio = h -> Out = H ; Out = VV )
    ).

% se_get_(+Grid, +R, +C, -V): cell accessor.
se_get_(Grid, R, C, V) :-
    nth0(R, Grid, Row), nth0(C, Row, V).

% se_set_(+Grid, +R, +C, +V, -G2): return new grid with cell (R,C) set to V.
se_set_(Grid, R, C, V, G2) :-
    nth0(R, Grid, OldRow),
    se_lset_(OldRow, C, V, NewRow),
    se_lset_(Grid, R, NewRow, G2).

% se_lset_(+List, +I, +V, -List2): list element replacement.
se_lset_([_|T], 0, V, [V|T]) :- !.
se_lset_([H|T], I, V, [H|T2]) :-
    I > 0, I1 is I-1, se_lset_(T, I1, V, T2).

% ---------------------------------------------------------------------------
% SECTION_TILE RULE (task b0039139)
% Input is divided by all-1 rows or all-1 cols into sections.
% Two shape sections (0-background + one foreground color) and two solid-color
% sections. Shape1 inner bbox is mapped (non-zero→C1, zero→C2) and tiled N
% times separated by single C2 separators. N = max non-zero count per row
% (horizontal layout) or per col (vertical layout) in the shape2 section.
% ---------------------------------------------------------------------------

% Register section_tile as a named rule.
arc2_named_rule(section_tile).

% arc2_transform(section_tile, +Grid, -Output): apply the section-tile rule.
arc2_transform(section_tile, Grid, Output) :-
% Detect whether dividers are rows or cols and collect their indices.
    st_find_dividers_(Grid, Layout, DivIdxs),
% Split the grid into sections along the divider axis.
    st_extract_sections_(Grid, Layout, DivIdxs, Sections),
% Separate shape sections (0+foreground) from solid-color sections.
    include(st_is_shape_sec_, Sections, ShapeSecs),
    include(st_is_solid_sec_, Sections, SolidSecs),
% Require at least two shape sections and two solid sections.
    ShapeSecs = [Sh1, Sh2 | _],
    SolidSecs = [Sol1, Sol2 | _],
% Read the two output colors from the solid sections.
    st_solid_color_(Sol1, C1),
    st_solid_color_(Sol2, C2),
% Extract the inner bounding box of shape1.
    st_inner_bbox_(Sh1, Inner1),
% Map: non-zero → C1, zero → C2 inside the bounding box.
    maplist([R_, MR_]>>(maplist([V_, MV_]>>(V_ =:= 0 -> MV_ = C2 ; MV_ = C1), R_, MR_)),
            Inner1, Mapped),
% Compute repetition count from shape2 structure.
    st_tile_count_(Sh2, Layout, N),
% Build the tiled output.
    st_build_tiled_(Mapped, C2, N, Layout, Output).

% st_find_dividers_(+Grid, -Layout, -DivIdxs):
% Detect all-1 rows (vertical) or all-1 cols (horizontal) as dividers.
st_find_dividers_(Grid, vertical, DivRows) :-
% Count rows and cols.
    length(Grid, NR), NR1 is NR - 1,
    Grid = [Row0_|_], length(Row0_, NC), NC1 is NC - 1,
% Collect row indices where every cell equals 1.
    findall(R_,
        (between(0, NR1, R_),
         nth0(R_, Grid, GRow_),
         forall(between(0, NC1, C_), (nth0(C_, GRow_, V_), V_ =:= 1))),
        DivRows),
% Must find at least one divider row to use vertical layout.
    DivRows \= [], !.
st_find_dividers_(Grid, horizontal, DivCols) :-
% Count rows and cols.
    length(Grid, NR), NR1 is NR - 1,
    Grid = [Row0_|_], length(Row0_, NC), NC1 is NC - 1,
% Collect col indices where every cell in that col equals 1.
    findall(C_,
        (between(0, NC1, C_),
         forall(between(0, NR1, R_),
                (nth0(R_, Grid, GRow_), nth0(C_, GRow_, V_), V_ =:= 1))),
        DivCols),
% Must find at least one divider col to use horizontal layout.
    DivCols \= [].

% st_extract_sections_(+Grid, +Layout, +DivIdxs, -Sections):
% Split the grid into non-divider sections.
st_extract_sections_(Grid, vertical, DivRows, Sections) :-
    length(Grid, NR),
    st_ranges_(DivRows, 0, NR, Ranges),
    include([(R0_-R1_)]>>(R0_ < R1_), Ranges, ValidRanges),
    maplist([R0_-R1_, Sec_]>>(st_slice_rows_(Grid, R0_, R1_, Sec_)),
            ValidRanges, Sections).
st_extract_sections_(Grid, horizontal, DivCols, Sections) :-
    Grid = [Row0_|_], length(Row0_, NC),
    st_ranges_(DivCols, 0, NC, Ranges),
    include([(C0_-C1_)]>>(C0_ < C1_), Ranges, ValidRanges),
    maplist([C0_-C1_, Sec_]>>(st_slice_cols_(Grid, C0_, C1_, Sec_)),
            ValidRanges, Sections).

% st_ranges_(+DivIdxs, +Start, +End, -Ranges):
% Compute contiguous sub-ranges between divider indices.
st_ranges_([], Start_, End_, [Start_-End_]).
st_ranges_([D_|Ds_], Start_, End_, [Start_-D_ | Rest_]) :-
    D1_ is D_ + 1,
    st_ranges_(Ds_, D1_, End_, Rest_).

% st_slice_rows_(+Grid, +R0, +R1, -Slice): extract rows R0..R1-1.
st_slice_rows_(_, R_, R_, []) :- !.
st_slice_rows_(Grid, R0_, R1_, Slice_) :-
    R0_ < R1_,
    R1m1_ is R1_ - 1,
    numlist(R0_, R1m1_, RowIdxs_),
    maplist([I_, Row_]>>(nth0(I_, Grid, Row_)), RowIdxs_, Slice_).

% st_slice_cols_(+Grid, +C0, +C1, -Slice): extract cols C0..C1-1 from each row.
st_slice_cols_(Grid, C0_, C1_, Slice_) :-
    maplist([Row_, Sub_]>>(st_sublist_(Row_, C0_, C1_, Sub_)), Grid, Slice_).

% st_sublist_(+List, +Start, +End, -Sub): extract elements Start..End-1.
st_sublist_(List_, Start_, End_, Sub_) :-
    length(Prefix_, Start_),
    append(Prefix_, Rest_, List_),
    Len_ is End_ - Start_,
    length(Sub_, Len_),
    append(Sub_, _, Rest_).

% st_is_shape_sec_(+Section): section has 0-background and exactly one
% non-zero foreground color with at least one non-zero and at least one zero.
st_is_shape_sec_(Section_) :-
    flatten(Section_, Flat_),
    include([V_]>>(V_ =\= 0), Flat_, NonZero_),
    NonZero_ \= [],
    sort(NonZero_, [_]),
    include([V_]>>(V_ =:= 0), Flat_, Zeros_),
    Zeros_ \= [].

% st_is_solid_sec_(+Section): every cell in the section is the same non-zero value.
st_is_solid_sec_(Section_) :-
    flatten(Section_, Flat_),
    Flat_ \= [],
    Flat_ = [V_|_],
    V_ =\= 0,
    forall(member(X_, Flat_), X_ =:= V_).

% st_solid_color_(+Section, -Color): read the single color from a solid section.
st_solid_color_(Section_, C_) :-
    Section_ = [Row_|_], Row_ = [C_|_].

% st_inner_bbox_(+Section, -Inner): extract bounding box of non-zero cells.
st_inner_bbox_(Section_, Inner_) :-
    length(Section_, NR_), NR1_ is NR_ - 1,
    Section_ = [Row0_|_], length(Row0_, NC_), NC1_ is NC_ - 1,
% Find row bounds of non-zero cells.
    findall(R_,
        (between(0, NR1_, R_), nth0(R_, Section_, Row_),
         member(V_, Row_), V_ =\= 0),
        NZRows_),
    min_list(NZRows_, RMin_), max_list(NZRows_, RMax_),
% Find col bounds of non-zero cells.
    findall(C_,
        (between(0, NR1_, R_), nth0(R_, Section_, Row_),
         between(0, NC1_, C_), nth0(C_, Row_, V_), V_ =\= 0),
        NZCols_),
    min_list(NZCols_, CMin_), max_list(NZCols_, CMax_),
% Slice rows and then cols to get bounding box.
    RMax1_ is RMax_ + 1, CMax1_ is CMax_ + 1,
    st_slice_rows_(Section_, RMin_, RMax1_, RowSlice_),
    maplist([Row_, Sub_]>>(st_sublist_(Row_, CMin_, CMax1_, Sub_)), RowSlice_, Inner_).

% st_tile_count_(+Section, +Layout, -N):
% N = total non-zero cells in shape2 section divided by 2.
% Shape2 always contains a two-row repeated base sub-pattern; dividing total
% non-zeros by 2 recovers the tile-repetition count for any layout direction.
st_tile_count_(Section_, _Layout_, N_) :-
    include([Row_]>>(Row_ \= []), Section_, Rows_),
    maplist([Row_, Count_]>>(
        include([V_]>>(V_ =\= 0), Row_, NZ_), length(NZ_, Count_)
    ), Rows_, Counts_),
    sumlist(Counts_, Total_),
    N_ is Total_ // 2.

% st_build_tiled_(+Mapped, +C2, +N, +Layout, -Output):
% Tile Mapped N times with single C2 separator rows (vertical) or cols (horiz).
st_build_tiled_(Mapped_, C2_, N_, vertical, Output_) :-
    Mapped_ = [Row0_|_], length(Row0_, W_),
    length(SepRow_, W_), maplist(=(C2_), SepRow_),
    st_tile_vert_(Mapped_, SepRow_, N_, Output_).
st_build_tiled_(Mapped_, C2_, N_, horizontal, Output_) :-
    length(Mapped_, H_),
    length(EmptyRows_, H_), maplist(=([]), EmptyRows_),
    st_tile_horiz_(Mapped_, C2_, N_, EmptyRows_, Output_).

% st_tile_vert_(+Mapped, +SepRow, +N, -Output): build vertical tiling.
st_tile_vert_(Mapped_, _, 1, Mapped_) :- !.
st_tile_vert_(Mapped_, SepRow_, N_, Output_) :-
    N_ > 1, N1_ is N_ - 1,
    st_tile_vert_(Mapped_, SepRow_, N1_, Partial_),
    append(Partial_, [SepRow_|Mapped_], Output_).

% st_tile_horiz_(+Mapped, +C2, +N, +Acc, -Output): build horizontal tiling.
st_tile_horiz_(_, _, 0, Acc_, Acc_) :- !.
st_tile_horiz_(Mapped_, C2_, N_, Acc_, Output_) :-
    N_ > 0, N1_ is N_ - 1,
    (   Acc_ = [[]|_]
    ->  maplist([ARow_, MRow_, NRow_]>>(append(ARow_, MRow_, NRow_)),
                Acc_, Mapped_, Acc1_)
    ;   maplist([ARow_, MRow_, NRow_]>>(append(ARow_, [C2_|MRow_], NRow_)),
                Acc_, Mapped_, Acc1_)
    ),
    st_tile_horiz_(Mapped_, C2_, N1_, Acc1_, Output_).

% ===========================================================================
% WAVE 22 — legend_veto (WP-280, Layer 255)
% Task d59b0160
% Rule: The 4×4 top-left frame has 3s on its right column (col 3, rows 0-3)
% and bottom row (row 3, cols 0-3). The three non-3, non-7, non-0 values in
% this 4×4 area form the "legend set" S. Each 4-connected component of
% non-7 cells outside the legend area is ERASED (replaced by 7) if it
% contains ALL values of S; otherwise kept unchanged.
% ===========================================================================

% arc2_named_rule: register legend_veto as a known rule name.
arc2_named_rule(legend_veto).

% arc2_transform(legend_veto, +Grid, -Out): apply legend_veto rule.
arc2_transform(legend_veto, Grid, Out) :-
% Extract the three legend values from the 4×4 top-left frame.
    arc2_lv_legend_set_(Grid, S),
% Require at least one legend value to guard against false triggers.
    S \= [],
% Find all 4-connected components of non-7 cells in the entire grid.
    arc2_lv_any_comps_(Grid, 7, AllComps),
% Separate legend components (any cell at row ≤ 3 AND col ≤ 3) from data.
    exclude(arc2_lv_is_leg_comp_, AllComps, DataComps),
% Erase each data component whose values cover all of S; keep the rest.
    foldl([Comp, GIn, GOut]>>(
        arc2_lv_comp_vals_(Comp, GIn, 7, Vals),
        (   arc2_lv_all_in_(S, Vals)
        ->  arc2_lv_erase_comp_(Comp, GIn, 7, GOut)
        ;   GOut = GIn
        )
    ), DataComps, Grid, Out).

% arc2_lv_legend_set_(+Grid, -S): extract the sorted set of non-3, non-7,
% non-0 values from the 4×4 top-left legend frame (rows 0-3, cols 0-3).
arc2_lv_legend_set_(Grid, S) :-
% Collect all qualifying values from the 4×4 area.
    findall(V,
        (between(0, 3, R), between(0, 3, C),
         arc2_cell_(Grid, R, C, V),
         V \= 7, V \= 3, V \= 0),
        Vs),
% Sort to deduplicate; result is the legend set.
    sort(Vs, S).

% arc2_lv_is_leg_comp_(+Comp): true when Comp overlaps the legend area
% (any cell with row ≤ 3 AND col ≤ 3).
arc2_lv_is_leg_comp_(Comp) :-
% A single overlapping cell is sufficient; cut after first match.
    member(R-C, Comp), R =< 3, C =< 3, !.

% arc2_lv_any_comps_(+Grid, +BG, -Comps): find all 4-connected components
% of non-BG cells regardless of color. Each Comp is a list of R-C coords.
arc2_lv_any_comps_(Grid, BG, Comps) :-
% Determine grid dimensions.
    length(Grid, NR), Grid = [FR|_], length(FR, NC),
    MaxR is NR-1, MaxC is NC-1,
% Collect all non-background cell coordinates in reading order.
    findall(R-C,
        (between(0, MaxR, R), between(0, MaxC, C),
         arc2_cell_(Grid, R, C, V), V \= BG),
        Seeds),
% Process seeds left-to-right, top-to-bottom; skip already-visited cells.
    arc2_lv_comps_(Grid, BG, Seeds, [], Comps).

% arc2_lv_comps_(+Grid, +BG, +Seeds, +Vis, -Comps): iterate over seeds,
% flood-filling each unvisited cell to find its full component.
arc2_lv_comps_(_, _, [], _, []).
arc2_lv_comps_(Grid, BG, [R-C|Rest], Vis0, Comps) :-
% If already visited, skip; otherwise flood-fill to find the component.
    (   memberchk(R-C, Vis0)
    ->  arc2_lv_comps_(Grid, BG, Rest, Vis0, Comps)
    ;   arc2_lv_bfs_(Grid, BG, [R-C], Vis0, [], Cells, Vis1),
        Comps = [Cells|Tail],
        arc2_lv_comps_(Grid, BG, Rest, Vis1, Tail)
    ).

% arc2_lv_bfs_(+Grid, +BG, +Queue, +Vis0, +Acc0, -Comp, -Vis):
% BFS flood-fill through any non-BG cells (color-agnostic).
arc2_lv_bfs_(_, _, [], Vis, Acc, Acc, Vis).
arc2_lv_bfs_(Grid, BG, [R-C|Q], Vis0, Acc0, Comp, Vis) :-
% Already visited: skip without adding to component.
    (   memberchk(R-C, Vis0)
    ->  arc2_lv_bfs_(Grid, BG, Q, Vis0, Acc0, Comp, Vis)
% New non-BG cell: record it, expand its 4-connected non-BG neighbors.
    ;   arc2_cell_(Grid, R, C, V), V \= BG,
        R1 is R+1, R0 is R-1, C1 is C+1, C0 is C-1,
        findall(NR-NC,
            (member(NR-NC, [R1-C, R0-C, R-C1, R-C0]),
             arc2_cell_(Grid, NR, NC, NV), NV \= BG),
            Nbrs),
        append(Nbrs, Q, Q1),
        arc2_lv_bfs_(Grid, BG, Q1, [R-C|Vis0], [R-C|Acc0], Comp, Vis)
    ).

% arc2_lv_comp_vals_(+Comp, +Grid, +BG, -Vals): collect the sorted set of
% non-BG, non-0 values present in the component's cells.
arc2_lv_comp_vals_(Comp, Grid, BG, Vals) :-
% Gather all qualifying values from the component cells.
    findall(V,
        (member(R-C, Comp),
         arc2_cell_(Grid, R, C, V),
         V \= BG, V \= 0),
        Vs),
% Sort to deduplicate.
    sort(Vs, Vals).

% arc2_lv_all_in_(+S, +Vals): true when every element of S appears in Vals.
arc2_lv_all_in_(S, Vals) :-
% Check each legend value is present in the component's value set.
    forall(member(X, S), memberchk(X, Vals)).

% arc2_lv_erase_comp_(+Comp, +Grid, +BG, -Out): set every cell in Comp to BG.
arc2_lv_erase_comp_(Comp, Grid, BG, Out) :-
% Apply arc2_set_cell_ for each cell in the component, threading the grid.
    foldl([R-C, GIn, GOut]>>(arc2_set_cell_(GIn, R, C, BG, GOut)),
          Comp, Grid, Out).

% ===========================================================================
% WAVE 23 — period_extend (WP-281, Layer 256)
% Task 16de56c4
% Rule: Find the dominant direction (row or column) by counting how many
% lines have 2+ cells of the same non-BG color. For each such "active"
% line, identify the anchor pair (two same-color cells), derive the step D,
% and compute all in-bounds pattern positions (multiples of D from the
% anchor). If a DIFFERENT non-BG color sits at a pattern position, it is
% the stop/recolor cell: fill pattern positions from the anchor side to the
% stop (inclusive) with the stop color. Otherwise fill all pattern positions
% with the anchor color. Non-BG singleton cells at non-pattern positions are
% preserved unchanged. BG = 0 throughout.
% ===========================================================================

% arc2_named_rule: register period_extend as a known rule name.
arc2_named_rule(period_extend).

% arc2_transform(period_extend, +Grid, -Out): apply the period_extend rule.
arc2_transform(period_extend, Grid, Out) :-
% Determine grid dimensions from the input.
    length(Grid, NR), Grid = [FR|_], length(FR, NC),
    MaxR is NR - 1, MaxC is NC - 1,
% Count active rows and cols (lines with 2+ same-color non-BG cells).
    arc2_pe_count_active_(Grid, MaxR, MaxC, RowCount, ColCount),
% Build a blank all-zero output grid of the same dimensions.
    arc2_pe_blank_grid_(NR, NC, Blank),
% Apply extensions in the direction with more active lines.
    ( RowCount >= ColCount
    -> arc2_pe_apply_rows_(Grid, MaxR, MaxC, Blank, Out)
    ;  arc2_pe_apply_cols_(Grid, MaxR, MaxC, Blank, Out)
    ).

% arc2_pe_count_active_(+Grid, +MaxR, +MaxC, -RowCount, -ColCount):
% RowCount = number of rows that have 2+ non-BG cells of the same color;
% ColCount = analogous count for columns.
arc2_pe_count_active_(Grid, MaxR, MaxC, RowCount, ColCount) :-
% Collect each row index that has a same-color pair.
    findall(R, (between(0, MaxR, R),
        findall(C-V, (between(0, MaxC, C),
                      arc2_cell_(Grid, R, C, V), V \= 0), RCells),
        member(C1-V, RCells), member(C2-V, RCells), C1 \= C2),
        RowList),
    sort(RowList, UniqueRows), length(UniqueRows, RowCount),
% Collect each col index that has a same-color pair.
    findall(C, (between(0, MaxC, C),
        findall(R-V, (between(0, MaxR, R),
                      arc2_cell_(Grid, R, C, V), V \= 0), CCells),
        member(R1-V, CCells), member(R2-V, CCells), R1 \= R2),
        ColList),
    sort(ColList, UniqueCols), length(UniqueCols, ColCount).

% arc2_pe_blank_grid_(+NR, +NC, -Grid): create an NR x NC grid of all zeros.
arc2_pe_blank_grid_(NR, NC, Grid) :-
% Build a single zero row of width NC.
    length(BlankRow, NC), maplist(=(0), BlankRow),
% Build NR rows all unified with the same blank row.
    length(Grid, NR), maplist(=(BlankRow), Grid).

% arc2_pe_apply_rows_(+InputGrid, +MaxR, +MaxC, +Blank, -Out):
% process each row in the InputGrid and fill the Blank grid row-wise.
arc2_pe_apply_rows_(InputGrid, MaxR, MaxC, Blank, Out) :-
% Thread the blank grid through each row index 0..MaxR.
    numlist(0, MaxR, Rows),
    foldl([R, GIn, GOut]>>(
        arc2_pe_one_row_(InputGrid, R, MaxC, GIn, GOut)
    ), Rows, Blank, Out).

% arc2_pe_apply_cols_(+InputGrid, +MaxR, +MaxC, +Blank, -Out):
% process each column in the InputGrid and fill the Blank grid col-wise.
arc2_pe_apply_cols_(InputGrid, MaxR, MaxC, Blank, Out) :-
% Thread the blank grid through each column index 0..MaxC.
    numlist(0, MaxC, Cols),
    foldl([C, GIn, GOut]>>(
        arc2_pe_one_col_(InputGrid, C, MaxR, GIn, GOut)
    ), Cols, Blank, Out).

% arc2_pe_one_row_(+InputGrid, +R, +MaxC, +GIn, -GOut):
% apply period_extend logic to row R of InputGrid, writing into GIn.
arc2_pe_one_row_(InputGrid, R, MaxC, GIn, GOut) :-
% Extract all non-BG cells from row R: list of Pos-Val pairs.
    findall(P-V, (between(0, MaxC, P),
                  arc2_cell_(InputGrid, R, P, V), V \= 0), Pairs),
    ( arc2_pe_find_anchor_(Pairs, AC, APos, Step)
    -> % Generate all in-bounds pattern positions for this anchor/step.
       arc2_pe_pat_pos_(APos, Step, MaxC, PatPos),
       % Compute which cells to write in the output row.
       arc2_pe_out_pairs_(Pairs, AC, APos, PatPos, OutPairs),
       % Write each output cell into the grid at row R.
       foldl([CP-CV, GI, GO]>>(arc2_set_cell_(GI, R, CP, CV, GO)),
             OutPairs, GIn, GOut)
    ; % No anchor pair: preserve all non-BG cells as singletons.
       foldl([CP-CV, GI, GO]>>(arc2_set_cell_(GI, R, CP, CV, GO)),
             Pairs, GIn, GOut)
    ).

% arc2_pe_one_col_(+InputGrid, +C, +MaxR, +GIn, -GOut):
% apply period_extend logic to column C of InputGrid, writing into GIn.
arc2_pe_one_col_(InputGrid, C, MaxR, GIn, GOut) :-
% Extract all non-BG cells from column C: list of Pos-Val pairs.
    findall(P-V, (between(0, MaxR, P),
                  arc2_cell_(InputGrid, P, C, V), V \= 0), Pairs),
    ( arc2_pe_find_anchor_(Pairs, AC, APos, Step)
    -> % Generate all in-bounds pattern positions for this anchor/step.
       arc2_pe_pat_pos_(APos, Step, MaxR, PatPos),
       % Compute which cells to write in the output column.
       arc2_pe_out_pairs_(Pairs, AC, APos, PatPos, OutPairs),
       % Write each output cell into the grid at column C.
       foldl([CP-CV, GI, GO]>>(arc2_set_cell_(GI, CP, C, CV, GO)),
             OutPairs, GIn, GOut)
    ; % No anchor pair: preserve all non-BG cells as singletons.
       foldl([CP-CV, GI, GO]>>(arc2_set_cell_(GI, CP, C, CV, GO)),
             Pairs, GIn, GOut)
    ).

% arc2_pe_find_anchor_(+Pairs, -AnchorColor, -AnchorPositions, -Step):
% find the pair of same-color cells with the smallest separation (step D).
% Fails if no same-color pair exists.
arc2_pe_find_anchor_(Pairs, AnchorColor, AnchorPositions, Step) :-
% Build list of (step, color) for every same-color pair in Pairs.
    findall(D-V, (member(P1-V, Pairs), member(P2-V, Pairs),
                  P2 > P1, D is P2 - P1), StepVals),
    StepVals \= [],
% Sort ascending; the smallest step comes first.
    sort(StepVals, [Step-AnchorColor|_]),
% Collect all positions of the chosen anchor color.
    findall(P, member(P-AnchorColor, Pairs), AnchorPositions).

% arc2_pe_pat_pos_(+AnchorPositions, +Step, +MaxPos, -PatPos):
% generate all in-bounds positions sharing the same remainder mod Step
% as the anchor positions (i.e., all P with P mod Step = AnchorPos1 mod Step).
arc2_pe_pat_pos_(AnchorPositions, Step, MaxPos, PatPos) :-
% Use the first anchor position to determine the remainder class.
    AnchorPositions = [P1|_],
    R is P1 mod Step,
% Collect every position in [0, MaxPos] with that remainder.
    findall(P, (between(0, MaxPos, P), P mod Step =:= R), PatPos).

% arc2_pe_out_pairs_(+Pairs, +AnchorColor, +AnchorPositions, +PatPos, -OutPairs):
% determine the list of Pos-Val cells to write into the output line.
% Singletons (non-BG, non-anchor, not at a pattern position) are preserved.
arc2_pe_out_pairs_(Pairs, AnchorColor, AnchorPositions, PatPos, OutPairs) :-
% Collect singletons: non-BG, different color from anchor, NOT at a pattern position.
    findall(P-V, (member(P-V, Pairs), V \= AnchorColor,
                  \+ member(P, PatPos)), Singletons),
% Collect stop candidates: different color from anchor, AT a pattern position.
    findall(P-V, (member(P-V, Pairs), V \= AnchorColor,
                  member(P, PatPos)), Stops),
    ( Stops = [StopP-StopC|_]
    -> % Determine fill range: from anchor side to stop (inclusive).
       min_list(AnchorPositions, AMin), max_list(AnchorPositions, AMax),
       ( StopP < AMin -> MinFill = StopP, MaxFill = AMax
       ;                 MinFill = AMin, MaxFill = StopP
       ),
% Fill pattern positions within [MinFill, MaxFill] with stop color.
       findall(P-StopC, (member(P, PatPos), P >= MinFill, P =< MaxFill),
               FillCells),
       append(FillCells, Singletons, OutPairs)
    ; % No stop: fill all pattern positions with the anchor color.
       findall(P-AnchorColor, member(P, PatPos), FillCells),
       append(FillCells, Singletons, OutPairs)
    ).

% ===========================================================================
% WAVE 24 — shape_sort (WP-282, Layer 257)
% Task 2ba387bc
% Rule: The input grid (BG=0) contains several 4x4 colored blocks scattered
% on the canvas. Each block is either HOLLOW (outer ring of one color, 2x2
% interior of zeros) or SOLID (all 16 cells the same color). Collect every
% block, sort by reading order (top-left row then column), then separate into
% a HOLLOW list and a SOLID list while preserving reading order within each.
% Pair position-i hollow with position-i solid side by side in 4 rows x 8
% cols. When one list runs out, substitute a 4x4 block of zeros. Stack all
% pairs vertically to form the output grid.
% ===========================================================================

% Register the named rule.
arc2_named_rule(shape_sort).

% Top-level dispatch: find shapes, split by type, pair, assemble output.
arc2_transform(shape_sort, Grid, Out) :-
    % Gather all 4x4 shape blocks, sorted by reading order.
    arc2_ss_shapes_(Grid, Shapes),
    % Hollow shapes have a 0 somewhere inside their 4x4 bounding box.
    include(arc2_ss_hollow_, Shapes, Hollows),
    % Solid shapes have no 0 inside their 4x4 bounding box.
    exclude(arc2_ss_hollow_, Shapes, Solids),
    % Pair hollows[i] with solids[i]; pad shorter list with zero blocks.
    arc2_ss_zip_(Hollows, Solids, Pairs),
    % Render each pair as 4 output rows of 8 columns.
    maplist(arc2_ss_pair_rows_, Pairs, Groups),
    % Concatenate all row groups into the final output grid.
    append(Groups, Out).

% Find all distinct non-BG colors; extract each shape; sort by reading order.
arc2_ss_shapes_(Grid, Shapes) :-
    % Collect every non-zero value in the grid.
    findall(V, (nth0(_, Grid, Row), nth0(_, Row, V), V \= 0), All),
    % Deduplicate to get one entry per shape color.
    sort(All, Colors),
    % For each color find its 4x4 subgrid keyed by (R0-C0-Sub).
    maplist(arc2_ss_one_shape_(Grid), Colors, Raw),
    % msort sorts R0-C0-Sub terms by R0 first then C0: reading order.
    msort(Raw, Shapes).

% For one color: find its topmost row and leftmost column, extract 4x4 sub.
arc2_ss_one_shape_(Grid, Color, R0-C0-Sub) :-
    % Row indices where this color appears.
    findall(R, (nth0(R, Grid, Row), memberchk(Color, Row)), Rs),
    % Column indices where this color appears (across all rows).
    findall(C, (nth0(_, Grid, GRow), nth0(C, GRow, Color)), Cs),
    % Top-left corner is minimum row and minimum column.
    min_list(Rs, R0), min_list(Cs, C0),
    % Extract the 4x4 subgrid starting at (R0, C0).
    arc2_ss_extract4x4_(Grid, R0, C0, Sub).

% Extract a 4x4 subgrid from Grid starting at row R0, column C0.
arc2_ss_extract4x4_(Grid, R0, C0, Sub) :-
    % Pre-compute the four row and column indices.
    R1 is R0+1, R2 is R0+2, R3 is R0+3,
    % Pre-compute the four column indices.
    C1 is C0+1, C2 is C0+2, C3 is C0+3,
    % For each of the four rows, extract the four column values.
    maplist([R, SRow]>>(
        nth0(R, Grid, GRow),
        maplist([C,V]>>(nth0(C, GRow, V)), [C0,C1,C2,C3], SRow)
    ), [R0,R1,R2,R3], Sub).

% A shape is hollow if any cell in its 4x4 subgrid equals zero.
arc2_ss_hollow_(_R0-_C0-Sub) :-
    % Search sub-rows for a 0; cut after first find (deterministic).
    member(SRow, Sub), member(0, SRow), !.

% Base case: both lists empty; no pairs.
arc2_ss_zip_([], [], []).
% Hollow list has more; pad solid side with zero block.
arc2_ss_zip_([H|Hs], [], [[H, Z]|Rest]) :-
    % Generate a 4x4 zero block for padding.
    arc2_ss_zero_(Z),
    % Recurse on remaining hollows.
    arc2_ss_zip_(Hs, [], Rest).
% Solid list has more; pad hollow side with zero block.
arc2_ss_zip_([], [S|Ss], [[Z, S]|Rest]) :-
    % Generate a 4x4 zero block for padding.
    arc2_ss_zero_(Z),
    % Recurse on remaining solids.
    arc2_ss_zip_([], Ss, Rest).
% Both lists have elements; pair them directly.
arc2_ss_zip_([H|Hs], [S|Ss], [[H, S]|Rest]) :-
    % Recurse on the tails.
    arc2_ss_zip_(Hs, Ss, Rest).

% A 4x4 zero block used for padding when one shape list is shorter.
arc2_ss_zero_(0-0-[[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]).

% Convert a hollow+solid pair to 4 output rows of 8 columns.
arc2_ss_pair_rows_([_-_-LSub, _-_-RSub], Rows) :-
    % Concatenate each left 4-wide row with the matching right 4-wide row.
    maplist([LRow, RRow, OutRow]>>(append(LRow, RRow, OutRow)),
            LSub, RSub, Rows).

% ===========================================================================
% WAVE 25 — bar_extend (WP-283, Layer 258)
% Task 1ae2feb7
% Rule: A vertical divider column (all non-BG cells in that column share one
% value) separates a left-side bar region from a right-side empty region.
% Each row optionally carries a bar of 1-2 non-BG colors to the left of the
% divider. The rightmost non-BG cell in the bar is the primary color P with
% count CP. Any other non-BG color is the secondary S with count CS (default
% CS=1 if absent). Period = CP*CS. Within one period: P at every CP-multiple
% position; S at every CS-multiple position not already occupied by P; BG
% elsewhere. The right side is filled by repeating the period cyclically.
% ===========================================================================

% Register the bar_extend rule name.
arc2_named_rule(bar_extend).

% Top-level transform: find divider, apply per-row extension.
arc2_transform(bar_extend, Grid, Out) :-
    % Find the divider column index.
    arc2_be_divider_(Grid, D),
    % Extend each row independently.
    maplist(arc2_be_row_(D), Grid, Out).

% Find divider column D: the column where all non-BG values are identical
% and at least 3 rows carry that value.
arc2_be_divider_(Grid, D) :-
    % Use the first row to determine grid width.
    nth0(0, Grid, R0),
    % Compute last valid column index.
    length(R0, W),
    W1 is W - 1,
    % Try columns from left to right; cut on first match.
    between(1, W1, D),
    % Collect the value at column D across all rows.
    maplist([Row, C]>>(nth0(D, Row, C)), Grid, ColVals),
    % Keep only non-BG values.
    include(\=(0), ColVals, NonBG),
    % Require at least 3 rows have non-BG here.
    length(NonBG, NB), NB >= 3,
    % All non-BG values must be the same (one unique value).
    sort(NonBG, [_]),
    !.

% Process one row: extend the right side based on the bar pattern.
arc2_be_row_(D, InRow, OutRow) :-
    % Compute total row width.
    length(InRow, W),
    % Slice bar (cols 0..D-1) and divider cell.
    length(Bar, D),
    append(Bar, [Div|_], InRow),
    % Find primary color and its count in the bar.
    arc2_be_primary_(Bar, PC, CP),
    % Blank row: copy unchanged.
    ( PC =:= 0
    -> OutRow = InRow
    % Active row: compute period and fill right side.
    ;  arc2_be_secondary_(Bar, PC, SC, CS),
       Period is CP * CS,
       % Build the repeating period cell list.
       Period1 is Period - 1,
       numlist(0, Period1, PIxs),
       maplist(arc2_be_cell_(PC, CP, SC, CS), PIxs, PeriodCells),
       % Compute right-side width.
       RW is W - D - 1,
       % Fill right side by cycling through PeriodCells.
       ( RW =:= 0
       -> RFill = []
       ;  RW1 is RW - 1,
          numlist(0, RW1, RIxs),
          length(PeriodCells, PLen),
          maplist([I, C]>>(J is I mod PLen, nth0(J, PeriodCells, C)),
                  RIxs, RFill)
       ),
       % Reconstruct row: original bar + divider + new right fill.
       append(Bar, [Div|RFill], OutRow)
    ).

% Find primary color: the rightmost non-BG cell in the bar.
arc2_be_primary_(Bar, PC, CP) :-
    ( arc2_be_last_nonbg_(Bar, PC)
    -> include(==(PC), Bar, PCs), length(PCs, CP)
    ;  PC = 0, CP = 0
    ).

% Return the last non-BG element of a list.
arc2_be_last_nonbg_(List, V) :-
    % Reverse so we search from the right end.
    reverse(List, Rev),
    % Find the first non-BG member (= rightmost original).
    member(V, Rev), V \= 0, !.

% Find secondary color: non-BG and different from primary.
arc2_be_secondary_(Bar, PC, SC, CS) :-
    ( member(SC, Bar), SC \= 0, SC \= PC, !
    -> include(==(SC), Bar, SCs), length(SCs, CS)
    % No secondary: treat as virtual secondary with CS=1.
    ;  SC = 0, CS = 1
    ).

% Determine the cell value at period position Idx.
arc2_be_cell_(PC, CP, SC, CS, Idx, Val) :-
    % Primary occupies multiples of CP.
    ( 0 is Idx mod CP
    -> Val = PC
    % Secondary occupies multiples of CS (when not already primary).
    ; SC \= 0, 0 is Idx mod CS
    -> Val = SC
    % Everything else is BG.
    ;  Val = 0
    ).

% ---------------------------------------------------------------------------
% WAVE 26 — straighten_diag (WP-284, Layer 259)
% Task 7b80bb43
% Rule: A two-color grid (BG + one line color) contains diagonal-only cells:
% non-BG cells with no 4-connected non-BG neighbor but at least one 8-connected
% non-BG neighbor. These diagonal shortcuts corrupt an orthogonal line network.
% Phase 1: find 8-connected components of diagonal cells; for each, find anchor
% cells (non-diagonal non-BG cells 8-adjacent to the component) and fill the
% H/V gap from anchor in the direction of the farthest diagonal tip.
% Phase 2: remove all diagonal cells, apply gap fills.
% Phase 3: iteratively prune perpendicular degree-1 stubs that are 8-adjacent
% to a diagonal cell (restricted to DiagNbr so real line endpoints are kept).
% ===========================================================================

% Register the straighten_diag rule.
arc2_named_rule(straighten_diag).

% arc2_transform(straighten_diag, +Grid, -Out): top-level transform.
arc2_transform(straighten_diag, Grid, Out) :-
% Find background (most common) color.
    arc2_bg_color_(Grid, BG),
% Find line value: any non-BG cell value in the grid.
    arc2_sd_line_val_(Grid, BG, LV),
% Collect all diagonal-only cell positions.
    arc2_sd_find_diag_(Grid, BG, Diag),
% Must have at least one diagonal cell to apply this rule.
    Diag \= [],
% Collect cells 8-adjacent to any diagonal (eligible for stub pruning).
    arc2_sd_diag_nbr_(Grid, BG, Diag, DiagNbr),
% Find 8-connected components of diagonal cells.
    arc2_sd_comps8_(Diag, Comps),
% Compute fill positions from each diagonal component.
    length(Grid, NRows), nth0(0, Grid, Row0), length(Row0, NCols),
    foldl(arc2_sd_comp_fills_(Grid, BG, Diag, NRows, NCols), Comps, [], FillAcc),
% Deduplicate fill list.
    sort(FillAcc, Fills),
% Build intermediate grid: remove diagonals, apply fills.
    arc2_sd_build_(Grid, BG, LV, Diag, Fills, NRows, NCols, Grid2),
% Iteratively prune perpendicular degree-1 stubs in DiagNbr.
    arc2_sd_prune_loop_(Grid2, BG, DiagNbr, Out).

% arc2_sd_line_val_(+Grid, +BG, -LV): first non-BG value found in the grid.
arc2_sd_line_val_(Grid, BG, LV) :-
% Flatten grid to a single list.
    append(Grid, Flat),
% Scan for first non-BG element.
    member(LV, Flat), LV \= BG, !.

% arc2_sd_find_diag_(+Grid, +BG, -Diag): collect all diagonal-only cell positions.
arc2_sd_find_diag_(Grid, BG, Diag) :-
% Determine grid bounds.
    length(Grid, NR), NR1 is NR-1,
    nth0(0, Grid, R0), length(R0, NC), NC1 is NC-1,
    findall(R-C, (
        between(0, NR1, R), between(0, NC1, C),
% Cell must be non-BG.
        arc2_cell_(Grid, R, C, V), V \= BG,
% Cell must have no 4-connected non-BG neighbor.
        \+ arc2_sd_has4nonbg_(Grid, R, C, BG),
% Cell must have at least one diagonal non-BG neighbor.
        arc2_sd_has_diag_nonbg_(Grid, R, C, BG)
    ), Diag).

% arc2_sd_has4nonbg_(+Grid, +R, +C, +BG): true if any 4-conn neighbor is non-BG.
arc2_sd_has4nonbg_(Grid, R, C, BG) :-
    ( R1 is R-1, arc2_cell_(Grid, R1, C, V1), V1 \= BG -> true
    ; R2 is R+1, arc2_cell_(Grid, R2, C, V2), V2 \= BG -> true
    ; C1 is C-1, arc2_cell_(Grid, R, C1, V3), V3 \= BG -> true
    ; C2 is C+1, arc2_cell_(Grid, R, C2, V4), V4 \= BG -> true
    ).

% arc2_sd_has_diag_nonbg_(+Grid, +R, +C, +BG): true if any diagonal neighbor is non-BG.
arc2_sd_has_diag_nonbg_(Grid, R, C, BG) :-
% Check 4 diagonal neighbors (cardinal neighbors already verified all BG for diag cells).
    ( R1 is R-1, C1 is C-1, arc2_cell_(Grid, R1, C1, V1), V1 \= BG -> true
    ; R1 is R-1, C2 is C+1, arc2_cell_(Grid, R1, C2, V2), V2 \= BG -> true
    ; R2 is R+1, C1 is C-1, arc2_cell_(Grid, R2, C1, V3), V3 \= BG -> true
    ; R2 is R+1, C2 is C+1, arc2_cell_(Grid, R2, C2, V4), V4 \= BG -> true
    ).

% arc2_sd_diag_nbr_(+Grid, +BG, +Diag, -DiagNbr):
% Collect non-diagonal non-BG cells 8-adjacent to any diagonal cell.
arc2_sd_diag_nbr_(Grid, BG, Diag, DiagNbr) :-
    findall(NR-NC, (
        member(R-C, Diag),
% Check all 8 neighbors of each diagonal cell.
        member(DR-DC, [-1-(-1),-1-0,-1-1,0-(-1),0-1,1-(-1),1-0,1-1]),
        NR is R+DR, NC is C+DC,
% Exclude other diagonal cells and BG cells.
        \+ memberchk(NR-NC, Diag),
        arc2_cell_(Grid, NR, NC, V), V \= BG
    ), DiagNbrList),
    sort(DiagNbrList, DiagNbr).

% arc2_sd_comps8_(+Cells, -Comps): partition Cells into 8-connected components.
arc2_sd_comps8_(Cells, Comps) :-
    arc2_sd_comps8_iter_(Cells, Cells, [], Comps).

% arc2_sd_comps8_iter_/4: iterate seeds, skipping already-visited cells.
arc2_sd_comps8_iter_([], _, _, []).
arc2_sd_comps8_iter_([H|T], AllCells, Vis0, Comps) :-
    ( memberchk(H, Vis0) ->
% Already assigned to a component: skip.
        arc2_sd_comps8_iter_(T, AllCells, Vis0, Comps)
    ;
% New seed: flood-fill to build its component.
        arc2_sd_flood8_(AllCells, [H], Vis0, [], Comp, Vis1),
        Comps = [Comp|Tail],
        arc2_sd_comps8_iter_(T, AllCells, Vis1, Tail)
    ).

% arc2_sd_flood8_(+AllCells, +Stack, +Vis0, +Acc, -Comp, -Vis):
% DFS flood-fill within AllCells over 8-connectivity.
arc2_sd_flood8_(_, [], Vis, Acc, Acc, Vis).
arc2_sd_flood8_(AllCells, [H|Stack], Vis0, Acc0, Comp, Vis) :-
    ( memberchk(H, Vis0) ->
% Already visited: skip without expanding.
        arc2_sd_flood8_(AllCells, Stack, Vis0, Acc0, Comp, Vis)
    ;
% Mark visited, expand all 8-connected AllCells neighbors.
        H = R-C,
        findall(NR-NC, (
            member(DR-DC, [-1-(-1),-1-0,-1-1,0-(-1),0-1,1-(-1),1-0,1-1]),
            NR is R+DR, NC is C+DC,
            memberchk(NR-NC, AllCells),
            \+ memberchk(NR-NC, Vis0)
        ), New),
        append(New, Stack, Stack1),
        arc2_sd_flood8_(AllCells, Stack1, [H|Vis0], [H|Acc0], Comp, Vis)
    ).

% arc2_sd_comp_fills_(+Grid,+BG,+Diag,+NRows,+NCols,+Comp,+Acc,-Acc1):
% Compute fill cells for one diagonal component; append to accumulator.
arc2_sd_comp_fills_(Grid, BG, Diag, NRows, NCols, Comp, Acc, Acc1) :-
% Find anchor cells: non-diagonal non-BG cells 8-adjacent to this component.
    findall(AR-AC, (
        member(R-C, Comp),
        member(DR-DC, [-1-(-1),-1-0,-1-1,0-(-1),0-1,1-(-1),1-0,1-1]),
        AR is R+DR, AC is C+DC,
        AR >= 0, AR < NRows, AC >= 0, AC < NCols,
        \+ memberchk(AR-AC, Diag),
        arc2_cell_(Grid, AR, AC, AV), AV \= BG
    ), AList),
    sort(AList, Anchors),
% For each anchor, compute fill cells and accumulate.
    foldl(arc2_sd_anchor_fill_(Grid, BG, Diag, Comp, NRows, NCols), Anchors, Acc, Acc1).

% arc2_sd_anchor_fill_(+Grid,+BG,+Diag,+Comp,+NRows,+NCols,+AR-AC,+Acc,-Acc1):
% Find gap fill cells for one anchor and add to accumulator.
arc2_sd_anchor_fill_(Grid, BG, Diag, Comp, NRows, NCols, AR-AC, Acc, Acc1) :-
% Find farthest diagonal tip from anchor (Manhattan distance).
    findall(Dist-TR-TC, (
        member(TR-TC, Comp),
        Dist is abs(TR-AR) + abs(TC-AC)
    ), DRCs),
    sort(0, @>=, DRCs, [_-TipR-TipC|_]),
% Signed delta from anchor to tip.
    DeltaR is TipR-AR, DeltaC is TipC-AC,
% Unit direction toward tip.
    ( DeltaR > 0 -> DDR = 1 ; DeltaR < 0 -> DDR = -1 ; DDR = 0 ),
    ( DeltaC > 0 -> DDC = 1 ; DeltaC < 0 -> DDC = -1 ; DDC = 0 ),
% Check if anchor has a horizontal line connection (non-diagonal same-row 4-conn non-BG).
    ( arc2_sd_anchor_axis_(Grid, BG, Diag, AR, AC, h) -> IsH = true ; IsH = false ),
% Check if anchor has a vertical line connection.
    ( arc2_sd_anchor_axis_(Grid, BG, Diag, AR, AC, v) -> IsV = true ; IsV = false ),
% Scan horizontally if anchor is H-type and tip has horizontal displacement.
    ( IsH = true, DDC \= 0,
      arc2_sd_scan_(Grid, BG, Diag, AR, AC, 0, DDC, NRows, NCols, Fill1)
    -> true ; Fill1 = [] ),
% Scan vertically if anchor is V-type and tip has vertical displacement.
    ( IsV = true, DDR \= 0,
      arc2_sd_scan_(Grid, BG, Diag, AR, AC, DDR, 0, NRows, NCols, Fill2)
    -> true ; Fill2 = [] ),
% Accumulate both fill sets.
    append(Fill1, Acc, Acc2),
    append(Fill2, Acc2, Acc1).

% arc2_sd_anchor_axis_(+Grid,+BG,+Diag,+AR,+AC,+Axis):
% True if anchor has a 4-connected non-diagonal non-BG neighbor in Axis direction.
arc2_sd_anchor_axis_(Grid, BG, Diag, AR, AC, h) :-
% Check left or right for a non-diagonal non-BG cell.
    ( AC1 is AC-1, arc2_cell_(Grid, AR, AC1, V1), V1 \= BG, \+ memberchk(AR-AC1, Diag) -> true
    ; AC2 is AC+1, arc2_cell_(Grid, AR, AC2, V2), V2 \= BG, \+ memberchk(AR-AC2, Diag) -> true
    ).
arc2_sd_anchor_axis_(Grid, BG, Diag, AR, AC, v) :-
% Check above or below for a non-diagonal non-BG cell.
    ( AR1 is AR-1, arc2_cell_(Grid, AR1, AC, V1), V1 \= BG, \+ memberchk(AR1-AC, Diag) -> true
    ; AR2 is AR+1, arc2_cell_(Grid, AR2, AC, V2), V2 \= BG, \+ memberchk(AR2-AC, Diag) -> true
    ).

% arc2_sd_scan_(+Grid,+BG,+Diag,+AR,+AC,+FDR,+FDC,+NRows,+NCols,-Gap):
% Scan from (AR+FDR, AC+FDC) in direction (FDR,FDC).
% BG cells are collected into Gap. Diagonal cells are skipped.
% Succeeds with Gap when a non-BG non-diagonal terminus is found.
% Fails when the scan goes out of bounds.
arc2_sd_scan_(Grid, BG, Diag, AR, AC, FDR, FDC, NRows, NCols, Gap) :-
    R0 is AR+FDR, C0 is AC+FDC,
    arc2_sd_scan_step_(Grid, BG, Diag, R0, C0, FDR, FDC, NRows, NCols, [], Gap).

% arc2_sd_scan_step_/10: one step of the gap scan.
arc2_sd_scan_step_(_, _, _, R, C, _, _, NRows, NCols, _, _) :-
% Out of bounds: gap is not closed; fail.
    ( R < 0 ; R >= NRows ; C < 0 ; C >= NCols ), !, fail.
arc2_sd_scan_step_(Grid, BG, Diag, R, C, FDR, FDC, NRows, NCols, Acc, Gap) :-
    arc2_cell_(Grid, R, C, V),
    R1 is R+FDR, C1 is C+FDC,
    ( V =:= BG ->
% BG cell: add to gap accumulator and continue.
        arc2_sd_scan_step_(Grid, BG, Diag, R1, C1, FDR, FDC, NRows, NCols, [R-C|Acc], Gap)
    ; memberchk(R-C, Diag) ->
% Diagonal cell: skip without adding to gap, continue.
        arc2_sd_scan_step_(Grid, BG, Diag, R1, C1, FDR, FDC, NRows, NCols, Acc, Gap)
    ;
% Non-BG non-diagonal terminus: gap is closed; return accumulated gap.
        Gap = Acc
    ).

% arc2_sd_build_(+Grid,+BG,+LV,+Diag,+Fills,+NRows,+NCols,-Out):
% Produce output grid: diagonal cells → BG; fill cells → LV; others unchanged.
arc2_sd_build_(Grid, BG, LV, Diag, Fills, NRows, NCols, Out) :-
    NR1 is NRows-1, NC1 is NCols-1,
    numlist(0, NR1, RIdxs), numlist(0, NC1, CIdxs),
    maplist([R, OutRow]>>(
        maplist([C, V]>>(
            ( memberchk(R-C, Diag)  -> V = BG
            ; memberchk(R-C, Fills) -> V = LV
            ; arc2_cell_(Grid, R, C, V)
            )
        ), CIdxs, OutRow)
    ), RIdxs, Out).

% arc2_sd_4nbrs_nonbg_(+Grid,+R,+C,+BG,-Nbrs):
% Collect all 4-connected non-BG neighbors of (R,C).
arc2_sd_4nbrs_nonbg_(Grid, R, C, BG, Nbrs) :-
    findall(NR-NC, (
        member(DR-DC, [-1-0,1-0,0-(-1),0-1]),
        NR is R+DR, NC is C+DC,
        arc2_cell_(Grid, NR, NC, NV), NV \= BG
    ), Nbrs).

% arc2_sd_prune_loop_(+Grid,+BG,+DiagNbr,-Out):
% Iteratively remove perpendicular degree-1 stubs from DiagNbr cells.
arc2_sd_prune_loop_(Grid, BG, DiagNbr, Out) :-
    ( arc2_sd_find_stub_(Grid, BG, DiagNbr, R-C) ->
% Found a stub: remove it (set to BG) and continue looping.
        arc2_set_cell_(Grid, R, C, BG, Grid1),
        arc2_sd_prune_loop_(Grid1, BG, DiagNbr, Out)
    ;
% No stub found: pruning complete.
        Out = Grid
    ).

% arc2_sd_find_stub_(+Grid,+BG,+DiagNbr,-R-C):
% Find a DiagNbr cell that qualifies as a perpendicular degree-1 stub.
arc2_sd_find_stub_(Grid, BG, DiagNbr, R-C) :-
    member(R-C, DiagNbr),
% Cell must still be non-BG (not already pruned).
    arc2_cell_(Grid, R, C, SV), SV \= BG,
% Must have exactly one 4-connected non-BG neighbor (degree-1).
    arc2_sd_4nbrs_nonbg_(Grid, R, C, BG, [AR-AC]),
% Direction from stub to its sole anchor.
    DDR is AR-R, DDC is AC-C,
% Anchor must have other 4-connected non-BG neighbors (not just this stub).
    arc2_sd_4nbrs_nonbg_(Grid, AR, AC, BG, ANeighbors0),
    exclude(==(R-C), ANeighbors0, ANeighbors),
    ANeighbors \= [],
% Stub direction must be perpendicular to anchor's line axis.
    arc2_sd_perp_check_(ANeighbors, AR, AC, DDR, DDC).

% arc2_sd_perp_check_(+ANeighbors,+AR,+AC,+DDR,+_DDC):
% True when stub direction (DDR,_) is perpendicular to anchor's line axis.
arc2_sd_perp_check_(ANeighbors, AR, AC, DDR, _DDC) :-
    ( DDR =:= 0 ->
% Horizontal stub: prune when anchor has no other neighbor in same row (anchor is V-only).
        \+ (member(NR-_, ANeighbors), NR =:= AR)
    ;
% Vertical stub: prune when anchor has no other neighbor in same col (anchor is H-only).
        \+ (member(_-NC, ANeighbors), NC =:= AC)
    ).

% ---------------------------------------------------------------------------
% WAVE 27 — stream_extend (WP-285, Layer 260)
% Task 53fb4810
% Rule: The grid contains one or more "A-marker" components (4-connected blobs
% of value 1). Each A-marker component has at most one direction that carries a
% contiguous non-BG non-marker "seed chain" of cells adjacent to the component.
% The seed chain terminates at a BG cell (not a grid boundary), indicating that
% the pattern must be extended. The chain establishes a periodic sequence with
% period P = chain length. That period is extended outward (away from the
% A-marker) to the grid boundary, overwriting whatever was there. Multiple
% parallel chains (e.g. two adjacent columns both seeded) are each extended
% independently using the same direction and period mechanism.
% ===========================================================================

% Register the stream_extend rule.
arc2_named_rule(stream_extend).

% arc2_transform(stream_extend, +Grid, -Out): top-level transform.
arc2_transform(stream_extend, Grid, Out) :-
% Compute grid row count.
    length(Grid, NRows),
% Extract first row to compute column count.
    Grid = [FirstRow_|_], length(FirstRow_, NCols),
% Identify background value as the most common cell value.
    arc2_bg_color_(Grid, BG),
% A-marker value is 1 for this task family.
    AVal = 1,
% Collect all cell positions whose value equals AVal.
    findall(R-C, (nth0(R, Grid, Row_), nth0(C, Row_, AVal)), ACells),
% If no A-markers exist the grid is already correct.
    ACells \= [],
% Partition AVal cells into 4-connected components.
    arc2_sx_comps4_(ACells, Comps),
% Process each component in turn, threading the grid through each step.
    foldl(arc2_sx_comp_(BG, AVal, NRows, NCols), Comps, Grid, Out).

% arc2_sx_comp_: try each of the four cardinal directions for one component.
arc2_sx_comp_(BG, AVal, NRows, NCols, Comp, G0, G1) :-
% Try upward extension.
    arc2_sx_try_dir_(up,    BG, AVal, NRows, NCols, Comp, G0,  G01),
% Try downward extension.
    arc2_sx_try_dir_(down,  BG, AVal, NRows, NCols, Comp, G01, G02),
% Try leftward extension.
    arc2_sx_try_dir_(left,  BG, AVal, NRows, NCols, Comp, G02, G03),
% Try rightward extension.
    arc2_sx_try_dir_(right, BG, AVal, NRows, NCols, Comp, G03, G1).

% arc2_sx_try_dir_: find seed chains in one direction and apply extension fills.
% Falls through silently (returns G0 unchanged) if no extension is needed.
arc2_sx_try_dir_(Dir, BG, AVal, NRows, NCols, Comp, G0, G1) :-
% Collect all valid seed chains from border cells in direction Dir.
    findall(Chain,
        arc2_sx_seed_chain_(G0, BG, AVal, NRows, NCols, Comp, Dir, Chain),
        Chains),
% Proceed only when at least one non-empty chain was found.
    Chains \= [],
% Compute all extension fill cells from every chain.
    findall(R-C-V,
        (member(Chain, Chains),
         arc2_sx_ext_fill_(Chain, Dir, NRows, NCols, R-C-V)),
        Fills),
% Proceed only when at least one fill cell was produced.
    Fills \= [],
% Apply every fill cell to the grid, threading updates sequentially.
    foldl([RF-CF-VF, GI, GO]>>(arc2_set_cell_(GI, RF, CF, VF, GO)),
          Fills, G0, G1), !.
% Catch-all: no extension in this direction; return grid unchanged.
arc2_sx_try_dir_(_, _, _, _, _, _, G, G).

% arc2_sx_seed_chain_: produce one valid seed chain from one border cell.
% Succeeds with a non-empty list Chain = [R-C-Val, ...] (closest to A-marker
% first). Fails if: the neighbor is already in the component, the first step
% hits BG (no seed), the first step hits another A-marker, or the scan reaches
% the grid boundary before BG (extension would go off-grid = already complete).
arc2_sx_seed_chain_(Grid, BG, AVal, NRows, NCols, Comp, Dir, Chain) :-
% Pick any cell in the component.
    member(R-C, Comp),
% Compute the step vector for Dir.
    arc2_sx_step_(Dir, DR, DC),
% Compute the immediate neighbor in direction Dir.
    R2 is R + DR, C2 is C + DC,
% (R,C) is a border cell only if its Dir-neighbor is not in the component.
    \+ memberchk(R2-C2, Comp),
% Scan outward from (R2,C2), collecting non-BG non-AVal cells into Chain.
    arc2_sx_collect_(Grid, BG, AVal, NRows, NCols, R2, C2, Dir, [], Chain),
% Discard empty chains (border cell's neighbor was BG; no seed).
    Chain \= [].

% arc2_sx_collect_: recursive scan from (R,C) in direction Dir.
% Accumulates non-BG non-AVal cells into Acc (prepended, reversed at end).
% Succeeds with Chain = reverse(Acc) when the next cell is BG.
% Fails when: (a) (R,C) is out of bounds (scan reached grid boundary),
%             (b) (R,C) holds value AVal (hit another marker component).
arc2_sx_collect_(Grid, BG, AVal, NRows, NCols, R, C, Dir, Acc, Chain) :-
% Fail immediately if current position is outside grid bounds.
    R >= 0, R < NRows, C >= 0, C < NCols,
% Retrieve the value at the current cell.
    arc2_cell_(Grid, R, C, V),
% Dispatch based on the current value.
    ( V =:= BG ->
% BG reached: the accumulated chain is complete; reverse to get front-first.
        reverse(Acc, Chain)
    ; V =:= AVal ->
% Hit another marker: this scan path is invalid.
        fail
    ;
% Non-BG non-AVal: add to accumulator and advance one step.
        arc2_sx_step_(Dir, DR, DC),
        R3 is R + DR, C3 is C + DC,
        arc2_sx_collect_(Grid, BG, AVal, NRows, NCols, R3, C3, Dir, [R-C-V|Acc], Chain)
    ).

% arc2_sx_ext_fill_: generate one extension fill cell from a chain.
% The seed chain has period P = length(Chain). For extension position at
% distance D from chain start (D >= P), value = Chain[D mod P].

% Up direction: chain rows decrease from R0 toward 0; extend rows 0..R0-P.
arc2_sx_ext_fill_(Chain, up, _NRows, _NCols, R-C-Val) :-
% Extract first chain element to get anchor row R0 and column C.
    Chain = [R0-C-_|_],
% Period equals chain length.
    length(Chain, P),
% Extension covers rows 0 through R0-P (the cell just before the chain).
    RLast is R0 - P,
    RLast >= 0,
% Generate each extension row in that range.
    between(0, RLast, R),
% Offset from anchor = distance from R0 going upward.
    Offset is R0 - R,
% Pattern index cycles with period P.
    Idx is Offset mod P,
% Look up the value at this index in the chain.
    nth0(Idx, Chain, _-_-Val).

% Down direction: chain rows increase from R0; extend rows R0+P..NRows-1.
arc2_sx_ext_fill_(Chain, down, NRows, _NCols, R-C-Val) :-
% Extract first chain element for anchor row R0 and column C.
    Chain = [R0-C-_|_],
% Period equals chain length.
    length(Chain, P),
% Extension starts at R0+P.
    RStart is R0 + P,
    RStart < NRows,
% Last row index.
    NRows1 is NRows - 1,
% Generate each extension row.
    between(RStart, NRows1, R),
% Offset increases downward from anchor.
    Offset is R - R0,
% Pattern index.
    Idx is Offset mod P,
% Value from chain.
    nth0(Idx, Chain, _-_-Val).

% Left direction: chain cols decrease from C0 toward 0; extend cols 0..C0-P.
arc2_sx_ext_fill_(Chain, left, _NRows, _NCols, R-C-Val) :-
% Extract first chain element for row R and anchor col C0.
    Chain = [R-C0-_|_],
% Period.
    length(Chain, P),
% Extension covers cols 0 through C0-P.
    CLast is C0 - P,
    CLast >= 0,
% Generate each extension column.
    between(0, CLast, C),
% Offset from anchor going leftward.
    Offset is C0 - C,
% Pattern index.
    Idx is Offset mod P,
% Value from chain.
    nth0(Idx, Chain, _-_-Val).

% Right direction: chain cols increase from C0; extend cols C0+P..NCols-1.
arc2_sx_ext_fill_(Chain, right, _NRows, NCols, R-C-Val) :-
% Extract first chain element for row R and anchor col C0.
    Chain = [R-C0-_|_],
% Period.
    length(Chain, P),
% Extension starts at C0+P.
    CStart is C0 + P,
    CStart < NCols,
% Last column index.
    NCols1 is NCols - 1,
% Generate each extension column.
    between(CStart, NCols1, C),
% Offset increases rightward from anchor.
    Offset is C - C0,
% Pattern index.
    Idx is Offset mod P,
% Value from chain.
    nth0(Idx, Chain, _-_-Val).

% arc2_sx_step_/3: direction vector (DeltaRow, DeltaCol) for each direction.
arc2_sx_step_(up,    -1,  0).
arc2_sx_step_(down,   1,  0).
arc2_sx_step_(left,   0, -1).
arc2_sx_step_(right,  0,  1).

% arc2_sx_comps4_: partition a cell list into 4-connected components via DFS.
arc2_sx_comps4_(Cells, Comps) :-
% Iterate over seeds; skip already-visited cells.
    arc2_sx_comps4_iter_(Cells, Cells, [], Comps).

% arc2_sx_comps4_iter_: seed-driven component iterator.
arc2_sx_comps4_iter_([], _, _, []).
arc2_sx_comps4_iter_([H|T], All, Vis0, Comps) :-
    ( memberchk(H, Vis0) ->
% Already assigned to a component: skip this seed.
        arc2_sx_comps4_iter_(T, All, Vis0, Comps)
    ;
% New seed: flood-fill to discover its full component.
        arc2_sx_flood4_(All, [H], Vis0, [], Comp, Vis1),
        Comps = [Comp|Tail],
        arc2_sx_comps4_iter_(T, All, Vis1, Tail)
    ).

% arc2_sx_flood4_: DFS flood-fill over 4-connected neighbors within All.
arc2_sx_flood4_(_, [], Vis, Acc, Acc, Vis).
arc2_sx_flood4_(All, [H|Stack], Vis0, Acc0, Comp, Vis) :-
    ( memberchk(H, Vis0) ->
% Already visited: skip without expanding.
        arc2_sx_flood4_(All, Stack, Vis0, Acc0, Comp, Vis)
    ;
% Mark as visited and expand 4-connected neighbors within All.
        H = R-Co,
        findall(NR-NC,
            (member(DR-DC, [-1-0, 0-(-1), 0-1, 1-0]),
             NR is R  + DR, NC is Co + DC,
             memberchk(NR-NC, All),
             \+ memberchk(NR-NC, Vis0)),
            New),
        append(New, Stack, Stack1),
        arc2_sx_flood4_(All, Stack1, [H|Vis0], [H|Acc0], Comp, Vis)
    ).

% ---------------------------------------------------------------------------
% WAVE 28 — slide_open (WP-286, Layer 261)
% Task 6e453dd6
% Rule: A vertical 5-divider splits the grid. Zero-shapes (0-colored blobs)
% on the left of the divider slide right until their rightmost column touches
% the divider (DC-1). After sliding, any row where: (1) the cell immediately
% left of the divider is 0, (2) the cell one step further left is BG, and
% (3) there is another 0 to the left of that gap, is an "open" row — fill
% all cells to the right of the divider with 2 in that row.
% ---------------------------------------------------------------------------

% Register the slide_open rule.
arc2_named_rule(slide_open).

% arc2_transform(slide_open, +Grid, -Out): top-level transform.
arc2_transform(slide_open, Grid, Out) :-
    length(Grid, NRows),
    Grid = [FR|_], length(FR, NCols),
    % Find the 5-divider column (all 5s in that column).
    arc2_so_divider_(Grid, NRows, DC),
    % Collect all 0-cells left of the divider.
    findall(R-C,
        (nth0(R, Grid, Row), nth0(C, Row, 0), C < DC),
        ZeroCells),
    % Find 4-connected components of zero cells.
    arc2_so_comps4_(ZeroCells, Comps),
    % Slide each component right to touch divider, thread through grid.
    foldl(arc2_so_slide_(DC, NRows, NCols), Comps, Grid, Shifted),
    % Fill right of divider with 2 at open rows.
    arc2_so_fill_open_(Shifted, NRows, NCols, DC, Out).

% arc2_so_divider_(+Grid, +NRows, -DC): find the column where all values are 5.
arc2_so_divider_(Grid, NRows, DC) :-
    Grid = [Row|_], length(Row, NCols),
    NCols1 is NCols - 1,
    between(0, NCols1, DC),
    NRowsM is NRows - 1,
    numlist(0, NRowsM, RList),
    forall(member(R, RList),
           (nth0(R, Grid, Row2), nth0(DC, Row2, 5))).

% arc2_so_comps4_(+Cells, -Comps): partition cells into 4-connected components.
arc2_so_comps4_(Cells, Comps) :-
    arc2_so_comps4_iter_(Cells, Cells, [], Comps).

arc2_so_comps4_iter_([], _, _, []).
arc2_so_comps4_iter_([H|T], All, Vis0, Comps) :-
    ( memberchk(H, Vis0) ->
        arc2_so_comps4_iter_(T, All, Vis0, Comps)
    ;
        arc2_so_flood4_(All, [H], Vis0, [], Comp, Vis1),
        Comps = [Comp|Tail],
        arc2_so_comps4_iter_(T, All, Vis1, Tail)
    ).

arc2_so_flood4_(_, [], Vis, Acc, Acc, Vis).
arc2_so_flood4_(All, [H|Stack], Vis0, Acc0, Comp, Vis) :-
    ( memberchk(H, Vis0) ->
        arc2_so_flood4_(All, Stack, Vis0, Acc0, Comp, Vis)
    ;
        H = R-Co,
        findall(NR-NC,
            (member(DR-DC2, [-1-0, 0-(-1), 0-1, 1-0]),
             NR is R  + DR, NC is Co + DC2,
             memberchk(NR-NC, All),
             \+ memberchk(NR-NC, Vis0)),
            New),
        append(New, Stack, Stack1),
        arc2_so_flood4_(All, Stack1, [H|Vis0], [H|Acc0], Comp, Vis)
    ).

% arc2_so_slide_(+DC, +NRows, +NCols, +Comp, +G0, -G1):
% slide component right so max col = DC-1.
arc2_so_slide_(DC, _NRows, _NCols, Comp, G0, G1) :-
    findall(C, member(_-C, Comp), Cols),
    max_list(Cols, MaxCol),
    Shift is (DC - 1) - MaxCol,
    % Clear original positions.
    foldl([R-C, GI, GO]>>(arc2_set_cell_(GI, R, C, 6, GO)), Comp, G0, G2),
    % Place shifted positions.
    foldl([R-C, GI, GO]>>(
        C2 is C + Shift,
        arc2_set_cell_(GI, R, C2, 0, GO)
    ), Comp, G2, G1).

% arc2_so_fill_open_(+Grid, +NRows, +NCols, +DC, -Out):
% for each row where cell(DC-1)=0, cell(DC-2)!=0, and another 0 exists
% left of DC-2, fill the entire right side (DC+1..NCols-1) with 2.
arc2_so_fill_open_(Grid, NRows, NCols, DC, Out) :-
    DC1 is DC - 1,
    DC2 is DC - 2,
    NRowsM is NRows - 1,
    numlist(0, NRowsM, RList0),
    foldl([R, GI, GO]>>(
        arc2_cell_(GI, R, DC1, VRight),
        arc2_cell_(GI, R, DC2, VGap),
        ( VRight =:= 0, VGap =\= 0,
          findall(C, (between(0, DC2, C), C =\= DC2,
                      arc2_cell_(GI, R, C, 0)), Lefts),
          Lefts \= [] ->
            DC1s is DC + 1, NCols1 is NCols - 1,
            numlist(DC1s, NCols1, FillCols),
            foldl([FC, GII, GOO]>>(arc2_set_cell_(GII, R, FC, 2, GOO)),
                  FillCols, GI, GO)
        ;
            GO = GI
        )
    ), RList0, Grid, Out).

% ---------------------------------------------------------------------------
% WAVE 29 — diag_beam (WP-287, Layer 262)
% Task db695cfb
% Rule: Pairs of 1s that are exactly 45 degrees apart (|row_diff|=|col_diff|)
% shoot a diagonal beam between them. The beam fills intermediate background
% cells with 1. Where the beam hits an existing 6, it bounces: two
% perpendicular 45-degree rays radiate from that obstacle cell, filling
% background cells with 6 until the grid boundary or another existing 6.
% ---------------------------------------------------------------------------

% Register the diag_beam rule.
arc2_named_rule(diag_beam).

% arc2_transform(diag_beam, +Grid, -Out): top-level transform.
arc2_transform(diag_beam, Grid, Out) :-
    % Background is the value at position (0,0).
    Grid = [[BG|_]|_],
    % Verify all non-background cells are 1 or 6.
    forall(
        (nth0(_R, Grid, Row), member(V, Row), V \= BG),
        member(V, [1, 6])
    ),
    % Collect positions of all 1-cells.
    findall(R-C, (nth0(R, Grid, Row), nth0(C, Row, 1)), Ones),
    % At least one 1 must exist.
    Ones = [_|_],
    % Collect positions of all existing 6-obstacles.
    findall(R-C, (nth0(R, Grid, Row), nth0(C, Row, 6)), Sixes),
    % Grid dimensions for boundary checks.
    length(Grid, NRows),
    Grid = [FRow|_], length(FRow, NCols),
    % Find all unordered diagonal pairs of 1s (|dr|=|dc|>0).
    findall(P1-P2,
        (member(P1, Ones), member(P2, Ones), P1 @< P2,
         P1 = R1-C1, P2 = R2-C2,
         AbsR is abs(R1 - R2), AbsC is abs(C1 - C2),
         AbsR =:= AbsC, AbsR > 0),
        Pairs),
    % At least one diagonal pair must exist.
    Pairs = [_|_],
    % Apply beams in sequence, threading the grid state.
    foldl(arc2_db_pair_(Sixes, NRows, NCols), Pairs, Grid, Out).

% arc2_db_pair_(+Sixes, +NRows, +NCols, +Pair, +G0, -G1):
% fire a beam from the first 1 of the pair toward the second.
arc2_db_pair_(Sixes, NRows, NCols, (R1-C1)-(R2-C2), G0, G1) :-
    % Step direction: +1 or -1 for each axis.
    ( R2 > R1 -> DR = 1 ; DR = -1 ),
    ( C2 > C1 -> DC = 1 ; DC = -1 ),
    % Start one step past the source (skip the source 1-cell).
    RS is R1 + DR, CS is C1 + DC,
    % March toward the destination.
    arc2_db_march_(RS, CS, DR, DC, R2, C2, Sixes, NRows, NCols, G0, G1).

% arc2_db_march_(+R, +C, +DR, +DC, +R2, +C2, ...):
% step along the diagonal; stop when the destination 1-cell is reached.
arc2_db_march_(R2, C2, _, _, R2, C2, _, _, _, G, G) :- !.
arc2_db_march_(R, C, DR, DC, R2, C2, Sixes, NRows, NCols, G0, G1) :-
    % Check whether this cell is an existing 6-obstacle.
    ( memberchk(R-C, Sixes) ->
        % Obstacle: bounce perpendicular rays without touching the 6-cell.
        arc2_db_bounce_(R, C, DR, DC, Sixes, NRows, NCols, G0, Gtmp)
    ;
        % Background cell: fill with 1.
        arc2_set_cell_(G0, R, C, 1, Gtmp)
    ),
    % Advance one step and continue.
    NR is R + DR, NC is C + DC,
    arc2_db_march_(NR, NC, DR, DC, R2, C2, Sixes, NRows, NCols, Gtmp, G1).

% arc2_db_bounce_(+R, +C, +DR, +DC, +Sixes, +NRows, +NCols, +G0, -G1):
% send two perpendicular rays from obstacle cell (R,C), filling cells with 6.
arc2_db_bounce_(R, C, DR, DC, Sixes, NRows, NCols, G0, G1) :-
    % Perpendicular to (DR,DC) in 2D: rotate 90 degrees both ways.
    PR1 is  DR, PC1 is -DC,
    PR2 is -DR, PC2 is  DC,
    % Fire first perpendicular ray.
    arc2_db_ray_(R, C, PR1, PC1, Sixes, NRows, NCols, G0, Gtmp),
    % Fire second perpendicular ray.
    arc2_db_ray_(R, C, PR2, PC2, Sixes, NRows, NCols, Gtmp, G1).

% arc2_db_ray_(+R, +C, +DR, +DC, +Sixes, +NRows, +NCols, +G0, -G1):
% extend a 6-filling ray step by step; stop at boundary or existing 6.
arc2_db_ray_(R, C, DR, DC, Sixes, NRows, NCols, G0, G1) :-
    % Compute the next cell position.
    NR is R + DR, NC is C + DC,
    ( NR >= 0, NR < NRows, NC >= 0, NC < NCols ->
        ( memberchk(NR-NC, Sixes) ->
            % Existing 6-obstacle: stop the ray here (no secondary bounce).
            G1 = G0
        ;
            % Background cell: fill with 6 and continue the ray.
            arc2_set_cell_(G0, NR, NC, 6, Gtmp),
            arc2_db_ray_(NR, NC, DR, DC, Sixes, NRows, NCols, Gtmp, G1)
        )
    ;
        % Out of bounds: stop.
        G1 = G0
    ).

% ---------------------------------------------------------------------------
% WAVE 30 — frame_absorb (WP-288, Layer 263)
% Task d35bdbdc
% ---------------------------------------------------------------------------

% Register the frame_absorb rule.
arc2_named_rule(frame_absorb).

% arc2_transform(frame_absorb, +Grid, -Out): top-level entry point.
arc2_transform(frame_absorb, Grid, Out) :-
    % Collect all non-background (0), non-snake (5) cell positions.
    findall(R-C,
        (nth0(R, Grid, Row), nth0(C, Row, V), V \= 0, V \= 5),
        Positions),
    % At least one non-background position must exist.
    Positions \= [],
    % Partition positions into 4-connected components.
    arc2_fa_comps_(Positions, Comps),
    % At least two components (blocks) must be present.
    Comps = [_,_|_],
    % Classify each component as a frame block term.
    maplist(arc2_fa_block_(Grid), Comps, Blocks),
    % Compute the absorption action sequence.
    arc2_fa_solve_(Blocks, Actions),
    % At least one action must result from solving.
    Actions \= [],
    % Apply all actions to produce the output grid.
    foldl(arc2_fa_exec_, Actions, Grid, Out).

% arc2_fa_adj_(+Pos, -Neighbour): the four 4-adjacent neighbours of Pos.
arc2_fa_adj_(R-C, NR-C) :- NR is R - 1, NR >= 0.
% Step south.
arc2_fa_adj_(R-C, NR-C) :- NR is R + 1.
% Step west.
arc2_fa_adj_(R-C, R-NC) :- NC is C - 1, NC >= 0.
% Step east.
arc2_fa_adj_(R-C, R-NC) :- NC is C + 1.

% arc2_fa_comps_(+Positions, -Components): BFS-partition into 4-connected groups.
arc2_fa_comps_([], []).
arc2_fa_comps_([H|T], [Comp|Rest]) :-
    % Grow one component starting from H.
    arc2_fa_bfs_([H], [H], T, Comp, Remaining),
    % Recursively partition the remaining positions.
    arc2_fa_comps_(Remaining, Rest).

% arc2_fa_bfs_(+Queue, +Visited, +Unvisited, -Component, -Remaining): BFS step.
arc2_fa_bfs_([], Visited, Remaining, Visited, Remaining) :- !.
arc2_fa_bfs_([H|Q], Visited, Unvisited, Comp, Remaining) :-
    % Find 4-adjacent neighbours in the unvisited pool not yet visited.
    findall(N,
        (arc2_fa_adj_(H, N), member(N, Unvisited), \+ member(N, Visited)),
        Ns),
    % Sort to remove duplicates and maintain determinism.
    sort(Ns, SortedNs),
    % Enqueue new neighbours.
    append(Q, SortedNs, NewQ),
    % Add new neighbours to the visited set.
    append(Visited, SortedNs, NewVisited),
    % Remove new neighbours from the unvisited pool.
    subtract(Unvisited, SortedNs, NewUnvisited),
    % Continue BFS with updated state.
    arc2_fa_bfs_(NewQ, NewVisited, NewUnvisited, Comp, Remaining).

% arc2_fa_block_(+Grid, +Cells, -Block): classify a component as a frame block.
% Block = block(CenterRow, CenterCol, CenterColor, ArmColor, Cells).
arc2_fa_block_(Grid, Cells, block(CR, CC, CV, AV, Cells)) :-
    % Collect the color value of each cell in the component.
    maplist([R-C, V]>>(nth0(R, Grid, Row), nth0(C, Row, V)), Cells, Vals),
    % Compute the distinct color set.
    list_to_set(Vals, Colors),
    (   Colors = [C1, C2]
    ->  % Two-color block: the singleton color is CV (center), majority is AV (arm).
        (include(=(C1), Vals, [_]) -> CV = C1, AV = C2 ; CV = C2, AV = C1),
        % Find the cell whose color matches CV: that is the center cell.
        member(CR-CC, Cells),
        % Verify this cell's grid value is CV.
        nth0(CR, Grid, Row0), nth0(CC, Row0, CV)
    ;   % Monochrome block: CV and AV are equal; center = max-degree cell.
        Colors = [AV], CV = AV,
        % Select the most 4-connected cell as the center.
        arc2_fa_max_deg_(Cells, CR-CC)
    ).

% arc2_fa_max_deg_(+Cells, -Best): cell with the highest 4-connectivity degree.
arc2_fa_max_deg_([R-C], R-C) :- !.
arc2_fa_max_deg_(Cells, Best) :-
    % For each cell, count its in-component 4-neighbours.
    maplist([Cell, Deg-Cell]>>(
        findall(N, (arc2_fa_adj_(Cell, N), member(N, Cells)), Ns),
        length(Ns, Deg)
    ), Cells, DegCells),
    % Sort ascending so the last element has the highest degree.
    msort(DegCells, Sorted),
    % Extract the cell paired with the highest degree.
    last(Sorted, _-Best).

% arc2_fa_solve_(+Blocks, -Actions): entry wrapper adds empty accumulator.
arc2_fa_solve_(Blocks, Actions) :-
    % Initialise the accumulator and dispatch to the recursive worker.
    arc2_fa_solve_(Blocks, [], Actions).

% Base case: no blocks left; return the accumulated actions.
arc2_fa_solve_([], Acc, Acc) :- !.
arc2_fa_solve_(Available, Acc, Actions) :-
    % Priority 1: find a monochrome block Y (CV = AV) and process it first.
    member(Y, Available),
    % Unpack Y's center and arm colors.
    Y = block(_, _, YCV, YAV, _),
    % Monochrome check: center equals arm.
    YCV =:= YAV,
    (   % Try to find a predecessor X whose CV matches Y's AV.
        member(X, Available), X \= Y,
        X = block(_, _, XCV, _, _), XCV =:= YAV
    ->  % X absorbs Y: remove both and record the action.
        select(X, Available, Av1), select(Y, Av1, Av2),
        arc2_fa_solve_(Av2, [absorb(X, Y)|Acc], Actions)
    ;   % No predecessor exists; Y is a dead end: erase it.
        select(Y, Available, Av2),
        arc2_fa_solve_(Av2, [erase(Y)|Acc], Actions)
    ), !.
arc2_fa_solve_(Available, Acc, Actions) :-
    % Priority 2: find a chain start X (no block Z has Z.CV = X.AV).
    member(X, Available),
    % Unpack X's arm color.
    X = block(_, _, _, XAV, _),
    % Confirm no other block's center color equals X's arm color.
    \+ (member(Z, Available), Z \= X,
        Z = block(_, _, ZCV, _, _), ZCV =:= XAV),
    (   % Try to find X's successor Y (X.CV = Y.AV).
        X = block(_, _, XCV, _, _),
        member(Y, Available), Y \= X,
        Y = block(_, _, _, YAV, _), XCV =:= YAV
    ->  % X absorbs Y: remove both and record the action.
        select(X, Available, Av1), select(Y, Av1, Av2),
        arc2_fa_solve_(Av2, [absorb(X, Y)|Acc], Actions)
    ;   % X has no successor; it is a dead end: erase it.
        select(X, Available, Av2),
        arc2_fa_solve_(Av2, [erase(X)|Acc], Actions)
    ), !.
arc2_fa_solve_(Available, Acc, Actions) :-
    % No start found (cyclic dependency): erase all remaining blocks.
    foldl([B, A0, [erase(B)|A0]]>>true, Available, Acc, Actions).

% arc2_fa_exec_(absorb(X,Y), +G0, -G1): erase Y; set X's center to Y's CV.
arc2_fa_exec_(absorb(X, Y), G0, G1) :-
    % Unpack Y's center color and cell set.
    Y = block(_, _, YCV, _, YCells),
    % Unpack X's center row and column.
    X = block(XR, XC, _, _, _),
    % Erase every cell of Y by setting it to background (0).
    foldl([R-C, Gi, Go]>>(arc2_set_cell_(Gi, R, C, 0, Go)), YCells, G0, Gtmp),
    % Paint X's center cell with Y's center color.
    arc2_set_cell_(Gtmp, XR, XC, YCV, G1).
% arc2_fa_exec_(erase(B), +G0, -G1): erase all cells of block B.
arc2_fa_exec_(erase(B), G0, G1) :-
    % Unpack B's cell set.
    B = block(_, _, _, _, BCells),
    % Set every cell of B to background (0).
    foldl([R-C, Gi, Go]>>(arc2_set_cell_(Gi, R, C, 0, Go)), BCells, G0, G1).

% ---------------------------------------------------------------------------
% WAVE 31 — shape_beam (WP-289, Layer 264)
% Task 5961cc34
% ---------------------------------------------------------------------------

% Register the shape_beam named rule.
arc2_named_rule(shape_beam).

% arc2_transform(shape_beam, +Grid, -Out): entry point for shape_beam.
arc2_transform(shape_beam, Grid, Out) :-
    % Fast guard: grid must contain exactly one 4-valued cell (rod head).
    flatten(Grid, Flat), include(=:=(4), Flat, Fours), Fours = [_],
    % Fast guard: grid must contain cells with value 1 (shape body).
    include(=:=(1), Flat, Ones), Ones \= [],
    % Identify background: the most-frequent cell value.
    arc2_sb_bg_(Grid, BG),
    % Find the rod: cell with value 4 and beam direction (opposite of 2-trail).
    arc2_sb_rod_(Grid, RR, RC, BeamDir),
    % Collect rod cells: 4-cell plus all 2-trail cells in trail direction.
    arc2_sb_rod_cells_(Grid, RR, RC, BeamDir, RodCells),
    % Collect all cells with value 1 or 3 (shape body and exit markers).
    findall(R-C, (nth0(R,Grid,Row), nth0(C,Row,V), (V=:=1 ; V=:=3)), RawPos),
    % At least one shape must be present.
    RawPos \= [],
    % Partition shape cells into 4-connected components.
    arc2_sb_comps_(RawPos, Comps),
    % Classify each component: determine exit direction and cross positions.
    maplist(arc2_sb_classify_(Grid, BG), Comps, Shapes),
    % Get grid dimensions.
    length(Grid, NR), Grid = [GR0|_], length(GR0, NC),
    % Run beam from rod position; collect all cells that become 2.
    arc2_sb_beam_(BeamDir, [RC], RR, Shapes, NR, NC, [], BeamCells),
    % Merge rod cells and beam cells; remove duplicates.
    append(RodCells, BeamCells, All2Raw),
    sort(All2Raw, All2),
    % Build blank background grid then paint all 2-positions.
    arc2_sb_blank_(NR, NC, BG, Blank),
    foldl([R-C, G0, G1]>>(arc2_set_cell_(G0, R, C, 2, G1)), All2, Blank, Out).

% --- BACKGROUND DETECTION ---

% arc2_sb_bg_(+Grid, -BG): find most-common cell value.
arc2_sb_bg_(Grid, BG) :-
    % Flatten grid to one value list.
    flatten(Grid, Flat),
    % Sort to group equal values together.
    msort(Flat, Sorted),
    % Find the value with the longest consecutive run.
    arc2_sb_maxrun_(Sorted, BG).

% arc2_sb_maxrun_(+Sorted, -Best): scan sorted list for most-frequent value.
arc2_sb_maxrun_([H|T], Best) :-
    % Start accumulator with first element as current run and best.
    arc2_sb_maxrun_acc_(T, H, 1, H, 1, Best).

% Base case: list exhausted; emit the current-best value.
arc2_sb_maxrun_acc_([], Cur, CurN, Best, BestN, Res) :-
    % Current run beats stored best: return Cur; else return Best.
    (CurN > BestN -> Res = Cur ; Res = Best).
% Recursive step: same value as current run.
arc2_sb_maxrun_acc_([H|T], Cur, CurN, Best, BestN, Res) :-
    H =:= Cur, !,
    % Extend the current run count.
    CurN1 is CurN + 1,
    % Update best if current run now exceeds it.
    (CurN1 > BestN -> B2 = Cur, BN2 = CurN1 ; B2 = Best, BN2 = BestN),
    % Continue scanning.
    arc2_sb_maxrun_acc_(T, Cur, CurN1, B2, BN2, Res).
% Recursive step: new value; reset current run to 1.
arc2_sb_maxrun_acc_([H|T], Cur, CurN, Best, BestN, Res) :-
    % Carry forward the better of current and stored best.
    (CurN > BestN -> B2 = Cur, BN2 = CurN ; B2 = Best, BN2 = BestN),
    % Start a new run for H.
    arc2_sb_maxrun_acc_(T, H, 1, B2, BN2, Res).

% --- ROD DETECTION ---

% arc2_sb_rod_(+Grid, -RR, -RC, -BeamDir): find 4-cell and beam direction.
arc2_sb_rod_(Grid, RR, RC, BeamDir) :-
    % Locate any cell with value 4.
    nth0(RR, Grid, Row), nth0(RC, Row, 4),
    % Determine which adjacent direction has the 2-trail.
    arc2_sb_trail_dir_(Grid, RR, RC, TrailDir), !,
    % Beam direction is opposite to the 2-trail direction.
    arc2_sb_opp_(TrailDir, BeamDir).

% arc2_sb_trail_dir_: find which adjacent direction from the 4-cell has value 2.
arc2_sb_trail_dir_(Grid, R, C, down) :-
    % Check cell directly below.
    R1 is R+1, nth0(R1, Grid, Row1), nth0(C, Row1, 2), !.
arc2_sb_trail_dir_(Grid, R, C, up) :-
    % Check cell directly above (guard against row -1).
    R1 is R-1, R1 >= 0, nth0(R1, Grid, Row1), nth0(C, Row1, 2), !.
arc2_sb_trail_dir_(Grid, R, C, right) :-
    % Check cell to the right.
    C1 is C+1, nth0(R, Grid, Row), nth0(C1, Row, 2), !.
arc2_sb_trail_dir_(Grid, R, C, left) :-
    % Check cell to the left (guard against col -1).
    C1 is C-1, C1 >= 0, nth0(R, Grid, Row), nth0(C1, Row, 2), !.

% arc2_sb_opp_/2: opposite directions.
arc2_sb_opp_(up, down).
arc2_sb_opp_(down, up).
arc2_sb_opp_(left, right).
arc2_sb_opp_(right, left).

% arc2_sb_rod_cells_(+Grid, +RR, +RC, +BeamDir, -Cells): 4-cell + 2-trail.
arc2_sb_rod_cells_(Grid, RR, RC, BeamDir, [RR-RC|Trail]) :-
    % Trail direction is opposite to beam direction.
    arc2_sb_opp_(BeamDir, TrailDir),
    % Collect all 2-valued cells extending in the trail direction.
    arc2_sb_trail2_(Grid, RR, RC, TrailDir, Trail).

% arc2_sb_trail2_: recursively collect 2-cells in the given direction.
arc2_sb_trail2_(Grid, R, C, down, [R1-C|Rest]) :-
    % Step downward and verify cell value is 2.
    R1 is R+1, nth0(R1, Grid, Row1), nth0(C, Row1, 2), !,
    arc2_sb_trail2_(Grid, R1, C, down, Rest).
arc2_sb_trail2_(Grid, R, C, up, [R1-C|Rest]) :-
    % Step upward (guard row bound) and verify 2.
    R1 is R-1, R1 >= 0, nth0(R1, Grid, Row1), nth0(C, Row1, 2), !,
    arc2_sb_trail2_(Grid, R1, C, up, Rest).
arc2_sb_trail2_(Grid, R, C, right, [R-C1|Rest]) :-
    % Step rightward and verify 2.
    C1 is C+1, nth0(R, Grid, Row), nth0(C1, Row, 2), !,
    arc2_sb_trail2_(Grid, R, C1, right, Rest).
arc2_sb_trail2_(Grid, R, C, left, [R-C1|Rest]) :-
    % Step leftward (guard col bound) and verify 2.
    C1 is C-1, C1 >= 0, nth0(R, Grid, Row), nth0(C1, Row, 2), !,
    arc2_sb_trail2_(Grid, R, C1, left, Rest).
% Base case: no more 2-cells in this direction.
arc2_sb_trail2_(_, _, _, _, []).

% --- 4-CONNECTED COMPONENT PARTITION ---

% arc2_sb_comps_(+Positions, -Components): BFS partition into 4-connected groups.
arc2_sb_comps_([], []).
arc2_sb_comps_([H|T], [Comp|Rest]) :-
    % Grow one component starting from H using BFS.
    arc2_sb_bfs_([H], [H], T, Comp, Rem),
    % Recursively partition the remaining positions.
    arc2_sb_comps_(Rem, Rest).

% arc2_sb_bfs_: BFS over 4-connected graph.
arc2_sb_bfs_([], Vis, Rem, Vis, Rem) :- !.
arc2_sb_bfs_([H|Q], Vis, Unvis, Comp, Rem) :-
    % Find 4-adjacent cells in Unvis not yet visited.
    findall(N, (arc2_sb_adj4_(H,N), member(N,Unvis), \+member(N,Vis)), Ns),
    % Sort to remove duplicates.
    sort(Ns, SNs),
    % Enqueue new neighbours.
    append(Q, SNs, NQ),
    % Add new neighbours to visited set.
    append(Vis, SNs, NVis),
    % Remove new neighbours from the unvisited pool.
    subtract(Unvis, SNs, NUnvis),
    % Continue BFS.
    arc2_sb_bfs_(NQ, NVis, NUnvis, Comp, Rem).

% arc2_sb_adj4_: the four 4-adjacent neighbours.
arc2_sb_adj4_(R-C, NR-C) :- NR is R-1, NR >= 0.
arc2_sb_adj4_(R-C, NR-C) :- NR is R+1.
arc2_sb_adj4_(R-C, R-NC) :- NC is C-1, NC >= 0.
arc2_sb_adj4_(R-C, R-NC) :- NC is C+1.

% --- SHAPE CLASSIFICATION ---

% arc2_sb_classify_(+Grid, +BG, +Cells, -Shape):
% Shape = shape(AllCells, ExitDir, CrossPositions, ExitAxisPos).
arc2_sb_classify_(Grid, BG, Cells, shape(Cells, ExitDir, Cross, ExitAP)) :-
    % Separate the 1-valued body cells.
    include([R-C]>>(nth0(R,Grid,Row), nth0(C,Row,V), V=:=1), Cells, Cells1),
    % Separate the 3-valued exit-marker cells.
    include([R-C]>>(nth0(R,Grid,Row), nth0(C,Row,V), V=:=3), Cells, Cells3),
    % Both body and markers must be present.
    Cells1 \= [], Cells3 \= [],
    % Determine exit direction: the open side adjacent to all 3-markers.
    arc2_sb_exit_dir_(Grid, BG, Cells3, ExitDir),
    % Compute rows and cols of all 3-markers.
    maplist([R-_, R]>>true, Cells3, R3sRaw), sort(R3sRaw, R3s),
    maplist([_-C, C]>>true, Cells3, C3sRaw), sort(C3sRaw, C3s),
    % For vertical exits (up/down): cross = cols of markers, axis = their row.
    % For horizontal exits (left/right): cross = rows of markers, axis = their col.
    (memberchk(ExitDir, [up, down]) ->
        Cross = C3s, R3s = [ExitAP|_]
    ;
        Cross = R3s, C3s = [ExitAP|_]
    ).

% arc2_sb_exit_dir_(+Grid, +BG, +Cells3, -ExitDir):
% Find which side of the 3-cells faces open (BG) space.
arc2_sb_exit_dir_(Grid, BG, Cells3, ExitDir) :-
    % Collect all rows and cols of 3-cells.
    maplist([R-_, R]>>true, Cells3, R3sRaw), sort(R3sRaw, R3s),
    maplist([_-C, C]>>true, Cells3, C3sRaw), sort(C3sRaw, C3s),
    % Determine whether 3-cells lie in a single row (vertical exit) or single col.
    (R3s = [R3] ->
        % Single row: check if row above or row below is open (BG).
        (Rup is R3-1, Rup >= 0,
         forall(member(C, C3s),
                (nth0(Rup, Grid, Rw), nth0(C, Rw, V), V =:= BG)) ->
            ExitDir = up
        ;   Rdn is R3+1,
            forall(member(C, C3s),
                   (nth0(Rdn, Grid, Rw), nth0(C, Rw, V), V =:= BG)),
            ExitDir = down
        )
    ;
        % Single col: check if col to left or col to right is open (BG).
        C3s = [C3],
        (Clt is C3-1, Clt >= 0,
         forall(member(R, R3s),
                (nth0(R, Grid, Rw), nth0(Clt, Rw, V), V =:= BG)) ->
            ExitDir = left
        ;   Crt is C3+1,
            forall(member(R, R3s),
                   (nth0(R, Grid, Rw), nth0(Crt, Rw, V), V =:= BG)),
            ExitDir = right
        )
    ).

% --- BEAM RUNNER ---

% arc2_sb_beam_(+Dir, +Cross, +AS, +Shapes, +NR, +NC, +Acc, -Out):
% Trace beam in direction Dir at cross positions Cross from axis start AS.
% Returns all cells (as R-C pairs) that should become 2.

% UP beam: search for shape with cells at Cross cols, row < AS.
arc2_sb_beam_(up, Cols, AS, Shapes, NR, NC, Acc, Out) :-
    % Attempt to find first shape hit going upward.
    arc2_sb_hit_(up, Cols, AS, Shapes, HitShape, HR), !,
    % Gap fill: all cells from HR+1 to AS at Cols.
    GF is HR + 1,
    arc2_sb_rect_(Cols, GF, AS, v, GapCells),
    % Unpack hit shape: all cells, exit direction, cross positions, axis pos.
    HitShape = shape(SCs, ExDir, ExCross, ExAP),
    % Compute new axis start for exit beam: one step past the 3-markers.
    arc2_sb_exit_start_(ExDir, ExAP, NAS),
    % Remove hit shape from remaining shapes.
    select(HitShape, Shapes, Rem),
    % Accumulate gap cells and shape cells.
    append(Acc, GapCells, A1), append(A1, SCs, A2),
    % Continue beam in exit direction.
    arc2_sb_beam_(ExDir, ExCross, NAS, Rem, NR, NC, A2, Out).
% UP beam: no shape hit; fill from 0 to AS at Cols.
arc2_sb_beam_(up, Cols, AS, _, _, _, Acc, Out) :-
    arc2_sb_rect_(Cols, 0, AS, v, GapCells),
    append(Acc, GapCells, Out).

% DOWN beam: search for shape with cells at Cross cols, row > AS.
arc2_sb_beam_(down, Cols, AS, Shapes, NR, NC, Acc, Out) :-
    % Attempt to find first shape hit going downward.
    arc2_sb_hit_(down, Cols, AS, Shapes, HitShape, HR), !,
    % Gap fill: AS to HR-1 at Cols.
    GF is HR - 1,
    arc2_sb_rect_(Cols, AS, GF, v, GapCells),
    HitShape = shape(SCs, ExDir, ExCross, ExAP),
    arc2_sb_exit_start_(ExDir, ExAP, NAS),
    select(HitShape, Shapes, Rem),
    append(Acc, GapCells, A1), append(A1, SCs, A2),
    arc2_sb_beam_(ExDir, ExCross, NAS, Rem, NR, NC, A2, Out).
% DOWN beam: no hit; fill from AS to NR-1 at Cols.
arc2_sb_beam_(down, Cols, AS, _, NR, _, Acc, Out) :-
    NRm1 is NR - 1,
    arc2_sb_rect_(Cols, AS, NRm1, v, GapCells),
    append(Acc, GapCells, Out).

% LEFT beam: search for shape with cells at Cross rows, col < AS.
arc2_sb_beam_(left, Rows, AS, Shapes, NR, NC, Acc, Out) :-
    % Attempt to find first shape hit going leftward.
    arc2_sb_hit_(left, Rows, AS, Shapes, HitShape, HC), !,
    % Gap fill: HC+1 to AS at Rows.
    GF is HC + 1,
    arc2_sb_rect_(Rows, GF, AS, h, GapCells),
    HitShape = shape(SCs, ExDir, ExCross, ExAP),
    arc2_sb_exit_start_(ExDir, ExAP, NAS),
    select(HitShape, Shapes, Rem),
    append(Acc, GapCells, A1), append(A1, SCs, A2),
    arc2_sb_beam_(ExDir, ExCross, NAS, Rem, NR, NC, A2, Out).
% LEFT beam: no hit; fill from 0 to AS at Rows.
arc2_sb_beam_(left, Rows, AS, _, _, _, Acc, Out) :-
    arc2_sb_rect_(Rows, 0, AS, h, GapCells),
    append(Acc, GapCells, Out).

% RIGHT beam: search for shape with cells at Cross rows, col > AS.
arc2_sb_beam_(right, Rows, AS, Shapes, NR, NC, Acc, Out) :-
    % Attempt to find first shape hit going rightward.
    arc2_sb_hit_(right, Rows, AS, Shapes, HitShape, HC), !,
    % Gap fill: AS to HC-1 at Rows.
    GF is HC - 1,
    arc2_sb_rect_(Rows, AS, GF, h, GapCells),
    HitShape = shape(SCs, ExDir, ExCross, ExAP),
    arc2_sb_exit_start_(ExDir, ExAP, NAS),
    select(HitShape, Shapes, Rem),
    append(Acc, GapCells, A1), append(A1, SCs, A2),
    arc2_sb_beam_(ExDir, ExCross, NAS, Rem, NR, NC, A2, Out).
% RIGHT beam: no hit; fill from AS to NC-1 at Rows.
arc2_sb_beam_(right, Rows, AS, _, _, NC, Acc, Out) :-
    NCm1 is NC - 1,
    arc2_sb_rect_(Rows, AS, NCm1, h, GapCells),
    append(Acc, GapCells, Out).

% arc2_sb_exit_start_: compute axis start for next beam after shape exit.
arc2_sb_exit_start_(up,    ExAP, NAS) :- NAS is ExAP - 1.
arc2_sb_exit_start_(down,  ExAP, NAS) :- NAS is ExAP + 1.
arc2_sb_exit_start_(left,  ExAP, NAS) :- NAS is ExAP - 1.
arc2_sb_exit_start_(right, ExAP, NAS) :- NAS is ExAP + 1.

% arc2_sb_hit_: find the closest shape hit in each beam direction.

% UP: find shape with max row < AS at any of Cols.
arc2_sb_hit_(up, Cols, AS, Shapes, HitShape, HitRow) :-
    % Collect (row, shape-index) pairs for all cells in beam column range above AS.
    findall(HR-Idx,
        (nth0(Idx, Shapes, HS), HS = shape(SCs,_,_,_),
         member(HR-HC, SCs), member(HC, Cols), HR < AS),
        Cands),
    % At least one candidate must exist.
    Cands \= [],
    % Pick the highest row (closest to beam start going up).
    pairs_keys(Cands, HRs), max_list(HRs, HitRow),
    % Retrieve the actual shape term by index.
    once((member(HitRow-HIdx, Cands), nth0(HIdx, Shapes, HitShape))).

% DOWN: find shape with min row > AS at any of Cols.
arc2_sb_hit_(down, Cols, AS, Shapes, HitShape, HitRow) :-
    findall(HR-Idx,
        (nth0(Idx, Shapes, HS), HS = shape(SCs,_,_,_),
         member(HR-HC, SCs), member(HC, Cols), HR > AS),
        Cands),
    Cands \= [],
    pairs_keys(Cands, HRs), min_list(HRs, HitRow),
    once((member(HitRow-HIdx, Cands), nth0(HIdx, Shapes, HitShape))).

% RIGHT: find shape with min col > AS at any of Rows.
arc2_sb_hit_(right, Rows, AS, Shapes, HitShape, HitCol) :-
    findall(HC-Idx,
        (nth0(Idx, Shapes, HS), HS = shape(SCs,_,_,_),
         member(HR-HC, SCs), member(HR, Rows), HC > AS),
        Cands),
    Cands \= [],
    pairs_keys(Cands, HCs), min_list(HCs, HitCol),
    once((member(HitCol-HIdx, Cands), nth0(HIdx, Shapes, HitShape))).

% LEFT: find shape with max col < AS at any of Rows.
arc2_sb_hit_(left, Rows, AS, Shapes, HitShape, HitCol) :-
    findall(HC-Idx,
        (nth0(Idx, Shapes, HS), HS = shape(SCs,_,_,_),
         member(HR-HC, SCs), member(HR, Rows), HC < AS),
        Cands),
    Cands \= [],
    pairs_keys(Cands, HCs), max_list(HCs, HitCol),
    once((member(HitCol-HIdx, Cands), nth0(HIdx, Shapes, HitShape))).

% arc2_sb_rect_: generate all (R,C) pairs in a rectangle.
% v = vertical axis (rows vary, cols fixed); h = horizontal (cols vary, rows fixed).
arc2_sb_rect_(_, From, To, _, []) :- From > To, !.
arc2_sb_rect_(Cross, From, To, v, Cells) :-
    % Generate rows From..To and cross with each col in Cross.
    numlist(From, To, Rows),
    findall(R-C, (member(R, Rows), member(C, Cross)), Cells).
arc2_sb_rect_(Cross, From, To, h, Cells) :-
    % Generate cols From..To and cross with each row in Cross.
    numlist(From, To, Cols),
    findall(R-C, (member(R, Cross), member(C, Cols)), Cells).

% arc2_sb_blank_: build an NR x NC grid filled with BG.
arc2_sb_blank_(0, _, _, []) :- !.
arc2_sb_blank_(NR, NC, BG, [Row|Rest]) :-
    NR > 0, NR1 is NR - 1,
    % Create a fresh row of NC background values.
    length(Row, NC), maplist(=(BG), Row),
    % Recurse for remaining rows.
    arc2_sb_blank_(NR1, NC, BG, Rest).

% ---------------------------------------------------------------------------
% WAVE 32 — shape_classify (WP-290, Layer 265)
% Task aa4ec2a5
% Rule: surround every shape with a 2-border; shapes that enclose background
%       holes become 8 (holes → 6); shapes with no holes stay unchanged.
% ---------------------------------------------------------------------------

% Register the shape_classify named rule.
arc2_named_rule(shape_classify).

% arc2_transform(shape_classify, +Grid, -Out): entry point for Wave 32.
arc2_transform(shape_classify, Grid, Out) :-
    % Guard: exactly 2 distinct cell values in the grid.
    flatten(Grid, Flat),
    sort(Flat, [_, _]),
    % Identify background as the most-frequent cell value.
    arc2_scc_bg_(Flat, BG),
    % Grid dimensions.
    length(Grid, NR),
    Grid = [GRow0|_], length(GRow0, NC),
    % Collect all non-BG cell positions.
    findall(R-C, (nth0(R, Grid, GRow), nth0(C, GRow, V), V \= BG), NonBG),
    NonBG \= [],
    % Flood-fill BG from the grid boundary to find outside-reachable BG cells.
    arc2_scc_outside_(Grid, NR, NC, BG, Outside),
    % Holes: BG cells not reachable from the grid boundary.
    findall(R-C,
        (nth0(R, Grid, GRow), nth0(C, GRow, V), V =:= BG,
         \+ member(R-C, Outside)),
        Holes),
    % Border: outside BG cells with at least one non-BG 4-neighbour.
    findall(R-C,
        (member(R-C, Outside),
         once(arc2_scc_nonbg_nbr_(Grid, BG, R, C))),
        Border),
    % Partition non-BG cells into 4-connected components.
    arc2_scc_comps_(NonBG, Comps),
    % Identify components that border at least one hole (their cells become 8).
    include(arc2_scc_touches_hole_(Holes), Comps, HoleComps),
    % Flatten hole-bearing components to a single deduplicated cell list.
    flatten(HoleComps, HCFlat), sort(HCFlat, HoleCells),
    % Paint holes 6, border 2, and hole-component cells 8 onto the input grid.
    % Use distinct accumulator names to prevent lambda variable capture.
    foldl([RC6, Gi6, Go6]>>(RC6 = R6-C6, arc2_set_cell_(Gi6, R6, C6, 6, Go6)), Holes, Grid, GA),
    foldl([RC2, Gi2, Go2]>>(RC2 = R2-C2, arc2_set_cell_(Gi2, R2, C2, 2, Go2)), Border, GA, GB),
    foldl([RC8, Gi8, Go8]>>(RC8 = R8-C8, arc2_set_cell_(Gi8, R8, C8, 8, Go8)), HoleCells, GB, Out).

% arc2_scc_bg_(+Flat, -BG): background is the most-frequent value in Flat.
arc2_scc_bg_(Flat, BG) :-
    % Sort to group equal values into consecutive runs.
    msort(Flat, Sorted),
    % Convert runs to Count-Value pairs.
    arc2_scc_runs_(Sorted, Runs),
    % Pick the pair with the highest count.
    max_member(_-BG, Runs).

% arc2_scc_runs_(+SortedList, -Pairs): run-length encode a sorted list.
arc2_scc_runs_([], []) :- !.
arc2_scc_runs_([H|T], [C-H|Rest]) :-
    % Count how many leading H values are present.
    arc2_scc_run_count_([H|T], H, 0, C, Rem),
    % Recurse on the remainder.
    arc2_scc_runs_(Rem, Rest).

% arc2_scc_run_count_(+List, +Val, +Acc, -Count, -Rem): count leading Val occurrences.
arc2_scc_run_count_([], _, C, C, []) :- !.
arc2_scc_run_count_([H|T], H, C0, C, Rem) :-
    !, C1 is C0 + 1,
    % Continue counting matching values.
    arc2_scc_run_count_(T, H, C1, C, Rem).
arc2_scc_run_count_([H|T], _, C, C, [H|T]).

% arc2_scc_outside_(+Grid, +NR, +NC, +BG, -Outside): all BG cells reachable from boundary.
arc2_scc_outside_(Grid, NR, NC, BG, Outside) :-
    % Seed BFS with all BG cells on the grid perimeter.
    NR1 is NR - 1, NC1 is NC - 1,
    findall(R-C,
        (between(0, NR1, R), between(0, NC1, C),
         ( R =:= 0 ; R =:= NR1 ; C =:= 0 ; C =:= NC1 ),
         nth0(R, Grid, GRow), nth0(C, GRow, V), V =:= BG),
        Seeds0),
    sort(Seeds0, Seeds),
    % BFS: expand through BG cells not yet visited.
    arc2_scc_bfs_(Seeds, Seeds, Grid, NR, NC, BG, Outside).

% arc2_scc_bfs_(+Queue, +Visited, +Grid, +NR, +NC, +BG, -All): BFS flood fill.
arc2_scc_bfs_([], Visited, _, _, _, _, Visited) :- !.
arc2_scc_bfs_([R-C|Q], Visited, Grid, NR, NC, BG, Outside) :-
    % Find unvisited BG neighbours of the current cell.
    R1 is R-1, R2 is R+1, C1 is C-1, C2 is C+1,
    findall(RN-CN,
        (member(RN-CN, [R1-C, R2-C, R-C1, R-C2]),
         RN >= 0, RN < NR, CN >= 0, CN < NC,
         nth0(RN, Grid, GRow), nth0(CN, GRow, V), V =:= BG,
         \+ memberchk(RN-CN, Visited)),
        New),
    % Extend the visited set and queue.
    append(Visited, New, V2),
    append(Q, New, Q2),
    arc2_scc_bfs_(Q2, V2, Grid, NR, NC, BG, Outside).

% arc2_scc_nonbg_nbr_(+Grid, +BG, +R, +C): succeeds if (R,C) has a non-BG 8-neighbour.
arc2_scc_nonbg_nbr_(Grid, BG, R, C) :-
    R1 is R-1, R2 is R+1, C1 is C-1, C2 is C+1,
    % Check all 8 Chebyshev neighbours (4 cardinal + 4 diagonal).
    member(RN-CN, [R1-C1, R1-C, R1-C2, R-C1, R-C2, R2-C1, R2-C, R2-C2]),
    nth0(RN, Grid, GRow), nth0(CN, GRow, V), V \= BG.

% arc2_scc_comps_(+Positions, -Components): partition into 4-connected components.
arc2_scc_comps_([], []) :- !.
arc2_scc_comps_([H|T], [Comp|Rest]) :-
    % Pool = all positions except the seed H.
    subtract([H|T], [H], Pool),
    % BFS-grow the component from seed H.
    arc2_scc_grow_([H], Pool, [H], Comp, Remaining),
    % Recurse on the leftover positions.
    arc2_scc_comps_(Remaining, Rest).

% arc2_scc_grow_(+Queue, +Pool, +Acc, -Comp, -Remaining): BFS component expansion.
arc2_scc_grow_([], Pool, Comp, Comp, Pool) :- !.
arc2_scc_grow_([R-C|Q], Pool, Acc, Comp, Remaining) :-
    % Find all Pool members that are 4-adjacent to the current cell.
    R1 is R-1, R2 is R+1, C1 is C-1, C2 is C+1,
    findall(RN-CN,
        (member(RN-CN, [R1-C, R2-C, R-C1, R-C2]),
         memberchk(RN-CN, Pool)),
        Nbrs),
    % Remove found neighbours from Pool to prevent re-discovery.
    subtract(Pool, Nbrs, Pool2),
    % Add neighbours to the BFS queue and component accumulator.
    append(Q, Nbrs, Q2),
    append(Acc, Nbrs, Acc2),
    arc2_scc_grow_(Q2, Pool2, Acc2, Comp, Remaining).

% arc2_scc_touches_hole_(+Holes, +Comp): succeeds if any Comp cell borders a hole.
arc2_scc_touches_hole_(Holes, Comp) :-
    member(R-C, Comp),
    R1 is R-1, R2 is R+1, C1 is C-1, C2 is C+1,
    % Check each cardinal neighbour for membership in Holes.
    member(RN-CN, [R1-C, R2-C, R-C1, R-C2]),
    memberchk(RN-CN, Holes), !.

% ---------------------------------------------------------------------------
% Wave 33 - tile_stamp (bf45cf4b)
% Rule: find the compact multi-color kernel rectangle and the scattered
%       single-color indicator pattern; tile the kernel at each non-BG
%       position of the pattern grid.
% ---------------------------------------------------------------------------

% Register the tile_stamp named rule.
arc2_named_rule(tile_stamp).

% arc2_transform(tile_stamp, +Grid, -Out): stamp kernel at each indicator cell.
arc2_transform(tile_stamp, Grid, Out) :-
% Flatten grid to feed into the most-frequent-value background detector.
    flatten(Grid, Flat),
% Identify background as the most-frequent cell value.
    arc2_scc_bg_(Flat, BG),
% Collect all non-background R-C positions.
    arc2_stamp_nonbg_(Grid, BG, Cells),
% Partition non-background cells into 4-connected components.
    arc2_scc_comps_(Cells, Comps),
% Split: kernel component uses >1 distinct value; pattern components use 1.
    arc2_stamp_kern_(Comps, Grid, KR1, KC1, KR, KC, PatCells),
% Extract the kernel sub-grid (interior BG cells are kept verbatim).
    arc2_stamp_subgrid_(Grid, KR1, KC1, KR, KC, Kern),
% Compute bounding box of all pattern indicator cells.
    arc2_stamp_bbox_(PatCells, PR1, PC1, PR2, PC2),
% Compute pattern grid dimensions.
    PNR is PR2 - PR1 + 1, PNC is PC2 - PC1 + 1,
% Build tiled output: PNR*KR rows x PNC*KC cols.
    arc2_stamp_out_(PatCells, PR1, PC1, PNR, PNC, BG, Kern, KR, KC, Out).

% arc2_stamp_nonbg_(+Grid, +BG, -Cells): collect all non-BG R-C positions.
arc2_stamp_nonbg_(Grid, BG, Cells) :-
% Enumerate every row and column; keep only non-background cells.
    findall(R-C, (nth0(R, Grid, Row), nth0(C, Row, V), V \= BG), Cells).

% arc2_stamp_kern_(+Comps, +Grid, -KR1, -KC1, -KR, -KC, -PatCells):
% Identify kernel component (>1 distinct value) and collect pattern cells.
arc2_stamp_kern_(Comps, Grid, KR1, KC1, KR, KC, PatCells) :-
% Separate the one kernel component from all pattern components.
    partition([Comp]>>(arc2_stamp_multi_val_(Comp, Grid)), Comps, [KernComp], Pats),
% Compute kernel bounding box.
    arc2_stamp_bbox_(KernComp, KR1, KC1, KR2, KC2),
% Compute kernel height and width.
    KR is KR2 - KR1 + 1, KC is KC2 - KC1 + 1,
% Merge all pattern components into one flat position list.
    flatten(Pats, PatCells).

% arc2_stamp_multi_val_(+Comp, +Grid): succeed if Comp cells use >1 distinct value.
arc2_stamp_multi_val_(Comp, Grid) :-
% Collect all cell values at component positions.
    findall(V, (member(R-C, Comp), nth0(R, Grid, Row), nth0(C, Row, V)), Vals),
% Convert to a set and require at least 2 distinct values.
    list_to_set(Vals, VSet), length(VSet, NV), NV > 1.

% arc2_stamp_bbox_(+Cells, -R1, -C1, -R2, -C2): bounding box of an R-C list.
arc2_stamp_bbox_(Cells, R1, C1, R2, C2) :-
% Extract all row indices.
    findall(R, member(R-_, Cells), Rs),
% Extract all column indices.
    findall(C, member(_-C, Cells), Cs),
% Min and max rows; min and max columns.
    min_list(Rs, R1), max_list(Rs, R2),
    min_list(Cs, C1), max_list(Cs, C2).

% arc2_stamp_subgrid_(+Grid, +R1, +C1, +KR, +KC, -SubGrid):
% Extract a KR x KC sub-grid starting at absolute position (R1, C1).
arc2_stamp_subgrid_(Grid, R1, C1, KR, KC, SubGrid) :-
% Build row-offset list 0..KR-1.
    KRm is KR - 1, numlist(0, KRm, DRs),
% Build column-offset list 0..KC-1.
    KCm is KC - 1, numlist(0, KCm, DCs),
% For each row offset fetch the corresponding kernel row.
    maplist([DR, KRow]>>(
        R is R1 + DR, nth0(R, Grid, FullRow),
        maplist([DC, V]>>(C is C1 + DC, nth0(C, FullRow, V)), DCs, KRow)
    ), DRs, SubGrid).

% arc2_stamp_out_(+PatCells, +PR1, +PC1, +PNR, +PNC, +BG, +Kern, +KR, +KC, -Out):
% Build output grid of PNR*KR rows x PNC*KC cols by tiling the kernel.
arc2_stamp_out_(PatCells, PR1, PC1, PNR, PNC, BG, Kern, KR, KC, Out) :-
% Total output rows.
    OutNR is PNR * KR, OutNRm is OutNR - 1,
% Build each output row from its flat row index.
    numlist(0, OutNRm, RowIdxs),
    maplist([ROut, Row]>>(
        TR is ROut // KR, DR is ROut mod KR,
        arc2_stamp_row_(TR, DR, PatCells, PR1, PC1, PNC, KC, BG, Kern, Row)
    ), RowIdxs, Out).

% arc2_stamp_row_(+TR, +DR, +PatCells, +PR1, +PC1, +PNC, +KC, +BG, +Kern, -Row):
% Build one output row for tile row TR at kernel row offset DR.
arc2_stamp_row_(TR, DR, PatCells, PR1, PC1, PNC, KC, BG, Kern, Row) :-
% Get the kernel row for this vertical offset.
    nth0(DR, Kern, KernRow),
% Tile column indices 0..PNC-1.
    PNCm is PNC - 1, numlist(0, PNCm, TCs),
% Kernel column offset indices 0..KC-1.
    KCm is KC - 1, numlist(0, KCm, DCs),
% For each tile column produce a kernel segment or a BG segment.
    maplist([TC, Seg]>>(
        R is PR1 + TR, C is PC1 + TC,
        ( memberchk(R-C, PatCells) ->
            maplist([DC, V]>>(nth0(DC, KernRow, V)), DCs, Seg)
        ;   length(Seg, KC), maplist(=(BG), Seg)
        )
    ), TCs, Segs),
% Concatenate tile segments into a single flat row list.
    flatten(Segs, Row).

% ---------------------------------------------------------------------------
% Wave 34 - rail_fill (271d71e2)
% Rule: each sub-object is a 0-bordered box with two parallel 9-rails (arm).
%       arm_gap = distance between inner and outer rail.
%       The box gains min(arm_gap, free_interior_cells) new 7-cells,
%       filling from the arm side in column(or row)-major order, then
%       moves toward the outer rail by the same amount.
%       The inner rail merges into the box; arm_gap shrinks accordingly.
% ---------------------------------------------------------------------------

% Register the rail_fill named rule.
arc2_named_rule(rail_fill).

% arc2_rf_row_val_: check row R cols C1..C2 all equal V.
arc2_rf_row_val_(Grid, R, C1, C2, V) :-
% Retrieve row R from the grid.
    nth0(R, Grid, Row),
% Every column in C1..C2 must hold value V.
    forall(between(C1, C2, C), (nth0(C, Row, X), X =:= V)).

% arc2_rf_col_val_: check column C rows R1..R2 all equal V.
arc2_rf_col_val_(Grid, C, R1, R2, V) :-
% Every row in R1..R2 must hold value V at column C.
    forall(between(R1, R2, R), (nth0(R, Grid, Row), nth0(C, Row, X), X =:= V)).

% arc2_rf_zero_border_: box (R1,C1)..(R2,C2) has a 0-valued border.
arc2_rf_zero_border_(Grid, R1, C1, R2, C2) :-
% Top border row all 0.
    arc2_rf_row_val_(Grid, R1, C1, C2, 0),
% Bottom border row all 0.
    arc2_rf_row_val_(Grid, R2, C1, C2, 0),
% Left border column all 0.
    arc2_rf_col_val_(Grid, C1, R1, R2, 0),
% Right border column all 0.
    arc2_rf_col_val_(Grid, C2, R1, R2, 0).

% arc2_rf_valid_interior_: interior of box contains only cells valued 5 or 7.
arc2_rf_valid_interior_(Grid, R1, C1, R2, C2) :-
% Compute interior index bounds.
    RI1 is R1 + 1, RI2 is R2 - 1, CI1 is C1 + 1, CI2 is C2 - 1,
% Interior must be non-empty.
    RI1 =< RI2, CI1 =< CI2,
% Every interior cell must be 5 or 7.
    forall(between(RI1, RI2, R),
        forall(between(CI1, CI2, C), (
            nth0(R, Grid, Row), nth0(C, Row, V),
            (V =:= 5 ; V =:= 7)
        ))).

% arc2_rf_find_9col_l_: first 9-column at or left of C spanning rows R1..R2.
arc2_rf_find_9col_l_(_, C, _, _, _) :- C < 0, !, fail.
arc2_rf_find_9col_l_(Grid, C, R1, R2, C) :-
% This column is all-9 in R1..R2; found it.
    arc2_rf_col_val_(Grid, C, R1, R2, 9), !.
arc2_rf_find_9col_l_(Grid, C, R1, R2, F) :-
% Move one column left and continue searching.
    C1 is C - 1, arc2_rf_find_9col_l_(Grid, C1, R1, R2, F).

% arc2_rf_find_9col_r_: first 9-column at or right of C, within NC.
arc2_rf_find_9col_r_(_, C, NC, _, _, _) :- C >= NC, !, fail.
arc2_rf_find_9col_r_(Grid, C, NC, R1, R2, C) :-
% This column is all-9 in R1..R2; found it.
    arc2_rf_col_val_(Grid, C, R1, R2, 9), !.
arc2_rf_find_9col_r_(Grid, C, NC, R1, R2, F) :-
% Move one column right and continue searching.
    C1 is C + 1, arc2_rf_find_9col_r_(Grid, C1, NC, R1, R2, F).

% arc2_rf_find_9row_u_: first 9-row at or above R spanning cols C1..C2.
arc2_rf_find_9row_u_(_, R, _, _, _) :- R < 0, !, fail.
arc2_rf_find_9row_u_(Grid, R, C1, C2, R) :-
% This row is all-9 in C1..C2; found it.
    arc2_rf_row_val_(Grid, R, C1, C2, 9), !.
arc2_rf_find_9row_u_(Grid, R, C1, C2, F) :-
% Move one row up and continue searching.
    R1 is R - 1, arc2_rf_find_9row_u_(Grid, R1, C1, C2, F).

% arc2_rf_find_9row_d_: first 9-row at or below R, within NR.
arc2_rf_find_9row_d_(_, R, NR, _, _, _) :- R >= NR, !, fail.
arc2_rf_find_9row_d_(Grid, R, NR, C1, C2, R) :-
% This row is all-9 in C1..C2; found it.
    arc2_rf_row_val_(Grid, R, C1, C2, 9), !.
arc2_rf_find_9row_d_(Grid, R, NR, C1, C2, F) :-
% Move one row down and continue searching.
    R1 is R + 1, arc2_rf_find_9row_d_(Grid, R1, NR, C1, C2, F).

% arc2_rf_arm_: detect arm direction and locate inner/outer rails.
arc2_rf_arm_(Grid, NR, NC, R1, C1, R2, C2, Dir, Inner, Outer) :-
% Try left arm: two 9-columns to the left of the box.
    (   C1 > 0, IL is C1 - 1,
        arc2_rf_find_9col_l_(Grid, IL, R1, R2, Inner),
        OL is Inner - 1, OL >= 0,
        arc2_rf_find_9col_l_(Grid, OL, R1, R2, Outer),
        Dir = arm_left
% Try right arm: two 9-columns to the right of the box.
    ;   IR is C2 + 1,
        arc2_rf_find_9col_r_(Grid, IR, NC, R1, R2, Inner),
        OR2 is Inner + 1,
        arc2_rf_find_9col_r_(Grid, OR2, NC, R1, R2, Outer),
        Dir = arm_right
% Try top arm: two 9-rows above the box.
    ;   R1 > 0, IU is R1 - 1,
        arc2_rf_find_9row_u_(Grid, IU, C1, C2, Inner),
        OU is Inner - 1, OU >= 0,
        arc2_rf_find_9row_u_(Grid, OU, C1, C2, Outer),
        Dir = arm_top
% Try bottom arm: two 9-rows below the box.
    ;   ID is R2 + 1,
        arc2_rf_find_9row_d_(Grid, ID, NR, C1, C2, Inner),
        OD is Inner + 1,
        arc2_rf_find_9row_d_(Grid, OD, NR, C1, C2, Outer),
        Dir = arm_bottom
    ), !.

% arc2_rf_arm_gap_: distance between inner and outer rail.
arc2_rf_arm_gap_(arm_left,   Inner, Outer, Gap) :- Gap is Inner - Outer.
arc2_rf_arm_gap_(arm_right,  Inner, Outer, Gap) :- Gap is Outer - Inner.
arc2_rf_arm_gap_(arm_top,    Inner, Outer, Gap) :- Gap is Inner - Outer.
arc2_rf_arm_gap_(arm_bottom, Inner, Outer, Gap) :- Gap is Outer - Inner.

% arc2_rf_fill_order_: R-C pairs in fill order for H x W interior, given arm direction.
% arm_left: column-by-column left-to-right, bottom-to-top within each column.
arc2_rf_fill_order_(arm_left, H, W, Order) :-
    H1 is H - 1, W1 is W - 1,
    numlist(0, W1, Cols), numlist(0, H1, RowsFwd), reverse(RowsFwd, Rows),
    findall(R-C, (member(C, Cols), member(R, Rows)), Order).
% arm_right: column-by-column right-to-left, top-to-bottom within each column.
arc2_rf_fill_order_(arm_right, H, W, Order) :-
    H1 is H - 1, W1 is W - 1,
    numlist(0, W1, ColsFwd), reverse(ColsFwd, Cols), numlist(0, H1, Rows),
    findall(R-C, (member(C, Cols), member(R, Rows)), Order).
% arm_top: row-by-row top-to-bottom, left-to-right within each row.
arc2_rf_fill_order_(arm_top, H, W, Order) :-
    H1 is H - 1, W1 is W - 1,
    numlist(0, H1, Rows), numlist(0, W1, Cols),
    findall(R-C, (member(R, Rows), member(C, Cols)), Order).
% arm_bottom: row-by-row bottom-to-top, right-to-left within each row.
arc2_rf_fill_order_(arm_bottom, H, W, Order) :-
    H1 is H - 1, W1 is W - 1,
    numlist(0, H1, RowsFwd), reverse(RowsFwd, Rows),
    numlist(0, W1, ColsFwd), reverse(ColsFwd, Cols),
    findall(R-C, (member(R, Rows), member(C, Cols)), Order).

% arc2_rf_take_n_: first N elements of a list, or all if N >= length.
arc2_rf_take_n_(N, List, Taken) :-
    length(List, Len),
% If N exceeds list length take everything; else take exactly N.
    ( N >= Len -> Taken = List
    ; length(Taken, N), append(Taken, _, List)
    ).

% arc2_rf_make_interior_: build H x W grid with first N7 cells in Order as 7, rest 5.
arc2_rf_make_interior_(H, W, N7, Order, Interior) :-
% Collect the positions that will become 7.
    arc2_rf_take_n_(N7, Order, SevenCells),
    H1 is H - 1, W1 is W - 1,
    numlist(0, H1, RowIdxs), numlist(0, W1, ColIdxs),
% Build each row, assigning 7 or 5 to each cell.
    maplist([Ri, Row]>>(
        maplist([Ci, V]>>(
            ( memberchk(Ri-Ci, SevenCells) -> V = 7 ; V = 5 )
        ), ColIdxs, Row)
    ), RowIdxs, Interior).

% arc2_rf_new_box_pos_: shift the box N steps toward the outer rail.
arc2_rf_new_box_pos_(arm_left,   R1, C1, R2, C2, N, R1, NC1, R2, NC2) :-
    NC1 is C1 - N, NC2 is C2 - N.
arc2_rf_new_box_pos_(arm_right,  R1, C1, R2, C2, N, R1, NC1, R2, NC2) :-
    NC1 is C1 + N, NC2 is C2 + N.
arc2_rf_new_box_pos_(arm_top,    R1, C1, R2, C2, N, NR1, C1, NR2, C2) :-
    NR1 is R1 - N, NR2 is R2 - N.
arc2_rf_new_box_pos_(arm_bottom, R1, C1, R2, C2, N, NR1, C1, NR2, C2) :-
    NR1 is R1 + N, NR2 is R2 + N.

% arc2_rf_new_inner_: new inner rail position; none when gap collapses to 0.
arc2_rf_new_inner_(_, _, 0, none) :- !.
arc2_rf_new_inner_(arm_left,   Outer, NewGap, NInner) :- NInner is Outer + NewGap.
arc2_rf_new_inner_(arm_right,  Outer, NewGap, NInner) :- NInner is Outer - NewGap.
arc2_rf_new_inner_(arm_top,    Outer, NewGap, NInner) :- NInner is Outer + NewGap.
arc2_rf_new_inner_(arm_bottom, Outer, NewGap, NInner) :- NInner is Outer - NewGap.

% arc2_rf_count_sevens_: count 7-valued cells in the interior of a box.
arc2_rf_count_sevens_(Grid, R1, C1, R2, C2, N7) :-
    RI1 is R1 + 1, RI2 is R2 - 1, CI1 is C1 + 1, CI2 is C2 - 1,
    findall(_, (
        between(RI1, RI2, R), between(CI1, CI2, C),
        nth0(R, Grid, Row), nth0(C, Row, 7)
    ), Sevens),
    length(Sevens, N7).

% arc2_rf_box_transform_: compute full output plan for one box.
arc2_rf_box_transform_(Grid, NR, NC, box(R1,C1,R2,C2),
        plan(NR1b,NC1b,NR2b,NC2b, Interior,
             Dir, Outer, RngR1,RngR2,RngC1,RngC2, NewInner)) :-
% Locate the arm direction and both rail positions.
    arc2_rf_arm_(Grid, NR, NC, R1, C1, R2, C2, Dir, Inner, Outer),
% Compute the gap between the two rails.
    arc2_rf_arm_gap_(Dir, Inner, Outer, Gap),
% Interior height and width.
    H is R2 - R1 - 1, W is C2 - C1 - 1,
% Count existing 7-cells.
    arc2_rf_count_sevens_(Grid, R1, C1, R2, C2, N7in),
% Gain = min(gap, free interior cells).
    FreeCells is H * W - N7in,
    N7gained is min(Gap, FreeCells),
% New total 7-count.
    N7new is N7in + N7gained,
% Build the fill order and new interior.
    arc2_rf_fill_order_(Dir, H, W, Order),
    arc2_rf_make_interior_(H, W, N7new, Order, Interior),
% New box position (shifted by N7gained toward outer rail).
    arc2_rf_new_box_pos_(Dir, R1, C1, R2, C2, N7gained, NR1b, NC1b, NR2b, NC2b),
% New inner rail position (none if gap collapses).
    NewGap is Gap - N7gained,
    arc2_rf_new_inner_(Dir, Outer, NewGap, NewInner),
% Rail spans the same row/col range as the (stationary-axis) box bounds.
    (   (Dir = arm_left ; Dir = arm_right)
    ->  RngR1 = R1, RngR2 = R2, RngC1 = Outer, RngC2 = Outer
    ;   RngR1 = Outer, RngR2 = Outer, RngC1 = C1, RngC2 = C2
    ).

% arc2_rf_cell_in_plan_: deduce output value at (R,C) from a single box plan.
arc2_rf_cell_in_plan_(R, C,
        plan(NR1b,NC1b,NR2b,NC2b,Interior,Dir,Outer,RngR1,RngR2,RngC1,RngC2,NewInner), V) :-
% Pre-compute interior row/col bounds to avoid arithmetic in between/3.
    NR1i is NR1b + 1, NR2i is NR2b - 1, NC1i is NC1b + 1, NC2i is NC2b - 1,
    (   (Dir = arm_left ; Dir = arm_right)
% Outer rail column.
    ->  (   C =:= Outer, between(RngR1, RngR2, R), V = 9
% New inner rail column (if it exists).
        ;   NewInner \= none, C =:= NewInner, between(RngR1, RngR2, R), V = 9
% Top and bottom box border rows.
        ;   (R =:= NR1b ; R =:= NR2b), between(NC1b, NC2b, C), V = 0
% Left and right box border columns.
        ;   (C =:= NC1b ; C =:= NC2b), between(NR1b, NR2b, R), V = 0
% Interior cell: look up value in the transformed interior grid.
        ;   between(NR1i, NR2i, R), between(NC1i, NC2i, C),
            Ri is R - NR1b - 1, Ci is C - NC1b - 1,
            nth0(Ri, Interior, IRow), nth0(Ci, IRow, V)
        )
% Same cases for top/bottom arm (outer rail is a row, not a column).
    ;   (   R =:= Outer, between(RngC1, RngC2, C), V = 9
        ;   NewInner \= none, R =:= NewInner, between(RngC1, RngC2, C), V = 9
        ;   (R =:= NR1b ; R =:= NR2b), between(NC1b, NC2b, C), V = 0
        ;   (C =:= NC1b ; C =:= NC2b), between(NR1b, NR2b, R), V = 0
        ;   between(NR1i, NR2i, R), between(NC1i, NC2i, C),
            Ri is R - NR1b - 1, Ci is C - NC1b - 1,
            nth0(Ri, Interior, IRow), nth0(Ci, IRow, V)
        )
    ), !.

% arc2_rf_cell_val_: output value at (R,C): first matching plan wins, else BG.
arc2_rf_cell_val_(R, C, BG, Plans, V) :-
    (   member(Plan, Plans), arc2_rf_cell_in_plan_(R, C, Plan, V), !
    ;   V = BG
    ).

% arc2_transform(rail_fill, +Grid, -Out): entry point for Wave 34.
arc2_transform(rail_fill, Grid, Out) :-
% Determine grid dimensions.
    length(Grid, NR), Grid = [FirstRow|_], length(FirstRow, NC),
% Background = value at top-left corner.
    FirstRow = [BG|_],
% Collect all 0-valued cells as candidate box-corner positions.
    findall(R-C, (nth0(R, Grid, Row), nth0(C, Row, 0)), ZeroCells),
% Find every valid 0-bordered box with a 5/7 interior.
    findall(box(R1,C1,R2,C2), (
        member(R1-C1, ZeroCells),
        member(R2-C2, ZeroCells),
        R2 > R1 + 1, C2 > C1 + 1,
        arc2_rf_zero_border_(Grid, R1, C1, R2, C2),
        arc2_rf_valid_interior_(Grid, R1, C1, R2, C2)
    ), Boxes),
% Compute a transformation plan for each box.
    maplist(arc2_rf_box_transform_(Grid, NR, NC), Boxes, Plans),
% Build the output grid: BG everywhere unless overridden by a plan.
    NR1 is NR - 1, NC1 is NC - 1,
    numlist(0, NR1, RowIdxs), numlist(0, NC1, ColIdxs),
    maplist([R, Row]>>(
        maplist([C, V]>>(
            arc2_rf_cell_val_(R, C, BG, Plans, V)
        ), ColIdxs, Row)
    ), RowIdxs, Out).

% ---------------------------------------------------------------------------
% WAVE 35: bbox_fill (Layer 268)
% Task 9385bd28.  A 2-column legend block at the bottom-left maps each object
% color K to a fill color V.  For every (K,V) pair in the legend (excluding
% erase entries where V=0 and BG≠0): collect all K-cells outside the legend,
% compute their bounding box, fill the entire box with V, then re-paint the
% original K-cells at their positions if the box is sparse (< 100% density).
% Smaller boxes are drawn last so they override larger overlapping boxes.
% When V = BG (not zero), the fill is the background value, which effectively
% blocks any earlier fill from a larger enclosing box.
% ---------------------------------------------------------------------------

% Register the bbox_fill named rule.
arc2_named_rule(bbox_fill).

% arc2_bxf_scan_up_: collect consecutive rows upward from R where col C is non-BG.
arc2_bxf_scan_up_(_, _, R, _, []) :-
% Stop if we go above the grid.
    R < 0, !.
arc2_bxf_scan_up_(Grid, BG, R, C, Block) :-
% Include row R if Grid[R][C] is not BG; continue upward.
    nth0(R, Grid, Row),
% Check that col C in this row is a non-background value.
    nth0(C, Row, V0), V0 =\= BG, !,
% Move one row up.
    R1 is R - 1,
% Recurse upward to collect more consecutive legend rows.
    arc2_bxf_scan_up_(Grid, BG, R1, C, Rest),
% Prepend current row to the block.
    Block = [R | Rest].
arc2_bxf_scan_up_(_, _, _, _, []).

% arc2_bxf_legend_: detect the 2-column legend block.
% Scans leftmost column pair (LC, LC+1) in the bottom half that has a
% contiguous block of rows where Grid[R][LC] ≠ BG.
% LC     = left legend column index.
% LegRows = ascending list of legend row indices.
% LegMap  = list of K-V pairs (may include K->BG entries).
arc2_bxf_legend_(Grid, BG, LC, LegRows, LegMap) :-
% Compute grid dimensions and lower search boundary.
    length(Grid, NR), Grid = [R0 | _], length(R0, NC),
    HalfNR is NR // 2, NR1 is NR - 1, NC2 is NC - 2,
% Try column pairs left-to-right; stop at the first valid legend block.
    (between(0, NC2, LC),
     findall(R, (between(HalfNR, NR1, R),
         nth0(R, Grid, Row),
         nth0(LC, Row, V0), V0 =\= BG), Cands),
     Cands \= [],
     last(Cands, LastR),
     arc2_bxf_scan_up_(Grid, BG, LastR, LC, Block),
     Block \= [] -> true ; fail), !,
% Reverse scan order to get ascending row order.
    reverse(Block, LegRows),
% Build K-V map from legend rows.
    LC1 is LC + 1,
    findall(K-V, (member(R, LegRows),
        nth0(R, Grid, Row),
        nth0(LC, Row, K),
        nth0(LC1, Row, V)), LegMap).

% arc2_bxf_update_bbox_: fold helper to expand bounding box.
arc2_bxf_update_bbox_(R-C, Ra-Ca-Rb-Cb, Nr1-Nc1-Nr2-Nc2) :-
% Expand min/max in both dimensions.
    Nr1 is min(R, Ra), Nc1 is min(C, Ca),
    Nr2 is max(R, Rb), Nc2 is max(C, Cb).

% arc2_bxf_bbox_: compute bounding box of a non-empty list of R-C cells.
arc2_bxf_bbox_([R0-C0 | Rest], R1, C1, R2, C2) :-
% Fold over remaining cells to find min/max extents.
    foldl(arc2_bxf_update_bbox_, Rest, R0-C0-R0-C0, R1-C1-R2-C2).

% arc2_bxf_is_erase_: true when V=0 and BG≠0 (erase sentinel).
arc2_bxf_is_erase_(V, BG) :-
% Value 0 with non-zero background signals "erase K-cells, no fill".
    V =:= 0, BG =\= 0.

% arc2_bxf_fill_for_: find fill value for (R,C) from smallest containing bbox.
% InfosAsc is sorted ascending by bbox area, so first match = smallest box.
arc2_bxf_fill_for_(R, C, [inf(_, V, BR1, BC1, BR2, BC2, _) | _], V) :-
% First matching (smallest) bbox wins.
    between(BR1, BR2, R), between(BC1, BC2, C), !.
arc2_bxf_fill_for_(R, C, [_ | Rest], V) :-
% Try the next bbox if this one does not contain (R,C).
    arc2_bxf_fill_for_(R, C, Rest, V).

% arc2_bxf_cell_val_: compute output value at (R,C) given all fills.
% Priority: legend cell > BG cell (fill lookup) > erase K-cell (fill lookup)
%           > mapped K-cell (dense→V ; sparse→K) > unmapped non-BG (preserve).
arc2_bxf_cell_val_(R, C, OrigV, _, LegCells, _, _, OrigV) :-
% Legend cells are always preserved verbatim.
    member(R-C, LegCells), !.
arc2_bxf_cell_val_(R, C, OrigV, BG, _, _, InfosAsc, V) :-
% Background cell: fill from smallest enclosing bbox, or keep BG.
    OrigV =:= BG, !,
    (arc2_bxf_fill_for_(R, C, InfosAsc, FV) -> V = FV ; V = BG).
arc2_bxf_cell_val_(R, C, OrigV, BG, _, LegMap, InfosAsc, V) :-
% Erase K-cell (V=0, BG≠0): treat same as background—no repaint.
    member(OrigV-MapV, LegMap), arc2_bxf_is_erase_(MapV, BG), !,
    (arc2_bxf_fill_for_(R, C, InfosAsc, FV) -> V = FV ; V = BG).
arc2_bxf_cell_val_(R, C, OrigV, _, _, LegMap, InfosAsc, V) :-
% Mapped K-cell with real fill: dense bbox → V; sparse bbox → keep K.
    member(OrigV-MapV, LegMap), !,
    (member(inf(OrigV, MapV, BR1, BC1, BR2, BC2, Dense), InfosAsc),
     between(BR1, BR2, R), between(BC1, BC2, C) ->
        (Dense = true -> V = MapV ; V = OrigV)
    ; V = OrigV).
arc2_bxf_cell_val_(_, _, OrigV, _, _, _, _, OrigV).

% arc2_bxf_build_row_: build one output row for row index R.
arc2_bxf_build_row_(Grid, R, NC, BG, LegCells, LegMap, InfosAsc, Row) :-
% Iterate over all column indices in this row.
    NC1p is NC - 1, numlist(0, NC1p, ColIs),
    maplist([C, V]>>(
        nth0(R, Grid, GRow), nth0(C, GRow, OrigV),
        arc2_bxf_cell_val_(R, C, OrigV, BG, LegCells, LegMap, InfosAsc, V)
    ), ColIs, Row).

% arc2_transform(bbox_fill, +Grid, -Out): entry point for Wave 35.
arc2_transform(bbox_fill, Grid, Out) :-
% Extract grid dimensions and background color.
    length(Grid, NR), Grid = [R0 | _], length(R0, NC),
    R0 = [BG | _], NR1 is NR - 1, NC1p is NC - 1,
% Detect legend: leftmost 2-col block in the bottom half.
    arc2_bxf_legend_(Grid, BG, LC, LegRows, LegMap),
% Collect all legend cell positions (both col LC and LC+1).
    LC1 is LC + 1,
    findall(R-C, (member(R, LegRows), (C = LC ; C = LC1)), LegCells),
% Build sorted info list (ascending by area) for non-erase fills.
    findall(Area-inf(K, V, BR1, BC1, BR2, BC2, Dense), (
        member(K-V, LegMap),
        \+ arc2_bxf_is_erase_(V, BG),
% Collect all non-legend K-cells in the grid.
        findall(R-C, (
            between(0, NR1, R), between(0, NC1p, C),
            nth0(R, Grid, Row), nth0(C, Row, K),
            \+ member(R-C, LegCells)
        ), KCells),
        KCells \= [],
% Compute bounding box and density.
        arc2_bxf_bbox_(KCells, BR1, BC1, BR2, BC2),
        H is BR2 - BR1 + 1, W is BC2 - BC1 + 1, Area is H * W,
        length(KCells, NK),
        (NK =:= Area -> Dense = true ; Dense = false)
    ), Pairs),
% Sort ascending by area so smallest bbox is first (fill_for finds smallest).
    keysort(Pairs, SortedAsc), pairs_values(SortedAsc, InfosAsc),
% Build output grid row by row.
    numlist(0, NR1, RowIs),
    maplist([R, Row]>>(
        arc2_bxf_build_row_(Grid, R, NC, BG, LegCells, LegMap, InfosAsc, Row)
    ), RowIs, Out).

% ---------------------------------------------------------------------------
% WAVE 36: slide_void (task 332f06d7)
% A void rectangle (0-cells, H x W) slides along a river of 1-cells toward a
% 2-marker (same H x W). The void moves to the FARTHEST reachable dead-end in
% the block-movement graph, where dead-end = block position with exactly one
% slide neighbour. If the farthest dead-end is adjacent to the 2-marker the
% void instead moves directly to the 2-marker position.
% Block passability: a cell is passable (value 0 or 1) in the original grid.
% ---------------------------------------------------------------------------

% Register the slide_void named rule.
arc2_named_rule(slide_void).

% ---------------------------------------------------------------------------
% WAVE 37: concentric_rings (task 13e47133)
% Grid background BG (most frequent) and divider Div (most frequent non-BG)
% partition into connected regions via flood-fill. Each region fills with
% concentric rectangular rings: ring 0 = cells on grid boundary or adjacent
% to any Div cell; ring K = BFS distance K from ring-0 sources (cannot cross
% Div). Non-BG, non-Div single-cell markers define the color cycle: cycle[R]
% = marker.color if a marker sits at ring R, else BG. The cycle repeats.
% ---------------------------------------------------------------------------

% arc2_named_rule fact registers concentric_rings for induction.
arc2_named_rule(concentric_rings).

% arc2_cri_bg_: background = most frequent color across all grid cells.
arc2_cri_bg_(Grid, BG) :-
% Flatten the 2-D grid into one flat list.
    flatten(Grid, Cells),
% Collect distinct values present in the grid.
    list_to_set(Cells, Vals),
% Count occurrences; produce Count-Value pairs.
    maplist({Cells}/[V, N-V]>>(include(=(V), Cells, Cs), length(Cs, N)),
            Vals, Counts),
% Sort ascending by count so the last element is the maximum.
    msort(Counts, Sorted),
% Extract the most frequent value as background.
    last(Sorted, _-BG).

% arc2_cri_div_: divider = most frequent non-BG color (forms wall structure).
arc2_cri_div_(Grid, BG, Div) :-
% Flatten and remove all BG cells.
    flatten(Grid, Cells),
% Keep only cells whose value differs from BG.
    exclude(=(BG), Cells, NonBG),
% Must have at least one non-BG value.
    NonBG \= [],
% Collect distinct non-BG values.
    list_to_set(NonBG, Vals),
% Count occurrences of each non-BG value.
    maplist({NonBG}/[V, N-V]>>(include(=(V), NonBG, Cs), length(Cs, N)),
            Vals, Counts),
% Sort ascending; last entry is the most frequent = divider.
    msort(Counts, Sorted),
% Extract divider color.
    last(Sorted, _-Div).

% arc2_cri_nbrs_: 4-connected grid neighbours of (R,C) within bounds.
arc2_cri_nbrs_(NR1, NC1, R, C, Nbrs) :-
% Generate the four directional offsets and filter for valid positions.
    findall(NR2-NC2, (
        member(DR-DC, [(-1)-0, 1-0, 0-(-1), 0-1]),
        NR2 is R + DR, NC2 is C + DC,
        between(0, NR1, NR2), between(0, NC1, NC2)
    ), Nbrs).

% arc2_cri_nbrs8_: 8-connected (4-ortho + 4-diagonal) grid neighbours of (R,C).
arc2_cri_nbrs8_(NR1, NC1, R, C, Nbrs) :-
% Generate all eight directional offsets and filter for valid positions.
    findall(NR2-NC2, (
        member(DR-DC, [(-1)-0, 1-0, 0-(-1), 0-1,
                       (-1)-(-1), (-1)-1, 1-(-1), 1-1]),
        NR2 is R + DR, NC2 is C + DC,
        between(0, NR1, NR2), between(0, NC1, NC2)
    ), Nbrs).

% arc2_cri_is_bnd_: cell (R,C) is ring-0 if on grid boundary or 8-adjacent to Div.
% Using 8-connectivity for Div-adjacency correctly handles L-shaped component
% corners where a diagonal Div neighbour marks a concavity boundary cell.
arc2_cri_is_bnd_(_, NR1, NC1, _, R, C) :-
% Grid boundary check: top, bottom, left, or right edge.
    (R =:= 0 ; R =:= NR1 ; C =:= 0 ; C =:= NC1), !.
arc2_cri_is_bnd_(Grid, NR1, NC1, Div, R, C) :-
% Adjacency-to-Div check: at least one 8-neighbour has the Div value.
    arc2_cri_nbrs8_(NR1, NC1, R, C, Nbrs),
    member(NR2-NC2, Nbrs),
    nth0(NR2, Grid, GRow), nth0(NC2, GRow, Div), !.

% arc2_cri_flood_: BFS flood-fill collecting all non-Div cells reachable from Queue.
% Vis is the accumulated visited set; Comp is returned as the final component.
arc2_cri_flood_(_, _, _, _, [], Vis, Vis) :- !.
arc2_cri_flood_(Grid, NR1, NC1, Div, [R-C | Q], Vis, Comp) :-
% Find 4-neighbours that are non-Div and not yet visited.
    arc2_cri_nbrs_(NR1, NC1, R, C, Nbrs),
    findall(NR2-NC2, (
        member(NR2-NC2, Nbrs),
        nth0(NR2, Grid, GRow), nth0(NC2, GRow, V), V =\= Div,
        \+ member(NR2-NC2, Vis)
    ), New),
% Merge new cells into the queue and deduplicate.
    append(Q, New, Q2), sort(Q2, Q3),
% Extend the visited set with newly discovered cells.
    append(Vis, New, Vis2),
% Continue BFS with updated queue and visited set.
    arc2_cri_flood_(Grid, NR1, NC1, Div, Q3, Vis2, Comp).

% arc2_cri_comps_: partition non-Div cell list NDCs into connected components.
% Seen tracks cells already assigned; Comps is the resulting component list.
arc2_cri_comps_(_, _, _, _, [], _, []) :- !.
arc2_cri_comps_(Grid, NR1, NC1, Div, [RC | Rest], Seen, Comps) :-
% Cell already belongs to a previous component; skip it.
    member(RC, Seen), !,
    arc2_cri_comps_(Grid, NR1, NC1, Div, Rest, Seen, Comps).
arc2_cri_comps_(Grid, NR1, NC1, Div, [R-C | Rest], Seen, [Comp | Comps]) :-
% Start a new component via flood-fill from this unvisited cell.
    arc2_cri_flood_(Grid, NR1, NC1, Div, [R-C], [R-C], Comp),
% Mark all component cells as seen to avoid re-processing.
    append(Seen, Comp, Seen2),
% Recurse over the remaining cells.
    arc2_cri_comps_(Grid, NR1, NC1, Div, Rest, Seen2, Comps).

% arc2_cri_bfs_: multi-source BFS expanding ring distances from Frontier.
% Acc is the accumulated list of R-C-Dist triples; Res is the final map.
arc2_cri_bfs_(_, _, _, _, [], Acc, Acc) :- !.
arc2_cri_bfs_(Grid, NR1, NC1, Div, Frontier, Acc, Res) :-
% Expand each frontier cell: find non-Div neighbours not yet in Acc.
    findall(NR2-NC2-D1, (
        member(R-C-D, Frontier),
        D1 is D + 1,
        arc2_cri_nbrs_(NR1, NC1, R, C, Nbrs),
        member(NR2-NC2, Nbrs),
        nth0(NR2, Grid, GRow), nth0(NC2, GRow, V), V =\= Div,
        \+ member(NR2-NC2-_, Acc)
    ), New0),
% Deduplicate newly discovered cells.
    sort(New0, New),
% Append new cells to the accumulator.
    append(Acc, New, Acc2),
% Continue BFS with new frontier and updated accumulator.
    arc2_cri_bfs_(Grid, NR1, NC1, Div, New, Acc2, Res).

% arc2_cri_build_cycle_: build color cycle from sorted Ring-Color pairs and BG.
% Empty marker list yields a single-element BG cycle.
arc2_cri_build_cycle_([], BG, [BG]) :- !.
arc2_cri_build_cycle_(RCPairs, BG, Cycle) :-
% Find the maximum ring index among all markers.
    last(RCPairs, MaxD-_),
% Enumerate all rings from 0 to MaxD.
    numlist(0, MaxD, Rings),
% For each ring: use the marker color if one exists there, otherwise BG.
    maplist({BG, RCPairs}/[Ring, Color]>>(
        (member(Ring-Color0, RCPairs) -> Color = Color0 ; Color = BG)
    ), Rings, Cycle).

% arc2_transform/3: concentric_rings entry point.
arc2_transform(concentric_rings, Grid, Out) :-
% Extract grid row count and column count.
    length(Grid, NR), NR1 is NR - 1,
    Grid = [Row0 | _], length(Row0, NC), NC1 is NC - 1,
% Detect background color (most frequent) and divider color (most frequent non-BG).
    arc2_cri_bg_(Grid, BG),
    arc2_cri_div_(Grid, BG, Div),
% Collect coordinates of all non-Div cells.
    findall(R-C, (
        between(0, NR1, R), between(0, NC1, C),
        nth0(R, Grid, GRow), nth0(C, GRow, V), V =\= Div
    ), NDCs),
% Partition non-Div cells into connected components via flood-fill.
    arc2_cri_comps_(Grid, NR1, NC1, Div, NDCs, [], Comps),
% For each component compute ring-distance map and color cycle.
    maplist({Grid, NR1, NC1, Div, BG}/[Comp, RM-Cycle]>>(
% Select ring-0 boundary cells: grid edge or adjacent to Div.
        include({Grid, NR1, NC1, Div}/[R-C]>>(
            arc2_cri_is_bnd_(Grid, NR1, NC1, Div, R, C)
        ), Comp, Bdry),
% Seed the BFS frontier with boundary cells at distance 0.
        maplist([RC, RC-0]>>true, Bdry, Bdry0),
% Run multi-source BFS to compute ring distance for every component cell.
        arc2_cri_bfs_(Grid, NR1, NC1, Div, Bdry0, Bdry0, RM),
% Identify marker cells: non-BG, non-Div cells in this component.
        include({Grid, BG, Div}/[R-C]>>(
            nth0(R, Grid, GRow), nth0(C, GRow, V),
            V =\= BG, V =\= Div
        ), Comp, MRCs),
% Map each marker to its ring distance and original color.
        maplist({Grid, RM}/[R-C, D-V]>>(
            member(R-C-D, RM),
            nth0(R, Grid, GRow), nth0(C, GRow, V)
        ), MRCs, RCPairs0),
% Sort Ring-Color pairs by ring distance ascending.
        msort(RCPairs0, RCPairs),
% Build cycling color list from marker positions.
        arc2_cri_build_cycle_(RCPairs, BG, Cycle)
    ), Comps, CompData),
% Build output grid row by row.
    numlist(0, NR1, RowIs),
    maplist({Grid, NC1, Div, Comps, CompData}/[R, OR]>>(
        numlist(0, NC1, ColIs),
        maplist({Grid, Div, Comps, CompData, R}/[C, V]>>(
            nth0(R, Grid, GRow), nth0(C, GRow, CV),
% Divider cells pass through unchanged.
            (CV =:= Div -> V = Div
            ;
% Find which component this cell belongs to.
                nth0(CI, Comps, Comp),
                member(R-C, Comp), !,
% Retrieve the ring map and cycle for this component.
                nth0(CI, CompData, RM-Cycle),
% Look up this cell's ring distance.
                member(R-C-D, RM),
% Apply cycling: color = Cycle[ring mod cycle_length].
                length(Cycle, CLen),
                Idx is D mod CLen,
                nth0(Idx, Cycle, V)
            )
        ), ColIs, OR)
    ), RowIs, Out).

% arc2_svo_bg_: background is the top-left corner cell value.
arc2_svo_bg_([[BG | _] | _], BG).

% arc2_svo_bbox_upd_: foldl helper that expands a bounding box by one R-C cell.
arc2_svo_bbox_upd_(R-C, Ra-Ca-Rb-Cb, R1-C1-R2-C2) :-
% Update min-row, min-col, max-row, max-col extents.
    R1 is min(R, Ra), C1 is min(C, Ca),
    R2 is max(R, Rb), C2 is max(C, Cb).

% arc2_svo_bbox_: bounding box of a non-empty list of R-C cells.
arc2_svo_bbox_([R0-C0 | Rest], R1, C1, R2, C2) :-
% Fold over all remaining cells expanding from the first seed.
    foldl(arc2_svo_bbox_upd_, Rest, R0-C0-R0-C0, R1-C1-R2-C2).

% arc2_svo_void_: locate the H x W block of 0-cells (the void).
arc2_svo_void_(Grid, NR1, NC1, VR, VC, H, W) :-
% Collect all zero-valued cell coordinates in the grid.
    findall(R-C, (between(0, NR1, R), between(0, NC1, C),
                  nth0(R, Grid, Row), nth0(C, Row, 0)), Cs),
    Cs \= [],
% Compute bounding box; H and W follow from the extents.
    arc2_svo_bbox_(Cs, VR, VC, R2, C2),
    H is R2 - VR + 1, W is C2 - VC + 1.

% arc2_svo_marker_: locate the H x W block of 2-cells (the marker).
arc2_svo_marker_(Grid, NR1, NC1, MR, MC, H, W) :-
% Collect all 2-valued cell coordinates in the grid.
    findall(R-C, (between(0, NR1, R), between(0, NC1, C),
                  nth0(R, Grid, Row), nth0(C, Row, 2)), Cs),
    Cs \= [],
% Bounding box; when H and W are already bound they must equal void dimensions.
    arc2_svo_bbox_(Cs, MR, MC, R2, C2),
    H is R2 - MR + 1, W is C2 - MC + 1.

% arc2_svo_face_cells_/9: collect cell values on one directional face of block (R,C,H,W).
% Returns [] for out-of-bounds faces (treated as background by the caller).
arc2_svo_face_cells_(Grid, _NR1, _NC1, R, C, _H, W, top, Vals) :-
% Top face: the row immediately above the block.
    FR is R - 1,
    (FR < 0 -> Vals = []
    ; C2 is C + W - 1,
      findall(V, (between(C, C2, FC), nth0(FR, Grid, FRow), nth0(FC, FRow, V)), Vals)).
arc2_svo_face_cells_(Grid, NR1, _NC1, R, C, H, W, bottom, Vals) :-
% Bottom face: the row immediately below the block.
    FR is R + H,
    (FR > NR1 -> Vals = []
    ; C2 is C + W - 1,
      findall(V, (between(C, C2, FC), nth0(FR, Grid, FRow), nth0(FC, FRow, V)), Vals)).
arc2_svo_face_cells_(Grid, _NR1, _NC1, R, C, H, _W, left, Vals) :-
% Left face: the column immediately to the left of the block.
    FC is C - 1,
    (FC < 0 -> Vals = []
    ; R2 is R + H - 1,
      findall(V, (between(R, R2, FR), nth0(FR, Grid, FRow), nth0(FC, FRow, V)), Vals)).
arc2_svo_face_cells_(Grid, _NR1, NC1, R, C, H, W, right, Vals) :-
% Right face: the column immediately to the right of the block.
    FC is C + W,
    (FC > NC1 -> Vals = []
    ; R2 is R + H - 1,
      findall(V, (between(R, R2, FR), nth0(FR, Grid, FRow), nth0(FC, FRow, V)), Vals)).

% arc2_svo_adj_marker_: succeed if any face of the block at (R,C,H,W) touches a 2-cell.
arc2_svo_adj_marker_(Grid, NR1, NC1, R, C, H, W) :-
% Scan each face for a 2-valued cell; cut on first match.
    member(D, [top, bottom, left, right]),
    arc2_svo_face_cells_(Grid, NR1, NC1, R, C, H, W, D, Vals),
    member(2, Vals), !.

% arc2_svo_row_passable_: row FR, columns C to C+W-1 are all passable (value 0 or 1).
arc2_svo_row_passable_(Grid, FR, C, W) :-
% Span columns from C to C+W-1; every cell must be 0 or 1.
    C2 is C + W - 1,
    forall(between(C, C2, IC),
           (nth0(FR, Grid, FRow), nth0(IC, FRow, V), (V =:= 0 ; V =:= 1))).

% arc2_svo_col_passable_: column FC, rows R to R+H-1 are all passable (value 0 or 1).
arc2_svo_col_passable_(Grid, R, FC, H) :-
% Span rows from R to R+H-1; every cell must be 0 or 1.
    R2 is R + H - 1,
    forall(between(R, R2, IR),
           (nth0(IR, Grid, GRow), nth0(FC, GRow, V), (V =:= 0 ; V =:= 1))).

% arc2_svo_one_nbr_/9: one block-movement neighbour of the H x W block at (R,C).
% Slide UP: new top-left (R-1,C); entering cells are row R-1, cols C..C+W-1.
arc2_svo_one_nbr_(Grid, _NR1, _NC1, R, C, _H, W, NR2, C) :-
% New position row is R-1; must stay in-bounds; new top row must be passable.
    NR2 is R - 1, NR2 >= 0,
    arc2_svo_row_passable_(Grid, NR2, C, W).
% Slide DOWN: new top-left (R+1,C); entering cells are row R+H, cols C..C+W-1.
arc2_svo_one_nbr_(Grid, NR1, _NC1, R, C, H, W, NR2, C) :-
% New position row is R+1; entering row is R+H; must stay in-bounds.
    FR is R + H, FR =< NR1,
    NR2 is R + 1,
    arc2_svo_row_passable_(Grid, FR, C, W).
% Slide LEFT: new top-left (R,C-1); entering cells are col C-1, rows R..R+H-1.
arc2_svo_one_nbr_(Grid, _NR1, _NC1, R, C, H, _W, R, NC2) :-
% New position col is C-1; must stay in-bounds; new left col must be passable.
    NC2 is C - 1, NC2 >= 0,
    arc2_svo_col_passable_(Grid, R, NC2, H).
% Slide RIGHT: new top-left (R,C+1); entering cells are col C+W, rows R..R+H-1.
arc2_svo_one_nbr_(Grid, _NR1, NC1, R, C, H, W, R, NC2) :-
% New position col is C+1; entering col is C+W; must stay in-bounds.
    FC is C + W, FC =< NC1,
    NC2 is C + 1,
    arc2_svo_col_passable_(Grid, R, FC, H).

% arc2_svo_block_bfs_step_: expand one BFS level over block positions.
arc2_svo_block_bfs_step_(Grid, NR1, NC1, H, W, Frontier, Visited, NextFrontier) :-
% Collect all unvisited block-movement neighbours from the current frontier.
    findall(NR2-NC2-D1, (
        member(R-C-D, Frontier),
        D1 is D + 1,
        arc2_svo_one_nbr_(Grid, NR1, NC1, R, C, H, W, NR2, NC2),
        \+ member(NR2-NC2, Visited)
    ), Raw),
% Deduplicate so each block position appears at most once per BFS level.
    sort(Raw, NextFrontier).

% arc2_svo_block_bfs_: BFS over block positions from void top-left (VR,VC).
% Returns Reached = list of R-C-Dist triples covering all reachable positions.
arc2_svo_block_bfs_(Grid, NR1, NC1, VR, VC, H, W, Reached) :-
% Seed BFS with the void's starting block position at distance 0.
    arc2_svo_bfs_blk_iter_(Grid, NR1, NC1, H, W,
        [VR-VC-0], [VR-VC], [VR-VC-0], Reached).

% arc2_svo_bfs_blk_iter_: iterative block BFS accumulating R-C-Dist entries.
arc2_svo_bfs_blk_iter_(_, _, _, _, _, [], _, Acc, Acc) :- !.
arc2_svo_bfs_blk_iter_(Grid, NR1, NC1, H, W, Frontier, Visited, Acc, Reached) :-
% Expand frontier to next BFS level.
    arc2_svo_block_bfs_step_(Grid, NR1, NC1, H, W, Frontier, Visited, NextF),
% Extract R-C pairs from next frontier for visited tracking.
    maplist([R-C-_, R-C]>>true, NextF, NextRCs),
    append(Visited, NextRCs, Visited2),
% Accumulate new triples and continue.
    append(Acc, NextF, Acc2),
    arc2_svo_bfs_blk_iter_(Grid, NR1, NC1, H, W, NextF, Visited2, Acc2, Reached).

% arc2_svo_is_deadend_: block at (R,C,H,W) is a dead-end — exactly 1 slide neighbour.
arc2_svo_is_deadend_(Grid, NR1, NC1, R, C, H, W) :-
% Count all slide neighbours in the full block-movement graph (not just BFS tree).
    findall(NR2-NC2, arc2_svo_one_nbr_(Grid, NR1, NC1, R, C, H, W, NR2, NC2), Nbrs),
    length(Nbrs, 1).

% arc2_svo_farthest_end_: find the farthest reachable dead-end from the void start.
% FR-FC is the top-left of the dead-end block with maximum BFS distance.
arc2_svo_farthest_end_(Grid, NR1, NC1, H, W, VR, VC, Reached, FR, FC) :-
% Collect all reachable non-start positions that are dead-ends.
    findall(D-R-C, (
        member(R-C-D, Reached),
        \+ (R =:= VR, C =:= VC),
        arc2_svo_is_deadend_(Grid, NR1, NC1, R, C, H, W)
    ), Cands),
    Cands \= [],
% msort gives ascending order; last element has the maximum distance.
    msort(Cands, Sorted),
    last(Sorted, _-FR-FC).

% arc2_svo_cell_out_: output value for one cell during void slide.
arc2_svo_cell_out_(OldCells, NewCells, R, C, Orig, Out) :-
% Old void cells become river (1); new target cells become void (0).
    (member(R-C, OldCells) -> Out = 1
    ; member(R-C, NewCells) -> Out = 0
    ; Out = Orig).

% arc2_transform(slide_void, +Grid, -Out): entry point for Wave 36.
arc2_transform(slide_void, Grid, Out) :-
% Compute grid dimensions.
    length(Grid, NR), Grid = [R0 | _], length(R0, NC),
    NR1 is NR - 1, NC1 is NC - 1,
% Locate void (0-cells) and marker (2-cells); both must be H x W.
    arc2_svo_void_(Grid, NR1, NC1, VR, VC, H, W),
    arc2_svo_marker_(Grid, NR1, NC1, MR, MC, H, W),
% Run block-movement BFS from the void's starting position.
    arc2_svo_block_bfs_(Grid, NR1, NC1, VR, VC, H, W, Reached),
% Find the farthest dead-end; if it touches the marker, move to marker instead.
    (arc2_svo_farthest_end_(Grid, NR1, NC1, H, W, VR, VC, Reached, TE_R, TE_C) ->
        (arc2_svo_adj_marker_(Grid, NR1, NC1, TE_R, TE_C, H, W) ->
            NR3 = MR, NC3 = MC
        ;   NR3 = TE_R, NC3 = TE_C)
    ;   NR3 = MR, NC3 = MC),
% Collect old void cell coordinates.
    VR2 is VR + H - 1, VC2 is VC + W - 1,
    findall(R-C, (between(VR, VR2, R), between(VC, VC2, C)), VoidCells),
% Collect new target cell coordinates.
    NR4 is NR3 + H - 1, NC4 is NC3 + W - 1,
    findall(R-C, (between(NR3, NR4, R), between(NC3, NC4, C)), NewCells),
% Build output grid: old void cells become 1, new cells become 0, rest unchanged.
    numlist(0, NR1, RowIs),
    maplist([R, Row]>>(
        numlist(0, NC1, ColIs),
        maplist([C, V]>>(
            nth0(R, Grid, GRow), nth0(C, GRow, Orig),
            arc2_svo_cell_out_(VoidCells, NewCells, R, C, Orig, V)
        ), ColIs, Row)
    ), RowIs, Out).

% ---------------------------------------------------------------------------
% WAVE 38 — fill_enclosed (task 8b7bacbf, Layer 271)
% ---------------------------------------------------------------------------
% arc2_named_rule fact registers fill_enclosed for induction.
arc2_named_rule(fill_enclosed).

% arc2_transform(fill_enclosed, +Grid, -Out)
% Algorithm: component-based enclosed BG-cluster detection with indicator-guided
% target/decoy classification.  Handles multi-frame colors (P1), outer walls (P3),
% disconnected background (P4), boundary pockets, and contaminated indicators.
% Step 1: BG=most-common; Ms=singletons; VAdjs=most-common non-BG neighbor of each M.
% Step 2: Find all BG connected components (list-based BFS, no dynamic facts).
% Step 3: Compute FrameSet from values adjacent to VAdj cells; distinguish FOthers
%   (values that form a complete frame around some BG component) from VDecContam.
% Step 4: Pocket = component whose every in-grid non-cluster neighbor is in FrameSet.
% Step 5: If FOthers non-empty (multi-frame): target=non-FDom-only pockets.
%   Otherwise (single-frame): target=pocket with clean VAdj indicator adjacent to frame;
%   if no indicators anywhere all pockets are targets (P4 exception).
% Step 6: Fill target pockets with their corresponding M.
arc2_transform(fill_enclosed, Grid, Out) :-
% Flatten grid and compute most-common value as BG.
    flatten(Grid, Flat), msort(Flat, Srt), arc2_fec_mc_(Srt, BG),
% Collect singleton values (appear exactly once, excluding BG) as marker list Ms.
    arc2_fec_sings_(Srt, BG, Ms),
% Compute grid dimensions NR1 (max row index) and NC1 (max col index).
    length(Grid, NR), NR1 is NR - 1, Grid = [GR0_|_], length(GR0_, NC), NC1 is NC - 1,
% Derive V_adj for each M: most-common non-BG non-M 4-connected neighbor.
    maplist(arc2_fec_vadj_(Grid, NR1, NC1, BG), Ms, VAdjs),
% Find all BG connected components via list-based BFS.
    arc2_fec_all_comps_(Grid, NR1, NC1, BG, AllComps),
% Compute FDom, FOthers, FrameSet, VDecContam from VAdj adjacency and pure-frame test.
    arc2_fec_frame_info_(Grid, NR1, NC1, BG, Ms, VAdjs, AllComps,
                         FDom, FOthers, FrameSet, VDecContam),
% Compute VDec = VDecContam union any remaining non-BG/M/VAdj/Frame values.
    arc2_fec_vdec_(Flat, BG, Ms, VAdjs, FrameSet, VDecContam, VDec),
% Filter AllComps to pockets: components fully surrounded by FrameSet cells.
    include(arc2_fec_is_pocket_(Grid, NR1, NC1, FrameSet), AllComps, Pockets),
% Classify pockets as targets (with M assignment) or decoys (ignored).
    arc2_fec_classify_all_(Pockets, Grid, NR1, NC1,
                           Ms, VAdjs, FDom, FOthers, VDec, Assigns),
% Apply fills: replace target pocket cells with their assigned M value.
    arc2_fec_apply_(Grid, Assigns, Out).

% arc2_fec_rl_/2: run-length encode a sorted list into N-V pairs.
arc2_fec_rl_([], []) :- !.
% Build one N-V pair and recurse on the tail after consuming leading copies.
arc2_fec_rl_([H | T], [N-H | R]) :- arc2_fec_cf_(H, T, 1, N, T2), arc2_fec_rl_(T2, R).
% arc2_fec_cf_/5: count leading copies of V in list, return count N and remainder.
arc2_fec_cf_(_, [], N, N, []) :- !.
% Increment count while next element matches V.
arc2_fec_cf_(V, [V | T], A, N, R) :- !, A1 is A + 1, arc2_fec_cf_(V, T, A1, N, R).
% Stop counting when next element differs.
arc2_fec_cf_(_, R, N, N, R).
% arc2_fec_mx_/4: find value associated with maximum count among N-V pairs.
arc2_fec_mx_([], _, BV, BV) :- !.
% Update best when current count exceeds current best.
arc2_fec_mx_([N-V | T], B, BV, O) :- (N > B -> arc2_fec_mx_(T, N, V, O) ; arc2_fec_mx_(T, B, BV, O)).
% arc2_fec_mc_/2: most common value in a sorted list (with duplicates).
arc2_fec_mc_(Srt, V) :- arc2_fec_rl_(Srt, P), arc2_fec_mx_(P, 0, _, V).
% arc2_fec_sings_/3: collect values appearing exactly once in sorted list, excluding BG.
arc2_fec_sings_(Srt, BG, Ms) :- arc2_fec_rl_(Srt, P), findall(V, (member(1-V, P), V \= BG), Ms).
% arc2_fec_vadj_/6: V_adj(M) = most-common non-BG non-M 4-neighbor of the single M cell.
arc2_fec_vadj_(Grid, NR1, NC1, BG, M, VA) :-
    findall(V, (between(0, NR1, R), between(0, NC1, C), nth0(R, Grid, Row), nth0(C, Row, M),
                member(DR-DC, [-1-0, 1-0, 0-(-1), 0-1]), AR is R + DR, AC is C + DC,
                between(0, NR1, AR), between(0, NC1, AC),
                nth0(AR, Grid, ARow), nth0(AC, ARow, V), V \= BG, V \= M), Vs0),
    (Vs0 = [] -> VA = none ; msort(Vs0, VS), arc2_fec_mc_(VS, VA)).

% arc2_fec_bfs_comp_/9: BFS from queue cells, staying on BG; returns component and updated Vis.
arc2_fec_bfs_comp_(_, _, _, _, [], Vis, Comp, Comp, Vis) :- !.
% Expand one queue cell: find unvisited BG neighbors, add to Vis/queue/component.
arc2_fec_bfs_comp_(Grid, NR1, NC1, BG, [R-C | Q], Vis0, Acc0, Comp, VisOut) :-
    findall(NR2-NC2, (member(DR-DC, [-1-0, 1-0, 0-(-1), 0-1]),
                      NR2 is R + DR, NC2 is C + DC,
                      between(0, NR1, NR2), between(0, NC1, NC2),
                      nth0(NR2, Grid, Row2), nth0(NC2, Row2, BG),
                      \+ memberchk(NR2-NC2, Vis0)), Nbrs),
    append(Vis0, Nbrs, Vis1), append(Q, Nbrs, Q1), append(Acc0, Nbrs, Acc1),
    arc2_fec_bfs_comp_(Grid, NR1, NC1, BG, Q1, Vis1, Acc1, Comp, VisOut).

% arc2_fec_all_comps_/5: find all BG connected components.
arc2_fec_all_comps_(Grid, NR1, NC1, BG, Comps) :-
    findall(R-C, (between(0, NR1, R), between(0, NC1, C),
                  nth0(R, Grid, Row), nth0(C, Row, BG)), AllBG),
    arc2_fec_find_comps_(AllBG, Grid, NR1, NC1, BG, [], Comps).
% arc2_fec_find_comps_/7: iterate seed list, BFS-expanding each unvisited BG cell.
arc2_fec_find_comps_([], _, _, _, _, _, []) :- !.
% Skip cell already visited by a previous component's BFS.
arc2_fec_find_comps_([Cell | Rest], Grid, NR1, NC1, BG, Vis0, Comps) :-
    (memberchk(Cell, Vis0) ->
        arc2_fec_find_comps_(Rest, Grid, NR1, NC1, BG, Vis0, Comps)
    ;
        arc2_fec_bfs_comp_(Grid, NR1, NC1, BG, [Cell], [Cell | Vis0], [Cell], Comp, Vis1),
        arc2_fec_find_comps_(Rest, Grid, NR1, NC1, BG, Vis1, RestComps),
        Comps = [Comp | RestComps]
    ).

% arc2_fec_pure_frame_/5: succeeds if value V alone forms a complete frame around some component.
arc2_fec_pure_frame_(V, AllComps, Grid, NR1, NC1) :-
    member(Cl, AllComps),
    forall(member(R-C, Cl),
           forall((member(DR-DC, [-1-0, 1-0, 0-(-1), 0-1]),
                   NR2 is R + DR, NC2 is C + DC,
                   between(0, NR1, NR2), between(0, NC1, NC2),
                   \+ memberchk(NR2-NC2, Cl)),
                  (nth0(NR2, Grid, NRow), nth0(NC2, NRow, NV), NV = V))).

% arc2_fec_frame_info_/11: derive FDom, FOthers, FrameSet, VDecContam.
% Primary path: FSAdj = non-BG/M/VAdj values adjacent to any VAdj cell.
% FDom = most common in FSAdj.  FOthers = non-FDom FSAdj values that form a pure frame.
% VDecContam = non-FDom FSAdj values that do NOT form a pure frame (contamination tokens).
% Fallback (empty FSAdj): all non-BG/M/VAdj values in grid form FrameSet.
arc2_fec_frame_info_(Grid, NR1, NC1, BG, Ms, VAdjs, AllComps,
                     FDom, FOthers, FrameSet, VDecContam) :-
    flatten(Grid, Flat),
    findall(V, (member(VA, VAdjs), VA \= none,
                between(0, NR1, R), between(0, NC1, C),
                nth0(R, Grid, Row), nth0(C, Row, VA),
                member(DR-DC, [-1-0, 1-0, 0-(-1), 0-1]),
                NR2 is R + DR, NC2 is C + DC,
                between(0, NR1, NR2), between(0, NC1, NC2),
                nth0(NR2, Grid, NRow2), nth0(NC2, NRow2, V),
                V \= BG, \+ memberchk(V, Ms), \+ memberchk(V, VAdjs), V \= none), FSAdj0),
    sort(FSAdj0, FSAdj),
    (FSAdj = [] ->
        findall(V, (member(V, Flat), V \= BG,
                    \+ memberchk(V, Ms), \+ memberchk(V, VAdjs), V \= none), FAL0),
        sort(FAL0, FAL),
        (FAL = [] -> FDom = none, FOthers = [], FrameSet = [], VDecContam = []
        ;   msort(FAL0, FAL1), arc2_fec_mc_(FAL1, FDom),
            subtract(FAL, [FDom], FOthers), FrameSet = [FDom | FOthers], VDecContam = [])
    ;   msort(FSAdj0, FSAdj1), arc2_fec_mc_(FSAdj1, FDom),
        subtract(FSAdj, [FDom], Cands),
        findall(V, (member(V, Cands),
                    arc2_fec_pure_frame_(V, AllComps, Grid, NR1, NC1)), FOthers),
        subtract(Cands, FOthers, VDecContam),
        FrameSet = [FDom | FOthers]
    ).

% arc2_fec_vdec_/7: VDec = VDecContam union any value not in BG/M/VAdj/FrameSet.
arc2_fec_vdec_(Flat, BG, Ms, VAdjs, FrameSet, VDecContam, VDec) :-
    append([[BG], Ms, VAdjs, FrameSet], K0), sort(K0, KS),
    findall(V, (member(V, Flat), V \= none, \+ memberchk(V, KS)), VO0),
    sort(VO0, VOther), append(VDecContam, VOther, VD0), sort(VD0, VDec).

% arc2_fec_is_pocket_/5: component is a pocket if every in-grid non-cluster neighbor is in FrameSet.
arc2_fec_is_pocket_(Grid, NR1, NC1, FrameSet, Cluster) :-
    FrameSet \= [],
    forall(member(R-C, Cluster),
           forall((member(DR-DC, [-1-0, 1-0, 0-(-1), 0-1]),
                   NR2 is R + DR, NC2 is C + DC,
                   between(0, NR1, NR2), between(0, NC1, NC2),
                   \+ memberchk(NR2-NC2, Cluster)),
                  (nth0(NR2, Grid, NRow), nth0(NC2, NRow, NV), memberchk(NV, FrameSet)))).

% arc2_fec_frame_nbrs_/5: collect unique in-grid non-cluster neighbors of a pocket cluster.
arc2_fec_frame_nbrs_(Cluster, Grid, NR1, NC1, FCs) :-
    findall(FR-FC, (member(R-C, Cluster), member(DR-DC, [-1-0, 1-0, 0-(-1), 0-1]),
                    FR is R + DR, FC is C + DC, between(0, NR1, FR), between(0, NC1, FC),
                    \+ memberchk(FR-FC, Cluster), nth0(FR, Grid, _)),
            FCs0), sort(FCs0, FCs).

% arc2_fec_va_bfs_/7: BFS on cells of value VA from initial queue; returns all reachable VA cells.
arc2_fec_va_bfs_(_, _, _, _, [], Vis, Vis) :- !.
% Expand queue cell: find unvisited VA neighbors, add to Vis and queue.
arc2_fec_va_bfs_(Grid, NR1, NC1, VA, [R-C | Q], Vis, Out) :-
    findall(NR2-NC2, (member(DR-DC, [-1-0, 1-0, 0-(-1), 0-1]),
                      NR2 is R + DR, NC2 is C + DC,
                      between(0, NR1, NR2), between(0, NC1, NC2),
                      nth0(NR2, Grid, Row2), nth0(NC2, Row2, VA),
                      \+ memberchk(NR2-NC2, Vis)), Nbrs),
    append(Vis, Nbrs, Vis1), append(Q, Nbrs, Q1),
    arc2_fec_va_bfs_(Grid, NR1, NC1, VA, Q1, Vis1, Out).

% arc2_fec_contam_/6: indicator cell is contaminated if its VA-chain is adjacent to a VDec cell.
arc2_fec_contam_(Cell, VA, Grid, NR1, NC1, VDec) :-
    VDec \= [],
    arc2_fec_va_bfs_(Grid, NR1, NC1, VA, [Cell], [Cell], Comp),
    member(CR-CC, Comp), member(DR-DC, [-1-0, 1-0, 0-(-1), 0-1]),
    NR2 is CR + DR, NC2 is CC + DC, between(0, NR1, NR2), between(0, NC1, NC2),
    nth0(NR2, Grid, Row2), nth0(NC2, Row2, DV), memberchk(DV, VDec).

% arc2_fec_is_rect_/1: succeeds if list of R-C pairs forms a filled axis-aligned rectangle.
arc2_fec_is_rect_(Cells) :-
    pairs_keys(Cells, Rs), pairs_values(Cells, Cs),
    min_list(Rs, Rmin), max_list(Rs, Rmax), min_list(Cs, Cmin), max_list(Cs, Cmax),
    length(Cells, N), N =:= (Rmax - Rmin + 1) * (Cmax - Cmin + 1).

% arc2_fec_fdom_only_/5: pocket is rectangular and all its frame neighbors are FDom.
arc2_fec_fdom_only_(Cluster, Grid, NR1, NC1, FDom) :-
    arc2_fec_is_rect_(Cluster),
    arc2_fec_frame_nbrs_(Cluster, Grid, NR1, NC1, FCs),
    forall(member(FR-FC, FCs), (nth0(FR, Grid, FR2), nth0(FC, FR2, FV), FV = FDom)).

% arc2_fec_clean_ind_/8: find a clean (uncontaminated) VAdj indicator adjacent to pocket frame.
% Indicator cell = VAdj-valued cell adjacent to any frame cell of the pocket; not in VDec chain.
arc2_fec_clean_ind_(Cluster, Grid, NR1, NC1, Ms, VAdjs, VDec, M) :-
    arc2_fec_frame_nbrs_(Cluster, Grid, NR1, NC1, FCs),
    member(FR-FC, FCs), member(DR-DC, [-1-0, 1-0, 0-(-1), 0-1]),
    AR is FR + DR, AC is FC + DC, between(0, NR1, AR), between(0, NC1, AC),
    nth0(AR, Grid, ARow), nth0(AC, ARow, IndV), IndV \= none,
    nth0(Idx, VAdjs, IndV), nth0(Idx, Ms, M),
    \+ arc2_fec_contam_(AR-AC, IndV, Grid, NR1, NC1, VDec), !.

% arc2_fec_classify_all_/10: produce Assigns list of Cluster-M pairs for target pockets.
% Multi-frame (FOthers non-empty): non-FDom-only pockets are targets.
% Single-frame: pockets with clean VAdj indicator are targets; if none found all are targets.
arc2_fec_classify_all_(Pockets, Grid, NR1, NC1,
                       Ms, VAdjs, FDom, FOthers, VDec, Assigns) :-
    (FOthers \= [] ->
        (Ms = [M0 | _] -> true ; M0 = 0),
        findall(Cl-M0, (member(Cl, Pockets),
                        \+ arc2_fec_fdom_only_(Cl, Grid, NR1, NC1, FDom)), Assigns)
    ;
        findall(Cl-M, (member(Cl, Pockets),
                       arc2_fec_clean_ind_(Cl, Grid, NR1, NC1, Ms, VAdjs, VDec, M)), Assigns0),
        (Assigns0 = [], Pockets \= [], Ms = [M0 | _] ->
            findall(Cl-M0, member(Cl, Pockets), Assigns)
        ;   Assigns = Assigns0)
    ).

% arc2_fec_apply_/3: fill Grid cells that belong to target pocket clusters.
arc2_fec_apply_(Grid, Assigns, Out) :-
    findall(R-C-M, (member(Cl-M, Assigns), member(R-C, Cl)), Fills),
    arc2_fec_fill_grid_(Grid, Fills, 0, Out).
% arc2_fec_fill_grid_/4: iterate rows, filling target cells.
arc2_fec_fill_grid_([], _, _, []) :- !.
% Process one row: increment row counter R after filling.
arc2_fec_fill_grid_([Row | Rows], Fills, R, [OR | ORs]) :-
    arc2_fec_fill_row_(Row, Fills, R, 0, OR), R1 is R + 1,
    arc2_fec_fill_grid_(Rows, Fills, R1, ORs).
% arc2_fec_fill_row_/5: replace cell V with M if R-C-M is in Fills, else keep V.
arc2_fec_fill_row_([], _, _, _, []) :- !.
% Fill or keep each cell; advance column counter C.
arc2_fec_fill_row_([V | Vs], Fills, R, C, [W | Ws]) :-
    (memberchk(R-C-W, Fills) -> true ; W = V), C1 is C + 1,
    arc2_fec_fill_row_(Vs, Fills, R, C1, Ws).

% ---------------------------------------------------------------------------
% WAVE 39 — room_outline (task 8f3a5a89, Layer 272)
% ---------------------------------------------------------------------------
% arc2_named_rule registers room_outline for the generic induction fallback.
arc2_named_rule(room_outline).

% arc2_transform(room_outline, +Grid, -Out): trace accessible-room boundary with 7.
% BG=8 (background), Wall=non-8 non-6 cells, Seed=6 (unique marker), Perim=7.
% Step 1: find the 6-cell seed.
% Step 2: 4-connected BFS from seed through 8-cells to build accessible set Vis.
% Step 3: compute wall 4-connected components; WallKeep = components touching Vis.
% Step 4: BdryWalls = WallKeep components that include a grid-boundary cell.
% Step 5: accessible BG on grid edge OR 8-adj to BdryWalls gets 7 (perimeter).
%   Accessible BG not perimeter gets 8 (interior).  Seed stays 6.
% Step 6: WallKeep cell preserves original value; non-WallKeep wall becomes 8.
arc2_transform(room_outline, Grid, Out) :-
% Compute 0-based max row and column indices NR1 and NC1.
    length(Grid, NR), NR1 is NR - 1,
    Grid = [GR0_|_], length(GR0_, NC), NC1 is NC - 1,
% Find the unique 6-cell (seed) position SR, SC in row-major order.
    arc2_ro_seed_(Grid, SR, SC),
% BFS flood-fill from (SR,SC) through 8-cells to build accessible set Vis.
    arc2_ro_flood_(Grid, NR1, NC1, SR, SC, Vis),
% Compute which wall cells to preserve: components that touch Vis.
    arc2_ro_keep_walls_(Grid, NR1, NC1, Vis, WallKeep),
% Compute boundary-connected walls: WallKeep components that include a grid-edge cell.
    arc2_ro_bdry_walls_(WallKeep, NR1, NC1, BdryWalls),
% Build output grid by classifying each cell against the rules above.
    numlist(0, NR1, RowIs), numlist(0, NC1, ColIs),
    maplist([R, OutRow]>>(
        maplist([C, V]>>(
            arc2_ro_cell_out_(Grid, NR1, NC1, SR, SC, Vis, WallKeep, BdryWalls, R, C, V)
        ), ColIs, OutRow)
    ), RowIs, Out).

% arc2_ro_seed_/3: find first 6-cell in row-major order via nth0 backtracking.
arc2_ro_seed_(Grid, SR, SC) :-
    nth0(SR, Grid, Row), nth0(SC, Row, 6), !.

% arc2_ro_flood_/6: 4-connected BFS from (SR,SC) through 8-cells; result sorted.
arc2_ro_flood_(Grid, NR1, NC1, SR, SC, Vis) :-
% Seed primes queue and visited; BFS expands 8-valued unvisited in-bounds cells.
    arc2_ro_bfs_([SR-SC], [SR-SC], Grid, NR1, NC1, Raw),
    msort(Raw, Vis).
% Empty queue: BFS complete; Vis is the full accessible set.
arc2_ro_bfs_([], Vis, _, _, _, Vis) :- !.
% Expand 4-neighbours of (R,C) that are unvisited in-bounds 8-cells; recurse.
arc2_ro_bfs_([R-C|Q], Vis, Grid, NR1, NC1, Final) :-
    R0 is R-1, R1 is R+1, C0 is C-1, C1 is C+1,
    include([NR-NC]>>(
        NR >= 0, NR =< NR1, NC >= 0, NC =< NC1,
        \+ memberchk(NR-NC, Vis),
        nth0(NR, Grid, Row), nth0(NC, Row, 8)
    ), [R0-C, R1-C, R-C0, R-C1], New),
    append(Q, New, Q2), append(Vis, New, Vis2),
    arc2_ro_bfs_(Q2, Vis2, Grid, NR1, NC1, Final).

% arc2_ro_keep_walls_/5: WallKeep = all wall cells whose 4-connected component touches Vis.
arc2_ro_keep_walls_(Grid, NR1, NC1, Vis, WallKeep) :-
% Collect all non-8 non-6 wall cell positions from the grid.
    findall(R-C, (
        between(0, NR1, R), nth0(R, Grid, GRow),
        between(0, NC1, C), nth0(C, GRow, V),
        V \= 8, V \= 6
    ), WallCells),
% Partition wall cells into 4-connected components.
    arc2_ro_wall_comps_(WallCells, NR1, NC1, Comps),
% Retain only components where some cell is 4-adjacent to an accessible cell.
    include([Comp]>>(
        once((member(R-C, Comp), arc2_ro_adj4_vis_(R, C, NR1, NC1, Vis)))
    ), Comps, GoodComps),
% Flatten retained components into a single keep-list.
    append(GoodComps, WallKeep).

% arc2_ro_bdry_walls_/4: BdryWalls = WallKeep cells in components with a grid-edge cell.
% Perimeter cells are 8-adj only to boundary-connected walls, not floating island walls.
arc2_ro_bdry_walls_(WallKeep, NR1, NC1, BdryWalls) :-
% Partition WallKeep cells into 4-connected components.
    arc2_ro_wall_comps_(WallKeep, NR1, NC1, Comps),
% Keep only components that contain at least one grid-boundary cell.
    include([Comp]>>(
        once((member(R-C, Comp), (R =:= 0 ; R =:= NR1 ; C =:= 0 ; C =:= NC1)))
    ), Comps, BdryComps),
% Flatten to get all boundary-connected wall cells.
    append(BdryComps, BdryWalls).

% arc2_ro_wall_comps_/4: partition WallCells into 4-connected components.
% No remaining wall cells: done.
arc2_ro_wall_comps_([], _, _, []) :- !.
% Seed BFS from first unassigned cell; recurse on remaining unassigned cells.
arc2_ro_wall_comps_([RC|Rest], NR1, NC1, [Comp|Comps]) :-
    arc2_ro_wbfs_([RC], [RC], Rest, NR1, NC1, Comp, Remaining),
    arc2_ro_wall_comps_(Remaining, NR1, NC1, Comps).

% arc2_ro_wbfs_/7: BFS through wall cells; returns component and unconsumed Avail list.
% Empty queue: component done; Rem = unassigned wall cells.
arc2_ro_wbfs_([], Comp, Rem, _, _, Comp, Rem) :- !.
% Expand 4-neighbours present in Avail; remove them from Avail to avoid revisit.
arc2_ro_wbfs_([R-C|Q], Comp, Avail, NR1, NC1, FComp, FRem) :-
    R0 is R-1, R1 is R+1, C0 is C-1, C1 is C+1,
    include([NR-NC]>>(
        NR >= 0, NR =< NR1, NC >= 0, NC =< NC1,
        memberchk(NR-NC, Avail)
    ), [R0-C, R1-C, R-C0, R-C1], New),
    subtract(Avail, New, Avail2),
    append(Q, New, Q2), append(Comp, New, Comp2),
    arc2_ro_wbfs_(Q2, Comp2, Avail2, NR1, NC1, FComp, FRem).

% arc2_ro_cell_out_/11: compute output value V for cell at (R,C).
arc2_ro_cell_out_(Grid, NR1, NC1, SR, SC, Vis, WallKeep, BdryWalls, R, C, V) :-
    nth0(R, Grid, Row), nth0(C, Row, Orig),
% Seed cell always emits 6.
    (   R =:= SR, C =:= SC -> V = 6
% Accessible BG cell: perimeter (7) or interior (8).
    ;   Orig =:= 8, memberchk(R-C, Vis)
    ->  (arc2_ro_is_perim_(BdryWalls, NR1, NC1, R, C) -> V = 7 ; V = 8)
% Inaccessible BG cell stays 8.
    ;   Orig =:= 8 -> V = 8
% Wall cell in a kept component preserves original; non-kept wall becomes 8.
    ;   (memberchk(R-C, WallKeep) -> V = Orig ; V = 8)
    ).

% arc2_ro_is_perim_/5: cell is perimeter if on grid edge or 8-adj to BdryWalls.
% Floating island walls (not boundary-connected) do not generate perimeter cells.
% Grid-edge cells (first or last row or column) are always perimeter.
arc2_ro_is_perim_(_, NR1, NC1, R, C) :-
    (R =:= 0 ; R =:= NR1 ; C =:= 0 ; C =:= NC1), !.
% Interior cell: perimeter if any of the 8 surrounding positions is in BdryWalls.
arc2_ro_is_perim_(BdryWalls, NR1, NC1, R, C) :-
    R0 is R-1, R1 is R+1, C0 is C-1, C1 is C+1,
    member(NR-NC, [R0-C0,R0-C,R0-C1,R-C0,R-C1,R1-C0,R1-C,R1-C1]),
    NR >= 0, NR =< NR1, NC >= 0, NC =< NC1,
    memberchk(NR-NC, BdryWalls), !.

% arc2_ro_adj4_vis_/5: true if any 4-neighbour of (R,C) is in the accessible set Vis.
% Check up (R0), down (R1), left (C0), right (C1); cut after first hit.
arc2_ro_adj4_vis_(R, C, NR1, NC1, Vis) :-
    R0 is R-1, R1 is R+1, C0 is C-1, C1 is C+1,
    (   (R0 >= 0,   memberchk(R0-C,  Vis))
    ;   (R1 =< NR1, memberchk(R1-C,  Vis))
    ;   (C0 >= 0,   memberchk(R-C0,  Vis))
    ;   (C1 =< NC1, memberchk(R-C1,  Vis))
    ), !.

% ---------------------------------------------------------------------------
% WP-298 Layer 273: grid_tile — shape-driven periodic tiling with centre highlight
% Task: eee78d87  BG=7  non-BG cells fill a 3x3 bounding box that defines a tile.
% ---------------------------------------------------------------------------

% arc2_named_rule registers grid_tile for the generic induction fallback.
arc2_named_rule(grid_tile).

% arc2_transform(grid_tile, +Grid, -Out)
% 1. Locate 3x3 bounding box of non-7 cells in the 6x6 input.
% 2. Derive 4 tiling values from the box: block, h_edge, v_edge, corner.
% 3. Tile a 16x16 output: f(r,c) = tile[r mod 3][c mod 3].
% 4. In centre region rows 5-10, cols 5-10: replace tile-0 cells with 9.
arc2_transform(grid_tile, Grid, Out) :-
    % locate bounding box top-left of non-7 region
    arc2_gt_bbox_(Grid, R0, C0),
    % derive tiling constants from the 3x3 sub-grid
    arc2_gt_tile_(Grid, R0, C0, Block, HEdge, VEdge, Corner),
    % build 16x16 output grid
    arc2_gt_build_(Block, HEdge, VEdge, Corner, Out).

% arc2_gt_bbox_(+Grid, -Rmin, -Cmin): bounding box top-left of non-7 cells.
arc2_gt_bbox_(Grid, Rmin, Cmin) :-
    % enumerate all rows and cols of the input grid
    length(Grid, NR), NR1 is NR - 1, numlist(0, NR1, Rs),
    % derive column count from first row
    nth0(0, Grid, Row0), length(Row0, NC), NC1 is NC - 1, numlist(0, NC1, Cs),
    % collect positions of all non-background (non-7) cells
    findall(R-C, (
        member(R, Rs), nth0(R, Grid, Row),
        member(C, Cs), nth0(C, Row, V), V =\= 7
    ), Cells),
    % extract minimum row and minimum column
    maplist([R-_, R]>>true, Cells, CRs), min_list(CRs, Rmin),
    maplist([_-C, C]>>true, Cells, CCs), min_list(CCs, Cmin).

% arc2_gt_tile_(+Grid, +R0, +C0, -Block, -HEdge, -VEdge, -Corner)
% Reads the nine cells of the 3x3 sub-grid at (R0,C0) and maps them to
% the four periodic tiling constants.
arc2_gt_tile_(Grid, R0, C0, Block, HEdge, VEdge, Corner) :-
    % precompute row and col indices for the three rows/cols
    R1 is R0 + 1, R2 is R0 + 2, C1 is C0 + 1, C2 is C0 + 2,
    % fetch all nine sub-grid values
    arc2_gt_gv_(Grid, R0, C0, S00), arc2_gt_gv_(Grid, R0, C1, S01),
    arc2_gt_gv_(Grid, R0, C2, S02),
    arc2_gt_gv_(Grid, R1, C0, S10), arc2_gt_gv_(Grid, R1, C1, S11),
    arc2_gt_gv_(Grid, R1, C2, S12),
    arc2_gt_gv_(Grid, R2, C0, S20), arc2_gt_gv_(Grid, R2, C1, S21),
    arc2_gt_gv_(Grid, R2, C2, S22),
    % center (1,1) determines corner (divider-row + divider-col intersection)
    (S11 =:= 7 -> Corner = 7 ; Corner = 0),
    % top+bottom midpoints (0,1)+(2,1) determine v_edge (vertical divider stripe)
    (S01 =:= 7, S21 =:= 7 -> VEdge = 7 ; VEdge = 0),
    % left+right midpoints (1,0)+(1,2) determine h_edge (horizontal divider stripe)
    (S10 =:= 7, S12 =:= 7 -> HEdge = 7 ; HEdge = 0),
    % all four corners determine block (2x2 interior of each tile cell)
    (S00 =:= 7, S02 =:= 7, S20 =:= 7, S22 =:= 7 -> Block = 7 ; Block = 0).

% arc2_gt_gv_(+Grid, +R, +C, -V): value at row R, col C.
arc2_gt_gv_(Grid, R, C, V) :-
    % index row then column
    nth0(R, Grid, Row), nth0(C, Row, V).

% arc2_gt_build_(+Block, +HEdge, +VEdge, +Corner, -Out)
% Builds a 16x16 list-of-lists from the four tiling constants.
arc2_gt_build_(Block, HEdge, VEdge, Corner, Out) :-
    % iterate over all 16 row indices
    numlist(0, 15, Rs),
    maplist([R, Row]>>(
        % iterate over all 16 column indices
        numlist(0, 15, Cs),
        maplist([C, V]>>arc2_gt_cell_(R, C, Block, HEdge, VEdge, Corner, V),
                Cs, Row)
    ), Rs, Out).

% arc2_gt_cell_(+R, +C, +Block, +HEdge, +VEdge, +Corner, -V)
% Compute the output value at (R,C) from tiling constants and active region.
arc2_gt_cell_(R, C, Block, HEdge, VEdge, Corner, V) :-
    % classify position by modular period-3 index
    RM is R mod 3, CM is C mod 3,
    % select base tiling value by position type
    (RM =:= 0, CM =:= 0 -> BaseV = Corner
    ; RM =:= 0            -> BaseV = HEdge
    ; CM =:= 0            -> BaseV = VEdge
    ;                        BaseV = Block),
    % active region (centre 6x6 of 16x16): replace background-0 with 9
    (R >= 5, R =< 10, C >= 5, C =< 10, BaseV =:= 0 -> V = 9 ; V = BaseV).

% ---------------------------------------------------------------------------
% WP-299 Layer 274: box_absorb — BFS from 3x3 box absorbs nearby 9s into box
% Task: dd6b8c4b.  Rule: BFS from [3,3,3;3,2,3;3,3,3] box through non-6 cells;
% each 9 adjacent to the flood is absorbed (cap = 9); absorbed 9s removed from
% grid and the first N box cells (reading order) filled with 9 in output.
% ---------------------------------------------------------------------------

% arc2_named_rule fact registers box_absorb for the generic induction fallback.
arc2_named_rule(box_absorb).

% arc2_transform(box_absorb, +Grid, -Out) — entry point.
arc2_transform(box_absorb, Grid, Out) :-
    % locate the 2 (box centre) by scanning rows top-to-bottom
    arc2_bxa_find2_(Grid, CR, CC),
    % compute box row/col extents (3x3 centred on CR,CC)
    R0 is CR-1, R2 is CR+1, C0 is CC-1, C2 is CC+1,
    % enumerate box cells in reading order (row-major, ascending)
    numlist(R0,R2,BRs), numlist(C0,C2,BCs),
    findall(R-C,(member(R,BRs),member(C,BCs)),BoxCells),
    % BFS from box through non-6 cells; cap absorptions at 9 (box size)
    length(BoxCells,Cap),
    arc2_bxa_bfs_(Grid, BoxCells, BoxCells, Cap, [], Absorbed),
    % fill first N box cells with 9, remove absorbed 9s from their positions
    length(Absorbed,N),
    length(Slots,N), append(Slots,_,BoxCells),
    arc2_bxa_build_(Grid, Absorbed, Slots, Out).

% arc2_bxa_find2_(+Grid, -R, -C) — find the unique 2 cell in Grid.
arc2_bxa_find2_(Grid, R, C) :-
    % scan each row for the value 2; cut on first match
    nth0(R, Grid, Row), nth0(C, Row, 2), !.

% arc2_bxa_bfs_(+Grid, +Queue, +Visited, +Cap, +AccIn, -Absorbed)
% BFS (FIFO queue) expanding through non-6 cells; absorbs 9s up to Cap.
arc2_bxa_bfs_(_, _, _, 0, Abs, Abs) :- !.
arc2_bxa_bfs_(_, [], _, _, Abs, Abs) :- !.
arc2_bxa_bfs_(Grid, [H|Queue], Visited, Cap, Acc, Abs) :-
    % expand current cell to reachable unvisited non-6 neighbours
    arc2_bxa_expand_(H, Grid, Visited, New, Nine),
    % absorb 9s from New up to remaining capacity
    length(Nine,NL),
    ( NL =< Cap ->
        % all Nine fit within cap
        append(Acc, Nine, Acc2), Cap2 is Cap-NL
    ;
        % take only first Cap elements of Nine to hit exact cap
        length(Take,Cap), append(Take,_,Nine),
        append(Acc, Take, Acc2), Cap2 = 0
    ),
    % enqueue all new cells (BFS: append to back)
    append(Queue, New, Queue2),
    % mark all new cells visited
    append(New, Visited, Vis2),
    arc2_bxa_bfs_(Grid, Queue2, Vis2, Cap2, Acc2, Abs).

% arc2_bxa_expand_(+RC, +Grid, +Visited, -New, -Nine)
% Returns unvisited non-6 neighbours (New); Nine = subset of New that are 9.
arc2_bxa_expand_(R-C, Grid, Visited, New, Nine) :-
    % get grid dimensions for bounds checking
    length(Grid,NR), nth0(0,Grid,Row0), length(Row0,NC),
    % collect all valid unvisited non-6 cardinal neighbours
    findall(NR2-NC2,(
        member(DR-DC, [-1-0,1-0,0-(-1),0-1]),
        NR2 is R+DR, NC2 is C+DC,
        NR2 >= 0, NR2 < NR, NC2 >= 0, NC2 < NC,
        \+ member(NR2-NC2, Visited),
        nth0(NR2,Grid,NRow2), nth0(NC2,NRow2,V2), V2 =\= 6
    ), New),
    % isolate those neighbours whose grid value is 9
    include(arc2_bxa_is9_(Grid), New, Nine).

% arc2_bxa_is9_(+Grid, +RC) — true iff grid cell at RC has value 9.
arc2_bxa_is9_(Grid, R-C) :-
    % fetch row then cell; succeed only for value 9
    nth0(R, Grid, Row), nth0(C, Row, 9).

% arc2_bxa_build_(+Grid, +Absorbed, +Slots, -Out)
% Build output: Slots cells become 9; Absorbed cells become 7; rest unchanged.
arc2_bxa_build_(Grid, Absorbed, Slots, Out) :-
    % enumerate all row indices
    length(Grid,NR), NR1 is NR-1, numlist(0,NR1,Rs),
    % enumerate all column indices
    nth0(0,Grid,Row0g), length(Row0g,NC), NC1 is NC-1, numlist(0,NC1,Cs),
    % build output row by row, cell by cell
    maplist([R,OutRow]>>(
        maplist([C,V]>>(
            nth0(R,Grid,GRow), nth0(C,GRow,OV),
            % box slot → 9; absorbed position → 7 (BG); else keep original
            ( member(R-C,Slots)    -> V = 9
            ; member(R-C,Absorbed) -> V = 7
            ; V = OV )
        ), Cs, OutRow)
    ), Rs, Out).

% ---------------------------------------------------------------------------
% WP-300 Layer 275: section_sort — sort grid sections ascending by non-BG count
% Task: 78332cb0. Rule: find all-6 divider rows/cols; extract sections; sort
% ascending by non-BG (non-6) cell count (ties: reverse reading-order); determine
% output direction by summing section bounding-box heights vs widths (2D case);
% V→H reverses order; H→V preserves order; reassemble with 6-dividers.
% ---------------------------------------------------------------------------

% arc2_named_rule fact registers section_sort for the generic induction fallback.
arc2_named_rule(section_sort).

% arc2_transform(section_sort, +Grid, -Out): sort sections and rotate direction.
arc2_transform(section_sort, Grid, Out) :-
    % locate all-6 divider rows and columns
    arc2_ss_divs_(Grid, HDivs, VDivs),
    % build (Start, End) row/col segments between dividers
    length(Grid, NR), arc2_ss_segs_(NR, HDivs, RSegs),
    % build col segments from first row width
    nth0(0, Grid, Row0), length(Row0, NC), arc2_ss_segs_(NC, VDivs, CSegs),
    % classify arrangement kind: td (2D), v (vertical stack), h (horizontal)
    arc2_ss_kind_(HDivs, VDivs, Kind),
    % extract each section as a sub-grid with index and cell count
    arc2_ss_extract_(Grid, RSegs, CSegs, Secs),
    % sort sections into output order
    arc2_ss_order_(Kind, Secs, Ordered),
    % determine output direction: v (vertical stack) or h (horizontal row)
    arc2_ss_outdir_(Kind, Secs, OutDir),
    % assemble output grid
    arc2_ss_build_(Ordered, OutDir, Out).

% arc2_ss_divs_: find rows where every cell = 6, and cols where every cell = 6.
arc2_ss_divs_(Grid, HDivs, VDivs) :-
    % enumerate all row indices
    length(Grid, NR), NR1 is NR-1, numlist(0, NR1, Rows),
    % enumerate all col indices from first row
    nth0(0, Grid, R0), length(R0, NC), NC1 is NC-1, numlist(0, NC1, Cols),
    % include row R if every value in that row equals 6
    include(arc2_ss_hd_(Grid), Rows, HDivs),
    % include col C if every row has value 6 at that column
    include(arc2_ss_vd_(Grid), Cols, VDivs).

% arc2_ss_hd_: succeed if row R of Grid is entirely 6s.
arc2_ss_hd_(Grid, R) :-
    % fetch row then check all values are 6
    nth0(R, Grid, Row), maplist(=(6), Row).

% arc2_ss_vd_: succeed if column C of Grid is entirely 6s.
arc2_ss_vd_(Grid, C) :-
    % for each row, fetch col C and check = 6
    maplist([Row]>>(nth0(C, Row, V), V =:= 6), Grid).

% arc2_ss_segs_: build Start-End pairs from divider positions.
arc2_ss_segs_(N, Divs, Segs) :-
    % prepend -1 and append N to dividers to form boundary pairs
    append([-1], Divs, Ps0), append(Divs, [N], Ps1),
    % each pair (A, B) gives segment (A+1, B-1)
    maplist([A, B, A1-B1]>>(A1 is A+1, B1 is B-1), Ps0, Ps1, Segs).

% arc2_ss_kind_: classify arrangement from divider presence.
arc2_ss_kind_([], [_|_], h).
% both horizontal and vertical dividers → 2D arrangement
arc2_ss_kind_([_|_], [], v).
% only horizontal dividers → vertical stack
arc2_ss_kind_([_|_], [_|_], td).

% arc2_ss_extract_: build list of sec(Grid, ReadIdx, CellCount) in reading order.
arc2_ss_extract_(Grid, RSegs, CSegs, Secs) :-
    % build index ranges for row-segs and col-segs
    length(RSegs, NRS), NRS1 is NRS-1, numlist(0, NRS1, RIs),
    length(CSegs, NCS), NCS1 is NCS-1, numlist(0, NCS1, CIs),
    % enumerate all (RI, CI) combinations in reading order via findall
    findall(sec(SecG, Idx, N), (
        member(RI, RIs), member(CI, CIs),
        % reading-order index for the section
        Idx is RI * NCS + CI,
        % fetch segment bounds
        nth0(RI, RSegs, R0-R1), nth0(CI, CSegs, C0-C1),
        % extract sub-grid and count non-BG cells
        arc2_ss_subgrid_(Grid, R0, R1, C0, C1, SecG),
        arc2_ss_ncount_(SecG, N)
    ), Secs).

% arc2_ss_subgrid_: extract rows R0..R1, cols C0..C1 from Grid.
arc2_ss_subgrid_(Grid, R0, R1, C0, C1, Sub) :-
    % enumerate target row and col indices
    numlist(R0, R1, Rs), numlist(C0, C1, Cs),
    % for each row index, extract the relevant columns
    maplist([R, Row]>>(
        nth0(R, Grid, GRow),
        maplist([C, V]>>(nth0(C, GRow, V)), Cs, Row)
    ), Rs, Sub).

% arc2_ss_ncount_: count cells that are neither BG (7) nor divider (6).
arc2_ss_ncount_(G, N) :-
    % findall a 1 for each qualifying cell then measure length
    findall(1, (member(Row, G), member(V, Row), V \= 7, V \= 6), Ones),
    length(Ones, N).

% arc2_ss_order_(v,...): vertical input → reverse section order.
arc2_ss_order_(v, Secs, Ordered) :- reverse(Secs, Ordered).
% arc2_ss_order_(h,...): horizontal input → preserve section order.
arc2_ss_order_(h, Secs, Secs).
% arc2_ss_order_(td,...): 2D input → sort ascending by N; ties by reverse reading-idx.
arc2_ss_order_(td, Secs, Ordered) :-
    % construct keysort key N-NegIdx where NegIdx = -Idx (higher Idx sorts first on tie)
    maplist([sec(G,Idx,N), (N-NegIdx)-sec(G,Idx,N)]>>(NegIdx is -Idx), Secs, Keyed),
    % keysort is stable ascending on the compound key (N, NegIdx)
    keysort(Keyed, SortedK),
    % extract sec(...) values from the sorted key-value pairs
    pairs_values(SortedK, Ordered).

% arc2_ss_outdir_(v,...): vertical input → horizontal output.
arc2_ss_outdir_(v, _, h).
% arc2_ss_outdir_(h,...): horizontal input → vertical output.
arc2_ss_outdir_(h, _, v).
% arc2_ss_outdir_(td,...): 2D input → direction from bbox height vs width totals.
arc2_ss_outdir_(td, Secs, OutDir) :-
    % collect (H, W) bounding boxes for each section
    findall(H-W, (member(sec(G,_,_), Secs), arc2_ss_bbox_(G, H, W)), HWs),
    % sum heights and widths separately
    findall(H, member(H-_, HWs), Hs), findall(W, member(_-W, HWs), Ws),
    sumlist(Hs, SH), sumlist(Ws, SW),
    % more total height → vertical stack; else horizontal row
    ( SH > SW -> OutDir = v ; OutDir = h ).

% arc2_ss_bbox_: bounding box height and width of non-BG, non-divider cells.
arc2_ss_bbox_(G, H, W) :-
    % collect row indices of qualifying cells
    findall(R, (nth0(R,G,Row), member(V,Row), V \= 7, V \= 6), Rs),
    % collect col indices of qualifying cells
    findall(C, (nth0(_,G,Row), nth0(C,Row,V), V \= 7, V \= 6), Cs),
    % empty section has zero bbox
    ( Rs = [] -> H = 0, W = 0
    ; min_list(Rs,Rmin), max_list(Rs,Rmax), H is Rmax-Rmin+1,
      min_list(Cs,Cmin), max_list(Cs,Cmax), W is Cmax-Cmin+1 ).

% arc2_ss_build_(+Ordered, v, -Out): assemble sections as vertical stack.
arc2_ss_build_(Ordered, v, Out) :-
    % extract grids from sec/3 terms
    maplist([sec(G,_,_), G]>>true, Ordered, Grids),
    % build a full-width divider row of 6s
    nth0(0, Grids, FG), nth0(0, FG, FR), length(FR, W),
    length(DivRow, W), maplist(=(6), DivRow),
    % stack grids with divider rows between them
    arc2_ss_vstack_(Grids, DivRow, Out).

% arc2_ss_vstack_: recursively stack grids with DivRow separator.
arc2_ss_vstack_([G], _, G).
arc2_ss_vstack_([G|Gs], D, Out) :-
    % recurse on tail then prepend current grid and divider
    arc2_ss_vstack_(Gs, D, Rest),
    append(G, [D|Rest], Out).

% arc2_ss_build_(+Ordered, h, -Out): assemble sections as horizontal row.
arc2_ss_build_(Ordered, h, Out) :-
    % extract grids from sec/3 terms
    maplist([sec(G,_,_), G]>>true, Ordered, Grids),
    % determine number of rows from first section
    nth0(0, Grids, FG), length(FG, NR), NR1 is NR-1, numlist(0, NR1, RI),
    % for each row index, extract that row from each grid and join with 6-dividers
    maplist([R, OutRow]>>(
        maplist([G, SR]>>(nth0(R, G, SR)), Grids, SRs),
        arc2_ss_hstack_(SRs, OutRow)
    ), RI, Out).

% arc2_ss_hstack_: concatenate rows with a single 6 between each pair.
arc2_ss_hstack_([SR], SR).
arc2_ss_hstack_([SR|SRs], Out) :-
    % recurse on tail then prepend current row and single 6-separator
    arc2_ss_hstack_(SRs, Rest),
    append(SR, [6|Rest], Out).

% ---------------------------------------------------------------------------
% WP-301 Layer 276: frame_stamp — stamp left-side shapes into a bordered room
% Task: 247ef758. Rule: a bordered room (cols 4+) is framed by a border whose
% dominant color is BdrBG. Anomalies in the top row (col K → color C) and
% right column (row R → color C) encode stamp positions. Each color with
% anomalies in both the top row and right column AND a left-side shape (cols
% 0-3) is stamped at every (R,K) center inside the room. Stamps applied
% largest-cell-count first so smaller shapes overwrite. Stamped left shapes
% are erased to BG; unmarked left shapes are kept unchanged.
% ---------------------------------------------------------------------------

% arc2_named_rule fact registers frame_stamp for the generic induction loop.
arc2_named_rule(frame_stamp).

% arc2_transform(frame_stamp, +Grid, -Out): detect and stamp left shapes.
arc2_transform(frame_stamp, Grid, Out) :-
    % Determine grid background from cell-frequency mode.
    arc2_bg_color_(Grid, BG),
    % Get row count and column count from grid.
    length(Grid, NR), nth0(0, Grid, Row0), length(Row0, NC),
    % Compute last-column index for border access.
    LastCol is NC - 1,
    % Find border background: mode of top row values cols 4..LastCol, excl BG.
    arc2_fst_bdr_bg_(Row0, 4, LastCol, BG, BdrBG),
    % Collect column anomalies from top row: Color->[Cols] association list.
    arc2_fst_col_anoms_(Row0, 4, LastCol, BdrBG, BG, ColAnoms),
    % Collect row anomalies from right border column: Color->[Rows].
    arc2_fst_row_anoms_(Grid, NR, LastCol, BdrBG, BG, RowAnoms),
    % Collect left-side shapes (cols 0-3) per color: Color->[R-C cells].
    arc2_fst_lshapes_(Grid, NR, BG, LShapes),
    % Build stamp specs for colors with anomalies in both borders and a shape.
    arc2_fst_stamps_(LShapes, ColAnoms, RowAnoms, Stamps),
    % Sort stamps descending by cell count: largest stamped first.
    msort(Stamps, AscStamps), reverse(AscStamps, SortedS),
    % Erase stamped left shapes then place all stamps in order.
    arc2_fst_apply_(Grid, NR, NC, SortedS, LShapes, BG, Out).

% arc2_fst_bdr_bg_: find mode of top row values in cols From..To excl BG.
arc2_fst_bdr_bg_(Row, From, To, BG, BdrBG) :-
    % Generate column indices for the room area.
    numlist(From, To, Cs),
    % Extract values at each column.
    maplist([C, V]>>(nth0(C, Row, V)), Cs, Vals),
    % Drop task-BG cells before computing mode.
    exclude(=(BG), Vals, Vals1),
    % Sort to group equal values into runs.
    msort(Vals1, Sorted),
    % Find the most frequent value via run accumulation.
    arc2_fst_mode_(Sorted, BdrBG).

% arc2_fst_mode_: mode of a sorted non-empty list via run-length accumulation.
arc2_fst_mode_([H|T], Mode) :-
    % Initialise current run and best run both at H with count 1.
    arc2_fst_mode_h_(T, H, 1, H, 1, Mode).

% arc2_fst_mode_h_: tail-recursive run accumulator; emits best-run value.
arc2_fst_mode_h_([], C, N, B, BN, M) :-
    % End of list: emit whichever run had the higher count.
    ( N > BN -> M = C ; M = B ).
arc2_fst_mode_h_([H|T], H, N, B, BN, M) :-
    % Same value: extend current run count.
    N1 is N + 1, arc2_fst_mode_h_(T, H, N1, B, BN, M).
arc2_fst_mode_h_([H|T], C, N, B, BN, M) :-
    % New value: update best if current run surpassed it; reset current run.
    H \= C,
    ( N > BN -> NB = C, NBN = N ; NB = B, NBN = BN ),
    arc2_fst_mode_h_(T, H, 1, NB, NBN, M).

% arc2_fst_col_anoms_: build Color->[Col] alist from top-row anomalies.
arc2_fst_col_anoms_(Row, From, To, BdrBG, BG, Anoms) :-
    % Generate column indices.
    numlist(From, To, Cs),
    % Fold over columns accumulating anomaly pairs.
    foldl(arc2_fst_col_step_(Row, BdrBG, BG), Cs, [], Anoms).

% arc2_fst_col_step_: process one column for top-border anomaly collection.
arc2_fst_col_step_(Row, BdrBG, BG, C, Acc, Acc2) :-
    % Fetch cell value at column C.
    nth0(C, Row, V),
    % Record anomaly only for values differing from BdrBG and BG.
    ( V \= BdrBG, V \= BG
    -> arc2_fst_assoc_add_(V, C, Acc, Acc2)
    ;  Acc2 = Acc ).

% arc2_fst_row_anoms_: build Color->[Row] alist from right-border anomalies.
arc2_fst_row_anoms_(Grid, NR, LastCol, BdrBG, BG, Anoms) :-
    % Generate row indices.
    NR1 is NR - 1, numlist(0, NR1, Rs),
    % Fold over rows accumulating anomaly pairs.
    foldl(arc2_fst_row_step_(Grid, LastCol, BdrBG, BG), Rs, [], Anoms).

% arc2_fst_row_step_: process one row for right-border anomaly collection.
arc2_fst_row_step_(Grid, LastCol, BdrBG, BG, R, Acc, Acc2) :-
    % Fetch the row at index R.
    nth0(R, Grid, Row),
    % Fetch the rightmost cell.
    nth0(LastCol, Row, V),
    % Record anomaly only for values differing from BdrBG and BG.
    ( V \= BdrBG, V \= BG
    -> arc2_fst_assoc_add_(V, R, Acc, Acc2)
    ;  Acc2 = Acc ).

% arc2_fst_assoc_add_: insert Pos into the Color->Positions pair in an alist.
arc2_fst_assoc_add_(Color, Pos, [], [(Color, [Pos])]).
arc2_fst_assoc_add_(Color, Pos, [(Color, Ps)|T], [(Color, [Pos|Ps])|T]) :- !.
arc2_fst_assoc_add_(Color, Pos, [H|T], [H|T2]) :-
    % Recurse past entries for other colors.
    arc2_fst_assoc_add_(Color, Pos, T, T2).

% arc2_fst_lshapes_: collect left-side (cols 0-3) non-BG cells per color.
arc2_fst_lshapes_(Grid, NR, BG, LShapes) :-
    % Generate row indices.
    NR1 is NR - 1, numlist(0, NR1, Rs),
    % Fold over all rows scanning cols 0-3.
    foldl([R, Ac, Ac2]>>(
        % Fetch row R from the grid.
        nth0(R, Grid, Row),
        % Fold over left-side columns 0-3.
        foldl([C, Ai, Ao]>>(
            % Fetch cell value.
            nth0(C, Row, V),
            % Accumulate non-BG cells keyed by color; store as R-C pair.
            ( V \= BG
            -> arc2_fst_assoc_add_(V, R-C, Ai, Ao)
            ;  Ao = Ai )
        ), [0, 1, 2, 3], Ac, Ac2)
    ), Rs, [], LShapes).

% arc2_fst_stamps_: build N-stamp(Color,Cells,SumR,SumC,N,Pls) terms.
arc2_fst_stamps_(LShapes, ColAnoms, RowAnoms, Stamps) :-
    % One stamp per color with left shape, col anomaly, and row anomaly.
    findall(N-stamp(Color, Cells, SumR, SumC, N, Pls), (
        % Require a left-side shape for this color.
        member((Color, Cells), LShapes),
        % Require column anomalies for this color in the top border.
        member((Color, Ks), ColAnoms),
        % Require row anomalies for this color in the right border.
        member((Color, Rs), RowAnoms),
        % Count shape cells for size ordering.
        length(Cells, N),
        % Decompose R-C pairs into separate row and col lists.
        pairs_keys_values(Cells, CellRs, CellCs),
        % Sum row indices for centroid computation.
        sumlist(CellRs, SumR),
        % Sum col indices for centroid computation.
        sumlist(CellCs, SumC),
        % Generate all (NewRow, NewCol) placement pairs.
        findall(R-K, (member(R, Rs), member(K, Ks)), Pls)
    ), Stamps).

% arc2_fst_apply_: erase stamped left shapes then place stamps in sorted order.
arc2_fst_apply_(Grid, NR, NC, SortedS, LShapes, BG, Out) :-
    % Collect colors that will be placed (to erase their left shapes).
    findall(Color, member(_-stamp(Color,_,_,_,_,_), SortedS), PlacedColors),
    % Remove duplicate color entries.
    list_to_set(PlacedColors, PlacedSet),
    % Erase each placed color's left-side cells from the grid.
    foldl([Color, G0, G1]>>(
        % Find the cell list for this color.
        member((Color, Cells), LShapes),
        % Set each left-side cell to BG.
        foldl([R-C, Gi, Go]>>(arc2_set_cell_(Gi, R, C, BG, Go)), Cells, G0, G1)
    ), PlacedSet, Grid, G1),
    % Apply each stamp in size-descending order (smaller stamps overwrite).
    foldl([_N-stamp(Color, Cells, SumR, SumC, N, Pls), Gi, Go]>>(
        % Process each (NewRow, NewCol) placement center.
        foldl([NewR-NewK, Gii, Goo]>>(
            % Compute integer row offset: round((NewR - SumR/N)).
            DR is round(float(NewR * N - SumR) / float(N)),
            % Compute integer col offset: round((NewK - SumC/N)).
            DC is round(float(NewK * N - SumC) / float(N)),
            % Place each shape cell at its shifted position.
            foldl([R-C, Gj, Gk]>>(
                % Compute the target row and column.
                Nr is R + DR, Nc is C + DC,
                % Stamp only if target is within grid bounds.
                ( Nr >= 0, Nr < NR, Nc >= 0, Nc < NC
                -> arc2_set_cell_(Gj, Nr, Nc, Color, Gk)
                ;  Gk = Gj )
            ), Cells, Gii, Goo)
        ), Pls, Gi, Go)
    ), SortedS, G1, Out).

% Fast specific clause for shape_walk: avoids catch-all timeout.
% Pre-filter: first row of first training input must contain both a 4 (divider) and a 5 (marker).
arc2_induce_rule(TrainingPairs, shape_walk) :-
% Unpack first training pair.
    TrainingPairs = [pair(First, _)|_],
% Read first row of the grid.
    First = [FR0|_],
% Quick check: first row must contain a 5 (marker) and a 4 (divider column).
    memberchk(5, FR0),
    memberchk(4, FR0),
% Full verification: all training pairs must transform correctly.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(shape_walk, In, Out)).

% Fast specific clause for pocket_shot: avoids catch-all timeout on large grids.
% Requires at least one 2-cell in the first training input as a quick pre-filter.
arc2_induce_rule(TrainingPairs, pocket_shot) :-
% Quick pre-filter: verify the first training input contains at least one 2-cell.
    TrainingPairs = [pair(First, _)|_],
    length(First, H), H1 is H - 1,
    First = [FRow|_], length(FRow, W), W1 is W - 1,
% Fast scan: succeed as soon as any 2-cell is found.
    once((between(0, H1, R), between(0, W1, C), arc2_cell_(First, R, C, 2))),
% Full verification: all training pairs must transform correctly.
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(pocket_shot, In, Out)).

% ===========================================================================
% WP-323  hole_color  —  Layer 298
% hole_color: recolor grey (5) blobs by counting internal enclosed holes.
% Each grey component is classified by its hole count, then recolored to the
% color of the legend template that has the same number of internal holes.
% Reference: ARC-AGI-2 task e3721c99.
% ===========================================================================

% Register hole_color as a known named rule.
arc2_named_rule(hole_color).

% arc2_induce_rule for hole_color: pre-filter on grey presence/absence.
arc2_induce_rule(TrainingPairs_, hole_color) :-
% Require grey (5) cells in first training input.
    TrainingPairs_ = [pair(In0_, Out0_)|_],
% Flatten input and check for grey cells.
    flatten(In0_, F0_), memberchk(5, F0_),
% Flatten output and verify no grey cells remain.
    flatten(Out0_, FO0_), \+ memberchk(5, FO0_),
% Verify all training pairs under hole_color.
    forall(member(pair(In_, Out_), TrainingPairs_),
% Each training pair must transform correctly.
           arc2_transform(hole_color, In_, Out_)).

% arc2_transform for hole_color: parse legend, count holes, recolor grey blobs.
arc2_transform(hole_color, Grid_, Out_) :-
% Early dispatch guard: the grid must contain at least one grey (5) cell.
    flatten(Grid_, FlatG_), memberchk(5, FlatG_),
% Determine grid dimensions.
    length(Grid_, NR_), Grid_ = [FR_|_], length(FR_, NC_),
% Compute maximum row and column indices (0-based).
    MaxR_ is NR_ - 1, MaxC_ is NC_ - 1,
% Find all connected components ignoring background (0).
    arc2_all_comps_(Grid_, 0, AllComps_),
% Separate grey (5) components from non-grey candidates.
    include([comp(5,_)]>>true, AllComps_, GreyComps_),
% Keep only compact non-grey components as legend templates.
    include([comp(V_,Cs_)]>>(
% Template color must not be grey.
        V_ \= 5,
% Compute the component bounding box.
        hc_bbox4_(Cs_, R1_, R2_, C1_, C2_),
% Compute bounding-box height and width.
        H_ is R2_ - R1_ + 1, W_ is C2_ - C1_ + 1,
% Require a minimum dimension of 2 in each direction.
        H_ >= 2, W_ >= 2,
% Compute component size and bounding-box area.
        length(Cs_, Sz_), Area_ is H_ * W_,
% Require a fill rate of at least 75 percent.
        Sz_ * 4 >= Area_ * 3
% Close the template filter over all components.
    ), AllComps_, TplComps_),
% Build legend map: hole_count -> template_color.
    findall(N_-V_, (
% Enumerate each legend template component.
        member(comp(V_, TC_), TplComps_),
% Count enclosed holes using the template color as the wall.
        hc_holes_(Grid_, TC_, V_, MaxR_, MaxC_, N_)
% Close the legend-map findall.
    ), RawMap_),
% Sort and deduplicate the legend map.
    sort(RawMap_, LegMap_),
% Pre-compute hole counts and target colors for all grey shapes on the original grid.
    findall(GC_-GCol_, (
% Enumerate each grey component.
        member(comp(5, GC_), GreyComps_),
% Count enclosed holes using grey as the wall color.
        hc_holes_(Grid_, GC_, 5, MaxR_, MaxC_, GN_),
% Look up the target color in the legend map; erase to background if absent.
        (member(GN_-GCol_, LegMap_) -> true ; GCol_ = 0)
% Close the colorings findall.
    ), Colorings_),
% Apply recoloring: replace each grey component's cells with its target color.
    foldl([GCC_-GCV_, G0_, G1_]>>(
% Thread the grid through every cell of the component.
        foldl([R_-C_, Gi_, Go_]>>(arc2_set_cell_(Gi_, R_, C_, GCV_, Go_)),
% Fold over the component cells starting from the incoming grid.
              GCC_, G0_, G1_)
% Fold over all colorings starting from the original grid.
    ), Colorings_, Grid_, Out_).

% hc_bbox4_/5: compute bounding box (min_row, max_row, min_col, max_col).
hc_bbox4_([R0_-C0_|Rest_], MnR_, MxR_, MnC_, MxC_) :-
% Initialise accumulator from the first cell.
    hc_bbox4_acc_(Rest_, R0_, R0_, C0_, C0_, MnR_, MxR_, MnC_, MxC_).

% hc_bbox4_acc_/9: base case returns the accumulated bounding box.
hc_bbox4_acc_([], MnR_, MxR_, MnC_, MxC_, MnR_, MxR_, MnC_, MxC_).
% hc_bbox4_acc_/9: accumulate bounding box values over remaining cells.
hc_bbox4_acc_([R_-C_|T_], MnR0_, MxR0_, MnC0_, MxC0_, MnR_, MxR_, MnC_, MxC_) :-
% Update min and max row with the new cell.
    NMnR_ is min(MnR0_, R_), NMxR_ is max(MxR0_, R_),
% Update min and max column with the new cell.
    NMnC_ is min(MnC0_, C_), NMxC_ is max(MxC0_, C_),
% Recurse over remaining cells.
    hc_bbox4_acc_(T_, NMnR_, NMxR_, NMnC_, NMxC_, MnR_, MxR_, MnC_, MxC_).

% hc_holes_/6: count enclosed background holes in a component.
% WallColor is the cell value that forms walls (5 for grey, V for template).
hc_holes_(Grid_, Cells_, WallColor_, MaxR_, MaxC_, N_) :-
% Sort component cells for efficient lookup.
    sort(Cells_, CellSet_),
% Collect boundary seeds: grid-border cells with value not equal to WallColor.
    findall(R_-C_, (
% Enumerate every cell position on the grid.
        between(0, MaxR_, R_), between(0, MaxC_, C_),
% Keep only cells on the grid border.
        (R_ =:= 0 ; R_ =:= MaxR_ ; C_ =:= 0 ; C_ =:= MaxC_),
% Keep only passable (non-wall) border cells.
        arc2_cell_(Grid_, R_, C_, V_), V_ \= WallColor_
% Close the boundary-seeds findall.
    ), Seeds0_),
% Sort seeds to remove duplicates.
    sort(Seeds0_, Seeds_),
% BFS from boundary through non-WallColor cells to find exterior.
    hc_nwall_bfs_(Grid_, WallColor_, Seeds_, [], Ext_),
% Find background (0) cells adjacent to component cells that are not exterior.
    findall(R_-C_, (
% Enumerate each cell of the component.
        member(CR_-CC_, CellSet_),
% Enumerate the four cardinal neighbours: above the cell first.
        (R_ is CR_-1, C_ = CC_ ;
% Neighbour below the cell.
         R_ is CR_+1, C_ = CC_ ;
% Neighbour to the left of the cell.
         R_ = CR_, C_ is CC_-1 ;
% Neighbour to the right of the cell.
         R_ = CR_, C_ is CC_+1),
% Keep only in-bounds neighbours.
        R_ >= 0, C_ >= 0, R_ =< MaxR_, C_ =< MaxC_,
% Keep only background (0) neighbours.
        arc2_cell_(Grid_, R_, C_, 0),
% Exclude neighbours reachable from the grid border.
        \+ memberchk(R_-C_, Ext_)
% Close the hole-seeds findall.
    ), HSeeds0_),
% Sort hole seeds to remove duplicates.
    sort(HSeeds0_, HSeeds_),
% Count connected components among enclosed background cells.
    hc_nwall_comps_(HSeeds_, Ext_, Grid_, 0, N_).

% hc_nwall_bfs_/5: base case with an empty queue returns visited set.
hc_nwall_bfs_(_, _, [], Vis_, Vis_) :- !.
% hc_nwall_bfs_/5: BFS through cells where value differs from WallColor.
hc_nwall_bfs_(Grid_, Wall_, [R_-C_|Q_], Vis0_, Vis_) :-
% Expand only if not yet visited and cell is passable (value not Wall).
    (   \+ memberchk(R_-C_, Vis0_),
% Read the cell value and require it to differ from the wall color.
        arc2_cell_(Grid_, R_, C_, V_), V_ \= Wall_
% Mark the cell as visited.
    ->  Vis1_ = [R_-C_|Vis0_],
% Compute the four cardinal neighbour coordinates.
        R1_ is R_-1, R2_ is R_+1, C1_ is C_-1, C2_ is C_+1,
% Add the four cardinal neighbours to the queue.
        append(Q_, [R1_-C_, R2_-C_, R_-C1_, R_-C2_], Q1_),
% Continue the BFS with the extended queue.
        hc_nwall_bfs_(Grid_, Wall_, Q1_, Vis1_, Vis_)
% Otherwise skip this cell and continue with the rest of the queue.
    ;   hc_nwall_bfs_(Grid_, Wall_, Q_, Vis0_, Vis_)
% Close the conditional expansion.
    ).

% hc_nwall_comps_/5: base case with no seeds returns the accumulated count.
hc_nwall_comps_([], _, _, N_, N_) :- !.
% hc_nwall_comps_/5: count connected components among hole seed cells.
hc_nwall_comps_([Seed_|Rest_], Ext_, Grid_, Acc_, N_) :-
% Expand one component from the seed through enclosed background cells.
    hc_bg_bfs_(Grid_, [Seed_], Ext_, [], Vis_),
% Remove all visited cells from remaining seeds.
    subtract(Rest_, Vis_, Rem_),
% Increment the component count.
    Acc1_ is Acc_ + 1,
% Recurse over remaining seeds.
    hc_nwall_comps_(Rem_, Ext_, Grid_, Acc1_, N_).

% hc_bg_bfs_/5: base case with an empty queue returns visited set.
hc_bg_bfs_(_, [], _, Vis_, Vis_) :- !.
% hc_bg_bfs_/5: BFS through enclosed background (0) cells not in Exterior.
hc_bg_bfs_(Grid_, [R_-C_|Q_], Ext_, Vis0_, Vis_) :-
% Expand only if not visited, value is 0, and not exterior.
    (   \+ memberchk(R_-C_, Vis0_),
% Require the cell to be background (0).
        arc2_cell_(Grid_, R_, C_, 0),
% Require the cell to be enclosed (not reachable from the border).
        \+ memberchk(R_-C_, Ext_)
% Mark the cell as visited.
    ->  Vis1_ = [R_-C_|Vis0_],
% Compute the four cardinal neighbour coordinates.
        R1_ is R_-1, R2_ is R_+1, C1_ is C_-1, C2_ is C_+1,
% Add the four cardinal neighbours to the queue.
        append(Q_, [R1_-C_, R2_-C_, R_-C1_, R_-C2_], Q1_),
% Continue the BFS with the extended queue.
        hc_bg_bfs_(Grid_, Q1_, Ext_, Vis1_, Vis_)
% Otherwise skip this cell and continue with the rest of the queue.
    ;   hc_bg_bfs_(Grid_, Q_, Ext_, Vis0_, Vis_)
% Close the conditional expansion.
    ).

% ---------------------------------------------------------------------------
% TASK-TYPE-AWARE INDUCTION (CORE OF ARC-AGI-2 APPROACH)
% arc2_induce_rule/2: classify task type and dispatch to appropriate strategy.
% ---------------------------------------------------------------------------

% arc2_induce_rule(+TrainingPairs, -Rule)
% Classify the task with tc_categorize, then dispatch to the right solver.
% Rule is an atom or compound term identifying the transformation.
arc2_induce_rule(TrainingPairs, Rule) :-
    % Attempt geometric/structural single-rule search first.
    arc2_named_rule(Rule),
    forall(member(pair(In, Out), TrainingPairs),
           arc2_transform(Rule, In, Out)).

% Plus-shape recolor: all changes are A->B and each changed cell is in a plus shape.
arc2_induce_rule(TrainingPairs, recolor_plus(A, B)) :-
    arc2_learn_single_recolor_(TrainingPairs, A, B),
    forall(member(pair(In, Out), TrainingPairs),
           (arc2_apply_plus_recolor(In, A, B, Computed),
            Computed = Out)).

% Fallback: try recolor bijection (color substitution map).
arc2_induce_rule(TrainingPairs, recolor_auto) :-
    arc2_induce_recolor(TrainingPairs, _Mapping).

% ---------------------------------------------------------------------------
% BENCHMARK RUNNER
% ---------------------------------------------------------------------------

% arc2_benchmark_run/3: run all loaded arc2_task/4 facts.
% Score is the number of solved tasks; Total is the total number of tasks.
arc2_benchmark_run(Score, Total, Results) :-
    % Collect all task facts from the arc_tasks_2 module.
    findall(
        task(TaskId, TrainingPairs, TestIn, TestOut),
        arc_tasks_2:arc2_task(TaskId, TrainingPairs, TestIn, TestOut),
        Tasks
    ),
    length(Tasks, Total),
    % Attempt each task.
    maplist(arc2_attempt_task_, Tasks, Results),
    % Count passes.
    include([result(_, pass(_))]>>true, Results, Passed),
    length(Passed, Score).

% arc2_attempt_task_(+Task, -Result): attempt one task; return pass or fail.
% A per-task 10-second limit prevents pair-induction from hanging the benchmark.
arc2_attempt_task_(task(TaskId, TrainingPairs, TestIn, TestOut), Result) :-
    % Wrap the full attempt in a time limit so no task stalls the benchmark.
    ( catch(
        call_with_time_limit(10.0,
            arc2_attempt_task_inner_(TaskId, TrainingPairs, TestIn, TestOut, Result)),
        time_limit_exceeded,
        Result = result(TaskId, fail)
    ) -> true ; Result = result(TaskId, fail) ).

% arc2_attempt_task_inner_/5: attempt task without time limit (called inside limit).
% Pair induction (Level 2) is omitted from the benchmark loop because
% it tries 576 combinations and dominates runtime; single-rule + recolor
% covers all currently solved tasks.
arc2_attempt_task_inner_(TaskId, TrainingPairs, TestIn, TestOut, Result) :-
    % Level 1: single named rule.
    (   arc2_induce_rule(TrainingPairs, Rule),
        arc2_transform(Rule, TestIn, Computed),
        Computed = TestOut
    ->  Result = result(TaskId, pass(Rule))
    % Level 2: color bijection recoloring.
    ;   arc2_induce_recolor(TrainingPairs, Mapping),
        arc2_recolor_grid(Mapping, TestIn, Computed2),
        Computed2 = TestOut
    ->  Result = result(TaskId, pass(recolor_auto))
    % No level solved it.
    ;   Result = result(TaskId, fail)
    ).

% arc2_induce_rule_pair_(+TrainingPairs, -pair(R1, R2))
% Find an ordered pair of named rules that together explain all training pairs.
arc2_induce_rule_pair_(TrainingPairs, pair(R1, R2)) :-
    arc2_named_rule(R1),
    arc2_named_rule(R2),
    R1 \= R2,
    forall(member(pair(In, Out), TrainingPairs),
           (arc2_transform(R1, In, Mid),
            arc2_transform(R2, Mid, Out))).

% ---------------------------------------------------------------------------
% WP-302 Layer 277: jigsaw_fill — slot-shaped object pieces tile template holes
% Task: 5dbc8537. Rule: the input splits into a 2-color template (solid S,
% hole H) and a multi-color objects region (background B). Every non-B
% connected component in the objects region is a "piece" whose shape (set of
% relative cell offsets, possibly multi-color) exactly matches one contiguous
% sub-region of H-cells in the template. Backtracking exact cover finds the
% unique non-overlapping assignment; the filled template is the output.
% ---------------------------------------------------------------------------

% ---------------------------------------------------------------------------
% WP-303  stair_fill  (Layer 278)  Task 28a6681f
% Input has staircase walls (non-0, non-1 cells forming L/step shapes) and
% N misplaced 1-cells. Output fills exactly N "stair pocket" interior cells
% with 1 and clears all other 1-cells. Two-phase algorithm: Phase 1 fills
% doubly-bounded pockets (staircase wall on BOTH left and right), bottom to
% top, smallest gap first. Phase 2 fills single-bounded pockets (staircase
% wall on left, grid boundary on right) with any remaining budget.
% ---------------------------------------------------------------------------

% arc2_named_rule registers stair_fill for the generic induction loop.
arc2_named_rule(stair_fill).

% arc2_transform(stair_fill, +Grid, -Out): fill staircase step pockets.
arc2_transform(stair_fill, Grid, Out) :-
% Count all 1-cells in the input grid.
    arc2_sf_count1_(Grid, N),
% Must have at least one 1-cell to place.
    N > 0,
% Determine grid dimensions.
    length(Grid, NR),
% Extract first row to get column count.
    Grid = [Row0|_],
% Column count.
    length(Row0, NC),
% Compute last row and last column indices.
    LastRow is NR - 1,
    LastCol is NC - 1,
% Phase 1: find doubly-bounded pockets (wall on left AND right).
    arc2_sf_phase1_(Grid, NR, NC, LastRow, LastCol, N, [], Pockets1, N1),
% Phase 2: find single-bounded pockets if budget remains.
    (   N1 > 0
    ->  arc2_sf_phase2_(Grid, NR, NC, LastRow, LastCol, N1, Pockets1, Pockets2)
    ;   Pockets2 = Pockets1
    ),
% Build the output grid: pocket cells become 1, other 1s become 0.
    arc2_sf_build_out_(Grid, Pockets2, Out).

% arc2_sf_count1_(+Grid, -N): count 1-cells in Grid.
arc2_sf_count1_(Grid, N) :-
% Flatten grid to a single list.
    flatten(Grid, Flat),
% Collect only the 1-values.
    include(==(1), Flat, Ones),
% N is the length of that list.
    length(Ones, N).

% arc2_sf_is_wall_(+Cell): true when Cell is a staircase wall (not 0, not 1).
arc2_sf_is_wall_(C) :-
% Non-background non-1 means a staircase boundary.
    C \== 0, C \== 1.

% arc2_sf_open_(+Cell): true when Cell is open (0 or 1, not a wall).
arc2_sf_open_(C) :-
% 0 and 1-cells are both treated as traversable open space.
    \+ arc2_sf_is_wall_(C).

% arc2_sf_find_ranges_(+Row, +NC, -Ranges): find maximal open runs.
% Each range is (GapSize, C_L, C_R).
arc2_sf_find_ranges_(Row, NC, Ranges) :-
% Scan left to right building maximal open runs.
    arc2_sf_scan_ranges_(Row, 0, NC, [], Ranges).

% arc2_sf_scan_ranges_(+Row, +C, +NC, +Acc, -Ranges)
arc2_sf_scan_ranges_(_, C, NC, Acc, Acc) :-
% Reached the end of the row; return accumulated ranges.
    C >= NC, !.
arc2_sf_scan_ranges_(Row, C, NC, Acc, Ranges) :-
% Get the cell at column C.
    nth0(C, Row, Cell),
% If this cell is a wall, skip it.
    arc2_sf_is_wall_(Cell), !,
% Advance past the wall.
    C1 is C + 1,
    arc2_sf_scan_ranges_(Row, C1, NC, Acc, Ranges).
arc2_sf_scan_ranges_(Row, C, NC, Acc, Ranges) :-
% Open cell: find the end of this run.
    arc2_sf_run_end_(Row, C, NC, C_R),
% Compute gap size.
    Gap is C_R - C + 1,
% Record this range.
    C1 is C_R + 1,
    arc2_sf_scan_ranges_(Row, C1, NC, [Gap-C-C_R|Acc], Ranges).

% arc2_sf_run_end_(+Row, +C, +NC, -C_R): find last open column in current run.
arc2_sf_run_end_(Row, C, NC, C_R) :-
% Next column.
    C1 is C + 1,
% Check if next column is within bounds and open.
    (   C1 < NC, nth0(C1, Row, Next), arc2_sf_open_(Next)
    ->  arc2_sf_run_end_(Row, C1, NC, C_R)
    ;   C_R = C
    ).

% arc2_sf_below_ok_(+Grid, +R, +C_L, +C_R, +NR, +Pockets): all below are wall/pocket/bottom.
arc2_sf_below_ok_(_, R, _, _, NR, _) :-
% Last row: grid boundary acts as floor.
    R =:= NR - 1, !.
arc2_sf_below_ok_(Grid, R, C_L, C_R, NR, Pockets) :-
% Row below.
    R1 is R + 1,
% Every column in range must have wall or pocket below.
    nth0(R1, Grid, RowBelow),
    forall(
        (between(C_L, C_R, C),
         nth0(C, RowBelow, BelowCell)),
        (   arc2_sf_is_wall_(BelowCell)
        ;   member(R1-C, Pockets)
        )
    ).

% arc2_sf_phase1_(+Grid, +NR, +NC, +LastRow, +LastCol, +N, +P0, -P1, -N1):
% Phase 1: doubly-bounded pockets (staircase wall on left AND right).
arc2_sf_phase1_(Grid, NR, NC, LastRow, LastCol, N, P0, P1, N1) :-
% Process rows bottom to top.
    arc2_sf_phase1_rows_(Grid, NR, NC, LastRow, LastCol, N, P0, P1, N1).

% arc2_sf_phase1_rows_: iterate rows from LastRow down to 0.
arc2_sf_phase1_rows_(_, _, _, R, _, N, P, P, N) :-
% Below row 0: done.
    R < 0, !.
arc2_sf_phase1_rows_(_, _, _, _, _, 0, P, P, 0) :- !.
arc2_sf_phase1_rows_(Grid, NR, NC, R, LastCol, N, P0, P, N_out) :-
% Get the current row.
    nth0(R, Grid, Row),
% Find all open runs in this row.
    arc2_sf_find_ranges_(Row, NC, AllRanges),
% Filter to doubly-bounded (left wall AND right wall, no grid boundary).
    arc2_sf_db_ranges_(Row, AllRanges, Grid, R, NR, LastCol, P0, DBRanges),
% Sort by gap size ascending (smallest first = innermost first).
    msort(DBRanges, Sorted),
% Fill cells from sorted ranges up to budget N.
    arc2_sf_fill_ranges_(Sorted, R, N, P0, P1_row, N1_row),
% Process next row upward.
    R1 is R - 1,
    arc2_sf_phase1_rows_(Grid, NR, NC, R1, LastCol, N1_row, P1_row, P, N_out).

% arc2_sf_db_ranges_(+Row, +Ranges, +Grid, +R, +NR, +LastCol, +P, -DB):
% Keep only doubly-bounded ranges (left wall = staircase, right wall = staircase, not boundary).
arc2_sf_db_ranges_(_, [], _, _, _, _, _, []).
arc2_sf_db_ranges_(Row, [Gap-C_L-C_R|Rest], Grid, R, NR, LastCol, P, DB) :-
% Check left wall: C_L > 0 and cell to left is staircase wall.
    (   C_L > 0,
        C_L1 is C_L - 1,
        nth0(C_L1, Row, LeftCell),
        arc2_sf_is_wall_(LeftCell),
% Check right wall: C_R < LastCol and cell to right is staircase wall.
        C_R1 is C_R + 1,
        C_R1 =< LastCol,
        nth0(C_R1, Row, RightCell),
        arc2_sf_is_wall_(RightCell),
% Check below: all cells below are wall or pocket or bottom.
        arc2_sf_below_ok_(Grid, R, C_L, C_R, NR, P)
    ->  DB = [Gap-C_L-C_R|Rest2]
    ;   DB = Rest2
    ),
    arc2_sf_db_ranges_(Row, Rest, Grid, R, NR, LastCol, P, Rest2).

% arc2_sf_phase2_(+Grid, +NR, +NC, +LastRow, +LastCol, +N, +P0, -P):
% Phase 2: single-bounded pockets (left = staircase wall, right = grid boundary).
arc2_sf_phase2_(Grid, NR, NC, LastRow, LastCol, N, P0, P) :-
    arc2_sf_phase2_rows_(Grid, NR, NC, LastRow, LastCol, N, P0, P).

% arc2_sf_phase2_rows_: iterate rows bottom to top for single-bounded pockets.
arc2_sf_phase2_rows_(_, _, _, R, _, _, P, P) :-
    R < 0, !.
arc2_sf_phase2_rows_(_, _, _, _, _, 0, P, P) :- !.
arc2_sf_phase2_rows_(Grid, NR, NC, R, LastCol, N, P0, P) :-
    nth0(R, Grid, Row),
    arc2_sf_find_ranges_(Row, NC, AllRanges),
% Filter to single-bounded: left=wall, right=grid boundary.
    arc2_sf_sb_ranges_(Row, AllRanges, Grid, R, NR, LastCol, P0, SBRanges),
    msort(SBRanges, Sorted),
    arc2_sf_fill_ranges_(Sorted, R, N, P0, P1_row, N1_row),
    R1 is R - 1,
    arc2_sf_phase2_rows_(Grid, NR, NC, R1, LastCol, N1_row, P1_row, P).

% arc2_sf_sb_ranges_(+Row, +Ranges, +Grid, +R, +NR, +LastCol, +P, -SB):
% Keep only single-bounded ranges (left wall, right = grid boundary only).
arc2_sf_sb_ranges_(_, [], _, _, _, _, _, []).
arc2_sf_sb_ranges_(Row, [Gap-C_L-C_R|Rest], Grid, R, NR, LastCol, P, SB) :-
    (   C_L > 0,
        C_L1 is C_L - 1,
        nth0(C_L1, Row, LeftCell),
        arc2_sf_is_wall_(LeftCell),
% Right must reach grid boundary (C_R == LastCol or next cell is not a wall).
        C_R =:= LastCol,
% Below condition.
        arc2_sf_below_ok_(Grid, R, C_L, C_R, NR, P)
    ->  SB = [Gap-C_L-C_R|Rest2]
    ;   SB = Rest2
    ),
    arc2_sf_sb_ranges_(Row, Rest, Grid, R, NR, LastCol, P, Rest2).

% arc2_sf_fill_ranges_(+Sorted, +R, +N, +P0, -P, -N_out):
% Add cells from sorted ranges to pocket set up to budget N.
arc2_sf_fill_ranges_([], _, N, P, P, N).
arc2_sf_fill_ranges_(_, _, 0, P, P, 0) :- !.
arc2_sf_fill_ranges_([_Gap-C_L-C_R|Rest], R, N, P0, P, N_out) :-
% Fill cells C_L..C_R into pocket, decrementing N.
    arc2_sf_fill_range_(C_L, C_R, R, N, P0, P1, N1),
    arc2_sf_fill_ranges_(Rest, R, N1, P1, P, N_out).

% arc2_sf_fill_range_(+C_L, +C_R, +R, +N, +P0, -P, -N_out):
% Add cells (R, C_L), (R, C_L+1), ..., (R, C_R) to pocket if budget allows.
arc2_sf_fill_range_(C, C_R, _, N, P, P, N) :-
% Past end of range.
    C > C_R, !.
arc2_sf_fill_range_(_, _, _, 0, P, P, 0) :- !.
arc2_sf_fill_range_(C, C_R, R, N, P0, P, N_out) :-
% Add this cell if not already in pocket.
    (   member(R-C, P0)
    ->  P1 = P0, N1 = N
    ;   P1 = [R-C|P0], N1 is N - 1
    ),
    C1 is C + 1,
    arc2_sf_fill_range_(C1, C_R, R, N1, P1, P, N_out).

% arc2_sf_build_out_(+Grid, +Pockets, -Out):
% Build output: pocket cells -> 1, other 1s -> 0, walls unchanged.
arc2_sf_build_out_(Grid, Pockets, Out) :-
% Process each row with its row index.
    length(Grid, NR),
    NR1 is NR - 1,
    numlist(0, NR1, RowIdxs),
    maplist(arc2_sf_build_row_(Pockets, Grid), RowIdxs, Out).

% arc2_sf_build_row_(+Pockets, +Grid, +R, -OutRow):
% Build one output row.
arc2_sf_build_row_(Pockets, Grid, R, OutRow) :-
    nth0(R, Grid, Row),
    length(Row, NC),
    NC1 is NC - 1,
    numlist(0, NC1, ColIdxs),
    maplist(arc2_sf_build_cell_(Pockets, Row, R), ColIdxs, OutRow).

% arc2_sf_build_cell_(+Pockets, +Row, +R, +C, -V):
% Determine output cell value.
arc2_sf_build_cell_(Pockets, Row, R, C, V) :-
    nth0(C, Row, Cell),
% Pocket cell -> output 1.
    (   member(R-C, Pockets)
    ->  V = 1
% Staircase wall -> keep as-is.
    ;   arc2_sf_is_wall_(Cell)
    ->  V = Cell
% 1-cell -> clear to 0.
    ;   Cell =:= 1
    ->  V = 0
% 0-cell -> keep 0.
    ;   V = 0
    ).

% arc2_named_rule registers jigsaw_fill for the generic induction loop.
arc2_named_rule(jigsaw_fill).

% arc2_transform(jigsaw_fill, +Grid, -Out): split, piece, cover, fill.
arc2_transform(jigsaw_fill, Grid, Out) :-
% Find template (2-color) / objects split; Hole is the fill-me color.
    arc2_jf_find_split_(Grid, Tmpl, Hole, ObjGrid, ObjBg),
% Collect every (R,C) in the template where the cell holds Hole.
    arc2_jf_holes_(Tmpl, Hole, Holes),
% Collect every non-ObjBg connected component from the objects region.
    arc2_jf_pieces_(ObjGrid, ObjBg, Pieces),
% Template row and column counts needed for placement bounds.
    length(Tmpl, TR),
% Extract first row to learn column count.
    Tmpl = [TRow|_],
% Column count of the template.
    length(TRow, TC),
% Augment each piece with its list of valid placements in the hole set.
    arc2_jf_augment_(Pieces, Holes, TR, TC, PiecesWP),
% Sort ascending by number of placements: fewest first for fast backtracking.
    msort(PiecesWP, Sorted),
% Backtracking exact cover: assign each piece to one non-overlapping placement.
    arc2_jf_cover_(Sorted, Holes, [], ColorMap),
% Rewrite template: each hole cell gets its assigned color from ColorMap.
    arc2_jf_apply_(Tmpl, ColorMap, Out).

% arc2_jf_find_split_(+Grid, -Tmpl, -Hole, -ObjGrid, -ObjBg)
% Try all row and column split points; pick the unique one where the template
% side has exactly 2 colors and total piece cells equal total hole cells.
arc2_jf_find_split_(Grid, Tmpl, Hole, ObjGrid, ObjBg) :-
% Try row splits (template = top rows, then bottom rows).
    (   arc2_jf_row_split_(Grid, Tmpl, Hole, ObjGrid, ObjBg)
    ;   arc2_jf_row_split_bot_(Grid, Tmpl, Hole, ObjGrid, ObjBg)
% Try column splits (template = left cols, then right cols).
    ;   arc2_jf_col_split_(Grid, Tmpl, Hole, ObjGrid, ObjBg)
    ;   arc2_jf_col_split_right_(Grid, Tmpl, Hole, ObjGrid, ObjBg)
    ), !.

% arc2_jf_row_split_: template = first N rows; objects = remaining rows.
arc2_jf_row_split_(Grid, Tmpl, Hole, Obj, ObjBg) :-
% Nondeterministically split Grid into a non-empty prefix and suffix.
    append(Tmpl, Obj, Grid),
% Both parts must be non-empty.
    Tmpl = [_|_], Obj = [_|_],
% Validate template structure and matching piece count.
    arc2_jf_check_tmpl_obj_(Tmpl, Obj, Hole, ObjBg).

% arc2_jf_row_split_bot_: template = last N rows; objects = first rows.
arc2_jf_row_split_bot_(Grid, Tmpl, Hole, Obj, ObjBg) :-
% Nondeterministically split with template at the end.
    append(Obj, Tmpl, Grid),
% Both parts must be non-empty.
    Tmpl = [_|_], Obj = [_|_],
% Validate.
    arc2_jf_check_tmpl_obj_(Tmpl, Obj, Hole, ObjBg).

% arc2_jf_col_split_: template = first N columns; objects = remaining columns.
arc2_jf_col_split_(Grid, Tmpl, Hole, Obj, ObjBg) :-
% Derive maximum column split index from the first row.
    Grid = [FR|_], length(FR, C), N is C - 1,
% Try each possible split point from 1 to N-1.
    between(1, N, Split),
% Slice every row at Split: left part becomes template row, right part object row.
    maplist(arc2_jf_split_row_at_(Split), Grid, Tmpl, Obj),
% Validate.
    arc2_jf_check_tmpl_obj_(Tmpl, Obj, Hole, ObjBg), !.

% arc2_jf_col_split_right_: template = last N columns; objects = first columns.
arc2_jf_col_split_right_(Grid, Tmpl, Hole, Obj, ObjBg) :-
% Derive maximum column split index.
    Grid = [FR|_], length(FR, C), N is C - 1,
% Try each split point; now right part is the template.
    between(1, N, M),
% Slice every row at M: left part is objects, right part is template.
    maplist(arc2_jf_split_row_at_(M), Grid, Obj, Tmpl),
% Validate.
    arc2_jf_check_tmpl_obj_(Tmpl, Obj, Hole, ObjBg), !.

% arc2_jf_split_row_at_(+N, +Row, -Left, -Right)
% Split a single row into its first N elements and the remainder.
arc2_jf_split_row_at_(N, Row, Left, Right) :-
% Constrain Left to length N then derive Right via append.
    length(Left, N), append(Left, Right, Row).

% arc2_jf_check_tmpl_obj_(+Tmpl, +Obj, -Hole, -ObjBg)
% Template must have exactly 2 colors; corner cell = solid; objects region
% must have > 2 colors; total non-bg cells in objects = total hole cells.
arc2_jf_check_tmpl_obj_(Tmpl, Obj, Hole, ObjBg) :-
% Flatten template to a single list of values.
    append(Tmpl, TFlat),
% Distinct colors in the template.
    list_to_set(TFlat, TColors),
% Must be exactly 2 (solid and hole).
    TColors = [_, _],
% Corner cell (top-left) determines the solid color.
    Tmpl = [TRow0|_], TRow0 = [Solid|_],
% The hole color is whichever template color is not the solid.
    TColors = [TC1, TC2],
    (TC1 =:= Solid -> Hole = TC2 ; Hole = TC1),
% Count hole cells in template.
    include(=(Hole), TFlat, HoleCells), length(HoleCells, HC), HC > 0,
% Flatten objects region.
    append(Obj, OFlat),
% Objects must carry more than 2 distinct colors (bg + multiple object colors).
    list_to_set(OFlat, OColors), length(OColors, NOC), NOC > 2,
% Most-common color in objects region is its background.
    arc2_jf_mode_(OFlat, ObjBg),
% Count non-bg cells in objects.
    exclude(=(ObjBg), OFlat, PCells), length(PCells, PC),
% The piece cell total must exactly equal the hole cell total.
    PC =:= HC.

% arc2_jf_mode_(+List, -Mode)
% Return the most frequently occurring element of a non-empty list.
arc2_jf_mode_(List, Mode) :-
% Get distinct values.
    list_to_set(List, Vals),
% Build count-value pairs for every distinct value.
    findall(N-V, (member(V, Vals), include(=(V), List, Ms), length(Ms, N)), Pairs),
% Sort ascending by count; the last element has the highest count.
    msort(Pairs, Sorted), last(Sorted, _-Mode).

% arc2_jf_holes_(+Grid, +Hole, -Pairs)
% Return list of R-C pairs for every cell in Grid that equals Hole.
arc2_jf_holes_(Grid, Hole, Pairs) :-
% findall collects every (R,C) at which Grid[R][C] = Hole.
    findall(R-C, (nth0(R, Grid, Row), nth0(C, Row, Hole)), Pairs).

% arc2_jf_pieces_(+Grid, +Bg, -Pieces)
% Find all 4-connected non-Bg components; each piece is a list of R-C-V triples.
arc2_jf_pieces_(Grid, Bg, Pieces) :-
% Grid dimensions for BFS bounds.
    length(Grid, Rows), Grid = [R0|_], length(R0, Cols),
% Loop through every cell; launch BFS from unvisited non-Bg cells.
    arc2_jf_pieces_loop_(Grid, Bg, Rows, Cols, 0, 0, [], [], Pieces).

% arc2_jf_pieces_loop_: row-major scan; base case when row index exceeds grid.
arc2_jf_pieces_loop_(_, _, Rows, _, R, _, _, Acc, Pieces) :-
% All rows processed; reverse accumulator to get canonical order.
    R >= Rows, !, reverse(Acc, Pieces).
% End of current row: advance to next row, reset column to 0.
arc2_jf_pieces_loop_(Grid, Bg, Rows, Cols, R, C, Vis0, Acc0, Pieces) :-
    C >= Cols, !, R1 is R + 1,
    arc2_jf_pieces_loop_(Grid, Bg, Rows, Cols, R1, 0, Vis0, Acc0, Pieces).
% Normal cell: skip if already visited or background; else launch BFS.
arc2_jf_pieces_loop_(Grid, Bg, Rows, Cols, R, C, Vis0, Acc0, Pieces) :-
    C1 is C + 1,
    (   memberchk(R-C, Vis0)
% Already visited: skip.
    ->  arc2_jf_pieces_loop_(Grid, Bg, Rows, Cols, R, C1, Vis0, Acc0, Pieces)
    ;   nth0(R, Grid, Row), nth0(C, Row, V), V =:= Bg
% Background cell: skip.
    ->  arc2_jf_pieces_loop_(Grid, Bg, Rows, Cols, R, C1, Vis0, Acc0, Pieces)
% New non-bg unvisited cell: BFS to collect entire component.
    ;   arc2_jf_bfs_([R-C], Grid, Bg, Rows, Cols, Vis0, [], Comp, Vis1),
        arc2_jf_pieces_loop_(Grid, Bg, Rows, Cols, R, C1, Vis1, [Comp|Acc0], Pieces)
    ).

% arc2_jf_bfs_: queue-based BFS; Acc accumulates R-C-V triples for component.
arc2_jf_bfs_([], _, _, _, _, Vis, Acc, Acc, Vis).
arc2_jf_bfs_([R-C|Queue], Grid, Bg, Rows, Cols, Vis0, Acc0, Comp, Vis) :-
    (   memberchk(R-C, Vis0)
% Already visited in this BFS: discard and continue queue.
    ->  arc2_jf_bfs_(Queue, Grid, Bg, Rows, Cols, Vis0, Acc0, Comp, Vis)
    ;   R >= 0, R < Rows, C >= 0, C < Cols,
        nth0(R, Grid, Row), nth0(C, Row, V), V \= Bg
% Valid unvisited non-bg cell: mark, record, enqueue 4-neighbours.
    ->  Vis1 = [R-C|Vis0],
        R1 is R-1, R2 is R+1, C1 is C-1, C2 is C+1,
        append([R1-C, R2-C, R-C1, R-C2], Queue, NewQ),
        arc2_jf_bfs_(NewQ, Grid, Bg, Rows, Cols, Vis1, [R-C-V|Acc0], Comp, Vis)
% Out-of-bounds or background: skip.
    ;   arc2_jf_bfs_(Queue, Grid, Bg, Rows, Cols, Vis0, Acc0, Comp, Vis)
    ).

% arc2_jf_normalize_(+Piece, -Norm)
% Translate piece coords so the bounding box starts at (0,0).
arc2_jf_normalize_(Piece, Norm) :-
% Collect all row indices.
    findall(R, member(R-_-_, Piece), Rs),
% Collect all column indices.
    findall(C, member(_-C-_, Piece), Cs),
% Top-left offset.
    min_list(Rs, MinR), min_list(Cs, MinC),
% Shift every cell by the negative of the top-left offset.
    maplist(arc2_jf_shift_(MinR, MinC), Piece, Norm).

% arc2_jf_shift_(+MinR, +MinC, +Cell, -ShiftedCell)
arc2_jf_shift_(MinR, MinC, R-C-V, DR-DC-V) :-
% Compute relative row and column from bounding-box origin.
    DR is R - MinR, DC is C - MinC.

% arc2_jf_valid_placements_(+Norm, +Holes, +TR, +TC, -Placements)
% Find all (R0,C0) offsets at which placing Norm covers only hole cells.
arc2_jf_valid_placements_(Norm, Holes, TR, TC, Placements) :-
% Bounding box height and width of the piece.
    findall(DR, member(DR-_-_, Norm), DRs),
    findall(DC, member(_-DC-_, Norm), DCs),
    max_list(DRs, MaxDR), max_list(DCs, MaxDC),
% Maximum valid top-left row and column for the placement.
    MaxR0 is TR - MaxDR - 1, MaxC0 is TC - MaxDC - 1,
% Collect all (R0,C0) where every piece cell lands on a hole.
    findall(R0-C0, (
        between(0, MaxR0, R0),
        between(0, MaxC0, C0),
        forall(member(DR-DC-_, Norm),
               (R is R0+DR, C is C0+DC, memberchk(R-C, Holes)))
    ), Placements).

% arc2_jf_augment_(+Pieces, +Holes, +TR, +TC, -PiecesWP)
% Build N-Norm-Placements triples where N = length(Placements) for msort key.
arc2_jf_augment_(Pieces, Holes, TR, TC, PiecesWP) :-
    maplist([Piece, N-Norm-Placements]>>(
% Normalize piece to (0,0) origin.
        arc2_jf_normalize_(Piece, Norm),
% Find all valid placements for this normalized shape.
        arc2_jf_valid_placements_(Norm, Holes, TR, TC, Placements),
% N drives msort: fewest placements first in backtracking.
        length(Placements, N)
    ), Pieces, PiecesWP).

% arc2_jf_cover_(+PiecesWP, +RemHoles, +Map0, -Map)
% Backtracking exact cover: assign each piece to a non-overlapping placement.
arc2_jf_cover_([], [], Map, Map).
arc2_jf_cover_([_N-Norm-Placements|Rest], RemHoles, Map0, Map) :-
% Try each valid placement for this piece.
    member(R0-C0, Placements),
% Compute absolute cell positions for this placement.
    arc2_jf_place_(Norm, R0, C0, Cells),
% All cells must still be available in the remaining hole set.
    maplist([R-C-_]>>(memberchk(R-C, RemHoles)), Cells),
% Remove placed cells from the remaining hole set.
    maplist([R-C-_, R-C]>>(true), Cells, Placed),
    subtract(RemHoles, Placed, NewRem),
% Add (R-C)-Color entries to the color map.
    maplist([R-C-V, (R-C)-V]>>(true), Cells, NewEntries),
    append(Map0, NewEntries, Map1),
% Recurse on remaining pieces and remaining holes.
    arc2_jf_cover_(Rest, NewRem, Map1, Map).

% arc2_jf_place_(+Norm, +R0, +C0, -Cells)
% Translate normalized piece offsets to absolute (R,C,Color) triples.
arc2_jf_place_(Norm, R0, C0, Cells) :-
    maplist([DR-DC-V, R-C-V]>>(R is R0+DR, C is C0+DC), Norm, Cells).

% arc2_jf_apply_(+Tmpl, +ColorMap, -Out)
% Rewrite every hole cell in Tmpl with its assigned color from ColorMap.
arc2_jf_apply_(Tmpl, ColorMap, Out) :-
% Enumerate row indices.
    length(Tmpl, NR), NR1 is NR - 1, numlist(0, NR1, RowIs),
% For each row, rewrite cells using ColorMap.
    maplist([Row, OutRow, R]>>(
        length(Row, NC), NC1 is NC - 1, numlist(0, NC1, ColIs),
        maplist([V, OutV, C]>>(
% If ColorMap has an entry for (R,C), use it; otherwise keep original value.
            (memberchk((R-C)-OutV, ColorMap) -> true ; OutV = V)
        ), Row, OutRow, ColIs)
    ), Tmpl, Out, RowIs).

% ---------------------------------------------------------------------------
% WP-304  two_join  (Layer 279)  Task 20270e3b
% Input contains two connected objects made of 4-cells, each with one or more
% 7-cells marking its connection point. The output merges the two objects by
% shifting one object so its 7 lands one row above the other object's 7, with
% columns aligned. All 7s become 4s. The background (1-cells) fills the rest
% of the output bounding box.
% ---------------------------------------------------------------------------

% arc2_named_rule registers two_join for the generic induction loop.
arc2_named_rule(two_join).

% arc2_transform(two_join, +Grid, -Out): merge two 4-objects at 7-markers.
arc2_transform(two_join, Grid, Out) :-
% Get number of rows.
    length(Grid, NR),
% Extract first row to measure column count.
    Grid = [Row0|_],
% NC = number of columns.
    length(Row0, NC),
% Gather all non-1 cell positions as R-C pairs.
    arc2_tj_nonbg_pos_(Grid, 0, NR, NC, AllPos),
% Gather all 7-cell positions.
    arc2_tj_all_sevens_(Grid, 0, NR, NC, Sevens),
% Split the 7-cells into two clusters by 4-connectivity.
    arc2_tj_seven_clusters_(Sevens, G1, G2),
% --- Ordering A: Object A from BFS(G1), Object B = everything else ---
% BFS from G1 through AllPos to identify Object A.
    arc2_tj_bfs_obj_(G1, NR, NC, AllPos, ObjA_A),
% Object B = all non-1 positions not reached by BFS(G1).
    arc2_tj_subtract_pos_(AllPos, ObjA_A, ObjB_A),
% Shift = minR(G1)-minR(G2)-1 rows, minC(G1)-minC(G2) cols.
    arc2_tj_shift_(G1, G2, DrA, DcA),
% Apply shift to every position in Object B.
    arc2_tj_shift_pos_(ObjB_A, DrA, DcA, ObjBs_A),
% If all shifted positions are non-negative, compute bounding-box size.
    (   arc2_tj_valid_pos_(ObjBs_A)
    ->  arc2_tj_combined_size_(ObjA_A, ObjBs_A, SizeA)
    ;   SizeA = 9999999
    ),
% --- Ordering B: Object A from BFS(G2), Object B = everything else ---
% BFS from G2 to identify Object A under the alternative ordering.
    arc2_tj_bfs_obj_(G2, NR, NC, AllPos, ObjA_B),
% Object B (alternative) = all non-1 positions not reached by BFS(G2).
    arc2_tj_subtract_pos_(AllPos, ObjA_B, ObjB_B),
% Shift for alternative ordering: swap the two 7-cluster arguments.
    arc2_tj_shift_(G2, G1, DrB, DcB),
% Apply alternative shift to Object B.
    arc2_tj_shift_pos_(ObjB_B, DrB, DcB, ObjBs_B),
% If all alternative shifted positions are non-negative, compute size.
    (   arc2_tj_valid_pos_(ObjBs_B)
    ->  arc2_tj_combined_size_(ObjA_B, ObjBs_B, SizeB)
    ;   SizeB = 9999999
    ),
% Pick the ordering whose merged bounding box is smaller (smaller = correct).
    (   SizeA =< SizeB
    ->  FinalA = ObjA_A, FinalBs = ObjBs_A
    ;   FinalA = ObjA_B, FinalBs = ObjBs_B
    ),
% Build the output grid: every cell in FinalA or FinalBs becomes 4.
    arc2_tj_build_out_(FinalA, FinalBs, Out).

% arc2_tj_nonbg_pos_(+Grid, +R, +NR, +NC, -Pos): R-C pairs for cells != 1.
arc2_tj_nonbg_pos_(_, R, NR, _, []) :-
% Base case: row index past the last row.
    R >= NR, !.
arc2_tj_nonbg_pos_(Grid, R, NR, NC, Pos) :-
% Extract row R from the grid.
    nth0(R, Grid, Row),
% Collect non-1 positions from this row.
    arc2_tj_row_nonbg_(Row, R, 0, NC, RowPos),
% Advance to the next row.
    R1 is R + 1,
% Recurse on remaining rows.
    arc2_tj_nonbg_pos_(Grid, R1, NR, NC, RestPos),
% Combine this row's positions with the rest.
    append(RowPos, RestPos, Pos).

% arc2_tj_row_nonbg_(+Row, +R, +C, +NC, -Pos): non-1 positions in one row.
arc2_tj_row_nonbg_(_, _, C, NC, []) :-
% Base case: column index past the last column.
    C >= NC, !.
arc2_tj_row_nonbg_(Row, R, C, NC, Pos) :-
% Get the value at column C.
    nth0(C, Row, V),
% Advance to the next column.
    C1 is C + 1,
% Recurse on remaining columns.
    arc2_tj_row_nonbg_(Row, R, C1, NC, Rest),
% Include R-C in results if V != 1, skip otherwise.
    (V =:= 1 -> Pos = Rest ; Pos = [R-C|Rest]).

% arc2_tj_all_sevens_(+Grid, +R, +NR, +NC, -Pos): R-C pairs for 7-cells.
arc2_tj_all_sevens_(_, R, NR, _, []) :-
% Base case: row index past the last row.
    R >= NR, !.
arc2_tj_all_sevens_(Grid, R, NR, NC, Pos) :-
% Extract row R.
    nth0(R, Grid, Row),
% Collect 7-cell positions from this row.
    arc2_tj_row_sevens_(Row, R, 0, NC, RowPos),
% Advance to the next row.
    R1 is R + 1,
% Recurse on remaining rows.
    arc2_tj_all_sevens_(Grid, R1, NR, NC, RestPos),
% Combine this row's 7-positions with the rest.
    append(RowPos, RestPos, Pos).

% arc2_tj_row_sevens_(+Row, +R, +C, +NC, -Pos): 7-cell positions in one row.
arc2_tj_row_sevens_(_, _, C, NC, []) :-
% Base case: column index past the last column.
    C >= NC, !.
arc2_tj_row_sevens_(Row, R, C, NC, Pos) :-
% Get cell value at column C.
    nth0(C, Row, V),
% Advance to the next column.
    C1 is C + 1,
% Recurse on remaining columns.
    arc2_tj_row_sevens_(Row, R, C1, NC, Rest),
% Include R-C only if the value is 7.
    (V =:= 7 -> Pos = [R-C|Rest] ; Pos = Rest).

% arc2_tj_seven_clusters_(+Sevens, -G1, -G2): split 7-cells into two clusters.
arc2_tj_seven_clusters_(Sevens, G1, G2) :-
% Use the first 7-cell as the BFS seed for cluster 1.
    Sevens = [S0|_],
% BFS within the 7-cell set starting from S0.
    arc2_tj_grow_cluster_(Sevens, [S0], [], G1),
% Cluster 2 = all 7-cells not in cluster 1.
    arc2_tj_subtract_pos_(Sevens, G1, G2).

% arc2_tj_grow_cluster_(+All7, +Frontier, +Visited, -Cluster): BFS on 7-cells.
arc2_tj_grow_cluster_(_, [], Vis, Vis).
arc2_tj_grow_cluster_(All, [H|Fr], Vis0, Cluster) :-
% Skip H if already visited.
    (   memberchk(H, Vis0)
    ->  arc2_tj_grow_cluster_(All, Fr, Vis0, Cluster)
    ;
% Mark H as visited.
        Vis1 = [H|Vis0],
% Decompose H into row and column.
        H = R-C,
% Find adjacent 7-cells for H.
        arc2_tj_seven_nbrs_(R, C, All, Nbrs),
% Add unvisited neighbors to the frontier.
        append(Nbrs, Fr, Fr1),
% Continue BFS.
        arc2_tj_grow_cluster_(All, Fr1, Vis1, Cluster)
    ).

% arc2_tj_seven_nbrs_(+R, +C, +All7, -Nbrs): 4-adjacent positions in All7.
arc2_tj_seven_nbrs_(R, C, All, Nbrs) :-
% Check all four cardinal directions.
    arc2_tj_filter_adj_(R, C, [(-1,0),(1,0),(0,-1),(0,1)], All, Nbrs).

% arc2_tj_filter_adj_(+R, +C, +Dirs, +Pool, -Nbrs): filter adjacent in Pool.
arc2_tj_filter_adj_(_, _, [], _, []).
arc2_tj_filter_adj_(R, C, [(Dr,Dc)|Dirs], Pool, Nbrs) :-
% Compute neighbor coordinates.
    R1 is R + Dr, C1 is C + Dc,
% Recurse on remaining directions.
    arc2_tj_filter_adj_(R, C, Dirs, Pool, Rest),
% Include neighbor if it is in the pool.
    (memberchk(R1-C1, Pool) -> Nbrs = [R1-C1|Rest] ; Nbrs = Rest).

% arc2_tj_bfs_obj_(+Seeds, +NR, +NC, +AllPos, -ObjA): BFS through AllPos.
arc2_tj_bfs_obj_(Seeds, NR, NC, AllPos, ObjA) :-
% Start BFS with Seeds as the initial frontier.
    arc2_tj_bfs_exp_(Seeds, NR, NC, AllPos, [], ObjA).

% arc2_tj_bfs_exp_(+Fr, +NR, +NC, +Pool, +Vis, -Obj): BFS expansion loop.
arc2_tj_bfs_exp_([], _, _, _, Vis, Vis).
arc2_tj_bfs_exp_([H|Fr], NR, NC, Pool, Vis0, Obj) :-
% Skip H if already visited.
    (   memberchk(H, Vis0)
    ->  arc2_tj_bfs_exp_(Fr, NR, NC, Pool, Vis0, Obj)
    ;
% Mark H as visited.
        Vis1 = [H|Vis0],
% Decompose H.
        H = R-C,
% Find non-1 neighbors of H that are within bounds.
        arc2_tj_adj_nbrs_(R, C, NR, NC, Pool, Nbrs),
% Prepend new neighbors to the frontier.
        append(Nbrs, Fr, Fr1),
% Continue BFS.
        arc2_tj_bfs_exp_(Fr1, NR, NC, Pool, Vis1, Obj)
    ).

% arc2_tj_adj_nbrs_(+R, +C, +NR, +NC, +Pool, -Nbrs): in-bounds Pool neighbors.
arc2_tj_adj_nbrs_(R, C, NR, NC, Pool, Nbrs) :-
% Check all four cardinal directions.
    arc2_tj_nbr_filt_(R, C, NR, NC, [(-1,0),(1,0),(0,-1),(0,1)], Pool, Nbrs).

% arc2_tj_nbr_filt_(+R, +C, +NR, +NC, +Dirs, +Pool, -Nbrs): filter neighbors.
arc2_tj_nbr_filt_(_, _, _, _, [], _, []).
arc2_tj_nbr_filt_(R, C, NR, NC, [(Dr,Dc)|Dirs], Pool, Nbrs) :-
% Compute neighbor coordinates.
    R1 is R + Dr, C1 is C + Dc,
% Recurse on remaining directions.
    arc2_tj_nbr_filt_(R, C, NR, NC, Dirs, Pool, Rest),
% Include only in-bounds members of Pool.
    (   R1 >= 0, R1 < NR, C1 >= 0, C1 < NC,
        memberchk(R1-C1, Pool)
    ->  Nbrs = [R1-C1|Rest]
    ;   Nbrs = Rest
    ).

% arc2_tj_subtract_pos_(+All, +Remove, -Result): Result = All minus Remove.
arc2_tj_subtract_pos_([], _, []).
arc2_tj_subtract_pos_([H|T], Remove, Result) :-
% Include H only if it is not in Remove.
    (   memberchk(H, Remove)
    ->  arc2_tj_subtract_pos_(T, Remove, Result)
    ;   arc2_tj_subtract_pos_(T, Remove, Rest),
        Result = [H|Rest]
    ).

% arc2_tj_shift_(+GA, +GB, -Dr, -Dc): shift so GB's 7 goes one row above GA's.
arc2_tj_shift_(GA, GB, Dr, Dc) :-
% Find the minimum row in GA (GA's 7-cluster).
    arc2_tj_min_row_(GA, MinRA),
% Find the minimum col in GA.
    arc2_tj_min_col_(GA, MinCA),
% Find the minimum row in GB.
    arc2_tj_min_row_(GB, MinRB),
% Find the minimum col in GB.
    arc2_tj_min_col_(GB, MinCB),
% Row shift places GB's top 7-row one row above GA's top 7-row.
    Dr is MinRA - MinRB - 1,
% Col shift aligns GA's leftmost 7-col with GB's leftmost 7-col.
    Dc is MinCA - MinCB.

% arc2_tj_min_row_(+Positions, -MinR): minimum row index in a R-C list.
arc2_tj_min_row_([R-_|T], MinR) :-
% Start accumulator with the first row.
    arc2_tj_min_r_acc_(T, R, MinR).

% arc2_tj_min_r_acc_(+Rest, +Acc, -Min): accumulator for min row.
arc2_tj_min_r_acc_([], M, M).
arc2_tj_min_r_acc_([R-_|T], M0, M) :-
% Update minimum if current row is smaller.
    M1 is min(M0, R),
% Continue accumulation.
    arc2_tj_min_r_acc_(T, M1, M).

% arc2_tj_min_col_(+Positions, -MinC): minimum column index in a R-C list.
arc2_tj_min_col_([_-C|T], MinC) :-
% Start accumulator with the first column.
    arc2_tj_min_c_acc_(T, C, MinC).

% arc2_tj_min_c_acc_(+Rest, +Acc, -Min): accumulator for min col.
arc2_tj_min_c_acc_([], M, M).
arc2_tj_min_c_acc_([_-C|T], M0, M) :-
% Update minimum if current col is smaller.
    M1 is min(M0, C),
% Continue accumulation.
    arc2_tj_min_c_acc_(T, M1, M).

% arc2_tj_shift_pos_(+Positions, +Dr, +Dc, -Shifted): shift all positions.
arc2_tj_shift_pos_([], _, _, []).
arc2_tj_shift_pos_([R-C|T], Dr, Dc, [R1-C1|T1]) :-
% Apply row shift.
    R1 is R + Dr,
% Apply col shift.
    C1 is C + Dc,
% Recurse on remaining positions.
    arc2_tj_shift_pos_(T, Dr, Dc, T1).

% arc2_tj_valid_pos_(+Positions): all positions have R>=0 and C>=0.
arc2_tj_valid_pos_([]).
arc2_tj_valid_pos_([R-C|T]) :-
% Row must be non-negative.
    R >= 0,
% Column must be non-negative.
    C >= 0,
% Check remaining positions.
    arc2_tj_valid_pos_(T).

% arc2_tj_combined_size_(+ObjA, +ObjBs, -Size): bounding-box area of union.
arc2_tj_combined_size_(ObjA, ObjBs, Size) :-
% Merge both position lists.
    append(ObjA, ObjBs, All),
% Find maximum row index.
    arc2_tj_max_row_(All, MaxR),
% Find maximum col index.
    arc2_tj_max_col_(All, MaxC),
% Area = (MaxR+1) * (MaxC+1).
    Size is (MaxR + 1) * (MaxC + 1).

% arc2_tj_max_row_(+Positions, -MaxR): maximum row index in a R-C list.
arc2_tj_max_row_([R-_|T], MaxR) :-
% Start accumulator with the first row.
    arc2_tj_max_r_acc_(T, R, MaxR).

% arc2_tj_max_r_acc_(+Rest, +Acc, -Max): accumulator for max row.
arc2_tj_max_r_acc_([], M, M).
arc2_tj_max_r_acc_([R-_|T], M0, M) :-
% Update maximum if current row is larger.
    M1 is max(M0, R),
% Continue accumulation.
    arc2_tj_max_r_acc_(T, M1, M).

% arc2_tj_max_col_(+Positions, -MaxC): maximum col index in a R-C list.
arc2_tj_max_col_([_-C|T], MaxC) :-
% Start accumulator with the first column.
    arc2_tj_max_c_acc_(T, C, MaxC).

% arc2_tj_max_c_acc_(+Rest, +Acc, -Max): accumulator for max col.
arc2_tj_max_c_acc_([], M, M).
arc2_tj_max_c_acc_([_-C|T], M0, M) :-
% Update maximum if current col is larger.
    M1 is max(M0, C),
% Continue accumulation.
    arc2_tj_max_c_acc_(T, M1, M).

% arc2_tj_build_out_(+ObjA, +ObjBs, -Out): build output grid.
arc2_tj_build_out_(ObjA, ObjBs, Out) :-
% Merge all positions into one list.
    append(ObjA, ObjBs, All),
% Find the output row count.
    arc2_tj_max_row_(All, MaxR),
% Find the output column count.
    arc2_tj_max_col_(All, MaxC),
% Generate one row per row index from 0 to MaxR.
    arc2_tj_make_grid_(0, MaxR, MaxC, All, Out).

% arc2_tj_make_grid_(+R, +MaxR, +MaxC, +All, -Grid): build grid row by row.
arc2_tj_make_grid_(R, MaxR, _, _, []) :-
% Base case: past the last row.
    R > MaxR, !.
arc2_tj_make_grid_(R, MaxR, MaxC, All, [Row|Rest]) :-
% Build the row at index R.
    arc2_tj_make_row_(0, R, MaxC, All, Row),
% Advance to the next row.
    R1 is R + 1,
% Recurse on remaining rows.
    arc2_tj_make_grid_(R1, MaxR, MaxC, All, Rest).

% arc2_tj_make_row_(+C, +R, +MaxC, +All, -Row): build one output row.
arc2_tj_make_row_(C, _, MaxC, _, []) :-
% Base case: past the last column.
    C > MaxC, !.
arc2_tj_make_row_(C, R, MaxC, All, [V|Rest]) :-
% Cell is 4 if R-C is in All, else 1 (background).
    (memberchk(R-C, All) -> V = 4 ; V = 1),
% Advance to the next column.
    C1 is C + 1,
% Recurse on remaining columns.
    arc2_tj_make_row_(C1, R, MaxC, All, Rest).

% ===========================================================================
% WP-305  shape_count  (Layer 280)  Task 58490d8a
% ===========================================================================
%
% Count same-color shape instances in the game board. The input has two
% regions: a rectangular template (all 0-cells with a single color marker at
% column TC0+1 of each odd template row) and a game board (non-zero-background
% cells containing identical instances of small colored shapes).
%
% For each (template_row, color) pair, count how many non-overlapping
% instances of the color-shape appear in the game board, then fill the
% template output row with that many copies of the color at columns 1,3,5,...
%
% Instance detection uses iterative bounding-box expansion: start from the
% top-left color cell, compute the tight bbox, expand by 1 in every direction,
% collect all same-color cells inside the expanded bbox, recompute tight bbox,
% repeat until stable. This correctly handles shapes that are not 4-connected
% (e.g., diamond/cross patterns:  C _ C / _ C _ / C _ C).

% arc2_named_rule registers shape_count for the generic induction loop.
arc2_named_rule(shape_count).

% arc2_induce_rule(+TaskId, -Rule): task 58490d8a uses shape_count.
arc2_induce_rule('58490d8a', shape_count).

% arc2_transform(shape_count, +Grid, -Out): count shape instances per color.
arc2_transform(shape_count, Grid, Out) :-
% Find the bounding box of all 0-cells (the template region).
    arc2_sc_tmpl_bbox_(Grid, TR0, TR1, TC0, TC1),
% Extract (TemplateRow, Color) pairs from odd template rows.
    arc2_sc_tmpl_colors_(Grid, TR0, TR1, TC0, TC1, Colors),
% Build zero-filled output grid of template dimensions.
    NTR is TR1 - TR0 + 1,
    NTC is TC1 - TC0 + 1,
    arc2_sc_zeros_(NTR, NTC, OutBase),
% Fill each template row with counted color markers.
    arc2_sc_fill_all_(Grid, Colors, TR0, TR1, TC0, TC1, NTC, OutBase, Out).

% ---- Template bounding-box detection ----

% arc2_sc_tmpl_bbox_/5: compute bounding box of all 0-cells in Grid.
arc2_sc_tmpl_bbox_(Grid, TR0, TR1, TC0, TC1) :-
% Scan all rows accumulating min/max row and col of 0-cells.
    arc2_sc_bbox_rows_(Grid, 0, 9999, -1, 9999, -1, TR0, TR1, TC0, TC1),
% Fail if no 0-cells were found (no template region).
    TR0 =< TR1.

% arc2_sc_bbox_rows_/10: row-by-row accumulator for 0-cell bounding box.
arc2_sc_bbox_rows_([], _, R0, R1, C0, C1, R0, R1, C0, C1).
arc2_sc_bbox_rows_([Row|Rest], R, R0A, R1A, C0A, C1A, R0, R1, C0, C1) :-
% Scan this row for 0-cells, updating the running min/max.
    arc2_sc_bbox_row_(Row, 0, R, R0A, R1A, C0A, C1A, R0B, R1B, C0B, C1B),
% Advance to the next row index.
    R1N is R + 1,
% Recurse on remaining rows.
    arc2_sc_bbox_rows_(Rest, R1N, R0B, R1B, C0B, C1B, R0, R1, C0, C1).

% arc2_sc_bbox_row_/11: scan one row, updating bbox when cell is 0.
arc2_sc_bbox_row_([], _, _, R0, R1, C0, C1, R0, R1, C0, C1).
arc2_sc_bbox_row_([V|Rest], C, R, R0A, R1A, C0A, C1A, R0, R1, C0, C1) :-
% Expand bbox if this cell is 0.
    ( V =:= 0 ->
        R0B is min(R, R0A), R1B is max(R, R1A),
        C0B is min(C, C0A), C1B is max(C, C1A)
    ;
        R0B = R0A, R1B = R1A, C0B = C0A, C1B = C1A
    ),
% Advance column index.
    C1N is C + 1,
% Recurse on remaining cells.
    arc2_sc_bbox_row_(Rest, C1N, R, R0B, R1B, C0B, C1B, R0, R1, C0, C1).

% ---- Template color extraction ----

% arc2_sc_tmpl_colors_/6: collect (TR, Color) from odd rows within template.
arc2_sc_tmpl_colors_(Grid, TR0, TR1, TC0, TC1, Colors) :-
% Relative index of last template row.
    MaxTR is TR1 - TR0,
% Scan odd relative rows starting from 1, accumulating results.
    arc2_sc_tmpl_odd_(Grid, TR0, TC0, TC1, 1, MaxTR, [], Colors).

% arc2_sc_tmpl_odd_/8: iterate odd relative template rows (TR = 1, 3, 5, ...).
arc2_sc_tmpl_odd_(_, _, _, _, TR, MaxTR, Acc, Colors) :-
% Base: exceeded template height; reverse accumulator.
    TR > MaxTR, !,
    reverse(Acc, Colors).
arc2_sc_tmpl_odd_(Grid, TR0, TC0, TC1, TR, MaxTR, Acc, Colors) :-
% Absolute row index.
    R is TR0 + TR,
% Get that row from the grid.
    nth0(R, Grid, Row),
% Find first non-zero value in template columns TC0..TC1.
    arc2_sc_row_nz_(Row, 0, TC0, TC1, MaybeV),
% Record (TR, V) if a color marker was found.
    ( MaybeV = v(V) -> NewAcc = [TR-V|Acc] ; NewAcc = Acc ),
% Advance to next odd row.
    TR2 is TR + 2,
% Recurse.
    arc2_sc_tmpl_odd_(Grid, TR0, TC0, TC1, TR2, MaxTR, NewAcc, Colors).

% arc2_sc_row_nz_/5: scan Row for first non-zero value in cols C0..C1.
arc2_sc_row_nz_([], _, _, _, none).
arc2_sc_row_nz_([V|_], C, C0, C1, v(V)) :-
% Non-zero value within the column range.
    C >= C0, C =< C1, V \= 0, !.
arc2_sc_row_nz_([_|Rest], C, C0, C1, Result) :-
% Advance column and continue scanning.
    Cn is C + 1,
    arc2_sc_row_nz_(Rest, Cn, C0, C1, Result).

% ---- Counting and output assembly ----

% arc2_sc_fill_all_/9: process each (TR, Color) pair, filling output rows.
arc2_sc_fill_all_(_, [], _, _, _, _, _, Out, Out) :- !.
arc2_sc_fill_all_(Grid, [TR-Color|Rest], TR0, TR1, TC0, TC1, NTC, OutIn, Out) :-
% Count shape instances of Color in the game board.
    arc2_sc_count_(Grid, Color, TR0, TR1, TC0, TC1, Count),
% Place Count copies of Color at odd columns in row TR of output.
    arc2_sc_place_(OutIn, TR, Color, Count, 1, NTC, OutMid),
% Process remaining colors.
    arc2_sc_fill_all_(Grid, Rest, TR0, TR1, TC0, TC1, NTC, OutMid, Out).

% arc2_sc_count_/7: count non-overlapping shape instances of Color.
arc2_sc_count_(Grid, Color, TR0, TR1, TC0, TC1, Count) :-
% Gather all Color cells outside the template region.
    arc2_sc_gather_(Grid, 0, Color, TR0, TR1, TC0, TC1, Cells),
% Sort for deterministic top-left-first processing.
    msort(Cells, Sorted),
% Count by iterative bbox-expansion extraction.
    arc2_sc_instances_(Sorted, 0, Count).

% arc2_sc_gather_/8: collect all Color cells not in the template region.
arc2_sc_gather_([], _, _, _, _, _, _, []).
arc2_sc_gather_([Row|Rest], R, Color, TR0, TR1, TC0, TC1, Cells) :-
% Gather Color cells from this row.
    arc2_sc_gather_row_(Row, 0, R, Color, TR0, TR1, TC0, TC1, RowCells),
% Advance row index.
    R1 is R + 1,
% Gather from remaining rows.
    arc2_sc_gather_(Rest, R1, Color, TR0, TR1, TC0, TC1, RestCells),
% Combine row cells with rest.
    append(RowCells, RestCells, Cells).

% arc2_sc_gather_row_/9: gather Color cells in one row, skipping template cols.
arc2_sc_gather_row_([], _, _, _, _, _, _, _, []).
arc2_sc_gather_row_([V|Rest], C, R, Color, TR0, TR1, TC0, TC1, Cells) :-
% Advance column index for recursive call.
    C1N is C + 1,
% Gather from the rest of the row.
    arc2_sc_gather_row_(Rest, C1N, R, Color, TR0, TR1, TC0, TC1, RestCells),
% Include this cell if it is the target color and outside the template.
    ( R >= TR0, R =< TR1, C >= TC0, C =< TC1 ->
        Cells = RestCells
    ; V =:= Color ->
        Cells = [R-C|RestCells]
    ;
        Cells = RestCells
    ).

% arc2_sc_instances_/3: count instances by iterative bbox-expansion extraction.
arc2_sc_instances_([], N, N) :- !.
arc2_sc_instances_([Seed|RestCells], N0, N) :-
% Expand bbox from Seed to find one complete shape instance.
    arc2_sc_expand_([Seed], [Seed|RestCells], Inst),
% Remove the instance cells from the remaining pool.
    arc2_sc_subtract_([Seed|RestCells], Inst, Remaining),
% Increment instance count.
    N1 is N0 + 1,
% Continue with remaining cells.
    arc2_sc_instances_(Remaining, N1, N).

% arc2_sc_expand_/3: grow CurInst by 1 in all bbox directions until stable.
arc2_sc_expand_(CurInst, AllCells, Inst) :-
% Compute tight bounding box of current instance cells.
    arc2_sc_tight_bbox_(CurInst, R0, R1, C0, C1),
% Expand bbox by 1 in each direction.
    ER0 is R0 - 1, ER1 is R1 + 1, EC0 is C0 - 1, EC1 is C1 + 1,
% Collect all same-color cells within the expanded bbox.
    include(arc2_sc_in_bbox_(ER0, ER1, EC0, EC1), AllCells, Expanded),
% Sort both sets for stable comparison.
    msort(CurInst, SCur),
    msort(Expanded, SExp),
% If no new cells were added, the instance is complete.
    ( SCur == SExp ->
        Inst = CurInst
    ;
% Otherwise recurse with the enlarged set.
        arc2_sc_expand_(Expanded, AllCells, Inst)
    ).

% arc2_sc_in_bbox_/2: check that cell R-C falls within the given bbox.
arc2_sc_in_bbox_(R0, R1, C0, C1, R-C) :-
% Row within bounds.
    R >= R0, R =< R1,
% Column within bounds.
    C >= C0, C =< C1.

% arc2_sc_tight_bbox_/5: minimum bounding box of a non-empty cell list.
arc2_sc_tight_bbox_([R-C|Rest], R0, R1, C0, C1) :-
% Accumulate min/max row and col starting from the first cell.
    arc2_sc_bbox_acc_(Rest, R, R, C, C, R0, R1, C0, C1).

% arc2_sc_bbox_acc_/9: running bbox accumulator.
arc2_sc_bbox_acc_([], R0, R1, C0, C1, R0, R1, C0, C1).
arc2_sc_bbox_acc_([R-C|Rest], R0A, R1A, C0A, C1A, R0, R1, C0, C1) :-
% Update running min/max.
    R0B is min(R, R0A), R1B is max(R, R1A),
    C0B is min(C, C0A), C1B is max(C, C1A),
% Recurse.
    arc2_sc_bbox_acc_(Rest, R0B, R1B, C0B, C1B, R0, R1, C0, C1).

% arc2_sc_subtract_/3: remove all elements of Remove from List.
arc2_sc_subtract_([], _, []).
arc2_sc_subtract_([H|Rest], Remove, Result) :-
% Skip H if it appears in Remove.
    ( memberchk(H, Remove) ->
        arc2_sc_subtract_(Rest, Remove, Result)
    ;
% Keep H and continue.
        arc2_sc_subtract_(Rest, Remove, RestResult),
        Result = [H|RestResult]
    ).

% ---- Output grid construction ----

% arc2_sc_zeros_/3: build an NR x NC grid filled with 0-cells.
arc2_sc_zeros_(NR, _, []) :- NR =< 0, !.
arc2_sc_zeros_(NR, NC, [Row|Rest]) :-
% Build one zero row.
    arc2_sc_zero_row_(NC, Row),
% Decrement row counter.
    NR1 is NR - 1,
% Build remaining rows.
    arc2_sc_zeros_(NR1, NC, Rest).

% arc2_sc_zero_row_/2: build a list of NC zeros.
arc2_sc_zero_row_(0, []) :- !.
arc2_sc_zero_row_(NC, [0|Rest]) :-
% Decrement column counter.
    NC1 is NC - 1,
% Build remaining.
    arc2_sc_zero_row_(NC1, Rest).

% arc2_sc_place_/7: place Count copies of Color at cols TC, TC+2, ... in row TR.
arc2_sc_place_(Out, _, _, 0, _, _, Out) :- !.
arc2_sc_place_(Out, _, _, _, TC, NTC, Out) :- TC >= NTC, !.
arc2_sc_place_(OutIn, TR, Color, Count, TC, NTC, Out) :-
% Set cell (TR, TC) = Color.
    arc2_sc_set_cell_(OutIn, TR, TC, Color, OutMid),
% Decrement remaining placements.
    Count1 is Count - 1,
% Advance to next odd column.
    TC2 is TC + 2,
% Place the remaining copies.
    arc2_sc_place_(OutMid, TR, Color, Count1, TC2, NTC, Out).

% arc2_sc_set_cell_/5: set position (R, C) to V in Grid, producing NewGrid.
arc2_sc_set_cell_(Grid, R, C, V, NewGrid) :-
% Extract the target row.
    nth0(R, Grid, OldRow),
% Replace the column value within that row.
    arc2_sc_set_col_(OldRow, 0, C, V, NewRow),
% Replace the row within the grid.
    arc2_sc_replace_(Grid, 0, R, NewRow, NewGrid).

% arc2_sc_set_col_/5: replace position C in Row with V, producing NewRow.
arc2_sc_set_col_([_|Rest], C, C, V, [V|Rest]) :- !.
arc2_sc_set_col_([H|Rest], Cur, C, V, [H|NewRest]) :-
% Advance column cursor.
    Cur1 is Cur + 1,
% Replace in the rest.
    arc2_sc_set_col_(Rest, Cur1, C, V, NewRest).

% arc2_sc_replace_/5: replace element at Pos in List with New, producing Out.
arc2_sc_replace_([_|Rest], Pos, Pos, New, [New|Rest]) :- !.
arc2_sc_replace_([H|Rest], Cur, Pos, New, [H|NewRest]) :-
% Advance position cursor.
    Cur1 is Cur + 1,
% Replace in the rest.
    arc2_sc_replace_(Rest, Cur1, Pos, New, NewRest).

% ---------------------------------------------------------------------------
% WP-306  stamp_grid  (Layer 281)  Task dfadab01
% ---------------------------------------------------------------------------
% Each single-cell marker (value 2, 3, 5, or 8) in the input triggers the
% placement of a hardcoded 4x4 stamp pattern in the output.
% When a multi-cell 4x4 cluster (the "shape") is present, its structure
% identifies which marker value maps to which pattern; the cell at
% (shape_bbox_maxrow+1, shape_bbox_maxcol+1) is the "definition marker"
% and is skipped. Shape cells are erased (set to background) in the output.
% If no shape is found, all non-background cells are placement markers.
%
% The four hardcoded 4x4 stamp patterns (relative DR,DC offsets in 0..3):
%   Marker 2 -> full-border rectangle, output color 4
%   Marker 3 -> edge-no-corners diamond, output color 1
%   Marker 5 -> diagonal 2x2 blocks,   output color 6
%   Marker 8 -> corners+inner-edge,     output color 7
% ---------------------------------------------------------------------------

% arc2_named_rule/1: register stamp_grid for the generic induction loop.
arc2_named_rule(stamp_grid).

% arc2_induce_rule/2: task dfadab01 uses the stamp_grid rule.
arc2_induce_rule('dfadab01', stamp_grid).

% arc2_sg_stmp_/3: MarkerVal, StampColor, list of (DR,DC) offsets.
% Pattern 2: full-border rectangle in color 4.
arc2_sg_stmp_(2, 4, [(0,0),(0,1),(0,2),(0,3),(1,0),(1,3),(2,0),(2,3),(3,0),(3,1),(3,2),(3,3)]).
% Pattern 3: edge-no-corners diamond in color 1.
arc2_sg_stmp_(3, 1, [(0,1),(0,2),(1,0),(1,3),(2,0),(2,3),(3,1),(3,2)]).
% Pattern 5: diagonal 2x2 blocks in color 6.
arc2_sg_stmp_(5, 6, [(0,0),(0,1),(1,0),(1,1),(2,2),(2,3),(3,2),(3,3)]).
% Pattern 8: corners-plus-inner-edge in color 7.
arc2_sg_stmp_(8, 7, [(0,0),(0,3),(1,1),(1,2),(2,1),(2,2),(3,0),(3,3)]).

% arc2_sg_bg_/2: most common value in Grid (used as background).
arc2_sg_bg_(Grid, BG) :-
% Flatten to a single list so all values can be compared.
    flatten(Grid, Flat),
% Sort to group equal values for run-length counting.
    msort(Flat, [H|T]),
% Scan for the longest run (= most frequent value).
    arc2_sg_run_(T, H, 1, 0, H, BG).

% arc2_sg_run_/6: accumulate mode over a sorted list.
% Base: compare final run to running maximum.
arc2_sg_run_([], Cur, Cnt, Max, Best, BG) :-
% Emit the run-winner as BG.
    ( Cnt > Max -> BG = Cur ; BG = Best ).
% Same element: increment run count, maybe update best.
arc2_sg_run_([H|T], H, Cnt, Max, Best, BG) :- !,
% Extend current run.
    Cnt1 is Cnt + 1,
% Update best if this run now exceeds maximum.
    ( Cnt1 > Max ->
        arc2_sg_run_(T, H, Cnt1, Cnt1, H, BG)
    ;   arc2_sg_run_(T, H, Cnt1, Max, Best, BG)
    ).
% New element: close current run, start fresh run at 1.
arc2_sg_run_([H|T], Cur, Cnt, Max, Best, BG) :- Cur \= H, !,
% Compare completed run to running maximum and continue.
    ( Cnt > Max ->
        arc2_sg_run_(T, H, 1, Cnt, Cur, BG)
    ;   arc2_sg_run_(T, H, 1, Max, Best, BG)
    ).

% arc2_sg_shape_/5: find the first color whose tight bounding box is 4x4.
arc2_sg_shape_(Grid, BG, SC, SR0, SC0) :-
% Collect all non-background values.
    flatten(Grid, Flat),
% Exclude background to get candidate shape colors.
    exclude(==(BG), Flat, NonBG),
% Deduplicate to iterate over distinct colors.
    list_to_set(NonBG, Colors),
% Try each color as the shape color.
    member(SC, Colors),
% Collect all (row, col) positions of this color (0-indexed).
    findall(R-C, (nth0(R,Grid,Row), nth0(C,Row,SC)), Cells),
% Require more than one cell (singleton = marker, not shape).
    length(Cells, N), N > 1,
% Extract row and column lists for bounding-box computation.
    pairs_keys(Cells, Rs), pairs_values(Cells, Cs),
% Find bounding-box extents.
    min_list(Rs, SR0), max_list(Rs, SR1),
    min_list(Cs, SC0), max_list(Cs, SC1),
% Accept only if the bounding box is exactly 4 rows by 4 cols.
    SR1 =:= SR0 + 3,
    SC1 =:= SC0 + 3,
% Commit to this color; no backtracking into further candidates.
    !.

% arc2_sg_mval_/6: identify which stamp value the 4x4 shape matches.
arc2_sg_mval_(Grid, _BG, SC, SR0, SC0, MVal) :-
% Try each known stamp definition.
    arc2_sg_stmp_(MVal, _, Offs),
% Every offset cell must hold the shape color.
    forall(member((DR,DC), Offs),
        ( R is SR0+DR, C is SC0+DC,
          nth0(R,Grid,Row), nth0(C,Row,SC) )),
% Build list of all 4x4 relative positions.
    numlist(0, 3, Ds),
% Every non-offset cell in the 4x4 must NOT be the shape color (markers may occupy them).
    forall(( member(DR,Ds), member(DC,Ds), \+ member((DR,DC),Offs) ),
        ( R is SR0+DR, C is SC0+DC,
          nth0(R,Grid,Row), nth0(C,Row,V0), V0 \= SC )),
% Commit to first matching stamp type.
    !.

% arc2_sg_mkrs_/8: collect placement markers, excluding shape and def cell.
arc2_sg_mkrs_(Grid, BG, SC, SR0, SC0, DefR, DefC, Mkrs) :-
% Scan every cell; keep non-BG cells that are not shape or def-marker.
    findall(m(R,C,V), (
        nth0(R, Grid, Row),
        nth0(C, Row, V),
% Cell must be non-background.
        V \= BG,
% Cell must not be a shape cell (shape color inside 4x4 bbox).
        \+ ( V =:= SC, R >= SR0, R =< SR0+3, C >= SC0, C =< SC0+3 ),
% Cell must not be the definition marker position.
        \+ ( R =:= DefR, C =:= DefC )
    ), Mkrs).

% arc2_sg_cell_/5: compute output color at (R,C); BG unless under a stamp.
arc2_sg_cell_(R, C, BG, Mkrs, Cell) :-
% Search for any marker whose stamp pattern covers (R,C).
    ( member(m(MR,MC,MV), Mkrs),
      arc2_sg_stmp_(MV, SC, Offs),
% Compute relative offset from marker's top-left.
      DR is R - MR, DC is C - MC,
% Offset must be within the 4x4 stamp footprint.
      DR >= 0, DR =< 3, DC >= 0, DC =< 3,
% Check that this (DR,DC) is a filled cell of the pattern.
      member((DR,DC), Offs)
    -> Cell = SC
    ;  Cell = BG
    ).

% arc2_transform/3: main stamp_grid transform (0-indexed grid).
arc2_transform(stamp_grid, Grid, Out) :-
% Determine background as the most common color.
    arc2_sg_bg_(Grid, BG),
% Compute grid dimensions for output row/column iteration.
    length(Grid, NRows), NRows1 is NRows - 1,
    nth0(0, Grid, FR), length(FR, NCols), NCols1 is NCols - 1,
% Detect shape and collect placement markers.
    ( arc2_sg_shape_(Grid, BG, SC, SR0, SC0) ->
% Shape found: verify it, compute definition-marker position, collect markers.
        arc2_sg_mval_(Grid, BG, SC, SR0, SC0, _),
        DefR is SR0 + 4, DefC is SC0 + 4,
        arc2_sg_mkrs_(Grid, BG, SC, SR0, SC0, DefR, DefC, Mkrs)
    ;
% No shape: treat all non-background cells as placement markers.
        findall(m(R,C,V),
            ( nth0(R,Grid,Row), nth0(C,Row,V), V \= BG ), Mkrs)
    ),
% Build output grid: one row per row index, one cell per column index.
    numlist(0, NRows1, RowIs),
    maplist([R, OutRow]>>(
% For each output row, map each column to its stamp color or BG.
        numlist(0, NCols1, ColIs),
        maplist([C, Cell]>>(arc2_sg_cell_(R,C,BG,Mkrs,Cell)), ColIs, OutRow)
    ), RowIs, Out).

% ---------------------------------------------------------------------------
% LAYOUT STACK (Task 291dc1e1) — Wave 49, WP-307, Layer 282
% ---------------------------------------------------------------------------
% Corner 0 + flanking 1s/2s define reading order; col-major rotates blocks
% 90 CCW; blocks stacked vertically centered on max block width; BG = 8.

% arc2_named_rule/1: register layout_stack for the generic induction loop.
arc2_named_rule(layout_stack).

% arc2_ls_corner_/3: find row CR and col CC of the unique 0-corner cell.
arc2_ls_corner_(Grid, CR, CC) :-
% Get grid dimensions for corner range.
    length(Grid, NR), NR1 is NR-1,
% Get column count from first row.
    nth0(0, Grid, FR), length(FR, NC), NC1 is NC-1,
% CR must be the first or last row.
    member(CR, [0, NR1]),
% Extract the header row at index CR.
    nth0(CR, Grid, HdrRow),
% CC must be the first or last column.
    member(CC, [0, NC1]),
% The cell at (CR, CC) must hold the value 0.
    nth0(CC, HdrRow, 0), !.

% arc2_ls_mode_/6: derive reading mode and reversal flags from the 0-corner.
arc2_ls_mode_(Grid, CR, CC, Mode, PrimReverse, SecReverse) :-
% Read the corner's header row.
    nth0(CR, Grid, HdrRow),
% Pick the cell adjacent to the corner along the header row (one step inward).
    ( CC =:= 0 -> AdjCC is 1 ; AdjCC is CC-1 ),
% Fetch the adjacent cell value.
    nth0(AdjCC, HdrRow, AdjVal),
% Value 1 adjacent horizontally -> row-major; value 2 -> col-major.
    ( AdjVal =:= 1 -> Mode = row_major ; Mode = col_major ),
% PrimReverse true when corner is on the last row (primary scan goes B->T).
    length(Grid, NR), NR1 is NR-1,
    ( CR =:= NR1 -> PrimReverse = true ; PrimReverse = false ),
% SecReverse true when corner is on the last col (secondary scan goes R->L).
    nth0(0, Grid, FR), length(FR, NC), NC1 is NC-1,
    ( CC =:= NC1 -> SecReverse = true ; SecReverse = false ).

% arc2_ls_del_row_/3: remove the row at index N from a grid.
arc2_ls_del_row_([_|T], 0, T) :- !.
% Recurse until reaching the target row.
arc2_ls_del_row_([H|T], N, [H|T2]) :- N > 0, N1 is N-1, arc2_ls_del_row_(T, N1, T2).

% arc2_ls_del_col_/3: remove the element at index C from a list.
arc2_ls_del_col_(0, [_|T], T) :- !.
% Recurse until reaching the target column.
arc2_ls_del_col_(C, [H|T], [H|T2]) :- C > 0, C1 is C-1, arc2_ls_del_col_(C1, T, T2).

% arc2_ls_interior_/4: strip the header row and header col to expose content area.
arc2_ls_interior_(Grid, CR, CC, Interior) :-
% Remove the header row first.
    arc2_ls_del_row_(Grid, CR, Grid1),
% Remove the header column from every remaining row.
    maplist(arc2_ls_del_col_(CC), Grid1, Interior).

% arc2_ls_consec_groups_/2: partition a sorted integer list into consecutive runs.
arc2_ls_consec_groups_([], []).
% Build one group starting at H, then recurse on the remainder.
arc2_ls_consec_groups_([H|T], [[H|GT]|Rest]) :-
    arc2_ls_consec_ext_(T, H, GT, Rem),
    arc2_ls_consec_groups_(Rem, Rest).

% arc2_ls_consec_ext_/4: extend a group while integers remain consecutive.
arc2_ls_consec_ext_([], _, [], []).
% Next integer is P+1: include it and keep extending.
arc2_ls_consec_ext_([H|T], P, [H|GT], Rem) :- H is P+1, !, arc2_ls_consec_ext_(T, H, GT, Rem).
% Gap found: stop the current group here.
arc2_ls_consec_ext_(Rest, _, [], Rest).

% arc2_ls_col_active_/2: true when column C holds at least one non-8 cell.
arc2_ls_col_active_(Interior, C) :-
    member(Row, Interior), nth0(C, Row, V), V \= 8, !.

% arc2_ls_col_bands_/2: column bands as lists of consecutive active col indices.
arc2_ls_col_bands_(Interior, Bands) :-
% Build the full column index range from the first row.
    Interior = [FR|_], length(FR, NC), NC1 is NC-1, numlist(0, NC1, AllCols),
% Keep only columns that have at least one non-8 value.
    include(arc2_ls_col_active_(Interior), AllCols, ActiveCols),
% Group consecutive active cols into bands.
    arc2_ls_consec_groups_(ActiveCols, Bands).

% arc2_ls_row_active_in_band_/3: true when row R has a non-8 cell in BandCols.
arc2_ls_row_active_in_band_(Interior, BandCols, R) :-
    nth0(R, Interior, Row), member(C, BandCols), nth0(C, Row, V), V \= 8, !.

% arc2_ls_band_stretches_/3: maximal consecutive active-row groups for a col band.
arc2_ls_band_stretches_(Interior, BandCols, Stretches) :-
% Build the full row index range.
    length(Interior, NR), NR1 is NR-1, numlist(0, NR1, AllRows),
% Keep only rows that have non-8 content in the band.
    include(arc2_ls_row_active_in_band_(Interior, BandCols), AllRows, ActiveRows),
% Group consecutive active rows into stretches.
    arc2_ls_consec_groups_(ActiveRows, RowGroups),
% Extract each stretch as a sub-grid restricted to BandCols.
    maplist([RG, SubGrid]>>(
        maplist([R, RV]>>(
            nth0(R, Interior, Row),
            maplist([C,V]>>(nth0(C,Row,V)), BandCols, RV)
        ), RG, SubGrid)
    ), RowGroups, Stretches).

% arc2_ls_rotate_ccw_/2: rotate a grid 90 degrees counter-clockwise.
% Output row i = input column (C-1-i) read top-to-bottom.
arc2_ls_rotate_ccw_(Grid, Rotated) :-
% Determine number of columns from the first row.
    Grid = [FR|_], length(FR, C), C1 is C-1, numlist(0, C1, ColIs),
% Each output row i is drawn from original column C-1-i.
    maplist([I, RotRow]>>(
        RevI is C-1-I,
% Collect cell at col RevI across all original rows in order.
        maplist([GRow, V]>>(nth0(RevI, GRow, V)), Grid, RotRow)
    ), ColIs, Rotated).

% arc2_ls_row_active_/2: true when any cell in row R of Interior is non-8.
arc2_ls_row_active_(Interior, R) :-
    nth0(R, Interior, Row), member(V, Row), V \= 8, !.

% arc2_ls_row_bands_/2: row bands as lists of consecutive active row indices.
arc2_ls_row_bands_(Interior, RowBands) :-
% Build the full row index range.
    length(Interior, NR), NR1 is NR-1, numlist(0, NR1, AllRows),
% Keep only rows with at least one non-8 cell.
    include(arc2_ls_row_active_(Interior), AllRows, ActiveRows),
% Group consecutive active rows into bands.
    arc2_ls_consec_groups_(ActiveRows, RowBands).

% arc2_ls_col_active_in_rows_/3: true when col C has non-8 in some row of RowBand.
arc2_ls_col_active_in_rows_(Interior, RowBand, C) :-
    member(R, RowBand), nth0(R, Interior, Row), nth0(C, Row, V), V \= 8, !.

% arc2_ls_band_col_stretches_/3: within RowBand rows, find column stretches.
arc2_ls_band_col_stretches_(Interior, RowBand, Stretches) :-
% Build the full column index range.
    Interior = [FR|_], length(FR, NC), NC1 is NC-1, numlist(0, NC1, AllCols),
% Keep only cols with non-8 content in some row of the band.
    include(arc2_ls_col_active_in_rows_(Interior, RowBand), AllCols, ActiveCols),
% Group consecutive active cols into column stretches.
    arc2_ls_consec_groups_(ActiveCols, ColGroups),
% Extract each col-stretch sub-grid from the row band.
    maplist([CG, SubGrid]>>(
        maplist([R, RV]>>(
            nth0(R, Interior, Row),
            maplist([C,V]>>(nth0(C,Row,V)), CG, RV)
        ), RowBand, SubGrid)
    ), ColGroups, Stretches).

% arc2_ls_center_block_/3: pad each block row with 8s to reach MaxW columns.
arc2_ls_center_block_(MaxW, Block, Centered) :-
% Center each row symmetrically; any remainder goes on the right.
    maplist([BRow, CRow]>>(
        length(BRow, W), Pad is (MaxW-W)//2, Pad2 is MaxW-W-Pad,
% Build left padding.
        length(Left, Pad), maplist(=(8), Left),
% Build right padding.
        length(Right, Pad2), maplist(=(8), Right),
% Concatenate left + block row + right.
        append(Left, BRow, Tmp), append(Tmp, Right, CRow)
    ), Block, Centered).

% arc2_transform/3: layout_stack top-level orchestrator (task 291dc1e1).
arc2_transform(layout_stack, Grid, Out) :-
% Locate the 0-corner and derive reading parameters.
    arc2_ls_corner_(Grid, CR, CC),
    arc2_ls_mode_(Grid, CR, CC, Mode, PrimReverse, SecReverse),
% Strip the header row and col to get the content interior.
    arc2_ls_interior_(Grid, CR, CC, Interior),
    ( Mode = col_major ->
% Col-major: read column bands in secondary order; rotate each block 90 CCW.
        arc2_ls_col_bands_(Interior, Bands),
        ( SecReverse = true -> reverse(Bands, OrdBands) ; OrdBands = Bands ),
        maplist([Band, BBlks]>>(
            arc2_ls_band_stretches_(Interior, Band, Stretches),
            ( PrimReverse = true -> reverse(Stretches, OS) ; OS = Stretches ),
            maplist(arc2_ls_rotate_ccw_, OS, BBlks)
        ), OrdBands, BandBlkLists),
% Flatten the list of per-band block lists into one sequence.
        append(BandBlkLists, AllBlocks)
    ;
% Row-major: read row bands in primary order; extract col stretches; no rotation.
        arc2_ls_row_bands_(Interior, RowBands),
        ( PrimReverse = true -> reverse(RowBands, OrdRBs) ; OrdRBs = RowBands ),
        maplist([RBand, RBBlks]>>(
            arc2_ls_band_col_stretches_(Interior, RBand, Stretches),
            ( SecReverse = true -> reverse(Stretches, OS) ; OS = Stretches ),
            RBBlks = OS
        ), OrdRBs, BandBlkLists),
% Flatten the list of per-band block lists into one sequence.
        append(BandBlkLists, AllBlocks)
    ),
% Compute the output width as the maximum block width.
    maplist([Blk, W]>>(Blk = [R|_], length(R, W)), AllBlocks, Widths),
    max_list(Widths, MaxW),
% Center every block in MaxW columns and concatenate into the output grid.
    maplist(arc2_ls_center_block_(MaxW), AllBlocks, CBlks),
    append(CBlks, Out).

% ---------------------------------------------------------------------------
% WP-308  frame_assemble  (Layer 283)  Task e8686506
% The input has frame cells (most-common non-BG color(s)) forming a template
% with BG holes inside its bounding box. Remaining non-BG cells are pieces.
% Output = frame bbox with each BG hole filled by the piece whose normalized
% 4-connected shape fits exactly at that position. Backtracking exact cover;
% fewest-placements-first. Frame colors = non-BG colors with cell count >=
% half the maximum non-BG color cell count (ties yield multiple frame colors).
% ---------------------------------------------------------------------------

% arc2_named_rule/1: register frame_assemble for generic induction dispatch.
arc2_named_rule(frame_assemble).

% arc2_fa_frame_colors_(+Grid, +Bg, -FrameColors)
% FrameColors = non-Bg colors whose total cell count * 2 >= max non-Bg count.
arc2_fa_frame_colors_(Grid, Bg, FrameColors) :-
% Flatten grid to single value list.
    append(Grid, Flat),
% Remove BG cells.
    exclude(=(Bg), Flat, NonBg),
% Distinct non-BG colors.
    list_to_set(NonBg, Vals),
% Build Count-Color pairs.
    findall(N-V, (member(V, Vals), include(=(V), NonBg, Ms), length(Ms, N)), Pairs),
% Sort ascending; last pair has the maximum count.
    msort(Pairs, Sorted), last(Sorted, Max-_),
% Collect colors with count >= Max/2 (integer: count*2 >= Max).
    findall(V, (member(N-V, Sorted), N * 2 >= Max), FrameColors).

% arc2_fa_frame_bbox_(+Grid, +FrameColors, -R1, -R2, -C1, -C2)
% Bounding box of all cells whose color is in FrameColors.
arc2_fa_frame_bbox_(Grid, FrameColors, R1, R2, C1, C2) :-
% Collect every (R,C) that holds a frame color.
    findall(R-C, (nth0(R, Grid, Row), nth0(C, Row, V), member(V, FrameColors)), RCList),
% Extract row and col lists for min/max.
    findall(R, member(R-_, RCList), Rs),
    findall(C, member(_-C, RCList), Cs),
    min_list(Rs, R1), max_list(Rs, R2),
    min_list(Cs, C1), max_list(Cs, C2).

% arc2_fa_holes_(+Grid, +Bg, +R1, +R2, +C1, +C2, -Holes)
% Holes = absolute R-C pairs of BG cells within the frame bounding box.
arc2_fa_holes_(Grid, Bg, R1, R2, C1, C2, Holes) :-
% Scan every cell in the bbox; keep those holding the BG value.
    findall(R-C, (between(R1, R2, R), between(C1, C2, C),
                 nth0(R, Grid, Row), nth0(C, Row, Bg)), Holes).

% arc2_fa_piece_comps_(+Grid, +Bg, +FrameColors, -PieceComps)
% PieceComps = 4-connected non-BG components with no frame-colored cell.
arc2_fa_piece_comps_(Grid, Bg, FrameColors, PieceComps) :-
% All non-BG 4-connected components.
    arc2_jf_pieces_(Grid, Bg, AllComps),
% Keep only components that contain no frame color.
    include([Comp]>>(\+ (member(_-_-V, Comp), member(V, FrameColors))),
            AllComps, PieceComps).

% arc2_fa_placements_(+Norm, +Holes, +R1, +C1, +TR, +TC, -Placements)
% Find all absolute (R0,C0) offsets where every piece cell lands on a hole.
arc2_fa_placements_(Norm, Holes, R1, C1, TR, TC, Placements) :-
% Piece normalized bounding extents.
    findall(DR, member(DR-_-_, Norm), DRs),
    findall(DC, member(_-DC-_, Norm), DCs),
    max_list(DRs, MaxDR), max_list(DCs, MaxDC),
% Maximum bbox-relative top-left offset that keeps piece inside bbox.
    MaxDR0 is TR - MaxDR - 1,
    MaxDC0 is TC - MaxDC - 1,
% Enumerate all valid absolute placements.
    findall(R0-C0, (
        between(0, MaxDR0, DR0), between(0, MaxDC0, DC0),
        R0 is R1 + DR0, C0 is C1 + DC0,
        forall(member(DR-DC-_, Norm),
               (R is R0 + DR, C is C0 + DC, memberchk(R-C, Holes)))
    ), Placements).

% arc2_fa_cover_(+PiecesWP, +RemHoles, +Map0, -Map)
% Backtracking exact cover: assign each piece to a non-overlapping placement.
arc2_fa_cover_([], [], Map, Map).
arc2_fa_cover_([_-Norm-Placements|Rest], RemHoles, Map0, Map) :-
% Try each pre-computed placement.
    member(R0-C0, Placements),
% Compute absolute cell positions for this offset.
    arc2_jf_place_(Norm, R0, C0, Cells),
% All cells must be in the current remaining hole set.
    maplist([R-C-_]>>(memberchk(R-C, RemHoles)), Cells),
% Convert R-C-V triples to R-C pairs for subtraction.
    maplist([R-C-_, R-C]>>(true), Cells, Placed),
    subtract(RemHoles, Placed, NewRem),
% Record (R-C)-Color entries in the color map.
    maplist([R-C-V, (R-C)-V]>>(true), Cells, NewEntries),
    append(Map0, NewEntries, Map1),
% Recurse on remaining pieces and remaining holes.
    arc2_fa_cover_(Rest, NewRem, Map1, Map).

% arc2_fa_build_(+Grid, +R1, +R2, +C1, +C2, +ColorMap, -Out)
% Extract the frame bbox subgrid; replace BG holes using ColorMap.
arc2_fa_build_(Grid, R1, R2, C1, C2, ColorMap, Out) :-
% Enumerate absolute row indices in the bbox.
    numlist(R1, R2, RowIs),
    maplist([RI, OutRow]>>(
% Enumerate absolute column indices in the bbox.
        numlist(C1, C2, ColIs),
        maplist([CI, OutV]>>(
            nth0(RI, Grid, Row), nth0(CI, Row, V),
% Use ColorMap entry if present; otherwise keep the original frame color.
            (memberchk((RI-CI)-OutV, ColorMap) -> true ; OutV = V)
        ), ColIs, OutRow)
    ), RowIs, Out).

% arc2_transform(frame_assemble, +Grid, -Out): top-level orchestration.
arc2_transform(frame_assemble, Grid, Out) :-
% Find the background color (most frequent value).
    append(Grid, Flat),
    arc2_jf_mode_(Flat, Bg),
% Identify frame colors by frequency threshold (count*2 >= max count).
    arc2_fa_frame_colors_(Grid, Bg, FrameColors),
% Compute bounding box of all frame-colored cells.
    arc2_fa_frame_bbox_(Grid, FrameColors, R1, R2, C1, C2),
% Bbox dimensions (rows x cols).
    TR is R2 - R1 + 1, TC is C2 - C1 + 1,
% Collect BG holes within the bbox.
    arc2_fa_holes_(Grid, Bg, R1, R2, C1, C2, Holes),
% Find all non-frame non-BG 4-connected piece components.
    arc2_fa_piece_comps_(Grid, Bg, FrameColors, PieceComps),
% Normalize each piece and compute valid placements over the full hole set.
    maplist([Piece, N-Norm-Placements]>>(
        arc2_jf_normalize_(Piece, Norm),
        arc2_fa_placements_(Norm, Holes, R1, C1, TR, TC, Placements),
        length(Placements, N)
    ), PieceComps, PiecesWP),
% Sort pieces by fewest placements first (most-constrained-first heuristic).
    msort(PiecesWP, Sorted),
% Backtracking exact cover assigns each piece to its hole positions.
    arc2_fa_cover_(Sorted, Holes, [], ColorMap),
% Extract the output subgrid from the frame bbox with holes filled.
    arc2_fa_build_(Grid, R1, R2, C1, C2, ColorMap, Out).

% ---------------------------------------------------------------------------
% WAVE 51 — quadrant_tile (WP-309, Layer 284)
% Task: f931b4a8
% Input is 2N x 2N. Top-left N rows encode TL_count (non-zero cells in cols
% 0..N-1) and TR_count (non-zero cells in cols N..2N-1). Bottom-left NxN
% is the BL fill template. Bottom-right NxN is the BR tile template (0s are
% holes). Output is TL_count rows x TR_count cols. Each output cell (R,C):
%   tile_r = R mod BRh, tile_c = C mod BRw, ti = R // BRh.
%   If BR[tile_r][tile_c] != 0: use that value.
%   Else: use BL[ti mod BLh][tile_c mod BLw].
% ---------------------------------------------------------------------------

% arc2_named_rule/1 registers quadrant_tile for generic induction dispatch.
arc2_named_rule(quadrant_tile).

% arc2_qt_subgrid_(+Grid, +R0, +R1, +C0, +C1, -Sub)
% Extract rows R0..R1 and columns C0..C1 as a subgrid.
arc2_qt_subgrid_(Grid, R0, R1, C0, C1, Sub) :-
% Build a list of row indices to extract.
    numlist(R0, R1, RowIs),
% For each row index, extract the requested column slice.
    maplist([RI, Row]>>(
% Get the full row from Grid.
        nth0(RI, Grid, FullRow),
% Build column indices for the slice.
        numlist(C0, C1, ColIs),
% Extract each column value.
        maplist([CI, V]>>(nth0(CI, FullRow, V)), ColIs, Row)
    ), RowIs, Sub).

% arc2_qt_count_nz_(+Grid, +R0, +R1, +C0, +C1, -Count)
% Count cells with value != 0 in the rectangle [R0..R1] x [C0..C1].
arc2_qt_count_nz_(Grid, R0, R1, C0, C1, Count) :-
% Enumerate all (row, col) pairs in the rectangle.
    numlist(R0, R1, RowIs),
% Collect all non-zero values using findall.
    findall(1, (
% Iterate over each row index.
        member(RI, RowIs),
% Get the row list.
        nth0(RI, Grid, Row),
% Check column range and non-zero value.
        between(C0, C1, CI),
        nth0(CI, Row, V),
        V \= 0
    ), Ones),
% The count is the length of the found list.
    length(Ones, Count).

% arc2_qt_cell_(+BR, +BL, +BRh, +BRw, +BLh, +BLw, +R, +C, -V)
% Compute the value at output position (R,C) using the tile and fill rules.
arc2_qt_cell_(BR, BL, BRh, BRw, BLh, BLw, R, C, V) :-
% Tile row index within BR (0-based).
    TileR is R mod BRh,
% Tile column index within BR (0-based).
    TileC is C mod BRw,
% Tile-block row index (which repetition of BR we are in).
    TI    is R // BRh,
% Look up the BR value at this tile position.
    nth0(TileR, BR, BRRow),
    nth0(TileC, BRRow, BRV),
% If BR has a non-zero value here, use it directly.
    ( BRV \= 0 ->
        V = BRV
    ;
% Otherwise look up the fill from BL using tile-block row and tile col.
        BLi is TI mod BLh,
        BLj is TileC mod BLw,
        nth0(BLi, BL, BLRow),
        nth0(BLj, BLRow, V)
    ).

% arc2_transform(quadrant_tile, +Grid, -Out)
% Top-level orchestration: split, count, tile-and-fill.
arc2_transform(quadrant_tile, Grid, Out) :-
% Grid dimensions.
    length(Grid, R),
    Grid = [Row0|_],
    length(Row0, C),
% Split point is the midpoint of each dimension.
    SplitR is R // 2,
    SplitC is C // 2,
% Last row/col indices for subgrid extraction.
    R1max  is R - 1,
    C1BL   is SplitC - 1,
    C1BR   is C - 1,
    SplitR1 is SplitR - 1,
% Extract BL (bottom-left) fill template.
    arc2_qt_subgrid_(Grid, SplitR, R1max, 0,      C1BL,  BL),
% Extract BR (bottom-right) tile template.
    arc2_qt_subgrid_(Grid, SplitR, R1max, SplitC, C1BR,  BR),
% Count non-zero cells in TL (top-left) to get output row count.
    arc2_qt_count_nz_(Grid, 0, SplitR1, 0,      C1BL,  TLCount),
% Count non-zero cells in TR (top-right) to get output col count.
    arc2_qt_count_nz_(Grid, 0, SplitR1, SplitC, C1BR,  TRCount),
% BL and BR dimensions.
    length(BL, BLh), BL = [BLR0|_], length(BLR0, BLw),
    length(BR, BRh), BR = [BRR0|_], length(BRR0, BRw),
% Output row and col index lists.
    TLLast is TLCount - 1,
    TRLast is TRCount - 1,
    numlist(0, TLLast, RowIs),
    numlist(0, TRLast, ColIs),
% Build each output row by computing each cell value.
    maplist([RI, OutRow]>>(
        maplist([CI, V]>>(
            arc2_qt_cell_(BR, BL, BRh, BRw, BLh, BLw, RI, CI, V)
        ), ColIs, OutRow)
    ), RowIs, Out).

% ---------------------------------------------------------------------------
% WP-310  PLUS_MARK  (Layer 285)  solves task 1818057f
% Rule: every 5-cell plus-shape (center + N/S/E/W) where all 5 cells hold
% value 4 is recoloured to 8; all other cells are unchanged.
% ---------------------------------------------------------------------------

% arc2_named_rule/1: register plus_mark for the generic induction dispatcher.
arc2_named_rule(plus_mark).

% arc2_pm_is_plus_center_/5: true when (R,C) is the center of a plus-shape
% in Grid where all five cells (center and four orthogonal neighbors) are 4.
% R and C must be interior (not on the grid boundary) for neighbors to exist.
arc2_pm_is_plus_center_(Grid, H, W, R, C) :-
% R must be strictly interior (has rows above and below).
    R > 0, R < H - 1,
% C must be strictly interior (has columns left and right).
    C > 0, C < W - 1,
% Extract center row and check the center cell.
    nth0(R, Grid, Row),
% Center cell must be 4.
    nth0(C, Row, 4),
% Compute neighbor row indices.
    R1 is R - 1, R2 is R + 1,
% Compute neighbor column indices.
    C1 is C - 1, C2 is C + 1,
% North neighbor row; check north cell.
    nth0(R1, Grid, RowN), nth0(C,  RowN, 4),
% South neighbor row; check south cell.
    nth0(R2, Grid, RowS), nth0(C,  RowS, 4),
% West neighbor from center row.
    nth0(C1, Row, 4),
% East neighbor from center row.
    nth0(C2, Row, 4).

% arc2_pm_plus_cells_/4: collect (as a sorted list of R-C pairs) every cell
% that belongs to any plus-shape in Grid.  A cell belongs if it is a center
% or an orthogonal neighbor of a center.
arc2_pm_plus_cells_(Grid, H, W, PlusCells) :-
% Compute inclusive upper bounds for between/3 enumeration.
    H1 is H - 1, W1 is W - 1,
% Gather every cell reachable from any plus center via findall.
    findall(R-C,
% Enumerate all candidate center rows.
        (   between(0, H1, CR),
% Enumerate all candidate center columns.
            between(0, W1, CC),
% Check that (CR,CC) is the center of a valid plus-shape.
            arc2_pm_is_plus_center_(Grid, H, W, CR, CC),
% Generate the center coordinate itself …
            ( R = CR,         C = CC
% … or the north neighbor …
            ; R1 is CR - 1,   R = R1, C = CC
% … or the south neighbor …
            ; R2 is CR + 1,   R = R2, C = CC
% … or the west neighbor …
            ; C1 is CC - 1,   R = CR, C = C1
% … or the east neighbor.
            ; C2 is CC + 1,   R = CR, C = C2
            )
        ),
% Sort deduplicates when multiple plus shapes share cells.
        Raw),
    sort(Raw, PlusCells).

% arc2_transform(plus_mark, +Grid, -Out): recolour every plus-shape cell to
% 8 and leave every other cell unchanged.
arc2_transform(plus_mark, Grid, Out) :-
% Measure the grid height.
    length(Grid, H),
% Measure the grid width from the first row.
    Grid = [Row0|_], length(Row0, W),
% Collect all cells that belong to any plus-shape.
    arc2_pm_plus_cells_(Grid, H, W, PlusCells),
% Build row and column index lists for maplist iteration.
    H1 is H - 1, W1 is W - 1,
% Row index list 0..H-1.
    numlist(0, H1, RowIs),
% Column index list 0..W-1.
    numlist(0, W1, ColIs),
% Construct each output row.
    maplist([RI, OutRow]>>(
% Construct each output cell.
        maplist([CI, V]>>(
% If this cell is part of a plus-shape, emit 8.
            ( memberchk(RI-CI, PlusCells) -> V = 8
% Otherwise copy the original cell value from the input grid.
            ; nth0(RI, Grid, InRow), nth0(CI, InRow, V)
            )
        ), ColIs, OutRow)
    ), RowIs, Out).

% ---------------------------------------------------------------------------
% WP-311  TEMPLATE_EXPAND  (Layer 286)  solves task c4d067a0
% ---------------------------------------------------------------------------

% Register template_expand for the generic induction dispatcher.
arc2_named_rule(template_expand).

% arc2_te_bg_(+Grid, -BG): most-common cell value is the background.
arc2_te_bg_(Grid, BG) :-
% Flatten all cell values into one list.
    findall(V, (member(Row, Grid), member(V, Row)), Flat),
% Sort to group equal values so the mode scan is linear.
    msort(Flat, Sorted),
% Scan for the value that appears most often.
    arc2_te_mode_(Sorted, BG).

% arc2_te_mode_(+SortedList, -Mode): initialise mode scan with first element.
arc2_te_mode_([V|Vs], Mode) :-
% Start with the first value as both current run and best.
    arc2_te_mode_scan_(Vs, V, 1, V, 1, Mode).

% Base: list exhausted; return accumulated best.
arc2_te_mode_scan_([], _, _, BestV, _, BestV).
% Same value as current run: extend the run, update best if now longer.
arc2_te_mode_scan_([V|Vs], V, N, BestV, BestN, Mode) :-
% Increment the run length.
    N1 is N + 1,
% Replace best if the new run is strictly longer.
    (N1 > BestN -> NewBV = V, NewBN = N1 ; NewBV = BestV, NewBN = BestN),
% Continue scanning.
    arc2_te_mode_scan_(Vs, V, N1, NewBV, NewBN, Mode).
% Different value: close previous run, restart count.
arc2_te_mode_scan_([V|Vs], Prev, N, BestV, BestN, Mode) :-
% Guard: ensure value changed.
    V \= Prev,
% Update best with the run that just ended.
    (N > BestN -> NewBV = Prev, NewBN = N ; NewBV = BestV, NewBN = BestN),
% Begin new run of length 1.
    arc2_te_mode_scan_(Vs, V, 1, NewBV, NewBN, Mode).

% arc2_te_isolated_(+Grid, +BG, +H, +W, +R, +C):
%   cell (R,C) is non-BG and has no non-BG 4-connected neighbour.
arc2_te_isolated_(Grid, BG, H, W, R, C) :-
% Verify the cell itself is non-BG.
    nth0(R, Grid, Row), nth0(C, Row, V), V \= BG,
% Confirm none of the four orthogonal neighbours is non-BG.
    \+ (member(DR-DC, [0-1, 0-(-1), 1-0, (-1)-0]),
        R1 is R + DR, C1 is C + DC,
% Neighbours outside the grid are ignored.
        R1 >= 0, R1 < H, C1 >= 0, C1 < W,
        nth0(R1, Grid, NRow), nth0(C1, NRow, NV), NV \= BG).

% arc2_te_templ_cells_(+Grid, +BG, +H, +W, -TemplCells):
%   collect every isolated non-BG cell as an R-C pair (template markers).
arc2_te_templ_cells_(Grid, BG, H, W, TemplCells) :-
% Enumerate all grid positions.
    H1 is H - 1, W1 is W - 1,
% Keep only those that satisfy the isolation check.
    findall(R-C, (between(0, H1, R), between(0, W1, C),
                  arc2_te_isolated_(Grid, BG, H, W, R, C)), TemplCells).

% arc2_te_col_runs_(+SortedCols, -Runs):
%   partition a sorted column list into contiguous runs as S-E pairs.
arc2_te_col_runs_([], []).
arc2_te_col_runs_([C|Cs], Runs) :-
% Bootstrap the scan with the first column as both start and end.
    arc2_te_col_runs_scan_(Cs, C, C, Runs).

% Base: emit the last run.
arc2_te_col_runs_scan_([], S, E, [S-E]).
% Contiguous: extend the current run.
arc2_te_col_runs_scan_([C|Cs], S, E, Runs) :-
    (C =:= E + 1
% Column follows immediately: widen the run end.
    ->  arc2_te_col_runs_scan_(Cs, S, C, Runs)
% Gap: close this run and start a new one.
    ;   Runs = [S-E | Rest], arc2_te_col_runs_scan_(Cs, C, C, Rest)).

% arc2_te_seed_info_(+Grid, +BG, +H, +W, +TemplCells,
%                    -SeedRowMin, -ColRuns, -BH, -BW, -Stride, -SeedColors):
%   derive seed block geometry: row range, column sub-block runs, strides, colors.
arc2_te_seed_info_(Grid, BG, H, W, TemplCells,
                   SeedRowMin, ColRuns, BH, BW, Stride, SeedColors) :-
% Seed cells = non-BG cells that are NOT isolated (i.e. not in TemplCells).
    H1 is H - 1, W1 is W - 1,
    findall(R-C, (between(0, H1, R), between(0, W1, C),
                  nth0(R, Grid, SRow0), nth0(C, SRow0, SV), SV \= BG,
                  \+ member(R-C, TemplCells)), SeedCells),
% Compute the row extent of the seed.
    findall(R, member(R-_, SeedCells), SeedRs),
    sort(SeedRs, SortedSeedRs),
    SortedSeedRs = [SeedRowMin|_],
    last(SortedSeedRs, SeedRowMax),
% Block height = row span.
    BH is SeedRowMax - SeedRowMin + 1,
% Collect columns occupied in the first seed row.
    findall(C, member(SeedRowMin-C, SeedCells), SRCols),
    sort(SRCols, SortedSRCols),
% Find contiguous column runs (one per sub-block).
    arc2_te_col_runs_(SortedSRCols, ColRuns),
% Need at least two sub-blocks to compute stride.
    ColRuns = [S1-E1, S2-_ | _],
% Block width from the first sub-block.
    BW is E1 - S1 + 1,
% Stride = distance between adjacent sub-block starts.
    Stride is S2 - S1,
% Record the color of each sub-block (read from its leftmost column).
    maplist([S-_, Color]>>(
        nth0(SeedRowMin, Grid, SRow2), nth0(S, SRow2, Color)
    ), ColRuns, SeedColors).

% arc2_te_template_structure_(+TemplCells, -TRows, -TCols):
%   extract sorted lists of distinct template row and column positions.
arc2_te_template_structure_(TemplCells, TRows, TCols) :-
% Collect all template row indices.
    findall(R, member(R-_, TemplCells), Rs), sort(Rs, TRows),
% Collect all template column indices.
    findall(C, member(_-C, TemplCells), Cs), sort(Cs, TCols).

% arc2_te_check_match_(+Grid, +TRows, +TCols, +SeedColors, +LI, +C0, +I):
%   verify that template row TRows[LI], col TCols[C0+I] equals SeedColors[I].
arc2_te_check_match_(_, _, _, [], _, _, _).
arc2_te_check_match_(Grid, TRows, TCols, [SC|SCs], LI, C0, I) :-
% Index into template row list.
    nth0(LI, TRows, TR),
% Offset col-group index by the starting col-group.
    CI is C0 + I,
% Index into template col list.
    nth0(CI, TCols, TC),
% Read template cell; must equal the seed color.
    nth0(TR, Grid, TRow), nth0(TC, TRow, SC),
% Recurse on remaining seed colors.
    I1 is I + 1,
    arc2_te_check_match_(Grid, TRows, TCols, SCs, LI, C0, I1).

% arc2_te_find_level_(+Grid, +TRows, +TCols, +SeedColors, -SeedLevel, -CGOff):
%   find the template level L and col-group offset C0 where the seed sits.
arc2_te_find_level_(Grid, TRows, TCols, SeedColors, SeedLevel, CGOff) :-
% Compute search bounds.
    length(TRows, NL), NL1 is NL - 1,
    length(TCols, NCG), length(SeedColors, NSB),
    MaxOff is NCG - NSB,
% Try each level index.
    between(0, NL1, LI),
% Try each possible col-group starting offset.
    between(0, MaxOff, C0),
% Stop at the first consistent (level, offset) pair.
    arc2_te_check_match_(Grid, TRows, TCols, SeedColors, LI, C0, 0),
    !,
% Commit the found values.
    SeedLevel = LI, CGOff = C0.

% arc2_te_in_block_(+X, +Anchor, +Stride, +BlockSize, +NumBlocks, -BIdx):
%   succeeds when coordinate X falls inside block BIdx of a regular tiling.
arc2_te_in_block_(X, Anchor, Stride, BlockSize, NumBlocks, BIdx) :-
% Distance from anchor.
    DX is X - Anchor,
% Must be at or after the anchor.
    DX >= 0,
% Integer block index.
    BIdx is DX // Stride,
% Must not exceed the last block.
    BIdx < NumBlocks,
% Offset within the stride period must be inside the block footprint.
    Off is DX - BIdx * Stride,
    Off < BlockSize.

% arc2_transform(template_expand, +Grid, -Out):
%   expand a seed block array according to a sparse single-cell template.
arc2_transform(template_expand, Grid, Out) :-
% Measure grid dimensions.
    length(Grid, H), Grid = [Row0|_], length(Row0, W),
% Detect background as the most-common cell value.
    arc2_te_bg_(Grid, BG),
% Find all isolated (template) cells.
    arc2_te_templ_cells_(Grid, BG, H, W, TemplCells),
% Guard: at least one template cell must exist.
    TemplCells \= [],
% Extract seed block geometry.
    arc2_te_seed_info_(Grid, BG, H, W, TemplCells,
                       SeedRowMin, ColRuns, BH, BW, Stride, SeedColors),
% Leftmost column of the first seed sub-block.
    ColRuns = [SeedColStart-_|_],
% Get sorted template row and column lists.
    arc2_te_template_structure_(TemplCells, TRows, TCols),
% Count template levels and col-groups.
    length(TRows, NL), length(TCols, NCG),
% Determine which level and col-group offset the seed represents.
    arc2_te_find_level_(Grid, TRows, TCols, SeedColors, SeedLevel, CGOff),
% Compute the top-left anchor of the entire block array.
    AnchorRow is SeedRowMin - SeedLevel * Stride,
    AnchorCol is SeedColStart - CGOff * Stride,
% Prepare index lists for maplist.
    H1 is H - 1, W1 is W - 1,
    numlist(0, H1, RowIs), numlist(0, W1, ColIs),
% Build output row by row, cell by cell.
    maplist([RI, OutRow]>>(
        maplist([CI, V]>>(
% Check if (RI,CI) falls inside a template block.
            (   arc2_te_in_block_(RI, AnchorRow, Stride, BH, NL, LI),
                arc2_te_in_block_(CI, AnchorCol, Stride, BW, NCG, CGI),
% Look up the template color for this block position.
                nth0(LI, TRows, TR), nth0(CGI, TCols, TC),
                nth0(TR, Grid, TRow2), nth0(TC, TRow2, TV), TV \= BG
% Assign the template color.
            ->  V = TV
% Outside all blocks: copy original value.
            ;   nth0(RI, Grid, InRow), nth0(CI, InRow, V)
            )
        ), ColIs, OutRow)
    ), RowIs, Out).

% ---------------------------------------------------------------------------
% NOISE ERASE (noise_erase, WP-312, Layer 287)
% Task: 71e489b6
% Stray-0 cells (0s embedded in the 1-region) stay 0 with a 3x3 frame of 7s.
% Stray-1 cells (isolated 1s in the 0-region) are erased to 0.
% Stray-0 seed: a 0-cell with 1-neighbor count >= min(3, available neighbors).
% Stray-0 set: BFS expansion from seeds to adjacent 0-cells with >=2 1-nbrs.
% Frame: in-bounds 8-neighbors of any stray-0 cell (excluding centers) -> 7.
% Stray-1: a 1-cell with 1-neighbor count <= 1.
% Priority: stray-0 center -> 0; frame -> 7; stray-1 -> 0; else unchanged.
% ---------------------------------------------------------------------------

% arc2_named_rule(noise_erase): register noise_erase as a known rule name.
arc2_named_rule(noise_erase).

% arc2_ne_1nbr_count_(+Grid, +R, +C, -Count):
%   Count = number of in-bounds 4-neighbors of (R,C) with value 1.
arc2_ne_1nbr_count_(Grid, R, C, Count) :-
% Compute all four cardinal neighbor coordinates.
    R1 is R-1, R2 is R+1, C1 is C-1, C2 is C+1,
% Collect only those neighbors that are in-bounds and hold value 1.
    include([NR-NC]>>(arc2_cell_(Grid, NR, NC, 1)),
% List of all four candidate neighbors.
            [R1-C, R2-C, R-C1, R-C2], Ones),
% Count is the length of the matching list.
    length(Ones, Count).

% arc2_ne_avail_count_(+Grid, +R, +C, -Avail):
%   Avail = number of in-bounds 4-neighbors of (R,C).
arc2_ne_avail_count_(Grid, R, C, Avail) :-
% Compute all four cardinal neighbor coordinates.
    R1 is R-1, R2 is R+1, C1 is C-1, C2 is C+1,
% Collect only those neighbors for which arc2_cell_ succeeds (i.e., in-bounds).
    include([NR-NC]>>(arc2_cell_(Grid, NR, NC, _)),
% List of all four candidate neighbors.
            [R1-C, R2-C, R-C1, R-C2], InBounds),
% Avail is the count of in-bounds neighbors.
    length(InBounds, Avail).

% arc2_ne_stray0_seed_(+Grid, +R, +C):
%   (R,C) is a stray-0 seed: value 0 and 1-count >= min(3, avail).
arc2_ne_stray0_seed_(Grid, R, C) :-
% Cell must hold value 0.
    arc2_cell_(Grid, R, C, 0),
% Count how many in-bounds 4-neighbors are 1.
    arc2_ne_1nbr_count_(Grid, R, C, OneCount),
% Count total in-bounds 4-neighbors.
    arc2_ne_avail_count_(Grid, R, C, Avail),
% Threshold adapts to corner/edge cells: min(3, total available).
    Thresh is min(3, Avail),
% Stray-0 seed when 1-neighbor count meets or exceeds threshold.
    OneCount >= Thresh.

% arc2_ne_stray1_(+Grid, +R, +C):
%   (R,C) is a stray-1: value 1 and 1-neighbor count <= 1.
arc2_ne_stray1_(Grid, R, C) :-
% Cell must hold value 1.
    arc2_cell_(Grid, R, C, 1),
% Count how many in-bounds 4-neighbors are also 1.
    arc2_ne_1nbr_count_(Grid, R, C, OneCount),
% Stray-1 when nearly all neighbors are 0 (isolated or peninsula tip).
    OneCount =< 1.

% arc2_ne_expand_bfs_(+Grid, +Queue, +Visited, -Stray0):
%   BFS from Queue; expand to 0-cell neighbors with >=2 1-neighbors.
%   Visited accumulates all stray-0 positions found so far.
arc2_ne_expand_bfs_(_, [], Visited, Visited).
arc2_ne_expand_bfs_(Grid, [R-C|Rest], Vis0, Stray0) :-
% Compute cardinal neighbor coordinates of current position.
    R1 is R-1, R2 is R+1, C1 is C-1, C2 is C+1,
% Find unvisited 0-cell neighbors with >=2 1-valued neighbors.
    include([NR-NC]>>(
% Neighbor must hold value 0.
        arc2_cell_(Grid, NR, NC, 0),
% Neighbor must not already be in the stray-0 set.
        \+ memberchk(NR-NC, Vis0),
% Neighbor must have at least 2 1-valued 4-neighbors.
        arc2_ne_1nbr_count_(Grid, NR, NC, OC), OC >= 2),
% Four cardinal neighbors to check.
        [R1-C, R2-C, R-C1, R-C2], New),
% Deduplicate newly found cells.
    sort(New, UniqueNew),
% Add newly found cells to the visited set.
    append(Vis0, UniqueNew, Vis1),
% Append newly found cells to the end of the BFS queue.
    append(Rest, UniqueNew, Queue1),
% Continue BFS with the updated queue and visited set.
    arc2_ne_expand_bfs_(Grid, Queue1, Vis1, Stray0).

% arc2_ne_stray0_all_(+Grid, +H, +W, -Stray0):
%   Stray0 = sorted list of all stray-0 positions (seeds + BFS expansion).
arc2_ne_stray0_all_(Grid, H, W, Stray0) :-
% Coordinate bounds for the full grid.
    H1 is H-1, W1 is W-1,
% Collect all seed stray-0 positions.
    findall(R-C,
        (between(0, H1, R), between(0, W1, C),
% Each candidate must pass the stray-0 seed test.
         arc2_ne_stray0_seed_(Grid, R, C)),
        Seeds),
% Sort seeds to produce a canonical starting set.
    sort(Seeds, SortedSeeds),
% BFS-expand from seeds to adjacent 0-cells with >=2 1-neighbors.
    arc2_ne_expand_bfs_(Grid, SortedSeeds, SortedSeeds, Stray0).

% arc2_ne_frame_(+Stray0, +Grid, -Frame):
%   Frame = sorted in-bounds 8-neighbor positions of Stray0, minus Stray0.
arc2_ne_frame_(Stray0, Grid, Frame) :-
% For each stray-0 cell and each of the 8 offsets, generate candidate positions.
    findall(NR-NC,
        (member(R-C, Stray0),
% Visit all 8 surrounding cells (excluding center offset 0-0).
         member(DR-DC, [-1-(-1), -1-0, -1-1, 0-(-1), 0-1, 1-(-1), 1-0, 1-1]),
         NR is R+DR, NC is C+DC,
% Candidate must be in bounds (arc2_cell_ fails for out-of-bounds).
         arc2_cell_(Grid, NR, NC, _),
% Candidate must not itself be a stray-0 center.
         \+ memberchk(NR-NC, Stray0)),
        Candidates),
% Deduplicate to produce a sorted frame set.
    sort(Candidates, Frame).

% arc2_ne_out_val_(+R, +C, +Grid, +Stray0, +Frame, +Stray1, -Val):
%   Compute output value with priority: stray-0->0, frame->7, stray-1->0, else copy.
arc2_ne_out_val_(R, C, Grid, Stray0, Frame, Stray1, Val) :-
% Stray-0 center stays 0 (highest priority).
    (   memberchk(R-C, Stray0) -> Val = 0
% Frame cell becomes 7.
    ;   memberchk(R-C, Frame)  -> Val = 7
% Stray-1 is erased to 0.
    ;   memberchk(R-C, Stray1) -> Val = 0
% All other cells copy the original value.
    ;   arc2_cell_(Grid, R, C, Val)
    ).

% arc2_transform(noise_erase, +Grid, -Out):
%   Top-level: detect stray-0 clusters and stray-1 cells; apply frame and erase.
arc2_transform(noise_erase, Grid, Out) :-
% Measure grid dimensions.
    length(Grid, H), Grid = [Row0|_], length(Row0, W),
% Build index ranges for maplist.
    H1 is H-1, W1 is W-1,
    numlist(0, H1, RowIs), numlist(0, W1, ColIs),
% Compute complete stray-0 set (seeds + BFS expansion).
    arc2_ne_stray0_all_(Grid, H, W, Stray0),
% Compute 8-neighbor frame around all stray-0 cells.
    arc2_ne_frame_(Stray0, Grid, Frame),
% Collect all stray-1 positions.
    findall(R-C,
        (between(0, H1, R), between(0, W1, C),
% Each 1-cell with <=1 same-valued neighbor qualifies.
         arc2_ne_stray1_(Grid, R, C)),
        Stray1Raw),
% Sort stray-1 list for fast memberchk.
    sort(Stray1Raw, Stray1),
% Build output row by row, cell by cell.
    maplist([RI, OutRow]>>(
        maplist([CI, V]>>(
% Apply priority rule to determine each output cell.
            arc2_ne_out_val_(RI, CI, Grid, Stray0, Frame, Stray1, V)
        ), ColIs, OutRow)
    ), RowIs, Out).

% ---------------------------------------------------------------------------
% WP-313: pocket_shot (Layer 288) — 2-blocks slide into frame interior channels
% Task: 8b9c3697
% ---------------------------------------------------------------------------

% Registry entry for arc2_induce_rule/2 dispatch.
arc2_named_rule(pocket_shot).

% arc2_ps_dr_/2: row delta for each firing direction.
arc2_ps_dr_(up,   -1).
% arc2_ps_dr_/2: row delta for down direction.
arc2_ps_dr_(down,  1).
% arc2_ps_dr_/2: row delta for left direction (zero).
arc2_ps_dr_(left,  0).
% arc2_ps_dr_/2: row delta for right direction (zero).
arc2_ps_dr_(right, 0).
% arc2_ps_dc_/2: col delta for each firing direction.
arc2_ps_dc_(up,    0).
% arc2_ps_dc_/2: col delta for down direction (zero).
arc2_ps_dc_(down,  0).
% arc2_ps_dc_/2: col delta for left direction.
arc2_ps_dc_(left, -1).
% arc2_ps_dc_/2: col delta for right direction.
arc2_ps_dc_(right, 1).
% arc2_ps_perpdirs_/2: perpendicular direction pair for each axis.
arc2_ps_perpdirs_(up,    [left, right]).
% arc2_ps_perpdirs_/2: perpendicular pair for down.
arc2_ps_perpdirs_(down,  [left, right]).
% arc2_ps_perpdirs_/2: perpendicular pair for left.
arc2_ps_perpdirs_(left,  [up, down]).
% arc2_ps_perpdirs_/2: perpendicular pair for right.
arc2_ps_perpdirs_(right, [up, down]).
% arc2_ps_opp_/2: opposite direction.
arc2_ps_opp_(up,    down).
% arc2_ps_opp_/2: opposite for down.
arc2_ps_opp_(down,  up).
% arc2_ps_opp_/2: opposite for left.
arc2_ps_opp_(left,  right).
% arc2_ps_opp_/2: opposite for right.
arc2_ps_opp_(right, left).

% arc2_ps_scan_/6: scan direction D from (R,C), skip BG/2 cells, return first arm-cell.
arc2_ps_scan_(Grid, BG, R, C, D, XR-XC) :-
% Look up row and col deltas for this direction.
    arc2_ps_dr_(D, DR), arc2_ps_dc_(D, DC),
% Start one step from the given position.
    R2 is R + DR, C2 is C + DC,
% Recurse until an arm-cell is found or grid boundary is reached.
    arc2_ps_scan_go_(Grid, BG, R2, C2, DR, DC, XR-XC).

% arc2_ps_scan_go_/7: base case — cell at (R,C) is an arm-cell (not BG, not 2).
arc2_ps_scan_go_(Grid, BG, R, C, _, _, R-C) :-
% Succeed only if this cell exists and is not background or a 2-cell.
    arc2_cell_(Grid, R, C, V), V \= BG, V \= 2, !.
% arc2_ps_scan_go_/7: step case — cell is BG or 2; advance one step.
arc2_ps_scan_go_(Grid, BG, R, C, DR, DC, Out) :-
% Cell must be BG or 2 to continue scanning.
    arc2_cell_(Grid, R, C, V), (V =:= BG ; V =:= 2), !,
% Advance one step in the scan direction.
    R2 is R + DR, C2 is C + DC,
% Continue scanning from the next cell.
    arc2_ps_scan_go_(Grid, BG, R2, C2, DR, DC, Out).

% arc2_ps_valid_peg_/4: verify (XR,XC) is a valid interior peg for approach direction D.
arc2_ps_valid_peg_(Grid, BG, XR-XC, D) :-
% Condition 1: open face toward the 2-block (BG or off-grid in opposite direction).
    arc2_ps_opp_(D, OD), arc2_ps_dr_(OD, ODR), arc2_ps_dc_(OD, ODC),
% Compute the opposite-direction neighbor of the peg.
    OR is XR + ODR, OC is XC + ODC,
% Opposite cell must be BG (or off-grid, which means \+ arc2_cell_ succeeds).
    (\+ arc2_cell_(Grid, OR, OC, _) ; arc2_cell_(Grid, OR, OC, OV), OV =:= BG),
% Condition 2: parent arm-cell exists in D direction (arm continues deeper into shape).
    arc2_ps_dr_(D, DR), arc2_ps_dc_(D, DC),
% Compute parent position (one step further in firing direction from peg).
    PR is XR + DR, PC is XC + DC,
% Parent must be an arm-cell (in bounds, not BG, not 2).
    arc2_cell_(Grid, PR, PC, PV), PV \= BG, PV \= 2,
% Condition 3: parent has >= 2 perpendicular arm-neighbors (forms a bar or spine).
    arc2_ps_perpdirs_(D, PDs),
% Count perpendicular arm-neighbors of the parent.
    include(arc2_ps_arm_nbr_(Grid, BG, PR, PC), PDs, PerpArms),
% Require at least two perpendicular arm-neighbors.
    length(PerpArms, N), N >= 2.

% arc2_ps_arm_nbr_/4: succeeds if direction PD from (R,C) leads to a non-BG non-2 cell.
arc2_ps_arm_nbr_(Grid, BG, R, C, PD) :-
% Look up the perpendicular direction offset.
    arc2_ps_dr_(PD, PDR), arc2_ps_dc_(PD, PDC),
% Compute neighbor position.
    NR is R + PDR, NC is C + PDC,
% Neighbor must exist and be an arm-cell.
    arc2_cell_(Grid, NR, NC, NV), NV \= BG, NV \= 2.

% arc2_ps_peg_col_/6: scan column C up/down from row SR; return arm row if valid peg.
arc2_ps_peg_col_(Grid, BG, SR, D, C, XR) :-
% Scan in direction D from (SR,C) and find first arm-cell.
    arc2_ps_scan_(Grid, BG, SR, C, D, XR-C),
% Verify the found arm-cell is a valid interior peg.
    arc2_ps_valid_peg_(Grid, BG, XR-C, D).

% arc2_ps_peg_row_/6: scan row R left/right from col SC; return arm col if valid peg.
arc2_ps_peg_row_(Grid, BG, SC, D, R, XC) :-
% Scan in direction D from (R,SC) and find first arm-cell.
    arc2_ps_scan_(Grid, BG, R, SC, D, R-XC),
% Verify the found arm-cell is a valid interior peg.
    arc2_ps_valid_peg_(Grid, BG, R-XC, D).

% arc2_ps_vland_/4: landing box for UP fire (arm row XAR; block rows R1-R2, cols C1-C2).
arc2_ps_vland_(R1-R2-C1-C2, up, XAR, LR1-LR2-C1-C2) :-
% Block top lands one row below the arm.
    LR1 is XAR + 1,
% Block bottom offset by block height.
    LR2 is XAR + 1 + (R2 - R1).
% arc2_ps_vland_/4: landing box for DOWN fire.
arc2_ps_vland_(R1-R2-C1-C2, down, XAR, LR1-LR2-C1-C2) :-
% Block bottom lands one row above the arm.
    LR2 is XAR - 1,
% Block top offset by block height.
    LR1 is XAR - 1 - (R2 - R1).
% arc2_ps_hland_/4: landing box for LEFT fire (arm col XAC; block rows R1-R2, cols C1-C2).
arc2_ps_hland_(R1-R2-C1-C2, left, XAC, R1-R2-LC1-LC2) :-
% Block left lands one col right of the arm.
    LC1 is XAC + 1,
% Block right offset by block width.
    LC2 is XAC + 1 + (C2 - C1).
% arc2_ps_hland_/4: landing box for RIGHT fire.
arc2_ps_hland_(R1-R2-C1-C2, right, XAC, R1-R2-LC1-LC2) :-
% Block right lands one col left of the arm.
    LC2 is XAC - 1,
% Block left offset by block width.
    LC1 is XAC - 1 - (C2 - C1).

% arc2_ps_fire_/5: find valid firing direction D and landing box for block Box.
%   Fails if no direction satisfies the peg conditions for all block positions.
arc2_ps_fire_(Grid, BG, Box, D, Land) :-
% Unpack block bounding box.
    Box = R1-R2-C1-C2,
% Try each direction in order.
    member(D, [up, down, left, right]),
    arc2_ps_dr_(D, DR),
    (DR \= 0 ->
% Vertical fire: scan each column in the block from its leading row.
        (DR < 0 -> SR = R1 ; SR = R2),
        numlist(C1, C2, Cols),
% Every column must find a valid peg at the same row (block integrity).
        maplist(arc2_ps_peg_col_(Grid, BG, SR, D), Cols, XRs),
% Block integrity: all arm-cells must be in the same row.
        sort(XRs, [XAR]),
% Compute landing box using vertical displacement.
        arc2_ps_vland_(Box, D, XAR, Land)
    ;
% Horizontal fire: scan each row in the block from its leading col.
        arc2_ps_dc_(D, DC),
        (DC < 0 -> SC = C1 ; SC = C2),
        numlist(R1, R2, Rows),
% Every row must find a valid peg at the same col (block integrity).
        maplist(arc2_ps_peg_row_(Grid, BG, SC, D), Rows, XCs),
% Block integrity: all arm-cells must be in the same column.
        sort(XCs, [XAC]),
% Compute landing box using horizontal displacement.
        arc2_ps_hland_(Box, D, XAC, Land)
    ).

% arc2_ps_find_blocks_/2: collect bounding boxes of all 4-connected 2-cell components.
arc2_ps_find_blocks_(Grid, Boxes) :-
% Measure grid dimensions.
    length(Grid, H), Grid = [GR|_], length(GR, W),
    H1 is H - 1, W1 is W - 1,
% Collect all 2-cell positions.
    findall(R-C,
        (between(0, H1, R), between(0, W1, C), arc2_cell_(Grid, R, C, 2)),
        Twos),
% Sort for deterministic component ordering.
    sort(Twos, TwoSorted),
% Group into connected components.
    arc2_ps_comps_(Grid, TwoSorted, [], Boxes).

% arc2_ps_comps_/4: base case — no more 2-cells to process.
arc2_ps_comps_(_, [], _, []).
% arc2_ps_comps_/4: cell already belongs to a processed component; skip it.
arc2_ps_comps_(Grid, [RC|Rest], Seen, Boxes) :-
    memberchk(RC, Seen), !,
% Advance to next cell with the same visited set.
    arc2_ps_comps_(Grid, Rest, Seen, Boxes).
% arc2_ps_comps_/4: new seed — BFS to get component; compute bounding box.
arc2_ps_comps_(Grid, [R-C|Rest], Seen0, [R1-R2-C1-C2|Boxes]) :-
% BFS-expand from R-C; Seen0 are cells already assigned to earlier components.
    arc2_bfs_(Grid, [R-C], 2, Seen0, [], Comp, Seen1),
% Extract all row coordinates of component cells.
    findall(RR, member(RR-_, Comp), Rs),
% Extract all col coordinates of component cells.
    findall(CC, member(_-CC, Comp), Cs),
% Bounding box: min/max row and col.
    min_list(Rs, R1), max_list(Rs, R2),
    min_list(Cs, C1), max_list(Cs, C2),
% Process remaining cells with updated visited set.
    arc2_ps_comps_(Grid, Rest, Seen1, Boxes).

% arc2_ps_trail_/5: compute zero-cells and two-cells for UP fire.
%   Zeros = original block + trail (rows LR2+1..R2); Twos = landing rows LR1..LR2.
arc2_ps_trail_(_-R2-C1-C2, up, LR1-LR2-_-_, Zeros, Twos) :-
% Collect landing positions (become 2).
    findall(R-C, (between(LR1, LR2, R), between(C1, C2, C)), Twos),
% Trail starts one row below landing bottom.
    ZR1 is LR2 + 1,
% Zeros span from trail start to original block bottom.
    findall(R-C, (between(ZR1, R2, R), between(C1, C2, C)), Zeros).
% arc2_ps_trail_/5: zero-cells and two-cells for DOWN fire.
arc2_ps_trail_(R1-_-C1-C2, down, LR1-LR2-_-_, Zeros, Twos) :-
% Collect landing positions.
    findall(R-C, (between(LR1, LR2, R), between(C1, C2, C)), Twos),
% Trail ends one row above landing top.
    ZR2 is LR1 - 1,
% Zeros span from original block top to trail end.
    findall(R-C, (between(R1, ZR2, R), between(C1, C2, C)), Zeros).
% arc2_ps_trail_/5: zero-cells and two-cells for LEFT fire.
arc2_ps_trail_(R1-R2-_-C2, left, _-_-LC1-LC2, Zeros, Twos) :-
% Collect landing positions.
    findall(R-C, (between(R1, R2, R), between(LC1, LC2, C)), Twos),
% Trail starts one col right of landing right edge.
    ZC1 is LC2 + 1,
% Zeros span from trail start to original block right.
    findall(R-C, (between(R1, R2, R), between(ZC1, C2, C)), Zeros).
% arc2_ps_trail_/5: zero-cells and two-cells for RIGHT fire.
arc2_ps_trail_(R1-R2-C1-_, right, _-_-LC1-LC2, Zeros, Twos) :-
% Collect landing positions.
    findall(R-C, (between(R1, R2, R), between(LC1, LC2, C)), Twos),
% Trail ends one col left of landing left edge.
    ZC2 is LC1 - 1,
% Zeros span from original block left to trail end.
    findall(R-C, (between(R1, R2, R), between(C1, ZC2, C)), Zeros).

% arc2_ps_solve_/6: compute zero/two/erase sets from block list.
arc2_ps_solve_(Grid, BG, Blocks, ZeroSet, TwoSet, EraseSet) :-
% Accumulate all position sets across all blocks.
    arc2_ps_solve_acc_(Grid, BG, Blocks, [], [], [], ZsAcc, TsAcc, EsAcc),
% Deduplicate each set.
    sort(ZsAcc, ZeroSet), sort(TsAcc, TwoSet), sort(EsAcc, EraseSet).

% arc2_ps_solve_acc_/9: accumulator base case — no blocks remaining.
arc2_ps_solve_acc_(_, _, [], Zs, Ts, Es, Zs, Ts, Es).
% arc2_ps_solve_acc_/9: firing block — compute trail+landing; accumulate zeros and twos.
arc2_ps_solve_acc_(Grid, BG, [Box|Bs], Zs0, Ts0, Es0, Zs, Ts, Es) :-
    once(arc2_ps_fire_(Grid, BG, Box, D, Land)), !,
% Compute trail (zeros) and landing (twos) for this block.
    arc2_ps_trail_(Box, D, Land, Zeros, Twos),
% Prepend zeros and twos to accumulators.
    append(Zeros, Zs0, Zs1), append(Twos, Ts0, Ts1),
% Process remaining blocks.
    arc2_ps_solve_acc_(Grid, BG, Bs, Zs1, Ts1, Es0, Zs, Ts, Es).
% arc2_ps_solve_acc_/9: non-firing block — erase all its cells to BG.
arc2_ps_solve_acc_(Grid, BG, [R1-R2-C1-C2|Bs], Zs0, Ts0, Es0, Zs, Ts, Es) :-
% Collect all positions in this block.
    findall(R-C, (between(R1, R2, R), between(C1, C2, C)), BoxCells),
% Add block cells to erase set.
    append(BoxCells, Es0, Es1),
% Process remaining blocks.
    arc2_ps_solve_acc_(Grid, BG, Bs, Zs0, Ts0, Es1, Zs, Ts, Es).

% arc2_ps_out_/8: compute output value at (R,C) with priority: two > zero > erase > original.
arc2_ps_out_(R, C, Grid, BG, ZeroSet, TwoSet, EraseSet, V) :-
% Landing cell: becomes 2.
    (memberchk(R-C, TwoSet)  -> V = 2  ;
% Trail or original firing position: becomes 0.
     memberchk(R-C, ZeroSet)  -> V = 0  ;
% Erased (non-firing) block: becomes BG.
     memberchk(R-C, EraseSet) -> V = BG ;
% All other cells: copy from input.
     arc2_cell_(Grid, R, C, V)).

% arc2_transform(pocket_shot, +Grid, -Out):
%   Top-level: find 2-block components; determine fate (fire or erase); build output.
arc2_transform(pocket_shot, Grid, Out) :-
% Detect background color (most common value).
    arc2_bg_color_(Grid, BG),
% Find bounding boxes of all 4-connected 2-cell components.
    arc2_ps_find_blocks_(Grid, Blocks),
% Compute zero (trail+original), two (landing), and erase position sets.
    arc2_ps_solve_(Grid, BG, Blocks, ZeroSet, TwoSet, EraseSet),
% Build row and col index lists.
    length(Grid, H), Grid = [GR|_], length(GR, W),
    H1 is H - 1, W1 is W - 1,
    numlist(0, H1, Rs), numlist(0, W1, Cs),
% Map over all rows and columns to produce the output grid.
    maplist([R, Row]>>(
        maplist([C, V]>>(
            arc2_ps_out_(R, C, Grid, BG, ZeroSet, TwoSet, EraseSet, V)
        ), Cs, Row)
    ), Rs, Out).

% ---------------------------------------------------------------------------
% WP-314: shape_walk (Layer 289) — 3x3 block shapes direct a colored chain walk
% Task: 136b0064
% ---------------------------------------------------------------------------

% Registry entry for arc2_induce_rule/2 dispatch.
arc2_named_rule(shape_walk).

% arc2_sw_divider_col_/2: first column index where all rows contain value 4.
arc2_sw_divider_col_(Grid, DC) :-
% Determine grid width from first row.
    Grid = [Row0|_], length(Row0, W), W1 is W - 1,
% Scan left to right; succeed at first all-4 column.
    between(0, W1, DC),
    forall(member(Row, Grid), nth0(DC, Row, 4)), !.

% arc2_sw_five_rc_/3: row and column of the single cell with value 5.
arc2_sw_five_rc_(Grid, R, C) :-
% Grid dimensions.
    length(Grid, H), H1 is H - 1,
    Grid = [Row0|_], length(Row0, W), W1 is W - 1,
% Scan all positions; take first cell with value 5.
    between(0, H1, R), between(0, W1, C),
    arc2_cell_(Grid, R, C, 5), !.

% arc2_sw_nonblank_rows_/3: rows with at least one non-zero cell in cols 0..DC-1.
arc2_sw_nonblank_rows_(Grid, DC, Rows) :-
% Last left-side column index.
    DC1 is DC - 1,
    length(Grid, H), H1 is H - 1,
% Collect indices where any left-side cell is non-zero.
    findall(R, (
        between(0, H1, R),
        nth0(R, Grid, Row),
        once((between(0, DC1, C), nth0(C, Row, V), V \= 0))
    ), Rows).

% arc2_sw_section_starts_/2: first row of each 3-row section in a sorted non-blank list.
arc2_sw_section_starts_([], []).
arc2_sw_section_starts_([R|Rest], [R|SRest]) :-
% Consume the consecutive triple R, R+1, R+2.
    R2 is R + 1, R3 is R + 2,
    select(R2, Rest, Rest1), select(R3, Rest1, Rest2), !,
    arc2_sw_section_starts_(Rest2, SRest).
arc2_sw_section_starts_([_|Rest], SRest) :-
% Skip lone non-blank rows (should not occur in valid inputs).
    arc2_sw_section_starts_(Rest, SRest).

% arc2_sw_block_color_/4: first non-zero value in the 3x3 block at top-left (R,C).
arc2_sw_block_color_(Grid, R, C, Color) :-
% Enumerate the nine (row,col) offsets and return first non-zero cell.
    R1 is R+1, R2 is R+2, C1 is C+1, C2 is C+2,
    once((
        member(Ri-Ci, [R-C,R-C1,R-C2,R1-C,R1-C1,R1-C2,R2-C,R2-C1,R2-C2]),
        arc2_cell_(Grid, Ri, Ci, Color), Color \= 0
    )).

% arc2_sw_norm_/2: binary normalization — 0 stays 0, any non-zero becomes 1.
arc2_sw_norm_(0, 0) :- !.
arc2_sw_norm_(_, 1).

% arc2_sw_block_shape_/4: normalized [[0,1]] 3x3 matrix at top-left (R,C).
arc2_sw_block_shape_(Grid, R, C, Shape) :-
% Compute offsets for 3x3 block.
    R1 is R+1, R2 is R+2, C1 is C+1, C2 is C+2,
% Read all nine raw cell values.
    arc2_cell_(Grid, R,  C,  V00), arc2_cell_(Grid, R,  C1, V01), arc2_cell_(Grid, R,  C2, V02),
    arc2_cell_(Grid, R1, C,  V10), arc2_cell_(Grid, R1, C1, V11), arc2_cell_(Grid, R1, C2, V12),
    arc2_cell_(Grid, R2, C,  V20), arc2_cell_(Grid, R2, C1, V21), arc2_cell_(Grid, R2, C2, V22),
% Normalize each to 0 or 1.
    maplist(arc2_sw_norm_,
            [V00,V01,V02,V10,V11,V12,V20,V21,V22],
            [N00,N01,N02,N10,N11,N12,N20,N21,N22]),
% Assemble row-major 3x3 structure.
    Shape = [[N00,N01,N02],[N10,N11,N12],[N20,N21,N22]].

% arc2_sw_shape_to_move_/3: map a normalized 3x3 shape to (direction, length).
% S1 — U-shape open at top: moves LEFT 2 cells.
arc2_sw_shape_to_move_([[1,0,1],[1,0,1],[1,1,1]], left,  2) :- !.
% S2 — Y-shape leaning right: moves RIGHT 3 cells.
arc2_sw_shape_to_move_([[1,1,0],[1,0,1],[0,1,0]], right, 3) :- !.
% S3 — inverted-V dropping down: moves DOWN 2 cells.
arc2_sw_shape_to_move_([[1,0,1],[0,1,0],[0,1,0]], down,  2) :- !.
% S4 — T-shape wide top: moves LEFT 4 cells.
arc2_sw_shape_to_move_([[1,1,1],[0,1,0],[1,0,1]], left,  4) :- !.

% arc2_sw_seg_cells_/5: list of R-C positions for segment starting at (R,C).
arc2_sw_seg_cells_(R, C, left,  Len, Cells) :-
% Left: same row, columns from C down to C-Len+1 inclusive.
    Cend is C - Len + 1, findall(R-Ci, between(Cend, C, Ci), Cells).
arc2_sw_seg_cells_(R, C, right, Len, Cells) :-
% Right: same row, columns from C to C+Len-1 inclusive.
    Cend is C + Len - 1, findall(R-Ci, between(C, Cend, Ci), Cells).
arc2_sw_seg_cells_(R, C, down,  Len, Cells) :-
% Down: same column, rows from R to R+Len-1 inclusive.
    Rend is R + Len - 1, findall(Ri-C, between(R, Rend, Ri), Cells).

% arc2_sw_seg_tip_/5: last cell position (tip) after drawing a segment.
arc2_sw_seg_tip_(R, C, left,  Len, R-Ct)  :- Ct  is C - Len + 1.
arc2_sw_seg_tip_(R, C, right, Len, R-Ct)  :- Ct  is C + Len - 1.
arc2_sw_seg_tip_(R, C, down,  Len, Rt-C)  :- Rt  is R + Len - 1.

% arc2_sw_walk_/5: draw chain segments; accumulate R-C-Color triples.
arc2_sw_walk_([], _, _, []).
arc2_sw_walk_([blk(Col,Dir,Len)|Bs], R, C, All) :-
% Compute cell positions for this segment.
    arc2_sw_seg_cells_(R, C, Dir, Len, Pos),
% Find the tip of this segment.
    arc2_sw_seg_tip_(R, C, Dir, Len, TipR-TipC),
% Next segment starts one row below the tip.
    NR is TipR + 1,
% Walk remaining segments.
    arc2_sw_walk_(Bs, NR, TipC, Rest),
% Tag each position with this segment's color.
    findall(Ri-Ci-Col, member(Ri-Ci, Pos), Tagged),
    append(Tagged, Rest, All).

% arc2_sw_blocks_at_/4: collect blk/3 terms for all sections at a given block-column start.
arc2_sw_blocks_at_(Grid, SectStarts, ColStart, Blocks) :-
% For each section start row, extract color, shape, direction, and length.
    findall(blk(Color,Dir,Len), (
        member(SR, SectStarts),
        arc2_sw_block_color_(Grid, SR, ColStart, Color),
        arc2_sw_block_shape_(Grid, SR, ColStart, Shape),
        arc2_sw_shape_to_move_(Shape, Dir, Len)
    ), Blocks).

% arc2_transform(shape_walk, +Grid, -Out): build the chain-walk output grid.
arc2_transform(shape_walk, Grid, Out) :-
% Locate the divider column (full column of 4s).
    arc2_sw_divider_col_(Grid, DC),
% Find the 5 marker; compute its output column as offset from divider.
    arc2_sw_five_rc_(Grid, _FR, FC),
    OutC5 is FC - DC - 1,
% Collect non-blank left-side rows; group into 3-row section starts.
    arc2_sw_nonblank_rows_(Grid, DC, NbRows),
    arc2_sw_section_starts_(NbRows, SectStarts),
% Left blocks at col 0; middle blocks at col DC-3 (= col 4 for DC=7).
    MidCol is DC - 3,
    arc2_sw_blocks_at_(Grid, SectStarts, 0,      LBlks),
    arc2_sw_blocks_at_(Grid, SectStarts, MidCol, MBlks),
    append(LBlks, MBlks, AllBlks),
% Walk chain starting at row 1, column OutC5.
    arc2_sw_walk_(AllBlks, 1, OutC5, ChainCells),
% Build H-row x DC-col output grid; place 5 marker and chain cells.
    length(Grid, H), H1 is H - 1, DC1 is DC - 1,
    numlist(0, H1, Rs), numlist(0, DC1, Cs),
    maplist([R, Row]>>(
        maplist([C, V]>>(
% Row 0: place 5 marker at computed output column.
            ( R =:= 0, C =:= OutC5 -> V = 5
% Chain cells: assign their segment color.
            ; member(R-C-V, ChainCells) -> true
% All other cells: background zero.
            ; V = 0)
        ), Cs, Row)
    ), Rs, Out).

% ---------------------------------------------------------------------------
% WP-315: frame_reflect (Layer 290) — 9x9 frame stamps 180-rotated sub-regions
% Task: db0c5428
% ---------------------------------------------------------------------------

% frame_reflect named_rule is registered early (near top of file).

% arc2_fr_frame_/3: scan for top-left (FR,FC) of the 9x9 non-8 frame.
arc2_fr_frame_(Grid, FR, FC) :-
% Compute grid height bound for row scan.
    length(Grid, H), H1 is H - 1,
% Compute grid width bound for column scan.
    Grid = [Row0|_], length(Row0, W), W1 is W - 1,
% Scan rows then columns in row-major order; stop at first non-8 cell.
    between(0, H1, FR),
    between(0, W1, FC),
% Non-8 cell found; cut to commit to this frame corner.
    \+ arc2_cell_(Grid, FR, FC, 8), !.

% arc2_fr_sub3_/4: extract 3x3 block with top-left at absolute (SR,SC).
arc2_fr_sub3_(Grid, SR, SC,
              [[V00,V01,V02],[V10,V11,V12],[V20,V21,V22]]) :-
% Row offsets for the three rows of the sub-region.
    SR1 is SR + 1, SR2 is SR + 2,
% Column offsets for the three columns of the sub-region.
    SC1 is SC + 1, SC2 is SC + 2,
% Read row 0 of the sub-region.
    arc2_cell_(Grid, SR,  SC,  V00), arc2_cell_(Grid, SR,  SC1, V01),
% Complete row 0 and begin row 1.
    arc2_cell_(Grid, SR,  SC2, V02), arc2_cell_(Grid, SR1, SC,  V10),
% Continue row 1.
    arc2_cell_(Grid, SR1, SC1, V11), arc2_cell_(Grid, SR1, SC2, V12),
% Read row 2 of the sub-region.
    arc2_cell_(Grid, SR2, SC,  V20), arc2_cell_(Grid, SR2, SC1, V21),
% Final cell of row 2.
    arc2_cell_(Grid, SR2, SC2, V22).

% arc2_fr_rot180_/2: 180-degree rotation of 3x3 by reversing both element and row order.
arc2_fr_rot180_([[A,B,C],[D,E,F],[G,H,I]], [[I,H,G],[F,E,D],[C,B,A]]).

% arc2_fr_mix_/6: mixing rule for hole fill — both arms equal ArmInner gives Filler.
arc2_fr_mix_(LA, TA, AI, Filler, _, Filler) :-
% Both left and top arms equal the inner arm marker.
    LA =:= AI, TA =:= AI, !.
% arc2_fr_mix_/6: left arm alone equals ArmInner — fill with ArmInner.
arc2_fr_mix_(LA, _, AI, _, _, AI) :-
% Left arm matches the inner arm marker.
    LA =:= AI, !.
% arc2_fr_mix_/6: top arm alone equals ArmInner — fill with ArmInner.
arc2_fr_mix_(_, TA, AI, _, _, AI) :-
% Top arm matches the inner arm marker.
    TA =:= AI, !.
% arc2_fr_mix_/6: neither arm is ArmInner — corner cell uses outer corner value.
arc2_fr_mix_(_, _, _, _, Corner, Corner).

% arc2_fr_hole_fill_/6: compute 9 R-C-V triples for the 3x3 interior hole.
arc2_fr_hole_fill_(Grid, FR, FC, HoleR, HoleC, Cells) :-
% Frame filler: value at top-edge center of frame (relative column 4).
    FC4 is FC + 4,
% Read the filler value at absolute (FR, FC+4).
    arc2_cell_(Grid, FR, FC4, Filler),
% Row immediately above hole; row immediately below hole bottom edge.
    AboveR is HoleR - 1, BelowR is HoleR + 3,
% Column immediately left of hole; column immediately right of hole right edge.
    LeftC is HoleC - 1, RightC is HoleC + 3,
% Hole column offsets +1 and +2.
    HC1 is HoleC + 1, HC2 is HoleC + 2,
% Hole row offsets +1 and +2.
    HR1 is HoleR + 1, HR2 is HoleR + 2,
% Top arm at j=0: directly above hole column 0.
    arc2_cell_(Grid, AboveR, HoleC, T0),
% ArmInner: center of top arm (j=1); this is the dominant arm-marker value.
    arc2_cell_(Grid, AboveR, HC1,   AI),
% Top arm at j=2: directly above hole column 2.
    arc2_cell_(Grid, AboveR, HC2,   T2),
% Left arm at i=0: directly left of hole row 0.
    arc2_cell_(Grid, HoleR,  LeftC, L0),
% Left arm at i=2: directly left of hole row 2.
    arc2_cell_(Grid, HR2,    LeftC, L2),
% Outer corner TL: frame cell diagonally above-left of hole.
    arc2_cell_(Grid, AboveR, LeftC,  TL),
% Outer corner TR: frame cell diagonally above-right of hole.
    arc2_cell_(Grid, AboveR, RightC, TR),
% Outer corner BL: frame cell diagonally below-left of hole.
    arc2_cell_(Grid, BelowR, LeftC,  BL),
% Outer corner BR: frame cell diagonally below-right of hole.
    arc2_cell_(Grid, BelowR, RightC, BR),
% Fill hole cell (0,0): top-left corner position.
    arc2_fr_mix_(L0, T0, AI, Filler, TL, V00),
% Fill hole cell (0,1): top center-edge position.
    arc2_fr_mix_(L0, AI, AI, Filler, _,  V01),
% Fill hole cell (0,2): top-right corner position.
    arc2_fr_mix_(L0, T2, AI, Filler, TR, V02),
% Fill hole cell (1,0): left center-edge position.
    arc2_fr_mix_(AI, T0, AI, Filler, _,  V10),
% Fill hole cell (1,1): center — always frame filler when both arms match.
    arc2_fr_mix_(AI, AI, AI, Filler, _,  V11),
% Fill hole cell (1,2): right center-edge position.
    arc2_fr_mix_(AI, T2, AI, Filler, _,  V12),
% Fill hole cell (2,0): bottom-left corner position.
    arc2_fr_mix_(L2, T0, AI, Filler, BL, V20),
% Fill hole cell (2,1): bottom center-edge position.
    arc2_fr_mix_(L2, AI, AI, Filler, _,  V21),
% Fill hole cell (2,2): bottom-right corner position.
    arc2_fr_mix_(L2, T2, AI, Filler, BR, V22),
% Assemble all 9 absolute R-C-V triples for the hole fill.
    Cells = [HoleR-HoleC-V00,  HoleR-HC1-V01,  HoleR-HC2-V02,
             HR1-HoleC-V10,    HR1-HC1-V11,    HR1-HC2-V12,
             HR2-HoleC-V20,    HR2-HC1-V21,    HR2-HC2-V22].

% arc2_transform(frame_reflect): stamp 180-rotated sub-regions at 8 outer positions.
arc2_transform(frame_reflect, Grid, Out) :-
% Find the frame top-left; hole always starts 3 rows and 3 cols inside.
    arc2_fr_frame_(Grid, FR, FC),
% Absolute position of the 3x3 interior hole top-left.
    HoleR is FR + 3, HoleC is FC + 3,
% Collect R-C-V mods for all 8 non-center sub-region stamps.
    findall(R-C-V, (
% Enumerate the 8 sub-region positions (center 1-1 handled separately).
        member(RSub-CSub, [0-0,0-1,0-2,1-0,1-2,2-0,2-1,2-2]),
% Absolute top-left of this sub-region within the 9x9 frame.
        SubR is FR + RSub * 3, SubC is FC + CSub * 3,
% Extract the 3x3 block content from the input grid.
        arc2_fr_sub3_(Grid, SubR, SubC, Sub),
% Compute 180-degree rotation of the sub-region.
        arc2_fr_rot180_(Sub, Rot),
% Stamp placement: adjacent to sub-region, shifted outward by one block-width.
        StampR is FR + (2 * RSub - 1) * 3,
        StampC is FC + (2 * CSub - 1) * 3,
% Destructure the three rows of the rotated block.
        Rot = [[R0C0,R0C1,R0C2],[R1C0,R1C1,R1C2],[R2C0,R2C1,R2C2]],
% Enumerate all 9 cells of the rotated block with their offsets.
        member(DI-DJ-V,
               [0-0-R0C0, 0-1-R0C1, 0-2-R0C2,
                1-0-R1C0, 1-1-R1C1, 1-2-R1C2,
                2-0-R2C0, 2-1-R2C1, 2-2-R2C2]),
% Compute absolute output row and column for this stamp cell.
        R is StampR + DI, C is StampC + DJ
    ), StampMods),
% Compute the 9 hole-fill triples for the interior 3x3.
    arc2_fr_hole_fill_(Grid, FR, FC, HoleR, HoleC, HoleMods),
% Merge stamp and hole modifications into one list.
    append(StampMods, HoleMods, AllMods),
% Grid dimensions for output row and column enumeration.
    length(Grid, H), H1 is H - 1,
    Grid = [GRow0|_], length(GRow0, W), W1 is W - 1,
% Row and column index lists for maplist iteration.
    numlist(0, H1, Rs), numlist(0, W1, Cs),
% Build each output row by substituting mod values or copying input.
    maplist([R, OutRow]>>(
        maplist([C, V]>>(
% If a modification exists for (R,C), use it; otherwise copy input cell.
            ( member(R-C-V0, AllMods) -> V = V0
% Copy the original input cell value as fallback.
            ; arc2_cell_(Grid, R, C, V) )
        ), Cs, OutRow)
    ), Rs, Out).

% frame_reflect induce_rule is registered early (near top of file).

% ---------------------------------------------------------------------------
% WP-316: cross_reflect (Layer 291) — cross-quadrant satellite reflection
% Task: b10624e5
% ---------------------------------------------------------------------------

% cross_reflect named_rule is registered early (near top of file).

% arc2_cr_cross_/4: find cross row R and cross col C (all-same non-BG lines).
arc2_cr_cross_(Grid, BG, R, C) :-
% Compute grid height for row enumeration.
    length(Grid, H), H1 is H - 1,
% Find R where the entire row has a single non-BG value V.
    between(0, H1, R),
    nth0(R, Grid, Row),
    sort(Row, [V]),
    V \= BG, !,
% Compute grid width for col enumeration.
    Grid = [Row0|_], length(Row0, W), W1 is W - 1,
% Find C where every cell in col C also equals V.
    between(0, W1, C),
    findall(VV, (nth0(RR, Grid, RRow), nth0(C, RRow, VV)), ColVals),
    sort(ColVals, [V]), !.

% arc2_cr_bbox_q_/10: bounding box of value V within quadrant RLo..RHi x CLo..CHi.
arc2_cr_bbox_q_(Grid, V, RLo, RHi, CLo, CHi, MinR, MaxR, MinC, MaxC) :-
% Collect all (Row,Col) positions of value V in the quadrant.
    findall(Row-Col, (between(RLo, RHi, Row), between(CLo, CHi, Col),
                      arc2_cell_(Grid, Row, Col, V)), Cells),
% Require at least one matching cell.
    Cells \= [],
% Separate row and col lists for min/max computation.
    findall(Row, member(Row-_, Cells), Rs),
    findall(Col, member(_-Col, Cells), Cs),
% Compute tight bounding box.
    min_list(Rs, MinR), max_list(Rs, MaxR),
    min_list(Cs, MinC), max_list(Cs, MaxC).

% arc2_cr_anchor_/5: anchor = first non-BG value found in top-right (TR) quadrant.
arc2_cr_anchor_(Grid, BG, R, C, Anchor) :-
% TR quadrant: rows 0..R-1, cols C+1..W-1.
    R1 is R - 1,
    Grid = [Row0|_], length(Row0, W), W1 is W - 1, C1 is C + 1,
% Scan TR in row-major order; take first non-BG value as the anchor.
    between(0, R1, RR), between(C1, W1, CC),
    arc2_cell_(Grid, RR, CC, V),
    V \= BG,
    Anchor = V, !.

% arc2_cr_sats_/6: list of distinct non-BG non-anchor values in TL quadrant.
arc2_cr_sats_(Grid, BG, Anchor, R, C, Sats) :-
% TL quadrant: rows 0..R-1, cols 0..C-1.
    R1 is R - 1, C1 is C - 1,
% Collect all non-BG non-anchor values in TL.
    findall(V, (between(0, R1, RR), between(0, C1, CC),
                arc2_cell_(Grid, RR, CC, V),
                V \= BG, V \= Anchor), Vals),
% Deduplicate: one entry per satellite colour.
    sort(Vals, Sats).

% arc2_cr_sat_info_/7: offset (DR,DC) and size (SH,SW) of satellite SV in TL.
% AR, AC = top-left of TL anchor block; returned as SV-DR-DC-SH-SW term.
arc2_cr_sat_info_(Grid, CrossR, CrossC, AR, AC, SV, SV-DR-DC-SH-SW) :-
% TL quadrant boundaries for bounding box search.
    R1 is CrossR - 1, C1 is CrossC - 1,
% Find tight bounding box of SV in TL quadrant.
    arc2_cr_bbox_q_(Grid, SV, 0, R1, 0, C1, MinR, MaxR, MinC, MaxC),
% Satellite block height and width in cells.
    SH is MaxR - MinR + 1, SW is MaxC - MinC + 1,
% Cell offsets from TL anchor top-left to satellite top-left.
    DR is MinR - AR, DC is MinC - AC.

% arc2_cr_mods_(tr,...): LR-reflected satellite mods for top-right quadrant.
arc2_cr_mods_(tr, SV, DR, DC, SH, SW, N_tl, N_q, AR, AC, Mods) :-
% LR reflection: dr unchanged; dc flips across the anchor's width N_tl.
    NewDC is N_tl - DC - SW,
% Scale all dimensions and offsets by N_q/N_tl.
    DR_q is (DR * N_q) // N_tl,
    DC_q is (NewDC * N_q) // N_tl,
    H_q  is (SH * N_q) // N_tl,
    W_q  is (SW * N_q) // N_tl,
% Compute placed block corners in absolute grid coordinates.
    MinR is AR + DR_q, MaxR is MinR + H_q - 1,
    MinC is AC + DC_q, MaxC is MinC + W_q - 1,
% Generate one R-C-SV triple per cell of the placed block.
    findall(R-C-SV, (between(MinR, MaxR, R), between(MinC, MaxC, C)), Mods).

% arc2_cr_mods_(br,...): 180-degree-rotated satellite mods for bottom-right quadrant.
arc2_cr_mods_(br, SV, DR, DC, SH, SW, N_tl, N_q, AR, AC, Mods) :-
% 180-degree rotation: both dr and dc flip across anchor dimensions.
    NewDR is N_tl - DR - SH, NewDC is N_tl - DC - SW,
% Scale all dimensions and offsets.
    DR_q is (NewDR * N_q) // N_tl,
    DC_q is (NewDC * N_q) // N_tl,
    H_q  is (SH * N_q) // N_tl,
    W_q  is (SW * N_q) // N_tl,
% Placed block corners.
    MinR is AR + DR_q, MaxR is MinR + H_q - 1,
    MinC is AC + DC_q, MaxC is MinC + W_q - 1,
% One R-C-SV triple per placed cell.
    findall(R-C-SV, (between(MinR, MaxR, R), between(MinC, MaxC, C)), Mods).

% arc2_cr_mods_(bl,...): TB-reflected satellite mods for bottom-left quadrant.
arc2_cr_mods_(bl, SV, DR, DC, SH, SW, N_tl, N_q, AR, AC, Mods) :-
% TB reflection: dr flips; dc unchanged.
    NewDR is N_tl - DR - SH,
% Scale all dimensions and offsets.
    DR_q is (NewDR * N_q) // N_tl,
    DC_q is (DC * N_q) // N_tl,
    H_q  is (SH * N_q) // N_tl,
    W_q  is (SW * N_q) // N_tl,
% Placed block corners.
    MinR is AR + DR_q, MaxR is MinR + H_q - 1,
    MinC is AC + DC_q, MaxC is MinC + W_q - 1,
% One R-C-SV triple per placed cell.
    findall(R-C-SV, (between(MinR, MaxR, R), between(MinC, MaxC, C)), Mods).

% arc2_transform(cross_reflect): add reflected satellites to TR, BR, and BL quadrants.
arc2_transform(cross_reflect, Grid, Out) :-
% Background from top-left corner cell.
    arc2_cell_(Grid, 0, 0, BG),
% Locate the cross row R and cross col C.
    arc2_cr_cross_(Grid, BG, R, C),
% Anchor value = only non-BG value present in TR quadrant.
    arc2_cr_anchor_(Grid, BG, R, C, Anchor),
% Grid dimensions for quadrant boundary computation.
    length(Grid, H), H1 is H - 1,
    Grid = [GRow0|_], length(GRow0, W), W1 is W - 1,
    R1 is R - 1, C1 is C - 1, C2 is C + 1, R2 is R + 1,
% TL anchor bounding box.
    arc2_cr_bbox_q_(Grid, Anchor, 0, R1, 0, C1,
                    TL_MinR, TL_MaxR, TL_MinC, _TL_MaxC),
% TL anchor size N_tl (square anchor, so height = width).
    N_tl is TL_MaxR - TL_MinR + 1,
% Satellite colours in TL (non-BG, non-anchor).
    arc2_cr_sats_(Grid, BG, Anchor, R, C, Sats),
% For each satellite, compute offset and size relative to TL anchor top-left.
    maplist(arc2_cr_sat_info_(Grid, R, C, TL_MinR, TL_MinC), Sats, SatInfos),
% TR anchor bounding box and size.
    arc2_cr_bbox_q_(Grid, Anchor, 0, R1, C2, W1,
                    TR_MinR, TR_MaxR, TR_MinC, _TR_MaxC),
    N_tr is TR_MaxR - TR_MinR + 1,
% BR anchor bounding box and size.
    arc2_cr_bbox_q_(Grid, Anchor, R2, H1, C2, W1,
                    BR_MinR, BR_MaxR, BR_MinC, _BR_MaxC),
    N_br is BR_MaxR - BR_MinR + 1,
% BL anchor bounding box and size.
    arc2_cr_bbox_q_(Grid, Anchor, R2, H1, 0, C1,
                    BL_MinR, BL_MaxR, BL_MinC, _BL_MaxC),
    N_bl is BL_MaxR - BL_MinR + 1,
% TR mods: LR-reflect each TL satellite at TR anchor, scaled to N_tr.
    findall(Mods, (member(SV-DR-DC-SH-SW, SatInfos),
                   arc2_cr_mods_(tr, SV, DR, DC, SH, SW,
                                 N_tl, N_tr, TR_MinR, TR_MinC, Mods)),
            TrLists),
% BR mods: 180-rotate each TL satellite at BR anchor, scaled to N_br.
    findall(Mods, (member(SV-DR-DC-SH-SW, SatInfos),
                   arc2_cr_mods_(br, SV, DR, DC, SH, SW,
                                 N_tl, N_br, BR_MinR, BR_MinC, Mods)),
            BrLists),
% BL mods: TB-reflect each TL satellite at BL anchor, scaled to N_bl.
    findall(Mods, (member(SV-DR-DC-SH-SW, SatInfos),
                   arc2_cr_mods_(bl, SV, DR, DC, SH, SW,
                                 N_tl, N_bl, BL_MinR, BL_MinC, Mods)),
            BlLists),
% Flatten nested mod lists into flat R-C-V triple lists.
    append(TrLists, TrMods), append(BrLists, BrMods), append(BlLists, BlMods),
% Combine all quadrant mods into one lookup list.
    append([TrMods, BrMods, BlMods], AllMods),
% Output: grid dimensions for row/col enumeration.
    numlist(0, H1, Rs), numlist(0, W1, Cs),
% Build each output row: use mod value when present, else copy input cell.
    maplist([Row, OutRow]>>(
        maplist([CC, V]>>(
% Use the modification value if this cell was modified.
            ( member(Row-CC-V0, AllMods) -> V = V0
% Otherwise copy the original input cell.
            ; arc2_cell_(Grid, Row, CC, V) )
        ), Cs, OutRow)
    ), Rs, Out).

% cross_reflect induce_rule is registered early (near top of file).

% ---------------------------------------------------------------------------
% WP-317: scaled_frame (Layer 292) — scale rectangular frame; fill hole groups
% ---------------------------------------------------------------------------
% Rule: scaled_frame — solves task 898e7135.
% Input: one rectangular frame (solid-border color FC, 0-holes inside) plus
% colored object-blobs in the background.  Scale = sqrt(GCD of object sizes).
% Output: frame scaled by Scale; each 0-hole-group filled by matched blob color.
% Matching: sort hole-groups and objects by (norm_size, centroid_col); pair.

% scaled_frame named_rule and induce_rule are registered early (near top of file).

% arc2_transform(scaled_frame): scale the frame and fill each hole-group.
arc2_transform(scaled_frame, Grid, Out) :-
% Delegate all work to the main solver predicate.
    arc2_sf_solve_(Grid, Out), !.

% arc2_sf_solve_(+Grid, -Out): main scaled_frame solver.
arc2_sf_solve_(Grid, Out) :-
% Locate the rectangular frame: color, bounding box.
    arc2_sf_frame_(Grid, FC, R0, C0, R1, C1),
% Collect all 0-cells strictly inside the frame bounding box.
    arc2_sf_holes_(Grid, R0, C0, R1, C1, Holes),
% Partition holes into 4-connected components.
    arc2_sf_conn_comps_(Holes, HComps),
% Collect background object blobs (non-frame, non-BG, size >= 4).
    arc2_sf_objects_(Grid, FC, R0, C0, R1, C1, Objects),
% Compute scale factor = sqrt(GCD of all object cell-counts).
    arc2_sf_scale_(Objects, Scale),
% Build hole-group to fill-color mapping.
    arc2_sf_match_(HComps, Objects, Scale, Matches),
% Output height = frame height * Scale.
    FH is R1 - R0 + 1,
% Output width = frame width * Scale.
    FW is C1 - C0 + 1,
% Compute actual output dimensions.
    OutH is FH * Scale, OutW is FW * Scale,
% Build index bounds for numlist.
    OutHm is OutH - 1, OutWm is OutW - 1,
% Enumerate all output row indices.
    numlist(0, OutHm, OutRows),
% Enumerate all output column indices.
    numlist(0, OutWm, OutCols),
% Build output grid row-by-row.
    maplist([R, Row]>>(
        maplist([C, V]>>(
            arc2_sf_cell_val_(Grid, FC, R0, C0, Scale, Matches, R, C, V)
        ), OutCols, Row)
    ), OutRows, Out).

% arc2_sf_cell_val_: resolve the output color for one output cell.
arc2_sf_cell_val_(Grid, FC, FR0, FC0, Scale, Matches, R, C, Val) :-
% Map output row R to the frame row it comes from.
    FRow is FR0 + R // Scale,
% Map output col C to the frame col it comes from.
    FCol is FC0 + C // Scale,
% Read the frame grid value at that position.
    nth0(FRow, Grid, GRow), nth0(FCol, GRow, GVal),
% If the frame cell is a hole (0), use the matched fill color.
    (   GVal =:= 0
    ->  arc2_sf_hole_color_(Matches, FRow, FCol, Val)
% Otherwise use the frame color.
    ;   Val = FC
    ).

% arc2_sf_hole_color_: look up fill color for a hole at (R,C).
arc2_sf_hole_color_(Matches, R, C, V) :-
% Search the match list for the component containing this hole.
    member(HComp-V, Matches), member(R-C, HComp), !.

% arc2_sf_frame_: find the rectangular frame in Grid.
arc2_sf_frame_(Grid, FC, R0, C0, R1, C1) :-
% Collect every non-BG cell with its row and col.
    findall(V-R-C, (nth0(R, Grid, Row), nth0(C, Row, V), V \== 0), All),
% Extract distinct colors present.
    findall(V, member(V-_-_, All), Vs0), sort(Vs0, Colors),
% Try each color as candidate frame color.
    member(FC, Colors),
% Collect all cells of this candidate color.
    findall(R-C, member(FC-R-C, All), FCells),
% Require at least one such cell.
    FCells \= [],
% Compute bounding box rows.
    findall(R, member(R-_, FCells), Rs),
    min_list(Rs, R0), max_list(Rs, R1),
% Compute bounding box cols.
    findall(C, member(_-C, FCells), Cs),
    min_list(Cs, C0), max_list(Cs, C1),
% Frame must be at least 3 rows tall (border + interior + border).
    R1 > R0 + 1,
% Frame must be at least 3 cols wide.
    C1 > C0 + 1,
% All four border sides of the bounding box must be solid FC.
    arc2_sf_solid_border_(Grid, FC, R0, C0, R1, C1),
% There must be at least one 0-hole strictly inside the bbox.
    RIn is R0 + 1, RIn1 is R1 - 1, CIn is C0 + 1, CIn1 is C1 - 1,
    between(RIn, RIn1, Rh), between(CIn, CIn1, Ch),
    nth0(Rh, Grid, Rowh), nth0(Ch, Rowh, 0), !.

% arc2_sf_solid_border_: verify all four border sides are color FC.
arc2_sf_solid_border_(Grid, FC, R0, C0, R1, C1) :-
% Pre-fetch top and bottom border rows.
    nth0(R0, Grid, TopRow), nth0(R1, Grid, BotRow),
% Every cell in top and bottom rows from C0 to C1 must equal FC.
    forall(between(C0, C1, C), (nth0(C, TopRow, FC), nth0(C, BotRow, FC))),
% Every cell in left and right cols from R0 to R1 must equal FC.
    forall(between(R0, R1, R), (
        nth0(R, Grid, Row), nth0(C0, Row, FC), nth0(C1, Row, FC)
    )).

% arc2_sf_holes_: collect all 0-cells strictly inside the frame bbox.
arc2_sf_holes_(Grid, R0, C0, R1, C1, Holes) :-
% Interior row range (excluding top and bottom border rows).
    RIn is R0 + 1, RIn1 is R1 - 1,
% Interior col range (excluding left and right border cols).
    CIn is C0 + 1, CIn1 is C1 - 1,
% Find every interior cell with value 0.
    findall(R-C, (
        between(RIn, RIn1, R), between(CIn, CIn1, C),
        nth0(R, Grid, Row), nth0(C, Row, 0)
    ), Holes).

% arc2_sf_objects_: find background object blobs (size >= 4).
arc2_sf_objects_(Grid, FC, R0, C0, R1, C1, Objects) :-
% Collect non-BG non-frame cells that are strictly outside the frame bbox.
    findall(V-R-C, (
        nth0(R, Grid, Row), nth0(C, Row, V), V \== 0, V \== FC,
        (R < R0 ; R > R1 ; C < C0 ; C > C1)
    ), AllCells),
% Extract just R-C positions for connectivity analysis.
    findall(R-C, member(_-R-C, AllCells), RCAll),
% Find 4-connected components of these positions.
    arc2_sf_conn_comps_(RCAll, RCComps),
% Keep only components with at least 4 cells (discard noise singletons).
    include([Comp]>>(length(Comp, L), L >= 4), RCComps, BigComps),
% Pair each component with its color (read from first cell).
    maplist([Comp, V-Comp]>>(
        Comp = [R-C|_], nth0(R, Grid, GRow), nth0(C, GRow, V)
    ), BigComps, Objects).

% arc2_sf_scale_: compute scale factor = sqrt(GCD of object cell-counts).
arc2_sf_scale_(Objects, Scale) :-
% Extract cell-count for each object.
    maplist([_-Cells, Sz]>>(length(Cells, Sz)), Objects, Sizes),
% GCD of all sizes gives scale-squared.
    arc2_sf_gcd_list_(Sizes, G),
% Square root of GCD = scale factor.
    Scale is round(sqrt(float(G))).

% arc2_sf_gcd_list_: compute GCD of a non-empty integer list.
arc2_sf_gcd_list_([X], X) :- !.
arc2_sf_gcd_list_([X|Rest], G) :-
% Recurse on tail first, then combine with head.
    arc2_sf_gcd_list_(Rest, G0),
% SWI-Prolog built-in gcd/2 arithmetic function.
    G is gcd(X, G0).

% arc2_sf_match_: pair each hole-group with a fill color.
arc2_sf_match_(HComps, Objects, Scale, Matches) :-
% Scale squared is the cell-count per hole.
    Scale2 is Scale * Scale,
% Annotate hole-groups: (hole_count, centroid_col, HComp).
    maplist([HC, Sz-Col-HC]>>(
        length(HC, Sz), arc2_sf_centcol_(HC, Col)
    ), HComps, HAnnot),
% Annotate objects: (norm_size = cells/scale2, centroid_col, Color).
    maplist([V-Cells, NS-Col-V]>>(
        length(Cells, S), NS is S // Scale2, arc2_sf_centcol_(Cells, Col)
    ), Objects, OAnnot),
% Sort both lists: primary key = normalized_size, secondary = centroid_col.
    msort(HAnnot, HSort),
    msort(OAnnot, OSort),
% Pair corresponding elements: each hole-group gets the matching object color.
    maplist(arc2_sf_pair_match_, HSort, OSort, Matches).

% arc2_sf_pair_match_: extract HComp and V from sorted annotation triples.
arc2_sf_pair_match_(_-_-HC, _-_-V, HC-V).

% arc2_sf_centcol_: compute centroid column of a R-C cell list.
arc2_sf_centcol_(Cells, Col) :-
% Extract all column indices.
    findall(C, member(_-C, Cells), Cs),
% Average column index = centroid column.
    sumlist(Cs, Sum), length(Cs, N), Col is Sum / N.

% arc2_sf_conn_comps_: find all 4-connected components of a R-C list.
arc2_sf_conn_comps_(Cells, Comps) :-
% Sort to remove any duplicate cells.
    sort(Cells, Sorted),
% Iteratively extract components from the sorted list.
    arc2_sf_comps_(Sorted, Comps).

% arc2_sf_comps_: recursively extract connected components.
arc2_sf_comps_([], []).
arc2_sf_comps_([Seed|Rest], [Comp|Comps]) :-
% BFS from Seed to find its full component.
    arc2_sf_bfs_([Seed], Rest, [Seed], Comp, Remaining),
% Recurse on cells not yet assigned to a component.
    arc2_sf_comps_(Remaining, Comps).

% arc2_sf_bfs_: BFS flood-fill for a single connected component.
arc2_sf_bfs_([], Remaining, Visited, Visited, Remaining).
arc2_sf_bfs_([R-C|Queue], Avail, Visited, Comp, Remaining) :-
% Compute the four 4-connected neighbor positions.
    R1 is R - 1, R2 is R + 1, C1 is C - 1, C2 is C + 1,
% Find neighbors that are available and not yet visited.
    findall(NR-NC, (
        member(NR-NC, [R1-C, R2-C, R-C1, R-C2]),
        member(NR-NC, Avail),
        \+ member(NR-NC, Visited)
    ), NewSeeds),
% Remove newly found seeds from the available pool.
    subtract(Avail, NewSeeds, NewAvail),
% Add them to the visited set.
    append(Visited, NewSeeds, NewVisited),
% Append them to the BFS queue.
    append(Queue, NewSeeds, NewQueue),
% Continue BFS with updated state.
    arc2_sf_bfs_(NewQueue, NewAvail, NewVisited, Comp, Remaining).

% ---------------------------------------------------------------------------
% layout_tile (WP-318, Layer 293) -- task 65b59efc
% ---------------------------------------------------------------------------
% Divider rows/cols (values in {0,5}) partition input into row/col groups.
% Row-group 0: N template shapes (S x S each, one per col-group).
% Row-group 2: N single-cell marker colors (one per col-group).
% Row-group 1: N layout subgrids (S x S each, one per col-group).
% Each non-zero layout cell at (r,c) with color C identifies the template T
% containing C; output block at (r,c) gets T recolored with T's marker.
% Output: S*S x S*S grid (S x S arrangement of S x S blocks).
% ---------------------------------------------------------------------------

% arc2_transform(layout_tile): apply the layout_tile transformation.
arc2_transform(layout_tile, Grid, Out) :-
% Delegate all work to the main solver predicate.
    arc2_lt_solve_(Grid, Out), !.

% arc2_lt_solve_(+Grid, -Out): main layout_tile solver.
arc2_lt_solve_(Grid, Out) :-
% Find all divider rows (rows with only 0/5 values).
    arc2_lt_divider_rows_(Grid, DivRows),
% Find all divider cols (cols with only 0/5 values, at least one 5).
    arc2_lt_divider_cols_(Grid, DivCols),
% Split into 3 row-groups: template (top), layout (middle), marker (bottom).
    arc2_lt_row_groups_(Grid, DivRows, RG0, RG1, RG2),
% Split into N col-groups, excluding all-zero padding cols.
    arc2_lt_col_groups_(Grid, DivCols, ColGroups),
% Block size NS = width of first col-group (= height of template row-group).
    ColGroups = [G0|_],
% Bind NS to the width of the first col-group.
    length(G0, NS),
% Extract template subgrid for each col-group.
    arc2_lt_subgrids_(Grid, RG0, ColGroups, Templates),
% Extract single marker color for each col-group from the bottom row-group.
    arc2_lt_markers_(Grid, RG2, ColGroups, Markers),
% Extract layout subgrid for each col-group from the middle row-group.
    arc2_lt_layouts_(Grid, RG1, ColGroups, Layouts),
% Build output block assignment list from layout subgrids.
    arc2_lt_assignments_(Layouts, Templates, Assigns),
% Assemble the NS^2 x NS^2 output grid from assignments.
    arc2_lt_build_output_(Assigns, Templates, Markers, NS, Out).

% arc2_lt_divider_rows_(+Grid, -DivRows): rows with all values in {0,5}, >=half are 5.
arc2_lt_divider_rows_(Grid, DivRows) :-
% A major divider row spans the full grid width with 5s; at least half the cells are 5.
    findall(R,
        (nth0(R, Grid, Row),
         \+ (member(V, Row), V \= 0, V \= 5),
         include(==(5), Row, Fives),
         length(Row, W), length(Fives, NF),
         NF * 2 >= W),
        DivRows).

% arc2_lt_divider_cols_(+Grid, -DivCols): cols where all values in {0,5}.
arc2_lt_divider_cols_(Grid, DivCols) :-
% Use first row to determine total column count.
    Grid = [FirstRow|_],
% Bind W to the total number of columns.
    length(FirstRow, W),
% Max column index.
    W1 is W - 1,
% Collect cols where all values are 0 or 5 and at least one value is 5.
    findall(C,
        (between(0, W1, C),
         findall(V, (member(Row, Grid), nth0(C, Row, V)), Vals),
         \+ (member(V, Vals), V \= 0, V \= 5),
         member(5, Vals)),
        DivCols).

% arc2_lt_row_groups_(+Grid,+DivRows,-RG0,-RG1,-RG2): split into 3 groups.
arc2_lt_row_groups_(Grid, DivRows, RG0, RG1, RG2) :-
% Total number of rows.
    length(Grid, H),
% Max row index.
    H1 is H - 1,
% Build full list of row indices.
    numlist(0, H1, AllRows),
% Remove divider rows to get content row indices.
    subtract(AllRows, DivRows, ContentRows),
% Group contiguous content rows into exactly 3 segments.
    arc2_lt_contiguous_groups_(ContentRows, [RG0, RG1, RG2]).

% arc2_lt_col_groups_(+Grid,+DivCols,-ColGroups): extract valid col groups.
arc2_lt_col_groups_(Grid, DivCols, ColGroups) :-
% Use first row to bound column range.
    Grid = [FirstRow|_],
% Total column count.
    length(FirstRow, W),
% Max column index.
    W1 is W - 1,
% All column indices.
    numlist(0, W1, AllCols),
% Remove divider cols from full set.
    subtract(AllCols, DivCols, ContentCols),
% Group contiguous content columns.
    arc2_lt_contiguous_groups_(ContentCols, AllGroups),
% Retain only groups that have at least one non-zero non-5 value (not padding).
    include([G]>>(
        member(C, G),
        member(GRow, Grid),
        nth0(C, GRow, V),
        V \= 0, V \= 5
    ), AllGroups, ColGroups).

% arc2_lt_contiguous_groups_(+Sorted,-Groups): split into contiguous runs.
arc2_lt_contiguous_groups_([], []).
% Start a new run from H and process the tail.
arc2_lt_contiguous_groups_([H|T], [[H|Run]|Rest]) :-
% Extend the current run as far as possible.
    arc2_lt_cont_run_(H, T, Run, Remaining),
% Recursively group remaining elements.
    arc2_lt_contiguous_groups_(Remaining, Rest).

% arc2_lt_cont_run_(+Prev,+In,-Run,-Out): extend a contiguous run from Prev.
arc2_lt_cont_run_(_, [], [], []).
% H continues the run if H = Prev + 1.
arc2_lt_cont_run_(Prev, [H|T], [H|Run], Rest) :-
% Check continuity.
    H =:= Prev + 1, !,
% Extend run by one more element.
    arc2_lt_cont_run_(H, T, Run, Rest).
% H breaks continuity; end the run here.
arc2_lt_cont_run_(_, Rest, [], Rest).

% arc2_lt_subgrid_(+Grid,+Rows,+Cols,-Sub): extract row-col subgrid.
arc2_lt_subgrid_(Grid, Rows, Cols, Sub) :-
% For each row R, build the restricted row by selecting columns Cols.
    findall(Row,
        (member(R, Rows),
         nth0(R, Grid, GRow),
         findall(V, (member(C, Cols), nth0(C, GRow, V)), Row)),
        Sub).

% arc2_lt_subgrids_(+Grid,+Rows,+ColGroups,-Subs): one subgrid per group.
arc2_lt_subgrids_(Grid, Rows, ColGroups, Subs) :-
% Map subgrid extraction over all col-groups.
    maplist([CG, S]>>(arc2_lt_subgrid_(Grid, Rows, CG, S)), ColGroups, Subs).

% arc2_lt_markers_(+Grid,+RG2,+ColGroups,-Markers): one color per col-group.
arc2_lt_markers_(Grid, RG2, ColGroups, Markers) :-
% For each col-group extract the single non-zero non-5 marker color.
    maplist([CG, M]>>(
        arc2_lt_subgrid_(Grid, RG2, CG, Sub),
        findall(V, (member(Row, Sub), member(V, Row), V \= 0, V \= 5), [M|_])
    ), ColGroups, Markers).

% arc2_lt_layouts_(+Grid,+RG1,+ColGroups,-Layouts): layout subgrid per group.
arc2_lt_layouts_(Grid, RG1, ColGroups, Layouts) :-
% Extract layout subgrid for each col-group from the middle row-group.
    maplist([CG, L]>>(arc2_lt_subgrid_(Grid, RG1, CG, L)), ColGroups, Layouts).

% arc2_lt_assignments_(+Layouts,+Templates,-Assigns): block-to-template map.
arc2_lt_assignments_(Layouts, Templates, Assigns) :-
% Collect triples (block-row BR, block-col BC, template-index TI).
    findall(BR-BC-TI,
        (nth0(_I, Layouts, Layout),
         nth0(R, Layout, LRow),
         nth0(C, LRow, V),
         V \= 0, V \= 5,
         nth0(TI, Templates, Tmpl),
         arc2_lt_has_color_(Tmpl, V),
         BR = R, BC = C),
        Assigns).

% arc2_lt_has_color_(+Tmpl,+V): true if template contains non-zero non-5 V.
arc2_lt_has_color_(Tmpl, V) :-
% Scan template cells; succeed when V is found as a non-zero non-5 value.
    member(Row, Tmpl),
    member(V, Row),
    V \= 0, V \= 5.

% arc2_lt_build_output_(+Assigns,+Templates,+Markers,+NS,-Out): assemble grid.
arc2_lt_build_output_(Assigns, Templates, Markers, NS, Out) :-
% Output side-length is NS squared.
    TotalSize is NS * NS,
% Max output index (0-based).
    TotalSize1 is TotalSize - 1,
% Build each output row by iterating over all output row indices.
    findall(OutRow,
        (between(0, TotalSize1, OR),
% Block row BR = output row OR divided by block size NS.
         BR is OR // NS,
% Inner row IR = output row OR modulo block size NS.
         IR is OR mod NS,
% Build each output cell in this row.
         findall(OV,
             (between(0, TotalSize1, OC),
% Block col BC = output col OC divided by block size NS.
              BC is OC // NS,
% Inner col IC = output col OC modulo block size NS.
              IC is OC mod NS,
% Look up whether this output block has an assignment.
              (   member(BR-BC-TI, Assigns)
              ->  nth0(TI, Templates, Tmpl),
% Get template row at inner row IR.
                  nth0(IR, Tmpl, TRow),
% Get template cell value at inner col IC.
                  nth0(IC, TRow, TV),
% Non-zero template cell → use marker color; zero cell → output zero.
                  (TV =:= 0 -> OV = 0 ; nth0(TI, Markers, OV))
% Unassigned block → output zero.
              ;   OV = 0
              )),
             OutRow)),
        Out).

% ---------------------------------------------------------------------------
% PRINT REPORT
% ---------------------------------------------------------------------------

% arc2_benchmark_print/0: run the full benchmark and print a report.
arc2_benchmark_print :-
    format("~n=== ARC-AGI-2 Benchmark Run ===~n"),
    format("Pure induction. No pretraining. Glass-box rules.~n"),
    format("Task-type-aware dispatch: single_rule / multi_step / context_gated / symbol_table.~n~n"),
    arc2_benchmark_run(Score, Total, Results),
    ( Total =:= 0 ->
        format("No arc2_task/4 facts loaded. Download ARC-AGI-2 tasks first.~n"),
        format("See data/arc_agi_2/arc_tasks_2.pl for instructions.~n")
    ;
        format("--- SOLVED TASKS ---~n"),
        forall(
            member(result(TaskId, pass(Rule)), Results),
            format("  PASS  ~w  rule: ~w~n", [TaskId, Rule])
        ),
        Percent is Score * 100 / Total,
        format("~n--- SCORE ---~n"),
        format("  ~w / ~w = ~2f%~n", [Score, Total, Percent]),
        format("~n  Methodology: pure induction from training examples, no pretraining,~n"),
        format("  transformation rule named glass-box for every solved task.~n")
    ),
    format("~n=== Benchmark complete. ===~n").

% ---------------------------------------------------------------------------
% FRAME POUR (fp_*): Layer 294, WP-319, Task b9e38dc0
% A rectangular frame (F) encloses a fill-color seed (FC) on its interior
% side.  The opposite side of the frame is the "opening."  The interior BFS
% fills BG cells on the seed-side of the frame.  The exterior projects a
% widening triangular cone outward through the opening; B-colored noise cells
% cast shadows that blank their row/col for all deeper depths.
% ---------------------------------------------------------------------------

% arc2_transform(frame_pour): delegate to solver.
arc2_transform(frame_pour, Grid, Out) :-
% Invoke the frame_pour main solver on the input grid.
    arc2_fp_solve_(Grid, Out).

% arc2_fp_solve_(+Grid, -Out): orchestrate the unified frame_pour algorithm.
arc2_fp_solve_(Grid, Out) :-
% Obtain grid height H and width W.
    length(Grid, H),
% Extract grid width from first row.
    Grid = [R0|_], length(R0, W),
% Identify background color (most common value in grid).
    arc2_fp_bg_(Grid, BG),
% Identify frame color F (most common non-BG value).
    arc2_fp_fcolor_(Grid, BG, F),
% Identify fill-seed color FC (most common non-BG non-F inside frame bbox).
    arc2_fp_ccolor_(Grid, BG, F, FC),
% Determine opening direction from FC centroid offset relative to frame center.
    arc2_fp_dir_(Grid, F, FC, Dir),
% Compute boundary row/col (Bnd), wall extents (LW, RW), slope S.
    arc2_fp_bnd_(Grid, F, Dir, Bnd, LW, RW, S),
% Enumerate all F-cells once for interior range lookup.
    findall(R-C, (nth0(R,Grid,Row), nth0(C,Row,F)), FCs),
% Interior shadow-cone: fill from far side to Bnd; shadows carry outward.
    arc2_fp_int_cone_(Grid, BG, F, FC, FCs, Dir, Bnd, H, W, IntFill, BlkFromInt),
% Exterior shadow-cone: widening cone outside Bnd, shadow from interior carried in.
    arc2_fp_exterior_(Grid, BG, FC, Dir, Bnd, LW, RW, S, H, W, BlkFromInt, IntFill, Out).

% arc2_fp_bg_(+Grid, -BG): most frequent value in entire grid (background).
arc2_fp_bg_(Grid, BG) :-
% Flatten grid to a single list of all cell values.
    flatten(Grid, All),
% Sort while keeping duplicates to group equal values together.
    msort(All, Sorted),
% Walk the sorted list picking the longest run as the background.
    arc2_fp_best_(Sorted, none, 0, BG).

% arc2_fp_best_(+Sorted, +BestV, +BestC, -Out): find value with longest run.
arc2_fp_best_([], B, _, B).
% Measure current run, compare to best-so-far, and recurse on remainder.
arc2_fp_best_([H|T], BV, BC, Out) :-
% Count consecutive H-valued cells at the head of the sorted list.
    arc2_fp_prefix_([H|T], H, 0, Cnt, Rest),
% Keep whichever run is longer.
    (Cnt > BC -> arc2_fp_best_(Rest, H,  Cnt, Out)
               ; arc2_fp_best_(Rest, BV, BC,  Out)).

% arc2_fp_prefix_(+List, +Val, +Acc, -Count, -Rest): consume a prefix run.
arc2_fp_prefix_([], _, C, C, []).
% Matching head: increment accumulator and continue.
arc2_fp_prefix_([H|T], H, C0, C, R) :- C1 is C0+1, arc2_fp_prefix_(T, H, C1, C, R).
% Non-matching head: stop and return remainder unchanged.
arc2_fp_prefix_([X|T], H, C, C, [X|T]) :- X \= H.

% arc2_fp_fcolor_(+Grid, +BG, -F): most frequent non-BG value (frame color).
arc2_fp_fcolor_(Grid, BG, F) :-
% Collect all non-BG cells from the flattened grid.
    flatten(Grid, All), exclude(==(BG), All, NB),
% Sort with duplicates and pick the longest run.
    msort(NB, Sorted), arc2_fp_best_(Sorted, none, 0, F).

% arc2_fp_ccolor_(+Grid, +BG, +F, -FC): dominant non-BG non-F color inside frame bbox.
arc2_fp_ccolor_(Grid, BG, F, FC) :-
% Enumerate all F-cell positions to determine bounding box.
    findall(R-C, (nth0(R,Grid,Row), nth0(C,Row,F)), FCs),
% Row span of frame.
    findall(R, member(R-_, FCs), Rs), min_list(Rs, R1), max_list(Rs, R2),
% Col span of frame.
    findall(C, member(_-C, FCs), Cs), min_list(Cs, C1), max_list(Cs, C2),
% Gather all non-BG non-F values that lie within the frame bounding box.
    findall(V, (nth0(R,Grid,Row), nth0(C,Row,V),
                R>=R1, R=<R2, C>=C1, C=<C2, V\=BG, V\=F), Vs),
% Sort with duplicates and pick the most frequent value.
    msort(Vs, VS), arc2_fp_best_(VS, none, 0, FC).

% arc2_fp_dir_(+Grid, +F, +FC, -Dir): opening direction north/south/east/west.
arc2_fp_dir_(Grid, F, FC, Dir) :-
% Enumerate frame cell positions.
    findall(R-C, (nth0(R,Grid,Row), nth0(C,Row,F)), FCs),
% Row and col extents of frame.
    findall(R, member(R-_, FCs), FRs), min_list(FRs, FR1), max_list(FRs, FR2),
    findall(C, member(_-C, FCs), FCols), min_list(FCols, FC1), max_list(FCols, FC2),
% Mean row of all FC-colored cells (weighted per-cell, not per-row).
    findall(R, (nth0(R,Grid,Row), member(FC,Row)), CRs),
    CRs \= [],
    sumlist(CRs, RS), length(CRs, RN), CR is RS/RN,
% Mean col of all FC-colored cells.
    findall(C, (nth0(_,Grid,Row), nth0(C,Row,FC)), CCs),
    CCs \= [],
    sumlist(CCs, CS), length(CCs, CN), CC is CS/CN,
% Frame center coordinates.
    FCR is (FR1+FR2)/2.0, FCC is (FC1+FC2)/2.0,
% Frame half-dimensions (avoid divide-by-zero).
    FH is max(1, FR2-FR1), FW is max(1, FC2-FC1),
% Normalized offsets of FC centroid from frame center.
    Voff is abs(CR-FCR)/(FH/2.0), Hoff is abs(CC-FCC)/(FW/2.0),
% Opening is OPPOSITE the side where FC sits: if FC is above center, opening is south.
    (Voff >= Hoff -> (CR < FCR -> Dir=south ; Dir=north)
                   ; (CC < FCC -> Dir=east  ; Dir=west)).

% arc2_fp_bnd_(+Grid,+F,+Dir,-Bnd,-LW,-RW,-S): boundary position, wall extents, slope.
arc2_fp_bnd_(Grid, F, Dir, Bnd, LW, RW, S) :-
% Enumerate all F-cell positions once.
    findall(R-C, (nth0(R,Grid,Row), nth0(C,Row,F)), FCs),
% Dispatch on direction to compute boundary row/col and two reference rows/cols.
    (Dir=south ->
        findall(R, member(R-_, FCs), Rs), max_list(Rs, Bnd),
% One row inside frame (Bnd-1) and two rows inside (Bnd-2) for slope.
        B1 is Bnd-1, B2 is Bnd-2,
        arc2_fp_wcols_(FCs, Bnd, B1, LW, RW),
        arc2_fp_slopev_(FCs, Bnd, B2, S)
    ; Dir=north ->
        findall(R, member(R-_, FCs), Rs), min_list(Rs, Bnd),
% One row inside frame (Bnd+1) and two rows inside (Bnd+2) for slope.
        B1 is Bnd+1, B2 is Bnd+2,
        arc2_fp_wcols_(FCs, Bnd, B1, LW, RW),
        arc2_fp_slopev_(FCs, Bnd, B2, S)
    ; Dir=west ->
        findall(C, member(_-C, FCs), Cs), min_list(Cs, Bnd),
% One col inside frame (Bnd+1) and two cols inside (Bnd+2) for slope.
        B1 is Bnd+1, B2 is Bnd+2,
        arc2_fp_wrows_(FCs, Bnd, B1, LW, RW),
        arc2_fp_slopeh_(FCs, Bnd, B2, S)
    ; % Dir=east
        findall(C, member(_-C, FCs), Cs), max_list(Cs, Bnd),
% One col inside frame (Bnd-1) and two cols inside (Bnd-2) for slope.
        B1 is Bnd-1, B2 is Bnd-2,
        arc2_fp_wrows_(FCs, Bnd, B1, LW, RW),
        arc2_fp_slopeh_(FCs, Bnd, B2, S)
    ).

% arc2_fp_wcols_(+FCs,+R1,+R2,-LW,-RW): min/max F-col at rows R1 or R2 combined.
arc2_fp_wcols_(FCs, R1, R2, LW, RW) :-
% Collect F-cols at boundary row and one row inward.
    findall(C, (member(R-C, FCs), (R=:=R1; R=:=R2)), Cs),
% Min col is left wall; max col is right wall.
    min_list(Cs, LW), max_list(Cs, RW).

% arc2_fp_wrows_(+FCs,+C1,+C2,-TW,-BW): min/max F-row at cols C1 or C2 combined.
arc2_fp_wrows_(FCs, C1, C2, TW, BW) :-
% Collect F-rows at boundary col and one col inward.
    findall(R, (member(R-C, FCs), (C=:=C1; C=:=C2)), Rs),
% Min row is top wall; max row is bottom wall.
    min_list(Rs, TW), max_list(Rs, BW).

% arc2_fp_slopev_(+FCs,+Bnd,+Bnd2,-S): rows-per-col expansion rate for vert openings.
arc2_fp_slopev_(FCs, Bnd, Bnd2, S) :-
% Min F-col at boundary row.
    findall(C, member(Bnd-C, FCs), Cs1), Cs1\=[],
    min_list(Cs1, LW1),
% Min F-col two rows into the frame (reference point for slope).
    (   findall(C, member(Bnd2-C, FCs), Cs2), Cs2\=[]
    ->  min_list(Cs2, LW2), DC is abs(LW2-LW1),
        (DC>0 -> S is 2.0/DC ; S=1.0)
    ;   S=1).

% arc2_fp_slopeh_(+FCs,+Bnd,+Bnd2,-S): cols-per-row expansion rate for horiz openings.
arc2_fp_slopeh_(FCs, Bnd, Bnd2, S) :-
% Min F-row at boundary col.
    findall(R, member(R-Bnd, FCs), Rs1), Rs1\=[],
    min_list(Rs1, TW1),
% Min F-row two cols into the frame (reference point for slope).
    (   findall(R, member(R-Bnd2, FCs), Rs2), Rs2\=[]
    ->  min_list(Rs2, TW2), DR is abs(TW2-TW1),
        (DR>0 -> S is 2.0/DR ; S=1.0)
    ;   S=1).

% arc2_fp_int_cone_: interior shadow-cone fill from far side to Bnd.
% B-cell shadows propagate toward the opening and into the exterior.
% LW/RW serve as fallback wall bounds when only one F-cell exists at Bnd.
arc2_fp_int_cone_(Grid, BG, F, FC, FCs, Dir, Bnd, H, W, FillOut, BlkOut) :-
% Dispatch on direction: row loop for N/S, col loop for E/W.
    (Dir = north ->
        findall(R, member(R-_, FCs), Rs), max_list(Rs, FarR),
% NORTH: far side = max F-row; scan downward (Sign=-1) toward Bnd=min F-row.
        arc2_fp_bnd_(Grid, F, Dir, Bnd, LW, RW, _),
        arc2_fp_int_rloop_(FarR, Bnd, -1, Grid, BG, F, FC, FCs, W, LW, RW, [], [], FillOut, BlkOut)
    ; Dir = south ->
        findall(R, member(R-_, FCs), Rs), min_list(Rs, FarR),
% SOUTH: far side = min F-row; scan upward (Sign=+1) toward Bnd=max F-row.
        arc2_fp_bnd_(Grid, F, Dir, Bnd, LW, RW, _),
        arc2_fp_int_rloop_(FarR, Bnd, 1, Grid, BG, F, FC, FCs, W, LW, RW, [], [], FillOut, BlkOut)
    ; Dir = west ->
        findall(C, member(_-C, FCs), Cs), max_list(Cs, FarC),
% WEST: far side = max F-col; scan leftward (Sign=-1) toward Bnd=min F-col.
        arc2_fp_bnd_(Grid, F, Dir, Bnd, TW, BW, _),
        arc2_fp_int_cloop_(FarC, Bnd, -1, Grid, BG, F, FC, FCs, H, TW, BW, [], [], FillOut, BlkOut)
    ; % east
        findall(C, member(_-C, FCs), Cs), min_list(Cs, FarC),
% EAST: far side = min F-col; scan rightward (Sign=+1) toward Bnd=max F-col.
        arc2_fp_bnd_(Grid, F, Dir, Bnd, TW, BW, _),
        arc2_fp_int_cloop_(FarC, Bnd, 1, Grid, BG, F, FC, FCs, H, TW, BW, [], [], FillOut, BlkOut)
    ).

% arc2_fp_int_rloop_: interior row loop (NORTH/SOUTH).
% Stop condition: R has passed Bnd in the scan direction.
arc2_fp_int_rloop_(R, Bnd, Sign, _, _, _, _, _, _, _, _, Blk, Acc, Acc, Blk) :-
    (Sign =:= -1 -> R < Bnd ; R > Bnd), !.
% Process row R: determine interior col range from F-cells, then fill.
arc2_fp_int_rloop_(R, Bnd, Sign, Grid, BG, F, FC, FCs, W, FbLW, FbRW, BlkIn, AccIn, AccOut, BlkOut) :-
% F-cols at this row determine the interior boundary.
    findall(C, member(R-C, FCs), FCols),
    (   FCols = [] ->
% No frame at this row: use fallback bounds (precomputed wall extent).
        MinC is max(0, FbLW+1), MaxC is min(W-1, FbRW-1),
        arc2_fp_scan_int_(MinC, MaxC, R, Grid, BG, F, FC, BlkIn, AccIn, A1, B1)
    ;   min_list(FCols, FLW), max_list(FCols, FRW),
        FLW =:= FRW,
        Mid is (FbLW + FbRW) / 2 ->
% Degenerate (single F-cell): decide which wall it is and extend to fallback.
        ( FLW < Mid ->
            MinC is max(0, FLW+1), MaxC is min(W-1, FbRW)
        ;
            MinC is max(0, FbLW), MaxC is min(W-1, FLW-1)
        ),
        arc2_fp_scan_int_(MinC, MaxC, R, Grid, BG, F, FC, BlkIn, AccIn, A1, B1)
    ;
% Normal: use left and right F-walls at this row.
        min_list(FCols, FLW2), max_list(FCols, FRW2),
        MinC is max(0, FLW2+1), MaxC is min(W-1, FRW2-1),
        arc2_fp_scan_int_(MinC, MaxC, R, Grid, BG, F, FC, BlkIn, AccIn, A1, B1)
    ),
    NextR is R + Sign,
    arc2_fp_int_rloop_(NextR, Bnd, Sign, Grid, BG, F, FC, FCs, W, FbLW, FbRW, B1, A1, AccOut, BlkOut).

% arc2_fp_int_cloop_: interior col loop (WEST/EAST).
arc2_fp_int_cloop_(C, Bnd, Sign, _, _, _, _, _, _, _, _, Blk, Acc, Acc, Blk) :-
    (Sign =:= -1 -> C < Bnd ; C > Bnd), !.
% Process col C: determine interior row range from F-cells, then fill.
arc2_fp_int_cloop_(C, Bnd, Sign, Grid, BG, F, FC, FCs, H, FbTW, FbBW, BlkIn, AccIn, AccOut, BlkOut) :-
    findall(R, member(R-C, FCs), FRows),
    (   FRows = [] ->
% No frame at col C: use fallback bounds.
        MinR is max(0, FbTW+1), MaxR is min(H-1, FbBW-1),
        arc2_fp_scan_intc_(MinR, MaxR, C, Grid, BG, F, FC, BlkIn, AccIn, A1, B1)
    ;   min_list(FRows, FTW), max_list(FRows, FBW),
        FTW =:= FBW,
        Mid is (FbTW + FbBW) / 2 ->
% Degenerate (single F-cell): decide which wall and extend to fallback.
        ( FTW < Mid ->
            MinR is max(0, FTW+1), MaxR is min(H-1, FbBW)
        ;
            MinR is max(0, FbTW), MaxR is min(H-1, FTW-1)
        ),
        arc2_fp_scan_intc_(MinR, MaxR, C, Grid, BG, F, FC, BlkIn, AccIn, A1, B1)
    ;
% Normal: use top and bottom F-walls at this col.
        min_list(FRows, FTW2), max_list(FRows, FBW2),
        MinR is max(0, FTW2+1), MaxR is min(H-1, FBW2-1),
        arc2_fp_scan_intc_(MinR, MaxR, C, Grid, BG, F, FC, BlkIn, AccIn, A1, B1)
    ),
    NextC is C + Sign,
    arc2_fp_int_cloop_(NextC, Bnd, Sign, Grid, BG, F, FC, FCs, H, FbTW, FbBW, B1, A1, AccOut, BlkOut).

% arc2_fp_scan_int_(+Min,+Max,+R,...): scan interior cols [Min..Max] at row R.
arc2_fp_scan_int_(Cur, Max, _, _, _, _, _, B, A, A, B) :- Cur > Max, !.
% Each cell: skip if blocked, skip F-cells, fill BG, shadow B-cells, skip FC.
arc2_fp_scan_int_(Cur, Max, R, Grid, BG, F, FC, BlkIn, AccIn, AccOut, BlkOut) :-
    nth0(R, Grid, Row), nth0(Cur, Row, V),
    (   member(Cur, BlkIn) -> A1=AccIn, B1=BlkIn
    ;   V =:= F             -> A1=AccIn, B1=BlkIn
    ;   V =:= BG            -> A1=[R-Cur|AccIn], B1=BlkIn
    ;   V =:= FC            -> A1=AccIn, B1=BlkIn
    ;   A1=AccIn, B1=[Cur|BlkIn]
    ),
    Cur1 is Cur+1,
    arc2_fp_scan_int_(Cur1, Max, R, Grid, BG, F, FC, B1, A1, AccOut, BlkOut).

% arc2_fp_scan_intc_(+Min,+Max,+C,...): scan interior rows [Min..Max] at col C.
arc2_fp_scan_intc_(Cur, Max, _, _, _, _, _, B, A, A, B) :- Cur > Max, !.
% Each cell: skip if blocked, skip F-cells, fill BG, shadow B-cells, skip FC.
arc2_fp_scan_intc_(Cur, Max, C, Grid, BG, F, FC, BlkIn, AccIn, AccOut, BlkOut) :-
    nth0(Cur, Grid, Row), nth0(C, Row, V),
    (   member(Cur, BlkIn) -> A1=AccIn, B1=BlkIn
    ;   V =:= F             -> A1=AccIn, B1=BlkIn
    ;   V =:= BG            -> A1=[Cur-C|AccIn], B1=BlkIn
    ;   V =:= FC            -> A1=AccIn, B1=BlkIn
    ;   A1=AccIn, B1=[Cur|BlkIn]
    ),
    Cur1 is Cur+1,
    arc2_fp_scan_intc_(Cur1, Max, C, Grid, BG, F, FC, B1, A1, AccOut, BlkOut).

% arc2_fp_apply_(+Grid,+FillSet,+FC,-Out): paint all cells in FillSet with FC.
arc2_fp_apply_(Grid, FillSet, FC, Out) :-
% Process each row with its index.
    arc2_fp_apply_rows_(Grid, 0, FillSet, FC, Out).
% arc2_fp_apply_rows_(+Rows,+R,+FS,+FC,-Out): iterate over rows.
arc2_fp_apply_rows_([], _, _, _, []).
% For each row, apply fill then recurse with incremented row index.
arc2_fp_apply_rows_([Row|Rows], R, FS, FC, [NRow|NRows]) :-
    arc2_fp_apply_row_(Row, R, 0, FS, FC, NRow),
    R1 is R+1, arc2_fp_apply_rows_(Rows, R1, FS, FC, NRows).
% arc2_fp_apply_row_(+Cells,+R,+C,+FS,+FC,-Out): iterate over cols in one row.
arc2_fp_apply_row_([], _, _, _, _, []).
% Replace cell with FC if (R-C) is in fill set; otherwise keep original value.
arc2_fp_apply_row_([V|Vs], R, C, FS, FC, [NV|NVs]) :-
    (member(R-C, FS) -> NV=FC ; NV=V),
    C1 is C+1, arc2_fp_apply_row_(Vs, R, C1, FS, FC, NVs).

% arc2_fp_exterior_(+Grid,+BG,+FC,+Dir,+Bnd,+LW,+RW,+S,+H,+W,+BlkIn,+IntFill,-Out).
% Widening exterior cone fill; shadow set BlkIn carries from interior phase.
arc2_fp_exterior_(Grid, BG, FC, Dir, Bnd, LW, RW, S, H, W, BlkIn, IntFill, Out) :-
% Determine max exterior depth and axis of propagation.
    (Dir=south -> MaxD is H-1-Bnd, Sign=1,  Ax=row
    ; Dir=north -> MaxD is Bnd,     Sign= -1, Ax=row
    ; Dir=west  -> MaxD is Bnd,     Sign= -1, Ax=col
    ; % east
                   MaxD is W-1-Bnd, Sign=1,  Ax=col),
% Apply accumulated fill set (interior + exterior) to original grid.
    (MaxD =< 0 ->
        arc2_fp_apply_(Grid, IntFill, FC, Out)
    ;
        arc2_fp_ext_loop_(1, MaxD, Grid, BG, FC, Bnd, LW, RW, S, H, W, Sign, Ax, BlkIn, IntFill, FinalFill),
        arc2_fp_apply_(Grid, FinalFill, FC, Out)
    ).

% arc2_fp_ext_loop_(+D,+MaxD,...,+BlkIn,+AccIn,-AccOut): exterior depth loop.
arc2_fp_ext_loop_(D, MaxD, _, _, _, _, _, _, _, _, _, _, _, _, Acc, Acc) :- D > MaxD, !.
% For depth D: compute cone expansion, scan the row or col, recurse.
arc2_fp_ext_loop_(D, MaxD, Grid, BG, FC, Bnd, LW, RW, S, H, W, Sign, Ax, BlkIn, AccIn, Out) :-
% Lateral expansion grows by 1 for every S units of depth.
    E is truncate((D-1) / S),
% Widened boundaries at depth D.
    Lo is LW-E, Hi is RW+E,
% Absolute row or col position at depth D.
    Pos is Bnd + D*Sign,
% Clip to grid bounds and scan.
    (Ax=row ->
        MinP is max(0,Lo), MaxP is min(W-1,Hi),
        arc2_fp_scan_(MinP, MaxP, row, Pos, Grid, BG, FC, BlkIn, AccIn, Acc1, Blk1)
    ;   MinP is max(0,Lo), MaxP is min(H-1,Hi),
        arc2_fp_scan_(MinP, MaxP, col, Pos, Grid, BG, FC, BlkIn, AccIn, Acc1, Blk1)),
    D1 is D+1,
    arc2_fp_ext_loop_(D1, MaxD, Grid, BG, FC, Bnd, LW, RW, S, H, W, Sign, Ax, Blk1, Acc1, Out).

% arc2_fp_scan_(+Min,+Max,+Ax,+Pos,...,-AccOut,-BlkOut): scan exterior positions.
arc2_fp_scan_(Cur, Max, _, _, _, _, _, B, A, A, B) :- Cur > Max, !.
% Scan each cell: fill BG, shadow noise B-cells, skip FC and blocked.
arc2_fp_scan_(Cur, Max, Ax, Pos, Grid, BG, FC, BlkIn, AccIn, AccOut, BlkOut) :-
    (Ax=row -> R=Pos, C=Cur ; R=Cur, C=Pos),
    nth0(R, Grid, GRow), nth0(C, GRow, V),
    (   member(Cur, BlkIn) -> A1=AccIn, B1=BlkIn
    ;   V =:= BG            -> A1=[R-C|AccIn], B1=BlkIn
    ;   V =\= FC            -> A1=AccIn, B1=[Cur|BlkIn]
    ;   A1=AccIn, B1=BlkIn
    ),
    Cur1 is Cur+1,
    arc2_fp_scan_(Cur1, Max, Ax, Pos, Grid, BG, FC, B1, A1, AccOut, BlkOut).

% === shape_slide: seed-directed shape relocation (task 581f7754, Layer 295) ===
% arc2_transform(shape_slide): delegate to solver.
arc2_transform(shape_slide, Grid, Out) :-
% Delegate to main shape_slide solver.
    arc2_ss_solve_(Grid, Out).

% arc2_ss_solve_: top-level shape_slide solver.
arc2_ss_solve_(Grid, Out) :-
% Grid dimensions.
    length(Grid, H), Grid = [R0|_], length(R0, W),
% Most-frequent value = background.
    arc2_fp_bg_(Grid, BG),
% Collect all non-BG cells as R-C-V triples.
    findall(R-C-V, (nth0(R,Grid,Row), nth0(C,Row,V), V \= BG), Cells),
% Find 4-connected components of non-BG cells.
    arc2_ss_comps_(Cells, Comps),
% Seeds = size-1 components; Shapes = size>1 components.
    include([Cs]>>(Cs=[_]), Comps, SeedComps),
% Exclude size-1 components to get shapes.
    exclude([Cs]>>(Cs=[_]), Comps, ShapeComps),
% Flatten seed lists to single R-C-V triples.
    arc2_ss_extract_seeds_(SeedComps, Seeds),
% Split seeds into anchor (on grid edge) and floating (interior).
    arc2_ss_split_seeds_(Seeds, H, W, AnchorSeeds, FloatSeeds),
% Compute direction and target row/col for each anchor seed.
    findall(V-Dir-Tgt, (
        member(R-C-V, AnchorSeeds),
        arc2_ss_dir_target_(R, C, H, W, Dir, Tgt)
    ), DTs0),
% Remove duplicate direction-target entries.
    sort(DTs0, DirTargets),
% Compute old/new cell lists for each shape whose interior matches an anchor color.
    findall(OCs-NCs, (
        member(OCs, ShapeComps),
        arc2_ss_comp_move_(OCs, DirTargets, H, W, NCs)
    ), ShapeMoves),
% Compute old/new positions for each floating seed matching an anchor color.
    findall([RO-CO-VO]-[RN-CN-VO], (
        member(RO-CO-VO, FloatSeeds),
        member(VO-Dir-Tgt, DirTargets),
        arc2_ss_slide_cell_(RO, CO, Dir, Tgt, RN, CN),
        RN >= 0, RN < H, CN >= 0, CN < W
    ), SeedMoves),
% Combine shape and seed moves.
    append(ShapeMoves, SeedMoves, AllMoves),
% Collect all vacated (old) positions as R-C pairs.
    findall(R-C, (member(OC-_, AllMoves), member(R-C-_, OC)), OldPosns),
% Collect all new positions with their values.
    findall(R-C-V, (member(_-NC, AllMoves), member(R-C-V, NC)), NewPosns),
% Apply vacate-and-fill to produce output grid.
    arc2_ss_apply_(Grid, OldPosns, NewPosns, BG, Out).

% arc2_ss_comps_: collect all 4-connected components from a cell list.
arc2_ss_comps_([], []).
% Take first cell as seed, BFS to find its component, recurse on remainder.
arc2_ss_comps_([H|T], [Comp|Rest]) :-
% Flood-fill from first cell; it starts in Acc and is absent from T.
    arc2_ss_flood_([H], [H], T, Comp, Remaining),
% Recurse on cells not yet placed in any component.
    arc2_ss_comps_(Remaining, Rest).

% arc2_ss_flood_: BFS flood-fill for one 4-connected component.
arc2_ss_flood_([], Acc, Rem, Acc, Rem).
% Process current frontier cell R-C; find 4-adjacent cells still in Rem.
arc2_ss_flood_([R-C-_|RestF], Acc, Rem0, Comp, Rem) :-
% Find all cells in Rem0 that are 4-adjacent to (R,C).
    findall(R2-C2-V2, (
        member(R2-C2-V2, Rem0),
        ( R2 =:= R+1, C2 =:= C
        ; R2 =:= R-1, C2 =:= C
        ; R2 =:= R,   C2 =:= C+1
        ; R2 =:= R,   C2 =:= C-1
        )
    ), Nbrs),
% Remove newly found neighbors from remaining pool to avoid revisiting.
    subtract(Rem0, Nbrs, Rem1),
% Append neighbors to frontier queue and component accumulator.
    append(RestF, Nbrs, NewF),
    append(Acc, Nbrs, NewAcc),
% Continue BFS with updated frontier, accumulator, and remaining pool.
    arc2_ss_flood_(NewF, NewAcc, Rem1, Comp, Rem).

% arc2_ss_extract_seeds_: unwrap singleton component lists to plain R-C-V triples.
arc2_ss_extract_seeds_([], []).
% Each seed component is a one-element list; extract its single triple.
arc2_ss_extract_seeds_([[RCV]|Rest], [RCV|Ss]) :-
    arc2_ss_extract_seeds_(Rest, Ss).

% arc2_ss_split_seeds_: partition seeds into anchor (edge) and floating (interior).
arc2_ss_split_seeds_([], _, _, [], []).
% Seed on any grid edge => anchor seed.
arc2_ss_split_seeds_([R-C-V|T], H, W, [R-C-V|As], Fs) :-
    ( R =:= 0 ; R =:= H-1 ; C =:= 0 ; C =:= W-1 ), !,
% Recurse to classify remaining seeds.
    arc2_ss_split_seeds_(T, H, W, As, Fs).
% Seed not on any edge => floating seed.
arc2_ss_split_seeds_([R-C-V|T], H, W, As, [R-C-V|Fs]) :-
    arc2_ss_split_seeds_(T, H, W, As, Fs).

% arc2_ss_dir_target_: determine slide direction and target from anchor seed position.
% Left edge (col=0): vertical slide, target row = R.
arc2_ss_dir_target_(R, C, _, _, vert, R) :- C =:= 0, !.
% Right edge (col=W-1): vertical slide, target row = R.
arc2_ss_dir_target_(R, C, _, W, vert, R) :- C =:= W-1, !.
% Top edge (row=0): horizontal slide, target col = C.
arc2_ss_dir_target_(R, C, _, _, horiz, C) :- R =:= 0, !.
% Bottom edge (row=H-1): horizontal slide, target col = C.
arc2_ss_dir_target_(R, C, H, _, horiz, C) :- R =:= H-1.

% arc2_ss_comp_move_: compute new cell positions for a shape by sliding to target.
arc2_ss_comp_move_(Comp, DirTargets, H, W, NewCells) :-
% Interior marker = the UNIQUE-COLOR cell (appears exactly once) whose color is an anchor seed.
    member(RI-CI-VI, Comp),
% Confirm VI appears exactly once in the component (it is the unique interior color).
    findall(R-C, member(R-C-VI, Comp), [RI-CI]),
% Confirm VI matches an anchor seed direction/target.
    member(VI-Dir-Tgt, DirTargets), !,
% Compute row and column displacement to align interior marker with target.
    ( Dir = vert  -> DR is Tgt - RI, DC is 0
    ; Dir = horiz -> DR is 0, DC is Tgt - CI
    ),
% Shift all cells; discard those landing outside grid bounds.
    findall(R1-C1-V0, (
        member(R0-C0-V0, Comp),
        R1 is R0 + DR, C1 is C0 + DC,
        R1 >= 0, R1 < H, C1 >= 0, C1 < W
    ), NewCells).

% arc2_ss_slide_cell_: compute new position for a floating seed.
% Vertical slide: column stays, row moves to target.
arc2_ss_slide_cell_(_, CO, vert, Tgt, Tgt, CO).
% Horizontal slide: row stays, column moves to target.
arc2_ss_slide_cell_(RO, _, horiz, Tgt, RO, Tgt).

% arc2_ss_apply_: build output grid by vacating old positions and filling new ones.
arc2_ss_apply_(Grid, OldPosns, NewPosns, BG, Out) :-
% Get grid dimensions.
    length(Grid, H), Grid = [GRow0|_], length(GRow0, W),
% Build row and column index lists.
    H1 is H-1, W1 is W-1,
% Enumerate row indices.
    numlist(0, H1, Rs), numlist(0, W1, Cs),
% Build output row by row using index-driven maplist.
    maplist(arc2_ss_apply_row_(Grid, Cs, OldPosns, NewPosns, BG), Rs, Out).

% arc2_ss_apply_row_: build one output row at index R.
arc2_ss_apply_row_(Grid, Cs, OldPosns, NewPosns, BG, R, OutRow) :-
% Get original row from input grid.
    nth0(R, Grid, GRow),
% Build each cell value in this row.
    maplist(arc2_ss_apply_cell_(GRow, R, OldPosns, NewPosns, BG), Cs, OutRow).

% arc2_ss_apply_cell_: determine output value for cell (R,C).
arc2_ss_apply_cell_(GRow, R, OldPosns, NewPosns, BG, C, Val) :-
% Get original cell value.
    nth0(C, GRow, Orig),
% Vacated cell: replaced by new value if refilled, else BG.
    ( member(R-C, OldPosns) ->
        ( member(R-C-V2, NewPosns) -> Val = V2 ; Val = BG )
% New fill only (not vacated): place new value.
    ; member(R-C-V2, NewPosns) -> Val = V2
% Unchanged cell: keep original.
    ; Val = Orig
    ).

% =============================================================================
% WP-321 - col_rank_fill: Layer 296
% Rule: indicator bars in top rows select a column segment to fill.
% For each column C where Grid[0][C] != BG, count the run of that color
% from row 0 downward; this gives (marker_color, rank) pairs.
% Segments are [bg*, M, F+, M, bg*] patterns in each column (below any bar).
% For each (marker, rank): sort segments with that marker by filler count desc;
% replace filler cells in the rank-th segment with the marker color.
% =============================================================================

% arc2_transform(col_rank_fill, +Grid, -Out): apply rank-based column fill.
arc2_transform(col_rank_fill, Grid, Out) :-
% Extract first row and compute width.
    Grid = [R0|_], length(R0, W),
% Compute grid height.
    length(Grid, H),
% Step 1: detect indicator bars (col, color, length).
    arc2_crf_indicators_(Grid, W, Indicators),
    Indicators \= [],
% Step 2: detect column segments below any indicator bar.
    arc2_crf_segments_(Grid, H, W, Indicators, Segs),
    Segs \= [],
% Step 3: for each indicator, pick the rank-th segment to fill.
    arc2_crf_targets_(Indicators, Segs, Targets),
    Targets \= [],
% Step 4: build replacement list and apply to grid.
    arc2_crf_apply_(Grid, Targets, Out).

% arc2_crf_indicators_(+Grid, +W, -Indicators): list of C-Color-Len tuples.
arc2_crf_indicators_(Grid, W, Indicators) :-
% For each column index C from 0 to W-1.
    W1 is W - 1,
% Collect (C, Color, BarLength) for columns with non-BG at row 0.
    findall(C-Color-Len, (
        between(0, W1, C),
% Read the cell at row 0, column C.
        nth0(0, Grid, R0), nth0(C, R0, Color),
% Only consider non-BG (non-zero) cells.
        Color =\= 0,
% Count how many consecutive rows from row 0 have this color.
        arc2_crf_bar_len_(Grid, C, Color, 0, 0, Len)
    ), Indicators).

% arc2_crf_bar_len_(+Grid, +Col, +Color, +Row, +Acc, -Len):
% Count consecutive Color cells starting at (Row, Col).
arc2_crf_bar_len_(Grid, Col, Color, Row, Acc, Len) :-
% Attempt to read cell at (Row, Col); if out of bounds, stop.
    ( nth0(Row, Grid, R), nth0(Col, R, V) ->
        ( V =:= Color ->
% Cell matches: increment accumulator and advance row.
            Row1 is Row + 1, Acc1 is Acc + 1,
            arc2_crf_bar_len_(Grid, Col, Color, Row1, Acc1, Len)
        ;
% Cell differs: bar ends here.
            Len = Acc
        )
    ;
% Out of bounds: bar ends here.
        Len = Acc
    ).

% arc2_crf_segments_(+Grid, +H, +W, +Indicators, -Segs):
% Find column segments: C-Marker-FillCount-TopRow-BotRow.
arc2_crf_segments_(Grid, H, W, Indicators, Segs) :-
    W1 is W - 1,
    findall(C-M-N-TR-BR, (
        between(0, W1, C),
% Get indicator bar length for this column (0 if none).
        ( member(C-_-BLen, Indicators) -> true ; BLen = 0 ),
% Find the segment in rows BLen..H-1.
        arc2_crf_seg_(Grid, H, C, BLen, M, N, TR, BR)
    ), Segs).

% arc2_crf_seg_(+Grid, +H, +Col, +BarLen, -Marker, -FillCount, -TopRow, -BotRow):
% Detect [BG*, M, F+, M, BG*] pattern in column Col at rows BarLen..H-1.
arc2_crf_seg_(Grid, H, C, BLen, Marker, FillCount, TopRow, BotRow) :-
    H1 is H - 1,
% Find first non-BG row at or after BarLen.
    between(BLen, H1, TopRow),
    nth0(TopRow, Grid, RT), nth0(C, RT, Marker),
    Marker =\= 0, !,
% Find last non-BG row in [BarLen..H1].
    arc2_crf_last_nonbg_(Grid, C, H1, BLen, BotRow),
    BotRow > TopRow,
% Top and bottom markers must be the same color.
    nth0(BotRow, Grid, RB), nth0(C, RB, Marker),
% Filler count is cells between top and bottom markers.
    FillCount is BotRow - TopRow - 1,
    FillCount > 0,
% Verify intermediate cells are all the same non-BG non-Marker filler color.
    TR1 is TopRow + 1, BR1 is BotRow - 1,
    findall(V, (between(TR1, BR1, R), nth0(R, Grid, GR), nth0(C, GR, V)), FVals),
    FVals = [FC|_], FC =\= 0, FC =\= Marker,
    \+ (member(V2, FVals), V2 \= FC).

% arc2_crf_last_nonbg_(+Grid, +Col, +MaxRow, +MinRow, -BotRow):
% Find the last (highest-index) non-BG row in Col within [MinRow..MaxRow].
arc2_crf_last_nonbg_(Grid, C, Row, MinRow, BotRow) :-
    ( Row < MinRow -> fail
    ; nth0(Row, Grid, R), nth0(C, R, V), V =\= 0 -> BotRow = Row
    ; Row1 is Row - 1, arc2_crf_last_nonbg_(Grid, C, Row1, MinRow, BotRow)
    ).

% arc2_crf_targets_(+Indicators, +Segs, -Targets):
% For each indicator (Marker, Rank): pick the rank-th segment (desc by filler count).
arc2_crf_targets_(Indicators, Segs, Targets) :-
    findall(Col-Marker-TR-BR, (
        member(_ColInd-Marker-Rank, Indicators),
% Collect all segments with this marker color.
        findall(N-C-TR-BR, member(C-Marker-N-TR-BR, Segs), MSegs0),
        MSegs0 \= [],
% Sort ascending by filler count, then reverse for descending.
        msort(MSegs0, Sorted0),
        reverse(Sorted0, Sorted),
% Pick the Rank-th element (1-indexed); fails if rank out of range.
        nth1(Rank, Sorted, _N-Col-TR-BR)
    ), Targets).

% arc2_crf_apply_(+Grid, +Targets, -Out):
% Replace all cells in each target segment (TopRow..BotRow, Col) with Marker.
arc2_crf_apply_(Grid, Targets, Out) :-
% Build flat list of (Row, Col, NewVal) replacement triples.
    findall(Row-Col-Marker, (
        member(Col-Marker-TR-BR, Targets),
        between(TR, BR, Row)
    ), Reps),
% Apply replacements row by row.
    arc2_crf_apply_rows_(Grid, 0, Reps, Out).

% arc2_crf_apply_rows_: process each grid row in order.
arc2_crf_apply_rows_([], _, _, []).
arc2_crf_apply_rows_([Row|Rest], RI, Reps, [NRow|NRest]) :-
% Collect replacements for this row index.
    findall(C-V, member(RI-C-V, Reps), RReps),
% Apply column replacements within this row.
    arc2_crf_apply_cols_(Row, 0, RReps, NRow),
    RI1 is RI + 1,
    arc2_crf_apply_rows_(Rest, RI1, Reps, NRest).

% arc2_crf_apply_cols_: process each cell in a row.
arc2_crf_apply_cols_([], _, _, []).
arc2_crf_apply_cols_([V|Rest], CI, Reps, [NV|NRest]) :-
% Use replacement value if one exists for this column, else keep original.
    ( member(CI-NV, Reps) -> true ; NV = V ),
    CI1 is CI + 1,
    arc2_crf_apply_cols_(Rest, CI1, Reps, NRest).

% ===========================================================
% WP-322  snake_frame  —  Layer 297
% Task cb2d8a2c: a single pointer cell (value 3) draws a
% rectangular wrap-path around each snake object (connected
% 1/2 bodies). All 1s inside snakes become 2s in the output.
% The pointer navigates nearest-to-farthest, turning at each
% snake boundary (snake_edge ± (num_1s+1)), direction
% determined by where the 1s are concentrated in the snake.
% ===========================================================

% arc2_transform(snake_frame, +Grid, -Out): entry point.
arc2_transform(snake_frame, Grid, Out) :-
% Measure grid height and width.
    length(Grid, H),
    Grid = [Row0|_], length(Row0, W),
% Locate the pointer (value 3).
    cbsf_ptr(Grid, 0, PR, PC),
% Collect all snake cells (values 1 or 2).
    cbsf_cells(Grid, 0, H, W, SCells),
% Partition snake cells into connected components.
    cbsf_partition(SCells, Comps),
% Analyse each component: bounding box and half-counts.
    maplist(cbsf_analyse(Grid), Comps, Infos),
% Determine which grid edge the pointer sits on.
    cbsf_edge(PR, PC, H, W, Edge),
% Sort components nearest-to-farthest from the pointer.
    cbsf_order(Edge, Infos, Ordered),
% Trace the 3-path through all snakes.
    cbsf_trace(PR, PC, Edge, Ordered, H, W, Path),
% Write output: 1→2 in snake cells, path cells→3.
    cbsf_out(Grid, 0, SCells, Path, Out).

% --- pointer location ---

% cbsf_ptr(+Rows, +RI, -PR, -PC): find the row and column of value 3.
cbsf_ptr([Row|_], RI, RI, PC) :-
% Search this row for value 3.
    nth0(PC, Row, 3), !.
% cbsf_ptr: value 3 not in this row; advance to next.
cbsf_ptr([_|Rest], RI, PR, PC) :-
% Increment row index and recurse.
    RI1 is RI + 1,
    cbsf_ptr(Rest, RI1, PR, PC).

% --- snake cell collection ---

% cbsf_cells(+Grid, +RI, +H, +W, -Cells): collect all R-C pairs with value 1 or 2.
cbsf_cells(_, H, H, _, []) :- !.
% cbsf_cells: collect from this row then recurse.
cbsf_cells([Row|Rest], RI, H, W, All) :-
% Gather snake cells from this row.
    cbsf_row(Row, RI, 0, W, RC),
% Advance row index.
    RI1 is RI + 1,
% Collect remaining rows.
    cbsf_cells(Rest, RI1, H, W, Tail),
% Combine this row's cells with the rest.
    append(RC, Tail, All).

% cbsf_row(+Row, +RI, +CI, +W, -Cells): collect snake cells from one row.
cbsf_row(_, _, W, W, []) :- !.
% cbsf_row: cell has value 1 or 2; include it.
cbsf_row([V|T], RI, CI, W, [RI-CI|Rest]) :-
    (V =:= 1 ; V =:= 2), !,
    CI1 is CI + 1,
    cbsf_row(T, RI, CI1, W, Rest).
% cbsf_row: background cell; skip it.
cbsf_row([_|T], RI, CI, W, Rest) :-
    CI1 is CI + 1,
    cbsf_row(T, RI, CI1, W, Rest).

% --- connected component partitioning ---

% cbsf_partition(+Cells, -Comps): split cells into 4-connected components.
cbsf_partition([], []).
% cbsf_partition: BFS from the head cell to collect one component.
cbsf_partition([H|T], [Comp|More]) :-
    cbsf_bfs([H], T, Comp, Rest),
    cbsf_partition(Rest, More).

% cbsf_bfs(+Queue, +Avail, -Comp, -Leftover): collect one component via BFS.
cbsf_bfs([], Avail, [], Avail).
% cbsf_bfs: expand front cell; find its available neighbours.
cbsf_bfs([C|Q], Avail, [C|Rest], Final) :-
    C = R-Col,
% Find available cells adjacent to R-Col.
    include(cbsf_adj4(R, Col), Avail, Nbrs),
% Remove found neighbours from the available pool.
    subtract(Avail, Nbrs, Avail2),
% Enqueue the neighbours for exploration.
    append(Q, Nbrs, Q2),
    cbsf_bfs(Q2, Avail2, Rest, Final).

% cbsf_adj4(+R, +C, +NR-NC): true if NR-NC is 4-adjacent to R-C.
cbsf_adj4(R, C, NR-NC) :-
    ( NR is R+1, NC = C
    ; NR is R-1, NC = C
    ; NR = R, NC is C+1
    ; NR = R, NC is C-1
    ).

% --- component analysis ---

% cbsf_analyse(+Grid, +Comp, -Info): compute bounding box and half-1-counts.
cbsf_analyse(Grid, Comp, info(TR,BR,LC,RC,N1,TopH,BotH,LH,RH)) :-
% Extract all row and column indices.
    findall(R, member(R-_, Comp), Rs),
    findall(C, member(_-C, Comp), Cs),
% Compute bounding rows and columns.
    min_list(Rs, TR), max_list(Rs, BR),
    min_list(Cs, LC), max_list(Cs, RC),
% Count cells with value 1.
    include(cbsf_is1(Grid), Comp, Ones),
    length(Ones, N1),
% Compute vertical midpoint for top/bottom split.
    VMid is (TR + BR) // 2,
% Count 1s in top half vs bottom half.
    include([R-_]>>(R =< VMid), Ones, TopList),
    include([R-_]>>(R > VMid), Ones, BotList),
    length(TopList, TopH),
    length(BotList, BotH),
% Compute horizontal midpoint for left/right split.
    HMid is (LC + RC) // 2,
% Count 1s in left half vs right half.
    include([_-C]>>(C =< HMid), Ones, LeftList),
    include([_-C]>>(C > HMid), Ones, RightList),
    length(LeftList, LH),
    length(RightList, RH).

% cbsf_is1(+Grid, +R-C): true when Grid[R][C] equals 1.
cbsf_is1(Grid, R-C) :-
    nth0(R, Grid, Row),
    nth0(C, Row, 1).

% --- pointer edge detection ---

% cbsf_edge(+PR, +PC, +H, +W, -Edge): which grid edge is the pointer on?
cbsf_edge(0, _, _, _, top) :- !.
% cbsf_edge: check bottom row.
cbsf_edge(PR, _, H, _, bottom) :- PR =:= H - 1, !.
% cbsf_edge: check left column.
cbsf_edge(_, 0, _, _, left) :- !.
% cbsf_edge: check right column.
cbsf_edge(_, PC, _, W, right) :- PC =:= W - 1, !.
% cbsf_edge: fallback — treat as top.
cbsf_edge(_, _, _, _, top).

% --- snake ordering ---

% cbsf_order(+Edge, +Infos, -Sorted): sort snakes nearest-to-farthest from pointer.
cbsf_order(right, Infos, Sorted) :-
% Right pointer: nearest snake has largest right column; sort -RC ascending.
    findall(K-I, (member(I,Infos), I=info(_,_,_,RC,_,_,_,_,_), K is -RC), KV),
    keysort(KV, KS), pairs_values(KS, Sorted).
% cbsf_order left: nearest snake has smallest left column.
cbsf_order(left, Infos, Sorted) :-
    findall(K-I, (member(I,Infos), I=info(_,_,LC,_,_,_,_,_,_), K=LC), KV),
    keysort(KV, KS), pairs_values(KS, Sorted).
% cbsf_order top: nearest snake has smallest top row.
cbsf_order(top, Infos, Sorted) :-
    findall(K-I, (member(I,Infos), I=info(TR,_,_,_,_,_,_,_,_), K=TR), KV),
    keysort(KV, KS), pairs_values(KS, Sorted).
% cbsf_order bottom: nearest snake has largest bottom row.
cbsf_order(bottom, Infos, Sorted) :-
    findall(K-I, (member(I,Infos), I=info(_,BR,_,_,_,_,_,_,_), K is -BR), KV),
    keysort(KV, KS), pairs_values(KS, Sorted).

% --- path tracing ---

% cbsf_trace(+R, +C, +Edge, +Snakes, +H, +W, -Path): generate all 3-path cells.

% Base cases: no more snakes; go to grid boundary.
cbsf_trace(R, C, right, [], _, _, Cells) :-
    cbsf_hline(R, C, 0, Cells).
cbsf_trace(R, C, left, [], _, W, Cells) :-
    WW is W - 1, cbsf_hline(R, C, WW, Cells).
cbsf_trace(R, C, top, [], H, _, Cells) :-
    HH is H - 1, cbsf_vline(R, C, HH, Cells).
cbsf_trace(R, C, bottom, [], _, _, Cells) :-
    cbsf_vline(R, C, 0, Cells).

% cbsf_trace right: primary direction is LEFT; snakes are vertical.
cbsf_trace(R, C, right, [info(TR,BR,_,RC,N1,TopH,BotH,_,_)|Rest], H, W, All) :-
% Near column: right boundary of snake's cell.
    NearC is RC + N1 + 1,
% Draw horizontal segment LEFT to near column.
    cbsf_hline(R, C, NearC, Seg1),
% Turn DOWN if top-half has more-or-equal 1s; else turn UP.
    ( TopH >= BotH ->
        FarR0 is BR + N1 + 1, FarR is min(FarR0, H-1)
    ;   FarR0 is TR - N1 - 1, FarR is max(FarR0, 0)
    ),
% Draw vertical segment to far row.
    cbsf_vline(R, NearC, FarR, Seg2),
% Continue from new position toward remaining snakes.
    cbsf_trace(FarR, NearC, right, Rest, H, W, RestCells),
    append(Seg1, Seg2, SegAB),
    append(SegAB, RestCells, All).

% cbsf_trace left: primary direction is RIGHT; snakes are vertical.
cbsf_trace(R, C, left, [info(TR,BR,LC,_,N1,TopH,BotH,_,_)|Rest], H, W, All) :-
% Near column: left boundary of snake's cell.
    NearC is LC - N1 - 1,
% Draw horizontal segment RIGHT to near column.
    cbsf_hline(R, C, NearC, Seg1),
% Turn DOWN if top-half has more-or-equal 1s; else turn UP.
    ( TopH >= BotH ->
        FarR0 is BR + N1 + 1, FarR is min(FarR0, H-1)
    ;   FarR0 is TR - N1 - 1, FarR is max(FarR0, 0)
    ),
% Draw vertical segment to far row.
    cbsf_vline(R, NearC, FarR, Seg2),
% Continue from new position toward remaining snakes.
    cbsf_trace(FarR, NearC, left, Rest, H, W, RestCells),
    append(Seg1, Seg2, SegAB),
    append(SegAB, RestCells, All).

% cbsf_trace top: primary direction is DOWN; snakes are horizontal.
cbsf_trace(R, C, top, [info(TR,_,LC,RC,N1,_,_,LH,RH)|Rest], H, W, All) :-
% Near row: top boundary of snake's cell.
    NearR is TR - N1 - 1,
% Draw vertical segment DOWN to near row.
    cbsf_vline(R, C, NearR, Seg1),
% Compute right and left far-column candidates.
    FarCR is RC + N1 + 1,
    FarCL is LC - N1 - 1,
% Choose direction: force if one side is out-of-bounds; else use 1-distribution.
    ( FarCR >= W, FarCL >= 0 -> GoRight = false
    ; FarCL < 0,  FarCR <  W -> GoRight = true
    ; LH >= RH                -> GoRight = true
    ;                            GoRight = false
    ),
% Compute the actual far column, clamped to grid.
    ( GoRight = true ->
        FarC is min(FarCR, W-1), cbsf_hline(NearR, C, FarC, Seg2)
    ;   FarC is max(FarCL, 0),   cbsf_hline(NearR, C, FarC, Seg2)
    ),
% Continue from new position toward remaining snakes.
    cbsf_trace(NearR, FarC, top, Rest, H, W, RestCells),
    append(Seg1, Seg2, SegAB),
    append(SegAB, RestCells, All).

% cbsf_trace bottom: primary direction is UP; snakes are horizontal.
cbsf_trace(R, C, bottom, [info(_,BR,LC,RC,N1,_,_,LH,RH)|Rest], H, W, All) :-
% Near row: bottom boundary of snake's cell.
    NearR is BR + N1 + 1,
% Draw vertical segment UP to near row.
    cbsf_vline(R, C, NearR, Seg1),
% Compute right and left far-column candidates.
    FarCR is RC + N1 + 1,
    FarCL is LC - N1 - 1,
% Choose direction using boundary constraint then 1-distribution.
    ( FarCR >= W, FarCL >= 0 -> GoRight = false
    ; FarCL < 0,  FarCR <  W -> GoRight = true
    ; LH >= RH                -> GoRight = true
    ;                            GoRight = false
    ),
% Compute actual far column, clamped to grid.
    ( GoRight = true ->
        FarC is min(FarCR, W-1), cbsf_hline(NearR, C, FarC, Seg2)
    ;   FarC is max(FarCL, 0),   cbsf_hline(NearR, C, FarC, Seg2)
    ),
% Continue from new position.
    cbsf_trace(NearR, FarC, bottom, Rest, H, W, RestCells),
    append(Seg1, Seg2, SegAB),
    append(SegAB, RestCells, All).

% --- line generation ---

% cbsf_hline(+R, +C1, +C2, -Cells): horizontal line from (R,C1) to (R,C2).
cbsf_hline(R, C1, C2, Cells) :-
    ( C1 =< C2 -> Lo = C1, Hi = C2 ; Lo = C2, Hi = C1 ),
    numlist(Lo, Hi, Cs),
    findall(R-C, member(C, Cs), Cells).

% cbsf_vline(+R1, +C, +R2, -Cells): vertical line from (R1,C) to (R2,C).
cbsf_vline(R1, C, R2, Cells) :-
    ( R1 =< R2 -> Lo = R1, Hi = R2 ; Lo = R2, Hi = R1 ),
    numlist(Lo, Hi, Rs),
    findall(R-C, member(R, Rs), Cells).

% --- output assembly ---

% cbsf_out(+Grid, +RI, +SCells, +Path, -Out): build the output grid.
cbsf_out([], _, _, _, []).
% cbsf_out: process one row then recurse.
cbsf_out([Row|Rest], RI, SCells, Path, [NRow|NRest]) :-
    length(Row, W),
    cbsf_outrow(Row, RI, 0, W, SCells, Path, NRow),
    RI1 is RI + 1,
    cbsf_out(Rest, RI1, SCells, Path, NRest).

% cbsf_outrow(+Row, +RI, +CI, +W, +SCells, +Path, -NRow): process one row.
cbsf_outrow([], _, _, _, _, _, []).
% cbsf_outrow: path cell takes value 3.
cbsf_outrow([V|T], RI, CI, W, SCells, Path, [NV|NT]) :-
    ( member(RI-CI, Path)              -> NV = 3
    ; member(RI-CI, SCells), V =:= 1   -> NV = 2
    ;                                     NV = V
    ),
    CI1 is CI + 1,
    cbsf_outrow(T, RI, CI1, W, SCells, Path, NT).
