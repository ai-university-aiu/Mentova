/*  Mentova — Elementary Curriculum Loader for the Causalontology Lattice

    This module joins three pieces into one accessible whole:

      curriculum_path_registry.pl     SourceId -> absolute file path
      curriculum_elementary_facts.pl  the understood facts + sound CROs
      reference_library.pl            streamed, on-demand look-it-up access

    On import it (1) registers every curriculum source with the Reference
    Library so citations resolve and the bulk corpus is searchable, and
    (2) when the PrologAI lattice packs are present, anchors each understood
    fact as a node_fact and each sound relation as a Causal Relation Object,
    with its source(SourceId, Line) citation carried as provenance. When the
    packs are absent (a bare tool run), the same knowledge stays queryable
    directly through the ci_* helpers, so this file is useful and testable
    on its own.

    The Reference Library and lattice are the two tiers of the Knowledge
    Storage Policy: understood facts in the head, the big corpus on the
    shelf. Mentova Chat reaches both through the query predicates below.
*/

% Declare this file as the curriculum lattice loader module and its exports.
:- module(curriculum_lattice, [
    % Register every curriculum source with the Reference Library.
    ci_register_sources/0,
    % Anchor the understood facts and CROs into a named lattice nexus.
    ci_import_elementary/1,
    % Import into the default curriculum nexus name.
    ci_import_elementary/0,
    % The one-call bootstrap for Mentova Chat startup.
    ci_chat_bootstrap/0,
    % A word this grade level teaches.
    ci_word/2,
    % The sorted vocabulary of a grade level.
    ci_words_for_grade/2,
    % The grade levels at which a word is taught.
    ci_grade_of_word/2,
    % A CCSS mathematics domain for a grade, with its code.
    ci_standard/3,
    % A PTKLF foundation: domain, identifier, and name.
    ci_ptklf/3,
    % A learned sound relation: a subject makes a sound.
    ci_sound/2,
    % Search the whole registered library (walls, standards, bulk manifest).
    ci_search/2,
    % The honest "why?": resolve a word to its cited source line.
    ci_why/3,
    % Resolve any citation to its exact source line of text.
    ci_cite/2,
    % A compact tally of what has been imported.
    ci_stats/1
]).

% Load the path registry that maps SourceIds to absolute paths.
:- use_module('curriculum_path_registry', [ci_source/3, ci_corpus_root/1]).
% Load the generated understood facts and sound CROs (elementary band).
% Loaded for their own module namespace; aggregated below by ci_any_fact/4.
:- use_module('curriculum_elementary_facts', []).
% Load the generated understood facts (Middle School / Junior High band).
:- use_module('curriculum_middle_facts', []).
% Load the generated understood facts (High School band, Grades 9-12).
:- use_module('curriculum_high_facts', []).
% Load the generated understood facts (Higher Education band, Grades 13-20).
:- use_module('curriculum_higher_ed_facts', []).
% Load the Reference Library for registration, search, and citation reading.
:- use_module('../../src/mentova/reference_library',
              [rl_register/2, rl_search/2, rl_citation_text/2]).
% Import list helpers used below.
:- use_module(library(lists), [member/2]).

% The default nexus address for the curriculum's understood facts.
ci_default_nexus('locus://mentova/curriculum').

% ---------------------------------------------------------------------------
% ci_any_fact/4 and ci_any_cro/5 — union the per-band generated fact modules
% so every query and the anchoring loop see all bands (elementary + middle)
% as one body of knowledge. New bands are added by loading one more module
% and adding one clause here.
% ---------------------------------------------------------------------------

% Define ci_any_fact: an understood fact from the elementary band.
ci_any_fact(Grade, Relation, Args, Citation) :-
    % Read it from the elementary facts module.
    curriculum_elementary_facts:ci_fact(Grade, Relation, Args, Citation).
% Define ci_any_fact: an understood fact from the middle-school band.
ci_any_fact(Grade, Relation, Args, Citation) :-
    % Read it from the middle-school facts module.
    curriculum_middle_facts:ci_fact(Grade, Relation, Args, Citation).
% Define ci_any_fact: an understood fact from the high-school band.
ci_any_fact(Grade, Relation, Args, Citation) :-
    % Read it from the high-school facts module.
    curriculum_high_facts:ci_fact(Grade, Relation, Args, Citation).
% Define ci_any_fact: an understood fact from the higher-education band.
ci_any_fact(Grade, Relation, Args, Citation) :-
    % Read it from the higher-education facts module.
    curriculum_higher_ed_facts:ci_fact(Grade, Relation, Args, Citation).

% Define ci_any_cro: a sound CRO from the elementary band.
ci_any_cro(Grade, Kind, Subject, Sound, Citation) :-
    % Read it from the elementary facts module.
    curriculum_elementary_facts:ci_cro(Grade, Kind, Subject, Sound, Citation).
% Define ci_any_cro: a sound CRO from the middle-school band.
ci_any_cro(Grade, Kind, Subject, Sound, Citation) :-
    % Read it from the middle-school facts module.
    curriculum_middle_facts:ci_cro(Grade, Kind, Subject, Sound, Citation).
% Define ci_any_cro: a sound CRO from the high-school band.
ci_any_cro(Grade, Kind, Subject, Sound, Citation) :-
    % Read it from the high-school facts module.
    curriculum_high_facts:ci_cro(Grade, Kind, Subject, Sound, Citation).
% Define ci_any_cro: a sound CRO from the higher-education band.
ci_any_cro(Grade, Kind, Subject, Sound, Citation) :-
    % Read it from the higher-education facts module.
    curriculum_higher_ed_facts:ci_cro(Grade, Kind, Subject, Sound, Citation).

% ---------------------------------------------------------------------------
% ci_register_sources/0 — make every source known to the Reference Library
% ---------------------------------------------------------------------------

% Define ci_register_sources: register each existing source, skip the missing.
ci_register_sources :-
    % Visit every registered source path.
    forall(ci_source(Id, Path, _Kind),
           % Register a source only when its file is actually present.
           ( exists_file(Path)
           % Register the present file with the Reference Library.
           -> rl_register(Id, Path)
           % A missing file is skipped rather than failing the whole import.
           ;  true )).

% ---------------------------------------------------------------------------
% ci_import_elementary/1 — anchor understood facts + CROs into a nexus
% ---------------------------------------------------------------------------

% Define ci_import_elementary/0: import into the default curriculum nexus.
ci_import_elementary :-
    % Look up the default nexus address.
    ci_default_nexus(Nexus),
    % Delegate to the addressed importer.
    ci_import_elementary(Nexus).

% Define ci_import_elementary/1: register sources, then anchor into the nexus.
ci_import_elementary(Nexus) :-
    % Always make the sources searchable and citations resolvable first.
    ci_register_sources,
    % When the lattice packs are present, open and select the nexus.
    ci_maybe_open_nexus(Nexus),
    % Anchor each understood fact as a node_fact (best effort).
    ci_anchor_facts(Count),
    % Assert each sound relation as a Causal Relation Object (best effort).
    ci_assert_cros(CroCount),
    % Report what was anchored, for a glass-box startup log.
    format("curriculum: registered sources; anchored ~w facts, ~w CROs into ~w~n",
           [Count, CroCount, Nexus]).

% Define ci_maybe_open_nexus: open + select the nexus if the lattice is loaded.
ci_maybe_open_nexus(Nexus) :-
    % Only touch the lattice when its predicates are actually defined.
    (   ci_defined(lattice:lattice_open(_, _)),
        % And when the node_facts default-nexus setter is defined.
        ci_defined(node_facts:set_default_nexus(_))
    % Open the nexus and make it the default target for anchoring.
    ->  catch(( lattice:lattice_open(Nexus, N),
                % Select the opened nexus as the anchoring destination.
                node_facts:set_default_nexus(N) ),
              % Any lattice error leaves us in registry-only mode.
              _, true)
    % No lattice: registry-only mode, nothing to open.
    ;   true ).

% Define ci_anchor_facts: anchor every understood fact, counting successes.
ci_anchor_facts(Count) :-
    % Only anchor when the node_facts anchor predicate is available.
    (   ci_defined(node_facts:anchor_node(_, _, _, _))
    % Anchor each fact with its grade and citation as referents.
    ->  aggregate_all(count,
            ( ci_any_fact(Grade, Relation, Args, Citation),
              % Anchor one fact; a per-fact error is tolerated, not fatal.
              catch(node_facts:anchor_node(Relation, Args,
                                           [grade(Grade), Citation], _), _, fail) ),
            Count)
    % No lattice available: nothing anchored, but the facts stay queryable.
    ;   Count = 0 ).

% Define ci_assert_cros: assert each sound relation as a reified CRO.
ci_assert_cros(Count) :-
    % Only assert when the co_core CRO constructor is available.
    (   ci_defined(co_core:co_new_cro(_, _, _, _, _, _, _, _))
    % Build one CRO per sound relation, carrying the citation as provenance.
    ->  aggregate_all(count,
            ( ci_any_cro(Grade, makes_sound, Subject, Sound, Citation),
              % A subject "makes" a sound: cause -> effect, high strength.
              catch(co_core:co_new_cro([makes(Subject)], [sound(Sound)],
                        temporal(0, 0, instant), sufficient, 0.9,
                        [grade(Grade)], prov(curriculum, Citation, 0.9), _),
                    _, fail) ),
            Count)
    % No co_core available: the sound relations stay queryable via ci_sound/2.
    ;   Count = 0 ).

% Define ci_defined: true when Head's predicate is defined, never throwing.
ci_defined(Head) :-
    % Ask for the predicate property, treating any error as "not defined".
    catch(predicate_property(Head, defined), _, fail).

% ---------------------------------------------------------------------------
% ci_chat_bootstrap/0 — the safe one-call entry point for Mentova Chat
% ---------------------------------------------------------------------------

% Define ci_chat_bootstrap: import the curriculum, never throwing on failure.
ci_chat_bootstrap :-
    % Guard the whole import so a curriculum problem can never crash the chat.
    catch(ci_import_elementary, Err,
          % On any error, report it and carry on with the chat unaffected.
          ( print_message(warning, Err), true )).

% ---------------------------------------------------------------------------
% Query API — used by Mentova Chat to answer, and by tests to verify
% ---------------------------------------------------------------------------

% Define ci_word: Word is taught at grade level Grade.
ci_word(Grade, Word) :-
    % A vocabulary fact names the word and its category.
    ci_any_fact(Grade, vocabulary, [Word, _Category], _).

% Define ci_words_for_grade: the sorted, de-duplicated vocabulary of a grade.
ci_words_for_grade(Grade, Words) :-
    % Collect every word taught at this grade.
    findall(W, ci_any_fact(Grade, vocabulary, [W, _], _), Raw),
    % Sort and de-duplicate for a stable answer.
    sort(Raw, Words).

% Define ci_grade_of_word: the grade levels at which a word appears.
ci_grade_of_word(Word, Grades) :-
    % Collect every grade whose vocabulary includes the word.
    findall(G, ci_any_fact(G, vocabulary, [Word, _], _), Raw),
    % Sort and de-duplicate the grade list.
    sort(Raw, Grades).

% Define ci_standard: a CCSS mathematics Domain (with Code) for a Grade.
ci_standard(Grade, Domain, Code) :-
    % A math_domain fact names the domain and its standards code.
    ci_any_fact(Grade, math_domain, [Domain, Code], _).

% Define ci_ptklf: a PTKLF Foundation named within a Domain by identifier.
ci_ptklf(Domain, FoundationId, Name) :-
    % A ptklf_foundation fact belongs to the preschool/TK band.
    ci_any_fact(preschool_tk, ptklf_foundation, [Domain, FoundationId, Name], _).

% Define ci_sound: Subject makes Sound, from a learned sound CRO.
ci_sound(Subject, Sound) :-
    % Read the subject and sound off a makes_sound relation.
    ci_any_cro(_Grade, makes_sound, Subject, Sound, _).

% Define ci_search: search every registered source, streamed and capped.
ci_search(Query, Hits) :-
    % Delegate to the Reference Library's streaming search.
    rl_search(Query, Hits).

% Define ci_why: the honest reason a word is known — its cited source line.
ci_why(Word, source(SourceId, Line), Text) :-
    % Find a vocabulary fact for the word and read its citation.
    ci_any_fact(_Grade, vocabulary, [Word, _], source(SourceId, Line)),
    % Resolve the citation to the exact line of source text.
    ci_cite(source(SourceId, Line), Text),
    % Commit to the first citation found.
    !.

% Define ci_cite: resolve any citation to the exact cited line of text.
ci_cite(source(SourceId, Line), Text) :-
    % Read the cited line through the Reference Library, honestly on failure.
    (   catch(rl_citation_text(source(SourceId, Line), Text), _, fail)
    % The citation resolved to real text.
    ->  true
    % Sources not yet registered: say so rather than inventing a line.
    ;   Text = '(citation unresolved — call ci_register_sources/0 first)' ).

% ---------------------------------------------------------------------------
% ci_stats/1 — a compact tally for reports and startup logs
% ---------------------------------------------------------------------------

% Define ci_stats: gather counts of facts, CROs, and sources.
ci_stats(stats(Facts, Cros, Sources)) :-
    % Count every understood fact.
    aggregate_all(count, ci_any_fact(_, _, _, _), Facts),
    % Count every sound CRO.
    aggregate_all(count, ci_any_cro(_, _, _, _, _), Cros),
    % Count every registered source.
    aggregate_all(count, ci_source(_, _, _), Sources).
