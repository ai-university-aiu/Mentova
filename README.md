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
| 14 | Mathematical | Pending |
| 15 | Fuzzy | Pending |
| 16 | Qualitative | Pending |
| 17 | Non-monotonic (defeasible) | Pending |
| 18 | Paraconsistent | Pending |
| 19 | Counterfactual | Pending |
| 20 | Hypothetical | Pending |
| 21 | Spatial | Pending |
| 22 | Diagrammatic | Pending |
| 23 | Temporal | Pending |
| 24 | Case-based | Pending |
| 25 | Constraint-based | Pending |
| 26 | Scientific | Pending |
| 27 | System | Pending |
| 28 | Model-based | Pending |
| 29 | Heuristic | Pending |
| 30 | Critical | Pending |
| 31 | Dialectical | Pending |
| 32 | Metacognitive | Pending |
| 33 | Modal | Pending |
| 34 | Epistemic | Pending |
| 35 | Deontic | Pending |
| 36 | Procedural | Pending |
| 37 | Symbolic | Pending |
| 38 | Practical | Pending |
| 39 | Teleological | Pending |
| 40 | Strategic | Pending |
| 41 | Narrative | Pending |
| 42 | Social | Pending |
| 43 | Intuitive | Pending |
| 44 | Emotional | Pending |
| 45 | Motivational | Pending |
| 46 | Informal | Pending |
| 47 | Legal | Pending |
| 48 | Moral | Pending |

## Platform dependency

Mentova depends on PrologAI (SWI-Prolog 9.0.4+).

```prolog
:- use_module(library(mentova)).
```

## Author

D. R. Dison, Founder of AIU (Artificial Intelligence University). Creator of PrologAI and Mentova. Open Researcher and Contributor ID (ORCID): 0009-0001-9246-5758. (https://www.linkedin.com/in/d-r-dison/)
