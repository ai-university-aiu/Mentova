/*  Mentova — validate the exported Causalontology 2.0.0 snapshot (Order Two)

    This is the STEP 2 gate for THE LATTICE BRIDGE. It reads the materialised
    2.0.0 type-tier snapshot (data/lattice_snapshot/causalontology_2_0_0/
    type_tier.ndjson) — canonical RFC 8785 JSON, one record per line — and proves
    it is 2.0.0-conformant and self-verifying:

      1. Every content object satisfies its 2.0.0 JSON-Schema and the local
         semantic rules.
      2. Every provenance record (assertion) additionally carries an Ed25519
         signature that verifies against Mentova's public key.
      3. Every content id is the true SHA-256 of the record's canonical
         identity-bearing bytes (self-verifying by hash).
      4. The seventeen-kind schemas and the 107 conformance vectors themselves
         still pass (Order One's harness), so the validator is faithful.

    It REUSES Order One's harness (schema_check, signing, causal_core, the
    conformance runner) and imports none of the ARC solving packs.
*/

% Declare the module and its entry points.
:- module(validate_causalontology_2_0_0, [
    % v2_validate_file/2: validate one NDJSON snapshot file, collecting errors.
    v2_validate_file/2,
    % v2_read_ndjson/2: parse an NDJSON snapshot file into record dicts.
    v2_read_ndjson/2,
    % v2_main/0: command-line gate (validates the default snapshot + vectors).
    v2_main/0
   ]).

% The PrologAI repository root (override with PROLOGAI_ROOT).
v2_prolog_root(Root) :-
    % Environment override first, then the standard sibling checkout.
    ( getenv('PROLOGAI_ROOT', Root) -> true ; Root = '/home/ccaitwo/PrologAI' ).

% Attach the PrologAI packs so library(causal_core) resolves.
:- initialization((v2_prolog_root(R), atomic_list_concat([R, '/packs'], P),
                   catch(attach_packs(P, [duplicate(replace)]), _, true)), now).
% Reuse the canonicalization/identity/semantics pack.
:- use_module(library(causal_core)).
% Reuse Order One's schema validator, signer and conformance runner by path.
:- initialization((v2_prolog_root(R),
    atomic_list_concat([R, '/tests/causalontology_conformance/schema_check.pl'], S1),
    catch(ensure_loaded(S1), _, true),
    atomic_list_concat([R, '/tests/causalontology_conformance/signing.pl'], S2),
    catch(ensure_loaded(S2), _, true),
    atomic_list_concat([R, '/tests/causalontology_conformance/run_conformance.pl'], S3),
    catch(ensure_loaded(S3), _, true)), now).
% JSON reading and list helpers.
:- use_module(library(http/json)).
:- use_module(library(lists)).

% -- The default materialised 2.0.0 type-tier snapshot path.
v2_default('data/lattice_snapshot/causalontology_2_0_0/type_tier.ndjson').

% -- v2_validate_file(+Path, -Errors): every 2.0.0 violation in the NDJSON file.
v2_validate_file(Path, Errors) :-
    % Read the file as a list of record dicts, one per line.
    v2_read_ndjson(Path, Records),
    % Collect a per-record error wherever one exists.
    findall(E, ( member(R, Records), v2_record_error(R, E) ), Errors).

% -- v2_read_ndjson(+Path, -Records): parse each non-empty line as a JSON dict.
v2_read_ndjson(Path, Records) :-
    % Read the whole file to a string.
    read_file_to_string(Path, Text, []),
    % Split into lines.
    split_string(Text, "\n", "", Lines0),
    % Drop blank lines.
    exclude(==(""), Lines0, Lines),
    % Parse each line as a JSON dict.
    maplist(v2_parse_line, Lines, Records).

% -- v2_parse_line(+Line, -Dict): parse one JSON line into a dict.
v2_parse_line(Line, Dict) :-
    % Read the JSON text into a dict via an in-memory stream.
    setup_call_cleanup(open_string(Line, S), json_read_dict(S, Dict), close(S)).

% -- v2_record_error(+Record, -Error): a schema/semantic/identity/signature fault.
v2_record_error(Record, Error) :-
    % Infer the record's kind from its type field.
    causal_core_infer_kind(Record, Kind),
    % The record's own id (for error reporting).
    get_dict(id, Record, Id),
    % Schema, semantics, identity and (for records) signature, in that order.
    ( \+ co_validate_schema(Record, Kind, true, _)
      -> co_validate_schema(Record, Kind, false, Why), Error = schema(Id, Why)
    ; causal_core_validate_semantics(Record, Kind, Reasons), Reasons \== []
      -> Error = semantics(Id, Reasons)
    ; \+ v2_identity_ok(Record, Kind)
      -> Error = identity_mismatch(Id)
    ; Kind == assertion, \+ co_verify_record(Record, assertion)
      -> Error = bad_signature(Id)
    ; fail
    ).

% -- v2_identity_ok(+Record, +Kind): the id is the true content hash (self-verify).
v2_identity_ok(Record, Kind) :-
    % Strip the signature (excluded from identity) before recomputing.
    ( del_dict(signature, Record, _, Body) -> true ; Body = Record ),
    % Recompute the content-addressed id over the identity-bearing bytes.
    causal_core_identify(Body, Kind, Recomputed),
    % It must equal the stored id.
    get_dict(id, Record, Stored),
    ( Stored == Recomputed -> true ; atom_string(Stored, S), S == Recomputed ).

% -- v2_main/0: the command-line gate. Validates the snapshot AND re-runs the
% 107 conformance vectors, then exits with a gate-friendly code.
v2_main :-
    % Resolve and validate the default snapshot file.
    v2_default(Path),
    ( exists_file(Path)
      -> v2_validate_file(Path, Errors),
         v2_read_ndjson(Path, Records), length(Records, NRec)
      ;  ( format("Causalontology 2.0.0 snapshot MISSING at ~w~n", [Path]), halt(1) ) ),
    % Re-run the 107 vectors to prove the validator itself is faithful (co_run
    % lives in the conformance runner's module).
    ( catch(co_conformance:co_run(Failures), VErr, (Failures = [error(VErr)])) -> true ; Failures = [run_failed] ),
    % Report the snapshot outcome.
    ( Errors == []
      -> format("Snapshot: ~w records, all 2.0.0-conformant (schema+semantics+identity+signature).~n", [NRec])
      ;  format("Snapshot FAILED: ~w~n", [Errors]) ),
    % Report the vector outcome.
    ( Failures == []
      -> format("Conformance vectors: 107/107 pass.~n", [])
      ;  format("Conformance vectors FAILED: ~w~n", [Failures]) ),
    % Exit green only when both the snapshot and the vectors are clean.
    ( Errors == [], Failures == [] -> halt(0) ; halt(1) ).
