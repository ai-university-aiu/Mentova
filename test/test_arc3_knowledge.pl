/*  Mentova — ARC-AGI-3 Game Knowledge Transfer Test Suite  (arc3_knowledge)

    Exercises the arc3_knowledge module's public query interface against the
    distilled per-game facts in knowledge/arc3_games.pl. Every capability the
    lattice / Causalontology / J-Space provide is optional, so on this bare load
    (no lattice, no causal store) the module runs in registry-only mode: the
    queries read straight from the loaded facts, and the boot entry still
    succeeds. These behavioural checks pin the documented outputs so future rot
    is visible.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_arc3_knowledge.pl
*/

%% Declare this file as a test module with no exports.
:- module(test_arc3_knowledge, []).
%% Load the PLUnit test framework.
:- use_module(library(plunit)).
%% Load the module under test from the library path.
:- use_module(library(arc3_knowledge)).

%% Open the test block for arc3_knowledge.
:- begin_tests(arc3_knowledge).

%% AC-A3K-001: a3_stats reports the transferred totals as a stats/4 term.
test(stats_totals) :-
    %% Read back how much knowledge was transferred.
    a3_stats(stats(Games, Objects, Relations, Hazards)),
    %% The knowledge base holds exactly the twenty-five ARC-AGI-3 games.
    assertion(Games =:= 25),
    %% Every count is a plain integer.
    assertion(integer(Objects)),
    %% Relations are counted as an integer too.
    assertion(integer(Relations)),
    %% Hazards are counted as an integer too.
    assertion(integer(Hazards)),
    %% Each of the twenty-five games contributes at least one object.
    assertion(Objects >= Games),
    %% Each of the twenty-five games contributes at least one relation.
    assertion(Relations >= Games),
    %% At least one game names a hazard.
    assertion(Hazards > 0).

%% AC-A3K-002: a3_about renders the Locksmith game's identity as a dict.
test(about_locksmith) :-
    %% Ask for the ls20 game's identity.
    a3_about(ls20, About),
    %% It reads back name, genre, win-levels, and control scheme exactly.
    assertion(About == arc3(ls20, 'Locksmith', transform_deliver,
                            win_levels(7), controls(move4))).

%% AC-A3K-003: a3_about renders a second, click-controlled game correctly.
test(about_centroid_carrier) :-
    %% Ask for the r11l game's identity.
    a3_about(r11l, About),
    %% The easiest game reads back as a six-level click carrier-delivery puzzle.
    assertion(About == arc3(r11l, 'Centroid-Carrier', carrier_delivery,
                            win_levels(6), controls(click))).

%% AC-A3K-004: a3_about fails for a game identifier that does not exist.
test(about_unknown_game_fails, [fail]) :-
    %% There is no game called no_such_game, so the query must fail.
    a3_about(no_such_game, _).

%% AC-A3K-005: a3_why cites the guide file a game's relation came from.
test(why_cites_guide_file) :-
    %% Ask why Mentova believes stepping on a ring refills the timer in ls20.
    a3_why(ls20, step_on(ring), refill(timer), Guide),
    %% The provenance is the real Locksmith guide file.
    assertion(Guide == 'assets/ls20.txt').

%% AC-A3K-006: a3_why refuses a relation the game does not hold.
test(why_rejects_absent_relation, [fail]) :-
    %% ls20 has no such relation, so the citation query must fail.
    a3_why(ls20, step_on(nonexistent_tile), win(level), _).

%% AC-A3K-007: a3_recall gathers every ls20 item mentioning "ring".
test(recall_ring) :-
    %% Collect everything the mind knows about the "ring" keyword in ls20.
    a3_recall(ls20, ring, Items),
    %% Exactly three items mention a ring: an object, a relation, and a tip.
    assertion(length(Items, 3)),
    %% The ring object and its collectible role are present.
    assertion(memberchk(object(ring, collectible), Items)),
    %% The ring's cause-effect relation (refills the step timer) is present.
    assertion(memberchk(relation(step_on(ring), refill(timer)), Items)),
    %% The mentor tip about collecting a ring is present.
    assertion(memberchk(tip('collect a ring to refill the step timer before it runs out'), Items)).

%% AC-A3K-008: a3_recall returns the empty list for an unmentioned keyword.
test(recall_no_match) :-
    %% Ask about a keyword no ls20 fact mentions.
    a3_recall(ls20, zzq_absent_keyword, Items),
    %% Nothing matches, so the result is empty.
    assertion(Items == []).

%% AC-A3K-009: a3_knows reads a known cause-effect relation for a game.
test(knows_single_relation) :-
    %% In registry-only mode a3_knows reads the loaded relation facts.
    assertion(a3_knows(ls20, step_on(ring), refill(timer))),
    %% Another Locksmith relation: a changer tile cycles a key property.
    assertion(a3_knows(ls20, step_on(changer), cycle(key_property))).

%% AC-A3K-010: a3_knows enumerates all five of the Locksmith relations.
test(knows_all_relations) :-
    %% Collect every cause-effect pair Mentova holds for ls20.
    findall(Cause-Effect, a3_knows(ls20, Cause, Effect), Pairs),
    %% Locksmith has exactly five documented relations.
    assertion(length(Pairs, 5)),
    %% Delivering a matching key onto the target wins the level.
    assertion(memberchk(deliver(matching_key, target)-win(level), Pairs)),
    %% A pusher shoves the carried block on contact.
    assertion(memberchk(contact(pusher)-shove(block), Pairs)).

%% AC-A3K-011: a3_bootstrap is a safe one-call boot that succeeds bare.
test(bootstrap_succeeds) :-
    %% The startup entry ingests everything, tolerating a missing lattice.
    assertion(a3_bootstrap),
    %% After booting, the queries still answer from the loaded facts.
    assertion(a3_about(dc22, arc3(dc22, 'Toggle-Door Maze', lock_and_key,
                                  win_levels(6), controls(move_click)))).

%% Close the test block for arc3_knowledge.
:- end_tests(arc3_knowledge).
