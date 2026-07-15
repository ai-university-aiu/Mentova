/*  Mentova — Narrative Reasoning Test Suite  (narrative module)

    Behavioural PLUnit tests for the pure narrative-reasoning module.
    The module is stateless (no lattice, no dynamic facts), so each test
    calls mentova_narrative/3 with a documented query and asserts the
    exact Result and Justification hand-computed from the story facts.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" \
              /home/ccaitwo/Mentova/test/test_narrative.pl
*/

% Declare this file as a test module with no exports.
:- module(test_narrative, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(narrative)).

% Open the test block for narrative.
:- begin_tests(narrative).

% AC-NAR-001: the arc query returns the story's setup, conflict, and resolution.
test(arc_tortoise_hare) :-
    % Ask for the narrative arc of the tortoise-and-hare story.
    mentova_narrative(arc(tortoise_hare), Result, Just),
    % The arc unpacks the three story beats in order.
    assertion(Result == arc(hare_boasts, race_begins, tortoise_wins)),
    % The justification names the story and mirrors the three beats.
    assertion(Just == just(narrative(story(tortoise_hare),
                                     arc(setup(hare_boasts),
                                         conflict(race_begins),
                                         resolution(tortoise_wins))))).

% AC-NAR-002: the arc query works for a different story too.
test(arc_boy_wolf) :-
    % Ask for the narrative arc of the boy-who-cried-wolf story.
    mentova_narrative(arc(boy_wolf), Result, _),
    % The arc reports that story's own three beats.
    assertion(Result == arc(boy_lies_wolf, real_wolf_comes, wolf_eats_sheep)).

% AC-NAR-003: the characters query lists the cast of a story.
test(characters_boy_wolf) :-
    % Ask for the characters of the boy-who-cried-wolf story.
    mentova_narrative(characters(boy_wolf), Result, Just),
    % The result pairs the story id with its exact character list.
    assertion(Result == characters(boy_wolf, [boy, villagers, wolf])),
    % The justification restates the character list.
    assertion(Just == just(narrative(story(boy_wolf), characters([boy, villagers, wolf])))).

% AC-NAR-004: the role query maps a character to its narrative role.
test(role_tortoise_is_hero) :-
    % Ask for the tortoise's role in its story.
    mentova_narrative(role(tortoise_hare, tortoise), Result, _),
    % The tortoise is cast as the hero.
    assertion(Result == role(tortoise, hero)).

% AC-NAR-005: the role query resolves an antagonist in another story.
test(role_wolf_is_antagonist) :-
    % Ask for the wolf's role in the boy-who-cried-wolf story.
    mentova_narrative(role(boy_wolf, wolf), Result, _),
    % The wolf is cast as the antagonist.
    assertion(Result == role(wolf, antagonist)).

% AC-NAR-006: the causal-chain query collects only cause-effect events, dropping the lesson event.
test(causal_chain_tortoise_hare) :-
    % Ask for the causal chain of the tortoise-and-hare story.
    mentova_narrative(causal_chain(tortoise_hare), Result, _),
    % The chain is the four causes(...) events as Event-Effect pairs, in story order.
    assertion(Result == chain(tortoise_hare,
                              [hare_boasts-hare_naps,
                               tortoise_runs_steady-tortoise_arrives,
                               hare_naps-hare_loses,
                               tortoise_arrives-tortoise_wins])).

% AC-NAR-007: the lesson query returns the story's final moral.
test(lesson_boy_wolf) :-
    % Ask for the moral of the boy-who-cried-wolf story.
    mentova_narrative(lesson(boy_wolf), Result, Just),
    % The moral is that liars are not believed.
    assertion(Result == lesson(liars_not_believed)),
    % The justification attributes the moral to the story.
    assertion(Just == just(narrative(story(boy_wolf), final_lesson(liars_not_believed)))).

% AC-NAR-008: the what_stories query enumerates every known story id.
test(what_stories_enumerates_all) :-
    % Ask which stories the module knows.
    mentova_narrative(what_stories, Result, _),
    % All three stories are listed in declaration order.
    assertion(Result == stories([tortoise_hare, boy_wolf, cinderella])).

% AC-NAR-009: an unknown story id yields no arc.
test(unknown_story_has_no_arc, [fail]) :-
    % Asking for a story that does not exist must fail rather than fabricate.
    mentova_narrative(arc(no_such_story), _, _).

% Close the test block for narrative.
:- end_tests(narrative).
