%% Declare this file as the test_informal module, exporting nothing.
:- module(test_informal, []).
%% Load the PLUnit unit-testing framework.
:- use_module(library(plunit)).
%% Load the informal reasoning module under test.
:- use_module(library(informal)).

%% Open the PLUnit test block named informal.
:- begin_tests(informal).

%% Verify that a known ad hominem argument is detected as a fallacy with its explanation and justification.
test(detect_fallacy_ad_hominem) :-
    %% Ask the module to detect the fallacy in argument arg1, committing to the first solution.
    once(mentova_informal(detect_fallacy(arg1), Result, Just)),
    %% Assert the result names arg1, the ad_hominem fallacy, and its documented explanation.
    assertion(Result == fallacy(arg1, ad_hominem, 'attacks the person not the argument')),
    %% Assert the glass-box justification records the fallacy-detection reasoning for arg1.
    assertion(Just == just(informal(fallacy_detection(arg1),
                                    fallacy(ad_hominem),
                                    explanation('attacks the person not the argument')))).

%% Verify that a different argument maps to its own distinct fallacy (post hoc for arg4).
test(detect_fallacy_post_hoc) :-
    %% Ask the module to detect the fallacy in argument arg4, committing to the first solution.
    once(mentova_informal(detect_fallacy(arg4), Result, _Just)),
    %% Assert arg4 is recognised as the post hoc fallacy with its explanation.
    assertion(Result == fallacy(arg4, post_hoc, 'assumes A caused B because A preceded B')).

%% Verify that a fallacious argument scores as implausible (score 0.2 lands in the 0.0-0.4 band).
test(plausibility_fallacious_is_implausible) :-
    %% Score the plausibility of argument arg1, which carries a fallacy.
    mentova_informal(plausibility(arg1), Result, _Just),
    %% Destructure the plausibility result into its argument id, numeric score, and grade.
    Result = plausibility(arg1, Score, Grade),
    %% Assert the numeric score equals the documented 0.2 for a fallacy-bearing argument.
    assertion(Score =:= 0.2),
    %% Assert the score of 0.2 grades as implausible.
    assertion(Grade == implausible).

%% Verify that a valid rhetorical move is identified with its description.
test(identify_move_analogy) :-
    %% Ask the module to identify the analogy rhetorical move.
    mentova_informal(identify_move(analogy), Result, _Just),
    %% Assert the move is described as clarifying by comparison.
    assertion(Result == move(analogy, 'clarifies by comparison')).

%% Verify that listing the fallacies returns all eight known fallacy-explanation pairs.
test(list_fallacies_returns_eight) :-
    %% Ask the module for the full catalogue of fallacies.
    mentova_informal(list_fallacies, fallacies(List), _Just),
    %% Assert the catalogue holds exactly eight entries.
    assertion(length(List, 8)),
    %% Assert the ad_hominem entry is present with its explanation.
    assertion(memberchk(ad_hominem-'attacks the person not the argument', List)),
    %% Assert the circular-reasoning entry is present with its explanation.
    assertion(memberchk(circular-'conclusion is assumed in the premise', List)).

%% Verify that explaining a named fallacy returns exactly its documented explanation.
test(explain_fallacy_circular) :-
    %% Ask the module to explain the circular-reasoning fallacy.
    mentova_informal(explain_fallacy(circular), Result, _Just),
    %% Assert the explanation is that the conclusion is assumed in the premise.
    assertion(Result == explanation(circular, 'conclusion is assumed in the premise')).

%% Verify Gricean implicature: an understatement carries an inferred stronger meaning.
test(gricean_understatement_implicature) :-
    %% Ask the module for the implicature of the quantity understatement about students.
    mentova_informal(gricean_implicature(understatement, 'Some students passed.'), Result, _Just),
    %% Assert the literal "some" implicates that not all students passed.
    assertion(Result == implicature('Some students passed.', 'Not all students passed.')).

%% Verify Gricean implicature: literal, explicit speech carries no extra implicature.
test(gricean_literal_no_implicature) :-
    %% Ask the module for the implicature of an explicit, literal utterance.
    mentova_informal(gricean_implicature(literal, explicit), Result, _Just),
    %% Assert an explicit message implies no additional meaning.
    assertion(Result == implicature(explicit, none)).

%% Close the PLUnit test block named informal.
:- end_tests(informal).
