/*  Mentova — Qualitative Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/qualitative.pl, which exports
    mentova_qualitative/3 — qualitative causal reasoning without numbers.
    Quantities carry a sign (+, 0, -) and relations are increases/2,
    decreases/2, no_effect/2 over a built-in knowledge base. The single
    entry point mentova_qualitative(+Query, -Result, -Justification)
    answers four query shapes: direction(X,Y) reads a stored relation;
    chain(X,Y,Z) multiplies two hop signs through the qualitative
    multiplication table; compare_effect(X,A,B) reports which of A and B
    a rise in X benefits; and predict(X,up|down) lists every quantity X
    moves and the direction it moves them. Each answer carries a
    glass-box justification term.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_qualitative.pl
*/

% Declare this file as a test module with no exports.
:- module(test_qualitative, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(qualitative)).

% Open the test block for the qualitative module.
:- begin_tests(qualitative).

% AC-QUAL-001: a direction query reads the stored sign of a single relation.
test(direction_reads_stored_relation) :-
    % A stored increases/2 relation reports the increases direction (take the one documented answer).
    once(mentova_qualitative(direction(temperature, evaporation), Up, UpJust)),
    % More temperature means more evaporation.
    assertion(Up == increases),
    % The justification names the exact stored relation it read.
    assertion(UpJust == just(increases(temperature, evaporation))),
    % A stored decreases/2 relation reports the decreases direction.
    once(mentova_qualitative(direction(temperature, ice_thickness), Down, DownJust)),
    % More temperature means less ice thickness.
    assertion(Down == decreases),
    % The justification names the decreasing relation.
    assertion(DownJust == just(decreases(temperature, ice_thickness))),
    % A stored no_effect/2 relation reports no effect.
    once(mentova_qualitative(direction(temperature, gravity), Flat, FlatJust)),
    % Temperature does not move gravity.
    assertion(Flat == no_effect),
    % The justification names the no-effect relation.
    assertion(FlatJust == just(no_effect(temperature, gravity))).

% AC-QUAL-002: a two-hop chain multiplies the two hop signs.
test(chain_multiplies_hop_signs) :-
    % Sunlight raises temperature (pos) which lowers ice thickness (neg); take the one documented answer.
    once(mentova_qualitative(chain(sunlight, temperature, ice_thickness), NegResult, NegJust)),
    % Positive times negative is negative, so the net effect is a decrease.
    assertion(NegResult == decreases),
    % The justification records the intermediate node and the inferred sign.
    assertion(NegJust == just(chain(sunlight, via(temperature), ice_thickness, inferred(decreases)))),
    % Sunlight raises temperature (pos) which raises pressure (pos).
    once(mentova_qualitative(chain(sunlight, temperature, pressure), PosResult, _)),
    % Positive times positive is positive, so the net effect is an increase.
    assertion(PosResult == increases).

% AC-QUAL-003: compare_effect names which of the two targets a rise in X benefits.
test(compare_effect_picks_the_winner) :-
    % Temperature raises both evaporation and pressure.
    mentova_qualitative(compare_effect(temperature, evaporation, pressure), Both, BothJust),
    % When X raises both targets, the winner is both.
    assertion(Both == both),
    % The justification carries the winner it chose.
    assertion(BothJust == just(compare_effect(temperature, evaporation, pressure, winner(both)))),
    % Temperature raises evaporation but has no increases relation to fitness.
    mentova_qualitative(compare_effect(temperature, evaporation, fitness), FirstWins, _),
    % Only the first target rises, so the winner is that first target.
    assertion(FirstWins == evaporation),
    % Colour raises neither mass nor evaporation.
    mentova_qualitative(compare_effect(colour, mass, evaporation), Neither, _),
    % When X raises neither target, the answer is neither.
    assertion(Neither == neither).

% AC-QUAL-004: predict(X, up) lists every quantity a rise in X moves, with its direction.
test(predict_up_lists_signed_changes) :-
    % Raising exercise moves fitness, fatigue and weight.
    mentova_qualitative(predict(exercise, up), Changes, ChangesJust),
    % Exercise raises fitness and fatigue and lowers weight, in stored order.
    assertion(Changes == [fitness-increases, fatigue-increases, weight-decreases]),
    % The justification carries the same change list under the up direction.
    assertion(ChangesJust == just(predict(exercise, up, changes([fitness-increases, fatigue-increases, weight-decreases])))).

% AC-QUAL-005: predict(X, down) inverts every direction relative to predict up.
test(predict_down_inverts_each_direction) :-
    % Lowering exercise moves the same quantities the opposite way.
    mentova_qualitative(predict(exercise, down), Changes, _),
    % Each stored increase becomes a decrease and the stored decrease becomes an increase.
    assertion(Changes == [fitness-decreases, fatigue-decreases, weight-increases]).

% AC-QUAL-006: predicting from a quantity with no outgoing relations yields [none].
test(predict_with_no_relations_is_none) :-
    % Gravity appears only as an effect, never as a cause, so it moves nothing.
    mentova_qualitative(predict(gravity, up), Changes, ChangesJust),
    % With no changes to report the module returns the singleton [none].
    assertion(Changes == [none]),
    % The justification carries that same empty-case marker.
    assertion(ChangesJust == just(predict(gravity, up, changes([none])))).

% Close the test block for the qualitative module.
:- end_tests(qualitative).
