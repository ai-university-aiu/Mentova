/*  Mentova — Fact Refinery Acceptance Demonstration  (Acc_425)

    Exercises the fact refinery and the Minority Report panel of
    Teach_Mentova_To_Chat_v2, Appendices Q, R, and S, end to end:

      - the reference library (Appendix Q): registered, searched, and
        paged as a streamed look-it-up tier, never asserted as fact;
      - direct and testimonial grounding (Appendix R): a perception fact
        and a trusted-record fact, each carrying its grounding kind, and
        the honest "why?" that cites the record and the checks;
      - the refinery stages (Appendix S): strict-shape extraction,
        qualification, the blind normalized panel vote with honest
        abstentions, confidence lanes, the plain-code honesty gate that
        outranks even a unanimous panel, the Minority Report Bin, the
        referee, the hand-audit sample, and submission into the chat's
        existing Review Queue.

    The panel members in this demonstration are deterministic test
    doubles, because the refinery's cardinal rule is that the pipeline
    itself must be correct regardless of which models sit on the panel.
    The Ollama adapter is probed and reported, but no live model call is
    an acceptance criterion.

    The demonstration fact is the one Appendix R itself uses: the Peace
    of Westphalia was signed in 1648 — testimonially grounded, anchored
    by a trusted record rather than by touch.

    Acceptance criteria (each prints PASS or FAIL at run time):
      AC-ACC425-001: the reference library streams pages, searches, and
                     verifies citations without asserting content.
      AC-ACC425-002: extraction enforces the strict candidate shape.
      AC-ACC425-003: qualification assigns testimonial and direct
                     grounding kinds and drops weak candidates.
      AC-ACC425-004: differently-worded answers count as agreement
                     (blind, normalized voting).
      AC-ACC425-005: "I do not know" is an abstention, never a
                     disagreement.
      AC-ACC425-006: votes grade into lanes — unanimous high, four of
                     five medium, three of two split to the Bin — with
                     every vote recorded.
      AC-ACC425-007: the plain-code honesty gate rejects an unconnected
                     or badly cited fact even when the panel is
                     unanimous.
      AC-ACC425-008: an even panel is rejected; the panel must be odd.
      AC-ACC425-009: the referee settles Bin entries — keep moves to the
                     medium lane, reject is recorded.
      AC-ACC425-010: a survivor enters the chat's real Review Queue.
      AC-ACC425-011: an approved fact is grounded with full provenance
                     and answers "why?" by citing the record, the votes,
                     and the checks.
      AC-ACC425-012: the hand-audit sample is deterministic from a seed.

    Run:
        swipl -l demos/fact_refinery_demo.pl -g run_fact_refinery_demo -t halt
*/

% Declare this file as the demo script module with a single entry point.
:- module(fact_refinery_demo_script, [run_fact_refinery_demo/0]).

% Load the reference library module under test.
:- use_module('../src/mentova/reference_library').
% Load the fact refinery module under test.
:- use_module('../src/mentova/fact_refinery').
% Load the chat database whose Review Queue receives the survivors.
:- use_module('../src/mentova/chat_db', [mc_db_init/1, mc_pending_proposals/1]).
% Load list helpers.
:- use_module(library(lists), [member/2, memberchk/2, last/2]).

% ---------------------------------------------------------------------------
% SCRATCH WORLD — a tiny corpus file, created at run time, outside git
% ---------------------------------------------------------------------------

% demo_dir(-Dir): the scratch directory of this demonstration.
demo_dir('/tmp/mentova_fact_refinery_demo').

% demo_corpus_path(-Path): the corpus file inside the scratch directory.
demo_corpus_path(Path) :-
    % The corpus lives inside the scratch directory.
    demo_dir(Dir),
    % Join the file name.
    atomic_list_concat([Dir, '/demo_corpus.txt'], Path).

% demo_setup/0: create the scratch corpus and register it as a source.
demo_setup :-
    % Ensure the scratch directory exists.
    demo_dir(Dir),
    % Create it and any parents.
    make_directory_path(Dir),
    % The corpus path.
    demo_corpus_path(Path),
    % Write the three-line corpus; line numbers are the citations.
    setup_call_cleanup(
        % Open the corpus for writing.
        open(Path, write, S),
        % Write the three source sentences, one per line.
        ( writeln(S, 'The Peace of Westphalia was signed in 1648.'),
          % The perception-kind sentence.
          writeln(S, 'A ball is round.'),
          % The sentence whose subject is deliberately not yet grounded.
          writeln(S, 'The moon is made of rock.') ),
        % Always close the stream.
        close(S)),
    % Register the corpus as a look-it-up source.
    rl_register(demo_corpus, Path),
    % Attach the chat database in the scratch directory.
    atomic_list_concat([Dir, '/chat_db'], DbDir),
    % Initialize the review-queue persistence there.
    mc_db_init(DbDir),
    % Start the refinery from a clean slate.
    fr_reset.

% ---------------------------------------------------------------------------
% DETERMINISTIC PANEL MEMBERS — genuinely different behaviours, blind votes
% ---------------------------------------------------------------------------

% m_exact(+Judgment, -Answer): a model that reads the claim exactly.
m_exact(judge(fact(S, R, O), _, _), triple(S, R, O)).

% m_wordy(+Judgment, -Answer): the same reading in different words.
m_wordy(judge(fact(peace_of_westphalia, signed_in, 1648), _, _),
        triple('Peace Of Westphalia', 'Signed In', 1648)) :- !.
% For any other fact the wordy model reads the claim exactly.
m_wordy(judge(fact(S, R, O), _, _), triple(S, R, O)).

% m_abstain(+Judgment, -Answer): a model that honestly does not know.
m_abstain(judge(_, _, _), unknown).

% m_dissent(+Judgment, -Answer): a model that reads a different claim.
m_dissent(judge(_, _, _), triple(something, entirely, different)).

% ---------------------------------------------------------------------------
% DETERMINISTIC EXTRACTOR AND QUALIFIER — strict shapes, graded judgments
% ---------------------------------------------------------------------------

% demo_extractor(+Passage, -Proposals): four proposals, one malformed.
demo_extractor(_Passage, [
    % The trusted-record fact of Appendix R, with its exact citation.
    cand(peace_of_westphalia, signed_in, 1648,
         'The Peace of Westphalia was signed in 1648.', source(demo_corpus, 1)),
    % The perception fact.
    cand(ball, has_shape, round,
         'A ball is round.', source(demo_corpus, 2)),
    % The unconnected-subject fact, to be stopped by the honesty gate.
    cand(moon, made_of, rock,
         'The moon is made of rock.', source(demo_corpus, 3)),
    % A malformed proposal missing its citation; the shape check drops it.
    bad_shape(no, citation),
    % A weak proposal the qualifier will refuse to qualify.
    cand(gossip, says, something,
         'Somebody said something once.', source(demo_corpus, 3))
]).

% demo_qualifier(+Candidate, -Judgment): grade each candidate.
demo_qualifier(cand(peace_of_westphalia, signed_in, 1648, _, _),
    % A dated historical event is the trusted-record kind (Appendix R).
    qualified(fact(peace_of_westphalia, signed_in, 1648), testimonial, 0.9)).
% The ball fact is the perception kind.
demo_qualifier(cand(ball, has_shape, round, _, _),
    % Roundness can be seen and held: direct grounding.
    qualified(fact(ball, has_shape, round), direct, 0.8)).
% The moon fact is well-formed prose, so it qualifies; the gate decides later.
demo_qualifier(cand(moon, made_of, rock, _, _),
    % A stable, checkable claim of the trusted-record kind.
    qualified(fact(moon, made_of, rock), testimonial, 0.7)).
% The gossip candidate is refused: no clause, so qualification fails.

% demo_grounded(-Concepts): the words already grounded in this scenario.
% The word moon is deliberately absent, so the gate has something to catch.
demo_grounded([peace, of, westphalia, signed, in, ball, has, shape, round,
               made, rock]).

% demo_referee(+Fact, +Prov, -Ruling): the stronger mind for the Bin.
demo_referee(fact(peace_of_westphalia, signed_in, 1648), _, keep) :- !.
% Everything else in the Bin is rejected by this referee.
demo_referee(_, _, reject).

% ---------------------------------------------------------------------------
% ENTRY POINT
% ---------------------------------------------------------------------------

% run_fact_refinery_demo/0: run every scene, print PASS/FAIL, summarize.
run_fact_refinery_demo :-
    % Print the banner.
    banner,
    % Build the scratch world.
    demo_setup,
    % Scene one: the look-it-up library.
    scene_library(A1),
    % Scene two: strict-shape extraction.
    scene_extraction(A2),
    % Scene three: the full pipeline with grounding kinds.
    scene_pipeline(A3, A7),
    % Scene four: blind normalized agreement.
    scene_normalized_vote(A4),
    % Scene five: honest abstention.
    scene_abstention(A5),
    % Scene six: the confidence lanes.
    scene_lanes(A6),
    % Scene seven: the even panel is unlawful.
    scene_odd_panel(A8),
    % Scene eight: the referee settles the Bin.
    scene_referee(A9),
    % Scene nine: into the real Review Queue.
    scene_review_queue(A10),
    % Scene ten: grounding and the honest why.
    scene_why(A11),
    % Scene eleven: the deterministic audit.
    scene_audit(A12),
    % Report the optional local-model adapter, informationally.
    report_ollama,
    % Gather every acceptance-criterion result.
    ACs = [A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12],
    % Print each result line.
    forall(member(AC, ACs), print_ac(AC)),
    % Print the final tally.
    summarize(ACs).

% banner/0: print the demonstration title.
banner :-
    % A blank line before the banner.
    nl,
    % The title.
    writeln('=== Acc_425: The Fact Refinery and the Minority Report Panel ==='),
    % The subtitle.
    writeln('Raw text in, checked and sourced candidate facts out - no fluent guess trusted.'),
    % A trailing blank line.
    nl.

% ---------------------------------------------------------------------------
% SCENES
% ---------------------------------------------------------------------------

% scene_library(-AC): Appendix Q — streamed search, pages, citations.
scene_library(ac('AC-ACC425-001', Pass, 'reference library streams, searches, and verifies citations')) :-
    % Search for the treaty line by two of its words.
    (   rl_search('peace westphalia', Hits),
        % The hit names the source, the line, and the text.
        memberchk(hit(demo_corpus, 1, _), Hits),
        % Page one of the corpus streams back its lines.
        rl_page(demo_corpus, 1, Lines),
        % The corpus has its three sentences.
        length(Lines, 3),
        % The real citation is reachable.
        rl_citation_exists(source(demo_corpus, 1)),
        % A citation past the end of the file is not.
        \+ rl_citation_exists(source(demo_corpus, 99))
    % The scene passes when all library behaviours hold.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ).

% scene_extraction(-AC): stage one enforces the strict shape.
scene_extraction(ac('AC-ACC425-002', Pass, 'extraction enforces the strict candidate shape')) :-
    % Run the extractor through the shape check.
    (   fr_extract(fact_refinery_demo_script:demo_extractor, passage, Candidates),
        % Five proposals went in; the malformed one was dropped.
        length(Candidates, 4),
        % The malformed proposal is gone.
        \+ memberchk(bad_shape(_, _), Candidates)
    % The scene passes when the shape is law.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ).

% scene_pipeline(-AC3, -AC7): the full refinery over the corpus passage.
scene_pipeline(ac('AC-ACC425-003', Pass3, 'qualification assigns grounding kinds and drops the weak'),
               ac('AC-ACC425-007', Pass7, 'the honesty gate outranks even a unanimous panel')) :-
    % The grounded concepts of this scenario.
    demo_grounded(Grounded),
    % A unanimous three-member panel: exact, wordy, exact.
    Panel = [fact_refinery_demo_script:m_exact,
             fact_refinery_demo_script:m_wordy,
             fact_refinery_demo_script:m_exact],
    % Assemble the refinery configuration.
    Config = refinery(fact_refinery_demo_script:demo_extractor,
                      fact_refinery_demo_script:demo_qualifier,
                      Panel, Grounded),
    % Run the passage through all the automatic stages.
    fr_refine(Config, passage, Outcomes),
    % Scene check one: grounding kinds and the dropped weakling.
    (   memberchk(outcome(fact(peace_of_westphalia, signed_in, 1648), high, _), Outcomes),
        % The perception fact also survived to the high lane.
        memberchk(outcome(fact(ball, has_shape, round), high, _), Outcomes),
        % The gossip candidate was refused at qualification.
        memberchk(outcome(fact(gossip, says, something), rejected(unqualified), _), Outcomes),
        % The lanes carry the grounding kinds assigned by the qualifier.
        fr_lane_entries(high, Entries),
        % The treaty fact is testimonial.
        memberchk(entry(fact(peace_of_westphalia, signed_in, 1648),
                        prov(testimonial, 0.9, source(demo_corpus, 1), _, _, ok)), Entries),
        % The ball fact is direct.
        memberchk(entry(fact(ball, has_shape, round),
                        prov(direct, 0.8, source(demo_corpus, 2), _, _, ok)), Entries)
    % Qualification behaved.
    ->  Pass3 = true
    % Otherwise it fails.
    ;   Pass3 = false
    ),
    % Scene check two: the moon fact was unanimous yet gate-rejected.
    (   memberchk(outcome(fact(moon, made_of, rock),
                          rejected(gate(unconnected([moon]))), MoonVotes), Outcomes),
        % The panel had in fact agreed unanimously.
        MoonVotes = votes(3, 0, 0, _),
        % And a bad citation also fails the gate, by plain code.
        fr_honesty_gate(qualified(fact(ball, has_shape, round), direct, 0.8,
                                  'A ball is round.', source(demo_corpus, 99)),
                        Grounded, failed(bad_citation(_)))
    % Unanimity is strong but not proof (S.4).
    ->  Pass7 = true
    % Otherwise it fails.
    ;   Pass7 = false
    ).

% scene_normalized_vote(-AC): wording differences count as agreement.
scene_normalized_vote(ac('AC-ACC425-004', Pass, 'differently-worded answers count as agreement')) :-
    % The qualified treaty fact.
    Q = qualified(fact(peace_of_westphalia, signed_in, 1648), testimonial, 0.9,
                  'The Peace of Westphalia was signed in 1648.', source(demo_corpus, 1)),
    % A panel whose middle member words the same fact differently.
    (   fr_panel_vote([fact_refinery_demo_script:m_exact,
                       fact_refinery_demo_script:m_wordy,
                       fact_refinery_demo_script:m_exact], Q, Votes),
        % All three count as agreement after normalization.
        Votes = votes(3, 0, 0, _),
        % The unanimous record grades into the high lane.
        fr_lane(Votes, high)
    % The scene passes when normalization does its work.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ).

% scene_abstention(-AC): "I do not know" is never a disagreement.
scene_abstention(ac('AC-ACC425-005', Pass, 'an honest abstention is not a disagreement')) :-
    % The qualified treaty fact.
    Q = qualified(fact(peace_of_westphalia, signed_in, 1648), testimonial, 0.9,
                  'The Peace of Westphalia was signed in 1648.', source(demo_corpus, 1)),
    % A panel with one honest abstention.
    (   fr_panel_vote([fact_refinery_demo_script:m_exact,
                       fact_refinery_demo_script:m_abstain,
                       fact_refinery_demo_script:m_exact], Q, Votes),
        % Two agreements, no disagreement, one abstention.
        Votes = votes(2, 0, 1, _),
        % Those who judged were unanimous, so the lane is still high.
        fr_lane(Votes, high)
    % The scene passes when abstention is honored.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ).

% scene_lanes(-AC): four of five is medium; three to two splits to the Bin.
scene_lanes(ac('AC-ACC425-006', Pass, 'votes grade into lanes and every vote is recorded')) :-
    % The qualified treaty fact.
    Q = qualified(fact(peace_of_westphalia, signed_in, 1648), testimonial, 0.9,
                  'The Peace of Westphalia was signed in 1648.', source(demo_corpus, 1)),
    % A five-member panel with a single dissenter.
    (   fr_panel_vote([fact_refinery_demo_script:m_exact,
                       fact_refinery_demo_script:m_exact,
                       fact_refinery_demo_script:m_exact,
                       fact_refinery_demo_script:m_wordy,
                       fact_refinery_demo_script:m_dissent], Q, V1),
        % Four agreements against one.
        V1 = votes(4, 1, 0, PerModel1),
        % A strong majority takes the medium lane.
        fr_lane(V1, medium),
        % The dissenting vote is recorded with the claim it made instead.
        memberchk(vote(_, disagree(triple(something, entirely, different))), PerModel1),
        % A five-member panel with two dissenters.
        fr_panel_vote([fact_refinery_demo_script:m_exact,
                       fact_refinery_demo_script:m_exact,
                       fact_refinery_demo_script:m_exact,
                       fact_refinery_demo_script:m_dissent,
                       fact_refinery_demo_script:m_dissent], Q, V2),
        % Three against two is a split.
        V2 = votes(3, 2, 0, _),
        % A split goes to the Minority Report Bin.
        fr_lane(V2, minority_bin)
    % The scene passes when the lanes grade correctly.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ).

% scene_odd_panel(-AC): the panel must be odd, three or five.
scene_odd_panel(ac('AC-ACC425-008', Pass, 'an even panel is rejected')) :-
    % The qualified treaty fact.
    Q = qualified(fact(peace_of_westphalia, signed_in, 1648), testimonial, 0.9,
                  'The Peace of Westphalia was signed in 1648.', source(demo_corpus, 1)),
    % A four-member panel is unlawful and must be refused.
    (   \+ fr_panel_vote([fact_refinery_demo_script:m_exact,
                          fact_refinery_demo_script:m_exact,
                          fact_refinery_demo_script:m_exact,
                          fact_refinery_demo_script:m_exact], Q, _)
    % The scene passes when the refusal holds.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ).

% scene_referee(-AC): the stronger mind settles the Bin.
scene_referee(ac('AC-ACC425-009', Pass, 'the referee settles Bin entries')) :-
    % Start this scene from a clean refinery.
    fr_reset,
    % The grounded concepts of this scenario.
    demo_grounded(Grounded),
    % A split panel: three to two on everything.
    SplitPanel = [fact_refinery_demo_script:m_exact,
                  fact_refinery_demo_script:m_exact,
                  fact_refinery_demo_script:m_exact,
                  fact_refinery_demo_script:m_dissent,
                  fact_refinery_demo_script:m_dissent],
    % Assemble a refinery whose every vote splits.
    Config = refinery(fact_refinery_demo_script:demo_extractor,
                      fact_refinery_demo_script:demo_qualifier,
                      SplitPanel, Grounded),
    % Run the passage; the surviving facts land in the Bin.
    fr_refine(Config, passage, _),
    % The Bin holds the split treaty fact with its full story.
    (   fr_bin_contents(Bin),
        % The treaty fact is among the Bin entries.
        memberchk(entry(fact(peace_of_westphalia, signed_in, 1648), _), Bin),
        % The referee keeps the treaty fact.
        fr_referee_bin(fact_refinery_demo_script:demo_referee,
                       fact(peace_of_westphalia, signed_in, 1648), keep),
        % A kept fact moves to the medium lane for the lighter look.
        fr_lane_entries(medium, Entries),
        % It is there.
        memberchk(entry(fact(peace_of_westphalia, signed_in, 1648), _), Entries),
        % The referee rejects the ball fact.
        fr_referee_bin(fact_refinery_demo_script:demo_referee,
                       fact(ball, has_shape, round), reject),
        % The rejection is recorded with the referee as the reason.
        fr_rejected(Rejected),
        % It is there.
        memberchk(rejected(fact(ball, has_shape, round), referee), Rejected)
    % The scene passes when both rulings land correctly.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ).

% scene_review_queue(-AC): stage five uses the chat's existing machinery.
scene_review_queue(ac('AC-ACC425-010', Pass, 'a survivor enters the chat Review Queue')) :-
    % The treaty fact's provenance from the medium lane of the last scene.
    (   fr_lane_entries(medium, [entry(Fact, Prov) | _]),
        % Hand the survivor to the chat database's review queue.
        fr_submit_review(Fact, Prov, QueueId),
        % The proposal is pending in the real queue.
        mc_pending_proposals(Pending),
        % Our queue identifier is among the pending proposals, filed under
        % the refinery's reserved system identity, mentor id zero.
        memberchk(entry(QueueId, FactAtom, 0, _), Pending),
        % The stored proposal carries the fact together with its provenance.
        sub_atom(FactAtom, _, _, _, refinery_fact)
    % The scene passes when the queue holds the proposal.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ).

% scene_why(-AC): stage six grounds with provenance; the why cites it all.
scene_why(ac('AC-ACC425-011', Pass, 'a grounded fact answers why by citing record, votes, and checks')) :-
    % The treaty fact and its provenance from the medium lane.
    (   fr_lane_entries(medium, [entry(Fact, Prov) | _]),
        % A mentor approves; the fact becomes understood, provenance intact.
        fr_approve(Fact, Prov),
        % The grounded store holds it.
        fr_grounded_fact(Fact, _),
        % Ask the honest question.
        fr_why(Fact, Why),
        % The why names the grounding kind of Appendix R.
        Why = why(Fact, grounding(testimonial), record(Citation, Sentence),
                  checked_by(votes(_, _, _, _)), gate(ok), confidence(0.9)),
        % The record is the exact citation.
        Citation == source(demo_corpus, 1),
        % And the exact source sentence.
        Sentence == 'The Peace of Westphalia was signed in 1648.'
    % The scene passes when the why tells the whole story.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ).

% scene_audit(-AC): the hand audit samples deterministically.
scene_audit(ac('AC-ACC425-012', Pass, 'the hand-audit sample is deterministic from a seed')) :-
    % Sample the medium lane twice from the same seed.
    (   fr_audit_sample(medium, 42, 1, S1),
        % The second, identical draw.
        fr_audit_sample(medium, 42, 1, S2),
        % One entry was sampled.
        S1 = [entry(_, _)],
        % The draws agree exactly.
        S1 == S2
    % The scene passes when the audit is reproducible.
    ->  Pass = true
    % Otherwise it fails.
    ;   Pass = false
    ).

% report_ollama/0: informational only — the optional local-model adapter.
report_ollama :-
    % Probe the local Ollama installation, guarded.
    fr_ollama_models(Models),
    % Report what the refinery's standing panel could be built from.
    format('INFO local Ollama models available to the panel: ~w~n~n', [Models]).

% ---------------------------------------------------------------------------
% REPORTING
% ---------------------------------------------------------------------------

% print_ac(+AC): print one acceptance-criterion result line.
print_ac(ac(Id, true, Desc)) :-
    % A passing criterion.
    format('PASS ~w : ~w~n', [Id, Desc]).
% A failing criterion.
print_ac(ac(Id, false, Desc)) :-
    % A failing criterion.
    format('FAIL ~w : ~w~n', [Id, Desc]).

% summarize(+ACs): print the final PASS/FAIL tally.
summarize(ACs) :-
    % Count the passing criteria.
    findall(Id, member(ac(Id, true, _), ACs), Passes),
    % How many passed.
    length(Passes, P),
    % How many in total.
    length(ACs, T),
    % Print the tally line.
    format('~nAcc_425 demonstration: ~w/~w acceptance criteria PASS~n', [P, T]),
    % A closing verdict.
    (   P =:= T
    % Every criterion passed.
    ->  writeln('RESULT: PASS - the fact refinery turns raw text into checked, sourced facts without trusting a fluent guess.')
    % Some criterion failed.
    ;   writeln('RESULT: FAIL - one or more acceptance criteria did not hold.')
    ).
