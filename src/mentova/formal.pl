/*  Mentova — Rung 13: Formal Reasoning Module

    Checks a derivation against the Minimal PrologAI Kernel (MPK).
    The MPK defines the only allowed proof transitions:

        MPK-1  Fact:       A ∈ KB  ⊢  A
        MPK-2  Modus Ponens: (A → B) ∈ KB, ⊢ A  ⊢  B
        MPK-3  Conjunction: ⊢ A, ⊢ B  ⊢  A ∧ B
        MPK-4  IsA Chain:   is_a(X,Y) ∈ KB, is_a(Y,Z) ∈ KB  ⊢  is_a(X,Z)

    A derivation is a list of steps: step(Type, Conclusion, Premises).
    The checker verifies each step uses only MPK transitions and that
    premises are in scope at each point.

    Pass criterion: proof uses only kernel transitions.
*/

:- module(formal, [
    mentova_formal/3
]).

:- use_module('../../knowledge/small_world', [is_a/2]).
:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% MPK rule check: mpk_valid(+Step, +KB, +DerivedSoFar)
% ---------------------------------------------------------------------------

% MPK-1: Fact lookup
mpk_valid(step(fact, A, []), KB, _Derived) :-
    member(A, KB).

% MPK-2: Modus Ponens — (A→B) in KB, A derived
mpk_valid(step(modus_ponens, B, [A]), KB, Derived) :-
    member((A -> B), KB),
    member(A, Derived).

% MPK-3: Conjunction — both A and B derived
mpk_valid(step(conjunction, (A, B), [A, B]), _KB, Derived) :-
    member(A, Derived),
    member(B, Derived).

% MPK-4: IsA transitivity — is_a(X,Y) and is_a(Y,Z) in KB or derived
mpk_valid(step(isa_chain, is_a(X,Z), [is_a(X,Y), is_a(Y,Z)]), KB, Derived) :-
    ( member(is_a(X,Y), KB) ; member(is_a(X,Y), Derived) ),
    ( member(is_a(Y,Z), KB) ; member(is_a(Y,Z), Derived) ).

% ---------------------------------------------------------------------------
% check_derivation(+Steps, +KB, +DerivedSoFar, -Valid, -Report)
% ---------------------------------------------------------------------------

check_derivation([], _KB, _Derived, valid, []).
check_derivation([Step|Rest], KB, Derived, Validity, [check(Step, StepResult)|Report]) :-
    Step = step(_Type, Conclusion, _Premises),
    ( mpk_valid(Step, KB, Derived)
    ->  StepResult = ok,
        Derived2 = [Conclusion|Derived],
        check_derivation(Rest, KB, Derived2, Validity, Report)
    ;   StepResult = invalid(not_kernel_transition),
        Validity = invalid,
        check_derivation(Rest, KB, Derived, _, Report)
    ).

% ---------------------------------------------------------------------------
% mentova_formal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_formal(check_proof(KB, Steps), Result,
               just(mpk_check(kb(KB), steps(Steps), result(Result), report(Report)))) :-
    check_derivation(Steps, KB, KB, Result, Report).

mentova_formal(kernel_info, kernel(mpk_transitions),
               just(transitions([
                   'MPK-1: Fact — A ∈ KB ⊢ A',
                   'MPK-2: Modus Ponens — (A→B) ∈ KB, ⊢A ⊢ B',
                   'MPK-3: Conjunction — ⊢A, ⊢B ⊢ A∧B',
                   'MPK-4: IsA Chain — is_a(X,Y), is_a(Y,Z) ⊢ is_a(X,Z)'
               ]))).
