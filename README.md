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
| 2 | Inductive | ✅ Accomplished |
| 3 | Abductive | ✅ Accomplished |
| 4 | Probabilistic | ✅ Accomplished |
| 5 | Bayesian | ✅ Accomplished |
| 6 | Causal | ✅ Accomplished |
| 7 | Statistical | ✅ Accomplished |
| 8 | Analogical | ✅ Accomplished |
| 9 | Relational | ✅ Accomplished |
| 10 | Transductive | ✅ Accomplished |
| 11 | Commonsense | ✅ Accomplished |
| 12 | Logical | ✅ Accomplished |
| 13 | Formal | ✅ Accomplished |
| 14 | Mathematical | ✅ Accomplished |
| 15 | Fuzzy | ✅ Accomplished |
| 16 | Qualitative | ✅ Accomplished |
| 17 | Non-monotonic (defeasible) | ✅ Accomplished |
| 18 | Paraconsistent | ✅ Accomplished |
| 19 | Counterfactual | ✅ Accomplished |
| 20 | Hypothetical | ✅ Accomplished |
| 21 | Spatial | ✅ Accomplished |
| 22 | Diagrammatic | ✅ Accomplished |
| 23 | Temporal | ✅ Accomplished |
| 24 | Case-based | ✅ Accomplished |
| 25 | Constraint-based | ✅ Accomplished |
| 26 | Scientific | ✅ Accomplished |
| 27 | System | ✅ Accomplished |
| 28 | Model-based | ✅ Accomplished |
| 29 | Heuristic | ✅ Accomplished |
| 30 | Critical | ✅ Accomplished |
| 31 | Dialectical | ✅ Accomplished |
| 32 | Metacognitive | ✅ Accomplished |
| 33 | Modal | ✅ Accomplished |
| 34 | Epistemic | ✅ Accomplished |
| 35 | Deontic | ✅ Accomplished |
| 36 | Procedural | ✅ Accomplished |
| 37 | Symbolic | ✅ Accomplished |
| 38 | Practical | ✅ Accomplished |
| 39 | Teleological | ✅ Accomplished |
| 40 | Strategic | ✅ Accomplished |
| 41 | Narrative | ✅ Accomplished |
| 42 | Social | ✅ Accomplished |
| 43 | Intuitive | ✅ Accomplished |
| 44 | Emotional | ✅ Accomplished |
| 45 | Motivational | ✅ Accomplished |
| 46 | Informal | ✅ Accomplished |
| 47 | Legal | ✅ Accomplished |
| 48 | Moral | ✅ Accomplished |

## Platform dependency

Mentova depends on PrologAI (SWI-Prolog 9.0.4+).

```prolog
:- use_module(library(mentova)).
```

## Author

D. R. Dison, Founder of AIU (Artificial Intelligence University). Creator of PrologAI and Mentova. Open Researcher and Contributor ID (ORCID): 0009-0001-9246-5758. (https://www.linkedin.com/in/d-r-dison/)
