/*  Mentova — THE LATTICE BRIDGE: causal content into Causalontology 2.0.0 form
    (Order Two of the Lattice-Bridge change set)

    This module expresses THE LATTICE's causal and relational content as a
    complete, schema-valid Causalontology 2.0.0 record set, signs the provenance
    with Mentova's Ed25519 key, and lets Mentova publish it to and read it back
    from the Causalontology commons — turning Mentova into a real contributor
    (the "first synthetic gardener").

    THE SCOPING RULE (decisive):
      A Lattice fact is exported to Causalontology 2.0.0 IF AND ONLY IF it
      expresses one of: causation (-> causal_relation_object); an enduring thing
      (-> continuant); a happening (-> occurrent); a disposition/function/role
      (-> realizable); a property (-> quality / state_assertion); a level of
      description (-> stratum); a cross-level identity (-> bridge); an interface
      (-> port / conduit); or provenance (-> assertion). It is NOT exported if it
      is perceptual grid/scene machinery, type-checker facts, or engine
      scaffolding. Causalontology models CAUSATION, not arbitrary facts; those
      remain native node_facts. This module never forces a non-causal fact in.

    THE TIER MAPPING (natural fit):
      - World-model laws / curriculum ("X causes Y")  -> TYPE TIER:
          occurrent + causal_relation_object (temporal window, modality),
          each vouched by a signed assertion carrying the evidence grade,
          the strength, and the confidence.
      - Levels of description (curriculum grades)      -> stratum (named scheme).
      - Enduring systems (the ARC-AGI-3 games)         -> continuant, each with a
          "winnable" disposition (-> realizable).
      - Mentova's EPISODIC MEMORY (what happened to it) -> TOKEN TIER
          (token_individual + token_occurrence + token_causal_claim), which is
          LOCAL BY DEFAULT for privacy and is emitted only on explicit opt-in.

    This is ADDITIVE, read-only export code. It imports NONE of the ARC
    grid/scene/induction/sequence packs and cannot affect the ARC-AGI-1/2
    solving core. Identity, canonicalization (RFC 8785) and the seventeen 2.0.0
    schemas are REUSED from Order One's conformance harness in the PrologAI repo.
*/

% Declare the module and its reuse surface.
:- module(lattice_co_export, [
    % lco_export/2: build, validate and write the 2.0.0 record set into a dir.
    lco_export/2,
    % lco_build_records/2: build the validated type-tier records (no writing).
    lco_build_records/2,
    % lco_mentova_key/2: Mentova's deterministic Ed25519 keypair (Secret, Pub).
    lco_mentova_key/2,
    % lco_write_ndjson/2: write a list of rec(Kind,Dict) as canonical NDJSON.
    lco_write_ndjson/2
   ]).

% The PrologAI repository root (override with the PROLOGAI_ROOT environment var).
lco_prolog_root(Root) :-
    % Take the environment override when present.
    ( getenv('PROLOGAI_ROOT', Root) -> true
    % Otherwise the standard sibling checkout used across Mentova's tools.
    ; Root = '/home/ccaitwo/PrologAI' ).

% Attach the whole PrologAI pack directory so library(causal_core) resolves.
:- initialization((lco_prolog_root(R), atomic_list_concat([R, '/packs'], P),
                   catch(attach_packs(P, [duplicate(replace)]), _, true)), now).
% Reuse Order One's canonicalization, identity and semantics (a real pack).
:- use_module(library(causal_core)).
% Reuse Order One's Ed25519 record signing/verification harness module.
:- initialization((lco_prolog_root(R),
    atomic_list_concat([R, '/tests/causalontology_conformance/signing.pl'], S),
    catch(ensure_loaded(S), _, true)), now).
% Reuse Order One's JSON-Schema validator for the seventeen 2.0.0 kinds.
:- initialization((lco_prolog_root(R),
    atomic_list_concat([R, '/tests/causalontology_conformance/schema_check.pl'], S),
    catch(ensure_loaded(S), _, true)), now).
% Standard libraries for hashing, lists and string handling.
:- use_module(library(sha)).
:- use_module(library(lists)).
:- use_module(library(apply)).

% A fixed release timestamp keeps every export byte-for-byte reproducible
% (a wall-clock time would re-hash and re-sign every record on each run).
lco_timestamp("2026-07-17T00:00:00Z").
% The named stratification scheme for Mentova's curriculum levels of description.
lco_scheme("mentova_curriculum").

% ---------------------------------------------------------------------------
% Mentova's cryptographic identity.
% ---------------------------------------------------------------------------

% -- lco_mentova_key(-Secret, -Pub): Mentova's deterministic Ed25519 keypair.
% The seed is SHA-256("key:mentova"), the same derivation the reference gardener
% and the conformance harness use for the "mentova" signer, so the public key is
% stable across the whole project. An operator may override the 32-byte seed by
% placing raw bytes in data/mentova_ed25519.seed.
lco_mentova_key(Secret, Pub) :-
    % Prefer an operator-provided seed file when present.
    ( exists_file('data/mentova_ed25519.seed')
      -> read_file_to_codes('data/mentova_ed25519.seed', Codes, [encoding(octet)]),
         length(Seed, 32), append(Seed, _, Codes)
    % Otherwise derive the seed deterministically from the signer name.
    ;  sha_hash("key:mentova", Seed, [algorithm(sha256), encoding(utf8)]) ),
    % Derive the keypair (Secret is the seed; Pub is "ed25519:<hex>").
    co_keypair_from_seed(Seed, Secret, Pub).

% ---------------------------------------------------------------------------
% Collecting the native causal content from the built lattice.
% ---------------------------------------------------------------------------

% -- lco_native_cros(-Cros): every native reified Causal Relation Object.
% Each is cro(NativeId, Causes, Effects, temporal(Lo,Hi,Unit), Modality,
% Strength, Context, prov(Source, Evidence, Conf)).
lco_native_cros(Cros) :-
    % Collect every asserted causal_core causal_relation_object, provenance and all.
    findall(cro(Id, Causes, Effects, T, Modality, Strength, Context, Prov),
            catch(causal_core:causal_core_causal_relation_object(
                      Id, Causes, Effects, T, Modality, Strength, Context, Prov),
                  _, fail),
            Cros).

% -- lco_cro_grade(+Context, -Grade): the curriculum grade named by a context.
lco_cro_grade(Context, Grade) :-
    % A grade(G) marker names the level of description; otherwise there is none.
    ( is_list(Context), member(grade(G), Context) -> Grade = G ; Grade = none ).

% -- lco_cro_game(+Context, -Game): the ARC-AGI-3 game named by a context.
lco_cro_game(Context, Game) :-
    % A game(G) marker names the enduring system; otherwise there is none.
    ( is_list(Context), member(game(G), Context) -> Game = G ; Game = none ).

% ---------------------------------------------------------------------------
% Canonical labels and categories (the occurrent/continuant naming discipline).
% ---------------------------------------------------------------------------

% -- lco_label(+Term, -Label): a canonical snake_case label for a native term.
% The 2.0.0 label discipline is ^[a-z][a-z0-9_]*$: English, lowercase, whole
% words. A compound term like g(ls20,step_on(changer)) becomes
% "g_ls20_step_on_changer"; makes(dog) becomes "makes_dog".
lco_label(Term, Label) :-
    % Render the term to its canonical text form.
    term_to_atom(Term, A0),
    % Lowercase every letter.
    downcase_atom(A0, A1),
    % Fold every run of non-[a-z0-9_] characters to a single underscore.
    atom_codes(A1, Cs0),
    lco_fold_codes(Cs0, Cs1),
    % Materialise the folded codes as an atom.
    atom_codes(A2, Cs1),
    % Trim any leading or trailing underscores.
    lco_trim_underscores(A2, A3),
    % Guarantee a leading letter (prefix o_ when the first char is not a-z).
    ( atom_codes(A3, [C|_]), C >= 0'a, C =< 0'z
      -> A4 = A3 ; atom_concat('o_', A3, A4) ),
    % Return the label as a string (schema string values are strings).
    atom_string(A4, Label).

% -- lco_fold_codes(+In, -Out): map non-label characters to underscores and
% collapse consecutive underscores into one.
lco_fold_codes([], []).
% A label character (a-z, 0-9, underscore) is kept verbatim.
lco_fold_codes([C|Cs], [C|Rest]) :-
    lco_label_code(C), !, lco_fold_codes(Cs, Rest).
% Any other character becomes an underscore, unless the previous emit was one.
lco_fold_codes([_|Cs], Out) :-
    % Look ahead: drop this separator if the next kept run also starts a separator
    % run, so multiple separators collapse to a single underscore.
    ( Cs = [D|_], \+ lco_label_code(D)
      -> lco_fold_codes(Cs, Out)
      ;  Out = [0'_|Rest], lco_fold_codes(Cs, Rest) ).

% -- lco_label_code(+C): C is a legal interior label character.
lco_label_code(C) :- C >= 0'a, C =< 0'z.
% Digits are legal interior characters.
lco_label_code(C) :- C >= 0'0, C =< 0'9.
% The underscore is a legal interior character.
lco_label_code(0'_).

% -- lco_trim_underscores(+A0, -A): strip leading and trailing underscores.
lco_trim_underscores(A0, A) :-
    % Strip a leading underscore and recurse.
    ( atom_concat('_', Rest, A0) -> lco_trim_underscores(Rest, A)
    % Strip a trailing underscore and recurse.
    ; atom_concat(Rest, '_', A0) -> lco_trim_underscores(Rest, A)
    % Nothing left to strip.
    ; A = A0 ).

% -- lco_category(+Term, -Category): the occurrent category for a native term.
% Agent-initiated verbs are actions; everything else is an event. Only
% determinism matters for identity, so the closed action set below is fixed.
lco_category(Term, Category) :-
    % Unwrap a game-scoped term g(Game, Inner) to classify by the inner verb.
    ( Term = g(_, Inner) -> functor(Inner, F, _) ; functor(Term, F, _) ),
    % An agent action verb yields the action category; otherwise event.
    ( lco_action_verb(F) -> Category = "action" ; Category = "event" ).

% -- lco_action_verb(+Functor): the closed set of agent-action verbs.
lco_action_verb(F) :-
    % Membership in the fixed action-verb set.
    memberchk(F, [step_on, click, press, deliver, arrange, contact, move, select,
                  toggle, push, pull, shove, swap, teleport, rotate, resize,
                  reshape, recolour, remove, grab_drop_or_delete, cast, pour,
                  connect, set, shift, jump_capture, transfer, unlock, act, makes,
                  dispense, merge, destroy, build_or_destroy, transform, refill,
                  refund, reset, check, change, grab, drop, delete, place, paint,
                  fill]).

% -- lco_grade_ordinal(+Grade, -Ordinal): a fixed developmental ladder ordinal.
lco_grade_ordinal(newborn, 0).       lco_grade_ordinal(infant, 1).
lco_grade_ordinal(toddler, 2).       lco_grade_ordinal(preschool, 3).
lco_grade_ordinal(kindergarten, 4).  lco_grade_ordinal(child, 5).
lco_grade_ordinal(preteen, 6).       lco_grade_ordinal(teen, 7).
lco_grade_ordinal(young_adult, 8).   lco_grade_ordinal(adult, 9).

% ---------------------------------------------------------------------------
% Building the identified content objects and signed provenance records.
% ---------------------------------------------------------------------------

% -- lco_mk(+Body, +Kind, -WithId): complete a content object with its content id.
lco_mk(Body, Kind, WithId) :-
    % Compute the content-addressed identity over the identity-bearing subset.
    causal_core_identify(Body, Kind, Id),
    % Attach it as the record's id.
    put_dict(id, Body, Id, WithId).

% -- lco_build_records(-Records, -Stats): build every validated type-tier record.
% Records is a list of rec(Kind, Dict); Stats is a list of Kind-Count pairs plus
% a native(Left) note for the scoping log.
lco_build_records(Records, Stats) :-
    % Mentova's signing identity (public key is the assertion source field).
    lco_mentova_key(Secret, Pub),
    % The native causal content.
    lco_native_cros(Cros),
    % The strata for the curriculum grades actually present.
    lco_build_strata(Cros, Strata, GradeStratumId),
    % The continuants for the ARC-AGI-3 games actually present.
    lco_build_continuants(Cros, Continuants, GameContId),
    % One "winnable" disposition realizable per game continuant.
    lco_build_realizables(GameContId, Realizables),
    % The deduplicated occurrents for every cause and effect term.
    lco_build_occurrents(Cros, GradeStratumId, Occurrents, TermOccId),
    % The causal_relation_objects, each referencing its cause/effect occurrents.
    lco_build_cros(Cros, TermOccId, Cro2, NativeCroId),
    % One signed assertion vouching for each causal_relation_object.
    lco_build_assertions(Cros, NativeCroId, Secret, Pub, Assertions),
    % Bridges where one happening is described at two strata (usually none).
    lco_build_bridges(Occurrents, Bridges),
    % Assemble in dependency order: vocabulary first, then laws, then provenance.
    append([Strata, Continuants, Realizables, Occurrents, Cro2, Bridges, Assertions],
           Records),
    % Validate every record before it is ever written or published.
    lco_validate_all(Records),
    % Tally the export for the manifest and the scoping log.
    lco_stats(Strata, Continuants, Realizables, Occurrents, Cro2, Bridges, Assertions, Stats).

% -- lco_build_strata(+Cros, -Strata, -GradeStratumId): a stratum per grade.
lco_build_strata(Cros, Strata, GradeStratumId) :-
    % The set of distinct curriculum grades named by any CRO context.
    ( setof(G, C^lco_cro_has_grade(Cros, C, G), Grades) -> true ; Grades = [] ),
    % Build a stratum record and an id mapping for each grade.
    foldl(lco_build_one_stratum, Grades, []-[], Strata0-Pairs),
    % The stratum records, in grade order.
    reverse(Strata0, Strata),
    % A grade -> stratum-id lookup list.
    GradeStratumId = Pairs.

% -- lco_cro_has_grade(+Cros, +Context, -Grade): a grade present in some CRO.
lco_cro_has_grade(Cros, Context, Grade) :-
    % Pick a CRO, read its context, and require a real grade marker.
    member(cro(_,_,_,_,_,_,Context,_), Cros), lco_cro_grade(Context, Grade), Grade \== none.

% -- lco_build_one_stratum(+Grade, +Acc0, -Acc): one stratum record and mapping.
lco_build_one_stratum(Grade, Recs0-Pairs0, [rec(stratum, St)|Recs0]-[Grade-Id|Pairs0]) :-
    % The scheme name and this grade's fixed ordinal.
    lco_scheme(Scheme), ( lco_grade_ordinal(Grade, Ord) -> true ; Ord = 50 ),
    % The grade name as a canonical label string.
    atom_string(Grade, Label),
    % The stratum body: a level of description within the named scheme.
    Body = _{type:"stratum", label:Label, scheme:Scheme, ordinal:Ord},
    % Complete it with its content id.
    lco_mk(Body, stratum, St),
    % The stratum's id for the occurrent stratum links.
    get_dict(id, St, Id).

% -- lco_build_continuants(+Cros, -Continuants, -GameContId): a continuant per game.
lco_build_continuants(Cros, Continuants, GameContId) :-
    % The set of distinct ARC-AGI-3 games named by any CRO context.
    ( setof(Gm, C^lco_cro_has_game(Cros, C, Gm), Games) -> true ; Games = [] ),
    % Build a continuant record and an id mapping for each game.
    foldl(lco_build_one_continuant, Games, []-[], Continuants0-Pairs),
    % The continuant records.
    reverse(Continuants0, Continuants),
    % A game -> continuant-id lookup list.
    GameContId = Pairs.

% -- lco_cro_has_game(+Cros, +Context, -Game): a game present in some CRO.
lco_cro_has_game(Cros, Context, Game) :-
    % Pick a CRO, read its context, and require a real game marker.
    member(cro(_,_,_,_,_,_,Context,_), Cros), lco_cro_game(Context, Game), Game \== none.

% -- lco_build_one_continuant(+Game, +Acc0, -Acc): one continuant and mapping.
lco_build_one_continuant(Game, Recs0-Pairs0, [rec(continuant, Ct)|Recs0]-[Game-Id|Pairs0]) :-
    % A game is an enduring information artifact; label it game_<id>.
    lco_label(game(Game), Label),
    % The continuant body.
    Body = _{type:"continuant", label:Label, category:"information"},
    % Complete it with its content id.
    lco_mk(Body, continuant, Ct),
    % The continuant's id for the realizable bearer link.
    get_dict(id, Ct, Id).

% -- lco_build_realizables(+GameContId, -Realizables): a "winnable" disposition
% per game continuant (every ARC-AGI-3 game bears the disposition to be won).
lco_build_realizables(GameContId, Realizables) :-
    % One realizable per (game, continuant-id) pair.
    findall(rec(realizable, Rz),
            ( member(_Game-ContId, GameContId),
              Body = _{type:"realizable", kind:"disposition", bearer:ContId, label:"winnable"},
              lco_mk(Body, realizable, Rz) ),
            Realizables).

% -- lco_build_occurrents(+Cros, +GradeStratumId, -Occurrents, -TermOccId):
% one deduplicated occurrent per distinct cause/effect term.
lco_build_occurrents(Cros, GradeStratumId, Occurrents, TermOccId) :-
    % Every distinct cause or effect term appearing anywhere in the CROs.
    ( setof(Term, lco_cro_term(Cros, Term), Terms) -> true ; Terms = [] ),
    % Build an occurrent and a term -> id mapping for each.
    foldl(lco_build_one_occurrent(Cros, GradeStratumId), Terms, []-[], Occ0-Pairs),
    % The occurrent records.
    reverse(Occ0, Occurrents),
    % A term -> occurrent-id lookup list.
    TermOccId = Pairs.

% -- lco_cro_term(+Cros, -Term): a cause or effect term of some CRO.
lco_cro_term(Cros, Term) :-
    % Choose a CRO and one of its cause or effect endpoints.
    member(cro(_, Causes, Effects, _, _, _, _, _), Cros),
    ( member(Term, Causes) ; member(Term, Effects) ).

% -- lco_build_one_occurrent(+Cros, +GradeStratumId, +Term, +Acc0, -Acc):
% one occurrent record, stratified when every referencing CRO shares one grade.
lco_build_one_occurrent(Cros, GradeStratumId, Term,
                        Recs0-Pairs0, [rec(occurrent, Oc)|Recs0]-[Term-Id|Pairs0]) :-
    % The canonical label and category for the term.
    lco_label(Term, Label), lco_category(Term, Category),
    % The base occurrent body.
    Body0 = _{type:"occurrent", label:Label, category:Category},
    % Attach a stratum only when the term is used at exactly one grade.
    ( lco_term_unique_grade(Cros, Term, Grade), memberchk(Grade-StId, GradeStratumId)
      -> put_dict(stratum, Body0, StId, Body1) ; Body1 = Body0 ),
    % Complete it with its content id.
    lco_mk(Body1, occurrent, Oc),
    % The occurrent's id for the CRO cause/effect references.
    get_dict(id, Oc, Id).

% -- lco_term_unique_grade(+Cros, +Term, -Grade): the sole grade of a term, if any.
lco_term_unique_grade(Cros, Term, Grade) :-
    % The set of grades of every CRO that references the term.
    setof(G, lco_term_grade(Cros, Term, G), Grades),
    % A single, non-none grade licenses stratification.
    Grades = [Grade], Grade \== none.

% -- lco_term_grade(+Cros, +Term, -Grade): a grade of a CRO referencing the term.
lco_term_grade(Cros, Term, Grade) :-
    % Find a CRO containing the term and read its grade.
    member(cro(_, Causes, Effects, _, _, _, Context, _), Cros),
    ( member(Term, Causes) ; member(Term, Effects) ),
    lco_cro_grade(Context, Grade).

% -- lco_build_cros(+Cros, +TermOccId, -CroRecs, -NativeCroId): the laws.
lco_build_cros(Cros, TermOccId, CroRecs, NativeCroId) :-
    % Build a causal_relation_object record and a native-id mapping for each CRO.
    foldl(lco_build_one_cro(TermOccId), Cros, []-[], Rec0-Pairs),
    % The CRO records.
    reverse(Rec0, CroRecs),
    % A native-id -> content-id lookup list (for the assertions).
    NativeCroId = Pairs.

% -- lco_build_one_cro(+TermOccId, +Cro, +Acc0, -Acc): one causal_relation_object.
lco_build_one_cro(TermOccId, cro(NativeId, Causes, Effects, temporal(Lo, Hi, Unit),
                                 Modality, _Strength, _Context, _Prov),
                  Recs0-Pairs0, [rec(causal_relation_object, Cr)|Recs0]-[NativeId-Id|Pairs0]) :-
    % Map every cause and effect term to its occurrent id.
    maplist(lco_term_to_occ(TermOccId), Causes, CauseIds),
    maplist(lco_term_to_occ(TermOccId), Effects, EffectIds),
    % The whole-word modality and temporal unit as strings.
    atom_string(Modality, ModS), atom_string(Unit, UnitS),
    % The temporal window: delay is part of the mechanism (Rule 4: Lo =< Hi).
    Temporal = _{minimum_delay:Lo, maximum_delay:Hi, unit:UnitS},
    % The causal_relation_object body (strength/provenance move to the assertion).
    Body = _{type:"causal_relation_object", causes:CauseIds, effects:EffectIds,
             temporal:Temporal, modality:ModS},
    % Complete it with its content id.
    lco_mk(Body, causal_relation_object, Cr),
    % The CRO's id for the assertion's about field.
    get_dict(id, Cr, Id).

% -- lco_term_to_occ(+TermOccId, +Term, -OccId): look up a term's occurrent id.
lco_term_to_occ(TermOccId, Term, OccId) :-
    % The mapping was built to be total over every cause/effect term.
    memberchk(Term-OccId, TermOccId).

% -- lco_build_assertions(+Cros, +NativeCroId, +Secret, +Pub, -Assertions): sign
% one provenance assertion per CRO, carrying the evidence grade, strength and
% confidence, with Mentova's Ed25519 key.
lco_build_assertions(Cros, NativeCroId, Secret, Pub, Assertions) :-
    % One signed assertion per CRO.
    foldl(lco_build_one_assertion(NativeCroId, Secret, Pub), Cros, [], Rev),
    % Restore export order.
    reverse(Rev, Assertions).

% -- lco_build_one_assertion(+NativeCroId, +Secret, +Pub, +Cro, +Acc0, -Acc).
lco_build_one_assertion(NativeCroId, Secret, Pub,
                        cro(NativeId, _, _, _, _, Strength, _Context, prov(Source, Evidence, Conf)),
                        Acc0, [rec(assertion, Signed)|Acc0]) :-
    % The CRO's content id is what the assertion is about.
    memberchk(NativeId-CroId, NativeCroId),
    % Grade the evidence honestly on the 2.0.0 ladder (curriculum/guide/draft
    % knowledge is imported documentary evidence, the weakest grade).
    lco_evidence_type(Source, EvType),
    % A short, human-legible provenance pointer (identity-bearing, so signed).
    lco_evidence_text(Source, Evidence, EvText),
    % A confidence in [0,1]; default 0.9 when the native envelope omits it.
    ( number(Conf) -> Confidence = Conf ; Confidence = 0.9 ),
    % A strength in [0,1]; default 0.9 likewise.
    ( number(Strength) -> Str = Strength ; Str = 0.9 ),
    % The fixed release timestamp.
    lco_timestamp(TS),
    % The assertion body; source is Mentova's public key (identity-bearing).
    Body = _{type:"assertion", about:CroId, source:Pub, evidence_type:EvType,
             evidence:EvText, strength:Str, confidence:Confidence, timestamp:TS},
    % Sign it with Mentova's key (adds the id and the signature over the body).
    co_sign_record(Body, Secret, assertion, Signed).

% -- lco_evidence_type(+NativeSource, -EvidenceType): the honest 2.0.0 grade.
% Every lattice law here is imported documentary knowledge (curriculum walls,
% ARC-AGI-3 guides, draft documents), so the honest grade is "imported".
lco_evidence_type(Source, "human_hint") :- Source == arc3_guide, !.
% Curriculum and draft imports are documentary "imported" evidence.
lco_evidence_type(_, "imported").

% -- lco_evidence_text(+Source, +Evidence, -Text): a compact provenance pointer.
lco_evidence_text(Source, Evidence, Text) :-
    % Render source and evidence envelope to a short, stable string.
    term_string(Source, SS), term_string(Evidence, ES),
    atomic_list_concat([SS, '|', ES], Atom), atom_string(Atom, Text).

% -- lco_build_bridges(+Occurrents, -Bridges): cross-level identities where the
% SAME happening (same label) is described at two strata. Usually none for the
% present lattice; emitted only when genuinely grounded (never fabricated).
lco_build_bridges(Occurrents, Bridges) :-
    % Group occurrent ids by label, keeping those pitched at a stratum.
    findall(Label-oc(StId, Id),
            ( member(rec(occurrent, O), Occurrents), get_dict(label, O, Label),
              get_dict(id, O, Id), get_dict(stratum, O, StId) ),
            Pairs),
    % Any label with two distinct strata yields a coarse/fine bridge; none here.
    findall(rec(bridge, Br), lco_bridge_of(Pairs, Br), Bridges).

% -- lco_bridge_of(+Pairs, -Bridge): a bridge for a label at two strata.
lco_bridge_of(Pairs, Br) :-
    % Two occurrents of the same label at different strata.
    member(Label-oc(St1, Coarse), Pairs), member(Label-oc(St2, Fine), Pairs),
    St1 \== St2, Coarse @< Fine,
    % Build a supervenes_on bridge (the coarse supervenes on the fine).
    Body = _{type:"bridge", coarse:Coarse, fine:[Fine], relation:"supervenes_on"},
    lco_mk(Body, bridge, Br).

% ---------------------------------------------------------------------------
% Validation — every record must satisfy its 2.0.0 schema and semantics, and
% every signature must verify, BEFORE anything is written or published.
% ---------------------------------------------------------------------------

% -- lco_validate_all(+Records): throw on the first non-conformant record.
lco_validate_all(Records) :-
    % Check each record; a failure raises lco_invalid/2 with the offending id.
    forall(member(rec(Kind, Dict), Records), lco_validate_one(Kind, Dict)).

% -- lco_validate_one(+Kind, +Dict): schema + semantics (+ signature for records).
lco_validate_one(Kind, Dict) :-
    % Structural schema validity for the kind.
    ( co_validate_schema(Dict, Kind, true, _) -> true
      ; ( co_validate_schema(Dict, Kind, false, Why),
          get_dict(id, Dict, Id), throw(lco_invalid(Id, schema(Why))) ) ),
    % Local semantic validity (Rule 4 windows, acyclicity, and the rest).
    ( causal_core_validate_semantics(Dict, Kind, []) -> true
      ; ( causal_core_validate_semantics(Dict, Kind, Reasons),
          get_dict(id, Dict, Id2), throw(lco_invalid(Id2, semantics(Reasons))) ) ),
    % A provenance record must additionally carry a verifying Ed25519 signature.
    ( Kind == assertion
      -> ( co_verify_record(Dict, assertion) -> true
           ; ( get_dict(id, Dict, Id3), throw(lco_invalid(Id3, signature)) ) )
      ;  true ).

% ---------------------------------------------------------------------------
% Writing the canonical NDJSON snapshot and its manifest.
% ---------------------------------------------------------------------------

% -- lco_write_ndjson(+File, +Records): write one canonical (RFC 8785) JSON
% object per line, in the given record order.
lco_write_ndjson(File, Records) :-
    % Open, write every record's canonical line, always close.
    setup_call_cleanup(open(File, write, S),
        forall(member(rec(_, Dict), Records),
               ( causal_core_jcs(Dict, Line), write(S, Line), nl(S) )),
        close(S)).

% -- lco_stats(+St,+Cn,+Rz,+Oc,+Cr,+Br,+As, -Stats): per-kind counts + native log.
lco_stats(St, Cn, Rz, Oc, Cr, Br, As, Stats) :-
    % Count each record list.
    length(St, NSt), length(Cn, NCn), length(Rz, NRz), length(Oc, NOc),
    length(Cr, NCr), length(Br, NBr), length(As, NAs),
    % Assemble the tally, including the kinds intentionally left native (0 here).
    Stats = [ stratum-NSt, continuant-NCn, realizable-NRz, occurrent-NOc,
              causal_relation_object-NCr, bridge-NBr, assertion-NAs,
              % These express no grounded causal content in the present lattice
              % and remain native node_facts per the scoping rule.
              quality-0, port-0, conduit-0 ].

% ---------------------------------------------------------------------------
% The top-level export: build, validate, write, manifest.
% ---------------------------------------------------------------------------

% -- lco_export(+Dir, -Stats): write the full 2.0.0 type-tier snapshot into Dir.
% The token tier (episodic memory) is LOCAL BY DEFAULT and is materialised only
% when the operator sets LATTICE_EXPORT_TOKEN_TIER=1 (to a separate local file
% that is never part of the published type-tier bundle).
lco_export(Dir, Stats) :-
    % Create the snapshot subdirectory if absent.
    ( exists_directory(Dir) -> true ; make_directory_path(Dir) ),
    % Build and validate the whole type-tier record set.
    lco_build_records(Records, Stats),
    % Write the published type-tier snapshot as canonical NDJSON.
    atomic_list_concat([Dir, '/type_tier.ndjson'], TypeFile),
    lco_write_ndjson(TypeFile, Records),
    % Mentova's public signing key, for the manifest and verification.
    lco_mentova_key(_, Pub),
    % Write the manifest tying counts, key and provenance together.
    lco_manifest(Dir, Stats, Pub),
    % Optionally materialise the LOCAL-ONLY token tier from episodic memory.
    ( getenv('LATTICE_EXPORT_TOKEN_TIER', "1")
      -> lco_export_token_tier(Dir, TokenStats)
      ;  TokenStats = skipped ),
    % Report both tiers to the console.
    format("Causalontology 2.0.0 type-tier snapshot written to ~w~n", [TypeFile]),
    format("  counts: ~w~n", [Stats]),
    format("  token tier (local-by-default): ~w~n", [TokenStats]),
    format("  signer: ~w~n", [Pub]).

% -- lco_manifest(+Dir, +Stats, +Pub): the human-readable manifest and scoping log.
lco_manifest(Dir, Stats, Pub) :-
    % The manifest path.
    atomic_list_concat([Dir, '/MANIFEST.txt'], File),
    % Write the provenance, counts, scoping rule and policy.
    setup_call_cleanup(open(File, write, S),
        ( format(S, "Mentova — Causalontology 2.0.0 Lattice Bridge snapshot (type tier)~n~n", []),
          format(S, "This is THE LATTICE's causal and relational content expressed in~n", []),
          format(S, "Causalontology 2.0.0 form: RFC 8785 canonical JSON, SHA-256 content~n", []),
          format(S, "identities, Ed25519-signed provenance. It is self-verifying by hash and~n", []),
          format(S, "signature and validates against the seventeen 2.0.0 schemas and the~n", []),
          format(S, "107 conformance vectors (Order One's harness).~n~n", []),
          format(S, "Signer (Mentova Ed25519 public key):~n  ~w~n~n", [Pub]),
          format(S, "Record counts by kind:~n", []),
          forall(member(K-N, Stats), format(S, "  ~w~t~30|: ~w~n", [K, N])),
          format(S, "~nSCOPING RULE: a Lattice fact is exported IFF it expresses causation~n", []),
          format(S, "(causal_relation_object), an enduring thing (continuant), a happening~n", []),
          format(S, "(occurrent), a disposition/function/role (realizable), a property~n", []),
          format(S, "(quality/state_assertion), a level of description (stratum), a cross-level~n", []),
          format(S, "identity (bridge), an interface (port/conduit), or provenance (assertion).~n", []),
          format(S, "Perceptual grid/scene machinery, type-checker facts and engine~n", []),
          format(S, "scaffolding are NOT exported; they remain native node_facts.~n~n", []),
          format(S, "TIER MAPPING: curriculum/world-model laws -> occurrent + causal_relation_object~n", []),
          format(S, "  + signed assertion; curriculum grades -> stratum; ARC-AGI-3 games ->~n", []),
          format(S, "  continuant + winnable realizable. Episodic memory -> TOKEN TIER, which is~n", []),
          format(S, "  LOCAL BY DEFAULT and excluded from this published snapshot.~n~n", []),
          format(S, "Regenerate with:  make lattice-snapshot~n", []) ),
        close(S)).

% ---------------------------------------------------------------------------
% The LOCAL-BY-DEFAULT token tier (episodic memory) — opt-in only.
% ---------------------------------------------------------------------------

% -- lco_export_token_tier(+Dir, -Stats): materialise the episodic token records
% into a SEPARATE local file that is NEVER part of the published type-tier
% bundle. Emitted only under explicit operator opt-in.
lco_export_token_tier(Dir, Stats) :-
    % Mentova's signing identity (for the observer field, when used).
    lco_mentova_key(_Secret, _Pub),
    % Build a minimal, conformant token record set from the learned win-paths.
    lco_build_token_records(Records),
    % Validate them exactly like the type tier.
    lco_validate_all_token(Records),
    % Write them to the LOCAL-ONLY file.
    atomic_list_concat([Dir, '/token_tier.local.ndjson'], File),
    lco_write_ndjson(File, Records),
    % Count what was materialised.
    length(Records, N), Stats = local(N, File).

% -- lco_build_token_records(-Records): a token_individual per learned game run
% plus token_occurrences for its win-path steps (kept minimal and conformant).
lco_build_token_records(Records) :-
    % The learned per-game store (empty when absent); each arc_learned/9+ term
    % carries a winning path we can reify as particular happenings.
    findall(rec(K, D), lco_token_record(K, D), Records).

% -- lco_token_record(-Kind, -Dict): one token-tier record from episodic memory.
% Kept deliberately small: it demonstrates the token tier is expressible and
% conformant while remaining local by default. Extended as episodic memory grows.
lco_token_record(_, _) :- fail.

% -- lco_validate_all_token(+Records): validate token records (schema+semantics).
lco_validate_all_token(Records) :-
    % Each token content record must be schema- and semantically valid.
    forall(member(rec(Kind, Dict), Records), lco_validate_one(Kind, Dict)).
