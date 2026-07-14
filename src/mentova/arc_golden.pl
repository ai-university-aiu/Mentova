/*  Mentova — Golden Game Environment Reference loader

    For each of the twenty-five ARC-AGI-3 games there is a unified GOLDEN GAME
    ENVIRONMENT REFERENCE FILE at /home/ccaitwo/ARC-AGI-3/<game>.txt: the practical mentor
    guide followed by that game's sections cut from all ten ARC-AGI-3_Steps_Draft
    documents (the former <game>_steps.txt, merged in), one game per file, no cross-game
    spillover. The GOLDEN GAME ENVIRONMENT REFERENCE RULE requires that, before an AI
    Mentor Bridge run to secure status:won for a game, the matching golden file is read
    and its ENTIRE contents are loaded into Jacobian Space (J-Space) so the steps stay
    at the forefront during the run. This module is that loader.

    Predicates:
      agp_golden_file/2   -- +Game, -Path       (the golden file path for a game)
      agp_load_golden/1   -- +Game              (load the whole file into J-Space)
      agp_load_golden/2   -- +Game, -Count      (as above, returning lines held)
      agp_golden_lines/2  -- +Game, -Lines      (the file's non-empty lines)
*/

:- module(arc_golden, [
    agp_golden_file/2,
    agp_load_golden/1,
    agp_load_golden/2,
    agp_golden_lines/2
]).

:- use_module(library(readutil), [read_file_to_string/3]).
:- use_module(library(lists)).

% Load the Jacobian-Space workspace, tolerating its absence at load time.
:- ( catch(use_module(library(jacobian_space), [jacobian_space_open/1, jacobian_space_hold/4]), _, fail) -> true ; true ).

% agp_golden_dir(-Dir): where the golden reference files live.
agp_golden_dir('/home/ccaitwo/ARC-AGI-3').

% agp_golden_file(+Game, -Path): the golden reference file path for a game. The golden
% sets were unified — each game's distilled draft sections were merged onto the end of
% its practical mentor guide, so the single file is <game>.txt (the former
% <game>_steps.txt was appended into it and removed).
agp_golden_file(Game, Path) :-
    agp_golden_dir(Dir),
    atomic_list_concat([Dir, '/', Game, '.txt'], Path).

% agp_workspace(+Game, -Workspace): the J-Space workspace name for a game's golden
% reference — one workspace per game so its steps are held apart.
agp_workspace(Game, Workspace) :-
    atom_concat(golden_, Game, Workspace).

% agp_golden_lines(+Game, -Lines): the golden file's non-empty lines, in order.
agp_golden_lines(Game, Lines) :-
    agp_golden_file(Game, Path),
    exists_file(Path),
    read_file_to_string(Path, Str, []),
    split_string(Str, "\n", "", Raw),
    findall(Line,
        ( member(S0, Raw), string_trim_(S0, S), S \== "", atom_string(Line, S) ),
        Lines).

% string_trim_(+In, -Out): trim surrounding whitespace from a string.
string_trim_(In, Out) :-
    split_string(In, "", "\s\t\r", [Out]).

% agp_load_golden(+Game): load the whole golden reference file into J-Space (fail-safe).
agp_load_golden(Game) :-
    ( catch(agp_load_golden(Game, _), _, fail) -> true ; true ).

% agp_load_golden(+Game, -Count): open the game's golden J-Space workspace and hold
% every non-empty line of its golden reference file as a concept, so the steps are at
% the forefront during the Mentor Bridge run. Count is the number of lines held.
% Guarded end to end: a missing file or an absent J-Space never throws.
agp_load_golden(Game, Count) :-
    ( agp_golden_lines(Game, Lines) -> true ; Lines = [] ),
    agp_workspace(Game, Workspace),
    ( agp_jspace_ready
    ->  catch(jspace:jacobian_space_open(Workspace), _, true),
        % A header concept naming the reference, then each line as a numbered step.
        catch(jspace:jacobian_space_hold(Workspace, golden_reference(Game), 1.0, arc_golden), _, true),
        foldl(agp_hold_line(Workspace, Game), Lines, 1, _),
        length(Lines, Count)
    ;   Count = 0
    ).

% agp_hold_line(+Workspace, +Game, +Line, +N0, -N1): hold one golden line as a concept.
agp_hold_line(Workspace, Game, Line, N0, N1) :-
    catch(jspace:jacobian_space_hold(Workspace, golden_step(Game, N0, Line), 1.0, arc_golden), _, true),
    N1 is N0 + 1.

% agp_jspace_ready: the J-Space workspace predicates are available.
agp_jspace_ready :-
    current_predicate(jspace:jacobian_space_open/1),
    current_predicate(jspace:jacobian_space_hold/4).
