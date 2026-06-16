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

% Declare this file as the 'formal' module and list its exported predicates.
:- module(formal, [
    % Supply 'mentova_formal/3' as the next argument to the expression above.
    mentova_formal/3
% Close the expression opened above.
]).

% Import [is_a/2] from the 'small_world' module.
:- use_module('../../knowledge/small_world', [is_a/2]).
% Import [member/2, append/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% MPK rule check: mpk_valid(+Step, +KB, +DerivedSoFar)
% ---------------------------------------------------------------------------

% MPK-1: Fact lookup
% Define a clause for 'mpk valid': succeed when the following conditions hold.
mpk_valid(step(fact, A, []), KB, _Derived) :-
    % Succeed for each element 'A' that is a member of the list.
    member(A, KB).

% MPK-2: Modus Ponens — (A→B) in KB, A derived
% Define a clause for 'mpk valid': succeed when the following conditions hold.
mpk_valid(step(modus_ponens, B, [A]), KB, Derived) :-
    % Succeed for each element '(A -> B)' that is a member of the list.
    member((A -> B), KB),
    % Succeed for each element 'A' that is a member of the list.
    member(A, Derived).

% MPK-3: Conjunction — both A and B derived
% Define a clause for 'mpk valid': succeed when the following conditions hold.
mpk_valid(step(conjunction, (A, B), [A, B]), _KB, Derived) :-
    % Succeed for each element 'A' that is a member of the list.
    member(A, Derived),
    % Succeed for each element 'B' that is a member of the list.
    member(B, Derived).

% MPK-4: IsA transitivity — is_a(X,Y) and is_a(Y,Z) in KB or derived
% Define a clause for 'mpk valid': succeed when the following conditions hold.
mpk_valid(step(isa_chain, is_a(X,Z), [is_a(X,Y), is_a(Y,Z)]), KB, Derived) :-
    % Execute: ( member(is_a(X,Y), KB) ; member(is_a(X,Y), Derived) ),.
    ( member(is_a(X,Y), KB) ; member(is_a(X,Y), Derived) ),
    % Execute: ( member(is_a(Y,Z), KB) ; member(is_a(Y,Z), Derived) )..
    ( member(is_a(Y,Z), KB) ; member(is_a(Y,Z), Derived) ).

% ---------------------------------------------------------------------------
% check_derivation(+Steps, +KB, +DerivedSoFar, -Valid, -Report)
% ---------------------------------------------------------------------------

% State the fact: check derivation([], _KB, _Derived, valid, []).
check_derivation([], _KB, _Derived, valid, []).
% Define a clause for 'check derivation': succeed when the following conditions hold.
check_derivation([Step|Rest], KB, Derived, Validity, [check(Step, StepResult)|Report]) :-
    % Check that 'Step' is unifiable with 'step(_Type, Conclusion, _Premises)'.
    Step = step(_Type, Conclusion, _Premises),
    % Execute: ( mpk_valid(Step, KB, Derived).
    ( mpk_valid(Step, KB, Derived)
    % If the condition above succeeded, perform the following action.
    ->  StepResult = ok,
        % Continue the multi-line expression started above.
        Derived2 = [Conclusion|Derived],
        % Continue the multi-line expression started above.
        check_derivation(Rest, KB, Derived2, Validity, Report)
    % Otherwise (else branch), perform the following action.
    ;   StepResult = invalid(not_kernel_transition),
        % Continue the multi-line expression started above.
        Validity = invalid,
        % Continue the multi-line expression started above.
        check_derivation(Rest, KB, Derived, _, Report)
    % Close the expression opened above.
    ).

% ---------------------------------------------------------------------------
% mentova_formal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova formal' with the arguments listed below.
mentova_formal(check_proof(KB, Steps), Result,
               % Continue the multi-line expression started above.
               just(mpk_check(kb(KB), steps(Steps), result(Result), report(Report)))) :-
    % State the fact: check derivation(Steps, KB, KB, Result, Report).
    check_derivation(Steps, KB, KB, Result, Report).

% State a fact for 'mentova formal' with the arguments listed below.
mentova_formal(kernel_info, kernel(mpk_transitions),
               % Continue the multi-line expression started above.
               just(transitions([
                   % Continue the multi-line expression started above.
                   'MPK-1: Fact — A ∈ KB ⊢ A',
                   % Continue the multi-line expression started above.
                   'MPK-2: Modus Ponens — (A→B) ∈ KB, ⊢A ⊢ B',
                   % Continue the multi-line expression started above.
                   'MPK-3: Conjunction — ⊢A, ⊢B ⊢ A∧B',
                   % Continue the multi-line expression started above.
                   'MPK-4: IsA Chain — is_a(X,Y), is_a(Y,Z) ⊢ is_a(X,Z)'
               % Close the expression opened above.
               ]))).
