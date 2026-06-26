This repository is Mentova, the first Synthetic Mind written in PrologAI.

It depends on the PrologAI platform: https://github.com/ai-university-aiu/PrologAI

The Demonstration and Proof-of-Concept Plan (PrologAI Volume 6,
docs/PrologAI_6_Demonstration_Mentova_v3.txt in the PrologAI repo) governs
how Mentova is born, proven, and grown.

AUTHOR — ALL PAPERS AND ANNOUNCEMENTS

Every paper (papers/Acc_N_*.txt) and every announcement
(announcements/Acc_N_*_LinkedIn.txt) must carry this author line:

    Author: D. R. Dison, Founder of AIU (Artificial Intelligence University).
    Creator of PrologAI and Mentova. Open Researcher and Contributor ID
    (ORCID): 0009-0001-9246-5758. (https://www.linkedin.com/in/d-r-dison/)

No AI tools are credited as authors or co-authors anywhere.

COPYRIGHT ACKNOWLEDGMENT — END OF EVERY PAPER

Every paper (papers/Acc_N_*.txt) must end with this block, verbatim,
as the very last content in the file:

---
Copyright (C) 2026 by D. R. Dison (LinkedIn) All rights reserved. No part of this work may be reproduced, stored in a retrieval system, or transmitted in any form or by any means, electronic, mechanical, photocopying, recording, or otherwise, without the prior written permission of the publisher, D. R. Dison, except as provided by U.S. Copyright Law or for the use of brief quotations in a review. Acknowledgment: This work was produced with the aid of various technological tools, including Work Processing Tools (WPT), Desktop Publishing Tools (DPT), Image Processing Tools (IPT), and Artificial Intelligence Tools (AIT).

PUBLISHED WORKS — NOTICE FILE ONLY

The author's published works (books, papers, YouTube channel) must appear ONLY
in the NOTICE file of the PrologAI repository. They must never appear in any
paper, announcement, README, source file, or any other file in this repository
or any other repository.

ACCOMPLISHMENT NUMBERING

Papers and announcements share a sequential tracking number: Acc_1, Acc_2, ...
Each number corresponds to one accomplished reasoning rung, practical track
milestone, or flagship demonstration.

A paper or announcement is written only after the accomplishment has been
achieved and its result measured. Never ahead of the evidence.

DIRECTORY LAYOUT

    knowledge/        Small-World Commonsense knowledge base
    bodies/           Body configurations (text I/O, game, ROS 2 robot)
    constitution/     Constitution instance (8 principles, 1 overseer)
    src/mentova/      Bootstrap entry point and runtime predicates
    papers/           Scientific papers — one per accomplishment (Acc_N_...)
    announcements/    LinkedIn announcements — one per accomplishment (Acc_N_..._LinkedIn.txt)

ELEMENT NAMES

Element names are original to PrologAI; do not introduce source-origin terms.

README UPDATE RULE: After any significant update to the Mentova codebase — new accomplishment, new benchmark result, new protocol support, new growth path milestone closed — update README.md in the Mentova repository root to reflect the change. The README must always show the current state: accurate accomplishment count, current ARC-AGI scores, growth path status, and up-to-date capability descriptions. This update goes in the same PR as the code change.

PR MERGE RULE: After creating a PR on this repository, merge it immediately using `gh pr merge <number> --squash --delete-branch`. No confirmation is needed for PRs that Claude authored. Do NOT auto-merge PRs opened by other contributors or external bots; those require explicit human approval before merging.
