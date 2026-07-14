/*  Mentova — OODA Methodology as a Held Skill in Jacobian Space

    The OODA loop (Observe, Orient, Decide, Act) is the middle layer of every plan
    Mentova builds (hierarchical_planning). This module holds the methodology itself in Mentova's
    Jacobian-Space workspace as a skill the mind can reason about — not only the
    shape of its plans but a concept it carries: which phase it is in, why
    orientation is the schwerpunkt, when to take the fast implicit path, and how the
    loop maps onto its own planner. The facts are distilled from the reference paper
    papers/OODA.txt (John Boyd's Discourse on Winning and Losing).

    Predicates:
      ooda_bootstrap/0            hold the methodology in J-Space (idempotent)
      ooda_phase/2                -- ?Phase, ?Description   (Boyd's four)
      ooda_orientation_ingredient/2 -- ?Ingredient, ?Description (the five)
      ooda_principle/2            -- ?Principle, ?Description
      ooda_hplan_map/2            -- ?OodaPhase, ?HplanPhases (the hierarchical_planning mapping)
      ooda_recall/2               -- +Topic, -Items
      ooda_stats/1                -- -stats(Phases, Ingredients, Principles, Held)
*/

% Declare this module and its OODA interface.
:- module(ooda_knowledge, [
    % ooda_bootstrap/0: hold the OODA methodology in J-Space.
    ooda_bootstrap/0,
    % ooda_phase/2: one of Boyd's four phases and its meaning.
    ooda_phase/2,
    % ooda_orientation_ingredient/2: one of the five ingredients of orientation.
    ooda_orientation_ingredient/2,
    % ooda_principle/2: a core OODA principle and its meaning.
    ooda_principle/2,
    % ooda_hplan_map/2: how an OODA phase maps onto hierarchical_planning's middle layer.
    ooda_hplan_map/2,
    % ooda_recall/2: recall the held OODA concepts matching a topic.
    ooda_recall/2,
    % ooda_stats/1: a summary count of the methodology.
    ooda_stats/1
]).

% Import aggregation for the summary counts.
:- use_module(library(aggregate), [aggregate_all/3]).
% Import list helpers.
:- use_module(library(lists), [member/2]).

% ===========================================================================
% SECTION 1 — the methodology as facts
% ===========================================================================

% ooda_phase(?Phase, ?Description): Boyd's four phases. See and re-observe are the
% two hierarchical_planning names them into; here they are Boyd's canonical four.
ooda_phase(observe,
    'Take in the situation, fed by the unfolding circumstances, outside information, and the unfolding interaction with the environment.').
ooda_phase(orient,
    'The schwerpunkt — the most important phase. Analysis and synthesis fuse genetic heritage, cultural traditions, previous experience, and new information into a working model of reality.').
ooda_phase(decide,
    'Choose an action — a decision Boyd labels a hypothesis, to be tested by acting.').
ooda_phase(act,
    'Perform the action — a test whose result changes the environment and must be re-observed, closing the loop.').

% ooda_orientation_ingredient(?Ingredient, ?Description): the five ingredients Boyd
% drew inside the Orient box.
ooda_orientation_ingredient(genetic_heritage,
    'Innate, biological predispositions.').
ooda_orientation_ingredient(cultural_traditions,
    'The values, language, and social frameworks one is raised inside.').
ooda_orientation_ingredient(previous_experience,
    'The accumulated personal history brought to a situation.').
ooda_orientation_ingredient(new_information,
    'The fresh sensory input arriving in the moment.').
ooda_orientation_ingredient(analysis_and_synthesis,
    'The engine at the centre: break incoming information apart (analysis) and recombine it (synthesis) into an updated picture.').

% ooda_principle(?Principle, ?Description): the core principles that distinguish
% Boyd's real loop from the cartoon four-box circle.
ooda_principle(orientation_is_schwerpunkt,
    'Orientation is the main thing: it shapes observation, decision, and action, and is shaped by their feedback. Better orientation can beat a materially stronger opponent.').
ooda_principle(implicit_guidance_and_control,
    'Two arrows run straight out of Orient — to Observe and directly to Act, bypassing Decide. This is the fast, intuitive path of the expert: when a pattern fits, orientation drives action with no explicit decision.').
ooda_principle(tempo,
    'Cycle faster and more accurately than the adversary to get inside their decision loop, generating ambiguity and mismatch until their orientation is wrong and their actions address a world that has moved on.').
ooda_principle(feedback_loops,
    'The loop is many nested, simultaneous loops: Act feeds back to Observe, Decide feeds back to Observe, and the observation window feeds itself. Acting is a test whose result is re-observed.').
ooda_principle(destruction_and_creation,
    'Learning requires destroying an obsolete mental model (analysis) and creating a better one (synthesis). Grounded in Godel, Heisenberg, and the second law: no closed model stays adequate, so orientation must be continually rebuilt.').
ooda_principle(moral_mental_physical,
    'Conflict has three dimensions — physical (menace and isolate), mental (generate uncertainty), and moral (break cohesion). The moral is most decisive, the physical least.').

% ===========================================================================
% SECTION 2 — the mapping onto hierarchical_planning's middle layer
% ===========================================================================

% ooda_hplan_map(?OodaPhase, ?HplanPhases): how each of Boyd's phases corresponds to
% the phases hierarchical_planning puts in a plan's middle layer.
ooda_hplan_map(observe, [see, observe]).
ooda_hplan_map(orient,  [orient]).
ooda_hplan_map(decide,  [decide]).
ooda_hplan_map(act,     [act]).
ooda_hplan_map(feedback,[reobserve_update]).

% ===========================================================================
% SECTION 3 — holding the methodology in Jacobian Space
% ===========================================================================

% ooda_defined(:Goal): true if the goal's predicate exists (guards optional jspace).
ooda_defined(Module:Goal) :-
    functor(Goal, Name, Arity),
    current_predicate(Module:Name/Arity).

% ooda_bootstrap: hold every OODA concept in the J-Space workspace ooda_mind, so
% the mind carries the methodology as a readable skill. Idempotent and guarded —
% if the jspace pack is unavailable the facts above are still queryable.
ooda_bootstrap :-
    catch(ooda_bootstrap_, _Err, true).

% The guarded body of the bootstrap.
ooda_bootstrap_ :-
    (   ooda_defined(jspace:jacobian_space_open(_)), ooda_defined(jspace:jacobian_space_hold(_, _, _, _))
    ->  % Open (or reset) the workspace.
        catch(jspace:jacobian_space_open(ooda_mind), _, true),
        % Hold each phase, ingredient, principle, and mapping as a concept.
        forall(ooda_phase(P, _),
            catch(jspace:jacobian_space_hold(ooda_mind, phase(P), 1.0, ooda_boyd), _, true)),
        forall(ooda_orientation_ingredient(I, _),
            catch(jspace:jacobian_space_hold(ooda_mind, orientation(I), 0.9, ooda_boyd), _, true)),
        forall(ooda_principle(Pr, _),
            catch(jspace:jacobian_space_hold(ooda_mind, principle(Pr), 0.95, ooda_boyd), _, true)),
        forall(ooda_hplan_map(O, H),
            catch(jspace:jacobian_space_hold(ooda_mind, maps_to(O, H), 0.85, ooda_boyd), _, true))
    ;   % No jspace: the facts remain available directly.
        true
    ).

% ===========================================================================
% SECTION 4 — recall and summary
% ===========================================================================

% ooda_recall(+Topic, -Items): the OODA concepts whose name or description mentions
% the topic (a substring match, case-insensitive on the atom text).
ooda_recall(Topic, Items) :-
    % Normalise the topic to an atom.
    ( atom(Topic) -> T = Topic ; term_to_atom(Topic, T) ),
    % Gather every concept whose key or text contains the topic.
    findall(concept(Kind, Key, Text),
        ( ooda_concept(Kind, Key, Text),
          ( sub_atom_ci(Key, T) ; sub_atom_ci(Text, T) ) ),
        Items).

% ooda_concept(?Kind, ?Key, ?Text): a uniform view over the four fact families.
ooda_concept(phase, P, Text) :- ooda_phase(P, Text).
ooda_concept(orientation, I, Text) :- ooda_orientation_ingredient(I, Text).
ooda_concept(principle, Pr, Text) :- ooda_principle(Pr, Text).
ooda_concept(mapping, O, Text) :- ooda_hplan_map(O, H), term_to_atom(H, Text).

% sub_atom_ci(+Atom, +Sub): case-insensitive substring test.
sub_atom_ci(Atom, Sub) :-
    downcase_atom(Atom, A), downcase_atom(Sub, S),
    sub_atom(A, _, _, _, S).

% ooda_stats(-stats(Phases, Ingredients, Principles, Held)): a summary. Held is how
% many concepts the J-Space workspace is carrying (zero if jspace is unavailable).
ooda_stats(stats(Phases, Ingredients, Principles, Held)) :-
    aggregate_all(count, ooda_phase(_, _), Phases),
    aggregate_all(count, ooda_orientation_ingredient(_, _), Ingredients),
    aggregate_all(count, ooda_principle(_, _), Principles),
    ( ooda_defined(jspace:jacobian_space_reading(_, _)),
      catch(jspace:jacobian_space_reading(ooda_mind, Reading), _, fail),
      is_list(Reading)
    -> length(Reading, Held) ; Held = 0 ).
