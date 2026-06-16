/*  Mentova — Rung 47: Legal Reasoning Module

    Applies legal rules with exceptions to concrete cases.
    Uses a small set of statutory rules and case precedents.
    Pass criterion: given a legal scenario, correctly apply the rule,
    check for exceptions, cite the relevant precedent, and deliver verdict.
*/

% Declare this file as the 'legal' module and list its exported predicates.
:- module(legal, [
    % Supply 'mentova_legal/3' as the next argument to the expression above.
    mentova_legal/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Legal rules: rule(RuleId, Description, General_clause, Conclusion)
% ---------------------------------------------------------------------------

% State a fact for 'legal rule' with the arguments listed below.
legal_rule(r1, 'theft_rule',
           % Continue the multi-line expression started above.
           'person takes property belonging to another without consent',
           % Continue the multi-line expression started above.
           liable(theft)).

% State a fact for 'legal rule' with the arguments listed below.
legal_rule(r2, 'self_defence_rule',
           % Continue the multi-line expression started above.
           'person uses reasonable force to defend against imminent threat',
           % Continue the multi-line expression started above.
           exempt(self_defence)).

% State a fact for 'legal rule' with the arguments listed below.
legal_rule(r3, 'contract_rule',
           % Continue the multi-line expression started above.
           'two parties agree on terms with consideration',
           % Continue the multi-line expression started above.
           valid(contract)).

% State a fact for 'legal rule' with the arguments listed below.
legal_rule(r4, 'negligence_rule',
           % Continue the multi-line expression started above.
           'person breaches duty of care causing foreseeable harm',
           % Continue the multi-line expression started above.
           liable(negligence)).

% State a fact for 'legal rule' with the arguments listed below.
legal_rule(r5, 'trespass_rule',
           % Continue the multi-line expression started above.
           'person enters land of another without permission',
           % Continue the multi-line expression started above.
           liable(trespass)).

% ---------------------------------------------------------------------------
% Exceptions: exception(RuleId, Exception, Conclusion)
% ---------------------------------------------------------------------------

% State a fact for 'legal exception' with the arguments listed below.
legal_exception(r1, 'necessity_defence',
                % Continue the multi-line expression started above.
                'property taken to prevent greater harm',
                % Continue the multi-line expression started above.
                exempt(necessity)).

% State a fact for 'legal exception' with the arguments listed below.
legal_exception(r1, 'owner_consent',
                % Continue the multi-line expression started above.
                'owner later ratified the taking',
                % Continue the multi-line expression started above.
                exempt(consent)).

% State a fact for 'legal exception' with the arguments listed below.
legal_exception(r4, 'volenti',
                % Continue the multi-line expression started above.
                'claimant voluntarily accepted the risk',
                % Continue the multi-line expression started above.
                exempt(volenti)).

% State a fact for 'legal exception' with the arguments listed below.
legal_exception(r5, 'implied_licence',
                % Continue the multi-line expression started above.
                'entry customarily permitted (e.g. postal delivery)',
                % Continue the multi-line expression started above.
                exempt(implied_licence)).

% ---------------------------------------------------------------------------
% Case precedents: precedent(CaseId, RuleApplied, Outcome, Ratio)
% ---------------------------------------------------------------------------

% State a fact for 'precedent' with the arguments listed below.
precedent(case_donoghue_stevenson, r4, liable(negligence),
          % Continue the multi-line expression started above.
          'manufacturer owes duty of care to end consumer').

% State a fact for 'precedent' with the arguments listed below.
precedent(case_carlill_carbolic,   r3, valid(contract),
          % Continue the multi-line expression started above.
          'advertisement with clear terms can constitute binding offer').

% State a fact for 'precedent' with the arguments listed below.
precedent(case_rv_hasan,           r2, not_exempt,
          % Continue the multi-line expression started above.
          'self-defence not available if defendant created the danger').

% State a fact for 'precedent' with the arguments listed below.
precedent(case_entick_v_carrington, r5, liable(trespass),
          % Continue the multi-line expression started above.
          'state agents may not enter private property without lawful authority').

% ---------------------------------------------------------------------------
% Apply rule to a scenario
% Scenario: list of facts as atoms
% ---------------------------------------------------------------------------

% Define a clause for 'rule applies': succeed when the following conditions hold.
rule_applies(RuleId, Scenario) :-
    % State a fact for 'legal rule' with the arguments listed below.
    legal_rule(RuleId, _, Clause, _),
    % Succeed for each element 'Clause' that is a member of the list.
    member(Clause, Scenario).

% Define a clause for 'exception applies': succeed when the following conditions hold.
exception_applies(RuleId, Scenario, ExDesc, ExConc) :-
    % State a fact for 'legal exception' with the arguments listed below.
    legal_exception(RuleId, ExDesc, ExClause, ExConc),
    % Succeed for each element 'ExClause' that is a member of the list.
    member(ExClause, Scenario).

% ---------------------------------------------------------------------------
% mentova_legal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova legal' with the arguments listed below.
mentova_legal(apply(RuleId, Scenario), verdict(Conc),
              % Continue the multi-line expression started above.
              just(legal(rule(RuleId),
                          % Continue the multi-line expression started above.
                          scenario(Scenario),
                          % Continue the multi-line expression started above.
                          conclusion(Conc),
                          % Continue the multi-line expression started above.
                          exception(none)))) :-
    % State a fact for 'legal rule' with the arguments listed below.
    legal_rule(RuleId, _, Clause, Conc),
    % Succeed for each element 'Clause' that is a member of the list.
    member(Clause, Scenario),
    % Succeed only if 'exception_applies(RuleId, Scenario, _, _' cannot be proved (negation as failure).
    \+ exception_applies(RuleId, Scenario, _, _).

% State a fact for 'mentova legal' with the arguments listed below.
mentova_legal(apply(RuleId, Scenario), verdict(ExConc),
              % Continue the multi-line expression started above.
              just(legal(rule(RuleId),
                          % Continue the multi-line expression started above.
                          scenario(Scenario),
                          % Continue the multi-line expression started above.
                          exception_applies(ExDesc),
                          % Continue the multi-line expression started above.
                          conclusion(ExConc)))) :-
    % State a fact for 'rule applies' with the arguments listed below.
    rule_applies(RuleId, Scenario),
    % State the fact: exception applies(RuleId, Scenario, ExDesc, ExConc).
    exception_applies(RuleId, Scenario, ExDesc, ExConc).

% State a fact for 'mentova legal' with the arguments listed below.
mentova_legal(precedent(CaseId), precedent(CaseId, Rule, Outcome, Ratio),
              % Continue the multi-line expression started above.
              just(legal(precedent_lookup(CaseId),
                          % Continue the multi-line expression started above.
                          rule(Rule), outcome(Outcome), ratio(Ratio)))) :-
    % State the fact: precedent(CaseId, Rule, Outcome, Ratio).
    precedent(CaseId, Rule, Outcome, Ratio).

% State a fact for 'mentova legal' with the arguments listed below.
mentova_legal(exceptions_for(RuleId), exceptions(RuleId, Excs),
              % Continue the multi-line expression started above.
              just(legal(exceptions_query(RuleId), list(Excs)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(E-C, legal_exception(RuleId, E, _, C), Excs).

% State a fact for 'mentova legal' with the arguments listed below.
mentova_legal(what_rules, rules(List),
              % Continue the multi-line expression started above.
              just(legal(all_rules, list(List)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Id-Desc, legal_rule(Id, Desc, _, _), List).
