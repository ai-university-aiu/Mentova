/*  Mentova — Formal Reasoning Module Test Suite

    Behavioural PLUnit tests for the single exported predicate
    mentova_formal/3 of src/mentova/formal.pl. The module checks a
    derivation against the Minimal PrologAI Kernel (MPK), whose only
    allowed proof transitions are MPK-1 Fact (A in KB), MPK-2 Modus
    Ponens ((A->B) in KB and A derived), MPK-3 Conjunction (A and B
    derived), and MPK-4 IsA Chain (is_a(X,Y) and is_a(Y,Z) known). A
    proof is a list of step(Type, Conclusion, Premises); the checker
    returns valid or invalid and a glass-box report naming each step's
    verdict. The kernel_info query returns the four transitions verbatim.

    Run with the full PrologAI library path plus the Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_formal.pl
*/

% Declare this file as the test module with no exports.
:- module(test_formal, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the formal reasoning module under test from the library path.
:- use_module(library(formal)).

% Open the test block for the formal module.
:- begin_tests(formal).

% AC-FORMAL-001: the kernel_info query returns the kernel name and its four transitions verbatim.
test(kernel_info_lists_the_four_mpk_transitions) :-
    % Ask the module to describe the Minimal PrologAI Kernel.
    mentova_formal(kernel_info, Result, Justification),
    % The result names the kernel by its transition set.
    assertion(Result == kernel(mpk_transitions)),
    % The justification carries the transition list under a transitions/1 wrapper.
    Justification = just(transitions(Transitions)),
    % Exactly the four MPK transitions are documented, no more and no fewer.
    assertion(length(Transitions, 4)),
    % The Fact transition MPK-1 is present.
    assertion(memberchk('MPK-1: Fact — A ∈ KB ⊢ A', Transitions)),
    % The Modus Ponens transition MPK-2 is present.
    assertion(memberchk('MPK-2: Modus Ponens — (A→B) ∈ KB, ⊢A ⊢ B', Transitions)).

% AC-FORMAL-002: a fact-then-modus-ponens proof is accepted and every step is reported ok.
test(valid_modus_ponens_proof_is_accepted) :-
    % A knowledge base holding the atom a and the rule a implies b.
    KB = [a, (a -> b)],
    % Derive a by MPK-1, then derive b by MPK-2 from the rule and a.
    Steps = [step(fact, a, []), step(modus_ponens, b, [a])],
    % Check the derivation against the kernel.
    mentova_formal(check_proof(KB, Steps), Result, Justification),
    % Every step is a kernel transition, so the proof is valid.
    assertion(Result == valid),
    % The glass-box justification echoes the knowledge base, the steps, the verdict, and the per-step report.
    Justification = just(mpk_check(kb(KB), steps(Steps), result(valid), report(Report))),
    % The report holds one verdict per step.
    assertion(length(Report, 2)),
    % The fact step passed.
    assertion(memberchk(check(step(fact, a, []), ok), Report)),
    % The modus-ponens step passed.
    assertion(memberchk(check(step(modus_ponens, b, [a]), ok), Report)).

% AC-FORMAL-003: a modus-ponens step whose implication is absent from the knowledge base is rejected.
test(modus_ponens_without_the_rule_is_rejected) :-
    % A knowledge base holding only the atom a, with no implication.
    KB = [a],
    % Attempt to derive b by modus ponens, which needs an (a -> b) rule that is not present.
    Steps = [step(modus_ponens, b, [a])],
    % Check the derivation against the kernel.
    mentova_formal(check_proof(KB, Steps), Result, Justification),
    % The step is not a licensed kernel transition, so the proof is invalid.
    assertion(Result == invalid),
    % The justification carries the verdict and the offending step's report.
    Justification = just(mpk_check(kb(KB), steps(Steps), result(invalid), report(Report))),
    % The single step is marked invalid for using no kernel transition.
    assertion(Report == [check(step(modus_ponens, b, [a]), invalid(not_kernel_transition))]).

% AC-FORMAL-004: an is_a chain over two knowledge-base links is accepted by MPK-4.
test(isa_chain_transitivity_is_accepted) :-
    % A knowledge base with the two links dog is_a mammal and mammal is_a animal.
    KB = [is_a(dog, mammal), is_a(mammal, animal)],
    % Conclude dog is_a animal by chaining the two links.
    Steps = [step(isa_chain, is_a(dog, animal), [is_a(dog, mammal), is_a(mammal, animal)])],
    % Check the derivation against the kernel.
    mentova_formal(check_proof(KB, Steps), Result, _Justification),
    % The chain is a licensed MPK-4 transition, so the proof is valid.
    assertion(Result == valid).

% AC-FORMAL-005: two facts followed by their conjunction is accepted by MPK-3.
test(conjunction_of_two_facts_is_accepted) :-
    % A knowledge base holding the atoms x and y.
    KB = [x, y],
    % Derive x, derive y, then combine them into the conjunction x and y.
    Steps = [step(fact, x, []), step(fact, y, []), step(conjunction, (x, y), [x, y])],
    % Check the derivation against the kernel.
    mentova_formal(check_proof(KB, Steps), Result, Justification),
    % All three steps are kernel transitions, so the proof is valid.
    assertion(Result == valid),
    % The report records a verdict for each of the three steps.
    Justification = just(mpk_check(_, _, result(valid), report(Report))),
    % There are exactly three per-step verdicts.
    assertion(length(Report, 3)),
    % The conjunction step passed.
    assertion(memberchk(check(step(conjunction, (x, y), [x, y]), ok), Report)).

% AC-FORMAL-006: a valid step followed by an invalid one fails the whole proof yet keeps the good step's ok verdict.
test(mixed_proof_invalidates_but_reports_each_step) :-
    % A knowledge base with the atom a and the rule a implies b.
    KB = [a, (a -> b)],
    % Derive a validly, then try to derive c by modus ponens with no (a -> c) rule.
    Steps = [step(fact, a, []), step(modus_ponens, c, [a])],
    % Check the derivation against the kernel.
    mentova_formal(check_proof(KB, Steps), Result, Justification),
    % One bad step is enough to invalidate the whole derivation.
    assertion(Result == invalid),
    % The glass-box report still distinguishes the good step from the bad one.
    Justification = just(mpk_check(_, _, result(invalid), report(Report))),
    % The first step remains reported ok.
    assertion(memberchk(check(step(fact, a, []), ok), Report)),
    % The second step is reported invalid for using no kernel transition.
    assertion(memberchk(check(step(modus_ponens, c, [a]), invalid(not_kernel_transition)), Report)).

% Close the test block for the formal module.
:- end_tests(formal).
