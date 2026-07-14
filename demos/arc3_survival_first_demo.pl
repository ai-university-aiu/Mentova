/*  Mentova — Survival-First Early-Budget Policy

    The cold sweeps died at first-hazard contact before assembling a winning
    hypothesis. This policy spends the opening fraction of the attempt budget
    SURVEYING — safe, breadth-first probing that builds the world model and the
    hazard map — and defers goal-pursuit (recall / committed hypothesis / relational
    targeting) until the survey window closes.

    Acceptance criteria (each prints PASS or FAIL):
      AC-SF-001: the survey window is a sensible fraction of the budget.
      AC-SF-002: EARLY in an attempt (session count 0) the choice is survival_survey,
                 NOT a committed-hypothesis lunge — even with a committed hypothesis
                 available. Goal-pursuit is suppressed during the survey.
      AC-SF-003: AFTER the survey window closes, the committed hypothesis is used
                 again (the suppression lifts).
      AC-SF-004: within the survey, a predicted-fatal move is never chosen when a
                 safe probe exists (hard-drop, not deprioritise).
      AC-SF-005: within the survey, a click probe (no avatar move) is preferred over
                 a step into unmapped territory.
*/

:- use_module('../src/mentova/mentova_arc_chat').
:- use_module(library(lists)).

report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> format("~w: PASS~n", [Id])
    ;  format("~w: FAIL~n", [Id]), nb_setval(sf_fails, 1) ).

run :-
    format("~n=== Survival-First Early-Budget Policy ===~n~n", []),
    nb_setval(sf_fails, 0),
    catch(ma_db_init('data/chat_db'), _, true),
    ma_set_solo_budget(150),
    ma_set_mode(solo),

    % AC-001: survey window is ~15% of budget, clamped to [8,30]. For 150 -> 23.
    report('AC-SF-001',
        ( mentova_arc_chat:ma_survey_budget(SN), SN >= 8, SN =< 30, SN =:= 23 )),

    % AC-002 + AC-003: goal-pursuit suppressed during survey, restored after. Use the
    % locksmith stand-in; give it a committed productive action, then check the choice
    % basis early (session 0) vs after the survey window.
    report('AC-SF-002',
        ( ma_set_game(ls20), mentova_arc_chat:ma_solo_start,
          % Clear any stale durable learnings so the survey clause is reachable (a
          % loaded win path would otherwise trigger replay above it).
          mentova_arc_chat:retractall(ma_replay_(ls20, _)),
          mentova_arc_chat:retractall(ma_win_path_(ls20, _)),
          mentova_arc_chat:retractall(ma_goal_(ls20, _)),
          mentova_arc_chat:retractall(ma_priority_(ls20, _)),
          % A committed hypothesis that WOULD be used past the survey window.
          mentova_arc_chat:ma_actions_env(ls20, As), As = [A1 | _],
          catch(mentova_arc_chat:hypothesis_reset, _, true),
          forall(between(1, 8, _), mentova_arc_chat:hypothesis_support(ls20, productive(A1))),
          mentova_arc_chat:hypothesis_update_commitment(ls20),
          % Session count is 0 (fresh attempt) -> we are in the survey window.
          mentova_arc_chat:retractall(ma_session_n_(_)),
          mentova_arc_chat:assertz(ma_session_n_(0)),
          mentova_arc_chat:ma_choose(_, BasisEarly),
          BasisEarly == survival_survey )),

    report('AC-SF-003',
        ( % Advance the session count PAST the survey window; suppression lifts.
          mentova_arc_chat:ma_survey_budget(SN2),
          Past is SN2 + 5,
          mentova_arc_chat:retractall(ma_session_n_(_)),
          mentova_arc_chat:assertz(ma_session_n_(Past)),
          % Exhaust the untried actions so novelty does not mask the hypothesis clause.
          ma_render(ls20, Frame3),
          ( catch(mentova_arc_chat:ma_explore_concrete(ls20, Frame3, C3), _, C3 = []) -> true ; C3 = [] ),
          forall(member(Ax, C3), catch(mentova_arc_chat:ma_bump_try(Ax), _, true)),
          mentova_arc_chat:retractall(ma_last_(_, _)),
          mentova_arc_chat:ma_choose(_, BasisLate),
          BasisLate == hypothesis(committed) )),

    % AC-004: within the survey, a predicted-fatal action is never chosen when a safe
    % probe exists. Mark one action fatal from the exact current state (death memory),
    % then confirm the survey action avoids it and is itself not predicted fatal.
    report('AC-SF-004',
        ( ma_set_game(ls20), mentova_arc_chat:ma_solo_start,
          ma_render(ls20, F4),
          mentova_arc_chat:ma_state_key(ls20, F4, Key4),
          mentova_arc_chat:ma_actions_env(ls20, As4), As4 = [Fatal4 | _],
          catch(mentova_arc_chat:verification_note_fatal(ls20, Key4, Fatal4), _, true),
          mentova_arc_chat:ma_predict_fatal(ls20, F4, Fatal4),
          mentova_arc_chat:ma_survey_action(ls20, F4, Chosen4),
          Chosen4 \== Fatal4,
          \+ mentova_arc_chat:ma_predict_fatal(ls20, F4, Chosen4) )),

    % AC-005: within the survey, a click probe (cost 0) is preferred over a step into
    % unmapped territory (cost 2), by the survival cost ranking.
    report('AC-SF-005',
        ( mentova_arc_chat:ma_survey_cost(any, select(3, 3), C_click),
          C_click =:= 0,
          % An unmapped move (no control vector known) costs 2.
          mentova_arc_chat:retractall(ma_move_vec_(any, _, _, _)),
          mentova_arc_chat:ma_survey_cost(any, action(up), C_move),
          C_move =:= 2,
          C_click < C_move )),

    nb_getval(sf_fails, F),
    ( F =:= 0
    -> format("~nALL SURVIVAL-FIRST CHECKS PASSED~n~n"), halt(0)
    ;  format("~nSOME SURVIVAL-FIRST CHECKS FAILED~n~n"), halt(1) ).

:- initialization(run).
