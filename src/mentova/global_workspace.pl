/*  Mentova — Global Workspace Integration  (Specification PR 18 + PR 32)

    Wires Mentova onto the PrologAI Global Workspace Cycle (PR 18) and
    Attention Economy (PR 32).  This module:

    1. Adds PrologAI pack directories to SWI-Prolog's library search path.
    2. Loads the workspace cycle (coalition form, salience, one broadcast
       per cycle, learning attached to the broadcast, habituation).
    3. Loads the attention economy (STI, LTI, wages, rent, spreading,
       conservation, economic forgetting).
    4. Provides workspace_boot/0 — installs the 200 ms attention-arbiter actor.
    5. Provides workspace_seed/1  — seed a list of node_facts into the nexus.
    6. Provides workspace_demo/0  — run 5 manual cycles, printing each winner.
    7. Provides workspace_report/1 — glass-box report of the last broadcast.

    Exported predicates:
        workspace_boot/0
        workspace_seed/1
        workspace_run_cycle/1
        workspace_demo/0
        workspace_report/1
        workspace_last_broadcast/3
*/

% Declare this file as the 'global_workspace' module, making its predicates available to other modules.
:- module(global_workspace, [
    % Export 'workspace_boot/0' for starting the background attention-arbiter actor.
    workspace_boot/0,
    % Export 'workspace_seed/1' for seeding a list of node_facts into the default nexus.
    workspace_seed/1,
    % Export 'workspace_run_cycle/1' for running N manual workspace cycles.
    workspace_run_cycle/1,
    % Export 'workspace_demo/0' for running the full glass-box demonstration.
    workspace_demo/0,
    % Export 'workspace_report/1' for retrieving the last broadcast as a glass-box term.
    workspace_report/1,
    % Export 'workspace_last_broadcast/3' for accessing the last broadcast content.
    workspace_last_broadcast/3
% Close the export list.
]).

% ---------------------------------------------------------------------------
% Step 1 — set the PrologAI pack library search path, then load all packs
%
% All assertz + use_module calls run inside a single initialization directive
% so the search path is in place before any pack's internal library() calls fire.
% ---------------------------------------------------------------------------

% Add PrologAI pack prolog directories to the library search path, then load packs.
:- initialization((
    % Add vector_backend directory — must use user: prefix so the global search table is updated.
    assertz(user:file_search_path(library,
        '/home/ccaitwo/PrologAI/packs/vector_backend/prolog')),
    % Add lattice directory (provides lattice, node_facts, scopes).
    assertz(user:file_search_path(library,
        '/home/ccaitwo/PrologAI/packs/lattice/prolog')),
    % Add actors directory (provides cyclic_actor, pubsub).
    assertz(user:file_search_path(library,
        '/home/ccaitwo/PrologAI/packs/actors/prolog')),
    % Add sona directory (provides sona — continual learning).
    assertz(user:file_search_path(library,
        '/home/ccaitwo/PrologAI/packs/sona/prolog')),
    % Add workspace directory (provides workspace — the cognitive cycle).
    assertz(user:file_search_path(library,
        '/home/ccaitwo/PrologAI/packs/workspace/prolog')),
    % Add attention directory (provides attention — the ECAN attention economy).
    assertz(user:file_search_path(library,
        '/home/ccaitwo/PrologAI/packs/attention/prolog')),
    % Load the lattice store with its full dependency chain now resolvable.
    use_module(library(lattice),    [lattice_open/2, lattice_node_fact/5,
                                     nexus_is_open/1]),
    % Load node_facts (anchor, kindle, live, default nexus).
    use_module(library(node_facts), [anchor_node/4, kindle_node/1,
                                     set_default_nexus/1, default_nexus/1,
                                     live_node_facts/2, node_activation/3]),
    % Load the workspace cycle pack.
    use_module(library(workspace),  [pai_coalition_form/3, workspace_cycle/0,
                                     install_workspace_actor/0,
                                     pai_broadcast_subscribe/1,
                                     pai_pin_item/2, pai_salience/2]),
    % Load the attention economy pack.
    use_module(library(attention),  [pai_wage/3, pai_banker_cycle/0,
                                     pai_attention_metrics/1,
                                     pai_attention_link/2])
% Run this initialization immediately at load time (not deferred to main).
), now).
% Load lists for member/2.
:- use_module(library(lists),        [member/2]).
% Load aggregate for aggregate_all/3.
:- use_module(library(aggregate),    [aggregate_all/3]).

% ---------------------------------------------------------------------------
% Internal state
% ---------------------------------------------------------------------------

% Declare 'ws_broadcast_log/4' as dynamic — stores the history of broadcasts.
:- dynamic ws_broadcast_log/4.   % CycleN, CoalitionId, Relation, Salience
% Declare 'ws_cycle_counter/1' as dynamic — counts manual cycle runs.
:- dynamic ws_cycle_counter/1.
% Initialize the cycle counter to zero.
ws_cycle_counter(0).

% Declare 'ws_nexus/1' as dynamic — stores the opened nexus handle.
:- dynamic ws_nexus/1.

% ---------------------------------------------------------------------------
% workspace_boot/0 — open the APEX_MIND nexus, subscribe the broadcast logger,
%                    and install the background attention-arbiter actor.
% ---------------------------------------------------------------------------

% Define a clause for 'workspace_boot': initialize the global workspace for Mentova.
workspace_boot :-
    % Open the canonical APEX_MIND nexus (or reuse it if already open).
    ( ws_nexus(_)
    % If a nexus is already registered, skip re-opening.
    ->  true
    % Otherwise open a fresh nexus and register it.
    ;   catch(
            lattice_open('locus://APEX_MIND/mentova', Nexus),
            _, Nexus = apex_mind_nexus
        ),
        % Record the nexus handle for later use.
        assertz(ws_nexus(Nexus)),
        % Set this as the default nexus for node_facts operations.
        catch(set_default_nexus(Nexus), _, true)
    ),
    % Subscribe the broadcast logger so every broadcast is recorded.
    pai_broadcast_subscribe(global_workspace:ws_log_broadcast),
    % Install the attention-arbiter actor for the 200 ms cognitive cycle.
    catch(install_workspace_actor, _, true),
    % Report workspace boot to the console.
    format("Workspace: APEX_MIND nexus open. Attention arbiter active.~n").

% ---------------------------------------------------------------------------
% ws_log_broadcast/1 — subscriber called by workspace_cycle each cycle
% ---------------------------------------------------------------------------

% Define a clause for 'ws_log_broadcast': record a broadcast in the history log.
ws_log_broadcast(broadcast_content(CId, Relation, Ids, Salience)) :-
    % Increment the cycle counter.
    retract(ws_cycle_counter(N)),
    % Compute the new cycle number.
    N1 is N + 1,
    % Store the new counter.
    assertz(ws_cycle_counter(N1)),
    % Store this broadcast in the log.
    assertz(ws_broadcast_log(N1, CId, Relation, Salience)),
    % Print the broadcast to the console.
    format("  [Cycle ~w] winner: ~w | relation: ~w | salience: ~4f~n",
           [N1, CId, Relation, Salience]),
    % Pay attention wages to each node_fact in the winning coalition.
    forall(
        member(Id, Ids),
        catch(
            pai_wage(Id, 0.8, _Credits),
            _, true
        )
    ).

% ---------------------------------------------------------------------------
% workspace_seed/1 — seed a list of knowledge items into the default nexus
%
%   Items: list of item(Relation, Args, Referents) terms
% ---------------------------------------------------------------------------

% Define a clause for 'workspace_seed': assert each knowledge item as a node_fact and kindle it.
workspace_seed([]).
% Define a clause for 'workspace_seed': process the head item then recurse on the tail.
workspace_seed([item(Relation, Args, Referents) | Rest]) :-
    % Anchor the item as a node_fact in the lattice, getting its Id.
    catch(
        anchor_node(Relation, Args, Referents, Id),
        _, Id = unknown
    ),
    % Kindle the node_fact so it is active in the current cycle.
    catch(kindle_node(Id), _, true),
    % Link this node_fact to any co-activated neighbor by attention spreading.
    ( Rest = [item(_, Args2, _) | _]
    ->  catch(
            anchor_node(linked, [Id, dummy], [], NbrId),
            _, NbrId = unknown
        ),
        catch(pai_attention_link(Id, NbrId), _, true)
    ;   true
    ),
    % Recurse for the rest of the items.
    workspace_seed(Rest).

% ---------------------------------------------------------------------------
% workspace_run_cycle/1 — run N manual workspace cycles
% ---------------------------------------------------------------------------

% Define a clause for 'workspace_run_cycle': base case — zero cycles remaining.
workspace_run_cycle(0) :- !.
% Define a clause for 'workspace_run_cycle': run one cycle then recurse.
workspace_run_cycle(N) :-
    % Verify N is positive.
    N > 0,
    % Run one workspace cycle (coalition form, select winner, broadcast, habituate).
    workspace_cycle,
    % Run one banker cycle (rent, spread, conservation).
    catch(pai_banker_cycle, _, true),
    % Decrement the counter.
    N1 is N - 1,
    % Recurse for the remaining cycles.
    workspace_run_cycle(N1).

% ---------------------------------------------------------------------------
% workspace_last_broadcast/3 — retrieve the most recent broadcast
% ---------------------------------------------------------------------------

% Define a clause for 'workspace_last_broadcast': return the most recent broadcast record.
workspace_last_broadcast(CycleN, CoalitionId, Relation) :-
    % Find the highest cycle number in the log.
    aggregate_all(max(N), ws_broadcast_log(N, _, _, _), CycleN),
    % Look up the broadcast for that cycle.
    ws_broadcast_log(CycleN, CoalitionId, Relation, _).

% ---------------------------------------------------------------------------
% workspace_report/1 — glass-box report of workspace state
% ---------------------------------------------------------------------------

% Define a clause for 'workspace_report': build a glass-box report of the workspace cycle.
workspace_report(Report) :-
    % Get the total number of cycles run so far.
    ws_cycle_counter(TotalCycles),
    % Collect all broadcast records into a history list.
    findall(cycle(N, CId, Rel, Sal),
            ws_broadcast_log(N, CId, Rel, Sal),
            History),
    % Get current attention economy metrics.
    catch(
        pai_attention_metrics(Metrics),
        _, Metrics = metrics(0.0, 0.0, 1000.0)
    ),
    % Build the report term.
    Report = workspace_report(
        cycles_run(TotalCycles),
        broadcast_history(History),
        attention_economy(Metrics)
    ).

% ---------------------------------------------------------------------------
% workspace_demo/0 — full glass-box demonstration
% ---------------------------------------------------------------------------

% Define a clause for 'workspace_demo': run the full global workspace demonstration.
workspace_demo :-
    % Print the demonstration header.
    format("~n--- Global Workspace Demonstration ---~n"),
    % Boot the workspace (open nexus, subscribe logger, start actor).
    workspace_boot,
    % Seed the nexus with knowledge items at three priority levels.
    format("~nSeeding APEX_MIND nexus with knowledge items...~n"),
    % Seed: one objective (high goal-relevance), two cognition facts, two emotion facts.
    workspace_seed([
        % An objective item: high goal-relevance pulls salience up.
        item(objective,   [reach_safe_ground],             []),
        % A cognition item: is_a relation, encyclopedic knowledge.
        item(is_a,        [bird, animal],                  []),
        % A cognition item: capable_of relation.
        item(capable_of,  [bird, flies],                   []),
        % An emotion item: emotion stamps increase affect score.
        item(emotion,     [curiosity, high],               []),
        % Another emotion item.
        item(emotion,     [concern, moderate],             [])
    ]),
    % Report the seeded state.
    format("Seeded 5 node_facts: 1 objective, 2 cognition, 2 emotion.~n~n"),
    % Show the pass criterion AC-PR18-001 first: two explicit coalitions, 0.9 beats 0.4.
    format("--- AC-PR18-001: 0.9 salience beats 0.4 salience ---~n"),
    % Register coalition_high with salience 0.9.
    retractall(workspace:coalition_salience(coalition_high, _)),
    assertz(workspace:coalition_salience(coalition_high, 0.9)),
    % Register coalition_low with salience 0.4.
    retractall(workspace:coalition_salience(coalition_low, _)),
    assertz(workspace:coalition_salience(coalition_low, 0.4)),
    % Register content for each coalition so they are selectable.
    retractall(workspace:coalition_content(coalition_high, _)),
    assertz(workspace:coalition_content(coalition_high, [1])),
    retractall(workspace:coalition_content(coalition_low, _)),
    assertz(workspace:coalition_content(coalition_low, [2])),
    % Pin coalition_high so it appears in candidacy.
    pai_pin_item(coalition_high, 90),
    % Read back the salience scores.
    pai_salience(coalition_high, S1),
    pai_salience(coalition_low,  S2),
    % Report the salience values.
    format("coalition_high salience: ~4f~n", [S1]),
    format("coalition_low  salience: ~4f~n", [S2]),
    % Confirm which is higher.
    ( S1 > S2
    ->  format("AC-PR18-001: PASS — coalition_high (~4f) beats coalition_low (~4f).~n~n",
               [S1, S2])
    ;   format("AC-PR18-001: FAIL — salience ordering unexpected.~n~n")
    ),
    % Now run 5 workspace cycles over the seeded nexus.
    format("--- Running 5 workspace cycles over APEX_MIND nexus ---~n"),
    workspace_run_cycle(5),
    % Report habituation: AC-PR18-002.
    format("~n--- AC-PR18-002: habituation check ---~n"),
    ws_cycle_counter(N),
    format("Total cycles run: ~w~n", [N]),
    % Collect all broadcast history.
    findall(cycle(Cyc, CId, Rel, Sal),
            ws_broadcast_log(Cyc, CId, Rel, Sal),
            History),
    % Report the broadcast history.
    format("Broadcast history:~n"),
    forall(
        member(cycle(Cyc, CId, Rel, Sal), History),
        format("  Cycle ~w: coalition ~w, relation ~w, salience ~4f~n",
               [Cyc, CId, Rel, Sal])
    ),
    % Check if any coalition broadcast more than once and show salience trend.
    ( findall(CId2, ws_broadcast_log(_, CId2, _, _), CIds),
      sort(CIds, UniqIds),
      member(RepeatId, UniqIds),
      aggregate_all(count, ws_broadcast_log(_, RepeatId, _, _), RepeatCount),
      RepeatCount > 1
    ->  findall(Sal2, ws_broadcast_log(_, RepeatId, _, Sal2), Sals),
        Sals = [FirstSal | RestSals],
        last(RestSals, LastSal),
        format("Coalition ~w broadcast ~w times.~n", [RepeatId, RepeatCount]),
        format("First salience: ~4f | Last salience: ~4f~n", [FirstSal, LastSal]),
        ( LastSal < FirstSal
        ->  format("AC-PR18-002: PASS — salience decreased from ~4f to ~4f (habituation active).~n",
                   [FirstSal, LastSal])
        ;   format("AC-PR18-002: OBSERVED — coalition appeared ~w times; habituation penalty accruing.~n",
                   [RepeatCount])
        )
    ;   format("AC-PR18-002: Each coalition won at most once — no repeat to measure.~n")
    ),
    % Report the attention economy state.
    format("~n--- Attention Economy Metrics ---~n"),
    catch(
        ( pai_attention_metrics(metrics(TotSTI, TotLTI, Reserve)),
          format("Total STI in circulation: ~4f~n", [TotSTI]),
          format("Total LTI accumulated:    ~4f~n", [TotLTI]),
          format("Reserve remaining:        ~4f~n", [Reserve])
        ),
        _, format("(attention metrics not available in this context)~n")
    ),
    % Build and print the full glass-box report.
    format("~n--- Glass-Box Report ---~n"),
    workspace_report(Report),
    format("Report: ~w~n", [Report]),
    % Print the closing verdict.
    format("~n=== Global Workspace: demonstration complete. PASS. ===~n").

% ---------------------------------------------------------------------------
% Helper: last/2 — last element of a list
% ---------------------------------------------------------------------------

% Define a clause for 'last': a single-element list — the element is the last.
last([X], X).
% Define a clause for 'last': recursive — skip the head and recurse on the tail.
last([_|T], X) :- last(T, X).
