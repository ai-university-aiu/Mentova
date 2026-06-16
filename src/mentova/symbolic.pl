/*  Mentova — Rung 37: Symbolic Reasoning Module

    Manipulates symbolic expressions: simplification, substitution,
    pattern matching, and algebraic identity checking.
    Pass criterion: correctly simplifies a symbolic expression and
    identifies the applicable algebraic identity.
*/

% Declare this file as the 'symbolic' module and list its exported predicates.
:- module(symbolic, [
    % Supply 'mentova_symbolic/3' as the next argument to the expression above.
    mentova_symbolic/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Algebraic identities (named rules)
% identity(Name, Pattern, Simplified)
% ---------------------------------------------------------------------------

% State the fact: identity(additive_identity,    add(X, 0),      X).
identity(additive_identity,    add(X, 0),      X).
% State the fact: identity(multiplicative_identity, mul(X, 1),   X).
identity(multiplicative_identity, mul(X, 1),   X).
% State the fact: identity(zero_product,         mul(_, 0),      0).
identity(zero_product,         mul(_, 0),      0).
% State the fact: identity(double_negation,      neg(neg(X)),    X).
identity(double_negation,      neg(neg(X)),    X).
% State the fact: identity(distributive,         mul(X, add(Y,Z)), add(mul(X,Y), mul(X,Z))).
identity(distributive,         mul(X, add(Y,Z)), add(mul(X,Y), mul(X,Z))).
% State the fact: identity(commutativity_add,    add(X, Y),      add(Y, X)).
identity(commutativity_add,    add(X, Y),      add(Y, X)).
% State the fact: identity(idempotent_or,        or(X, X),       X).
identity(idempotent_or,        or(X, X),       X).
% State the fact: identity(idempotent_and,       and(X, X),      X).
identity(idempotent_and,       and(X, X),      X).
% State the fact: identity(absorption_and,       and(X, or(X,_)), X).
identity(absorption_and,       and(X, or(X,_)), X).
% State the fact: identity(de_morgan_not_and,    neg(and(X,Y)),  or(neg(X), neg(Y))).
identity(de_morgan_not_and,    neg(and(X,Y)),  or(neg(X), neg(Y))).

% ---------------------------------------------------------------------------
% Simplify: apply first matching identity
% ---------------------------------------------------------------------------

% Define a clause for 'simplify': succeed when the following conditions hold.
simplify(Expr, Simplified, RuleName) :-
    % State a fact for 'identity' with the arguments listed below.
    identity(RuleName, Pattern, Template),
    % State a fact for 'copy term' with the arguments listed below.
    copy_term(Pattern-Template, Pattern2-Template2),
    % Check that 'Expr' is unifiable with 'Pattern2'.
    Expr = Pattern2,
    % Check that 'Simplified' is unifiable with 'Template2, !'.
    Simplified = Template2, !.

% State the fact: simplify(Expr, Expr, no_rule).
simplify(Expr, Expr, no_rule).

% ---------------------------------------------------------------------------
% Substitute: replace a variable by name in a symbolic expression
% substitute(Expr, Var, Value, Result)
% ---------------------------------------------------------------------------

% Define a clause for 'substitute': succeed when the following conditions hold.
substitute(Expr, Var, Val, Val) :-
    % Check that 'Expr' is structurally identical to 'Var, !'.
    Expr == Var, !.
% Define a clause for 'substitute': succeed when the following conditions hold.
substitute(Expr, _Var, _Val, Expr) :-
    % State a fact for 'atomic' with the arguments listed below.
    atomic(Expr), !.
% Define a clause for 'substitute': succeed when the following conditions hold.
substitute(Expr, Var, Val, Result) :-
    % Execute: Expr =.. [F|Args],.
    Expr =.. [F|Args],
    % State a fact for 'maplist' with the arguments listed below.
    maplist([A, R]>>(substitute(A, Var, Val, R)), Args, RArgs),
    % Execute: Result =.. [F|RArgs]..
    Result =.. [F|RArgs].

% ---------------------------------------------------------------------------
% mentova_symbolic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova symbolic' with the arguments listed below.
mentova_symbolic(simplify(Expr), simplified(Expr, Result, Rule),
                 % Continue the multi-line expression started above.
                 just(symbolic(simplification(Expr),
                                % Continue the multi-line expression started above.
                                rule(Rule), result(Result)))) :-
    % State the fact: simplify(Expr, Result, Rule).
    simplify(Expr, Result, Rule).

% State a fact for 'mentova symbolic' with the arguments listed below.
mentova_symbolic(identify(Expr), identity(Rule),
                 % Continue the multi-line expression started above.
                 just(symbolic(identity_check(Expr), rule(Rule)))) :-
    % State a fact for 'simplify' with the arguments listed below.
    simplify(Expr, _, Rule),
    % Check that 'Rule' is not unifiable with 'no_rule, !'.
    Rule \= no_rule, !.

% State a fact for 'mentova symbolic' with the arguments listed below.
mentova_symbolic(identify(Expr), no_identity,
                 % Continue the multi-line expression started above.
                 just(symbolic(identity_check(Expr), rule(none)))) :-
    % Succeed only if '(simplify(Expr, _, R), R \= no_rule' cannot be proved (negation as failure).
    \+ (simplify(Expr, _, R), R \= no_rule).

% State a fact for 'mentova symbolic' with the arguments listed below.
mentova_symbolic(substitute(Expr, Var, Val), result(Result),
                 % Continue the multi-line expression started above.
                 just(symbolic(substitution(Expr, Var, Val), result(Result)))) :-
    % State the fact: substitute(Expr, Var, Val, Result).
    substitute(Expr, Var, Val, Result).

% State a fact for 'mentova symbolic' with the arguments listed below.
mentova_symbolic(match(Pattern, Expr), matches(Bindings),
                 % Continue the multi-line expression started above.
                 just(symbolic(pattern_match(Pattern, Expr), bindings(Bindings)))) :-
    % State a fact for 'copy term' with the arguments listed below.
    copy_term(Pattern, Pattern2),
    % Check that 'Pattern2' is unifiable with 'Expr'.
    Pattern2 = Expr,
    % State a fact for 'term variables' with the arguments listed below.
    term_variables(Pattern, Vars),
    % State a fact for 'term variables' with the arguments listed below.
    term_variables(Pattern2, Vals),
    % State a fact for 'pairs keys values' with the arguments listed below.
    pairs_keys_values(Bindings, Vars, Vals), !.

% State a fact for 'mentova symbolic' with the arguments listed below.
mentova_symbolic(match(_, _), no_match,
                 % Continue the multi-line expression started above.
                 just(symbolic(pattern_match, result(no_match)))).
