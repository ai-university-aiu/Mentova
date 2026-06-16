/*  Mentova — Rung 10: Transductive Reasoning Module

    Classifies a new point by its nearest known cases without forming
    a general rule (k-Nearest Neighbours over the knowledge base).

    A "point" is described by a set of named features.
    Distance is the number of features that differ (Hamming distance).

    Pass criterion: label is correct without forming a general rule.
*/

% Declare this file as the 'transductive' module and list its exported predicates.
:- module(transductive, [
    % Supply 'mentova_transduce/3' as the next argument to the expression above.
    mentova_transduce/3
% Close the expression opened above.
]).

% Import [member/2, append/3] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, append/3]).

% ---------------------------------------------------------------------------
% Known labelled cases: case(Id, Features, Label)
% ---------------------------------------------------------------------------

% Features: list of property=value pairs
% State the fact: known case(c1, [wings=yes, feathers=yes, beak=yes,  flies=yes,  size=small], bird).
known_case(c1, [wings=yes, feathers=yes, beak=yes,  flies=yes,  size=small], bird).
% State the fact: known case(c2, [wings=yes, feathers=yes, beak=yes,  flies=no,   size=medium], bird).
known_case(c2, [wings=yes, feathers=yes, beak=yes,  flies=no,   size=medium], bird).
% State the fact: known case(c3, [wings=no,  feathers=no,  beak=no,   flies=no,   size=medium], mammal).
known_case(c3, [wings=no,  feathers=no,  beak=no,   flies=no,   size=medium], mammal).
% State the fact: known case(c4, [wings=no,  feathers=no,  beak=no,   flies=no,   size=large],  mammal).
known_case(c4, [wings=no,  feathers=no,  beak=no,   flies=no,   size=large],  mammal).
% State the fact: known case(c5, [wings=yes, feathers=no,  beak=no,   flies=yes,  size=medium], insect).
known_case(c5, [wings=yes, feathers=no,  beak=no,   flies=yes,  size=medium], insect).
% State the fact: known case(c6, [wings=no,  feathers=no,  beak=no,   flies=no,   size=small],  mammal).
known_case(c6, [wings=no,  feathers=no,  beak=no,   flies=no,   size=small],  mammal).
% State the fact: known case(c7, [wings=yes, feathers=yes, beak=yes,  flies=yes,  size=large],  bird).
known_case(c7, [wings=yes, feathers=yes, beak=yes,  flies=yes,  size=large],  bird).

% ---------------------------------------------------------------------------
% hamming_distance(+Features1, +Features2, -Distance)
% ---------------------------------------------------------------------------

% State the fact: hamming distance([], [], 0).
hamming_distance([], [], 0).
% Define a clause for 'hamming distance': succeed when the following conditions hold.
hamming_distance([K=V1|Rest1], Features2, D) :-
    % Execute: ( member(K=V2, Features2).
    ( member(K=V2, Features2)
    % If the condition above succeeded, perform the following action.
    ->  ( V1 = V2 -> Diff = 0 ; Diff = 1 )
    % Otherwise (else branch), perform the following action.
    ;   Diff = 1
    % Close the expression opened above.
    ),
    % State a fact for 'hamming rest' with the arguments listed below.
    hamming_rest(Rest1, Features2, DR),
    % Evaluate the arithmetic expression 'Diff + DR' and bind the result to 'D'.
    D is Diff + DR.

% State the fact: hamming rest([], _, 0).
hamming_rest([], _, 0).
% Define a clause for 'hamming rest': succeed when the following conditions hold.
hamming_rest([K=V1|Rest], Features2, D) :-
    % Execute: ( member(K=V2, Features2).
    ( member(K=V2, Features2)
    % If the condition above succeeded, perform the following action.
    ->  ( V1 = V2 -> Diff = 0 ; Diff = 1 )
    % Otherwise (else branch), perform the following action.
    ;   Diff = 1
    % Close the expression opened above.
    ),
    % State a fact for 'hamming rest' with the arguments listed below.
    hamming_rest(Rest, Features2, DR),
    % Evaluate the arithmetic expression 'Diff + DR' and bind the result to 'D'.
    D is Diff + DR.

% ---------------------------------------------------------------------------
% nearest_neighbours(+NewFeatures, +K, -Neighbours)
% Neighbours: list of dist-Label pairs, sorted ascending
% ---------------------------------------------------------------------------

% Define a clause for 'nearest neighbours': succeed when the following conditions hold.
nearest_neighbours(NewFeatures, K, Neighbours) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(D-Label-Id,
            % Continue the multi-line expression started above.
            ( known_case(Id, KnownFeatures, Label),
              % Continue the multi-line expression started above.
              hamming_distance(NewFeatures, KnownFeatures, D)
            % Close the expression opened above.
            ),
            % Supply 'All' as the next argument to the expression above.
            All),
    % Sort list 'All' into 'Sorted', keeping duplicates.
    msort(All, Sorted),
    % Unify 'K' with the number of elements in list 'Prefix'.
    length(Prefix, K),
    % Check that '( append(Prefix, _, Sorted) -> Neighbours' is unifiable with 'Prefix ; Neighbours = Sorted )'.
    ( append(Prefix, _, Sorted) -> Neighbours = Prefix ; Neighbours = Sorted ).

% ---------------------------------------------------------------------------
% mentova_transduce(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova transduce' with the arguments listed below.
mentova_transduce(classify(Features, K), Label,
                  % Continue the multi-line expression started above.
                  just(knn(k(K), neighbours(Neighbours), voted(Label)))) :-
    % State a fact for 'nearest neighbours' with the arguments listed below.
    nearest_neighbours(Features, K, Neighbours),
    % State a fact for 'votes' with the arguments listed below.
    votes(Neighbours, Votes),
    % State the fact: best vote(Votes, Label).
    best_vote(Votes, Label).

% votes(+NeighbourList, -Votes): tally label frequencies
% State the fact: votes([], []).
votes([], []).
% Define a clause for 'votes': succeed when the following conditions hold.
votes([_D-Label-_Id|Rest], Votes) :-
    % State a fact for 'votes' with the arguments listed below.
    votes(Rest, RestVotes),
    % Execute: ( select_vote(Label, RestVotes, N, Others).
    ( select_vote(Label, RestVotes, N, Others)
    % If the condition above succeeded, perform the following action.
    ->  N1 is N + 1,
        % Continue the multi-line expression started above.
        Votes = [Label-N1|Others]
    % Otherwise (else branch), perform the following action.
    ;   Votes = [Label-1|RestVotes]
    % Close the expression opened above.
    ).

% Define a clause for 'select vote': succeed when the following conditions hold.
select_vote(Label, [Label-N|Rest], N, Rest) :- !.
% Define a clause for 'select vote': succeed when the following conditions hold.
select_vote(Label, [Other|Rest], N, [Other|Others]) :-
    % State the fact: select vote(Label, Rest, N, Others).
    select_vote(Label, Rest, N, Others).

% Define a clause for 'best vote': succeed when the following conditions hold.
best_vote([L-N|Rest], Best) :-
    % State the fact: best vote (Rest, L, N, Best).
    best_vote_(Rest, L, N, Best).

% State the fact: best vote ([], Best, _, Best).
best_vote_([], Best, _, Best).
% Define a clause for 'best vote ': succeed when the following conditions hold.
best_vote_([L-N|Rest], _BestSoFar, NBest, Best) :-
    % Check that 'N' is greater than 'NBest, !'.
    N > NBest, !,
    % State the fact: best vote (Rest, L, N, Best).
    best_vote_(Rest, L, N, Best).
% Define a clause for 'best vote ': succeed when the following conditions hold.
best_vote_([_|Rest], BSF, NBest, Best) :-
    % State the fact: best vote (Rest, BSF, NBest, Best).
    best_vote_(Rest, BSF, NBest, Best).
