/*  Mentova — Claude-Facing Agent Interface Demonstration

    Proves the machine-facing agentview gives a Claude session everything it needs
    to see the game and reason about it: the grid as digit lines, co_see's object
    inventory with roles and positions, the meters, the labelled controls, and the
    current hierarchical plan tree. Acting and teaching reuse the existing mentor
    endpoints, so this demo checks the read-side data the agentview assembles.

    Acceptance criteria (each prints PASS or FAIL):
      AC-AV-001: the grid renders as compact digit lines.
      AC-AV-002: the object inventory carries roles and positions.
      AC-AV-003: a life-bar is reported in the meters.
      AC-AV-004: the labelled control panel is non-empty with commands.
      AC-AV-005: the plan tree is present with the OODA phases.
      AC-AV-006: the how-to-mentor note names the act and teach endpoints.

    Run:
        swipl -l demos/arc3_agentview_demo.pl -g run_agentview_demo -t halt
*/

% Load the backend under test.
:- use_module('../src/mentova/mentova_arc_chat').
% List helpers.
:- use_module(library(lists), [member/2, memberchk/2]).

% report(+Id, +Goal): print PASS or FAIL for one criterion.
report(Id, Goal) :-
    ( catch(Goal, E, (format("  error: ~q~n", [E]), fail))
    -> V = 'PASS' ; V = 'FAIL' ),
    format("~w: ~w~n", [Id, V]).

% A synthetic frame: an avatar (5), a collectible dot (4), and a life-bar (2).
frame([
    [0,0,0,0,0,0,0,0],
    [0,5,0,0,0,0,4,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [2,2,2,2,2,2,0,0]
]).

% run_agentview_demo: assemble the agentview data and check every part is there.
run_agentview_demo :-
    % Announce.
    format("~n=== Claude-Facing Agent Interface ===~n~n", []),
    % A frame and a game to view.
    frame(F), G = ls20,
    % Build the plan so the view has one.
    ( catch(mentova_arc_chat:ma_build_plan(G), _, true) -> true ; true ),

    % AC-001: the grid renders as compact digit lines.
    report('AC-AV-001',
        ( mentova_arc_chat:ma_grid_ascii(F, Ascii),
          length(Ascii, 8),
          member(Line, Ascii), sub_atom(Line, _, _, _, '5') )),

    % AC-002: the object inventory carries roles and positions.
    report('AC-AV-002',
        ( mentova_arc_chat:ma_agent_inventory(F, Inv),
          member(D, Inv), get_dict(role, D, meter),
          get_dict(row, D, _), get_dict(col, D, _) )),

    % AC-003: a life-bar is reported in the meters.
    report('AC-AV-003',
        ( mentova_arc_chat:ma_agent_meters(G, F, Meters),
          member(M, Meters), get_dict(orientation, M, horizontal),
          get_dict(length, M, L), L >= 5 )),

    % AC-004: the labelled control panel is non-empty with commands.
    report('AC-AV-004',
        ( mentova_arc_chat:ma_action_descriptors(G, Actions),
          Actions \== [],
          member(A, Actions), get_dict(command, A, _), get_dict(label, A, _) )),

    % AC-005: the plan tree is present with the OODA phases.
    report('AC-AV-005',
        ( mentova_arc_chat:ma_plan_view(G, Plan),
          get_dict(tree, Plan, TreeJson),
          get_dict(children, TreeJson, [Ooda]),
          get_dict(children, Ooda, Phases), length(Phases, 6) )),

    % AC-006: the how-to note names the act and teach endpoints.
    report('AC-AV-006',
        ( mentova_arc_chat:ma_agent_howto(HowTo),
          get_dict(act, HowTo, ActNote), sub_atom(ActNote, _, _, _, '/api/arc/control'),
          get_dict(teach, HowTo, TeachNote), sub_atom(TeachNote, _, _, _, '/api/arc/hint') )),

    % Show the digit grid the agent would read.
    format("~nThe grid a Claude mentor sees:~n", []),
    forall(member(Ln, Ascii), format("  ~w~n", [Ln])),
    format("~n", []).
