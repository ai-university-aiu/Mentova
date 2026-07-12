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
% Reference-library source wall_grade13 (word_wall).
ci_source('wall_grade13', '/home/ccaitwo/curriculum/Age_18_to_Age_19_Grade_13_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade14 (word_wall).
ci_source('wall_grade14', '/home/ccaitwo/curriculum/Age_19_to_Age_20_Grade_14_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade15 (word_wall).
ci_source('wall_grade15', '/home/ccaitwo/curriculum/Age_20_to_Age_21_Grade_15_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade16 (word_wall).
ci_source('wall_grade16', '/home/ccaitwo/curriculum/Age_21_to_Age_22_Grade_16_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade17 (word_wall).
ci_source('wall_grade17', '/home/ccaitwo/curriculum/Age_22_to_Age_23_Grade_17_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade18 (word_wall).
ci_source('wall_grade18', '/home/ccaitwo/curriculum/Age_23_to_Age_24_Grade_18_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade19 (word_wall).
ci_source('wall_grade19', '/home/ccaitwo/curriculum/Age_24_to_Age_25_Grade_19_Rosetta_Rock_Word_Wall.txt', 'word_wall').
% Reference-library source wall_grade20 (word_wall).
ci_source('wall_grade20', '/home/ccaitwo/curriculum/Age_25_to_Age_26_Grade_20_Rosetta_Rock_Word_Wall.txt', 'word_wall').
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
% Reference-library source rosetta_rock_build_report (report).
ci_source('rosetta_rock_build_report', '/home/ccaitwo/curriculum/Age_02_to_Age_26_Rosetta_Rock_Series_Build_Report.txt', 'report').
% Reference-library source engageny_corpus_manifest (corpus_manifest).
ci_source('engageny_corpus_manifest', '/home/ccaitwo/curriculum/extracted_text/EngageNY_Corpus_Manifest.txt', 'corpus_manifest').
% Reference-library source engageny_corpus_manifest_middle (corpus_manifest).
ci_source('engageny_corpus_manifest_middle', '/home/ccaitwo/curriculum/extracted_text/EngageNY_Corpus_Manifest_Middle.txt', 'corpus_manifest').
% Reference-library source engageny_corpus_manifest_high (corpus_manifest).
ci_source('engageny_corpus_manifest_high', '/home/ccaitwo/curriculum/extracted_text/EngageNY_Corpus_Manifest_High.txt', 'corpus_manifest').

% ---------------------------------------------------------------------------
% EngageNY/Eureka math FULL-MODULE extracted text (PreK through Grade 5).
% Added 2026-07-12: every elementary math module's full text, so the
% Reference Library can stream and search actual lesson content, not only
% the manifest of file paths. Kind 'full_module_text'. On-disk, out of git.
% ---------------------------------------------------------------------------
% Reference-library source mathfull_gpk_m1 (full_module_text).
ci_source('mathfull_gpk_m1', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_04_to_Age_05_math-gpk-m1-full-module.txt', 'full_module_text').
% Reference-library source mathfull_gpk_m2 (full_module_text).
ci_source('mathfull_gpk_m2', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_04_to_Age_05_Math-GPK-M2-Full-Module.txt', 'full_module_text').
% Reference-library source mathfull_gpk_m3 (full_module_text).
ci_source('mathfull_gpk_m3', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_04_to_Age_05_math-gpk-m3-full-module.txt', 'full_module_text').
% Reference-library source mathfull_gpk_m4 (full_module_text).
ci_source('mathfull_gpk_m4', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_04_to_Age_05_math-gpk-m4-full-module.txt', 'full_module_text').
% Reference-library source mathfull_gpk_m5 (full_module_text).
ci_source('mathfull_gpk_m5', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_04_to_Age_05_math-gpk-m5-full-module.txt', 'full_module_text').
% Reference-library source mathfull_gk_m1 (full_module_text).
ci_source('mathfull_gk_m1', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_05_to_Age_06_math-gk-m1-full-module.txt', 'full_module_text').
% Reference-library source mathfull_gk_m2 (full_module_text).
ci_source('mathfull_gk_m2', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_05_to_Age_06_Math-GK-M2-Full-Module.txt', 'full_module_text').
% Reference-library source mathfull_gk_m3 (full_module_text).
ci_source('mathfull_gk_m3', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_05_to_Age_06_math-gk-m3-full-module.txt', 'full_module_text').
% Reference-library source mathfull_gk_m4 (full_module_text).
ci_source('mathfull_gk_m4', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_05_to_Age_06_math-gk-m4-full-module.txt', 'full_module_text').
% Reference-library source mathfull_gk_m5 (full_module_text).
ci_source('mathfull_gk_m5', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_05_to_Age_06_math-gk-m5-full-module.txt', 'full_module_text').
% Reference-library source mathfull_gk_m6 (full_module_text).
ci_source('mathfull_gk_m6', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_05_to_Age_06_math-gk-m6-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g1_m1 (full_module_text).
ci_source('mathfull_g1_m1', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_06_to_Age_07_math-g1-m1-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g1_m2 (full_module_text).
ci_source('mathfull_g1_m2', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_06_to_Age_07_math-g1-m2-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g1_m3 (full_module_text).
ci_source('mathfull_g1_m3', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_06_to_Age_07_math-g1-m3-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g1_m4 (full_module_text).
ci_source('mathfull_g1_m4', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_06_to_Age_07_math-g1-m4-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g1_m5 (full_module_text).
ci_source('mathfull_g1_m5', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_06_to_Age_07_math-g1-m5-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g1_m6 (full_module_text).
ci_source('mathfull_g1_m6', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_06_to_Age_07_math-g1-m6-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g2_m1 (full_module_text).
ci_source('mathfull_g2_m1', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_07_to_Age_08_Math-G2-M1-Full-Module.txt', 'full_module_text').
% Reference-library source mathfull_g2_m2 (full_module_text).
ci_source('mathfull_g2_m2', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_07_to_Age_08_Math-G2-M2-Full-Module.txt', 'full_module_text').
% Reference-library source mathfull_g2_m3 (full_module_text).
ci_source('mathfull_g2_m3', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_07_to_Age_08_math-g2-m3-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g2_m4 (full_module_text).
ci_source('mathfull_g2_m4', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_07_to_Age_08_math-g2-m4-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g2_m5 (full_module_text).
ci_source('mathfull_g2_m5', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_07_to_Age_08_math-g2-m5-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g2_m6 (full_module_text).
ci_source('mathfull_g2_m6', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_07_to_Age_08_math-g2-m6-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g2_m7 (full_module_text).
ci_source('mathfull_g2_m7', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_07_to_Age_08_math-g2-m7-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g2_m8 (full_module_text).
ci_source('mathfull_g2_m8', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_07_to_Age_08_math-g2-m8-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g3_m1 (full_module_text).
ci_source('mathfull_g3_m1', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_08_to_Age_09_math-g3-m1-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g3_m2 (full_module_text).
ci_source('mathfull_g3_m2', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_08_to_Age_09_math-g3-m2-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g3_m3 (full_module_text).
ci_source('mathfull_g3_m3', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_08_to_Age_09_math-g3-m3-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g3_m4 (full_module_text).
ci_source('mathfull_g3_m4', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_08_to_Age_09_Math-G3-M4-Full-Module.txt', 'full_module_text').
% Reference-library source mathfull_g3_m5 (full_module_text).
ci_source('mathfull_g3_m5', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_08_to_Age_09_math-g3-m5-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g3_m6 (full_module_text).
ci_source('mathfull_g3_m6', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_08_to_Age_09_math-g3-m6-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g3_m7 (full_module_text).
ci_source('mathfull_g3_m7', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_08_to_Age_09_math-g3-m7-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g4_m1 (full_module_text).
ci_source('mathfull_g4_m1', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_09_to_Age_10_math-g4-m1-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g4_m2 (full_module_text).
ci_source('mathfull_g4_m2', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_09_to_Age_10_math-g4-m2-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g4_m3 (full_module_text).
ci_source('mathfull_g4_m3', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_09_to_Age_10_math-g4-m3-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g4_m4 (full_module_text).
ci_source('mathfull_g4_m4', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_09_to_Age_10_math-g4-m4-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g4_m5 (full_module_text).
ci_source('mathfull_g4_m5', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_09_to_Age_10_math-g4-m5-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g4_m6 (full_module_text).
ci_source('mathfull_g4_m6', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_09_to_Age_10_math-g4-m6-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g4_m7 (full_module_text).
ci_source('mathfull_g4_m7', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_09_to_Age_10_math-g4-m7-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g5_m1 (full_module_text).
ci_source('mathfull_g5_m1', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_10_to_Age_11_math-g5-m1-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g5_m2 (full_module_text).
ci_source('mathfull_g5_m2', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_10_to_Age_11_math-g5-m2-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g5_m3 (full_module_text).
ci_source('mathfull_g5_m3', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_10_to_Age_11_math-g5-m3-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g5_m4 (full_module_text).
ci_source('mathfull_g5_m4', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_10_to_Age_11_math-g5-m4-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g5_m5 (full_module_text).
ci_source('mathfull_g5_m5', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_10_to_Age_11_math-g5-m5-full-module.txt', 'full_module_text').
% Reference-library source mathfull_g5_m6 (full_module_text).
ci_source('mathfull_g5_m6', '/home/ccaitwo/curriculum/extracted_text/engageny_math_fullmodule/Age_10_to_Age_11_math-g5-m6-full-module.txt', 'full_module_text').
