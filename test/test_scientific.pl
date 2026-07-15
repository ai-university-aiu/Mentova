/*  Mentova — Scientific Reasoning Module Test Suite

    Genuine PLUnit coverage for src/mentova/scientific.pl, which exports
    mentova_scientific/3 — the discovery loop that proposes a hypothesis
    by pattern recognition over the small-world observation table, tests
    it against the counts, scores it by coverage (Count / Total), grades
    the score (confirmed >= 0.8, supported >= 0.6, weakly_supported >= 0.4,
    not_supported < 0.4), and returns a glass-box justification term.

    Two query forms are exercised across several subjects:
      - discover(Subject, Property)     — propose-and-test the first hypothesis
      - test_hypothesis(Pattern)        — score one named pattern directly
    Expected values are hand-computed from the observation table in
    knowledge/small_world.pl:
      canary  yellow 47, green  3   (total 50)
      rose    red    82, white 18   (total 100)
      penguin swims  95, flies  0   (total 95)
      eagle   hunts  71, rests 29   (total 100)

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_scientific.pl
*/

% Declare this file as a test module with no exports.
:- module(test_scientific, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path (it pulls observation/3 in by its own relative import).
:- use_module(library(scientific)).

% Open the test block for the scientific module.
:- begin_tests(scientific).

% AC-SCI-001: discover for the canary proposes the yellow-dominance hypothesis and confirms it.
test(discover_canary_proposes_confirmed_yellow) :-
    % Ask the module to propose and test a hypothesis about the canary's colour, taking the first solution.
    once(mentova_scientific(discover(canary, colour), Result, _Justification)),
    % The result is the four-slot hypothesis term the module documents.
    Result = hypothesis(Description, subject(Subject), score(Score), grade(Grade)),
    % The first hypothesis proposed is dominant-colour, carried as its English description.
    assertion(Description == 'Most observations of Subject show yellow colour'),
    % The subject reported back is the canary that was asked about.
    assertion(Subject == canary),
    % Coverage is 47 yellow of 50 total observations, i.e. 0.94.
    assertion(abs(Score - 0.94) < 1.0e-9),
    % A score of 0.94 sits in the confirmed band (>= 0.8).
    assertion(Grade == confirmed).

% AC-SCI-002: the justification restates the same score and grade and names the evidence counts.
test(discover_justification_agrees_with_result) :-
    % Run the same canary discovery, this time keeping the justification, taking the first solution.
    once(mentova_scientific(discover(canary, colour), Result, Justification)),
    % Read the score and grade out of the returned result.
    Result = hypothesis(Description, subject(canary), score(Score), grade(Grade)),
    % The justification is the documented scientific/4 glass-box term.
    Justification = just(scientific(propose(JDescription), test(Evidence), score(JScore), grade(JGrade))),
    % The proposed description in the justification matches the result's description.
    assertion(JDescription == Description),
    % The justification's score is the very same value returned in the result.
    assertion(JScore =:= Score),
    % The justification's grade is the very same grade returned in the result.
    assertion(JGrade == Grade),
    % The evidence names 47 yellow observations of 50 total for the canary.
    assertion(Evidence == evidence(canary, yellow, 47, of(50))).

% AC-SCI-003: testing mostly-red against the rose confirms it at 82 of 100.
test(test_hypothesis_mostly_red_rose_confirmed) :-
    % Score the mostly-red pattern directly for the rose, taking the first solution.
    once(mentova_scientific(test_hypothesis(mostly_red(rose)), Result, _Justification)),
    % The direct form returns a three-slot result of score, grade, and evidence.
    Result = result(Score, Grade, Evidence),
    % Coverage is 82 red of 100 total, i.e. 0.82.
    assertion(abs(Score - 0.82) < 1.0e-9),
    % A score of 0.82 sits in the confirmed band (>= 0.8).
    assertion(Grade == confirmed),
    % The evidence names 82 red observations of 100 total for the rose.
    assertion(Evidence == evidence(rose, red, 82, of(100))).

% AC-SCI-004: rarely-flies scores high for the penguin because it is never observed flying.
test(test_hypothesis_rarely_flies_penguin_confirmed) :-
    % Score the rarely-flies pattern for the penguin, taking the first solution.
    once(mentova_scientific(test_hypothesis(rarely_flies(penguin)), Result, _Justification)),
    % Unpack the score, grade, and evidence.
    Result = result(Score, Grade, Evidence),
    % The score is one minus the flying fraction: 1 - 0/95 = 1.0.
    assertion(abs(Score - 1.0) < 1.0e-9),
    % A perfect score sits in the confirmed band.
    assertion(Grade == confirmed),
    % The evidence names 0 flying observations of 95 total for the penguin.
    assertion(Evidence == evidence(penguin, flies, 0, of(95))).

% AC-SCI-005: a 71-of-100 coverage lands in the middle 'supported' band, not 'confirmed'.
test(test_hypothesis_eagle_hunts_supported) :-
    % Score the dominant-activity pattern hunts for the eagle, taking the first solution.
    once(mentova_scientific(test_hypothesis(dominant_colour(eagle, hunts)), Result, _Justification)),
    % Unpack the score, grade, and evidence.
    Result = result(Score, Grade, Evidence),
    % Coverage is 71 hunts of 100 total, i.e. 0.71.
    assertion(abs(Score - 0.71) < 1.0e-9),
    % A score of 0.71 sits in the supported band (0.6 =< score < 0.8), below confirmed.
    assertion(Grade == supported),
    % The evidence names 71 hunts of 100 total for the eagle.
    assertion(Evidence == evidence(eagle, hunts, 71, of(100))).

% AC-SCI-006: a pattern whose colour is never observed scores zero and is not supported.
test(test_hypothesis_absent_colour_not_supported) :-
    % Score mostly-red for the canary, which is only ever yellow or green, taking the first solution.
    once(mentova_scientific(test_hypothesis(mostly_red(canary)), Result, _Justification)),
    % Unpack the score, grade, and evidence.
    Result = result(Score, Grade, Evidence),
    % With no red observations the coverage is 0 of 50, i.e. zero.
    assertion(Score =:= 0),
    % A zero score sits in the not-supported band (< 0.4).
    assertion(Grade == not_supported),
    % The evidence names 0 red observations of 50 total for the canary.
    assertion(Evidence == evidence(canary, red, 0, of(50))).

% AC-SCI-007: higher coverage yields a strictly higher score and a stronger grade band.
test(grade_bands_track_coverage_monotonically) :-
    % Score the absent-colour case (0.0, not supported), taking the first solution.
    once(mentova_scientific(test_hypothesis(mostly_red(canary)), result(LowScore, LowGrade, _), _)),
    % Score the mid-coverage case (0.71, supported), taking the first solution.
    once(mentova_scientific(test_hypothesis(dominant_colour(eagle, hunts)), result(MidScore, MidGrade, _), _)),
    % Score the high-coverage case (0.82, confirmed), taking the first solution.
    once(mentova_scientific(test_hypothesis(mostly_red(rose)), result(HighScore, HighGrade, _), _)),
    % The scores rise strictly with coverage across the three cases.
    assertion(LowScore < MidScore),
    % And keep rising into the highest case.
    assertion(MidScore < HighScore),
    % The lowest coverage is graded not-supported.
    assertion(LowGrade == not_supported),
    % The middle coverage is graded supported.
    assertion(MidGrade == supported),
    % The highest coverage is graded confirmed.
    assertion(HighGrade == confirmed).

% Close the test block for the scientific module.
:- end_tests(scientific).
