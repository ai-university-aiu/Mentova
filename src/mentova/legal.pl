/*  Mentova — Rung 47: Legal Reasoning Module

    Applies legal rules with exceptions to concrete cases.
    Uses a small set of statutory rules and case precedents.
    Pass criterion: given a legal scenario, correctly apply the rule,
    check for exceptions, cite the relevant precedent, and deliver verdict.
*/

:- module(legal, [
    mentova_legal/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Legal rules: rule(RuleId, Description, General_clause, Conclusion)
% ---------------------------------------------------------------------------

legal_rule(r1, 'theft_rule',
           'person takes property belonging to another without consent',
           liable(theft)).

legal_rule(r2, 'self_defence_rule',
           'person uses reasonable force to defend against imminent threat',
           exempt(self_defence)).

legal_rule(r3, 'contract_rule',
           'two parties agree on terms with consideration',
           valid(contract)).

legal_rule(r4, 'negligence_rule',
           'person breaches duty of care causing foreseeable harm',
           liable(negligence)).

legal_rule(r5, 'trespass_rule',
           'person enters land of another without permission',
           liable(trespass)).

% ---------------------------------------------------------------------------
% Exceptions: exception(RuleId, Exception, Conclusion)
% ---------------------------------------------------------------------------

legal_exception(r1, 'necessity_defence',
                'property taken to prevent greater harm',
                exempt(necessity)).

legal_exception(r1, 'owner_consent',
                'owner later ratified the taking',
                exempt(consent)).

legal_exception(r4, 'volenti',
                'claimant voluntarily accepted the risk',
                exempt(volenti)).

legal_exception(r5, 'implied_licence',
                'entry customarily permitted (e.g. postal delivery)',
                exempt(implied_licence)).

% ---------------------------------------------------------------------------
% Case precedents: precedent(CaseId, RuleApplied, Outcome, Ratio)
% ---------------------------------------------------------------------------

precedent(case_donoghue_stevenson, r4, liable(negligence),
          'manufacturer owes duty of care to end consumer').

precedent(case_carlill_carbolic,   r3, valid(contract),
          'advertisement with clear terms can constitute binding offer').

precedent(case_rv_hasan,           r2, not_exempt,
          'self-defence not available if defendant created the danger').

precedent(case_entick_v_carrington, r5, liable(trespass),
          'state agents may not enter private property without lawful authority').

% ---------------------------------------------------------------------------
% Apply rule to a scenario
% Scenario: list of facts as atoms
% ---------------------------------------------------------------------------

rule_applies(RuleId, Scenario) :-
    legal_rule(RuleId, _, Clause, _),
    member(Clause, Scenario).

exception_applies(RuleId, Scenario, ExDesc, ExConc) :-
    legal_exception(RuleId, ExDesc, ExClause, ExConc),
    member(ExClause, Scenario).

% ---------------------------------------------------------------------------
% mentova_legal(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_legal(apply(RuleId, Scenario), verdict(Conc),
              just(legal(rule(RuleId),
                          scenario(Scenario),
                          conclusion(Conc),
                          exception(none)))) :-
    legal_rule(RuleId, _, Clause, Conc),
    member(Clause, Scenario),
    \+ exception_applies(RuleId, Scenario, _, _).

mentova_legal(apply(RuleId, Scenario), verdict(ExConc),
              just(legal(rule(RuleId),
                          scenario(Scenario),
                          exception_applies(ExDesc),
                          conclusion(ExConc)))) :-
    rule_applies(RuleId, Scenario),
    exception_applies(RuleId, Scenario, ExDesc, ExConc).

mentova_legal(precedent(CaseId), precedent(CaseId, Rule, Outcome, Ratio),
              just(legal(precedent_lookup(CaseId),
                          rule(Rule), outcome(Outcome), ratio(Ratio)))) :-
    precedent(CaseId, Rule, Outcome, Ratio).

mentova_legal(exceptions_for(RuleId), exceptions(RuleId, Excs),
              just(legal(exceptions_query(RuleId), list(Excs)))) :-
    findall(E-C, legal_exception(RuleId, E, _, C), Excs).

mentova_legal(what_rules, rules(List),
              just(legal(all_rules, list(List)))) :-
    findall(Id-Desc, legal_rule(Id, Desc, _, _), List).
