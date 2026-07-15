/*  Mentova — Analogical Reasoning Test Suite  (analogical module)

    Behavioural PLUnit coverage for the 'analogical' module, whose single
    export mentova_analogy/3 completes an A-to-B-as-C-to-? analogy by
    structure mapping over the small_world commonsense knowledge base.

    Each expected filler below is computed by hand from the facts in
    knowledge/small_world.pl and the two clauses of mentova_analogy/3:
      clause one prefers a filler D different from B (D \= B);
      clause two falls back to any D, including D = B (same-class analogy).

    Run with the full library path (every PrologAI pack plus Mentova src):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_analogical.pl
*/

% Declare this file as a test-only module with no exports.
:- module(test_analogical, []).
% Load the PLUnit testing framework.
:- use_module(library(plunit)).
% Load the module under test (it pulls in the small_world knowledge base itself).
:- use_module(library(analogical)).

% Open the test block named for the module under test.
:- begin_tests(analogical).

% An is_a analogy prefers a filler that differs from B, then falls back to bird.
test(is_a_canary_bird_eagle) :-
    % Take the first analogical completion for canary:bird :: eagle:?.
    once(mentova_analogy(analogy(canary, bird, eagle, ?), D, _)),
    % The eagle is also a bird, so the completed filler is bird.
    assertion(D == bird).

% A capable_of analogy maps the knife's cutting power to the hammer's.
test(capable_of_knife_cut_hammer) :-
    % Take the first completion for knife:cut :: hammer:?.
    once(mentova_analogy(analogy(knife, cut, hammer, ?), D, _)),
    % A hammer is capable_of drive_nail, so that is the filler.
    assertion(D == drive_nail).

% The justification term records the filler and the relation it travelled through.
test(justification_records_relation) :-
    % Take the first completion and its justification for knife:cut :: hammer:?.
    once(mentova_analogy(analogy(knife, cut, hammer, ?), D, J)),
    % The filler is drive_nail as computed above.
    assertion(D == drive_nail),
    % The justification names the mapped filler and the via-relation list [capable_of].
    assertion(J == just(analogy(knife, cut, hammer, drive_nail, via([capable_of])))).

% A part_of analogy maps a wing-of-bird to a leaf-of-tree.
test(part_of_wing_bird_leaf) :-
    % Take the first completion for wing:bird :: leaf:?.
    once(mentova_analogy(analogy(wing, bird, leaf, ?), D, _)),
    % A leaf is part_of a tree, and tree differs from bird, so the filler is tree.
    assertion(D == tree).

% A used_for analogy maps the knife's cutting use to the hammer's building use.
test(used_for_knife_cutting_hammer) :-
    % Take the first completion for knife:cutting :: hammer:?.
    once(mentova_analogy(analogy(knife, cutting, hammer, ?), D, _)),
    % A hammer is used_for building, which differs from cutting, so the filler is building.
    assertion(D == building).

% A has_property analogy maps the canary's colour to the rose's colour.
test(has_property_canary_yellow_rose) :-
    % Take the first completion for canary:yellow :: rose:?.
    once(mentova_analogy(analogy(canary, yellow, rose, ?), D, _)),
    % A rose has_property red, which differs from yellow, so the filler is red.
    assertion(D == red).

% An at_location analogy maps the fish-in-water to the bird-in-sky.
test(at_location_fish_water_bird) :-
    % Take the first completion for fish:water :: bird:?.
    once(mentova_analogy(analogy(fish, water, bird, ?), D, _)),
    % A bird is at_location sky, which differs from water, so the filler is sky.
    assertion(D == sky).

% When no relation connects A to B the analogy has nothing to map and fails.
test(no_relation_fails, [fail]) :-
    % There is no relation holding between canary and purple, so this must fail.
    mentova_analogy(analogy(canary, purple, eagle, ?), _, _).

% Enumerating every completion for the is_a case yields exactly the single filler bird.
test(all_solutions_is_a) :-
    % Collect every filler the predicate can produce for canary:bird :: eagle:?.
    findall(D, mentova_analogy(analogy(canary, bird, eagle, ?), D, _), Ds),
    % Only bird is derivable (clause one is blocked by D \= B; clause two yields bird once).
    assertion(Ds == [bird]).

% Close the test block named for the module under test.
:- end_tests(analogical).
