/*  Mentova — Rung 25: Constraint-Based Reasoning Module

    Solves a small Zebra-style puzzle by constraint propagation.
    Pass criterion: unique satisfying assignment found with deduction shown.

    Puzzle (from small_world scenario):
      Three owners (alice, bob, carol) each own a pet (cat, dog, fish).
      Constraints:
        alice does not own cat.
        bob owns dog.
        carol does not own dog.
      Find: who owns what?
*/

% Declare this file as the 'constraint_based' module and list its exported predicates.
:- module(constraint_based, [
    % Supply 'mentova_constraint/3' as the next argument to the expression above.
    mentova_constraint/3
% Close the expression opened above.
]).

% Import [member/2, permutation/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, permutation/2]).

% ---------------------------------------------------------------------------
% Constraint solver
% ---------------------------------------------------------------------------

% Pets available
% State the fact: pet(cat). pet(dog). pet(fish).
pet(cat). pet(dog). pet(fish).

% solve_puzzle: enumerate and filter by constraints
% Define a clause for 'solve zebra': succeed when the following conditions hold.
solve_zebra(Assignments) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Owner-Pet, (member(Owner, [alice,bob,carol]), pet(Pet)), _),
    % Generate assignment: each owner gets one pet, all different
    % State a fact for 'permutation' with the arguments listed below.
    permutation([cat,dog,fish], [AlicePet, BobPet, CarolPet]),
    % Apply constraints
    % Check that 'AlicePet' is not unifiable with 'cat,          % constraint: alice not_owns cat'.
    AlicePet \= cat,          % constraint: alice not_owns cat
    % Check that 'BobPet' is unifiable with 'dog,             % constraint: bob owns dog'.
    BobPet = dog,             % constraint: bob owns dog
    % Check that 'CarolPet' is not unifiable with 'dog,          % constraint: carol not_owns dog'.
    CarolPet \= dog,          % constraint: carol not_owns dog
    % Check that 'Assignments' is unifiable with '[alice-AlicePet, bob-BobPet, carol-CarolPet]'.
    Assignments = [alice-AlicePet, bob-BobPet, carol-CarolPet].

% Deduction log
% State a fact for 'deduction log' with the arguments listed below.
deduction_log([
    % Continue the multi-line expression started above.
    step(1, 'bob owns dog',        constraint(bob,owns,dog)),
    % Continue the multi-line expression started above.
    step(2, 'alice not owns cat',  constraint(alice,not_owns,cat)),
    % Continue the multi-line expression started above.
    step(3, 'carol not owns dog',  constraint(carol,not_owns,dog)),
    % Continue the multi-line expression started above.
    step(4, 'alice gets fish',     deduction(alice,fish,'not cat, not dog (taken by bob)')),
    % Continue the multi-line expression started above.
    step(5, 'carol gets cat',      deduction(carol,cat,'not dog (taken by bob), fish taken by alice'))
% Close the expression opened above.
]).

% ---------------------------------------------------------------------------
% General constraint network solver
% ---------------------------------------------------------------------------

% Simple CSP: variables with domains, binary constraints
% Define a clause for 'solve csp': succeed when the following conditions hold.
solve_csp(Vars, Domains, Constraints, Assignment) :-
    % State a fact for 'assign vars' with the arguments listed below.
    assign_vars(Vars, Domains, Assignment),
    % State the fact: check constraints(Constraints, Assignment).
    check_constraints(Constraints, Assignment).

% State the fact: assign vars([], _, []).
assign_vars([], _, []).
% Define a clause for 'assign vars': succeed when the following conditions hold.
assign_vars([V|Vs], Domains, [V=Val|Rest]) :-
    % Succeed for each element 'V-Dom' that is a member of the list.
    member(V-Dom, Domains),
    % Succeed for each element 'Val' that is a member of the list.
    member(Val, Dom),
    % State the fact: assign vars(Vs, Domains, Rest).
    assign_vars(Vs, Domains, Rest).

% State the fact: check constraints([], _).
check_constraints([], _).
% Define a clause for 'check constraints': succeed when the following conditions hold.
check_constraints([C|Cs], Assignment) :-
    % State a fact for 'check constraint' with the arguments listed below.
    check_constraint(C, Assignment),
    % State the fact: check constraints(Cs, Assignment).
    check_constraints(Cs, Assignment).

% Define a clause for 'check constraint': succeed when the following conditions hold.
check_constraint(neq(V1, V2), Assignment) :-
    % Succeed for each element 'V1=Val1' that is a member of the list.
    member(V1=Val1, Assignment),
    % Succeed for each element 'V2=Val2' that is a member of the list.
    member(V2=Val2, Assignment),
    % Check that 'Val1' is not unifiable with 'Val2'.
    Val1 \= Val2.
% Define a clause for 'check constraint': succeed when the following conditions hold.
check_constraint(eq(V, Val), Assignment) :-
    % Succeed for each element 'V=Val' that is a member of the list.
    member(V=Val, Assignment).
% Define a clause for 'check constraint': succeed when the following conditions hold.
check_constraint(neq_val(V, Val), Assignment) :-
    % Succeed for each element 'V=Assigned' that is a member of the list.
    member(V=Assigned, Assignment),
    % Check that 'Assigned' is not unifiable with 'Val'.
    Assigned \= Val.

% ---------------------------------------------------------------------------
% mentova_constraint(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova constraint' with the arguments listed below.
mentova_constraint(solve_zebra, Assignments,
                    % Continue the multi-line expression started above.
                    just(constraint_solve(puzzle(zebra_lite),
                                          % Continue the multi-line expression started above.
                                          steps(Log),
                                          % Continue the multi-line expression started above.
                                          solution(Assignments)))) :-
    % State a fact for 'solve zebra' with the arguments listed below.
    solve_zebra(Assignments),
    % State the fact: deduction log(Log).
    deduction_log(Log).

% State a fact for 'mentova constraint' with the arguments listed below.
mentova_constraint(find_all_solutions, AllSolutions,
                    % Continue the multi-line expression started above.
                    just(constraint_all(puzzle(zebra_lite), count(N), solutions(AllSolutions)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(A, solve_zebra(A), AllSolutions),
    % Unify 'N' with the number of elements in list 'AllSolutions'.
    length(AllSolutions, N).

% State a fact for 'mentova constraint' with the arguments listed below.
mentova_constraint(solve_csp(Vars, Domains, Constraints), Assignment,
                    % Continue the multi-line expression started above.
                    just(csp_solve(vars(Vars), solution(Assignment)))) :-
    % State the fact: once(solve_csp(Vars, Domains, Constraints, Assignment)).
    once(solve_csp(Vars, Domains, Constraints, Assignment)).
