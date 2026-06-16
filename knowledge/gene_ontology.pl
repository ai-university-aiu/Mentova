/*  Mentova — Gene Ontology Knowledge Base (GO Scope)

    A curated subset of the Gene Ontology (GO), loaded into its own scope.
    Three sub-ontologies: Biological Process (BP), Molecular Function (MF),
    Cellular Component (CC). Gene annotations link genes to GO terms.

    Relations used: go_is_a/2, go_part_of/2, go_regulates/2, go_annotation/3.
    Every fact is a node_fact; every answer carries a readable justification.

    Source: Gene Ontology Consortium (https://geneontology.org)
    This is a hand-curated toy subset for demonstration purposes only.
*/

% Declare this file as the 'gene_ontology' module, making its predicates available to other modules.
:- module(gene_ontology, [
    % Supply 'go_term/2' as the next argument to the expression above.
    go_term/2,
    % Supply 'go_is_a/2' as the next argument to the expression above.
    go_is_a/2,
    % Supply 'go_part_of/2' as the next argument to the expression above.
    go_part_of/2,
    % Supply 'go_regulates/2' as the next argument to the expression above.
    go_regulates/2,
    % Supply 'go_annotation/3' as the next argument to the expression above.
    go_annotation/3,
    % Supply 'go_sub_ontology/2' as the next argument to the expression above.
    go_sub_ontology/2,
    % Supply 'go_is_a_chain/3' as the next argument to the expression above.
    go_is_a_chain/3,
    % Supply 'go_ancestor/2' as the next argument to the expression above.
    go_ancestor/2
% Close the expression opened above.
]).

% Allow 'go_is_a/2' clauses to appear at non-consecutive positions in this file.
:- discontiguous go_is_a/2.
% Allow 'go_term/2' clauses to appear at non-consecutive positions in this file.
:- discontiguous go_term/2.
% Allow 'go_annotation/3' clauses to appear at non-consecutive positions in this file.
:- discontiguous go_annotation/3.

% ---------------------------------------------------------------------------
% GO Term Registry — go_term(+ID, +Name)
% ---------------------------------------------------------------------------

% ROOT TERMS

% State the fact: the GO term with identifier 'go_0003674' is named 'molecular_function'.
go_term(go_0003674, molecular_function).
% State the fact: the GO term with identifier 'go_0008150' is named 'biological_process'.
go_term(go_0008150, biological_process).
% State the fact: the GO term with identifier 'go_0005575' is named 'cellular_component'.
go_term(go_0005575, cellular_component).

% BIOLOGICAL PROCESS TERMS

% State the fact: the GO term 'go_0009987' is named 'cellular_process'.
go_term(go_0009987, cellular_process).
% State the fact: the GO term 'go_0008152' is named 'metabolic_process'.
go_term(go_0008152, metabolic_process).
% State the fact: the GO term 'go_0007049' is named 'cell_cycle'.
go_term(go_0007049, cell_cycle).
% State the fact: the GO term 'go_0007165' is named 'signal_transduction'.
go_term(go_0007165, signal_transduction).
% State the fact: the GO term 'go_0006915' is named 'apoptotic_process'.
go_term(go_0006915, apoptotic_process).
% State the fact: the GO term 'go_0006259' is named 'dna_metabolic_process'.
go_term(go_0006259, dna_metabolic_process).
% State the fact: the GO term 'go_0006281' is named 'dna_repair'.
go_term(go_0006281, dna_repair).
% State the fact: the GO term 'go_0005975' is named 'carbohydrate_metabolic_process'.
go_term(go_0005975, carbohydrate_metabolic_process).
% State the fact: the GO term 'go_0006096' is named 'glycolytic_process'.
go_term(go_0006096, glycolytic_process).
% State the fact: the GO term 'go_0001228' is named 'transcription_regulator_activity_binding'.
go_term(go_0001228, dna_binding_transcription_activator_activity).
% State the fact: the GO term 'go_0051301' is named 'cell_division'.
go_term(go_0051301, cell_division).
% State the fact: the GO term 'go_0000077' is named 'dna_damage_checkpoint'.
go_term(go_0000077, dna_damage_checkpoint).
% State the fact: the GO term 'go_0042981' is named 'regulation_of_apoptotic_process'.
go_term(go_0042981, regulation_of_apoptotic_process).
% State the fact: the GO term 'go_0045786' is named 'negative_regulation_of_cell_cycle'.
go_term(go_0045786, negative_regulation_of_cell_cycle).

% MOLECULAR FUNCTION TERMS

% State the fact: the GO term 'go_0003824' is named 'catalytic_activity'.
go_term(go_0003824, catalytic_activity).
% State the fact: the GO term 'go_0016787' is named 'hydrolase_activity'.
go_term(go_0016787, hydrolase_activity).
% State the fact: the GO term 'go_0016301' is named 'kinase_activity'.
go_term(go_0016301, kinase_activity).
% State the fact: the GO term 'go_0004672' is named 'protein_kinase_activity'.
go_term(go_0004672, protein_kinase_activity).
% State the fact: the GO term 'go_0003677' is named 'dna_binding'.
go_term(go_0003677, dna_binding).
% State the fact: the GO term 'go_0003700' is named 'dna_binding_transcription_factor_activity'.
go_term(go_0003700, dna_binding_transcription_factor_activity).
% State the fact: the GO term 'go_0008017' is named 'microtubule_binding'.
go_term(go_0008017, microtubule_binding).
% State the fact: the GO term 'go_0005515' is named 'protein_binding'.
go_term(go_0005515, protein_binding).
% State the fact: the GO term 'go_0004725' is named 'protein_tyrosine_phosphatase_activity'.
go_term(go_0004725, protein_tyrosine_phosphatase_activity).
% State the fact: the GO term 'go_0004713' is named 'protein_tyrosine_kinase_activity'.
go_term(go_0004713, protein_tyrosine_kinase_activity).

% CELLULAR COMPONENT TERMS

% State the fact: the GO term 'go_0005623' is named 'cell'.
go_term(go_0005623, cell).
% State the fact: the GO term 'go_0005622' is named 'intracellular_anatomical_structure'.
go_term(go_0005622, intracellular_anatomical_structure).
% State the fact: the GO term 'go_0005634' is named 'nucleus'.
go_term(go_0005634, nucleus).
% State the fact: the GO term 'go_0005737' is named 'cytoplasm'.
go_term(go_0005737, cytoplasm).
% State the fact: the GO term 'go_0005739' is named 'mitochondrion'.
go_term(go_0005739, mitochondrion).
% State the fact: the GO term 'go_0005694' is named 'chromosome'.
go_term(go_0005694, chromosome).
% State the fact: the GO term 'go_0005654' is named 'nucleoplasm'.
go_term(go_0005654, nucleoplasm).
% State the fact: the GO term 'go_0005829' is named 'cytosol'.
go_term(go_0005829, cytosol).
% State the fact: the GO term 'go_0016020' is named 'membrane'.
go_term(go_0016020, membrane).
% State the fact: the GO term 'go_0005886' is named 'plasma_membrane'.
go_term(go_0005886, plasma_membrane).

% ---------------------------------------------------------------------------
% Sub-ontology membership — go_sub_ontology(+ID, +SubOntology)
% SubOntology is one of: biological_process, molecular_function, cellular_component
% ---------------------------------------------------------------------------

% State the fact: GO term 'go_0008150' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0008150, biological_process).
% State the fact: GO term 'go_0009987' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0009987, biological_process).
% State the fact: GO term 'go_0008152' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0008152, biological_process).
% State the fact: GO term 'go_0007049' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0007049, biological_process).
% State the fact: GO term 'go_0007165' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0007165, biological_process).
% State the fact: GO term 'go_0006915' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0006915, biological_process).
% State the fact: GO term 'go_0006259' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0006259, biological_process).
% State the fact: GO term 'go_0006281' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0006281, biological_process).
% State the fact: GO term 'go_0005975' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0005975, biological_process).
% State the fact: GO term 'go_0006096' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0006096, biological_process).
% State the fact: GO term 'go_0051301' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0051301, biological_process).
% State the fact: GO term 'go_0000077' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0000077, biological_process).
% State the fact: GO term 'go_0042981' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0042981, biological_process).
% State the fact: GO term 'go_0045786' belongs to the 'biological_process' sub-ontology.
go_sub_ontology(go_0045786, biological_process).

% State the fact: GO term 'go_0003674' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0003674, molecular_function).
% State the fact: GO term 'go_0003824' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0003824, molecular_function).
% State the fact: GO term 'go_0016787' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0016787, molecular_function).
% State the fact: GO term 'go_0016301' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0016301, molecular_function).
% State the fact: GO term 'go_0004672' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0004672, molecular_function).
% State the fact: GO term 'go_0003677' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0003677, molecular_function).
% State the fact: GO term 'go_0003700' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0003700, molecular_function).
% State the fact: GO term 'go_0008017' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0008017, molecular_function).
% State the fact: GO term 'go_0005515' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0005515, molecular_function).
% State the fact: GO term 'go_0004725' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0004725, molecular_function).
% State the fact: GO term 'go_0004713' belongs to the 'molecular_function' sub-ontology.
go_sub_ontology(go_0004713, molecular_function).

% State the fact: GO term 'go_0005575' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0005575, cellular_component).
% State the fact: GO term 'go_0005623' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0005623, cellular_component).
% State the fact: GO term 'go_0005622' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0005622, cellular_component).
% State the fact: GO term 'go_0005634' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0005634, cellular_component).
% State the fact: GO term 'go_0005737' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0005737, cellular_component).
% State the fact: GO term 'go_0005739' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0005739, cellular_component).
% State the fact: GO term 'go_0005694' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0005694, cellular_component).
% State the fact: GO term 'go_0005654' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0005654, cellular_component).
% State the fact: GO term 'go_0005829' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0005829, cellular_component).
% State the fact: GO term 'go_0016020' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0016020, cellular_component).
% State the fact: GO term 'go_0005886' belongs to the 'cellular_component' sub-ontology.
go_sub_ontology(go_0005886, cellular_component).

% ---------------------------------------------------------------------------
% Taxonomic backbone — go_is_a(+Child, +Parent)
% Child inherits all properties of Parent (transitive)
% ---------------------------------------------------------------------------

% BIOLOGICAL PROCESS IS_A HIERARCHY

% State the fact: 'cellular_process' is a kind of 'biological_process'.
go_is_a(go_0009987, go_0008150).
% State the fact: 'metabolic_process' is a kind of 'biological_process'.
go_is_a(go_0008152, go_0008150).
% State the fact: 'cell_cycle' is a kind of 'cellular_process'.
go_is_a(go_0007049, go_0009987).
% State the fact: 'signal_transduction' is a kind of 'cellular_process'.
go_is_a(go_0007165, go_0009987).
% State the fact: 'apoptotic_process' is a kind of 'cellular_process'.
go_is_a(go_0006915, go_0009987).
% State the fact: 'dna_metabolic_process' is a kind of 'metabolic_process'.
go_is_a(go_0006259, go_0008152).
% State the fact: 'dna_repair' is a kind of 'dna_metabolic_process'.
go_is_a(go_0006281, go_0006259).
% State the fact: 'carbohydrate_metabolic_process' is a kind of 'metabolic_process'.
go_is_a(go_0005975, go_0008152).
% State the fact: 'glycolytic_process' is a kind of 'carbohydrate_metabolic_process'.
go_is_a(go_0006096, go_0005975).
% State the fact: 'cell_division' is a kind of 'cellular_process'.
go_is_a(go_0051301, go_0009987).
% State the fact: 'dna_damage_checkpoint' is a kind of 'cell_cycle'.
go_is_a(go_0000077, go_0007049).
% State the fact: 'regulation_of_apoptotic_process' is a kind of 'biological_process'.
go_is_a(go_0042981, go_0008150).
% State the fact: 'negative_regulation_of_cell_cycle' is a kind of 'biological_process'.
go_is_a(go_0045786, go_0008150).

% MOLECULAR FUNCTION IS_A HIERARCHY

% State the fact: 'catalytic_activity' is a kind of 'molecular_function'.
go_is_a(go_0003824, go_0003674).
% State the fact: 'hydrolase_activity' is a kind of 'catalytic_activity'.
go_is_a(go_0016787, go_0003824).
% State the fact: 'kinase_activity' is a kind of 'catalytic_activity'.
go_is_a(go_0016301, go_0003824).
% State the fact: 'protein_kinase_activity' is a kind of 'kinase_activity'.
go_is_a(go_0004672, go_0016301).
% State the fact: 'protein_tyrosine_kinase_activity' is a kind of 'protein_kinase_activity'.
go_is_a(go_0004713, go_0004672).
% State the fact: 'dna_binding' is a kind of 'molecular_function'.
go_is_a(go_0003677, go_0003674).
% State the fact: 'dna_binding_transcription_factor_activity' is a kind of 'dna_binding'.
go_is_a(go_0003700, go_0003677).
% State the fact: 'microtubule_binding' is a kind of 'molecular_function'.
go_is_a(go_0008017, go_0003674).
% State the fact: 'protein_binding' is a kind of 'molecular_function'.
go_is_a(go_0005515, go_0003674).
% State the fact: 'protein_tyrosine_phosphatase_activity' is a kind of 'hydrolase_activity'.
go_is_a(go_0004725, go_0016787).

% CELLULAR COMPONENT IS_A HIERARCHY

% State the fact: 'cell' is a kind of 'cellular_component'.
go_is_a(go_0005623, go_0005575).
% State the fact: 'intracellular_anatomical_structure' is a kind of 'cellular_component'.
go_is_a(go_0005622, go_0005575).
% State the fact: 'nucleus' is a kind of 'intracellular_anatomical_structure'.
go_is_a(go_0005634, go_0005622).
% State the fact: 'cytoplasm' is a kind of 'intracellular_anatomical_structure'.
go_is_a(go_0005737, go_0005622).
% State the fact: 'mitochondrion' is a kind of 'intracellular_anatomical_structure'.
go_is_a(go_0005739, go_0005622).
% State the fact: 'nucleoplasm' is a kind of 'intracellular_anatomical_structure'.
go_is_a(go_0005654, go_0005622).
% State the fact: 'cytosol' is a kind of 'intracellular_anatomical_structure'.
go_is_a(go_0005829, go_0005622).
% State the fact: 'plasma_membrane' is a kind of 'membrane'.
go_is_a(go_0005886, go_0016020).
% State the fact: 'membrane' is a kind of 'cellular_component'.
go_is_a(go_0016020, go_0005575).

% ---------------------------------------------------------------------------
% Part-of relations — go_part_of(+Part, +Whole)
% Part is physically contained within or structurally part of Whole
% ---------------------------------------------------------------------------

% State the fact: 'nucleus' is part of 'cell'.
go_part_of(go_0005634, go_0005623).
% State the fact: 'cytoplasm' is part of 'cell'.
go_part_of(go_0005737, go_0005623).
% State the fact: 'mitochondrion' is part of 'cytoplasm'.
go_part_of(go_0005739, go_0005737).
% State the fact: 'chromosome' is part of 'nucleus'.
go_part_of(go_0005694, go_0005634).
% State the fact: 'nucleoplasm' is part of 'nucleus'.
go_part_of(go_0005654, go_0005634).
% State the fact: 'cytosol' is part of 'cytoplasm'.
go_part_of(go_0005829, go_0005737).
% State the fact: 'plasma_membrane' is part of 'cell'.
go_part_of(go_0005886, go_0005623).

% ---------------------------------------------------------------------------
% Regulatory relations — go_regulates(+Regulator, +Regulated)
% Regulator process modulates the frequency, rate, or extent of Regulated
% ---------------------------------------------------------------------------

% State the fact: 'regulation_of_apoptotic_process' regulates 'apoptotic_process'.
go_regulates(go_0042981, go_0006915).
% State the fact: 'negative_regulation_of_cell_cycle' regulates 'cell_cycle'.
go_regulates(go_0045786, go_0007049).
% State the fact: 'dna_damage_checkpoint' regulates 'cell_cycle'.
go_regulates(go_0000077, go_0007049).

% ---------------------------------------------------------------------------
% Gene annotations — go_annotation(+Gene, +GoTermID, +Evidence)
% Evidence codes: experimental (IDA, IMP, IPI), inferred (ISS, IEA)
% ---------------------------------------------------------------------------

% BRCA1 annotations (breast cancer susceptibility gene 1)
% State the fact: gene 'brca1' is annotated with GO term 'go_0006281' (dna_repair) with experimental evidence.
go_annotation(brca1, go_0006281, experimental).
% State the fact: gene 'brca1' is annotated with GO term 'go_0000077' (dna_damage_checkpoint) with experimental evidence.
go_annotation(brca1, go_0000077, experimental).
% State the fact: gene 'brca1' is annotated with GO term 'go_0005654' (nucleoplasm) with experimental evidence.
go_annotation(brca1, go_0005654, experimental).
% State the fact: gene 'brca1' is annotated with GO term 'go_0003677' (dna_binding) with experimental evidence.
go_annotation(brca1, go_0003677, experimental).

% TP53 annotations (tumor protein p53)
% State the fact: gene 'tp53' is annotated with GO term 'go_0003700' (dna_binding_transcription_factor_activity) with experimental evidence.
go_annotation(tp53, go_0003700, experimental).
% State the fact: gene 'tp53' is annotated with GO term 'go_0042981' (regulation_of_apoptotic_process) with experimental evidence.
go_annotation(tp53, go_0042981, experimental).
% State the fact: gene 'tp53' is annotated with GO term 'go_0045786' (negative_regulation_of_cell_cycle) with experimental evidence.
go_annotation(tp53, go_0045786, experimental).
% State the fact: gene 'tp53' is annotated with GO term 'go_0005654' (nucleoplasm) with experimental evidence.
go_annotation(tp53, go_0005654, experimental).

% EGFR annotations (epidermal growth factor receptor)
% State the fact: gene 'egfr' is annotated with GO term 'go_0004713' (protein_tyrosine_kinase_activity) with experimental evidence.
go_annotation(egfr, go_0004713, experimental).
% State the fact: gene 'egfr' is annotated with GO term 'go_0007165' (signal_transduction) with experimental evidence.
go_annotation(egfr, go_0007165, experimental).
% State the fact: gene 'egfr' is annotated with GO term 'go_0005886' (plasma_membrane) with experimental evidence.
go_annotation(egfr, go_0005886, experimental).
% State the fact: gene 'egfr' is annotated with GO term 'go_0005515' (protein_binding) with experimental evidence.
go_annotation(egfr, go_0005515, experimental).

% PTEN annotations (phosphatase and tensin homolog)
% State the fact: gene 'pten' is annotated with GO term 'go_0004725' (protein_tyrosine_phosphatase_activity) with experimental evidence.
go_annotation(pten, go_0004725, experimental).
% State the fact: gene 'pten' is annotated with GO term 'go_0006259' (dna_metabolic_process) with inferred evidence.
go_annotation(pten, go_0006259, inferred).
% State the fact: gene 'pten' is annotated with GO term 'go_0005737' (cytoplasm) with experimental evidence.
go_annotation(pten, go_0005737, experimental).

% KRAS annotations (KRAS proto-oncogene)
% State the fact: gene 'kras' is annotated with GO term 'go_0007165' (signal_transduction) with experimental evidence.
go_annotation(kras, go_0007165, experimental).
% State the fact: gene 'kras' is annotated with GO term 'go_0005886' (plasma_membrane) with experimental evidence.
go_annotation(kras, go_0005886, experimental).
% State the fact: gene 'kras' is annotated with GO term 'go_0005515' (protein_binding) with experimental evidence.
go_annotation(kras, go_0005515, experimental).

% ---------------------------------------------------------------------------
% Derived predicates — transitive reasoning over GO hierarchy
% ---------------------------------------------------------------------------

% Define a clause for 'go_is_a_chain': base case — direct is_a link, chain has two nodes.
go_is_a_chain(Child, Parent, [Child, Parent]) :-
    % Check whether the GO term 'Child' directly has a go_is_a relation to 'Parent'.
    go_is_a(Child, Parent).
% Define a clause for 'go_is_a_chain': recursive case — follow is_a links transitively.
go_is_a_chain(Child, Ancestor, [Child | Rest]) :-
    % Find the immediate parent of 'Child' in the GO is_a hierarchy.
    go_is_a(Child, Mid),
    % Recursively find the chain from 'Mid' up to 'Ancestor'.
    go_is_a_chain(Mid, Ancestor, Rest).

% Define a clause for 'go_ancestor': succeed when 'Ancestor' is any transitive parent of 'Term'.
go_ancestor(Term, Ancestor) :-
    % Compute the transitive is_a chain from 'Term' to 'Ancestor'.
    go_is_a_chain(Term, Ancestor, _).
