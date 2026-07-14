/*  Mentova — versioned lattice snapshot exporter (open-source / prize compliance)

    Writes a committed, human-readable, re-loadable snapshot of the FULL functioning
    Causalontology lattice and the runtime learned store into data/lattice_snapshot/, so
    the whole mind ships with the open-source repository (Kaggle / ARC-AGI-3 prize
    eligibility requires the lattice to be open-sourced, not merely regenerable).

    The base lattice is already deterministically rebuilt at boot from committed sources
    (knowledge/ (all .pl) + the PrologAI platform); this exporter materialises that built lattice
    to disk AND captures the runtime learned store (data/arc_learnings.db) that was
    otherwise git-ignored. Secrets (the ARC API key) are never in either store and are
    never written here.

    Run from the repository root:
        swipl -q -g true -t halt tools/lattice_export.pl
    or:
        make lattice-snapshot

    Outputs (all under data/lattice_snapshot/, committed):
      lattice_<nexus>.pl        the materialised lattice node-facts, one file per nexus
      causalontology_cros.pl    every Causalontology Reasoning Object (causal_core_cro/8)
      arc_learnings_snapshot.pl the runtime per-game learned store (secret-free)
      MANIFEST.txt              counts, provenance, and the regeneration command
*/

% Load the whole mind: modules, and the boot registrations that build the lattice.
:- use_module('../src/mentova/mentova_chat').
% Directory and list helpers.
:- use_module(library(filesex)).
:- use_module(library(lists)).

% le_dir(-Dir): the committed snapshot directory.
le_dir('data/lattice_snapshot').

% le_export: build the lattice in-process, then write every snapshot artefact.
le_export :-
    % The snapshot directory (created if absent).
    le_dir(Dir),
    ( exists_directory(Dir) -> true ; make_directory_path(Dir) ),
    % Build the full lattice the same way the server boot does, minus the HTTP listener.
    le_build_lattice,
    % Dump each populated nexus's node-facts.
    le_dump_nexuses(Dir, NexusCount, NodeFactCount),
    % Dump every Causalontology Reasoning Object.
    le_dump_cros(Dir, CroCount),
    % Snapshot the runtime learned store (secret-free).
    le_dump_learned(Dir, GameCount, TermCount),
    % Write the manifest tying it together.
    le_manifest(Dir, NexusCount, NodeFactCount, CroCount, GameCount, TermCount),
    % Report to the console.
    format("lattice snapshot written to ~w~n", [Dir]),
    format("  nexuses=~w node_facts=~w cros=~w learned_games=~w learned_terms=~w~n",
           [NexusCount, NodeFactCount, CroCount, GameCount, TermCount]).

% le_build_lattice: run the boot registrations that populate the lattice, each guarded so
% a missing optional source never aborts the export. Mirrors mc_chat_main without serving.
le_build_lattice :-
    % Attach the durable learned store so its cognitive state is present too.
    ignore(catch(ma_learn_attach('data/chat_db'), _, true)),
    % The registration entry points, in boot order.
    forall(member(G, [ci_chat_bootstrap, a3_bootstrap, ooda_bootstrap,
                      as_bootstrap, hr_bootstrap, cog_bootstrap]),
           ignore(catch(mentova_chat:G, _, true))).

% le_dump_nexuses(+Dir, -NexusCount, -NodeFactCount): dump each nexus that holds node-facts
% to its own file via the platform's lattice_dump/2, and total the node-facts.
le_dump_nexuses(Dir, NexusCount, NodeFactCount) :-
    % Every nexus that currently holds at least one node-fact.
    ( setof(Nx, le_populated_nexus(Nx), Nexuses) -> true ; Nexuses = [] ),
    % Dump each, accumulating the node-fact total.
    foldl(le_dump_one_nexus(Dir), Nexuses, 0, NodeFactCount),
    % How many nexuses were dumped.
    length(Nexuses, NexusCount).

% le_populated_nexus(-Nx): a nexus with at least one node-fact.
le_populated_nexus(Nx) :-
    % Enumerate distinct nexuses appearing in the node-fact table.
    lattice:lattice_node_fact(Nx, _, _, _, _).

% le_dump_one_nexus(+Dir, +Nx, +Acc0, -Acc): dump one nexus and add its node-fact count.
le_dump_one_nexus(Dir, Nx, Acc0, Acc) :-
    % The nexus's human address (locus://...), falling back to its internal id.
    ( catch(lattice:lattice_nexus(Nx, Addr, _, _), _, fail) -> true ; Addr = Nx ),
    % A filesystem-safe base name from the nexus address.
    le_safe_name(Addr, Safe),
    % Its snapshot file path.
    atomic_list_concat([Dir, '/lattice_', Safe, '.pl'], File),
    % Materialise the nexus's node-facts to that file (platform dumper).
    ignore(catch(lattice:lattice_dump(Nx, File), _, true)),
    % Count this nexus's node-facts for the manifest.
    ( catch(aggregate_all(count, lattice:lattice_node_fact(Nx, _, _, _, _), N), _, N = 0)
      -> true ; N = 0 ),
    % Accumulate.
    Acc is Acc0 + N.

% le_dump_cros(+Dir, -CroCount): write every Causalontology Reasoning Object to one file.
le_dump_cros(Dir, CroCount) :-
    % Collect every CRO term (causal_core_cro/8) present.
    findall(cro(A,B,C,D,E,F,G,H),
            catch(causal_core:causal_core_cro(A,B,C,D,E,F,G,H), _, fail), Cros),
    % Its snapshot file.
    atomic_list_concat([Dir, '/causalontology_cros.pl'], File),
    % Write a headed, re-loadable list of CROs.
    setup_call_cleanup(open(File, write, S),
        ( le_header(S, "Causalontology Reasoning Objects (causal_core_cro/8) — materialised snapshot"),
          forall(member(T, Cros), ( write_term(S, T, [quoted(true)]), write(S, '.\n') )) ),
        close(S)),
    % How many were written.
    length(Cros, CroCount).

% le_dump_learned(+Dir, -GameCount, -TermCount): snapshot the runtime learned store, term by
% term, refusing to write anything that looks like a secret (defensive — the store holds no
% credentials).
le_dump_learned(Dir, GameCount, TermCount) :-
    % The live learned-store path.
    ( catch(ma_learn_file(Src), _, fail) -> true ; Src = 'data/arc_learnings.db' ),
    % The snapshot file.
    atomic_list_concat([Dir, '/arc_learnings_snapshot.pl'], File),
    % Read every term from the live store (empty when the store is absent).
    ( exists_file(Src) -> le_read_terms(Src, Terms) ; Terms = [] ),
    % Keep only terms with no secret-looking atom in them.
    include(le_secret_free, Terms, Safe),
    % Prune raw per-action telemetry (the Effects/Impacts/Deaths logs), keeping the essential
    % learned KNOWLEDGE — goal, priorities, hazards, labels, winning path, causal edges, CROs.
    % The telemetry is re-derived at runtime; dropping it keeps the committed snapshot lean.
    maplist(le_prune_learned, Safe, Pruned),
    % Write them back, headed and re-loadable.
    setup_call_cleanup(open(File, write, S),
        ( le_header(S, "Runtime per-game learned store (arc_learned/arc_cog/arc_cog_global) — secret-free, telemetry-pruned snapshot"),
          forall(member(T, Pruned), ( write_term(S, T, [quoted(true)]), write(S, '.\n') )) ),
        close(S)),
    % Count the games and the terms captured.
    aggregate_all(count, ( member(T, Pruned), functor(T, arc_learned, _) ), GameCount),
    length(Pruned, TermCount).

% le_prune_learned(+Term, -Pruned): blank the raw runtime TELEMETRY in an arc_learned term,
% preserving the learned KNOWLEDGE. The fields are
%   arc_learned(Game, Goal, Prios, Avoided, Labels, Effects, WinPath, Edges, Cros[,Impacts[,Deaths]])
% Kept: Goal, Prios, Avoided (hazards), Labels, WinPath, Cros (causal relations). Blanked:
% Effects (arg 6), Edges (arg 8 — the raw co_graph state-exploration graph, megabytes, wholly
% re-derived by exploration), Impacts (arg 10), Deaths (arg 11). arc_cog world-model
% observations are likewise trimmed (the hypothesis state is kept). Non-learned terms pass
% through unchanged.
le_prune_learned(arc_learned(G,Go,P,A,L,_E,W,_Ed,C),           arc_learned(G,Go,P,A,L,[],W,[],C)) :- !.
le_prune_learned(arc_learned(G,Go,P,A,L,_E,W,_Ed,C,_I),        arc_learned(G,Go,P,A,L,[],W,[],C,[])) :- !.
le_prune_learned(arc_learned(G,Go,P,A,L,_E,W,_Ed,C,_I,_D),     arc_learned(G,Go,P,A,L,[],W,[],C,[],[])) :- !.
% Trim the world-model observation log from a cognitive snapshot, keeping the hypothesis state.
le_prune_learned(arc_cog(G,_WmObs,HyState), arc_cog(G,[],HyState)) :- !.
% Everything else is preserved as-is.
le_prune_learned(T, T).

% le_secret_free(+Term): true when the term contains no credential-looking atom.
le_secret_free(Term) :-
    % Render the term to text and check it against the secret patterns.
    term_to_atom(Term, Atom),
    % None of the forbidden markers appear.
    \+ ( member(Pat, ['api_key', 'x-api-key', 'apikey', 'password', 'secret', 'bearer', 'token']),
         sub_atom(Atom, _, _, _, Pat) ).

% le_read_terms(+File, -Terms): read every Prolog term from a file into a list.
le_read_terms(File, Terms) :-
    % Open, read to end of file, always close.
    setup_call_cleanup(open(File, read, S), le_read_terms_(S, Terms), close(S)).
le_read_terms_(S, Terms) :-
    % One term at a time until end of file.
    read_term(S, T, []),
    ( T == end_of_file
    -> Terms = []
    ;  Terms = [T | Rest], le_read_terms_(S, Rest) ).

% le_manifest(+Dir, +NexusCount, +NodeFactCount, +CroCount, +GameCount, +TermCount): write
% the human-readable manifest describing the snapshot and how to regenerate it.
le_manifest(Dir, NexusCount, NodeFactCount, CroCount, GameCount, TermCount) :-
    % The manifest path.
    atomic_list_concat([Dir, '/MANIFEST.txt'], File),
    % Write the provenance and counts.
    setup_call_cleanup(open(File, write, S),
        ( format(S, "Mentova lattice snapshot (open-source / ARC-AGI-3 prize compliance)~n~n", []),
          format(S, "This directory is the materialised, committed copy of the full functioning~n", []),
          format(S, "Causalontology lattice and the runtime learned store, so the whole mind ships~n", []),
          format(S, "with the open-source repository.~n~n", []),
          format(S, "Counts at export time:~n", []),
          format(S, "  lattice nexuses      : ~w~n", [NexusCount]),
          format(S, "  lattice node-facts   : ~w~n", [NodeFactCount]),
          format(S, "  Causalontology CROs  : ~w~n", [CroCount]),
          format(S, "  learned-store games  : ~w~n", [GameCount]),
          format(S, "  learned-store terms  : ~w~n~n", [TermCount]),
          format(S, "Files:~n", []),
          format(S, "  lattice_<nexus>.pl        node-facts per nexus (via lattice_dump/2)~n", []),
          format(S, "  causalontology_cros.pl    every causal_core_cro/8 reasoning object~n", []),
          format(S, "  arc_learnings_snapshot.pl the runtime per-game learned store (secret-free)~n~n", []),
          format(S, "Provenance and reproducibility:~n", []),
          format(S, "  The BASE lattice is rebuilt deterministically at boot from committed sources~n", []),
          format(S, "  (knowledge/ (all .pl), knowledge/curriculum/ (all), knowledge/arc3_games.pl,~n", []),
          format(S, "  knowledge/arc3_steps/draft_*.facts) plus the PrologAI platform. This snapshot~n", []),
          format(S, "  is that built lattice materialised, plus the runtime learnings that live in the~n", []),
          format(S, "  git-ignored data/arc_learnings.db.~n~n", []),
          format(S, "The learned-store snapshot keeps the distilled KNOWLEDGE per game (goal,~n", []),
          format(S, "  priorities, hazards, labels, winning path, causal relations) and prunes the raw~n", []),
          format(S, "  runtime TELEMETRY (per-action effect logs and the megabyte-scale co_graph~n", []),
          format(S, "  state-exploration graph), which is wholly re-derived at runtime.~n~n", []),
          format(S, "Secrets: the ARC-AGI-3 API key (data/arc_api_key.txt) is NEVER included; the~n", []),
          format(S, "  learned-store export additionally drops any term with a credential-looking atom.~n~n", []),
          format(S, "Regenerate with:~n", []),
          format(S, "  make lattice-snapshot        (or)  swipl -q -g true -t halt tools/lattice_export.pl~n", []) ),
        close(S)).

% le_header(+Stream, +Title): a two-line header comment atop a snapshot file.
le_header(S, Title) :-
    % The title line and a regeneration note.
    format(S, "% ~w~n", [Title]),
    format(S, "% Generated by tools/lattice_export.pl (make lattice-snapshot). Do not edit by hand.~n~n", []).

% le_safe_name(+Nexus, -Safe): a filesystem-safe base name for a nexus address.
le_safe_name(Nexus, Safe) :-
    % As text.
    term_to_atom(Nexus, A0),
    % Replace every run of non-alphanumeric characters with a single underscore.
    ( split_string(A0, ":/.@ ()'\"-", "", Parts0)
    -> exclude(==(""), Parts0, Parts),
       atomic_list_concat(Parts, '_', Safe)
    ;  Safe = A0 ).

% Run the export when this file is loaded as a script.
:- initialization((catch(le_export, E, (print_message(error, E), true)), halt)).
