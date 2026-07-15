/*  Mentova — mentova_chat Test Suite

    Genuine PLUnit coverage for the Mentova Web Chat server module.

    The module exports two thin HTTP entry points (mc_start_server/1,
    mc_chat_main/2) that wrap a rich glass-box reasoning pipeline:
    content-safety screening, emotional and linguistic prosody detection,
    focus detection, natural-language query parsing, deterministic reply
    execution, prosody-aware reply adaptation, and the /api/why explanation.
    These behavioural tests exercise that pipeline directly (the internal
    predicates, called module-qualified) and then exercise the exported
    mc_start_server/1 end to end over a real HTTP round-trip.

    Run with the full library path (every PrologAI pack plus Mentova src):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_mentova_chat.pl
*/

% Declare this file as a test module with no exports.
:- module(test_mentova_chat, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(mentova_chat)).
% Load the chat database so the HTTP test can initialise persistence.
:- use_module(library(chat_db)).
% Load the HTTP client for the over-the-wire test of the exported server.
:- use_module(library(http/http_open)).
% Load the JSON codec for encoding the request and reading the reply.
:- use_module(library(http/json)).
% Load the threaded HTTP server library for stopping the test server.
:- use_module(library(http/thread_httpd)).

% Open the test block for mentova_chat.
:- begin_tests(mentova_chat).

% AC-MC-001: an unsafe keyword in a message is detected and blocked.
test(unsafe_keyword_is_blocked) :-
    % A message containing a blocked keyword ("kill") is unsafe.
    assertion(mentova_chat:mc_is_unsafe("I want to kill it")),
    % A wholesome question about a bird is not flagged as unsafe.
    assertion(\+ mentova_chat:mc_is_unsafe("What is a canary?")).

% AC-MC-002: emotional prosody is read from affective cues, with neutral default.
test(emotional_prosody_states) :-
    % "i hate" is an anger cue, so the state is angry.
    mentova_chat:mc_detect_emotional_prosody("I hate this", Angry),
    % Confirm the angry classification.
    assertion(Angry == angry),
    % The word "happy" is a happiness cue.
    mentova_chat:mc_detect_emotional_prosody("I am so happy today", Happy),
    % Confirm the happy classification.
    assertion(Happy == happy),
    % A bare question mark signals inquiry, so the state is curious.
    mentova_chat:mc_detect_emotional_prosody("What is a bird?", Curious),
    % Confirm the curious classification.
    assertion(Curious == curious),
    % A statement with no affective cue falls through to neutral.
    mentova_chat:mc_detect_emotional_prosody("the sky is blue", Neutral),
    % Confirm the neutral default.
    assertion(Neutral == neutral).

% AC-MC-003: linguistic prosody returns a four-field dict with speech act,
% certainty, politeness, and inarticulate features.
test(linguistic_prosody_dict) :-
    % A trailing "?" makes the speech act a question.
    mentova_chat:mc_detect_linguistic_prosody("What is a bird?", Q),
    % Read the speech-act field of the question dict.
    get_dict(speech_act, Q, QAct),
    % Confirm it is classified as a question.
    assertion(QAct == question),
    % An imperative opening ("please tell") is a polite command.
    mentova_chat:mc_detect_linguistic_prosody("please tell me about birds", C),
    % Read the speech-act field of the command dict.
    get_dict(speech_act, C, CAct),
    % Confirm the command classification.
    assertion(CAct == command),
    % Read the politeness field of the command dict.
    get_dict(politeness, C, CPol),
    % Confirm the "please" cue marks it polite.
    assertion(CPol == polite).

% AC-MC-004: an ALL-CAPS word signals contrastive focus; ordinary text has none.
test(focus_word_detection) :-
    % The capitalised word "RED" is the focus of the message.
    mentova_chat:mc_detect_focus("I want the RED button", Focus),
    % Confirm the focus word is RED.
    assertion(Focus == "RED"),
    % A message with no capitalised word has an empty focus.
    mentova_chat:mc_detect_focus("no caps here", NoFocus),
    % Confirm the empty-string focus.
    assertion(NoFocus == "").

% AC-MC-005: natural-language messages parse into structured query terms.
test(parse_query_patterns) :-
    % A greeting message parses to the greeting term.
    mentova_chat:mc_parse_query("hello there", G),
    % Confirm the greeting parse.
    assertion(G == greeting),
    % "what is a canary?" parses to a what_is query about the canary.
    mentova_chat:mc_parse_query("what is a canary?", W),
    % Confirm the what_is parse names the subject canary.
    assertion(W == what_is(canary)),
    % "can a bird fly?" parses to a capable_of query about a bird flying.
    mentova_chat:mc_parse_query("can a bird fly?", Cap),
    % Confirm the capable_of parse names the subject and action.
    assertion(Cap == capable_of(bird, fly)),
    % An unrecognised message parses to the unknown term.
    mentova_chat:mc_parse_query("asdf zxcv", U),
    % Confirm the unknown fallback.
    assertion(U == unknown).

% AC-MC-006: deterministic query execution returns the fixed greeting and the
% honest-ignorance reply, each with an empty justification.
test(execute_deterministic_replies) :-
    % Executing a greeting yields the fixed welcome message.
    mentova_chat:mc_execute_query(greeting, GReply, GJust),
    % The greeting reply introduces Mentova.
    assertion(sub_string(GReply, _, _, _, "I am Mentova")),
    % The greeting carries no justification.
    assertion(GJust == ""),
    % Executing an unknown query yields the honest-ignorance reply.
    mentova_chat:mc_execute_query(unknown, UReply, UJust),
    % The unknown reply refuses to guess.
    assertion(sub_string(UReply, _, _, _, "I have not learned that yet")),
    % The unknown reply carries no justification.
    assertion(UJust == "").

% AC-MC-007: prosody adaptation prepends an emotional opener to the reply.
test(adapt_reply_prepends_opener) :-
    % A neutral linguistic dict so only the emotional opener applies.
    Ling = _{speech_act: statement, certainty: neutral, politeness: neutral, inarticulate: none},
    % Adapt a base reply for a sad visitor.
    mentova_chat:mc_adapt_reply_to_prosody("Here is your answer.", sad, Ling, Adapted),
    % The sad opener is prepended ahead of the base reply.
    assertion(sub_string(Adapted, _, _, _, "I am sorry to hear that.")),
    % The original reply text is still present after the opener.
    assertion(sub_string(Adapted, _, _, _, "Here is your answer.")).

% AC-MC-008: the /api/why explanation declines when no reason is available.
test(explain_declines_without_reason) :-
    % An unrecognised query has no justification to show.
    mentova_chat:mc_explain("asdf zxcv", Explanation),
    % The explanation states there is no showable reason.
    assertion(Explanation == "I cannot show you a reason for that, so I should not claim it.").

% AC-MC-009: the exported mc_start_server/1 serves the chat pipeline end to end,
% returning a grounded JSON reply over a real HTTP round-trip.
test(server_serves_chat_over_http,
     [setup(tmc_start_server), cleanup(tmc_stop_server)]) :-
    % The test port the server was started on.
    tmc_port(Port),
    % Compose the local chat endpoint URL.
    format(atom(Url), 'http://localhost:~w/api/chat', [Port]),
    % Encode a safe greeting message as the JSON request body.
    with_output_to(string(Body),
                   json_write_dict(current_output,
                                   _{message: "hello there", session_id: "test-session"})),
    % POST the request and read the JSON reply, always closing the stream.
    setup_call_cleanup(
        % Open the POST request to the running server.
        http_open(Url, Stream, [post(string('application/json', Body))]),
        % Read the JSON reply dict.
        json_read_dict(Stream, Reply),
        % Always close the stream.
        close(Stream)),
    % Read the reply text field from the JSON response.
    get_dict(reply, Reply, ReplyText),
    % The pipeline answered the greeting by introducing Mentova.
    assertion(sub_string(ReplyText, _, _, _, "I am Mentova")),
    % Read the emotional-prosody field from the JSON response.
    get_dict(emotional_prosody, Reply, Emo),
    % A neutral greeting is classified as neutral over the wire.
    assertion(Emo == "neutral").

% Close the test block for mentova_chat.
:- end_tests(mentova_chat).

% ------------------------------------------------------------------
% Test-server helpers for the end-to-end HTTP test
% ------------------------------------------------------------------

% tmc_port/1 is the fixed local port for the test HTTP server.
tmc_port(8237).

% tmc_db_dir/1 is the scratch directory for the test chat database.
tmc_db_dir('/tmp/mentova_chat_test_db').

% tmc_start_server/0 initialises the database and starts the exported server.
tmc_start_server :-
    % Resolve the scratch database directory.
    tmc_db_dir(Dir),
    % Attach (or create) the persistence file under that directory.
    mc_db_init(Dir),
    % Resolve the test port.
    tmc_port(Port),
    % Start the exported HTTP server on the test port.
    mc_start_server(Port).

% tmc_stop_server/0 stops the test HTTP server, tolerating an already-stopped one.
tmc_stop_server :-
    % Resolve the test port.
    tmc_port(Port),
    % Stop the server on that port, ignoring any error if it is already down.
    catch(http_stop_server(Port, []), _, true).
