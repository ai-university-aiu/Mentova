/*  Mentova — Elementary Curriculum Path Registry

    The path registry of the light-pass curriculum import: it maps each
    Reference-Library SourceId to the ABSOLUTE path of its file on disk.
    curriculum_lattice.pl reads these facts and calls rl_register/2 so
    the streamed reference library and the source(SourceId, Line)
    citations of curriculum_elementary_facts.pl resolve to real lines.

    Kinds:
      word_wall        a clean Rosetta Rock word wall (original .txt)
      standard         an extracted CA standard text (PTKLF / CCSS)
      index            the human-readable curriculum index
      corpus_manifest  the searchable manifest of the bulk EngageNY
                       corpus: one absolute path per lesson document,
                       streamed on demand (NOT text-extracted here)

    The raw 30 GB corpus stays on disk; only this compact registry and
    the understood facts enter git.
*/

% Declare this file as the curriculum path registry module.
:- module(curriculum_path_registry, [ci_source/3, ci_corpus_root/1]).

% The on-disk root of the raw curriculum corpus (kept out of git).
ci_corpus_root('/home/ccaitwo/curriculum').

% ci_source(SourceId, AbsolutePath, Kind): one registrable library source.
% Allow the registry to be inspected and extended at runtime.
:- dynamic ci_source/3.

% Reference-library source wall_toddler (word_wall).
ci_source('wall_toddler', '/home/ccaitwo/curriculum/Age_02_to_Age_03_Toddler_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_preschool (word_wall).
ci_source('wall_preschool', '/home/ccaitwo/curriculum/Age_03_to_Age_04_Preschool_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_tk (word_wall).
ci_source('wall_tk', '/home/ccaitwo/curriculum/Age_04_to_Age_05_TK_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_kindergarten (word_wall).
ci_source('wall_kindergarten', '/home/ccaitwo/curriculum/Age_05_to_Age_06_Kindergarten_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade1 (word_wall).
ci_source('wall_grade1', '/home/ccaitwo/curriculum/Age_06_to_Age_07_Grade_01_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade2 (word_wall).
ci_source('wall_grade2', '/home/ccaitwo/curriculum/Age_07_to_Age_08_Grade_02_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade3 (word_wall).
ci_source('wall_grade3', '/home/ccaitwo/curriculum/Age_08_to_Age_09_Grade_03_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade4 (word_wall).
ci_source('wall_grade4', '/home/ccaitwo/curriculum/Age_09_to_Age_10_Grade_04_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade5 (word_wall).
ci_source('wall_grade5', '/home/ccaitwo/curriculum/Age_10_to_Age_11_Grade_05_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade6 (word_wall).
ci_source('wall_grade6', '/home/ccaitwo/curriculum/Age_11_to_Age_12_Grade_06_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade7 (word_wall).
ci_source('wall_grade7', '/home/ccaitwo/curriculum/Age_12_to_Age_13_Grade_07_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade8 (word_wall).
ci_source('wall_grade8', '/home/ccaitwo/curriculum/Age_13_to_Age_14_Grade_08_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade9 (word_wall).
ci_source('wall_grade9', '/home/ccaitwo/curriculum/Age_14_to_Age_15_Grade_09_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade10 (word_wall).
ci_source('wall_grade10', '/home/ccaitwo/curriculum/Age_15_to_Age_16_Grade_10_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade11 (word_wall).
ci_source('wall_grade11', '/home/ccaitwo/curriculum/Age_16_to_Age_17_Grade_11_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade12 (word_wall).
ci_source('wall_grade12', '/home/ccaitwo/curriculum/Age_17_to_Age_18_Grade_12_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source ccss_math (standard).
ci_source('ccss_math', '/home/ccaitwo/curriculum/extracted_text/Age_05_to_Age_18_CA_CCSS_Mathematics_Standards.txt', 'standard').
% Reference-library source ccss_ela (standard).
ci_source('ccss_ela', '/home/ccaitwo/curriculum/extracted_text/Age_05_to_Age_18_CA_CCSS_ELA_Literacy_Standards.txt', 'standard').
% Reference-library source ptklf_introduction (standard).
ci_source('ptklf_introduction', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_01_Introduction.txt', 'standard').
% Reference-library source ptklf_approaches (standard).
ci_source('ptklf_approaches', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_02_Approaches_to_Learning.txt', 'standard').
% Reference-library source ptklf_social_emot (standard).
ci_source('ptklf_social_emot', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_03_Social_Emotional_Development.txt', 'standard').
% Reference-library source ptklf_language (standard).
ci_source('ptklf_language', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_04_Language_Literacy_Development.txt', 'standard').
% Reference-library source ptklf_math (standard).
ci_source('ptklf_math', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_05_Mathematics.txt', 'standard').
% Reference-library source ptklf_science (standard).
ci_source('ptklf_science', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_06_Science.txt', 'standard').
% Reference-library source ptklf_physical (standard).
ci_source('ptklf_physical', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_07_Physical_Development.txt', 'standard').
% Reference-library source ptklf_health (standard).
ci_source('ptklf_health', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_08_Health.txt', 'standard').
% Reference-library source ptklf_history (standard).
ci_source('ptklf_history', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_09_History_Social_Science.txt', 'standard').
% Reference-library source ptklf_arts (standard).
ci_source('ptklf_arts', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_10_Visual_Performing_Arts.txt', 'standard').
% Reference-library source ptklf_at_a_glance (standard).
ci_source('ptklf_at_a_glance', '/home/ccaitwo/curriculum/extracted_text/Age_03_to_Age_05_CA_PTKLF_11_At_a_Glance.txt', 'standard').
% Reference-library source curriculum_index (index).
ci_source('curriculum_index', '/home/ccaitwo/curriculum/Age_03_to_Age_18_curriculum_index.txt', 'index').
% Reference-library source engageny_corpus_manifest (corpus_manifest).
ci_source('engageny_corpus_manifest', '/home/ccaitwo/curriculum/extracted_text/EngageNY_Corpus_Manifest.txt', 'corpus_manifest').
% Reference-library source engageny_corpus_manifest_middle (corpus_manifest).
ci_source('engageny_corpus_manifest_middle', '/home/ccaitwo/curriculum/extracted_text/EngageNY_Corpus_Manifest_Middle.txt', 'corpus_manifest').
% Reference-library source engageny_corpus_manifest_high (corpus_manifest).
ci_source('engageny_corpus_manifest_high', '/home/ccaitwo/curriculum/extracted_text/EngageNY_Corpus_Manifest_High.txt', 'corpus_manifest').
