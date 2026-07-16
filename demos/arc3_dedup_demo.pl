/*  Mentova — Fact-Existence / No-Duplicate-Facts Demonstration

    Proves the Mentova stores are not cluttered with duplicate facts: re-ingesting
    the ARC-AGI-3 game knowledge a second time adds nothing (the assert-if-new
    doors reuse the existing facts), and the boot dedup sweep finds a clean store.

    It also proves the nuance: a subtle-difference draft of a fact is NOT merged —
    it is kept as a flagged variant with its delta surfaced for attention.

    Acceptance criteria (each prints PASS or FAIL):
      AC-DUP-001: the first ingest anchors node-facts and relations.
      AC-DUP-002: a SECOND ingest adds no new node-facts (idempotent).
      AC-DUP-003: a SECOND ingest adds no new arc3 relations (idempotent).
      AC-DUP-004: the dedup sweep finds nothing to remove on the clean store.
      AC-DUP-005: the raw doors still make EXACT duplicates, and dedup removes them.
      AC-DUP-006: two drafts differing only in citation are BOTH kept (not merged).
      AC-DUP-007: the drafts are linked as variants with the delta surfaced.
      AC-DUP-008: a near-duplicate relation is kept as a flagged variant too.

    Run:
        swipl -l demos/arc3_dedup_demo.pl -g run_dedup_demo -t halt
*/

% Load the full stack (opens the lattice/nexus the ingest anchors into).
:- use_module('../src/mentova/mentova_chat').
:- use_module('../src/mentova/arc3_knowledge').
% The stores under test.
:- use_module(library(node_facts)).
:- use_module(library(causal_core)).
:- use_module(library(aggregate), [aggregate_all/3]).

% report(+Id, +Goal): print PASS or FAIL for one criterion.
report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> V = 'PASS' ; V = 'FAIL' ),
    format("~w: ~w~n", [Id, V]).

% nf_count(-N): total lattice node-facts.
nf_count(N) :- aggregate_all(count, node_facts:lattice_node_fact(_,_,_,_,_), N).
% arc_cro_count(-N): arc3-sourced relations.
arc_cro_count(N) :- aggregate_all(count, causal_core:causal_core_causal_relation_object_(_,_,_,_,_,_,_,prov(arc3_guide,_,_)), N).

% run_dedup_demo: ingest, re-ingest, and check nothing duplicated.
run_dedup_demo :-
    format("~n=== Fact Existence / No Duplicate Facts ===~n~n", []),
    % First ingest.
    ( catch(a3_ingest, _, true) -> true ; true ),
    nf_count(NF1), arc_cro_count(CR1),

    % AC-001: the first ingest anchored facts and relations.
    report('AC-DUP-001', ( NF1 > 0, CR1 > 0 )),

    % Second ingest (should be idempotent via the assert-if-new doors).
    ( catch(a3_ingest, _, true) -> true ; true ),
    nf_count(NF2), arc_cro_count(CR2),

    % AC-002: no new node-facts after the second ingest.
    report('AC-DUP-002', ( NF2 =:= NF1 )),

    % AC-003: no new arc3 relations after the second ingest.
    report('AC-DUP-003', ( CR2 =:= CR1 )),

    % AC-004: the dedup sweep finds nothing to remove on the clean store.
    report('AC-DUP-004',
        ( node_facts:node_facts_dedup(DF), causal_core:causal_core_causal_relation_object_dedup(DC),
          DF =:= 0, DC =:= 0 )),

    % AC-005: the RAW doors still make EXACT duplicates, and dedup removes them.
    report('AC-DUP-005',
        ( node_facts:anchor_node(dup_test, [a, b], [], _),
          node_facts:anchor_node(dup_test, [a, b], [], _),
          node_facts:node_facts_dedup(DF2), DF2 >= 1 )),

    % --- the nuance: a subtle-difference draft is kept as a flagged variant ---

    % AC-006: two drafts of the SAME node-fact that differ only in their citation
    % are BOTH kept (the subtle difference is not merged away).
    report('AC-DUP-006',
        ( node_facts:anchor_node_unique(draft_fact, [ls20, ring, refills, timer],
              [source(draft_a)], DIdA),
          node_facts:anchor_node_unique(draft_fact, [ls20, ring, refills, timer],
              [source(draft_b)], DIdB),
          DIdA \== DIdB )),

    % AC-007: the two drafts are linked as variants with the delta surfaced (which
    % citation differs) — the nugget flagged for attention, not dropped or merged.
    report('AC-DUP-007',
        ( node_facts:node_fact_variant(_, _, Deltas),
          member(added(source(draft_b)), Deltas) )),

    % AC-008: a near-duplicate RELATION (same cause->effect, different provenance)
    % is likewise kept as a flagged variant, not merged.
    report('AC-DUP-008',
        ( causal_core:causal_core_new_causal_relation_object_unique([g(demo, step_on(ring))], [refill(timer)],
              temporal(0,0,instant), sufficient, 0.8, [], prov(draft_a, cite_a, 0.8), RA),
          causal_core:causal_core_new_causal_relation_object_unique([g(demo, step_on(ring))], [refill(timer)],
              temporal(0,0,instant), sufficient, 0.8, [], prov(draft_b, cite_b, 0.8), RB),
          RA \== RB,
          causal_core:causal_core_causal_relation_object_variant(_, _, RDeltas), member(delta(prov, _, _), RDeltas) )),

    format("~nnode-facts: ~w (unchanged after re-ingest ~w)  arc3 relations: ~w -> ~w~n",
           [NF1, NF2, CR1, CR2]),
    ( node_facts:node_fact_variants(FV) -> length(FV, FVn) ; FVn = 0 ),
    ( causal_core:causal_core_causal_relation_object_variants(RV) -> length(RV, RVn) ; RVn = 0 ),
    format("flagged variants: ~w node-facts, ~w relations~n~n", [FVn, RVn]).
