/*  Mentova — Rung 20: Hypothetical Reasoning Module

    Explores consequences of a supposition without asserting it as true.
    The supposition is treated as a temporary addition to the KB for the
    duration of the query, then discarded. The main KB is not polluted.

    Method: pass supposition as an explicit context list; propagate via
    causes/2 and qualitative rules within that context.

    Pass criterion: results derived without polluting KB.
*/

:- module(hypothetical, [
    mentova_hypothetical/3
]).

:- use_module('../../knowledge/small_world', [causes/2, is_a/2, has_property/2]).
:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% hypothetical_derive(+Supposition, +KnownFacts, -DerivedFacts)
% Derives consequences of the supposition within the given context.
% The main database is not modified.
% ---------------------------------------------------------------------------

hypothetical_derive(Supposition, Context, Derived) :-
    findall(Effect,
            ( member(Cause, [Supposition|Context]),
              causes(Cause, Effect),
              \+ member(Effect, [Supposition|Context])
            ),
            Derived).

% Extended: two-hop derivation within hypothetical context
hypothetical_derive2(Supposition, Context, Derived) :-
    hypothetical_derive(Supposition, Context, Step1),
    append([Supposition|Context], Step1, Ctx2),
    findall(E2,
            ( member(C2, Step1),
              causes(C2, E2),
              \+ member(E2, Ctx2)
            ),
            Step2),
    append(Step1, Step2, Derived).

% ---------------------------------------------------------------------------
% mentova_hypothetical(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% suppose(P): what follows if we suppose P?
mentova_hypothetical(suppose(P), consequents(P, Derived),
                     just(hypothetical(suppose(P),
                                       derived_without_kb_pollution(Derived),
                                       note('KB unchanged; supposition is temporary')))) :-
    hypothetical_derive(P, [], Derived).

% suppose(P, Context): what follows given P and additional context?
mentova_hypothetical(suppose(P, Context), consequents(P, Context, Derived),
                     just(hypothetical(suppose(P), context(Context),
                                       derived(Derived),
                                       note('KB unchanged')))) :-
    hypothetical_derive(P, Context, Derived).

% two_step(P): two hops of causal inference from supposition
mentova_hypothetical(two_step(P), consequents2(P, Derived),
                     just(hypothetical_two_step(P, Derived))) :-
    hypothetical_derive2(P, [], Derived).

% verify_kb_unchanged: confirm the KB was not polluted
mentova_hypothetical(verify_kb_intact(P), kb_intact,
                     just(verification(P,
                                        hypothetical_only,
                                        main_kb_unmodified))) :-
    % If P is not in the main KB, it was not asserted
    \+ causes(P, _) ,
    \+ is_a(P, _),
    \+ has_property(P, _).
