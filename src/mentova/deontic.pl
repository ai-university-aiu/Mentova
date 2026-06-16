/*  Mentova — Rung 35: Deontic Reasoning Module

    Reasons about obligations (must), permissions (may), and prohibitions
    (must not). Uses norm/2 from Small-World KB and adds richer deontic facts.
    Pass criterion: correctly reports whether an action is obligatory,
    permitted, or prohibited in a given context.
*/

:- module(deontic, [
    mentova_deontic/3
]).

:- use_module(library(lists), [member/2]).
:- use_module('../../knowledge/small_world', [norm/2]).

% ---------------------------------------------------------------------------
% Deontic facts: deontic(Agent, Action, Status, Context)
% Status: obligatory | permitted | prohibited
% ---------------------------------------------------------------------------

deontic(driver,    wear_seatbelt,     obligatory,  road).
deontic(driver,    use_phone,         prohibited,  road).
deontic(driver,    stop_at_red,       obligatory,  road).
deontic(driver,    exceed_speed,      prohibited,  road).
deontic(driver,    use_horn,          permitted,   road).

deontic(employee,  attend_meetings,   obligatory,  workplace).
deontic(employee,  share_password,    prohibited,  workplace).
deontic(employee,  take_breaks,       permitted,   workplace).
deontic(employee,  submit_reports,    obligatory,  workplace).

deontic(citizen,   pay_taxes,         obligatory,  society).
deontic(citizen,   vote,              permitted,   society).
deontic(citizen,   harm_others,       prohibited,  society).
deontic(citizen,   free_speech,       permitted,   society).

deontic(student,   attend_classes,    obligatory,  school).
deontic(student,   cheat_exams,       prohibited,  school).
deontic(student,   ask_questions,     permitted,   school).
deontic(student,   study,             obligatory,  school).

% ---------------------------------------------------------------------------
% mentova_deontic(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_deontic(status(Agent, Action, Context), status(Agent, Action, Status, Context),
                just(deontic(agent(Agent), action(Action),
                              context(Context), status(Status)))) :-
    deontic(Agent, Action, Status, Context), !.

mentova_deontic(status(Agent, Action, Context), status(Agent, Action, unregulated, Context),
                just(deontic(agent(Agent), action(Action),
                              context(Context), status(unregulated)))) :-
    \+ deontic(Agent, Action, _, Context).

mentova_deontic(may(Agent, Action, Context), permitted,
                just(deontic(permission_check(Agent, Action, Context),
                              result(permitted)))) :-
    deontic(Agent, Action, permitted, Context), !.

mentova_deontic(may(Agent, Action, Context), not_permitted,
                just(deontic(permission_check(Agent, Action, Context),
                              result(not_permitted)))) :-
    \+ deontic(Agent, Action, permitted, Context).

mentova_deontic(must(Agent, Action, Context), obligatory,
                just(deontic(obligation_check(Agent, Action, Context),
                              result(obligatory)))) :-
    deontic(Agent, Action, obligatory, Context), !.

mentova_deontic(must(Agent, Action, Context), not_obligatory,
                just(deontic(obligation_check(Agent, Action, Context),
                              result(not_obligatory)))) :-
    \+ deontic(Agent, Action, obligatory, Context).

mentova_deontic(forbidden(Agent, Action, Context), prohibited,
                just(deontic(prohibition_check(Agent, Action, Context),
                              result(prohibited)))) :-
    deontic(Agent, Action, prohibited, Context), !.

mentova_deontic(forbidden(Agent, Action, Context), not_prohibited,
                just(deontic(prohibition_check(Agent, Action, Context),
                              result(not_prohibited)))) :-
    \+ deontic(Agent, Action, prohibited, Context).

mentova_deontic(obligations_of(Agent, Context), obligations(Agent, Context, Acts),
                just(deontic(all_obligations(Agent, Context), list(Acts)))) :-
    findall(A, deontic(Agent, A, obligatory, Context), Acts).

mentova_deontic(violations(Agent, Context), violations(Agent, Context, Viols),
                just(deontic(violation_check(Agent, Context), list(Viols)))) :-
    findall(A, deontic(Agent, A, prohibited, Context), Viols).
