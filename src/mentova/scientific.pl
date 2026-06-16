/*  Mentova — Rung 26: Scientific Reasoning Module

    Forms and tests a hypothesis (discovery loop).
    Pass criterion: hypothesis proposed, tested, and scored.

    The hypothesis is proposed by pattern recognition over the observation table,
    tested against the data, and scored by coverage/accuracy.
*/

:- module(scientific, [
    mentova_scientific/3
]).

:- use_module('../../knowledge/small_world', [observation/3]).
:- use_module(library(lists), [member/2]).
:- use_module(library(aggregate), [aggregate_all/3]).

% ---------------------------------------------------------------------------
% Hypothesis templates: hypothesis(Id, Pattern, Description)
% A pattern is a predicate that must hold for the hypothesis to apply.
% ---------------------------------------------------------------------------

hypothesis(h1, dominant_colour(_Subject, yellow),
           'Most observations of Subject show yellow colour').
hypothesis(h2, rarely_flies(_Subject),
           'Subject rarely or never flies').
hypothesis(h3, mostly_red(_Subject),
           'Subject is predominantly red').
hypothesis(h4, always_swims(_Subject),
           'Subject always or almost always swims').

% ---------------------------------------------------------------------------
% Test a hypothesis against observation data
% ---------------------------------------------------------------------------

test_hypothesis(dominant_colour(Subject, Colour), Score, Evidence) :-
    ( observation(Subject, Colour, Count) -> true ; Count = 0 ),
    aggregate_all(sum(C), observation(Subject, _, C), Total),
    Total > 0,
    Score is Count / Total,
    Evidence = evidence(Subject, Colour, Count, of(Total)).

test_hypothesis(rarely_flies(Subject), Score, Evidence) :-
    ( observation(Subject, flies, Count) -> true ; Count = 0 ),
    aggregate_all(sum(C), observation(Subject, _, C), Total),
    Total > 0,
    Score is 1.0 - Count / Total,  % high score = rarely flies
    Evidence = evidence(Subject, flies, Count, of(Total)).

test_hypothesis(mostly_red(Subject), Score, Evidence) :-
    ( observation(Subject, red, Count) -> true ; Count = 0 ),
    aggregate_all(sum(C), observation(Subject, _, C), Total),
    Total > 0,
    Score is Count / Total,
    Evidence = evidence(Subject, red, Count, of(Total)).

test_hypothesis(always_swims(Subject), Score, Evidence) :-
    ( observation(Subject, swims, Count) -> true ; Count = 0 ),
    aggregate_all(sum(C), observation(Subject, _, C), Total),
    Total > 0,
    Score is Count / Total,
    Evidence = evidence(Subject, swims, Count, of(Total)).

% ---------------------------------------------------------------------------
% Grade the hypothesis
% ---------------------------------------------------------------------------

grade(Score, confirmed)       :- Score >= 0.8.
grade(Score, supported)       :- Score >= 0.6, Score < 0.8.
grade(Score, weakly_supported):- Score >= 0.4, Score < 0.6.
grade(Score, not_supported)   :- Score < 0.4.

% ---------------------------------------------------------------------------
% mentova_scientific(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% Propose and test a hypothesis about a subject
mentova_scientific(discover(Subject, _Property), HypResult,
                    just(scientific(propose(H), test(Evidence), score(Score), grade(Grade)))) :-
    hypothesis(_, Pattern, H),
    Pattern =.. [_|Args],
    member(Subject, Args),
    test_hypothesis(Pattern, Score, Evidence),
    grade(Score, Grade),
    HypResult = hypothesis(H, subject(Subject), score(Score), grade(Grade)).

% Test a specific hypothesis pattern
mentova_scientific(test_hypothesis(Pattern), result(Score, Grade, Evidence),
                    just(scientific_test(pattern(Pattern), score(Score), grade(Grade)))) :-
    test_hypothesis(Pattern, Score, Evidence),
    grade(Score, Grade).

% Discovery loop: propose all, test all, return ranked
mentova_scientific(full_discovery(Subject), ranked_hypotheses(Ranked),
                    just(discovery_loop(subject(Subject), top(Ranked)))) :-
    findall(Score-H-Grade-Evidence,
            ( hypothesis(_, Pattern, H),
              functor(Pattern, _, _),
              copy_term(Pattern, P2),
              P2 =.. [Fn|_], P2b =.. [Fn, Subject|_],
              catch(test_hypothesis(P2b, Score, Evidence), _, fail),
              grade(Score, Grade)
            ),
            All),
    msort(All, Sorted),
    reverse(Sorted, Ranked).
