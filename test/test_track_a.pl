/*  Mentova — Track A Transparent Reasoning Assistant Test Suite

    Genuine PLUnit coverage for src/mentova/track_a.pl, whose module exports
    mentova_track_a/3 — a glass-box query interface over two expert
    ontologies (the Gene Ontology GO scope and the Disease Ontology DO scope)
    plus the cross-scope links between them — and track_a_demo/0. Every query
    returns an answer term and a human-readable justification chain of the
    named node_facts that produced it.

    The expected values asserted below are computed by hand from the static
    facts in knowledge/gene_ontology.pl and knowledge/disease_ontology.pl,
    which track_a.pl loads for itself, so no live state has to be set up.

    Run with the full library path:
        LIB=""; for d in /home/ccaitwo/PrologAI/packs/*/prolog; do LIB="$LIB -p library=$d"; done
        swipl $LIB -p library=/home/ccaitwo/Mentova/src/mentova \
              -g "run_tests, halt" -t "halt(1)" /home/ccaitwo/Mentova/test/test_track_a.pl
*/

% Declare this file as a test module with no exports.
:- module(test_track_a, []).
% Load the PLUnit test framework.
:- use_module(library(plunit)).
% Load the module under test from the library path (it pulls in both ontologies itself).
:- use_module(library(track_a)).

% Open the test block for the track_a module.
:- begin_tests(track_a).

% AC-TRACKA-001: BRCA1's only molecular-function annotation is DNA binding.
test(gene_function_brca1_is_dna_binding) :-
    % Ask the GO scope which molecular functions BRCA1 performs.
    mentova_track_a(gene_function(brca1), answer(Functions, _), _Justification),
    % Of BRCA1's four annotations only go_0003677 (dna_binding) sits in the molecular_function sub-ontology.
    assertion(Functions == [dna_binding]).

% AC-TRACKA-002: BRCA1's biological processes are DNA repair then the DNA-damage checkpoint.
test(gene_process_brca1_lists_both_processes) :-
    % Ask the GO scope which biological processes BRCA1 participates in.
    mentova_track_a(gene_process(brca1), answer(Processes, _), _Justification),
    % The two biological_process annotations come back in fact order: dna_repair then dna_damage_checkpoint.
    assertion(Processes == [dna_repair, dna_damage_checkpoint]).

% AC-TRACKA-003: BRCA1's only cellular-component location is the nucleoplasm.
test(gene_location_brca1_is_nucleoplasm) :-
    % Ask the GO scope where in the cell BRCA1 localises.
    mentova_track_a(gene_location(brca1), answer(Locations, _), _Justification),
    % Only go_0005654 (nucleoplasm) is in the cellular_component sub-ontology for BRCA1.
    assertion(Locations == [nucleoplasm]).

% AC-TRACKA-004: DNA repair classifies under biological_process along a four-hop is_a chain, with the chain and both names in the answer and justification.
test(go_classify_dna_repair_under_biological_process) :-
    % Ask the GO scope to classify dna_repair (go_0006281) under biological_process (go_0008150), taking the first proof deterministically.
    once(mentova_track_a(go_classify(go_0006281, go_0008150), Result, Justification)),
    % The answer confirms yes and carries the exact is_a chain and the two human-readable term names.
    assertion(Result == answer(yes, just(go_scope, go_classify,
                  chain([go_0006281, go_0006259, go_0008152, go_0008150]),
                  names(dna_repair, biological_process)))),
    % The justification names the descendant, the ancestor, and the via-chain used to prove it.
    assertion(Justification == justification(go_scope, go_classify, go_0006281,
                  is_a_descendant_of, go_0008150,
                  via([go_0006281, go_0006259, go_0008152, go_0008150]))).

% AC-TRACKA-005: TP53 is associated with four cancers in the DO scope, in fact order.
test(gene_diseases_tp53_four_cancers) :-
    % Ask the DO scope which diseases TP53 is associated with.
    mentova_track_a(gene_diseases(tp53), answer(Diseases, _), _Justification),
    % TP53's four disease_gene facts return cancer, lung, colorectal, and breast cancer in order.
    assertion(Diseases == [cancer, lung_cancer, colorectal_cancer, breast_cancer]).

% AC-TRACKA-006: glioblastoma classifies under disease along a five-hop is_a chain, with the chain and both names reported.
test(disease_classify_glioblastoma_is_disease) :-
    % Ask the DO scope to classify glioblastoma (doid_3068) under disease (doid_4), taking the first proof deterministically.
    once(mentova_track_a(disease_classify(doid_3068, doid_4), Result, Justification)),
    % The answer confirms yes and carries the exact is_a chain and the two disease names.
    assertion(Result == answer(yes, just(do_scope, disease_classify,
                  chain([doid_3068, doid_1319, doid_162, doid_14566, doid_4]),
                  names(glioblastoma, disease)))),
    % The justification names the descendant, the ancestor, and the via-chain used to prove it.
    assertion(Justification == justification(do_scope, disease_classify, doid_3068,
                  is_a_descendant_of, doid_4,
                  via([doid_3068, doid_1319, doid_162, doid_14566, doid_4]))).

% AC-TRACKA-007: glioblastoma has the symptoms headache and seizure, echoed in the justification.
test(disease_symptoms_glioblastoma) :-
    % Ask the DO scope which symptoms glioblastoma (doid_3068) has.
    mentova_track_a(disease_symptoms(doid_3068), answer(Symptoms, _), Justification),
    % The two symptom facts return headache then seizure in fact order.
    assertion(Symptoms == [headache, seizure]),
    % The justification restates the symptom list under the disease's node id.
    assertion(Justification == justification(do_scope, disease_symptoms, doid_3068,
                  symptoms([headache, seizure]))).

% AC-TRACKA-008: the only gene shared between breast cancer and lung cancer is TP53.
test(shared_genes_breast_and_lung_cancer_is_tp53) :-
    % Ask the cross scope which genes breast cancer (doid_1612) and lung cancer (doid_1324) share.
    mentova_track_a(shared_genes(doid_1612, doid_1324), answer(Shared, _), _Justification),
    % Breast cancer's genes are brca1, tp53, pten; lung cancer's are tp53, egfr, kras; the intersection is tp53.
    assertion(Shared == [tp53]).

% AC-TRACKA-009: signal transduction reaches four diseases across the scopes, deduplicated and sorted.
test(function_to_disease_signal_transduction_sorted) :-
    % Ask the cross scope which diseases have genes with the signal_transduction (go_0007165) function.
    mentova_track_a(function_to_disease(go_0007165), answer(Diseases, _), _Justification),
    % EGFR and KRAS carry that function; their diseases sort to colorectal, glioblastoma, lung, pancreatic.
    assertion(Diseases == [colorectal_cancer, glioblastoma, lung_cancer, pancreatic_cancer]).

% AC-TRACKA-010: the bundled demonstration runs all ten queries to its PASS line without failing.
test(track_a_demo_runs_to_completion) :-
    % Run the full Track A demonstration, capturing its printout so the test log stays clean.
    with_output_to(string(_Captured), track_a_demo).

% Close the test block for the track_a module.
:- end_tests(track_a).
