/*  Mentova — Inductive Reasoning Module Test Suite  (induction)

    Genuine PLUnit coverage for src/mentova/induction.pl, the Rung 2
    inductive logic programming module. It exports:

        mentova_induce/4 — +Pos, +Neg, +Background, -Rule : generate-and-test
                           ILP that returns the shortest rule (Head :- Body)
                           covering every positive and no negative example;
                           background conditions are cond(Pred, Extra) (builds
                           Pred(X, Extra...)) and neg_cond(Pred, Extra) (builds
                           \+ Pred(X, Extra...)), and length-1 bodies are tried
                           before length-2 so simpler rules win.
        apply_rule/3     — +Head, +Body, +Example : copies the rule and tests
                           whether Example satisfies the body, binding nothing
                           in the caller.

    Every expected rule below is computed by hand from the module's search
    order and the small_world facts it reasons over (is_a/2, has_property/2):
        is_a(canary,bird), is_a(eagle,bird), is_a(salmon,fish), is_a(rose,flower)
        has_property(penguin,flightless), has_property(canary,yellow),
        has_property(eagle,large)
    so canary and eagle are flying birds, penguin is a flightless bird, and
    salmon and rose are not birds.

    Run with the full library path (every PrologAI pack plus the Mentova src):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_induction.pl
*/

% Declare this file as a test module with no exports.
:- module(test_induction, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(induction)).

% Open the test block for the induction module.
:- begin_tests(induction).

% AC-IND-001: from two flying birds against non-birds, induce the single-condition rule flies(X) :- is_a(X, bird).
test(induce_bird_flight_single_condition) :-
    % Induce a rule (committing to the first/shortest) over a background offering only is_a(X, bird).
    once(mentova_induce([flies(canary), flies(eagle)], [flies(salmon), flies(rose)],
                        [cond(is_a, [bird])], Rule)),
    % The induced rule splits into a head and a body.
    Rule = (Head :- Body),
    % The head is the target predicate applied to a single fresh variable.
    Head = flies(HeadVar),
    % The body is exactly the one background condition is_a(_, bird).
    Body = is_a(BodyVar, bird),
    % The head variable is still an unbound logic variable.
    assertion(var(HeadVar)),
    % The head variable and the body variable are the SAME shared variable.
    assertion(HeadVar == BodyVar),
    % The body is a single goal, not a conjunction (the shortest rule is preferred).
    assertion(Body \= (_,_)),
    % Behaviourally the rule covers the first positive example, canary.
    assertion(apply_rule(Head, Body, flies(canary))),
    % Behaviourally the rule covers the second positive example, eagle.
    assertion(apply_rule(Head, Body, flies(eagle))),
    % The rule excludes the fish negative, salmon.
    assertion(\+ apply_rule(Head, Body, flies(salmon))),
    % The rule excludes the flower negative, rose.
    assertion(\+ apply_rule(Head, Body, flies(rose))).

% AC-IND-002: with a lone flightless-bird negative and a negatable background, prefer the negated single literal.
test(induce_prefers_negated_condition) :-
    % Induce (committing to the first rule) over is_a(X, bird) and the negatable has_property(X, flightless).
    once(mentova_induce([flies(canary), flies(eagle)], [flies(penguin)],
                        [cond(is_a, [bird]), neg_cond(has_property, [flightless])], Rule)),
    % Split the rule into head and body.
    Rule = (Head :- Body),
    % The head is the target over one fresh variable.
    Head = flies(HeadVar),
    % is_a(X, bird) alone would cover the penguin negative, so the negated literal is chosen instead.
    Body = (\+ has_property(BodyVar, flightless)),
    % Head and body share the one variable.
    assertion(HeadVar == BodyVar),
    % The body is a single negated goal, not a conjunction.
    assertion(Body \= (_,_)),
    % The rule covers canary, which is not flightless.
    assertion(apply_rule(Head, Body, flies(canary))),
    % The rule covers eagle, which is not flightless.
    assertion(apply_rule(Head, Body, flies(eagle))),
    % The rule excludes penguin, which is flightless.
    assertion(\+ apply_rule(Head, Body, flies(penguin))).

% AC-IND-003: when no single literal separates the examples, induce a two-literal conjunction.
test(induce_two_condition_conjunction) :-
    % Positives are two flying birds; negatives are a flightless bird and a non-bird; commit to the first rule.
    once(mentova_induce([flies(canary), flies(eagle)], [flies(penguin), flies(salmon)],
                        [cond(is_a, [bird]), neg_cond(has_property, [flightless])], Rule)),
    % Split the rule into head and body.
    Rule = (Head :- Body),
    % The head is the target over one fresh variable.
    Head = flies(HeadVar),
    % The body is the conjunction of the two literals.
    Body = (First, Second),
    % The first literal is the positive class membership is_a(_, bird).
    First = is_a(Var1, bird),
    % The second literal is the negated property \+ has_property(_, flightless).
    Second = (\+ has_property(Var2, flightless)),
    % The head variable and the first body variable are the same shared variable.
    assertion(HeadVar == Var1),
    % The two body literals share that variable too.
    assertion(Var1 == Var2),
    % The rule covers the positive canary.
    assertion(apply_rule(Head, Body, flies(canary))),
    % The rule covers the positive eagle.
    assertion(apply_rule(Head, Body, flies(eagle))),
    % The rule excludes the flightless-bird negative penguin.
    assertion(\+ apply_rule(Head, Body, flies(penguin))),
    % The rule excludes the non-bird negative salmon.
    assertion(\+ apply_rule(Head, Body, flies(salmon))).

% AC-IND-004: apply_rule/3 tests a candidate rule against an example and binds nothing in the caller.
test(apply_rule_covers_and_excludes) :-
    % A single-condition body accepts a bird example.
    assertion(apply_rule(flies(X1), is_a(X1, bird), flies(canary))),
    % The same body rejects a fish example.
    assertion(\+ apply_rule(flies(X2), is_a(X2, bird), flies(salmon))),
    % A conjunctive body with a negated literal accepts a flying bird.
    assertion(apply_rule(flies(X3), (is_a(X3, bird), \+ has_property(X3, flightless)), flies(eagle))),
    % The same conjunctive body rejects a flightless bird.
    assertion(\+ apply_rule(flies(X4), (is_a(X4, bird), \+ has_property(X4, flightless)), flies(penguin))),
    % apply_rule copies the rule before testing, so the caller's variable stays unbound.
    assertion(( apply_rule(flies(X5), is_a(X5, bird), flies(canary)), var(X5) )).

% AC-IND-005: when a one-literal rule already separates the data, it is preferred over a longer one.
test(induce_prefers_shorter_rule) :-
    % The same rich background as the conjunction case, but an easier negative set; commit to the first rule.
    once(mentova_induce([flies(canary), flies(eagle)], [flies(salmon)],
                        [cond(is_a, [bird]), neg_cond(has_property, [flightless])], Rule)),
    % Split the rule into head and body.
    Rule = (Head :- Body),
    % is_a(X, bird) already excludes the non-bird salmon, so the single literal is returned.
    Head = flies(HeadVar),
    % The body is exactly that single membership literal.
    Body = is_a(BodyVar, bird),
    % Even though a two-literal rule also fits, the body is not a conjunction.
    assertion(Body \= (_,_)),
    % Head and body share the one variable.
    assertion(HeadVar == BodyVar),
    % The single-literal rule covers the first positive, canary.
    assertion(apply_rule(Head, Body, flies(canary))),
    % It also covers the second positive, eagle.
    assertion(apply_rule(Head, Body, flies(eagle))),
    % And it excludes the negative, salmon.
    assertion(\+ apply_rule(Head, Body, flies(salmon))).

% AC-IND-006: when the same example is both a positive and a negative, no rule can be induced.
test(induce_fails_when_unseparable) :-
    % No body can cover canary as a positive and simultaneously exclude it as a negative.
    assertion(\+ mentova_induce([flies(canary)], [flies(canary)], [cond(is_a, [bird])], _Rule)).

% Close the test block for the induction module.
:- end_tests(induction).
