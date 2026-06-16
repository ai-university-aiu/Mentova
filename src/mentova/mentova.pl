/*  Mentova — Bootstrap Entry Point

    Mentova is a Synthetic Mind written in PrologAI.
    This module loads the foundational knowledge, constitution, and bodies,
    and exposes the top-level reasoning predicates.

    Usage:
        swipl -l src/mentova/mentova.pl -g "mentova_boot" -t halt
*/

% Declare this file as the 'mentova' module and list its exported predicates.
:- module(mentova, [
    % Supply 'mentova_boot/0' as the next argument to the expression above.
    mentova_boot/0,
    % Supply 'mentova_query/3' as the next argument to the expression above.
    mentova_query/3
% Close the expression opened above.
]).

% Load the 'small_world' module so its predicates are available here.
:- use_module('../../knowledge/small_world').
% Load the 'constitution' module so its predicates are available here.
:- use_module('../../constitution/constitution').
% Load the 'bodies' module so its predicates are available here.
:- use_module('../../bodies/bodies').
% Execute the compile-time directive: use_module(induction).
:- use_module(induction).
% Execute the compile-time directive: use_module(abduction).
:- use_module(abduction).
% Execute the compile-time directive: use_module(probabilistic).
:- use_module(probabilistic).
% Execute the compile-time directive: use_module(bayesian).
:- use_module(bayesian).
% Execute the compile-time directive: use_module(causal).
:- use_module(causal).
% Execute the compile-time directive: use_module(statistical).
:- use_module(statistical).
% Execute the compile-time directive: use_module(analogical).
:- use_module(analogical).
% Execute the compile-time directive: use_module(relational).
:- use_module(relational).
% Execute the compile-time directive: use_module(transductive).
:- use_module(transductive).
% Execute the compile-time directive: use_module(commonsense).
:- use_module(commonsense).
% Execute the compile-time directive: use_module(logical).
:- use_module(logical).
% Execute the compile-time directive: use_module(formal).
:- use_module(formal).
% Execute the compile-time directive: use_module(mathematical).
:- use_module(mathematical).
% Execute the compile-time directive: use_module(fuzzy).
:- use_module(fuzzy).
% Execute the compile-time directive: use_module(qualitative).
:- use_module(qualitative).
% Execute the compile-time directive: use_module(nonmonotonic).
:- use_module(nonmonotonic).
% Execute the compile-time directive: use_module(paraconsistent).
:- use_module(paraconsistent).
% Execute the compile-time directive: use_module(counterfactual).
:- use_module(counterfactual).
% Execute the compile-time directive: use_module(hypothetical).
:- use_module(hypothetical).
% Execute the compile-time directive: use_module(spatial).
:- use_module(spatial).
% Execute the compile-time directive: use_module(diagrammatic).
:- use_module(diagrammatic).
% Execute the compile-time directive: use_module(temporal).
:- use_module(temporal).
% Execute the compile-time directive: use_module(case_based).
:- use_module(case_based).
% Execute the compile-time directive: use_module(constraint_based).
:- use_module(constraint_based).
% Execute the compile-time directive: use_module(scientific).
:- use_module(scientific).
% Execute the compile-time directive: use_module(system_reasoning).
:- use_module(system_reasoning).
% Execute the compile-time directive: use_module(model_based).
:- use_module(model_based).
% Execute the compile-time directive: use_module(heuristic).
:- use_module(heuristic).
% Execute the compile-time directive: use_module(critical).
:- use_module(critical).
% Execute the compile-time directive: use_module(dialectical).
:- use_module(dialectical).
% Execute the compile-time directive: use_module(metacognitive).
:- use_module(metacognitive).
% Execute the compile-time directive: use_module(modal).
:- use_module(modal).
% Execute the compile-time directive: use_module(epistemic).
:- use_module(epistemic).
% Execute the compile-time directive: use_module(deontic).
:- use_module(deontic).
% Execute the compile-time directive: use_module(procedural).
:- use_module(procedural).
% Execute the compile-time directive: use_module(symbolic).
:- use_module(symbolic).
% Execute the compile-time directive: use_module(practical).
:- use_module(practical).
% Execute the compile-time directive: use_module(teleological).
:- use_module(teleological).
% Execute the compile-time directive: use_module(strategic).
:- use_module(strategic).
% Execute the compile-time directive: use_module(narrative).
:- use_module(narrative).
% Execute the compile-time directive: use_module(social).
:- use_module(social).
% Execute the compile-time directive: use_module(intuitive).
:- use_module(intuitive).
% Execute the compile-time directive: use_module(emotional).
:- use_module(emotional).
% Execute the compile-time directive: use_module(motivational).
:- use_module(motivational).
% Execute the compile-time directive: use_module(informal).
:- use_module(informal).
% Execute the compile-time directive: use_module(legal).
:- use_module(legal).
% Execute the compile-time directive: use_module(moral).
:- use_module(moral).
% Load the Track A Transparent Reasoning Assistant module so its predicates are available here.
:- use_module(track_a).
% Load the game-as-a-body harness so game enrollment and the perceive-reason-act cycle are available.
:- use_module(game_body).
% Load the ARC-AGI driver so ARC tasks can be played as game bodies.
:- use_module(games/arc).
% Load the Raven's Progressive Matrices driver so RPM tasks can be played as game bodies.
:- use_module(games/ravens).
% Load the Baba Is You driver so Baba levels can be played as game bodies.
:- use_module(games/baba).
% Load the Pokemon stub driver so the Pokemon emulator interface is registered.
:- use_module(games/pokemon).
% Load the global workspace integration — PR 18 cycle and PR 32 attention economy.
:- use_module(global_workspace).
% Load the attention schema integration — PR 42 schema and Conscious Turing Machine correspondence.
:- use_module(attention_schema).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% mentova_boot/0 — initialise Mentova
% ---------------------------------------------------------------------------

% Execute: mentova_boot :-.
mentova_boot :-
    % Write formatted output to the current output stream.
    format("~n=== Mentova is waking up ===~n"),
    % Write formatted output to the current output stream.
    format("Platform : PrologAI~n"),
    % Write formatted output to the current output stream.
    format("Mind     : Mentova~n"),
    % Write formatted output to the current output stream.
    format("~n"),
    % Call the goal 'enroll_bodies'.
    enroll_bodies,
    % Aggregate solutions using 'count' and bind the result to a single value.
    aggregate_all(count, constitutional_principle(_, _), NPrinciples),
    % Aggregate solutions using 'count' and bind the result to a single value.
    aggregate_all(count, registered_overseer(_, _),      NOverseers),
    % Write formatted output to the current output stream.
    format("~nConstitution: ~w principles, ~w overseer(s)~n",
           % Continue the multi-line expression started above.
           [NPrinciples, NOverseers]),
    % Write formatted output to the current output stream.
    format("Knowledge: Small-World Commonsense loaded~n"),
    % Activate the Global Workspace cycle — open the APEX_MIND nexus and subscribe the broadcast logger.
    catch(workspace_boot, _, true),
    % Activate the attention schema subscriber on the workspace broadcast channel.
    catch(schema_boot, _, true),
    % Write formatted output to the current output stream.
    format("~nMentova is ready. Born at Rung 1 — transparent deduction.~n~n").

% ---------------------------------------------------------------------------
% mentova_query/3 — top-level glass-box query
%
%   +QueryType: deductive | defeasible | probabilistic | ...
%   +Query:     the query term
%   -Result:    answer(Conclusion, Justification)
% ---------------------------------------------------------------------------

% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(deductive, is_a(X, Class), answer(yes, just(X, is_a, Class, chain(Chain)))) :-
    % State the fact: is a chain(X, Class, Chain).
    is_a_chain(X, Class, Chain).
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(deductive, capable_of(X, Cap), answer(yes, just(X, capable_of, Cap, via_isa))) :-
    % State the fact: is a(X, Parent), capable_of(Parent, Cap).
    is_a(X, Parent), capable_of(Parent, Cap).
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(deductive, capable_of(X, Cap), answer(yes, just(X, capable_of, Cap, direct))) :-
    % State the fact: capable of(X, Cap).
    capable_of(X, Cap).
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(defeasible, flies(X), answer(Answer, Justification)) :-
    % Execute: ( default_rule(flies(X), is_a(X, bird)),.
    ( default_rule(flies(X), is_a(X, bird)),
      % Continue the multi-line expression started above.
      is_a(X, bird)
    % If the condition above succeeded, perform the following action.
    ->  ( exception_rule(flies(X), Cond, Note),
          % Continue the multi-line expression started above.
          call(Cond)
        % If the condition above succeeded, perform the following action.
        ->  Answer = no,
            % Continue the multi-line expression started above.
            Justification = just(exception(Note))
        % Otherwise (else branch), perform the following action.
        ;   Answer = yes,
            % Continue the multi-line expression started above.
            Justification = just(default(bird_flies))
        % Close the expression opened above.
        )
    % Otherwise (else branch), perform the following action.
    ;   Answer = no,
        % Continue the multi-line expression started above.
        Justification = just(not_a_bird)
    % Close the expression opened above.
    ).
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(probabilistic, prob(Prop), answer(Prob, just(weighted_fact(Prop)))) :-
    % State the fact: prob fact(Prop, Prob).
    prob_fact(Prop, Prob).
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(epistemic, believes(Agent, Prop), answer(Value, just(belief(Agent, Prop)))) :-
    % State the fact: believes(Agent, Prop, Value).
    believes(Agent, Prop, Value).

% Track A — transparent reasoning assistant over GO and DO expert ontologies
% Define a clause for 'mentova_query' handling Track A queries.
mentova_query(track_a, TAQuery, answer(Result, Just)) :-
    % Delegate to the Track A module which handles GO, DO, and cross-scope queries.
    once(mentova_track_a(TAQuery, answer(Result, Just), _)).

% Attention schema — query the schema's state and prediction for a given cycle
% Define a clause for 'mentova_query' handling attention schema queries.
mentova_query(attention_schema, report, answer(Report, Just)) :-
    % Retrieve the glass-box schema report.
    schema_report(Report),
    % Justify: schema is a simplified model of workspace dynamics per PR 42.
    Just = just(attention_schema_pr42,
                model_of(workspace_dynamics),
                contents([recent_winners, suppressed_coalitions, habituation, predictions]),
                ctm_correspondence(blum_and_blum_2022),
                dissociation_invariant(disabling_degrades_prediction_not_cycle)).

% Global workspace — broadcast the highest-salience coalition and return the report
% Define a clause for 'mentova_query' handling workspace queries.
mentova_query(workspace, run_cycle(N), answer(Report, Just)) :-
    % Run N workspace cycles, broadcasting the winner of each.
    workspace_run_cycle(N),
    % Build the glass-box workspace report.
    workspace_report(Report),
    % Justify: one broadcast per cycle, learning attached, habituation active.
    Just = just(workspace_cycle, cycles(N),
                broadcast_channel('broadcast://APEX_MIND/cycle'),
                salience_formula(novelty_0_4 + goal_relevance_0_3 + affect_0_2 - habituation),
                learning_attached(sona_absorb_each_broadcast)).

% Game harness — perceive-reason-act over enrolled game bodies
% Define a clause for 'mentova_query' handling game reasoning queries.
mentova_query(game, game_reason(GameId, QueryType), answer(Action, Just)) :-
    % Observe the current game state.
    game_observe(GameId, _Step, Percept),
    % Apply Mentova's reasoning to the percept and produce an action with justification.
    game_reason(GameId, Percept, QueryType, Action, Just).

% Rung 48 — moral: multi-framework ethical reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(moral, MorQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_moral(MorQuery, Result, Just)).
    once(mentova_moral(MorQuery, Result, Just)).

% Rung 47 — legal: rule-exception-precedent reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(legal, LQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_legal(LQuery, Result, Just)).
    once(mentova_legal(LQuery, Result, Just)).

% Rung 46 — informal: fallacy detection and rhetoric analysis
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(informal, InfQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_informal(InfQuery, Result, Just)).
    once(mentova_informal(InfQuery, Result, Just)).

% Rung 45 — motivational: drive and need hierarchy reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(motivational, MotQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_motivational(MotQuery, Result, Just)).
    once(mentova_motivational(MotQuery, Result, Just)).

% Rung 44 — emotional: appraisal-based emotion reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(emotional, EmoQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_emotional(EmoQuery, Result, Just)).
    once(mentova_emotional(EmoQuery, Result, Just)).

% Rung 43 — intuitive: fast prototype-based pattern matching
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(intuitive, IQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_intuitive(IQuery, Result, Just)).
    once(mentova_intuitive(IQuery, Result, Just)).

% Rung 42 — social: roles, relationships, trust, group reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(social, SocQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_social(SocQuery, Result, Just)).
    once(mentova_social(SocQuery, Result, Just)).

% Rung 41 — narrative: story structure and plot reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(narrative, NQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_narrative(NQuery, Result, Just)).
    once(mentova_narrative(NQuery, Result, Just)).

% Rung 40 — strategic: game-theoretic optimal move selection
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(strategic, StQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_strategic(StQuery, Result, Just)).
    once(mentova_strategic(StQuery, Result, Just)).

% Rung 39 — teleological: purpose and final-cause reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(teleological, TQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_teleological(TQuery, Result, Just)).
    once(mentova_teleological(TQuery, Result, Just)).

% Rung 38 — practical: means-ends action selection
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(practical, PQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_practical(PQuery, Result, Just)).
    once(mentova_practical(PQuery, Result, Just)).

% Rung 37 — symbolic: symbol manipulation and algebraic identities
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(symbolic, SQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_symbolic(SQuery, Result, Just)).
    once(mentova_symbolic(SQuery, Result, Just)).

% Rung 36 — procedural: step-by-step plan reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(procedural, ProcQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_procedural(ProcQuery, Result, Just)).
    once(mentova_procedural(ProcQuery, Result, Just)).

% Rung 35 — deontic: obligation/permission/prohibition reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(deontic, DeoQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_deontic(DeoQuery, Result, Just)).
    once(mentova_deontic(DeoQuery, Result, Just)).

% Rung 34 — epistemic: knowledge/belief/ignorance reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(epistemic, EQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_epistemic(EQuery, Result, Just)).
    once(mentova_epistemic(EQuery, Result, Just)).

% Rung 33 — modal: possible/necessary/contingent world reasoning
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(modal, MQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_modal(MQuery, Result, Just)).
    once(mentova_modal(MQuery, Result, Just)).

% Rung 32 — metacognitive: reason about own capabilities
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(metacognitive, MCQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_metacognitive(MCQuery, Result, Just)).
    once(mentova_metacognitive(MCQuery, Result, Just)).

% Rung 31 — dialectical: weigh pro/con arguments
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(dialectical, DQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_dialectical(DQuery, Result, Just)).
    once(mentova_dialectical(DQuery, Result, Just)).

% Rung 30 — critical: evaluate claim support
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(critical, CritQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_critical(CritQuery, Result, Just)).
    once(mentova_critical(CritQuery, Result, Just)).

% Rung 29 — heuristic: good-enough answer within budget
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(heuristic, HeurQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_heuristic(HeurQuery, Result, Just)).
    once(mentova_heuristic(HeurQuery, Result, Just)).

% Rung 28 — model-based: predict from explicit model
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(model_based, ModelQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_model(ModelQuery, Result, Just)).
    once(mentova_model(ModelQuery, Result, Just)).

% Rung 27 — system: reason about parts and interactions
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(system, SysQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_system(SysQuery, Result, Just)).
    once(mentova_system(SysQuery, Result, Just)).

% Rung 26 — scientific: form, test, and score a hypothesis
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(scientific, SciQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_scientific(SciQuery, Result, Just)).
    once(mentova_scientific(SciQuery, Result, Just)).

% Rung 25 — constraint-based: solve a constraint puzzle
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(constraint, ConstraintQuery, answer(Result, Just)) :-
    % State the fact: mentova constraint(ConstraintQuery, Result, Just).
    mentova_constraint(ConstraintQuery, Result, Just).

% Rung 24 — case-based: solve by adapting similar past case
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(case_based, CBRQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_cbr(CBRQuery, Result, Just)).
    once(mentova_cbr(CBRQuery, Result, Just)).

% Rung 23 — temporal: ordering and duration questions
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(temporal, TempQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_temporal(TempQuery, Result, Just)).
    once(mentova_temporal(TempQuery, Result, Just)).

% Rung 22 — diagrammatic: read a small grid or layout
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(diagrammatic, DiagQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_diagrammatic(DiagQuery, Result, Just)).
    once(mentova_diagrammatic(DiagQuery, Result, Just)).

% Rung 21 — spatial: containment and position with reference frames
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(spatial, SpatialQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_spatial(SpatialQuery, Result, Just)).
    once(mentova_spatial(SpatialQuery, Result, Just)).

% Rung 20 — hypothetical: explore supposition without asserting it
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(hypothetical, HypQuery, answer(Result, Just)) :-
    % State the fact: mentova hypothetical(HypQuery, Result, Just).
    mentova_hypothetical(HypQuery, Result, Just).

% Rung 19 — counterfactual: what if this were different
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(counterfactual, CFQuery, answer(Result, Just)) :-
    % State the fact: mentova counterfactual(CFQuery, Result, Just).
    mentova_counterfactual(CFQuery, Result, Just).

% Rung 18 — paraconsistent: reason despite contradiction
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(paraconsistent, ParaQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_paraconsistent(ParaQuery, Result, Just)).
    once(mentova_paraconsistent(ParaQuery, Result, Just)).

% Rung 17 — non-monotonic: defeasible default retraction
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(nonmonotonic, NMQuery, answer(Result, Just)) :-
    % State the fact: mentova defeasible(NMQuery, Result, Just).
    mentova_defeasible(NMQuery, Result, Just).

% Rung 16 — qualitative: predict direction of change
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(qualitative, QualQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_qualitative(QualQuery, Result, Just)).
    once(mentova_qualitative(QualQuery, Result, Just)).

% Rung 15 — fuzzy: graded membership / degree of truth
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(fuzzy, FuzzyQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_fuzzy(FuzzyQuery, Result, Just)).
    once(mentova_fuzzy(FuzzyQuery, Result, Just)).

% Rung 14 — mathematical: compute quantitative answer
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(mathematical, MathQuery, answer(Result, Just)) :-
    % State the fact: mentova math(MathQuery, Result, Just).
    mentova_math(MathQuery, Result, Just).

% Rung 13 — formal: check derivation against Minimal PrologAI Kernel
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(formal, FormalQuery, answer(Result, Just)) :-
    % State the fact: mentova formal(FormalQuery, Result, Just).
    mentova_formal(FormalQuery, Result, Just).

% Rung 12 — logical: forward-chaining rule engine
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(logical, LogQuery, answer(Result, Just)) :-
    % State the fact: mentova logical(LogQuery, Result, Just).
    mentova_logical(LogQuery, Result, Just).

% Rung 11 — commonsense: answer everyday-knowledge question with provenance
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(commonsense, CSQuery, answer(Ans, Just)) :-
    % State the fact: once(mentova_commonsense(CSQuery, Ans, Just)).
    once(mentova_commonsense(CSQuery, Ans, Just)).

% Rung 10 — transductive: classify by nearest known cases (kNN)
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(transductive, TransQuery, answer(Label, Just)) :-
    % State the fact: mentova transduce(TransQuery, Label, Just).
    mentova_transduce(TransQuery, Label, Just).

% Rung 9 — relational: multi-hop relational query
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(relational, RelQuery, answer(Result, Just)) :-
    % State the fact: once(mentova_relational(RelQuery, Result, Just)).
    once(mentova_relational(RelQuery, Result, Just)).

% Rung 8 — analogical: complete A:B :: C:? by structure mapping
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(analogical, AnalogyQuery, answer(D, Just)) :-
    % State the fact: once(mentova_analogy(AnalogyQuery, D, Just)).
    once(mentova_analogy(AnalogyQuery, D, Just)).

% Rung 7 — statistical: find pattern in observation table
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(statistical, StatQuery, answer(Result, Just)) :-
    % State the fact: mentova stat(StatQuery, Result, Just).
    mentova_stat(StatQuery, Result, Just).

% Rung 6 — causal: predict effect of intervention vs observation
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(causal, CausalQuery, answer(Result, Just)) :-
    % State the fact: mentova causal(CausalQuery, Result, Just).
    mentova_causal(CausalQuery, Result, Just).

% Rung 5 — bayesian: update belief on new evidence
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(bayesian, update(H, E), answer(Posterior, Just)) :-
    % State the fact: mentova bayes(H, E, Posterior, Just).
    mentova_bayes(H, E, Posterior, Just).

% Rung 4 — probabilistic: compute query likelihood
% Define a clause for 'mentova query': succeed when the following conditions hold.
mentova_query(probabilistic, ProbQuery, answer(P, Just)) :-
    % State the fact: mentova prob(ProbQuery, P, Just).
    mentova_prob(ProbQuery, P, Just).

% Rung 3 — abductive: best explanation for an observation
% State a fact for 'mentova query' with the arguments listed below.
mentova_query(abductive, explain(Obs),
              % Continue the multi-line expression started above.
              answer(Best, just(abduction(Obs), all_explanations(All)))) :-
    % State the fact: mentova abduce(Obs, Best, _Score, All).
    mentova_abduce(Obs, Best, _Score, All).

% Rung 2 — inductive: induce a rule from examples, verify on held-out cases
% State a fact for 'mentova query' with the arguments listed below.
mentova_query(inductive, induce(Pos, Neg, BG, HeldOut),
              % Continue the multi-line expression started above.
              answer(rule(Rule), just(induced(Rule), verified(HeldOut, Results)))) :-
    % State a fact for 'mentova induce' with the arguments listed below.
    mentova_induce(Pos, Neg, BG, Rule),
    % Check that 'Rule' is unifiable with '(Head :- Body)'.
    Rule = (Head :- Body),
    % State a fact for 'maplist' with the arguments listed below.
    maplist([Ex, Ex-Verdict]>>(
        % Continue the multi-line expression started above.
        copy_term(Head-Body, Ex-BodyInst),
        % Continue the multi-line expression started above.
        ( call(BodyInst) -> Verdict = pass ; Verdict = fail )
    % Continue the multi-line expression started above.
    ), HeldOut, Results).

% is_a_chain(+X, +Class, -Chain): find transitive IsA chain
% Define a clause for 'is a chain': succeed when the following conditions hold.
is_a_chain(X, Class, [X, Class]) :-
    % State the fact: is a(X, Class).
    is_a(X, Class).
% Define a clause for 'is a chain': succeed when the following conditions hold.
is_a_chain(X, Class, [X | Rest]) :-
    % State a fact for 'is a' with the arguments listed below.
    is_a(X, Mid),
    % State the fact: is a chain(Mid, Class, Rest).
    is_a_chain(Mid, Class, Rest).
