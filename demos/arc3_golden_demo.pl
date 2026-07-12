/*  Mentova — Golden Game Environment Reference loader demonstration

    Proves the loader that the GOLDEN GAME ENVIRONMENT REFERENCE RULE relies on: before
    a Mentor Bridge run, the matching unified golden file (/home/ccaitwo/ARC-AGI-3/<game>.txt)
    is read and its entire contents are loaded into J-Space.

    Acceptance criteria (each prints PASS or FAIL):
      AC-GD-001: the golden file path resolves and the file exists for a game.
      AC-GD-002: the golden file's non-empty lines are read (non-trivial count).
      AC-GD-003: loading holds every line into J-Space and returns the count.
      AC-GD-004: a game with no golden file loads gracefully (0 concepts, no throw).
*/

:- use_module('../src/mentova/mentova_arc_chat').
:- use_module('../src/mentova/arc_golden').
:- use_module(library(lists)).

report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> format("~w: PASS~n", [Id])
    ;  format("~w: FAIL~n", [Id]), nb_setval(gd_fails, 1) ).

run :-
    format("~n=== Golden Game Environment Reference loader ===~n~n", []),
    nb_setval(gd_fails, 0),

    report('AC-GD-001',
        ( arc_golden:agp_golden_file(sb26, Path), exists_file(Path) )),

    report('AC-GD-002',
        ( arc_golden:agp_golden_lines(sb26, Lines), length(Lines, N), N > 50 )),

    report('AC-GD-003',
        ( arc_golden:agp_load_golden(sb26, Count), integer(Count), Count > 50 )),

    report('AC-GD-004',
        ( arc_golden:agp_load_golden('no_such_game_xyz', C0), C0 =:= 0 )),

    nb_getval(gd_fails, F),
    ( F =:= 0
    -> format("~nALL GOLDEN-LOADER CHECKS PASSED~n~n"), halt(0)
    ;  format("~nSOME GOLDEN-LOADER CHECKS FAILED~n~n"), halt(1) ).

:- initialization(run).
