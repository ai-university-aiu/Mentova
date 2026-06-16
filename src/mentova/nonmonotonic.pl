/*  Mentova — Rung 17: Non-Monotonic (Defeasible) Reasoning Module

    Implements defeasible reasoning: default rules that can be retracted
    when exceptions apply.

    Pass criterion: "birds fly" withdrawn for penguin with exception named.

    Extends the defeasible framework already in mentova_query/3 with:
      - Full default+exception resolution
      - Explicit exception listing
      - Multiple exception handling
*/

:- module(nonmonotonic, [
    mentova_defeasible/3
]).

:- use_module('../../knowledge/small_world', [
    is_a/2, has_property/2, default_rule/2, exception_rule/3
]).
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% defeasible_conclusion(+Proposition, +Entity, -Status, -Justification)
%
% Status: holds(default) | withdrawn(exception(Name)) | not_applicable
% ---------------------------------------------------------------------------

defeasible_conclusion(flies(X), Status, Just) :-
    ( default_rule(flies(X), Cond),
      call(Cond)
    ->  % Default applies — check for exceptions
        ( findall(Note, (exception_rule(flies(X), ECond, Note), call(ECond)), Exceptions),
          Exceptions \= []
        ->  Exceptions = [ExNote|_],
            Status = withdrawn(exception(ExNote)),
            Just = just(defeasible(flies(X),
                                   default(bird_flies),
                                   exception(ExNote),
                                   conclusion(does_not_fly)))
        ;   Status = holds(default),
            Just = just(defeasible(flies(X),
                                   default(bird_flies),
                                   no_exception_found,
                                   conclusion(flies)))
        )
    ;   Status = not_applicable,
        Just = just(defeasible(flies(X), default(bird_flies), condition_not_met))
    ).

% Generalised defeasible for any proposition
defeasible_conclusion(Prop, Status, Just) :-
    Prop \= flies(_),
    ( default_rule(Prop, Cond),
      call(Cond)
    ->  ( findall(Note, (exception_rule(Prop, ECond, Note), call(ECond)), Exceptions),
          Exceptions \= []
        ->  Exceptions = [ExNote|_],
            Status = withdrawn(exception(ExNote)),
            Just = just(defeasible(Prop, default_applies, exception(ExNote), withdrawn))
        ;   Status = holds(default),
            Just = just(defeasible(Prop, default_applies, no_exception, holds))
        )
    ;   Status = not_applicable,
        Just = just(defeasible(Prop, default_not_applicable))
    ).

% ---------------------------------------------------------------------------
% mentova_defeasible(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_defeasible(query(Prop), Result, Just) :-
    defeasible_conclusion(Prop, Result, Just).
% Accept bare proposition (caller may omit query/1 wrapper)
mentova_defeasible(Prop, Result, Just) :-
    Prop \= query(_), Prop \= exceptions(_), Prop \= is_exception(_,_),
    defeasible_conclusion(Prop, Result, Just).

% List all exceptions for a proposition
mentova_defeasible(exceptions(Prop), exceptions(List),
                   just(all_exceptions(Prop, List))) :-
    findall(exc(Note, Cond),
            exception_rule(Prop, Cond, Note),
            List).

% Check if an entity is an exception
mentova_defeasible(is_exception(Prop, X), Answer,
                   just(exception_check(Prop, X, Answer))) :-
    ( exception_rule(Prop, ECond, Note),
      copy_term(ECond, ECond2),
      ECond2 =.. [_|_],
      call(ECond2)
    ->  Answer = yes_exception(Note)
    ;   Answer = no_exception
    ).
