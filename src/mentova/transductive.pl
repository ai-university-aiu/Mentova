/*  Mentova — Rung 10: Transductive Reasoning Module

    Classifies a new point by its nearest known cases without forming
    a general rule (k-Nearest Neighbours over the knowledge base).

    A "point" is described by a set of named features.
    Distance is the number of features that differ (Hamming distance).

    Pass criterion: label is correct without forming a general rule.
*/

:- module(transductive, [
    mentova_transduce/3
]).

:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% Known labelled cases: case(Id, Features, Label)
% ---------------------------------------------------------------------------

% Features: list of property=value pairs
known_case(c1, [wings=yes, feathers=yes, beak=yes,  flies=yes,  size=small], bird).
known_case(c2, [wings=yes, feathers=yes, beak=yes,  flies=no,   size=medium], bird).
known_case(c3, [wings=no,  feathers=no,  beak=no,   flies=no,   size=medium], mammal).
known_case(c4, [wings=no,  feathers=no,  beak=no,   flies=no,   size=large],  mammal).
known_case(c5, [wings=yes, feathers=no,  beak=no,   flies=yes,  size=medium], insect).
known_case(c6, [wings=no,  feathers=no,  beak=no,   flies=no,   size=small],  mammal).
known_case(c7, [wings=yes, feathers=yes, beak=yes,  flies=yes,  size=large],  bird).

% ---------------------------------------------------------------------------
% hamming_distance(+Features1, +Features2, -Distance)
% ---------------------------------------------------------------------------

hamming_distance([], [], 0).
hamming_distance([K=V1|Rest1], Features2, D) :-
    ( member(K=V2, Features2)
    ->  ( V1 = V2 -> Diff = 0 ; Diff = 1 )
    ;   Diff = 1
    ),
    hamming_rest(Rest1, Features2, DR),
    D is Diff + DR.

hamming_rest([], _, 0).
hamming_rest([K=V1|Rest], Features2, D) :-
    ( member(K=V2, Features2)
    ->  ( V1 = V2 -> Diff = 0 ; Diff = 1 )
    ;   Diff = 1
    ),
    hamming_rest(Rest, Features2, DR),
    D is Diff + DR.

% ---------------------------------------------------------------------------
% nearest_neighbours(+NewFeatures, +K, -Neighbours)
% Neighbours: list of dist-Label pairs, sorted ascending
% ---------------------------------------------------------------------------

nearest_neighbours(NewFeatures, K, Neighbours) :-
    findall(D-Label-Id,
            ( known_case(Id, KnownFeatures, Label),
              hamming_distance(NewFeatures, KnownFeatures, D)
            ),
            All),
    msort(All, Sorted),
    length(Prefix, K),
    ( append(Prefix, _, Sorted) -> Neighbours = Prefix ; Neighbours = Sorted ).

% ---------------------------------------------------------------------------
% mentova_transduce(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_transduce(classify(Features, K), Label,
                  just(knn(k(K), neighbours(Neighbours), voted(Label)))) :-
    nearest_neighbours(Features, K, Neighbours),
    votes(Neighbours, Votes),
    best_vote(Votes, Label).

% votes(+NeighbourList, -Votes): tally label frequencies
votes([], []).
votes([_D-Label-_Id|Rest], Votes) :-
    votes(Rest, RestVotes),
    ( select_vote(Label, RestVotes, N, Others)
    ->  N1 is N + 1,
        Votes = [Label-N1|Others]
    ;   Votes = [Label-1|RestVotes]
    ).

select_vote(Label, [Label-N|Rest], N, Rest) :- !.
select_vote(Label, [Other|Rest], N, [Other|Others]) :-
    select_vote(Label, Rest, N, Others).

best_vote([L-N|Rest], Best) :-
    best_vote_(Rest, L, N, Best).

best_vote_([], Best, _, Best).
best_vote_([L-N|Rest], _BestSoFar, NBest, Best) :-
    N > NBest, !,
    best_vote_(Rest, L, N, Best).
best_vote_([_|Rest], BSF, NBest, Best) :-
    best_vote_(Rest, BSF, NBest, Best).
