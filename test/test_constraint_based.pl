/*  Mentova — Constraint-Based Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/constraint_based.pl, which
    exports mentova_constraint/3 in three query modes:
      - solve_zebra: the three-owner / three-pet zebra-lite puzzle, solved
        by permutation-and-filter, returning the unique assignment plus a
        five-step deduction log;
      - find_all_solutions: every satisfying assignment of that puzzle with
        a solution count;
      - solve_csp(Vars, Domains, Constraints): a general finite-domain CSP
        solver honouring neq/2, eq/2, and neq_val/2 constraints.
    Each mode returns a glass-box justification term.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_constraint_based.pl
*/

% Declare this file as a test module with no exports.
:- module(test_constraint_based, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(constraint_based)).

% Open the test block for the constraint_based module.
:- begin_tests(constraint_based).

% AC-CB-001: the zebra-lite puzzle has the unique solution alice-fish, bob-dog, carol-cat.
test(zebra_unique_solution) :-
    % Solve the zebra-lite puzzle, taking the single satisfying assignment.
    once(mentova_constraint(solve_zebra, Assignments, _Justification)),
    % Bob owns dog, alice is barred from cat so takes fish, carol takes the remaining cat.
    assertion(Assignments == [alice-fish, bob-dog, carol-cat]).

% AC-CB-002: the solve_zebra justification carries the puzzle name, the deduction steps, and the solution.
test(zebra_justification_reports_steps_and_solution) :-
    % Solve the puzzle and capture its glass-box justification term.
    once(mentova_constraint(solve_zebra, Assignments, Justification)),
    % The justification is the documented constraint_solve term over the zebra_lite puzzle.
    Justification = just(constraint_solve(puzzle(zebra_lite), steps(Log), solution(Solution))),
    % The solution slot repeats the returned assignment.
    assertion(Solution == Assignments),
    % The deduction log records exactly the five documented reasoning steps.
    assertion((is_list(Log), length(Log, 5))),
    % The first logged step is the bob-owns-dog constraint that anchors the deduction.
    assertion(Log = [step(1, 'bob owns dog', constraint(bob, owns, dog)) | _]).

% AC-CB-003: find_all_solutions returns exactly the one satisfying assignment with count one.
test(find_all_solutions_is_singleton) :-
    % Enumerate every satisfying assignment of the puzzle.
    once(mentova_constraint(find_all_solutions, AllSolutions, Justification)),
    % The constraints admit a single unique assignment.
    assertion(AllSolutions == [[alice-fish, bob-dog, carol-cat]]),
    % The justification reports that same single solution counted as one.
    assertion(Justification == just(constraint_all(puzzle(zebra_lite), count(1),
                                                   solutions([[alice-fish, bob-dog, carol-cat]])))).

% AC-CB-004: the general CSP solver honours a not-equal constraint between two variables.
test(csp_neq_between_variables) :-
    % Solve a two-variable CSP whose only constraint forbids x and y sharing a value.
    once(mentova_constraint(solve_csp([x, y], [x-[1, 2], y-[1, 2]], [neq(x, y)]),
                            Assignment, Justification)),
    % Depth-first search takes x=1 then the first admissible y=2, the smallest distinct pair.
    assertion(Assignment == [x=1, y=2]),
    % The justification names the variables and echoes the found solution.
    assertion(Justification == just(csp_solve(vars([x, y]), solution([x=1, y=2])))).

% AC-CB-005: the CSP solver honours an equality constraint pinning a variable to a value.
test(csp_eq_pins_value) :-
    % Solve a one-variable CSP whose constraint requires x to equal 2.
    once(mentova_constraint(solve_csp([x], [x-[1, 2, 3]], [eq(x, 2)]), Assignment, _Justification)),
    % Search skips the failing x=1 and settles on the constraint-satisfying x=2.
    assertion(Assignment == [x=2]).

% AC-CB-006: the CSP solver honours a value-exclusion constraint on a single variable.
test(csp_neq_val_excludes_value) :-
    % Solve a one-variable CSP whose constraint bars x from taking the value 1.
    once(mentova_constraint(solve_csp([x], [x-[1, 2, 3]], [neq_val(x, 1)]), Assignment, _Justification)),
    % Search rejects the excluded x=1 and returns the next domain value x=2.
    assertion(Assignment == [x=2]).

% Close the test block for the constraint_based module.
:- end_tests(constraint_based).
