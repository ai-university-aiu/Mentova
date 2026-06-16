/*  Mentova — Inductive Reasoning Module  (Rung 2)

    Induces a general rule from positive and negative examples over
    background knowledge, using a generate-and-test ILP approach.

    Background predicates are given as cond(Predicate, ExtraArgs) terms,
    where the rule's variable X is always the first argument:
        cond(is_a, [bird])          builds  is_a(X, bird)
        cond(has_property, [flightless]) builds  has_property(X, flightless)

    Strategy:
        1. Generate candidate rule bodies of length 1, then 2.
        2. Build each body by choosing conditions from the background list.
        3. Accept the first rule that covers ALL positives and ZERO negatives.
        4. Prefer shorter (simpler) rules.

    Predicates:
        mentova_induce/4  — +Pos, +Neg, +Background, -Rule
        apply_rule/3      — +Head, +Body, +Example (-true if covered)
*/

% Declare this file as the 'induction' module and list its exported predicates.
:- module(induction, [
    % Supply 'mentova_induce/4' as the next argument to the expression above.
    mentova_induce/4,
    % Supply 'apply_rule/3' as the next argument to the expression above.
    apply_rule/3
% Close the expression opened above.
]).

% Import [member/2, append/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, append/3]).
% Import [is_a/2, has_property/2, capable_of/2] from the 'small_world' module.
:- use_module('../../knowledge/small_world', [is_a/2, has_property/2, capable_of/2]).

% ---------------------------------------------------------------------------
% mentova_induce/4
%
%   Pos        — positive examples, e.g. [flies(canary), flies(eagle)]
%   Neg        — negative examples, e.g. [flies(penguin), flies(cat)]
%   Background — background conditions as cond(Pred, ExtraArgs) terms
%   Rule       — induced rule: (Head :- Body)
% ---------------------------------------------------------------------------

% Define a clause for 'mentova induce': succeed when the following conditions hold.
mentova_induce(Pos, Neg, Background, Rule) :-
    % Check that 'Pos' is unifiable with '[Ex|_]'.
    Pos = [Ex|_],
    % State a fact for 'functor' with the arguments listed below.
    functor(Ex, Pred, Arity),
    % Search by body length: try 1 condition first, then 2
    % Execute: ( induce_body(1, Pred, Arity, Background, Pos, Neg, HeadX, Body).
    ( induce_body(1, Pred, Arity, Background, Pos, Neg, HeadX, Body)
    % If the condition above succeeded, perform the following action.
    ->  true
    % Otherwise (else branch), perform the following action.
    ;   induce_body(2, Pred, Arity, Background, Pos, Neg, HeadX, Body)
    % Close the expression opened above.
    ),
    % Check that 'Rule' is unifiable with '(HeadX :- Body)'.
    Rule = (HeadX :- Body).

% Define a clause for 'induce body': succeed when the following conditions hold.
induce_body(Len, Pred, Arity, Background, Pos, Neg, HeadX, Body) :-
    % Unify 'Len' with the number of elements in list 'CondSpecs'.
    length(CondSpecs, Len),
    % X is a fresh variable shared by the head and all conditions
    % State a fact for 'functor' with the arguments listed below.
    functor(HeadX, Pred, Arity),
    % Execute: HeadX =.. [Pred | HeadArgs],.
    HeadX =.. [Pred | HeadArgs],
    % Check that '( HeadArgs' is unifiable with '[X|_] ; HeadArgs = [X] ), !'.
    ( HeadArgs = [X|_] ; HeadArgs = [X] ), !,
    % Choose Len conditions from Background
    % State a fact for 'conditions from bg' with the arguments listed below.
    conditions_from_bg(CondSpecs, X, Background, Conds),
    % State a fact for 'list to conj' with the arguments listed below.
    list_to_conj(Conds, Body),
    % Accept if covers all positives and no negatives
    % State a fact for 'all covered' with the arguments listed below.
    all_covered(HeadX, Body, Pos),
    % State the fact: none covered(HeadX, Body, Neg).
    none_covered(HeadX, Body, Neg).

% Build a list of condition terms by selecting from Background.
% cond(Pred, Extra)     builds Pred(X, Extra...)
% neg_cond(Pred, Extra) builds \+(Pred(X, Extra...))
% State the fact: conditions from bg([], _, _, []).
conditions_from_bg([], _, _, []).
% Define a clause for 'conditions from bg': succeed when the following conditions hold.
conditions_from_bg([_|SpecRest], X, Background, [Cond|CondRest]) :-
    % Execute: ( member(cond(Pred, Extra), Background),.
    ( member(cond(Pred, Extra), Background),
      % Continue the multi-line expression started above.
      Atom =.. [Pred, X | Extra],
      % Continue the multi-line expression started above.
      Cond = Atom
    % Otherwise (else branch), perform the following action.
    ; member(neg_cond(Pred, Extra), Background),
      % Continue the multi-line expression started above.
      Atom =.. [Pred, X | Extra],
      % Continue the multi-line expression started above.
      Cond = \+(Atom)
    % Close the expression opened above.
    ),
    % State the fact: conditions from bg(SpecRest, X, Background, CondRest).
    conditions_from_bg(SpecRest, X, Background, CondRest).

% ---------------------------------------------------------------------------
% Coverage checks
% ---------------------------------------------------------------------------

% State the fact: all covered(_Head, _Body, []).
all_covered(_Head, _Body, []).
% Define a clause for 'all covered': succeed when the following conditions hold.
all_covered(Head, Body, [Ex|Rest]) :-
    % State a fact for 'apply rule' with the arguments listed below.
    apply_rule(Head, Body, Ex),
    % State the fact: all covered(Head, Body, Rest).
    all_covered(Head, Body, Rest).

% State the fact: none covered(_Head, _Body, []).
none_covered(_Head, _Body, []).
% Define a clause for 'none covered': succeed when the following conditions hold.
none_covered(Head, Body, [Ex|Rest]) :-
    % Succeed only if 'apply_rule(Head, Body, Ex' cannot be proved (negation as failure).
    \+ apply_rule(Head, Body, Ex),
    % State the fact: none covered(Head, Body, Rest).
    none_covered(Head, Body, Rest).

% apply_rule/3: does Ex satisfy Head :- Body?
% Define a clause for 'apply rule': succeed when the following conditions hold.
apply_rule(Head, Body, Ex) :-
    % State a fact for 'copy term' with the arguments listed below.
    copy_term(Head-Body, Ex-BodyInst),
    % State the fact: call(BodyInst).
    call(BodyInst).

% ---------------------------------------------------------------------------
% Utility
% ---------------------------------------------------------------------------

% Define a clause for 'list to conj': succeed when the following conditions hold.
list_to_conj([C], C) :- !.
% Define a clause for 'list to conj': succeed when the following conditions hold.
list_to_conj([C|Rest], (C, Conj)) :-
    % State the fact: list to conj(Rest, Conj).
    list_to_conj(Rest, Conj).
