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

:- module(induction, [
    mentova_induce/4,
    apply_rule/3
]).

:- use_module(library(lists), [member/2, append/3]).
:- use_module('../../knowledge/small_world', [is_a/2, has_property/2, capable_of/2]).

% ---------------------------------------------------------------------------
% mentova_induce/4
%
%   Pos        — positive examples, e.g. [flies(canary), flies(eagle)]
%   Neg        — negative examples, e.g. [flies(penguin), flies(cat)]
%   Background — background conditions as cond(Pred, ExtraArgs) terms
%   Rule       — induced rule: (Head :- Body)
% ---------------------------------------------------------------------------

mentova_induce(Pos, Neg, Background, Rule) :-
    Pos = [Ex|_],
    functor(Ex, Pred, Arity),
    % Search by body length: try 1 condition first, then 2
    ( induce_body(1, Pred, Arity, Background, Pos, Neg, HeadX, Body)
    ->  true
    ;   induce_body(2, Pred, Arity, Background, Pos, Neg, HeadX, Body)
    ),
    Rule = (HeadX :- Body).

induce_body(Len, Pred, Arity, Background, Pos, Neg, HeadX, Body) :-
    length(CondSpecs, Len),
    % X is a fresh variable shared by the head and all conditions
    functor(HeadX, Pred, Arity),
    HeadX =.. [Pred | HeadArgs],
    ( HeadArgs = [X|_] ; HeadArgs = [X] ), !,
    % Choose Len conditions from Background
    conditions_from_bg(CondSpecs, X, Background, Conds),
    list_to_conj(Conds, Body),
    % Accept if covers all positives and no negatives
    all_covered(HeadX, Body, Pos),
    none_covered(HeadX, Body, Neg).

% Build a list of condition terms by selecting from Background.
% cond(Pred, Extra)     builds Pred(X, Extra...)
% neg_cond(Pred, Extra) builds \+(Pred(X, Extra...))
conditions_from_bg([], _, _, []).
conditions_from_bg([_|SpecRest], X, Background, [Cond|CondRest]) :-
    ( member(cond(Pred, Extra), Background),
      Atom =.. [Pred, X | Extra],
      Cond = Atom
    ; member(neg_cond(Pred, Extra), Background),
      Atom =.. [Pred, X | Extra],
      Cond = \+(Atom)
    ),
    conditions_from_bg(SpecRest, X, Background, CondRest).

% ---------------------------------------------------------------------------
% Coverage checks
% ---------------------------------------------------------------------------

all_covered(_Head, _Body, []).
all_covered(Head, Body, [Ex|Rest]) :-
    apply_rule(Head, Body, Ex),
    all_covered(Head, Body, Rest).

none_covered(_Head, _Body, []).
none_covered(Head, Body, [Ex|Rest]) :-
    \+ apply_rule(Head, Body, Ex),
    none_covered(Head, Body, Rest).

% apply_rule/3: does Ex satisfy Head :- Body?
apply_rule(Head, Body, Ex) :-
    copy_term(Head-Body, Ex-BodyInst),
    call(BodyInst).

% ---------------------------------------------------------------------------
% Utility
% ---------------------------------------------------------------------------

list_to_conj([C], C) :- !.
list_to_conj([C|Rest], (C, Conj)) :-
    list_to_conj(Rest, Conj).
