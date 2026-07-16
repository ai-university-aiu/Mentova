/*  Mentova — Elementary Curriculum Understood Facts  (generated data)

    Clean, structured curriculum content promoted to understood facts
    for the Causalontology lattice. Each fact carries a source(SourceId,
    LineNo) citation resolvable through the Reference Library, so the
    honest answer to "why?" cites a real, reachable line. Bulk lesson
    corpora are NOT here; they live in the Reference Library.

    Loaded and anchored into the lattice by curriculum_lattice.pl.
    ci_fact(Grade, Relation, Args, source(SourceId, Line)).
    ci_causal_relation_object(Grade, makes_sound, Subject, Sound, source(SourceId, Line)).
*/

% Declare the generated data predicates so a bare load never errors.
:- module(curriculum_elementary_facts, [ci_fact/4, ci_causal_relation_object/5]).

% Allow these facts to be inspected and extended at runtime.
:- dynamic ci_fact/4.
% Allow the sound causal_relation_objects to be inspected and extended at runtime.
:- dynamic ci_causal_relation_object/5.

% ---- Understood facts (node_facts): vocabulary and standards ----
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['mama', 'people'], source('wall_toddler', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['dada', 'people'], source('wall_toddler', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['baby', 'people'], source('wall_toddler', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['me', 'people'], source('wall_toddler', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['you', 'people'], source('wall_toddler', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['more', 'wants'], source('wall_toddler', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['milk', 'wants'], source('wall_toddler', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['eat', 'wants'], source('wall_toddler', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['drink', 'wants'], source('wall_toddler', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['all done', 'wants'], source('wall_toddler', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['go', 'doing'], source('wall_toddler', 76)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['stop', 'doing'], source('wall_toddler', 78)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['up', 'doing'], source('wall_toddler', 80)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['down', 'doing'], source('wall_toddler', 82)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['help', 'doing'], source('wall_toddler', 84)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['hi', 'friendly_words'], source('wall_toddler', 88)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bye', 'friendly_words'], source('wall_toddler', 90)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['yes', 'friendly_words'], source('wall_toddler', 92)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['no', 'friendly_words'], source('wall_toddler', 94)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['please', 'friendly_words'], source('wall_toddler', 96)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['me', 'people_words'], source('wall_toddler', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['you', 'people_words'], source('wall_toddler', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['my', 'people_words'], source('wall_toddler', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['your', 'people_words'], source('wall_toddler', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['we', 'people_words'], source('wall_toddler', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['mama', 'people_words'], source('wall_toddler', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['dada', 'people_words'], source('wall_toddler', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['baby', 'people_words'], source('wall_toddler', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['go', 'doing_words'], source('wall_toddler', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['stop', 'doing_words'], source('wall_toddler', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['up', 'doing_words'], source('wall_toddler', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['down', 'doing_words'], source('wall_toddler', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['run', 'doing_words'], source('wall_toddler', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['jump', 'doing_words'], source('wall_toddler', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['sit', 'doing_words'], source('wall_toddler', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['eat', 'doing_words'], source('wall_toddler', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['drink', 'doing_words'], source('wall_toddler', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['hug', 'doing_words'], source('wall_toddler', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['kiss', 'doing_words'], source('wall_toddler', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['clap', 'doing_words'], source('wall_toddler', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['wave', 'doing_words'], source('wall_toddler', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['stomp', 'doing_words'], source('wall_toddler', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['kick', 'doing_words'], source('wall_toddler', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['throw', 'doing_words'], source('wall_toddler', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['fall', 'doing_words'], source('wall_toddler', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['play', 'doing_words'], source('wall_toddler', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['splash', 'doing_words'], source('wall_toddler', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['help', 'doing_words'], source('wall_toddler', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['says', 'doing_words'], source('wall_toddler', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['hi', 'friendly_and_feeling_words'], source('wall_toddler', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bye', 'friendly_and_feeling_words'], source('wall_toddler', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['yes', 'friendly_and_feeling_words'], source('wall_toddler', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['no', 'friendly_and_feeling_words'], source('wall_toddler', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['please', 'friendly_and_feeling_words'], source('wall_toddler', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['yum', 'friendly_and_feeling_words'], source('wall_toddler', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['yay', 'friendly_and_feeling_words'], source('wall_toddler', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['more', 'friendly_and_feeling_words'], source('wall_toddler', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['all', 'friendly_and_feeling_words'], source('wall_toddler', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['done', 'friendly_and_feeling_words'], source('wall_toddler', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['again', 'friendly_and_feeling_words'], source('wall_toddler', 191)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['night', 'friendly_and_feeling_words'], source('wall_toddler', 193)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['a', 'little_words'], source('wall_toddler', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['an', 'little_words'], source('wall_toddler', 199)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['and', 'little_words'], source('wall_toddler', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['the', 'little_words'], source('wall_toddler', 203)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['is', 'little_words'], source('wall_toddler', 205)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['in', 'little_words'], source('wall_toddler', 207)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['on', 'little_words'], source('wall_toddler', 209)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['to', 'little_words'], source('wall_toddler', 211)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['out', 'little_words'], source('wall_toddler', 213)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['round', 'little_words'], source('wall_toddler', 215)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['where', 'little_words'], source('wall_toddler', 217)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['there', 'little_words'], source('wall_toddler', 219)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['peek', 'peek_a_boo_words'], source('wall_toddler', 223)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['boo', 'peek_a_boo_words'], source('wall_toddler', 225)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['hand', 'body_words'], source('wall_toddler', 229)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['hands', 'body_words'], source('wall_toddler', 231)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['foot', 'body_words'], source('wall_toddler', 233)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['feet', 'body_words'], source('wall_toddler', 235)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['eye', 'body_words'], source('wall_toddler', 237)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['nose', 'body_words'], source('wall_toddler', 239)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['ear', 'body_words'], source('wall_toddler', 241)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['hair', 'body_words'], source('wall_toddler', 243)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['tummy', 'body_words'], source('wall_toddler', 245)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['dog', 'animal_words'], source('wall_toddler', 249)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['cat', 'animal_words'], source('wall_toddler', 251)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['cow', 'animal_words'], source('wall_toddler', 253)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['pig', 'animal_words'], source('wall_toddler', 255)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['duck', 'animal_words'], source('wall_toddler', 257)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['fish', 'animal_words'], source('wall_toddler', 259)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bird', 'animal_words'], source('wall_toddler', 261)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['woof', 'animal_sounds'], source('wall_toddler', 265)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['meow', 'animal_sounds'], source('wall_toddler', 267)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['moo', 'animal_sounds'], source('wall_toddler', 269)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['quack', 'animal_sounds'], source('wall_toddler', 271)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['beep', 'animal_sounds'], source('wall_toddler', 273)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['milk', 'food_and_drink_words'], source('wall_toddler', 277)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['juice', 'food_and_drink_words'], source('wall_toddler', 279)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['water', 'food_and_drink_words'], source('wall_toddler', 281)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['apple', 'food_and_drink_words'], source('wall_toddler', 283)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['banana', 'food_and_drink_words'], source('wall_toddler', 285)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['cookie', 'food_and_drink_words'], source('wall_toddler', 287)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['ball', 'things_words'], source('wall_toddler', 291)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['car', 'things_words'], source('wall_toddler', 293)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['book', 'things_words'], source('wall_toddler', 295)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['cup', 'things_words'], source('wall_toddler', 297)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['shoe', 'things_words'], source('wall_toddler', 299)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['hat', 'things_words'], source('wall_toddler', 301)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bed', 'things_words'], source('wall_toddler', 303)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bath', 'things_words'], source('wall_toddler', 305)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['sun', 'things_words'], source('wall_toddler', 307)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['tree', 'things_words'], source('wall_toddler', 309)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['pajamas', 'things_words'], source('wall_toddler', 311)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['time', 'things_words'], source('wall_toddler', 313)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['big', 'describing_words'], source('wall_toddler', 317)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['little', 'describing_words'], source('wall_toddler', 319)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['hot', 'describing_words'], source('wall_toddler', 321)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['fun', 'describing_words'], source('wall_toddler', 323)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['high', 'describing_words'], source('wall_toddler', 325)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['red', 'describing_words'], source('wall_toddler', 327)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['blue', 'describing_words'], source('wall_toddler', 329)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['one', 'number_words'], source('wall_toddler', 333)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['two', 'number_words'], source('wall_toddler', 335)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['three', 'number_words'], source('wall_toddler', 337)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['ant', 'animals_and_insects'], source('wall_toddler', 761)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bee', 'animals_and_insects'], source('wall_toddler', 763)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bunny', 'animals_and_insects'], source('wall_toddler', 765)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['kitten', 'animals_and_insects'], source('wall_toddler', 767)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['lion', 'animals_and_insects'], source('wall_toddler', 769)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['monkey', 'animals_and_insects'], source('wall_toddler', 771)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['mouse', 'animals_and_insects'], source('wall_toddler', 773)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['owl', 'animals_and_insects'], source('wall_toddler', 775)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['puppy', 'animals_and_insects'], source('wall_toddler', 777)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['snake', 'animals_and_insects'], source('wall_toddler', 779)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bread', 'food_and_drink'], source('wall_toddler', 783)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['candy', 'food_and_drink'], source('wall_toddler', 785)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['cheese', 'food_and_drink'], source('wall_toddler', 787)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['jam', 'food_and_drink'], source('wall_toddler', 789)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['pie', 'food_and_drink'], source('wall_toddler', 791)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['soup', 'food_and_drink'], source('wall_toddler', 793)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['arm', 'body_parts'], source('wall_toddler', 797)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['neck', 'body_parts'], source('wall_toddler', 799)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['toe', 'body_parts'], source('wall_toddler', 801)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['tooth', 'body_parts'], source('wall_toddler', 803)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['cap', 'clothing'], source('wall_toddler', 807)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['sock', 'clothing'], source('wall_toddler', 809)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bell', 'home_and_objects'], source('wall_toddler', 813)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bottle', 'home_and_objects'], source('wall_toddler', 815)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['doll', 'home_and_objects'], source('wall_toddler', 817)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['fork', 'home_and_objects'], source('wall_toddler', 819)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['spoon', 'home_and_objects'], source('wall_toddler', 821)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['truck', 'vehicles_and_transportation'], source('wall_toddler', 825)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['zoo', 'places_and_buildings'], source('wall_toddler', 829)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['drum', 'music'], source('wall_toddler', 833)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('toddler', 'vocabulary', ['bubble', 'fun_and_actions'], source('wall_toddler', 837)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['a', 'start_here'], source('wall_preschool', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['see', 'start_here'], source('wall_preschool', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['my', 'start_here'], source('wall_preschool', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['me', 'start_here'], source('wall_preschool', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['like', 'next'], source('wall_preschool', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['the', 'next'], source('wall_preschool', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['go', 'next'], source('wall_preschool', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['up', 'next'], source('wall_preschool', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['to', 'next'], source('wall_preschool', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['we', 'after_that'], source('wall_preschool', 76)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['can', 'after_that'], source('wall_preschool', 78)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['is', 'after_that'], source('wall_preschool', 80)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['no', 'after_that'], source('wall_preschool', 82)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['yes', 'after_that'], source('wall_preschool', 84)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['you', 'later_in_the_year'], source('wall_preschool', 88)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['he', 'later_in_the_year'], source('wall_preschool', 90)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['she', 'later_in_the_year'], source('wall_preschool', 92)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['and', 'later_in_the_year'], source('wall_preschool', 94)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['look', 'later_in_the_year'], source('wall_preschool', 96)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['me', 'people_words'], source('wall_preschool', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['my', 'people_words'], source('wall_preschool', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['you', 'people_words'], source('wall_preschool', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['your', 'people_words'], source('wall_preschool', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['we', 'people_words'], source('wall_preschool', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['he', 'people_words'], source('wall_preschool', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['she', 'people_words'], source('wall_preschool', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['it', 'people_words'], source('wall_preschool', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['them', 'people_words'], source('wall_preschool', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['am', 'action_words'], source('wall_preschool', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['is', 'action_words'], source('wall_preschool', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['are', 'action_words'], source('wall_preschool', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['can', 'action_words'], source('wall_preschool', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['see', 'action_words'], source('wall_preschool', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['go', 'action_words'], source('wall_preschool', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['do', 'action_words'], source('wall_preschool', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['look', 'action_words'], source('wall_preschool', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['like', 'action_words'], source('wall_preschool', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['play', 'action_words'], source('wall_preschool', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['run', 'action_words'], source('wall_preschool', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['jump', 'action_words'], source('wall_preschool', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['hop', 'action_words'], source('wall_preschool', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['eat', 'action_words'], source('wall_preschool', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['help', 'action_words'], source('wall_preschool', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['want', 'action_words'], source('wall_preschool', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['come', 'action_words'], source('wall_preschool', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['hug', 'action_words'], source('wall_preschool', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['pet', 'action_words'], source('wall_preschool', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['kick', 'action_words'], source('wall_preschool', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['count', 'action_words'], source('wall_preschool', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['fly', 'action_words'], source('wall_preschool', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['have', 'action_words'], source('wall_preschool', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['a', 'little_words'], source('wall_preschool', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['an', 'little_words'], source('wall_preschool', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['and', 'little_words'], source('wall_preschool', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['the', 'little_words'], source('wall_preschool', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['to', 'little_words'], source('wall_preschool', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['in', 'little_words'], source('wall_preschool', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['on', 'little_words'], source('wall_preschool', 191)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['at', 'little_words'], source('wall_preschool', 193)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['up', 'little_words'], source('wall_preschool', 195)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['down', 'little_words'], source('wall_preschool', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['here', 'little_words'], source('wall_preschool', 199)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['so', 'little_words'], source('wall_preschool', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['too', 'little_words'], source('wall_preschool', 203)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['with', 'little_words'], source('wall_preschool', 205)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['not', 'little_words'], source('wall_preschool', 207)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['all', 'little_words'], source('wall_preschool', 209)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['for', 'little_words'], source('wall_preschool', 211)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['what', 'question_words'], source('wall_preschool', 215)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['who', 'question_words'], source('wall_preschool', 217)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['where', 'question_words'], source('wall_preschool', 219)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['yes', 'yes_and_no_words'], source('wall_preschool', 223)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['no', 'yes_and_no_words'], source('wall_preschool', 225)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['red', 'color_words'], source('wall_preschool', 229)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['blue', 'color_words'], source('wall_preschool', 231)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['yellow', 'color_words'], source('wall_preschool', 233)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['green', 'color_words'], source('wall_preschool', 235)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['orange', 'color_words'], source('wall_preschool', 237)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['purple', 'color_words'], source('wall_preschool', 239)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['pink', 'color_words'], source('wall_preschool', 241)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['brown', 'color_words'], source('wall_preschool', 243)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['black', 'color_words'], source('wall_preschool', 245)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['white', 'color_words'], source('wall_preschool', 247)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['one', 'number_words'], source('wall_preschool', 251)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['two', 'number_words'], source('wall_preschool', 253)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['three', 'number_words'], source('wall_preschool', 255)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['four', 'number_words'], source('wall_preschool', 257)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['five', 'number_words'], source('wall_preschool', 259)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['circle', 'shape_words'], source('wall_preschool', 263)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['square', 'shape_words'], source('wall_preschool', 265)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['triangle', 'shape_words'], source('wall_preschool', 267)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['star', 'shape_words'], source('wall_preschool', 269)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['heart', 'shape_words'], source('wall_preschool', 271)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['happy', 'feeling_words'], source('wall_preschool', 275)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['sad', 'feeling_words'], source('wall_preschool', 277)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['mad', 'feeling_words'], source('wall_preschool', 279)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['glad', 'feeling_words'], source('wall_preschool', 281)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['mom', 'family_words'], source('wall_preschool', 285)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['dad', 'family_words'], source('wall_preschool', 287)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['baby', 'family_words'], source('wall_preschool', 289)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['sister', 'family_words'], source('wall_preschool', 291)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['brother', 'family_words'], source('wall_preschool', 293)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['family', 'family_words'], source('wall_preschool', 295)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['cat', 'animal_words'], source('wall_preschool', 299)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['dog', 'animal_words'], source('wall_preschool', 301)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['cow', 'animal_words'], source('wall_preschool', 303)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['pig', 'animal_words'], source('wall_preschool', 305)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['duck', 'animal_words'], source('wall_preschool', 307)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['fish', 'animal_words'], source('wall_preschool', 309)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['bird', 'animal_words'], source('wall_preschool', 311)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['bug', 'animal_words'], source('wall_preschool', 313)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['sun', 'everyday_things'], source('wall_preschool', 317)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['ball', 'everyday_things'], source('wall_preschool', 319)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['hat', 'everyday_things'], source('wall_preschool', 321)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['box', 'everyday_things'], source('wall_preschool', 323)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['bed', 'everyday_things'], source('wall_preschool', 325)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['car', 'everyday_things'], source('wall_preschool', 327)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['cup', 'everyday_things'], source('wall_preschool', 329)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['big', 'describing_words'], source('wall_preschool', 333)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['little', 'describing_words'], source('wall_preschool', 335)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['good', 'describing_words'], source('wall_preschool', 337)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['far', 'describing_words'], source('wall_preschool', 339)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['butterfly', 'animals_and_insects'], source('wall_preschool', 891)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['chicken', 'animals_and_insects'], source('wall_preschool', 893)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['fox', 'animals_and_insects'], source('wall_preschool', 895)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['goose', 'animals_and_insects'], source('wall_preschool', 897)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['horse', 'animals_and_insects'], source('wall_preschool', 899)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['lamb', 'animals_and_insects'], source('wall_preschool', 901)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['panda', 'animals_and_insects'], source('wall_preschool', 903)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['pony', 'animals_and_insects'], source('wall_preschool', 905)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['rat', 'animals_and_insects'], source('wall_preschool', 907)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['shark', 'animals_and_insects'], source('wall_preschool', 909)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['sheep', 'animals_and_insects'], source('wall_preschool', 911)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['snail', 'animals_and_insects'], source('wall_preschool', 913)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['turtle', 'animals_and_insects'], source('wall_preschool', 915)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['wolf', 'animals_and_insects'], source('wall_preschool', 917)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['zebra', 'animals_and_insects'], source('wall_preschool', 919)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['carrot', 'food_and_drink'], source('wall_preschool', 923)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['cherry', 'food_and_drink'], source('wall_preschool', 925)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['chocolate', 'food_and_drink'], source('wall_preschool', 927)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['fruit', 'food_and_drink'], source('wall_preschool', 929)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['grape', 'food_and_drink'], source('wall_preschool', 931)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['jelly', 'food_and_drink'], source('wall_preschool', 933)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['lemon', 'food_and_drink'], source('wall_preschool', 935)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['noodle', 'food_and_drink'], source('wall_preschool', 937)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['nut', 'food_and_drink'], source('wall_preschool', 939)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['pea', 'food_and_drink'], source('wall_preschool', 941)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['peach', 'food_and_drink'], source('wall_preschool', 943)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['pear', 'food_and_drink'], source('wall_preschool', 945)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['pizza', 'food_and_drink'], source('wall_preschool', 947)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['sandwich', 'food_and_drink'], source('wall_preschool', 949)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['toast', 'food_and_drink'], source('wall_preschool', 951)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['bone', 'body_parts'], source('wall_preschool', 955)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['cheek', 'body_parts'], source('wall_preschool', 957)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['chin', 'body_parts'], source('wall_preschool', 959)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['knee', 'body_parts'], source('wall_preschool', 961)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['lip', 'body_parts'], source('wall_preschool', 963)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['paw', 'body_parts'], source('wall_preschool', 965)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['thumb', 'body_parts'], source('wall_preschool', 967)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['belt', 'clothing'], source('wall_preschool', 971)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['boot', 'clothing'], source('wall_preschool', 973)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['dress', 'clothing'], source('wall_preschool', 975)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['glove', 'clothing'], source('wall_preschool', 977)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['mitten', 'clothing'], source('wall_preschool', 979)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['scarf', 'clothing'], source('wall_preschool', 981)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['shirt', 'clothing'], source('wall_preschool', 983)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['broom', 'home_and_objects'], source('wall_preschool', 987)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['bucket', 'home_and_objects'], source('wall_preschool', 989)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['comb', 'home_and_objects'], source('wall_preschool', 991)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['flag', 'home_and_objects'], source('wall_preschool', 993)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['glass', 'home_and_objects'], source('wall_preschool', 995)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['lamp', 'home_and_objects'], source('wall_preschool', 997)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['plate', 'home_and_objects'], source('wall_preschool', 999)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['soap', 'home_and_objects'], source('wall_preschool', 1001)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['television', 'home_and_objects'], source('wall_preschool', 1003)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['towel', 'home_and_objects'], source('wall_preschool', 1005)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['pencil', 'tools'], source('wall_preschool', 1009)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['airplane', 'vehicles_and_transportation'], source('wall_preschool', 1013)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['bicycle', 'vehicles_and_transportation'], source('wall_preschool', 1015)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['circus', 'places_and_buildings'], source('wall_preschool', 1019)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['pool', 'places_and_buildings'], source('wall_preschool', 1021)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['swing', 'places_and_buildings'], source('wall_preschool', 1023)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['clown', 'people_and_jobs'], source('wall_preschool', 1027)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['chase', 'fun_and_actions'], source('wall_preschool', 1031)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool', 'vocabulary', ['cry', 'fun_and_actions'], source('wall_preschool', 1033)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['a', 'introduce_in_this_approximate_order'], source('wall_tk', 22)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['the', 'introduce_in_this_approximate_order'], source('wall_tk', 23)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['see', 'introduce_in_this_approximate_order'], source('wall_tk', 24)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['like', 'introduce_in_this_approximate_order'], source('wall_tk', 25)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['can', 'introduce_in_this_approximate_order'], source('wall_tk', 26)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['we', 'introduce_in_this_approximate_order'], source('wall_tk', 27)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['my', 'introduce_in_this_approximate_order'], source('wall_tk', 28)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['and', 'introduce_in_this_approximate_order'], source('wall_tk', 29)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['is', 'introduce_in_this_approximate_order'], source('wall_tk', 30)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['to', 'introduce_in_this_approximate_order'], source('wall_tk', 36)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['go', 'introduce_in_this_approximate_order'], source('wall_tk', 37)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['it', 'introduce_in_this_approximate_order'], source('wall_tk', 38)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['in', 'introduce_in_this_approximate_order'], source('wall_tk', 39)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['am', 'introduce_in_this_approximate_order'], source('wall_tk', 40)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['at', 'introduce_in_this_approximate_order'], source('wall_tk', 41)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['me', 'introduce_in_this_approximate_order'], source('wall_tk', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['he', 'introduce_in_this_approximate_order'], source('wall_tk', 43)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['she', 'introduce_in_this_approximate_order'], source('wall_tk', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['you', 'introduce_in_this_approximate_order'], source('wall_tk', 45)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['do', 'introduce_in_this_approximate_order'], source('wall_tk', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['on', 'introduce_in_this_approximate_order'], source('wall_tk', 51)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['for', 'introduce_in_this_approximate_order'], source('wall_tk', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['of', 'introduce_in_this_approximate_order'], source('wall_tk', 53)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['are', 'introduce_in_this_approximate_order'], source('wall_tk', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['was', 'introduce_in_this_approximate_order'], source('wall_tk', 55)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['so', 'introduce_in_this_approximate_order'], source('wall_tk', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['up', 'introduce_in_this_approximate_order'], source('wall_tk', 57)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['no', 'introduce_in_this_approximate_order'], source('wall_tk', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['be', 'introduce_in_this_approximate_order'], source('wall_tk', 63)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['have', 'introduce_in_this_approximate_order'], source('wall_tk', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['they', 'introduce_in_this_approximate_order'], source('wall_tk', 65)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['this', 'introduce_in_this_approximate_order'], source('wall_tk', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['that', 'introduce_in_this_approximate_order'], source('wall_tk', 67)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['with', 'introduce_in_this_approximate_order'], source('wall_tk', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['from', 'introduce_in_this_approximate_order'], source('wall_tk', 69)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['or', 'introduce_in_this_approximate_order'], source('wall_tk', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['one', 'introduce_in_this_approximate_order'], source('wall_tk', 71)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['had', 'introduce_in_this_approximate_order'], source('wall_tk', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['by', 'introduce_in_this_approximate_order'], source('wall_tk', 74)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['but', 'introduce_in_this_approximate_order'], source('wall_tk', 75)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['not', 'introduce_in_this_approximate_order'], source('wall_tk', 76)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['what', 'introduce_in_this_approximate_order'], source('wall_tk', 77)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['all', 'introduce_in_this_approximate_order'], source('wall_tk', 78)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['were', 'introduce_in_this_approximate_order'], source('wall_tk', 79)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['when', 'introduce_in_this_approximate_order'], source('wall_tk', 80)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['your', 'introduce_in_this_approximate_order'], source('wall_tk', 81)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['said', 'introduce_in_this_approximate_order'], source('wall_tk', 82)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['there', 'introduce_in_this_approximate_order'], source('wall_tk', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['an', 'introduce_in_this_approximate_order'], source('wall_tk', 95)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['as', 'introduce_in_this_approximate_order'], source('wall_tk', 98)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['ate', 'introduce_in_this_approximate_order'], source('wall_tk', 100)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['away', 'introduce_in_this_approximate_order'], source('wall_tk', 101)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['been', 'introduce_in_this_approximate_order'], source('wall_tk', 104)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['big', 'introduce_in_this_approximate_order'], source('wall_tk', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['black', 'introduce_in_this_approximate_order'], source('wall_tk', 106)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['blue', 'introduce_in_this_approximate_order'], source('wall_tk', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['brown', 'introduce_in_this_approximate_order'], source('wall_tk', 108)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['call', 'introduce_in_this_approximate_order'], source('wall_tk', 112)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['came', 'introduce_in_this_approximate_order'], source('wall_tk', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['come', 'introduce_in_this_approximate_order'], source('wall_tk', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['could', 'introduce_in_this_approximate_order'], source('wall_tk', 116)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['day', 'introduce_in_this_approximate_order'], source('wall_tk', 118)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['did', 'introduce_in_this_approximate_order'], source('wall_tk', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['down', 'introduce_in_this_approximate_order'], source('wall_tk', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['each', 'introduce_in_this_approximate_order'], source('wall_tk', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['eat', 'introduce_in_this_approximate_order'], source('wall_tk', 124)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['find', 'introduce_in_this_approximate_order'], source('wall_tk', 126)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['five', 'introduce_in_this_approximate_order'], source('wall_tk', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['four', 'introduce_in_this_approximate_order'], source('wall_tk', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['funny', 'introduce_in_this_approximate_order'], source('wall_tk', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['get', 'introduce_in_this_approximate_order'], source('wall_tk', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['good', 'introduce_in_this_approximate_order'], source('wall_tk', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['green', 'introduce_in_this_approximate_order'], source('wall_tk', 136)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['has', 'introduce_in_this_approximate_order'], source('wall_tk', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['help', 'introduce_in_this_approximate_order'], source('wall_tk', 142)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['her', 'introduce_in_this_approximate_order'], source('wall_tk', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['here', 'introduce_in_this_approximate_order'], source('wall_tk', 144)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['him', 'introduce_in_this_approximate_order'], source('wall_tk', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['his', 'introduce_in_this_approximate_order'], source('wall_tk', 146)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['how', 'introduce_in_this_approximate_order'], source('wall_tk', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['if', 'introduce_in_this_approximate_order'], source('wall_tk', 150)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['into', 'introduce_in_this_approximate_order'], source('wall_tk', 152)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['its', 'introduce_in_this_approximate_order'], source('wall_tk', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['jump', 'introduce_in_this_approximate_order'], source('wall_tk', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['little', 'introduce_in_this_approximate_order'], source('wall_tk', 160)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['long', 'introduce_in_this_approximate_order'], source('wall_tk', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['look', 'introduce_in_this_approximate_order'], source('wall_tk', 162)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['made', 'introduce_in_this_approximate_order'], source('wall_tk', 164)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['make', 'introduce_in_this_approximate_order'], source('wall_tk', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['many', 'introduce_in_this_approximate_order'], source('wall_tk', 166)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['may', 'introduce_in_this_approximate_order'], source('wall_tk', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['more', 'introduce_in_this_approximate_order'], source('wall_tk', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['must', 'introduce_in_this_approximate_order'], source('wall_tk', 170)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['new', 'introduce_in_this_approximate_order'], source('wall_tk', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['now', 'introduce_in_this_approximate_order'], source('wall_tk', 176)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['orange', 'introduce_in_this_approximate_order'], source('wall_tk', 182)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['other', 'introduce_in_this_approximate_order'], source('wall_tk', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['our', 'introduce_in_this_approximate_order'], source('wall_tk', 184)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['out', 'introduce_in_this_approximate_order'], source('wall_tk', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['part', 'introduce_in_this_approximate_order'], source('wall_tk', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['pink', 'introduce_in_this_approximate_order'], source('wall_tk', 188)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['play', 'introduce_in_this_approximate_order'], source('wall_tk', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['please', 'introduce_in_this_approximate_order'], source('wall_tk', 190)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['pretty', 'introduce_in_this_approximate_order'], source('wall_tk', 191)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['purple', 'introduce_in_this_approximate_order'], source('wall_tk', 192)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['ran', 'introduce_in_this_approximate_order'], source('wall_tk', 194)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['red', 'introduce_in_this_approximate_order'], source('wall_tk', 195)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['ride', 'introduce_in_this_approximate_order'], source('wall_tk', 196)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['run', 'introduce_in_this_approximate_order'], source('wall_tk', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['saw', 'introduce_in_this_approximate_order'], source('wall_tk', 200)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['say', 'introduce_in_this_approximate_order'], source('wall_tk', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['some', 'introduce_in_this_approximate_order'], source('wall_tk', 205)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['soon', 'introduce_in_this_approximate_order'], source('wall_tk', 206)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['their', 'introduce_in_this_approximate_order'], source('wall_tk', 210)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['them', 'introduce_in_this_approximate_order'], source('wall_tk', 211)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['then', 'introduce_in_this_approximate_order'], source('wall_tk', 212)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['these', 'introduce_in_this_approximate_order'], source('wall_tk', 214)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['three', 'introduce_in_this_approximate_order'], source('wall_tk', 217)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['time', 'introduce_in_this_approximate_order'], source('wall_tk', 218)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['too', 'introduce_in_this_approximate_order'], source('wall_tk', 220)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['two', 'introduce_in_this_approximate_order'], source('wall_tk', 221)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['under', 'introduce_in_this_approximate_order'], source('wall_tk', 223)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['us', 'introduce_in_this_approximate_order'], source('wall_tk', 225)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['use', 'introduce_in_this_approximate_order'], source('wall_tk', 226)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['want', 'introduce_in_this_approximate_order'], source('wall_tk', 228)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['way', 'introduce_in_this_approximate_order'], source('wall_tk', 230)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['well', 'introduce_in_this_approximate_order'], source('wall_tk', 232)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['went', 'introduce_in_this_approximate_order'], source('wall_tk', 233)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['where', 'introduce_in_this_approximate_order'], source('wall_tk', 237)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['which', 'introduce_in_this_approximate_order'], source('wall_tk', 238)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['white', 'introduce_in_this_approximate_order'], source('wall_tk', 239)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['who', 'introduce_in_this_approximate_order'], source('wall_tk', 240)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['will', 'introduce_in_this_approximate_order'], source('wall_tk', 241)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['word', 'introduce_in_this_approximate_order'], source('wall_tk', 243)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['would', 'introduce_in_this_approximate_order'], source('wall_tk', 244)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['yellow', 'introduce_in_this_approximate_order'], source('wall_tk', 246)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['yes', 'introduce_in_this_approximate_order'], source('wall_tk', 247)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['a', 'create_a_tracking_sheet_for_each_student'], source('wall_tk', 495)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('transitional_kindergarten', 'vocabulary', ['the', 'create_a_tracking_sheet_for_each_student'], source('wall_tk', 501)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['the', 'start_here'], source('wall_kindergarten', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['a', 'start_here'], source('wall_kindergarten', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['see', 'start_here'], source('wall_kindergarten', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['like', 'start_here'], source('wall_kindergarten', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['we', 'next'], source('wall_kindergarten', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['can', 'next'], source('wall_kindergarten', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['go', 'next'], source('wall_kindergarten', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['to', 'next'], source('wall_kindergarten', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['my', 'next'], source('wall_kindergarten', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['you', 'after_that'], source('wall_kindergarten', 76)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['he', 'after_that'], source('wall_kindergarten', 78)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['she', 'after_that'], source('wall_kindergarten', 80)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['it', 'after_that'], source('wall_kindergarten', 82)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['is', 'after_that'], source('wall_kindergarten', 84)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['and', 'building_sentences'], source('wall_kindergarten', 88)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['said', 'building_sentences'], source('wall_kindergarten', 90)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['was', 'building_sentences'], source('wall_kindergarten', 92)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['they', 'building_sentences'], source('wall_kindergarten', 94)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['with', 'building_sentences'], source('wall_kindergarten', 96)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['a', 'a_words'], source('wall_kindergarten', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['after', 'a_words'], source('wall_kindergarten', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['again', 'a_words'], source('wall_kindergarten', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['all', 'a_words'], source('wall_kindergarten', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['am', 'a_words'], source('wall_kindergarten', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['an', 'a_words'], source('wall_kindergarten', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['and', 'a_words'], source('wall_kindergarten', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['any', 'a_words'], source('wall_kindergarten', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['are', 'a_words'], source('wall_kindergarten', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['as', 'a_words'], source('wall_kindergarten', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['asleep', 'a_words'], source('wall_kindergarten', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['at', 'a_words'], source('wall_kindergarten', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['ate', 'a_words'], source('wall_kindergarten', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['away', 'a_words'], source('wall_kindergarten', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['baby', 'b_words'], source('wall_kindergarten', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['back', 'b_words'], source('wall_kindergarten', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['be', 'b_words'], source('wall_kindergarten', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['best', 'b_words'], source('wall_kindergarten', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['big', 'b_words'], source('wall_kindergarten', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['black', 'b_words'], source('wall_kindergarten', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['block', 'b_words'], source('wall_kindergarten', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['blue', 'b_words'], source('wall_kindergarten', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['book', 'b_words'], source('wall_kindergarten', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['box', 'b_words'], source('wall_kindergarten', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['boy', 'b_words'], source('wall_kindergarten', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['brown', 'b_words'], source('wall_kindergarten', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['brush', 'b_words'], source('wall_kindergarten', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['bug', 'b_words'], source('wall_kindergarten', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['but', 'b_words'], source('wall_kindergarten', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['by', 'b_words'], source('wall_kindergarten', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['came', 'c_words'], source('wall_kindergarten', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['can', 'c_words'], source('wall_kindergarten', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['close', 'c_words'], source('wall_kindergarten', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['cold', 'c_words'], source('wall_kindergarten', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['come', 'c_words'], source('wall_kindergarten', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['could', 'c_words'], source('wall_kindergarten', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['count', 'c_words'], source('wall_kindergarten', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['crack', 'c_words'], source('wall_kindergarten', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['day', 'd_words'], source('wall_kindergarten', 193)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['did', 'd_words'], source('wall_kindergarten', 195)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['do', 'd_words'], source('wall_kindergarten', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['down', 'd_words'], source('wall_kindergarten', 199)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['drip', 'd_words'], source('wall_kindergarten', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['eat', 'e_words'], source('wall_kindergarten', 205)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['egg', 'e_words'], source('wall_kindergarten', 207)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['eye', 'e_words'], source('wall_kindergarten', 209)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['every', 'e_words'], source('wall_kindergarten', 211)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['fast', 'f_words'], source('wall_kindergarten', 215)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['fat', 'f_words'], source('wall_kindergarten', 217)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['feel', 'f_words'], source('wall_kindergarten', 219)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['find', 'f_words'], source('wall_kindergarten', 221)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['first', 'f_words'], source('wall_kindergarten', 223)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['five', 'f_words'], source('wall_kindergarten', 225)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['fly', 'f_words'], source('wall_kindergarten', 227)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['food', 'f_words'], source('wall_kindergarten', 229)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['for', 'f_words'], source('wall_kindergarten', 231)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['found', 'f_words'], source('wall_kindergarten', 233)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['four', 'f_words'], source('wall_kindergarten', 235)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['friend', 'f_words'], source('wall_kindergarten', 237)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['fun', 'f_words'], source('wall_kindergarten', 239)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['funny', 'f_words'], source('wall_kindergarten', 241)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['gave', 'g_words'], source('wall_kindergarten', 245)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['get', 'g_words'], source('wall_kindergarten', 247)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['girl', 'g_words'], source('wall_kindergarten', 249)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['give', 'g_words'], source('wall_kindergarten', 251)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['go', 'g_words'], source('wall_kindergarten', 253)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['going', 'g_words'], source('wall_kindergarten', 255)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['good', 'g_words'], source('wall_kindergarten', 257)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['got', 'g_words'], source('wall_kindergarten', 259)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['green', 'g_words'], source('wall_kindergarten', 261)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['had', 'h_words'], source('wall_kindergarten', 265)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['has', 'h_words'], source('wall_kindergarten', 267)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['have', 'h_words'], source('wall_kindergarten', 269)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['he', 'h_words'], source('wall_kindergarten', 271)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['head', 'h_words'], source('wall_kindergarten', 273)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['help', 'h_words'], source('wall_kindergarten', 275)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['her', 'h_words'], source('wall_kindergarten', 277)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['here', 'h_words'], source('wall_kindergarten', 279)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['high', 'h_words'], source('wall_kindergarten', 281)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['him', 'h_words'], source('wall_kindergarten', 283)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['his', 'h_words'], source('wall_kindergarten', 285)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['home', 'h_words'], source('wall_kindergarten', 287)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['how', 'h_words'], source('wall_kindergarten', 289)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['hug', 'h_words'], source('wall_kindergarten', 291)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['in', 'i_words'], source('wall_kindergarten', 297)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['into', 'i_words'], source('wall_kindergarten', 299)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['is', 'i_words'], source('wall_kindergarten', 301)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['it', 'i_words'], source('wall_kindergarten', 303)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['jump', 'j_words'], source('wall_kindergarten', 307)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['just', 'j_words'], source('wall_kindergarten', 309)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['keep', 'k_words'], source('wall_kindergarten', 313)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['kept', 'k_words'], source('wall_kindergarten', 315)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['kick', 'k_words'], source('wall_kindergarten', 317)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['laugh', 'l_words'], source('wall_kindergarten', 321)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['let', 'l_words'], source('wall_kindergarten', 323)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['like', 'l_words'], source('wall_kindergarten', 325)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['little', 'l_words'], source('wall_kindergarten', 327)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['live', 'l_words'], source('wall_kindergarten', 329)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['log', 'l_words'], source('wall_kindergarten', 331)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['look', 'l_words'], source('wall_kindergarten', 333)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['lost', 'l_words'], source('wall_kindergarten', 335)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['lunch', 'l_words'], source('wall_kindergarten', 337)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['made', 'm_words'], source('wall_kindergarten', 341)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['make', 'm_words'], source('wall_kindergarten', 343)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['many', 'm_words'], source('wall_kindergarten', 345)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['may', 'm_words'], source('wall_kindergarten', 347)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['me', 'm_words'], source('wall_kindergarten', 349)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['mom', 'm_words'], source('wall_kindergarten', 351)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['morning', 'm_words'], source('wall_kindergarten', 353)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['must', 'm_words'], source('wall_kindergarten', 355)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['my', 'm_words'], source('wall_kindergarten', 357)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['name', 'n_words'], source('wall_kindergarten', 361)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['nest', 'n_words'], source('wall_kindergarten', 363)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['new', 'n_words'], source('wall_kindergarten', 365)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['next', 'n_words'], source('wall_kindergarten', 367)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['night', 'n_words'], source('wall_kindergarten', 369)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['no', 'n_words'], source('wall_kindergarten', 371)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['not', 'n_words'], source('wall_kindergarten', 373)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['now', 'n_words'], source('wall_kindergarten', 375)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['of', 'o_words'], source('wall_kindergarten', 379)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['old', 'o_words'], source('wall_kindergarten', 381)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['on', 'o_words'], source('wall_kindergarten', 383)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['once', 'o_words'], source('wall_kindergarten', 385)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['one', 'o_words'], source('wall_kindergarten', 387)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['open', 'o_words'], source('wall_kindergarten', 389)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['or', 'o_words'], source('wall_kindergarten', 391)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['our', 'o_words'], source('wall_kindergarten', 393)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['out', 'o_words'], source('wall_kindergarten', 395)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['over', 'o_words'], source('wall_kindergarten', 397)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['pajamas', 'p_words'], source('wall_kindergarten', 401)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['park', 'p_words'], source('wall_kindergarten', 403)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['peep', 'p_words'], source('wall_kindergarten', 405)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['pig', 'p_words'], source('wall_kindergarten', 407)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['play', 'p_words'], source('wall_kindergarten', 409)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['please', 'p_words'], source('wall_kindergarten', 411)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['pond', 'p_words'], source('wall_kindergarten', 413)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['pretty', 'p_words'], source('wall_kindergarten', 415)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['put', 'p_words'], source('wall_kindergarten', 417)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['rain', 'r_words'], source('wall_kindergarten', 421)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['ran', 'r_words'], source('wall_kindergarten', 423)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['read', 'r_words'], source('wall_kindergarten', 425)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['red', 'r_words'], source('wall_kindergarten', 427)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['ride', 'r_words'], source('wall_kindergarten', 429)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['round', 'r_words'], source('wall_kindergarten', 431)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['run', 'r_words'], source('wall_kindergarten', 433)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['said', 's_words'], source('wall_kindergarten', 437)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['sat', 's_words'], source('wall_kindergarten', 439)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['saw', 's_words'], source('wall_kindergarten', 441)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['say', 's_words'], source('wall_kindergarten', 443)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['school', 's_words'], source('wall_kindergarten', 445)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['see', 's_words'], source('wall_kindergarten', 447)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['she', 's_words'], source('wall_kindergarten', 449)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['sing', 's_words'], source('wall_kindergarten', 451)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['six', 's_words'], source('wall_kindergarten', 453)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['slide', 's_words'], source('wall_kindergarten', 455)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['so', 's_words'], source('wall_kindergarten', 457)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['some', 's_words'], source('wall_kindergarten', 459)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['song', 's_words'], source('wall_kindergarten', 461)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['soon', 's_words'], source('wall_kindergarten', 463)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['splash', 's_words'], source('wall_kindergarten', 465)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['stop', 's_words'], source('wall_kindergarten', 467)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['sun', 's_words'], source('wall_kindergarten', 469)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['swim', 's_words'], source('wall_kindergarten', 471)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['take', 't_words'], source('wall_kindergarten', 475)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['teeth', 't_words'], source('wall_kindergarten', 477)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['thank', 't_words'], source('wall_kindergarten', 479)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['that', 't_words'], source('wall_kindergarten', 481)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['the', 't_words'], source('wall_kindergarten', 483)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['them', 't_words'], source('wall_kindergarten', 485)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['then', 't_words'], source('wall_kindergarten', 487)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['there', 't_words'], source('wall_kindergarten', 489)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['they', 't_words'], source('wall_kindergarten', 491)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['think', 't_words'], source('wall_kindergarten', 493)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['this', 't_words'], source('wall_kindergarten', 495)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['three', 't_words'], source('wall_kindergarten', 497)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['throw', 't_words'], source('wall_kindergarten', 499)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['time', 't_words'], source('wall_kindergarten', 501)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['to', 't_words'], source('wall_kindergarten', 503)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['too', 't_words'], source('wall_kindergarten', 505)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['top', 't_words'], source('wall_kindergarten', 507)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['town', 't_words'], source('wall_kindergarten', 509)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['toy', 't_words'], source('wall_kindergarten', 511)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['tree', 't_words'], source('wall_kindergarten', 513)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['two', 't_words'], source('wall_kindergarten', 515)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['under', 'u_words'], source('wall_kindergarten', 519)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['up', 'u_words'], source('wall_kindergarten', 521)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['us', 'u_words'], source('wall_kindergarten', 523)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['very', 'v_words'], source('wall_kindergarten', 527)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['walk', 'w_words'], source('wall_kindergarten', 531)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['want', 'w_words'], source('wall_kindergarten', 533)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['warm', 'w_words'], source('wall_kindergarten', 535)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['was', 'w_words'], source('wall_kindergarten', 537)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['we', 'w_words'], source('wall_kindergarten', 539)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['well', 'w_words'], source('wall_kindergarten', 541)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['went', 'w_words'], source('wall_kindergarten', 543)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['were', 'w_words'], source('wall_kindergarten', 545)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['wet', 'w_words'], source('wall_kindergarten', 547)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['what', 'w_words'], source('wall_kindergarten', 549)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['when', 'w_words'], source('wall_kindergarten', 551)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['where', 'w_words'], source('wall_kindergarten', 553)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['which', 'w_words'], source('wall_kindergarten', 555)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['white', 'w_words'], source('wall_kindergarten', 557)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['who', 'w_words'], source('wall_kindergarten', 559)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['whole', 'w_words'], source('wall_kindergarten', 561)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['will', 'w_words'], source('wall_kindergarten', 563)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['with', 'w_words'], source('wall_kindergarten', 565)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['worm', 'w_words'], source('wall_kindergarten', 567)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['would', 'w_words'], source('wall_kindergarten', 569)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['yellow', 'y_words'], source('wall_kindergarten', 573)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['yes', 'y_words'], source('wall_kindergarten', 575)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['yum', 'y_words'], source('wall_kindergarten', 577)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['you', 'y_words'], source('wall_kindergarten', 579)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['your', 'y_words'], source('wall_kindergarten', 581)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['alligator', 'animals_and_insects'], source('wall_kindergarten', 1014)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['beaver', 'animals_and_insects'], source('wall_kindergarten', 1016)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['beetle', 'animals_and_insects'], source('wall_kindergarten', 1018)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['camel', 'animals_and_insects'], source('wall_kindergarten', 1020)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['crocodile', 'animals_and_insects'], source('wall_kindergarten', 1022)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['deer', 'animals_and_insects'], source('wall_kindergarten', 1024)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['dinosaur', 'animals_and_insects'], source('wall_kindergarten', 1026)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['donkey', 'animals_and_insects'], source('wall_kindergarten', 1028)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['eagle', 'animals_and_insects'], source('wall_kindergarten', 1030)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['giraffe', 'animals_and_insects'], source('wall_kindergarten', 1032)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['kangaroo', 'animals_and_insects'], source('wall_kindergarten', 1034)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['koala', 'animals_and_insects'], source('wall_kindergarten', 1036)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['leopard', 'animals_and_insects'], source('wall_kindergarten', 1038)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['ostrich', 'animals_and_insects'], source('wall_kindergarten', 1040)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['parrot', 'animals_and_insects'], source('wall_kindergarten', 1042)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['peacock', 'animals_and_insects'], source('wall_kindergarten', 1044)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['pigeon', 'animals_and_insects'], source('wall_kindergarten', 1046)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['raccoon', 'animals_and_insects'], source('wall_kindergarten', 1048)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['rooster', 'animals_and_insects'], source('wall_kindergarten', 1050)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['squirrel', 'animals_and_insects'], source('wall_kindergarten', 1052)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['swan', 'animals_and_insects'], source('wall_kindergarten', 1054)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['turkey', 'animals_and_insects'], source('wall_kindergarten', 1056)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['cabbage', 'food_and_drink'], source('wall_kindergarten', 1060)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['celery', 'food_and_drink'], source('wall_kindergarten', 1062)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['cream', 'food_and_drink'], source('wall_kindergarten', 1064)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['honey', 'food_and_drink'], source('wall_kindergarten', 1066)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['mango', 'food_and_drink'], source('wall_kindergarten', 1068)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['melon', 'food_and_drink'], source('wall_kindergarten', 1070)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['onion', 'food_and_drink'], source('wall_kindergarten', 1072)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['pepper', 'food_and_drink'], source('wall_kindergarten', 1074)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['pineapple', 'food_and_drink'], source('wall_kindergarten', 1076)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['popcorn', 'food_and_drink'], source('wall_kindergarten', 1078)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['potato', 'food_and_drink'], source('wall_kindergarten', 1080)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['pretzel', 'food_and_drink'], source('wall_kindergarten', 1082)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['raspberry', 'food_and_drink'], source('wall_kindergarten', 1084)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['rice', 'food_and_drink'], source('wall_kindergarten', 1086)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['salad', 'food_and_drink'], source('wall_kindergarten', 1088)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['strawberry', 'food_and_drink'], source('wall_kindergarten', 1090)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['tomato', 'food_and_drink'], source('wall_kindergarten', 1092)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['chest', 'body_parts'], source('wall_kindergarten', 1096)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['claw', 'body_parts'], source('wall_kindergarten', 1098)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['shoulder', 'body_parts'], source('wall_kindergarten', 1100)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['stomach', 'body_parts'], source('wall_kindergarten', 1102)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['tongue', 'body_parts'], source('wall_kindergarten', 1104)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['whisker', 'body_parts'], source('wall_kindergarten', 1106)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['wrist', 'body_parts'], source('wall_kindergarten', 1108)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['skirt', 'clothing'], source('wall_kindergarten', 1112)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['slipper', 'clothing'], source('wall_kindergarten', 1114)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['sweater', 'clothing'], source('wall_kindergarten', 1116)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['bench', 'home_and_objects'], source('wall_kindergarten', 1120)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['cage', 'home_and_objects'], source('wall_kindergarten', 1122)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['candle', 'home_and_objects'], source('wall_kindergarten', 1124)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['carpet', 'home_and_objects'], source('wall_kindergarten', 1126)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['ceiling', 'home_and_objects'], source('wall_kindergarten', 1128)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['chain', 'home_and_objects'], source('wall_kindergarten', 1130)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['crown', 'home_and_objects'], source('wall_kindergarten', 1132)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['curtain', 'home_and_objects'], source('wall_kindergarten', 1134)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['jar', 'home_and_objects'], source('wall_kindergarten', 1136)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['knife', 'home_and_objects'], source('wall_kindergarten', 1138)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['refrigerator', 'home_and_objects'], source('wall_kindergarten', 1140)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['shelf', 'home_and_objects'], source('wall_kindergarten', 1142)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['sofa', 'home_and_objects'], source('wall_kindergarten', 1144)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['stairs', 'home_and_objects'], source('wall_kindergarten', 1146)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['stove', 'home_and_objects'], source('wall_kindergarten', 1148)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['telephone', 'home_and_objects'], source('wall_kindergarten', 1150)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['rope', 'tools'], source('wall_kindergarten', 1154)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['string', 'tools'], source('wall_kindergarten', 1156)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['clay', 'materials'], source('wall_kindergarten', 1160)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['ambulance', 'vehicles_and_transportation'], source('wall_kindergarten', 1164)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['helicopter', 'vehicles_and_transportation'], source('wall_kindergarten', 1166)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['rocket', 'vehicles_and_transportation'], source('wall_kindergarten', 1168)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['sled', 'vehicles_and_transportation'], source('wall_kindergarten', 1170)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['church', 'places_and_buildings'], source('wall_kindergarten', 1174)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['party', 'places_and_buildings'], source('wall_kindergarten', 1176)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['playground', 'places_and_buildings'], source('wall_kindergarten', 1178)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['tent', 'places_and_buildings'], source('wall_kindergarten', 1180)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['tower', 'places_and_buildings'], source('wall_kindergarten', 1182)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['yard', 'places_and_buildings'], source('wall_kindergarten', 1184)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['autumn', 'nature_weather_and_plants'], source('wall_kindergarten', 1188)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['bush', 'nature_weather_and_plants'], source('wall_kindergarten', 1190)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['creek', 'nature_weather_and_plants'], source('wall_kindergarten', 1192)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['daisy', 'nature_weather_and_plants'], source('wall_kindergarten', 1194)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['fog', 'nature_weather_and_plants'], source('wall_kindergarten', 1196)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['lightning', 'nature_weather_and_plants'], source('wall_kindergarten', 1198)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['stream', 'nature_weather_and_plants'], source('wall_kindergarten', 1200)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['sunflower', 'nature_weather_and_plants'], source('wall_kindergarten', 1202)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['tulip', 'nature_weather_and_plants'], source('wall_kindergarten', 1204)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['waterfall', 'nature_weather_and_plants'], source('wall_kindergarten', 1206)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['band', 'music'], source('wall_kindergarten', 1210)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['guitar', 'music'], source('wall_kindergarten', 1212)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['piano', 'music'], source('wall_kindergarten', 1214)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['violin', 'music'], source('wall_kindergarten', 1216)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['whistle', 'music'], source('wall_kindergarten', 1218)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['cook', 'people_and_jobs'], source('wall_kindergarten', 1222)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['daughter', 'people_and_jobs'], source('wall_kindergarten', 1224)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'vocabulary', ['feed', 'fun_and_actions'], source('wall_kindergarten', 1228)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['again', 'group_1'], source('wall_grade1', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['because', 'group_1'], source('wall_grade1', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['before', 'group_1'], source('wall_grade1', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['after', 'group_1'], source('wall_grade1', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['know', 'group_1'], source('wall_grade1', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['think', 'group_2'], source('wall_grade1', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['could', 'group_2'], source('wall_grade1', 62)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['would', 'group_2'], source('wall_grade1', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['should', 'group_2'], source('wall_grade1', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['when', 'group_2'], source('wall_grade1', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['every', 'group_3'], source('wall_grade1', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['other', 'group_3'], source('wall_grade1', 74)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['together', 'group_3'], source('wall_grade1', 76)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['about', 'group_3'], source('wall_grade1', 78)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['why', 'group_3'], source('wall_grade1', 80)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['about', 'common_high_frequency_words'], source('wall_grade1', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['after', 'common_high_frequency_words'], source('wall_grade1', 95)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['again', 'common_high_frequency_words'], source('wall_grade1', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['an', 'common_high_frequency_words'], source('wall_grade1', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['any', 'common_high_frequency_words'], source('wall_grade1', 101)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['as', 'common_high_frequency_words'], source('wall_grade1', 103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['ask', 'common_high_frequency_words'], source('wall_grade1', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['because', 'common_high_frequency_words'], source('wall_grade1', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['before', 'common_high_frequency_words'], source('wall_grade1', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['both', 'common_high_frequency_words'], source('wall_grade1', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['by', 'common_high_frequency_words'], source('wall_grade1', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['could', 'common_high_frequency_words'], source('wall_grade1', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['does', 'common_high_frequency_words'], source('wall_grade1', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['end', 'common_high_frequency_words'], source('wall_grade1', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['every', 'common_high_frequency_words'], source('wall_grade1', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['first', 'common_high_frequency_words'], source('wall_grade1', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['from', 'common_high_frequency_words'], source('wall_grade1', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['give', 'common_high_frequency_words'], source('wall_grade1', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['going', 'common_high_frequency_words'], source('wall_grade1', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['had', 'common_high_frequency_words'], source('wall_grade1', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['has', 'common_high_frequency_words'], source('wall_grade1', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['her', 'common_high_frequency_words'], source('wall_grade1', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['him', 'common_high_frequency_words'], source('wall_grade1', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['his', 'common_high_frequency_words'], source('wall_grade1', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['how', 'common_high_frequency_words'], source('wall_grade1', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['just', 'common_high_frequency_words'], source('wall_grade1', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['know', 'common_high_frequency_words'], source('wall_grade1', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['let', 'common_high_frequency_words'], source('wall_grade1', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['live', 'common_high_frequency_words'], source('wall_grade1', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['may', 'common_high_frequency_words'], source('wall_grade1', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['need', 'common_high_frequency_words'], source('wall_grade1', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['number', 'common_high_frequency_words'], source('wall_grade1', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['of', 'common_high_frequency_words'], source('wall_grade1', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['old', 'common_high_frequency_words'], source('wall_grade1', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['once', 'common_high_frequency_words'], source('wall_grade1', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['only', 'common_high_frequency_words'], source('wall_grade1', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['open', 'common_high_frequency_words'], source('wall_grade1', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['other', 'common_high_frequency_words'], source('wall_grade1', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['over', 'common_high_frequency_words'], source('wall_grade1', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['own', 'common_high_frequency_words'], source('wall_grade1', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['place', 'common_high_frequency_words'], source('wall_grade1', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['put', 'common_high_frequency_words'], source('wall_grade1', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['round', 'common_high_frequency_words'], source('wall_grade1', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['some', 'common_high_frequency_words'], source('wall_grade1', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['stop', 'common_high_frequency_words'], source('wall_grade1', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['take', 'common_high_frequency_words'], source('wall_grade1', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['thank', 'common_high_frequency_words'], source('wall_grade1', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['them', 'common_high_frequency_words'], source('wall_grade1', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['then', 'common_high_frequency_words'], source('wall_grade1', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['think', 'common_high_frequency_words'], source('wall_grade1', 191)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['today', 'common_high_frequency_words'], source('wall_grade1', 193)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['together', 'common_high_frequency_words'], source('wall_grade1', 195)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['walk', 'common_high_frequency_words'], source('wall_grade1', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['were', 'common_high_frequency_words'], source('wall_grade1', 199)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['when', 'common_high_frequency_words'], source('wall_grade1', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['why', 'common_high_frequency_words'], source('wall_grade1', 203)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['work', 'common_high_frequency_words'], source('wall_grade1', 205)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['year', 'common_high_frequency_words'], source('wall_grade1', 207)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['best', 'describing_and_number_words'], source('wall_grade1', 211)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['change', 'describing_and_number_words'], source('wall_grade1', 213)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['fast', 'describing_and_number_words'], source('wall_grade1', 215)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['grow', 'describing_and_number_words'], source('wall_grade1', 217)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['hard', 'describing_and_number_words'], source('wall_grade1', 219)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['ready', 'describing_and_number_words'], source('wall_grade1', 221)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['six', 'describing_and_number_words'], source('wall_grade1', 223)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['seven', 'describing_and_number_words'], source('wall_grade1', 225)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['ten', 'describing_and_number_words'], source('wall_grade1', 227)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['animal', 'naming_words'], source('wall_grade1', 231)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['apple', 'naming_words'], source('wall_grade1', 233)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['bird', 'naming_words'], source('wall_grade1', 235)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['boat', 'naming_words'], source('wall_grade1', 237)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['book', 'naming_words'], source('wall_grade1', 239)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['box', 'naming_words'], source('wall_grade1', 241)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['cake', 'naming_words'], source('wall_grade1', 243)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['farm', 'naming_words'], source('wall_grade1', 245)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['father', 'naming_words'], source('wall_grade1', 247)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['fish', 'naming_words'], source('wall_grade1', 249)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['frog', 'naming_words'], source('wall_grade1', 251)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['garden', 'naming_words'], source('wall_grade1', 253)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['house', 'naming_words'], source('wall_grade1', 255)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['kite', 'naming_words'], source('wall_grade1', 257)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['leaf', 'naming_words'], source('wall_grade1', 259)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['moon', 'naming_words'], source('wall_grade1', 261)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['mother', 'naming_words'], source('wall_grade1', 263)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['nest', 'naming_words'], source('wall_grade1', 265)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['park', 'naming_words'], source('wall_grade1', 267)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['pond', 'naming_words'], source('wall_grade1', 269)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['rain', 'naming_words'], source('wall_grade1', 271)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['rock', 'naming_words'], source('wall_grade1', 273)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['school', 'naming_words'], source('wall_grade1', 275)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['seed', 'naming_words'], source('wall_grade1', 277)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['snow', 'naming_words'], source('wall_grade1', 279)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['star', 'naming_words'], source('wall_grade1', 281)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['sun', 'naming_words'], source('wall_grade1', 283)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['tree', 'naming_words'], source('wall_grade1', 285)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['water', 'naming_words'], source('wall_grade1', 287)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['wind', 'naming_words'], source('wall_grade1', 289)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['above', 'place_words'], source('wall_grade1', 710)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['across', 'place_words'], source('wall_grade1', 712)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['afraid', 'place_words'], source('wall_grade1', 714)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['afternoon', 'place_words'], source('wall_grade1', 716)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['air', 'place_words'], source('wall_grade1', 718)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['almost', 'place_words'], source('wall_grade1', 720)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['along', 'place_words'], source('wall_grade1', 722)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['already', 'place_words'], source('wall_grade1', 724)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['always', 'place_words'], source('wall_grade1', 726)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['answer', 'place_words'], source('wall_grade1', 728)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['around', 'place_words'], source('wall_grade1', 730)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['balloon', 'place_words'], source('wall_grade1', 732)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['basket', 'place_words'], source('wall_grade1', 734)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['beautiful', 'place_words'], source('wall_grade1', 736)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['begin', 'place_words'], source('wall_grade1', 738)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['behind', 'place_words'], source('wall_grade1', 740)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['below', 'place_words'], source('wall_grade1', 742)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['between', 'place_words'], source('wall_grade1', 744)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['breakfast', 'place_words'], source('wall_grade1', 746)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['bridge', 'place_words'], source('wall_grade1', 748)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['bright', 'place_words'], source('wall_grade1', 750)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['brother', 'place_words'], source('wall_grade1', 752)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['butter', 'place_words'], source('wall_grade1', 754)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['button', 'place_words'], source('wall_grade1', 756)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['castle', 'place_words'], source('wall_grade1', 758)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['circle', 'place_words'], source('wall_grade1', 760)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['city', 'place_words'], source('wall_grade1', 762)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['clean', 'place_words'], source('wall_grade1', 764)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['climb', 'place_words'], source('wall_grade1', 766)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['cloud', 'place_words'], source('wall_grade1', 768)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['color', 'place_words'], source('wall_grade1', 770)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['corner', 'place_words'], source('wall_grade1', 772)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['country', 'place_words'], source('wall_grade1', 774)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['cousin', 'place_words'], source('wall_grade1', 776)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['dance', 'place_words'], source('wall_grade1', 778)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['dark', 'place_words'], source('wall_grade1', 780)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['dinner', 'place_words'], source('wall_grade1', 782)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['dragon', 'place_words'], source('wall_grade1', 784)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['dream', 'place_words'], source('wall_grade1', 786)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['early', 'place_words'], source('wall_grade1', 788)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['earth', 'place_words'], source('wall_grade1', 790)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['empty', 'place_words'], source('wall_grade1', 792)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['enough', 'place_words'], source('wall_grade1', 794)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['evening', 'place_words'], source('wall_grade1', 796)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['family', 'place_words'], source('wall_grade1', 798)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['favorite', 'place_words'], source('wall_grade1', 800)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['field', 'place_words'], source('wall_grade1', 802)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['finger', 'place_words'], source('wall_grade1', 804)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['floor', 'place_words'], source('wall_grade1', 806)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['follow', 'place_words'], source('wall_grade1', 808)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['forest', 'place_words'], source('wall_grade1', 810)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['friend', 'place_words'], source('wall_grade1', 812)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['future', 'place_words'], source('wall_grade1', 814)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['giant', 'place_words'], source('wall_grade1', 816)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['grass', 'place_words'], source('wall_grade1', 818)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['ground', 'place_words'], source('wall_grade1', 820)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['happen', 'place_words'], source('wall_grade1', 822)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['history', 'place_words'], source('wall_grade1', 824)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['holiday', 'place_words'], source('wall_grade1', 826)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['hospital', 'place_words'], source('wall_grade1', 828)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['hundred', 'place_words'], source('wall_grade1', 830)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['hungry', 'place_words'], source('wall_grade1', 832)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['island', 'place_words'], source('wall_grade1', 834)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['jacket', 'place_words'], source('wall_grade1', 836)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['kitchen', 'place_words'], source('wall_grade1', 838)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['ladder', 'place_words'], source('wall_grade1', 840)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['letter', 'place_words'], source('wall_grade1', 842)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['machine', 'place_words'], source('wall_grade1', 844)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['market', 'place_words'], source('wall_grade1', 846)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['meadow', 'place_words'], source('wall_grade1', 848)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['minute', 'place_words'], source('wall_grade1', 850)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['mountain', 'place_words'], source('wall_grade1', 852)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['music', 'place_words'], source('wall_grade1', 854)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['nature', 'place_words'], source('wall_grade1', 856)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['neighbor', 'place_words'], source('wall_grade1', 858)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['ocean', 'place_words'], source('wall_grade1', 860)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['orange', 'place_words'], source('wall_grade1', 862)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['people', 'place_words'], source('wall_grade1', 864)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['pocket', 'place_words'], source('wall_grade1', 866)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['present', 'place_words'], source('wall_grade1', 868)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['question', 'place_words'], source('wall_grade1', 870)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['rabbit', 'place_words'], source('wall_grade1', 872)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['rainbow', 'place_words'], source('wall_grade1', 874)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['river', 'place_words'], source('wall_grade1', 876)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['sailor', 'place_words'], source('wall_grade1', 878)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['second', 'place_words'], source('wall_grade1', 880)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['sister', 'place_words'], source('wall_grade1', 882)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['special', 'place_words'], source('wall_grade1', 884)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['spider', 'place_words'], source('wall_grade1', 886)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['summer', 'place_words'], source('wall_grade1', 888)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['sugar', 'place_words'], source('wall_grade1', 890)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['teacher', 'place_words'], source('wall_grade1', 892)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['thunder', 'place_words'], source('wall_grade1', 894)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['tiger', 'place_words'], source('wall_grade1', 896)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['tomorrow', 'place_words'], source('wall_grade1', 898)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['travel', 'place_words'], source('wall_grade1', 900)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['under', 'place_words'], source('wall_grade1', 902)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['village', 'place_words'], source('wall_grade1', 904)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['window', 'place_words'], source('wall_grade1', 906)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['winter', 'place_words'], source('wall_grade1', 908)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['yesterday', 'place_words'], source('wall_grade1', 910)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['stork', 'animals_and_insects'], source('wall_grade1', 927)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['zipper', 'clothing'], source('wall_grade1', 931)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['cellar', 'home_and_objects'], source('wall_grade1', 935)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['cupboard', 'home_and_objects'], source('wall_grade1', 937)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['gate', 'home_and_objects'], source('wall_grade1', 939)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['mattress', 'home_and_objects'], source('wall_grade1', 941)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['suitcase', 'home_and_objects'], source('wall_grade1', 943)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['hammer', 'tools'], source('wall_grade1', 947)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['nail', 'tools'], source('wall_grade1', 949)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['needle', 'tools'], source('wall_grade1', 951)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['pin', 'tools'], source('wall_grade1', 953)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['rake', 'tools'], source('wall_grade1', 955)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['ruler', 'tools'], source('wall_grade1', 957)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['shovel', 'tools'], source('wall_grade1', 959)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['diamond', 'materials'], source('wall_grade1', 963)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['ink', 'materials'], source('wall_grade1', 965)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['iron', 'materials'], source('wall_grade1', 967)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['jewel', 'materials'], source('wall_grade1', 969)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['silver', 'materials'], source('wall_grade1', 971)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['sail', 'vehicles_and_transportation'], source('wall_grade1', 975)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['submarine', 'vehicles_and_transportation'], source('wall_grade1', 977)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['camp', 'places_and_buildings'], source('wall_grade1', 981)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['fountain', 'places_and_buildings'], source('wall_grade1', 983)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['igloo', 'places_and_buildings'], source('wall_grade1', 985)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['office', 'places_and_buildings'], source('wall_grade1', 987)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['sidewalk', 'places_and_buildings'], source('wall_grade1', 989)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['station', 'places_and_buildings'], source('wall_grade1', 991)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['tunnel', 'places_and_buildings'], source('wall_grade1', 993)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['stem', 'nature_weather_and_plants'], source('wall_grade1', 997)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['tornado', 'nature_weather_and_plants'], source('wall_grade1', 999)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['trunk', 'nature_weather_and_plants'], source('wall_grade1', 1001)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['dentist', 'people_and_jobs'], source('wall_grade1', 1005)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['fairy', 'people_and_jobs'], source('wall_grade1', 1007)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['mermaid', 'people_and_jobs'], source('wall_grade1', 1009)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['pilot', 'people_and_jobs'], source('wall_grade1', 1011)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['east', 'directions_and_shapes'], source('wall_grade1', 1015)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['north', 'directions_and_shapes'], source('wall_grade1', 1017)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['rectangle', 'directions_and_shapes'], source('wall_grade1', 1019)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['south', 'directions_and_shapes'], source('wall_grade1', 1021)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['west', 'directions_and_shapes'], source('wall_grade1', 1023)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['cough', 'fun_and_actions'], source('wall_grade1', 1027)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['float', 'fun_and_actions'], source('wall_grade1', 1029)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'vocabulary', ['knot', 'fun_and_actions'], source('wall_grade1', 1031)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['always', 'group_1'], source('wall_grade2', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['another', 'group_1'], source('wall_grade2', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['between', 'group_1'], source('wall_grade2', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['different', 'group_1'], source('wall_grade2', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['important', 'group_1'], source('wall_grade2', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['answer', 'group_2'], source('wall_grade2', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['idea', 'group_2'], source('wall_grade2', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['learn', 'group_2'], source('wall_grade2', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['problem', 'group_2'], source('wall_grade2', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['study', 'group_2'], source('wall_grade2', 62)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['early', 'group_3'], source('wall_grade2', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['never', 'group_3'], source('wall_grade2', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['often', 'group_3'], source('wall_grade2', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['since', 'group_3'], source('wall_grade2', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['until', 'group_3'], source('wall_grade2', 74)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['always', 'common_high_frequency_words'], source('wall_grade2', 85)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['around', 'common_high_frequency_words'], source('wall_grade2', 87)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['been', 'common_high_frequency_words'], source('wall_grade2', 89)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['buy', 'common_high_frequency_words'], source('wall_grade2', 91)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['call', 'common_high_frequency_words'], source('wall_grade2', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['done', 'common_high_frequency_words'], source('wall_grade2', 95)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['found', 'common_high_frequency_words'], source('wall_grade2', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['goes', 'common_high_frequency_words'], source('wall_grade2', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['its', 'common_high_frequency_words'], source('wall_grade2', 101)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['made', 'common_high_frequency_words'], source('wall_grade2', 103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['off', 'common_high_frequency_words'], source('wall_grade2', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['or', 'common_high_frequency_words'], source('wall_grade2', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['pull', 'common_high_frequency_words'], source('wall_grade2', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['right', 'common_high_frequency_words'], source('wall_grade2', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['sing', 'common_high_frequency_words'], source('wall_grade2', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['sit', 'common_high_frequency_words'], source('wall_grade2', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['sleep', 'common_high_frequency_words'], source('wall_grade2', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['tell', 'common_high_frequency_words'], source('wall_grade2', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['their', 'common_high_frequency_words'], source('wall_grade2', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['these', 'common_high_frequency_words'], source('wall_grade2', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['those', 'common_high_frequency_words'], source('wall_grade2', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['upon', 'common_high_frequency_words'], source('wall_grade2', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['use', 'common_high_frequency_words'], source('wall_grade2', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['very', 'common_high_frequency_words'], source('wall_grade2', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['wash', 'common_high_frequency_words'], source('wall_grade2', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['which', 'common_high_frequency_words'], source('wall_grade2', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['wish', 'common_high_frequency_words'], source('wall_grade2', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['write', 'common_high_frequency_words'], source('wall_grade2', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['your', 'common_high_frequency_words'], source('wall_grade2', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['another', 'common_high_frequency_words'], source('wall_grade2', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['answer', 'common_high_frequency_words'], source('wall_grade2', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['behind', 'common_high_frequency_words'], source('wall_grade2', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['below', 'common_high_frequency_words'], source('wall_grade2', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['between', 'common_high_frequency_words'], source('wall_grade2', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['even', 'common_high_frequency_words'], source('wall_grade2', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['follow', 'common_high_frequency_words'], source('wall_grade2', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['front', 'common_high_frequency_words'], source('wall_grade2', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['near', 'common_high_frequency_words'], source('wall_grade2', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['never', 'common_high_frequency_words'], source('wall_grade2', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['often', 'common_high_frequency_words'], source('wall_grade2', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['different', 'academic_words'], source('wall_grade2', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['early', 'academic_words'], source('wall_grade2', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['enough', 'academic_words'], source('wall_grade2', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['important', 'academic_words'], source('wall_grade2', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['idea', 'academic_words'], source('wall_grade2', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['learn', 'academic_words'], source('wall_grade2', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['letter', 'academic_words'], source('wall_grade2', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['money', 'academic_words'], source('wall_grade2', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['order', 'academic_words'], source('wall_grade2', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['page', 'academic_words'], source('wall_grade2', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['paper', 'academic_words'], source('wall_grade2', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['problem', 'academic_words'], source('wall_grade2', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['second', 'academic_words'], source('wall_grade2', 191)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['sentence', 'academic_words'], source('wall_grade2', 193)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['since', 'academic_words'], source('wall_grade2', 195)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['story', 'academic_words'], source('wall_grade2', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['study', 'academic_words'], source('wall_grade2', 199)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['sure', 'academic_words'], source('wall_grade2', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['today', 'academic_words'], source('wall_grade2', 203)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['until', 'academic_words'], source('wall_grade2', 205)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['beach', 'naming_words'], source('wall_grade2', 209)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['bear', 'naming_words'], source('wall_grade2', 211)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['branch', 'naming_words'], source('wall_grade2', 213)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['cave', 'naming_words'], source('wall_grade2', 215)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['cloud', 'naming_words'], source('wall_grade2', 217)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['corn', 'naming_words'], source('wall_grade2', 219)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['desert', 'naming_words'], source('wall_grade2', 221)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['field', 'naming_words'], source('wall_grade2', 223)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['flower', 'naming_words'], source('wall_grade2', 225)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['forest', 'naming_words'], source('wall_grade2', 227)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['grass', 'naming_words'], source('wall_grade2', 229)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['ground', 'naming_words'], source('wall_grade2', 231)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['hill', 'naming_words'], source('wall_grade2', 233)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['insect', 'naming_words'], source('wall_grade2', 235)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['jungle', 'naming_words'], source('wall_grade2', 237)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['lake', 'naming_words'], source('wall_grade2', 239)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['mountain', 'naming_words'], source('wall_grade2', 241)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['ocean', 'naming_words'], source('wall_grade2', 243)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['planet', 'naming_words'], source('wall_grade2', 245)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['rabbit', 'naming_words'], source('wall_grade2', 247)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['river', 'naming_words'], source('wall_grade2', 249)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['road', 'naming_words'], source('wall_grade2', 251)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['robin', 'naming_words'], source('wall_grade2', 253)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['shell', 'naming_words'], source('wall_grade2', 255)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['spider', 'naming_words'], source('wall_grade2', 257)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['valley', 'naming_words'], source('wall_grade2', 259)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['whale', 'naming_words'], source('wall_grade2', 261)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['wing', 'naming_words'], source('wall_grade2', 263)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['wood', 'naming_words'], source('wall_grade2', 265)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['world', 'naming_words'], source('wall_grade2', 267)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['absent', 'time_words'], source('wall_grade2', 638)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['accident', 'time_words'], source('wall_grade2', 640)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['adventure', 'time_words'], source('wall_grade2', 642)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['alphabet', 'time_words'], source('wall_grade2', 644)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['ankle', 'time_words'], source('wall_grade2', 646)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['apartment', 'time_words'], source('wall_grade2', 648)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['athlete', 'time_words'], source('wall_grade2', 650)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['attic', 'time_words'], source('wall_grade2', 652)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['author', 'time_words'], source('wall_grade2', 654)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['balance', 'time_words'], source('wall_grade2', 656)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['bandage', 'time_words'], source('wall_grade2', 658)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['basement', 'time_words'], source('wall_grade2', 660)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['battery', 'time_words'], source('wall_grade2', 662)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['blanket', 'time_words'], source('wall_grade2', 664)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['blossom', 'time_words'], source('wall_grade2', 666)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['boulder', 'time_words'], source('wall_grade2', 668)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['brave', 'time_words'], source('wall_grade2', 670)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['calendar', 'time_words'], source('wall_grade2', 672)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['camera', 'time_words'], source('wall_grade2', 674)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['captain', 'time_words'], source('wall_grade2', 676)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['cardboard', 'time_words'], source('wall_grade2', 678)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['carpenter', 'time_words'], source('wall_grade2', 680)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['century', 'time_words'], source('wall_grade2', 682)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['ceremony', 'time_words'], source('wall_grade2', 684)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['champion', 'time_words'], source('wall_grade2', 686)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['chapter', 'time_words'], source('wall_grade2', 688)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['chimney', 'time_words'], source('wall_grade2', 690)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['collar', 'time_words'], source('wall_grade2', 692)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['compass', 'time_words'], source('wall_grade2', 694)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['cottage', 'time_words'], source('wall_grade2', 696)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['crayon', 'time_words'], source('wall_grade2', 698)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['creature', 'time_words'], source('wall_grade2', 700)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['crystal', 'time_words'], source('wall_grade2', 702)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['curious', 'time_words'], source('wall_grade2', 704)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['customer', 'time_words'], source('wall_grade2', 706)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['decide', 'time_words'], source('wall_grade2', 708)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['delight', 'time_words'], source('wall_grade2', 710)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['desert', 'time_words'], source('wall_grade2', 712)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['dolphin', 'time_words'], source('wall_grade2', 714)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['drawer', 'time_words'], source('wall_grade2', 716)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['elbow', 'time_words'], source('wall_grade2', 718)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['elephant', 'time_words'], source('wall_grade2', 720)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['engine', 'time_words'], source('wall_grade2', 722)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['explore', 'time_words'], source('wall_grade2', 724)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['fabric', 'time_words'], source('wall_grade2', 726)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['factory', 'time_words'], source('wall_grade2', 728)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['feather', 'time_words'], source('wall_grade2', 730)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['festival', 'time_words'], source('wall_grade2', 732)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['gentle', 'time_words'], source('wall_grade2', 734)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['glacier', 'time_words'], source('wall_grade2', 736)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['gravity', 'time_words'], source('wall_grade2', 738)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['harbor', 'time_words'], source('wall_grade2', 740)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['harvest', 'time_words'], source('wall_grade2', 742)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['helmet', 'time_words'], source('wall_grade2', 744)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['hobby', 'time_words'], source('wall_grade2', 746)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['honest', 'time_words'], source('wall_grade2', 748)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['horizon', 'time_words'], source('wall_grade2', 750)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['imagine', 'time_words'], source('wall_grade2', 752)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['invent', 'time_words'], source('wall_grade2', 754)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['journey', 'time_words'], source('wall_grade2', 756)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['kingdom', 'time_words'], source('wall_grade2', 758)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['knowledge', 'time_words'], source('wall_grade2', 760)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['lantern', 'time_words'], source('wall_grade2', 762)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['lizard', 'time_words'], source('wall_grade2', 764)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['magnet', 'time_words'], source('wall_grade2', 766)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['mammal', 'time_words'], source('wall_grade2', 768)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['marble', 'time_words'], source('wall_grade2', 770)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['medicine', 'time_words'], source('wall_grade2', 772)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['mirror', 'time_words'], source('wall_grade2', 774)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['mystery', 'time_words'], source('wall_grade2', 776)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['napkin', 'time_words'], source('wall_grade2', 778)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['nephew', 'time_words'], source('wall_grade2', 780)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['niece', 'time_words'], source('wall_grade2', 782)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['nibble', 'time_words'], source('wall_grade2', 784)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['observe', 'time_words'], source('wall_grade2', 786)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['octopus', 'time_words'], source('wall_grade2', 788)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['orchard', 'time_words'], source('wall_grade2', 790)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['otter', 'time_words'], source('wall_grade2', 792)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['palace', 'time_words'], source('wall_grade2', 794)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['parade', 'time_words'], source('wall_grade2', 796)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['pasture', 'time_words'], source('wall_grade2', 798)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['pebble', 'time_words'], source('wall_grade2', 800)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['penguin', 'time_words'], source('wall_grade2', 802)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['pillow', 'time_words'], source('wall_grade2', 804)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['pirate', 'time_words'], source('wall_grade2', 806)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['pleasant', 'time_words'], source('wall_grade2', 808)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['pumpkin', 'time_words'], source('wall_grade2', 810)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['puzzle', 'time_words'], source('wall_grade2', 812)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['quilt', 'time_words'], source('wall_grade2', 814)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['ribbon', 'time_words'], source('wall_grade2', 816)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['saddle', 'time_words'], source('wall_grade2', 818)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['scissors', 'time_words'], source('wall_grade2', 820)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['shadow', 'time_words'], source('wall_grade2', 822)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['signal', 'time_words'], source('wall_grade2', 824)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['skeleton', 'time_words'], source('wall_grade2', 826)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['telescope', 'time_words'], source('wall_grade2', 828)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['treasure', 'time_words'], source('wall_grade2', 830)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['trumpet', 'time_words'], source('wall_grade2', 832)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['umbrella', 'time_words'], source('wall_grade2', 834)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['volcano', 'time_words'], source('wall_grade2', 836)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['wander', 'time_words'], source('wall_grade2', 838)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'vocabulary', ['whisper', 'time_words'], source('wall_grade2', 840)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['discover', 'group_1'], source('wall_grade3', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['explore', 'group_1'], source('wall_grade3', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['imagine', 'group_1'], source('wall_grade3', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['wonder', 'group_1'], source('wall_grade3', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['curious', 'group_1'], source('wall_grade3', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['describe', 'group_2'], source('wall_grade3', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['explain', 'group_2'], source('wall_grade3', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['compare', 'group_2'], source('wall_grade3', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['observe', 'group_2'], source('wall_grade3', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['predict', 'group_2'], source('wall_grade3', 62)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['decide', 'group_3'], source('wall_grade3', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['consider', 'group_3'], source('wall_grade3', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['remember', 'group_3'], source('wall_grade3', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['realize', 'group_3'], source('wall_grade3', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['understand', 'group_3'], source('wall_grade3', 74)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['appear', 'thinking_and_action_words'], source('wall_grade3', 85)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['arrive', 'thinking_and_action_words'], source('wall_grade3', 87)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['believe', 'thinking_and_action_words'], source('wall_grade3', 89)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['compare', 'thinking_and_action_words'], source('wall_grade3', 91)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['complete', 'thinking_and_action_words'], source('wall_grade3', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['consider', 'thinking_and_action_words'], source('wall_grade3', 95)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['continue', 'thinking_and_action_words'], source('wall_grade3', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['create', 'thinking_and_action_words'], source('wall_grade3', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['decide', 'thinking_and_action_words'], source('wall_grade3', 101)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['describe', 'thinking_and_action_words'], source('wall_grade3', 103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['develop', 'thinking_and_action_words'], source('wall_grade3', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['discover', 'thinking_and_action_words'], source('wall_grade3', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['examine', 'thinking_and_action_words'], source('wall_grade3', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['explain', 'thinking_and_action_words'], source('wall_grade3', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['explore', 'thinking_and_action_words'], source('wall_grade3', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['gather', 'thinking_and_action_words'], source('wall_grade3', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['imagine', 'thinking_and_action_words'], source('wall_grade3', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['increase', 'thinking_and_action_words'], source('wall_grade3', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['invent', 'thinking_and_action_words'], source('wall_grade3', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['measure', 'thinking_and_action_words'], source('wall_grade3', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['notice', 'thinking_and_action_words'], source('wall_grade3', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['observe', 'thinking_and_action_words'], source('wall_grade3', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['predict', 'thinking_and_action_words'], source('wall_grade3', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['prepare', 'thinking_and_action_words'], source('wall_grade3', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['protect', 'thinking_and_action_words'], source('wall_grade3', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['realize', 'thinking_and_action_words'], source('wall_grade3', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['recognize', 'thinking_and_action_words'], source('wall_grade3', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['remember', 'thinking_and_action_words'], source('wall_grade3', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['respect', 'thinking_and_action_words'], source('wall_grade3', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['understand', 'thinking_and_action_words'], source('wall_grade3', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['wonder', 'thinking_and_action_words'], source('wall_grade3', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['ancient', 'describing_words'], source('wall_grade3', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['average', 'describing_words'], source('wall_grade3', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['brave', 'describing_words'], source('wall_grade3', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['calm', 'describing_words'], source('wall_grade3', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['careful', 'describing_words'], source('wall_grade3', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['certain', 'describing_words'], source('wall_grade3', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['curious', 'describing_words'], source('wall_grade3', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['dangerous', 'describing_words'], source('wall_grade3', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['enormous', 'describing_words'], source('wall_grade3', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['excited', 'describing_words'], source('wall_grade3', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['famous', 'describing_words'], source('wall_grade3', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['gentle', 'describing_words'], source('wall_grade3', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['gigantic', 'describing_words'], source('wall_grade3', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['grateful', 'describing_words'], source('wall_grade3', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['important', 'describing_words'], source('wall_grade3', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['natural', 'describing_words'], source('wall_grade3', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['nervous', 'describing_words'], source('wall_grade3', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['ordinary', 'describing_words'], source('wall_grade3', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['peaceful', 'describing_words'], source('wall_grade3', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['popular', 'describing_words'], source('wall_grade3', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['powerful', 'describing_words'], source('wall_grade3', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['serious', 'describing_words'], source('wall_grade3', 191)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['several', 'describing_words'], source('wall_grade3', 193)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['similar', 'describing_words'], source('wall_grade3', 195)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['simple', 'describing_words'], source('wall_grade3', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['special', 'describing_words'], source('wall_grade3', 199)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['strange', 'describing_words'], source('wall_grade3', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['terrible', 'describing_words'], source('wall_grade3', 203)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['although', 'connecting_words'], source('wall_grade3', 207)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['finally', 'connecting_words'], source('wall_grade3', 209)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['however', 'connecting_words'], source('wall_grade3', 211)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['instead', 'connecting_words'], source('wall_grade3', 213)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['perhaps', 'connecting_words'], source('wall_grade3', 215)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['probably', 'connecting_words'], source('wall_grade3', 217)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['suddenly', 'connecting_words'], source('wall_grade3', 219)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['usually', 'connecting_words'], source('wall_grade3', 221)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['adventure', 'naming_words'], source('wall_grade3', 225)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['century', 'naming_words'], source('wall_grade3', 227)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['challenge', 'naming_words'], source('wall_grade3', 229)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['character', 'naming_words'], source('wall_grade3', 231)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['climate', 'naming_words'], source('wall_grade3', 233)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['continent', 'naming_words'], source('wall_grade3', 235)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['courage', 'naming_words'], source('wall_grade3', 237)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['distance', 'naming_words'], source('wall_grade3', 239)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['effort', 'naming_words'], source('wall_grade3', 241)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['energy', 'naming_words'], source('wall_grade3', 243)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['environment', 'naming_words'], source('wall_grade3', 245)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['history', 'naming_words'], source('wall_grade3', 247)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['journey', 'naming_words'], source('wall_grade3', 249)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['knowledge', 'naming_words'], source('wall_grade3', 251)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['language', 'naming_words'], source('wall_grade3', 253)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['machine', 'naming_words'], source('wall_grade3', 255)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['material', 'naming_words'], source('wall_grade3', 257)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['message', 'naming_words'], source('wall_grade3', 259)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['moment', 'naming_words'], source('wall_grade3', 261)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['purpose', 'naming_words'], source('wall_grade3', 263)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['reason', 'naming_words'], source('wall_grade3', 265)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['result', 'naming_words'], source('wall_grade3', 267)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['surface', 'naming_words'], source('wall_grade3', 269)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['telescope', 'naming_words'], source('wall_grade3', 271)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['volcano', 'naming_words'], source('wall_grade3', 273)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['abandon', 'describing_words'], source('wall_grade3', 646)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['absorb', 'describing_words'], source('wall_grade3', 648)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['accurate', 'describing_words'], source('wall_grade3', 650)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['admire', 'describing_words'], source('wall_grade3', 652)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['advice', 'describing_words'], source('wall_grade3', 654)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['ancestor', 'describing_words'], source('wall_grade3', 656)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['announce', 'describing_words'], source('wall_grade3', 658)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['anxious', 'describing_words'], source('wall_grade3', 660)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['apparent', 'describing_words'], source('wall_grade3', 662)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['appreciate', 'describing_words'], source('wall_grade3', 664)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['architect', 'describing_words'], source('wall_grade3', 666)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['assemble', 'describing_words'], source('wall_grade3', 668)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['assist', 'describing_words'], source('wall_grade3', 670)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['astronaut', 'describing_words'], source('wall_grade3', 672)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['attempt', 'describing_words'], source('wall_grade3', 674)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['attract', 'describing_words'], source('wall_grade3', 676)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['avalanche', 'describing_words'], source('wall_grade3', 678)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['barrier', 'describing_words'], source('wall_grade3', 680)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['benefit', 'describing_words'], source('wall_grade3', 682)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['boundary', 'describing_words'], source('wall_grade3', 684)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['burrow', 'describing_words'], source('wall_grade3', 686)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['capable', 'describing_words'], source('wall_grade3', 688)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['capture', 'describing_words'], source('wall_grade3', 690)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['caterpillar', 'describing_words'], source('wall_grade3', 692)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['cautious', 'describing_words'], source('wall_grade3', 694)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['ceremony', 'describing_words'], source('wall_grade3', 696)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['circulate', 'describing_words'], source('wall_grade3', 698)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['coincidence', 'describing_words'], source('wall_grade3', 700)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['collapse', 'describing_words'], source('wall_grade3', 702)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['colony', 'describing_words'], source('wall_grade3', 704)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['communicate', 'describing_words'], source('wall_grade3', 706)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['companion', 'describing_words'], source('wall_grade3', 708)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['concentrate', 'describing_words'], source('wall_grade3', 710)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['conclude', 'describing_words'], source('wall_grade3', 712)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['confident', 'describing_words'], source('wall_grade3', 714)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['confused', 'describing_words'], source('wall_grade3', 716)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['conquer', 'describing_words'], source('wall_grade3', 718)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['construct', 'describing_words'], source('wall_grade3', 720)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['contribute', 'describing_words'], source('wall_grade3', 722)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['cooperate', 'describing_words'], source('wall_grade3', 724)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['creative', 'describing_words'], source('wall_grade3', 726)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['cultivate', 'describing_words'], source('wall_grade3', 728)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['decade', 'describing_words'], source('wall_grade3', 730)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['decorate', 'describing_words'], source('wall_grade3', 732)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['dedicate', 'describing_words'], source('wall_grade3', 734)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['delicate', 'describing_words'], source('wall_grade3', 736)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['demonstrate', 'describing_words'], source('wall_grade3', 738)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['descend', 'describing_words'], source('wall_grade3', 740)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['determine', 'describing_words'], source('wall_grade3', 742)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['disappear', 'describing_words'], source('wall_grade3', 744)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['disaster', 'describing_words'], source('wall_grade3', 746)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['distant', 'describing_words'], source('wall_grade3', 748)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['dribble', 'describing_words'], source('wall_grade3', 750)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['eager', 'describing_words'], source('wall_grade3', 752)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['elegant', 'describing_words'], source('wall_grade3', 754)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['emerge', 'describing_words'], source('wall_grade3', 756)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['encounter', 'describing_words'], source('wall_grade3', 758)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['endanger', 'describing_words'], source('wall_grade3', 760)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['estimate', 'describing_words'], source('wall_grade3', 762)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['evidence', 'describing_words'], source('wall_grade3', 764)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['exhausted', 'describing_words'], source('wall_grade3', 766)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['experiment', 'describing_words'], source('wall_grade3', 768)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['fascinate', 'describing_words'], source('wall_grade3', 770)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['fortunate', 'describing_words'], source('wall_grade3', 772)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['fragile', 'describing_words'], source('wall_grade3', 774)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['frontier', 'describing_words'], source('wall_grade3', 776)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['generous', 'describing_words'], source('wall_grade3', 778)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['genuine', 'describing_words'], source('wall_grade3', 780)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['glimpse', 'describing_words'], source('wall_grade3', 782)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['graceful', 'describing_words'], source('wall_grade3', 784)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['hesitate', 'describing_words'], source('wall_grade3', 786)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['horizon', 'describing_words'], source('wall_grade3', 788)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['identify', 'describing_words'], source('wall_grade3', 790)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['illustrate', 'describing_words'], source('wall_grade3', 792)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['independent', 'describing_words'], source('wall_grade3', 794)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['inhabit', 'describing_words'], source('wall_grade3', 796)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['investigate', 'describing_words'], source('wall_grade3', 798)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['magnificent', 'describing_words'], source('wall_grade3', 800)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['mammal', 'describing_words'], source('wall_grade3', 802)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['migrate', 'describing_words'], source('wall_grade3', 804)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['mineral', 'describing_words'], source('wall_grade3', 806)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['moisture', 'describing_words'], source('wall_grade3', 808)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['navigate', 'describing_words'], source('wall_grade3', 810)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['nutrition', 'describing_words'], source('wall_grade3', 812)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['obstacle', 'describing_words'], source('wall_grade3', 814)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['organism', 'describing_words'], source('wall_grade3', 816)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['participate', 'describing_words'], source('wall_grade3', 818)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['patient', 'describing_words'], source('wall_grade3', 820)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['persuade', 'describing_words'], source('wall_grade3', 822)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['pollinate', 'describing_words'], source('wall_grade3', 824)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['portion', 'describing_words'], source('wall_grade3', 826)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['precious', 'describing_words'], source('wall_grade3', 828)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['reptile', 'describing_words'], source('wall_grade3', 830)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['resource', 'describing_words'], source('wall_grade3', 832)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['scatter', 'describing_words'], source('wall_grade3', 834)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['sturdy', 'describing_words'], source('wall_grade3', 836)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['summit', 'describing_words'], source('wall_grade3', 838)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['survive', 'describing_words'], source('wall_grade3', 840)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['tradition', 'describing_words'], source('wall_grade3', 842)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'vocabulary', ['vibrate', 'describing_words'], source('wall_grade3', 844)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['analyze', 'group_1'], source('wall_grade4', 40)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['conclude', 'group_1'], source('wall_grade4', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['determine', 'group_1'], source('wall_grade4', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['evaluate', 'group_1'], source('wall_grade4', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['examine', 'group_1'], source('wall_grade4', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['evidence', 'group_2'], source('wall_grade4', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['opinion', 'group_2'], source('wall_grade4', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['reason', 'group_2'], source('wall_grade4', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['response', 'group_2'], source('wall_grade4', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['solution', 'group_2'], source('wall_grade4', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['however', 'group_3'], source('wall_grade4', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['therefore', 'group_3'], source('wall_grade4', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['meanwhile', 'group_3'], source('wall_grade4', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['furthermore', 'group_3'], source('wall_grade4', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['nevertheless', 'group_3'], source('wall_grade4', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['accomplish', 'thinking_and_action_words'], source('wall_grade4', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['acquire', 'thinking_and_action_words'], source('wall_grade4', 85)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['analyze', 'thinking_and_action_words'], source('wall_grade4', 87)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['anticipate', 'thinking_and_action_words'], source('wall_grade4', 89)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['approach', 'thinking_and_action_words'], source('wall_grade4', 91)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['assume', 'thinking_and_action_words'], source('wall_grade4', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['collapse', 'thinking_and_action_words'], source('wall_grade4', 95)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['conclude', 'thinking_and_action_words'], source('wall_grade4', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['demonstrate', 'thinking_and_action_words'], source('wall_grade4', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['determine', 'thinking_and_action_words'], source('wall_grade4', 101)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['distinguish', 'thinking_and_action_words'], source('wall_grade4', 103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['emphasize', 'thinking_and_action_words'], source('wall_grade4', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['establish', 'thinking_and_action_words'], source('wall_grade4', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['evaluate', 'thinking_and_action_words'], source('wall_grade4', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['illustrate', 'thinking_and_action_words'], source('wall_grade4', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['indicate', 'thinking_and_action_words'], source('wall_grade4', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['interpret', 'thinking_and_action_words'], source('wall_grade4', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['maintain', 'thinking_and_action_words'], source('wall_grade4', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['obtain', 'thinking_and_action_words'], source('wall_grade4', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['propose', 'thinking_and_action_words'], source('wall_grade4', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['represent', 'thinking_and_action_words'], source('wall_grade4', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['reveal', 'thinking_and_action_words'], source('wall_grade4', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['suggest', 'thinking_and_action_words'], source('wall_grade4', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['survive', 'thinking_and_action_words'], source('wall_grade4', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['abundant', 'describing_words'], source('wall_grade4', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['accurate', 'describing_words'], source('wall_grade4', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['ancient', 'describing_words'], source('wall_grade4', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['complex', 'describing_words'], source('wall_grade4', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['crucial', 'describing_words'], source('wall_grade4', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['definite', 'describing_words'], source('wall_grade4', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['efficient', 'describing_words'], source('wall_grade4', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['essential', 'describing_words'], source('wall_grade4', 147)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['familiar', 'describing_words'], source('wall_grade4', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['frequent', 'describing_words'], source('wall_grade4', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['identical', 'describing_words'], source('wall_grade4', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['intense', 'describing_words'], source('wall_grade4', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['obvious', 'describing_words'], source('wall_grade4', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['precise', 'describing_words'], source('wall_grade4', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['reliable', 'describing_words'], source('wall_grade4', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['sufficient', 'describing_words'], source('wall_grade4', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['tremendous', 'describing_words'], source('wall_grade4', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['various', 'describing_words'], source('wall_grade4', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['vivid', 'describing_words'], source('wall_grade4', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['analysis', 'naming_words'], source('wall_grade4', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['argument', 'naming_words'], source('wall_grade4', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['benefit', 'naming_words'], source('wall_grade4', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['conclusion', 'naming_words'], source('wall_grade4', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['consequence', 'naming_words'], source('wall_grade4', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['evidence', 'naming_words'], source('wall_grade4', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['factor', 'naming_words'], source('wall_grade4', 185)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['function', 'naming_words'], source('wall_grade4', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['influence', 'naming_words'], source('wall_grade4', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['method', 'naming_words'], source('wall_grade4', 191)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['obstacle', 'naming_words'], source('wall_grade4', 193)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['opinion', 'naming_words'], source('wall_grade4', 195)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['process', 'naming_words'], source('wall_grade4', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['region', 'naming_words'], source('wall_grade4', 199)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['resource', 'naming_words'], source('wall_grade4', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['response', 'naming_words'], source('wall_grade4', 203)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['solution', 'naming_words'], source('wall_grade4', 205)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['structure', 'naming_words'], source('wall_grade4', 207)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['theory', 'naming_words'], source('wall_grade4', 209)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['tradition', 'naming_words'], source('wall_grade4', 211)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['consequently', 'connecting_words'], source('wall_grade4', 215)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['furthermore', 'connecting_words'], source('wall_grade4', 217)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['meanwhile', 'connecting_words'], source('wall_grade4', 219)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['moreover', 'connecting_words'], source('wall_grade4', 221)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['nevertheless', 'connecting_words'], source('wall_grade4', 223)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['therefore', 'connecting_words'], source('wall_grade4', 225)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['whereas', 'connecting_words'], source('wall_grade4', 227)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['abolish', 'connecting_words'], source('wall_grade4', 598)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['accustom', 'connecting_words'], source('wall_grade4', 600)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['adequate', 'connecting_words'], source('wall_grade4', 602)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['adjacent', 'connecting_words'], source('wall_grade4', 604)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['alliance', 'connecting_words'], source('wall_grade4', 606)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['altitude', 'connecting_words'], source('wall_grade4', 608)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['ambition', 'connecting_words'], source('wall_grade4', 610)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['ambush', 'connecting_words'], source('wall_grade4', 612)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['amphibian', 'connecting_words'], source('wall_grade4', 614)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['appliance', 'connecting_words'], source('wall_grade4', 616)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['apprentice', 'connecting_words'], source('wall_grade4', 618)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['assemble', 'connecting_words'], source('wall_grade4', 620)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['atmosphere', 'connecting_words'], source('wall_grade4', 622)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['authority', 'connecting_words'], source('wall_grade4', 624)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['autobiography', 'connecting_words'], source('wall_grade4', 626)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['beverage', 'connecting_words'], source('wall_grade4', 628)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['biography', 'connecting_words'], source('wall_grade4', 630)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['boundary', 'connecting_words'], source('wall_grade4', 632)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['brilliant', 'connecting_words'], source('wall_grade4', 634)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['campaign', 'connecting_words'], source('wall_grade4', 636)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['cancel', 'connecting_words'], source('wall_grade4', 638)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['cargo', 'connecting_words'], source('wall_grade4', 640)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['cavity', 'connecting_words'], source('wall_grade4', 642)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['century', 'connecting_words'], source('wall_grade4', 644)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['circulate', 'connecting_words'], source('wall_grade4', 646)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['civilization', 'connecting_words'], source('wall_grade4', 648)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['climate', 'connecting_words'], source('wall_grade4', 650)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['coastline', 'connecting_words'], source('wall_grade4', 652)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['column', 'connecting_words'], source('wall_grade4', 654)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['combustion', 'connecting_words'], source('wall_grade4', 656)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['commerce', 'connecting_words'], source('wall_grade4', 658)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['committee', 'connecting_words'], source('wall_grade4', 660)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['community', 'connecting_words'], source('wall_grade4', 662)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['competition', 'connecting_words'], source('wall_grade4', 664)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['complicate', 'connecting_words'], source('wall_grade4', 666)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['compound', 'connecting_words'], source('wall_grade4', 668)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['condense', 'connecting_words'], source('wall_grade4', 670)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['constellation', 'connecting_words'], source('wall_grade4', 672)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['continent', 'connecting_words'], source('wall_grade4', 674)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['coordinate', 'connecting_words'], source('wall_grade4', 676)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['cultivate', 'connecting_words'], source('wall_grade4', 678)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['currency', 'connecting_words'], source('wall_grade4', 680)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['decompose', 'connecting_words'], source('wall_grade4', 682)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['descendant', 'connecting_words'], source('wall_grade4', 684)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['diameter', 'connecting_words'], source('wall_grade4', 686)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['diplomat', 'connecting_words'], source('wall_grade4', 688)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['document', 'connecting_words'], source('wall_grade4', 690)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['ecosystem', 'connecting_words'], source('wall_grade4', 692)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['elaborate', 'connecting_words'], source('wall_grade4', 694)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['elevation', 'connecting_words'], source('wall_grade4', 696)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['equator', 'connecting_words'], source('wall_grade4', 698)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['erosion', 'connecting_words'], source('wall_grade4', 700)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['exhibit', 'connecting_words'], source('wall_grade4', 702)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['expedition', 'connecting_words'], source('wall_grade4', 704)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['fertile', 'connecting_words'], source('wall_grade4', 706)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['fortunate', 'connecting_words'], source('wall_grade4', 708)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['fossil', 'connecting_words'], source('wall_grade4', 710)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['fugitive', 'connecting_words'], source('wall_grade4', 712)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['gravity', 'connecting_words'], source('wall_grade4', 714)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['habitat', 'connecting_words'], source('wall_grade4', 716)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['hemisphere', 'connecting_words'], source('wall_grade4', 718)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['heritage', 'connecting_words'], source('wall_grade4', 720)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['hibernate', 'connecting_words'], source('wall_grade4', 722)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['ignite', 'connecting_words'], source('wall_grade4', 724)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['immigrant', 'connecting_words'], source('wall_grade4', 726)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['independence', 'connecting_words'], source('wall_grade4', 728)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['industry', 'connecting_words'], source('wall_grade4', 730)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['ingredient', 'connecting_words'], source('wall_grade4', 732)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['landmark', 'connecting_words'], source('wall_grade4', 734)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['latitude', 'connecting_words'], source('wall_grade4', 736)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['legend', 'connecting_words'], source('wall_grade4', 738)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['legislature', 'connecting_words'], source('wall_grade4', 740)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['liberty', 'connecting_words'], source('wall_grade4', 742)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['magnetic', 'connecting_words'], source('wall_grade4', 744)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['majority', 'connecting_words'], source('wall_grade4', 746)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['manufacture', 'connecting_words'], source('wall_grade4', 748)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['migrate', 'connecting_words'], source('wall_grade4', 750)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['molecule', 'connecting_words'], source('wall_grade4', 752)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['monument', 'connecting_words'], source('wall_grade4', 754)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['naturalist', 'connecting_words'], source('wall_grade4', 756)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['negotiate', 'connecting_words'], source('wall_grade4', 758)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['nutrient', 'connecting_words'], source('wall_grade4', 760)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['orbit', 'connecting_words'], source('wall_grade4', 762)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['organism', 'connecting_words'], source('wall_grade4', 764)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['parliament', 'connecting_words'], source('wall_grade4', 766)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['peninsula', 'connecting_words'], source('wall_grade4', 768)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['phenomenon', 'connecting_words'], source('wall_grade4', 770)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['pollution', 'connecting_words'], source('wall_grade4', 772)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['population', 'connecting_words'], source('wall_grade4', 774)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['precipitation', 'connecting_words'], source('wall_grade4', 776)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['predator', 'connecting_words'], source('wall_grade4', 778)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['prehistoric', 'connecting_words'], source('wall_grade4', 780)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['republic', 'connecting_words'], source('wall_grade4', 782)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['revolution', 'connecting_words'], source('wall_grade4', 784)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['sediment', 'connecting_words'], source('wall_grade4', 786)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['temperature', 'connecting_words'], source('wall_grade4', 788)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['territory', 'connecting_words'], source('wall_grade4', 790)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['vapor', 'connecting_words'], source('wall_grade4', 792)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['vegetation', 'connecting_words'], source('wall_grade4', 794)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'vocabulary', ['voyage', 'connecting_words'], source('wall_grade4', 796)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['significant', 'group_1'], source('wall_grade5', 40)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['perspective', 'group_1'], source('wall_grade5', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['evidence', 'group_1'], source('wall_grade5', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['objective', 'group_1'], source('wall_grade5', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['insight', 'group_1'], source('wall_grade5', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['acknowledge', 'group_2'], source('wall_grade5', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['justify', 'group_2'], source('wall_grade5', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['persuade', 'group_2'], source('wall_grade5', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['assert', 'group_2'], source('wall_grade5', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['convey', 'group_2'], source('wall_grade5', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['comprehend', 'group_3'], source('wall_grade5', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['perceive', 'group_3'], source('wall_grade5', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['deduce', 'group_3'], source('wall_grade5', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['infer', 'group_3'], source('wall_grade5', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['interpret', 'group_3'], source('wall_grade5', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['accelerate', 'thinking_and_action_words'], source('wall_grade5', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['acknowledge', 'thinking_and_action_words'], source('wall_grade5', 85)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['assert', 'thinking_and_action_words'], source('wall_grade5', 87)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['comprehend', 'thinking_and_action_words'], source('wall_grade5', 89)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['conceive', 'thinking_and_action_words'], source('wall_grade5', 91)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['consist', 'thinking_and_action_words'], source('wall_grade5', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['convey', 'thinking_and_action_words'], source('wall_grade5', 95)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['deduce', 'thinking_and_action_words'], source('wall_grade5', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['derive', 'thinking_and_action_words'], source('wall_grade5', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['devise', 'thinking_and_action_words'], source('wall_grade5', 101)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['diminish', 'thinking_and_action_words'], source('wall_grade5', 103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['dominate', 'thinking_and_action_words'], source('wall_grade5', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['eliminate', 'thinking_and_action_words'], source('wall_grade5', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['emerge', 'thinking_and_action_words'], source('wall_grade5', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['enhance', 'thinking_and_action_words'], source('wall_grade5', 111)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['ensure', 'thinking_and_action_words'], source('wall_grade5', 113)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['exceed', 'thinking_and_action_words'], source('wall_grade5', 115)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['exclude', 'thinking_and_action_words'], source('wall_grade5', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['generate', 'thinking_and_action_words'], source('wall_grade5', 119)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['justify', 'thinking_and_action_words'], source('wall_grade5', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['modify', 'thinking_and_action_words'], source('wall_grade5', 123)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['monitor', 'thinking_and_action_words'], source('wall_grade5', 125)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['perceive', 'thinking_and_action_words'], source('wall_grade5', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['persist', 'thinking_and_action_words'], source('wall_grade5', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['pursue', 'thinking_and_action_words'], source('wall_grade5', 131)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['reinforce', 'thinking_and_action_words'], source('wall_grade5', 133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['restore', 'thinking_and_action_words'], source('wall_grade5', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['retain', 'thinking_and_action_words'], source('wall_grade5', 137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['sustain', 'thinking_and_action_words'], source('wall_grade5', 139)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['transform', 'thinking_and_action_words'], source('wall_grade5', 141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['utilize', 'thinking_and_action_words'], source('wall_grade5', 143)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['vary', 'thinking_and_action_words'], source('wall_grade5', 145)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['ambiguous', 'describing_words'], source('wall_grade5', 149)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['apparent', 'describing_words'], source('wall_grade5', 151)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['appropriate', 'describing_words'], source('wall_grade5', 153)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['coherent', 'describing_words'], source('wall_grade5', 155)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['diverse', 'describing_words'], source('wall_grade5', 157)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['equivalent', 'describing_words'], source('wall_grade5', 159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['inevitable', 'describing_words'], source('wall_grade5', 161)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['prior', 'describing_words'], source('wall_grade5', 163)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['profound', 'describing_words'], source('wall_grade5', 165)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['prominent', 'describing_words'], source('wall_grade5', 167)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['random', 'describing_words'], source('wall_grade5', 169)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['reluctant', 'describing_words'], source('wall_grade5', 171)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['significant', 'describing_words'], source('wall_grade5', 173)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['stable', 'describing_words'], source('wall_grade5', 175)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['subtle', 'describing_words'], source('wall_grade5', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['uniform', 'describing_words'], source('wall_grade5', 179)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['valid', 'describing_words'], source('wall_grade5', 181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['widespread', 'describing_words'], source('wall_grade5', 183)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['capacity', 'naming_words'], source('wall_grade5', 187)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['characteristic', 'naming_words'], source('wall_grade5', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['circumstance', 'naming_words'], source('wall_grade5', 191)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['criteria', 'naming_words'], source('wall_grade5', 193)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['dimension', 'naming_words'], source('wall_grade5', 195)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['hierarchy', 'naming_words'], source('wall_grade5', 197)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['hypothesis', 'naming_words'], source('wall_grade5', 199)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['incentive', 'naming_words'], source('wall_grade5', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['insight', 'naming_words'], source('wall_grade5', 203)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['mechanism', 'naming_words'], source('wall_grade5', 205)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['notion', 'naming_words'], source('wall_grade5', 207)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['objective', 'naming_words'], source('wall_grade5', 209)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['perspective', 'naming_words'], source('wall_grade5', 211)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['phenomenon', 'naming_words'], source('wall_grade5', 213)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['scenario', 'naming_words'], source('wall_grade5', 215)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['sequence', 'naming_words'], source('wall_grade5', 217)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['status', 'naming_words'], source('wall_grade5', 219)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['theme', 'naming_words'], source('wall_grade5', 221)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['vision', 'naming_words'], source('wall_grade5', 223)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['accordingly', 'connecting_words'], source('wall_grade5', 227)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['subsequently', 'connecting_words'], source('wall_grade5', 229)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['thereby', 'connecting_words'], source('wall_grade5', 231)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['abstract', 'change_words'], source('wall_grade5', 602)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['accommodate', 'change_words'], source('wall_grade5', 604)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['adequate', 'change_words'], source('wall_grade5', 606)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['advocate', 'change_words'], source('wall_grade5', 608)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['allocate', 'change_words'], source('wall_grade5', 610)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['alternative', 'change_words'], source('wall_grade5', 612)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['analogy', 'change_words'], source('wall_grade5', 614)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['anonymous', 'change_words'], source('wall_grade5', 616)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['arbitrary', 'change_words'], source('wall_grade5', 618)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['aspect', 'change_words'], source('wall_grade5', 620)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['assemble', 'change_words'], source('wall_grade5', 622)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['attribute', 'change_words'], source('wall_grade5', 624)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['biased', 'change_words'], source('wall_grade5', 626)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['calculate', 'change_words'], source('wall_grade5', 628)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['category', 'change_words'], source('wall_grade5', 630)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['cease', 'change_words'], source('wall_grade5', 632)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['collaborate', 'change_words'], source('wall_grade5', 634)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['commence', 'change_words'], source('wall_grade5', 636)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['compensate', 'change_words'], source('wall_grade5', 638)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['complement', 'change_words'], source('wall_grade5', 640)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['component', 'change_words'], source('wall_grade5', 642)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['comprise', 'change_words'], source('wall_grade5', 644)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['conform', 'change_words'], source('wall_grade5', 646)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['consequence', 'change_words'], source('wall_grade5', 648)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['considerable', 'change_words'], source('wall_grade5', 650)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['consistent', 'change_words'], source('wall_grade5', 652)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['constitute', 'change_words'], source('wall_grade5', 654)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['contradict', 'change_words'], source('wall_grade5', 656)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['controversy', 'change_words'], source('wall_grade5', 658)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['correspond', 'change_words'], source('wall_grade5', 660)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['cumulative', 'change_words'], source('wall_grade5', 662)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['deficient', 'change_words'], source('wall_grade5', 664)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['definite', 'change_words'], source('wall_grade5', 666)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['deliberate', 'change_words'], source('wall_grade5', 668)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['denote', 'change_words'], source('wall_grade5', 670)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['designate', 'change_words'], source('wall_grade5', 672)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['deteriorate', 'change_words'], source('wall_grade5', 674)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['dilemma', 'change_words'], source('wall_grade5', 676)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['discrete', 'change_words'], source('wall_grade5', 678)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['dispute', 'change_words'], source('wall_grade5', 680)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['distort', 'change_words'], source('wall_grade5', 682)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['elaborate', 'change_words'], source('wall_grade5', 684)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['endure', 'change_words'], source('wall_grade5', 686)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['equivalent', 'change_words'], source('wall_grade5', 688)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['evident', 'change_words'], source('wall_grade5', 690)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['exaggerate', 'change_words'], source('wall_grade5', 692)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['exceed', 'change_words'], source('wall_grade5', 694)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['exploit', 'change_words'], source('wall_grade5', 696)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['facilitate', 'change_words'], source('wall_grade5', 698)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['fluctuate', 'change_words'], source('wall_grade5', 700)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['formulate', 'change_words'], source('wall_grade5', 702)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['fundamental', 'change_words'], source('wall_grade5', 704)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['hostile', 'change_words'], source('wall_grade5', 706)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['ideology', 'change_words'], source('wall_grade5', 708)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['implement', 'change_words'], source('wall_grade5', 710)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['implication', 'change_words'], source('wall_grade5', 712)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['incline', 'change_words'], source('wall_grade5', 714)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['incorporate', 'change_words'], source('wall_grade5', 716)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['indifferent', 'change_words'], source('wall_grade5', 718)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['inhibit', 'change_words'], source('wall_grade5', 720)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['initiate', 'change_words'], source('wall_grade5', 722)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['innovate', 'change_words'], source('wall_grade5', 724)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['integrate', 'change_words'], source('wall_grade5', 726)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['intervene', 'change_words'], source('wall_grade5', 728)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['intricate', 'change_words'], source('wall_grade5', 730)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['legitimate', 'change_words'], source('wall_grade5', 732)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['manipulate', 'change_words'], source('wall_grade5', 734)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['margin', 'change_words'], source('wall_grade5', 736)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['mediate', 'change_words'], source('wall_grade5', 738)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['minimize', 'change_words'], source('wall_grade5', 740)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['negate', 'change_words'], source('wall_grade5', 742)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['neutral', 'change_words'], source('wall_grade5', 744)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['nominal', 'change_words'], source('wall_grade5', 746)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['notorious', 'change_words'], source('wall_grade5', 748)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['offset', 'change_words'], source('wall_grade5', 750)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['ongoing', 'change_words'], source('wall_grade5', 752)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['optimistic', 'change_words'], source('wall_grade5', 754)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['overlap', 'change_words'], source('wall_grade5', 756)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['paradox', 'change_words'], source('wall_grade5', 758)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['phase', 'change_words'], source('wall_grade5', 760)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['precede', 'change_words'], source('wall_grade5', 762)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['predominant', 'change_words'], source('wall_grade5', 764)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['presume', 'change_words'], source('wall_grade5', 766)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['prohibit', 'change_words'], source('wall_grade5', 768)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['prospect', 'change_words'], source('wall_grade5', 770)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['provoke', 'change_words'], source('wall_grade5', 772)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['reciprocal', 'change_words'], source('wall_grade5', 774)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['reluctance', 'change_words'], source('wall_grade5', 776)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['reverse', 'change_words'], source('wall_grade5', 778)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['scrutinize', 'change_words'], source('wall_grade5', 780)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['simulate', 'change_words'], source('wall_grade5', 782)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['spontaneous', 'change_words'], source('wall_grade5', 784)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['subordinate', 'change_words'], source('wall_grade5', 786)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['supplement', 'change_words'], source('wall_grade5', 788)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['suppress', 'change_words'], source('wall_grade5', 790)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['terminate', 'change_words'], source('wall_grade5', 792)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['transmit', 'change_words'], source('wall_grade5', 794)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['undergo', 'change_words'], source('wall_grade5', 796)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['verify', 'change_words'], source('wall_grade5', 798)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['versatile', 'change_words'], source('wall_grade5', 800)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'vocabulary', ['vigorous', 'change_words'], source('wall_grade5', 802)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'math_domain', ['number and operations in base ten', '3.NBT'], source('ccss_math', 298)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'math_domain', ['counting and cardinality', 'K.CC'], source('ccss_math', 557)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'math_domain', ['operations and algebraic thinking', 'K.OA'], source('ccss_math', 581)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'math_domain', ['number and operations in base ten', 'K.NBT'], source('ccss_math', 604)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten', 'math_domain', ['measurement and data', 'K.MD'], source('ccss_math', 612)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'math_domain', ['operations and algebraic thinking', '1.OA'], source('ccss_math', 719)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'math_domain', ['number and operations in base ten', '1.NBT'], source('ccss_math', 749)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade1', 'math_domain', ['measurement and data', '1.MD'], source('ccss_math', 782)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'math_domain', ['operations and algebraic thinking', '2.OA'], source('ccss_math', 876)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'math_domain', ['number and operations in base ten', '2.NBT'], source('ccss_math', 894)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade2', 'math_domain', ['measurement and data', '2.MD'], source('ccss_math', 928)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'math_domain', ['operations and algebraic thinking', '3.OA'], source('ccss_math', 1057)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade3', 'math_domain', ['measurement and data', '3.MD'], source('ccss_math', 1133)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'math_domain', ['operations and algebraic thinking', '4.OA'], source('ccss_math', 1266)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade4', 'math_domain', ['measurement and data', '4.MD'], source('ccss_math', 1364)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'math_domain', ['operations and algebraic thinking', '5.OA'], source('ccss_math', 1489)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'math_domain', ['number and operations in base ten', '5.NBT'], source('ccss_math', 1507)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('grade5', 'math_domain', ['measurement and data', '5.MD'], source('ccss_math', 1588)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten_to_grade5', 'ela_strand', ['reading_literature'], source('ccss_ela', 105)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten_to_grade5', 'ela_strand', ['reading_informational_text'], source('ccss_ela', 106)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten_to_grade5', 'ela_strand', ['reading_foundational_skills'], source('ccss_ela', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten_to_grade5', 'ela_strand', ['writing'], source('ccss_ela', 110)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten_to_grade5', 'ela_strand', ['speaking_and_listening'], source('ccss_ela', 114)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('kindergarten_to_grade5', 'ela_strand', ['language'], source('ccss_ela', 117)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['approaches_to_learning', '1.0', 'motivation to learn'], source('ptklf_approaches', 37)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '1.1', 'curiosity and interest'], source('ptklf_approaches', 39)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '1.2', 'initiative'], source('ptklf_approaches', 41)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '1.3', 'engagement'], source('ptklf_approaches', 43)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '1.4', 'persisting despite difficulties'], source('ptklf_approaches', 45)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['approaches_to_learning', '2.0', 'executive functioning'], source('ptklf_approaches', 47)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '2.1', 'working memory'], source('ptklf_approaches', 49)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '2.2', 'managing impulsive behaviors'], source('ptklf_approaches', 51)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '2.3', 'managing attention and distractions'], source('ptklf_approaches', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '2.4', 'flexibility'], source('ptklf_approaches', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['approaches_to_learning', '3.0', 'goal-directed learning'], source('ptklf_approaches', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '3.1', 'planning'], source('ptklf_approaches', 62)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '3.2', 'reflecting and analyzing'], source('ptklf_approaches', 63)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '3.3', 'problem-solving together'], source('ptklf_approaches', 65)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['approaches_to_learning', '3.4', 'understanding others'], source('ptklf_approaches', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['social_emotional_development', '1.0', 'self'], source('ptklf_social_emot', 39)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '1.1', 'self-identity'], source('ptklf_social_emot', 41)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '1.2', 'confidence in abilities'], source('ptklf_social_emot', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '1.3', 'understanding emotions in self and others'], source('ptklf_social_emot', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '1.4', 'regulating emotions, behaviors, and stress'], source('ptklf_social_emot', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '1.5', 'managing routines and transitions'], source('ptklf_social_emot', 47)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '1.6', 'awareness of similarities and differences across people'], source('ptklf_social_emot', 49)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '1.7', 'understanding other people’s thoughts, behaviors, and experiences'], source('ptklf_social_emot', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '1.8', 'empathy and caring'], source('ptklf_social_emot', 51)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['social_emotional_development', '2.0', 'interactions and relationships with adults'], source('ptklf_social_emot', 53)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '2.1', 'reciprocal interactions with adults'], source('ptklf_social_emot', 55)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '2.2', 'seeking security and support'], source('ptklf_social_emot', 63)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '2.3', 'coping with departures'], source('ptklf_social_emot', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '2.4', 'relationships with adults'], source('ptklf_social_emot', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['social_emotional_development', '3.0', 'interactions and relationships with peers'], source('ptklf_social_emot', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '3.1', 'interacting and cooperating with peers'], source('ptklf_social_emot', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '3.2', 'conflict resolution with peers'], source('ptklf_social_emot', 71)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '3.3', 'fairness and respect'], source('ptklf_social_emot', 73)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['social_emotional_development', '3.4', 'developing friendships'], source('ptklf_social_emot', 75)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['language_literacy_development', '1.0', 'listening and speaking'], source('ptklf_language', 41)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.1', 'understanding and using vocabulary'], source('ptklf_language', 43)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.2', 'understanding and using words for categories'], source('ptklf_language', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.3', 'understanding and using size and location words'], source('ptklf_language', 45)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.4', 'using grammatical features and sentence structure'], source('ptklf_language', 47)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.5', 'asking questions'], source('ptklf_language', 49)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.6', 'constructing narratives'], source('ptklf_language', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.7', 'sharing explanations and opinions'], source('ptklf_language', 51)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.8', 'participating in conversations'], source('ptklf_language', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['language_literacy_development', '2.0', 'foundational literacy skills'], source('ptklf_language', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '2.1', 'isolating initial sounds'], source('ptklf_language', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '2.2', 'recognizing and blending sounds'], source('ptklf_language', 63)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '2.3', 'participating in rhyming and wordplay'], source('ptklf_language', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '2.4', 'identifying letters'], source('ptklf_language', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '2.5', 'learning letter–sound correspondence'], source('ptklf_language', 67)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '2.6', 'understanding the concept of print'], source('ptklf_language', 69)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '2.7', 'understanding print conventions'], source('ptklf_language', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['language_literacy_development', '3.0', 'reading'], source('ptklf_language', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '3.1', 'demonstrating interest in literacy activities'], source('ptklf_language', 74)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '3.2', 'understanding stories'], source('ptklf_language', 76)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '3.3', 'understanding informational text'], source('ptklf_language', 77)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['language_literacy_development', '4.0', 'writing'], source('ptklf_language', 79)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '4.1', 'developing fine motor skills in writing'], source('ptklf_language', 81)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '4.2', 'writing to represent sounds'], source('ptklf_language', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '4.4', 'writing to represent words or ideas'], source('ptklf_language', 85)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '4.5', 'writing own name'], source('ptklf_language', 86)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.1', 'understanding words'], source('ptklf_language', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.2', 'using words'], source('ptklf_language', 94)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.3', 'using grammatical features'], source('ptklf_language', 96)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.4', 'using complex sentence structures'], source('ptklf_language', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.5', 'communicating needs'], source('ptklf_language', 99)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.6', 'understanding requests and directions'], source('ptklf_language', 106)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.7', 'asking questions'], source('ptklf_language', 107)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.8', 'constructing narratives'], source('ptklf_language', 108)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.9', 'sharing explanations and opinions'], source('ptklf_language', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.10', 'participating in conversations'], source('ptklf_language', 110)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '2.1', 'recognizing and segmenting sounds'], source('ptklf_language', 114)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '2.4', 'recognizing and identifying letters'], source('ptklf_language', 118)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '3.2', 'participating in read-aloud activities'], source('ptklf_language', 127)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '3.3', 'understanding stories'], source('ptklf_language', 129)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '3.4', 'understanding informational text'], source('ptklf_language', 130)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '4.1', 'writing to represent words or ideas'], source('ptklf_language', 134)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '4.2', 'writing own name'], source('ptklf_language', 135)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '1.8', 'participating in conversationss'], source('ptklf_language', 1572)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['language_literacy_development', '4.5', 'writing to represent words or ideas'], source('ptklf_language', 3160)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['mathematics', '1.0', 'counting and cardinality'], source('ptklf_math', 34)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '1.1', 'reciting numbers'], source('ptklf_math', 36)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '1.2', 'one-to-one correspondence'], source('ptklf_math', 37)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '1.3', 'cardinality'], source('ptklf_math', 38)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '1.4', 'subitize'], source('ptklf_math', 40)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '1.5', 'numeral recognition'], source('ptklf_math', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '1.6', 'number comparison'], source('ptklf_math', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['mathematics', '2.0', 'operations and algebraic thinking'], source('ptklf_math', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '2.1', 'principles of addition and subtraction'], source('ptklf_math', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '2.2', 'number composition and decomposition'], source('ptklf_math', 49)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '2.3', 'solving addition and subtraction problems'], source('ptklf_math', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '2.4', 'sharing objects (division)'], source('ptklf_math', 51)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '2.5', 'sorting and classifying'], source('ptklf_math', 57)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '2.6', 'recognizing, duplicating, and extending patterns'], source('ptklf_math', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '2.7', 'creating patterns'], source('ptklf_math', 59)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['mathematics', '3.0', 'measurement and data'], source('ptklf_math', 61)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '3.1', 'comparing measurable attributes of objects'], source('ptklf_math', 63)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '3.2', 'ordering objects'], source('ptklf_math', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '3.3', 'measuring length'], source('ptklf_math', 65)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '3.4', 'representing data'], source('ptklf_math', 67)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '3.5', 'interpreting data'], source('ptklf_math', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['mathematics', '4.0', 'geometry and spatial thinking'], source('ptklf_math', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '4.1', 'identifying two-dimensional shapes'], source('ptklf_math', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '4.2', 'identifying three-dimensional shapes'], source('ptklf_math', 73)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '4.3', 'comparing two-dimensional shapes'], source('ptklf_math', 74)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '4.4', 'composing shapes'], source('ptklf_math', 75)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '4.5', 'positions and directions in space'], source('ptklf_math', 77)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['mathematics', '4.6', 'mental rotation'], source('ptklf_math', 78)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['science', '1.0', 'science and engineering practices'], source('ptklf_science', 33)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '1.1', 'making observations'], source('ptklf_science', 35)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '1.2', 'comparing and contrasting'], source('ptklf_science', 36)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '1.3', 'asking questions'], source('ptklf_science', 37)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '1.4', 'defining problems'], source('ptklf_science', 38)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '1.5', 'making predictions'], source('ptklf_science', 39)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '1.6', 'planning and carrying out investigations'], source('ptklf_science', 40)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '1.7', 'using tools'], source('ptklf_science', 41)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '1.8', 'documenting observations and using models'], source('ptklf_science', 43)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '1.9', 'mathematical thinking and analyzing data'], source('ptklf_science', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '1.10', 'formulating and communicating explanations and solutions'], source('ptklf_science', 45)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['science', '2.0', 'physical science'], source('ptklf_science', 47)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '2.1', 'characteristics of objects and materials'], source('ptklf_science', 49)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '2.2', 'light and sound waves'], source('ptklf_science', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '2.3', 'exploring changes in objects and materials'], source('ptklf_science', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '2.4', 'force and motion'], source('ptklf_science', 57)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '2.5', 'energy'], source('ptklf_science', 58)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['science', '3.0', 'life science'], source('ptklf_science', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '3.1', 'characteristics of living things'], source('ptklf_science', 62)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '3.2', 'bodily processes'], source('ptklf_science', 63)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '3.3', 'living and nonliving things'], source('ptklf_science', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '3.4', 'heredity and traits'], source('ptklf_science', 65)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '3.5', 'habitats'], source('ptklf_science', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '3.7', 'needs of living things'], source('ptklf_science', 69)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['science', '4.0', 'earth and space science'], source('ptklf_science', 71)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '4.1', 'characteristics of earth materials'], source('ptklf_science', 73)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '4.2', 'natural objects in the sky'], source('ptklf_science', 75)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '4.3', 'weather'], source('ptklf_science', 76)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '4.4', 'earth and human activity'], source('ptklf_science', 77)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['science', '5.0', 'engineering, technology, and applications of science'], source('ptklf_science', 79)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '5.1', 'engineering design process'], source('ptklf_science', 81)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '5.2', 'design solutions and society'], source('ptklf_science', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['science', '5.3', 'using digital devices'], source('ptklf_science', 84)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['physical_development', '1.0', 'fundamental movement skills'], source('ptklf_physical', 36)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '1.1', 'balancing while still'], source('ptklf_physical', 38)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '1.2', 'balancing in motion'], source('ptklf_physical', 39)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '1.3', 'walking with balance'], source('ptklf_physical', 41)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '1.4', 'running'], source('ptklf_physical', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '1.5', 'jumping'], source('ptklf_physical', 43)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '1.6', 'varied locomotor skills'], source('ptklf_physical', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '1.7', 'gross motor manipulative skills'], source('ptklf_physical', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '1.8', 'fine motor manipulative skills'], source('ptklf_physical', 47)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '1.9', 'hand preference'], source('ptklf_physical', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['physical_development', '2.0', 'perceptual–motor skills and movement concepts'], source('ptklf_physical', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '2.1', 'knowledge of body parts'], source('ptklf_physical', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '2.2', 'spatial awareness'], source('ptklf_physical', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '2.3', 'directional understanding'], source('ptklf_physical', 61)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '2.4', 'directional movement'], source('ptklf_physical', 62)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '2.5', 'object locations'], source('ptklf_physical', 63)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['physical_development', '3.0', 'active physical play'], source('ptklf_physical', 65)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '3.1', 'physical activity'], source('ptklf_physical', 67)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '3.2', 'cardiovascular endurance'], source('ptklf_physical', 69)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['physical_development', '3.3', 'strength, endurance, and flexibility'], source('ptklf_physical', 71)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['health', '1.0', 'understanding health and wellness'], source('ptklf_health', 35)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '1.1', 'identifying and naming body parts'], source('ptklf_health', 37)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '1.2', 'communicating about health needs'], source('ptklf_health', 38)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '1.3', 'understanding the role of health care providers'], source('ptklf_health', 39)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '1.4', 'recognizing and communicating about body boundaries'], source('ptklf_health', 41)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '1.5', 'identifying foods'], source('ptklf_health', 43)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '1.6', 'communicating fullness and hunger'], source('ptklf_health', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '1.7', 'understanding a variety of foods'], source('ptklf_health', 45)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '1.8', 'recognizing the body’s response to physical activity'], source('ptklf_health', 47)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '1.9', 'recognizing and indicating when tired'], source('ptklf_health', 49)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['health', '2.0', 'health and safety habits'], source('ptklf_health', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '2.1', 'handwashing'], source('ptklf_health', 56)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '2.2', 'preventing infectious diseases'], source('ptklf_health', 57)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '2.3', 'toothbrushing'], source('ptklf_health', 59)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '2.4', 'practicing sun safety'], source('ptklf_health', 61)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '2.5', 'following safety rules'], source('ptklf_health', 63)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '2.6', 'following emergency routines'], source('ptklf_health', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['health', '2.7', 'following transportation and pedestrian safety rules'], source('ptklf_health', 65)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['history_social_science', '1.0', 'social inquiry skills'], source('ptklf_history', 36)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '1.1', 'making observations and asking questions'], source('ptklf_history', 38)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '1.2', 'gathering and using evidence'], source('ptklf_history', 39)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '1.3', 'creating representations'], source('ptklf_history', 41)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['history_social_science', '2.0', 'self and social systems'], source('ptklf_history', 43)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '2.1', 'self-identity'], source('ptklf_history', 45)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '2.2', 'membership in communities'], source('ptklf_history', 46)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '2.3', 'awareness of social roles'], source('ptklf_history', 47)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '2.4', 'exploring cultural communities'], source('ptklf_history', 49)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '2.5', 'exploring similarities and differences'], source('ptklf_history', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['history_social_science', '3.0', 'skills for democracy and being a community member (civics)'], source('ptklf_history', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '3.1', 'identifying and including members of peer groups'], source('ptklf_history', 54)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '3.2', 'showing care and offering help'], source('ptklf_history', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '3.3', 'understanding different needs and fairness'], source('ptklf_history', 61)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '3.4', 'contributing to the group'], source('ptklf_history', 63)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '3.5', 'following community rules and norms'], source('ptklf_history', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '3.6', 'group decision-making'], source('ptklf_history', 66)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '3.7', 'collective problem-solving'], source('ptklf_history', 67)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '3.8', 'developing solutions and taking action'], source('ptklf_history', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['history_social_science', '4.0', 'time, continuity, and change'], source('ptklf_history', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '4.1', 'using time order words'], source('ptklf_history', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '4.2', 'describing change over time'], source('ptklf_history', 74)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '4.3', 'recalling past events'], source('ptklf_history', 76)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['history_social_science', '5.0', 'sense of place and environment'], source('ptklf_history', 78)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '5.1', 'identifying characteristics of locations'], source('ptklf_history', 80)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '5.2', 'communicating locations and directions'], source('ptklf_history', 81)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '5.3', 'understanding physical space through drawings,'], source('ptklf_history', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '5.4', 'caring for the world'], source('ptklf_history', 86)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['history_social_science', '6.0', 'economic systems'], source('ptklf_history', 88)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '6.1', 'meeting community needs'], source('ptklf_history', 90)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '6.2', 'awareness of people at work'], source('ptklf_history', 91)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '6.3', 'understanding exchange'], source('ptklf_history', 93)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['history_social_science', '3.0', 'skills for democracy and being a community'], source('ptklf_history', 1060)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['history_social_science', '5.3', 'understanding physical space through drawings, building materials,'], source('ptklf_history', 1778)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['visual_performing_arts', '1.0', 'visual arts'], source('ptklf_arts', 35)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '1.1', 'attending to and engaging in visual arts'], source('ptklf_arts', 37)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '1.2', 'communicating about art forms and elements'], source('ptklf_arts', 38)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '1.3', 'drawing or painting lines and curves'], source('ptklf_arts', 40)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '1.4', 'working with dough or clay'], source('ptklf_arts', 41)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '1.5', 'using visual arts materials'], source('ptklf_arts', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '1.6', 'communicating visual arts terms'], source('ptklf_arts', 43)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '1.7', 'demonstrating motor control'], source('ptklf_arts', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '1.8', 'mixing and blending colors'], source('ptklf_arts', 45)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '1.9', 'creating two-dimensional and three-dimensional representations'], source('ptklf_arts', 47)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '1.10', 'intensity and mood'], source('ptklf_arts', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['visual_performing_arts', '2.0', 'music'], source('ptklf_arts', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '2.1', 'attending to and engaging in music'], source('ptklf_arts', 52)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '2.2', 'responding to music with body movements'], source('ptklf_arts', 53)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '2.3', 'recognizing sounds and vibrations'], source('ptklf_arts', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '2.4', 'exploring vocal expression and instruments'], source('ptklf_arts', 61)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '2.5', 'exploring beat and rhythmic awareness'], source('ptklf_arts', 62)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '2.6', 'communicating music terms'], source('ptklf_arts', 63)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '2.7', 'producing or improvising melodies and rhythms'], source('ptklf_arts', 65)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['visual_performing_arts', '3.0', 'drama'], source('ptklf_arts', 67)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '3.1', 'engaging in drama'], source('ptklf_arts', 69)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '3.2', 'understanding plot'], source('ptklf_arts', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '3.3', 'showing emotions'], source('ptklf_arts', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '3.4', 'acting out prompts or scripts'], source('ptklf_arts', 73)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '3.5', 'engaging in role-play'], source('ptklf_arts', 74)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '3.6', 'vocal projection'], source('ptklf_arts', 75)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '3.7', 'communicating drama terms'], source('ptklf_arts', 76)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '3.8', 'using props or costumes'], source('ptklf_arts', 78)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '3.9', 'creating scripts'], source('ptklf_arts', 79)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['visual_performing_arts', '4.0', 'dance'], source('ptklf_arts', 81)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '4.1', 'attending to and engaging in dance'], source('ptklf_arts', 83)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '4.2', 'spatial awareness and coordination'], source('ptklf_arts', 85)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '4.3', 'responding to tempo'], source('ptklf_arts', 86)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '4.4', 'learning basic dance skills'], source('ptklf_arts', 87)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '4.5', 'communicating dance terms'], source('ptklf_arts', 88)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '4.6', 'representation through dance'], source('ptklf_arts', 90)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '4.7', 'inventing and improvising dance'], source('ptklf_arts', 91)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['visual_performing_arts', '4.8', 'communicating feelings through dance'], source('ptklf_arts', 92)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '1.0', 'motivation to learn'], source('ptklf_at_a_glance', 19)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '2.0', 'executive functioning'], source('ptklf_at_a_glance', 20)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '3.0', 'goal-directed learning'], source('ptklf_at_a_glance', 21)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '1.0', 'self'], source('ptklf_at_a_glance', 24)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '2.0', 'interactions and relationships with adults'], source('ptklf_at_a_glance', 25)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '3.0', 'interactions and relationships with peers'], source('ptklf_at_a_glance', 26)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '1.0', 'listening and speaking'], source('ptklf_at_a_glance', 29)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '2.0', 'foundational literacy skills'], source('ptklf_at_a_glance', 30)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '3.0', 'reading'], source('ptklf_at_a_glance', 31)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '4.0', 'writing'], source('ptklf_at_a_glance', 32)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '1.0', 'counting and cardinality'], source('ptklf_at_a_glance', 41)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '2.0', 'operations and algebraic thinking'], source('ptklf_at_a_glance', 42)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '3.0', 'measurement and data'], source('ptklf_at_a_glance', 43)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '4.0', 'geometry and spatial thinking'], source('ptklf_at_a_glance', 44)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '1.0', 'science and engineering practices'], source('ptklf_at_a_glance', 47)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '2.0', 'physical science'], source('ptklf_at_a_glance', 48)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '3.0', 'life science'], source('ptklf_at_a_glance', 49)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '4.0', 'earth and space science'], source('ptklf_at_a_glance', 50)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '5.0', 'engineering, technology, and applications of science'], source('ptklf_at_a_glance', 51)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '1.0', 'fundamental movement skills'], source('ptklf_at_a_glance', 59)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '2.0', 'perceptual–motor skills and movement concepts'], source('ptklf_at_a_glance', 60)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '3.0', 'active physical play'], source('ptklf_at_a_glance', 61)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '1.0', 'understanding health and wellness'], source('ptklf_at_a_glance', 64)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '2.0', 'health and safety habits'], source('ptklf_at_a_glance', 65)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '1.0', 'social inquiry skills'], source('ptklf_at_a_glance', 68)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '2.0', 'self and social systems'], source('ptklf_at_a_glance', 69)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '3.0', 'skills for democracy and being a community member (civics)'], source('ptklf_at_a_glance', 70)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '4.0', 'time, continuity, and change'], source('ptklf_at_a_glance', 71)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '5.0', 'sense of place and environment'], source('ptklf_at_a_glance', 72)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '6.0', 'economic systems'], source('ptklf_at_a_glance', 73)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '1.0', 'visual arts'], source('ptklf_at_a_glance', 76)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '2.0', 'music'], source('ptklf_at_a_glance', 77)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '3.0', 'drama'], source('ptklf_at_a_glance', 78)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '4.0', 'dance'], source('ptklf_at_a_glance', 79)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.1', 'curiosity and interest'], source('ptklf_at_a_glance', 97)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.2', 'initiative'], source('ptklf_at_a_glance', 109)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.3', 'engagement'], source('ptklf_at_a_glance', 121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.4', 'persisting despite difficulties'], source('ptklf_at_a_glance', 134)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.1', 'working memory'], source('ptklf_at_a_glance', 150)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.2', 'managing impulsive behaviors'], source('ptklf_at_a_glance', 162)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.3', 'managing attention and distractions'], source('ptklf_at_a_glance', 177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.4', 'flexibility'], source('ptklf_at_a_glance', 189)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.1', 'planning'], source('ptklf_at_a_glance', 201)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.2', 'reflecting and analyzing'], source('ptklf_at_a_glance', 210)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.3', 'problem-solving together'], source('ptklf_at_a_glance', 224)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.4', 'understanding others'], source('ptklf_at_a_glance', 233)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.1', 'self-identity'], source('ptklf_at_a_glance', 252)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.2', 'confidence in abilities'], source('ptklf_at_a_glance', 264)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.3', 'understanding emotions in self and others'], source('ptklf_at_a_glance', 276)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.4', 'regulating emotions, behaviors, and stress'], source('ptklf_at_a_glance', 293)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.5', 'managing routines and transitions'], source('ptklf_at_a_glance', 303)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.6', 'awareness of similarities and differences across people'], source('ptklf_at_a_glance', 315)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.7', 'understanding other people’s thoughts, behaviors, and experiences'], source('ptklf_at_a_glance', 325)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.8', 'empathy and caring'], source('ptklf_at_a_glance', 339)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.1', 'reciprocal interactions with adults'], source('ptklf_at_a_glance', 353)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.2', 'seeking security and support'], source('ptklf_at_a_glance', 365)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.3', 'coping with departures'], source('ptklf_at_a_glance', 382)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.4', 'relationships with adults'], source('ptklf_at_a_glance', 395)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.1', 'interacting and cooperating with peers'], source('ptklf_at_a_glance', 410)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.2', 'conflict resolution with peers'], source('ptklf_at_a_glance', 423)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.3', 'fairness and respect'], source('ptklf_at_a_glance', 434)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.4', 'developing friendships'], source('ptklf_at_a_glance', 445)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.1', 'understanding and using vocabulary'], source('ptklf_at_a_glance', 464)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.2', 'understanding and using words for categories'], source('ptklf_at_a_glance', 473)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.3', 'understanding and using size and location words'], source('ptklf_at_a_glance', 481)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.4', 'using grammatical features and sentence structure*'], source('ptklf_at_a_glance', 496)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.5', 'asking questions'], source('ptklf_at_a_glance', 504)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.6', 'constructing narratives'], source('ptklf_at_a_glance', 513)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.7', 'sharing explanations and opinions'], source('ptklf_at_a_glance', 521)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.8', 'participating in conversations'], source('ptklf_at_a_glance', 539)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.1', 'isolating initial sounds'], source('ptklf_at_a_glance', 552)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.2', 'recognizing and blending sounds*'], source('ptklf_at_a_glance', 560)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.3', 'participating in rhyming and wordplay'], source('ptklf_at_a_glance', 568)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.4', 'identifying letters*'], source('ptklf_at_a_glance', 588)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.5', 'learning letter–sound correspondence'], source('ptklf_at_a_glance', 601)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.6', 'understanding the concept of print'], source('ptklf_at_a_glance', 616)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.7', 'understanding print conventions'], source('ptklf_at_a_glance', 634)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.1', 'demonstrating interest in literacy activities'], source('ptklf_at_a_glance', 645)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.2', 'understanding stories'], source('ptklf_at_a_glance', 656)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.3', 'understanding informational text'], source('ptklf_at_a_glance', 677)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.1', 'developing fine motor skills in writing'], source('ptklf_at_a_glance', 690)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.2', 'writing to represent sounds*'], source('ptklf_at_a_glance', 699)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.4', 'writing to represent words or ideas*'], source('ptklf_at_a_glance', 726)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.5', 'writing own name'], source('ptklf_at_a_glance', 733)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.1', 'understanding words'], source('ptklf_at_a_glance', 756)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.2', 'using words'], source('ptklf_at_a_glance', 769)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.3', 'using grammatical features'], source('ptklf_at_a_glance', 783)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.4', 'using complex sentence structures'], source('ptklf_at_a_glance', 798)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.5', 'communicating needs'], source('ptklf_at_a_glance', 819)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.6', 'understanding requests and directions'], source('ptklf_at_a_glance', 831)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.7', 'asking questions'], source('ptklf_at_a_glance', 845)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.8', 'constructing narratives'], source('ptklf_at_a_glance', 855)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.9', 'sharing explanations and opinions'], source('ptklf_at_a_glance', 864)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.10', 'participating in conversations'], source('ptklf_at_a_glance', 873)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.1', 'recognizing and segmenting sounds'], source('ptklf_at_a_glance', 894)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.2', 'recognizing and blending sounds'], source('ptklf_at_a_glance', 905)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.4', 'recognizing and identifying letters'], source('ptklf_at_a_glance', 936)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.2', 'participating in read-aloud activities'], source('ptklf_at_a_glance', 1003)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.3', 'understanding stories'], source('ptklf_at_a_glance', 1021)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.4', 'understanding informational text'], source('ptklf_at_a_glance', 1034)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.1', 'writing to represent words or ideas'], source('ptklf_at_a_glance', 1051)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.2', 'writing own name*'], source('ptklf_at_a_glance', 1065)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.1', 'reciting numbers'], source('ptklf_at_a_glance', 1086)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.2', 'one-to-one correspondence'], source('ptklf_at_a_glance', 1094)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.3', 'cardinality'], source('ptklf_at_a_glance', 1103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.4', 'subitize'], source('ptklf_at_a_glance', 1116)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.5', 'numeral recognition'], source('ptklf_at_a_glance', 1128)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.6', 'number comparison'], source('ptklf_at_a_glance', 1137)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.1', 'principles of addition and subtraction'], source('ptklf_at_a_glance', 1150)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.2', 'number composition and decomposition'], source('ptklf_at_a_glance', 1159)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.3', 'solving addition and subtraction problems'], source('ptklf_at_a_glance', 1172)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.4', 'sharing objects (division)'], source('ptklf_at_a_glance', 1180)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.5', 'sorting and classifying'], source('ptklf_at_a_glance', 1192)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.6', 'recognizing, duplicating, and extending patterns'], source('ptklf_at_a_glance', 1203)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.7', 'creating patterns'], source('ptklf_at_a_glance', 1216)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.1', 'comparing measurable attributes of objects'], source('ptklf_at_a_glance', 1228)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.2', 'ordering objects'], source('ptklf_at_a_glance', 1237)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.3', 'measuring length'], source('ptklf_at_a_glance', 1245)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.4', 'representing data'], source('ptklf_at_a_glance', 1259)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.5', 'interpreting data'], source('ptklf_at_a_glance', 1270)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.1', 'identifying two-dimensional shapes'], source('ptklf_at_a_glance', 1282)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.2', 'identifying three-dimensional shapes'], source('ptklf_at_a_glance', 1297)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.3', 'comparing two-dimensional shapes'], source('ptklf_at_a_glance', 1307)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.4', 'composing shapes'], source('ptklf_at_a_glance', 1318)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.5', 'positions and directions in space'], source('ptklf_at_a_glance', 1331)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.6', 'mental rotation'], source('ptklf_at_a_glance', 1343)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.1', 'making observations'], source('ptklf_at_a_glance', 1360)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.2', 'comparing and contrasting'], source('ptklf_at_a_glance', 1368)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.3', 'asking questions'], source('ptklf_at_a_glance', 1377)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.4', 'defining problems'], source('ptklf_at_a_glance', 1386)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.5', 'making predictions'], source('ptklf_at_a_glance', 1398)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.6', 'planning and carrying out investigations'], source('ptklf_at_a_glance', 1409)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.7', 'using tools'], source('ptklf_at_a_glance', 1420)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.8', 'documenting observations and using models'], source('ptklf_at_a_glance', 1432)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.9', 'mathematical thinking and analyzing data'], source('ptklf_at_a_glance', 1445)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.10', 'formulating and communicating explanations and solutions'], source('ptklf_at_a_glance', 1456)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.1', 'characteristics of objects and materials'], source('ptklf_at_a_glance', 1470)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.2', 'light and sound waves'], source('ptklf_at_a_glance', 1479)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.3', 'exploring changes in objects and materials'], source('ptklf_at_a_glance', 1490)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.4', 'force and motion'], source('ptklf_at_a_glance', 1503)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.5', 'energy'], source('ptklf_at_a_glance', 1514)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.1', 'characteristics of living things'], source('ptklf_at_a_glance', 1528)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.2', 'bodily processes'], source('ptklf_at_a_glance', 1541)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.3', 'living and nonliving things'], source('ptklf_at_a_glance', 1552)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.4', 'heredity and traits'], source('ptklf_at_a_glance', 1562)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.5', 'habitats'], source('ptklf_at_a_glance', 1570)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.7', 'needs of living things'], source('ptklf_at_a_glance', 1594)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.1', 'characteristics of earth materials'], source('ptklf_at_a_glance', 1607)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.2', 'natural objects in the sky'], source('ptklf_at_a_glance', 1620)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.3', 'weather'], source('ptklf_at_a_glance', 1629)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.4', 'earth and human activity'], source('ptklf_at_a_glance', 1638)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '5.1', 'engineering design process'], source('ptklf_at_a_glance', 1654)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '5.2', 'design solutions and society'], source('ptklf_at_a_glance', 1669)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '5.3', 'using digital devices'], source('ptklf_at_a_glance', 1679)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.1', 'balancing while still'], source('ptklf_at_a_glance', 1698)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.2', 'balancing in motion'], source('ptklf_at_a_glance', 1705)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.3', 'walking with balance'], source('ptklf_at_a_glance', 1716)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.4', 'running'], source('ptklf_at_a_glance', 1727)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.5', 'jumping'], source('ptklf_at_a_glance', 1741)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.6', 'varied locomotor skills'], source('ptklf_at_a_glance', 1751)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.7', 'gross motor manipulative skills'], source('ptklf_at_a_glance', 1763)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.8', 'fine motor manipulative skills'], source('ptklf_at_a_glance', 1772)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.9', 'hand preference'], source('ptklf_at_a_glance', 1785)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.1', 'knowledge of body parts'], source('ptklf_at_a_glance', 1797)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.2', 'spatial awareness'], source('ptklf_at_a_glance', 1806)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.3', 'directional understanding'], source('ptklf_at_a_glance', 1817)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.4', 'directional movement'], source('ptklf_at_a_glance', 1829)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.5', 'object locations'], source('ptklf_at_a_glance', 1837)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.1', 'physical activity'], source('ptklf_at_a_glance', 1849)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.2', 'cardiovascular endurance'], source('ptklf_at_a_glance', 1858)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.3', 'strength, endurance, and flexibility'], source('ptklf_at_a_glance', 1873)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.1', 'identifying and naming body parts'], source('ptklf_at_a_glance', 1889)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.2', 'communicating about health needs'], source('ptklf_at_a_glance', 1900)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.3', 'understanding the role of health care providers'], source('ptklf_at_a_glance', 1909)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.4', 'recognizing and communicating about body boundaries'], source('ptklf_at_a_glance', 1921)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.5', 'identifying foods'], source('ptklf_at_a_glance', 1938)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.6', 'communicating fullness and hunger'], source('ptklf_at_a_glance', 1946)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.7', 'understanding a variety of foods'], source('ptklf_at_a_glance', 1959)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.8', 'recognizing the body’s response to physical activity'], source('ptklf_at_a_glance', 1971)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.9', 'recognizing and indicating when tired'], source('ptklf_at_a_glance', 1986)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.1', 'handwashing'], source('ptklf_at_a_glance', 2002)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.2', 'preventing infectious diseases'], source('ptklf_at_a_glance', 2009)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.3', 'toothbrushing'], source('ptklf_at_a_glance', 2019)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.4', 'practicing sun safety'], source('ptklf_at_a_glance', 2031)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.5', 'following safety rules'], source('ptklf_at_a_glance', 2043)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.6', 'following emergency routines'], source('ptklf_at_a_glance', 2052)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.7', 'following transportation and pedestrian safety rules'], source('ptklf_at_a_glance', 2061)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.1', 'making observations and asking questions'], source('ptklf_at_a_glance', 2080)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.2', 'gathering and using evidence'], source('ptklf_at_a_glance', 2089)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.3', 'creating representations'], source('ptklf_at_a_glance', 2103)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.1', 'self-identity'], source('ptklf_at_a_glance', 2121)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.2', 'membership in communities'], source('ptklf_at_a_glance', 2130)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.3', 'awareness of social roles'], source('ptklf_at_a_glance', 2141)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.4', 'exploring cultural communities'], source('ptklf_at_a_glance', 2154)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.5', 'exploring similarities and differences'], source('ptklf_at_a_glance', 2164)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_strand', ['at_a_glance', '3.0', 'skills for democracy and being a community member'], source('ptklf_at_a_glance', 2177)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.1', 'identifying and including members of peer groups'], source('ptklf_at_a_glance', 2181)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.2', 'showing care and offering help'], source('ptklf_at_a_glance', 2194)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.3', 'understanding different needs and fairness'], source('ptklf_at_a_glance', 2204)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.4', 'contributing to the group'], source('ptklf_at_a_glance', 2217)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.5', 'following community rules and norms'], source('ptklf_at_a_glance', 2226)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.6', 'group decision-making'], source('ptklf_at_a_glance', 2240)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.7', 'collective problem-solving'], source('ptklf_at_a_glance', 2250)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.8', 'developing solutions and taking action'], source('ptklf_at_a_glance', 2259)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.1', 'using time order words'], source('ptklf_at_a_glance', 2272)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.2', 'describing change over time'], source('ptklf_at_a_glance', 2286)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.3', 'recalling past events'], source('ptklf_at_a_glance', 2297)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '5.1', 'identifying characteristics of locations'], source('ptklf_at_a_glance', 2311)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '5.2', 'communicating locations and directions'], source('ptklf_at_a_glance', 2324)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '5.3', 'understanding physical space through drawings, building materials, and'], source('ptklf_at_a_glance', 2336)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '5.4', 'caring for the world'], source('ptklf_at_a_glance', 2349)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '6.1', 'meeting community needs'], source('ptklf_at_a_glance', 2369)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '6.2', 'awareness of people at work'], source('ptklf_at_a_glance', 2379)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '6.3', 'understanding exchange'], source('ptklf_at_a_glance', 2390)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.1', 'attending to and engaging in visual arts'], source('ptklf_at_a_glance', 2409)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.2', 'communicating about art forms and elements'], source('ptklf_at_a_glance', 2420)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.3', 'drawing or painting lines and curves'], source('ptklf_at_a_glance', 2432)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.4', 'working with dough or clay'], source('ptklf_at_a_glance', 2446)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.5', 'using visual arts materials'], source('ptklf_at_a_glance', 2454)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.6', 'communicating visual arts terms'], source('ptklf_at_a_glance', 2464)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.7', 'demonstrating motor control'], source('ptklf_at_a_glance', 2472)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.8', 'mixing and blending colors'], source('ptklf_at_a_glance', 2480)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.9', 'creating two-dimensional and three-dimensional representations'], source('ptklf_at_a_glance', 2493)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '1.10', 'intensity and mood'], source('ptklf_at_a_glance', 2503)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.1', 'attending to and engaging in music'], source('ptklf_at_a_glance', 2516)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.2', 'responding to music with body movements'], source('ptklf_at_a_glance', 2531)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.3', 'recognizing sounds and vibrations'], source('ptklf_at_a_glance', 2542)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.4', 'exploring vocal expression and instruments'], source('ptklf_at_a_glance', 2552)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.5', 'exploring beat and rhythmic awareness'], source('ptklf_at_a_glance', 2562)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.6', 'communicating music terms'], source('ptklf_at_a_glance', 2575)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '2.7', 'producing or improvising melodies and rhythms'], source('ptklf_at_a_glance', 2586)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.1', 'engaging in drama'], source('ptklf_at_a_glance', 2599)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.2', 'understanding plot'], source('ptklf_at_a_glance', 2613)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.3', 'showing emotions'], source('ptklf_at_a_glance', 2622)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.4', 'acting out prompts or scripts'], source('ptklf_at_a_glance', 2629)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.5', 'engaging in role-play'], source('ptklf_at_a_glance', 2638)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.6', 'vocal projection'], source('ptklf_at_a_glance', 2646)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.7', 'communicating drama terms'], source('ptklf_at_a_glance', 2657)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.8', 'using props or costumes'], source('ptklf_at_a_glance', 2667)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '3.9', 'creating scripts'], source('ptklf_at_a_glance', 2676)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.1', 'attending to and engaging in dance'], source('ptklf_at_a_glance', 2692)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.2', 'spatial awareness and coordination'], source('ptklf_at_a_glance', 2705)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.3', 'responding to tempo'], source('ptklf_at_a_glance', 2713)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.4', 'learning basic dance skills'], source('ptklf_at_a_glance', 2720)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.5', 'communicating dance terms'], source('ptklf_at_a_glance', 2732)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.6', 'representation through dance'], source('ptklf_at_a_glance', 2744)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.7', 'inventing and improvising dance'], source('ptklf_at_a_glance', 2751)).
% A grounded curriculum fact cited to a real reference-library line.
ci_fact('preschool_tk', 'ptklf_foundation', ['at_a_glance', '4.8', 'communicating feelings through dance'], source('ptklf_at_a_glance', 2760)).

% ---- Sound causal_relation_objects: a subject makes a sound (cause -> effect) ----
% A learned sound relation: the subject produces the sound.
ci_causal_relation_object('toddler', makes_sound, 'dog', 'woof', source('wall_toddler', 378)).
% A learned sound relation: the subject produces the sound.
ci_causal_relation_object('toddler', makes_sound, 'cat', 'meow', source('wall_toddler', 380)).
% A learned sound relation: the subject produces the sound.
ci_causal_relation_object('toddler', makes_sound, 'cow', 'moo', source('wall_toddler', 382)).
% A learned sound relation: the subject produces the sound.
ci_causal_relation_object('toddler', makes_sound, 'duck', 'quack', source('wall_toddler', 384)).
% A learned sound relation: the subject produces the sound.
ci_causal_relation_object('toddler', makes_sound, 'car', 'beep', source('wall_toddler', 386)).
