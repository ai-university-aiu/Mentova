/*  Mentova — Legal Reasoning Module Test Suite

    Behavioural PLUnit tests for the single exported predicate
    mentova_legal/3 of src/mentova/legal.pl. The module reasons over a
    built-in table of statutory rules (legal_rule/4), exceptions
    (legal_exception/4), and case precedents (precedent/4), and answers
    five query shapes:
      apply(RuleId, Scenario)  — apply a rule to a scenario (a list of
                                 fact atoms), returning verdict(Conc);
                                 when a defence in the scenario matches an
                                 exception for that rule, the exception's
                                 conclusion supersedes the rule's;
      precedent(CaseId)        — look up a stored case precedent;
      exceptions_for(RuleId)   — list every exception of a rule as
                                 Desc-Conclusion pairs;
      what_rules               — list every rule as Id-Description pairs.
    Each answer carries a glass-box just(...) justification term. Every
    expected value below is hand-computed from the module's fact table.

    Run with the full PrologAI library path plus the Mentova source:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_legal.pl
*/

% Declare this file as the test module with no exports.
:- module(test_legal, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the legal reasoning module under test from the library path.
:- use_module(library(legal)).

% Open the test block for the legal module.
:- begin_tests(legal).

% AC-LEGAL-001: applying the theft rule to a matching scenario with no exception returns a liable verdict.
test(apply_theft_rule_no_exception) :-
    % The scenario names only the theft rule's general clause.
    Scenario = ['person takes property belonging to another without consent'],
    % Apply the theft rule r1 to that scenario, taking its primary verdict.
    once(mentova_legal(apply(r1, Scenario), Result, Justification)),
    % Rule r1 concludes liable(theft) and no exception is present, so the verdict is liable(theft).
    assertion(Result == verdict(liable(theft))),
    % The justification names the rule, the scenario, the conclusion, and records that no exception fired.
    assertion(Justification == just(legal(rule(r1), scenario(Scenario),
                                          % Name the liable-theft conclusion and record that no exception fired.
                                          conclusion(liable(theft)), exception(none)))).

% AC-LEGAL-002: a necessity defence in the scenario overrides the theft rule's conclusion.
test(apply_theft_rule_with_necessity_exception) :-
    % The scenario names the theft clause and the necessity-defence clause.
    Scenario = ['person takes property belonging to another without consent',
                % Add the necessity-defence clause to the scenario list.
                'property taken to prevent greater harm'],
    % Apply the theft rule r1 to that scenario, taking its primary verdict.
    once(mentova_legal(apply(r1, Scenario), Result, Justification)),
    % The necessity exception of r1 concludes exempt(necessity), which supersedes the rule's liable(theft).
    assertion(Result == verdict(exempt(necessity))),
    % The justification names the rule, the scenario, the fired exception, and the exception's conclusion.
    assertion(Justification == just(legal(rule(r1), scenario(Scenario),
                                          % Name the necessity-defence exception that fired.
                                          exception_applies('necessity_defence'),
                                          % Name the exemption conclusion the exception produced.
                                          conclusion(exempt(necessity))))).

% AC-LEGAL-003: an implied-licence defence overrides the trespass rule, while bare negligence stays liable.
test(exception_overrides_only_when_present) :-
    % A trespass scenario that also raises the implied-licence defence.
    TrespassScenario = ['person enters land of another without permission',
                        % Add the implied-licence defence clause to the scenario list.
                        'entry customarily permitted (e.g. postal delivery)'],
    % Applying the trespass rule r5 there yields the exception's exempt(implied_licence) verdict.
    once(mentova_legal(apply(r5, TrespassScenario), TrespassResult, _)),
    % The implied-licence exception supersedes liable(trespass).
    assertion(TrespassResult == verdict(exempt(implied_licence))),
    % A negligence scenario with no matching defence clause.
    NegligenceScenario = ['person breaches duty of care causing foreseeable harm'],
    % Applying the negligence rule r4 there yields the plain liable verdict.
    once(mentova_legal(apply(r4, NegligenceScenario), NegligenceResult, _)),
    % With no volenti defence in the scenario, the rule's own conclusion stands.
    assertion(NegligenceResult == verdict(liable(negligence))).

% AC-LEGAL-004: a rule whose clause is absent from the scenario yields no verdict at all.
test(rule_with_unmatched_clause_gives_no_verdict) :-
    % A scenario that matches none of the rules' general clauses.
    Scenario = ['an unrelated everyday fact with no legal clause'],
    % Applying the theft rule r1 to it produces no solution.
    assertion(\+ mentova_legal(apply(r1, Scenario), _, _)).

% AC-LEGAL-005: a precedent lookup returns the stored case tuple and its glass-box justification.
test(precedent_lookup_returns_stored_case) :-
    % Look up the Carlill v Carbolic Smoke Ball precedent.
    mentova_legal(precedent(case_carlill_carbolic), Result, Justification),
    % The stored precedent records rule r3, the valid-contract outcome, and its ratio.
    assertion(Result == precedent(case_carlill_carbolic, r3, valid(contract),
                                  % Give the ratio decidendi that closes the expected precedent tuple.
                                  'advertisement with clear terms can constitute binding offer')),
    % The justification names the lookup, the rule, the outcome, and the ratio.
    assertion(Justification == just(legal(precedent_lookup(case_carlill_carbolic),
                                          % Name the rule and the valid-contract outcome inside the justification.
                                          rule(r3), outcome(valid(contract)),
                                          % Restate the ratio decidendi inside the justification.
                                          ratio('advertisement with clear terms can constitute binding offer')))).

% AC-LEGAL-006: exceptions_for lists a rule's exceptions in order, and is empty for a rule that has none.
test(exceptions_for_lists_rule_exceptions) :-
    % Query the exceptions attached to the theft rule r1.
    mentova_legal(exceptions_for(r1), Result, Justification),
    % Rule r1 has exactly the necessity and consent exceptions, in that stored order.
    assertion(Result == exceptions(r1, ['necessity_defence'-exempt(necessity),
                                        % Close the exceptions list with the owner-consent exception.
                                        'owner_consent'-exempt(consent)])),
    % The justification carries the same list under the exceptions query.
    assertion(Justification == just(legal(exceptions_query(r1),
                                          % Begin the exceptions list inside the justification with the necessity exception.
                                          list(['necessity_defence'-exempt(necessity),
                                                % Close the exceptions list inside the justification with the owner-consent exception.
                                                'owner_consent'-exempt(consent)])))),
    % The contract rule r3 has no exceptions at all.
    mentova_legal(exceptions_for(r3), EmptyResult, _),
    % Its exception list is therefore empty.
    assertion(EmptyResult == exceptions(r3, [])).

% AC-LEGAL-007: what_rules lists every rule as an Id-Description pair in declaration order.
test(what_rules_lists_all_rules) :-
    % Ask the module to enumerate all of its rules.
    mentova_legal(what_rules, Result, Justification),
    % The five rules appear as Id-Description pairs in their declared order.
    assertion(Result == rules([r1-'theft_rule', r2-'self_defence_rule',
                               % Continue the rule list with the contract and negligence rules.
                               r3-'contract_rule', r4-'negligence_rule',
                               % Close the rule list with the trespass rule.
                               r5-'trespass_rule'])),
    % The justification carries the same list under the all-rules tag.
    assertion(Justification == just(legal(all_rules,
                                          % Begin the all-rules list inside the justification with the theft and self-defence rules.
                                          list([r1-'theft_rule', r2-'self_defence_rule',
                                                % Continue the all-rules list with the contract and negligence rules.
                                                r3-'contract_rule', r4-'negligence_rule',
                                                % Close the all-rules list with the trespass rule.
                                                r5-'trespass_rule'])))).

% Close the test block for the legal module.
:- end_tests(legal).
