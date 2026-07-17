% PLUnit test: THE LATTICE BRIDGE — the exported Causalontology 2.0.0 type-tier
% snapshot is schema-, semantics- and identity-conformant, and its signed
% provenance verifies. This gates that the additive 2.0.0 export stays valid so a
% schema regression, an identity drift, or a broken signature cannot slip in.
%
% Full signature verification of all records is slow (pure-Prolog Ed25519), so
% this test verifies EVERY record's schema, semantics and content identity and a
% SAMPLE of assertion signatures; the exhaustive gate is
% bin/validate_causalontology_2_0_0.sh / make lattice-2_0_0-validate.
:- module(test_causalontology_2_0_0_bridge, []).
% Load the 2.0.0 validator (also attaches the PrologAI packs and Order One's
% schema/signing harness by path, so co_validate_schema and friends resolve).
:- use_module('../tools/validate_causalontology_2_0_0.pl').
% The PLUnit framework.
:- use_module(library(plunit)).
% List helpers.
:- use_module(library(lists)).

% The default materialised 2.0.0 type-tier snapshot.
t2_snapshot('data/lattice_snapshot/causalontology_2_0_0/type_tier.ndjson').

% The Lattice Bridge conformance test group.
:- begin_tests(causalontology_2_0_0_bridge).

% test: the snapshot exists and parses as one JSON record per line.
test(snapshot_parses) :-
    % Resolve and read the snapshot into record dicts.
    t2_snapshot(Path), v2_read_ndjson(Path, Records),
    % It must be non-empty.
    assertion(Records \== []).

% test: every record is schema-, semantics- and identity-conformant.
test(all_records_schema_semantics_identity_valid) :-
    % Read the records.
    t2_snapshot(Path), v2_read_ndjson(Path, Records),
    % Collect every schema/semantics/identity fault (signatures checked below).
    findall(E, ( member(R, Records), t2_content_error(R, E) ), Errors),
    % Any fault is a failure, reported with its offending id.
    assertion(Errors == []).

% test: a sample of provenance assertions carry verifying signatures.
test(sample_assertion_signatures_verify) :-
    % Read the records and take the first few assertions.
    t2_snapshot(Path), v2_read_ndjson(Path, Records),
    include([R]>>(get_dict(type, R, "assertion")), Records, Assertions),
    length(Assertions, NA), assertion(NA > 0),
    % Verify the first five (or fewer) signatures against Mentova's key.
    length(Sample, Min), ( NA >= 5 -> Min = 5 ; Min = NA ), append(Sample, _, Assertions),
    % Each sampled signature must verify (once/1 keeps the check deterministic).
    forall(member(A, Sample), assertion(once(co_signing:co_verify_record(A, assertion)))).

% Close the test group.
:- end_tests(causalontology_2_0_0_bridge).

% -- t2_content_error(+Record, -Error): a schema/semantics/identity fault (no
% signature check — that is sampled separately for speed).
t2_content_error(Record, Error) :-
    % Infer the record's kind and read its id.
    causal_core:causal_core_infer_kind(Record, Kind), get_dict(id, Record, Id),
    % Schema, then semantics, then content-identity self-verification.
    ( \+ co_schema:co_validate_schema(Record, Kind, true, _)
      -> co_schema:co_validate_schema(Record, Kind, false, Why), Error = schema(Id, Why)
    ; causal_core:causal_core_validate_semantics(Record, Kind, Reasons), Reasons \== []
      -> Error = semantics(Id, Reasons)
    ; \+ t2_identity_ok(Record, Kind)
      -> Error = identity_mismatch(Id)
    ; fail
    ).

% -- t2_identity_ok(+Record, +Kind): the stored id is the true content hash.
t2_identity_ok(Record, Kind) :-
    % Strip the signature (excluded from identity) before recomputing.
    ( del_dict(signature, Record, _, Body) -> true ; Body = Record ),
    % Recompute the content id and compare (tolerating atom/string encodings).
    causal_core:causal_core_identify(Body, Kind, Recomputed),
    get_dict(id, Record, Stored),
    ( Stored == Recomputed -> true ; atom_string(Stored, S), S == Recomputed ).
