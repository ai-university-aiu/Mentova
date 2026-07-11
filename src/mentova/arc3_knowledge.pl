/*  Mentova — ARC-AGI-3 Game Knowledge Transfer  (the heavy pass)

    Takes the 25 ARC-AGI-3 mentor guides (in the assets folder), distilled into
    game-keyed facts in knowledge/arc3_games.pl, and transfers them into
    Mentova's mind across the full stack, exactly the way the curriculum
    "light pass" does:

      - every fact (game identity, controls, objects, hazards, tips, notes)
        is anchored as a NODE_FACT in the lattice, carrying its guide-file
        citation as provenance;
      - every cause-effect relation (changer -> property, ring -> timer refill,
        hazard -> ends run, key -> unlock door ...) becomes a game-keyed
        Causal Relation Object, cause [g(Game, Cause)], so it never bleeds
        between environments and is read by both Guided and Solo;
      - each game's identity and relations are held as concepts in a J-Space
        workspace (arc3_mind).

    Persistence: the knowledge lives on disk in the loaded fact file
    knowledge/arc3_games.pl and is re-ingested at every boot (a3_bootstrap is
    called from mc_chat_main), so it survives restarts and is available to both
    sub-projects. Ingestion is idempotent — a3_clear removes prior arc3-sourced
    relations first, so re-running never duplicates.

    Every external capability (lattice, Causalontology, J-Space) is used only
    when present; on a bare load the facts still stay queryable, so this module
    is safe to load anywhere.
*/

% Declare the ARC-AGI-3 knowledge module and its public interface.
:- module(arc3_knowledge, [
    % a3_bootstrap/0: the safe one-call boot entry (ingest all games).
    a3_bootstrap/0,
    % a3_ingest/0: ingest every game's facts into the mind.
    a3_ingest/0,
    % a3_clear/0: remove previously-ingested arc3 relations (idempotency).
    a3_clear/0,
    % a3_knows/3: a cause-effect relation Mentova holds for a game.
    a3_knows/3,
    % a3_about/2: a game's identity as a dict.
    a3_about/2,
    % a3_recall/3: what Mentova knows about a keyword in a game.
    a3_recall/3,
    % a3_why/4: the guide that a game relation is cited to.
    a3_why/4,
    % a3_stats/1: how much was transferred.
    a3_stats/1
]).

% Load the distilled per-game facts (the source of the transfer).
:- use_module('../../knowledge/arc3_games').

% a3_defined(+Head): true when Head's predicate is defined, never throwing.
a3_defined(Head) :-
    % Ask for the predicate property, treating any error as "not defined".
    catch(predicate_property(Head, defined), _, fail).

% ---------------------------------------------------------------------------
% Bootstrap and ingestion
% ---------------------------------------------------------------------------

% Define a3_bootstrap: the safe one-call entry used at server startup.
a3_bootstrap :-
    % Ingest everything, tolerating any error so boot never fails.
    catch(a3_ingest, _E, true).

% Define a3_ingest: transfer every game's knowledge into the mind.
a3_ingest :-
    % Start clean so re-ingesting never duplicates relations.
    a3_clear,
    % Open and select an arc3 nexus for anchoring, if the lattice is present.
    a3_open_nexus,
    % Anchor every fact as a node_fact (best effort), counting successes.
    a3_anchor_facts(NF),
    % Assert every cause-effect relation as a game-keyed CRO, counting them.
    a3_assert_cros(NC),
    % Mark every hazard preventive in the Causalontology (best effort).
    a3_assert_hazards(NH),
    % Hold each game's identity and relations in the J-Space workspace.
    a3_hold_jspace(NJ),
    % How many games were transferred.
    aggregate_all(count, a3_game(_, _, _, _), NG),
    % A glass-box startup log, mirroring the curriculum's.
    format("arc3: transferred ~w games — ~w node-facts, ~w relations, ~w hazards, ~w J-Space concepts~n",
           [NG, NF, NC, NH, NJ]).

% Define a3_clear: retract every CRO and preventive this module ingested, by
% its arc3_guide provenance, so a re-ingest is idempotent.
a3_clear :-
    % Only when the Causalontology store is present.
    (   a3_defined(co_core:co_cro(_, _, _, _, _, _, _, _))
    % Retract every CRO whose provenance names an arc3 guide, in one sweep.
    ->  catch(retractall(co_core:co_cro_(_, _, _, _, _, _, _, prov(arc3_guide, _, _))), _, true)
    % No store: nothing to clear.
    ;   true
    ).

% Define a3_open_nexus: open an arc3 nexus and make it the anchoring target.
a3_open_nexus :-
    % Only when the lattice and the default-nexus setter are both present.
    (   a3_defined(lattice:lattice_open(_, _)),
        a3_defined(node_facts:set_default_nexus(_))
    % Open the arc3 nexus (a locus address, like the curriculum's) and select
    % it as the anchoring destination, tolerating any lattice hiccup.
    ->  catch(( lattice:lattice_open('locus://mentova/arc3', N),
                node_facts:set_default_nexus(N) ), _, true)
    % No lattice: registry-only mode.
    ;   true
    ).

% Define a3_anchor_facts: anchor each game fact as a node_fact with its guide
% citation, counting the successes.
a3_anchor_facts(Count) :-
    % Only when the node_facts anchor predicate is available.
    (   a3_defined(node_facts:anchor_node_unique(_, _, _, _))
    % Anchor each enumerated fact; a per-fact error is tolerated.
    ->  aggregate_all(count,
            ( a3_any_fact(Game, Relation, Args),
              a3_cite(Game, Cite),
              catch(node_facts:anchor_node_unique(Relation, Args,
                        [game(Game), Cite], _), _, fail) ),
            Count)
    % No lattice: the facts stay queryable directly.
    ;   Count = 0
    ).

% a3_any_fact(-Game, -Relation, -Args): enumerate every game fact as a
% (relation, args) pair suitable for node anchoring.
% The game's identity.
a3_any_fact(Game, arc3_game, [Game, Name, Genre, WinLevels]) :-
    a3_game(Game, Name, Genre, WinLevels).
% The control scheme.
a3_any_fact(Game, arc3_control, [Game, Scheme]) :-
    a3_control(Game, Scheme, _).
% An object and its role.
a3_any_fact(Game, arc3_object, [Game, Object, Role]) :-
    a3_object(Game, Object, Role).
% A hazard.
a3_any_fact(Game, arc3_hazard, [Game, Hazard]) :-
    a3_hazard(Game, Hazard).
% A mentor tip.
a3_any_fact(Game, arc3_tip, [Game, Text]) :-
    a3_tip(Game, Text).
% A note.
a3_any_fact(Game, arc3_note, [Game, Key, Value]) :-
    a3_note(Game, Key, Value).

% Define a3_assert_cros: assert each cause-effect relation as a game-keyed CRO.
a3_assert_cros(Count) :-
    % Only when the co_core CRO constructor is available.
    (   a3_defined(co_core:co_new_cro_unique(_, _, _, _, _, _, _, _))
    % Build one CRO per relation, cause keyed by game, cited to the guide.
    ->  aggregate_all(count,
            ( a3_rel(Game, Cause, Effect),
              a3_cite(Game, Cite),
              catch(co_core:co_new_cro_unique([g(Game, Cause)], [Effect],
                        temporal(0, 0, instant), sufficient, 0.85,
                        [game(Game)], prov(arc3_guide, Cite, 0.85), _),
                    _, fail) ),
            Count)
    % No co_core: the relations stay queryable via a3_rel/3.
    ;   Count = 0
    ).

% Define a3_assert_hazards: record each hazard as a game-keyed preventive CRO.
a3_assert_hazards(Count) :-
    % Only when the CRO constructor is available.
    (   a3_defined(co_core:co_new_cro_unique(_, _, _, _, _, _, _, _))
    % One preventive relation per hazard: this game-state ends the run.
    ->  aggregate_all(count,
            ( a3_hazard(Game, Hazard),
              a3_cite(Game, Cite),
              catch(co_core:co_new_cro_unique([g(Game, Hazard)], [ends(run)],
                        temporal(0, 0, instant), preventive, 0.9,
                        [game(Game)], prov(arc3_guide, Cite, 0.9), _),
                    _, fail) ),
            Count)
    % No co_core: hazards stay queryable via a3_hazard/2.
    ;   Count = 0
    ).

% Define a3_hold_jspace: hold each game's identity and relations as concepts in
% the arc3_mind workspace.
a3_hold_jspace(Count) :-
    % Only when the J-Space workspace is available.
    (   a3_defined(jspace:js_open(_)), a3_defined(jspace:js_hold(_, _, _, _))
    % Open the workspace, guarded.
    ->  catch(jspace:js_open(arc3_mind), _, true),
        % Hold each game's identity and each of its relations.
        aggregate_all(count,
            ( a3_jspace_item(Concept, Strength),
              catch(jspace:js_hold(arc3_mind, Concept, Strength, arc3_guide), _, fail) ),
            Count)
    % No J-Space: nothing held.
    ;   Count = 0
    ).

% a3_jspace_item(-Concept, -Strength): a concept to hold in arc3_mind.
% Each game's identity.
a3_jspace_item(game(Game, Name, Genre), 1.0) :-
    a3_game(Game, Name, Genre, _).
% Each cause-effect relation as a "knows" concept.
a3_jspace_item(knows(Game, Cause, Effect), 0.85) :-
    a3_rel(Game, Cause, Effect).

% a3_cite(+Game, -Citation): the guide citation for a game, as a source term.
a3_cite(Game, source(arc3_guide, Path)) :-
    % Resolve the game's guide file path, defaulting when unknown.
    ( a3_guide(Game, Path) -> true ; Path = 'assets/unknown.txt' ).

% ---------------------------------------------------------------------------
% Queries — what the mind now knows
% ---------------------------------------------------------------------------

% Define a3_knows: a cause-effect relation Mentova holds for a game, read back
% from the Causalontology when present, else from the loaded facts.
a3_knows(Game, Cause, Effect) :-
    % Prefer the ingested CROs (proves the transfer reached the mind).
    (   a3_defined(co_core:co_cro(_, _, _, _, _, _, _, _)),
        co_core:co_cro(_, [g(Game, Cause)], [Effect], _, Modality, _, _, _),
        Modality \== preventive
    % Otherwise fall back to the loaded relation facts.
    ;   \+ a3_defined(co_core:co_cro(_, _, _, _, _, _, _, _)),
        a3_rel(Game, Cause, Effect)
    ).

% Define a3_about: a game's identity as a readable dict.
a3_about(Game, arc3(Game, Name, Genre, win_levels(WinLevels), controls(Scheme))) :-
    % The identity.
    a3_game(Game, Name, Genre, WinLevels),
    % Its control scheme.
    ( a3_control(Game, Scheme, _) -> true ; Scheme = unknown ).

% Define a3_recall: everything the mind knows about a keyword in a game — the
% relations, objects, hazards, and tips whose terms mention the keyword. This
% answers questions like "what does Mentova know about ls20 rings?".
a3_recall(Game, Keyword, Items) :-
    % Collect every matching item across the stores.
    findall(Item, a3_recall_item(Game, Keyword, Item), Items0),
    % Drop duplicates, keep a stable order.
    sort(Items0, Items).

% a3_recall_item(+Game, +Keyword, -Item): one item mentioning the keyword.
% A relation whose cause or effect mentions the keyword.
a3_recall_item(Game, Keyword, relation(Cause, Effect)) :-
    a3_rel(Game, Cause, Effect),
    ( a3_mentions(Cause, Keyword) ; a3_mentions(Effect, Keyword) ).
% An object whose name mentions the keyword.
a3_recall_item(Game, Keyword, object(Object, Role)) :-
    a3_object(Game, Object, Role),
    a3_mentions(Object, Keyword).
% A hazard mentioning the keyword.
a3_recall_item(Game, Keyword, hazard(Hazard)) :-
    a3_hazard(Game, Hazard),
    a3_mentions(Hazard, Keyword).
% A tip mentioning the keyword.
a3_recall_item(Game, Keyword, tip(Text)) :-
    a3_tip(Game, Text),
    a3_mentions(Text, Keyword).

% a3_mentions(+Term, +Keyword): the term's text contains the keyword.
a3_mentions(Term, Keyword) :-
    % Render the term as text.
    term_string(Term, S0),
    % Case-fold both sides.
    string_lower(S0, S),
    ( atom(Keyword) -> atom_string(Keyword, K0) ; K0 = Keyword ),
    string_lower(K0, K),
    % A substring match.
    sub_string(S, _, _, _, K).

% Define a3_why: the guide a game's relation is cited to.
a3_why(Game, Cause, Effect, Guide) :-
    % The relation must exist for the game.
    a3_rel(Game, Cause, Effect),
    % Its guide file.
    a3_guide(Game, Guide).

% Define a3_stats: how much knowledge was transferred.
a3_stats(stats(Games, Objects, Relations, Hazards)) :-
    % Count the games.
    aggregate_all(count, a3_game(_, _, _, _), Games),
    % Count the objects.
    aggregate_all(count, a3_object(_, _, _), Objects),
    % Count the relations.
    aggregate_all(count, a3_rel(_, _, _), Relations),
    % Count the hazards.
    aggregate_all(count, a3_hazard(_, _), Hazards).
