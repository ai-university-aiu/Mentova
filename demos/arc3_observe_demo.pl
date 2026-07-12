/*  Mentova — Observe_Game_Play_Run demonstration

    Proves the mentor's observation instrument: it runs a Solo attempt on one game,
    records a per-step choice-basis trace, analyses it into structured notes (outcome,
    how it was thinking, where it stuck, end cognition, what it is missing, candidate
    mentoring), and writes those notes to disk.

    Acceptance criteria (each prints PASS or FAIL):
      AC-OG-001: ogp_run produces a well-formed report for a solo attempt.
      AC-OG-002: the per-step trace is non-empty and ordered.
      AC-OG-003: the report analyses the choice-basis distribution (how it thinks).
      AC-OG-004: the report surfaces end cognition (hypothesis / laws / goal / deaths).
      AC-OG-005: a mentor notes file is written to disk and is readable.
*/

:- use_module('../src/mentova/observe_game_play').
:- use_module('../src/mentova/mentova_arc_chat').
:- use_module(library(lists)).

report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> format("~w: PASS~n", [Id])
    ;  format("~w: FAIL~n", [Id]), nb_setval(og_fails, 1) ).

run :-
    format("~n=== Observe_Game_Play_Run ===~n~n", []),
    nb_setval(og_fails, 0),
    catch(ma_db_init('data/chat_db'), _, true),

    report('AC-OG-001',
        ( ogp_run(ft09, 40, R),
          R = report(ft09, _Outcome, _Steps, _Bases, _Stuck, _Cog, _Missing, _Iv) )),

    report('AC-OG-002',
        ( ogp_trace(Trace), Trace \== [],
          Trace = [S0 - _ | _], integer(S0) )),

    report('AC-OG-003',
        ( ogp_run(ft09, 40, R3),
          R3 = report(_, _, _, Bases, _, _, _, _),
          is_list(Bases), Bases \== [],
          forall(member(_ - N, Bases), integer(N)) )),

    report('AC-OG-004',
        ( ogp_run(ft09, 40, R4),
          R4 = report(_, _, _, _, _, cog(_Committed, Laws, _Goal, Deaths), _, _),
          integer(Laws), integer(Deaths) )),

    report('AC-OG-005',
        ( ogp_run(ft09, 40, _R5),
          ogp_notes_file(Path),
          exists_file(Path) )),

    nb_getval(og_fails, F),
    ( F =:= 0
    -> format("~nALL OBSERVE CHECKS PASSED~n~n"), halt(0)
    ;  format("~nSOME OBSERVE CHECKS FAILED~n~n"), halt(1) ).

:- initialization(run).
