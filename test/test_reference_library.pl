/*  Mentova — Reference Library Module Test Suite  (Acc_425)

    Genuine PLUnit coverage for src/mentova/reference_library.pl, the
    look-it-up library of Appendix Q of Teach_Mentova_To_Chat_v2. The
    module holds only a registry of text sources and reads them one page
    or one line at a time, streamed, never asserting their content as
    fact. It exports rl_register/2, rl_unregister/1, rl_sources/1,
    rl_page_size/1, rl_page/3, rl_search/2, rl_search/3,
    rl_citation_exists/1 and rl_citation_text/2.

    These tests write a five-line fixture file with known content at run
    time, register it, and assert the exact pages, search hits (with
    their citation-ready line numbers) and cited lines the documented
    behaviour must produce — then confirm unregistering makes the source
    unreachable again.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_reference_library.pl
*/

% Declare this file as a test module with no exports.
:- module(test_reference_library, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the list helpers used by the setup predicates.
:- use_module(library(lists), [member/2]).
% Load the module under test from the library path.
:- use_module(library(reference_library)).

% ---------------------------------------------------------------------------
% Fixture — a five-line text source with known, hand-checkable content.
% ---------------------------------------------------------------------------

% fixture_path/1: the on-disk path of the temporary fixture file.
fixture_path('/tmp/test_reference_library_fixture.txt').

% write_fixture/0: (over)write the fixture file with its five known lines.
write_fixture :-
    % Look up the fixture path.
    fixture_path(Path),
    % Open, write the lines, and always close the file.
    setup_call_cleanup(
        % Open the fixture for writing.
        open(Path, write, Stream),
        % Write the five known lines.
        write_fixture_lines(Stream),
        % Always close the stream.
        close(Stream)).

% write_fixture_lines/1: emit the five lines whose content the tests assert.
write_fixture_lines(Stream) :-
    % Line 1 contains the word apple.
    writeln(Stream, "apple banana cherry"),
    % Line 2 contains no apple.
    writeln(Stream, "date elderberry fig"),
    % Line 3 contains both apple and honeydew.
    writeln(Stream, "grape apple honeydew"),
    % Line 4 contains no apple.
    writeln(Stream, "kiwi lemon mango"),
    % Line 5 contains the word apple.
    writeln(Stream, "apple nectarine orange").

% clear_registry/0: unregister every currently registered source.
clear_registry :-
    % Read the registered source identifiers.
    rl_sources(Ids),
    % Unregister each one so the registry starts empty.
    forall(member(Id, Ids), rl_unregister(Id)).

% setup_library/0: per-test setup — a fresh fixture, an empty registry, one source.
setup_library :-
    % Ensure the fixture file exists with its known content.
    write_fixture,
    % Start from an empty registry regardless of prior tests.
    clear_registry,
    % Register the fixture under the identifier reftest.
    fixture_path(Path),
    % Record the single source the tests read.
    rl_register(reftest, Path).

% cleanup_library/0: block cleanup — remove the temporary fixture file.
cleanup_library :-
    % Look up the fixture path.
    fixture_path(Path),
    % Delete the file if it is present, ignoring its absence.
    ( exists_file(Path) -> delete_file(Path) ; true ).

% Open the test block, removing the fixture file once every test has run.
:- begin_tests(reference_library, [cleanup(cleanup_library)]).

% AC-REFLIB-001: the page size is the documented constant of forty lines.
test(page_size_is_forty, [setup(setup_library)]) :-
    % Read the configured lines-per-page.
    rl_page_size(Size),
    % The module fixes one page at forty lines.
    assertion(Size =:= 40).

% AC-REFLIB-002: registering a source makes it the sole listed identifier.
test(register_lists_the_source, [setup(setup_library)]) :-
    % Read the registered source identifiers.
    rl_sources(Ids),
    % Setup registered exactly the reftest source.
    assertion(Ids == [reftest]).

% AC-REFLIB-003: page one returns all five fixture lines, in order, as strings.
test(page_one_returns_all_lines, [setup(setup_library)]) :-
    % Read the first page of the reftest source.
    rl_page(reftest, 1, Lines),
    % The five lines come back in file order.
    assertion(Lines == ["apple banana cherry",
                         "date elderberry fig",
                         "grape apple honeydew",
                         "kiwi lemon mango",
                         "apple nectarine orange"]).

% AC-REFLIB-004: a page beyond the end of the source fails rather than empties.
test(page_beyond_end_fails, [setup(setup_library)]) :-
    % The second page begins at line forty-one, past a five-line file.
    assertion(\+ rl_page(reftest, 2, _)).

% AC-REFLIB-005: a one-word search returns every matching line with its line number.
test(search_finds_all_apple_lines, [setup(setup_library)]) :-
    % Search every source for the word apple, taking its single result.
    once(rl_search("apple", Hits)),
    % Lines 1, 3 and 5 match, each carrying its citation-ready line number.
    assertion(Hits == [hit(reftest, 1, "apple banana cherry"),
                       hit(reftest, 3, "grape apple honeydew"),
                       hit(reftest, 5, "apple nectarine orange")]).

% AC-REFLIB-006: search is case-insensitive on the query text.
test(search_is_case_insensitive, [setup(setup_library)]) :-
    % Search with an upper-case query, taking its single result.
    once(rl_search("APPLE", Hits)),
    % The same three lines match as for the lower-case query.
    assertion(Hits == [hit(reftest, 1, "apple banana cherry"),
                       hit(reftest, 3, "grape apple honeydew"),
                       hit(reftest, 5, "apple nectarine orange")]).

% AC-REFLIB-007: a multi-word query keeps only lines containing every word.
test(search_requires_all_words, [setup(setup_library)]) :-
    % Search for lines holding both apple and honeydew, taking its single result.
    once(rl_search("apple honeydew", Hits)),
    % Only line 3 contains both words.
    assertion(Hits == [hit(reftest, 3, "grape apple honeydew")]).

% AC-REFLIB-008: the explicit hit cap stops the scan once it is reached.
test(search_honours_the_hit_cap, [setup(setup_library)]) :-
    % Search for apple but ask for at most two hits, taking its single result.
    once(rl_search("apple", 2, Hits)),
    % Only the first two matching lines are returned.
    assertion(Hits == [hit(reftest, 1, "apple banana cherry"),
                       hit(reftest, 3, "grape apple honeydew")]).

% AC-REFLIB-009: a real, reachable citation exists and yields its exact line.
test(citation_exists_and_reads_line, [setup(setup_library)]) :-
    % A citation to line 3 of reftest is real and reachable.
    assertion(rl_citation_exists(source(reftest, 3))),
    % Fetching the cited text returns exactly that line.
    rl_citation_text(source(reftest, 3), Line),
    % Line 3 of the fixture is grape apple honeydew.
    assertion(Line == "grape apple honeydew").

% AC-REFLIB-010: a citation past the end of the source is not reachable.
test(citation_past_end_is_unreachable, [setup(setup_library)]) :-
    % Line 99 does not exist in a five-line source.
    assertion(\+ rl_citation_exists(source(reftest, 99))).

% AC-REFLIB-011: unregistering a source empties the registry and unreaches its pages.
test(unregister_removes_the_source, [setup(setup_library)]) :-
    % Remove the reftest source from the registry.
    rl_unregister(reftest),
    % The registry is now empty.
    assertion(rl_sources([])),
    % Its pages can no longer be read.
    assertion(\+ rl_page(reftest, 1, _)).

% Close the test block.
:- end_tests(reference_library).
