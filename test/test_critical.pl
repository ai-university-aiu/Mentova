/*  Mentova — Critical Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/critical.pl, which exports
    mentova_critical/3 — a glass-box claim assessor over a built-in
    evidence base. Its four query forms are:
      evaluate(ClaimId)       -> evaluation(ClaimId, Grade, Alert)
      all_evidence(ClaimId)   -> evidence_list(Tuples)
      source_quality(ClaimId) -> source(Type, Reliability)
      compare(ClaimA, ClaimB) -> better(Winner)
    Net support is AvgSupporting - AvgOpposing*0.5, graded well_supported
    (>=0.75), moderately (>=0.50), weakly_supported (>=0.25), else
    not_supported; a weak or unsupported grade raises a weak_claim flag.

    Hand-computed net support over the built-in evidence base:
      canary_yellow    : avg supporting 0.87, no opposition -> 0.87 (well)
      all_eagles_large : 0.60 - 0.30*0.5 = 0.45              (weakly)
      canary_swims     : 0.05 - 0.90*0.5 = -0.40             (not)

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_critical.pl
*/

% Declare this file as a test module with no exports.
:- module(test_critical, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path.
:- use_module(library(critical)).

% Open the test block for the critical module.
:- begin_tests(critical).

% AC-CRIT-001: a well-evidenced claim grades well_supported with no alert.
test(canary_yellow_is_well_supported_no_alert) :-
    % Evaluate the canary-is-yellow claim against its evidence base.
    once(mentova_critical(evaluate(canary_yellow), Result, Justification)),
    % Two supporting weights 0.94 and 0.80 average to 0.87 with no opposition.
    assertion(Result == evaluation(canary_yellow, well_supported, none)),
    % The justification is the documented six-slot critical term.
    Justification = just(critical(claim(canary_yellow),
                                  net_support(Net),
                                  supporting(SC), opposing(OC),
                                  grade(Grade), alert(Alert))),
    % The net support equals the hand-computed 0.87.
    assertion(abs(Net - 0.87) < 1.0e-9),
    % Two pieces of supporting evidence were counted.
    assertion(SC =:= 2),
    % No opposing evidence was counted.
    assertion(OC =:= 0),
    % The justification's grade agrees with the returned grade.
    assertion(Grade == well_supported),
    % The justification's alert agrees with the returned no-alert.
    assertion(Alert == none).

% AC-CRIT-002: a mixed-evidence claim grades weakly_supported and is flagged.
test(all_eagles_large_is_weakly_supported_and_flagged) :-
    % Evaluate the all-eagles-are-large claim against its evidence base.
    once(mentova_critical(evaluate(all_eagles_large), Result, Justification)),
    % Read the grade and alert out of the evaluation result.
    Result = evaluation(all_eagles_large, Grade, Alert),
    % Net = 0.60 - 0.30*0.5 = 0.45 lands in the weakly_supported band.
    assertion(Grade == weakly_supported),
    % A weak grade raises a weak_claim flag naming its one opposing item.
    assertion(Alert = flag(weak_claim, reasons([low_support(_), opposition(1)]))),
    % Pull the net support back out of the justification.
    Justification = just(critical(claim(all_eagles_large),
                                  net_support(Net), _, _, _, _)),
    % The net support equals the hand-computed 0.45.
    assertion(abs(Net - 0.45) < 1.0e-9),
    % The low-support reason inside the flag carries that same net support.
    Alert = flag(weak_claim, reasons([low_support(FlagNet), _])),
    % And the flag's reported net support matches too.
    assertion(abs(FlagNet - 0.45) < 1.0e-9).

% AC-CRIT-003: an opposed claim grades not_supported and is flagged.
test(canary_swims_is_not_supported_and_flagged) :-
    % Evaluate the canary-can-swim claim against its evidence base.
    once(mentova_critical(evaluate(canary_swims), Result, _Justification)),
    % Read the grade and alert out of the evaluation result.
    Result = evaluation(canary_swims, Grade, Alert),
    % Net = 0.05 - 0.90*0.5 = -0.40 falls below zero into not_supported.
    assertion(Grade == not_supported),
    % A not_supported grade also raises the weak_claim flag naming its one opposing item.
    assertion(Alert = flag(weak_claim, reasons([low_support(_), opposition(1)]))),
    % Extract the flagged net support with a bare unification so the binding escapes.
    Alert = flag(weak_claim, reasons([low_support(FlagNet), _])),
    % The flagged net support is the hand-computed negative -0.40.
    assertion(abs(FlagNet - (-0.40)) < 1.0e-9).

% AC-CRIT-004: all_evidence dumps every stored evidence tuple in order.
test(all_evidence_dumps_every_tuple) :-
    % Ask for the full evidence dump of the well-supported claim.
    mentova_critical(all_evidence(canary_yellow), Result1, _),
    % Both stored tuples are returned as e(Type, Weight), in file order.
    assertion(Result1 == evidence_list([e(supporting, 0.94), e(supporting, 0.80)])),
    % Ask for the full evidence dump of the mixed-evidence claim.
    mentova_critical(all_evidence(all_eagles_large), Result2, Justification2),
    % Its supporting and opposing tuples are both present.
    assertion(Result2 == evidence_list([e(supporting, 0.60), e(opposing, 0.30)])),
    % The justification echoes the same evidence list under its claim id.
    assertion(Justification2 == just(evidence_dump(all_eagles_large,
                                     [e(supporting, 0.60), e(opposing, 0.30)]))).

% AC-CRIT-005: source_quality returns the stored source type and reliability.
test(source_quality_reports_stored_source) :-
    % Look up the source backing the well-supported claim.
    mentova_critical(source_quality(canary_yellow), Result1, _),
    % It is an observation table with reliability 0.95.
    assertion(Result1 == source(observation_table, 0.95)),
    % Look up the source backing the unsupported claim.
    mentova_critical(source_quality(canary_swims), Result2, Justification2),
    % It is a rumour with reliability 0.10.
    assertion(Result2 == source(rumour, 0.10)),
    % The justification names the claim, its source type, and reliability.
    assertion(Justification2 == just(source_eval(canary_swims, rumour,
                                                 reliability(0.10)))).

% AC-CRIT-006: compare picks the claim with the greater net support.
test(compare_picks_better_supported_claim) :-
    % Compare the well-supported claim against the unsupported one.
    mentova_critical(compare(canary_yellow, canary_swims), Result1, _),
    % 0.87 beats -0.40, so the yellow claim wins.
    assertion(Result1 == better(canary_yellow)),
    % Compare the weak claim against the well-supported one.
    mentova_critical(compare(all_eagles_large, canary_yellow), Result2, _),
    % 0.87 beats 0.45, so the second argument wins the tie-break to the right.
    assertion(Result2 == better(canary_yellow)),
    % Reversing the arguments still selects the stronger claim.
    mentova_critical(compare(canary_swims, canary_yellow), Result3, _),
    % The yellow claim wins from the right-hand side as well.
    assertion(Result3 == better(canary_yellow)).

% Close the test block for the critical module.
:- end_tests(critical).
