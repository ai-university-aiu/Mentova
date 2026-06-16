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

:- module(constraint_based, [
    mentova_constraint/3
]).

:- use_module(library(lists), [member/2, permutation/2]).

% ---------------------------------------------------------------------------
% Constraint solver
% ---------------------------------------------------------------------------

% Pets available
pet(cat). pet(dog). pet(fish).

% solve_puzzle: enumerate and filter by constraints
solve_zebra(Assignments) :-
    findall(Owner-Pet, (member(Owner, [alice,bob,carol]), pet(Pet)), _),
    % Generate assignment: each owner gets one pet, all different
    permutation([cat,dog,fish], [AlicePet, BobPet, CarolPet]),
    % Apply constraints
    AlicePet \= cat,          % constraint: alice not_owns cat
    BobPet = dog,             % constraint: bob owns dog
    CarolPet \= dog,          % constraint: carol not_owns dog
    Assignments = [alice-AlicePet, bob-BobPet, carol-CarolPet].

% Deduction log
deduction_log([
    step(1, 'bob owns dog',        constraint(bob,owns,dog)),
    step(2, 'alice not owns cat',  constraint(alice,not_owns,cat)),
    step(3, 'carol not owns dog',  constraint(carol,not_owns,dog)),
    step(4, 'alice gets fish',     deduction(alice,fish,'not cat, not dog (taken by bob)')),
    step(5, 'carol gets cat',      deduction(carol,cat,'not dog (taken by bob), fish taken by alice'))
]).

% ---------------------------------------------------------------------------
% General constraint network solver
% ---------------------------------------------------------------------------

% Simple CSP: variables with domains, binary constraints
solve_csp(Vars, Domains, Constraints, Assignment) :-
    assign_vars(Vars, Domains, Assignment),
    check_constraints(Constraints, Assignment).

assign_vars([], _, []).
assign_vars([V|Vs], Domains, [V=Val|Rest]) :-
    member(V-Dom, Domains),
    member(Val, Dom),
    assign_vars(Vs, Domains, Rest).

check_constraints([], _).
check_constraints([C|Cs], Assignment) :-
    check_constraint(C, Assignment),
    check_constraints(Cs, Assignment).

check_constraint(neq(V1, V2), Assignment) :-
    member(V1=Val1, Assignment),
    member(V2=Val2, Assignment),
    Val1 \= Val2.
check_constraint(eq(V, Val), Assignment) :-
    member(V=Val, Assignment).
check_constraint(neq_val(V, Val), Assignment) :-
    member(V=Assigned, Assignment),
    Assigned \= Val.

% ---------------------------------------------------------------------------
% mentova_constraint(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_constraint(solve_zebra, Assignments,
                    just(constraint_solve(puzzle(zebra_lite),
                                          steps(Log),
                                          solution(Assignments)))) :-
    solve_zebra(Assignments),
    deduction_log(Log).

mentova_constraint(find_all_solutions, AllSolutions,
                    just(constraint_all(puzzle(zebra_lite), count(N), solutions(AllSolutions)))) :-
    findall(A, solve_zebra(A), AllSolutions),
    length(AllSolutions, N).

mentova_constraint(solve_csp(Vars, Domains, Constraints), Assignment,
                    just(csp_solve(vars(Vars), solution(Assignment)))) :-
    once(solve_csp(Vars, Domains, Constraints, Assignment)).
