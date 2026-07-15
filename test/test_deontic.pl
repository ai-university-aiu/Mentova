/*  Mentova — Deontic Reasoning Module Test Suite

    Behavioural PLUnit tests for the single exported predicate
    mentova_deontic/3 of src/mentova/deontic.pl. The module reasons over a
    built-in table of deontic(Agent, Action, Status, Context) facts, where
    Status is obligatory, permitted, or prohibited, and answers six query
    shapes: status/3 (regulated or unregulated), may/3 (permitted /
    not_permitted), must/3 (obligatory / not_obligatory), forbidden/3
    (prohibited / not_prohibited), obligations_of/2 (list all obligations),
    and violations/2 (list all prohibitions). Each answer carries a
    glass-box just(...) justification term. Every expected value below is
    hand-computed from the module's fact table.

    Run with the full PrologAI library path plus the Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_deontic.pl
*/

% Declare this file as the test module with no exports.
:- module(test_deontic, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the deontic reasoning module under test from the library path.
:- use_module(library(deontic)).

% Open the test block for the deontic module.
:- begin_tests(deontic).

% AC-DEONTIC-001: a regulated status query returns the stored status and its glass-box justification.
test(status_regulated_returns_status_and_justification) :-
    % Ask for the deontic status of a driver wearing a seatbelt on the road.
    mentova_deontic(status(driver, wear_seatbelt, road), Result, Justification),
    % The fact table records wear_seatbelt as obligatory for a driver on the road.
    assertion(Result == status(driver, wear_seatbelt, obligatory, road)),
    % The justification names the agent, action, context, and resolved status.
    assertion(Justification == just(deontic(agent(driver), action(wear_seatbelt),
                                            context(road), status(obligatory)))).

% AC-DEONTIC-002: a status query for an unlisted action reports it as unregulated.
test(status_unregulated_when_no_fact) :-
    % Ask for the status of an action no rule covers for a driver on the road.
    mentova_deontic(status(driver, whistle, road), Result, Justification),
    % With no matching fact the action is reported as unregulated.
    assertion(Result == status(driver, whistle, unregulated, road)),
    % The justification carries the unregulated verdict rather than a stored status.
    assertion(Justification == just(deontic(agent(driver), action(whistle),
                                            context(road), status(unregulated)))).

% AC-DEONTIC-003: a must query confirms an obligation and a permission is not an obligation.
test(must_reports_obligation_and_non_obligation) :-
    % Stopping at a red light is an obligation for a driver on the road.
    mentova_deontic(must(driver, stop_at_red, road), MustResult, MustJust),
    % The obligation check returns obligatory.
    assertion(MustResult == obligatory),
    % The justification names the obligation check and its obligatory result.
    assertion(MustJust == just(deontic(obligation_check(driver, stop_at_red, road),
                                       result(obligatory)))),
    % Using the horn is merely permitted, so it is not an obligation.
    mentova_deontic(must(driver, use_horn, road), NotResult, _),
    % The obligation check returns not_obligatory for a permitted-only action.
    assertion(NotResult == not_obligatory).

% AC-DEONTIC-004: a may query grants a permitted action and withholds a non-permitted one.
test(may_reports_permission_and_non_permission) :-
    % Using the horn is explicitly permitted for a driver on the road.
    mentova_deontic(may(driver, use_horn, road), MayResult, MayJust),
    % The permission check returns permitted.
    assertion(MayResult == permitted),
    % The justification names the permission check and its permitted result.
    assertion(MayJust == just(deontic(permission_check(driver, use_horn, road),
                                      result(permitted)))),
    % Wearing a seatbelt is obligatory rather than permitted, so may is withheld.
    mentova_deontic(may(driver, wear_seatbelt, road), NotResult, _),
    % An action whose only status is obligatory is reported not_permitted.
    assertion(NotResult == not_permitted).

% AC-DEONTIC-005: a forbidden query flags a prohibition and clears a permitted action.
test(forbidden_reports_prohibition_and_non_prohibition) :-
    % Using a phone is prohibited for a driver on the road.
    mentova_deontic(forbidden(driver, use_phone, road), ForbidResult, ForbidJust),
    % The prohibition check returns prohibited.
    assertion(ForbidResult == prohibited),
    % The justification names the prohibition check and its prohibited result.
    assertion(ForbidJust == just(deontic(prohibition_check(driver, use_phone, road),
                                         result(prohibited)))),
    % Using the horn is permitted, so it is not prohibited.
    mentova_deontic(forbidden(driver, use_horn, road), NotResult, _),
    % A permitted action is reported not_prohibited.
    assertion(NotResult == not_prohibited).

% AC-DEONTIC-006: obligations_of gathers every obligatory action for an agent in a context, in table order.
test(obligations_of_lists_all_obligations) :-
    % Collect every obligation a driver has on the road.
    mentova_deontic(obligations_of(driver, road), Result, Justification),
    % The two road obligations are wear_seatbelt and stop_at_red, in fact-table order.
    assertion(Result == obligations(driver, road, [wear_seatbelt, stop_at_red])),
    % The justification names the all-obligations gather and lists the same actions.
    assertion(Justification == just(deontic(all_obligations(driver, road),
                                            list([wear_seatbelt, stop_at_red])))),
    % A different agent-context pair yields its own distinct obligation list, proving a real query.
    mentova_deontic(obligations_of(employee, workplace), EmpResult, _),
    % An employee's workplace obligations are attending meetings and submitting reports.
    assertion(EmpResult == obligations(employee, workplace, [attend_meetings, submit_reports])).

% AC-DEONTIC-007: violations gathers every prohibited action for an agent in a context, in table order.
test(violations_lists_all_prohibitions) :-
    % Collect every prohibited action for a driver on the road.
    mentova_deontic(violations(driver, road), Result, Justification),
    % The two road prohibitions are use_phone and exceed_speed, in fact-table order.
    assertion(Result == violations(driver, road, [use_phone, exceed_speed])),
    % The justification names the violation check and lists the same prohibited actions.
    assertion(Justification == just(deontic(violation_check(driver, road),
                                            list([use_phone, exceed_speed])))),
    % A citizen in society has a single prohibition, confirming the list is genuinely computed.
    mentova_deontic(violations(citizen, society), CitResult, _),
    % Harming others is the citizen's one societal prohibition.
    assertion(CitResult == violations(citizen, society, [harm_others])).

% Close the test block for the deontic module.
:- end_tests(deontic).
