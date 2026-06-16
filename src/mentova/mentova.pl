/*  Mentova — Bootstrap Entry Point

    Mentova is a Synthetic Mind written in PrologAI.
    This module loads the foundational knowledge, constitution, and bodies,
    and exposes the top-level reasoning predicates.

    Usage:
        swipl -l src/mentova/mentova.pl -g "mentova_boot" -t halt
*/

:- module(mentova, [
    mentova_boot/0,
    mentova_query/3
]).

:- use_module('../../knowledge/small_world').
:- use_module('../../constitution/constitution').
:- use_module('../../bodies/bodies').
:- use_module(induction).
:- use_module(abduction).
:- use_module(probabilistic).
:- use_module(bayesian).
:- use_module(causal).
:- use_module(statistical).
:- use_module(analogical).
:- use_module(relational).
:- use_module(transductive).
:- use_module(commonsense).
:- use_module(logical).
:- use_module(formal).
:- use_module(mathematical).
:- use_module(fuzzy).
:- use_module(qualitative).
:- use_module(nonmonotonic).
:- use_module(paraconsistent).
:- use_module(counterfactual).
:- use_module(hypothetical).
:- use_module(spatial).
:- use_module(diagrammatic).
:- use_module(temporal).
:- use_module(case_based).
:- use_module(constraint_based).
:- use_module(scientific).
:- use_module(system_reasoning).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% mentova_boot/0 — initialise Mentova
% ---------------------------------------------------------------------------

mentova_boot :-
    format("~n=== Mentova is waking up ===~n"),
    format("Platform : PrologAI~n"),
    format("Mind     : Mentova~n"),
    format("~n"),
    enroll_bodies,
    aggregate_all(count, constitutional_principle(_, _), NPrinciples),
    aggregate_all(count, registered_overseer(_, _),      NOverseers),
    format("~nConstitution: ~w principles, ~w overseer(s)~n",
           [NPrinciples, NOverseers]),
    format("Knowledge: Small-World Commonsense loaded~n"),
    format("~nMentova is ready. Born at Rung 1 — transparent deduction.~n~n").

% ---------------------------------------------------------------------------
% mentova_query/3 — top-level glass-box query
%
%   +QueryType: deductive | defeasible | probabilistic | ...
%   +Query:     the query term
%   -Result:    answer(Conclusion, Justification)
% ---------------------------------------------------------------------------

mentova_query(deductive, is_a(X, Class), answer(yes, just(X, is_a, Class, chain(Chain)))) :-
    is_a_chain(X, Class, Chain).
mentova_query(deductive, capable_of(X, Cap), answer(yes, just(X, capable_of, Cap, via_isa))) :-
    is_a(X, Parent), capable_of(Parent, Cap).
mentova_query(deductive, capable_of(X, Cap), answer(yes, just(X, capable_of, Cap, direct))) :-
    capable_of(X, Cap).
mentova_query(defeasible, flies(X), answer(Answer, Justification)) :-
    ( default_rule(flies(X), is_a(X, bird)),
      is_a(X, bird)
    ->  ( exception_rule(flies(X), Cond, Note),
          call(Cond)
        ->  Answer = no,
            Justification = just(exception(Note))
        ;   Answer = yes,
            Justification = just(default(bird_flies))
        )
    ;   Answer = no,
        Justification = just(not_a_bird)
    ).
mentova_query(probabilistic, prob(Prop), answer(Prob, just(weighted_fact(Prop)))) :-
    prob_fact(Prop, Prob).
mentova_query(epistemic, believes(Agent, Prop), answer(Value, just(belief(Agent, Prop)))) :-
    believes(Agent, Prop, Value).

% Rung 27 — system: reason about parts and interactions
mentova_query(system, SysQuery, answer(Result, Just)) :-
    once(mentova_system(SysQuery, Result, Just)).

% Rung 26 — scientific: form, test, and score a hypothesis
mentova_query(scientific, SciQuery, answer(Result, Just)) :-
    once(mentova_scientific(SciQuery, Result, Just)).

% Rung 25 — constraint-based: solve a constraint puzzle
mentova_query(constraint, ConstraintQuery, answer(Result, Just)) :-
    mentova_constraint(ConstraintQuery, Result, Just).

% Rung 24 — case-based: solve by adapting similar past case
mentova_query(case_based, CBRQuery, answer(Result, Just)) :-
    once(mentova_cbr(CBRQuery, Result, Just)).

% Rung 23 — temporal: ordering and duration questions
mentova_query(temporal, TempQuery, answer(Result, Just)) :-
    once(mentova_temporal(TempQuery, Result, Just)).

% Rung 22 — diagrammatic: read a small grid or layout
mentova_query(diagrammatic, DiagQuery, answer(Result, Just)) :-
    once(mentova_diagrammatic(DiagQuery, Result, Just)).

% Rung 21 — spatial: containment and position with reference frames
mentova_query(spatial, SpatialQuery, answer(Result, Just)) :-
    once(mentova_spatial(SpatialQuery, Result, Just)).

% Rung 20 — hypothetical: explore supposition without asserting it
mentova_query(hypothetical, HypQuery, answer(Result, Just)) :-
    mentova_hypothetical(HypQuery, Result, Just).

% Rung 19 — counterfactual: what if this were different
mentova_query(counterfactual, CFQuery, answer(Result, Just)) :-
    mentova_counterfactual(CFQuery, Result, Just).

% Rung 18 — paraconsistent: reason despite contradiction
mentova_query(paraconsistent, ParaQuery, answer(Result, Just)) :-
    once(mentova_paraconsistent(ParaQuery, Result, Just)).

% Rung 17 — non-monotonic: defeasible default retraction
mentova_query(nonmonotonic, NMQuery, answer(Result, Just)) :-
    mentova_defeasible(query(NMQuery), Result, Just).

% Rung 16 — qualitative: predict direction of change
mentova_query(qualitative, QualQuery, answer(Result, Just)) :-
    once(mentova_qualitative(QualQuery, Result, Just)).

% Rung 15 — fuzzy: graded membership / degree of truth
mentova_query(fuzzy, FuzzyQuery, answer(Result, Just)) :-
    once(mentova_fuzzy(FuzzyQuery, Result, Just)).

% Rung 14 — mathematical: compute quantitative answer
mentova_query(mathematical, MathQuery, answer(Result, Just)) :-
    mentova_math(MathQuery, Result, Just).

% Rung 13 — formal: check derivation against Minimal PrologAI Kernel
mentova_query(formal, FormalQuery, answer(Result, Just)) :-
    mentova_formal(FormalQuery, Result, Just).

% Rung 12 — logical: forward-chaining rule engine
mentova_query(logical, LogQuery, answer(Result, Just)) :-
    mentova_logical(LogQuery, Result, Just).

% Rung 11 — commonsense: answer everyday-knowledge question with provenance
mentova_query(commonsense, CSQuery, answer(Ans, Just)) :-
    once(mentova_commonsense(CSQuery, Ans, Just)).

% Rung 10 — transductive: classify by nearest known cases (kNN)
mentova_query(transductive, TransQuery, answer(Label, Just)) :-
    mentova_transduce(TransQuery, Label, Just).

% Rung 9 — relational: multi-hop relational query
mentova_query(relational, RelQuery, answer(Result, Just)) :-
    once(mentova_relational(RelQuery, Result, Just)).

% Rung 8 — analogical: complete A:B :: C:? by structure mapping
mentova_query(analogical, AnalogyQuery, answer(D, Just)) :-
    once(mentova_analogy(AnalogyQuery, D, Just)).

% Rung 7 — statistical: find pattern in observation table
mentova_query(statistical, StatQuery, answer(Result, Just)) :-
    mentova_stat(StatQuery, Result, Just).

% Rung 6 — causal: predict effect of intervention vs observation
mentova_query(causal, CausalQuery, answer(Result, Just)) :-
    mentova_causal(CausalQuery, Result, Just).

% Rung 5 — bayesian: update belief on new evidence
mentova_query(bayesian, update(H, E), answer(Posterior, Just)) :-
    mentova_bayes(H, E, Posterior, Just).

% Rung 4 — probabilistic: compute query likelihood
mentova_query(probabilistic, ProbQuery, answer(P, Just)) :-
    mentova_prob(ProbQuery, P, Just).

% Rung 3 — abductive: best explanation for an observation
mentova_query(abductive, explain(Obs),
              answer(Best, just(abduction(Obs), all_explanations(All)))) :-
    mentova_abduce(Obs, Best, _Score, All).

% Rung 2 — inductive: induce a rule from examples, verify on held-out cases
mentova_query(inductive, induce(Pos, Neg, BG, HeldOut),
              answer(rule(Rule), just(induced(Rule), verified(HeldOut, Results)))) :-
    mentova_induce(Pos, Neg, BG, Rule),
    Rule = (Head :- Body),
    maplist([Ex, Ex-Verdict]>>(
        copy_term(Head-Body, Ex-BodyInst),
        ( call(BodyInst) -> Verdict = pass ; Verdict = fail )
    ), HeldOut, Results).

% is_a_chain(+X, +Class, -Chain): find transitive IsA chain
is_a_chain(X, Class, [X, Class]) :-
    is_a(X, Class).
is_a_chain(X, Class, [X | Rest]) :-
    is_a(X, Mid),
    is_a_chain(Mid, Class, Rest).
