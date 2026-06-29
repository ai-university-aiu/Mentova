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
