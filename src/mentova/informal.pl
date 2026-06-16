/*  Mentova — Rung 46: Informal Reasoning Module

    Handles everyday argumentative patterns: plausibility scoring,
    fallacy detection, rhetorical move identification, and Gricean
    implicature reasoning.
    Pass criterion: given an argument, identify the rhetorical pattern
    and flag fallacious reasoning with explanation.
*/

% Declare this file as the 'informal' module and list its exported predicates.
% Declare this file as the 'informal' module and list its exported predicates.
:- module(informal, [
    % Supply 'mentova_informal/3' as the next argument to the expression above.
    % Supply 'mentova_informal/3' as the next argument to the expression above.
    mentova_informal/3
% Close the expression opened above.
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Informal argument patterns and fallacies
% ---------------------------------------------------------------------------

% State the fact: fallacy(ad_hominem,    'attacks the person not the argument').
% State the fact: fallacy(ad_hominem,    'attacks the person not the argument').
fallacy(ad_hominem,    'attacks the person not the argument').
% State the fact: fallacy(straw_man,     'misrepresents opponents position to attack it').
% State the fact: fallacy(straw_man,     'misrepresents opponents position to attack it').
fallacy(straw_man,     'misrepresents opponents position to attack it').
% State the fact: fallacy(false_dilemma, 'presents only two options when more exist').
% State the fact: fallacy(false_dilemma, 'presents only two options when more exist').
fallacy(false_dilemma, 'presents only two options when more exist').
% State the fact: fallacy(slippery_slope,'assumes small step inevitably leads to extreme outcome').
% State the fact: fallacy(slippery_slope,'assumes small step inevitably leads to extreme outcome').
fallacy(slippery_slope,'assumes small step inevitably leads to extreme outcome').
% State the fact: fallacy(appeal_to_authority, 'cites an authority instead of providing evidence').
% State the fact: fallacy(appeal_to_authority, 'cites an authority instead of providing evidence').
fallacy(appeal_to_authority, 'cites an authority instead of providing evidence').
% State the fact: fallacy(circular,      'conclusion is assumed in the premise').
% State the fact: fallacy(circular,      'conclusion is assumed in the premise').
fallacy(circular,      'conclusion is assumed in the premise').
% State the fact: fallacy(hasty_generalisation, 'draws broad conclusion from few examples').
% State the fact: fallacy(hasty_generalisation, 'draws broad conclusion from few examples').
fallacy(hasty_generalisation, 'draws broad conclusion from few examples').
% State the fact: fallacy(post_hoc,      'assumes A caused B because A preceded B').
% State the fact: fallacy(post_hoc,      'assumes A caused B because A preceded B').
fallacy(post_hoc,      'assumes A caused B because A preceded B').

% Argument templates: argument(Id, Pattern, Fallacy or none)
% State a fact for 'argument' with the arguments listed below.
% State a fact for 'argument' with the arguments listed below.
argument(arg1, 'Your argument is wrong because you are inexperienced.',
         % Supply 'ad_hominem' as the next argument to the expression above.
         % Supply 'ad_hominem' as the next argument to the expression above.
         ad_hominem).
% State a fact for 'argument' with the arguments listed below.
% State a fact for 'argument' with the arguments listed below.
argument(arg2, 'You either support us or you are against us.',
         % Supply 'false_dilemma' as the next argument to the expression above.
         % Supply 'false_dilemma' as the next argument to the expression above.
         false_dilemma).
% State a fact for 'argument' with the arguments listed below.
% State a fact for 'argument' with the arguments listed below.
argument(arg3, 'If we allow X, eventually everything will collapse.',
         % Supply 'slippery_slope' as the next argument to the expression above.
         % Supply 'slippery_slope' as the next argument to the expression above.
         slippery_slope).
% State a fact for 'argument' with the arguments listed below.
% State a fact for 'argument' with the arguments listed below.
argument(arg4, 'I ate an apple, then I got sick. The apple caused it.',
         % Supply 'post_hoc' as the next argument to the expression above.
         % Supply 'post_hoc' as the next argument to the expression above.
         post_hoc).
% State a fact for 'argument' with the arguments listed below.
% State a fact for 'argument' with the arguments listed below.
argument(arg5, 'All swans I have seen are white, so all swans are white.',
         % Supply 'hasty_generalisation' as the next argument to the expression above.
         % Supply 'hasty_generalisation' as the next argument to the expression above.
         hasty_generalisation).
% State a fact for 'argument' with the arguments listed below.
% State a fact for 'argument' with the arguments listed below.
argument(arg6, 'The expert says so, therefore it must be true.',
         % Supply 'appeal_to_authority' as the next argument to the expression above.
         % Supply 'appeal_to_authority' as the next argument to the expression above.
         appeal_to_authority).
% State a fact for 'argument' with the arguments listed below.
% State a fact for 'argument' with the arguments listed below.
argument(arg7, 'We should trust this because it is trustworthy.',
         % Supply 'circular' as the next argument to the expression above.
         % Supply 'circular' as the next argument to the expression above.
         circular).
% State a fact for 'argument' with the arguments listed below.
% State a fact for 'argument' with the arguments listed below.
argument(arg8, 'My opponent secretly wants to destroy the economy.',
         % Supply 'straw_man' as the next argument to the expression above.
         % Supply 'straw_man' as the next argument to the expression above.
         straw_man).

% Valid rhetorical moves
% State the fact: rhetorical move(analogy,     'clarifies by comparison').
% State the fact: rhetorical move(analogy,     'clarifies by comparison').
rhetorical_move(analogy,     'clarifies by comparison').
% State the fact: rhetorical move(example,     'supports with concrete instance').
% State the fact: rhetorical move(example,     'supports with concrete instance').
rhetorical_move(example,     'supports with concrete instance').
% State the fact: rhetorical move(concession,  'acknowledges opponents valid point').
% State the fact: rhetorical move(concession,  'acknowledges opponents valid point').
rhetorical_move(concession,  'acknowledges opponents valid point').
% State the fact: rhetorical move(rebuttal,    'directly contradicts with evidence').
% State the fact: rhetorical move(rebuttal,    'directly contradicts with evidence').
rhetorical_move(rebuttal,    'directly contradicts with evidence').
% State the fact: rhetorical move(modus_ponens,'if A then B; A; therefore B').
% State the fact: rhetorical move(modus_ponens,'if A then B; A; therefore B').
rhetorical_move(modus_ponens,'if A then B; A; therefore B').

% Plausibility levels
% State the fact: plausibility level(0.8, 1.0, highly_plausible).
% State the fact: plausibility level(0.8, 1.0, highly_plausible).
plausibility_level(0.8, 1.0, highly_plausible).
% State the fact: plausibility level(0.6, 0.8, plausible).
% State the fact: plausibility level(0.6, 0.8, plausible).
plausibility_level(0.6, 0.8, plausible).
% State the fact: plausibility level(0.4, 0.6, uncertain).
% State the fact: plausibility level(0.4, 0.6, uncertain).
plausibility_level(0.4, 0.6, uncertain).
% State the fact: plausibility level(0.0, 0.4, implausible).
% State the fact: plausibility level(0.0, 0.4, implausible).
plausibility_level(0.0, 0.4, implausible).

% Define a clause for 'plausibility grade': succeed when the following conditions hold.
% Define a clause for 'plausibility grade': succeed when the following conditions hold.
plausibility_grade(Score, Grade) :-
    % State a fact for 'plausibility level' with the arguments listed below.
    % State a fact for 'plausibility level' with the arguments listed below.
    plausibility_level(Low, High, Grade),
    % Check that 'Score' is greater than or equal to 'Low'.
    % Check that 'Score' is greater than or equal to 'Low'.
    Score >= Low,
    % Check that 'Score' is less than 'High, !'.
    % Check that 'Score' is less than 'High, !'.
    Score < High, !.

% Simple argument plausibility based on:
% + has_evidence reduces implausibility
% - contains fallacy reduces plausibility
% Define a clause for 'argument score': succeed when the following conditions hold.
% Define a clause for 'argument score': succeed when the following conditions hold.
argument_score(ArgId, Score) :-
    % State a fact for 'argument' with the arguments listed below.
    % State a fact for 'argument' with the arguments listed below.
    argument(ArgId, _, Fallacy),
    % Check that '( Fallacy' is unifiable with 'none -> Base = 0.8 ; Base = 0.2 )'.
    % Check that '( Fallacy' is unifiable with 'none -> Base = 0.8 ; Base = 0.2 )'.
    ( Fallacy = none -> Base = 0.8 ; Base = 0.2 ),
    % Check that 'Score' is unifiable with 'Base'.
    % Check that 'Score' is unifiable with 'Base'.
    Score = Base.

% ---------------------------------------------------------------------------
% mentova_informal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova informal' with the arguments listed below.
% State a fact for 'mentova informal' with the arguments listed below.
mentova_informal(detect_fallacy(ArgId), fallacy(ArgId, Fallacy, Explanation),
                 % Continue the multi-line expression started above.
                 % Continue the multi-line expression started above.
                 just(informal(fallacy_detection(ArgId),
                                % Continue the multi-line expression started above.
                                % Continue the multi-line expression started above.
                                fallacy(Fallacy),
                                % Continue the multi-line expression started above.
                                % Continue the multi-line expression started above.
                                explanation(Explanation)))) :-
    % State a fact for 'argument' with the arguments listed below.
    % State a fact for 'argument' with the arguments listed below.
    argument(ArgId, _, Fallacy),
    % Check that 'Fallacy' is not unifiable with 'none'.
    % Check that 'Fallacy' is not unifiable with 'none'.
    Fallacy \= none,
    % State the fact: fallacy(Fallacy, Explanation).
    % State the fact: fallacy(Fallacy, Explanation).
    fallacy(Fallacy, Explanation).

% State a fact for 'mentova informal' with the arguments listed below.
% State a fact for 'mentova informal' with the arguments listed below.
mentova_informal(detect_fallacy(ArgId), no_fallacy(ArgId),
                 % Continue the multi-line expression started above.
                 % Continue the multi-line expression started above.
                 just(informal(fallacy_detection(ArgId), result(valid_form)))) :-
    % State the fact: argument(ArgId, _, none).
    % State the fact: argument(ArgId, _, none).
    argument(ArgId, _, none).

% State a fact for 'mentova informal' with the arguments listed below.
% State a fact for 'mentova informal' with the arguments listed below.
mentova_informal(plausibility(ArgId), plausibility(ArgId, Score, Grade),
                 % Continue the multi-line expression started above.
                 % Continue the multi-line expression started above.
                 just(informal(plausibility_score(ArgId),
                                % Continue the multi-line expression started above.
                                % Continue the multi-line expression started above.
                                score(Score), grade(Grade)))) :-
    % State a fact for 'argument score' with the arguments listed below.
    % State a fact for 'argument score' with the arguments listed below.
    argument_score(ArgId, Score),
    % State the fact: plausibility grade(Score, Grade).
    % State the fact: plausibility grade(Score, Grade).
    plausibility_grade(Score, Grade).

% State a fact for 'mentova informal' with the arguments listed below.
% State a fact for 'mentova informal' with the arguments listed below.
mentova_informal(identify_move(Move), move(Move, Description),
                 % Continue the multi-line expression started above.
                 % Continue the multi-line expression started above.
                 just(informal(rhetorical_move(Move), description(Description)))) :-
    % State the fact: rhetorical move(Move, Description).
    % State the fact: rhetorical move(Move, Description).
    rhetorical_move(Move, Description).

% State a fact for 'mentova informal' with the arguments listed below.
% State a fact for 'mentova informal' with the arguments listed below.
mentova_informal(list_fallacies, fallacies(List),
                 % Continue the multi-line expression started above.
                 % Continue the multi-line expression started above.
                 just(informal(all_fallacies, list(List)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(F-E, fallacy(F, E), List).

% State a fact for 'mentova informal' with the arguments listed below.
% State a fact for 'mentova informal' with the arguments listed below.
mentova_informal(explain_fallacy(Fallacy), explanation(Fallacy, Expl),
                 % Continue the multi-line expression started above.
                 % Continue the multi-line expression started above.
                 just(informal(fallacy_lookup(Fallacy), explanation(Expl)))) :-
    % State a fact for 'fallacy' with the arguments listed below.
    % State a fact for 'fallacy' with the arguments listed below.
    fallacy(Fallacy, Expl), !.

% State a fact for 'mentova informal' with the arguments listed below.
% State a fact for 'mentova informal' with the arguments listed below.
mentova_informal(gricean_implicature(literal, Msg), implicature(Msg, none),
                 % Continue the multi-line expression started above.
                 % Continue the multi-line expression started above.
                 just(informal(gricean(literal), result(none)))) :-
    % Succeed for each element 'Msg, [explicit' that is a member of the list.
    % Succeed for each element 'Msg, [explicit' that is a member of the list.
    member(Msg, [explicit, clear]), !.

% State a fact for 'mentova informal' with the arguments listed below.
% State a fact for 'mentova informal' with the arguments listed below.
mentova_informal(gricean_implicature(understatement, Msg), implicature(Msg, ImplMsg),
                 % Continue the multi-line expression started above.
                 % Continue the multi-line expression started above.
                 just(informal(gricean(understatement, Msg), implies(ImplMsg)))) :-
    % State a fact for 'gricean pair' with the arguments listed below.
    % State a fact for 'gricean pair' with the arguments listed below.
    gricean_pair(Msg, ImplMsg), !.

% State the fact: gricean pair('It is not bad.', 'Speaker thinks it is quite good.').
% State the fact: gricean pair('It is not bad.', 'Speaker thinks it is quite good.').
gricean_pair('It is not bad.', 'Speaker thinks it is quite good.').
% State the fact: gricean pair('Some students passed.', 'Not all students passed.').
% State the fact: gricean pair('Some students passed.', 'Not all students passed.').
gricean_pair('Some students passed.', 'Not all students passed.').
% State the fact: gricean pair('He sometimes arrives on time.', 'He often does not arrive on time.').
% State the fact: gricean pair('He sometimes arrives on time.', 'He often does not arrive on time.').
gricean_pair('He sometimes arrives on time.', 'He often does not arrive on time.').
