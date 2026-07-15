/*  Mentova — Paraconsistent Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/paraconsistent.pl, which exports
    mentova_paraconsistent/3 — paraconsistent reasoning over the Small-World
    knowledge base. The base carries a deliberate contradiction for tweety:
    the default rule "birds fly" makes flies(tweety) derivable, while the
    exception rule for flightless birds makes does-not-fly derivable. The
    predicate isolates that contradictory pair (tagging it 'both') and keeps
    reasoning about unrelated propositions without explosion (ex contradictione
    quodlibet avoided). It answers four query forms, each returning a glass-box
    justification term:
      - check(Prop)                 : the paraconsistent tag (both | true).
      - unaffected(Prop)            : an unrelated proposition survives, and the
                                      contradictory prop itself is excluded.
      - explain_contradiction(Prop) : the default and exception that both fire.
      - true_elsewhere(Subject)     : what stays true for a subject regardless.

    Worked facts from the module and Small-World base: flies(tweety) tags 'both'
    (default fires AND penguin_exception fires); flies(canary) tags 'true' (the
    default fires, no exception applies); the contradiction is named
    contradiction(flies(tweety), both); explain_contradiction(flies(tweety))
    lists [default_applies(flies(tweety)), exception(penguin_exception)];
    true_elsewhere(canary) = [flies(canary), is_a(canary, bird)] and
    true_elsewhere(tweety) = [is_a(tweety, bird)] (flies(tweety) is NOT listed,
    since it is tagged 'both', not 'true').

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_paraconsistent.pl
*/

% Declare this file as a test module with no exports.
:- module(test_paraconsistent, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(paraconsistent)).

% Open the test block for the paraconsistent module.
:- begin_tests(paraconsistent).

% AC-PARA-001: the contradictory proposition is tagged 'both' with an isolation flag.
test(check_contradiction_tags_both) :-
    % Ask for the paraconsistent tag of flies(tweety), the built-in contradiction.
    mentova_paraconsistent(check(flies(tweety)), Result, Justification),
    % Both the default (birds fly) and the exception (flightless) fire, so the tag is both.
    assertion(Result == both),
    % The justification names the proposition, its tag, and that it is isolated.
    assertion(Justification == just(paraconsistent(flies(tweety), tag(both), isolated(yes)))).

% AC-PARA-002: a non-contradictory proposition is tagged plain 'true'.
test(check_consistent_tags_true) :-
    % Ask for the paraconsistent tag of flies(canary), which has no exception.
    mentova_paraconsistent(check(flies(canary)), Result, Justification),
    % The default fires and no exception applies, so the tag is a clean true.
    assertion(Result == true),
    % The justification names the proposition, its true tag, and the isolation flag.
    assertion(Justification == just(paraconsistent(flies(canary), tag(true), isolated(yes)))).

% AC-PARA-003: an unrelated proposition survives the contradiction (no explosion).
test(unaffected_proposition_survives) :-
    % Ask whether flies(canary) is unaffected by the tweety contradiction.
    mentova_paraconsistent(unaffected(flies(canary)), Answer, Justification),
    % The unrelated proposition still resolves to true.
    assertion(Answer == true),
    % The justification names the contradiction it is isolated from and records explosion_avoided.
    assertion(Justification == just(paraconsistent_isolation(
                                        % Name the contradiction this proposition is isolated from.
                                        contradiction(flies(tweety), both),
                                        % Name the unrelated proposition and its own true value.
                                        unrelated(flies(canary), true),
                                        % Record that explosion was avoided.
                                        explosion_avoided))).

% AC-PARA-004: the contradictory proposition itself is excluded from the unaffected set.
test(contradictory_prop_is_not_unaffected) :-
    % The unaffected query must FAIL for flies(tweety), since it is the contradiction.
    assertion(\+ mentova_paraconsistent(unaffected(flies(tweety)), _, _)).

% AC-PARA-005: explaining the contradiction lists both the default and the exception that fire.
test(explain_contradiction_names_both_sides) :-
    % Ask why flies(tweety) is contradictory.
    mentova_paraconsistent(explain_contradiction(flies(tweety)), Explanation, Justification),
    % The explanation pairs the proposition with the two reasons that collide.
    assertion(Explanation == explanation(flies(tweety),
                                         % List the default and the exception that both fire.
                                         [default_applies(flies(tweety)), exception(penguin_exception)])),
    % The justification carries the same proposition-and-reasons pair.
    assertion(Justification == just(contradiction_explanation(flies(tweety),
                                         % List the same default-and-exception pair inside the justification.
                                         [default_applies(flies(tweety)), exception(penguin_exception)]))).

% AC-PARA-006: truths for a subject persist despite the contradiction, and the 'both' prop is not among them.
test(true_elsewhere_persists_despite_contradiction) :-
    % For canary, both its flight and its bird-hood stay true.
    mentova_paraconsistent(true_elsewhere(canary), CanaryTrue, CanaryJust),
    % The canary's surviving truths are its flight and its taxonomy, in that order.
    assertion(CanaryTrue == [flies(canary), is_a(canary, bird)]),
    % The justification carries the subject and its surviving-truths list.
    assertion(CanaryJust == just(paraconsistent_true(canary, [flies(canary), is_a(canary, bird)]))),
    % For tweety, only its bird-hood survives as a clean truth.
    mentova_paraconsistent(true_elsewhere(tweety), TweetyTrue, _),
    % tweety stays a bird, and crucially flies(tweety) is absent because it is tagged 'both', not 'true'.
    assertion(TweetyTrue == [is_a(tweety, bird)]).

% Close the test block for the paraconsistent module.
:- end_tests(paraconsistent).
