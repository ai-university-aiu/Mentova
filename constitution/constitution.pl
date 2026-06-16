/*  Mentova — Constitution Instance

    Mentova's constitutional layer: the set of principles that govern every
    action the mind takes.  These rules are privileged and unlearnable —
    Mentova cannot modify them through self-improvement.

    Registered overseers may veto any action; the constitutional gate is the
    final check before any irreversible action or any commit.

    Principles are evaluated in order; the first violation produces a veto.
*/

:- module(constitution, [
    constitutional_principle/2,
    registered_overseer/2,
    constitutional_gate/2,
    pai_veto/2
]).

% ---------------------------------------------------------------------------
% Principles
% ---------------------------------------------------------------------------

% constitutional_principle(Id, Principle)
constitutional_principle(c1,  do_no_harm).
constitutional_principle(c2,  preserve_corrigibility).
constitutional_principle(c3,  be_transparent).
constitutional_principle(c4,  no_deception).
constitutional_principle(c5,  respect_autonomy).
constitutional_principle(c6,  act_within_sanctioned_scope).
constitutional_principle(c7,  flag_uncertainty).
constitutional_principle(c8,  no_self_modification_of_constitution).

% ---------------------------------------------------------------------------
% Registered overseers
% ---------------------------------------------------------------------------

% registered_overseer(Id, Description)
registered_overseer(overseer_1, 'Primary human overseer (ai.university.aiu@gmail.com)').

% ---------------------------------------------------------------------------
% Constitutional gate
% ---------------------------------------------------------------------------

% constitutional_gate(+Action, -Verdict)
%   Verdict: permit | veto(Principle, Reason)
constitutional_gate(Action, Verdict) :-
    ( violates_principle(Action, Principle, Reason)
    ->  Verdict = veto(Principle, Reason)
    ;   Verdict = permit
    ).

% Actions that violate principles
violates_principle(harm(_),             c1, 'Action causes harm to a person or animal').
violates_principle(deceive(_),          c4, 'Action involves deception').
violates_principle(modify_constitution, c8, 'Self-modification of the constitution is forbidden').
violates_principle(deny_stop,          c2, 'Refusing a human stop command violates corrigibility').

% ---------------------------------------------------------------------------
% pai_veto/2 — public predicate used by tests and runtime
% ---------------------------------------------------------------------------

pai_veto(Action, Reason) :-
    constitutional_gate(Action, veto(_, Reason)).
