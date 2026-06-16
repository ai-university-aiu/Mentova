/*  Mentova — Rung 32: Metacognitive Reasoning Module

    Reasons about Mentova's own reasoning capabilities and confidence.
    Pass criterion: Mentova reports which reasoning type applies to a
    query and what its confidence in the answer is.
*/

:- module(metacognitive, [
    mentova_metacognitive/3
]).

:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Capability registry: capability(Tag, Description, Confidence)
% ---------------------------------------------------------------------------

capability(probabilistic,  'probability algebra and weighted facts',     high).
capability(bayes,          'Bayesian prior-to-posterior update',         high).
capability(causal,         'do-calculus causal inference',               high).
capability(stats,          'aggregate observation statistics',           high).
capability(analogy,        'structure-mapping analogical reasoning',     high).
capability(relational,     'multi-hop graph traversal',                  high).
capability(transductive,   'kNN instance-based classification',          high).
capability(commonsense,    'small-world commonsense lookup',             high).
capability(logical,        'forward-chaining rule saturation',           high).
capability(formal,         'MPK proof-rule checking',                    high).
capability(mathematical,   'arithmetic and number theory',               high).
capability(fuzzy,          'triangular membership function grading',     high).
capability(qualitative,    'sign-algebra influence propagation',         high).
capability(nonmonotonic,   'defeasible default retraction',              high).
capability(paraconsistent, 'contradiction isolation without explosion',   high).
capability(counterfactual, 'closest-world counterfactual evaluation',    high).
capability(hypothetical,   'context-list supposition derivation',        high).
capability(spatial,        'containment and adjacency chains',           high).
capability(diagrammatic,   'named-grid symbol counting',                 high).
capability(temporal,       'event ordering and duration reasoning',      high).
capability(case_based,     'similarity-based case retrieval',            high).
capability(constraint,     'constraint satisfaction with deduction log', high).
capability(scientific,     'hypothesis formation and scoring',           high).
capability(system,         'parts-roles-behavior system modeling',       high).
capability(model_based,    'linear/threshold/FSM model prediction',      high).
capability(heuristic,      'greedy best-first and Dijkstra search',      high).
capability(critical,       'evidence-support grading and flagging',      high).
capability(dialectical,    'pro/con argument weighing and synthesis',    high).

% Gaps (not yet implemented or limited)
capability(inductive_general, 'general inductive concept learning',    limited).
capability(abductive_deep,    'abduction over large hypothesis spaces', limited).
capability(continuous_time,   'continuous differential equations',      none).
capability(vision,            'image perception and parsing',           none).

% ---------------------------------------------------------------------------
% Introspect: which capabilities are active?
% ---------------------------------------------------------------------------

introspect_all(Caps) :-
    findall(T-D-C, capability(T, D, C), All),
    include([_-_-high]>>true, All, Caps).

% ---------------------------------------------------------------------------
% Self-grade: how confident is Mentova about its answer to a query type?
% ---------------------------------------------------------------------------

confidence_for(Tag, Conf) :-
    ( capability(Tag, _, Conf) -> true ; Conf = unknown ).

% ---------------------------------------------------------------------------
% mentova_metacognitive(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

mentova_metacognitive(what_can_i_do, caps(Caps),
                      just(metacognitive(active_capabilities, Caps))) :-
    findall(T, capability(T, _, high), Caps).

mentova_metacognitive(confidence_for(Tag), conf(Tag, Conf),
                      just(metacognitive(confidence_query(Tag), confidence(Conf)))) :-
    confidence_for(Tag, Conf).

mentova_metacognitive(self_describe, desc(Name, Rungs, Platform),
                      just(metacognitive(self_description,
                                         name(Name),
                                         rungs_implemented(Rungs),
                                         platform(Platform)))) :-
    Name = mentova,
    findall(T, capability(T, _, high), Caps),
    length(Caps, Rungs),
    Platform = prologai.

mentova_metacognitive(can_i_do(Tag), yes_using(Desc),
                      just(metacognitive(capability_check(Tag), result(yes, desc(Desc))))) :-
    capability(Tag, Desc, high), !.

mentova_metacognitive(can_i_do(Tag), limited_using(Desc),
                      just(metacognitive(capability_check(Tag), result(limited, desc(Desc))))) :-
    capability(Tag, Desc, limited), !.

mentova_metacognitive(can_i_do(_), answer(no, using(not_implemented)),
                      just(metacognitive(capability_check(unknown), result(no)))).
