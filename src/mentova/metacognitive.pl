/*  Mentova — Rung 32: Metacognitive Reasoning Module

    Reasons about Mentova's own reasoning capabilities and confidence.
    Pass criterion: Mentova reports which reasoning type applies to a
    query and what its confidence in the answer is.
*/

% Declare this file as the 'metacognitive' module and list its exported predicates.
:- module(metacognitive, [
    % Supply 'mentova_metacognitive/3' as the next argument to the expression above.
    mentova_metacognitive/3
% Close the expression opened above.
]).

% Import [member/2] from the built-in 'lists' library.
:- use_module(library(lists), [member/2]).

% ---------------------------------------------------------------------------
% Capability registry: capability(Tag, Description, Confidence)
% ---------------------------------------------------------------------------

% State the fact: capability(probabilistic,  'probability algebra and weighted facts',     high).
capability(probabilistic,  'probability algebra and weighted facts',     high).
% State the fact: capability(bayes,          'Bayesian prior-to-posterior update',         high).
capability(bayes,          'Bayesian prior-to-posterior update',         high).
% State the fact: capability(causal,         'do-calculus causal inference',               high).
capability(causal,         'do-calculus causal inference',               high).
% State the fact: capability(stats,          'aggregate observation statistics',           high).
capability(stats,          'aggregate observation statistics',           high).
% State the fact: capability(analogy,        'structure-mapping analogical reasoning',     high).
capability(analogy,        'structure-mapping analogical reasoning',     high).
% State the fact: capability(relational,     'multi-hop graph traversal',                  high).
capability(relational,     'multi-hop graph traversal',                  high).
% State the fact: capability(transductive,   'kNN instance-based classification',          high).
capability(transductive,   'kNN instance-based classification',          high).
% State the fact: capability(commonsense,    'small-world commonsense lookup',             high).
capability(commonsense,    'small-world commonsense lookup',             high).
% State the fact: capability(logical,        'forward-chaining rule saturation',           high).
capability(logical,        'forward-chaining rule saturation',           high).
% State the fact: capability(formal,         'MPK proof-rule checking',                    high).
capability(formal,         'MPK proof-rule checking',                    high).
% State the fact: capability(mathematical,   'arithmetic and number theory',               high).
capability(mathematical,   'arithmetic and number theory',               high).
% State the fact: capability(fuzzy,          'triangular membership function grading',     high).
capability(fuzzy,          'triangular membership function grading',     high).
% State the fact: capability(qualitative,    'sign-algebra influence propagation',         high).
capability(qualitative,    'sign-algebra influence propagation',         high).
% State the fact: capability(nonmonotonic,   'defeasible default retraction',              high).
capability(nonmonotonic,   'defeasible default retraction',              high).
% State the fact: capability(paraconsistent, 'contradiction isolation without explosion',   high).
capability(paraconsistent, 'contradiction isolation without explosion',   high).
% State the fact: capability(counterfactual, 'closest-world counterfactual evaluation',    high).
capability(counterfactual, 'closest-world counterfactual evaluation',    high).
% State the fact: capability(hypothetical,   'context-list supposition derivation',        high).
capability(hypothetical,   'context-list supposition derivation',        high).
% State the fact: capability(spatial,        'containment and adjacency chains',           high).
capability(spatial,        'containment and adjacency chains',           high).
% State the fact: capability(diagrammatic,   'named-grid symbol counting',                 high).
capability(diagrammatic,   'named-grid symbol counting',                 high).
% State the fact: capability(temporal,       'event ordering and duration reasoning',      high).
capability(temporal,       'event ordering and duration reasoning',      high).
% State the fact: capability(case_based,     'similarity-based case retrieval',            high).
capability(case_based,     'similarity-based case retrieval',            high).
% State the fact: capability(constraint,     'constraint satisfaction with deduction log', high).
capability(constraint,     'constraint satisfaction with deduction log', high).
% State the fact: capability(scientific,     'hypothesis formation and scoring',           high).
capability(scientific,     'hypothesis formation and scoring',           high).
% State the fact: capability(system,         'parts-roles-behavior system modeling',       high).
capability(system,         'parts-roles-behavior system modeling',       high).
% State the fact: capability(model_based,    'linear/threshold/FSM model prediction',      high).
capability(model_based,    'linear/threshold/FSM model prediction',      high).
% State the fact: capability(heuristic,      'greedy best-first and Dijkstra search',      high).
capability(heuristic,      'greedy best-first and Dijkstra search',      high).
% State the fact: capability(critical,       'evidence-support grading and flagging',      high).
capability(critical,       'evidence-support grading and flagging',      high).
% State the fact: capability(dialectical,    'pro/con argument weighing and synthesis',    high).
capability(dialectical,    'pro/con argument weighing and synthesis',    high).

% Gaps (not yet implemented or limited)
% State the fact: capability(inductive_general, 'general inductive concept learning',    limited).
capability(inductive_general, 'general inductive concept learning',    limited).
% State the fact: capability(abductive_deep,    'abduction over large hypothesis spaces', limited).
capability(abductive_deep,    'abduction over large hypothesis spaces', limited).
% State the fact: capability(continuous_time,   'continuous differential equations',      none).
capability(continuous_time,   'continuous differential equations',      none).
% State the fact: capability(vision,            'image perception and parsing',           none).
capability(vision,            'image perception and parsing',           none).

% ---------------------------------------------------------------------------
% Introspect: which capabilities are active?
% ---------------------------------------------------------------------------

% Define a clause for 'introspect all': succeed when the following conditions hold.
introspect_all(Caps) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(T-D-C, capability(T, D, C), All),
    % State the fact: include([_-_-high]>>true, All, Caps).
    include([_-_-high]>>true, All, Caps).

% ---------------------------------------------------------------------------
% Self-grade: how confident is Mentova about its answer to a query type?
% ---------------------------------------------------------------------------

% Define a clause for 'confidence for': succeed when the following conditions hold.
confidence_for(Tag, Conf) :-
    % Check that '( capability(Tag, _, Conf) -> true ; Conf' is unifiable with 'unknown )'.
    ( capability(Tag, _, Conf) -> true ; Conf = unknown ).

% ---------------------------------------------------------------------------
% mentova_metacognitive(+Query, -Result, -Justification)
% ---------------------------------------------------------------------------

% State a fact for 'mentova metacognitive' with the arguments listed below.
mentova_metacognitive(what_can_i_do, caps(Caps),
                      % Continue the multi-line expression started above.
                      just(metacognitive(active_capabilities, Caps))) :-
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(T, capability(T, _, high), Caps).

% State a fact for 'mentova metacognitive' with the arguments listed below.
mentova_metacognitive(confidence_for(Tag), conf(Tag, Conf),
                      % Continue the multi-line expression started above.
                      just(metacognitive(confidence_query(Tag), confidence(Conf)))) :-
    % State the fact: confidence for(Tag, Conf).
    confidence_for(Tag, Conf).

% State a fact for 'mentova metacognitive' with the arguments listed below.
mentova_metacognitive(self_describe, desc(Name, Rungs, Platform),
                      % Continue the multi-line expression started above.
                      just(metacognitive(self_description,
                                         % Continue the multi-line expression started above.
                                         name(Name),
                                         % Continue the multi-line expression started above.
                                         rungs_implemented(Rungs),
                                         % Continue the multi-line expression started above.
                                         platform(Platform)))) :-
    % Check that 'Name' is unifiable with 'mentova'.
    Name = mentova,
    % Collect all matching Template values into a list (findall — never fails, returns empty list if none).
    findall(T, capability(T, _, high), Caps),
    % Unify 'Rungs' with the number of elements in list 'Caps'.
    length(Caps, Rungs),
    % Check that 'Platform' is unifiable with 'prologai'.
    Platform = prologai.

% State a fact for 'mentova metacognitive' with the arguments listed below.
mentova_metacognitive(can_i_do(Tag), yes_using(Desc),
                      % Continue the multi-line expression started above.
                      just(metacognitive(capability_check(Tag), result(yes, desc(Desc))))) :-
    % State a fact for 'capability' with the arguments listed below.
    capability(Tag, Desc, high), !.

% State a fact for 'mentova metacognitive' with the arguments listed below.
mentova_metacognitive(can_i_do(Tag), limited_using(Desc),
                      % Continue the multi-line expression started above.
                      just(metacognitive(capability_check(Tag), result(limited, desc(Desc))))) :-
    % State a fact for 'capability' with the arguments listed below.
    capability(Tag, Desc, limited), !.

% State a fact for 'mentova metacognitive' with the arguments listed below.
mentova_metacognitive(can_i_do(_), answer(no, using(not_implemented)),
                      % Continue the multi-line expression started above.
                      just(metacognitive(capability_check(unknown), result(no)))).
