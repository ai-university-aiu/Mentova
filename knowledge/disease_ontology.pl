/*  Mentova — Disease Ontology Knowledge Base (DO Scope)

    A curated subset of the Disease Ontology (DO), loaded into its own scope.
    Covers major disease categories with gene-disease associations linking
    this scope to the Gene Ontology scope.

    Relations used: disease_is_a/2, disease_gene/3, disease_symptom/2.
    Every fact is a node_fact; every answer carries a readable justification.

    Source: Disease Ontology (https://disease-ontology.org)
    This is a hand-curated toy subset for demonstration purposes only.
*/

% Declare this file as the 'disease_ontology' module, making its predicates available to other modules.
:- module(disease_ontology, [
    % Supply 'disease_term/2' as the next argument to the expression above.
    disease_term/2,
    % Supply 'disease_is_a/2' as the next argument to the expression above.
    disease_is_a/2,
    % Supply 'disease_gene/3' as the next argument to the expression above.
    disease_gene/3,
    % Supply 'disease_symptom/2' as the next argument to the expression above.
    disease_symptom/2,
    % Supply 'disease_is_a_chain/3' as the next argument to the expression above.
    disease_is_a_chain/3,
    % Supply 'disease_ancestor/2' as the next argument to the expression above.
    disease_ancestor/2
% Close the expression opened above.
]).

% Allow 'disease_is_a/2' clauses to appear at non-consecutive positions in this file.
:- discontiguous disease_is_a/2.
% Allow 'disease_term/2' clauses to appear at non-consecutive positions in this file.
:- discontiguous disease_term/2.
% Allow 'disease_gene/3' clauses to appear at non-consecutive positions in this file.
:- discontiguous disease_gene/3.

% ---------------------------------------------------------------------------
% Disease Term Registry — disease_term(+ID, +Name)
% ---------------------------------------------------------------------------

% ROOT

% State the fact: the Disease Ontology term 'doid_4' is named 'disease'.
disease_term(doid_4, disease).

% MAJOR DISEASE CATEGORIES

% State the fact: disease term 'doid_7' is named 'disease_of_anatomical_entity'.
disease_term(doid_7,     disease_of_anatomical_entity).
% State the fact: disease term 'doid_14566' is named 'disease_of_cellular_proliferation'.
disease_term(doid_14566, disease_of_cellular_proliferation).
% State the fact: disease term 'doid_150' is named 'disease_of_mental_health'.
disease_term(doid_150,   disease_of_mental_health).
% State the fact: disease term 'doid_0014667' is named 'disease_of_metabolism'.
disease_term(doid_0014667, disease_of_metabolism).
% State the fact: disease term 'doid_630' is named 'genetic_disease'.
disease_term(doid_630,   genetic_disease).

% CANCERS

% State the fact: disease term 'doid_162' is named 'cancer'.
disease_term(doid_162,  cancer).
% State the fact: disease term 'doid_1612' is named 'breast_cancer'.
disease_term(doid_1612, breast_cancer).
% State the fact: disease term 'doid_1781' is named 'thyroid_cancer'.
disease_term(doid_1781, thyroid_cancer).
% State the fact: disease term 'doid_1319' is named 'brain_cancer'.
disease_term(doid_1319, brain_cancer).
% State the fact: disease term 'doid_1324' is named 'lung_cancer'.
disease_term(doid_1324, lung_cancer).
% State the fact: disease term 'doid_9256' is named 'colorectal_cancer'.
disease_term(doid_9256, colorectal_cancer).
% State the fact: disease term 'doid_1793' is named 'pancreatic_cancer'.
disease_term(doid_1793, pancreatic_cancer).
% State the fact: disease term 'doid_3068' is named 'glioblastoma'.
disease_term(doid_3068, glioblastoma).

% NEUROLOGICAL DISORDERS

% State the fact: disease term 'doid_863' is named 'nervous_system_disease'.
disease_term(doid_863,  nervous_system_disease).
% State the fact: disease term 'doid_769' is named 'neuropathy'.
disease_term(doid_769,  neuropathy).
% State the fact: disease term 'doid_12858' is named 'huntingtons_disease'.
disease_term(doid_12858, huntingtons_disease).
% State the fact: disease term 'doid_10652' is named 'alzheimers_disease'.
disease_term(doid_10652, alzheimers_disease).
% State the fact: disease term 'doid_14330' is named 'parkinsons_disease'.
disease_term(doid_14330, parkinsons_disease).

% METABOLIC DISEASES

% State the fact: disease term 'doid_9351' is named 'diabetes_mellitus'.
disease_term(doid_9351, diabetes_mellitus).
% State the fact: disease term 'doid_9352' is named 'type_2_diabetes_mellitus'.
disease_term(doid_9352, type_2_diabetes_mellitus).
% State the fact: disease term 'doid_9744' is named 'type_1_diabetes_mellitus'.
disease_term(doid_9744, type_1_diabetes_mellitus).
% State the fact: disease term 'doid_3146' is named 'lipid_metabolism_disorder'.
disease_term(doid_3146, lipid_metabolism_disorder).

% ---------------------------------------------------------------------------
% Taxonomic backbone — disease_is_a(+Child, +Parent)
% ---------------------------------------------------------------------------

% State the fact: 'disease_of_anatomical_entity' is a kind of 'disease'.
disease_is_a(doid_7,       doid_4).
% State the fact: 'disease_of_cellular_proliferation' is a kind of 'disease'.
disease_is_a(doid_14566,   doid_4).
% State the fact: 'disease_of_mental_health' is a kind of 'disease'.
disease_is_a(doid_150,     doid_4).
% State the fact: 'disease_of_metabolism' is a kind of 'disease'.
disease_is_a(doid_0014667, doid_4).
% State the fact: 'genetic_disease' is a kind of 'disease'.
disease_is_a(doid_630,     doid_4).

% State the fact: 'cancer' is a kind of 'disease_of_cellular_proliferation'.
disease_is_a(doid_162,  doid_14566).
% State the fact: 'breast_cancer' is a kind of 'cancer'.
disease_is_a(doid_1612, doid_162).
% State the fact: 'thyroid_cancer' is a kind of 'cancer'.
disease_is_a(doid_1781, doid_162).
% State the fact: 'brain_cancer' is a kind of 'cancer'.
disease_is_a(doid_1319, doid_162).
% State the fact: 'lung_cancer' is a kind of 'cancer'.
disease_is_a(doid_1324, doid_162).
% State the fact: 'colorectal_cancer' is a kind of 'cancer'.
disease_is_a(doid_9256, doid_162).
% State the fact: 'pancreatic_cancer' is a kind of 'cancer'.
disease_is_a(doid_1793, doid_162).
% State the fact: 'glioblastoma' is a kind of 'brain_cancer'.
disease_is_a(doid_3068, doid_1319).

% State the fact: 'nervous_system_disease' is a kind of 'disease_of_anatomical_entity'.
disease_is_a(doid_863,  doid_7).
% State the fact: 'neuropathy' is a kind of 'nervous_system_disease'.
disease_is_a(doid_769,  doid_863).
% State the fact: 'huntingtons_disease' is a kind of 'nervous_system_disease'.
disease_is_a(doid_12858, doid_863).
% State the fact: 'alzheimers_disease' is a kind of 'nervous_system_disease'.
disease_is_a(doid_10652, doid_863).
% State the fact: 'parkinsons_disease' is a kind of 'nervous_system_disease'.
disease_is_a(doid_14330, doid_863).

% State the fact: 'diabetes_mellitus' is a kind of 'disease_of_metabolism'.
disease_is_a(doid_9351, doid_0014667).
% State the fact: 'type_2_diabetes_mellitus' is a kind of 'diabetes_mellitus'.
disease_is_a(doid_9352, doid_9351).
% State the fact: 'type_1_diabetes_mellitus' is a kind of 'diabetes_mellitus'.
disease_is_a(doid_9744, doid_9351).
% State the fact: 'lipid_metabolism_disorder' is a kind of 'disease_of_metabolism'.
disease_is_a(doid_3146, doid_0014667).

% ---------------------------------------------------------------------------
% Gene-disease associations — disease_gene(+DiseaseID, +Gene, +Evidence)
% Evidence: curated (manually reviewed), inferred (computational)
% ---------------------------------------------------------------------------

% BRCA1 associations
% State the fact: gene 'brca1' is associated with 'breast_cancer' based on curated evidence.
disease_gene(doid_1612, brca1, curated).
% State the fact: gene 'brca1' is associated with 'ovarian_cancer' — mapped to breast_cancer class here.
disease_gene(doid_162,  brca1, curated).

% TP53 associations
% State the fact: gene 'tp53' is associated with 'cancer' (general) based on curated evidence.
disease_gene(doid_162,  tp53, curated).
% State the fact: gene 'tp53' is associated with 'lung_cancer' based on curated evidence.
disease_gene(doid_1324, tp53, curated).
% State the fact: gene 'tp53' is associated with 'colorectal_cancer' based on curated evidence.
disease_gene(doid_9256, tp53, curated).
% State the fact: gene 'tp53' is associated with 'breast_cancer' based on curated evidence.
disease_gene(doid_1612, tp53, curated).

% EGFR associations
% State the fact: gene 'egfr' is associated with 'lung_cancer' based on curated evidence.
disease_gene(doid_1324, egfr, curated).
% State the fact: gene 'egfr' is associated with 'glioblastoma' based on curated evidence.
disease_gene(doid_3068, egfr, curated).
% State the fact: gene 'egfr' is associated with 'colorectal_cancer' based on inferred evidence.
disease_gene(doid_9256, egfr, inferred).

% PTEN associations
% State the fact: gene 'pten' is associated with 'cancer' (general) based on curated evidence.
disease_gene(doid_162,  pten, curated).
% State the fact: gene 'pten' is associated with 'breast_cancer' based on curated evidence.
disease_gene(doid_1612, pten, curated).
% State the fact: gene 'pten' is associated with 'glioblastoma' based on curated evidence.
disease_gene(doid_3068, pten, curated).

% KRAS associations
% State the fact: gene 'kras' is associated with 'pancreatic_cancer' based on curated evidence.
disease_gene(doid_1793, kras, curated).
% State the fact: gene 'kras' is associated with 'colorectal_cancer' based on curated evidence.
disease_gene(doid_9256, kras, curated).
% State the fact: gene 'kras' is associated with 'lung_cancer' based on curated evidence.
disease_gene(doid_1324, kras, curated).

% ---------------------------------------------------------------------------
% Symptoms — disease_symptom(+DiseaseID, +Symptom)
% ---------------------------------------------------------------------------

% State the fact: 'breast_cancer' has the symptom 'breast_lump'.
disease_symptom(doid_1612, breast_lump).
% State the fact: 'breast_cancer' has the symptom 'breast_pain'.
disease_symptom(doid_1612, breast_pain).
% State the fact: 'glioblastoma' has the symptom 'headache'.
disease_symptom(doid_3068, headache).
% State the fact: 'glioblastoma' has the symptom 'seizure'.
disease_symptom(doid_3068, seizure).
% State the fact: 'type_2_diabetes_mellitus' has the symptom 'hyperglycemia'.
disease_symptom(doid_9352, hyperglycemia).
% State the fact: 'type_2_diabetes_mellitus' has the symptom 'insulin_resistance'.
disease_symptom(doid_9352, insulin_resistance).
% State the fact: 'alzheimers_disease' has the symptom 'memory_loss'.
disease_symptom(doid_10652, memory_loss).
% State the fact: 'parkinsons_disease' has the symptom 'tremor'.
disease_symptom(doid_14330, tremor).

% ---------------------------------------------------------------------------
% Derived predicates — transitive reasoning over DO hierarchy
% ---------------------------------------------------------------------------

% Define a clause for 'disease_is_a_chain': base case — direct is_a link.
disease_is_a_chain(Child, Parent, [Child, Parent]) :-
    % Check whether 'Child' directly has a disease_is_a relation to 'Parent'.
    disease_is_a(Child, Parent).
% Define a clause for 'disease_is_a_chain': recursive case — follow links transitively.
disease_is_a_chain(Child, Ancestor, [Child | Rest]) :-
    % Find the immediate parent of 'Child' in the disease is_a hierarchy.
    disease_is_a(Child, Mid),
    % Recursively find the chain from 'Mid' up to 'Ancestor'.
    disease_is_a_chain(Mid, Ancestor, Rest).

% Define a clause for 'disease_ancestor': succeed when 'Ancestor' is any transitive parent of 'Term'.
disease_ancestor(Term, Ancestor) :-
    % Compute the transitive is_a chain from 'Term' up to 'Ancestor'.
    disease_is_a_chain(Term, Ancestor, _).
