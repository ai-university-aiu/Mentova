/*  Mentova — Hypothetical Reasoning Module Test Suite  (Rung 20)

    Behavioural PLUnit suite for src/mentova/hypothetical.pl, which explores
    the consequences of a supposition WITHOUT asserting it as true: the
    supposition is carried as a temporary context list and propagated through
    the causes/2 graph of knowledge/small_world.pl, so the main knowledge base
    is never polluted.

    The module exports one predicate, mentova_hypothetical/3, serving four
    query shapes:
      - suppose(P)            -> consequents(P, Derived)         : direct effects
      - suppose(P, Context)   -> consequents(P, Context, Derived): effects of P
                                                                   or any context item
      - two_step(P)           -> consequents2(P, Derived)        : up to two hops
      - verify_kb_intact(P)   -> kb_intact                       : P absent from KB

    Every expected result below is computed by hand from the seven causes/2
    facts in small_world.pl:
        rain->wet_ground, sprinkler->wet_ground, fire->smoke, hunger->eating,
        exercise->fatigue, illness->fatigue, sunlight->plant_growth.
    All seven effects are terminal (none is itself a cause), which the
    two-step test relies on.

    Run with the full PrologAI library path plus the Mentova source:
        swipl <libs> -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" test/test_hypothetical.pl
*/

% Declare this file as the test module with no exports.
:- module(test_hypothetical, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the hypothetical reasoning module under test from the library path.
:- use_module(library(hypothetical)).

% Open the test block for the hypothetical module.
:- begin_tests(hypothetical).

% A bare supposition derives exactly its one direct causal effect, with a pollution-free justification.
test(suppose_single_derives_direct_effect) :-
    % Suppose that it rains and read back the result and its justification.
    mentova_hypothetical(suppose(rain), Result, Justification),
    % Supposing rain derives exactly its single direct effect, wet ground.
    assertion(Result == consequents(rain, [wet_ground])),
    % The justification names the supposition, its pollution-free derivation, and the KB-unchanged note.
    assertion(Justification == just(hypothetical(suppose(rain),
                                    % Name the pollution-free derivation of wet ground.
                                    derived_without_kb_pollution([wet_ground]),
                                    % Add the note that the KB stays unchanged since the supposition is temporary.
                                    note('KB unchanged; supposition is temporary')))).

% A second, different supposition proves the effect is genuinely queried from causes/2, not hard-coded.
test(suppose_single_queries_graph_not_constant) :-
    % Suppose a fire has started and read back its derived effects.
    mentova_hypothetical(suppose(fire), Result, _),
    % Supposing fire derives exactly its single direct effect, smoke.
    assertion(Result == consequents(fire, [smoke])).

% A supposition whose atom causes nothing derives an empty effect list.
test(suppose_single_no_effect_is_empty) :-
    % Suppose a canary, an atom that heads no causes/2 fact, and read the result.
    mentova_hypothetical(suppose(canary), Result, _),
    % With no causal edge out of canary the derived list is empty.
    assertion(Result == consequents(canary, [])).

% Adding context makes the supposition collect the effects of every context item as well.
test(suppose_with_context_collects_all_causes) :-
    % Suppose rain in the added context of a fire, and read the result and justification.
    mentova_hypothetical(suppose(rain, [fire]), Result, Justification),
    % Rain contributes wet ground and the context fire contributes smoke, in that order.
    assertion(Result == consequents(rain, [fire], [wet_ground, smoke])),
    % The justification carries the supposition, the context, the derivation, and the KB-unchanged note.
    assertion(Justification == just(hypothetical(suppose(rain),
                                    % Name the added context of the fire supposition.
                                    context([fire]),
                                    % Name the combined derivation of wet ground and smoke.
                                    derived([wet_ground, smoke]),
                                    % Add the note that the knowledge base stays unchanged.
                                    note('KB unchanged')))).

% Two different causes of the same effect both contribute, so the effect appears twice — the derivation is not de-duplicated.
test(suppose_context_keeps_duplicate_effects) :-
    % Suppose exercise in the added context of illness, both of which cause fatigue.
    mentova_hypothetical(suppose(exercise, [illness]), Result, _),
    % Both causes fire, so fatigue is collected once per cause.
    assertion(Result == consequents(exercise, [illness], [fatigue, fatigue])).

% Two-step derivation from a supposition whose effect is terminal yields just that first-hop effect.
test(two_step_terminal_effect_has_no_second_hop) :-
    % Ask for up to two hops of consequence from supposing rain.
    mentova_hypothetical(two_step(rain), Result, Justification),
    % Wet ground causes nothing further, so the two-step result is just the first hop.
    assertion(Result == consequents2(rain, [wet_ground])),
    % The two-step justification names the supposition and its derived list.
    assertion(Justification == just(hypothetical_two_step(rain, [wet_ground]))).

% verify_kb_intact succeeds for an atom that appears in no causes/2, is_a/2, or has_property/2 fact.
test(verify_kb_intact_true_for_absent_atom) :-
    % Check that griffin, an atom absent from the whole knowledge base, is confirmed intact.
    mentova_hypothetical(verify_kb_intact(griffin), Result, Justification),
    % The result reports the knowledge base intact.
    assertion(Result == kb_intact),
    % The justification records that griffin exists hypothetically only and the main KB is unmodified.
    assertion(Justification == just(verification(griffin, hypothetical_only, main_kb_unmodified))).

% verify_kb_intact fails for an atom that IS in the KB, here rain, which heads a causes/2 fact.
test(verify_kb_intact_fails_for_known_cause, [fail]) :-
    % rain is a real cause in the KB, so the intact check has no solution and must fail.
    mentova_hypothetical(verify_kb_intact(rain), _, _).

% The module's headline promise: exploring a supposition never asserts it, so the KB stays intact afterwards.
test(supposition_does_not_pollute_kb) :-
    % Before exploring, confirm the novel atom griffin is absent from the knowledge base.
    mentova_hypothetical(verify_kb_intact(griffin), kb_intact, _),
    % Explore a supposition about griffin, which causes nothing and so derives an empty list.
    mentova_hypothetical(suppose(griffin), consequents(griffin, Derived), _),
    % The exploration derived no effects.
    assertion(Derived == []),
    % After exploring, griffin is still absent — the supposition was temporary and asserted nothing.
    mentova_hypothetical(verify_kb_intact(griffin), kb_intact, _).

% Close the test block for the hypothetical module.
:- end_tests(hypothetical).
