/*  Mentova — Rung 17: Non-Monotonic (Defeasible) Reasoning Module

    Implements defeasible reasoning: default rules that can be retracted
    when exceptions apply.

    Pass criterion: "birds fly" withdrawn for penguin with exception named.

    Extends the defeasible framework already in mentova_query/3 with:
      - Full default+exception resolution
      - Explicit exception listing
      - Multiple exception handling
*/

% Declare this file as the 'nonmonotonic' module and list its exported predicates.
:- module(nonmonotonic, [
    % Supply 'mentova_defeasible/3' as the next argument to the expression above.
    mentova_defeasible/3
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
% defeasible_conclusion(+Proposition, +Entity, -Status, -Justification)
%
% Status: holds(default) | withdrawn(exception(Name)) | not_applicable
% ---------------------------------------------------------------------------

% Define a clause for 'defeasible conclusion': succeed when the following conditions hold.
defeasible_conclusion(flies(X), Status, Just) :-
    % Execute: ( default_rule(flies(X), Cond),.
    ( default_rule(flies(X), Cond),
      % Continue the multi-line expression started above.
      call(Cond)
    % If the condition above succeeded, perform the following action.
    ->  % Default applies — check for exceptions
        % Continue the multi-line expression started above.
        ( findall(Note, (exception_rule(flies(X), ECond, Note), call(ECond)), Exceptions),
          % Continue the multi-line expression started above.
          Exceptions \= []
        % If the condition above succeeded, perform the following action.
        ->  Exceptions = [ExNote|_],
            % Continue the multi-line expression started above.
            Status = withdrawn(exception(ExNote)),
            % Continue the multi-line expression started above.
            Just = just(defeasible(flies(X),
                                   % Continue the multi-line expression started above.
                                   default(bird_flies),
                                   % Continue the multi-line expression started above.
                                   exception(ExNote),
                                   % Continue the multi-line expression started above.
                                   conclusion(does_not_fly)))
        % Otherwise (else branch), perform the following action.
        ;   Status = holds(default),
            % Continue the multi-line expression started above.
            Just = just(defeasible(flies(X),
                                   % Continue the multi-line expression started above.
                                   default(bird_flies),
                                   % Supply 'no_exception_found' as the next argument to the expression above.
                                   no_exception_found,
                                   % Continue the multi-line expression started above.
                                   conclusion(flies)))
        % Close the expression opened above.
        )
    % Otherwise (else branch), perform the following action.
    ;   Status = not_applicable,
        % Continue the multi-line expression started above.
        Just = just(defeasible(flies(X), default(bird_flies), condition_not_met))
    % Close the expression opened above.
    ).

% Generalised defeasible for any proposition
% Define a clause for 'defeasible conclusion': succeed when the following conditions hold.
defeasible_conclusion(Prop, Status, Just) :-
    % Check that 'Prop' is not unifiable with 'flies(_)'.
    Prop \= flies(_),
    % Execute: ( default_rule(Prop, Cond),.
    ( default_rule(Prop, Cond),
      % Continue the multi-line expression started above.
      call(Cond)
    % If the condition above succeeded, perform the following action.
    ->  ( findall(Note, (exception_rule(Prop, ECond, Note), call(ECond)), Exceptions),
          % Continue the multi-line expression started above.
          Exceptions \= []
        % If the condition above succeeded, perform the following action.
        ->  Exceptions = [ExNote|_],
            % Continue the multi-line expression started above.
            Status = withdrawn(exception(ExNote)),
            % Continue the multi-line expression started above.
            Just = just(defeasible(Prop, default_applies, exception(ExNote), withdrawn))
        % Otherwise (else branch), perform the following action.
        ;   Status = holds(default),
            % Continue the multi-line expression started above.
            Just = just(defeasible(Prop, default_applies, no_exception, holds))
        % Close the expression opened above.
        )
    % Otherwise (else branch), perform the following action.
    ;   Status = not_applicable,
        % Continue the multi-line expression started above.
        Just = just(defeasible(Prop, default_not_applicable))
    % Close the expression opened above.
    ).

% ---------------------------------------------------------------------------
% mentova_defeasible(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Define a clause for 'mentova defeasible': succeed when the following conditions hold.
mentova_defeasible(query(Prop), Result, Just) :-
    % State the fact: defeasible conclusion(Prop, Result, Just).
    defeasible_conclusion(Prop, Result, Just).
% Accept bare proposition (caller may omit query/1 wrapper)
% Define a clause for 'mentova defeasible': succeed when the following conditions hold.
mentova_defeasible(Prop, Result, Just) :-
    % Check that 'Prop' is not unifiable with 'query(_), Prop \= exceptions(_), Prop \= is_exception(_,_)'.
    Prop \= query(_), Prop \= exceptions(_), Prop \= is_exception(_,_),
    % State the fact: defeasible conclusion(Prop, Result, Just).
    defeasible_conclusion(Prop, Result, Just).

% List all exceptions for a proposition
% State a fact for 'mentova defeasible' with the arguments listed below.
mentova_defeasible(exceptions(Prop), exceptions(List),
                   % Continue the multi-line expression started above.
                   just(all_exceptions(Prop, List))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(exc(Note, Cond),
            % Continue the multi-line expression started above.
            exception_rule(Prop, Cond, Note),
            % Supply 'List' as the next argument to the expression above.
            List).

% Check if an entity is an exception
% State a fact for 'mentova defeasible' with the arguments listed below.
mentova_defeasible(is_exception(Prop, X), Answer,
                   % Continue the multi-line expression started above.
                   just(exception_check(Prop, X, Answer))) :-
    % Execute: ( exception_rule(Prop, ECond, Note),.
    ( exception_rule(Prop, ECond, Note),
      % Continue the multi-line expression started above.
      copy_term(ECond, ECond2),
      % Continue the multi-line expression started above.
      ECond2 =.. [_|_],
      % Continue the multi-line expression started above.
      call(ECond2)
    % If the condition above succeeded, perform the following action.
    ->  Answer = yes_exception(Note)
    % Otherwise (else branch), perform the following action.
    ;   Answer = no_exception
    % Close the expression opened above.
    ).
