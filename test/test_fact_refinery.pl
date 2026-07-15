/*  Mentova — The Fact Refinery Test Suite

    Genuine PLUnit coverage for src/mentova/fact_refinery.pl (Acc_425),
    the six-stage pipeline that turns raw text into clean, checked,
    sourced candidate facts without ever trusting a language model's
    fluent guess. The module exports fr_reset/0, fr_normalize/2,
    fr_extract/3, fr_qualify/3, fr_panel_vote/3, fr_lane/2,
    fr_honesty_gate/3, fr_refine/3, fr_lane_entries/2, fr_bin_contents/1,
    fr_rejected/1, fr_referee_bin/3, fr_submit_review/3, fr_approve/2,
    fr_grounded_fact/2, fr_why/2, fr_audit_sample/4, fr_ollama_models/1,
    and fr_ollama_generate/4.

    Every model in the module is a caller-supplied goal, so the suite
    drives the pipeline with deterministic test doubles (an extractor, a
    qualifier, and a three-mind blind panel) rather than any live model,
    and asserts on the exact records, verdicts, lanes, and provenance the
    documented behaviour produces. The end-to-end test registers a real
    reference-library source so the honesty gate can confirm a citation.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_fact_refinery.pl
*/

% Declare this file as a test module with no exports.
:- module(test_fact_refinery, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(fact_refinery)).
% Load the reference library so the end-to-end test can register a real source.
:- use_module(library(reference_library)).

% ---------------------------------------------------------------------------
% Deterministic test doubles — every "model" is a plain, inspectable goal.
% ---------------------------------------------------------------------------

% te_extract/2 is a stand-in extractor proposing three raw candidates.
te_extract(_Passage, [
    % A well-formed candidate in the strict five-slot shape.
    cand(cat, eats, fish, 'The cat eats fish.', source(book, 12)),
    % A candidate whose exact source sentence is empty, so it is dropped.
    cand(dog, eats, bone, '', source(book, 13)),
    % A malformed candidate that does not fit cand/5 at all, so it is dropped.
    cand(malformed, thing)
]).

% te_extract_pipe/2 is the end-to-end extractor citing a registered source.
te_extract_pipe(_Passage, [
    % A grounded candidate that should survive to the high-confidence lane.
    cand(cat, eats, fish, 'The cat eats fish.', source(refbook, 1)),
    % A candidate whose words are not grounded, so the honesty gate rejects it.
    cand(zzz, qqq, www, 'Nonsense sentence.', source(refbook, 1))
]).

% te_qualify/2 is a stand-in qualifier that testimonially accepts a candidate.
te_qualify(cand(S, R, O, _, _), qualified(fact(S, R, O), testimonial, 0.9)).

% te_agree/2 is a panel voter that echoes the claim, counting as agreement.
te_agree(judge(fact(S, R, O), _, _), triple(S, R, O)).

% te_disagree/2 is a panel voter that returns a genuinely different claim.
te_disagree(judge(_, _, _), triple(other, thing, here)).

% te_unknown/2 is a panel voter that honestly abstains.
te_unknown(judge(_, _, _), unknown).

% Open the test block for the fact_refinery module.
:- begin_tests(fact_refinery).

% AC-FR-001: normalization lowercases each slot and turns spaces into underscores.
test(normalize_lowercases_and_despaces) :-
    % Normalize a triple whose slots carry capitals and spaces.
    fr_normalize(triple('Signed In', 'Is A', 'Big Dog'), Norm),
    % Each slot is lowercased and de-spaced so wording differences agree.
    assertion(Norm == triple(signed_in, is_a, big_dog)).

% AC-FR-002: numbers pass through normalization unchanged as canonical terms.
test(normalize_passes_numbers) :-
    % Normalize a triple whose object slot is a number.
    fr_normalize(triple('CAT', likes, 5), Norm),
    % The atom is normalized and the number is left exactly as it was.
    assertion(Norm == triple(cat, likes, 5)).

% AC-FR-003: a unanimous panel among judges grades into the high lane.
test(lane_unanimous_is_high) :-
    % Grade a vote record with three agreements and no disagreement.
    fr_lane(votes(3, 0, 0, []), Lane),
    % Unanimous agreement is the high-confidence lane.
    assertion(Lane == high).

% AC-FR-004: a strong majority of exactly three-quarters grades into the medium lane.
test(lane_strong_majority_is_medium) :-
    % Grade three agreements against one disagreement, four judges in all.
    fr_lane(votes(3, 1, 0, []), Lane),
    % A three-of-four majority meets the 0.75 threshold for the medium lane.
    assertion(Lane == medium).

% AC-FR-005: an even split falls to the Minority Report Bin for a person.
test(lane_split_is_minority_bin) :-
    % Grade one agreement against one disagreement.
    fr_lane(votes(1, 1, 0, []), Lane),
    % A half-and-half split is below 0.75, so it goes to the Bin.
    assertion(Lane == minority_bin).

% AC-FR-006: when nobody actually judged, only a person can settle it.
test(lane_all_abstain_is_minority_bin) :-
    % Grade a vote record where every voter abstained.
    fr_lane(votes(0, 0, 3, []), Lane),
    % Zero judged votes means the Minority Report Bin, not an automatic lane.
    assertion(Lane == minority_bin).

% AC-FR-007: extraction keeps only candidates in the strict five-slot shape.
test(extract_keeps_only_strict_shape) :-
    % Run the stand-in extractor over an arbitrary passage.
    fr_extract(test_fact_refinery:te_extract, 'some passage', Candidates),
    % Only the well-formed, non-empty-sentence candidate survives the shape filter.
    assertion(Candidates == [cand(cat, eats, fish, 'The cat eats fish.', source(book, 12))]).

% AC-FR-008: qualification validates the judgment and assembles the qualified record.
test(qualify_assembles_record) :-
    % A candidate carrying its source sentence and citation.
    Candidate = cand(cat, eats, fish, 'The cat eats fish.', source(book, 12)),
    % Qualify it through the stand-in stronger mind.
    fr_qualify(test_fact_refinery:te_qualify, Candidate, Qualified),
    % The qualified record carries the fact, grounding, confidence, sentence, and citation.
    assertion(Qualified == qualified(fact(cat, eats, fish), testimonial, 0.9,
                                     'The cat eats fish.', source(book, 12))).

% AC-FR-009: the blind panel tallies agreement, disagreement, and abstention.
test(panel_vote_counts_agree_disagree_abstain) :-
    % The qualified claim the panel will judge.
    Qualified = qualified(fact(cat, eats, fish), testimonial, 0.9,
                          'The cat eats fish.', source(book, 12)),
    % A genuinely different odd panel: one agrees, one disagrees, one abstains.
    Panel = [test_fact_refinery:te_agree,
             test_fact_refinery:te_disagree,
             test_fact_refinery:te_unknown],
    % Run the Minority Report panel over the claim.
    fr_panel_vote(Panel, Qualified, VoteRecord),
    % The record shows one agreement, one disagreement, and one honest abstention.
    assertion(VoteRecord = votes(1, 1, 1, _)).

% AC-FR-010: the honesty gate refuses a fact whose words are not grounded.
test(honesty_gate_flags_unconnected) :-
    % A qualified fact whose words float free of the grounded concepts.
    Qualified = qualified(fact(zebra, hunts, comet), testimonial, 0.9,
                          'A sentence.', source(book, 1)),
    % Run the plain-code gate against a small set of grounded concepts.
    fr_honesty_gate(Qualified, [cat, eats, fish], Result),
    % The gate names every word that does not connect, sorted.
    assertion(Result == failed(unconnected([comet, hunts, zebra]))).

% AC-FR-011: the honesty gate refuses a fact whose citation is not reachable.
test(honesty_gate_flags_bad_citation) :-
    % A qualified fact whose every word is grounded but whose citation is fake.
    Qualified = qualified(fact(cat, eats, fish), testimonial, 0.9,
                          'The cat eats fish.', source(no_such_source, 999)),
    % Run the gate with all fact words grounded, leaving only the citation to fail.
    fr_honesty_gate(Qualified, [cat, eats, fish], Result),
    % The unregistered source makes the citation unreachable, so the gate fails on it.
    assertion(Result == failed(bad_citation(source(no_such_source, 999)))).

% AC-FR-012: approving a fact grounds it and the honest "why?" tells its full story.
test(approve_grounds_and_why_tells_full_story) :-
    % Start from clean refinery state.
    fr_reset,
    % The permanent provenance the refinery would attach to a survivor.
    Prov = prov(testimonial, 0.9, source(book, 12), 'The cat eats fish.',
                votes(3, 0, 0, []), ok),
    % Ground the reviewed fact with its full provenance.
    fr_approve(fact(cat, eats, fish), Prov),
    % The grounded store returns exactly the provenance it was given.
    fr_grounded_fact(fact(cat, eats, fish), Got),
    % The stored provenance matches the approved provenance.
    assertion(Got == Prov),
    % Ask the glass-box "why?" for the grounded fact.
    fr_why(fact(cat, eats, fish), Why),
    % The why cites the record, who checked it, the gate, and the confidence.
    assertion(Why == why(fact(cat, eats, fish),
                         grounding(testimonial),
                         record(source(book, 12), 'The cat eats fish.'),
                         checked_by(votes(3, 0, 0, [])),
                         gate(ok),
                         confidence(0.9))).

% AC-FR-013: the full pipeline sends a grounded fact to a lane and rejects an ungrounded one.
test(refine_pipeline_end_to_end) :-
    % Start from clean refinery state.
    fr_reset,
    % Register a real file as the reference source so its citation is reachable.
    rl_register(refbook, '/home/ccaitwo/Mentova/src/mentova/reference_library.pl'),
    % The pipeline configuration: extractor, qualifier, an all-agree panel, grounded words.
    Config = refinery(test_fact_refinery:te_extract_pipe,
                      test_fact_refinery:te_qualify,
                      [test_fact_refinery:te_agree,
                       test_fact_refinery:te_agree,
                       test_fact_refinery:te_agree],
                      [cat, eats, fish]),
    % Run one passage through every automatic stage.
    fr_refine(Config, 'a passage', Outcomes),
    % The grounded candidate reaches the high lane; the ungrounded one is gate-rejected.
    assertion(Outcomes = [outcome(fact(cat, eats, fish), high, _),
                          outcome(fact(zzz, qqq, www),
                                  rejected(gate(unconnected([qqq, www, zzz]))), _)]),
    % The high lane now holds exactly the surviving grounded fact.
    fr_lane_entries(high, HighEntries),
    % One entry, carrying the fact and its provenance.
    assertion(HighEntries = [entry(fact(cat, eats, fish), _)]),
    % The rejected list records the gate refusal with its reason.
    fr_rejected(Rejected),
    % The ungrounded candidate appears with its unconnected-word reason.
    assertion(memberchk(rejected(fact(zzz, qqq, www),
                                 gate(unconnected([qqq, www, zzz]))), Rejected)),
    % Nothing was sent to the Minority Report Bin in this run.
    fr_bin_contents(Bin),
    % The Bin is empty.
    assertion(Bin == []),
    % A deterministic hand audit of one high-lane entry reproducibly draws it.
    fr_audit_sample(high, 12345, 1, Sample),
    % The sole high-lane entry is the fact that survived.
    assertion(Sample = [entry(fact(cat, eats, fish), _)]),
    % An audit of the empty medium lane draws nothing.
    fr_audit_sample(medium, 12345, 2, EmptySample),
    % The empty lane samples the empty list.
    assertion(EmptySample == []).

% Close the test block for the fact_refinery module.
:- end_tests(fact_refinery).
