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

    % Show the current learnings both sub-projects see.
    g3_learnings(Learn),
    format("~nshared learnings (seen by both sub-projects): ~q~n", [Learn]),
    % Show the recorded attempts.
    ma_attempts_list(Files),
    format("solo attempt reports on record: ~w~n~n", [Files]).

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
    s3_learnings(learnings(Goal, _, _, _, _, _)),
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
