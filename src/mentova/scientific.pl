/*  Mentova — Rung 26: Scientific Reasoning Module

    Forms and tests a hypothesis (discovery loop).
    Pass criterion: hypothesis proposed, tested, and scored.

    The hypothesis is proposed by pattern recognition over the observation table,
    tested against the data, and scored by coverage/accuracy.
*/

% Declare this file as the 'scientific' module and list its exported predicates.
:- module(scientific, [
    % Supply 'mentova_scientific/3' as the next argument to the expression above.
    mentova_scientific/3
% Close the expression opened above.
]).

% Import [observation/3] from the 'small_world' module.
:- use_module('../../knowledge/small_world', [observation/3]).
% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).
% Import [aggregate_all/3] from the built-in 'aggregate' library.
:- use_module(library(aggregate), [aggregate_all/3]).

% ---------------------------------------------------------------------------
% Hypothesis templates: hypothesis(Id, Pattern, Description)
% A pattern is a predicate that must hold for the hypothesis to apply.
% ---------------------------------------------------------------------------

% State a fact for 'hypothesis' with the arguments listed below.
hypothesis(h1, dominant_colour(_Subject, yellow),
           % Continue the multi-line expression started above.
           'Most observations of Subject show yellow colour').
% State a fact for 'hypothesis' with the arguments listed below.
hypothesis(h2, rarely_flies(_Subject),
           % Continue the multi-line expression started above.
           'Subject rarely or never flies').
% State a fact for 'hypothesis' with the arguments listed below.
hypothesis(h3, mostly_red(_Subject),
           % Continue the multi-line expression started above.
           'Subject is predominantly red').
% State a fact for 'hypothesis' with the arguments listed below.
hypothesis(h4, always_swims(_Subject),
           % Continue the multi-line expression started above.
           'Subject always or almost always swims').

% ---------------------------------------------------------------------------
% Test a hypothesis against observation data
% ---------------------------------------------------------------------------

% Define a clause for 'test hypothesis': succeed when the following conditions hold.
test_hypothesis(dominant_colour(Subject, Colour), Score, Evidence) :-
    % Check that '( observation(Subject, Colour, Count) -> true ; Count' is unifiable with '0 )'.
    ( observation(Subject, Colour, Count) -> true ; Count = 0 ),
    % Aggregate solutions using 'sum' and bind the result to a single value.
    aggregate_all(sum(C), observation(Subject, _, C), Total),
    % Check that 'Total' is greater than '0'.
    Total > 0,
    % Evaluate the arithmetic expression 'Count / Total' and bind the result to 'Score'.
    Score is Count / Total,
    % Check that 'Evidence' is unifiable with 'evidence(Subject, Colour, Count, of(Total))'.
    Evidence = evidence(Subject, Colour, Count, of(Total)).

% Define a clause for 'test hypothesis': succeed when the following conditions hold.
test_hypothesis(rarely_flies(Subject), Score, Evidence) :-
    % Check that '( observation(Subject, flies, Count) -> true ; Count' is unifiable with '0 )'.
    ( observation(Subject, flies, Count) -> true ; Count = 0 ),
    % Aggregate solutions using 'sum' and bind the result to a single value.
    aggregate_all(sum(C), observation(Subject, _, C), Total),
    % Check that 'Total' is greater than '0'.
    Total > 0,
    % Evaluate the arithmetic expression '1.0 - Count / Total,  % high score = rarely flies' and bind the result to 'Score'.
    Score is 1.0 - Count / Total,  % high score = rarely flies
    % Check that 'Evidence' is unifiable with 'evidence(Subject, flies, Count, of(Total))'.
    Evidence = evidence(Subject, flies, Count, of(Total)).

% Define a clause for 'test hypothesis': succeed when the following conditions hold.
test_hypothesis(mostly_red(Subject), Score, Evidence) :-
    % Check that '( observation(Subject, red, Count) -> true ; Count' is unifiable with '0 )'.
    ( observation(Subject, red, Count) -> true ; Count = 0 ),
    % Aggregate solutions using 'sum' and bind the result to a single value.
    aggregate_all(sum(C), observation(Subject, _, C), Total),
    % Check that 'Total' is greater than '0'.
    Total > 0,
    % Evaluate the arithmetic expression 'Count / Total' and bind the result to 'Score'.
    Score is Count / Total,
    % Check that 'Evidence' is unifiable with 'evidence(Subject, red, Count, of(Total))'.
    Evidence = evidence(Subject, red, Count, of(Total)).

% Define a clause for 'test hypothesis': succeed when the following conditions hold.
test_hypothesis(always_swims(Subject), Score, Evidence) :-
    % Check that '( observation(Subject, swims, Count) -> true ; Count' is unifiable with '0 )'.
    ( observation(Subject, swims, Count) -> true ; Count = 0 ),
    % Aggregate solutions using 'sum' and bind the result to a single value.
    aggregate_all(sum(C), observation(Subject, _, C), Total),
    % Check that 'Total' is greater than '0'.
    Total > 0,
    % Evaluate the arithmetic expression 'Count / Total' and bind the result to 'Score'.
    Score is Count / Total,
    % Check that 'Evidence' is unifiable with 'evidence(Subject, swims, Count, of(Total))'.
    Evidence = evidence(Subject, swims, Count, of(Total)).

% ---------------------------------------------------------------------------
% Grade the hypothesis
% ---------------------------------------------------------------------------

% Check that 'grade(Score, confirmed)       :- Score' is greater than or equal to '0.8'.
grade(Score, confirmed)       :- Score >= 0.8.
% Check that 'grade(Score, supported)       :- Score' is greater than or equal to '0.6, Score < 0.8'.
grade(Score, supported)       :- Score >= 0.6, Score < 0.8.
% Check that 'grade(Score, weakly_supported):- Score' is greater than or equal to '0.4, Score < 0.6'.
grade(Score, weakly_supported):- Score >= 0.4, Score < 0.6.
% Check that 'grade(Score, not_supported)   :- Score' is less than '0.4'.
grade(Score, not_supported)   :- Score < 0.4.

% ---------------------------------------------------------------------------
% mentova_scientific(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Propose and test a hypothesis about a subject
% State a fact for 'mentova scientific' with the arguments listed below.
mentova_scientific(discover(Subject, _Property), HypResult,
                    % Continue the multi-line expression started above.
                    just(scientific(propose(H), test(Evidence), score(Score), grade(Grade)))) :-
    % State a fact for 'hypothesis' with the arguments listed below.
    hypothesis(_, Pattern, H),
    % Execute: Pattern =.. [_|Args],.
    Pattern =.. [_|Args],
    % Succeed for each element 'Subject' that is a member of the list.
    member(Subject, Args),
    % State a fact for 'test hypothesis' with the arguments listed below.
    test_hypothesis(Pattern, Score, Evidence),
    % State a fact for 'grade' with the arguments listed below.
    grade(Score, Grade),
    % Check that 'HypResult' is unifiable with 'hypothesis(H, subject(Subject), score(Score), grade(Grade))'.
    HypResult = hypothesis(H, subject(Subject), score(Score), grade(Grade)).

% Test a specific hypothesis pattern
% State a fact for 'mentova scientific' with the arguments listed below.
mentova_scientific(test_hypothesis(Pattern), result(Score, Grade, Evidence),
                    % Continue the multi-line expression started above.
                    just(scientific_test(pattern(Pattern), score(Score), grade(Grade)))) :-
    % State a fact for 'test hypothesis' with the arguments listed below.
    test_hypothesis(Pattern, Score, Evidence),
    % State the fact: grade(Score, Grade).
    grade(Score, Grade).

% Discovery loop: propose all, test all, return ranked
% State a fact for 'mentova scientific' with the arguments listed below.
mentova_scientific(full_discovery(Subject), ranked_hypotheses(Ranked),
                    % Continue the multi-line expression started above.
                    just(discovery_loop(subject(Subject), top(Ranked)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Score-H-Grade-Evidence,
            % Continue the multi-line expression started above.
            ( hypothesis(_, Pattern, H),
              % Continue the multi-line expression started above.
              functor(Pattern, _, _),
              % Continue the multi-line expression started above.
              copy_term(Pattern, P2),
              % Continue the multi-line expression started above.
              P2 =.. [Fn|_], P2b =.. [Fn, Subject|_],
              % Continue the multi-line expression started above.
              catch(test_hypothesis(P2b, Score, Evidence), _, fail),
              % Continue the multi-line expression started above.
              grade(Score, Grade)
            % Close the expression opened above.
            ),
            % Supply 'All' as the next argument to the expression above.
            All),
    % Sort list 'All' into 'Sorted', keeping duplicates.
    msort(All, Sorted),
    % State the fact: reverse(Sorted, Ranked).
    reverse(Sorted, Ranked).
