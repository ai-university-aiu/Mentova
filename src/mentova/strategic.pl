/*  Mentova — Rung 40: Strategic Reasoning Module

    Reasons about optimal strategy in competitive and cooperative settings.
    Implements minimax for two-player zero-sum games and Nash equilibrium
    detection for simple matrix games.
    Pass criterion: return the optimal move in a game position with minimax
    value and strategy justification.
*/

:- module(strategic, [
    mentova_strategic/3
]).

:- use_module(library(lists), [member/2, max_list/2, min_list/2]).

% ---------------------------------------------------------------------------
% Game tree: node(Position, Player, Moves)
% Leaf: leaf(Position, Value)  (value from maximiser's perspective)
% ---------------------------------------------------------------------------

% Simple tic-tac-toe-like tree (3 depth)
game_tree(root, max, [
    move(a, leaf(a, 3)),
    move(b, node(b, min, [
        move(b1, leaf(b1, 5)),
        move(b2, leaf(b2, 2))
    ])),
    move(c, node(c, min, [
        move(c1, leaf(c1, 9)),
        move(c2, leaf(c2, 1))
    ]))
]).

% ---------------------------------------------------------------------------
% Minimax evaluation
% ---------------------------------------------------------------------------

minimax(leaf(_, V), V, no_move) :- !.
minimax(node(_, max, Moves), BestVal, BestMove) :-
    findall(V-M, (member(move(M, Child), Moves), minimax(Child, V, _)), Pairs),
    max_pair(Pairs, BestVal-BestMove).
minimax(node(_, min, Moves), BestVal, BestMove) :-
    findall(V-M, (member(move(M, Child), Moves), minimax(Child, V, _)), Pairs),
    min_pair(Pairs, BestVal-BestMove).

max_pair([V-M|Rest], BestV-BestM) :-
    foldl([CV-CM, BV-BM, NV-NM]>>(CV > BV -> NV=CV, NM=CM ; NV=BV, NM=BM),
          Rest, V-M, BestV-BestM).

min_pair([V-M|Rest], BestV-BestM) :-
    foldl([CV-CM, BV-BM, NV-NM]>>(CV < BV -> NV=CV, NM=CM ; NV=BV, NM=BM),
          Rest, V-M, BestV-BestM).

% ---------------------------------------------------------------------------
% Matrix games: payoff(Game, Row, Col, RowPayoff, ColPayoff)
% ---------------------------------------------------------------------------

% Prisoner's Dilemma
payoff(prisoners_dilemma, cooperate, cooperate, 3, 3).
payoff(prisoners_dilemma, cooperate, defect,    0, 5).
payoff(prisoners_dilemma, defect,    cooperate, 5, 0).
payoff(prisoners_dilemma, defect,    defect,    1, 1).

% Matching pennies (zero-sum)
payoff(matching_pennies, heads, heads,  1, -1).
payoff(matching_pennies, heads, tails, -1,  1).
payoff(matching_pennies, tails, heads, -1,  1).
payoff(matching_pennies, tails, tails,  1, -1).

% Nash equilibrium: neither player can improve by unilateral deviation
nash_equilibrium(Game, Row, Col) :-
    payoff(Game, Row, Col, RowP, _),
    \+ (payoff(Game, OtherRow, Col, OtherRowP, _),
        OtherRow \= Row,
        OtherRowP > RowP),
    payoff(Game, Row, Col, _, ColP),
    \+ (payoff(Game, Row, OtherCol, _, OtherColP),
        OtherCol \= Col,
        OtherColP > ColP).

% Dominant strategy: best regardless of opponent
dominant_strategy(Game, Player, Strategy) :-
    Player = row,
    findall(R, payoff(Game, R, _, _, _), Rows0),
    sort(Rows0, Rows),
    member(Strategy, Rows),
    \+ (member(OtherStrategy, Rows),
        OtherStrategy \= Strategy,
        findall(Col, payoff(Game, _, Col, _, _), Cols0),
        sort(Cols0, Cols),
        member(C, Cols),
        payoff(Game, Strategy, C, P1, _),
        payoff(Game, OtherStrategy, C, P2, _),
        P2 > P1).

% ---------------------------------------------------------------------------
% mentova_strategic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_strategic(minimax(Position), move(BestMove, value(BestVal)),
                  just(strategic(minimax_search(Position),
                                  best_move(BestMove),
                                  value(BestVal)))) :-
    game_tree(Position, Player, Moves),
    minimax(node(Position, Player, Moves), BestVal, BestMove).

mentova_strategic(nash(Game), equilibria(Game, Eqs),
                  just(strategic(nash_equilibrium(Game), list(Eqs)))) :-
    findall(R-C, nash_equilibrium(Game, R, C), Eqs).

mentova_strategic(dominant(Game, row), dominant(Game, row, Strategy),
                  just(strategic(dominant_strategy(Game, row), strategy(Strategy)))) :-
    dominant_strategy(Game, row, Strategy), !.

mentova_strategic(dominant(Game, row), no_dominant(Game, row),
                  just(strategic(dominant_strategy(Game, row), result(none)))) :-
    \+ dominant_strategy(Game, row, _).

mentova_strategic(payoff(Game, Row, Col), payoff(RowP, ColP),
                  just(strategic(payoff_lookup(Game, Row, Col),
                                  row(RowP), col(ColP)))) :-
    payoff(Game, Row, Col, RowP, ColP).
