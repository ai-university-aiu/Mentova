/*  Mentova — Strategic Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/strategic.pl, which exports
    mentova_strategic/3 — a single glass-box strategy oracle answering four
    query forms over built-in games:
      minimax(Position)     -> the optimal move and its minimax value in a
                               two-player zero-sum game tree (game_tree/3),
      nash(Game)            -> the pure-strategy Nash equilibria of a matrix
                               game (payoff/5),
      dominant(Game, row)   -> the row player's dominant strategy, or a
                               no_dominant verdict when none exists,
      payoff(Game, Row, Col)-> the row and column payoffs of one cell,
    each paired with a just(strategic(...)) justification term.

    Every expected value below is hand-computed from the module's built-in
    game_tree(root, max, ...) tree and its prisoners_dilemma / matching_pennies
    payoff tables, so no test passes trivially.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_strategic.pl
*/

% Declare this file as a test module with no exports.
:- module(test_strategic, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(strategic)).

% Open the test block for the strategic module.
:- begin_tests(strategic).

% AC-STRAT-001: minimax on the built-in root tree selects move a with value 3.
test(minimax_root_selects_move_a_value_3) :-
    % Ask for the optimal move at the root of the game tree, taking its first answer.
    once(mentova_strategic(minimax(root), Result, _Justification)),
    % Root is a max node over a:leaf(3), b:min(5,2)=2, c:min(9,1)=1, so max is a at 3.
    assertion(Result == move(a, value(3))).

% AC-STRAT-002: the minimax justification names the search, the best move, and the value.
test(minimax_justification_names_search_move_and_value) :-
    % Ask for the optimal move and keep the justification this time, taking its first answer.
    once(mentova_strategic(minimax(root), _Result, Justification)),
    % The justification is the documented four-slot strategic minimax term.
    assertion(Justification == just(strategic(minimax_search(root),
                                              % Name the best move the search selected.
                                              best_move(a),
                                              % Record the minimax value of that move.
                                              value(3)))).

% AC-STRAT-003: the prisoner's dilemma has exactly one pure Nash equilibrium: mutual defection.
test(nash_prisoners_dilemma_is_mutual_defection) :-
    % Ask for every pure-strategy Nash equilibrium of the prisoner's dilemma.
    mentova_strategic(nash(prisoners_dilemma), Result, _Justification),
    % Only (defect,defect) survives: from any other cell some player gains by deviating.
    assertion(Result == equilibria(prisoners_dilemma, [defect-defect])).

% AC-STRAT-004: matching pennies is zero-sum and has no pure-strategy Nash equilibrium.
test(nash_matching_pennies_has_no_pure_equilibrium) :-
    % Ask for every pure-strategy Nash equilibrium of matching pennies.
    mentova_strategic(nash(matching_pennies), Result, _Justification),
    % In every cell one player strictly prefers to switch, so the equilibrium list is empty.
    assertion(Result == equilibria(matching_pennies, [])).

% AC-STRAT-005: the row player's dominant strategy in the prisoner's dilemma is defect.
test(dominant_strategy_prisoners_dilemma_row_is_defect) :-
    % Ask whether the row player has a dominant strategy in the prisoner's dilemma.
    mentova_strategic(dominant(prisoners_dilemma, row), Result, _Justification),
    % Defect out-earns cooperate in both columns (5>3 and 1>0), so defect dominates.
    assertion(Result == dominant(prisoners_dilemma, row, defect)).

% AC-STRAT-006: matching pennies has no dominant row strategy, and the oracle says so.
test(no_dominant_strategy_in_matching_pennies_row) :-
    % Ask whether the row player has a dominant strategy in matching pennies.
    mentova_strategic(dominant(matching_pennies, row), Result, _Justification),
    % Neither heads nor tails wins in every column, so the verdict is no_dominant.
    assertion(Result == no_dominant(matching_pennies, row)).

% AC-STRAT-007: a payoff lookup returns the row and column payoffs of the named cell.
test(payoff_lookup_defect_cooperate) :-
    % Look up the (defect, cooperate) cell of the prisoner's dilemma, taking its first answer.
    once(mentova_strategic(payoff(prisoners_dilemma, defect, cooperate), Result, _Justification)),
    % The defecting row player earns 5 and the cooperating column player earns 0.
    assertion(Result == payoff(5, 0)).

% Close the test block for the strategic module.
:- end_tests(strategic).
