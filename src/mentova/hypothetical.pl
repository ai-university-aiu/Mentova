/*  Mentova — Rung 20: Hypothetical Reasoning Module

    Explores consequences of a supposition without asserting it as true.
    The supposition is treated as a temporary addition to the KB for the
    duration of the query, then discarded. The main KB is not polluted.

    Method: pass supposition as an explicit context list; propagate via
    causes/2 and qualitative rules within that context.

    Pass criterion: results derived without polluting KB.
*/

% Declare this file as the 'hypothetical' module and list its exported predicates.
:- module(hypothetical, [
    % Supply 'mentova_hypothetical/3' as the next argument to the expression above.
    mentova_hypothetical/3
% Close the expression opened above.
]).

% Import [causes/2, is_a/2, has_property/2] from the 'small_world' module.
:- use_module('../../knowledge/small_world', [causes/2, is_a/2, has_property/2]).
% Import [member/2, append/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% hypothetical_derive(+Supposition, +KnownFacts, -DerivedFacts)
% Derives consequences of the supposition within the given context.
% The main database is not modified.
% ---------------------------------------------------------------------------

% Define a clause for 'hypothetical derive': succeed when the following conditions hold.
hypothetical_derive(Supposition, Context, Derived) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Effect,
            % Continue the multi-line expression started above.
            ( member(Cause, [Supposition|Context]),
              % Continue the multi-line expression started above.
              causes(Cause, Effect),
              % Continue the multi-line expression started above.
              \+ member(Effect, [Supposition|Context])
            % Close the expression opened above.
            ),
            % Supply 'Derived' as the next argument to the expression above.
            Derived).

% Extended: two-hop derivation within hypothetical context
% Define a clause for 'hypothetical derive2': succeed when the following conditions hold.
hypothetical_derive2(Supposition, Context, Derived) :-
    % State a fact for 'hypothetical derive' with the arguments listed below.
    hypothetical_derive(Supposition, Context, Step1),
    % Unify the third argument with the concatenation of the first two lists.
    append([Supposition|Context], Step1, Ctx2),
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(E2,
            % Continue the multi-line expression started above.
            ( member(C2, Step1),
              % Continue the multi-line expression started above.
              causes(C2, E2),
              % Continue the multi-line expression started above.
              \+ member(E2, Ctx2)
            % Close the expression opened above.
            ),
            % Supply 'Step2' as the next argument to the expression above.
            Step2),
    % Unify the third argument with the concatenation of the first two lists.
    append(Step1, Step2, Derived).

% ---------------------------------------------------------------------------
% mentova_hypothetical(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% suppose(P): what follows if we suppose P?
% State a fact for 'mentova hypothetical' with the arguments listed below.
mentova_hypothetical(suppose(P), consequents(P, Derived),
                     % Continue the multi-line expression started above.
                     just(hypothetical(suppose(P),
                                       % Continue the multi-line expression started above.
                                       derived_without_kb_pollution(Derived),
                                       % Continue the multi-line expression started above.
                                       note('KB unchanged; supposition is temporary')))) :-
    % State the fact: hypothetical derive(P, [], Derived).
    hypothetical_derive(P, [], Derived).

% suppose(P, Context): what follows given P and additional context?
% State a fact for 'mentova hypothetical' with the arguments listed below.
mentova_hypothetical(suppose(P, Context), consequents(P, Context, Derived),
                     % Continue the multi-line expression started above.
                     just(hypothetical(suppose(P), context(Context),
                                       % Continue the multi-line expression started above.
                                       derived(Derived),
                                       % Continue the multi-line expression started above.
                                       note('KB unchanged')))) :-
    % State the fact: hypothetical derive(P, Context, Derived).
    hypothetical_derive(P, Context, Derived).

% two_step(P): two hops of causal inference from supposition
% State a fact for 'mentova hypothetical' with the arguments listed below.
mentova_hypothetical(two_step(P), consequents2(P, Derived),
                     % Continue the multi-line expression started above.
                     just(hypothetical_two_step(P, Derived))) :-
    % State the fact: hypothetical derive2(P, [], Derived).
    hypothetical_derive2(P, [], Derived).

% verify_kb_unchanged: confirm the KB was not polluted
% State a fact for 'mentova hypothetical' with the arguments listed below.
mentova_hypothetical(verify_kb_intact(P), kb_intact,
                     % Continue the multi-line expression started above.
                     just(verification(P,
                                        % Supply 'hypothetical_only' as the next argument to the expression above.
                                        hypothetical_only,
                                        % Continue the multi-line expression started above.
                                        main_kb_unmodified))) :-
    % If P is not in the main KB, it was not asserted
    % Succeed only if 'causes(P, _' cannot be proved (negation as failure).
    \+ causes(P, _) ,
    % Succeed only if 'is_a(P, _' cannot be proved (negation as failure).
    \+ is_a(P, _),
    % Succeed only if 'has_property(P, _' cannot be proved (negation as failure).
    \+ has_property(P, _).
