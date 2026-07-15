/*  Mentova — arc3_cognition Test Suite

    A genuine PLUnit suite for the ARC-AGI-3 cognitive-architecture module,
    which distils the ten Steps drafts into transferable principles, maps each
    principle down to a Mentova / PrologAI capability pillar, and plants the
    Kaggle north-star in Jacobian Space.

    Run with every PrologAI pack plus the Mentova source on the library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
            -g "run_tests, halt" -t "halt(1)" test/test_arc3_cognition.pl
*/

% Declare this file as a test module with no exports.
:- module(test_arc3_cognition, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(arc3_cognition)).
% Load the counting aggregate used by the count assertions.
:- use_module(library(aggregate), [aggregate_all/3]).
% Load the list membership helper used by the integrity walk.
:- use_module(library(lists), [member/2]).

% Open the test block for arc3_cognition.
:- begin_tests(arc3_cognition).

% AC-A3C-001: the north-star is the documented guiding concept text.
test(northstar_is_the_kaggle_guiding_concept) :-
    % Read the guiding concept text.
    cog_northstar(Text),
    % It is a bound, non-variable term.
    assertion(nonvar(Text)),
    % It opens with the exact Kaggle north-star phrasing from the header.
    assertion(sub_atom(Text, 0, _, _, 'How to Win the Kaggle ARC-AGI-3 competition')),
    % It names the proving ground of the public twenty-five games.
    assertion(sub_atom(Text, _, _, _, 'public twenty-five')).

% AC-A3C-002: a known principle slug resolves to a non-empty statement, and the
% catalogue holds exactly the fourteen distilled principles.
test(principles_catalogue) :-
    % A specific slug resolves to its statement.
    cog_principle(explore_before_optimise, Statement),
    % The statement is bound.
    assertion(nonvar(Statement)),
    % The statement is the documented sentence about learning before optimising.
    assertion(sub_atom(Statement, 0, _, _, 'Spend the first actions learning')),
    % Count every principle fact in the catalogue.
    aggregate_all(count, cog_principle(_, _), N),
    % There are exactly fourteen principles.
    assertion(N =:= 14).

% AC-A3C-003: a known capability pillar names its realising pack and role, and
% the catalogue holds exactly the twelve pillars.
test(pillars_catalogue) :-
    % The world-model capability is realised by the world_model pack.
    cog_pillar(world_model, Pack, Role),
    % The realising pack is world_model.
    assertion(Pack == world_model),
    % Its role is the learn-verify-repair-roll-forward transition model.
    assertion(sub_atom(Role, 0, _, _, 'learn, verify, repair')),
    % Count every pillar fact in the catalogue.
    aggregate_all(count, cog_pillar(_, _, _), N),
    % There are exactly twelve pillars.
    assertion(N =:= 12).

% AC-A3C-004: the maps relation links a principle down to the pillar that
% realises it, and one principle may be realised by more than one pillar.
test(maps_link_principles_to_pillars) :-
    % The executable-world-model principle is realised by the world-model pillar.
    assertion(cog_maps(executable_world_model, world_model)),
    % The OODA control spine is realised by the hierarchical-plan pillar.
    assertion(cog_maps(ooda_control_spine, hierarchical_plan)),
    % It is also realised by the OODA-skill pillar (a one-to-many mapping).
    assertion(cog_maps(ooda_control_spine, ooda_skill)),
    % Gather every capability the OODA control spine maps to.
    findall(Cap, cog_maps(ooda_control_spine, Cap), Caps),
    % It maps to exactly two capabilities.
    assertion(Caps == [hierarchical_plan, ooda_skill]).

% AC-A3C-005: every mapping is well-formed — its principle is a real principle
% and its capability is a real pillar, so no map dangles.
test(maps_are_referentially_intact) :-
    % Collect every mapping edge in the catalogue.
    findall(Slug-Cap, cog_maps(Slug, Cap), Edges),
    % There are fifteen mapping edges.
    assertion(length(Edges, 15)),
    % Every mapped principle slug is a declared principle.
    forall(member(S-_, Edges), assertion(cog_principle(S, _))),
    % Every mapped capability is a declared pillar.
    forall(member(_-C, Edges), assertion(cog_pillar(C, _, _))).

% AC-A3C-006: the summary counts agree with the catalogues, and the held count
% is a non-negative integer (zero here, as Jacobian Space is not loaded).
test(stats_summarise_the_catalogues) :-
    % Read the summary triple.
    cog_stats(stats(Principles, Pillars, Held)),
    % The principle count matches the catalogue.
    assertion(Principles =:= 14),
    % The pillar count matches the catalogue.
    assertion(Pillars =:= 12),
    % The held-concept count is an integer.
    assertion(integer(Held)),
    % And it is never negative.
    assertion(Held >= 0).

% AC-A3C-007: bootstrapping the mind's north-star is total and idempotent — it
% succeeds, and succeeds again on a second call, changing nothing observable.
test(bootstrap_is_total_and_idempotent) :-
    % The first bootstrap succeeds.
    assertion(cog_bootstrap),
    % A second bootstrap also succeeds (idempotent, guarded, side-effect-safe).
    assertion(cog_bootstrap),
    % The catalogues are unchanged after bootstrapping.
    cog_stats(stats(Principles, Pillars, _)),
    % Still fourteen principles.
    assertion(Principles =:= 14),
    % Still twelve pillars.
    assertion(Pillars =:= 12).

% Close the test block for arc3_cognition.
:- end_tests(arc3_cognition).
