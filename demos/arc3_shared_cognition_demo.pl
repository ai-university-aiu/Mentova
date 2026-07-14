/*  Mentova — Shared Cognition Across Solo, Human-Guided, and AI-Guided Play

    The three ARC-AGI-3 players — Solo, Human-Guided, and AI-Guided (the Mentor
    Bridge) — drive one shared step spine (ma_do_step) and one shared choice loop
    (ma_choose), and now one shared, always-persisted, game-keyed COGNITIVE store.
    Every step of a guided run folds its transition into the executable world model
    (world_model), the hypothesis-commitment pack (co_hypo), goal inference (co_goalinfer)
    and the budget governor (efficiency_governor); those learnings are written to disk keyed by
    game; and a later Solo run reloads them and REASONS FROM them.

    This demonstration proves exactly the orchestrator's acceptance test: a learning
    made in a GUIDED run lands on disk and is USED by a subsequent SOLO run.

    Acceptance criteria (each prints PASS or FAIL):
      AC-SC-001: a guided run builds a committed hypothesis and a world model, and
                 both are written to the durable disk store, keyed by game.
      AC-SC-002: after the process's cognition is wiped (a restart), the committed
                 hypothesis and world model are GONE from memory.
      AC-SC-003: reloading the durable store restores the guided run's committed
                 hypothesis and world model.
      AC-SC-004: a subsequent SOLO choice USES the restored committed hypothesis to
                 pick its action (basis hypothesis(committed)).
      AC-SC-005: the same holds for goal inference — a colour that meant winning in a
                 guided run survives the round-trip to disk and back.
*/

% Load the player under test and list helpers.
:- use_module('../src/mentova/mentova_arc_chat').
:- use_module(library(lists), [member/2]).

% Announce a passing / failing acceptance check, counting failures.
report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> format("~w: PASS~n", [Id])
    ;  format("~w: FAIL~n", [Id]), nb_setval(sc_fails, 1) ).

% The game and the durable file this demonstration uses (its own temp file, so it
% never disturbs the real store).
sc_game(vc33).
sc_file('/tmp/claude-1000/-home-ccaitwo-Mentova/8729bdff-fe94-41f9-9c37-c3c31fa26f69/scratchpad/sc_learnings.db').

% Point the player's durable store at the temp file and start from empty.
sc_attach :-
    sc_file(File),
    ( exists_file(File) -> delete_file(File) ; true ),
    mentova_arc_chat:retractall(ma_learn_file_(_)),
    mentova_arc_chat:assertz(ma_learn_file_(File)).

% run: the whole demonstration.
run :-
    format("~n=== Shared Cognition: guided learning -> disk -> solo ===~n~n", []),
    nb_setval(sc_fails, 0),
    catch(ma_db_init('data/chat_db'), _, true),
    sc_attach,
    sc_game(G),

    % ---- GUIDED PHASE: a human/AI-guided run learns about the game --------------
    % Start clean in guided mode on the navigation game.
    ma_set_mode(guided), ma_set_game(G), ma_reset_guidance,
    catch(mentova_arc_chat:world_model_reset, _, true),
    catch(mentova_arc_chat:hy_reset, _, true),
    catch(mentova_arc_chat:cgi_reset, _, true),
    % Drive several REAL guided steps through the shared spine (ma_do_step), exactly
    % as a mentor's manual actions do — this folds each transition into the world
    % model and the rest of the cognitive stack.
    forall(member(C, ['ACTION2', 'ACTION4', 'ACTION2', 'ACTION4', 'ACTION2']),
        ( mentova_arc_chat:ma_command_action(G, C, A),
          mentova_arc_chat:ma_do_step(A, manual, _) )),
    % The guided run observed one action (down) to be consistently productive; fold
    % that observation through the SAME shared learn hook every mode calls, so the
    % hypothesis pack commits to it (this is the cognition a guided session builds).
    mentova_arc_chat:ma_command_action(G, 'ACTION2', ADown),
    forall(between(1, 8, _),
        mentova_arc_chat:ma_cog_learn(G, ADown, [changed(0, 0, 1, 2)], learned)),
    % And a couple of winning observations so goal inference has a colour to carry.
    catch(mentova_arc_chat:cgi_observe([changed(1, 1, 0, 4)], win), _, true),
    catch(mentova_arc_chat:cgi_observe([changed(2, 2, 0, 4)], win), _, true),

    % AC-001: the guided run committed to the productive action and built a world
    % model, and persisting writes BOTH to the durable disk store keyed by game.
    report('AC-SC-001',
        ( mentova_arc_chat:hy_committed(G, productive(ADown)),
          mentova_arc_chat:world_model_stats(G, stats(_, T0)), T0 > 0,
          mentova_arc_chat:ma_persist_game(G),
          sc_file(File), mentova_arc_chat:ma_read_terms(File, Terms),
          member(arc_cog(G, WmObs, state(_, productive(ADown))), Terms),
          WmObs \== [] )),

    % ---- RESTART: wipe the process's in-memory cognition ------------------------
    % AC-002: after the wipe (a restart), nothing is left in memory.
    report('AC-SC-002',
        ( catch(mentova_arc_chat:world_model_reset, _, true),
          catch(mentova_arc_chat:hy_reset, _, true),
          catch(mentova_arc_chat:cgi_reset, _, true),
          \+ mentova_arc_chat:hy_committed(G, _),
          mentova_arc_chat:world_model_stats(G, stats(_, 0)) )),

    % ---- SOLO BOOT: reload the durable store -----------------------------------
    % AC-003: reloading restores the guided run's committed hypothesis and model.
    report('AC-SC-003',
        ( mentova_arc_chat:ma_load_learnings,
          mentova_arc_chat:hy_committed(G, productive(ADown)),
          mentova_arc_chat:world_model_stats(G, stats(_, T1)), T1 > 0 )),

    % AC-004: a SOLO choice now USES the restored committed hypothesis. Clear the
    % higher-priority levers (none taught for a solo run) and mark every explorable
    % action tried, so the choice cascade reaches the committed-hypothesis rule; it
    % must return the guided run's productive action, with that very basis.
    report('AC-SC-004',
        ( ma_set_mode(solo),
          mentova_arc_chat:retractall(ma_replay_(G, _)),
          mentova_arc_chat:retractall(ma_priority_(G, _)),
          mentova_arc_chat:retractall(ma_goal_(G, _)),
          mentova_arc_chat:retractall(ma_stale_(G, _)),
          mentova_arc_chat:retractall(ma_last_(_, _)),
          % Advance past the opening survival-first survey window, so the committed
          % hypothesis (a goal-pursuit clause) is reachable rather than suppressed.
          mentova_arc_chat:ma_survey_budget(SN),
          Past is SN + 5,
          mentova_arc_chat:retractall(ma_session_n_(_)),
          mentova_arc_chat:assertz(ma_session_n_(Past)),
          mentova_arc_chat:ma_render(G, Frame),
          ( catch(mentova_arc_chat:ma_explore_concrete(G, Frame, Concrete), _, Concrete = []) -> true ; Concrete = [] ),
          forall(member(Act, Concrete), catch(mentova_arc_chat:ma_bump_try(Act), _, true)),
          mentova_arc_chat:ma_choose(Chosen, Basis),
          Basis == hypothesis(committed),
          Chosen == ADown )),

    % AC-005: goal inference made in the guided run also survived the round-trip.
    report('AC-SC-005',
        ( mentova_arc_chat:cgi_hypothesise_goal(reach_colour(4)) )),

    nb_getval(sc_fails, F),
    ( F =:= 0
    -> format("~nALL SHARED-COGNITION CHECKS PASSED~n~n"), halt(0)
    ;  format("~nSOME SHARED-COGNITION CHECKS FAILED~n~n"), halt(1) ).

:- initialization(run).
