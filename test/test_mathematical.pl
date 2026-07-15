/*  Mentova — Mathematical Reasoning Module Test Suite  (Rung 14)

    Behavioural PLUnit tests for src/mentova/mathematical.pl, which exports
    mentova_math/3 (Query, Result, Justification). Each test asks a query with
    known inputs and asserts the exact answer computed by hand from the
    module's documented behaviour.

    Run with the full library path (every PrologAI pack plus the Mentova source):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_mathematical.pl
*/

% Declare this file as a test module with no exports.
:- module(test_mathematical, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(mathematical)).

% Open the test block for mathematical.
:- begin_tests(mathematical).

% AC-MATH-001: an arithmetic expression is evaluated with operator precedence.
test(eval_respects_precedence) :-
    % Ask for the value of two plus three times four.
    mentova_math(eval(2 + 3 * 4), Result, Justification),
    % Multiplication binds tighter than addition, so the answer is fourteen.
    assertion(Result =:= 14),
    % The justification names the evaluated expression and its result.
    assertion(Justification == just(eval(2 + 3 * 4, 14))).

% AC-MATH-002: the factorial of five is one hundred and twenty.
test(factorial_of_five) :-
    % Ask for five factorial.
    mentova_math(factorial(5), Result, Justification),
    % Five factorial equals 5 * 4 * 3 * 2 * 1, which is one hundred and twenty.
    assertion(Result =:= 120),
    % The justification records the input and the computed factorial.
    assertion(Justification == just(factorial(5, 120))).

% AC-MATH-003: the base case factorial of zero is one.
test(factorial_of_zero) :-
    % Ask for zero factorial.
    mentova_math(factorial(0), Result, _),
    % Zero factorial is defined as one.
    assertion(Result =:= 1).

% AC-MATH-004: the tenth Fibonacci number is fifty-five.
test(fibonacci_tenth) :-
    % Ask for the tenth Fibonacci number.
    mentova_math(fibonacci(10), Result, Justification),
    % The sequence 0,1,1,2,3,5,8,13,21,34,55 puts fifty-five at index ten.
    assertion(Result =:= 55),
    % The justification records the index and the computed value.
    assertion(Justification == just(fibonacci(10, 55))).

% AC-MATH-005: the greatest common divisor of forty-eight and thirty-six is twelve.
test(gcd_euclid) :-
    % Ask for the greatest common divisor of forty-eight and thirty-six.
    mentova_math(gcd(48, 36), Result, Justification),
    % The Euclidean algorithm reduces 48 and 36 to a common divisor of twelve.
    assertion(Result =:= 12),
    % The justification records both inputs and the divisor.
    assertion(Justification == just(gcd(48, 36, 12))).

% AC-MATH-006: a prime number is reported as prime.
test(is_prime_yes) :-
    % Ask whether seven is prime.
    mentova_math(is_prime(7), Answer, Justification),
    % Seven has no divisor other than one and itself, so the answer is yes.
    assertion(Answer == yes),
    % The justification records the check and its verdict.
    assertion(Justification == just(prime_check(7, yes))).

% AC-MATH-007: a composite number is reported as not prime.
test(is_prime_no) :-
    % Ask whether nine is prime.
    mentova_math(is_prime(9), Answer, _),
    % Nine is three times three, so the answer is no.
    assertion(Answer == no).

% AC-MATH-008: the mean of a list is its sum divided by its length.
test(mean_of_list) :-
    % Ask for the mean of two, four, and six.
    mentova_math(mean([2, 4, 6]), Result, Justification),
    % The sum is twelve over three elements, giving a mean of four.
    assertion(Result =:= 4),
    % The justification records the list and its mean.
    assertion(Justification == just(mean([2, 4, 6], 4))).

% AC-MATH-009: the maximum of a list is its largest element.
test(max_of_list) :-
    % Ask for the maximum of the list.
    mentova_math(max_of([3, 7, 2, 9, 1]), Result, _),
    % Nine is the largest element of the list.
    assertion(Result =:= 9).

% AC-MATH-010: the area of a circle is pi times the radius squared.
test(circle_area) :-
    % Ask for the area of a circle of radius two.
    mentova_math(circle_area(2), Result, _),
    % Pi times two squared is four pi, within floating-point tolerance.
    assertion(abs(Result - (pi * 4)) < 1.0e-9).

% AC-MATH-011: raising a base to an integer power.
test(power) :-
    % Ask for two raised to the tenth power.
    mentova_math(power(2, 10), Result, Justification),
    % Two to the tenth is one thousand and twenty-four.
    assertion(Result =:= 1024),
    % The justification records the base, exponent, and result.
    assertion(Justification == just(power(2, 10, 1024))).

% AC-MATH-012: a negative factorial argument is rejected by the guard.
test(factorial_negative_fails, [fail]) :-
    % Asking for the factorial of a negative number must fail its integer guard.
    mentova_math(factorial(-1), _, _).

% Close the test block for mathematical.
:- end_tests(mathematical).
