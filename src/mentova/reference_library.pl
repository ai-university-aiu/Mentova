/*  Mentova — The Reference Library  (Acc_425)

    The look-it-up library of Appendix Q of Teach_Mentova_To_Chat_v2:
    large reference bodies (an encyclopedia, a curriculum, a corpus) that
    Mentova consults one page at a time but has NOT understood.

    Two rules from Appendix Q are enforced by construction:

      1. The library is never asserted as fact. This module holds only a
         registry of sources; the content itself stays in its files and
         is read on demand. Nothing a source says ever becomes a Prolog
         fact through this module.

      2. Stream, do not slurp. Pages and searches read the files line by
         line, so a corpus never has to fit in memory.

    Citations have the shape source(SourceId, LineNo) and are the
    currency of testimonial grounding (Appendix R): the fact refinery's
    honesty gate calls rl_citation_exists/1 to confirm a citation is
    real and reachable before any fact may pass.

    Predicates:
      rl_register/2        -- +SourceId, +FilePath
      rl_unregister/1      -- +SourceId
      rl_sources/1         -- -SourceIds
      rl_page_size/1       -- -LinesPerPage
      rl_page/3            -- +SourceId, +PageNo, -Lines
      rl_search/2          -- +Query, -Hits (default cap 25)
      rl_search/3          -- +Query, +MaxHits, -Hits
      rl_citation_exists/1 -- +source(SourceId, LineNo)
      rl_citation_text/2   -- +source(SourceId, LineNo), -Line
*/

% Declare this file as the 'reference_library' module and list its exports.
:- module(reference_library, [
    % Export rl_register/2: register a text file as a library source.
    rl_register/2,
    % Export rl_unregister/1: remove a source from the registry.
    rl_unregister/1,
    % Export rl_sources/1: list the registered source identifiers.
    rl_sources/1,
    % Export rl_page_size/1: the number of lines per page.
    rl_page_size/1,
    % Export rl_page/3: read one page of a source, streamed.
    rl_page/3,
    % Export rl_search/2: search all sources with the default hit cap.
    rl_search/2,
    % Export rl_search/3: search all sources with an explicit hit cap.
    rl_search/3,
    % Export rl_citation_exists/1: a citation is real and reachable.
    rl_citation_exists/1,
    % Export rl_citation_text/2: fetch the exact cited line.
    rl_citation_text/2
% Close the module declaration.
]).

% Import list helpers.
:- use_module(library(lists), [member/2, reverse/2]).
% Import the line reader used for streaming.
:- use_module(library(readutil), [read_line_to_string/2]).

% ---------------------------------------------------------------------------
% Internal state — the registry is the ONLY dynamic state of this module.
% ---------------------------------------------------------------------------

% rl_source_/2: (SourceId, FilePath) — the registered sources.
:- dynamic rl_source_/2.

% The number of lines that make up one page.
rl_page_size(40).

% ---------------------------------------------------------------------------
% rl_register/2 — register a text file as a library source
% ---------------------------------------------------------------------------

% Define rl_register: the file must exist; registration is an upsert.
rl_register(SourceId, FilePath) :-
    % A source that does not exist on disk cannot be consulted.
    exists_file(FilePath),
    % Replace any previous registration of this identifier.
    retractall(rl_source_(SourceId, _)),
    % Record the source in the registry.
    assertz(rl_source_(SourceId, FilePath)).

% Define rl_unregister: remove a source from the registry.
rl_unregister(SourceId) :-
    % Drop the registry entry; the file itself is untouched.
    retractall(rl_source_(SourceId, _)).

% Define rl_sources: list the registered source identifiers, sorted.
rl_sources(SourceIds) :-
    % Collect every registered identifier.
    findall(Id, rl_source_(Id, _), Raw),
    % Sort and de-duplicate.
    sort(Raw, SourceIds).

% ---------------------------------------------------------------------------
% rl_page/3 — read one page of a source, streaming line by line
% ---------------------------------------------------------------------------

% Define rl_page: page numbers are one-based; a page past the end fails.
rl_page(SourceId, PageNo, Lines) :-
    % Look up the source's file path.
    rl_source_(SourceId, FilePath),
    % Pages are one-based.
    PageNo >= 1,
    % Fetch the configured page size.
    rl_page_size(PS),
    % The first line of the requested page.
    First is (PageNo - 1) * PS + 1,
    % The last line of the requested page.
    Last is PageNo * PS,
    % Stream the file, keeping only the lines of this page.
    setup_call_cleanup(
        % Open the file for reading.
        open(FilePath, read, Stream),
        % Collect the page's lines while streaming.
        rl_collect_range(Stream, 1, First, Last, [], Lines),
        % Always close the stream.
        close(Stream)),
    % An empty page means the page is past the end of the source.
    Lines \== [].

% rl_collect_range(+Stream, +N, +First, +Last, +Acc, -Lines): the stream walk.
rl_collect_range(Stream, N, First, Last, Acc, Lines) :-
    % Read the next line without loading the whole file.
    read_line_to_string(Stream, Line),
    % Decide what to do with it.
    (   Line == end_of_file
    % End of file: return what was collected, in order.
    ->  reverse(Acc, Lines)
    % Past the page: stop early without reading the rest of the file.
    ;   N > Last
    ->  reverse(Acc, Lines)
    % Inside the page: keep the line.
    ;   N >= First
    ->  N1 is N + 1,
        % Continue with the line accumulated.
        rl_collect_range(Stream, N1, First, Last, [Line | Acc], Lines)
    % Before the page: skip the line.
    ;   N1 is N + 1,
        % Continue without accumulating.
        rl_collect_range(Stream, N1, First, Last, Acc, Lines)
    ).

% ---------------------------------------------------------------------------
% rl_search/2,3 — search every registered source, streaming, capped
% ---------------------------------------------------------------------------

% Define rl_search/2: use the default cap of twenty-five hits.
rl_search(Query, Hits) :-
    % Delegate with the default cap.
    rl_search(Query, 25, Hits).

% Define rl_search/3: a hit is a line containing every query word.
rl_search(Query, MaxHits, Hits) :-
    % Split the query into lowercase words.
    rl_query_words(Query, Words),
    % Gather the registered sources.
    rl_sources(SourceIds),
    % Scan each source in turn, streaming, until the cap is reached.
    rl_search_sources(SourceIds, Words, MaxHits, [], RevHits),
    % Hits were accumulated newest-first.
    reverse(RevHits, Hits).

% rl_query_words(+Query, -Words): lowercase word list of the query.
rl_query_words(Query, Words) :-
    % Accept an atom or a string.
    atom_string(QueryAtom, Query),
    % Lowercase the whole query.
    downcase_atom(QueryAtom, Lower),
    % Split on spaces.
    atomic_list_concat(Parts, ' ', Lower),
    % Drop any empty parts from repeated spaces.
    findall(W, ( member(W, Parts), W \== '' ), Words).

% rl_search_sources(+Ids, +Words, +Left, +Acc, -Hits): scan each source.
rl_search_sources([], _, _, Acc, Acc).
% Stop scanning entirely once the cap is reached.
rl_search_sources(_, _, 0, Acc, Acc) :- !.
% Scan the next source and continue with the remaining budget.
rl_search_sources([Id | Ids], Words, Left, Acc, Hits) :-
    % Look up the source's file path.
    rl_source_(Id, FilePath),
    % Stream this one file, collecting matching lines.
    setup_call_cleanup(
        % Open the file for reading.
        open(FilePath, read, Stream),
        % Walk the stream, matching lines against the query words.
        rl_scan_stream(Stream, Id, Words, 1, Left, Acc, Acc2, Left2),
        % Always close the stream.
        close(Stream)),
    % Continue with the remaining sources and remaining budget.
    rl_search_sources(Ids, Words, Left2, Acc2, Hits).

% rl_scan_stream(+Stream, +Id, +Words, +N, +Left, +Acc, -Acc2, -Left2).
rl_scan_stream(_, _, _, _, 0, Acc, Acc, 0) :- !.
% Read and test one line, then continue.
rl_scan_stream(Stream, Id, Words, N, Left, Acc, Acc2, Left2) :-
    % Read the next line without loading the whole file.
    read_line_to_string(Stream, Line),
    % Decide what to do with it.
    (   Line == end_of_file
    % End of this source.
    ->  Acc2 = Acc,
        % The budget is unchanged.
        Left2 = Left
    % A line matching every query word is a hit.
    ;   rl_line_matches(Line, Words)
    ->  N1 is N + 1,
        % One less hit remains in the budget.
        LeftNext is Left - 1,
        % Record the hit with its citation-ready line number.
        rl_scan_stream(Stream, Id, Words, N1, LeftNext,
                       [hit(Id, N, Line) | Acc], Acc2, Left2)
    % A non-matching line is skipped.
    ;   N1 is N + 1,
        % Continue the walk.
        rl_scan_stream(Stream, Id, Words, N1, Left, Acc, Acc2, Left2)
    ).

% rl_line_matches(+Line, +Words): every query word occurs in the line.
rl_line_matches(Line, Words) :-
    % Lowercase the line once.
    string_lower(Line, Lower),
    % Every word must appear as a substring.
    forall(member(W, Words), sub_atom(Lower, _, _, _, W)).

% ---------------------------------------------------------------------------
% rl_citation_exists/1 and rl_citation_text/2 — the honesty gate's checks
% ---------------------------------------------------------------------------

% Define rl_citation_exists: the cited line is real and reachable.
rl_citation_exists(source(SourceId, LineNo)) :-
    % Fetching the cited text proves the citation reachable.
    rl_citation_text(source(SourceId, LineNo), _).

% Define rl_citation_text: fetch the exact cited line, streamed.
rl_citation_text(source(SourceId, LineNo), Line) :-
    % Look up the source's file path.
    rl_source_(SourceId, FilePath),
    % Line numbers are one-based.
    integer(LineNo),
    % The line number must be positive.
    LineNo >= 1,
    % Stream to the cited line.
    setup_call_cleanup(
        % Open the file for reading.
        open(FilePath, read, Stream),
        % Walk to the requested line.
        rl_nth_line(Stream, 1, LineNo, Line),
        % Always close the stream.
        close(Stream)).

% rl_nth_line(+Stream, +N, +Target, -Line): walk to line Target.
rl_nth_line(Stream, N, Target, Line) :-
    % Read the next line.
    read_line_to_string(Stream, Current),
    % A citation past the end of the file is unreachable.
    Current \== end_of_file,
    % Decide whether this is the cited line.
    (   N =:= Target
    % Found the cited line.
    ->  Line = Current
    % Keep walking.
    ;   N1 is N + 1,
        % Continue toward the target.
        rl_nth_line(Stream, N1, Target, Line)
    ).
