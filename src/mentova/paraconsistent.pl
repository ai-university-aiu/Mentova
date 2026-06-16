/*  Mentova — Rung 18: Paraconsistent Reasoning Module

    Reasons despite a contradiction — a contradictory pair does not collapse
    all other conclusions (ex contradictione quodlibet avoided).

    The Small-World KB has a deliberate contradiction for tweety:
      - is_a(tweety, bird) and default_rule(flies(X), is_a(X, bird))
        → flies(tweety) (default)
      - has_property(tweety, flightless) and exception_rule(flies(X), ...)
        → does_not_fly(tweety) (exception)

    Paraconsistent treatment: isolate the contradiction, label both conclusions,
    and continue reasoning about unrelated propositions without explosion.

    Pass criterion: contradictory pair does not collapse all other conclusions.
*/

:- module(paraconsistent, [
    mentova_paraconsistent/3
]).

:- use_module('../../knowledge/small_world', [
    is_a/2, has_property/2, default_rule/2, exception_rule/3
]).
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Paraconsistent derivation: collect both sides of a contradiction
% ---------------------------------------------------------------------------

% Derive all conclusions under paraconsistent semantics:
% Each proposition is tagged: true, false, both (contradictory), or unknown.

para_tag(flies(tweety), both) :-
    % birds fly (default)
    is_a(tweety, bird),
    default_rule(flies(tweety), is_a(tweety, bird)),
    % but tweety is flightless (exception)
    has_property(tweety, flightless),
    exception_rule(flies(tweety), has_property(tweety, flightless), _).

para_tag(flies(canary), true) :-
    is_a(canary, bird),
    default_rule(flies(canary), is_a(canary, bird)),
    \+ ( exception_rule(flies(canary), ECond, _), call(ECond) ).

para_tag(is_a(X, C), true) :- is_a(X, C).

% ---------------------------------------------------------------------------
% mentova_paraconsistent(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Check the contradictory proposition
mentova_paraconsistent(check(Prop), Result,
                        just(paraconsistent(Prop, tag(Result), isolated(yes)))) :-
    para_tag(Prop, Result).

% Show that a non-contradictory proposition is unaffected
mentova_paraconsistent(unaffected(Prop), Answer,
                        just(paraconsistent_isolation(
                               contradiction(flies(tweety), both),
                               unrelated(Prop, Answer),
                               explosion_avoided))) :-
    para_tag(Prop, Answer),
    Prop \= flies(tweety).

% Explain the contradiction
mentova_paraconsistent(explain_contradiction(Prop), explanation(Prop, Reasons),
                        just(contradiction_explanation(Prop, Reasons))) :-
    findall(Reason,
            ( ( default_rule(Prop, Cond), call(Cond) -> Reason = default_applies(Prop)
              ; true, fail )
            ; ( exception_rule(Prop, ECond, Note), call(ECond) -> Reason = exception(Note)
              ; true, fail )
            ),
            Reasons).

% List what is true despite the contradiction
mentova_paraconsistent(true_elsewhere(Subject), TrueProps,
                        just(paraconsistent_true(Subject, TrueProps))) :-
    findall(P, (para_tag(P, true), functor(P, _, _), arg(1, P, Subject)), TrueProps).
