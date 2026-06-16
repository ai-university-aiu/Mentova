/*  Mentova — Rung 12: Logical Reasoning Module

    Forward-chaining rule engine: given a set of facts and if-then rules,
    saturate the fact set until no new conclusions can be drawn.

    Pass criterion: conclusion follows with rule chain shown.
*/

:- module(logical, [
    mentova_logical/3
]).

:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% Built-in forward-chaining rule base (if-then rules)
% fc_rule(Conclusion, [Condition1, ...])
% ---------------------------------------------------------------------------

fc_rule(is_animal(X),       [is_bird(X)]).
fc_rule(is_animal(X),       [is_fish(X)]).
fc_rule(is_living(X),       [is_animal(X)]).
fc_rule(is_living(X),       [is_plant(X)]).
fc_rule(can_fly(X),         [is_bird(X), not_flightless(X)]).
fc_rule(is_warm_blooded(X), [is_bird(X)]).
fc_rule(is_warm_blooded(X), [is_mammal(X)]).
fc_rule(needs_water(X),     [is_living(X)]).
fc_rule(is_prey(X),         [is_small(X), is_animal(X)]).
fc_rule(is_predator(X),     [can_fly(X),  is_animal(X)]).

% ---------------------------------------------------------------------------
% forward_chain(+Facts, -AllFacts, -FiredLog)
% ---------------------------------------------------------------------------

forward_chain(Facts, AllFacts, Log) :-
    findall(H-B, fc_rule(H,B), Rules),
    fc_iterate(Facts, Rules, Facts, AllFacts, Log).

fc_iterate(OldFacts, Rules, Acc, AllFacts, Log) :-
    apply_rules(Rules, Acc, NewFacts0, Log0),
    subtract_my(NewFacts0, Acc, TrulyNew),
    ( TrulyNew = []
    ->  AllFacts = Acc, Log = Log0
    ;   append(Acc, TrulyNew, Acc2),
        fc_iterate(OldFacts, Rules, Acc2, AllFacts, LogRest),
        append(Log0, LogRest, Log)
    ).

apply_rules([], _, [], []).
apply_rules([H-B|Rest], Facts, Derived, Log) :-
    apply_rules(Rest, Facts, DerivedRest, LogRest),
    ( \+ member(H, Facts),
      all_satisfied(B, Facts)
    ->  Derived = [H|DerivedRest],
        Log     = [fired(H, from(B))|LogRest]
    ;   Derived = DerivedRest,
        Log     = LogRest
    ).

all_satisfied([], _).
all_satisfied([C|Rest], Facts) :-
    member(C, Facts),
    all_satisfied(Rest, Facts).

subtract_my([], _, []).
subtract_my([H|T], Set, Result) :-
    ( member(H, Set)
    ->  subtract_my(T, Set, Result)
    ;   Result = [H|Rest], subtract_my(T, Set, Rest)
    ).

% ---------------------------------------------------------------------------
% mentova_logical(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% chain(InitFacts): saturate and return all derived facts with rule chain
mentova_logical(chain(InitFacts), derived(AllFacts, Log),
                just(forward_chain(init(InitFacts), rules_fired(Log)))) :-
    forward_chain(InitFacts, AllFacts, Log).

% check(Fact, InitFacts): can Fact be derived?
mentova_logical(check(Fact, InitFacts), Answer,
                just(check(Fact, init(InitFacts), result(Answer), log(Log)))) :-
    forward_chain(InitFacts, AllFacts, Log),
    ( member(Fact, AllFacts) -> Answer = yes ; Answer = no ).

% prove(Goal, InitFacts): derive Goal and show rule chain
mentova_logical(prove(Goal, InitFacts), Answer,
                just(prove(Goal, from(InitFacts), result(Answer), fired(Log)))) :-
    forward_chain(InitFacts, AllFacts, Log),
    ( member(Goal, AllFacts) -> Answer = proved ; Answer = not_provable ).
