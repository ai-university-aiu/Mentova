/*  Mentova — History-of-Puzzle-Games Reference Ingestion

    Two golden reference documents about the history of puzzle video games live in
    the golden store beside the twenty-five per-game guides:
        /home/ccaitwo/ARC-AGI-3/History_Outline.txt   (draft id history_outline)
        /home/ccaitwo/ARC-AGI-3/History_Book.txt       (draft id history_book)
    They give Mentova the human lineage of the medium it is being tested on — the
    small family of mechanics (sliding, matching, packing, pushing, deducing,
    constructing, rule-rewriting) that every ARC-AGI-3 game is a fresh combination
    of. This module carries both documents into the mind at boot through the same
    NUANCED fact doors the ten Steps drafts use: each document's machine-readable
    appendix contributes structured facts to the Causalontology lattice, its prose is
    reported (never silently dropped), and each document's concepts are also held in a
    per-draft J-Space workspace. Ingestion is idempotent — an exact fact repeated on a
    later boot is strengthened, not duplicated — so this is safe to run at every start.

    Predicates:
      hr_bootstrap/0    ingest both history references (guarded; safe at startup)
      hr_ingest/1       -- -Summary(TotalNew, TotalStrengthened, TotalVariant)
*/

% Declare this module and its interface.
:- module(history_refs, [
    % hr_bootstrap/0: the safe one-call boot entry.
    hr_bootstrap/0,
    % hr_ingest/1: ingest both references, returning the aggregate summary.
    hr_ingest/1
]).

% The nuanced draft-ingestion pipeline (same door the Steps drafts use).
:- use_module('draft_ingest', [di_ingest_file/3]).
% Aggregation and list helpers.
:- use_module(library(aggregate), [aggregate_all/3]).
:- use_module(library(lists), [member/2]).

% hr_ref(-DraftId, -File): each history reference document and its golden-store path.
hr_ref(history_outline, '/home/ccaitwo/ARC-AGI-3/History_Outline.txt').
% The full narrative book carries the same draft id it was ingested under.
hr_ref(history_book, '/home/ccaitwo/ARC-AGI-3/History_Book.txt').

% hr_bootstrap: ingest both history references, tolerating any error so boot never fails.
hr_bootstrap :-
    % Run the ingest and print a one-line summary, swallowing any error.
    catch(( hr_ingest(summary(New, Strong, Var)),
            format("history_refs: ingested 2 history references — ~w new facts, ~w strengthened, ~w variants flagged~n",
                   [New, Strong, Var]) ),
          _Err, true).

% hr_ingest(-Summary): ingest each reference through the nuanced doors, summing the
% new / strengthened / variant-flagged counts across both reports. A missing file is
% tolerated (its report contributes nothing) so a moved golden store never blocks boot.
hr_ingest(summary(New, Strong, Var)) :-
    % Collect the per-reference counts, skipping any file that fails to ingest.
    findall(counts(N, S, V),
        ( hr_ref(DraftId, File),
          catch(di_ingest_file(File, DraftId, Report), _, fail),
          hr_report_counts(Report, N, S, V) ),
        AllCounts),
    % Sum the new facts across both references.
    aggregate_all(sum(N), member(counts(N, _, _), AllCounts), New),
    % Sum the strengthened (exact-repeat) facts.
    aggregate_all(sum(S), member(counts(_, S, _), AllCounts), Strong),
    % Sum the near-duplicate variants flagged for attention.
    aggregate_all(sum(V), member(counts(_, _, V), AllCounts), Var).

% hr_report_counts(+Report, -New, -Strong, -Variant): tally one reference's report.
hr_report_counts(report(_, Results, _), New, Strong, Variant) :-
    % Count the brand-new facts this reference introduced.
    aggregate_all(count, ( member(result(_, S), Results), S = new ), New),
    % Count the facts that exactly repeated an existing one (strengthened).
    aggregate_all(count, ( member(result(_, S), Results), S = exact(_) ), Strong),
    % Count the near-duplicate variants kept apart with their delta flagged.
    aggregate_all(count, ( member(result(_, S), Results), S = variant(_, _) ), Variant).
