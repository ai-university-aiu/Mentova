/*  Mentova — Rung 40: Strategic Reasoning Module

    Reasons about optimal strategy in competitive and cooperative settings.
    Implements minimax for two-player zero-sum games and Nash equilibrium
    detection for simple matrix games.
    Pass criterion: return the optimal move in a game position with minimax
    value and strategy justification.
*/

% Declare this file as the 'strategic' module and list its exported predicates.
:- module(strategic, [
    % Supply 'mentova_strategic/3' as the next argument to the expression above.
    mentova_strategic/3
% Close the expression opened above.
]).

% Import [member/2, max_list/2, min_list/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2, max_list/2, min_list/2]).

% ---------------------------------------------------------------------------
% Game tree: node(Position, Player, Moves)
% Leaf: leaf(Position, Value)  (value from maximiser's perspective)
% ---------------------------------------------------------------------------

% Simple tic-tac-toe-like tree (3 depth)
% State a fact for 'game tree' with the arguments listed below.
game_tree(root, max, [
    % Continue the multi-line expression started above.
    move(a, leaf(a, 3)),
    % Continue the multi-line expression started above.
    move(b, node(b, min, [
        % Continue the multi-line expression started above.
        move(b1, leaf(b1, 5)),
        % Continue the multi-line expression started above.
        move(b2, leaf(b2, 2))
    % Close the expression opened above.
    ])),
    % Continue the multi-line expression started above.
    move(c, node(c, min, [
        % Continue the multi-line expression started above.
        move(c1, leaf(c1, 9)),
        % Continue the multi-line expression started above.
        move(c2, leaf(c2, 1))
    % Close the expression opened above.
    ]))
% Close the expression opened above.
]).

% ---------------------------------------------------------------------------
% Minimax evaluation
% ---------------------------------------------------------------------------

% Define a clause for 'minimax': succeed when the following conditions hold.
minimax(leaf(_, V), V, no_move) :- !.
% Define a clause for 'minimax': succeed when the following conditions hold.
minimax(node(_, max, Moves), BestVal, BestMove) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(V-M, (member(move(M, Child), Moves), minimax(Child, V, _)), Pairs),
    % State the fact: max pair(Pairs, BestVal-BestMove).
    max_pair(Pairs, BestVal-BestMove).
% Define a clause for 'minimax': succeed when the following conditions hold.
minimax(node(_, min, Moves), BestVal, BestMove) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(V-M, (member(move(M, Child), Moves), minimax(Child, V, _)), Pairs),
    % State the fact: min pair(Pairs, BestVal-BestMove).
    min_pair(Pairs, BestVal-BestMove).

% Define a clause for 'max pair': succeed when the following conditions hold.
max_pair([V-M|Rest], BestV-BestM) :-
    % Check that 'foldl([CV-CM, BV-BM, NV-NM]>>(CV' is greater than 'BV -> NV=CV, NM=CM ; NV=BV, NM=BM)'.
    foldl([CV-CM, BV-BM, NV-NM]>>(CV > BV -> NV=CV, NM=CM ; NV=BV, NM=BM),
          % Continue the multi-line expression started above.
          Rest, V-M, BestV-BestM).

% Define a clause for 'min pair': succeed when the following conditions hold.
min_pair([V-M|Rest], BestV-BestM) :-
    % Check that 'foldl([CV-CM, BV-BM, NV-NM]>>(CV' is less than 'BV -> NV=CV, NM=CM ; NV=BV, NM=BM)'.
    foldl([CV-CM, BV-BM, NV-NM]>>(CV < BV -> NV=CV, NM=CM ; NV=BV, NM=BM),
          % Continue the multi-line expression started above.
          Rest, V-M, BestV-BestM).

% ---------------------------------------------------------------------------
% Matrix games: payoff(Game, Row, Col, RowPayoff, ColPayoff)
% ---------------------------------------------------------------------------

% Prisoner's Dilemma
% State the fact: payoff(prisoners_dilemma, cooperate, cooperate, 3, 3).
payoff(prisoners_dilemma, cooperate, cooperate, 3, 3).
% State the fact: payoff(prisoners_dilemma, cooperate, defect,    0, 5).
payoff(prisoners_dilemma, cooperate, defect,    0, 5).
% State the fact: payoff(prisoners_dilemma, defect,    cooperate, 5, 0).
payoff(prisoners_dilemma, defect,    cooperate, 5, 0).
% State the fact: payoff(prisoners_dilemma, defect,    defect,    1, 1).
payoff(prisoners_dilemma, defect,    defect,    1, 1).

% Matching pennies (zero-sum)
% State the fact: payoff(matching_pennies, heads, heads,  1, -1).
payoff(matching_pennies, heads, heads,  1, -1).
% State the fact: payoff(matching_pennies, heads, tails, -1,  1).
payoff(matching_pennies, heads, tails, -1,  1).
% State the fact: payoff(matching_pennies, tails, heads, -1,  1).
payoff(matching_pennies, tails, heads, -1,  1).
% State the fact: payoff(matching_pennies, tails, tails,  1, -1).
payoff(matching_pennies, tails, tails,  1, -1).

% Nash equilibrium: neither player can improve by unilateral deviation
% Define a clause for 'nash equilibrium': succeed when the following conditions hold.
nash_equilibrium(Game, Row, Col) :-
    % State a fact for 'payoff' with the arguments listed below.
    payoff(Game, Row, Col, RowP, _),
    % Succeed only if '(payoff(Game, OtherRow, Col, OtherRowP, _' cannot be proved (negation as failure).
    \+ (payoff(Game, OtherRow, Col, OtherRowP, _),
        % Continue the multi-line expression started above.
        OtherRow \= Row,
        % Continue the multi-line expression started above.
        OtherRowP > RowP),
    % State a fact for 'payoff' with the arguments listed below.
    payoff(Game, Row, Col, _, ColP),
    % Succeed only if '(payoff(Game, Row, OtherCol, _, OtherColP' cannot be proved (negation as failure).
    \+ (payoff(Game, Row, OtherCol, _, OtherColP),
        % Continue the multi-line expression started above.
        OtherCol \= Col,
        % Continue the multi-line expression started above.
        OtherColP > ColP).

% Dominant strategy: best regardless of opponent
% Define a clause for 'dominant strategy': succeed when the following conditions hold.
dominant_strategy(Game, Player, Strategy) :-
    % Check that 'Player' is unifiable with 'row'.
    Player = row,
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(R, payoff(Game, R, _, _, _), Rows0),
    % Sort list 'Rows0' into 'Rows', removing duplicates.
    sort(Rows0, Rows),
    % Succeed for each element 'Strategy' that is a member of the list.
    member(Strategy, Rows),
    % Succeed only if '(member(OtherStrategy, Rows' cannot be proved (negation as failure).
    \+ (member(OtherStrategy, Rows),
        % Continue the multi-line expression started above.
        OtherStrategy \= Strategy,
        % Continue the multi-line expression started above.
        findall(Col, payoff(Game, _, Col, _, _), Cols0),
        % Continue the multi-line expression started above.
        sort(Cols0, Cols),
        % Continue the multi-line expression started above.
        member(C, Cols),
        % Continue the multi-line expression started above.
        payoff(Game, Strategy, C, P1, _),
        % Continue the multi-line expression started above.
        payoff(Game, OtherStrategy, C, P2, _),
        % Continue the multi-line expression started above.
        P2 > P1).

% ---------------------------------------------------------------------------
% mentova_strategic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova strategic' with the arguments listed below.
mentova_strategic(minimax(Position), move(BestMove, value(BestVal)),
                  % Continue the multi-line expression started above.
                  just(strategic(minimax_search(Position),
                                  % Continue the multi-line expression started above.
                                  best_move(BestMove),
                                  % Continue the multi-line expression started above.
                                  value(BestVal)))) :-
    % State a fact for 'game tree' with the arguments listed below.
    game_tree(Position, Player, Moves),
    % State the fact: minimax(node(Position, Player, Moves), BestVal, BestMove).
    minimax(node(Position, Player, Moves), BestVal, BestMove).

% State a fact for 'mentova strategic' with the arguments listed below.
mentova_strategic(nash(Game), equilibria(Game, Eqs),
                  % Continue the multi-line expression started above.
                  just(strategic(nash_equilibrium(Game), list(Eqs)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(R-C, nash_equilibrium(Game, R, C), Eqs).

% State a fact for 'mentova strategic' with the arguments listed below.
mentova_strategic(dominant(Game, row), dominant(Game, row, Strategy),
                  % Continue the multi-line expression started above.
                  just(strategic(dominant_strategy(Game, row), strategy(Strategy)))) :-
    % State a fact for 'dominant strategy' with the arguments listed below.
    dominant_strategy(Game, row, Strategy), !.

% State a fact for 'mentova strategic' with the arguments listed below.
mentova_strategic(dominant(Game, row), no_dominant(Game, row),
                  % Continue the multi-line expression started above.
                  just(strategic(dominant_strategy(Game, row), result(none)))) :-
    % Succeed only if 'dominant_strategy(Game, row, _' cannot be proved (negation as failure).
    \+ dominant_strategy(Game, row, _).

% State a fact for 'mentova strategic' with the arguments listed below.
mentova_strategic(payoff(Game, Row, Col), payoff(RowP, ColP),
                  % Continue the multi-line expression started above.
                  just(strategic(payoff_lookup(Game, Row, Col),
                                  % Continue the multi-line expression started above.
                                  row(RowP), col(ColP)))) :-
    % State the fact: payoff(Game, Row, Col, RowP, ColP).
    payoff(Game, Row, Col, RowP, ColP).
