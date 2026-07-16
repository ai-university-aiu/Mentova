/*  Mentova — High School Curriculum Understood Facts  (generated data)

    Grades 9 to 12 (ages 14 to 18). Clean, structured curriculum content
    promoted to understood facts for the Causalontology lattice, with a
    source(SourceId, Line) citation on every fact. A separate module from
    the elementary and middle facts so the bands compose without clashing.
    High-school mathematics is organized by conceptual category across the
    9-12 courses (Algebra I, Geometry, Algebra II, Precalculus); its
    domains carry the band label grade9_to_grade12.
    Loaded and anchored into the lattice by curriculum_lattice.pl.
*/

% Declare the generated high-school data predicates.
:- module(curriculum_high_facts, [ci_fact/4, ci_causal_relation_object/5]).

% Allow these facts to be inspected and extended at runtime.
:- dynamic ci_fact/4.
% Allow the sound causal_relation_objects to be inspected and extended at runtime.
:- dynamic ci_causal_relation_object/5.

% ---- Understood facts (node_facts): vocabulary and standards ----
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['elucidate', 'group_1'], source('wall_grade9', 40)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['disparage', 'group_1'], source('wall_grade9', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['bolster', 'group_1'], source('wall_grade9', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['assuage', 'group_1'], source('wall_grade9', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['vindicate', 'group_1'], source('wall_grade9', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['apprehensive', 'group_2'], source('wall_grade9', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['despondent', 'group_2'], source('wall_grade9', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['indignant', 'group_2'], source('wall_grade9', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['circumspect', 'group_2'], source('wall_grade9', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['fastidious', 'group_2'], source('wall_grade9', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['acumen', 'group_3'], source('wall_grade9', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['demeanor', 'group_3'], source('wall_grade9', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['connotation', 'group_3'], source('wall_grade9', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['decorum', 'group_3'], source('wall_grade9', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['antagonist', 'group_3'], source('wall_grade9', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['abhor', 'thinking_and_action_words'], source('wall_grade9', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['admonish', 'thinking_and_action_words'], source('wall_grade9', 85)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['assuage', 'thinking_and_action_words'], source('wall_grade9', 87)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['bolster', 'thinking_and_action_words'], source('wall_grade9', 89)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['chastise', 'thinking_and_action_words'], source('wall_grade9', 91)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['condescend', 'thinking_and_action_words'], source('wall_grade9', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['conciliate', 'thinking_and_action_words'], source('wall_grade9', 95)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['debilitate', 'thinking_and_action_words'], source('wall_grade9', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['deplore', 'thinking_and_action_words'], source('wall_grade9', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['deride', 'thinking_and_action_words'], source('wall_grade9', 101)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['disparage', 'thinking_and_action_words'], source('wall_grade9', 103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['disseminate', 'thinking_and_action_words'], source('wall_grade9', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['elucidate', 'thinking_and_action_words'], source('wall_grade9', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['enervate', 'thinking_and_action_words'], source('wall_grade9', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['exacerbate', 'thinking_and_action_words'], source('wall_grade9', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['obfuscate', 'thinking_and_action_words'], source('wall_grade9', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['placate', 'thinking_and_action_words'], source('wall_grade9', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['vindicate', 'thinking_and_action_words'], source('wall_grade9', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['amorphous', 'describing_words'], source('wall_grade9', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['apprehensive', 'describing_words'], source('wall_grade9', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['assiduous', 'describing_words'], source('wall_grade9', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['banal', 'describing_words'], source('wall_grade9', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['capricious', 'describing_words'], source('wall_grade9', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['caustic', 'describing_words'], source('wall_grade9', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['circumspect', 'describing_words'], source('wall_grade9', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['clandestine', 'describing_words'], source('wall_grade9', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['colloquial', 'describing_words'], source('wall_grade9', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['copious', 'describing_words'], source('wall_grade9', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['cryptic', 'describing_words'], source('wall_grade9', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['culpable', 'describing_words'], source('wall_grade9', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['despondent', 'describing_words'], source('wall_grade9', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['didactic', 'describing_words'], source('wall_grade9', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['diffident', 'describing_words'], source('wall_grade9', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ebullient', 'describing_words'], source('wall_grade9', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['eclectic', 'describing_words'], source('wall_grade9', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['egregious', 'describing_words'], source('wall_grade9', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['erudite', 'describing_words'], source('wall_grade9', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['esoteric', 'describing_words'], source('wall_grade9', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['fastidious', 'describing_words'], source('wall_grade9', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['fortuitous', 'describing_words'], source('wall_grade9', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['garrulous', 'describing_words'], source('wall_grade9', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['grandiose', 'describing_words'], source('wall_grade9', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['hapless', 'describing_words'], source('wall_grade9', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['impetuous', 'describing_words'], source('wall_grade9', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['impervious', 'describing_words'], source('wall_grade9', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['indignant', 'describing_words'], source('wall_grade9', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['acumen', 'naming_words'], source('wall_grade9', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['affinity', 'naming_words'], source('wall_grade9', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['alacrity', 'naming_words'], source('wall_grade9', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['antagonist', 'naming_words'], source('wall_grade9', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['brevity', 'naming_words'], source('wall_grade9', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['cacophony', 'naming_words'], source('wall_grade9', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['connotation', 'naming_words'], source('wall_grade9', 191)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['consternation', 'naming_words'], source('wall_grade9', 193)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['decorum', 'naming_words'], source('wall_grade9', 195)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['deference', 'naming_words'], source('wall_grade9', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['demeanor', 'naming_words'], source('wall_grade9', 199)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['diatribe', 'naming_words'], source('wall_grade9', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['euphemism', 'naming_words'], source('wall_grade9', 203)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['hegemony', 'naming_words'], source('wall_grade9', 205)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['idiosyncrasy', 'naming_words'], source('wall_grade9', 207)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ergo', 'connecting_words'], source('wall_grade9', 211)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['hitherto', 'connecting_words'], source('wall_grade9', 213)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ostensibly', 'connecting_words'], source('wall_grade9', 215)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['abdicate', 'persuasion_words'], source('wall_grade9', 586)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['aberrant', 'persuasion_words'], source('wall_grade9', 588)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['abscond', 'persuasion_words'], source('wall_grade9', 590)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['abstruse', 'persuasion_words'], source('wall_grade9', 592)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['acerbic', 'persuasion_words'], source('wall_grade9', 594)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['acquiesce', 'persuasion_words'], source('wall_grade9', 596)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['admonition', 'persuasion_words'], source('wall_grade9', 598)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['adroit', 'persuasion_words'], source('wall_grade9', 600)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['adulation', 'persuasion_words'], source('wall_grade9', 602)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['adversity', 'persuasion_words'], source('wall_grade9', 604)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['aggrandize', 'persuasion_words'], source('wall_grade9', 606)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['alacrity', 'persuasion_words'], source('wall_grade9', 608)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['amalgamate', 'persuasion_words'], source('wall_grade9', 610)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ambivalence', 'persuasion_words'], source('wall_grade9', 612)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ameliorate', 'persuasion_words'], source('wall_grade9', 614)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['anachronism', 'persuasion_words'], source('wall_grade9', 616)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['antithesis', 'persuasion_words'], source('wall_grade9', 618)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['apocryphal', 'persuasion_words'], source('wall_grade9', 620)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['approbation', 'persuasion_words'], source('wall_grade9', 622)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['arcane', 'persuasion_words'], source('wall_grade9', 624)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['archetype', 'persuasion_words'], source('wall_grade9', 626)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ardor', 'persuasion_words'], source('wall_grade9', 628)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['articulate', 'persuasion_words'], source('wall_grade9', 630)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ascetic', 'persuasion_words'], source('wall_grade9', 632)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['aspersion', 'persuasion_words'], source('wall_grade9', 634)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['assail', 'persuasion_words'], source('wall_grade9', 636)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['assuage', 'persuasion_words'], source('wall_grade9', 638)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['austerity', 'persuasion_words'], source('wall_grade9', 640)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['avarice', 'persuasion_words'], source('wall_grade9', 642)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['beguile', 'persuasion_words'], source('wall_grade9', 644)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['belie', 'persuasion_words'], source('wall_grade9', 646)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['bombastic', 'persuasion_words'], source('wall_grade9', 648)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['bucolic', 'persuasion_words'], source('wall_grade9', 650)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['burgeon', 'persuasion_words'], source('wall_grade9', 652)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['cajole', 'persuasion_words'], source('wall_grade9', 654)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['callous', 'persuasion_words'], source('wall_grade9', 656)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['castigate', 'persuasion_words'], source('wall_grade9', 658)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['circumlocution', 'persuasion_words'], source('wall_grade9', 660)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['cogent', 'persuasion_words'], source('wall_grade9', 662)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['cognizant', 'persuasion_words'], source('wall_grade9', 664)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['commodious', 'persuasion_words'], source('wall_grade9', 666)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['complicity', 'persuasion_words'], source('wall_grade9', 668)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['conflagration', 'persuasion_words'], source('wall_grade9', 670)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['connoisseur', 'persuasion_words'], source('wall_grade9', 672)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['contrite', 'persuasion_words'], source('wall_grade9', 674)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['conundrum', 'persuasion_words'], source('wall_grade9', 676)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['convoluted', 'persuasion_words'], source('wall_grade9', 678)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['craven', 'persuasion_words'], source('wall_grade9', 680)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['demagogue', 'persuasion_words'], source('wall_grade9', 682)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['denigrate', 'persuasion_words'], source('wall_grade9', 684)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['deprecate', 'persuasion_words'], source('wall_grade9', 686)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['despot', 'persuasion_words'], source('wall_grade9', 688)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['diaphanous', 'persuasion_words'], source('wall_grade9', 690)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['dilettante', 'persuasion_words'], source('wall_grade9', 692)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['disabuse', 'persuasion_words'], source('wall_grade9', 694)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['discordant', 'persuasion_words'], source('wall_grade9', 696)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['disparate', 'persuasion_words'], source('wall_grade9', 698)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['dissemble', 'persuasion_words'], source('wall_grade9', 700)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['dogmatic', 'persuasion_words'], source('wall_grade9', 702)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['dubious', 'persuasion_words'], source('wall_grade9', 704)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ebullience', 'persuasion_words'], source('wall_grade9', 706)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['effervescent', 'persuasion_words'], source('wall_grade9', 708)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['effigy', 'persuasion_words'], source('wall_grade9', 710)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['elegy', 'persuasion_words'], source('wall_grade9', 712)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['eloquence', 'persuasion_words'], source('wall_grade9', 714)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['emulate', 'persuasion_words'], source('wall_grade9', 716)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['enmity', 'persuasion_words'], source('wall_grade9', 718)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ennui', 'persuasion_words'], source('wall_grade9', 720)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['epitome', 'persuasion_words'], source('wall_grade9', 722)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['equanimity', 'persuasion_words'], source('wall_grade9', 724)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['equivocate', 'persuasion_words'], source('wall_grade9', 726)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['evanescent', 'persuasion_words'], source('wall_grade9', 728)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['exculpate', 'persuasion_words'], source('wall_grade9', 730)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['extol', 'persuasion_words'], source('wall_grade9', 732)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['facetious', 'persuasion_words'], source('wall_grade9', 734)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['fallacious', 'persuasion_words'], source('wall_grade9', 736)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['fatuous', 'persuasion_words'], source('wall_grade9', 738)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['fecund', 'persuasion_words'], source('wall_grade9', 740)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['felicity', 'persuasion_words'], source('wall_grade9', 742)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['fervor', 'persuasion_words'], source('wall_grade9', 744)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['flippant', 'persuasion_words'], source('wall_grade9', 746)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['forbearance', 'persuasion_words'], source('wall_grade9', 748)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['fractious', 'persuasion_words'], source('wall_grade9', 750)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['gregarious', 'persuasion_words'], source('wall_grade9', 752)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['guile', 'persuasion_words'], source('wall_grade9', 754)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['harangue', 'persuasion_words'], source('wall_grade9', 756)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['iconoclast', 'persuasion_words'], source('wall_grade9', 758)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ignominious', 'persuasion_words'], source('wall_grade9', 760)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['impecunious', 'persuasion_words'], source('wall_grade9', 762)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['imperious', 'persuasion_words'], source('wall_grade9', 764)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['impetus', 'persuasion_words'], source('wall_grade9', 766)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['impugn', 'persuasion_words'], source('wall_grade9', 768)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['inchoate', 'persuasion_words'], source('wall_grade9', 770)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['incontrovertible', 'persuasion_words'], source('wall_grade9', 772)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['indefatigable', 'persuasion_words'], source('wall_grade9', 774)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ineluctable', 'persuasion_words'], source('wall_grade9', 776)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['inexorable', 'persuasion_words'], source('wall_grade9', 778)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['ingenuous', 'persuasion_words'], source('wall_grade9', 780)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['insipid', 'persuasion_words'], source('wall_grade9', 782)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['intransigence', 'persuasion_words'], source('wall_grade9', 784)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9', 'vocabulary', ['inveterate', 'persuasion_words'], source('wall_grade9', 786)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['ameliorate', 'group_1'], source('wall_grade10', 40)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['castigate', 'group_1'], source('wall_grade10', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['extol', 'group_1'], source('wall_grade10', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['emulate', 'group_1'], source('wall_grade10', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['denigrate', 'group_1'], source('wall_grade10', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['cogent', 'group_2'], source('wall_grade10', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['dubious', 'group_2'], source('wall_grade10', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['contrite', 'group_2'], source('wall_grade10', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['callous', 'group_2'], source('wall_grade10', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['ingenuous', 'group_2'], source('wall_grade10', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['adversity', 'group_3'], source('wall_grade10', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['equanimity', 'group_3'], source('wall_grade10', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['antithesis', 'group_3'], source('wall_grade10', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['archetype', 'group_3'], source('wall_grade10', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['conundrum', 'group_3'], source('wall_grade10', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['abdicate', 'thinking_and_action_words'], source('wall_grade10', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['abscond', 'thinking_and_action_words'], source('wall_grade10', 85)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['acquiesce', 'thinking_and_action_words'], source('wall_grade10', 87)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['aggrandize', 'thinking_and_action_words'], source('wall_grade10', 89)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['ameliorate', 'thinking_and_action_words'], source('wall_grade10', 91)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['assail', 'thinking_and_action_words'], source('wall_grade10', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['beguile', 'thinking_and_action_words'], source('wall_grade10', 95)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['belie', 'thinking_and_action_words'], source('wall_grade10', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['burgeon', 'thinking_and_action_words'], source('wall_grade10', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['cajole', 'thinking_and_action_words'], source('wall_grade10', 101)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['castigate', 'thinking_and_action_words'], source('wall_grade10', 103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['denigrate', 'thinking_and_action_words'], source('wall_grade10', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['deprecate', 'thinking_and_action_words'], source('wall_grade10', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['disabuse', 'thinking_and_action_words'], source('wall_grade10', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['dissemble', 'thinking_and_action_words'], source('wall_grade10', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['emulate', 'thinking_and_action_words'], source('wall_grade10', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['equivocate', 'thinking_and_action_words'], source('wall_grade10', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['exculpate', 'thinking_and_action_words'], source('wall_grade10', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['extol', 'thinking_and_action_words'], source('wall_grade10', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['impugn', 'thinking_and_action_words'], source('wall_grade10', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['aberrant', 'describing_words'], source('wall_grade10', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['abstruse', 'describing_words'], source('wall_grade10', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['acerbic', 'describing_words'], source('wall_grade10', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['adroit', 'describing_words'], source('wall_grade10', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['apocryphal', 'describing_words'], source('wall_grade10', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['arcane', 'describing_words'], source('wall_grade10', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['bombastic', 'describing_words'], source('wall_grade10', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['bucolic', 'describing_words'], source('wall_grade10', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['callous', 'describing_words'], source('wall_grade10', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['cogent', 'describing_words'], source('wall_grade10', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['cognizant', 'describing_words'], source('wall_grade10', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['contrite', 'describing_words'], source('wall_grade10', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['convoluted', 'describing_words'], source('wall_grade10', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['craven', 'describing_words'], source('wall_grade10', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['dubious', 'describing_words'], source('wall_grade10', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['facetious', 'describing_words'], source('wall_grade10', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['fallacious', 'describing_words'], source('wall_grade10', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['fatuous', 'describing_words'], source('wall_grade10', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['flippant', 'describing_words'], source('wall_grade10', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['ingenuous', 'describing_words'], source('wall_grade10', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['insipid', 'describing_words'], source('wall_grade10', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['adulation', 'naming_words'], source('wall_grade10', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['adversity', 'naming_words'], source('wall_grade10', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['anachronism', 'naming_words'], source('wall_grade10', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['antithesis', 'naming_words'], source('wall_grade10', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['approbation', 'naming_words'], source('wall_grade10', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['archetype', 'naming_words'], source('wall_grade10', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['avarice', 'naming_words'], source('wall_grade10', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['complicity', 'naming_words'], source('wall_grade10', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['conflagration', 'naming_words'], source('wall_grade10', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['connoisseur', 'naming_words'], source('wall_grade10', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['conundrum', 'naming_words'], source('wall_grade10', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['demagogue', 'naming_words'], source('wall_grade10', 191)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['ennui', 'naming_words'], source('wall_grade10', 193)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['epitome', 'naming_words'], source('wall_grade10', 195)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['equanimity', 'naming_words'], source('wall_grade10', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['fervor', 'naming_words'], source('wall_grade10', 199)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['forbearance', 'naming_words'], source('wall_grade10', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['guile', 'naming_words'], source('wall_grade10', 203)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['abeyance', 'mind_and_mood'], source('wall_grade10', 574)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['abjure', 'mind_and_mood'], source('wall_grade10', 576)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['abnegation', 'mind_and_mood'], source('wall_grade10', 578)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['abrogate', 'mind_and_mood'], source('wall_grade10', 580)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['acumen', 'mind_and_mood'], source('wall_grade10', 582)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['adamant', 'mind_and_mood'], source('wall_grade10', 584)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['admonish', 'mind_and_mood'], source('wall_grade10', 586)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['affable', 'mind_and_mood'], source('wall_grade10', 588)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['alacrity', 'mind_and_mood'], source('wall_grade10', 590)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['amenable', 'mind_and_mood'], source('wall_grade10', 592)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['anathema', 'mind_and_mood'], source('wall_grade10', 594)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['anomalous', 'mind_and_mood'], source('wall_grade10', 596)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['antipathy', 'mind_and_mood'], source('wall_grade10', 598)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['apathetic', 'mind_and_mood'], source('wall_grade10', 600)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['aplomb', 'mind_and_mood'], source('wall_grade10', 602)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['apprise', 'mind_and_mood'], source('wall_grade10', 604)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['approbatory', 'mind_and_mood'], source('wall_grade10', 606)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['arrogate', 'mind_and_mood'], source('wall_grade10', 608)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['ascendancy', 'mind_and_mood'], source('wall_grade10', 610)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['asperity', 'mind_and_mood'], source('wall_grade10', 612)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['assiduity', 'mind_and_mood'], source('wall_grade10', 614)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['assuage', 'mind_and_mood'], source('wall_grade10', 616)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['attenuate', 'mind_and_mood'], source('wall_grade10', 618)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['audacity', 'mind_and_mood'], source('wall_grade10', 620)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['austere', 'mind_and_mood'], source('wall_grade10', 622)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['avuncular', 'mind_and_mood'], source('wall_grade10', 624)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['beatific', 'mind_and_mood'], source('wall_grade10', 626)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['bellicose', 'mind_and_mood'], source('wall_grade10', 628)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['benevolence', 'mind_and_mood'], source('wall_grade10', 630)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['blandishment', 'mind_and_mood'], source('wall_grade10', 632)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['cadence', 'mind_and_mood'], source('wall_grade10', 634)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['calumny', 'mind_and_mood'], source('wall_grade10', 636)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['capitulate', 'mind_and_mood'], source('wall_grade10', 638)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['circumspect', 'mind_and_mood'], source('wall_grade10', 640)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['coalesce', 'mind_and_mood'], source('wall_grade10', 642)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['cognizance', 'mind_and_mood'], source('wall_grade10', 644)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['commodious', 'mind_and_mood'], source('wall_grade10', 646)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['compunction', 'mind_and_mood'], source('wall_grade10', 648)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['conciliatory', 'mind_and_mood'], source('wall_grade10', 650)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['concomitant', 'mind_and_mood'], source('wall_grade10', 652)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['condescension', 'mind_and_mood'], source('wall_grade10', 654)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['confluence', 'mind_and_mood'], source('wall_grade10', 656)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['conjecture', 'mind_and_mood'], source('wall_grade10', 658)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['consummate', 'mind_and_mood'], source('wall_grade10', 660)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['contentious', 'mind_and_mood'], source('wall_grade10', 662)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['contrition', 'mind_and_mood'], source('wall_grade10', 664)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['copious', 'mind_and_mood'], source('wall_grade10', 666)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['corollary', 'mind_and_mood'], source('wall_grade10', 668)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['covenant', 'mind_and_mood'], source('wall_grade10', 670)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['credulous', 'mind_and_mood'], source('wall_grade10', 672)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['cursory', 'mind_and_mood'], source('wall_grade10', 674)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['debacle', 'mind_and_mood'], source('wall_grade10', 676)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['decorous', 'mind_and_mood'], source('wall_grade10', 678)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['deferential', 'mind_and_mood'], source('wall_grade10', 680)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['deleterious', 'mind_and_mood'], source('wall_grade10', 682)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['demure', 'mind_and_mood'], source('wall_grade10', 684)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['denouement', 'mind_and_mood'], source('wall_grade10', 686)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['deride', 'mind_and_mood'], source('wall_grade10', 688)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['desultory', 'mind_and_mood'], source('wall_grade10', 690)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['diffidence', 'mind_and_mood'], source('wall_grade10', 692)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['dilatory', 'mind_and_mood'], source('wall_grade10', 694)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['discomfit', 'mind_and_mood'], source('wall_grade10', 696)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['disconsolate', 'mind_and_mood'], source('wall_grade10', 698)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['discursive', 'mind_and_mood'], source('wall_grade10', 700)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['disingenuous', 'mind_and_mood'], source('wall_grade10', 702)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['disparate', 'mind_and_mood'], source('wall_grade10', 704)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['dispassionate', 'mind_and_mood'], source('wall_grade10', 706)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['disseminate', 'mind_and_mood'], source('wall_grade10', 708)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['dissonance', 'mind_and_mood'], source('wall_grade10', 710)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['docile', 'mind_and_mood'], source('wall_grade10', 712)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['ebullient', 'mind_and_mood'], source('wall_grade10', 714)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['effrontery', 'mind_and_mood'], source('wall_grade10', 716)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['egregious', 'mind_and_mood'], source('wall_grade10', 718)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['elicit', 'mind_and_mood'], source('wall_grade10', 720)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['emollient', 'mind_and_mood'], source('wall_grade10', 722)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['empirical', 'mind_and_mood'], source('wall_grade10', 724)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['enmity', 'mind_and_mood'], source('wall_grade10', 726)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['ephemeral', 'mind_and_mood'], source('wall_grade10', 728)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['equivocal', 'mind_and_mood'], source('wall_grade10', 730)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['ersatz', 'mind_and_mood'], source('wall_grade10', 732)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['eschew', 'mind_and_mood'], source('wall_grade10', 734)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['evanescent', 'mind_and_mood'], source('wall_grade10', 736)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['exigent', 'mind_and_mood'], source('wall_grade10', 738)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['expedient', 'mind_and_mood'], source('wall_grade10', 740)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['expurgate', 'mind_and_mood'], source('wall_grade10', 742)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['extemporaneous', 'mind_and_mood'], source('wall_grade10', 744)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['extricate', 'mind_and_mood'], source('wall_grade10', 746)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['fastidious', 'mind_and_mood'], source('wall_grade10', 748)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['fatuity', 'mind_and_mood'], source('wall_grade10', 750)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['fealty', 'mind_and_mood'], source('wall_grade10', 752)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['feckless', 'mind_and_mood'], source('wall_grade10', 754)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['felicitous', 'mind_and_mood'], source('wall_grade10', 756)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['fervid', 'mind_and_mood'], source('wall_grade10', 758)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['fortitude', 'mind_and_mood'], source('wall_grade10', 760)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['fractious', 'mind_and_mood'], source('wall_grade10', 762)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['furtive', 'mind_and_mood'], source('wall_grade10', 764)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['gainsay', 'mind_and_mood'], source('wall_grade10', 766)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['garish', 'mind_and_mood'], source('wall_grade10', 768)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['germane', 'mind_and_mood'], source('wall_grade10', 770)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade10', 'vocabulary', ['grandiloquent', 'mind_and_mood'], source('wall_grade10', 772)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['eschew', 'group_1'], source('wall_grade11', 40)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['extricate', 'group_1'], source('wall_grade11', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['capitulate', 'group_1'], source('wall_grade11', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['coalesce', 'group_1'], source('wall_grade11', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['attenuate', 'group_1'], source('wall_grade11', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['contentious', 'group_2'], source('wall_grade11', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['disingenuous', 'group_2'], source('wall_grade11', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['germane', 'group_2'], source('wall_grade11', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['exigent', 'group_2'], source('wall_grade11', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['dispassionate', 'group_2'], source('wall_grade11', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['aplomb', 'group_3'], source('wall_grade11', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['fortitude', 'group_3'], source('wall_grade11', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['debacle', 'group_3'], source('wall_grade11', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['denouement', 'group_3'], source('wall_grade11', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['enmity', 'group_3'], source('wall_grade11', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['abjure', 'thinking_and_action_words'], source('wall_grade11', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['abrogate', 'thinking_and_action_words'], source('wall_grade11', 85)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['apprise', 'thinking_and_action_words'], source('wall_grade11', 87)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['arrogate', 'thinking_and_action_words'], source('wall_grade11', 89)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['attenuate', 'thinking_and_action_words'], source('wall_grade11', 91)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['capitulate', 'thinking_and_action_words'], source('wall_grade11', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['coalesce', 'thinking_and_action_words'], source('wall_grade11', 95)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['conjecture', 'thinking_and_action_words'], source('wall_grade11', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['discomfit', 'thinking_and_action_words'], source('wall_grade11', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['eschew', 'thinking_and_action_words'], source('wall_grade11', 101)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['expurgate', 'thinking_and_action_words'], source('wall_grade11', 103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['extricate', 'thinking_and_action_words'], source('wall_grade11', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['gainsay', 'thinking_and_action_words'], source('wall_grade11', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['vex', 'thinking_and_action_words'], source('wall_grade11', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['anomalous', 'describing_words'], source('wall_grade11', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['bellicose', 'describing_words'], source('wall_grade11', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['concomitant', 'describing_words'], source('wall_grade11', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['contentious', 'describing_words'], source('wall_grade11', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['credulous', 'describing_words'], source('wall_grade11', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['cursory', 'describing_words'], source('wall_grade11', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['decorous', 'describing_words'], source('wall_grade11', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['deferential', 'describing_words'], source('wall_grade11', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['desultory', 'describing_words'], source('wall_grade11', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['dilatory', 'describing_words'], source('wall_grade11', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['discursive', 'describing_words'], source('wall_grade11', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['disingenuous', 'describing_words'], source('wall_grade11', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['dispassionate', 'describing_words'], source('wall_grade11', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['ersatz', 'describing_words'], source('wall_grade11', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['exigent', 'describing_words'], source('wall_grade11', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['expedient', 'describing_words'], source('wall_grade11', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['feckless', 'describing_words'], source('wall_grade11', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['felicitous', 'describing_words'], source('wall_grade11', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['fervid', 'describing_words'], source('wall_grade11', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['fractious', 'describing_words'], source('wall_grade11', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['furtive', 'describing_words'], source('wall_grade11', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['garish', 'describing_words'], source('wall_grade11', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['germane', 'describing_words'], source('wall_grade11', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['grandiloquent', 'describing_words'], source('wall_grade11', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['aplomb', 'naming_words'], source('wall_grade11', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['asperity', 'naming_words'], source('wall_grade11', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['cadence', 'naming_words'], source('wall_grade11', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['calumny', 'naming_words'], source('wall_grade11', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['confluence', 'naming_words'], source('wall_grade11', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['corollary', 'naming_words'], source('wall_grade11', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['covenant', 'naming_words'], source('wall_grade11', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['debacle', 'naming_words'], source('wall_grade11', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['denouement', 'naming_words'], source('wall_grade11', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['dissonance', 'naming_words'], source('wall_grade11', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['effrontery', 'naming_words'], source('wall_grade11', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['enmity', 'naming_words'], source('wall_grade11', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['fortitude', 'naming_words'], source('wall_grade11', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['abstemious', 'composure_words'], source('wall_grade11', 556)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['acerbity', 'composure_words'], source('wall_grade11', 558)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['acrimony', 'composure_words'], source('wall_grade11', 560)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['adjuration', 'composure_words'], source('wall_grade11', 562)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['adumbrate', 'composure_words'], source('wall_grade11', 564)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['aggrandizement', 'composure_words'], source('wall_grade11', 566)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['alacritous', 'composure_words'], source('wall_grade11', 568)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['amalgam', 'composure_words'], source('wall_grade11', 570)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['ameliorative', 'composure_words'], source('wall_grade11', 572)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['anathematize', 'composure_words'], source('wall_grade11', 574)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['animadversion', 'composure_words'], source('wall_grade11', 576)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['antediluvian', 'composure_words'], source('wall_grade11', 578)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['apostasy', 'composure_words'], source('wall_grade11', 580)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['apotheosis', 'composure_words'], source('wall_grade11', 582)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['approbatory', 'composure_words'], source('wall_grade11', 584)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['arrant', 'composure_words'], source('wall_grade11', 586)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['articulacy', 'composure_words'], source('wall_grade11', 588)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['asseverate', 'composure_words'], source('wall_grade11', 590)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['atavistic', 'composure_words'], source('wall_grade11', 592)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['attenuation', 'composure_words'], source('wall_grade11', 594)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['avaricious', 'composure_words'], source('wall_grade11', 596)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['axiomatic', 'composure_words'], source('wall_grade11', 598)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['beatitude', 'composure_words'], source('wall_grade11', 600)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['bowdlerize', 'composure_words'], source('wall_grade11', 602)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['cantankerous', 'composure_words'], source('wall_grade11', 604)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['captious', 'composure_words'], source('wall_grade11', 606)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['castigation', 'composure_words'], source('wall_grade11', 608)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['catharsis', 'composure_words'], source('wall_grade11', 610)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['caustically', 'composure_words'], source('wall_grade11', 612)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['circumlocutory', 'composure_words'], source('wall_grade11', 614)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['cognoscenti', 'composure_words'], source('wall_grade11', 616)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['comestible', 'composure_words'], source('wall_grade11', 618)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['commensurable', 'composure_words'], source('wall_grade11', 620)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['complaisant', 'composure_words'], source('wall_grade11', 622)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['comportment', 'composure_words'], source('wall_grade11', 624)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['concatenation', 'composure_words'], source('wall_grade11', 626)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['conflagrant', 'composure_words'], source('wall_grade11', 628)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['connubial', 'composure_words'], source('wall_grade11', 630)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['consanguine', 'composure_words'], source('wall_grade11', 632)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['contumacious', 'composure_words'], source('wall_grade11', 634)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['countervail', 'composure_words'], source('wall_grade11', 636)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['craven', 'composure_words'], source('wall_grade11', 638)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['declivity', 'composure_words'], source('wall_grade11', 640)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['deleterious', 'composure_words'], source('wall_grade11', 642)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['demagoguery', 'composure_words'], source('wall_grade11', 644)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['denigration', 'composure_words'], source('wall_grade11', 646)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['depredation', 'composure_words'], source('wall_grade11', 648)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['desuetude', 'composure_words'], source('wall_grade11', 650)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['diaphanous', 'composure_words'], source('wall_grade11', 652)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['diffidence', 'composure_words'], source('wall_grade11', 654)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['disputatious', 'composure_words'], source('wall_grade11', 656)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['disquisition', 'composure_words'], source('wall_grade11', 658)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['dissemblance', 'composure_words'], source('wall_grade11', 660)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['dithyrambic', 'composure_words'], source('wall_grade11', 662)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['ebullition', 'composure_words'], source('wall_grade11', 664)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['effulgent', 'composure_words'], source('wall_grade11', 666)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['egalitarian', 'composure_words'], source('wall_grade11', 668)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['elegiac', 'composure_words'], source('wall_grade11', 670)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['emolument', 'composure_words'], source('wall_grade11', 672)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['encomium', 'composure_words'], source('wall_grade11', 674)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['endemic', 'composure_words'], source('wall_grade11', 676)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['ennoble', 'composure_words'], source('wall_grade11', 678)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['ephemerality', 'composure_words'], source('wall_grade11', 680)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['epicurean', 'composure_words'], source('wall_grade11', 682)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['equivocation', 'composure_words'], source('wall_grade11', 684)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['ersatz', 'composure_words'], source('wall_grade11', 686)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['eruditeness', 'composure_words'], source('wall_grade11', 688)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['evanescence', 'composure_words'], source('wall_grade11', 690)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['excoriate', 'composure_words'], source('wall_grade11', 692)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['execrable', 'composure_words'], source('wall_grade11', 694)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['exegesis', 'composure_words'], source('wall_grade11', 696)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['expatiate', 'composure_words'], source('wall_grade11', 698)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['extemporize', 'composure_words'], source('wall_grade11', 700)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['fastidiousness', 'composure_words'], source('wall_grade11', 702)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['fatuousness', 'composure_words'], source('wall_grade11', 704)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['fecundity', 'composure_words'], source('wall_grade11', 706)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['feigned', 'composure_words'], source('wall_grade11', 708)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['fervency', 'composure_words'], source('wall_grade11', 710)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['flagitious', 'composure_words'], source('wall_grade11', 712)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['forbearing', 'composure_words'], source('wall_grade11', 714)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['fulminate', 'composure_words'], source('wall_grade11', 716)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['gasconade', 'composure_words'], source('wall_grade11', 718)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['grandiosity', 'composure_words'], source('wall_grade11', 720)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['gregariousness', 'composure_words'], source('wall_grade11', 722)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['harangue', 'composure_words'], source('wall_grade11', 724)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['hauteur', 'composure_words'], source('wall_grade11', 726)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['hebetude', 'composure_words'], source('wall_grade11', 728)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['hegemonic', 'composure_words'], source('wall_grade11', 730)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['heterodox', 'composure_words'], source('wall_grade11', 732)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['iconoclasm', 'composure_words'], source('wall_grade11', 734)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['idiosyncratic', 'composure_words'], source('wall_grade11', 736)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['ignominy', 'composure_words'], source('wall_grade11', 738)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['imbroglio', 'composure_words'], source('wall_grade11', 740)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['immutable', 'composure_words'], source('wall_grade11', 742)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['impecuniosity', 'composure_words'], source('wall_grade11', 744)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['imperturbable', 'composure_words'], source('wall_grade11', 746)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['impingement', 'composure_words'], source('wall_grade11', 748)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['importunate', 'composure_words'], source('wall_grade11', 750)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['inchoate', 'composure_words'], source('wall_grade11', 752)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade11', 'vocabulary', ['incontrovertibly', 'composure_words'], source('wall_grade11', 754)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['obviate', 'group_1'], source('wall_grade12', 40)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['promulgate', 'group_1'], source('wall_grade12', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['excoriate', 'group_1'], source('wall_grade12', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['fulminate', 'group_1'], source('wall_grade12', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['countervail', 'group_1'], source('wall_grade12', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['sagacious', 'group_2'], source('wall_grade12', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['inexorable', 'group_2'], source('wall_grade12', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['ubiquitous', 'group_2'], source('wall_grade12', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['obdurate', 'group_2'], source('wall_grade12', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['perfidious', 'group_2'], source('wall_grade12', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['acrimony', 'group_3'], source('wall_grade12', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['catharsis', 'group_3'], source('wall_grade12', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['ignominy', 'group_3'], source('wall_grade12', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['panacea', 'group_3'], source('wall_grade12', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['turpitude', 'group_3'], source('wall_grade12', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['adumbrate', 'thinking_and_action_words'], source('wall_grade12', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['anathematize', 'thinking_and_action_words'], source('wall_grade12', 85)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['asseverate', 'thinking_and_action_words'], source('wall_grade12', 87)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['bowdlerize', 'thinking_and_action_words'], source('wall_grade12', 89)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['countervail', 'thinking_and_action_words'], source('wall_grade12', 91)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['excoriate', 'thinking_and_action_words'], source('wall_grade12', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['expatiate', 'thinking_and_action_words'], source('wall_grade12', 95)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['extemporize', 'thinking_and_action_words'], source('wall_grade12', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['fulminate', 'thinking_and_action_words'], source('wall_grade12', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['importune', 'thinking_and_action_words'], source('wall_grade12', 101)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['inveigh', 'thinking_and_action_words'], source('wall_grade12', 103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['obviate', 'thinking_and_action_words'], source('wall_grade12', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['promulgate', 'thinking_and_action_words'], source('wall_grade12', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['proscribe', 'thinking_and_action_words'], source('wall_grade12', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['vituperate', 'thinking_and_action_words'], source('wall_grade12', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['abstemious', 'describing_words'], source('wall_grade12', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['antediluvian', 'describing_words'], source('wall_grade12', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['arrant', 'describing_words'], source('wall_grade12', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['atavistic', 'describing_words'], source('wall_grade12', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['axiomatic', 'describing_words'], source('wall_grade12', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['cantankerous', 'describing_words'], source('wall_grade12', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['captious', 'describing_words'], source('wall_grade12', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['complaisant', 'describing_words'], source('wall_grade12', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['contumacious', 'describing_words'], source('wall_grade12', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['endemic', 'describing_words'], source('wall_grade12', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['execrable', 'describing_words'], source('wall_grade12', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['heterodox', 'describing_words'], source('wall_grade12', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['immutable', 'describing_words'], source('wall_grade12', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['imperturbable', 'describing_words'], source('wall_grade12', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['inexorable', 'describing_words'], source('wall_grade12', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['inveterate', 'describing_words'], source('wall_grade12', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['mordant', 'describing_words'], source('wall_grade12', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['multifarious', 'describing_words'], source('wall_grade12', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['obdurate', 'describing_words'], source('wall_grade12', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['perfidious', 'describing_words'], source('wall_grade12', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['sagacious', 'describing_words'], source('wall_grade12', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['sanguine', 'describing_words'], source('wall_grade12', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['truculent', 'describing_words'], source('wall_grade12', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['ubiquitous', 'describing_words'], source('wall_grade12', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['acrimony', 'naming_words'], source('wall_grade12', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['apostasy', 'naming_words'], source('wall_grade12', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['apotheosis', 'naming_words'], source('wall_grade12', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['catharsis', 'naming_words'], source('wall_grade12', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['encomium', 'naming_words'], source('wall_grade12', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['hauteur', 'naming_words'], source('wall_grade12', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['ignominy', 'naming_words'], source('wall_grade12', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['imbroglio', 'naming_words'], source('wall_grade12', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['panacea', 'naming_words'], source('wall_grade12', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['sycophant', 'naming_words'], source('wall_grade12', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['turpitude', 'naming_words'], source('wall_grade12', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['verisimilitude', 'naming_words'], source('wall_grade12', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['abnegate', 'literature_and_rhetoric'], source('wall_grade12', 554)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['abrogation', 'literature_and_rhetoric'], source('wall_grade12', 556)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['acerbic', 'literature_and_rhetoric'], source('wall_grade12', 558)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['acquisitive', 'literature_and_rhetoric'], source('wall_grade12', 560)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['adjure', 'literature_and_rhetoric'], source('wall_grade12', 562)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['adventitious', 'literature_and_rhetoric'], source('wall_grade12', 564)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['afflatus', 'literature_and_rhetoric'], source('wall_grade12', 566)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['aggrandize', 'literature_and_rhetoric'], source('wall_grade12', 568)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['alacritous', 'literature_and_rhetoric'], source('wall_grade12', 570)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['animadvert', 'literature_and_rhetoric'], source('wall_grade12', 572)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['antinomy', 'literature_and_rhetoric'], source('wall_grade12', 574)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['apogee', 'literature_and_rhetoric'], source('wall_grade12', 576)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['apothegm', 'literature_and_rhetoric'], source('wall_grade12', 578)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['approbative', 'literature_and_rhetoric'], source('wall_grade12', 580)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['arrogate', 'literature_and_rhetoric'], source('wall_grade12', 582)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['ascetic', 'literature_and_rhetoric'], source('wall_grade12', 584)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['asperse', 'literature_and_rhetoric'], source('wall_grade12', 586)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['assiduous', 'literature_and_rhetoric'], source('wall_grade12', 588)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['atrabilious', 'literature_and_rhetoric'], source('wall_grade12', 590)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['augury', 'literature_and_rhetoric'], source('wall_grade12', 592)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['auspicious', 'literature_and_rhetoric'], source('wall_grade12', 594)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['avuncular', 'literature_and_rhetoric'], source('wall_grade12', 596)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['bellicosity', 'literature_and_rhetoric'], source('wall_grade12', 598)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['beneficence', 'literature_and_rhetoric'], source('wall_grade12', 600)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['blandishment', 'literature_and_rhetoric'], source('wall_grade12', 602)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['cacophonous', 'literature_and_rhetoric'], source('wall_grade12', 604)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['calumnious', 'literature_and_rhetoric'], source('wall_grade12', 606)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['castellated', 'literature_and_rhetoric'], source('wall_grade12', 608)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['circumlocution', 'literature_and_rhetoric'], source('wall_grade12', 610)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['cognoscente', 'literature_and_rhetoric'], source('wall_grade12', 612)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['comestibles', 'literature_and_rhetoric'], source('wall_grade12', 614)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['concupiscence', 'literature_and_rhetoric'], source('wall_grade12', 616)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['consanguinity', 'literature_and_rhetoric'], source('wall_grade12', 618)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['contravene', 'literature_and_rhetoric'], source('wall_grade12', 620)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['contumely', 'literature_and_rhetoric'], source('wall_grade12', 622)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['coruscate', 'literature_and_rhetoric'], source('wall_grade12', 624)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['cupidity', 'literature_and_rhetoric'], source('wall_grade12', 626)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['declaim', 'literature_and_rhetoric'], source('wall_grade12', 628)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['deleterious', 'literature_and_rhetoric'], source('wall_grade12', 630)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['demur', 'literature_and_rhetoric'], source('wall_grade12', 632)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['denouement', 'literature_and_rhetoric'], source('wall_grade12', 634)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['deprecatory', 'literature_and_rhetoric'], source('wall_grade12', 636)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['descry', 'literature_and_rhetoric'], source('wall_grade12', 638)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['desiderata', 'literature_and_rhetoric'], source('wall_grade12', 640)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['diaphanous', 'literature_and_rhetoric'], source('wall_grade12', 642)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['diffident', 'literature_and_rhetoric'], source('wall_grade12', 644)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['dirigible', 'literature_and_rhetoric'], source('wall_grade12', 646)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['disabuse', 'literature_and_rhetoric'], source('wall_grade12', 648)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['disquietude', 'literature_and_rhetoric'], source('wall_grade12', 650)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['dissimulate', 'literature_and_rhetoric'], source('wall_grade12', 652)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['dolorous', 'literature_and_rhetoric'], source('wall_grade12', 654)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['ebullient', 'literature_and_rhetoric'], source('wall_grade12', 656)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['effrontery', 'literature_and_rhetoric'], source('wall_grade12', 658)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['effulgence', 'literature_and_rhetoric'], source('wall_grade12', 660)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['egregiousness', 'literature_and_rhetoric'], source('wall_grade12', 662)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['emollient', 'literature_and_rhetoric'], source('wall_grade12', 664)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['encomiastic', 'literature_and_rhetoric'], source('wall_grade12', 666)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['ennoble', 'literature_and_rhetoric'], source('wall_grade12', 668)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['enervation', 'literature_and_rhetoric'], source('wall_grade12', 670)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['epideictic', 'literature_and_rhetoric'], source('wall_grade12', 672)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['epigone', 'literature_and_rhetoric'], source('wall_grade12', 674)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['equanimous', 'literature_and_rhetoric'], source('wall_grade12', 676)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['eschatology', 'literature_and_rhetoric'], source('wall_grade12', 678)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['evanesce', 'literature_and_rhetoric'], source('wall_grade12', 680)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['exculpatory', 'literature_and_rhetoric'], source('wall_grade12', 682)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['execrate', 'literature_and_rhetoric'], source('wall_grade12', 684)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['exigency', 'literature_and_rhetoric'], source('wall_grade12', 686)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['expiate', 'literature_and_rhetoric'], source('wall_grade12', 688)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['extirpate', 'literature_and_rhetoric'], source('wall_grade12', 690)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['fastidious', 'literature_and_rhetoric'], source('wall_grade12', 692)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['fecund', 'literature_and_rhetoric'], source('wall_grade12', 694)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['felicitous', 'literature_and_rhetoric'], source('wall_grade12', 696)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['fissiparous', 'literature_and_rhetoric'], source('wall_grade12', 698)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['fractiousness', 'literature_and_rhetoric'], source('wall_grade12', 700)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['fulsome', 'literature_and_rhetoric'], source('wall_grade12', 702)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['fungible', 'literature_and_rhetoric'], source('wall_grade12', 704)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['garrulity', 'literature_and_rhetoric'], source('wall_grade12', 706)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['grandiloquence', 'literature_and_rhetoric'], source('wall_grade12', 708)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['gravamen', 'literature_and_rhetoric'], source('wall_grade12', 710)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['hagiography', 'literature_and_rhetoric'], source('wall_grade12', 712)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['hebdomadal', 'literature_and_rhetoric'], source('wall_grade12', 714)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['hortatory', 'literature_and_rhetoric'], source('wall_grade12', 716)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['iconoclastic', 'literature_and_rhetoric'], source('wall_grade12', 718)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['ignominious', 'literature_and_rhetoric'], source('wall_grade12', 720)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['imbroglio', 'literature_and_rhetoric'], source('wall_grade12', 722)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['immiscible', 'literature_and_rhetoric'], source('wall_grade12', 724)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['impecunious', 'literature_and_rhetoric'], source('wall_grade12', 726)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['imperious', 'literature_and_rhetoric'], source('wall_grade12', 728)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['impignorate', 'literature_and_rhetoric'], source('wall_grade12', 730)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['imprecation', 'literature_and_rhetoric'], source('wall_grade12', 732)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['inchoate', 'literature_and_rhetoric'], source('wall_grade12', 734)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['incohate', 'literature_and_rhetoric'], source('wall_grade12', 736)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['indefatigable', 'literature_and_rhetoric'], source('wall_grade12', 738)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['ineffable', 'literature_and_rhetoric'], source('wall_grade12', 740)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['ineluctable', 'literature_and_rhetoric'], source('wall_grade12', 742)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['inimical', 'literature_and_rhetoric'], source('wall_grade12', 744)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['insouciant', 'literature_and_rhetoric'], source('wall_grade12', 746)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['internecine', 'literature_and_rhetoric'], source('wall_grade12', 748)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['inveigh', 'literature_and_rhetoric'], source('wall_grade12', 750)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade12', 'vocabulary', ['jejune', 'literature_and_rhetoric'], source('wall_grade12', 752)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['linear, quadratic, and exponential models', 'F-LE'], source('ccss_math', 345)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['the real number system', 'N-RN'], source('ccss_math', 2521)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['seeing structure in expressions', 'A-SSE'], source('ccss_math', 2544)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['arithmetic with polynomials and rational expressions', 'A-APR'], source('ccss_math', 2571)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['creating equations', 'A-CED'], source('ccss_math', 2578)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['reasoning with equations and inequalities', 'A-REI'], source('ccss_math', 2593)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['interpreting functions', 'F-IF'], source('ccss_math', 2633)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['building functions', 'F-BF'], source('ccss_math', 2676)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['interpreting categorical and quantitative data', 'S-ID'], source('ccss_math', 2719)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['congruence', 'G-CO'], source('ccss_math', 2860)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['similarity, right triangles, and trigonometry', 'G-SRT'], source('ccss_math', 2903)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['expressing geometric properties with equations', 'G-GPE'], source('ccss_math', 2958)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['geometric measurement and dimension', 'G-GMD'], source('ccss_math', 2975)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['modeling with geometry', 'G-MG'], source('ccss_math', 2994)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['conditional probability and the rules of probability', 'S-CP'], source('ccss_math', 3006)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['using probability to make decisions', 'S-MD'], source('ccss_math', 3038)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['the complex number system', 'N-CN'], source('ccss_math', 3173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['trigonometric functions', 'F-TF'], source('ccss_math', 3323)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['making inferences and justifying conclusions', 'S-IC'], source('ccss_math', 3359)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'math_domain', ['vector and matrix quantities', 'N-VM'], source('ccss_math', 4777)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'ela_strand', ['writing'], source('ccss_ela', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'ela_strand', ['speaking_and_listening'], source('ccss_ela', 103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'ela_strand', ['language'], source('ccss_ela', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'ela_strand', ['reading_literature'], source('ccss_ela', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade9_to_grade12', 'ela_strand', ['reading_informational_text'], source('ccss_ela', 128)).

% ---- Sound causal_relation_objects: a subject makes a sound (cause -> effect) ----
