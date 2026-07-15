/*  Mentova — Transductive Reasoning Module Test Suite  (transductive)

    Genuine PLUnit coverage for src/mentova/transductive.pl, the Rung 10
    transductive reasoning module. The module is pure (its labelled case
    library is compiled-in known_case/3 facts, so no lattice, server, or
    asserted state is needed): mentova_transduce(classify(Features, K),
    Label, Justification) classifies a new feature bundle by k-Nearest
    Neighbours over the seven known cases, using Hamming distance (the count
    of differing features) and a majority vote, without forming a general
    rule.

    Every expected value below is computed by hand from the seven
    known_case(Id, Features, Label) facts and the Hamming distance, then
    asserted exactly. The seven cases are:
      c1 bird   [wings=yes, feathers=yes, beak=yes, flies=yes, size=small]
      c2 bird   [wings=yes, feathers=yes, beak=yes, flies=no,  size=medium]
      c3 mammal [wings=no,  feathers=no,  beak=no,  flies=no,  size=medium]
      c4 mammal [wings=no,  feathers=no,  beak=no,  flies=no,  size=large]
      c5 insect [wings=yes, feathers=no,  beak=no,  flies=yes, size=medium]
      c6 mammal [wings=no,  feathers=no,  beak=no,  flies=no,  size=small]
      c7 bird   [wings=yes, feathers=yes, beak=yes, flies=yes, size=large]
    Neighbours are D-Label-Id triples, msort-ordered ascending on distance
    then label then id, truncated to the first K.

    Run with the full library path (every PrologAI pack plus the Mentova src):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_transductive.pl
*/

% Declare this file as a test module with no exports.
:- module(test_transductive, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(transductive)).

% Open the test block for the transductive module.
:- begin_tests(transductive).

% TRANS-001: a bird-like query at k=3 is out-voted by its three nearest bird cases.
test(bird_query_k3_votes_bird) :-
    % Classify a winged, feathered, flying, medium creature against the three nearest cases.
    mentova_transduce(classify([wings=yes, feathers=yes, beak=yes, flies=yes, size=medium], 3),
                      % Bind the output label and its glass-box justification.
                      Label, Justification),
    % The three nearest cases (c1, c2, c7, each distance one) are all birds, so bird wins.
    assertion(Label == bird),
    % The full glass-box justification names k, the ordered nearest neighbours, and the vote.
    assertion(Justification == just(knn(k(3),
                                        % Name the three nearest neighbours in ascending distance order.
                                        neighbours([1-bird-c1, 1-bird-c2, 1-bird-c7]),
                                        % Name the majority vote that decided the label.
                                        voted(bird)))).

% TRANS-002: a mammal-like query at k=3 is decided by its three nearest mammal cases.
test(mammal_query_k3_votes_mammal) :-
    % Classify a wingless, non-flying, medium creature against the three nearest cases.
    mentova_transduce(classify([wings=no, feathers=no, beak=no, flies=no, size=medium], 3),
                      % Bind the output label and its glass-box justification.
                      Label, Justification),
    % The three nearest cases (c3 at distance zero, c4 and c6 at distance one) are all mammals.
    assertion(Label == mammal),
    % The justification lists exactly those three mammal neighbours in ascending order.
    assertion(Justification == just(knn(k(3),
                                        % Name the three nearest mammal neighbours in ascending distance order.
                                        neighbours([0-mammal-c3, 1-mammal-c4, 1-mammal-c6]),
                                        % Name the majority vote that decided the label.
                                        voted(mammal)))).

% TRANS-003: an exact copy of the lone insect case at k=1 classifies as insect.
test(insect_query_k1_votes_insect) :-
    % Classify a feature bundle identical to case c5 against its single nearest neighbour.
    mentova_transduce(classify([wings=yes, feathers=no, beak=no, flies=yes, size=medium], 1),
                      % Bind the output label and its glass-box justification.
                      Label, Justification),
    % Its own zero-distance match c5 is the sole neighbour, so the rare label insect is chosen.
    assertion(Label == insect),
    % The justification carries the single zero-distance insect neighbour.
    assertion(Justification == just(knn(k(1),
                                        % Name the single zero-distance neighbour.
                                        neighbours([0-insect-c5]),
                                        % Name the majority vote that decided the label.
                                        voted(insect)))).

% TRANS-004: a query identical to a known case sits at Hamming distance zero from it.
test(exact_match_is_distance_zero) :-
    % Classify a bundle identical to mammal case c3 with a single nearest neighbour.
    mentova_transduce(classify([wings=no, feathers=no, beak=no, flies=no, size=medium], 1),
                      % Bind the label and destructure the justification to capture the neighbours list directly.
                      Label, just(knn(k(1), neighbours(Neighbours), voted(_)))),
    % The nearest neighbour is c3 at distance zero — an identical bundle differs in nothing.
    assertion(Neighbours == [0-mammal-c3]),
    % And that zero-distance case fixes the label as mammal.
    assertion(Label == mammal).

% TRANS-005: k controls how many neighbours are considered, yet the majority still holds.
test(k_five_returns_five_neighbours) :-
    % Classify the bird-like query but widen the neighbourhood to five cases.
    mentova_transduce(classify([wings=yes, feathers=yes, beak=yes, flies=yes, size=medium], 5),
                      % Bind the label and destructure the justification to capture the five neighbours directly.
                      Label, just(knn(k(5), neighbours(Neighbours), voted(_)))),
    % Exactly five nearest neighbours are returned when k is five.
    assertion(length(Neighbours, 5)),
    % The three bird cases outvote the single insect and single mammal in that window.
    assertion(Label == bird),
    % The five neighbours are the smallest-distance triples in ascending order.
    assertion(Neighbours == [1-bird-c1, 1-bird-c2, 1-bird-c7, 2-insect-c5, 4-mammal-c3]).

% TRANS-006: classification commits to a single answer — the predicate is deterministic.
test(classification_is_deterministic) :-
    % Collect every label the module offers for the bird-like query at k=3.
    findall(L,
            % Classify the bird-like query at k=3 inside the findall template.
            mentova_transduce(classify([wings=yes, feathers=yes, beak=yes, flies=yes, size=medium], 3),
                              % Bind the label to L and discard the justification.
                              L, _),
            % Collect every label solution into the Labels list.
            Labels),
    % There is exactly one solution: the unambiguous majority vote bird.
    assertion(Labels == [bird]).

% Close the test block for the transductive module.
:- end_tests(transductive).
