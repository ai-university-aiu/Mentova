/*  Mentova — mentova_arc_agi_3_chat Acceptance Demonstration  (Acc_426)

    Exercises the Causalontology delivery end to end:

      - the verbatim runnable core of Causalontology_v5 Appendix A, executed
        in a subprocess with its own self-checks;
      - the clue-grounding table of Section 10.4, clue by clue;
      - the guided game loop: a human's clues label the key, suggest the
        pickup, declare the trap hazardous, and set the door goal — and
        Mentova, guided, wins the locksmith level;
      - the glass-box why, distinguishing guidance from discovery;
      - the full HTTP application: mentor login, clue over the wire routed
        through the real teach queue with game-play auto-approve, control,
        frame, and why endpoints, and refusal of the unauthenticated.

    Acceptance criteria (each prints PASS or FAIL at run time):
      AC-ACC426-001: the Appendix A runnable core passes its self-checks.
      AC-ACC426-002: every clue of the Section 10.4 table grounds correctly.
      AC-ACC426-003: ungroundable and unsafe clue texts are refused.
      AC-ACC426-004: injected clues label continuants, attach a disposition,
                     set the goal, and enforce the human-declared hazard.
      AC-ACC426-005: the guided run wins the locksmith level within budget.
      AC-ACC426-006: the why reports the last action as guided by the human.
      AC-ACC426-007: reinforcement raises the strength of the last relations.
      AC-ACC426-008: over HTTP — login, hint, control, frame, why — the
                     application works end to end and refuses bad tokens.

    Run:
        swipl -l demos/arc_chat_demo.pl -g run_arc_chat_demo -t halt
*/

% Declare this file as the demo script module with a single entry point.
:- module(arc_chat_demo_script, [run_arc_chat_demo/0]).

% Load the application under test.
:- use_module('../src/mentova/mentova_arc_chat').
% Load the chat database for mentor accounts and sessions.
:- use_module('../src/mentova/chat_db',
              [mc_create_mentor/2, mc_authenticate_mentor/3, mc_create_session/2]).
% Load the Causalontology stores the clues write into.
:- use_module(library(noun_backbone), [noun_backbone_continuant/2]).
% Load the hinge the key clue populates.
:- use_module(library(realizable_hinge), [realizable_hinge_realizable/3]).
% Load the learner whose avoid-set the hazard clue feeds.
:- use_module(library(causal_learning), [causal_learning_avoid/1, causal_learning_reset/0]).
% Load the core for the reinforcement check.
:- use_module(library(causal_core), [causal_core_cro/8, causal_core_reset/0]).
% Load the hinge reset.
:- use_module(library(realizable_hinge), [realizable_hinge_reset/0]).
% Load the HTTP client for the over-the-wire scenes.
:- use_module(library(http/http_open)).
% Load the JSON codec.
:- use_module(library(http/json)).
% Load list helpers.
:- use_module(library(lists), [member/2, memberchk/2]).
% Load process creation for the subprocess scene.
:- use_module(library(process)).
% Load the line reader.
:- use_module(library(readutil), [read_line_to_string/2]).

% The test port of the HTTP scenes.
demo_port(8099).

% fresh/0: clear every store the demonstration touches.
fresh :-
    % Clear the verb layer.
    causal_core_reset,
    % Clear the hinge.
    realizable_hinge_reset,
    % Clear the learning state.
    causal_learning_reset,
    % Clear guidance, labels, and counters.
    ma_reset_guidance,
    % Reset the game.
    ma_game_reset(_).

% ---------------------------------------------------------------------------
% ENTRY POINT
% ---------------------------------------------------------------------------

% run_arc_chat_demo/0: run every scene, print PASS/FAIL, summarize.
run_arc_chat_demo :-
    % The banner.
    nl,
    % The title.
    writeln('=== Acc_426: Causalontology — the runnable core and mentova_arc_agi_3_chat ==='),
    % The subtitle.
    writeln('A human guides Mentova through a locksmith level; every clue is a grounded assertion.'),
    % A blank line.
    nl,
    % Attach the chat database in a scratch directory.
    make_directory_path('/tmp/mentova_arc_chat_demo'),
    % The database.
    ma_db_init('/tmp/mentova_arc_chat_demo/chat_db'),
    % Scene one: the verbatim runnable core.
    scene_runnable_core(A1),
    % Scene two: the grounding table.
    scene_grounding(A2),
    % Scene three: refusals.
    scene_refusals(A3),
    % Scenes four to seven: the guided run.
    scene_guided_run(A4, A5, A6, A7),
    % Scene eight: the HTTP application.
    scene_http(A8),
    % Gather the results.
    ACs = [A1, A2, A3, A4, A5, A6, A7, A8],
    % Print each.
    forall(member(AC, ACs), print_ac(AC)),
    % The tally.
    summarize(ACs).

% ---------------------------------------------------------------------------
% SCENE ONE — the verbatim Appendix A core, in a subprocess
% ---------------------------------------------------------------------------

% scene_runnable_core(-AC): the specification's own acceptance artifact.
scene_runnable_core(ac('AC-ACC426-001', Pass, 'the Appendix A runnable core passes its self-checks')) :-
    % Run the verbatim core's self-checks in a fresh SWI-Prolog.
    (   catch(
            % Spawn the subprocess.
            ( process_create(path(swipl),
                             ['-g', run_tests, '-t', halt, 'demos/causalontology_demo.pl'],
                             [stdout(pipe(Out))]),
              % Read its whole output.
              read_all_lines(Out, Lines),
              % Close the pipe.
              close(Out),
              % The verbatim core reports success in these words.
              memberchk("  all checks passed.", Lines) ),
            % Any failure fails the scene.
            _, fail)
    % The core passed.
    ->  Pass = true
    % Otherwise it failed.
    ;   Pass = false
    ).

% read_all_lines(+Stream, -Lines): read every line of a stream.
read_all_lines(Stream, Lines) :-
    % Read the next line.
    read_line_to_string(Stream, Line),
    % Stop at end of file.
    (   Line == end_of_file
    % Done.
    ->  Lines = []
    % Keep the line and continue.
    ;   Lines = [Line | Rest],
        % The rest.
        read_all_lines(Stream, Rest)
    ).

% ---------------------------------------------------------------------------
% SCENE TWO — the clue-grounding table of Section 10.4
% ---------------------------------------------------------------------------

% scene_grounding(-AC): every clue grounds to its specified assertion.
scene_grounding(ac('AC-ACC426-002', Pass, 'every clue of the Section 10.4 table grounds correctly')) :-
    % Check each row of the table.
    (   co_ground('That looks like a key', [2, 2], hint_label([2, 2], key_like)),
        % The lock row.
        co_ground('that looks like a lock', [0, 4], hint_label([0, 4], lock_like)),
        % The door row, which also sets the goal.
        co_ground('That looks like a door. Let''s walk through it', [0, 4],
                  hint_goal([0, 4], traverse)),
        % The pickup suggestion.
        co_ground('Pick that up', [2, 2], hint_action(action(pickup))),
        % The hazard declaration.
        co_ground('Don''t touch that', [3, 3], hint_preventive([3, 3])),
        % The reinforcement.
        co_ground('Good, that worked', none, hint_reinforce),
        % The encouragement.
        co_ground('keep going', none, hint_continue)
    % All rows ground.
    ->  Pass = true
    % Otherwise the table is broken.
    ;   Pass = false
    ).

% ---------------------------------------------------------------------------
% SCENE THREE — refusals
% ---------------------------------------------------------------------------

% scene_refusals(-AC): ungroundable and unsafe clue texts are refused.
scene_refusals(ac('AC-ACC426-003', Pass, 'ungroundable and unsafe clue texts are refused')) :-
    % Both refusals must hold.
    (   \+ co_ground('the weather is nice today', none, _),
        % The safety check declines harmful text.
        \+ mentova_arc_chat:ma_hint_safe('go kill it')
    % Both refused.
    ->  Pass = true
    % Otherwise a refusal failed.
    ;   Pass = false
    ).

% ---------------------------------------------------------------------------
% SCENES FOUR TO SEVEN — the guided run
% ---------------------------------------------------------------------------

% scene_guided_run(-A4, -A5, -A6, -A7): clues in, victory out.
scene_guided_run(ac('AC-ACC426-004', P4, 'clues label, attach a disposition, set the goal, and enforce the hazard'),
                 ac('AC-ACC426-005', P5, 'the guided run wins the locksmith level within budget'),
                 ac('AC-ACC426-006', P6, 'the why reports the last action as guided by the human'),
                 ac('AC-ACC426-007', P7, 'reinforcement raises the strength of the last relations')) :-
    % A fresh world.
    fresh,
    % The guide's four clues, grounded and injected as the app would.
    forall(member(Text-Ref, ['that looks like a key'-[2, 2],
                             'pick that up'-[2, 2],
                             'don''t touch that'-[3, 3],
                             'that looks like a door. let''s walk through it'-[0, 4]]),
           % Ground and inject each clue.
           ( co_ground(Text, Ref, Assertion), ma_inject(Assertion) )),
    % Every learning is keyed to the selected game, so read its id to check them.
    ma_selected_game(G),
    % The key object's game-keyed id.
    atomic_list_concat([object_, G, '_2_2'], KeyId),
    % The door object's game-keyed id.
    atomic_list_concat([object_, G, '_0_4'], DoorId),
    % Scene four: the clues took hold in the ontology, keyed to this game.
    (   noun_backbone_continuant(KeyId, key_like),
        % The door was labeled.
        noun_backbone_continuant(DoorId, door_like),
        % The key-like object bears a disposition.
        realizable_hinge_realizable(KeyId, disposition, KeyId),
        % The human-declared hazard is enforced like a self-learned one, keyed to the game.
        causal_learning_avoid(g(G, touch(cell(3, 3))))
    % The ontology holds the guidance.
    ->  P4 = true
    % Otherwise it does not.
    ;   P4 = false
    ),
    % Scene five: the guided run wins.
    (   ma_auto(40, won(Steps)),
        % Within the budget.
        Steps =< 40
    % Victory.
    ->  P5 = true
    % Otherwise no victory.
    ;   P5 = false
    ),
    % Scene six: the why names the human guidance.
    (   ma_why(why(_, toward(goal), guided_by_human))
    % The last step headed for the human-set goal.
    ->  P6 = true
    % Otherwise the story is wrong.
    ;   P6 = false
    ),
    % Scene seven: reinforcement raises the last action's relations, keyed to the game.
    (   ma_why(why(LastAction, _, _)),
        % Its current strength (the relation head is keyed to this game).
        causal_core_cro(_, [g(G, LastAction)], _, _, _, S0, _, _),
        % The guide praises the result.
        ma_inject(hint_reinforce),
        % The strength rose.
        causal_core_cro(_, [g(G, LastAction)], _, _, _, S1, _, _),
        % Strictly.
        S1 > S0
    % Reinforcement worked.
    ->  P7 = true
    % Otherwise it did not.
    ;   P7 = false
    ).

% ---------------------------------------------------------------------------
% SCENE EIGHT — the application over HTTP
% ---------------------------------------------------------------------------

% scene_http(-AC): login, hint, control, frame, and why over the wire.
scene_http(ac('AC-ACC426-008', Pass, 'the HTTP application works end to end and refuses bad tokens')) :-
    % A fresh world behind the server.
    fresh,
    % The test port.
    demo_port(Port),
    % Start the server.
    ma_start_server(Port),
    % Run the over-the-wire scenario, always stopping the server after.
    (   catch(http_scenario(Port), _, fail)
    % The scenario held.
    ->  Pass = true
    % Otherwise it failed.
    ;   Pass = false
    ),
    % Stop the server.
    ma_stop_server(Port).

% http_scenario(+Port): the full over-the-wire exchange.
http_scenario(Port) :-
    % A mentor account for the guide, tolerated when it already exists.
    catch(mc_create_mentor(guide_426, secret426), _, true),
    % Authenticate with the account's password.
    mc_authenticate_mentor(guide_426, secret426, MentorId),
    % A session token.
    mc_create_session(MentorId, Token),
    % Reset the game over the wire.
    post_json(Port, '/api/arc/control', _{token: Token, cmd: "reset"}, R1),
    % The reset succeeded.
    R1.ok == true,
    % A bad token is refused.
    post_json(Port, '/api/arc/hint',
              _{token: "bad-token", text: "that looks like a key",
                ref: [2, 2], session_id: "s1"}, RBad),
    % Refused.
    RBad.ok == false,
    % The four clues over the wire, through the real teach queue.
    forall(member(Text-Ref, ["that looks like a key"-[2, 2],
                             "pick that up"-[2, 2],
                             "don't touch that"-[3, 3],
                             "that looks like a door. let's walk through it"-[0, 4]]),
           % Each clue is grounded and accepted.
           ( post_json(Port, '/api/arc/hint',
                       _{token: Token, text: Text, ref: Ref, session_id: "s1"}, RH),
             % Accepted.
             RH.ok == true )),
    % Run the guided episode over the wire.
    post_json(Port, '/api/arc/control', _{token: Token, cmd: "auto", budget: 40}, RA),
    % It ran.
    RA.ok == true,
    % The outcome is a win.
    sub_atom(RA.outcome, 0, _, _, won),
    % The frame endpoint reports the win.
    get_json(Port, '/api/arc/frame', RF),
    % Status won.
    RF.status == "won",
    % The why endpoint names the human guidance.
    get_json(Port, '/api/arc/why', RW),
    % Guided.
    RW.provenance == "guided_by_human".

% post_json(+Port, +Path, +Dict, -Reply): POST JSON to the local server.
post_json(Port, Path, Dict, Reply) :-
    % Compose the URL.
    format(atom(Url), 'http://localhost:~w~w', [Port, Path]),
    % Encode the body.
    with_output_to(string(Body), json_write_dict(current_output, Dict)),
    % Post and read the JSON reply.
    setup_call_cleanup(
        % Open the request.
        http_open(Url, Stream, [post(string('application/json', Body))]),
        % Read the reply.
        json_read_dict(Stream, Reply),
        % Always close.
        close(Stream)).

% get_json(+Port, +Path, -Reply): GET JSON from the local server.
get_json(Port, Path, Reply) :-
    % Compose the URL.
    format(atom(Url), 'http://localhost:~w~w', [Port, Path]),
    % Get and read the JSON reply.
    setup_call_cleanup(
        % Open the request.
        http_open(Url, Stream, []),
        % Read the reply.
        json_read_dict(Stream, Reply),
        % Always close.
        close(Stream)).

% ---------------------------------------------------------------------------
% REPORTING
% ---------------------------------------------------------------------------

% print_ac(+AC): print one acceptance-criterion result line.
print_ac(ac(Id, true, Desc)) :-
    % A passing criterion.
    format('PASS ~w : ~w~n', [Id, Desc]).
% A failing criterion.
print_ac(ac(Id, false, Desc)) :-
    % A failing criterion.
    format('FAIL ~w : ~w~n', [Id, Desc]).

% summarize(+ACs): the final tally.
summarize(ACs) :-
    % Count the passes.
    findall(Id, member(ac(Id, true, _), ACs), Passes),
    % How many passed.
    length(Passes, P),
    % Of how many.
    length(ACs, T),
    % The tally line.
    format('~nAcc_426 demonstration: ~w/~w acceptance criteria PASS~n', [P, T]),
    % The verdict.
    (   P =:= T
    % All green.
    ->  writeln('RESULT: PASS - the Causalontology core runs, and a human guided Mentova to a win, clue by grounded clue.')
    % Something failed.
    ;   writeln('RESULT: FAIL - one or more acceptance criteria did not hold.')
    ).
