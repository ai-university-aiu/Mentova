/*  Mentova — Symbolic Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/symbolic.pl, which exports
    mentova_symbolic/3 — a glass-box symbolic engine dispatching on the
    query form:
      simplify(Expr)             -> simplified(Expr, Result, Rule)
      identify(Expr)             -> identity(Rule) | no_identity
      substitute(Expr, Var, Val) -> result(Result)
      match(Pattern, Expr)       -> matches(Bindings) | no_match
    Each answer carries a just(symbolic(...)) justification term. The
    module applies the first matching named algebraic identity (tried in
    source order: additive_identity, multiplicative_identity,
    zero_product, double_negation, distributive, commutativity_add, ...).

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_symbolic.pl
*/

% Declare this file as a test module with no exports.
:- module(test_symbolic, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(symbolic)).

% Open the test block for the symbolic module.
:- begin_tests(symbolic).

% AC-SYM-001: simplify(add(X,0)) applies the additive-identity rule to X.
test(simplify_additive_identity) :-
    % Simplify the expression x + 0.
    mentova_symbolic(simplify(add(x, 0)), Result, Justification),
    % The result strips the +0 and names the additive-identity rule.
    assertion(Result == simplified(add(x, 0), x, additive_identity)),
    % The justification records the simplification, the rule, and the result.
    assertion(Justification == just(symbolic(simplification(add(x, 0)),
                                             rule(additive_identity), result(x)))).

% AC-SYM-002: simplify(mul(_,0)) collapses to 0 via the zero-product rule, not multiplicative-identity.
test(simplify_zero_product) :-
    % Simplify the expression a * 0.
    mentova_symbolic(simplify(mul(a, 0)), Result, _Justification),
    % The whole product collapses to zero and names the zero-product rule.
    assertion(Result == simplified(mul(a, 0), 0, zero_product)).

% AC-SYM-003: simplify(mul(X,1)) applies the multiplicative-identity rule to X.
test(simplify_multiplicative_identity) :-
    % Simplify the expression k * 1.
    mentova_symbolic(simplify(mul(k, 1)), Result, _Justification),
    % The result strips the *1 and names the multiplicative-identity rule.
    assertion(Result == simplified(mul(k, 1), k, multiplicative_identity)).

% AC-SYM-004: simplify(neg(neg(X))) cancels the double negation back to X.
test(simplify_double_negation) :-
    % Simplify the expression not(not(a)).
    mentova_symbolic(simplify(neg(neg(a))), Result, _Justification),
    % Both negations cancel and the double-negation rule is named.
    assertion(Result == simplified(neg(neg(a)), a, double_negation)).

% AC-SYM-005: an expression matching no identity is returned unchanged with rule no_rule.
test(simplify_no_matching_rule) :-
    % Simplify an expression no algebraic identity covers.
    mentova_symbolic(simplify(foo(bar)), Result, _Justification),
    % The expression is echoed unchanged and tagged no_rule.
    assertion(Result == simplified(foo(bar), foo(bar), no_rule)).

% AC-SYM-006: identify names the applicable rule for a recognised pattern.
test(identify_known_rule) :-
    % Ask which identity applies to p + 0.
    mentova_symbolic(identify(add(p, 0)), Result, Justification),
    % It is the additive-identity rule.
    assertion(Result == identity(additive_identity)),
    % The justification records the identity check and the rule found.
    assertion(Justification == just(symbolic(identity_check(add(p, 0)),
                                             rule(additive_identity)))).

% AC-SYM-007: identify reports no_identity when no rule applies.
test(identify_no_identity) :-
    % Ask which identity applies to an unrecognised expression.
    mentova_symbolic(identify(foo(bar)), Result, Justification),
    % No identity matches.
    assertion(Result == no_identity),
    % The justification records the check and the absence of a rule.
    assertion(Justification == just(symbolic(identity_check(foo(bar)), rule(none)))).

% AC-SYM-008: substitute replaces a named variable everywhere it occurs, leaving others intact.
test(substitute_named_variable) :-
    % Substitute the atom 5 for x throughout x + y.
    mentova_symbolic(substitute(add(x, y), x, 5), Result, Justification),
    % x becomes 5 while y is left untouched.
    assertion(Result == result(add(5, y))),
    % The justification records the substitution and its result.
    assertion(Justification == just(symbolic(substitution(add(x, y), x, 5),
                                             result(add(5, y))))).

% AC-SYM-009: matching a ground pattern against an equal term succeeds with no bindings.
test(match_ground_terms_bind_empty) :-
    % Match f(a) against the identical term f(a).
    mentova_symbolic(match(f(a), f(a)), Result, Justification),
    % The terms unify with an empty binding list.
    assertion(Result == matches([])),
    % The justification records the pattern match and its empty bindings.
    assertion(Justification == just(symbolic(pattern_match(f(a), f(a)), bindings([])))).

% AC-SYM-010: matching against a non-unifiable term reports no_match.
test(match_non_matching_returns_no_match) :-
    % Match f(a) against the incompatible term g(b).
    mentova_symbolic(match(f(a), g(b)), Result, _Justification),
    % The terms do not unify, so the engine reports no_match.
    assertion(Result == no_match).

% Close the test block for the symbolic module.
:- end_tests(symbolic).
