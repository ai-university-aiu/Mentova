THIS REPOSITORY IS Mentova

Mentova is the world's first synthetic mind written in PrologAI. It depends on the PrologAI
platform: https://github.com/ai-university-aiu/PrologAI. The Demonstration and
Proof-of-Concept Plan (PrologAI Volume 6, docs/PrologAI_6_Demonstration_Mentova_v3.txt in the
PrologAI repository) governs how Mentova is born, proven, and grown.

This CONSTITUTION.md holds Mentova's own repository-specific rules. The organization-wide
policies that apply to every ai-university-aiu repository (attribution, authorship,
copyright, published-works notice, English Readable Code, whole-word naming, branch-and-pull-
request discipline, six-file documentation, archive, style) live in the one organization
CLAUDE.md at /home/ccaitwo/CLAUDE.md. The rules below are how Mentova applies and extends
those policies, plus the file paths and methodology specific to this repository.


AUTHOR - ALL PAPERS AND ANNOUNCEMENTS

Every paper (papers/Acc_N_*.txt) and every announcement (announcements/Acc_N_*_LinkedIn.txt)
must carry this author line:

    Author: D. R. Dison, Founder of AIU (Artificial Intelligence University).
    Creator and Owner of PrologAI and Mentova. Open Researcher and Contributor ID
    (ORCID): 0009-0001-9246-5758. (https://www.linkedin.com/in/d-r-dison/)

No artificial-intelligence tools are credited as authors or co-authors anywhere.


COPYRIGHT ACKNOWLEDGMENT - END OF EVERY PAPER

Every paper (papers/Acc_N_*.txt) must end with this block, verbatim, as the very last
content in the file:

    Copyright (C) 2026 by D. R. Dison (LinkedIn) All rights reserved. No part of this work may be reproduced, stored in a retrieval system, or transmitted in any form or by any means, electronic, mechanical, photocopying, recording, or otherwise, without the prior written permission of the publisher, D. R. Dison, except as provided by U.S. Copyright Law or for the use of brief quotations in a review. Acknowledgment: This work was produced with the aid of various technological tools, including Work Processing Tools (WPT), Desktop Publishing Tools (DPT), Image Processing Tools (IPT), and Artificial Intelligence Tools (AIT).


PUBLISHED WORKS - NOTICE FILE ONLY

The author's published works (books, papers, YouTube channel) must appear ONLY in the NOTICE
file of the PrologAI repository. They must never appear in any paper, announcement, README,
source file, or any other file in this repository or any other repository.


ACCOMPLISHMENT NUMBERING

Papers and announcements share a sequential tracking number: Acc_1, Acc_2, and so on. Each
number corresponds to one accomplished reasoning rung, practical track milestone, or flagship
demonstration.

A paper or announcement is written only after the accomplishment has been achieved and its
result measured. Never ahead of the evidence.


DIRECTORY LAYOUT

    knowledge/        Small-World Commonsense knowledge base
    bodies/           Body configurations (text I/O, game, ROS 2 robot)
    constitution/     Constitution instance (8 principles, 1 overseer)
    src/mentova/      Bootstrap entry point and runtime predicates
    papers/           Scientific papers - one per accomplishment (Acc_N_...)
    announcements/    LinkedIn announcements - one per accomplishment (Acc_N_..._LinkedIn.txt)


ELEMENT NAMES

Element names are original to PrologAI; do not introduce source-origin terms.


README UPDATE RULE

After any significant update to the Mentova codebase - new accomplishment, new benchmark
result, new protocol support, new growth path milestone closed - update README.md in the
Mentova repository root to reflect the change. The README must always show the current state:
accurate accomplishment count, current ARC-AGI scores, growth path status, and up-to-date
capability descriptions. This update goes in the same PR as the code change.


ARC-AGI-3 PROGRESS LOG RULE

As Mentova climbs ARC-AGI-3, every piece of ARC-AGI-3 work must append a dated progress entry
to papers/Climbing_ARC-AGI-3.txt - a living scientific chronicle of the ascent. Record
ESPECIALLY the wins, and also the learnings, the methodology, and the course corrections.
Entries are APPENDED (never rewrite or delete earlier entries), newest last, each dated and
tagged WIN, LEARNING, METHODOLOGY, or COURSE CORRECTION; a WIN entry is written only for a
real, measured result and names the game, the levels completed, the action efficiency, and
the glass-box behaviours that produced it. This append goes in the SAME PR as the ARC-AGI-3
work. Stay evidence-first: no leaderboard score is recorded in the paper until it is really
measured on the live ARC-AGI-3 leaderboard, and the ARC-AGI-3 Perfect Score report
(papers/ARC-AGI-3_Perfect_Score_Report.txt) is written ONLY after such measured wins - never
ahead of the evidence. The paper carries the standard author byline (like the other Climbing_
papers); it does not carry the Acc_N copyright block.


UI PALETTE RULE

Every page the server serves uses one warm palette - crimson, red, gold, yellow, limoncello,
light yellow, dark red (dark-red backgrounds; light-yellow/gold text; crimson/yellow/
limoncello accents; no cool colours in the chrome). Chat pages get it from CSS variables
overridden with !important at the end of assets/chat/chat.css (bump chat.css?v=N when it
changes); the ARC pages set it inline. The ARC game grid COLORS map keeps the standard ARC
cell colours (game data, not chrome). See docs/UI_Conventions.txt.


UI BUTTON RULE

Every HTML page the Mentova server serves must include the shared script
`/assets/common/press.js` once, just before `</body>`. It gives every button (and select) on
the page a pressed-inverted visual: while the mouse button is held down on a button its
colours invert, and on release the colour first reverts to normal and THEN the action fires
(the invert is on mouseup, the action on the following click); dragging off a held button
reverts it without firing. New pages MUST include this one line and MUST NOT re-implement
per-page pressed styling. See docs/UI_Conventions.txt.


PR MERGE RULE

After creating a PR on this repository, merge it immediately using
`gh pr merge <number> --squash --delete-branch`. No confirmation is needed for PRs that you
authored. Do NOT auto-merge PRs opened by other contributors or external bots; those require
explicit human approval before merging.


ARCHIVE RULE

Old versions of versioned documents never stay in docs/ (or in mentova-chat-docs/). Whenever
a new version of a versioned document is created (the five SPARC volumes, the MCD living chat
documents, or any future versioned series), move the superseded version into the sibling
archive/ folder (docs/archive/ or mentova-chat-docs/archive/) with git mv IN THE SAME CHANGE.
Additionally, on every document update, sweep for stragglers: for each series, if more than
one version is present, move all but the highest version into archive/. Only the latest
version of each series may live outside archive/. (Enforced repo-wide on 2026-07-10: 395 old
SPARC versions archived, PR #461; same rule enforced in PrologAI via its PR #498.)


AUTO-BUILD RULE

Build every recommendation and suggestion going forward without waiting for further approval.
When a piece of work surfaces a next step, an improvement, or a lever worth pulling, implement
it (feature branch, PR, tests, docs, merge) rather than only proposing it. The standing
authorization covers the whole growth path; do not pause to ask "should I build this?" for
work that clearly advances Mentova. Reserve questions for genuine forks the user alone can
resolve (see the interactive-question guidance). Outward-facing or hard-to-reverse actions
still get the usual care.


WORK SUMMARY RULE

Document every unit of work in a plain-text work summary at
/home/ccaitwo/claude_work_summaries/[yyyy-mm-dd_hh-mm_title].txt (the directory is outside the
repos and is created if absent; timestamps are the local time the work landed, title is a
short kebab or underscore slug). Each summary records what was asked, what was built, the
PRs/commits, the tests and their results, and what remains. Write one per work order (or per
coherent piece of a large order). These are a running log of the work; they are NOT committed
to the repositories.


CONSULT-THE-GOLDEN-FILE-WHEN-STUCK RULE (ARC-AGI-3)

Whenever stuck decoding a game's mechanic or a specific level (a commit signal, a
windowing/two-tier layout, a target-correspondence, and so on), STOP probing and RE-READ that
game's unified GOLDEN GAME ENVIRONMENT REFERENCE FILE (/home/ccaitwo/ARC-AGI-3/<game>.txt) in
full first - it holds the practical mentor guide followed by the distilled per-game research
from all ten drafts, and it cracked the sb26 and ft09 level mechanics already. If the golden
file lacks material for the specific level, also check the source drafts
(ARC-AGI-3_Steps_Draft_1..10), then resume probing informed by whatever they say. Mine the
reference before spending live-probe budget. (Adopted 2026-07-12.)


BRIDGE-THEN-ALTERNATE RULE (ARC-AGI-3)

Per game, run two phases. PHASE BRIDGE = "BRIDGE ONLY": the mentor repeats AI Mentor Bridge
runs back-to-back (bridge, bridge, bridge, and so on) - each attempt informed by the previous
attempt's saved notes and the game's GOLDEN reference file loaded into J-Space - until the
MENTOR achieves status:won for that game; only then persist the learnings to disk. PHASE SOLO
= "SOLO OBSERVED AND COACHED": the Solo player plays while the mentor OBSERVES each run via
Observe_Game_Play_Run and COACHES between runs (adds clues, rules, functions/code, and
Causalontology lattice writes drawn from what the observation showed it was missing),
repeating Solo-run-then-coach until the SOLO run achieves status:won UNAIDED. Only when Solo
reaches unaided status:won does the next Game Environment begin. Report to the user at EVERY
status change: the game, the phase, the current total win count, and games_completed (how many
of the 25 have reached Solo status:won). (Adopted 2026-07-11; framing refined 2026-07-11.
Works with the ONE-GAME-AT-A-TIME RULE and the GOLDEN GAME ENVIRONMENT REFERENCE RULE.)


WEB-RESEARCH-BEFORE-NEW-GAME RULE (ARC-AGI-3)

Before starting any new Game Environment, run an EXHAUSTIVE, comprehensive, thorough web
internet search on "ARC-AGI-3 xxxx" (the game name) - all possible locations, including
discussion forums where humans talk about the game (Reddit, Discord, Hacker News, Kaggle, X,
blogs, GitHub) and ESPECIALLY the engine-source mirror
(github.com/axobase001/arc-agi-games and any successor mirror), which has proven to be the
gold: reading the game's engine source (its step() and win-check logic) yields the true
mechanic when forums are silent. Append the findings to that game's
/home/ccaitwo/ARC-AGI-3/xxxx.txt GOLDEN file under a dated "WEB RESEARCH ADDENDUM" header
BEFORE play begins, then use them. The ft09 and sb26 addenda from the 2026-07-12 search are
the template (ft09 = per-clue local relational conjunction; sb26 = tape/program-execution
with a call stack). (Adopted 2026-07-12. Composes with the GOLDEN GAME ENVIRONMENT REFERENCE
RULE and CONSULT-THE-GOLDEN-FILE-WHEN-STUCK RULE.)


GOLDEN GAME ENVIRONMENT REFERENCE RULE (ARC-AGI-3)

For each of the 25 games there is a single unified GOLDEN GAME ENVIRONMENT REFERENCE FILE at
/home/ccaitwo/ARC-AGI-3/<game>.txt (for example sb26.txt) - the practical mentor guide
followed by that game's sections cut from all ten ARC-AGI-3_Steps_Draft documents (the former
<game>_steps.txt was merged in and removed), one game per file, no cross-game spillover.
BEFORE each AI Mentor Bridge run to secure status:won for a game, READ the matching golden
reference file and LOAD THE ENTIRE FILE INTO J-SPACE (the jspace workspace for that game) so
its steps stay at the forefront while performing the run. The loader is agp_load_golden/1 in
src/mentova/arc_golden.pl (holds each line of the golden file as a concept in the game's
J-Space workspace). Golden files are the authoritative per-game reference. (Adopted
2026-07-11; unified into <game>.txt 2026-07-12.)


ONE-GAME-AT-A-TIME RULE (ARC-AGI-3)

Do NOT cycle through the entire 25-game set to make progress. Focus one Game Environment at a
time and stay on it until status:won before moving to the next. The per-game cycle is: (1) AI
Mentor Bridge run on game XXXX - mentor it, and SAVE the learnings to the durable store; (2)
Solo run on game XXXX - it reads those learnings; (2a) Observe_Game_Play_Run - the mentor
OBSERVES the solo run while it is running and writes structured notes to disk: where it gets
stuck, how it is (and is not) thinking, what it is missing (and obviously missing), what
clues/rules/mentoring/code/functions it could be given, and what data could be written to the
Mentova Causalontology lattice to communicate with it; (3) adjust from those notes (add clues,
rules, code, or lattice writes), then repeat the cycle. Only when a game reaches status:won
does the next game begin. Full 25-game sweeps remain allowed ONLY as an occasional
measurement/benchmark (for example a clean A/B of a policy change), never as the way progress
is made. (Adopted 2026-07-11 as a course correction after the v4/v5 cold sweeps measured 0
levels: breadth-first cycling does not win; depth-first per-game mentoring is the path.)


LEVEL-LAYER RULE (ARC-AGI-3)

Within a game, work at the LEVEL LAYER, not the whole-game layer. Learning is acquired one
level at a time. The per-level cycle is: (1) Phase Bridge on level N - the mentor runs the AI
Mentor Bridge until the MENTOR wins level N; (2) ENCODE that level's steps and principles into
game-and-level-keyed durable persistence (the learnings/solver keyed by both game and level,
so a level's procedure is stored and recalled on its own); (3) Phase Solo on level N - the
Solo player plays until it wins level N UNAIDED; (4) only then advance to level N+1 and
repeat. Do NOT try to solve all of a game's levels in one undifferentiated pass: each level is
Bridged-until-won, encoded, then Soloed-until-won-unaided before the next level begins. Report
each Solo LEVEL win to the user (game, level, action count) as it lands, not only whole-game
wins. (Adopted 2026-07-12. Refines the BRIDGE-THEN-ALTERNATE and ONE-GAME-AT-A-TIME rules to
the level granularity.)
