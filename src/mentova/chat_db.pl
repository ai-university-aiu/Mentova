/*  chat_db.pl — Mentova Chat Persistence Layer

    Provides durable storage for the Mentova web chat feature using
    library(persistency).  All chat logs, mentor accounts, sessions,
    review-queue entries, and audit events are kept in a flat file
    that survives server restarts.

    Acc_423 — Mentova Web Chat, text-only milestone.
*/

% Declare this file as the 'chat_db' module and export its predicates.
:- module(chat_db, [
    % mc_db_init/1 — attach the persistence file under DataDir.
    mc_db_init/1,
    % mc_log_message/4 — record one chat turn.
    mc_log_message/4,
    % mc_create_mentor/2 — register a new mentor account.
    mc_create_mentor/2,
    % mc_authenticate_mentor/3 — verify username/password; unify MentorId.
    mc_authenticate_mentor/3,
    % mc_create_session/2 — create a session token for an authenticated mentor.
    mc_create_session/2,
    % mc_verify_session/2 — check token is valid; unify MentorId.
    mc_verify_session/2,
    % mc_revoke_session/1 — sign a mentor out by revoking their token.
    mc_revoke_session/1,
    % mc_propose_fact/4 — place a proposed fact on the review queue.
    mc_propose_fact/4,
    % mc_approve_fact/2 — approve a queued proposal and store it in the Lattice.
    mc_approve_fact/2,
    % mc_audit/3 — write one audit entry.
    mc_audit/3,
    % mc_pending_proposals/1 — unify a list of all pending queue entries.
    mc_pending_proposals/1
% Close the export list.
]).

% Load library(persistency) for durable flat-file fact storage.
:- use_module(library(persistency)).
% Load library(sha) for SHA-256 password hashing.
:- use_module(library(sha)).
% Load library(uuid) for unique token generation.
:- use_module(library(uuid)).
% Load library(apply) for maplist/2.
:- use_module(library(apply)).

% ------------------------------------------------------------------
% Persistent fact declarations
% ------------------------------------------------------------------

% Declare mc_schema_version/1 as a persistent fact.
:- persistent mc_schema_version(version:integer).

% Declare mc_chat_id_counter/1 as a persistent fact.
:- persistent mc_chat_id_counter(next:integer).

% Declare mc_review_id_counter/1 as a persistent fact.
:- persistent mc_review_id_counter(next:integer).

% Declare mc_chat_log/6 as a persistent fact storing one chat turn.
:- persistent mc_chat_log(
    id:integer,
    session_id:atom,
    tier:atom,
    speaker:atom,
    message:atom,
    created_at:atom
).

% Declare mc_mentor_account/5 as a persistent fact for mentor credentials.
:- persistent mc_mentor_account(
    id:integer,
    username:atom,
    password_hash:atom,
    salt:atom,
    active:atom
).

% Declare mc_mentor_session/5 as a persistent fact for active sessions.
:- persistent mc_mentor_session(
    mentor_id:integer,
    token_hash:atom,
    created_at:atom,
    expires_at:atom,
    revoked:atom
).

% Declare mc_review_queue/7 as a persistent fact for proposed teachings.
:- persistent mc_review_queue(
    id:integer,
    proposed_fact:atom,
    mentor_id:integer,
    session_id:atom,
    status:atom,
    created_at:atom,
    decided_at:atom
).

% Declare mc_audit_log/4 as a persistent fact for significant events.
:- persistent mc_audit_log(
    event:atom,
    detail:atom,
    actor:atom,
    created_at:atom
).

% ------------------------------------------------------------------
% mc_db_init/1 — attach the persistence backing file
% ------------------------------------------------------------------

% mc_db_init(DataDir) attaches (or creates) the persistence file.
mc_db_init(DataDir) :-
    % Ensure the data directory exists before attaching.
    ensure_directory(DataDir),
    % Build the full path to the database file.
    atomic_list_concat([DataDir, '/mentova_chat.db'], DbFile),
    % Attach the persistence file; creates it if absent.
    db_attach(DbFile, []),
    % Initialise counters and schema version on the very first run.
    mc_ensure_schema.

% mc_ensure_schema/0 writes the schema version stamp if absent.
mc_ensure_schema :-
    % Check whether the schema version is already present.
    (   mc_schema_version(_)
    ->  true
    ;   % Insert the initial schema version stamp.
        assert_mc_schema_version(1),
        % Insert the initial chat ID counter starting at 1.
        assert_mc_chat_id_counter(1),
        % Insert the initial review ID counter starting at 1.
        assert_mc_review_id_counter(1)
    ).

% ensure_directory/1 creates a directory if it does not exist.
ensure_directory(Dir) :-
    % Test whether Dir already exists as a directory.
    (   exists_directory(Dir)
    ->  true
    ;   % Create the directory along with any missing parents.
        make_directory_path(Dir)
    ).

% ------------------------------------------------------------------
% Counter helpers
% ------------------------------------------------------------------

% mc_next_chat_id(-Id) retrieves and increments the chat ID counter.
mc_next_chat_id(Id) :-
    % Retrieve the current chat counter value.
    mc_chat_id_counter(Id),
    % Calculate the next value.
    Next is Id + 1,
    % Remove the old counter fact.
    retract_mc_chat_id_counter(Id),
    % Store the new counter value.
    assert_mc_chat_id_counter(Next).

% mc_next_review_id(-Id) retrieves and increments the review ID counter.
mc_next_review_id(Id) :-
    % Retrieve the current review counter value.
    mc_review_id_counter(Id),
    % Calculate the next value.
    Next is Id + 1,
    % Remove the old counter fact.
    retract_mc_review_id_counter(Id),
    % Store the new counter value.
    assert_mc_review_id_counter(Next).

% ------------------------------------------------------------------
% Timestamp helper
% ------------------------------------------------------------------

% mc_now(-Atom) unifies Atom with the current UTC timestamp as an atom.
mc_now(Atom) :-
    % Get the current time as a float.
    get_time(T),
    % Format it as an ISO 8601 string.
    format_time(atom(Atom), '%Y-%m-%dT%H:%M:%SZ', T).

% ------------------------------------------------------------------
% mc_log_message/4 — record one chat turn
% ------------------------------------------------------------------

% mc_log_message(+SessionId, +Tier, +Speaker, +Message) stores one turn.
mc_log_message(SessionId, Tier, Speaker, Message) :-
    % Get a fresh ID for this chat log entry.
    mc_next_chat_id(Id),
    % Get the current timestamp.
    mc_now(Now),
    % Store the chat log entry in the persistence file.
    assert_mc_chat_log(Id, SessionId, Tier, Speaker, Message, Now).

% ------------------------------------------------------------------
% mc_create_mentor/2 — register a new mentor account
% ------------------------------------------------------------------

% mc_create_mentor(+Username, +Password) creates a mentor account.
mc_create_mentor(Username, Password) :-
    % Refuse to create a duplicate account.
    (   mc_mentor_account(_, Username, _, _, _)
    ->  throw(error(duplicate_mentor(Username), mc_create_mentor/2))
    ;   true
    ),
    % Generate a random salt for this account.
    uuid(Salt),
    % Hash the salted password using SHA-256.
    mc_hash_password(Password, Salt, Hash),
    % Calculate the next mentor ID.
    aggregate_all(count, mc_mentor_account(_, _, _, _, _), Count),
    % The new ID is one more than the current count.
    Id is Count + 1,
    % Store the mentor account in the persistence file.
    assert_mc_mentor_account(Id, Username, Hash, Salt, active),
    % Record the account creation in the audit log.
    mc_audit(mentor_created, Username, system).

% ------------------------------------------------------------------
% mc_authenticate_mentor/3 — verify credentials
% ------------------------------------------------------------------

% mc_authenticate_mentor(+Username, +Password, -MentorId) verifies login.
mc_authenticate_mentor(Username, Password, MentorId) :-
    % Retrieve the stored account record for this username.
    mc_mentor_account(MentorId, Username, StoredHash, Salt, active),
    % Hash the supplied password with the stored salt.
    mc_hash_password(Password, Salt, Hash),
    % Verify that the hashes match.
    Hash == StoredHash.

% ------------------------------------------------------------------
% mc_create_session/2 — issue a session token
% ------------------------------------------------------------------

% mc_create_session(+MentorId, -Token) creates a new session token.
mc_create_session(MentorId, Token) :-
    % Generate a UUID as the raw token value.
    uuid(Token),
    % Hash the token before storing it.
    mc_hash_token(Token, TokenHash),
    % Record the creation time.
    mc_now(Now),
    % Sessions expire 8 hours from now.
    get_time(T),
    ExpiryT is T + 8 * 3600,
    format_time(atom(Expires), '%Y-%m-%dT%H:%M:%SZ', ExpiryT),
    % Store the session in the persistence file.
    assert_mc_mentor_session(MentorId, TokenHash, Now, Expires, 'false').

% ------------------------------------------------------------------
% mc_verify_session/2 — check a token is valid
% ------------------------------------------------------------------

% mc_verify_session(+Token, -MentorId) succeeds if token is valid.
mc_verify_session(Token, MentorId) :-
    % Hash the supplied token for lookup.
    mc_hash_token(Token, TokenHash),
    % Find the matching session record.
    mc_mentor_session(MentorId, TokenHash, _Created, Expires, 'false'),
    % Check that the session has not expired.
    mc_now(Now),
    % Compare the expiry timestamp with the current time.
    Expires @>= Now.

% ------------------------------------------------------------------
% mc_revoke_session/1 — sign a mentor out
% ------------------------------------------------------------------

% mc_revoke_session(+Token) marks the session as revoked.
mc_revoke_session(Token) :-
    % Hash the token to find the session record.
    mc_hash_token(Token, TokenHash),
    % Find the session record to revoke.
    mc_mentor_session(MentorId, TokenHash, Created, Expires, 'false'),
    % Remove the active session record.
    retract_mc_mentor_session(MentorId, TokenHash, Created, Expires, 'false'),
    % Store the revoked session record.
    assert_mc_mentor_session(MentorId, TokenHash, Created, Expires, 'true').

% ------------------------------------------------------------------
% mc_propose_fact/4 — add a proposed fact to the review queue
% ------------------------------------------------------------------

% mc_propose_fact(+Fact, +MentorId, +SessionId, -QueueId) enqueues a proposal.
mc_propose_fact(Fact, MentorId, SessionId, QueueId) :-
    % Get a fresh review queue ID.
    mc_next_review_id(QueueId),
    % Record the creation timestamp.
    mc_now(Now),
    % Convert the fact term to an atom for storage.
    term_to_atom(Fact, FactAtom),
    % Store the proposal in the review queue.
    assert_mc_review_queue(QueueId, FactAtom, MentorId, SessionId, pending, Now, ''),
    % Record the proposal in the audit log.
    mc_audit(fact_proposed, FactAtom, MentorId).

% ------------------------------------------------------------------
% mc_approve_fact/2 — approve a queued proposal
% ------------------------------------------------------------------

% mc_approve_fact(+QueueId, +ApproverId) approves and stores the fact.
mc_approve_fact(QueueId, ApproverId) :-
    % Find the pending proposal with this ID.
    mc_review_queue(QueueId, FactAtom, MentorId, SessionId, pending, Created, _),
    % Record the decision timestamp.
    mc_now(Now),
    % Remove the pending entry from the queue.
    retract_mc_review_queue(QueueId, FactAtom, MentorId, SessionId, pending, Created, _),
    % Store the approved entry in the queue for audit purposes.
    assert_mc_review_queue(QueueId, FactAtom, MentorId, SessionId, approved, Created, Now),
    % Parse the fact atom back into a Prolog term.
    term_to_atom(FactTerm, FactAtom),
    % Assert the approved fact into the Prolog database.
    assertz(FactTerm),
    % Record the approval in the audit log.
    mc_audit(fact_approved, FactAtom, ApproverId).

% ------------------------------------------------------------------
% mc_audit/3 — write one audit entry
% ------------------------------------------------------------------

% mc_audit(+Event, +Detail, +Actor) writes an audit log entry.
mc_audit(Event, Detail, Actor) :-
    % Record the current timestamp.
    mc_now(Now),
    % Convert detail to atom if needed.
    (atom(Detail) -> DetailAtom = Detail ; term_to_atom(Detail, DetailAtom)),
    % Convert actor to atom if needed.
    (atom(Actor) -> ActorAtom = Actor ; term_to_atom(Actor, ActorAtom)),
    % Write the audit entry to the persistence file.
    assert_mc_audit_log(Event, DetailAtom, ActorAtom, Now).

% ------------------------------------------------------------------
% mc_pending_proposals/1 — list all pending queue entries
% ------------------------------------------------------------------

% mc_pending_proposals(-List) unifies List with all pending proposals.
mc_pending_proposals(List) :-
    % Find all pending entries in the review queue.
    findall(
        entry(Id, Fact, MentorId, Created),
        mc_review_queue(Id, Fact, MentorId, _, pending, Created, _),
        List
    ).

% ------------------------------------------------------------------
% Password and token hashing helpers
% ------------------------------------------------------------------

% mc_hash_password(+Password, +Salt, -Hash) produces a SHA-256 hash.
mc_hash_password(Password, Salt, Hash) :-
    % Combine the salt and password with a colon separator.
    atomic_list_concat([Salt, ':', Password], Salted),
    % Convert the combined atom to a string for hashing.
    atom_string(Salted, SaltedStr),
    % Compute the SHA-256 hash as a list of bytes.
    sha_hash(SaltedStr, HashBytes, [algorithm(sha256)]),
    % Convert the byte list to a hex atom.
    hash_atom(HashBytes, Hash).

% mc_hash_token(+Token, -Hash) produces a SHA-256 hash of a session token.
mc_hash_token(Token, Hash) :-
    % Convert the token atom to a string.
    atom_string(Token, TokenStr),
    % Compute the SHA-256 hash as a list of bytes.
    sha_hash(TokenStr, HashBytes, [algorithm(sha256)]),
    % Convert the byte list to a hex atom.
    hash_atom(HashBytes, Hash).
