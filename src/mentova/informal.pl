/*  Mentova — Rung 46: Informal Reasoning Module

    Handles everyday argumentative patterns: plausibility scoring,
    fallacy detection, rhetorical move identification, and Gricean
    implicature reasoning.
    Pass criterion: given an argument, identify the rhetorical pattern
    and flag fallacious reasoning with explanation.
*/

:- module(informal, [
    mentova_informal/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Informal argument patterns and fallacies
% ---------------------------------------------------------------------------

fallacy(ad_hominem,    'attacks the person not the argument').
fallacy(straw_man,     'misrepresents opponents position to attack it').
fallacy(false_dilemma, 'presents only two options when more exist').
fallacy(slippery_slope,'assumes small step inevitably leads to extreme outcome').
fallacy(appeal_to_authority, 'cites an authority instead of providing evidence').
fallacy(circular,      'conclusion is assumed in the premise').
fallacy(hasty_generalisation, 'draws broad conclusion from few examples').
fallacy(post_hoc,      'assumes A caused B because A preceded B').

% Argument templates: argument(Id, Pattern, Fallacy or none)
argument(arg1, 'Your argument is wrong because you are inexperienced.',
         ad_hominem).
argument(arg2, 'You either support us or you are against us.',
         false_dilemma).
argument(arg3, 'If we allow X, eventually everything will collapse.',
         slippery_slope).
argument(arg4, 'I ate an apple, then I got sick. The apple caused it.',
         post_hoc).
argument(arg5, 'All swans I have seen are white, so all swans are white.',
         hasty_generalisation).
argument(arg6, 'The expert says so, therefore it must be true.',
         appeal_to_authority).
argument(arg7, 'We should trust this because it is trustworthy.',
         circular).
argument(arg8, 'My opponent secretly wants to destroy the economy.',
         straw_man).

% Valid rhetorical moves
rhetorical_move(analogy,     'clarifies by comparison').
rhetorical_move(example,     'supports with concrete instance').
rhetorical_move(concession,  'acknowledges opponents valid point').
rhetorical_move(rebuttal,    'directly contradicts with evidence').
rhetorical_move(modus_ponens,'if A then B; A; therefore B').

% Plausibility levels
plausibility_level(0.8, 1.0, highly_plausible).
plausibility_level(0.6, 0.8, plausible).
plausibility_level(0.4, 0.6, uncertain).
plausibility_level(0.0, 0.4, implausible).

plausibility_grade(Score, Grade) :-
    plausibility_level(Low, High, Grade),
    Score >= Low,
    Score < High, !.

% Simple argument plausibility based on:
% + has_evidence reduces implausibility
% - contains fallacy reduces plausibility
argument_score(ArgId, Score) :-
    argument(ArgId, _, Fallacy),
    ( Fallacy = none -> Base = 0.8 ; Base = 0.2 ),
    Score = Base.

% ---------------------------------------------------------------------------
% mentova_informal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_informal(detect_fallacy(ArgId), fallacy(ArgId, Fallacy, Explanation),
                 just(informal(fallacy_detection(ArgId),
                                fallacy(Fallacy),
                                explanation(Explanation)))) :-
    argument(ArgId, _, Fallacy),
    Fallacy \= none,
    fallacy(Fallacy, Explanation).

mentova_informal(detect_fallacy(ArgId), no_fallacy(ArgId),
                 just(informal(fallacy_detection(ArgId), result(valid_form)))) :-
    argument(ArgId, _, none).

mentova_informal(plausibility(ArgId), plausibility(ArgId, Score, Grade),
                 just(informal(plausibility_score(ArgId),
                                score(Score), grade(Grade)))) :-
    argument_score(ArgId, Score),
    plausibility_grade(Score, Grade).

mentova_informal(identify_move(Move), move(Move, Description),
                 just(informal(rhetorical_move(Move), description(Description)))) :-
    rhetorical_move(Move, Description).

mentova_informal(list_fallacies, fallacies(List),
                 just(informal(all_fallacies, list(List)))) :-
    findall(F-E, fallacy(F, E), List).

mentova_informal(explain_fallacy(Fallacy), explanation(Fallacy, Expl),
                 just(informal(fallacy_lookup(Fallacy), explanation(Expl)))) :-
    fallacy(Fallacy, Expl), !.

mentova_informal(gricean_implicature(literal, Msg), implicature(Msg, none),
                 just(informal(gricean(literal), result(none)))) :-
    member(Msg, [explicit, clear]), !.

mentova_informal(gricean_implicature(understatement, Msg), implicature(Msg, ImplMsg),
                 just(informal(gricean(understatement, Msg), implies(ImplMsg)))) :-
    gricean_pair(Msg, ImplMsg), !.

gricean_pair('It is not bad.', 'Speaker thinks it is quite good.').
gricean_pair('Some students passed.', 'Not all students passed.').
gricean_pair('He sometimes arrives on time.', 'He often does not arrive on time.').
