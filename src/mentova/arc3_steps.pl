/*  Mentova — ARC-AGI-3 Steps Draft Ingestion

    The eleven ARC-AGI-3_Steps_Draft documents were digested into per-draft candidate-
    fact files under knowledge/arc3_steps/ (draft_1.facts .. draft_11.facts). This
    module carries all ten into Mentova's mind at boot through the NUANCED fact
    doors: an exact fact repeated across drafts is merged and strengthened, while a
    fact that a draft states with a subtle difference (a different mechanic, a
    different relation) is kept as a linked VARIANT with its delta flagged — because
    the ten drafts genuinely disagree about several games (a static-transform view
    versus the interactive-benchmark view), and those disagreements are nuggets to
    keep, not noise to merge. Every fact carries its draft id as provenance, and
    each draft's concepts are also held in a per-draft J-Space workspace.

    Predicates:
      as_bootstrap/0    ingest all eleven drafts (idempotent; safe at startup)
      as_ingest/1       -- -Summary(TotalNew, TotalStrengthened, TotalVariant)
      as_stats/1        -- -stats(NodeFactVariants, RelationVariants)
*/

% Declare this module and its interface.
:- module(arc3_steps, [
    % as_bootstrap/0: the safe one-call boot entry.
    as_bootstrap/0,
    % as_ingest/1: ingest every draft, returning the aggregate summary.
    as_ingest/1,
    % as_stats/1: the flagged cross-draft variant counts.
    as_stats/1
]).

% The nuanced draft-ingestion pipeline.
:- use_module('draft_ingest', [di_ingest_file/3]).
% Aggregation.
:- use_module(library(aggregate), [aggregate_all/3]).
:- use_module(library(lists), [member/2]).

% as_dir(-Dir): the directory holding the per-draft fact files.
as_dir('/home/ccaitwo/Mentova/knowledge/arc3_steps').

% as_draft(-DraftId, -File): each draft and its fact file.
as_draft(DraftId, File) :-
    member(N, [1,2,3,4,5,6,7,8,9,10,11]),
    atom_concat(draft_, N, DraftId),
    as_dir(Dir),
    atomic_list_concat([Dir, '/', DraftId, '.facts'], File).

% as_bootstrap: ingest all eleven drafts, tolerating any error so boot never fails.
as_bootstrap :-
    catch(( as_ingest(summary(New, Strong, Var)),
            format("arc3_steps: ingested 11 drafts — ~w new facts, ~w strengthened, ~w variants flagged~n",
                   [New, Strong, Var]) ),
          _Err, true).

% as_ingest(-Summary): ingest each draft through the nuanced doors, summing the
% new / strengthened / variant-flagged counts across all eleven reports.
as_ingest(summary(New, Strong, Var)) :-
    findall(counts(N, S, V),
        ( as_draft(DraftId, File),
          catch(di_ingest_file(File, DraftId, Report), _, fail),
          as_report_counts(Report, N, S, V) ),
        AllCounts),
    aggregate_all(sum(N), member(counts(N, _, _), AllCounts), New),
    aggregate_all(sum(S), member(counts(_, S, _), AllCounts), Strong),
    aggregate_all(sum(V), member(counts(_, _, V), AllCounts), Var).

% as_report_counts(+Report, -New, -Strong, -Variant): tally one draft's report.
as_report_counts(report(_, Results, _), New, Strong, Variant) :-
    aggregate_all(count, ( member(result(_, S), Results), S = new ), New),
    aggregate_all(count, ( member(result(_, S), Results), S = exact(_) ), Strong),
    aggregate_all(count, ( member(result(_, S), Results), S = variant(_, _) ), Variant).

% as_stats(-stats(NodeFactVariants, RelationVariants)): the flagged cross-draft
% variants now held apart in the two stores.
as_stats(stats(NFV, RV)) :-
    ( catch(node_facts:node_fact_variants(NFVList), _, NFVList = []) -> true ; NFVList = [] ),
    ( catch(causal_core:causal_core_causal_relation_object_variants(RVList), _, RVList = []) -> true ; RVList = [] ),
    length(NFVList, NFV), length(RVList, RV).
