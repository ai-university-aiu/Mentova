/*  Mentova — ARC-AGI-3 Steps Draft Ingestion Test Suite

    Exercises the three exported predicates of the arc3_steps module, which
    carries the eleven ARC-AGI-3_Steps_Draft fact files into Mentova's mind
    through the NUANCED fact doors: an exact fact repeated across drafts is
    merged and strengthened, while a subtly different one is kept as a linked
    variant with its delta flagged.

    Behavioural claims verified here:
      - as_ingest/1 on a fresh verb layer creates genuinely new facts, and a
        candidate-fact count that is conserved across a second pass.
      - a second ingest of the same drafts creates nothing new and strengthens
        every previously-seen fact (the nuanced merge door in action).
      - as_stats/1 reports at least one flagged cross-draft variant, because the
        eleven drafts genuinely disagree about several games.
      - as_bootstrap/0 is a safe, idempotent boot entry that actually performs
        the ingest (a re-ingest after it reports nothing new).

    The stores the pipeline drives (lattice, node_facts, causal_core) are called
    module-qualified inside draft_ingest and are NOT use_module'd there, so this
    suite loads them, exactly as the Mentova demos load the stores they touch.

    Run with the full library path:
        swipl $LIB -p library=.../Mentova/src/mentova -g "run_tests, halt" -t "halt(1)" test/test_arc3_steps.pl
*/

%% Declare this file as a test module with no exports.
:- module(test_arc3_steps, []).

%% Load the PLUnit test framework.
:- use_module(library(plunit)).

%% Load the module under test.
:- use_module(library(arc3_steps)).
%% Load the lattice so draft_ingest's nexus door resolves.
:- use_module(library(lattice)).
%% Load the node-fact store so the anchor door resolves and its variants can be counted.
:- use_module(library(node_facts)).
%% Load the causal core for the reset and so the relation door resolves.
:- use_module(library(causal_core)).

%% Open the arc3_steps test block.
:- begin_tests(arc3_steps).

%% A fresh ingest creates new facts, and the candidate-fact count is conserved on a second pass.
test(ingest_creates_facts_and_conserves_total) :-
    %% Give the verb layer a clean slate so newly-asserted relations are genuinely new.
    causal_core_reset,
    %% Ingest all eleven drafts for the first time.
    as_ingest(summary(New1, Strong1, Var1)),
    %% The three tallies are integers.
    assertion(integer(New1)),
    %% The strengthened count is an integer.
    assertion(integer(Strong1)),
    %% The variant count is an integer.
    assertion(integer(Var1)),
    %% A fresh verb layer means real new facts are created.
    assertion(New1 > 0),
    %% The total candidate facts recognised on the first pass.
    Total1 is New1 + Strong1 + Var1,
    %% That total is positive — the drafts are not empty.
    assertion(Total1 > 0),
    %% Ingest the same eleven drafts a second time.
    as_ingest(summary(New2, Strong2, Var2)),
    %% Nothing is new the second time round.
    assertion(New2 =:= 0),
    %% Every previously-seen fact is re-recognised and strengthened.
    assertion(Strong2 > 0),
    %% The total candidate facts recognised on the second pass.
    Total2 is New2 + Strong2 + Var2,
    %% The candidate-fact count is conserved across the two passes.
    assertion(Total1 =:= Total2).

%% After ingesting the eleven drafts, at least one cross-draft variant is flagged apart.
test(stats_reports_flagged_variants) :-
    %% Ensure every draft has been ingested (idempotent, self-opening boot entry).
    as_bootstrap,
    %% Read the flagged cross-draft variant counts.
    as_stats(stats(NodeFactVariants, RelationVariants)),
    %% The node-fact variant count is an integer.
    assertion(integer(NodeFactVariants)),
    %% The relation variant count is an integer.
    assertion(integer(RelationVariants)),
    %% Neither count is negative.
    assertion(NodeFactVariants >= 0),
    %% Neither count is negative.
    assertion(RelationVariants >= 0),
    %% The total number of flagged variants across the two stores.
    TotalVariants is NodeFactVariants + RelationVariants,
    %% The eleven drafts genuinely disagree, so at least one variant is kept, not merged away.
    assertion(TotalVariants >= 1).

%% The boot entry succeeds, is safe to call twice, and truly performs the ingest.
test(bootstrap_is_idempotent_and_ingests) :-
    %% The one-call boot entry succeeds.
    assertion(as_bootstrap),
    %% And it is safe to call again (idempotent; safe at startup).
    assertion(as_bootstrap),
    %% After bootstrap, a further ingest of the same drafts finds nothing new.
    as_ingest(summary(New, Strong, _Var)),
    %% Bootstrap already ingested everything, so no fact is new.
    assertion(New =:= 0),
    %% But every fact is re-recognised and strengthened, proving bootstrap did ingest.
    assertion(Strong > 0).

%% Close the arc3_steps test block.
:- end_tests(arc3_steps).
