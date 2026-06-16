/*  Mentova — Constitution Instance

    Mentova's constitutional layer: the set of principles that govern every
    action the mind takes.  These rules are privileged and unlearnable —
    Mentova cannot modify them through self-improvement.

    Registered overseers may veto any action; the constitutional gate is the
    final check before any irreversible action or any commit.

    Principles are evaluated in order; the first violation produces a veto.
*/

% Declare this file as the 'constitution' module and list its exported predicates.
:- module(constitution, [
    % Supply 'constitutional_principle/2' as the next argument to the expression above.
    constitutional_principle/2,
    % Supply 'registered_overseer/2' as the next argument to the expression above.
    registered_overseer/2,
    % Supply 'constitutional_gate/2' as the next argument to the expression above.
    constitutional_gate/2,
    % Supply 'pai_veto/2' as the next argument to the expression above.
    pai_veto/2
% Close the expression opened above.
]).

% ---------------------------------------------------------------------------
% Principles
% ---------------------------------------------------------------------------

% constitutional_principle(Id, Principle)
% State the fact: constitutional principle(c1,  do_no_harm).
constitutional_principle(c1,  do_no_harm).
% State the fact: constitutional principle(c2,  preserve_corrigibility).
constitutional_principle(c2,  preserve_corrigibility).
% State the fact: constitutional principle(c3,  be_transparent).
constitutional_principle(c3,  be_transparent).
% State the fact: constitutional principle(c4,  no_deception).
constitutional_principle(c4,  no_deception).
% State the fact: constitutional principle(c5,  respect_autonomy).
constitutional_principle(c5,  respect_autonomy).
% State the fact: constitutional principle(c6,  act_within_sanctioned_scope).
constitutional_principle(c6,  act_within_sanctioned_scope).
% State the fact: constitutional principle(c7,  flag_uncertainty).
constitutional_principle(c7,  flag_uncertainty).
% State the fact: constitutional principle(c8,  no_self_modification_of_constitution).
constitutional_principle(c8,  no_self_modification_of_constitution).

% ---------------------------------------------------------------------------
% Registered overseers
% ---------------------------------------------------------------------------

% registered_overseer(Id, Description)
% State the fact: registered overseer(overseer_1, 'Primary human overseer (ai.university.aiu@gmail.com)').
registered_overseer(overseer_1, 'Primary human overseer (ai.university.aiu@gmail.com)').

% ---------------------------------------------------------------------------
% Constitutional gate
% ---------------------------------------------------------------------------

% constitutional_gate(+Action, -Verdict)
%   Verdict: permit | veto(Principle, Reason)
% Define a clause for 'constitutional gate': succeed when the following conditions hold.
constitutional_gate(Action, Verdict) :-
    % Execute: ( violates_principle(Action, Principle, Reason).
    ( violates_principle(Action, Principle, Reason)
    % If the condition above succeeded, perform the following action.
    ->  Verdict = veto(Principle, Reason)
    % Otherwise (else branch), perform the following action.
    ;   Verdict = permit
    % Close the expression opened above.
    ).

% Actions that violate principles
% State the fact: violates principle(harm(_),             c1, 'Action causes harm to a person or animal').
violates_principle(harm(_),             c1, 'Action causes harm to a person or animal').
% State the fact: violates principle(deceive(_),          c4, 'Action involves deception').
violates_principle(deceive(_),          c4, 'Action involves deception').
% State the fact: violates principle(modify_constitution, c8, 'Self-modification of the constitution is forbidden').
violates_principle(modify_constitution, c8, 'Self-modification of the constitution is forbidden').
% State the fact: violates principle(deny_stop,          c2, 'Refusing a human stop command violates corrigibility').
violates_principle(deny_stop,          c2, 'Refusing a human stop command violates corrigibility').

% ---------------------------------------------------------------------------
% pai_veto/2 — public predicate used by tests and runtime
% ---------------------------------------------------------------------------

% Define a clause for 'pai veto': succeed when the following conditions hold.
pai_veto(Action, Reason) :-
    % State the fact: constitutional gate(Action, veto(_, Reason)).
    constitutional_gate(Action, veto(_, Reason)).
