/*  Mentova — sb26 solver demonstration (Phase Solo capability)

    The sb26 game-specific solver encodes the cracked level-1 procedure so the Solo
    player wins sb26 level 1 itself: fill the centre placeholders to match the top
    target sequence, then commit with ACTION5. This proves the parsing (including the
    run-finder that decodes marker/target/palette columns) and the plan it emits.

    Acceptance criteria (each prints PASS or FAIL):
      AC-SB-001: sb26_is_game recognises the id (bare and hash-suffixed) and rejects others.
      AC-SB-002: the run-finder decodes red-marker columns EXACTLY (the off-by-one fix):
                 markers at cols 22-23,28-29,34-35,40-41 -> centres 22,28,34,40.
      AC-SB-003: sb26_fill_actions maps markers+target+palette to the right select/click
                 pairs (select the palette tile of each target colour, click its marker).
      AC-SB-004: on a synthetic level-1 board, sb26_build_plan yields the full winning
                 plan (four select+click pairs then action(5)).
*/

:- use_module('../src/mentova/arc_sb26').
:- use_module(library(lists)).

report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> format("~w: PASS~n", [Id])
    ;  format("~w: FAIL~n", [Id]), nb_setval(sb_fails, 1) ).

% a 64-wide row: colour Fill everywhere except the given (start-end,Colour) spans.
mk_row(Fill, Spans, Row) :-
    numlist(0, 63, Cols),
    findall(V,
        ( member(C, Cols),
          ( member(S-E-Col, Spans), C >= S, C =< E -> V = Col ; V = Fill ) ),
        Row).

run :-
    format("~n=== sb26 solver ===~n~n", []),
    nb_setval(sb_fails, 0),

    report('AC-SB-001',
        ( arc_sb26:sb26_is_game('sb26-7fbdac44'),
          arc_sb26:sb26_is_game(sb26),
          \+ arc_sb26:sb26_is_game('vc33-5430563c') )),

    % A marker row: red(2) pairs at 22-23,28-29,34-35,40-41 -> centres 22,28,34,40.
    report('AC-SB-002',
        ( mk_row(4, [22-23-2, 28-29-2, 34-35-2, 40-41-2], Row),
          arc_sb26:sb26_row_runs(Row, [0,1,3,4,5,6,7,8,9,10,11,12,13,14,15], Runs),
          findall(X, ( member(run(2,C0,C1), Runs), X is (C0+C1)//2 ), Centres),
          Centres == [22,28,34,40] )),

    report('AC-SB-003',
        ( Markers = [mk(22,29), mk(28,29), mk(34,29), mk(40,29)],
          Target = [9, 14, 11, 15],
          Pal = [pt(9,35,57), pt(14,19,57), pt(11,43,57), pt(15,27,57)],
          arc_sb26:sb26_fill_actions(Markers, Target, Pal, Acts),
          Acts == [select(35,57), select(22,29),
                   select(19,57), select(28,29),
                   select(43,57), select(34,29),
                   select(27,57), select(40,29)] )),

    report('AC-SB-004',
        ( % Build a minimal level-1 board: target borders row 1, palette row 57,
          % red markers row 29.
          mk_row(5, [], GreyRow),
          mk_row(4, [8-13-9, 15-20-14, 22-27-11, 29-34-15], TopRow),
          mk_row(4, [8-13-9, 15-20-14, 22-27-11, 29-34-15], PalRow),
          mk_row(4, [10-11-2, 16-17-2, 23-24-2, 30-31-2], MarkRow),
          mk_row(4, [], Blank),
          numlist(0, 63, _),
          Frame = Rows,
          length(Pre1, 1), maplist(=(GreyRow), Pre1),
          % assemble 64 rows: row0 grey, row1 top, rows..., row29 markers, row57 palette
          findall(R,
              ( between(0, 63, RN),
                ( RN =:= 1 -> R = TopRow
                ; RN =:= 29 -> R = MarkRow
                ; RN =:= 57 -> R = PalRow
                ; R = Blank ) ),
              Rows),
          arc_sb26:sb26_reset(test), arc_sb26:sb26_build_plan(test, Frame, Plan),
          last(Plan, action(5)),
          include([select(_,_)]>>true, Plan, Sels),
          length(Sels, 8) )),

    nb_getval(sb_fails, F),
    ( F =:= 0
    -> format("~nALL sb26 SOLVER CHECKS PASSED~n~n"), halt(0)
    ;  format("~nSOME sb26 SOLVER CHECKS FAILED~n~n"), halt(1) ).

:- use_module(library(apply)).
:- use_module(library(yall)).
:- initialization(run).
