/*  Mentova — Rung 41: Narrative Reasoning Module

    Reasons about story structure: events, characters, causal links,
    narrative arcs, and plot roles.
    Pass criterion: given a story identifier, return the narrative arc
    (setup, conflict, resolution) with character roles and causal chain.
*/

:- module(narrative, [
    mentova_narrative/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Stories: story(Id, Title, Characters, Events, Arc)
% ---------------------------------------------------------------------------

story(tortoise_hare,
      'The Tortoise and the Hare',
      [tortoise, hare],
      [
        event(1, hare_boasts,         [character(hare)],   causes(hare_naps)),
        event(2, tortoise_runs_steady,[character(tortoise)],causes(tortoise_arrives)),
        event(3, hare_naps,           [character(hare)],   causes(hare_loses)),
        event(4, tortoise_arrives,    [character(tortoise)],causes(tortoise_wins)),
        event(5, hare_loses,          [character(hare)],   final_lesson(slow_steady_wins))
      ],
      arc(setup(hare_boasts), conflict(race_begins), resolution(tortoise_wins))).

story(boy_wolf,
      'The Boy Who Cried Wolf',
      [boy, villagers, wolf],
      [
        event(1, boy_lies_wolf,       [character(boy)],     causes(villagers_respond)),
        event(2, boy_lies_again,      [character(boy)],     causes(villagers_ignore)),
        event(3, real_wolf_comes,     [character(wolf)],    causes(boy_cries_for_help)),
        event(4, villagers_ignore,    [character(villagers)],causes(wolf_eats_sheep)),
        event(5, wolf_eats_sheep,     [character(wolf)],    final_lesson(liars_not_believed))
      ],
      arc(setup(boy_lies_wolf), conflict(real_wolf_comes), resolution(wolf_eats_sheep))).

story(cinderella,
      'Cinderella',
      [cinderella, stepmother, prince, fairy_godmother],
      [
        event(1, cinderella_oppressed, [character(cinderella), character(stepmother)],
              causes(fairy_appears)),
        event(2, fairy_appears,        [character(fairy_godmother)],
              causes(cinderella_goes_to_ball)),
        event(3, prince_meets_cinderella, [character(prince), character(cinderella)],
              causes(prince_falls_in_love)),
        event(4, midnight_strikes,     [character(cinderella)],
              causes(cinderella_flees)),
        event(5, slipper_fits,         [character(prince), character(cinderella)],
              causes(happily_ever_after)),
        event(6, happily_ever_after,   [character(cinderella), character(prince)],
              final_lesson(virtue_rewarded))
      ],
      arc(setup(cinderella_oppressed), conflict(midnight_strikes), resolution(slipper_fits))).

% ---------------------------------------------------------------------------
% Character roles (Propp/Campbell-inspired)
% ---------------------------------------------------------------------------

role(tortoise, hero,    tortoise_hare).
role(hare,     foil,    tortoise_hare).
role(boy,      trickster, boy_wolf).
role(villagers, victim,  boy_wolf).
role(wolf,     antagonist, boy_wolf).
role(cinderella, hero,  cinderella).
role(stepmother, antagonist, cinderella).
role(prince,   helper,  cinderella).
role(fairy_godmother, helper, cinderella).

% ---------------------------------------------------------------------------
% mentova_narrative(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_narrative(arc(StoryId), arc(Setup, Conflict, Resolution),
                  just(narrative(story(StoryId),
                                  arc(setup(Setup),
                                      conflict(Conflict),
                                      resolution(Resolution))))) :-
    story(StoryId, _, _, _, arc(setup(Setup), conflict(Conflict), resolution(Resolution))).

mentova_narrative(characters(StoryId), characters(StoryId, Chars),
                  just(narrative(story(StoryId), characters(Chars)))) :-
    story(StoryId, _, Chars, _, _).

mentova_narrative(role(StoryId, Character), role(Character, Role),
                  just(narrative(story(StoryId), character(Character), role(Role)))) :-
    role(Character, Role, StoryId), !.

mentova_narrative(causal_chain(StoryId), chain(StoryId, Chain),
                  just(narrative(story(StoryId), causal_chain(Chain)))) :-
    story(StoryId, _, _, Events, _),
    findall(E-C, (member(event(_, E, _, causes(C)), Events)), Chain).

mentova_narrative(lesson(StoryId), lesson(Lesson),
                  just(narrative(story(StoryId), final_lesson(Lesson)))) :-
    story(StoryId, _, _, Events, _),
    member(event(_, _, _, final_lesson(Lesson)), Events), !.

mentova_narrative(what_stories, stories(Ids),
                  just(narrative(available_stories, list(Ids)))) :-
    findall(Id, story(Id, _, _, _, _), Ids).
