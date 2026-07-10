/*  Mentova — The Fact Refinery and the Minority Report Panel  (Acc_425)

    Implements Appendices R and S of Teach_Mentova_To_Chat_v2: a pipeline
    that reads raw text at one end and produces clean, checked, sourced
    candidate facts at the other, without ever trusting a language
    model's fluent guess.

    The cardinal rule (S.1): nothing a language model says is trusted
    merely because a language model said it. Every model in this module
    is a caller-supplied goal — a local model through Ollama, a stronger
    remote model, or a deterministic test double — and every model's
    output is only a CANDIDATE until checked by votes, by plain code,
    and by review.

    The six stages (S.2):

      1. Extraction     fr_extract/3     a cheap model proposes candidate
                        facts in a strict shape: subject, relation,
                        object, exact source sentence, citation.
      2. Qualification  fr_qualify/3     a stronger model checks support,
                        well-formedness, grounding kind (direct or
                        testimonial, Appendix R), and stability,
                        assigning a confidence.
      3. Cross-check    fr_panel_vote/3  the Minority Report panel: an
                        odd number of genuinely different models vote
                        BLIND, answers are NORMALIZED before counting so
                        wording differences count as agreement, and "I
                        do not know" is an honest abstention, never a
                        disagreement (S.3).
      4. Honesty gate   fr_honesty_gate/4 plain code, no model votes:
                        the fact's words must connect to concepts
                        already grounded, and the citation must be real
                        and reachable in the reference library. Kept
                        even for unanimous facts, because a unanimous
                        panel can share a misconception (S.4).
      5. Review         fr_refine/3 grades survivors into confidence
                        lanes (S.5): unanimous -> high (auto-acceptable
                        with a random hand audit), strong majority ->
                        medium (lighter look), split -> the Minority
                        Report Bin for a person; fr_submit_review/3
                        hands a survivor to the existing chat Review
                        Queue (chat_db's mc_propose_fact).
      6. Grounding      fr_approve/2 turns a reviewed fact into an
                        understood fact with ALL its provenance, so the
                        honest answer to "why?" (fr_why/2) cites the
                        record, the votes, and the checks — testimonial
                        grounding done cleanly (R.3).

    The referee (S.6): a stronger model is spent only where it changes
    an outcome — fr_referee_bin/3 lets it rule on Bin entries.

    Every vote is recorded, so Mentova can always show who agreed and
    who did not (S.5).

    Predicates:
      fr_reset/0            -- clear all refinery state
      fr_normalize/2        -- +Triple, -NormalizedTriple
      fr_extract/3          -- :Extractor, +Passage, -Candidates
      fr_qualify/3          -- :Qualifier, +Candidate, -Qualified
      fr_panel_vote/3       -- +PanelGoals, +Candidate, -VoteRecord
      fr_lane/2             -- +VoteRecord, -Lane
      fr_honesty_gate/3     -- +Qualified, +GroundedConcepts, -Result
      fr_refine/3           -- +Config, +Passage, -Outcomes
      fr_lane_entries/2     -- +Lane, -Entries
      fr_bin_contents/1     -- -BinEntries
      fr_rejected/1         -- -RejectedEntries
      fr_referee_bin/3      -- :RefereeGoal, +Fact, -Ruling
      fr_submit_review/3    -- +Fact, +Prov, -QueueId  (chat Review Queue)
      fr_approve/2          -- +Fact, +Prov            (ground with provenance)
      fr_grounded_fact/2    -- ?Fact, -Prov
      fr_why/2              -- +Fact, -Why
      fr_audit_sample/4     -- +Lane, +Seed, +N, -Sample
      fr_ollama_models/1    -- -Models      (optional local-model adapter)
      fr_ollama_generate/4  -- +Model, +Prompt, +TimeoutSec, -Reply
*/

% Declare this file as the 'fact_refinery' module and list its exports.
:- module(fact_refinery, [
    % Export fr_reset/0: clear all refinery state.
    fr_reset/0,
    % Export fr_normalize/2: normalize a triple for blind vote counting.
    fr_normalize/2,
    % Export fr_extract/3: stage one, bulk candidate extraction.
    fr_extract/3,
    % Export fr_qualify/3: stage two, qualification by a stronger mind.
    fr_qualify/3,
    % Export fr_panel_vote/3: stage three, the Minority Report panel.
    fr_panel_vote/3,
    % Export fr_lane/2: grade a vote record into a confidence lane.
    fr_lane/2,
    % Export fr_honesty_gate/3: stage four, the plain-code gate.
    fr_honesty_gate/3,
    % Export fr_refine/3: the full pipeline over one passage.
    fr_refine/3,
    % Export fr_lane_entries/2: the graded survivors of a lane.
    fr_lane_entries/2,
    % Export fr_bin_contents/1: the Minority Report Bin.
    fr_bin_contents/1,
    % Export fr_rejected/1: candidates dropped with their reasons.
    fr_rejected/1,
    % Export fr_referee_bin/3: a stronger model rules on a Bin entry.
    fr_referee_bin/3,
    % Export fr_submit_review/3: hand a survivor to the chat Review Queue.
    fr_submit_review/3,
    % Export fr_approve/2: stage six, ground a reviewed fact.
    fr_approve/2,
    % Export fr_grounded_fact/2: query the grounded facts with provenance.
    fr_grounded_fact/2,
    % Export fr_why/2: the honest answer to "why?" for a grounded fact.
    fr_why/2,
    % Export fr_audit_sample/4: deterministic random hand-audit sample.
    fr_audit_sample/4,
    % Export fr_ollama_models/1: list locally available Ollama models.
    fr_ollama_models/1,
    % Export fr_ollama_generate/4: call a local Ollama model, guarded.
    fr_ollama_generate/4
% Close the module declaration.
]).

% Import list helpers.
:- use_module(library(lists), [member/2, nth0/3, reverse/2]).
% Import the reference library for citation reachability checks.
:- use_module('reference_library', [rl_citation_exists/1]).
% Import the line reader used by the Ollama adapter.
:- use_module(library(readutil), [read_line_to_string/2]).

% The extractor is a caller-module closure over a passage.
:- meta_predicate fr_extract(2, +, -).
% The qualifier is a caller-module closure over a candidate.
:- meta_predicate fr_qualify(2, +, -).
% The referee is a caller-module closure over a fact.
:- meta_predicate fr_referee_bin(2, +, -).

% ---------------------------------------------------------------------------
% Internal state
% ---------------------------------------------------------------------------

% fr_lane_entry_/3: (Lane, Fact, Prov) — graded survivors by lane.
:- dynamic fr_lane_entry_/3.
% fr_bin_/2: (Fact, Prov) — the Minority Report Bin.
:- dynamic fr_bin_/2.
% fr_rejected_/3: (Fact, Reason, Prov) — dropped candidates and why.
:- dynamic fr_rejected_/3.
% fr_grounded_/2: (Fact, Prov) — understood facts with full provenance.
:- dynamic fr_grounded_/2.
% fr_run_counter_/1: counter for refinery run identifiers.
:- dynamic fr_run_counter_/1.
% Initialize the run counter.
fr_run_counter_(0).

% Define fr_reset: clear every piece of refinery state.
fr_reset :-
    % Drop the lane entries.
    retractall(fr_lane_entry_(_, _, _)),
    % Drop the Bin.
    retractall(fr_bin_(_, _)),
    % Drop the rejections.
    retractall(fr_rejected_(_, _, _)),
    % Drop the grounded facts.
    retractall(fr_grounded_(_, _)).

% ---------------------------------------------------------------------------
% fr_normalize/2 — one tidy shape so wording differences count as agreement
% ---------------------------------------------------------------------------

% Define fr_normalize: normalize each slot of a subject-relation-object triple.
fr_normalize(triple(S, R, O), triple(NS, NR, NO)) :-
    % Normalize the subject.
    fr_norm_term(S, NS),
    % Normalize the relation.
    fr_norm_term(R, NR),
    % Normalize the object.
    fr_norm_term(O, NO).

% fr_norm_term(+Term, -Norm): lowercase, spaces to underscores; numbers pass.
fr_norm_term(Term, Term) :-
    % Numbers are already canonical.
    number(Term),
    % Stop looking at other clauses.
    !.
% Atoms and strings are lowercased and de-spaced.
fr_norm_term(Term, Norm) :-
    % Accept an atom or a string.
    atom_string(Atom, Term),
    % Lowercase the whole term.
    downcase_atom(Atom, Lower),
    % Split on spaces.
    atomic_list_concat(Parts, ' ', Lower),
    % Rejoin with underscores so "Signed In" equals signed_in.
    atomic_list_concat(Parts, '_', Norm).

% ---------------------------------------------------------------------------
% STAGE ONE — fr_extract/3: cheap, in bulk, strict shape
% ---------------------------------------------------------------------------

% Define fr_extract: the extractor proposes candidates; the shape is law.
fr_extract(Extractor, Passage, Candidates) :-
    % Ask the extractor model for its candidates.
    call(Extractor, Passage, Raw),
    % Keep only candidates in the strict five-slot shape.
    findall(C,
        % Take each proposal in turn.
        ( member(C, Raw),
          % The strict shape: subject, relation, object, sentence, citation.
          C = cand(_, _, _, Sentence, source(_, _)),
          % The exact source sentence must be present.
          Sentence \== '' ),
        Candidates).

% ---------------------------------------------------------------------------
% STAGE TWO — fr_qualify/3: a stronger mind checks each candidate
% ---------------------------------------------------------------------------

% Define fr_qualify: the qualifier's verdict is validated by plain code.
fr_qualify(Qualifier, Candidate, Qualified) :-
    % Ask the qualifier model for its judgment.
    call(Qualifier, Candidate, Judgment),
    % The judgment must have the qualified/3 shape.
    Judgment = qualified(fact(S, R, O), Grounding, Confidence),
    % The grounding kind is one of the two of Appendix R.
    memberchk(Grounding, [direct, testimonial]),
    % Confidence is a fraction.
    number(Confidence),
    % Lower bound.
    Confidence >= 0.0,
    % Upper bound.
    Confidence =< 1.0,
    % Carry the candidate's source sentence and citation forward.
    Candidate = cand(_, _, _, Sentence, Citation),
    % Assemble the qualified record.
    Qualified = qualified(fact(S, R, O), Grounding, Confidence, Sentence, Citation).

% ---------------------------------------------------------------------------
% STAGE THREE — fr_panel_vote/3: the Minority Report panel
% ---------------------------------------------------------------------------

% Define fr_panel_vote: an odd panel votes blind; answers are normalized.
fr_panel_vote(PanelGoals, qualified(Fact, _, _, Sentence, Citation), VoteRecord) :-
    % An odd number of voters, three or five, avoids ties (S.3).
    length(PanelGoals, N),
    % At least three genuinely different minds.
    N >= 3,
    % The panel size must be odd.
    1 =:= N mod 2,
    % The claim under vote, in normalized form.
    Fact = fact(S, R, O),
    % Normalize the candidate triple once.
    fr_normalize(triple(S, R, O), NormClaim),
    % Each model judges the fact on its own, blind to the others (S.3).
    findall(vote(Model, Verdict),
        % Take each panel member in turn.
        ( member(Model, PanelGoals),
          % The model sees only the claim, its sentence, and its citation.
          fr_one_vote(Model, Fact, Sentence, Citation, NormClaim, Verdict) ),
        PerModel),
    % Count the agreements.
    fr_count_verdicts(PerModel, agree, Agree),
    % Count the disagreements.
    fr_count_verdicts(PerModel, disagree, Disagree),
    % Count the honest abstentions.
    fr_count_verdicts(PerModel, abstain, Abstain),
    % Assemble the full, permanently recorded vote.
    VoteRecord = votes(Agree, Disagree, Abstain, PerModel).

% fr_one_vote(+Model, +Fact, +Sentence, +Citation, +NormClaim, -Verdict).
fr_one_vote(Model, Fact, Sentence, Citation, NormClaim, Verdict) :-
    % Ask the model for its own reading of the evidence.
    catch(call(Model, judge(Fact, Sentence, Citation), Answer), _, Answer = unknown),
    % Classify the answer.
    (   Answer == unknown
    % "I do not know" is an honest abstention, not a disagreement (S.3).
    ->  Verdict = abstain
    % A triple answer is normalized before counting.
    ;   Answer = triple(_, _, _)
    ->  fr_normalize(Answer, NormAnswer),
        % The same fact in different words counts as agreement.
        (   NormAnswer == NormClaim
        % The normalized answers match: agreement.
        ->  Verdict = agree
        % A genuinely different claim counts as a split.
        ;   Verdict = disagree(NormAnswer)
        )
    % Anything malformed is treated as an abstention, never as agreement.
    ;   Verdict = abstain
    ).

% fr_count_verdicts(+PerModel, +Kind, -Count): tally one verdict kind.
fr_count_verdicts(PerModel, Kind, Count) :-
    % Collect the votes of the requested kind.
    findall(x,
        % Take each recorded vote.
        ( member(vote(_, V), PerModel),
          % Match the verdict kind, treating disagree/1 by its functor.
          ( Kind == disagree -> V = disagree(_) ; V == Kind ) ),
        Xs),
    % The tally is the length.
    length(Xs, Count).

% ---------------------------------------------------------------------------
% fr_lane/2 — confidence lanes rather than keep-or-dump (S.5)
% ---------------------------------------------------------------------------

% Define fr_lane: grade a vote record into high, medium, or the Bin.
fr_lane(votes(Agree, Disagree, _Abstain, _), Lane) :-
    % The judged votes are those that were not abstentions.
    Judged is Agree + Disagree,
    % Decide the lane.
    (   Judged =:= 0
    % Nobody judged: only a person can settle it.
    ->  Lane = minority_bin
    % Unanimous agreement among those who judged.
    ;   Disagree =:= 0
    % The high-confidence lane, auto-acceptable with a sampled hand audit.
    ->  Lane = high
    % A strong majority, such as four of five, gets a lighter human look.
    ;   Agree / Judged >= 0.75
    % The medium lane.
    ->  Lane = medium
    % A split goes to the Minority Report Bin for a person to settle.
    ;   Lane = minority_bin
    ).

% ---------------------------------------------------------------------------
% STAGE FOUR — fr_honesty_gate/3: plain code, no model gets a vote (S.2, S.4)
% ---------------------------------------------------------------------------

% Define fr_honesty_gate: connection to grounded concepts, and a real citation.
fr_honesty_gate(qualified(fact(S, R, O), _, _, _, Citation), GroundedConcepts, Result) :-
    % Gather every word of the fact.
    fr_fact_words([S, R, O], Words),
    % Find the words that do not connect to already-grounded concepts.
    findall(W,
        % Take each word of the fact.
        ( member(W, Words),
          % Keep it when it is not grounded.
          \+ memberchk(W, GroundedConcepts) ),
        Unconnected),
    % Both checks must pass; neither is a model's opinion.
    (   Unconnected \== []
    % Some words float free of the grounded Lattice.
    ->  Result = failed(unconnected(Unconnected))
    % The citation must be real and reachable in the reference library.
    ;   \+ rl_citation_exists(Citation)
    % The cited line does not exist.
    ->  Result = failed(bad_citation(Citation))
    % Both checks pass.
    ;   Result = ok
    ).

% fr_fact_words(+Terms, -Words): the underscore-split words of the fact.
fr_fact_words(Terms, Words) :-
    % Collect the words of every slot.
    findall(W,
        % Take each slot of the fact.
        ( member(T, Terms),
          % Normalize it the same way votes are normalized.
          fr_norm_term(T, Norm),
          % Numbers ground themselves.
          \+ number(Norm),
          % Split the normalized slot into words.
          atomic_list_concat(Parts, '_', Norm),
          % Take each word.
          member(W, Parts),
          % Skip empties.
          W \== '' ),
        Raw),
    % De-duplicate.
    sort(Raw, Words).

% ---------------------------------------------------------------------------
% THE FULL PIPELINE — fr_refine/3
% ---------------------------------------------------------------------------

% Define fr_refine: run one passage through all the automatic stages.
% Config = refinery(Extractor, Qualifier, PanelGoals, GroundedConcepts).
fr_refine(refinery(Extractor, Qualifier, PanelGoals, GroundedConcepts), Passage, Outcomes) :-
    % Stage one: extraction, cheap and in bulk.
    fr_extract(Extractor, Passage, Candidates),
    % Run every candidate through stages two, three, and four.
    findall(Outcome,
        % Take each candidate in turn.
        ( member(Candidate, Candidates),
          % Process one candidate end to end.
          fr_refine_one(Qualifier, PanelGoals, GroundedConcepts, Candidate, Outcome) ),
        Outcomes).

% fr_refine_one(+Qualifier, +Panel, +Grounded, +Candidate, -Outcome).
fr_refine_one(Qualifier, PanelGoals, GroundedConcepts, Candidate, Outcome) :-
    % Stage two: qualification; a candidate the qualifier drops is rejected.
    (   fr_qualify(Qualifier, Candidate, Qualified)
    % Qualification succeeded; continue with the panel.
    ->  Qualified = qualified(Fact, Grounding, Confidence, Sentence, Citation),
        % Stage three: the blind, normalized panel vote.
        fr_panel_vote(PanelGoals, Qualified, VoteRecord),
        % Grade the vote into a confidence lane.
        fr_lane(VoteRecord, Lane),
        % Stage four: the plain-code honesty gate, kept even for unanimity.
        fr_honesty_gate(Qualified, GroundedConcepts, Gate),
        % The permanent provenance of this fact.
        Prov = prov(Grounding, Confidence, Citation, Sentence, VoteRecord, Gate),
        % Dispatch by gate and lane.
        (   Gate = failed(Reason)
        % The gate is absolute: a failing fact is rejected with its reason.
        ->  assertz(fr_rejected_(Fact, gate(Reason), Prov)),
            % Report the rejection.
            Outcome = outcome(Fact, rejected(gate(Reason)), VoteRecord)
        % A split goes to the Minority Report Bin for a person.
        ;   Lane == minority_bin
        ->  assertz(fr_bin_(Fact, Prov)),
            % Report the Bin placement.
            Outcome = outcome(Fact, minority_bin, VoteRecord)
        % High and medium survivors enter their lanes for review.
        ;   assertz(fr_lane_entry_(Lane, Fact, Prov)),
            % Report the lane.
            Outcome = outcome(Fact, Lane, VoteRecord)
        )
    % The qualifier dropped the candidate as weak.
    ;   Candidate = cand(S, R, O, Sentence0, Citation0),
        % Record the rejection with its provenance-to-date.
        assertz(fr_rejected_(fact(S, R, O), unqualified,
                             prov(none, 0.0, Citation0, Sentence0, none, none))),
        % Report the rejection.
        Outcome = outcome(fact(S, R, O), rejected(unqualified), none)
    ).

% Define fr_lane_entries: the graded survivors of one lane.
fr_lane_entries(Lane, Entries) :-
    % Collect the lane's entries in arrival order.
    findall(entry(Fact, Prov), fr_lane_entry_(Lane, Fact, Prov), Entries).

% Define fr_bin_contents: the Minority Report Bin, a valuable queue.
fr_bin_contents(BinEntries) :-
    % Collect the Bin entries with their full stories.
    findall(entry(Fact, Prov), fr_bin_(Fact, Prov), BinEntries).

% Define fr_rejected: the dropped candidates and the reasons they dropped.
fr_rejected(Rejected) :-
    % Collect every rejection.
    findall(rejected(Fact, Reason), fr_rejected_(Fact, Reason, _), Rejected).

% ---------------------------------------------------------------------------
% THE REFEREE — a stronger mind, spent only where it changes an outcome (S.6)
% ---------------------------------------------------------------------------

% Define fr_referee_bin: the referee rules keep or reject on a Bin entry.
fr_referee_bin(RefereeGoal, Fact, Ruling) :-
    % The fact must actually be in the Bin.
    fr_bin_(Fact, Prov),
    % Ask the stronger model for its ruling on the full story.
    call(RefereeGoal, Fact, Prov, Ruling),
    % Only keep and reject are lawful rulings.
    memberchk(Ruling, [keep, reject]),
    % The entry leaves the Bin either way.
    retract(fr_bin_(Fact, Prov)),
    % Apply the ruling.
    (   Ruling == keep
    % A kept fact enters the medium lane for the lighter human look.
    ->  assertz(fr_lane_entry_(medium, Fact, Prov))
    % A rejected fact is recorded with the referee as the reason.
    ;   assertz(fr_rejected_(Fact, referee, Prov))
    ).

% ---------------------------------------------------------------------------
% STAGE FIVE — fr_submit_review/3: into the existing chat Review Queue
% ---------------------------------------------------------------------------

% The review queue types its proposer as an integer mentor account id;
% zero is reserved as the fact refinery's system identity, and the
% session tag names the refinery run so the audit trail stays readable.
fr_refinery_mentor_id(0).

% Define fr_submit_review: hand a survivor to chat_db's review queue.
fr_submit_review(Fact, Prov, QueueId) :-
    % Allocate a run identifier to stand as the proposing session.
    retract(fr_run_counter_(N)),
    % Increment the counter.
    N1 is N + 1,
    % Store the counter back.
    assertz(fr_run_counter_(N1)),
    % Build the session tag, naming the refinery as the proposer.
    atomic_list_concat([fact_refinery_run_, N1], RunId),
    % The refinery's reserved system identity.
    fr_refinery_mentor_id(MentorId),
    % The proposal carries the fact together with its provenance.
    Proposal = refinery_fact(Fact, Prov),
    % Enqueue through the chat database's existing review machinery.
    catch(chat_db:mc_propose_fact(Proposal, MentorId, RunId, QueueId), _, fail).

% ---------------------------------------------------------------------------
% STAGE SIX — fr_approve/2 and the honest "why?"
% ---------------------------------------------------------------------------

% Define fr_approve: an approved fact becomes understood, provenance intact.
fr_approve(Fact, Prov) :-
    % Never ground the same fact twice.
    (   fr_grounded_(Fact, _)
    % Already grounded: nothing to add.
    ->  true
    % Ground it with its full story.
    ;   assertz(fr_grounded_(Fact, Prov))
    ).

% Define fr_grounded_fact: query the understood facts with provenance.
fr_grounded_fact(Fact, Prov) :-
    % Enumerate or test the grounded store.
    fr_grounded_(Fact, Prov).

% Define fr_why: "a trusted record says so, here is that record, and here
% is how it was checked" — the honest answer of Appendix R.3.
fr_why(Fact, Why) :-
    % The fact must be grounded to have a why.
    fr_grounded_(Fact, prov(Grounding, Confidence, Citation, Sentence, VoteRecord, Gate)),
    % Assemble the full glass-box story.
    Why = why(Fact,
              % How the fact is anchored: perception or trusted record.
              grounding(Grounding),
              % The record itself.
              record(Citation, Sentence),
              % Who agreed and who did not.
              checked_by(VoteRecord),
              % The plain-code checks that reality concurred.
              gate(Gate),
              % The qualifier's confidence.
              confidence(Confidence)).

% ---------------------------------------------------------------------------
% fr_audit_sample/4 — the deterministic random hand audit of a lane (S.5)
% ---------------------------------------------------------------------------

% Define fr_audit_sample: reproducibly sample N entries of a lane.
fr_audit_sample(Lane, Seed, N, Sample) :-
    % Fetch the lane's entries.
    fr_lane_entries(Lane, Entries),
    % Count them.
    length(Entries, Len),
    % An empty lane samples nothing.
    (   Len =:= 0
    % Nothing to audit.
    ->  Sample = []
    % Draw N deterministic picks.
    ;   fr_draw(N, Seed, Len, Entries, [], Rev),
        % Picks were accumulated newest-first.
        reverse(Rev, Sample)
    ).

% fr_draw(+N, +Seed, +Len, +Entries, +Acc, -Sample): seeded picks.
fr_draw(0, _, _, _, Acc, Acc) :- !.
% Draw one entry and recurse with the advanced seed.
fr_draw(N, Seed, Len, Entries, Acc, Sample) :-
    % One step of the linear congruential generator.
    Seed2 is (Seed * 1103515245 + 12345) mod 2147483648,
    % Reduce the new seed into an index.
    I is Seed2 mod Len,
    % Fetch the picked entry.
    nth0(I, Entries, Pick),
    % One fewer pick remains.
    N1 is N - 1,
    % Continue with the advanced seed.
    fr_draw(N1, Seed2, Len, Entries, [Pick | Acc], Sample).

% ---------------------------------------------------------------------------
% THE OLLAMA ADAPTER — optional local models, guarded, never load-bearing
% ---------------------------------------------------------------------------

% Define fr_ollama_models: list the locally installed Ollama models.
fr_ollama_models(Models) :-
    % Any failure to reach Ollama simply reports no models.
    catch(fr_ollama_models_(Models), _, Models = []).

% fr_ollama_models_(-Models): parse the output of "ollama list".
fr_ollama_models_(Models) :-
    % Run the list command.
    process_create(path(ollama), [list], [stdout(pipe(Out))]),
    % Read every output line.
    fr_read_lines(Out, Lines),
    % Close the pipe.
    close(Out),
    % Drop the header line and take the first token of each row.
    (   Lines = [_Header | Rows]
    % Extract the model names.
    ->  findall(Name,
            % Take each row in turn.
            ( member(Row, Rows),
              % Split the row on whitespace.
              split_string(Row, " \t", " \t", [First | _]),
              % Skip empty rows.
              First \== "",
              % The first token is the model name.
              atom_string(Name, First) ),
            Models)
    % No output means no models.
    ;   Models = []
    ).

% fr_read_lines(+Stream, -Lines): read every line of a stream.
fr_read_lines(Stream, Lines) :-
    % Read the next line.
    read_line_to_string(Stream, Line),
    % Stop at end of file.
    (   Line == end_of_file
    % No more lines.
    ->  Lines = []
    % Keep the line and continue.
    ;   Lines = [Line | Rest],
        % Read the rest.
        fr_read_lines(Stream, Rest)
    ).

% Define fr_ollama_generate: one guarded, time-limited local-model call.
fr_ollama_generate(Model, Prompt, TimeoutSec, Reply) :-
    % Any failure or timeout makes the call fail rather than hang or lie.
    catch(
        % Enforce the wall-clock limit.
        call_with_time_limit(TimeoutSec, fr_ollama_generate_(Model, Prompt, Reply)),
        % On any error the adapter fails honestly.
        _, fail).

% fr_ollama_generate_(+Model, +Prompt, -Reply): the raw call.
fr_ollama_generate_(Model, Prompt, Reply) :-
    % Run the model once with the prompt as its input.
    process_create(path(ollama), [run, Model, Prompt], [stdout(pipe(Out))]),
    % Read the whole reply.
    fr_read_lines(Out, Lines),
    % Close the pipe.
    close(Out),
    % Join the reply lines into one atom.
    atomic_list_concat(Lines, '\n', Reply).
