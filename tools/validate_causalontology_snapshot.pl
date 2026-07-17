% Module: validate a materialized Causalontology snapshot for 2.0.0 vocabulary
% conformance. The Lattice materializes Reasoning Objects to
% data/lattice_snapshot/causalontology_causal_relation_objects.pl in PrologAI's
% native causal_relation_object/8 term form (symbolic causes and effects), not
% the JSON content-addressed record form; so the light check here validates that
% the snapshot speaks whole-word Causalontology 2.0.0 vocabulary and obeys the
% locally decidable rules (whole-word functor and fields, the 2.0.0 modality and
% temporal-unit enumerations, Rule 4 window ordering, strength in [0,1], and no
% retired cro/dmin/dmax spellings). It reads facts as data; it asserts nothing.
:- module(validate_causalontology_snapshot, [
    % validate_snapshot_file/2: validate one snapshot file, collecting errors.
    validate_snapshot_file/2,
    % causalontology_snapshot_valid/0: validate the default snapshot; fail on any error.
    causalontology_snapshot_valid/0,
    % causalontology_snapshot_main/0: command-line entry point (halts).
    causalontology_snapshot_main/0
   ]).

% Read terms and inspect files.
:- use_module(library(readutil)).
:- use_module(library(lists)).

% -- The default materialized snapshot path, relative to the Mentova root.
snapshot_default('data/lattice_snapshot/causalontology_causal_relation_objects.pl').

% -- The five whole-word 2.0.0 modalities.
valid_modality(necessary).    valid_modality(sufficient).
valid_modality(contributory). valid_modality(preventive).
valid_modality(enabling).

% -- The eight whole-word 2.0.0 temporal units.
valid_unit(instant). valid_unit(seconds). valid_unit(minutes). valid_unit(hours).
valid_unit(days).    valid_unit(weeks).   valid_unit(months).  valid_unit(years).

% -- validate_snapshot_file(+Path, -Errors): every 2.0.0 violation in the file.
validate_snapshot_file(Path, Errors) :-
    % Read every top-level term (the causal_relation_object/8 facts).
    read_file_terms(Path, Terms),
    % Collect a per-fact error and any retired-spelling error.
    findall(E, ( member(T, Terms), fact_error(T, E) ), FactErrors),
    % Scan the raw text for retired abbreviations.
    ( retired_spelling(Path, Sp) -> SpellErrors = [Sp] ; SpellErrors = [] ),
    % Join both error sources.
    append(FactErrors, SpellErrors, Errors).

% -- read_file_terms(+Path, -Terms): read all Prolog terms from a file.
read_file_terms(Path, Terms) :-
    % Open the file for reading.
    open(Path, read, S),
    % Read term by term to end of file.
    read_terms_stream(S, Terms),
    % Close the stream.
    close(S).
% Read to the end of the stream.
read_terms_stream(S, Terms) :-
    % Read one term.
    read_term(S, T, []),
    % Stop at end of file, otherwise keep the term and continue.
    ( T == end_of_file -> Terms = []
    ; ( Terms = [T|Rest], read_terms_stream(S, Rest) ) ).

% -- fact_error(+Term, -Error): a 2.0.0 violation in one causal_relation_object fact.
% Only causal_relation_object/8 facts are validated; other terms are ignored.
fact_error(causal_relation_object(Id, Causes, Effects, Temporal, Modality, Strength, _Context, Prov), Error) :-
    ( \+ atom(Id) -> Error = invalid_id(Id)
    ; \+ ( is_list(Causes), Causes \== [] ) -> Error = empty_or_nonlist_causes(Id)
    ; \+ ( is_list(Effects), Effects \== [] ) -> Error = empty_or_nonlist_effects(Id)
    ; \+ temporal_ok(Temporal) -> Error = bad_temporal(Id, Temporal)
    ; \+ valid_modality(Modality) -> Error = bad_modality(Id, Modality)
    ; \+ ( number(Strength), Strength >= 0, Strength =< 1 ) -> Error = bad_strength(Id, Strength)
    ; \+ Prov = prov(_, _, _) -> Error = bad_provenance(Id)
    ; fail
    ).

% -- temporal_ok(+Temporal): a whole-word unit and Rule 4 window ordering.
temporal_ok(temporal(Dmin, Dmax, Unit)) :-
    % The unit is one of the eight whole words.
    valid_unit(Unit),
    % Both bounds are non-negative numbers.
    number(Dmin), number(Dmax), Dmin >= 0, Dmax >= 0,
    % Rule 4: the minimum delay may not exceed the maximum.
    Dmin =< Dmax.

% -- retired_spelling(+Path, -Error): the file uses a retired abbreviation.
retired_spelling(Path, retired_spelling(Path)) :-
    % Read the whole file as text.
    read_file_to_string(Path, Text, []),
    % Any retired cro(, dmin, or dmax spelling is a violation.
    ( sub_string(Text, _, _, _, "cro(")
    ; sub_string(Text, _, _, _, "dmin")
    ; sub_string(Text, _, _, _, "dmax") ), !.

% -- causalontology_snapshot_valid/0: validate the default snapshot, no errors.
causalontology_snapshot_valid :-
    % Resolve the default snapshot path.
    snapshot_default(Path),
    % Validate it and require an empty error list.
    validate_snapshot_file(Path, Errors),
    % Succeed only when nothing was flagged.
    Errors == [].

% -- causalontology_snapshot_main/0: report and exit for the command line.
causalontology_snapshot_main :-
    % Resolve and validate the default snapshot.
    snapshot_default(Path), validate_snapshot_file(Path, Errors),
    % Count the validated facts for the report.
    read_file_terms(Path, Terms),
    aggregate_all(count, ( member(T, Terms), T = causal_relation_object(_,_,_,_,_,_,_,_) ), N),
    % Print the outcome and exit with a gate-friendly code.
    ( Errors == []
      -> ( format("Causalontology 2.0.0 snapshot check: ~w/~w facts valid; OK~n", [N, N]), halt(0) )
      ;  ( format("Causalontology 2.0.0 snapshot check FAILED: ~w~n", [Errors]), halt(1) )
    ).
