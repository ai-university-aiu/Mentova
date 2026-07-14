/*  Mentova — ARC-AGI-3 Cognitive Architecture and the Kaggle North-Star

    The ten Steps drafts, read together, are not twenty-five narrow puzzle
    walk-throughs; they are one recurring account of what it takes to win an
    interactive reasoning benchmark under novelty. This module abstracts that
    account UP into the cognitive-architecture and OODA principles that carry
    forward to games never seen, maps each principle DOWN to the Mentova / PrologAI
    capability that realises it, and plants the guiding concept in Jacobian Space:

        "How to Win the Kaggle ARC-AGI-3 competition by building Mentova and
         PrologAI."

    The point of layering up and down is transfer. The public twenty-five games are
    a demonstration set (several admit shortcuts); the real prize is the private and
    future environments. A mind that has internalised the PRINCIPLES — explore
    before you optimise, keep an executable world model and repair it, commit to a
    hypothesis without drifting, reason over object relations, spend actions to
    learn within a budget, carry general laws to the next level — can meet an
    unknown game, whereas a mind that only memorised the twenty-five cannot.

    Predicates:
      cog_bootstrap/0        hold the principles, pillars, and north-star in J-Space
      cog_principle/2        -- ?Slug, ?Statement   (the abstracted principles)
      cog_pillar/3           -- ?Capability, ?Pack, ?Role  (the architecture pillars)
      cog_maps/2             -- ?PrincipleSlug, ?PillarCapability
      cog_northstar/1        -- -Text
      cog_stats/1            -- -stats(Principles, Pillars, Held)
*/

% Declare this module and its interface.
:- module(arc3_cognition, [
    % cog_bootstrap/0: plant the cognitive architecture and north-star in J-Space.
    cog_bootstrap/0,
    % cog_principle/2: an abstracted cognitive-architecture / OODA principle.
    cog_principle/2,
    % cog_pillar/3: a Mentova capability pillar (its pack and its role).
    cog_pillar/3,
    % cog_maps/2: which pillar realises a principle (the abstraction going down).
    cog_maps/2,
    % cog_northstar/1: the guiding concept text.
    cog_northstar/1,
    % cog_stats/1: a summary.
    cog_stats/1
]).

:- use_module(library(aggregate), [aggregate_all/3]).
:- use_module(library(lists), [member/2]).

% ===========================================================================
% SECTION 1 — abstraction UP: the principles that transfer to unseen games
% ===========================================================================

% cog_principle(?Slug, ?Statement): the recurring principles distilled from all ten
% drafts, phrased to hold for ANY novel interactive environment, not just the 25.
cog_principle(explore_before_optimise,
    'Spend the first actions learning the hidden rules, not chasing the goal. Separate model-learning from task-optimisation; plan only once the model is trusted.').
cog_principle(executable_world_model,
    'Keep a runnable model of the environment''s dynamics. Predict the next state, verify it against what actually happened, repair the model on mismatch, and plan by rolling it forward before spending real actions.').
cog_principle(hypothesis_commitment,
    'Generate several candidate rules, rank them by how well they predict the evidence, and COMMIT to the best — holding it through a stray surprise (hysteresis) yet yielding when it is truly contradicted. Drift and non-commitment are the losing agents'' defining failure.').
cog_principle(object_relational_reasoning,
    'Reason over segmented objects and their relations — adjacency, containment, alignment, offset vectors, ordinal size — not over raw pixels. Most mechanics are defined on relations, and structured state is far cheaper to plan over.').
cog_principle(ooda_control_spine,
    'Run the observe-orient-decide-act loop continuously, with orientation as the schwerpunkt: a correct, well-built model matters more than a fast action.').
cog_principle(information_gain_exploration,
    'Choose the probe that most reduces uncertainty (vary one factor at a time; probe every action type early, including the click, so a one-action win is never missed), not the action that looks most rewarding now.').
cog_principle(action_budget_efficiency,
    'Treat the action budget as a scored resource (efficiency is penalised quadratically against the human baseline). Learn economically, avoid duplicate transitions, and plan in the model rather than in the live environment.').
cog_principle(causal_attribution,
    'Attribute each observed frame-delta to the action that caused it, one action at a time, to isolate mechanics cleanly from a stream of change.').
cog_principle(core_knowledge_priors,
    'Lean only on the innate priors the benchmark allows — objectness, geometry, topology, intuitive physics, and agentness — because language and cultural knowledge do not transfer and are not permitted.').
cog_principle(per_level_generalisation,
    'Carry a rule proven cheaply on an early level forward as a prior, but re-verify it with a quick probe each level, since later levels recombine and add mechanics.').
cog_principle(simplicity_bias,
    'Among models consistent with the evidence, prefer the simplest (minimum description length). Simple laws generalise; over-fitted ones break on the next level.').
cog_principle(analogy_discipline,
    'Seed a first hypothesis from an archetype (lights-out, sokoban, frogger) but derive the rule from observed transitions, and audit any success — a lucky win can harden a wrong theory that fails later.').
cog_principle(self_reflection,
    'Watch for a stalled or contradicted hypothesis and re-orient, rather than thrashing the same failed actions.').
cog_principle(glass_box_transparency,
    'Show the reasoning: every learned relation attributable, every plan inspectable, every commitment explained. A transparent mind can be taught, audited, and trusted — the differentiator of a symbolic approach.').

% ===========================================================================
% SECTION 2 — abstraction DOWN: the Mentova / PrologAI pillars that realise them
% ===========================================================================

% cog_pillar(?Capability, ?Pack, ?Role): the architecture Mentova is building toward
% the north-star, each a concrete pack that realises part of the winning recipe.
cog_pillar(perception,            co_see,       'segment the whole grid into roled objects and read meters').
cog_pillar(exploration,           co_explore,   'novelty-seeking, loop-avoiding, salient-target action selection').
cog_pillar(state_graph_memory,    state_graph,     'a directed graph of frame-hash states and action transitions').
cog_pillar(world_model,           world_model,        'learn, verify, repair, and roll forward a transition model').
cog_pillar(hypothesis_commitment, co_hypo,      'generate, rank, and commit to a hypothesis without drift').
cog_pillar(object_relations,      object_relations,       'relations between objects: adjacency, containment, vectors').
cog_pillar(hierarchical_plan,     hierarchical_planning,     'the Win-Game / OODA / controls plan reified onto the causal graph').
cog_pillar(verify_before_act,     verification,    'predict a move fatal before spending a real action on it').
cog_pillar(goal_inference,        co_goalinfer, 'hypothesise the unstated win condition from winning deltas').
cog_pillar(efficiency,            efficiency_governor,      'the action-budget governor and RHAE-style scoring').
cog_pillar(cross_game_priors,     arc3_priors,   'mechanic archetypes abstracted from studied games, for the unseen').
cog_pillar(ooda_skill,            ooda_knowledge,'the OODA methodology held in J-Space as a concept it reasons with').

% cog_maps(?PrincipleSlug, ?PillarCapability): which pillar realises each principle
% — the abstraction taken down from wisdom to working code.
cog_maps(explore_before_optimise,      exploration).
cog_maps(executable_world_model,       world_model).
cog_maps(hypothesis_commitment,        hypothesis_commitment).
cog_maps(object_relational_reasoning,  object_relations).
cog_maps(ooda_control_spine,           hierarchical_plan).
cog_maps(ooda_control_spine,           ooda_skill).
cog_maps(information_gain_exploration, exploration).
cog_maps(action_budget_efficiency,     efficiency).
cog_maps(causal_attribution,           perception).
cog_maps(core_knowledge_priors,        cross_game_priors).
cog_maps(per_level_generalisation,     cross_game_priors).
cog_maps(simplicity_bias,              world_model).
cog_maps(analogy_discipline,           hypothesis_commitment).
cog_maps(self_reflection,              hypothesis_commitment).
cog_maps(glass_box_transparency,       hierarchical_plan).

% ===========================================================================
% SECTION 3 — the Kaggle north-star, planted in Jacobian Space
% ===========================================================================

% cog_northstar(-Text): the guiding concept.
cog_northstar('How to Win the Kaggle ARC-AGI-3 competition by building Mentova and PrologAI: build a glass-box symbolic mind that runs the OODA loop over an executable, repairable world model; commits to hypotheses without drifting; reasons over object relations rather than pixels; explores to gain information within a scored action budget; attributes every effect to its cause; leans only on core-knowledge priors so it transfers to unseen games; carries the simplest general laws from level to level; and shows all of its work. The public twenty-five are the proving ground; the private and future environments are the prize.').

% cog_defined(:Goal): true if the goal's predicate exists (guards optional jspace).
cog_defined(Module:Goal) :-
    functor(Goal, Name, Arity), current_predicate(Module:Name/Arity).

% cog_bootstrap: hold the north-star, its pillars, and the principles as concepts in
% the Jacobian-Space workspace kaggle_northstar, so the mind carries the goal and
% the plan for reaching it as things it can reason about. Guarded and idempotent.
cog_bootstrap :-
    catch(cog_bootstrap_, _Err, true).

cog_bootstrap_ :-
    (   cog_defined(jspace:js_open(_)), cog_defined(jspace:js_hold(_, _, _, _))
    ->  catch(jspace:js_open(kaggle_northstar), _, true),
        % The north-star itself, at full strength.
        cog_northstar(Star),
        catch(jspace:js_hold(kaggle_northstar, north_star(Star), 1.0, arc3_cognition), _, true),
        % Each principle as a concept.
        forall(cog_principle(Slug, _),
            catch(jspace:js_hold(kaggle_northstar, principle(Slug), 0.95, arc3_cognition), _, true)),
        % Each pillar and the principle it realises.
        forall(cog_pillar(Cap, Pack, _),
            catch(jspace:js_hold(kaggle_northstar, pillar(Cap, Pack), 0.9, arc3_cognition), _, true)),
        forall(cog_maps(P, Cap),
            catch(jspace:js_hold(kaggle_northstar, realises(Cap, P), 0.85, arc3_cognition), _, true))
    ;   true
    ).

% cog_stats(-stats(Principles, Pillars, Held)): a summary count.
cog_stats(stats(Principles, Pillars, Held)) :-
    aggregate_all(count, cog_principle(_, _), Principles),
    aggregate_all(count, cog_pillar(_, _, _), Pillars),
    ( cog_defined(jspace:js_reading(_, _)),
      catch(jspace:js_reading(kaggle_northstar, R), _, fail), is_list(R)
    -> length(R, Held) ; Held = 0 ).
