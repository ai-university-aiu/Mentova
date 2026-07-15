/*  Mentova — Chat Persistence Layer Test Suite

    Genuine PLUnit coverage for src/mentova/chat_db.pl (Acc_423), the
    durable store behind the Mentova web chat. The module uses
    library(persistency) for a flat-file database of chat logs, mentor
    accounts, sessions, a review queue, and an audit log, and exports
    mc_db_init/1, mc_log_message/4, mc_create_mentor/2,
    mc_authenticate_mentor/3, mc_create_session/2, mc_verify_session/2,
    mc_revoke_session/1, mc_propose_fact/4, mc_approve_fact/2,
    mc_audit/3, and mc_pending_proposals/1.

    The suite attaches a fresh backing file in a per-process scratch
    directory, then exercises the mentor / session / review-queue /
    logging / audit round-trips with real assertions on outputs.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_chat_db.pl
*/

% Declare this file as a test module with no exports.
:- module(test_chat_db, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(chat_db)).

% chat_db_test_attach/0 attaches a fresh persistence file before any test runs.
chat_db_test_attach :-
    % Read this process's identifier to keep the scratch path unique.
    current_prolog_flag(pid, Pid),
    % Read the wall-clock time to further disambiguate the scratch path.
    get_time(Time),
    % Turn the time into an integer millisecond stamp.
    Stamp is round(Time * 1000),
    % Build a unique scratch directory name under the system temp area.
    format(atom(Dir), '/tmp/mentova_chat_db_test_~w_~w', [Pid, Stamp]),
    % Attach (creating) the chat database in that fresh directory.
    mc_db_init(Dir).

% Attach the database once, at load time, before the test block opens.
:- chat_db_test_attach.

% Open the test block for the chat_db module.
:- begin_tests(chat_db).

% AC-CHATDB-001: a created mentor authenticates with the right password and rejects a wrong one.
test(mentor_create_and_authenticate) :-
    % Register a brand-new mentor account with a known password.
    mc_create_mentor(alice, 'pw-alice'),
    % Authenticate with the correct credentials, binding the mentor id.
    mc_authenticate_mentor(alice, 'pw-alice', MentorId),
    % A successful authentication yields an integer mentor id.
    assertion(integer(MentorId)),
    % The same account refuses a wrong password (the SHA-256 hash check fails).
    assertion(\+ mc_authenticate_mentor(alice, 'wrong-pw', _)).

% AC-CHATDB-002: creating a second account with an existing username is refused.
test(duplicate_mentor_rejected) :-
    % Register a mentor account for this test.
    mc_create_mentor(bob, 'pw-bob'),
    % Attempt to register the same username again, catching the raised error.
    catch(mc_create_mentor(bob, 'pw-bob-again'), Error, true),
    % The second attempt must actually have thrown (Error is now bound).
    assertion(nonvar(Error)),
    % The thrown error is the documented duplicate-mentor error for that username.
    assertion(Error = error(duplicate_mentor(bob), _)).

% AC-CHATDB-003: a session token verifies to its owner and stops verifying once revoked.
test(session_create_verify_and_revoke) :-
    % Register a mentor whose session we will manage.
    mc_create_mentor(carol, 'pw-carol'),
    % Authenticate to obtain that mentor's id.
    mc_authenticate_mentor(carol, 'pw-carol', MentorId),
    % Issue a fresh session token for the authenticated mentor.
    mc_create_session(MentorId, Token),
    % Verifying the token returns the very mentor id it was issued for.
    mc_verify_session(Token, VerifiedId),
    % The verified id matches the issuing mentor's id.
    assertion(VerifiedId == MentorId),
    % Revoke the session, signing that mentor out.
    mc_revoke_session(Token),
    % After revocation the same token no longer verifies.
    assertion(\+ mc_verify_session(Token, _)).

% AC-CHATDB-004: a proposed fact appears on the pending queue, then is approved and asserted.
test(propose_pending_and_approve) :-
    % Register a mentor to own the proposal.
    mc_create_mentor(dave, 'pw-dave'),
    % Authenticate to obtain that mentor's id.
    mc_authenticate_mentor(dave, 'pw-dave', MentorId),
    % Propose a teaching fact onto the review queue, binding its queue id.
    mc_propose_fact(mentova_test_fact(sky, blue), MentorId, 'sess-dave', QueueId),
    % A proposal receives an integer queue id.
    assertion(integer(QueueId)),
    % The queue stores the fact as the atom produced by term_to_atom/2.
    term_to_atom(mentova_test_fact(sky, blue), FactAtom),
    % Read the current list of pending proposals.
    mc_pending_proposals(Pending),
    % The freshly proposed entry is present with its queue id, atom, and proposer.
    assertion(memberchk(entry(QueueId, FactAtom, MentorId, _), Pending)),
    % Approve the queued proposal under the same mentor as approver.
    mc_approve_fact(QueueId, MentorId),
    % Re-read the pending proposals after approval.
    mc_pending_proposals(StillPending),
    % The approved entry is no longer pending.
    assertion(\+ memberchk(entry(QueueId, _, _, _), StillPending)),
    % Approval asserts the parsed fact into the chat_db module's database.
    assertion(chat_db:mentova_test_fact(sky, blue)).

% AC-CHATDB-005: logging a chat turn writes a durable, well-formed chat-log record.
test(log_message_persisted) :-
    % Record one public-tier turn spoken by the child.
    mc_log_message('sess-log', public, child, 'hello mentova'),
    % A chat-log record with those exact fields now exists and carries an integer id.
    assertion(( chat_db:mc_chat_log(Id, 'sess-log', public, child, 'hello mentova', _),
                integer(Id) )).

% AC-CHATDB-006: an audit entry is written with its event, detail, actor, and a timestamp.
test(audit_entry_persisted) :-
    % Write one audit entry describing a unit-test event.
    mc_audit(unit_test_event, detail_payload, tester),
    % An audit record with those fields exists and stamps an atom timestamp.
    assertion(( chat_db:mc_audit_log(unit_test_event, detail_payload, tester, When),
                atom(When) )).

% Close the test block for the chat_db module.
:- end_tests(chat_db).
