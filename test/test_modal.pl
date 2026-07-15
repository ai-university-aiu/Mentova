/*  Mentova — Modal Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/modal.pl, which exports
    mentova_modal/3 — a Kripke-style modal evaluator over a fixed set of
    possible worlds (actual, w1, w2, w3), an accessibility relation, and a
    holds/2 table. It classifies a claim as necessarily true (holds in every
    accessible world), possibly true (holds in some accessible world),
    contingent (possible but not necessary), or impossible, and returns a
    glass-box justification term naming the worlds checked or the witness world.

    Worked facts from the module: birds_fly / fire_is_hot / water_is_wet /
    canary_is_yellow hold in ALL four worlds (necessary); tweety_flies holds
    only in w1 and w2 (contingent, first witness w1); it_rains holds only in
    w1 and w3 (contingent); an unknown atom holds nowhere (impossible).

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_modal.pl
*/

% Declare this file as a test module with no exports.
:- module(test_modal, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(modal)).

% Open the test block for the modal module.
:- begin_tests(modal).

% AC-MODAL-001: a claim true in every accessible world is judged necessarily true.
test(necessarily_true_for_universal_fact) :-
    % Ask whether birds_fly is necessarily true, which holds in all four worlds.
    mentova_modal(necessarily(birds_fly), Result, Justification),
    % The verdict is true.
    assertion(Result == true),
    % The justification names an all-accessible-worlds check with a true result.
    assertion(Justification == just(modal(necessarily(birds_fly),
                                          % Name the all-accessible-worlds check performed.
                                          worlds_checked(all_accessible),
                                          % Record the true result of that check.
                                          result(true)))).

% AC-MODAL-002: a claim absent from some accessible world is NOT necessarily true.
test(necessarily_false_for_nonuniversal_fact) :-
    % Ask whether tweety_flies is necessarily true; it fails in actual and w3.
    mentova_modal(necessarily(tweety_flies), Result, Justification),
    % The verdict is false.
    assertion(Result == false),
    % The justification names an all-accessible-worlds check with a false result.
    assertion(Justification == just(modal(necessarily(tweety_flies),
                                          % Name the all-accessible-worlds check performed.
                                          worlds_checked(all_accessible),
                                          % Record the false result of that check.
                                          result(false)))).

% AC-MODAL-003: a claim true in some accessible world is possibly true, naming its witness.
test(possibly_true_names_first_witness_world) :-
    % Ask whether tweety_flies is possibly true; the first witness accessible is w1.
    mentova_modal(possibly(tweety_flies), Result, Justification),
    % The verdict is true.
    assertion(Result == true),
    % The justification names w1 as the witness world of the true result.
    assertion(Justification == just(modal(possibly(tweety_flies),
                                          % Name the witness world where the claim holds.
                                          witness_world(w1),
                                          % Record the true result of that check.
                                          result(true)))).

% AC-MODAL-004: a claim true in no accessible world is judged not possible.
test(possibly_false_for_unknown_fact) :-
    % Ask whether an atom present in no world is possibly true.
    mentova_modal(possibly(dragons_breathe_fire), Result, Justification),
    % The verdict is false.
    assertion(Result == false),
    % The justification records the exhausted all-accessible-worlds check.
    assertion(Justification == just(modal(possibly(dragons_breathe_fire),
                                          % Name the exhausted all-accessible-worlds check.
                                          worlds_checked(all_accessible),
                                          % Record the false result of that check.
                                          result(false)))).

% AC-MODAL-005: contingent = possible but not necessary, and a necessary fact is not contingent.
test(contingent_true_and_necessary_not_contingent) :-
    % it_rains holds in w1 and w3 but not in actual, so it is contingent.
    mentova_modal(contingent(it_rains), RainResult, RainJustification),
    % The verdict for it_rains is true.
    assertion(RainResult == true),
    % Its justification gives the possible-not-necessary reason.
    assertion(RainJustification == just(modal(contingent(it_rains),
                                              % Name the possible-but-not-necessary reason for the contingent verdict.
                                              reason(possible_not_necessary),
                                              % Record the true result of the contingency check.
                                              result(true)))),
    % birds_fly is necessary, so it is NOT contingent.
    mentova_modal(contingent(birds_fly), BirdResult, BirdJustification),
    % The verdict for birds_fly is false.
    assertion(BirdResult == false),
    % Its justification gives the necessary-or-impossible reason.
    assertion(BirdJustification == just(modal(contingent(birds_fly),
                                             % Name the necessary-or-impossible reason the claim is not contingent.
                                             reason(necessary_or_impossible),
                                             % Record the false result of the contingency check.
                                             result(false)))).

% AC-MODAL-006: classify sorts each claim into necessary, contingent, or impossible.
test(classify_covers_necessary_contingent_impossible) :-
    % A fact true in every world classifies as necessary.
    mentova_modal(classify(fire_is_hot), FireClass, _),
    % fire_is_hot is necessary.
    assertion(FireClass == necessary),
    % A fact true in only some worlds classifies as contingent.
    mentova_modal(classify(it_rains), RainClass, _),
    % it_rains is contingent.
    assertion(RainClass == contingent),
    % A fact true in no world classifies as impossible.
    mentova_modal(classify(dragons_breathe_fire), DragonClass, _),
    % the unknown atom is impossible.
    assertion(DragonClass == impossible),
    % The classify justification simply carries the chosen class.
    mentova_modal(classify(fire_is_hot), _, ClassifyJustification),
    % The justification term reports classification(necessary).
    assertion(ClassifyJustification == just(modal(classify(fire_is_hot),
                                                  % Record the necessary classification in the justification.
                                                  classification(necessary)))).

% Close the test block for the modal module.
:- end_tests(modal).
