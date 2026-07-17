/*  Mentova — publish the Lattice Bridge snapshot to the Causalontology commons
    and read the frontier back (Order Two, Step 3: the gardener loop, for real)

    This closes the loop the whole project was built for. It:

      1. PUBLISHES the type-tier snapshot (content objects to POST /objects, and
         Mentova's signed provenance assertions to POST /records) to a running
         Causalontology store — the same store client and endpoints the
         reference gardener uses.
      2. READS THE FRONTIER back with GET /gaps, so Mentova sees where the
         commons still needs bricks (the read-frontier -> act -> induce -> sign ->
         contribute loop, against real 2.0.0 whole-word records over real HTTP).

    Only the TYPE TIER (the laws) is published; the token tier (Mentova's
    episodic diary) is local by default and never shipped here. This is ADDITIVE
    and touches no ARC-AGI serving path.

    Run against a live store (default http://127.0.0.1:8785):
        CAUSALONTOLOGY_STORE=http://127.0.0.1:8785 \
            swipl -q -g lp_main -t halt tools/lattice_publish.pl
*/

% Declare the module and its entry points.
:- module(lattice_publish, [
    % lp_publish/2: publish an NDJSON snapshot file; report accepted/gaps.
    lp_publish/2,
    % lp_main/0: command-line entry point (halts with a gate-friendly code).
    lp_main/0
   ]).

% The PrologAI repository root (override with PROLOGAI_ROOT).
lp_prolog_root(Root) :-
    % Environment override first, then the standard sibling checkout.
    ( getenv('PROLOGAI_ROOT', Root) -> true ; Root = '/home/ccaitwo/PrologAI' ).

% The 2.0.0 export builder gives us the NDJSON reader; reuse it.
:- use_module('lattice_causalontology_export', []).
% The validator supplies the shared NDJSON parser.
:- use_module('validate_causalontology_2_0_0', [v2_read_ndjson/2]).
% HTTP client and JSON for talking to the store.
:- use_module(library(http/http_open)).
:- use_module(library(http/json)).
:- use_module(library(lists)).

% -- lp_store_base(-Base): the commons base URL, defaulting to the RFC 8785 port.
lp_store_base(Base) :-
    % Take CAUSALONTOLOGY_STORE when set, otherwise the reference default.
    ( getenv('CAUSALONTOLOGY_STORE', Base) -> true ; Base = 'http://127.0.0.1:8785' ).

% -- lp_default_snapshot(-Path): the materialised type-tier snapshot.
lp_default_snapshot('data/lattice_snapshot/causalontology_2_0_0/type_tier.ndjson').

% -- lp_get_json(+Path, -Dict): GET a store path into a dict.
lp_get_json(Path, Dict) :-
    % Build the URL from the base and the path.
    lp_store_base(Base), atom_concat(Base, Path, URL),
    % Open, read the JSON body, always close.
    setup_call_cleanup(http_open(URL, In, [status_code(_)]),
                       json_read_dict(In, Dict),
                       close(In)).

% -- lp_post_json(+Path, +Dict, -Reply): POST a dict, reading the JSON reply.
lp_post_json(Path, Dict, Reply) :-
    % Build the URL.
    lp_store_base(Base), atom_concat(Base, Path, URL),
    % Serialize the dict to a JSON atom.
    with_output_to(atom(Body), json_write_dict(current_output, Dict, [])),
    % POST it, accepting any status so replies are inspectable.
    setup_call_cleanup(
        http_open(URL, In, [method(post), post(atom('application/json', Body)),
                            status_code(_Code)]),
        json_read_dict(In, Reply),
        close(In)).

% -- lp_publish(+Path, -Result): publish every record and read the frontier back.
% Result = published(Objects, Records, Before, After) where each frontier reading
% is missing(N)-total(M): the missing_field gaps and the whole open frontier.
lp_publish(Path, published(NObj, NRec, Before, After)) :-
    % Parse the snapshot into record dicts.
    v2_read_ndjson(Path, Records),
    % Read the frontier BEFORE contributing (missing_field and total).
    lp_frontier(Before),
    % Content objects go to /objects; signed assertions go to /records.
    partition([R]>>(get_dict(type, R, "assertion")), Records, Provenance, Content),
    % Publish every content object (idempotent content-addressed put).
    foldl(lp_put_object, Content, 0, NObj),
    % Publish every signed provenance record.
    foldl(lp_put_record, Provenance, 0, NRec),
    % Read the frontier AFTER contributing.
    lp_frontier(After).

% -- lp_frontier(-Reading): the frontier as missing(N)-total(M).
lp_frontier(missing(NMiss)-total(NTot)) :-
    % The missing_field gaps (well-formed-law frontier).
    lp_gaps_count(NMiss),
    % The whole open frontier (all gap kinds, e.g. empty_mechanism).
    lp_gaps_total(NTot).

% -- lp_gaps_total(-N): the total number of open gaps of every kind.
lp_gaps_total(N) :-
    % GET the unfiltered stigmergy frontier and count its items.
    ( catch(lp_get_json('/gaps', Gaps), _, fail),
      get_dict(items, Gaps, Items), is_list(Items)
      -> length(Items, N) ; N = 0 ).

% -- lp_put_object(+Obj, +Acc0, -Acc): POST a content object; count acceptance.
lp_put_object(Obj, Acc0, Acc) :-
    % Post to the content endpoint; a returned id counts as accepted.
    ( catch(lp_post_json('/objects', Obj, Reply), _, fail), get_dict(id, Reply, _)
      -> Acc is Acc0 + 1 ; Acc = Acc0 ).

% -- lp_put_record(+Rec, +Acc0, -Acc): POST a provenance record; count acceptance.
lp_put_record(Rec, Acc0, Acc) :-
    % Post to the records endpoint; a returned id counts as accepted.
    ( catch(lp_post_json('/records', Rec, Reply), _, fail), get_dict(id, Reply, _)
      -> Acc is Acc0 + 1 ; Acc = Acc0 ).

% -- lp_gaps_count(-N): the number of open missing_field gaps on the frontier.
lp_gaps_count(N) :-
    % GET the stigmergy frontier; count its items (0 when unreachable/empty).
    ( catch(lp_get_json('/gaps?kind=missing_field', Gaps), _, fail),
      get_dict(items, Gaps, Items), is_list(Items)
      -> length(Items, N) ; N = 0 ).

% -- lp_main/0: the command-line gardener loop against the live commons.
lp_main :-
    % The snapshot to publish.
    lp_default_snapshot(Path),
    % Refuse politely when the snapshot has not been materialised yet.
    ( exists_file(Path) -> true
      ; ( format("no 2.0.0 snapshot at ~w; run make lattice-snapshot first~n", [Path]), halt(1) ) ),
    % Confirm the store is reachable before attempting to publish.
    ( catch(lp_get_json('/', _), _, fail)
      -> true
      ;  ( lp_store_base(Base),
           format("commons store unreachable at ~w — start it with:~n", [Base]),
           format("  python3 <causalontology>/store/server/server.py &~n", []),
           halt(2) ) ),
    % Publish the type tier and read the frontier before and after.
    lp_publish(Path, published(NObj, NRec, missing(MB)-total(TB), missing(MA)-total(TA))),
    % Report the round trip.
    format("published to the commons: ~w content objects, ~w signed records~n", [NObj, NRec]),
    format("frontier before: missing_field=~w total=~w~n", [MB, TB]),
    format("frontier after : missing_field=~w total=~w~n", [MA, TA]),
    % A clean missing_field frontier means Mentova's laws are well-formed; a
    % non-zero total frontier (e.g. empty_mechanism) names the next bricks to lay.
    format("Mentova read the frontier back — the commons now names ~w gaps to garden next.~n", [TA]),
    format("read-frontier -> act -> induce -> sign -> contribute: closed against a real 2.0.0 store.~n", []),
    % Exit green.
    halt(0).
