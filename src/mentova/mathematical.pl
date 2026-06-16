/*  Mentova — Rung 14: Mathematical Reasoning Module

    Computes quantitative answers over structured numeric questions.
    Covers: arithmetic, factorial, Fibonacci, GCD, prime check,
            basic statistics (mean, max), and simple geometry.

    Every answer carries a justification naming the computation steps.

    Pass criterion: number is correct.
*/

% Declare this file as the 'mathematical' module and list its exported predicates.
:- module(mathematical, [
    % Supply 'mentova_math/3' as the next argument to the expression above.
    mentova_math/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).
% Allow 'mentova_math/3' clauses to appear at non-consecutive positions in this file.
:- discontiguous mentova_math/3.

% ---------------------------------------------------------------------------
% mentova_math(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Arithmetic
% Define a clause for 'mentova math': succeed when the following conditions hold.
mentova_math(eval(Expr), Result, just(eval(Expr, Result))) :-
    % Evaluate the arithmetic expression 'Expr' and bind the result to 'Result'.
    Result is Expr.

% Factorial: n!
% Define a clause for 'mentova math': succeed when the following conditions hold.
mentova_math(factorial(N), F, just(factorial(N, F))) :-
    % Check that 'integer(N), N' is greater than or equal to '0'.
    integer(N), N >= 0,
    % State the fact: factorial(N, F).
    factorial(N, F).

% Define a clause for 'factorial': succeed when the following conditions hold.
factorial(0, 1) :- !.
% Define a clause for 'factorial': succeed when the following conditions hold.
factorial(N, F) :-
    % Check that 'N' is greater than '0'.
    N > 0,
    % Evaluate the arithmetic expression 'N - 1' and bind the result to 'N1'.
    N1 is N - 1,
    % State a fact for 'factorial' with the arguments listed below.
    factorial(N1, F1),
    % Evaluate the arithmetic expression 'N * F1' and bind the result to 'F'.
    F is N * F1.

% Fibonacci: nth Fibonacci number
% Define a clause for 'mentova math': succeed when the following conditions hold.
mentova_math(fibonacci(N), F, just(fibonacci(N, F))) :-
    % Check that 'integer(N), N' is greater than or equal to '0'.
    integer(N), N >= 0,
    % State the fact: fibonacci(N, F).
    fibonacci(N, F).

% Define a clause for 'fibonacci': succeed when the following conditions hold.
fibonacci(0, 0) :- !.
% Define a clause for 'fibonacci': succeed when the following conditions hold.
fibonacci(1, 1) :- !.
% Define a clause for 'fibonacci': succeed when the following conditions hold.
fibonacci(N, F) :-
    % Check that 'N' is greater than '1'.
    N > 1,
    % Evaluate the arithmetic expression 'N - 1, N2 is N - 2' and bind the result to 'N1'.
    N1 is N - 1, N2 is N - 2,
    % State a fact for 'fibonacci' with the arguments listed below.
    fibonacci(N1, F1), fibonacci(N2, F2),
    % Evaluate the arithmetic expression 'F1 + F2' and bind the result to 'F'.
    F is F1 + F2.

% GCD: Euclidean algorithm
% Define a clause for 'mentova math': succeed when the following conditions hold.
mentova_math(gcd(A, B), G, just(gcd(A, B, G))) :-
    % Check that 'integer(A), integer(B), A' is greater than '0, B > 0'.
    integer(A), integer(B), A > 0, B > 0,
    % State the fact: gcd(A, B, G).
    gcd(A, B, G).

% Define a clause for 'gcd': succeed when the following conditions hold.
gcd(A, 0, A) :- !.
% Check that 'gcd(A, B, G) :- B' is greater than '0, R is A mod B, gcd(B, R, G)'.
gcd(A, B, G) :- B > 0, R is A mod B, gcd(B, R, G).

% Prime check
% Define a clause for 'mentova math': succeed when the following conditions hold.
mentova_math(is_prime(N), Answer, just(prime_check(N, Answer))) :-
    % Check that 'integer(N), N' is greater than '1'.
    integer(N), N > 1,
    % Check that '( is_prime(N) -> Answer' is unifiable with 'yes ; Answer = no )'.
    ( is_prime(N) -> Answer = yes ; Answer = no ).

% Define a clause for 'is prime': succeed when the following conditions hold.
is_prime(2) :- !.
% Check that 'is_prime(N) :- N' is greater than '2, \+ has_factor(N, 2)'.
is_prime(N) :- N > 2, \+ has_factor(N, 2).

% Check that 'has_factor(N, F) :- F * F =< N, (N mod F' is numerically equal to '0 ; has_factor(N, F+1))'.
has_factor(N, F) :- F * F =< N, (N mod F =:= 0 ; has_factor(N, F+1)).
% Check that 'has_factor(N, F) :- F2 is F + 1, F2 * F2 =< N, N mod F2' is numerically equal to '0'.
has_factor(N, F) :- F2 is F + 1, F2 * F2 =< N, N mod F2 =:= 0.
% Check that 'has_factor(N, F) :- F2 is F + 1, F2 * F2' is less than or equal to 'N, has_factor(N, F2)'.
has_factor(N, F) :- F2 is F + 1, F2 * F2 =< N, has_factor(N, F2).

% Mean of a list
% Define a clause for 'mentova math': succeed when the following conditions hold.
mentova_math(mean(List), Mean, just(mean(List, Mean))) :-
    % Check that 'List' is unifiable with '[_|_]'.
    List = [_|_],
    % State a fact for 'sumlist' with the arguments listed below.
    sumlist(List, S),
    % Unify 'Len' with the number of elements in list 'List'.
    length(List, Len),
    % Evaluate the arithmetic expression 'S / Len' and bind the result to 'Mean'.
    Mean is S / Len.

% State the fact: sumlist([], 0).
sumlist([], 0).
% Define a clause for 'sumlist': succeed when the following conditions hold.
sumlist([H|T], S) :- sumlist(T, S1), S is S1 + H.

% Max of a list
% Define a clause for 'mentova math': succeed when the following conditions hold.
mentova_math(max_of(List), Max, just(max_of(List, Max))) :-
    % Check that 'List' is unifiable with '[H|T]'.
    List = [H|T],
    % State the fact: max list(T, H, Max).
    max_list(T, H, Max).

% State the fact: max list([], Max, Max).
max_list([], Max, Max).
% Define a clause for 'max list': succeed when the following conditions hold.
max_list([H|T], Best, Max) :-
    % Check that '( H' is greater than 'Best -> Best2 = H ; Best2 = Best )'.
    ( H > Best -> Best2 = H ; Best2 = Best ),
    % State the fact: max list(T, Best2, Max).
    max_list(T, Best2, Max).

% Circle area: π × r²
% Define a clause for 'mentova math': succeed when the following conditions hold.
mentova_math(circle_area(R), Area, just(circle_area(R, pi_r_squared, Area))) :-
    % Check that 'number(R), R' is greater than '0'.
    number(R), R > 0,
    % Evaluate the arithmetic expression 'pi * R * R' and bind the result to 'Area'.
    Area is pi * R * R.

% Power: A^B
% Define a clause for 'mentova math': succeed when the following conditions hold.
mentova_math(power(A, B), P, just(power(A, B, P))) :-
    % Check that 'number(A), integer(B), B' is greater than or equal to '0'.
    number(A), integer(B), B >= 0,
    % Evaluate the arithmetic expression 'A ** B' and bind the result to 'P'.
    P is A ** B.
