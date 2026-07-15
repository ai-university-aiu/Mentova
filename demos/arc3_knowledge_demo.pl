/*  Mentova — ARC-AGI-3 Game Knowledge Transfer Demonstration

    Proves the "heavy pass": the 25 ARC-AGI-3 mentor guides, distilled into
    knowledge/arc3_games.pl, are transferred into Mentova's mind across the
    full stack — the lattice (node-facts with citations), the Causalontology
    (game-keyed cause-effect relations, and thus the causal predictor both
    Guided and Solo use), and the J-Space workspace.

    Acceptance criteria (each prints PASS or FAIL):
      AC-KT-001: all 25 games are known.
      AC-KT-002: many cause-effect relations were transferred.
      AC-KT-003: Mentova knows ls20 rings refill the step timer.
      AC-KT-004: the knowledge is game-keyed — vc33 does NOT know rings.
      AC-KT-005: the ls20 ring relation is a Causalontology CRO cited to its guide.
      AC-KT-006: the relation reached the causal predictor (causal_core_predict).
      AC-KT-007: recall answers "what does Mentova know about ls20 rings?".
      AC-KT-008: the facts are anchored as lattice node-facts with citations.
      AC-KT-009: the J-Space workspace holds the game concepts.

    Run:
        swipl -l demos/arc3_knowledge_demo.pl -g run_arc3_knowledge_demo -t halt
*/

% Load the full chat stack (packs, lattice, Causalontology, J-Space, arc3).
:- use_module('../src/mentova/mentova_chat').
% The knowledge module under test.
:- use_module('../src/mentova/arc3_knowledge').

% report(+Id, +Cond): print PASS or FAIL for one criterion.
report(Id, Cond) :-
    ( call(Cond) -> V = 'PASS' ; V = 'FAIL' ),
    format("~w: ~w~n", [Id, V]).

% Define run_arc3_knowledge_demo: transfer the knowledge and check it landed.
run_arc3_knowledge_demo :-
    % Announce.
    format("~n=== ARC-AGI-3 Game Knowledge Transfer ===~n~n", []),
    % Perform the transfer (idempotent).
    ( catch(a3_ingest, _, true) -> true ; true ),

    % AC-001: all 25 games are known.
    report('AC-KT-001', ( a3_stats(stats(Games, _, _, _)), Games =:= 25 )),

    % AC-002: many cause-effect relations were transferred.
    report('AC-KT-002', ( a3_stats(stats(_, _, Rels, _)), Rels >= 60 )),

    % AC-003: Mentova knows ls20 rings refill the step timer.
    report('AC-KT-003', a3_knows(ls20, step_on(ring), refill(timer))),

    % AC-004: game-keyed — vc33 does NOT know rings.
    report('AC-KT-004', \+ a3_knows(vc33, step_on(ring), _)),

    % AC-005: the ls20 ring relation is a Causalontology CRO cited to its guide.
    report('AC-KT-005',
        ( causal_core:causal_core_cro(_, [g(ls20, step_on(ring))], [refill(timer)],
                         _, _, _, _, prov(arc3_guide, source(arc3_guide, 'assets/ls20.txt'), _)) )),

    % AC-006: the relation reached the causal predictor (used by the solver).
    report('AC-KT-006',
        ( causal_core:causal_core_predict(g(ls20, step_on(ring)), refill(timer)) )),

    % AC-007: recall answers "what does Mentova know about ls20 rings?".
    report('AC-KT-007',
        ( a3_recall(ls20, ring, Items), Items \== [] )),

    % AC-008: the facts are anchored as lattice node-facts WITH citations.
    report('AC-KT-008',
        ( node_facts:lattice_node_fact(_, _, arc3_object, [ls20, ring, _],
              Referents),
          memberchk(source(arc3_guide, _), Referents) )),

    % AC-009: the J-Space workspace holds the game concepts.
    report('AC-KT-009',
        ( catch(jacobian_space:jacobian_space_reading(arc3_mind, R), _, fail), R \== [] )),

    % Show a sample of what Mentova now knows about ls20 rings.
    ( a3_recall(ls20, ring, Sample) -> true ; Sample = [] ),
    format("~nMentova knows about ls20 rings: ~q~n~n", [Sample]).
