/*  Mentova — Observe_Game_Play_Run

    The one-game-at-a-time methodology needs the MENTOR to watch a Solo run and take
    structured notes: where it gets stuck, how it is (and is not) thinking, what it is
    missing, and what clues / rules / code / lattice-writes could help. This module is
    that instrument. It runs a Solo attempt on one game while recording a per-step
    observation trace (the action, the BASIS that chose it — the glass-box "why" — the
    staleness, and the outcome), then analyses the trace into a notes report and writes
    it to disk, so the mentor (a Claude session) can read it and decide the next
    intervention. It changes no play behaviour; it only observes and reports.

    Predicates:
      ogp_run/3       -- +Game, +Budget, -Report   (run a solo attempt, observe, note)
      ogp_run/2       -- +Game, -Report             (uses the current solo budget)
      ogp_trace/1     -- -Steps                      (the last run's per-step records)
      ogp_notes_file/1-- -Path                       (where the last notes were written)
*/

:- module(observe_game_play, [
    ogp_run/3,
    ogp_run/2,
    ogp_trace/1,
    ogp_notes_file/1
]).

:- use_module('mentova_arc_chat').
:- use_module(library(lists)).
:- use_module(library(aggregate)).

% ogp_step_/2: (Step, obs(Action, Basis, Provenance, Stale, Outcome)) — one observed
% step of the run under observation.
:- dynamic ogp_step_/2.
% ogp_notes_file_/1: the path of the last notes file written.
:- dynamic ogp_notes_file_/1.

% ogp_run(+Game, -Report): observe a solo attempt at the current solo budget.
ogp_run(Game, Report) :-
    ( catch(mentova_arc_chat:ma_solo_budget(B), _, fail) -> true ; B = 150 ),
    ogp_run(Game, B, Report).

% ogp_run(+Game, +Budget, -Report): run a Solo attempt on Game while recording a
% per-step observation trace, analyse it, write the mentor notes to disk, and return
% a structured report. Fully guarded so an observation hiccup never breaks the run.
ogp_run(Game, Budget, Report) :-
    retractall(ogp_step_(_, _)),
    catch(mentova_arc_chat:ma_set_game(Game), _, true),
    catch(mentova_arc_chat:ma_set_solo_budget(Budget), _, true),
    catch(mentova_arc_chat:ma_set_mode(solo), _, true),
    catch(mentova_arc_chat:ma_solo_start, _, true),
    ogp_loop(Game, 0),
    ogp_analyze(Game, Budget, Report),
    ogp_write_notes(Game, Budget, Report).

% ogp_loop(+Game, +Guard): tick the solo run to completion, capturing each step. The
% guard caps iterations well past any real budget so a stuck tick can never spin.
ogp_loop(Game, Guard) :-
    ( Guard >= 4000
    ->  true
    ;   ( catch(mentova_arc_chat:ma_solo_tick(T), _, fail)
        ->  ogp_capture(Game, T),
            ( get_dict(done, T, true)
            ->  true
            ;   G1 is Guard + 1, ogp_loop(Game, G1) )
        ;   true
        )
    ).

% ogp_capture(+Game, +Telemetry): record one observation from the tick telemetry plus
% the current glass-box state (the basis that chose the action, its provenance, and
% the staleness), keyed by the step number.
ogp_capture(Game, T) :-
    catch((
        ( get_dict(step, T, Step) -> true ; Step = 0 ),
        ( get_dict(outcome, T, Out) -> true ; Out = "running" ),
        ( mentova_arc_chat:ma_last_(Action, Basis) -> true ; Action = none, Basis = none ),
        ( catch(mentova_arc_chat:ma_why(why(_, _, Prov)), _, fail) -> true ; Prov = unknown ),
        ( catch(mentova_arc_chat:ma_stale_(Game, Stale), _, fail) -> true ; Stale = 0 ),
        assertz(ogp_step_(Step, obs(Action, Basis, Prov, Stale, Out)))
    ), _, true).

% ogp_trace(-Steps): the last run's per-step records, in order.
ogp_trace(Steps) :-
    findall(Step - Obs, ogp_step_(Step, Obs), Raw),
    keysort(Raw, Steps).

% ogp_notes_file(-Path): where the last notes were written.
ogp_notes_file(Path) :- ogp_notes_file_(Path).

% ===========================================================================
% ANALYSIS — turn the trace into structured mentor notes
% ===========================================================================

% ogp_analyze(+Game, +Budget, -Report): the structured observation.
ogp_analyze(Game, Budget, report(Game, Outcome, Steps, Bases, Stuck, Cog, Missing, Interventions)) :-
    ogp_trace(Trace),
    length(Trace, Steps),
    ogp_outcome(Trace, Outcome),
    ogp_basis_distribution(Trace, Bases),
    ogp_stuck(Trace, Stuck),
    ogp_cognition(Game, Cog),
    ogp_missing(Game, Budget, Trace, Outcome, Bases, Cog, Missing),
    ogp_interventions(Missing, Interventions).

% ogp_outcome(+Trace, -Outcome): the final outcome string (won / game_over / budget).
ogp_outcome(Trace, Outcome) :-
    ( last(Trace, _ - obs(_, _, _, _, Outcome)) -> true ; Outcome = "no_steps" ).

% ogp_basis_distribution(+Trace, -Bases): how many steps each choice basis drove,
% best-understood as WHAT KIND OF THINKING carried the run (survey, novelty,
% committed hypothesis, relational targeting, curiosity, ...).
ogp_basis_distribution(Trace, Bases) :-
    findall(Key, ( member(_ - obs(_, Basis, _, _, _), Trace), ogp_basis_key(Basis, Key) ), Keys),
    msort(Keys, Sorted),
    ogp_tally(Sorted, Bases).

% ogp_basis_key(+Basis, -Key): a compact family name for a choice basis.
ogp_basis_key(Basis, Key) :- ( compound(Basis) -> functor(Basis, Key, _) ; Key = Basis ).

% ogp_tally(+SortedKeys, -Counts): count runs of equal keys into Key-Count.
ogp_tally([], []).
ogp_tally([K | Ks], [K - N | Rest]) :-
    ogp_take_while(K, [K | Ks], Same, Remain),
    length(Same, N),
    ogp_tally(Remain, Rest).
ogp_take_while(K, [K | Xs], [K | Same], Remain) :- !, ogp_take_while(K, Xs, Same, Remain).
ogp_take_while(_, Xs, [], Xs).

% ogp_stuck(+Trace, -Stuck): the stuck picture — the maximum staleness reached (a run
% of no-progress steps) and the step at which it peaked. A high peak means the run
% plateaued, rediscovering nothing.
ogp_stuck(Trace, stuck(MaxStale, AtStep)) :-
    ( findall(Stale - Step, member(Step - obs(_, _, _, Stale, _), Trace), Pairs),
      Pairs \== []
    -> max_member(MaxStale - AtStep, Pairs)
    ;  MaxStale = 0, AtStep = 0 ).

% ogp_cognition(+Game, -Cog): the mind's end-state on this game — did it commit to a
% hypothesis, how many general laws did the world model learn, did it infer a goal,
% and how many times did it die.
ogp_cognition(Game, cog(Committed, Laws, Goal, Deaths)) :-
    ( catch(mentova_arc_chat:hypothesis_committed(Game, HC), _, fail) -> Committed = HC ; Committed = none ),
    ( catch(aggregate_all(count, mentova_arc_chat:world_model_law(Game, _, _), Laws), _, fail) -> true ; Laws = 0 ),
    ( catch(mentova_arc_chat:goal_inference_hypothesise_goal(G0), _, fail) -> Goal = G0 ; Goal = none ),
    ( catch(aggregate_all(count, mentova_arc_chat:ma_death_(Game, _, _), Deaths), _, fail) -> true ; Deaths = 0 ).

% ogp_missing(...): the diagnostics — WHAT THE RUN IS MISSING, each a flag the mentor
% acts on. Heuristics over the trace and the end cognition.
ogp_missing(_Game, Budget, Trace, Outcome, Bases, cog(Committed, Laws, Goal, _), Missing) :-
    length(Trace, Steps),
    findall(M, ogp_missing_flag(Budget, Steps, Outcome, Bases, Committed, Laws, Goal, M), Missing).

% A game_over spent well under budget — it died early, before it could learn.
ogp_missing_flag(Budget, _, Outcome, _, _, _, _, died_early) :-
    sub_atom(Outcome, _, _, _, game_over),
    ( sub_atom(Outcome, B, _, _, '(') -> true ; B = 999 ),
    % Parse the step count out of "game_over(NN)".
    ( atom_string(OA, Outcome), atomic_list_concat([_, Rest], '(', OA),
      atomic_list_concat([NumA | _], ')', Rest), atom_number(NumA, N)
    -> N < Budget * 0.3 ; fail ), !.
% Never committed to a hypothesis about what is productive.
ogp_missing_flag(_, _, _, _, none, _, _, no_committed_hypothesis).
% The world model learned no general law — it never found a repeatable effect.
ogp_missing_flag(_, _, _, _, _, 0, _, no_world_model_law).
% Never inferred a goal (no win to bootstrap from — the known blocker).
ogp_missing_flag(_, _, _, _, _, _, none, no_goal_inferred).
% One kind of thinking dominated the whole run (tunnel vision).
ogp_missing_flag(_, Steps, _, Bases, _, _, _, dominated_by(Key)) :-
    Steps > 0, member(Key - N, Bases), N >= Steps * 0.6, !.
% The run never got past the opening survey (nothing else ever fired).
ogp_missing_flag(_, Steps, _, Bases, _, _, _, never_left_survey) :-
    Steps > 0, member(survival_survey - N, Bases), N >= Steps * 0.95, !.

% ogp_interventions(+Missing, -Interventions): candidate mentor actions for each
% diagnostic — the clue, rule, code, or lattice-write that could help. These are
% SUGGESTIONS for the mentor to consider, not automatic changes.
ogp_interventions(Missing, Interventions) :-
    findall(I, ( member(M, Missing), ogp_intervention(M, I) ), Interventions).

ogp_intervention(died_early,
    'Died early: teach the deadly cell/colour as a hazard (hint_preventive) or a control-map correction, so the survival-first survey routes around it; consider lengthening the survey window for this game.').
ogp_intervention(no_committed_hypothesis,
    'No committed hypothesis: the productive action is unclear. Mentor a hint_action naming the action that advances this game, or write a CRO to the lattice (causal_learning_causal) linking the right action to its effect, so hypothesis can commit.').
ogp_intervention(no_world_model_law,
    'No world-model law: effects look inconsistent (a changing HUD/counter is masking them). Teach the volatile region, or add a context feature to world_model so the effect becomes learnable.').
ogp_intervention(no_goal_inferred,
    'No goal inferred: there is no win to bootstrap from. This is the core blocker — mentor a hint_goal (the target cell/colour), or seed a winning path over the Bridge so goal inference has a delta to learn from.').
ogp_intervention(dominated_by(Key),
    'Tunnel vision: one kind of thinking dominated the run. Consider a rule/clue that diversifies exploration or, if that basis is correct, a hint that lets it exploit sooner.').
ogp_intervention(never_left_survey,
    'Never left the survey: the survey window may be too long for this game, or every non-survey clause failed. Shorten the survey for this game, or give it a goal/hypothesis so goal-pursuit can take over.').

% ===========================================================================
% NOTES TO DISK
% ===========================================================================

% ogp_write_notes(+Game, +Budget, +Report): write the structured mentor notes to a
% dated file under the observations directory, so the cycle has a durable record.
ogp_write_notes(Game, Budget, report(_, Outcome, Steps, Bases, Stuck, Cog, Missing, Interventions)) :-
    catch((
        ogp_stamp(Stamp),
        Dir = '/home/ccaitwo/claude_work_summaries/ARC-AGI-3_Observations',
        ( exists_directory(Dir) -> true ; make_directory_path(Dir) ),
        atomic_list_concat([Dir, '/', Game, '_', Stamp, '.txt'], Path),
        setup_call_cleanup(open(Path, write, S),
            ogp_render(S, Game, Budget, Outcome, Steps, Bases, Stuck, Cog, Missing, Interventions),
            close(S)),
        retractall(ogp_notes_file_(_)),
        assertz(ogp_notes_file_(Path))
    ), _, true).

% ogp_stamp(-Atom): a filename-safe timestamp from the wall clock.
ogp_stamp(Stamp) :-
    ( catch(get_time(Now), _, fail) -> true ; Now = 0 ),
    format_time(atom(Stamp), '%Y%m%d_%H%M%S', Now).

% ogp_render(+Stream, ...): the human-readable notes.
ogp_render(S, Game, Budget, Outcome, Steps, Bases, stuck(MaxStale, AtStep),
           cog(Committed, Laws, Goal, Deaths), Missing, Interventions) :-
    format(S, "Observe_Game_Play_Run — mentor notes~n", []),
    format(S, "Game: ~w   Budget: ~w~n~n", [Game, Budget]),
    format(S, "OUTCOME: ~w   (steps observed: ~w)~n~n", [Outcome, Steps]),
    format(S, "HOW IT WAS THINKING (choice-basis distribution):~n", []),
    forall(member(K - N, Bases), format(S, "  ~w~t~28|~w steps~n", [K, N])),
    format(S, "~nWHERE IT GOT STUCK: peak staleness ~w at step ~w~n", [MaxStale, AtStep]),
    format(S, "~nEND COGNITION:~n", []),
    format(S, "  committed hypothesis: ~w~n", [Committed]),
    format(S, "  world-model laws:     ~w~n", [Laws]),
    format(S, "  inferred goal:        ~w~n", [Goal]),
    format(S, "  deaths recorded:      ~w~n", [Deaths]),
    format(S, "~nWHAT IT IS MISSING:~n", []),
    ( Missing == [] -> format(S, "  (nothing flagged)~n", [])
    ; forall(member(M, Missing), format(S, "  - ~w~n", [M])) ),
    format(S, "~nCANDIDATE MENTORING (clues / rules / code / lattice-writes):~n", []),
    ( Interventions == [] -> format(S, "  (none)~n", [])
    ; forall(member(I, Interventions), format(S, "  * ~w~n", [I])) ),
    format(S, "~n(These notes are the mentor's; adjust from them, then run the cycle again.)~n", []).
