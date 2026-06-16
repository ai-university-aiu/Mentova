/*  Mentova — Rung 41: Narrative Reasoning Module

    Reasons about story structure: events, characters, causal links,
    narrative arcs, and plot roles.
    Pass criterion: given a story identifier, return the narrative arc
    (setup, conflict, resolution) with character roles and causal chain.
*/

% Declare this file as the 'narrative' module and list its exported predicates.
:- module(narrative, [
    % Supply 'mentova_narrative/3' as the next argument to the expression above.
    mentova_narrative/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Stories: story(Id, Title, Characters, Events, Arc)
% ---------------------------------------------------------------------------

% State a fact for 'story' with the arguments listed below.
story(tortoise_hare,
      % Continue the multi-line expression started above.
      'The Tortoise and the Hare',
      % Continue the multi-line expression started above.
      [tortoise, hare],
      % Continue the multi-line expression started above.
      [
        % Continue the multi-line expression started above.
        event(1, hare_boasts,         [character(hare)],   causes(hare_naps)),
        % Continue the multi-line expression started above.
        event(2, tortoise_runs_steady,[character(tortoise)],causes(tortoise_arrives)),
        % Continue the multi-line expression started above.
        event(3, hare_naps,           [character(hare)],   causes(hare_loses)),
        % Continue the multi-line expression started above.
        event(4, tortoise_arrives,    [character(tortoise)],causes(tortoise_wins)),
        % Continue the multi-line expression started above.
        event(5, hare_loses,          [character(hare)],   final_lesson(slow_steady_wins))
      % Close the expression opened above.
      ],
      % Continue the multi-line expression started above.
      arc(setup(hare_boasts), conflict(race_begins), resolution(tortoise_wins))).

% State a fact for 'story' with the arguments listed below.
story(boy_wolf,
      % Continue the multi-line expression started above.
      'The Boy Who Cried Wolf',
      % Continue the multi-line expression started above.
      [boy, villagers, wolf],
      % Continue the multi-line expression started above.
      [
        % Continue the multi-line expression started above.
        event(1, boy_lies_wolf,       [character(boy)],     causes(villagers_respond)),
        % Continue the multi-line expression started above.
        event(2, boy_lies_again,      [character(boy)],     causes(villagers_ignore)),
        % Continue the multi-line expression started above.
        event(3, real_wolf_comes,     [character(wolf)],    causes(boy_cries_for_help)),
        % Continue the multi-line expression started above.
        event(4, villagers_ignore,    [character(villagers)],causes(wolf_eats_sheep)),
        % Continue the multi-line expression started above.
        event(5, wolf_eats_sheep,     [character(wolf)],    final_lesson(liars_not_believed))
      % Close the expression opened above.
      ],
      % Continue the multi-line expression started above.
      arc(setup(boy_lies_wolf), conflict(real_wolf_comes), resolution(wolf_eats_sheep))).

% State a fact for 'story' with the arguments listed below.
story(cinderella,
      % Supply 'Cinderella' as the next argument to the expression above.
      'Cinderella',
      % Continue the multi-line expression started above.
      [cinderella, stepmother, prince, fairy_godmother],
      % Continue the multi-line expression started above.
      [
        % Continue the multi-line expression started above.
        event(1, cinderella_oppressed, [character(cinderella), character(stepmother)],
              % Continue the multi-line expression started above.
              causes(fairy_appears)),
        % Continue the multi-line expression started above.
        event(2, fairy_appears,        [character(fairy_godmother)],
              % Continue the multi-line expression started above.
              causes(cinderella_goes_to_ball)),
        % Continue the multi-line expression started above.
        event(3, prince_meets_cinderella, [character(prince), character(cinderella)],
              % Continue the multi-line expression started above.
              causes(prince_falls_in_love)),
        % Continue the multi-line expression started above.
        event(4, midnight_strikes,     [character(cinderella)],
              % Continue the multi-line expression started above.
              causes(cinderella_flees)),
        % Continue the multi-line expression started above.
        event(5, slipper_fits,         [character(prince), character(cinderella)],
              % Continue the multi-line expression started above.
              causes(happily_ever_after)),
        % Continue the multi-line expression started above.
        event(6, happily_ever_after,   [character(cinderella), character(prince)],
              % Continue the multi-line expression started above.
              final_lesson(virtue_rewarded))
      % Close the expression opened above.
      ],
      % Continue the multi-line expression started above.
      arc(setup(cinderella_oppressed), conflict(midnight_strikes), resolution(slipper_fits))).

% ---------------------------------------------------------------------------
% Character roles (Propp/Campbell-inspired)
% ---------------------------------------------------------------------------

% State the fact: role(tortoise, hero,    tortoise_hare).
role(tortoise, hero,    tortoise_hare).
% State the fact: role(hare,     foil,    tortoise_hare).
role(hare,     foil,    tortoise_hare).
% State the fact: role(boy,      trickster, boy_wolf).
role(boy,      trickster, boy_wolf).
% State the fact: role(villagers, victim,  boy_wolf).
role(villagers, victim,  boy_wolf).
% State the fact: role(wolf,     antagonist, boy_wolf).
role(wolf,     antagonist, boy_wolf).
% State the fact: role(cinderella, hero,  cinderella).
role(cinderella, hero,  cinderella).
% State the fact: role(stepmother, antagonist, cinderella).
role(stepmother, antagonist, cinderella).
% State the fact: role(prince,   helper,  cinderella).
role(prince,   helper,  cinderella).
% State the fact: role(fairy_godmother, helper, cinderella).
role(fairy_godmother, helper, cinderella).

% ---------------------------------------------------------------------------
% mentova_narrative(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova narrative' with the arguments listed below.
mentova_narrative(arc(StoryId), arc(Setup, Conflict, Resolution),
                  % Continue the multi-line expression started above.
                  just(narrative(story(StoryId),
                                  % Continue the multi-line expression started above.
                                  arc(setup(Setup),
                                      % Continue the multi-line expression started above.
                                      conflict(Conflict),
                                      % Continue the multi-line expression started above.
                                      resolution(Resolution))))) :-
    % State the fact: story(StoryId, _, _, _, arc(setup(Setup), conflict(Conflict), resolution(Resolution))).
    story(StoryId, _, _, _, arc(setup(Setup), conflict(Conflict), resolution(Resolution))).

% State a fact for 'mentova narrative' with the arguments listed below.
mentova_narrative(characters(StoryId), characters(StoryId, Chars),
                  % Continue the multi-line expression started above.
                  just(narrative(story(StoryId), characters(Chars)))) :-
    % State the fact: story(StoryId, _, Chars, _, _).
    story(StoryId, _, Chars, _, _).

% State a fact for 'mentova narrative' with the arguments listed below.
mentova_narrative(role(StoryId, Character), role(Character, Role),
                  % Continue the multi-line expression started above.
                  just(narrative(story(StoryId), character(Character), role(Role)))) :-
    % State a fact for 'role' with the arguments listed below.
    role(Character, Role, StoryId), !.

% State a fact for 'mentova narrative' with the arguments listed below.
mentova_narrative(causal_chain(StoryId), chain(StoryId, Chain),
                  % Continue the multi-line expression started above.
                  just(narrative(story(StoryId), causal_chain(Chain)))) :-
    % State a fact for 'story' with the arguments listed below.
    story(StoryId, _, _, Events, _),
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(E-C, (member(event(_, E, _, causes(C)), Events)), Chain).

% State a fact for 'mentova narrative' with the arguments listed below.
mentova_narrative(lesson(StoryId), lesson(Lesson),
                  % Continue the multi-line expression started above.
                  just(narrative(story(StoryId), final_lesson(Lesson)))) :-
    % State a fact for 'story' with the arguments listed below.
    story(StoryId, _, _, Events, _),
    % Succeed for each element 'event(_, _, _, final_lesson(Lesson))' that is a member of the list.
    member(event(_, _, _, final_lesson(Lesson)), Events), !.

% State a fact for 'mentova narrative' with the arguments listed below.
mentova_narrative(what_stories, stories(Ids),
                  % Continue the multi-line expression started above.
                  just(narrative(available_stories, list(Ids)))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(Id, story(Id, _, _, _, _), Ids).
