/*  mentova_chat.pl — Mentova Web Chat HTTP Server

    Text-only, two-tier web chat for Mentova.
    Public visitors may chat and ask "why?".
    Signed-in mentors may propose facts through the review queue.

    Acc_423 — Mentova Web Chat, text-only milestone.

    Usage:
        swipl -l src/mentova/mentova_chat.pl \
              -g "mc_db_init('data/chat_db'), mc_start_server(8080)" \
              -t halt
*/

% Declare this file as the 'mentova_chat' module and export its predicates.
:- module(mentova_chat, [
    % mc_start_server/1 — start the HTTP server on the given port.
    mc_start_server/1,
    % mc_chat_main/2 — convenience: init DB then start server (for -g flag).
    mc_chat_main/2
% Close the export list.
]).

% Load the HTTP server library for creating a multi-threaded HTTP server.
:- use_module(library(http/thread_httpd)).
% Load the HTTP dispatch library for routing URLs to handler predicates.
:- use_module(library(http/http_dispatch)).
% Load the HTTP JSON library for reading and writing JSON bodies.
:- use_module(library(http/http_json)).
% Load the HTTP parameters library for reading URL query parameters.
:- use_module(library(http/http_parameters)).
% Load the static file serving library for assets.
:- use_module(library(http/http_files)).
% Load the uuid library for generating session identifiers.
:- use_module(library(uuid)).
% Load the chat_db module for all persistence operations.
:- use_module('chat_db').
% Load the mentova module for mentova_query/3.
:- use_module('mentova').
% Load the ARC-AGI-3 chat backend so its /arc page and /api/arc/* routes
% (Guided and Solo modes, game selection, solo telemetry, and the attempts
% record) are registered on the running chat server.
:- use_module('mentova_arc_chat').
% Load the two ARC-AGI-3 learning sub-projects that share the chat backend's
% learnings: ARC-AGI-3_Guided (human-in-the-loop) and ARC-AGI-3_Solo (unaided).
:- use_module('arc_agi_3_guided').
% The unaided solo sub-project.
:- use_module('arc_agi_3_solo').
% Load the small_world module for knowledge base predicates.
:- use_module('../../knowledge/small_world').
% Load the elementary curriculum loader: understood facts (word walls and
% CA standards) plus streamed reference-library access to the bulk corpus.
:- use_module('../../knowledge/curriculum/curriculum_lattice').
% Load the ARC-AGI-3 game-knowledge transfer: the 25 mentor guides distilled
% into game-keyed node-facts, Causalontology relations, and J-Space concepts.
:- use_module('arc3_knowledge').
% Load the OODA methodology skill: John Boyd's observe-orient-decide-act loop, held
% in Jacobian Space as a concept Mentova reasons with (it is co_hplan's middle layer).
:- use_module('ooda_knowledge').

% mc_match_pattern/2 clauses are interleaved with helper predicates.
:- discontiguous mc_match_pattern/2.

% ------------------------------------------------------------------
% URL routing table
% ------------------------------------------------------------------

% Route GET / to the public chat index page handler.
:- http_handler(root(.),          mc_handle_index,      [method(get)]).
% Route GET /mentor to the mentor chat page handler.
:- http_handler(root(mentor),     mc_handle_mentor_page,[method(get)]).
% Route GET /assets/... to the static asset file server.
:- http_handler(root(assets),     mc_handle_assets,     [prefix]).
% Route POST /api/chat to the public chat message handler.
:- http_handler(root(api/chat),   mc_handle_chat,       [method(post)]).
% Route GET /api/why to the justification handler.
:- http_handler(root(api/why),    mc_handle_why,        [method(get)]).
% Route POST /api/mentor/login to the mentor login handler.
:- http_handler(root(api/mentor/login),   mc_handle_login,   [method(post)]).
% Route POST /api/mentor/signup to the mentor sign-up handler.
:- http_handler(root(api/mentor/signup),  mc_handle_signup,  [method(post)]).
% Route POST /api/mentor/logout to the mentor logout handler.
:- http_handler(root(api/mentor/logout),  mc_handle_logout,  [method(post)]).
% Route POST /api/mentor/teach to the mentor teach handler.
:- http_handler(root(api/mentor/teach),   mc_handle_teach,   [method(post)]).
% Route POST /api/mentor/approve to the mentor approve handler.
:- http_handler(root(api/mentor/approve), mc_handle_approve, [method(post)]).
% Route GET /api/mentor/queue to the review queue list handler.
:- http_handler(root(api/mentor/queue),   mc_handle_queue,   [method(get)]).

% ------------------------------------------------------------------
% mc_start_server/1 — start the HTTP server
% ------------------------------------------------------------------

% mc_start_server(+Port) starts the HTTP server listening on Port.
mc_start_server(Port) :-
    % Print a startup message to standard output.
    format('Mentova Chat Server starting on port ~w~n', [Port]),
    % Start the multi-threaded HTTP server on the given port.
    http_server(http_dispatch, [port(Port)]).

% mc_chat_main(+DataDir, +Port) initialises the database and starts the server.
% This is the convenience entry point for the -g flag, visible in user module.
mc_chat_main(DataDir, Port) :-
    % Initialise the persistence layer first.
    mc_db_init(DataDir),
    % Attach and reload the durable per-game ARC learnings (guarded so a read
    % hiccup never blocks startup) — wins concluded before a restart come back.
    catch(ma_learn_attach(DataDir), _, true),
    % Import the elementary curriculum (guarded so it can never crash startup):
    % register its reference-library sources and anchor its understood facts.
    catch(ci_chat_bootstrap, _CurriculumError, true),
    % Transfer the ARC-AGI-3 game knowledge (the 25 guides) into the mind, so
    % both Guided and Solo know each game's objects, relations, and hazards.
    catch(a3_bootstrap, _Arc3Error, true),
    % Hold the OODA methodology in Jacobian Space as a skill — the observe-orient-
    % decide-act loop that is the middle layer of every plan Mentova builds.
    catch(ooda_bootstrap, _OodaError, true),
    % Then start the HTTP server on the requested port.
    mc_start_server(Port).

% ------------------------------------------------------------------
% Static page handlers
% ------------------------------------------------------------------

% mc_handle_index/1 serves the public chat index page.
mc_handle_index(Request) :-
    % Resolve the path to the assets/chat/index.html file.
    mc_asset_file('chat/index.html', FilePath),
    % Serve the file; unsafe(true) allows absolute paths outside aliases.
    http_reply_file(FilePath, [unsafe(true)], Request).

% mc_handle_mentor_page/1 serves the mentor chat page.
mc_handle_mentor_page(Request) :-
    % Resolve the path to the assets/chat/mentor.html file.
    mc_asset_file('chat/mentor.html', FilePath),
    % Serve the file; unsafe(true) allows absolute paths outside aliases.
    http_reply_file(FilePath, [unsafe(true)], Request).

% mc_handle_assets/1 serves static assets from the assets/ directory.
mc_handle_assets(Request) :-
    % Resolve the absolute assets directory.
    mc_assets_dir(AssetsDir),
    % Extract the path after the /assets prefix.
    memberchk(path_info(PathInfo), Request),
    % Build the full absolute file path.
    atom_concat(AssetsDir, PathInfo, FilePath),
    % Serve the file; unsafe(true) allows absolute paths outside registered aliases.
    http_reply_file(FilePath, [unsafe(true)], Request).

% ------------------------------------------------------------------
% Asset path helpers
% ------------------------------------------------------------------

% mc_asset_file(+Relative, -AbsPath) resolves a path under assets/.
mc_asset_file(Relative, AbsPath) :-
    % Find the absolute path of this source file.
    source_file(mc_start_server(_), ThisFile),
    % Compute the Mentova repo root (three levels up from src/mentova/).
    file_directory_name(ThisFile, SrcMentova),
    file_directory_name(SrcMentova, Src),
    file_directory_name(Src, Root),
    % Build the full path to the asset file.
    atomic_list_concat([Root, '/assets/', Relative], AbsPath).

% mc_assets_dir(-AbsDir) resolves the assets/ directory.
mc_assets_dir(AbsDir) :-
    % Find the absolute path of this source file.
    source_file(mc_start_server(_), ThisFile),
    % Navigate up to the repo root.
    file_directory_name(ThisFile, SrcMentova),
    file_directory_name(SrcMentova, Src),
    file_directory_name(Src, Root),
    % Build the path to the assets directory.
    atomic_list_concat([Root, '/assets'], AbsDir).

% ------------------------------------------------------------------
% POST /api/chat — public chat endpoint
% ------------------------------------------------------------------

% mc_handle_chat/1 processes a public visitor chat message.
mc_handle_chat(Request) :-
    % Read the JSON body from the request.
    http_read_json_dict(Request, Body),
    % Extract the message text from the JSON body.
    _{message: MsgStr, session_id: SessionStr} :< Body,
    % Convert strings to atoms for Prolog processing.
    atom_string(Msg, MsgStr),
    atom_string(SessionId, SessionStr),
    % Log the incoming visitor message.
    mc_log_message(SessionId, public, person, Msg),
    % Check the message for unsafe content.
    (   mc_is_unsafe(Msg)
    ->  % Reply with the safety decline message; skip prosody adaptation.
        Reply = "That is not something I can talk about. If something is bothering you, please talk with a trusted adult.",
        Justification = "",
        EmotionalProsody = neutral,
        LinguisticProsody = _{speech_act:statement, certainty:neutral, politeness:neutral, inarticulate:none},
        FocusWord = ""
    ;   % Detect emotional prosody (affective state from text cues).
        mc_detect_emotional_prosody(Msg, EmotionalProsody),
        % Detect linguistic prosody (speech-act type, certainty, politeness, inarticulate).
        mc_detect_linguistic_prosody(Msg, LinguisticProsody),
        % Detect focus word (ALL-CAPS contrastive or narrow focus).
        mc_detect_focus(Msg, FocusWord),
        % Query the Mentova mind for a grounded answer.
        mc_build_reply(Msg, Reply0, Justification),
        % Adapt the reply to the detected prosody signals.
        mc_adapt_reply_to_prosody(Reply0, EmotionalProsody, LinguisticProsody, Reply)
    ),
    % Log Mentova's reply.
    atom_string(ReplyAtom, Reply),
    mc_log_message(SessionId, public, mentova, ReplyAtom),
    % Send the JSON response to the browser.
    reply_json_dict(_{
        reply:              Reply,
        justification:      Justification,
        focus_word:         FocusWord,
        emotional_prosody:  EmotionalProsody,
        linguistic_prosody: LinguisticProsody
    }).

% ------------------------------------------------------------------
% GET /api/why — justification endpoint
% ------------------------------------------------------------------

% mc_handle_why/1 returns the justification for a Mentova answer.
mc_handle_why(Request) :-
    % Extract the query parameter from the URL.
    http_parameters(Request, [query(QueryStr, [])]),
    % Convert the query string to an atom.
    atom_string(Query, QueryStr),
    % Build the justification text for this query.
    mc_explain(Query, Explanation),
    % Return the explanation as JSON.
    reply_json_dict(_{explanation: Explanation}).

% ------------------------------------------------------------------
% POST /api/mentor/login — mentor authentication
% ------------------------------------------------------------------

% mc_handle_login/1 authenticates a mentor and returns a session token.
mc_handle_login(Request) :-
    % Read the JSON body from the request.
    http_read_json_dict(Request, Body),
    % Extract username and password from the JSON body.
    _{username: UserStr, password: PassStr} :< Body,
    % Convert to atoms.
    atom_string(Username, UserStr),
    atom_string(Password, PassStr),
    % Attempt authentication.
    (   mc_authenticate_mentor(Username, Password, MentorId)
    ->  % Create a session token for the authenticated mentor.
        mc_create_session(MentorId, Token),
        % Record the successful login in the audit log.
        mc_audit(mentor_login, Username, Username),
        % Return the token to the browser.
        atom_string(Token, TokenStr),
        reply_json_dict(_{ok: true, token: TokenStr})
    ;   % Return an authentication failure response.
        reply_json_dict(_{ok: false, error: "Invalid username or password."})
    ).

% ------------------------------------------------------------------
% POST /api/mentor/signup — self-serve mentor account creation
% ------------------------------------------------------------------

% mc_handle_signup/1 creates a mentor account and returns a session token so
% the new mentor is signed in immediately. Sign-up can be turned off for a
% public deployment by setting the environment variable MENTOVA_DISABLE_SIGNUP
% to true.
mc_handle_signup(Request) :-
    % Read the JSON body from the request.
    http_read_json_dict(Request, Body),
    % Extract username and password.
    _{username: UserStr, password: PassStr} :< Body,
    % Convert to atoms.
    atom_string(Username, UserStr),
    atom_string(Password, PassStr),
    % Compute the result and reply.
    mc_signup_result(Username, Password, UserStr, Reply),
    reply_json_dict(Reply).

% mc_signup_result(+Username, +Password, +UserStr, -Reply): the sign-up outcome.
% Sign-up is disabled by the environment.
mc_signup_result(_, _, _, _{ok: false, error: "Sign-up is disabled on this server."}) :-
    getenv('MENTOVA_DISABLE_SIGNUP', V), downcase_atom(V, VL), VL == true, !.
% A missing username or password is rejected.
mc_signup_result(U, P, _, _{ok: false, error: "Username and password are required."}) :-
    ( U == '' ; P == '' ), !.
% Too-short passwords are rejected.
mc_signup_result(_, P, _, _{ok: false, error: "Password must be at least four characters."}) :-
    atom_length(P, L), L < 4, !.
% Otherwise create the account; a duplicate username is reported honestly, and
% any other failure surfaces its real reason rather than being mislabelled.
mc_signup_result(U, P, UserStr, Reply) :-
    % Create the mentor account, catching any error.
    catch(mc_create_mentor(U, P), Err, true),
    (   var(Err)
    % Created: sign the new mentor in and return the token.
    ->  mc_authenticate_mentor(U, P, MentorId),
        mc_create_session(MentorId, Token),
        atom_string(Token, TokenStr),
        Reply = _{ok: true, username: UserStr, token: TokenStr}
    % A genuine duplicate username.
    ;   Err = error(duplicate_mentor(_), _)
    ->  Reply = _{ok: false, error: "That username is already taken."}
    % Any other failure: report the real reason.
    ;   term_string(Err, ErrStr),
        string_concat("Could not create the account: ", ErrStr, Msg),
        Reply = _{ok: false, error: Msg}
    ).

% ------------------------------------------------------------------
% POST /api/mentor/logout — mentor sign-out
% ------------------------------------------------------------------

% mc_handle_logout/1 revokes a mentor session token.
mc_handle_logout(Request) :-
    % Read the JSON body from the request.
    http_read_json_dict(Request, Body),
    % Extract the token from the JSON body.
    _{token: TokenStr} :< Body,
    % Convert token to atom.
    atom_string(Token, TokenStr),
    % Attempt to revoke the session.
    (   mc_revoke_session(Token)
    ->  reply_json_dict(_{ok: true})
    ;   reply_json_dict(_{ok: false, error: "Session not found."})
    ).

% ------------------------------------------------------------------
% POST /api/mentor/teach — propose a new fact
% ------------------------------------------------------------------

% mc_handle_teach/1 places a proposed fact on the review queue.
mc_handle_teach(Request) :-
    % Read the JSON body from the request.
    http_read_json_dict(Request, Body),
    % Extract token, fact, and session_id from the JSON body.
    _{token: TokenStr, fact: FactStr, session_id: SessionStr} :< Body,
    % Convert to atoms.
    atom_string(Token, TokenStr),
    atom_string(FactAtom, FactStr),
    atom_string(SessionId, SessionStr),
    % Verify the mentor session is valid.
    (   mc_verify_session(Token, MentorId)
    ->  % Place the proposal on the review queue.
        mc_propose_fact(FactAtom, MentorId, SessionId, QueueId),
        % Return the queue entry ID to the browser.
        reply_json_dict(_{ok: true, queue_id: QueueId})
    ;   % Return an authentication error.
        reply_json_dict(_{ok: false, error: "Not signed in."})
    ).

% ------------------------------------------------------------------
% POST /api/mentor/approve — approve a queued proposal
% ------------------------------------------------------------------

% mc_handle_approve/1 approves a proposal and stores the fact.
mc_handle_approve(Request) :-
    % Read the JSON body from the request.
    http_read_json_dict(Request, Body),
    % Extract token and queue_id from the JSON body.
    _{token: TokenStr, queue_id: QueueId} :< Body,
    % Convert token to atom.
    atom_string(Token, TokenStr),
    % Verify the mentor session is valid.
    (   mc_verify_session(Token, ApproverId)
    ->  % Approve the queued proposal.
        (   mc_approve_fact(QueueId, ApproverId)
        ->  reply_json_dict(_{ok: true})
        ;   reply_json_dict(_{ok: false, error: "Proposal not found or already decided."})
        )
    ;   reply_json_dict(_{ok: false, error: "Not signed in."})
    ).

% ------------------------------------------------------------------
% GET /api/mentor/queue — list pending proposals
% ------------------------------------------------------------------

% mc_handle_queue/1 returns the list of pending review queue entries.
mc_handle_queue(Request) :-
    % Extract the token from the query parameters.
    http_parameters(Request, [token(TokenStr, [])]),
    % Convert to atom.
    atom_string(Token, TokenStr),
    % Verify the mentor session.
    (   mc_verify_session(Token, _MentorId)
    ->  % Retrieve all pending proposals.
        mc_pending_proposals(Proposals),
        % Convert each proposal to a JSON-friendly dict.
        maplist(mc_proposal_to_dict, Proposals, PropDicts),
        % Return the list as JSON.
        reply_json_dict(_{ok: true, proposals: PropDicts})
    ;   reply_json_dict(_{ok: false, error: "Not signed in."})
    ).

% mc_proposal_to_dict/2 converts a proposal term to a JSON dict.
mc_proposal_to_dict(entry(Id, Fact, MentorId, Created), Dict) :-
    % Build a dict from the proposal fields.
    Dict = _{id: Id, fact: Fact, mentor_id: MentorId, created_at: Created}.

% ------------------------------------------------------------------
% Content safety check
% ------------------------------------------------------------------

% mc_unsafe_keywords/1 provides the list of blocked keyword atoms.
mc_unsafe_keywords([
    kill, murder, suicide, sex, porn, nude, naked,
    bomb, weapon, hack, drugs, rape, violent, abuse
]).

% mc_is_unsafe/1 succeeds if the message contains an unsafe keyword.
mc_is_unsafe(Msg) :-
    % Normalise the message to lower-case for matching.
    string_lower(Msg, Lower),
    % Retrieve the list of unsafe keywords.
    mc_unsafe_keywords(Keywords),
    % Check whether any keyword appears in the lower-cased message.
    member(Kw, Keywords),
    atom_string(Kw, KwStr),
    sub_string(Lower, _, _, _, KwStr),
    !.

% ------------------------------------------------------------------
% Prosody detection
% ------------------------------------------------------------------

% ------------------------------------------------------------------
% PROSODY DETECTION
% Two major categories: Emotional (affective) and Linguistic.
% Reference: types_of_prosody.txt
% ------------------------------------------------------------------

% mc_detect_focus/2 — focus and accent prosody (narrow/contrastive focus).
% An ALL-CAPS word signals contrastive or narrow focus in written text.
mc_detect_focus(Msg, FocusWord) :-
    % Split the message into whitespace-delimited words.
    atomic_list_concat(Words, ' ', Msg),
    % Find the first word that is entirely upper-case and at least 2 chars.
    (   member(W, Words),
        atom_length(W, Len),
        Len >= 2,
        upcase_atom(W, W),
        % Exclude single-letter pronouns that are always capitalised.
        \+ member(W, ['I', 'A'])
    ->  atom_string(W, FocusWord)
    ;   FocusWord = ""
    ).

% mc_detect_emotional_prosody/2 — affective prosody (8 states + neutral).
% States: angry, fearful, disgusted, surprised, sad, happy, excited, curious, neutral.
% Higher-priority states are checked first; neutral is the default.
mc_detect_emotional_prosody(Msg, State) :-
    % Convert to lower-case for keyword matching.
    string_lower(Msg, L),
    % Angry: multiple "!" marks, angry keywords, or rage emoji.
    (   (   sub_string(L, _, _, _, "!!!")
        ;   sub_string(L, _, _, _, " angry")
        ;   sub_string(L, _, _, _, " furious")
        ;   sub_string(L, _, _, _, " hate ")
        ;   sub_string(L, _, _, _, "i hate")
        ;   sub_string(L, _, _, _, " mad ")
        ;   sub_string(L, _, _, _, "so mad")
        ;   sub_string(L, _, _, _, "😡")
        ;   sub_string(L, _, _, _, "🤬")
        )
    ->  State = angry
    % Fearful: fear and worry keywords.
    ;   (   sub_string(L, _, _, _, "scared")
        ;   sub_string(L, _, _, _, "afraid")
        ;   sub_string(L, _, _, _, "terrified")
        ;   sub_string(L, _, _, _, "frightened")
        ;   sub_string(L, _, _, _, "worried")
        ;   sub_string(L, _, _, _, "please help")
        ;   sub_string(L, _, _, _, "😨")
        ;   sub_string(L, _, _, _, "😱")
        )
    ->  State = fearful
    % Disgusted: disgust keywords and emoji.
    ;   (   sub_string(L, _, _, _, "ugh")
        ;   sub_string(L, _, _, _, "eww")
        ;   sub_string(L, _, _, _, "gross")
        ;   sub_string(L, _, _, _, "disgusting")
        ;   sub_string(L, _, _, _, "horrible")
        ;   sub_string(L, _, _, _, "🤮")
        ;   sub_string(L, _, _, _, "🤢")
        )
    ->  State = disgusted
    % Surprised: surprise keywords and emoji.
    ;   (   sub_string(L, _, _, _, "wow")
        ;   sub_string(L, _, _, _, "whoa")
        ;   sub_string(L, _, _, _, "oh my")
        ;   sub_string(L, _, _, _, "omg")
        ;   sub_string(L, _, _, _, "no way")
        ;   sub_string(L, _, _, _, "😮")
        ;   sub_string(L, _, _, _, "😲")
        )
    ->  State = surprised
    % Sad: sadness keywords and emoji.
    ;   (   sub_string(L, _, _, _, "sad")
        ;   sub_string(L, _, _, _, "miss ")
        ;   sub_string(L, _, _, _, "lonely")
        ;   sub_string(L, _, _, _, ":(")
        ;   sub_string(L, _, _, _, "depressed")
        ;   sub_string(L, _, _, _, "😢")
        ;   sub_string(L, _, _, _, "😞")
        ;   sub_string(L, _, _, _, "😭")
        )
    ->  State = sad
    % Happy: happiness keywords and emoji.
    ;   (   sub_string(L, _, _, _, ":)")
        ;   sub_string(L, _, _, _, "😊")
        ;   sub_string(L, _, _, _, "😄")
        ;   sub_string(L, _, _, _, "happy")
        ;   sub_string(L, _, _, _, "great!")
        ;   sub_string(L, _, _, _, "love it")
        ;   sub_string(L, _, _, _, "thank you")
        ;   sub_string(L, _, _, _, "thanks!")
        )
    ->  State = happy
    % Excited: single exclamation mark (without angry context already caught).
    ;   sub_string(L, _, _, _, "!")
    ->  State = excited
    % Curious: question mark signals inquiry.
    ;   sub_string(L, _, _, _, "?")
    ->  State = curious
    % Neutral: no detectable affective cue.
    ;   State = neutral
    ).

% mc_detect_linguistic_prosody/2 — linguistic prosody (four features).
% Returns a dict: speech_act, certainty, politeness, inarticulate.
mc_detect_linguistic_prosody(Msg, LP) :-
    % Work in lower-case for all keyword checks.
    string_lower(Msg, L),
    % -- Speech act type --
    % Question: ends with "?" after trimming punctuation.
    (   sub_string(L, _, _, _, "?")
    ->  SA = question
    % Command: starts with an imperative verb, or "please" then a verb.
    ;   (   sub_string(L, 0, _, _, "tell ")
        ;   sub_string(L, 0, _, _, "show ")
        ;   sub_string(L, 0, _, _, "explain ")
        ;   sub_string(L, 0, _, _, "describe ")
        ;   sub_string(L, 0, _, _, "give ")
        ;   sub_string(L, 0, _, _, "list ")
        ;   sub_string(L, 0, _, _, "define ")
        ;   sub_string(L, 0, _, _, "name ")
        ;   sub_string(L, 0, _, _, "please tell")
        ;   sub_string(L, 0, _, _, "please show")
        ;   sub_string(L, 0, _, _, "please explain")
        ;   sub_string(L, 0, _, _, "please describe")
        ;   sub_string(L, 0, _, _, "please give")
        ;   sub_string(L, 0, _, _, "please list")
        ;   sub_string(L, 0, _, _, "please define")
        ;   sub_string(L, 0, _, _, "please name")
        )
    ->  SA = command
    % Statement: default.
    ;   SA = statement
    ),
    % -- Certainty --
    (   (   sub_string(L, _, _, _, "definitely")
        ;   sub_string(L, _, _, _, "certainly")
        ;   sub_string(L, _, _, _, "absolutely")
        ;   sub_string(L, _, _, _, "i know")
        ;   sub_string(L, _, _, _, "i'm sure")
        ;   sub_string(L, _, _, _, "no doubt")
        )
    ->  Cert = certain
    ;   (   sub_string(L, _, _, _, "maybe")
        ;   sub_string(L, _, _, _, "perhaps")
        ;   sub_string(L, _, _, _, "i think")
        ;   sub_string(L, _, _, _, "i wonder")
        ;   sub_string(L, _, _, _, "not sure")
        ;   sub_string(L, _, _, _, "i'm not")
        ;   sub_string(L, _, _, _, "could be")
        )
    ->  Cert = uncertain
    ;   Cert = neutral
    ),
    % -- Politeness --
    (   (   sub_string(L, _, _, _, "please")
        ;   sub_string(L, _, _, _, "thank you")
        ;   sub_string(L, _, _, _, "thanks")
        ;   sub_string(L, _, _, _, "could you")
        ;   sub_string(L, _, _, _, "would you")
        ;   sub_string(L, _, _, _, "if you don't mind")
        )
    ->  Pol = polite
    ;   Pol = neutral
    ),
    % -- Inarticulate prosody: filler sounds signal thinking or hesitation --
    (   sub_string(L, _, _, _, "mm-hmm")
    ->  Inar = mmhmm
    ;   sub_string(L, _, _, _, "uh-huh")
    ->  Inar = uhhuh
    ;   (sub_string(L, 0, _, _, "hmm") ; sub_string(L, 0, _, _, "hm ") ; sub_string(L, 0, _, _, "hm."))
    ->  Inar = hmm
    ;   (sub_string(L, 0, _, _, "um") ; sub_string(L, 0, _, _, "um,"))
    ->  Inar = um
    ;   (sub_string(L, 0, _, _, "uh") ; sub_string(L, 0, _, _, "uh,"))
    ->  Inar = uh
    ;   Inar = none
    ),
    % Build the linguistic prosody dict.
    LP = _{speech_act: SA, certainty: Cert, politeness: Pol, inarticulate: Inar}.

% mc_adapt_reply_to_prosody/4 — prepend a brief prosody-aware opener.
% The opener acknowledges the visitor's detected emotional or linguistic state.
mc_adapt_reply_to_prosody(Reply0, EmotionalProsody, LinguisticProsody, Reply) :-
    % Derive an opener from the emotional state.
    mc_emotional_opener(EmotionalProsody, EOpener),
    % Derive an opener from the linguistic state.
    mc_linguistic_opener(LinguisticProsody, LOpener),
    % Combine openers (emotional takes precedence if non-empty).
    (   EOpener \= ""
    ->  Opener = EOpener
    ;   Opener = LOpener
    ),
    % Prepend the opener to the reply if it is non-empty.
    (   Opener \= ""
    ->  format(string(Reply), "~w ~w", [Opener, Reply0])
    ;   Reply = Reply0
    ).

% mc_emotional_opener/2 — opener phrase for each emotional prosody state.
mc_emotional_opener(angry,     "I can hear that this matters to you.").
mc_emotional_opener(fearful,   "You can ask me anything here safely.").
mc_emotional_opener(disgusted, "I understand that feeling.").
mc_emotional_opener(surprised, "That can be surprising!").
mc_emotional_opener(sad,       "I am sorry to hear that.").
mc_emotional_opener(happy,     "I am glad!").
mc_emotional_opener(excited,   "").
mc_emotional_opener(curious,   "").
mc_emotional_opener(neutral,   "").

% mc_linguistic_opener/2 — opener phrase for linguistic prosody features.
mc_linguistic_opener(LP, Opener) :-
    % Inarticulate fillers signal thinking or hesitation.
    (   get_dict(inarticulate, LP, Inar),
        Inar \= none
    ->  Opener = "Take your time."
    % Uncertain certainty signals hesitation.
    ;   get_dict(certainty, LP, uncertain)
    ->  Opener = "That is a thoughtful question."
    % Polite requests deserve a polite acknowledgment.
    ;   get_dict(politeness, LP, polite)
    ->  Opener = "Of course."
    ;   Opener = ""
    ).

% ------------------------------------------------------------------
% Natural-language query parsing and reply building
% ------------------------------------------------------------------

% mc_build_reply/3 builds a reply and justification for a message.
mc_build_reply(Msg, Reply, Justification) :-
    % Parse the message into a structured query term.
    mc_parse_query(Msg, QueryTerm),
    % Execute the query and build the reply.
    mc_execute_query(QueryTerm, Reply, Justification).

% mc_parse_query/2 maps natural language patterns to query terms.
mc_parse_query(Msg, Query) :-
    % Normalise message to lower-case for pattern matching.
    string_lower(Msg, Lower),
    % Try each pattern in order until one matches.
    (   mc_match_pattern(Lower, Query) -> true
    ;   Query = unknown
    ).

% mc_match_pattern/2 tries to match the lowercased message to a query term.

% Match greetings: hello, hi, hey, good morning/afternoon/evening, howdy.
mc_match_pattern(Lower, greeting) :-
    % Check whether the message begins with or contains a greeting word.
    (   sub_string(Lower, 0, _, _, "hello")
    ;   sub_string(Lower, 0, _, _, "hi ")
    ;   Lower = "hi"
    ;   sub_string(Lower, 0, _, _, "hey")
    ;   sub_string(Lower, 0, _, _, "good morning")
    ;   sub_string(Lower, 0, _, _, "good afternoon")
    ;   sub_string(Lower, 0, _, _, "good evening")
    ;   sub_string(Lower, 0, _, _, "howdy")
    ), !.

mc_match_pattern(Lower, is_a(Subject, Object)) :-
    % Require "is a " or "is an " so that "That is great!" does not fire this rule.
    (sub_string(Lower, _, _, _, "is a ") ; sub_string(Lower, _, _, _, "is an ")),
    split_string(Lower, " \t\n?.!,", " \t\n?.!,", AllWords),
    include([P]>>(P \= ""), AllWords, Words),
    % Remove leading "is" (and optionally "a" or "an" as article for subject).
    mc_isa_words(Words, Subject, Object).

% mc_isa_words/3 extracts subject and object from the word list after removing "is".
mc_isa_words(Words, Subject, Object) :-
    % Drop any leading "is", then skip articles "a" and "an" for subject.
    ( Words = ["is"|R1] ; Words = [_,"is"|R1] ),
    mc_skip_article(R1, [SubjectStr|R2]),
    atom_string(Subject, SubjectStr),
    % Skip article before object word.
    mc_skip_article(R2, [ObjectStr|_]),
    ObjectStr \= "",
    atom_string(Object, ObjectStr).
% Match "what is a X?" or "what is X?" patterns — skip article after "what is".
mc_match_pattern(Lower, what_is(Subject)) :-
    sub_string(Lower, _, _, _, "what is"),
    split_string(Lower, " \t\n?.!,", " \t\n?.!,", AllW),
    include([P]>>(P \= ""), AllW, Words),
    mc_what_is_words(Words, Subject).

% mc_what_is_words extracts subject after "what", "is", skipping articles.
mc_what_is_words(Words, Subject) :-
    % Drop words until after "is".
    append(_, ["is"|After], Words),
    mc_skip_article(After, [SubjectStr|_]),
    SubjectStr \= "",
    atom_string(Subject, SubjectStr).

% Match "can a X Y?" or "can X Y?" patterns — skip article after "can".
mc_match_pattern(Lower, capable_of(Subject, Action)) :-
    sub_string(Lower, _, _, _, "can "),
    split_string(Lower, " \t\n?.!,", " \t\n?.!,", AllW),
    include([P]>>(P \= ""), AllW, Words),
    mc_can_words(Words, Subject, Action).

% mc_can_words extracts subject and action after "can", skipping articles.
mc_can_words(Words, Subject, Action) :-
    % Drop words until after "can".
    append(_, ["can"|After], Words),
    mc_skip_article(After, [SubjectStr|Rest]),
    SubjectStr \= "",
    atom_string(Subject, SubjectStr),
    % Skip "do", "does", "be" etc. if present before action.
    mc_skip_aux(Rest, [ActionStr|_]),
    ActionStr \= "",
    atom_string(Action, ActionStr).

% mc_skip_aux/2 skips common auxiliary words before the action.
mc_skip_aux(["do"|Rest], Rest) :- !.
% Skip "does" auxiliary word.
mc_skip_aux(["does"|Rest], Rest) :- !.
% Skip "be" auxiliary word.
mc_skip_aux(["be"|Rest], Rest) :- !.
% No auxiliary to skip.
mc_skip_aux(List, List).

% Match "what can X do?" patterns — skip article after "can".
mc_match_pattern(Lower, what_can(Subject)) :-
    sub_string(Lower, _, _, _, "what can"),
    split_string(Lower, " \t\n?.!,", " \t\n?.!,", AllW),
    include([P]>>(P \= ""), AllW, Words),
    append(_, ["can"|After], Words),
    mc_skip_article(After, [SubjectStr|_]),
    SubjectStr \= "",
    atom_string(Subject, SubjectStr).
% Match "does X cause Y?" or "why does X cause Y?" patterns.
mc_match_pattern(Lower, causes(Cause, Effect)) :-
    sub_string(Lower, _, _, _, "cause"),
    atomic_list_concat(Parts, 'cause', Lower),
    Parts = [Before, After|_],
    mc_extract_last_word(Before, Cause),
    mc_extract_first_word(After, Effect).
% Match "what does X have?" or "what properties does X have?" patterns.
mc_match_pattern(Lower, properties_of(Subject)) :-
    sub_string(Lower, _, _, _, "propert"),
    atomic_list_concat(Parts, 'propert', Lower),
    Parts = [Before|_],
    mc_extract_last_word(Before, Subject).

% mc_extract_first_word/2 extracts the first non-empty word from a string.
mc_extract_first_word(Str, Word) :-
    % Split on spaces and punctuation.
    split_string(Str, " \t\n?.!", " \t\n?.!", Parts),
    % Find the first non-empty part.
    member(P, Parts),
    P \= "",
    !,
    % Convert to atom.
    atom_string(Word, P).

% mc_extract_last_word/2 extracts the last non-empty word from a string.
mc_extract_last_word(Str, Word) :-
    % Split on spaces and punctuation.
    split_string(Str, " \t\n?.!", " \t\n?.!", Parts),
    % Find all non-empty parts.
    include([P]>>(P \= ""), Parts, NonEmpty),
    % Get the last one.
    last(NonEmpty, P),
    !,
    atom_string(Word, P).

% mc_skip_article/2 skips "a" or "an" at the head of a word list.
mc_skip_article(["a"|Rest], Rest) :- !.
% Skip "an" article at head of word list.
mc_skip_article(["an"|Rest], Rest) :- !.
% If no article, return the list unchanged.
mc_skip_article(List, List).

% mc_extract_two_words/3 extracts the first two non-empty words.
mc_extract_two_words(Str, W1, W2) :-
    % Split on whitespace and punctuation only (no letters).
    split_string(Str, " \t\n?.!,", " \t\n?.!,", Parts),
    % Find all non-empty parts.
    include([P]>>(P \= ""), Parts, NonEmpty),
    % Get the first two.
    NonEmpty = [P1, P2|_],
    atom_string(W1, P1),
    atom_string(W2, P2).

% ------------------------------------------------------------------
% Query execution and reply formatting
% ------------------------------------------------------------------

% mc_execute_query/3 executes a parsed query and builds a reply.
mc_execute_query(is_a(Subject, Object), Reply, Just) :-
    % Check whether Subject is_a Object in the knowledge base.
    (   is_a(Subject, Object)
    ->  % Build the positive answer.
        mc_format_is_a_reply(Subject, Object, Reply, Just)
    ;   % Build the honest ignorance answer.
        format(string(Reply), "I have not learned whether ~w is a ~w yet, so I do not want to guess.", [Subject, Object]),
        Just = ""
    ).
mc_execute_query(what_is(Subject), Reply, Just) :-
    % Gather all known facts about Subject.
    mc_gather_facts(Subject, Facts),
    % Format the aggregated reply.
    (   Facts = []
    ->  format(string(Reply), "I have not learned what ~w is yet, so I do not want to guess.", [Subject]),
        Just = ""
    ;   mc_format_what_is_reply(Subject, Facts, Reply, Just)
    ).
mc_execute_query(capable_of(Subject, Action), Reply, Just) :-
    % Use mentova_query to handle both direct and is_a-chain capable_of.
    (   mentova:mentova_query(deductive, capable_of(Subject, Action), answer(yes, J))
    ->  format(string(Reply), "Yes, ~w can ~w.", [Subject, Action]),
        mc_format_just(J, Just)
    ;   format(string(Reply), "I have not learned whether ~w can ~w yet, so I do not want to guess.", [Subject, Action]),
        Just = ""
    ).
mc_execute_query(what_can(Subject), Reply, Just) :-
    % Find all actions Subject is capable of.
    findall(A, capable_of(Subject, A), Actions),
    (   Actions = []
    ->  format(string(Reply), "I have not learned what ~w can do yet.", [Subject]),
        Just = ""
    ;   atomic_list_concat(Actions, ', ', ActionList),
        format(string(Reply), "~w can: ~w.", [Subject, ActionList]),
        format(string(Just), "These come from my capable_of facts about ~w.", [Subject])
    ).
mc_execute_query(causes(Cause, Effect), Reply, Just) :-
    % Check whether Cause causes Effect.
    (   causes(Cause, Effect)
    ->  format(string(Reply), "~w causes ~w.", [Cause, Effect]),
        format(string(Just), "I know this because causes(~w, ~w) is in my knowledge base.", [Cause, Effect])
    ;   format(string(Reply), "I have not learned whether ~w causes ~w yet, so I do not want to guess.", [Cause, Effect]),
        Just = ""
    ).
mc_execute_query(properties_of(Subject), Reply, Just) :-
    % Find all properties of Subject.
    findall(P, has_property(Subject, P), Props),
    (   Props = []
    ->  format(string(Reply), "I have not learned the properties of ~w yet.", [Subject]),
        Just = ""
    ;   atomic_list_concat(Props, ', ', PropList),
        format(string(Reply), "~w has these properties: ~w.", [Subject, PropList]),
        format(string(Just), "These come from my has_property facts about ~w.", [Subject])
    ).
% Greet the visitor warmly.
mc_execute_query(greeting, Reply, "") :-
    Reply = "Hello! I am Mentova. You can ask me things like 'What is a canary?' or 'Can a bird fly?'".

mc_execute_query(unknown, Reply, "") :-
    % The message did not match any known pattern.
    Reply = "I have not learned that yet, so I do not want to guess.".

% mc_gather_facts/2 collects known facts about Subject into a list.
mc_gather_facts(Subject, Facts) :-
    % Gather is_a relations for Subject.
    findall(is_a(Subject, O), is_a(Subject, O), IsAs),
    % Gather has_property relations.
    findall(has_property(Subject, P), has_property(Subject, P), Props),
    % Gather capable_of relations.
    findall(capable_of(Subject, A), capable_of(Subject, A), Caps),
    % Gather at_location relations.
    findall(at_location(Subject, L), at_location(Subject, L), Locs),
    % Combine all facts.
    append([IsAs, Props, Caps, Locs], Facts).

% mc_format_just/2 converts a justification term to a human-readable string.
mc_format_just(just(S, capable_of, A, via_isa), Just) :-
    % Subject can do Action because it inherits from a parent that can.
    format(string(Just), "~w can ~w because it inherits this ability.", [S, A]).
% Direct capable_of justification.
mc_format_just(just(S, capable_of, A, direct), Just) :-
    format(string(Just), "~w can ~w directly.", [S, A]).
% Catch-all: format the justification term as text.
mc_format_just(J, Just) :-
    format(string(Just), "~w", [J]).

% mc_format_is_a_reply/4 formats a positive is_a reply.
mc_format_is_a_reply(Subject, Object, Reply, Just) :-
    % Build a chain of is_a links for the justification.
    mc_is_a_chain(Subject, Object, Chain),
    format(string(Reply), "Yes, ~w is a ~w.", [Subject, Object]),
    (   Chain = [_]
    ->  format(string(Just), "I know this directly: is_a(~w, ~w) is in my knowledge base.", [Subject, Object])
    ;   atomic_list_concat(Chain, ' -> ', ChainStr),
        format(string(Just), "I know this because ~w.", [ChainStr])
    ).

% mc_is_a_chain/3 builds the chain of is_a links from Subject to Object.
mc_is_a_chain(Subject, Object, [Subject, Object]) :-
    % Base case: direct is_a link.
    is_a(Subject, Object).
mc_is_a_chain(Subject, Object, [Subject | Rest]) :-
    % Recursive case: Subject is_a Middle, Middle chains to Object.
    is_a(Subject, Middle),
    Middle \= Object,
    mc_is_a_chain(Middle, Object, Rest).

% mc_format_what_is_reply/4 formats a what_is reply from gathered facts.
mc_format_what_is_reply(Subject, Facts, Reply, Just) :-
    % Format each fact as a readable phrase.
    maplist(mc_fact_to_phrase, Facts, Phrases),
    % Join the phrases with semicolons.
    atomic_list_concat(Phrases, '; ', PhraseList),
    format(string(Reply), "Here is what I know about ~w: ~w.", [Subject, PhraseList]),
    format(string(Just), "These come from my knowledge base facts about ~w.", [Subject]).

% mc_fact_to_phrase/2 converts a fact term to a readable phrase.
mc_fact_to_phrase(is_a(S, O), Phrase) :-
    format(atom(Phrase), "~w is a ~w", [S, O]).
mc_fact_to_phrase(has_property(S, P), Phrase) :-
    format(atom(Phrase), "~w has property ~w", [S, P]).
mc_fact_to_phrase(capable_of(S, A), Phrase) :-
    format(atom(Phrase), "~w can ~w", [S, A]).
mc_fact_to_phrase(at_location(S, L), Phrase) :-
    format(atom(Phrase), "~w is at ~w", [S, L]).

% ------------------------------------------------------------------
% mc_explain/2 — justification for the /api/why endpoint
% ------------------------------------------------------------------

% mc_explain/2 returns an explanation for a given query string.
mc_explain(QueryStr, Explanation) :-
    % Parse the query string into a structured query term.
    mc_parse_query(QueryStr, Query),
    % Execute the query to get the justification.
    (   mc_execute_query(Query, _Reply, Just),
        Just \= ""
    ->  Explanation = Just
    ;   Explanation = "I cannot show you a reason for that, so I should not claim it."
    ).
