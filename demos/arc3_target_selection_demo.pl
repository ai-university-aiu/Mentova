/*  Mentova — Ranked-Utility Object Target Selection

    Correcting a pure nearest-distance heuristic: the object worth going to NEXT is
    not always the closest one. This demonstration exercises ma_relation_target/5
    directly on synthetic object inventories and proves it ranks candidates by
    utility — goal-relevance first (committed-hypothesis click, inferred win colour,
    a proven winning-path ordering, or a refill dot while a resource drains), then
    information value, with distance ONLY as a tiebreaker — and that it reports, in a
    glass-box reason, why a farther object was chosen over a nearer one.

    Acceptance criteria (each prints PASS or FAIL):
      AC-TS-001: a far object of the inferred WIN COLOUR is chosen over a near
                 non-goal object, and the reason names goal_colour and over_nearer.
      AC-TS-002: the object the COMMITTED HYPOTHESIS says to click wins outright.
      AC-TS-003: a cell on a proven WINNING PATH is chosen (changers-then-door
                 ordering), over a nearer off-path object.
      AC-TS-004: a HAZARDOUS object (avoid-cell or deadly colour) is never chosen,
                 even when it is the goal colour and nearest.
      AC-TS-005: with no goal signal, an unvisited object is chosen for CURIOSITY,
                 and there the nearest legitimately wins (distance as tiebreaker).
      AC-TS-006: while a resource DRAINS, a collectible dot is preferred as a refill.
*/

:- use_module('../src/mentova/mentova_arc_chat').
:- use_module(library(lists), [member/2]).

report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> format("~w: PASS~n", [Id])
    ;  format("~w: FAIL~n", [Id]), nb_setval(ts_fails, 1) ).

% Clear every scrap of per-game state ma_relation_target reads, so each check starts
% from a known slate.
ts_clean(G) :-
    mentova_arc_chat:retractall(ma_avatar_(G, _, _)),
    mentova_arc_chat:retractall(ma_visited_(G, _, _)),
    mentova_arc_chat:retractall(ma_avoid_cell_(G, _)),
    mentova_arc_chat:retractall(ma_deadly_colour_(G, _)),
    mentova_arc_chat:retractall(ma_win_path_(G, _)),
    mentova_arc_chat:retractall(ma_meter_(G, _, _, _)),
    catch(mentova_arc_chat:hy_reset, _, true),
    catch(mentova_arc_chat:cgi_reset, _, true).

% A convenience: run the selector on a synthetic inventory.
ts_pick(G, Items, Pos, Reason) :-
    mentova_arc_chat:ma_relation_target(G, [], Items, Pos, Reason).

run :-
    format("~n=== Ranked-Utility Object Target Selection ===~n~n", []),
    nb_setval(ts_fails, 0),
    G = tgt_demo,

    % AC-001: goal colour beats nearness. Avatar at (0,0); a near non-goal piece at
    % (0,2), a FAR piece of the inferred win colour (4) at (0,8). The far goal object
    % must win, and the reason must say so.
    report('AC-TS-001',
        ( ts_clean(G),
          mentova_arc_chat:assertz(ma_avatar_(G, 0, 0)),
          mentova_arc_chat:cgi_observe([changed(1, 1, 0, 4)], win),
          Items1 = [ seen(a, 5, 3, cell(0, 2), piece),
                     seen(b, 4, 3, cell(0, 8), piece) ],
          ts_pick(G, Items1, Pos1, Reason1),
          Pos1 == pos(0, 8),
          Reason1 = chosen(goal_colour(4), over_nearer_by(8, 2)) )),

    % AC-002: the committed-hypothesis click wins outright. Commit productive(select(3,3))
    % (x=col 3, y=row 3) — the object at cell(3,3) must be chosen even past a nearer one.
    report('AC-TS-002',
        ( ts_clean(G),
          mentova_arc_chat:assertz(ma_avatar_(G, 0, 0)),
          forall(between(1, 8, _), mentova_arc_chat:hy_support(G, productive(select(3, 3)))),
          mentova_arc_chat:hy_update_commitment(G),
          Items2 = [ seen(a, 5, 3, cell(0, 1), piece),
                     seen(b, 5, 3, cell(3, 3), piece) ],
          ts_pick(G, Items2, Pos2, Reason2),
          Pos2 == pos(3, 3),
          Reason2 = chosen(committed_click, _) )),

    % AC-003: a proven winning-path cell is chosen over a nearer off-path object.
    % Avatar at (0,5); win path selects cell(0,1) then cell(0,3); a near off-path
    % piece sits at (0,4). The first path cell must win despite being farther.
    report('AC-TS-003',
        ( ts_clean(G),
          mentova_arc_chat:assertz(ma_avatar_(G, 0, 5)),
          mentova_arc_chat:assertz(ma_win_path_(G, [select(1, 0), select(3, 0)])),
          Items3 = [ seen(a, 5, 3, cell(0, 4), piece),
                     seen(b, 5, 3, cell(0, 1), piece),
                     seen(c, 5, 3, cell(0, 3), piece) ],
          ts_pick(G, Items3, Pos3, Reason3),
          Pos3 == pos(0, 1),
          Reason3 = chosen(won_path_order(0), over_nearer_by(4, 1)) )),

    % AC-004: a hazardous object is never chosen, even if goal-coloured and nearest.
    % The goal-coloured object at (0,1) sits on an avoid cell; the safe curiosity
    % piece at (0,6) must be chosen instead.
    report('AC-TS-004',
        ( ts_clean(G),
          mentova_arc_chat:assertz(ma_avatar_(G, 0, 0)),
          mentova_arc_chat:cgi_observe([changed(1, 1, 0, 4)], win),
          mentova_arc_chat:assertz(ma_avoid_cell_(G, pos(0, 1))),
          Items4 = [ seen(a, 4, 3, cell(0, 1), piece),
                     seen(b, 5, 3, cell(0, 6), piece) ],
          ts_pick(G, Items4, Pos4, _Reason4),
          Pos4 == pos(0, 6) )),

    % AC-005: with no goal signal, curiosity picks an unvisited object and the
    % nearest legitimately wins (distance as the tiebreaker within the same tier).
    report('AC-TS-005',
        ( ts_clean(G),
          mentova_arc_chat:assertz(ma_avatar_(G, 0, 0)),
          Items5 = [ seen(a, 5, 3, cell(0, 5), piece),
                     seen(b, 5, 3, cell(0, 2), piece) ],
          ts_pick(G, Items5, Pos5, Reason5),
          Pos5 == pos(0, 2),
          Reason5 = chosen(curiosity(piece), nearest) )),

    % AC-006: while a resource drains, a collectible dot is preferred as a refill,
    % over a nearer non-dot piece.
    report('AC-TS-006',
        ( ts_clean(G),
          mentova_arc_chat:assertz(ma_avatar_(G, 0, 0)),
          mentova_arc_chat:assertz(ma_meter_(G, life, 3, falling)),
          Items6 = [ seen(a, 5, 3, cell(0, 1), piece),
                     seen(b, 6, 1, cell(0, 5), dot) ],
          ts_pick(G, Items6, Pos6, Reason6),
          Pos6 == pos(0, 5),
          Reason6 = chosen(resource_refill_dot, over_nearer_by(5, 1)) )),

    nb_getval(ts_fails, F),
    ( F =:= 0
    -> format("~nALL TARGET-SELECTION CHECKS PASSED~n~n"), halt(0)
    ;  format("~nSOME TARGET-SELECTION CHECKS FAILED~n~n"), halt(1) ).

:- initialization(run).
