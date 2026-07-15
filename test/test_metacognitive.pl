/*  Mentova — Metacognitive Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/metacognitive.pl, which exports
    mentova_metacognitive/3 — a glass-box self-model that reports which of
    Mentova's reasoning capabilities apply to a query and how confident it
    is. The module holds a static capability(Tag, Description, Confidence)
    registry: 28 tags at high confidence, 2 at limited, 2 at none. The
    exported predicate answers four query shapes over that registry:
    what_can_i_do, confidence_for(Tag), self_describe, and can_i_do(Tag),
    each returning a result term and a glass-box justification term.

    Every expected value below is computed by hand from the registry, so
    the tests fail if a capability row is added, removed, or re-graded.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_metacognitive.pl
*/

% Declare this file as a test module with no exports.
:- module(test_metacognitive, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(metacognitive)).

% Open the test block for the metacognitive module.
:- begin_tests(metacognitive).

% AC-META-001: what_can_i_do lists exactly the 28 high-confidence capability tags.
test(what_can_i_do_lists_all_high_capabilities) :-
    % Ask the self-model which capabilities are active.
    mentova_metacognitive(what_can_i_do, caps(Caps), _Justification),
    % The registry declares exactly 28 tags at high confidence.
    length(Caps, N),
    % That count is fixed by the registry and must match exactly.
    assertion(N =:= 28),
    % A representative high-confidence tag is present.
    assertion(memberchk(bayes, Caps)),
    % Another high-confidence tag is present.
    assertion(memberchk(causal, Caps)),
    % The last-listed high-confidence tag is present.
    assertion(memberchk(dialectical, Caps)),
    % A 'none'-graded gap (vision) is NOT reported as an active capability.
    assertion(\+ memberchk(vision, Caps)),
    % A 'limited'-graded gap is NOT reported among the high-confidence set.
    assertion(\+ memberchk(inductive_general, Caps)).

% AC-META-002: the what_can_i_do justification wraps the same capability list.
test(what_can_i_do_justification_names_capabilities) :-
    % Ask the self-model which capabilities are active.
    mentova_metacognitive(what_can_i_do, caps(Caps), Justification),
    % The documented justification is the active-capabilities term over that list.
    assertion(Justification == just(metacognitive(active_capabilities, Caps))).

% AC-META-003: confidence_for a known high-confidence tag returns 'high'.
test(confidence_for_high_capability) :-
    % Query Mentova's confidence in Bayesian reasoning.
    mentova_metacognitive(confidence_for(bayes), conf(bayes, Conf), Justification),
    % Bayes is graded high in the registry.
    assertion(Conf == high),
    % The justification reports the queried tag and the confidence found.
    assertion(Justification == just(metacognitive(confidence_query(bayes), confidence(high)))).

% AC-META-004: confidence_for a declared gap returns its graded 'none'.
test(confidence_for_gap_capability) :-
    % Query Mentova's confidence in image vision.
    mentova_metacognitive(confidence_for(vision), conf(vision, Conf), _Justification),
    % Vision is present in the registry but graded none.
    assertion(Conf == none).

% AC-META-005: confidence_for an unregistered tag falls back to 'unknown'.
test(confidence_for_unregistered_tag) :-
    % Query a tag that appears nowhere in the capability registry.
    mentova_metacognitive(confidence_for(quantum_teleportation), conf(quantum_teleportation, Conf), _Justification),
    % With no matching capability fact, the confidence defaults to unknown.
    assertion(Conf == unknown).

% AC-META-006: self_describe reports the name, the high-capability count, and the platform.
test(self_describe_reports_identity) :-
    % Ask the self-model to describe itself.
    mentova_metacognitive(self_describe, desc(Name, Rungs, Platform), _Justification),
    % The mind identifies itself as mentova.
    assertion(Name == mentova),
    % The rung count equals the 28 high-confidence capabilities.
    assertion(Rungs =:= 28),
    % The platform is prologai.
    assertion(Platform == prologai).

% AC-META-007: can_i_do a high capability answers yes with its exact description.
test(can_i_do_high_capability_yes) :-
    % Ask whether Mentova can do Bayesian reasoning.
    mentova_metacognitive(can_i_do(bayes), Result, Justification),
    % The answer is yes, carrying the registry's description string for bayes.
    assertion(Result == yes_using('Bayesian prior-to-posterior update')),
    % The justification records a positive capability check for the tag.
    assertion(Justification == just(metacognitive(capability_check(bayes), result(yes, desc('Bayesian prior-to-posterior update'))))).

% AC-META-008: can_i_do a limited capability answers 'limited' with its description.
test(can_i_do_limited_capability) :-
    % Ask whether Mentova can do general inductive concept learning.
    mentova_metacognitive(can_i_do(inductive_general), Result, _Justification),
    % Inductive_general is graded limited, so the answer is limited_using its description.
    assertion(Result == limited_using('general inductive concept learning')).

% AC-META-009: can_i_do a 'none'-graded gap answers no / not_implemented.
test(can_i_do_none_capability_no) :-
    % Ask whether Mentova can do image vision.
    mentova_metacognitive(can_i_do(vision), Result, Justification),
    % Vision is graded none, so neither the high nor the limited clause fires; the fallback answers no.
    assertion(Result == answer(no, using(not_implemented))),
    % The fallback justification reports an unknown capability check with a no result.
    assertion(Justification == just(metacognitive(capability_check(unknown), result(no)))).

% AC-META-010: can_i_do an entirely unregistered tag also answers no / not_implemented.
test(can_i_do_unregistered_tag_no) :-
    % Ask about a capability that has no registry row at all.
    mentova_metacognitive(can_i_do(teleportation), Result, _Justification),
    % With no high or limited row, the fallback clause answers no.
    assertion(Result == answer(no, using(not_implemented))).

% Close the test block for the metacognitive module.
:- end_tests(metacognitive).
