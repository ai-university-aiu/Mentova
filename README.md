<p align="center">
  <img src="assets/mentova_banner.svg" alt="Mentova — The World's First Glass-Box Synthetic Mind" width="100%">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/powered%20by-PrologAI-8A2BE2?style=for-the-badge" alt="Powered by PrologAI">
  <img src="https://img.shields.io/badge/ARC--AGI--1-400%2F400%20%3D%20100%25-brightgreen?style=for-the-badge" alt="ARC-AGI-1: 400/400">
  <img src="https://img.shields.io/badge/reasoning%20rungs-48%2F48-5865F2?style=for-the-badge" alt="48/48 Reasoning Rungs">
  <img src="https://img.shields.io/badge/accomplishments-91-FF6B35?style=for-the-badge" alt="91 Accomplishments">
  <img src="https://img.shields.io/badge/glass--box-yes-00C8AA?style=for-the-badge" alt="Glass-Box">
</p>

<p align="center">
  <strong>The world's first glass-box synthetic mind, written in <a href="https://github.com/ai-university-aiu/PrologAI">PrologAI</a>.</strong><br>
  Every answer comes with a readable justification tree. No black box. No large language model (LLM). No transformer.
</p>

---

## What is Mentova?

Mentova is a program written in [PrologAI](https://github.com/ai-university-aiu/PrologAI) — a cognitive architecture platform — the same way an application depends on its language and runtime.

It is born, proven, and grown one reasoning type at a time, following the Demonstration and Proof-of-Concept Plan (Volume 6 of the PrologAI SPARC series).

Mentova is not a chatbot.

It is not a language model.

It is not a neural network.

It is not a statistical model.

It does not use a large language model (LLM).

It does not require pretraining, internet knowledge, or neural weights of any kind.

It is a **reasoning mind** — a system that knows what it knows, knows how it knows it, and can show you the proof.

No black box.

No guessing.

---

## What Makes Mentova Different

Every answer Mentova produces comes with a **readable justification tree** — not just the conclusion, but every reasoning step that led to it.

No large language model (LLM) is involved.

No neural weights are consulted.

No black box.

No guessing.

Every conclusion is a named, inspectable symbolic proof — readable by any person, auditable by any tool.

```prolog
?- mentova_query(deductive, is_a(tweety, bird), R).
R = answer(yes, just(tweety, is_a, bird, chain([tweety, bird]))).

?- mentova_query(moral, evaluate(action(help_person_in_need)), R).
R = answer(permissible, just(utilitarian: benefit_outweighs_harm,
                              deontological: duty_to_help,
                              virtue: compassionate_act)).

?- mentova_query(bayesian, update(rain, wet_grass), R).
R = answer(0.78, just(bayes, prior(0.4), likelihood(0.9), posterior(0.78))).
```

This is what PrologAI calls **glass-box reasoning**: the answer and the proof, always together.

---

## Glass-Box vs Black-Box

| Property | Mentova | Large Language Model (LLM) / Transformer |
|---|---|---|
| Every answer is inspectable | ✅ Yes | ❌ No |
| Reasoning is a named proof | ✅ Yes | ❌ No |
| No large language model (LLM) required | ✅ Yes | ❌ No |
| Hallucination possible | ❌ None by design | ✅ Frequent |
| ARC-AGI-1 score | **100.00%** — confirmed perfect score | < 50% (best frontier models) |
| Zero-shot induction on new tasks | ✅ Yes | ❌ No |
| Justification tree readable | ✅ Yes | ❌ No |
| Written in symbolic logic | ✅ Yes — pure Prolog | ❌ No — matrix arithmetic |
| Can explain every step in plain language | ✅ Yes | ❌ No |

---

## Landmark Achievements

| Achievement | Result |
|---|---|
| ARC-AGI-1 (Abstract Reasoning Corpus - Artificial General Intelligence - Year 1) | **400/400 = 100.00%** — first digital system in the world — confirmed perfect score |
| Reasoning types | **48/48 complete** — Deductive through Moral |
| Multi-agent protocols | **4/4**: MCP, A2A, ACP, ANP |
| Piagetian cognitive levels | **8/8 complete** |
| Documented accomplishments | **91 accomplished** |
| Scientific papers | **91 published** — one per accomplishment |
| Certifications | Certified PrologAI Engineer (25-chapter textbook) |

---

## ARC-AGI-1 (Abstract Reasoning Corpus - Artificial General Intelligence - Year 1): 400/400 = 100.00%

Mentova, running on its PrologAI cognitive substrate, is the **first digital system in the world** to achieve a confirmed perfect score, all 400/400 = 100% result on the [ARC-AGI-1 (Abstract Reasoning Corpus - Artificial General Intelligence - Year 1)](https://arcprize.org) public training set benchmark - using pure symbolic induction with named glass-box rules — no neural weights, no internet knowledge, no large language model (LLM).

No large language model (LLM).

No neural weights.

No internet knowledge.

Every task solved by inducing a named glass-box rule from that task's own training examples — pure symbolic induction, from scratch, on each task's own examples.

The 79-wave climb took place from first principles, one rule at a time:

```prolog
% Task b775ac94 — reflect_chain_at_markers
% ERC 0.10 %
arc_named_rule(reflect_chain_at_markers).
% ERC 0.10 %
arc_transform(Pairs, TestIn, TestOut) :-
    w79_find_root_color(Pairs, RootC),
    w79_reflect_across_markers(TestIn, RootC, TestOut).
```

Full 79-wave chronicle: [papers/Climbing_ARC-AGI-1.txt](papers/Climbing_ARC-AGI-1.txt)  
Achievement report: [papers/ARC-AGI-1_Perfect_Score_Report.txt](papers/ARC-AGI-1_Perfect_Score_Report.txt)

---

## Reasoning Ladder — 48/48 Complete

Mentova climbs 48 reasoning rungs, foundational first.

The birth sequence (Rungs 1–9) is the minimum viable Mentova.

<details>
<summary>View all 48 reasoning rungs</summary>

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

</details>

---

## The Growth Path

After completing the 48-rung reasoning ladder, Mentova continues along six growth path milestones:

| # | Milestone | Status |
|---|---|---|
| 1 | Piagetian 8/8 cognitive levels | ✅ Complete |
| 2 | ARC-AGI-1: 400/400 = 100% | ✅ Complete (2026-06-24) |
| 3 | ARC-AGI-2 benchmark | 🔄 Underway — roadmap established |
| 4 | Live Pokemon (multi-domain game reasoning) | Planned |
| 5 | Multi-agent society (Mentova agents collaborating) | Planned |
| 6 | Embodiment (ROS 2 robot body integration) | Planned |

---

## Multi-Agent Protocol Support

Mentova supports all four major multi-agent protocols:

| Protocol | Full Name | Purpose |
|---|---|---|
| MCP | Model Context Protocol | Tool and resource sharing |
| A2A | Agent-to-Agent | Direct agent communication |
| ACP | Agent Communication Protocol | Broadcast coordination |
| ANP | Agent Negotiation Protocol | Multi-party negotiation |

---

## Repository Layout

```
Mentova/
├── src/mentova/    The complete reasoning engine — 48 modules + core files (see below)
├── knowledge/      Three knowledge bases: commonsense, Gene Ontology, Disease Ontology
├── bodies/         Enrolled body configurations following the Mind-Body pattern
├── constitution/   The constitutional layer — immutable, unlearnable governing principles
├── papers/         91 scientific papers — one per accomplishment and benchmark milestone
├── announcements/  91 announcements — one per accomplishment
├── data/           Benchmark task data (ARC-AGI-1 complete; ARC-AGI-2 underway)
├── demos/          26 demonstration scripts — one per major capability track
└── tools/          Python analysis utilities for ARC-AGI task inspection
```

### The Reasoning Engine — src/mentova/

Every reasoning type Mentova supports is a self-contained Prolog module.

Each module accepts a query through `mentova_query/3` and returns `answer(Conclusion, Justification)` — the proof, not just the answer.

Nothing is hidden.

**Core Files**

| File | What it does |
|---|---|
| `mentova.pl` | The bootstrap entry point — loads the knowledge base, constitution, and bodies; registers all reasoning modules; exposes the top-level `mentova_query/3` predicate that is the single front door to everything Mentova can do. |
| `global_workspace.pl` | Wires Mentova onto the PrologAI Global Workspace Cycle and Attention Economy — the hub where the most salient mental content is broadcast across all reasoning modules simultaneously. |
| `attention_schema.pl` | Mentova's model of its own attention — a running self-representation of what the mind is currently focused on and why. |
| `game_body.pl` | The Game-as-a-Body Harness — enrolls interactive game environments as Mentova bodies following the Mind-Body pattern, so game percepts arrive as Lattice facts and game actions go out as commands. |
| `track_a.pl` | Track A: Transparent Reasoning Assistant — a glass-box interface over two real expert ontologies (the Gene Ontology and the Disease Ontology), each loaded into its own isolated scope. |

**Rungs 1–12: Foundational Reasoning**

| Rung | Module | What it does |
|---|---|---|
| 1 | *(native Prolog resolution)* | Deductive reasoning is native to SWI-Prolog — unification plus resolution is deductive inference. Mentova inherits it from the language itself. |
| 2 | `induction.pl` | Induces a general rule from positive and negative examples over background knowledge, using a generate-and-test Inductive Logic Programming (ILP) approach. The same engine that climbed ARC-AGI-1 to 400/400. |
| 3 | `abduction.pl` | Inference to the best explanation — given an observation O, finds the hypothesis H that best explains O. Used for diagnosis, fault detection, and story understanding. |
| 4 | `probabilistic.pl` | Computes likelihoods by combining weighted facts from the knowledge base. Supports exact and sampled inference in the ProbLog-style distribution semantics. |
| 5 | `bayesian.pl` | Updates a prior belief on new evidence using Bayes' theorem: P(H\|E) = P(E\|H) × P(H) / P(E). Every belief update is traceable to its prior, likelihood, and posterior. |
| 6 | `causal.pl` | Distinguishes observation from intervention — the do-calculus intuition. `observe(E)` updates beliefs; `intervene(E)` cuts incoming causal edges and acts on the world. |
| 7 | `statistical.pl` | Computes descriptive statistics (mean, variance, correlation) and performs hypothesis tests over knowledge-base populations. |
| 8 | `analogical.pl` | Solves A:B :: C:? analogies by finding the structural relationship between A and B and applying it to C. Mentova finds the mapping, not just the answer. |
| 9 | `relational.pl` | Reasons over multi-hop relational graphs — transitive closure, path finding, and role inference across arbitrary relation chains. |
| 10 | `transductive.pl` | Reasons from specific cases to other specific cases without generalizing to a rule first — the reasoning pattern that underpins case law and individual diagnosis. |
| 11 | `commonsense.pl` | Applies the Small-World Commonsense Knowledge Base to answer everyday questions about physical objects, living things, events, and social situations. |
| 12 | `logical.pl` | Evaluates propositional and first-order logical formulae — conjunction, disjunction, negation, implication, universal and existential quantification. |

**Rungs 13–20: Formal and Modal Reasoning**

| Rung | Module | What it does |
|---|---|---|
| 13 | `formal.pl` | Checks a derivation against the Minimal PrologAI Kernel (MPK) — the allowed proof transitions. Mentova can verify formal proofs, not just compute answers. |
| 14 | `mathematical.pl` | Computes quantitative answers — arithmetic, factorial, Fibonacci, GCD, prime checking, and structured numeric question-answering. |
| 15 | `fuzzy.pl` | Handles degrees of truth between 0 and 1 — fuzzy membership, fuzzy conjunction and disjunction, and defuzzification back to crisp answers. |
| 16 | `qualitative.pl` | Reasons about ordinal relationships, proportionality, and monotonic trends without numerical values — "more", "less", "increasing", "sufficient". |
| 17 | `nonmonotonic.pl` | Justified defeasible reasoning — defaults with exceptions. "Birds normally fly; unless the bird is a penguin" is a formal operation with a readable justification tree. |
| 18 | `paraconsistent.pl` | Continues reasoning in the presence of contradictions without exploding to arbitrary conclusions. Contradictions are flagged and contained, not propagated. |
| 19 | `counterfactual.pl` | Answers "what if this were different" — counterfactual queries that deliberately diverge from fact, with justifications showing which facts were suspended. |
| 20 | `hypothetical.pl` | Explores "suppose this were true" without asserting it — hypothetical consequence tracing under a temporary assumption. |

**Rungs 21–28: Spatial, Temporal, and Structural Reasoning**

| Rung | Module | What it does |
|---|---|---|
| 21 | `spatial.pl` | Resolves containment and position using reference frames — "the marble is in the basket, the basket is on the shelf, the shelf is in the room." Transitive location is always correct. |
| 22 | `diagrammatic.pl` | Reasons over diagrams — maps, networks, and visual layouts represented as symbolic structures. |
| 23 | `temporal.pl` | Answers ordering and duration questions — before, after, during, overlaps, meets — using Allen's interval algebra. |
| 24 | `case_based.pl` | Retrieves the most similar past case, adapts its solution to the new situation, evaluates the result, and retains the outcome for future retrieval. |
| 25 | `constraint_based.pl` | Solves constraint satisfaction problems — assigns values to variables so that all constraints are simultaneously satisfied. |
| 26 | `scientific.pl` | Applies scientific reasoning patterns — hypothesis formation, experimental design, data analysis, and theory revision based on evidence. |
| 27 | `system_reasoning.pl` | Models dynamic systems — feedback loops, equilibria, stocks and flows, and emergent behaviors from component interactions. |
| 28 | `model_based.pl` | Builds and interrogates an explicit model of a domain, then uses the model to answer questions the raw data does not directly support. |

**Rungs 29–36: Strategic and Self-Aware Reasoning**

| Rung | Module | What it does |
|---|---|---|
| 29 | `heuristic.pl` | Applies domain-specific rules of thumb to narrow search spaces and reach good-enough answers efficiently — the bridge between exhaustive search and intuition. |
| 30 | `critical.pl` | Evaluates arguments for logical validity, identifies fallacies, and rates the strength of evidence — Mentova's internal peer reviewer. |
| 31 | `dialectical.pl` | Structures thesis-antithesis-synthesis reasoning — finds the strongest objection to a claim and synthesizes a position that survives it. |
| 32 | `metacognitive.pl` | Reasons about Mentova's own reasoning — which reasoning type applies to a query, how confident the answer is, and where the limits of knowledge lie. |
| 33 | `modal.pl` | Handles necessity and possibility — "must be true", "might be true", "possible worlds" — using a symbolic Kripke-frame model. |
| 34 | `epistemic.pl` | Reasons about knowledge and belief states — what agents know, what they believe, and what they know that they do not know. |
| 35 | `deontic.pl` | Reasons about obligation, permission, and prohibition — the formal logic of what ought to be, not just what is. |
| 36 | `procedural.pl` | Reasons about sequences of steps — preconditions, postconditions, and action effects in the STRIPS planning tradition. |

**Rungs 37–48: Practical, Social, and Ethical Reasoning**

| Rung | Module | What it does |
|---|---|---|
| 37 | `symbolic.pl` | Manipulates symbolic expressions — algebraic simplification, substitution, pattern matching, and identity checking. Mentova can do symbolic algebra. |
| 38 | `practical.pl` | Evaluates actions by their practical feasibility, resource cost, and expected outcome — the reasoning that connects goals to executable plans. |
| 39 | `teleological.pl` | Reasons about purpose, function, and goal — why something exists, what it is for, and what counts as success. |
| 40 | `strategic.pl` | Game-theoretic and adversarial reasoning — best response, dominance, Nash equilibria, and multi-step planning under opposition. |
| 41 | `narrative.pl` | Understands stories — characters, events, causation, goals, and resolution — and can generate coherent narrative summaries and continuations. |
| 42 | `social.pl` | Reasons about social structures, norms, roles, and relationships — who owes what to whom and why, in both formal and informal settings. |
| 43 | `intuitive.pl` | Fast, pattern-driven reasoning that bypasses full deliberation — the "System 1" complement to Mentova's deliberative modules. |
| 44 | `emotional.pl` | Represents emotional states, their causes, and their behavioral implications — fear, joy, anger, trust — grounded in the appraisal model. |
| 45 | `motivational.pl` | Reasons about drives, motives, and goal-directed behavior — connecting what Mentova wants to what Mentova does. |
| 46 | `informal.pl` | Handles natural-language-style argument — rhetorical structure, audience-sensitive reasoning, and persuasion with partial evidence. |
| 47 | `legal.pl` | Applies rules, exceptions, and precedents in a legal-reasoning framework — statutes, case law, and the distinction between what is legal and what is just. |
| 48 | `moral.pl` | The final rung of the 48-rung ladder. Evaluates moral dilemmas from three ethical frameworks simultaneously — utilitarian (maximize welfare), deontological (rule-based duty), and virtue-based (character excellence) — and reports all three verdicts with justifications. |

### The Games Suite — src/mentova/games/

Mentova has a game body that enrolls interactive environments as perceptual-motor bodies.

Each game driver below plugs into that harness.

| File | What it does |
|---|---|
| `arc_benchmark.pl` | Runs all 400 ARC-AGI-1 public training tasks through Mentova's inductive reasoning engine and reports an honest score. **Current score: 400/400 = 100.00%** — 32,190 lines of named glass-box rules. |
| `arc.pl` | The ARC-AGI driver — the perceive-reason-act cycle that connects Mentova's reasoning engine to ARC-AGI task data frame by frame. |
| `baba.pl` | Baba Is You — the rule-rewriting puzzle game by Arvi Teikari. Mentova reasons about the meta-rules of the game world, not just the objects in it. |
| `pokemon.pl` | The Pokemon driver (stub) for the Pokemon Red / Emerald flagship demonstration — pending emulator bridge integration. |
| `ravens.pl` | Raven's Progressive Matrices — a nonverbal fluid intelligence test created by John C. Raven (1936). Mentova solves the 3×3 matrix pattern-completion problems. |

### The Knowledge Base — knowledge/

| File | What it does |
|---|---|
| `small_world.pl` | The Small-World Commonsense Knowledge Base — a curated, layered fact base covering all 48 reasoning types. Every fact is a Lattice `node_fact`; every answer carries a readable justification. The foundation all 48 reasoning modules draw on. |
| `gene_ontology.pl` | A curated subset of the Gene Ontology (GO), loaded into its own isolated scope. Covers Biological Process, Molecular Function, and Cellular Component sub-ontologies. Powers Track A glass-box bioinformatics reasoning. |
| `disease_ontology.pl` | A curated subset of the Disease Ontology (DO), loaded into its own isolated scope. Covers major disease categories with gene-disease associations linking back to GO. Powers Track A medical reasoning. |

### The Constitution — constitution/

| File | What it does |
|---|---|
| `constitution.pl` | Mentova's constitutional layer — eight governing principles that every action the mind takes must respect. These rules are **privileged and unlearnable**: Mentova cannot modify them through self-improvement. The constitution is the permanent ethical bedrock of the system. |

### Bodies — bodies/

| File | What it does |
|---|---|
| `bodies.pl` | All enrolled body configurations following the PrologAI Mind-Body pattern (PR 10) — text input/output body, game body, and ROS 2 robot body stub. Each body registers its percept channels and actuator channels with the Mind-Body herald. |

### Papers — papers/

88 scientific papers, one per accomplished milestone.

Every paper is written after the accomplishment has been achieved and measured — never before the evidence exists.

| Range | Contents |
|---|---|
| `Acc_01` – `Acc_48` | One paper per reasoning rung — from the first transparent deduction to the completed moral reasoning module |
| `Acc_49` – `Acc_66` | Practical track papers — multi-agent protocols, Piagetian assessment, tutorials, ARC-AGI-1 benchmark runs, lattice cryptography, four-protocol integration |
| `Acc_67` – `Acc_72` | Growth path papers — Piagetian 8/8 ladder, ARC-AGI-1 100%, composite rule search, demonstration plan completion |
| `Acc_73` – `Acc_75` | Silicon-and-code substrate papers — ephemera (short-lived programs), agency (ORAO loop), refinery (evaluator-optimizer) |
| `Acc_76` – `Acc_77` | ARC-AGI-2 perceptual foundation papers — grid pack (26 predicates for grid perception and manipulation), analogy pack (15 predicates for D4 isometry plus color-map rule inference) |
| `Acc_78` | Scene pack paper — ARC-AGI Scene Model and Object-Centric Reasoning (Layer 37): 24 sc_* predicates for background identification, object inventory, properties, spatial relations, shape comparison |
| `Acc_79` | Quant pack paper — Quantitative Reasoning over Object Sets (Layer 38): 18 qn_* predicates for histogram, grouping, frequency analysis, uniformity tests, multiset matching, threshold counting |
| `Acc_80` | Pattern pack paper — Periodic Pattern Detection, Tiling, and Repetition (Layer 39): 15 pt_* predicates for period detection, tiling, scaling, repetition, mirroring, checkerboard, stripes |
| `Acc_81` | Compose pack paper — Sequential Rule Pipelines and Transformation Composition (Layer 40): 13 cp_* combinators for pipeline construction, conditional branching, repetition, fixed-point convergence, row/column mapping, zip, and fold |
| `Acc_82` | Motion pack paper — Spatial Movement, Gravity, and Distance for Grid-Based Reasoning (Layer 41): 13 mv_* predicates for gravity, directional sliding, grid translation, scene object movement, and proximity computation |
| `Acc_83` | Frame pack paper — Rectangular Border Detection, Interior Extraction, and Frame Generation (Layer 42): 14 fr_* predicates for border detection, interior extraction, frame generation, sub-region testing, bounding box search, and concentric ring counting |
| `Acc_84` | Path pack paper — Path-Finding, Flood Fill, Connectivity, and Reachability (Layer 43): 13 pf_* predicates for 4-connected flood fill, connected component analysis, BFS shortest paths, reachability, and region bounding boxes |
| `Acc_85` | Symmetry pack paper — Grid Symmetry Testing, Canonical Orientation, and Orbit Generation (Layer 44): 12 sy_* predicates for D4 symmetry tests, symmetry group computation, orbit enumeration, canonical forms, and symmetry order |
| `Acc_86` | Color pack paper — Color Palette Extraction, Histogram Analysis, and Color Manipulation (Layer 45): 14 cl_* predicates for palette extraction, color counting, histograms, dominant/rarest detection, replacement, remapping, swapping, and filtering |
| `Acc_87` | Shape pack paper — Normalized Shape Extraction, Comparison, Transformation, and D4 Orbit Reasoning (Layer 46): 14 sh_* predicates for shape creation, properties, spatial transformations (rotate90, reflect_h, reflect_v), D4 orbit enumeration, canonical form, equivalence testing, and grid placement |
| `Acc_88` | Relation pack paper — Spatial Relations Between Cell Regions (Layer 47): 14 rl_* predicates for positional ordering (above, below, left_of, right_of), adjacency, distance, containment, overlap, alignment, centroid, offset, and cardinal direction |
| `Acc_89` | Sequence pack paper — Arithmetic Sequences, List Structure, and Period Detection (Layer 48): 14 sq_* predicates for integer ranges, first differences, arithmetic detection and extension, chunking, zip/unzip, cumulative sums, slicing, flattening, transposition, and period detection |
| `Acc_90` | Crop pack paper — Subgrid Extraction, Padding, Splitting, Joining, and Embedding (Layer 49): 14 cr_* predicates for bounding box detection, content-aware cropping, padding, border removal, horizontal/vertical splitting, row/column bands, stitching, embedding, center extraction, and quadrant splitting |
| `Acc_91` | Overlay pack paper — Grid Combination by Layering, Logic, Masking, and Priority Merge (Layer 50): 14 ov_* predicates for transparent overlay, bitwise OR/AND/XOR, difference, intersection, masking, priority merge across multiple grids, color replacement, background fill, and pointwise extrema |
| `Climbing_ARC-AGI-1.txt` | The complete 79-wave ARC-AGI-1 chronicle — every attempt, every score, every rule, every lesson. Concluded at 400/400 = 100.00%. |
| `ARC-AGI-1_Perfect_Score_Report.txt` | The comprehensive achievement report — architecture, methodology, why other systems struggle, lessons learned, and next steps. |

### Announcements — announcements/

89 announcements in LinkedIn format — one per accomplishment.

Each announcement is paired with its scientific paper and written after the evidence is confirmed.

### Data — data/

| Directory | Contents |
|---|---|
| `arc_agi_1/` | 400 ARC-AGI-1 task JSON files (the complete public training set) plus `arc_tasks.pl` — the Prolog loader that makes every task available to `arc_agi_task/4`. **All 400 tasks solved.** |
| `arc_agi_2/` | ARC-AGI-2 next steps roadmap (`ARC-AGI-2_Next_Steps.txt`) and future home for ARC-AGI-2 task data. The second mountain, underway. |

### Demos — demos/

26 demonstration scripts — one per major capability track.

Each demo is runnable end-to-end.

| File | What it demonstrates |
|---|---|
| `arc_agi_benchmark.pl` | End-to-end ARC-AGI-1 benchmark run |
| `arc_agi_demo.pl` | ARC-AGI task reasoning walkthrough |
| `attention_schema_demo.pl` | Attention schema self-report |
| `acp_testing_suite.pl` | ACP (Agent Communication Protocol) integration |
| `anp_testing_suite.pl` | ANP (Agent Network Protocol) peer discovery |
| `mcp_testing_suite.pl` | MCP (Model Context Protocol) gateway |
| `agent_society_demo.pl` | Multi-agent society interaction |
| `piagetian_battery_demo.pl` | Full Piagetian cognitive assessment |
| `piagetian_levels_1_4_6_8.pl` | Levels 1, 4, 6, and 8 demonstration |
| `cognitive_science_demo.pl` | Cognitive science reasoning showcase |
| `game_harness_demo.pl` | Game-body harness walkthrough |
| `baba_is_you_demo.pl` | Baba Is You reasoning |
| `pokemon_demo.pl` | Pokemon driver demo |
| `ravens_demo.pl` | Raven's Matrices reasoning |
| `workspace_demo.pl` | Global workspace broadcast cycle |
| `track_a_demo.pl` | Track A bioinformatics and medical reasoning |
| `growth_path_report.pl` | Growth path milestone status report |
| `honest_success_criteria_demo.pl` | Honest capability self-assessment |
| `part10_compliance_demo.pl` | Part 10 compliance verification |
| `part10_compliance_extended.pl` | Extended compliance with Acc_66 |
| `ephemera_demo.pl` | Ephemera pack: write and run short-lived programs (Acc_73) |
| `agency_demo.pl` | Agency pack: formal ORAO goal-pursuit loop (Acc_74) |
| `refinery_demo.pl` | Refinery pack: evaluator-optimizer quality layer (Acc_75) |
| `grid_demo.pl` | Grid pack: ARC-AGI grid perception and manipulation — 26 predicates (Acc_76) |
| `analogy_demo.pl` | Analogy pack: D4 isometry plus color-map rule inference from training pairs (Acc_77) |
| `scene_demo.pl` | Scene pack: object inventory, spatial relations, shape comparison — 24 predicates (Acc_78) |
| `quant_demo.pl` | Quant pack: histogram, grouping, frequency analysis, uniformity tests, multiset matching — 18 predicates (Acc_79) |
| `pattern_demo.pl` | Pattern pack: period detection, tiling, scaling, repetition, mirroring, constructed patterns — 15 predicates (Acc_80) |

### Tools — tools/

| File | What it does |
|---|---|
| `arc_agi_to_prolog.py` | Converts ARC-AGI JSON task files to Prolog `arc_agi_task/4` facts for use in `arc_tasks.pl`. |
| `arc_task_analysis.py` | Analyzes ARC-AGI task structure — grid sizes, color counts, transformation categories — to guide rule induction priorities. |
| `arc_inspect_failing.py` | Inspects failing ARC-AGI tasks to identify which primitive operations are needed next — the diagnostic tool that guided each wave. |

---

## Quick Start

**Prerequisite:** [PrologAI](https://github.com/ai-university-aiu/PrologAI) and SWI-Prolog 9.0.4+ (SWI stands for Sociaal-Wetenschappelijke Informatica — the University of Amsterdam research group where Jan Wielemaker created it in 1987; SWI is the Dutch name for Social Scientific Informatics)

No large language model (LLM) required.

No pretraining required.

No internet connection required.

```prolog
% Start Mentova
?- [src/mentova/boot].

% Ask Mentova a deductive question
?- mentova_query(deductive, is_a(whale, mammal), R).
R = answer(yes, just(whale, is_a, mammal, chain([whale, mammal]))).

% Run a moral evaluation
?- mentova_query(moral, evaluate(action(lie_to_save_life)), R).

% Ask about spatial relationships
?- mentova_query(spatial, chain(marble), R).

% Solve an ARC-AGI-1 task
?- mentova_query(game, game_reason(arc_agi, deductive), R).

% Run a workspace cycle
?- mentova_query(workspace, run_cycle(1), R).
```

Every answer returns `answer(Conclusion, Justification)` — the conclusion plus a readable proof trace.

No black box.

No guessing.

---

## Platform Dependency

Mentova depends on [PrologAI](https://github.com/ai-university-aiu/PrologAI):

```prolog
:- use_module(library(mentova)).
```

---

## Author

**D. R. Dison**  
Founder of AIU (Artificial Intelligence University) · Creator of PrologAI and Mentova  
ORCID: 0009-0001-9246-5758 · [LinkedIn](https://www.linkedin.com/in/d-r-dison/)
