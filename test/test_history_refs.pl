/*  Mentova — History-of-Puzzle-Games Reference Ingestion Test Suite

    Behavioural PLUnit tests for src/mentova/history_refs.pl, the module that
    carries the two golden history-of-puzzle-games references
    (/home/ccaitwo/ARC-AGI-3/History_Outline.txt and History_Book.txt) into the
    mind at boot through the nuanced fact doors. It exports two predicates:
        hr_ingest/1    -- ingest both references, returning summary(New, Strengthened, Variant)
        hr_bootstrap/0 -- the guarded, boot-safe one-call entry that prints a summary

    The tests exercise both exported predicates against the real golden files and
    the real Causalontology stores (the lattice node-fact layer plus the
    causal_core verb layer):
      - a fresh ingest carries genuine new facts in;
      - re-ingesting the same references is idempotent — every fact is
        strengthened, not duplicated (the module's headline guarantee);
      - the total number of facts carried in is a stable function of the corpus;
      - the boot entry is total (never throws) and prints its summary line.

    Isolation note: each hr_ingest reopens the fixed 'locus://mentova/drafts'
    nexus internally, so the node layer accumulates process-globally there and
    cannot be reset per test. The verb layer, however, is cleared with
    causal_core_reset in every setup, so the causal relations re-enter as new on
    each test; the assertions therefore rest only on order-independent invariants
    (a positive total, idempotence, conservation) and never on a raw first-run
    count.

    Run with the full PrologAI library path plus the Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_history_refs.pl
*/

% Declare this file as a test module with no exports.
:- module(test_history_refs, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(history_refs)).
% Load the lattice so the nuanced node-fact door and its drafts nexus are available.
:- use_module(library(lattice), []).
% Load the node-fact store the references anchor their node-facts into.
:- use_module(library(node_facts), []).
% Load the causal_core verb layer and import its reset for per-test isolation.
:- use_module(library(causal_core), [causal_core_reset/0]).

% Open the test block for history_refs.
:- begin_tests(history_refs).

% AC-HR-001: ingesting the two golden references carries genuine new facts in.
test(fresh_ingest_reports_new_facts, [setup(causal_core_reset)]) :-
    % Ingest both history references through the nuanced doors.
    hr_ingest(summary(New, Strengthened, Variant)),
    % The new-facts tally is an integer.
    assertion(integer(New)),
    % The strengthened tally is an integer.
    assertion(integer(Strengthened)),
    % The variant tally is an integer.
    assertion(integer(Variant)),
    % The new-facts tally is not negative.
    assertion(New >= 0),
    % The strengthened tally is not negative.
    assertion(Strengthened >= 0),
    % The variant tally is not negative.
    assertion(Variant >= 0),
    % With the verb layer just cleared, the causal relations re-enter as brand-new facts.
    assertion(New > 0),
    % Across both references at least one fact was successfully carried in.
    assertion(New + Strengthened + Variant > 0).

% AC-HR-002: re-ingesting the same references strengthens every fact instead of
% duplicating it — the module's headline idempotence guarantee.
test(reingest_is_idempotent_and_strengthens, [setup(causal_core_reset)]) :-
    % First pass over the references.
    hr_ingest(summary(New1, Strengthened1, Variant1)),
    % Second pass over the very same references.
    hr_ingest(summary(New2, Strengthened2, Variant2)),
    % The first pass carried real new facts in.
    assertion(New1 > 0),
    % The second pass introduces nothing new — ingestion is idempotent.
    assertion(New2 =:= 0),
    % The second pass flags no fresh variants either.
    assertion(Variant2 =:= 0),
    % Every repeated fact is strengthened rather than duplicated.
    assertion(Strengthened2 > 0),
    % Conservation: every fact from the first pass is now counted as an exact repeat.
    assertion(Strengthened2 =:= New1 + Strengthened1 + Variant1).

% AC-HR-003: the total number of facts carried in is a stable function of the
% fixed golden corpus, independent of the verb layer's prior contents.
test(total_carried_in_is_invariant, [setup(causal_core_reset)]) :-
    % Ingest once and read its three tallies.
    hr_ingest(summary(NewA, StrengthenedA, VariantA)),
    % The total number of facts carried in by the first ingest.
    TotalA is NewA + StrengthenedA + VariantA,
    % Clear the verb layer again for an independent second measurement.
    causal_core_reset,
    % Ingest a second time and read its three tallies.
    hr_ingest(summary(NewB, StrengthenedB, VariantB)),
    % The total number of facts carried in by the second ingest.
    TotalB is NewB + StrengthenedB + VariantB,
    % Both ingests carry exactly the same number of facts in.
    assertion(TotalA =:= TotalB),
    % And that number is positive — the golden corpus is non-empty.
    assertion(TotalA > 0).

% AC-HR-004: the boot entry is total (never throws) and prints its one-line summary.
test(bootstrap_succeeds_and_reports, [setup(causal_core_reset)]) :-
    % Run the guarded boot entry, capturing its printed summary line.
    with_output_to(string(Out), hr_bootstrap),
    % The summary names the two references it ingested.
    assertion(sub_string(Out, _, _, _, "history_refs: ingested 2 history references")),
    % The summary reports the count of new facts.
    assertion(sub_string(Out, _, _, _, "new facts")),
    % The summary reports the count strengthened.
    assertion(sub_string(Out, _, _, _, "strengthened")),
    % The summary reports the count of variants flagged.
    assertion(sub_string(Out, _, _, _, "variants flagged")).

% AC-HR-005: the boot entry is safe to run at every start — calling it twice both succeeds.
test(bootstrap_is_safe_to_repeat, [setup(causal_core_reset)]) :-
    % The first boot succeeds, its printed summary discarded.
    with_output_to(string(_), hr_bootstrap),
    % A second boot over the now-populated stores also succeeds.
    with_output_to(string(_), hr_bootstrap).

% Close the test block for history_refs.
:- end_tests(history_refs).
