# Mentova

**The world's first glass-box synthetic mind written in PrologAI.**

Mentova is a program written in [PrologAI](https://github.com/ai-university-aiu/PrologAI) — the cognitive architecture platform — the way an application depends on its language.

It is born, proven, and grown one reasoning type at a time, following the Demonstration and Proof-of-Concept Plan (Volume 6 of the PrologAI SPARC series).

## What makes Mentova different

Every answer Mentova produces comes with a readable justification tree. You can see not just what it concluded but exactly why. No black box.

## Repository layout

```
knowledge/        Small-World Commonsense knowledge base (foundational data)
bodies/           Body configurations (game bodies, robot body)
constitution/     Mentova's constitution instance with registered overseers
src/mentova/      Bootstrap and runtime entry points
papers/           Scientific papers for each accomplished milestone (Acc_N_...)
announcements/    LinkedIn-style announcements for each milestone (Acc_N_..._LinkedIn.txt)
```

## Reasoning ladder

Mentova climbs 48 reasoning rungs, one at a time, foundational first.
The birth sequence (Rungs 1-9) is the minimum viable Mentova.

| Rung | Type | Status |
|------|------|--------|
| 1 | Deductive | ✅ Accomplished |
| 2 | Inductive | Pending |
| 3 | Abductive | Pending |
| 4 | Probabilistic | Pending |
| 5 | Bayesian | Pending |
| 6 | Causal | Pending |
| 7 | Statistical | Pending |
| 8 | Analogical | Pending |
| 9 | Relational | Pending |
| 10–48 | Knowledge-representation, Agentic, Social/Normative | Pending |

## Platform dependency

Mentova depends on PrologAI (SWI-Prolog 9.0.4+).

```prolog
:- use_module(library(mentova)).
```

## Author

D. R. Dison, Founder of AIU (Artificial Intelligence University). Creator of PrologAI and Mentova. Open Researcher and Contributor ID (ORCID): 0009-0001-9246-5758. (https://www.linkedin.com/in/d-r-dison/)
