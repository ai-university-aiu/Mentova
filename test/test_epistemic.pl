/*  Mentova — Epistemic Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/epistemic.pl, which exports
    mentova_epistemic/3 — a glass-box epistemic reasoner that distinguishes
    what an agent KNOWS (justified, with a confidence) from what it merely
    BELIEVES (a truth value, possibly contested), reports IGNORANCE of a
    proposition, tests COMMON KNOWLEDGE across all agents, inventories an
    agent's knowledge, and runs the Sally-Anne FALSE-BELIEF test. It reads
    static knows/3 facts from its own module and static believes/3 facts from
    the small_world knowledge base, so no dynamic state setup is required.

    Every expected value below is computed by hand from the module's clauses
    and the two knowledge bases:
      knows(mentor, birds_have_feathers, 1.0), knows(alice, canary_is_yellow, 0.9),
      knows(bob, dogs_bark, 1.0); believes(sally, marble_in_basket, true),
      believes(anne, marble_in_basket, false); all_agents([mentor, alice, bob]).

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_epistemic.pl
*/

% Declare this file as a test module with no exports.
:- module(test_epistemic, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(epistemic)).

% Open the test block for the epistemic module.
:- begin_tests(epistemic).

% AC-EPI-001: a known fact returns knows/3 with its confidence and a knowledge justification.
test(known_fact_returns_confidence_and_justification) :-
    % Ask what the mentor knows about birds having feathers.
    mentova_epistemic(knows(mentor, birds_have_feathers), Result, Justification),
    % The result is the knows/3 fact, binding the reported confidence for the check below.
    Result = knows(mentor, birds_have_feathers, Confidence),
    % The mentor's confidence in this fact is the certain 1.0.
    assertion(Confidence =:= 1.0),
    % The justification names the knowledge and echoes that same confidence.
    assertion(Justification = just(epistemic(knowledge(mentor, birds_have_feathers),
                                             confidence(1.0)))).

% AC-EPI-002: a fractional-confidence known fact reports its exact stored confidence.
test(fractional_confidence_is_reported_exactly) :-
    % Ask what alice knows about the canary being yellow.
    mentova_epistemic(knows(alice, canary_is_yellow), Result, _Justification),
    % The result carries alice's stored confidence, bound here for the check below.
    Result = knows(alice, canary_is_yellow, Confidence),
    % Alice holds this belief with the stored 0.9 confidence, not the certain 1.0.
    assertion(Confidence =:= 0.9).

% AC-EPI-003: querying a fact an agent has no knowledge of yields does_not_know.
test(absent_knowledge_yields_does_not_know) :-
    % Ask whether bob knows that birds have feathers, a fact only the mentor holds.
    mentova_epistemic(knows(bob, birds_have_feathers), Result, _Justification),
    % Because there is no knows(bob, birds_have_feathers, _) fact, the reasoner reports ignorance of it.
    assertion(Result == does_not_know(bob, birds_have_feathers)).

% AC-EPI-004: a belief returns believes/3 with its truth value and a belief justification.
test(belief_returns_truth_value_and_justification) :-
    % Ask what sally believes about the marble being in the basket (the Sally-Anne setup).
    mentova_epistemic(believes(sally, marble_in_basket), Result, Justification),
    % Sally believes the marble is in the basket, so the truth value is true.
    assertion(Result == believes(sally, marble_in_basket, true)),
    % The justification names the belief and carries that truth value as its confidence slot.
    assertion(Justification == just(epistemic(belief(sally, marble_in_basket),
                                              confidence(true)))).

% AC-EPI-005: an agent with neither knowledge nor belief of a fact is ignorant of it.
test(no_knowledge_and_no_belief_is_ignorance) :-
    % Bob has no knows fact and no believes fact for birds having feathers.
    mentova_epistemic(ignorant(bob, birds_have_feathers), Result, Justification),
    % The reasoner confirms bob is ignorant of the proposition.
    assertion(Result == ignorant(bob, birds_have_feathers)),
    % The justification records the reason as having neither knowledge nor belief.
    assertion(Justification == just(epistemic(ignorance(bob, birds_have_feathers),
                                              reason(no_knowledge_or_belief)))).

% AC-EPI-006: an agent that knows a fact is reported as not ignorant of it.
test(knowing_a_fact_defeats_ignorance) :-
    % The mentor does know that birds have feathers.
    mentova_epistemic(ignorant(mentor, birds_have_feathers), Result, _Justification),
    % So the ignorance check reports that the mentor is not ignorant of it.
    assertion(Result == not_ignorant(mentor, birds_have_feathers)).

% AC-EPI-007: a fact not known by every agent is not common knowledge.
test(fact_not_shared_by_all_agents_is_not_common) :-
    % Only the mentor knows birds have feathers; alice and bob do not.
    mentova_epistemic(common_knowledge(birds_have_feathers), Result, _Justification),
    % Since the forall over all_agents fails, the reasoner reports it is not common knowledge.
    assertion(Result == not_common(birds_have_feathers)).

% AC-EPI-008: an agent's knowledge inventory lists every fact-confidence pair it holds.
test(knowledge_inventory_lists_all_held_facts) :-
    % Ask for the mentor's full knowledge inventory.
    mentova_epistemic(what_does(mentor, know), Result, _Justification),
    % The result is the inventory term, binding the fact-confidence list for the checks below.
    Result = knowledge(mentor, Facts),
    % The mentor holds exactly four known facts.
    assertion(length(Facts, 4)),
    % Birds-have-feathers is present with certain confidence.
    assertion(memberchk(birds_have_feathers-1.0, Facts)),
    % Fire-is-hot is present with certain confidence.
    assertion(memberchk(fire_is_hot-1.0, Facts)),
    % The made-up fact the mentor never learned is absent from the inventory.
    assertion(\+ memberchk(dogs_bark-_, Facts)).

% AC-EPI-009: the Sally-Anne false-belief test flags a belief that other agents contradict.
test(sally_anne_false_belief_is_detected) :-
    % Sally believes the marble is in the basket; anne, who moved it, believes it is not.
    once(mentova_epistemic(false_belief(sally, marble_in_basket), Result, _Justification)),
    % The reasoner reports sally's own true belief and that others differ.
    assertion(Result == false_belief(sally, marble_in_basket,
                                     their_belief(true), others_differ)).

% AC-EPI-010: an agent holding no belief about a proposition triggers no false-belief report.
test(no_belief_means_no_false_belief) :-
    % The mentor holds no believes fact about the marble at all.
    assertion(\+ mentova_epistemic(false_belief(mentor, marble_in_basket), _Result, _Justification)).

% Close the test block for the epistemic module.
:- end_tests(epistemic).
