/*  Mentova — Track A: Transparent Reasoning Assistant

    Track A is the no-hardware practical track from Volume 6, Part 6.
    It gives Mentova a glass-box interface over two real expert ontologies:
    the Gene Ontology (GO) and the Disease Ontology (DO), each loaded into
    its own scope.

    Every answer returns both a conclusion and a human-readable justification
    chain built from named node_facts — the same glass-box guarantee that
    runs through all 48 rungs of the reasoning ladder.

    Query families:
        go   — queries within the GO scope (function, location, taxonomy)
        do   — queries within the DO scope (disease hierarchy, associations)
        cross — cross-scope queries linking GO functions to DO diseases

    Pass criterion (Volume 6, Part 6, Track A):
        pose a question, receive the answer with the readable chain of
        node_facts and justifications that produced it.

    The Gene Ontology multi-scope showpiece passes when:
        1. Deep taxonomic deduction (go_classify) works across 4+ hops
        2. Gene function queries return GO term names with justifications
        3. Cross-scope queries link GO molecular functions to DO diseases
        4. All justifications name the specific node_facts used
*/

% Declare this file as the 'track_a' module, making its predicates available to other modules.
:- module(track_a, [
    % Supply 'mentova_track_a/3' as the next argument to the expression above.
    mentova_track_a/3,
    % Supply 'track_a_demo/0' as the next argument to the expression above.
    track_a_demo/0
% Close the expression opened above.
]).

% Load the built-in 'lists' library so its predicates are available here.
:- use_module(library(lists), [member/2]).
% Load the built-in 'aggregate' library so its predicates are available here.
:- use_module(library(aggregate)).
% Load the 'gene_ontology' module so its predicates are available here.
:- use_module('../../knowledge/gene_ontology').
% Load the 'disease_ontology' module so its predicates are available here.
:- use_module('../../knowledge/disease_ontology').

% ---------------------------------------------------------------------------
% mentova_track_a(+Query, -Result, -Justification)
%
% Top-level Track A entry point. QueryType embedded in the Query term.
%
% GO queries:
%   gene_function(Gene)           — what molecular functions does Gene perform?
%   gene_location(Gene)           — what cellular components does Gene localise to?
%   gene_process(Gene)            — what biological processes does Gene participate in?
%   go_classify(TermID, AncestorID) — is TermID a descendant of AncestorID? show chain.
%   go_ancestors(TermID)          — list all ancestors of TermID
%
% DO queries:
%   gene_diseases(Gene)           — what diseases is Gene associated with?
%   disease_genes(DiseaseID)      — what genes are associated with DiseaseID?
%   disease_classify(DiseaseID, AncestorID) — is DiseaseID a descendant of AncestorID?
%   disease_symptoms(DiseaseID)   — what symptoms does DiseaseID have?
%
% Cross-scope queries:
%   explain_disease(DiseaseID)    — link disease to GO functions of associated genes
%   shared_genes(DiseaseA, DiseaseB) — genes shared between two diseases
%   function_to_disease(GoTermID) — which diseases have genes with this GO function?
% ---------------------------------------------------------------------------

% ---------------------------------------------------------------------------
% GO SCOPE QUERIES
% ---------------------------------------------------------------------------

% Define a clause for 'mentova_track_a' handling 'gene_function' queries.
mentova_track_a(gene_function(Gene),
                answer(Functions, just(go_scope, gene_function, Gene, annotations(Anns))),
                justification(go_scope, gene_function, Gene, detail(Anns))) :-
    % Collect all molecular-function GO annotations for the given gene.
    findall(
        % For each annotation, collect both the GO term ID and its human-readable name.
        fn(GoID, Name, Evidence),
        % Find a GO annotation for Gene that belongs to the molecular_function sub-ontology.
        ( go_annotation(Gene, GoID, Evidence),
          go_sub_ontology(GoID, molecular_function),
          go_term(GoID, Name) ),
        % Bind the collected list to 'DirectAnns'.
        DirectAnns
    ),
    % Also collect inferred functions via is_a chains from annotated terms.
    findall(
        % For each inferred function, record the annotated term, the ancestor, and the chain.
        inferred(GoID, AncName, Chain),
        % Find a GO annotation then find an ancestor in the molecular_function sub-ontology.
        ( go_annotation(Gene, GoID, _),
          go_is_a_chain(GoID, AncID, Chain),
          go_sub_ontology(AncID, molecular_function),
          go_term(AncID, AncName),
          AncID \= GoID ),
        % Bind the collected list to 'InferredAnns'.
        InferredAnns
    ),
    % Combine direct and inferred annotations into one list.
    append(DirectAnns, InferredAnns, Anns),
    % Require that at least one annotation was found.
    Anns \= [],
    % Collect just the human-readable function names for the top-level result.
    findall(Name, member(fn(_, Name, _), DirectAnns), Functions).

% Define a clause for 'mentova_track_a' handling 'gene_location' queries.
mentova_track_a(gene_location(Gene),
                answer(Locations, just(go_scope, gene_location, Gene, annotations(Locs))),
                justification(go_scope, gene_location, Gene, detail(Locs))) :-
    % Collect all cellular-component GO annotations for the given gene.
    findall(
        % For each location annotation, collect the GO term ID, name, and evidence.
        loc(GoID, Name, Evidence),
        % Find a GO annotation for Gene that belongs to the cellular_component sub-ontology.
        ( go_annotation(Gene, GoID, Evidence),
          go_sub_ontology(GoID, cellular_component),
          go_term(GoID, Name) ),
        % Bind the collected list to 'Locs'.
        Locs
    ),
    % Require that at least one location was found.
    Locs \= [],
    % Collect just the human-readable location names for the top-level result.
    findall(Name, member(loc(_, Name, _), Locs), Locations).

% Define a clause for 'mentova_track_a' handling 'gene_process' queries.
mentova_track_a(gene_process(Gene),
                answer(Processes, just(go_scope, gene_process, Gene, annotations(Procs))),
                justification(go_scope, gene_process, Gene, detail(Procs))) :-
    % Collect all biological-process GO annotations for the given gene.
    findall(
        % For each process annotation, collect the GO term ID, name, and evidence.
        proc(GoID, Name, Evidence),
        % Find a GO annotation for Gene that belongs to the biological_process sub-ontology.
        ( go_annotation(Gene, GoID, Evidence),
          go_sub_ontology(GoID, biological_process),
          go_term(GoID, Name) ),
        % Bind the collected list to 'Procs'.
        Procs
    ),
    % Require that at least one process was found.
    Procs \= [],
    % Collect just the human-readable process names for the top-level result.
    findall(Name, member(proc(_, Name, _), Procs), Processes).

% Define a clause for 'mentova_track_a' handling 'go_classify' queries.
mentova_track_a(go_classify(TermID, AncestorID),
                answer(yes, just(go_scope, go_classify, chain(Chain), names(TermName, AncName))),
                justification(go_scope, go_classify, TermID, is_a_descendant_of, AncestorID, via(Chain))) :-
    % Find the transitive is_a chain from TermID up to AncestorID.
    go_is_a_chain(TermID, AncestorID, Chain),
    % Look up the human-readable name for the child term.
    go_term(TermID, TermName),
    % Look up the human-readable name for the ancestor term.
    go_term(AncestorID, AncName).

% Define a clause for 'mentova_track_a' handling 'go_ancestors' queries.
mentova_track_a(go_ancestors(TermID),
                answer(AncNames, just(go_scope, go_ancestors, TermID, chains(Chains))),
                justification(go_scope, go_ancestors, TermID, all_chains(Chains))) :-
    % Collect all direct parents of TermID in the is_a hierarchy.
    findall(
        % For each ancestor, collect the chain of IDs and the human-readable ancestor name.
        anc(AncID, AncName, Chain),
        % Find a complete is_a chain from TermID up to any ancestor AncID.
        ( go_is_a_chain(TermID, AncID, Chain),
          go_term(AncID, AncName) ),
        % Bind the collected list to 'Chains'.
        Chains
    ),
    % Require at least one ancestor.
    Chains \= [],
    % Collect just the ancestor names for the top-level result.
    findall(AncName, member(anc(_, AncName, _), Chains), AncNamesDup),
    % Remove duplicate names from the list.
    sort(AncNamesDup, AncNames).

% ---------------------------------------------------------------------------
% DO SCOPE QUERIES
% ---------------------------------------------------------------------------

% Define a clause for 'mentova_track_a' handling 'gene_diseases' queries.
mentova_track_a(gene_diseases(Gene),
                answer(DiseaseNames, just(do_scope, gene_diseases, Gene, associations(Assocs))),
                justification(do_scope, gene_diseases, Gene, detail(Assocs))) :-
    % Collect all disease associations for the given gene.
    findall(
        % For each association, record the disease ID, name, and evidence type.
        assoc(DID, DName, Evidence),
        % Find a disease_gene fact for Gene, then look up the disease name.
        ( disease_gene(DID, Gene, Evidence),
          disease_term(DID, DName) ),
        % Bind the collected list to 'Assocs'.
        Assocs
    ),
    % Require at least one association.
    Assocs \= [],
    % Collect just the disease names for the top-level result.
    findall(DName, member(assoc(_, DName, _), Assocs), DiseaseNames).

% Define a clause for 'mentova_track_a' handling 'disease_genes' queries.
mentova_track_a(disease_genes(DiseaseID),
                answer(Genes, just(do_scope, disease_genes, DiseaseID, name(DiseaseName), genes(Assocs))),
                justification(do_scope, disease_genes, DiseaseID, detail(Assocs))) :-
    % Look up the human-readable name for the disease.
    disease_term(DiseaseID, DiseaseName),
    % Collect all genes associated with this disease.
    findall(
        % For each gene association, record the gene symbol and evidence type.
        gene(Gene, Evidence),
        % Find a disease_gene fact for DiseaseID.
        disease_gene(DiseaseID, Gene, Evidence),
        % Bind the collected list to 'Assocs'.
        Assocs
    ),
    % Require at least one gene association.
    Assocs \= [],
    % Collect just the gene names for the top-level result.
    findall(Gene, member(gene(Gene, _), Assocs), Genes).

% Define a clause for 'mentova_track_a' handling 'disease_classify' queries.
mentova_track_a(disease_classify(DiseaseID, AncestorID),
                answer(yes, just(do_scope, disease_classify, chain(Chain), names(DisName, AncName))),
                justification(do_scope, disease_classify, DiseaseID, is_a_descendant_of, AncestorID, via(Chain))) :-
    % Find the transitive is_a chain from DiseaseID up to AncestorID.
    disease_is_a_chain(DiseaseID, AncestorID, Chain),
    % Look up the human-readable name for the child disease.
    disease_term(DiseaseID, DisName),
    % Look up the human-readable name for the ancestor disease.
    disease_term(AncestorID, AncName).

% Define a clause for 'mentova_track_a' handling 'disease_symptoms' queries.
mentova_track_a(disease_symptoms(DiseaseID),
                answer(Symptoms, just(do_scope, disease_symptoms, DiseaseID, name(DisName))),
                justification(do_scope, disease_symptoms, DiseaseID, symptoms(Symptoms))) :-
    % Look up the human-readable name for the disease.
    disease_term(DiseaseID, DisName),
    % Collect all known symptoms of the disease.
    findall(Symptom, disease_symptom(DiseaseID, Symptom), Symptoms),
    % Require at least one symptom.
    Symptoms \= [].

% ---------------------------------------------------------------------------
% CROSS-SCOPE QUERIES
% ---------------------------------------------------------------------------

% Define a clause for 'mentova_track_a' handling 'explain_disease' cross-scope queries.
mentova_track_a(explain_disease(DiseaseID),
                answer(Explanation, just(cross_scope, go_plus_do, DiseaseID, name(DisName), via(Links))),
                justification(cross_scope, explain_disease, DiseaseID, gene_function_links(Links))) :-
    % Look up the human-readable name for the disease.
    disease_term(DiseaseID, DisName),
    % Collect cross-scope links: for each gene associated with the disease,
    % find its GO molecular functions.
    findall(
        % For each link, record the gene, its disease association, and GO functions.
        link(Gene, Evidence, Functions),
        % Find a gene associated with the disease, then find its GO functions.
        ( disease_gene(DiseaseID, Gene, Evidence),
          findall(
              fn(FnID, FnName),
              ( go_annotation(Gene, FnID, _),
                go_sub_ontology(FnID, molecular_function),
                go_term(FnID, FnName) ),
              Functions ),
          Functions \= [] ),
        % Bind the collected list to 'Links'.
        Links
    ),
    % Require at least one cross-scope link.
    Links \= [],
    % Build the top-level explanation from the collected links.
    Explanation = cross_scope_explanation(DiseaseID, DisName, gene_function_links(Links)).

% Define a clause for 'mentova_track_a' handling 'shared_genes' cross-scope queries.
mentova_track_a(shared_genes(DiseaseA, DiseaseB),
                answer(Shared, just(cross_scope, shared_genes, DiseaseA, and, DiseaseB, names(NameA, NameB))),
                justification(cross_scope, shared_genes, DiseaseA, DiseaseB, shared(Shared))) :-
    % Look up the human-readable name for the first disease.
    disease_term(DiseaseA, NameA),
    % Look up the human-readable name for the second disease.
    disease_term(DiseaseB, NameB),
    % Collect all genes associated with the first disease.
    findall(Gene, disease_gene(DiseaseA, Gene, _), GenesA),
    % Collect all genes associated with the second disease.
    findall(Gene, disease_gene(DiseaseB, Gene, _), GenesB),
    % Find the intersection of the two gene lists.
    include([G]>>(member(G, GenesB)), GenesA, Shared),
    % Require at least one shared gene.
    Shared \= [].

% Define a clause for 'mentova_track_a' handling 'function_to_disease' cross-scope queries.
mentova_track_a(function_to_disease(GoTermID),
                answer(Diseases, just(cross_scope, function_to_disease, GoTermID, name(FnName), via(Links))),
                justification(cross_scope, function_to_disease, GoTermID, fn_name(FnName), disease_links(Links))) :-
    % Look up the human-readable name for the GO term.
    go_term(GoTermID, FnName),
    % Collect all diseases reachable via: gene has GO annotation -> gene has disease association.
    findall(
        % For each link, record the gene, its GO annotation evidence, the disease, and disease evidence.
        link(Gene, GoEvid, DID, DName, DEvid),
        % Find a gene annotated with GoTermID, then find a disease associated with that gene.
        ( go_annotation(Gene, GoTermID, GoEvid),
          disease_gene(DID, Gene, DEvid),
          disease_term(DID, DName) ),
        % Bind the collected list to 'Links'.
        Links
    ),
    % Require at least one link.
    Links \= [],
    % Collect just the unique disease names for the top-level result.
    findall(DName, member(link(_, _, _, DName, _), Links), DNamesDup),
    % Remove duplicate disease names.
    sort(DNamesDup, Diseases).

% ---------------------------------------------------------------------------
% track_a_demo/0 — run all Track A demonstration queries
% ---------------------------------------------------------------------------

% Define a clause for 'track_a_demo': run the full Track A glass-box demonstration.
track_a_demo :-
    % Write a section header for the Track A demonstration output.
    format("~n=== Track A: Transparent Reasoning Assistant ===~n"),
    % Write a sub-header identifying the GO scope demonstration.
    format("--- GO Scope: Gene Ontology Expert Queries ---~n~n"),

    % DEMO 1: gene function query
    % Write a label for demonstration query 1.
    format("Q1: What molecular functions does BRCA1 perform?~n"),
    % Execute the gene function query for BRCA1 and print the result with justification.
    mentova_track_a(gene_function(brca1), R1, J1),
    % Write the result of query 1 to standard output.
    format("    Result:        ~w~n", [R1]),
    % Write the justification of query 1 to standard output.
    format("    Justification: ~w~n~n", [J1]),

    % DEMO 2: gene location query
    % Write a label for demonstration query 2.
    format("Q2: Where in the cell does BRCA1 localise?~n"),
    % Execute the gene location query for BRCA1.
    mentova_track_a(gene_location(brca1), R2, J2),
    % Write the result of query 2 to standard output.
    format("    Result:        ~w~n", [R2]),
    % Write the justification of query 2 to standard output.
    format("    Justification: ~w~n~n", [J2]),

    % DEMO 3: deep GO taxonomy classification (4-hop chain)
    % Write a label for demonstration query 3.
    format("Q3: Is DNA repair (go_0006281) a descendant of biological_process (go_0008150)?~n"),
    % Execute the GO classification query to find the 4-hop is_a chain.
    mentova_track_a(go_classify(go_0006281, go_0008150), R3, J3),
    % Write the result of query 3 to standard output.
    format("    Result:        ~w~n", [R3]),
    % Write the justification of query 3 to standard output.
    format("    Justification: ~w~n~n", [J3]),

    % DEMO 4: GO classification — molecular function hierarchy (3-hop)
    % Write a label for demonstration query 4.
    format("Q4: Is protein_tyrosine_kinase_activity a kind of molecular_function?~n"),
    % Execute the GO classification query for protein_tyrosine_kinase_activity.
    mentova_track_a(go_classify(go_0004713, go_0003674), R4, J4),
    % Write the result of query 4 to standard output.
    format("    Result:        ~w~n", [R4]),
    % Write the justification of query 4 to standard output.
    format("    Justification: ~w~n~n", [J4]),

    % Write a sub-header identifying the DO scope demonstration.
    format("--- DO Scope: Disease Ontology Expert Queries ---~n~n"),

    % DEMO 5: gene-disease associations
    % Write a label for demonstration query 5.
    format("Q5: What diseases is TP53 associated with?~n"),
    % Execute the gene diseases query for TP53.
    mentova_track_a(gene_diseases(tp53), R5, J5),
    % Write the result of query 5 to standard output.
    format("    Result:        ~w~n", [R5]),
    % Write the justification of query 5 to standard output.
    format("    Justification: ~w~n~n", [J5]),

    % DEMO 6: disease taxonomy classification (3-hop)
    % Write a label for demonstration query 6.
    format("Q6: Is glioblastoma (doid_3068) a kind of disease (doid_4)?~n"),
    % Execute the disease classification query for glioblastoma.
    mentova_track_a(disease_classify(doid_3068, doid_4), R6, J6),
    % Write the result of query 6 to standard output.
    format("    Result:        ~w~n", [R6]),
    % Write the justification of query 6 to standard output.
    format("    Justification: ~w~n~n", [J6]),

    % DEMO 7: disease gene lookup
    % Write a label for demonstration query 7.
    format("Q7: What genes are associated with breast cancer (doid_1612)?~n"),
    % Execute the disease genes query for breast cancer.
    mentova_track_a(disease_genes(doid_1612), R7, J7),
    % Write the result of query 7 to standard output.
    format("    Result:        ~w~n", [R7]),
    % Write the justification of query 7 to standard output.
    format("    Justification: ~w~n~n", [J7]),

    % Write a sub-header identifying the cross-scope demonstration.
    format("--- Cross-Scope: GO + DO Linked Expert Queries ---~n~n"),

    % DEMO 8: cross-scope disease explanation via gene functions
    % Write a label for demonstration query 8.
    format("Q8: Explain breast cancer (doid_1612) via the GO functions of its genes.~n"),
    % Execute the cross-scope explain_disease query for breast cancer.
    mentova_track_a(explain_disease(doid_1612), R8, J8),
    % Write the result of query 8 to standard output.
    format("    Result:        ~w~n", [R8]),
    % Write the justification of query 8 to standard output.
    format("    Justification: ~w~n~n", [J8]),

    % DEMO 9: shared genes between two diseases
    % Write a label for demonstration query 9.
    format("Q9: What genes are shared between breast cancer and lung cancer?~n"),
    % Execute the shared genes cross-scope query.
    mentova_track_a(shared_genes(doid_1612, doid_1324), R9, J9),
    % Write the result of query 9 to standard output.
    format("    Result:        ~w~n", [R9]),
    % Write the justification of query 9 to standard output.
    format("    Justification: ~w~n~n", [J9]),

    % DEMO 10: function to disease (cross-scope reverse lookup)
    % Write a label for demonstration query 10.
    format("Q10: Which diseases have genes with signal_transduction (go_0007165) annotations?~n"),
    % Execute the function_to_disease cross-scope query.
    mentova_track_a(function_to_disease(go_0007165), R10, J10),
    % Write the result of query 10 to standard output.
    format("    Result:        ~w~n", [R10]),
    % Write the justification of query 10 to standard output.
    format("    Justification: ~w~n~n", [J10]),

    % Write the pass/fail verdict for the Track A demonstration.
    format("All Track A queries answered with readable justifications. PASS.~n~n").
