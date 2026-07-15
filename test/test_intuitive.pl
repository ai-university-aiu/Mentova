/*  Mentova — Intuitive Reasoning Test Suite  (Rung 43: intuitive)

    Behavioural PLUnit tests for the pure prototype-matching module
    src/mentova/intuitive.pl, which exports mentova_intuitive/3 and
    dispatches on four query forms: classify/1, gut/1, prototypes, and
    match_detail/2. Every expected value below is computed by hand from
    the ten prototype/3 facts and the documented match_score = matched /
    total behaviour, so no test passes trivially.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_intuitive.pl
*/

% Declare this file as a test module exporting nothing.
:- module(test_intuitive, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the intuitive reasoning module under test from the library path.
:- use_module(library(intuitive)).

% Open the test block for the intuitive module.
:- begin_tests(intuitive).

% AC-INT-001: a complete bird feature profile classifies as the bird prototype.
test(classify_full_bird_matches_prototype) :-
    % Ask the module to classify the four defining features of a bird.
    mentova_intuitive(classify([has_wings, has_feathers, can_fly, lays_eggs]),
                      % Capture the returned category, exemplar, and confidence score.
                      match(Category, Exemplar, confidence(Score)), _),
    % The winning category is bird.
    assertion(Category == bird),
    % Its exemplar is the robin.
    assertion(Exemplar == robin),
    % All four of four features match, so the confidence is exactly one.
    assertion(Score =:= 1).

% AC-INT-002: a partial profile picks the highest-scoring prototype, not merely any overlap.
test(classify_partial_prefers_higher_score) :-
    % Classify three features shared strongly by fish and weakly by reptile.
    mentova_intuitive(classify([has_fins, breathes_water, cold_blooded]),
                      % Capture the winning category, exemplar, and score.
                      match(Category, Exemplar, confidence(Score)), _),
    % Fish wins with three of its four features (0.75) over reptile's lone cold_blooded (0.25).
    assertion(Category == fish),
    % The fish exemplar is the salmon.
    assertion(Exemplar == salmon),
    % Three matched features over four total is exactly 0.75.
    assertion(Score =:= 0.75).

% AC-INT-003: the classify justification names the matched category and exemplar transparently.
test(classify_justification_names_category_and_exemplar) :-
    % Classify a complete bird profile and keep the third justification argument.
    mentova_intuitive(classify([has_wings, has_feathers, can_fly, lays_eggs]), _, Just),
    % The justification is a glass-box intuitive/4 term naming the bird category and robin exemplar.
    assertion(Just = just(intuitive(prototype_match(_), category(bird), exemplar(robin), score(_)))).

% AC-INT-004: a gut reaction fires on the first profile feature owned by a prototype.
test(gut_reaction_triggers_on_unique_feature) :-
    % Give the gut path a feature (has_fur) unique to the mammal prototype.
    mentova_intuitive(gut([has_fur, warm_blooded]), Gut, _),
    % has_fur belongs only to the mammal prototype, so the gut reaction names mammal.
    assertion(Gut == gut(mammal, triggered_by(has_fur))).

% AC-INT-005: the gut path skips a feature no prototype owns and triggers on the next one.
test(gut_reaction_skips_unknown_feature_then_triggers) :-
    % Lead with an unknown feature, then a real one, forcing backtracking over the profile.
    mentova_intuitive(gut([sparkles, has_fur]), Result, _),
    % The unknown 'sparkles' matches nothing, so the trigger is has_fur pointing at mammal.
    assertion(Result == gut(mammal, triggered_by(has_fur))).

% AC-INT-006: the prototypes query lists every category-exemplar pair in database order.
test(prototypes_lists_all_ten_category_exemplar_pairs) :-
    % Ask for the full catalogue of known prototypes.
    mentova_intuitive(prototypes, all(Cats), _),
    % The catalogue is exactly the ten prototype/3 facts as Category-Exemplar pairs, in order.
    assertion(Cats == [bird-robin, fish-salmon, mammal-dog, reptile-lizard,
                       insect-ant, fruit-apple, vegetable-carrot, vehicle-car,
                       aircraft-aeroplane, vessel-ship]).

% AC-INT-007: match_detail reports the score and the exact matched-feature list for a named category.
test(match_detail_scores_partial_overlap) :-
    % Ask how three features score against the mammal prototype specifically.
    mentova_intuitive(match_detail([warm_blooded, has_fur, live_birth], mammal),
                      % Capture the echoed category, the score, and the matched features.
                      detail(Category, Score, Matched), _),
    % The category is echoed back as mammal.
    assertion(Category == mammal),
    % Three of the mammal prototype's four features match, giving 0.75.
    assertion(Score =:= 0.75),
    % The matched list keeps prototype order and excludes the unmatched nurses_young.
    assertion(Matched == [warm_blooded, has_fur, live_birth]).

% Close the test block for the intuitive module.
:- end_tests(intuitive).
