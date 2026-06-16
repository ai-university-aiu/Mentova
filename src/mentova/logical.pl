/*  Mentova — Rung 12: Logical Reasoning Module

    Forward-chaining rule engine: given a set of facts and if-then rules,
    saturate the fact set until no new conclusions can be drawn.

    Pass criterion: conclusion follows with rule chain shown.
*/

% Declare this file as the 'logical' module and list its exported predicates.
:- module(logical, [
    % Supply 'mentova_logical/3' as the next argument to the expression above.
    mentova_logical/3
% Close the expression opened above.
]).

% Import [member/2, append/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% Built-in forward-chaining rule base (if-then rules)
% fc_rule(Conclusion, [Condition1, ...])
% ---------------------------------------------------------------------------

% State the fact: fc rule(is_animal(X),       [is_bird(X)]).
fc_rule(is_animal(X),       [is_bird(X)]).
% State the fact: fc rule(is_animal(X),       [is_fish(X)]).
fc_rule(is_animal(X),       [is_fish(X)]).
% State the fact: fc rule(is_living(X),       [is_animal(X)]).
fc_rule(is_living(X),       [is_animal(X)]).
% State the fact: fc rule(is_living(X),       [is_plant(X)]).
fc_rule(is_living(X),       [is_plant(X)]).
% State the fact: fc rule(can_fly(X),         [is_bird(X), not_flightless(X)]).
fc_rule(can_fly(X),         [is_bird(X), not_flightless(X)]).
% State the fact: fc rule(is_warm_blooded(X), [is_bird(X)]).
fc_rule(is_warm_blooded(X), [is_bird(X)]).
% State the fact: fc rule(is_warm_blooded(X), [is_mammal(X)]).
fc_rule(is_warm_blooded(X), [is_mammal(X)]).
% State the fact: fc rule(needs_water(X),     [is_living(X)]).
fc_rule(needs_water(X),     [is_living(X)]).
% State the fact: fc rule(is_prey(X),         [is_small(X), is_animal(X)]).
fc_rule(is_prey(X),         [is_small(X), is_animal(X)]).
% State the fact: fc rule(is_predator(X),     [can_fly(X),  is_animal(X)]).
fc_rule(is_predator(X),     [can_fly(X),  is_animal(X)]).

% ---------------------------------------------------------------------------
% forward_chain(+Facts, -AllFacts, -FiredLog)
% ---------------------------------------------------------------------------

% Define a clause for 'forward chain': succeed when the following conditions hold.
forward_chain(Facts, AllFacts, Log) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(H-B, fc_rule(H,B), Rules),
    % State the fact: fc iterate(Facts, Rules, Facts, AllFacts, Log).
    fc_iterate(Facts, Rules, Facts, AllFacts, Log).

% Define a clause for 'fc iterate': succeed when the following conditions hold.
fc_iterate(OldFacts, Rules, Acc, AllFacts, Log) :-
    % State a fact for 'apply rules' with the arguments listed below.
    apply_rules(Rules, Acc, NewFacts0, Log0),
    % State a fact for 'subtract my' with the arguments listed below.
    subtract_my(NewFacts0, Acc, TrulyNew),
    % Check that '( TrulyNew' is unifiable with '[]'.
    ( TrulyNew = []
    % If the condition above succeeded, perform the following action.
    ->  AllFacts = Acc, Log = Log0
    % Otherwise (else branch), perform the following action.
    ;   append(Acc, TrulyNew, Acc2),
        % Continue the multi-line expression started above.
        fc_iterate(OldFacts, Rules, Acc2, AllFacts, LogRest),
        % Continue the multi-line expression started above.
        append(Log0, LogRest, Log)
    % Close the expression opened above.
    ).

% State the fact: apply rules([], _, [], []).
apply_rules([], _, [], []).
% Define a clause for 'apply rules': succeed when the following conditions hold.
apply_rules([H-B|Rest], Facts, Derived, Log) :-
    % State a fact for 'apply rules' with the arguments listed below.
    apply_rules(Rest, Facts, DerivedRest, LogRest),
    % Execute: ( \+ member(H, Facts),.
    ( \+ member(H, Facts),
      % Continue the multi-line expression started above.
      all_satisfied(B, Facts)
    % If the condition above succeeded, perform the following action.
    ->  Derived = [H|DerivedRest],
        % Continue the multi-line expression started above.
        Log     = [fired(H, from(B))|LogRest]
    % Otherwise (else branch), perform the following action.
    ;   Derived = DerivedRest,
        % Continue the multi-line expression started above.
        Log     = LogRest
    % Close the expression opened above.
    ).

% State the fact: all satisfied([], _).
all_satisfied([], _).
% Define a clause for 'all satisfied': succeed when the following conditions hold.
all_satisfied([C|Rest], Facts) :-
    % Succeed for each element 'C' that is a member of the list.
    member(C, Facts),
    % State the fact: all satisfied(Rest, Facts).
    all_satisfied(Rest, Facts).

% State the fact: subtract my([], _, []).
subtract_my([], _, []).
% Define a clause for 'subtract my': succeed when the following conditions hold.
subtract_my([H|T], Set, Result) :-
    % Execute: ( member(H, Set).
    ( member(H, Set)
    % If the condition above succeeded, perform the following action.
    ->  subtract_my(T, Set, Result)
    % Otherwise (else branch), perform the following action.
    ;   Result = [H|Rest], subtract_my(T, Set, Rest)
    % Close the expression opened above.
    ).

% ---------------------------------------------------------------------------
% mentova_logical(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% chain(InitFacts): saturate and return all derived facts with rule chain
% State a fact for 'mentova logical' with the arguments listed below.
mentova_logical(chain(InitFacts), derived(AllFacts, Log),
                % Continue the multi-line expression started above.
                just(forward_chain(init(InitFacts), rules_fired(Log)))) :-
    % State the fact: forward chain(InitFacts, AllFacts, Log).
    forward_chain(InitFacts, AllFacts, Log).

% check(Fact, InitFacts): can Fact be derived?
% State a fact for 'mentova logical' with the arguments listed below.
mentova_logical(check(Fact, InitFacts), Answer,
                % Continue the multi-line expression started above.
                just(check(Fact, init(InitFacts), result(Answer), log(Log)))) :-
    % State a fact for 'forward chain' with the arguments listed below.
    forward_chain(InitFacts, AllFacts, Log),
    % Check that '( member(Fact, AllFacts) -> Answer' is unifiable with 'yes ; Answer = no )'.
    ( member(Fact, AllFacts) -> Answer = yes ; Answer = no ).

% prove(Goal, InitFacts): derive Goal and show rule chain
% State a fact for 'mentova logical' with the arguments listed below.
mentova_logical(prove(Goal, InitFacts), Answer,
                % Continue the multi-line expression started above.
                just(prove(Goal, from(InitFacts), result(Answer), fired(Log)))) :-
    % State a fact for 'forward chain' with the arguments listed below.
    forward_chain(InitFacts, AllFacts, Log),
    % Check that '( member(Goal, AllFacts) -> Answer' is unifiable with 'proved ; Answer = not_provable )'.
    ( member(Goal, AllFacts) -> Answer = proved ; Answer = not_provable ).
