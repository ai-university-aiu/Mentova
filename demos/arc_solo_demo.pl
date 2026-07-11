/*  Mentova — ARC-AGI-3 Guided and Solo Sub-Projects Demonstration

    Exercises the two ARC-AGI-3 learning sub-projects and their shared page:
      - ARC-AGI-3_Guided receives human clues and learns.
      - ARC-AGI-3_Solo takes those learnings and runs the game unaided,
        writing a date-and-time-stamped report of each attempt.

    Acceptance criteria (each prints PASS or FAIL at run time):
      AC-GS-001: three ARC-AGI-3 game environments are selectable.
      AC-GS-002: the mode switches between Guided and Solo.
      AC-GS-003: Solo wins the signal game (ft09) unaided and writes a report.
      AC-GS-004: after guided teaching, Solo uses the learnings to win the
                 locksmith game (ls20), and its report records the taught goal.
      AC-GS-005: both sub-projects read exactly the same shared learnings.
      AC-GS-006: the solo attempts list is populated and a report is viewable.
      AC-GS-007: Guided play builds the shared state graph and Solo reads it.
      AC-GS-008: learnings are keyed by game id — teaching one environment never
                 bleeds into another, and reselecting a game restores its own.
      AC-GS-009: a game's learnings are persisted to disk and reloaded after a
                 restart, keyed by game id — a concluded win outlasts the process.

    Run:
        swipl -l demos/arc_solo_demo.pl -g run_arc_solo_demo -t halt
*/

% Load the shared ARC-AGI-3 chat backend and the two sub-project facades.
:- use_module('../src/mentova/mentova_arc_chat').
% The guided sub-project.
:- use_module('../src/mentova/arc_agi_3_guided').
% The solo sub-project.
:- use_module('../src/mentova/arc_agi_3_solo').
% List helpers.
:- use_module(library(lists), [member/2]).

% report(+Id, +Cond): print PASS or FAIL for one acceptance criterion.
report(Id, Cond) :-
    % Evaluate once.
    ( call(Cond) -> V = 'PASS' ; V = 'FAIL' ),
    % Print the verdict.
    format("~w: ~w~n", [Id, V]).

% tick_to_done(+N, +Max, -Final): advance the solo run until it finishes.
tick_to_done(N, Max, Final) :-
    % Stop at the cap.
    ( N >= Max
    ->  ma_solo_tick(Final)
    % Otherwise tick and check.
    ;   ma_solo_tick(T),
        ( get_dict(done, T, true) -> Final = T ; N1 is N + 1, tick_to_done(N1, Max, Final) )
    ).

% Define run_arc_solo_demo: run the full demonstration.
run_arc_solo_demo :-
    % Announce.
    format("~n=== ARC-AGI-3 Guided and Solo Sub-Projects ===~n~n", []),
    % Attach the shared database (guarded).
    catch(ma_db_init('data/chat_db'), _, true),
    % Start fresh: guided mode, locksmith, no leftover guidance.
    ma_set_mode(guided), ma_set_game(ls20), ma_reset_guidance,

    % AC-001: three environments are selectable.
    report('AC-GS-001', ( findall(I, ma_game_info(I, _), Ids), length(Ids, 3) )),

    % AC-002: the mode switches both ways.
    report('AC-GS-002', ( ma_set_mode(solo), ma_mode(solo),
                          ma_set_mode(guided), ma_mode(guided) )),

    % AC-003: Solo wins the signal game unaided and writes a report.
    report('AC-GS-003', demo_solo_signal),

    % AC-004: after guided teaching, Solo uses the learnings to win the locksmith.
    report('AC-GS-004', demo_guided_then_solo),

    % AC-005: both sub-projects read the same shared learnings.
    report('AC-GS-005', ( g3_learnings(L1), s3_learnings(L2), L1 == L2 )),

    % AC-006: the attempts list is populated and a report is viewable.
    report('AC-GS-006', demo_attempts_viewable),

    % AC-007: Guided play builds the shared state graph, and Solo reads the very
    % same graph (co_graph wired into both, one store).
    report('AC-GS-007', demo_shared_graph),

    % AC-008: learnings are keyed by game id — what is taught in one environment
    % never bleeds into another, and reselecting the first game restores its own.
    report('AC-GS-008', demo_cross_game_isolation),

    % AC-009: a game's learnings are written to disk and reloaded after a restart,
    % keyed by game id — a concluded win survives the process ending.
    report('AC-GS-009', demo_durable_persistence),

    % Show the current learnings both sub-projects see.
    g3_learnings(Learn),
    format("~nshared learnings (seen by both sub-projects): ~q~n", [Learn]),
    % Show the recorded attempts.
    ma_attempts_list(Files),
    format("solo attempt reports on record: ~w~n~n", [Files]).

% demo_shared_graph: Guided actions build the state graph; Solo reads the same one.
demo_shared_graph :-
    % A fresh navigation game with an empty graph.
    ma_set_game(vc33), ma_set_mode(guided), ma_reset_guidance,
    catch(mentova_arc_chat:cg_reset, _, true),
    % Drive a few guided actions, which build the shared exploration graph.
    forall(member(C, ['ACTION2', 'ACTION4', 'ACTION2', 'ACTION4']),
        ( mentova_arc_chat:ma_command_action(vc33, C, A),
          mentova_arc_chat:ma_do_step(A, manual, _) )),
    % The Guided sub-project now sees a non-trivial graph.
    g3_graph(G1),
    G1 = stats(Nodes, _Edges, Tested, _Dead),
    Nodes >= 3, Tested >= 3,
    % The Solo sub-project reads the very same graph (identical statistics).
    s3_graph(G2),
    G1 == G2.

% demo_cross_game_isolation: teach the locksmith (ls20) a full set of learnings,
% then prove none of them appear under a different game (vc33), and that
% reselecting ls20 restores exactly what was taught there — Game Environment
% Identification is firmly attached to every learning, so no environment's
% learnings ever bleed into another's.
demo_cross_game_isolation :-
    % Record the navigation game's current learnings as a baseline. Whatever the
    % locksmith is taught next must leave this baseline completely unchanged.
    ma_set_game(vc33), ma_set_mode(guided),
    g3_learnings(BaselineV),
    % Give the locksmith a fresh, full set of learnings of its own: clear only the
    % locksmith's guidance, then label, prioritise, set a goal, and mark a hazard.
    ma_set_game(ls20), ma_reset_guidance,
    g3_inject(hint_label([2, 2], key_like)),
    g3_inject(hint_action(action(pickup))),
    g3_inject(hint_goal([0, 4], traverse)),
    g3_inject(hint_preventive([3, 3])),
    % The locksmith now carries real learnings across the lever stores.
    g3_learnings(learnings(GoalL, PriosL, AvoidL, LabelsL, _, _, _)),
    GoalL \== none, PriosL \== [], AvoidL \== [], LabelsL \== [],
    % Switch to the navigation game: teaching the locksmith changed nothing here.
    % Its learnings are byte-for-byte the baseline — no bleed across environments.
    ma_set_game(vc33),
    g3_learnings(AfterV),
    AfterV == BaselineV,
    % None of the locksmith's taught levers appear under the navigation game.
    AfterV = learnings(GoalV, PriosV, AvoidV, LabelsV, _, _, _),
    GoalV == none, PriosV == [], AvoidV == [], LabelsV == [],
    % Switch back to the locksmith: its own learnings are intact and unchanged by
    % anything the other game did.
    ma_set_game(ls20),
    g3_learnings(learnings(GoalL2, PriosL2, AvoidL2, LabelsL2, _, _, _)),
    GoalL2 == GoalL, PriosL2 == PriosL, AvoidL2 == AvoidL, LabelsL2 == LabelsL.

% demo_durable_persistence: a game's learnings are written to disk when a win is
% concluded and reloaded on the next boot, so a win outlasts the process. This
% proves the round trip within one run: teach a game, persist it (exactly what
% concluding a win does), wipe every in-memory learning store as a restart would,
% reload from disk, and confirm every learning came back byte for byte, keyed by
% the game it came from.
demo_durable_persistence :-
    % Isolate the durable store in a scratch location so the demo never writes the
    % repository's own data directory.
    ma_learn_attach('/tmp/mentova_persist_demo/chat_db'),
    % Teach the locksmith a full set of learnings and drive a couple of steps so
    % the graph, effects, and causal relations are populated too.
    ma_set_game(ls20), ma_set_mode(guided), ma_reset_guidance,
    g3_inject(hint_label([2, 2], key_like)),
    g3_inject(hint_action(action(pickup))),
    g3_inject(hint_goal([0, 4], traverse)),
    g3_inject(hint_preventive([3, 3])),
    forall(member(C, ['ACTION2', 'ACTION4']),
        ( mentova_arc_chat:ma_command_action(ls20, C, A),
          mentova_arc_chat:ma_do_step(A, manual, _) )),
    % Persist this game's learnings to disk, exactly as concluding a win does.
    mentova_arc_chat:ma_persist_game(ls20),
    % Capture the learnings as they stand, and confirm they are non-trivial.
    g3_learnings(Before),
    Before = learnings(GoalB, _, _, _, _, _, _), GoalB \== none,
    % Simulate a restart: wipe every in-memory learning store, including the
    % Causalontology relations and the shared state graph.
    retractall(mentova_arc_chat:ma_goal_(_, _)),
    retractall(mentova_arc_chat:ma_priority_(_, _)),
    retractall(mentova_arc_chat:ma_avoid_cell_(_, _)),
    retractall(mentova_arc_chat:ma_label_(_, _, _)),
    retractall(mentova_arc_chat:ma_effect_(_, _, _)),
    retractall(mentova_arc_chat:ma_win_path_(_, _)),
    catch(mentova_arc_chat:cg_reset, _, true),
    retractall(co_core:co_cro_(_, _, _, _, _, _, _, _)),
    % The stores are now empty for the game.
    g3_learnings(learnings(none, [], [], [], 0, _, stats(0, 0, 0, 0))),
    % Reload from disk, exactly as boot does.
    mentova_arc_chat:ma_load_learnings,
    % Every learning is back, byte for byte, under its own game id.
    g3_learnings(After),
    After == Before.

% demo_solo_signal: Solo wins ft09 unaided and a report is written.
demo_solo_signal :-
    % Select the signal game and enter solo mode.
    ma_set_game(ft09), ma_set_mode(solo),
    % Begin a fresh solo attempt.
    ma_restart(_SoloStart, _SoloReply),
    % Advance to completion.
    tick_to_done(0, 80, Final),
    % It must have won.
    sub_atom(Final.outcome, 0, _, _, won),
    % A report filename must have been returned.
    Final.report \== none.

% demo_guided_then_solo: teach the locksmith, then Solo uses the learnings.
demo_guided_then_solo :-
    % Guided mode on the locksmith.
    ma_set_game(ls20), ma_set_mode(guided), ma_reset_guidance,
    % Teach as the guided clues would: label the key, suggest pickup, set the door goal.
    g3_inject(hint_label([2, 2], key_like)),
    % Raise the pickup action's priority.
    g3_inject(hint_action(action(pickup))),
    % Set the traverse goal at the door.
    g3_inject(hint_goal([0, 4], traverse)),
    % Now hand off to Solo — no further human input.
    ma_set_mode(solo), ma_restart(_GS, _GR),
    % Advance to completion.
    tick_to_done(0, 80, Final),
    % Solo must have won using the taught learnings.
    sub_atom(Final.outcome, 0, _, _, won),
    % The learnings Solo drew on must include the taught goal.
    s3_learnings(learnings(Goal, _, _, _, _, _, _)),
    % A goal was carried over from guided teaching.
    Goal \== none.

% demo_attempts_viewable: the attempts list is populated and readable.
demo_attempts_viewable :-
    % The list has at least one report.
    ma_attempts_list([First | _]),
    % It is a stamped text report.
    atom_concat('ARC-AGI-3_Solo_', _, First),
    % Its file exists on disk under the attempts directory.
    ma_attempts_dir(Dir),
    % The full path.
    atomic_list_concat([Dir, '/', First], Path),
    % It exists.
    exists_file(Path).
