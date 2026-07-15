/*  Mentova — Logical Reasoning Module Test Suite  (Rung 12)

    Behavioural PLUnit suite for src/mentova/logical.pl, the forward-chaining
    rule engine that saturates a fact set and reports the rule chain.

    Run with the full library path (every PrologAI pack plus the Mentova source):
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
            -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_logical.pl
*/

%% Declare this file as a test module exporting nothing.
:- module(test_logical, []).
%% Load the PLUnit test framework.
:- use_module(library(plunit)).
%% Load the module under test from the library path.
:- use_module(library(logical)).

%% Open the test block for the logical module.
:- begin_tests(logical).

%% chain saturates a bird's facts through the full transitive rule chain.
test(chain_saturates_bird_facts) :-
    %% Forward-chain from a bird that is not flightless.
    mentova_logical(chain([is_bird(tweety), not_flightless(tweety)]), derived(AllFacts, _Log), _J),
    %% is_bird gives is_animal by the animal rule.
    assertion(memberchk(is_animal(tweety), AllFacts)),
    %% is_bird and not_flightless together give can_fly.
    assertion(memberchk(can_fly(tweety), AllFacts)),
    %% is_bird gives is_warm_blooded.
    assertion(memberchk(is_warm_blooded(tweety), AllFacts)),
    %% is_animal gives is_living, chaining one step deeper.
    assertion(memberchk(is_living(tweety), AllFacts)),
    %% is_living gives needs_water, chaining a further step.
    assertion(memberchk(needs_water(tweety), AllFacts)),
    %% can_fly and is_animal together give is_predator.
    assertion(memberchk(is_predator(tweety), AllFacts)).

%% chain never invents facts whose conditions were not met.
test(chain_does_not_overreach) :-
    %% Forward-chain from a lone bird with no smallness fact.
    mentova_logical(chain([is_bird(robin)]), derived(AllFacts, _Log), _J),
    %% Without not_flightless the flight rule must not fire.
    assertion(\+ memberchk(can_fly(robin), AllFacts)),
    %% Without is_small the prey rule must not fire.
    assertion(\+ memberchk(is_prey(robin), AllFacts)),
    %% is_mammal is a base fact type no rule can conclude.
    assertion(\+ memberchk(is_mammal(robin), AllFacts)).

%% chain logs each firing with its head and the conditions that triggered it.
test(chain_log_records_rule_chain) :-
    %% Forward-chain from a bird that is not flightless.
    mentova_logical(chain([is_bird(tweety), not_flightless(tweety)]), derived(_AllFacts, Log), _J),
    %% The animal firing records is_bird as its sole condition.
    assertion(memberchk(fired(is_animal(tweety), from([is_bird(tweety)])), Log)),
    %% The flight firing records both of its conditions in order.
    assertion(memberchk(fired(can_fly(tweety), from([is_bird(tweety), not_flightless(tweety)])), Log)),
    %% The predator firing depends on the earlier-derived can_fly and is_animal.
    assertion(memberchk(fired(is_predator(tweety), from([can_fly(tweety), is_animal(tweety)])), Log)).

%% chain returns the glass-box justification wrapping the init facts and the log.
test(chain_justification_structure) :-
    %% Forward-chain from a single bird.
    mentova_logical(chain([is_bird(tweety)]), derived(_AllFacts, Log), Justification),
    %% The justification names the init facts and carries the fired-rules log verbatim.
    assertion(Justification == just(forward_chain(init([is_bird(tweety)]), rules_fired(Log)))).

%% check answers yes for a fact reachable through several rule steps.
test(check_reports_yes_for_derivable) :-
    %% Ask whether a flying bird is a predator.
    mentova_logical(check(is_predator(tweety), [is_bird(tweety), not_flightless(tweety)]), Answer, _J),
    %% is_predator is reachable, so the answer is yes.
    assertion(Answer == yes).

%% check answers no for a fact whose conditions are never met.
test(check_reports_no_for_underivable) :-
    %% Ask whether a bird with no smallness fact is prey.
    mentova_logical(check(is_prey(tweety), [is_bird(tweety), not_flightless(tweety)]), Answer, _J),
    %% is_prey needs is_small, which is absent, so the answer is no.
    assertion(Answer == no).

%% check follows the fish branch from is_fish all the way to needs_water.
test(check_follows_fish_branch) :-
    %% Ask whether a fish needs water.
    mentova_logical(check(needs_water(nemo), [is_fish(nemo)]), Answer, _J),
    %% is_fish gives is_animal gives is_living gives needs_water, so yes.
    assertion(Answer == yes).

%% check reports the yes-branch justification with the answer embedded.
test(check_justification_reports_answer) :-
    %% Ask whether a fish is an animal.
    mentova_logical(check(is_animal(nemo), [is_fish(nemo)]), Answer, Justification),
    %% The answer is yes.
    assertion(Answer == yes),
    %% The justification records the queried fact, the init facts, and the yes result.
    assertion(Justification = just(check(is_animal(nemo), init([is_fish(nemo)]), result(yes), log(_Log)))).

%% prove reports proved for a goal that follows from the facts.
test(prove_reports_proved) :-
    %% Ask to prove that a bird is living.
    mentova_logical(prove(is_living(tweety), [is_bird(tweety)]), Answer, _J),
    %% is_bird gives is_animal gives is_living, so it is proved.
    assertion(Answer == proved).

%% prove reports not_provable for a goal no rule can reach.
test(prove_reports_not_provable) :-
    %% Ask to prove that a bird is a mammal.
    mentova_logical(prove(is_mammal(tweety), [is_bird(tweety)]), Answer, _J),
    %% No rule concludes is_mammal, so it is not provable.
    assertion(Answer == not_provable).

%% prove fires the two-condition prey rule once both conditions are present.
test(prove_prey_needs_both_conditions) :-
    %% Ask to prove a small bird is prey, supplying both smallness and birdhood.
    mentova_logical(prove(is_prey(sparrow), [is_small(sparrow), is_bird(sparrow)]), Answer, _J),
    %% is_bird gives is_animal, and with is_small the prey rule fires, so proved.
    assertion(Answer == proved).

%% Close the test block for the logical module.
:- end_tests(logical).
