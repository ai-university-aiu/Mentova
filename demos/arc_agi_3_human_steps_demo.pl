/*  Mentova — ARC-AGI-3 Human-Step Solo Demonstration (in J-Space)

    Mentova attempts an ARC-AGI-3 navigation environment solo by walking the
    six-phase, thirty-micro-step human ladder and keeping the step it is on
    live in the Jacobian Space (J-Space) workspace. It orients, probes each
    action to assemble the Jacobian and read off which object it controls,
    locates the goal, descends the goal gradient into a route, and executes to
    a win — all with no human help.

    Acceptance criteria (each prints PASS or FAIL at run time):
      AC-HS-001: the solo controller wins the navigation level.
      AC-HS-002: the Jacobian identifies the controllable object as the avatar
                 (colour three).
      AC-HS-003: it plans and executes the optimal route at full efficiency
                 (score 1.0 against the human baseline).
      AC-HS-004: the plan length equals the Manhattan distance to the goal.
      AC-HS-005: the J-Lens holds the human-step process, with the final
                 transfer step current.

    Run:
        swipl -l demos/arc_agi_3_human_steps_demo.pl -g run_hs_demo -t halt
*/

% Load the human-step solo controller under demonstration.
:- use_module('../src/mentova/games/arc_agi_3_human_steps').
% Load list helpers.
:- use_module(library(lists), [member/2]).

% report(+Id, +Cond): print PASS or FAIL for one acceptance criterion.
report(Id, Cond) :-
    % Evaluate the condition once.
    ( call(Cond) -> V = 'PASS' ; V = 'FAIL' ),
    % Print the verdict.
    format("~w: ~w~n", [Id, V]).

% Define run_hs_demo: run the full human-step solo demonstration.
run_hs_demo :-
    % Announce the demonstration.
    format("~n=== ARC-AGI-3 Human-Step Solo (in J-Space) ===~n~n", []),
    % Play the navigation game solo, walking the ladder in the J-Space named jdemo.
    hs3_play(jdemo, Result),
    % Show the result.
    format("result: ~q~n", [Result]),
    % Unpack the fields for the checks.
    Result = result(Outcome, actions(Actions), score(Score),
                    controllable(Ctrl), goal(_), plan(Plan)),
    % AC-001: the level was won.
    report('AC-HS-001', ( Outcome == won )),
    % AC-002: the controllable object is the avatar colour three.
    report('AC-HS-002', ( Ctrl =:= 3 )),
    % AC-003: full-efficiency score of one.
    report('AC-HS-003', ( Score =:= 1.0 )),
    % AC-004: the plan is the eight-move Manhattan route.
    report('AC-HS-004', ( length(Plan, 8), Actions =:= 8 )),
    % AC-005: the J-Lens holds the process with the final step current.
    report('AC-HS-005', hs_final_step_current),
    % Show the plan.
    format("plan: ~q~n", [Plan]),
    % Show the J-Lens readout of the process.
    hs3_jlens(jdemo, Reading),
    % How many steps are held.
    length(Reading, NHeld),
    % Print the current step and the count held.
    Reading = [Current | _],
    % Report the lens state.
    format("j-lens: current=~q, ~w steps held~n~n", [Current, NHeld]).

% hs_final_step_current: the strongest held concept is the final transfer step.
hs_final_step_current :-
    % Read the J-Lens.
    hs3_jlens(jdemo, Reading),
    % Its strongest entry is the last human step.
    Reading = [hstep('VI.4') - _ | _].
