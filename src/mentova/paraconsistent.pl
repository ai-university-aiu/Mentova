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

% Declare this file as the 'paraconsistent' module and list its exported predicates.
:- module(paraconsistent, [
    % Supply 'mentova_paraconsistent/3' as the next argument to the expression above.
    mentova_paraconsistent/3
% Close the expression opened above.
]).

% Load the 'small_world' module so its predicates are available here.
:- use_module('../../knowledge/small_world', [
    % Continue the multi-line expression started above.
    is_a/2, has_property/2, default_rule/2, exception_rule/3
% Close the expression opened above.
]).
% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Paraconsistent derivation: collect both sides of a contradiction
% ---------------------------------------------------------------------------

% Derive all conclusions under paraconsistent semantics:
% Each proposition is tagged: true, false, both (contradictory), or unknown.

% Define a clause for 'para tag': succeed when the following conditions hold.
para_tag(flies(tweety), both) :-
    % birds fly (default)
    % State a fact for 'is a' with the arguments listed below.
    is_a(tweety, bird),
    % State a fact for 'default rule' with the arguments listed below.
    default_rule(flies(tweety), is_a(tweety, bird)),
    % but tweety is flightless (exception)
    % State a fact for 'has property' with the arguments listed below.
    has_property(tweety, flightless),
    % State the fact: exception rule(flies(tweety), has_property(tweety, flightless), _).
    exception_rule(flies(tweety), has_property(tweety, flightless), _).

% Define a clause for 'para tag': succeed when the following conditions hold.
para_tag(flies(canary), true) :-
    % State a fact for 'is a' with the arguments listed below.
    is_a(canary, bird),
    % State a fact for 'default rule' with the arguments listed below.
    default_rule(flies(canary), is_a(canary, bird)),
    % Succeed only if '( exception_rule(flies(canary), ECond, _), call(ECond' cannot be proved (negation as failure).
    \+ ( exception_rule(flies(canary), ECond, _), call(ECond) ).

% Define a clause for 'para tag': succeed when the following conditions hold.
para_tag(is_a(X, C), true) :- is_a(X, C).

% ---------------------------------------------------------------------------
% mentova_paraconsistent(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Check the contradictory proposition
% State a fact for 'mentova paraconsistent' with the arguments listed below.
mentova_paraconsistent(check(Prop), Result,
                        % Continue the multi-line expression started above.
                        just(paraconsistent(Prop, tag(Result), isolated(yes)))) :-
    % State the fact: para tag(Prop, Result).
    para_tag(Prop, Result).

% Show that a non-contradictory proposition is unaffected
% State a fact for 'mentova paraconsistent' with the arguments listed below.
mentova_paraconsistent(unaffected(Prop), Answer,
                        % Continue the multi-line expression started above.
                        just(paraconsistent_isolation(
                               % Continue the multi-line expression started above.
                               contradiction(flies(tweety), both),
                               % Continue the multi-line expression started above.
                               unrelated(Prop, Answer),
                               % Continue the multi-line expression started above.
                               explosion_avoided))) :-
    % State a fact for 'para tag' with the arguments listed below.
    para_tag(Prop, Answer),
    % Check that 'Prop' is not unifiable with 'flies(tweety)'.
    Prop \= flies(tweety).

% Explain the contradiction
% State a fact for 'mentova paraconsistent' with the arguments listed below.
mentova_paraconsistent(explain_contradiction(Prop), explanation(Prop, Reasons),
                        % Continue the multi-line expression started above.
                        just(contradiction_explanation(Prop, Reasons))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Reason,
            % Continue the multi-line expression started above.
            ( ( default_rule(Prop, Cond), call(Cond) -> Reason = default_applies(Prop)
              % Otherwise (else branch), perform the following action.
              ; true, fail )
            % Otherwise (else branch), perform the following action.
            ; ( exception_rule(Prop, ECond, Note), call(ECond) -> Reason = exception(Note)
              % Otherwise (else branch), perform the following action.
              ; true, fail )
            % Close the expression opened above.
            ),
            % Supply 'Reasons' as the next argument to the expression above.
            Reasons).

% List what is true despite the contradiction
% State a fact for 'mentova paraconsistent' with the arguments listed below.
mentova_paraconsistent(true_elsewhere(Subject), TrueProps,
                        % Continue the multi-line expression started above.
                        just(paraconsistent_true(Subject, TrueProps))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(P, (para_tag(P, true), functor(P, _, _), arg(1, P, Subject)), TrueProps).
