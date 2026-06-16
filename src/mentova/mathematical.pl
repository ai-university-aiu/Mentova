/*  Mentova — Rung 14: Mathematical Reasoning Module

    Computes quantitative answers over structured numeric questions.
    Covers: arithmetic, factorial, Fibonacci, GCD, prime check,
            basic statistics (mean, max), and simple geometry.

    Every answer carries a justification naming the computation steps.

    Pass criterion: number is correct.
*/

:- module(mathematical, [
    mentova_math/3
]).

:- use_module(library(lists), [member/2]).
:- discontiguous mentova_math/3.

% ---------------------------------------------------------------------------
% mentova_math(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Arithmetic
mentova_math(eval(Expr), Result, just(eval(Expr, Result))) :-
    Result is Expr.

% Factorial: n!
mentova_math(factorial(N), F, just(factorial(N, F))) :-
    integer(N), N >= 0,
    factorial(N, F).

factorial(0, 1) :- !.
factorial(N, F) :-
    N > 0,
    N1 is N - 1,
    factorial(N1, F1),
    F is N * F1.

% Fibonacci: nth Fibonacci number
mentova_math(fibonacci(N), F, just(fibonacci(N, F))) :-
    integer(N), N >= 0,
    fibonacci(N, F).

fibonacci(0, 0) :- !.
fibonacci(1, 1) :- !.
fibonacci(N, F) :-
    N > 1,
    N1 is N - 1, N2 is N - 2,
    fibonacci(N1, F1), fibonacci(N2, F2),
    F is F1 + F2.

% GCD: Euclidean algorithm
mentova_math(gcd(A, B), G, just(gcd(A, B, G))) :-
    integer(A), integer(B), A > 0, B > 0,
    gcd(A, B, G).

gcd(A, 0, A) :- !.
gcd(A, B, G) :- B > 0, R is A mod B, gcd(B, R, G).

% Prime check
mentova_math(is_prime(N), Answer, just(prime_check(N, Answer))) :-
    integer(N), N > 1,
    ( is_prime(N) -> Answer = yes ; Answer = no ).

is_prime(2) :- !.
is_prime(N) :- N > 2, \+ has_factor(N, 2).

has_factor(N, F) :- F * F =< N, (N mod F =:= 0 ; has_factor(N, F+1)).
has_factor(N, F) :- F2 is F + 1, F2 * F2 =< N, N mod F2 =:= 0.
has_factor(N, F) :- F2 is F + 1, F2 * F2 =< N, has_factor(N, F2).

% Mean of a list
mentova_math(mean(List), Mean, just(mean(List, Mean))) :-
    List = [_|_],
    sumlist(List, S),
    length(List, Len),
    Mean is S / Len.

sumlist([], 0).
sumlist([H|T], S) :- sumlist(T, S1), S is S1 + H.

% Max of a list
mentova_math(max_of(List), Max, just(max_of(List, Max))) :-
    List = [H|T],
    max_list(T, H, Max).

max_list([], Max, Max).
max_list([H|T], Best, Max) :-
    ( H > Best -> Best2 = H ; Best2 = Best ),
    max_list(T, Best2, Max).

% Circle area: π × r²
mentova_math(circle_area(R), Area, just(circle_area(R, pi_r_squared, Area))) :-
    number(R), R > 0,
    Area is pi * R * R.

% Power: A^B
mentova_math(power(A, B), P, just(power(A, B, P))) :-
    number(A), integer(B), B >= 0,
    P is A ** B.
