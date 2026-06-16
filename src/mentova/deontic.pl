/*  Mentova — Rung 35: Deontic Reasoning Module

    Reasons about obligations (must), permissions (may), and prohibitions
    (must not). Uses norm/2 from Small-World KB and adds richer deontic facts.
    Pass criterion: correctly reports whether an action is obligatory,
    permitted, or prohibited in a given context.
*/

% Declare this file as the 'deontic' module and list its exported predicates.
:- module(deontic, [
    % Supply 'mentova_deontic/3' as the next argument to the expression above.
    mentova_deontic/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).
% Import [norm/2] from the 'small_world' module.
:- use_module('../../knowledge/small_world', [norm/2]).

% ---------------------------------------------------------------------------
% Deontic facts: deontic(Agent, Action, Status, Context)
% Status: obligatory | permitted | prohibited
% ---------------------------------------------------------------------------

% State the fact: deontic(driver,    wear_seatbelt,     obligatory,  road).
deontic(driver,    wear_seatbelt,     obligatory,  road).
% State the fact: deontic(driver,    use_phone,         prohibited,  road).
deontic(driver,    use_phone,         prohibited,  road).
% State the fact: deontic(driver,    stop_at_red,       obligatory,  road).
deontic(driver,    stop_at_red,       obligatory,  road).
% State the fact: deontic(driver,    exceed_speed,      prohibited,  road).
deontic(driver,    exceed_speed,      prohibited,  road).
% State the fact: deontic(driver,    use_horn,          permitted,   road).
deontic(driver,    use_horn,          permitted,   road).

% State the fact: deontic(employee,  attend_meetings,   obligatory,  workplace).
deontic(employee,  attend_meetings,   obligatory,  workplace).
% State the fact: deontic(employee,  share_password,    prohibited,  workplace).
deontic(employee,  share_password,    prohibited,  workplace).
% State the fact: deontic(employee,  take_breaks,       permitted,   workplace).
deontic(employee,  take_breaks,       permitted,   workplace).
% State the fact: deontic(employee,  submit_reports,    obligatory,  workplace).
deontic(employee,  submit_reports,    obligatory,  workplace).

% State the fact: deontic(citizen,   pay_taxes,         obligatory,  society).
deontic(citizen,   pay_taxes,         obligatory,  society).
% State the fact: deontic(citizen,   vote,              permitted,   society).
deontic(citizen,   vote,              permitted,   society).
% State the fact: deontic(citizen,   harm_others,       prohibited,  society).
deontic(citizen,   harm_others,       prohibited,  society).
% State the fact: deontic(citizen,   free_speech,       permitted,   society).
deontic(citizen,   free_speech,       permitted,   society).

% State the fact: deontic(student,   attend_classes,    obligatory,  school).
deontic(student,   attend_classes,    obligatory,  school).
% State the fact: deontic(student,   cheat_exams,       prohibited,  school).
deontic(student,   cheat_exams,       prohibited,  school).
% State the fact: deontic(student,   ask_questions,     permitted,   school).
deontic(student,   ask_questions,     permitted,   school).
% State the fact: deontic(student,   study,             obligatory,  school).
deontic(student,   study,             obligatory,  school).

% ---------------------------------------------------------------------------
% mentova_deontic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova deontic' with the arguments listed below.
mentova_deontic(status(Agent, Action, Context), status(Agent, Action, Status, Context),
                % Continue the multi-line expression started above.
                just(deontic(agent(Agent), action(Action),
                              % Continue the multi-line expression started above.
                              context(Context), status(Status)))) :-
    % State a fact for 'deontic' with the arguments listed below.
    deontic(Agent, Action, Status, Context), !.

% State a fact for 'mentova deontic' with the arguments listed below.
mentova_deontic(status(Agent, Action, Context), status(Agent, Action, unregulated, Context),
                % Continue the multi-line expression started above.
                just(deontic(agent(Agent), action(Action),
                              % Continue the multi-line expression started above.
                              context(Context), status(unregulated)))) :-
    % Succeed only if 'deontic(Agent, Action, _, Context' cannot be proved (negation as failure).
    \+ deontic(Agent, Action, _, Context).

% State a fact for 'mentova deontic' with the arguments listed below.
mentova_deontic(may(Agent, Action, Context), permitted,
                % Continue the multi-line expression started above.
                just(deontic(permission_check(Agent, Action, Context),
                              % Continue the multi-line expression started above.
                              result(permitted)))) :-
    % State a fact for 'deontic' with the arguments listed below.
    deontic(Agent, Action, permitted, Context), !.

% State a fact for 'mentova deontic' with the arguments listed below.
mentova_deontic(may(Agent, Action, Context), not_permitted,
                % Continue the multi-line expression started above.
                just(deontic(permission_check(Agent, Action, Context),
                              % Continue the multi-line expression started above.
                              result(not_permitted)))) :-
    % Succeed only if 'deontic(Agent, Action, permitted, Context' cannot be proved (negation as failure).
    \+ deontic(Agent, Action, permitted, Context).

% State a fact for 'mentova deontic' with the arguments listed below.
mentova_deontic(must(Agent, Action, Context), obligatory,
                % Continue the multi-line expression started above.
                just(deontic(obligation_check(Agent, Action, Context),
                              % Continue the multi-line expression started above.
                              result(obligatory)))) :-
    % State a fact for 'deontic' with the arguments listed below.
    deontic(Agent, Action, obligatory, Context), !.

% State a fact for 'mentova deontic' with the arguments listed below.
mentova_deontic(must(Agent, Action, Context), not_obligatory,
                % Continue the multi-line expression started above.
                just(deontic(obligation_check(Agent, Action, Context),
                              % Continue the multi-line expression started above.
                              result(not_obligatory)))) :-
    % Succeed only if 'deontic(Agent, Action, obligatory, Context' cannot be proved (negation as failure).
    \+ deontic(Agent, Action, obligatory, Context).

% State a fact for 'mentova deontic' with the arguments listed below.
mentova_deontic(forbidden(Agent, Action, Context), prohibited,
                % Continue the multi-line expression started above.
                just(deontic(prohibition_check(Agent, Action, Context),
                              % Continue the multi-line expression started above.
                              result(prohibited)))) :-
    % State a fact for 'deontic' with the arguments listed below.
    deontic(Agent, Action, prohibited, Context), !.

% State a fact for 'mentova deontic' with the arguments listed below.
mentova_deontic(forbidden(Agent, Action, Context), not_prohibited,
                % Continue the multi-line expression started above.
                just(deontic(prohibition_check(Agent, Action, Context),
                              % Continue the multi-line expression started above.
                              result(not_prohibited)))) :-
    % Succeed only if 'deontic(Agent, Action, prohibited, Context' cannot be proved (negation as failure).
    \+ deontic(Agent, Action, prohibited, Context).

% State a fact for 'mentova deontic' with the arguments listed below.
mentova_deontic(obligations_of(Agent, Context), obligations(Agent, Context, Acts),
                % Continue the multi-line expression started above.
                just(deontic(all_obligations(Agent, Context), list(Acts)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(A, deontic(Agent, A, obligatory, Context), Acts).

% State a fact for 'mentova deontic' with the arguments listed below.
mentova_deontic(violations(Agent, Context), violations(Agent, Context, Viols),
                % Continue the multi-line expression started above.
                just(deontic(violation_check(Agent, Context), list(Viols)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(A, deontic(Agent, A, prohibited, Context), Viols).
