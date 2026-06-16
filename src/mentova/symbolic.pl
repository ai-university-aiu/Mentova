/*  Mentova — Rung 37: Symbolic Reasoning Module

    Manipulates symbolic expressions: simplification, substitution,
    pattern matching, and algebraic identity checking.
    Pass criterion: correctly simplifies a symbolic expression and
    identifies the applicable algebraic identity.
*/

:- module(symbolic, [
    mentova_symbolic/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Algebraic identities (named rules)
% identity(Name, Pattern, Simplified)
% ---------------------------------------------------------------------------

identity(additive_identity,    add(X, 0),      X).
identity(multiplicative_identity, mul(X, 1),   X).
identity(zero_product,         mul(_, 0),      0).
identity(double_negation,      neg(neg(X)),    X).
identity(distributive,         mul(X, add(Y,Z)), add(mul(X,Y), mul(X,Z))).
identity(commutativity_add,    add(X, Y),      add(Y, X)).
identity(idempotent_or,        or(X, X),       X).
identity(idempotent_and,       and(X, X),      X).
identity(absorption_and,       and(X, or(X,_)), X).
identity(de_morgan_not_and,    neg(and(X,Y)),  or(neg(X), neg(Y))).

% ---------------------------------------------------------------------------
% Simplify: apply first matching identity
% ---------------------------------------------------------------------------

simplify(Expr, Simplified, RuleName) :-
    identity(RuleName, Pattern, Template),
    copy_term(Pattern-Template, Pattern2-Template2),
    Expr = Pattern2,
    Simplified = Template2, !.

simplify(Expr, Expr, no_rule).

% ---------------------------------------------------------------------------
% Substitute: replace a variable by name in a symbolic expression
% substitute(Expr, Var, Value, Result)
% ---------------------------------------------------------------------------

substitute(Expr, Var, Val, Val) :-
    Expr == Var, !.
substitute(Expr, _Var, _Val, Expr) :-
    atomic(Expr), !.
substitute(Expr, Var, Val, Result) :-
    Expr =.. [F|Args],
    maplist([A, R]>>(substitute(A, Var, Val, R)), Args, RArgs),
    Result =.. [F|RArgs].

% ---------------------------------------------------------------------------
% mentova_symbolic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_symbolic(simplify(Expr), simplified(Expr, Result, Rule),
                 just(symbolic(simplification(Expr),
                                rule(Rule), result(Result)))) :-
    simplify(Expr, Result, Rule).

mentova_symbolic(identify(Expr), identity(Rule),
                 just(symbolic(identity_check(Expr), rule(Rule)))) :-
    simplify(Expr, _, Rule),
    Rule \= no_rule, !.

mentova_symbolic(identify(Expr), no_identity,
                 just(symbolic(identity_check(Expr), rule(none)))) :-
    \+ (simplify(Expr, _, R), R \= no_rule).

mentova_symbolic(substitute(Expr, Var, Val), result(Result),
                 just(symbolic(substitution(Expr, Var, Val), result(Result)))) :-
    substitute(Expr, Var, Val, Result).

mentova_symbolic(match(Pattern, Expr), matches(Bindings),
                 just(symbolic(pattern_match(Pattern, Expr), bindings(Bindings)))) :-
    copy_term(Pattern, Pattern2),
    Pattern2 = Expr,
    term_variables(Pattern, Vars),
    term_variables(Pattern2, Vals),
    pairs_keys_values(Bindings, Vars, Vals), !.

mentova_symbolic(match(_, _), no_match,
                 just(symbolic(pattern_match, result(no_match)))).
