% PLUnit test: the materialized Causalontology snapshot is 2.0.0-valid.
% Mentova consumes PrologAI's pack-qualified Causalontology vocabulary as-is and
% materializes Reasoning Objects to data/lattice_snapshot/ in the native
% causal_relation_object/8 form. This test gates that the snapshot speaks
% whole-word 2.0.0 vocabulary and obeys the locally decidable rules, so a
% re-abbreviation or an out-of-enumeration modality/unit cannot slip in.
:- module(test_causalontology_snapshot, []).
% Load the snapshot validator.
:- use_module('../tools/validate_causalontology_snapshot.pl').
% Load the PLUnit framework.
:- use_module(library(plunit)).

% The snapshot conformance test group.
:- begin_tests(causalontology_snapshot).

% test: the default materialized snapshot has zero 2.0.0 violations.
test(default_snapshot_is_2_0_0_valid) :-
    % Validate the shipped snapshot and require an empty error list.
    validate_snapshot_file('data/lattice_snapshot/causalontology_causal_relation_objects.pl', Errors),
    % Any violation is a test failure, reported with its details.
    assertion(Errors == []).

% Close the test group.
:- end_tests(causalontology_snapshot).
