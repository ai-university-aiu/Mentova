%  Mentova — Acc_426: the Causalontology runnable core.
%  This file is Appendix A of Causalontology_v5, carried VERBATIM as the
%  executable acceptance artifact of the specification (Section 8.1).
%  Run:   swipl -g demo -t halt demos/causalontology_demo.pl
%  Test:  swipl -g run_tests -t halt demos/causalontology_demo.pl

:- module(causalontology_demo, [demo/0, run_tests/0]).
:- use_module(library(lists)).
:- use_module(library(gensym)).

% ---------------- STORE (stand-in for the PrologAI lattice) ----------------
:- dynamic continuant/2.        % NOUN:  continuant(Id, Category)
:- dynamic realizable/3.        % HINGE: realizable(Id, Kind, Bearer)
:- dynamic realized_in/2.       % HINGE->VERB: realized_in(RealizableId, OccurrentType)
:- dynamic cro/8.               % VERB:  reified Causal Relation Object
:- dynamic avoid/1.             % safety set (never re-run for exploration)
:- dynamic clue/1.              % an environment clue the agent can read

% cro(Id, Causes, Effects, temporal(Dmin,Dmax,Unit), Modality, Strength,
%     Context, prov(Source,Evidence,Conf))

% ---------------- GROUND-TRUTH ENVIRONMENT (hidden from the agent) ----------
truth_effect(press(b_red),   light(red,on),   0).
truth_effect(press(b_green), light(green,on), 0).
truth_effect(press(b_blue),  light(blue,on),  0).
truth_effect(touch(spike),   penalty,         0).
truth_unlock_sequence([press(b_red), press(b_green), press(b_blue)]).

act(Action, Effect) :- truth_effect(Action, Effect, _), !.
act(_, none).

% ---------------- INITIALISATION (perception -> NOUN layer) -----------------
init_world :-
    retractall(continuant(_,_)), retractall(realizable(_,_,_)),
    retractall(realized_in(_,_)), retractall(cro(_,_,_,_,_,_,_,_)),
    retractall(avoid(_)), retractall(clue(_)),
    forall(member(B, [b_red, b_green, b_blue, door, spike]),
           assertz(continuant(B, object))),
    assertz(clue(sequence([press(b_red),press(b_green),press(b_blue)]) -> door(open))).

% ---------------- INTERVENTIONAL LEARNING LOOP ------------------------------
intervene(Action) :-
    act(Action, Effect),
    ( Effect == none    -> format("  do(~w) -> no observable effect in this context~n", [Action])
    ; Effect == penalty -> learn_preventive(Action, Effect)
    ;                      learn_causal(Action, Effect) ).

learn_causal(Action, Effect) :-
    ( cro(Id, [Action], [Effect], T, M, S0, C, _) ->
        S1 is min(0.99, S0 + 0.2),
        retract(cro(Id, [Action], [Effect], T, M, S0, C, _)),
        assertz(cro(Id, [Action], [Effect], T, M, S1, C,
                    prov(agent, learned_by_intervention, S1))),
        format("  confirm  ~w : do(~w) => ~w   (strength ~2f)~n", [Id, Action, Effect, S1])
    ;   gensym(cro_, Id),
        assertz(cro(Id, [Action], [Effect],
                    temporal(0,0,instant), sufficient, 0.70, [],
                    prov(agent, learned_by_intervention, 0.70))),
        format("  induce   ~w : do(~w) => ~w   (strength 0.70)~n", [Id, Action, Effect]),
        posit_disposition(Action) ).

% Bottom-up: verb-side causation reveals a noun-side realizable (the HINGE).
posit_disposition(press(Button)) :-
    ( realizable(_, pressable, Button) -> true
    ; gensym(disp_, D),
      assertz(realizable(D, pressable, Button)),
      assertz(realized_in(D, press(Button))),
      format("    ^ noun-side: posit ~w bears a 'pressable' disposition (~w), realized_in press(~w)~n",
             [Button, D, Button]) ).
posit_disposition(_).

learn_preventive(Action, Effect) :-
    ( avoid(Action) -> true
    ; assertz(avoid(Action)),
      gensym(cro_, Id),
      assertz(cro(Id, [Action], [Effect],
                  temporal(0,0,instant), preventive, 0.90, [],
                  prov(agent, learned_by_intervention, 0.90))),
      format("  HAZARD   do(~w) => ~w : tag PREVENTIVE, add to avoid-set~n", [Action, Effect]) ).

% ---------------- FORWARD PREDICTION and ABDUCTION --------------------------
predict(Action, Effect) :-
    cro(_, [Action], [Effect], _, Modality, _, _, _),
    Modality \== preventive.

seed_temporal_kb :-
    ( cro(cro_shellfish,_,_,_,_,_,_,_) -> true
    ; assertz(cro(cro_shellfish, [ate(spoiled_shellfish)], [state(gastroenteritis)],
                  temporal(1,6,hours), contributory, 0.70, [], prov(kb, asserted, 0.70))),
      assertz(cro(cro_poultry,   [ate(undercooked_poultry)], [state(gastroenteritis)],
                  temporal(6,72,hours), contributory, 0.60, [], prov(kb, asserted, 0.60))) ).

temporal_abduction(Meals, Ranked) :-
    findall(Conf-Cause,
            ( member(Cause-HoursAgo, Meals),
              cro(_, [Cause], [state(gastroenteritis)], temporal(Dmin,Dmax,hours), _, S, _, _),
              HoursAgo >= Dmin, HoursAgo =< Dmax,     % temporal admissibility gate
              Conf = S ),
            Fits),
    sort(0, @>=, Fits, Ranked).

report_temporal(Meals) :-
    forall(member(Cause-HoursAgo, Meals),
           ( cro(_, [Cause], [state(gastroenteritis)], temporal(Dmin,Dmax,hours), _, _, _, _),
             ( (HoursAgo >= Dmin, HoursAgo =< Dmax) -> Tag = admissible ; Tag = 'EXCLUDED-by-timing' ),
             format("    ~w eaten ~wh ago vs window ~w-~wh  ->  ~w~n",
                    [Cause, HoursAgo, Dmin, Dmax, Tag]) )).

% ---------------- HIERARCHY + PLANNING --------------------------------------
compose_procedure :-
    clue(sequence(Seq) -> Goal),
    ( cro(_, [sequence(Seq)], [Goal], _, _, _, _, _) -> true
    ; gensym(cro_, Id),
      assertz(cro(Id, [sequence(Seq)], [Goal],
                  temporal(0,1,short), sufficient, 0.60, [], prov(clue, asserted, 0.60))),
      format("  compose  ~w : sequence ~w => ~w~n", [Id, Seq, Goal]) ).

plan(Goal, Plan) :-
    cro(_, [sequence(Seq)], [Goal], _, _, _, _, _),
    forall(member(Step, Seq), (achievable(Step), \+ avoid(Step))),
    Plan = Seq.

achievable(Action) :-
    cro(_, [Action], [_], _, Mod, _, _, _),
    Mod \== preventive.

execute(Plan, Result) :-
    ( truth_unlock_sequence(Plan) -> Result = door(open) ; Result = door(closed) ).

% ---------------- GLASS-BOX JUSTIFICATION -----------------------------------
why(Goal) :-
    cro(Id, [sequence(Seq)], [Goal], _, _, _, _, prov(Src,_,_)),
    format("  ~w  holds because ~w asserts:  sequence ~w => ~w   [source: ~w]~n",
           [Goal, Id, Seq, Goal, Src]),
    forall(member(Step, Seq),
           ( cro(Cid, [Step], [Eff], _, _, S, _, prov(S2,_,_)),
             format("     - ~w realizes ~w => ~w   [~w, ~w, strength ~2f]~n",
                    [Step, Step, Eff, Cid, S2, S]) )).

% ---------------- DEMO ORCHESTRATION ----------------------------------------
banner(T) :- format("~n=== ~w ===~n", [T]).

demo :-
    init_world,
    format("CAUSALONTOLOGY (CO) -- runnable core demonstration~n"),
    format("SWI-Prolog; no LLM, no neural weights; every step is an inspectable rule.~n"),
    banner('1. NOUN LAYER: objects registered by perception'),
    forall(continuant(Id,Cat), format("  continuant(~w, ~w)~n",[Id,Cat])),
    banner('2. INTERVENTIONAL LEARNING: do -> observe -> induce CROs (+ dispositions)'),
    intervene(press(b_red)), intervene(press(b_green)), intervene(press(b_blue)),
    intervene(press(b_red)),
    format("~n  HINGE now populated bottom-up:~n"),
    forall(realized_in(D,Occ),
           ( realizable(D,Kind,Bearer),
             format("    realizable(~w,~w) on ~w  --realized_in-->  ~w~n",[D,Kind,Bearer,Occ]) )),
    banner('3. FORWARD PREDICTION from the learned CROs'),
    forall(predict(press(B), E), format("  predict: do(~w) => ~w~n",[press(B),E])),
    banner('4. TIMING-AS-MECHANISM: temporal abduction (excludes a cause on timing)'),
    seed_temporal_kb,
    Meals = [ ate(spoiled_shellfish)-3, ate(undercooked_poultry)-2 ],
    format("  observed: gastroenteritis, onset now.  Two recent meals:~n"),
    report_temporal(Meals),
    temporal_abduction(Meals, Ranked),
    format("  => temporally-admissible causes, ranked by strength: ~w~n",[Ranked]),
    banner('5. HIERARCHY + PLANNING: compose a procedure, plan to open the door'),
    compose_procedure,
    ( plan(door(open), Plan)
      -> format("  plan(door(open)) = ~w~n",[Plan]),
         execute(Plan, R), format("  execute -> ~w~n",[R])
      ;  format("  no safe plan found~n") ),
    banner('6. SAFETY: discover a hazard, tag it preventive, refuse to re-run it'),
    intervene(touch(spike)), intervene(touch(spike)),
    ( \+ achievable(touch(spike))
      -> format("  planner will not use touch(spike): it is preventive / avoided~n")
      ;  format("  (unexpected) touch(spike) considered achievable~n") ),
    banner('7. GLASS-BOX: why did the door open?'),
    why(door(open)),
    banner('SELF-CHECK'),
    run_tests.

% ---------------- SELF-VERIFYING TESTS --------------------------------------
run_tests :- ( var_ok -> format("  all checks passed.~n") ; true ).

var_ok :-
    init_world,
    intervene(press(b_red)), intervene(press(b_green)), intervene(press(b_blue)),
    seed_temporal_kb, compose_procedure, intervene(touch(spike)),
    aggregate_all(count, cro(_,[press(_)],[light(_,_)],_,_,_,_,_), NLights),
    assertion(NLights =:= 3),
    aggregate_all(count, realizable(_,pressable,_), NDisp),
    assertion(NDisp =:= 3),
    assertion(predict(press(b_red), light(red,on))),
    temporal_abduction([ate(spoiled_shellfish)-3, ate(undercooked_poultry)-2], R),
    assertion(memberchk(_-ate(spoiled_shellfish), R)),
    assertion(\+ memberchk(_-ate(undercooked_poultry), R)),
    assertion(plan(door(open), [press(b_red),press(b_green),press(b_blue)])),
    assertion((plan(door(open),P), execute(P, door(open)))),
    assertion(avoid(touch(spike))),
    assertion(\+ achievable(touch(spike))).

% ---- end of Appendix A ----
