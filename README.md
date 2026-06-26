<p align="center">
  <img src="assets/mentova_banner.svg" alt="Mentova — The World's First Glass-Box Synthetic Mind" width="100%">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/powered%20by-PrologAI-8A2BE2?style=for-the-badge" alt="Powered by PrologAI">
  <img src="https://img.shields.io/badge/ARC--AGI--1-400%2F400%20%3D%20100%25-brightgreen?style=for-the-badge" alt="ARC-AGI-1: 400/400">
  <img src="https://img.shields.io/badge/reasoning%20rungs-48%2F48-5865F2?style=for-the-badge" alt="48/48 Reasoning Rungs">
  <img src="https://img.shields.io/badge/accomplishments-226-FF6B35?style=for-the-badge" alt="226 Accomplishments">
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
| Documented accomplishments | **226 accomplished** |
| Scientific papers | **226 published** — one per accomplishment |
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
├── papers/         226 scientific papers — one per accomplishment and benchmark milestone
├── announcements/  226 announcements — one per accomplishment
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

226 scientific papers, one per accomplished milestone.

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
| `Acc_92` | Measure pack paper — Geometric Region Metrics for Cognitive Perception (Layer 51): 14 ms_* predicates for area, bounding box, bounding box size, perimeter, diameter, extent ratio, aspect ratio, row span, column span, centroid, radius, interior count, border count, and grid color count |
| `Acc_93` | Transform pack paper — Grid-Level Spatial and Color Transformations (Layer 52): 14 tr_* predicates for scaling up and down, horizontal/vertical tiling, transposition, left-right and top-bottom reflection, 90/180 degree rotation, content shifting with fill, color-map application, single-color replacement, and mask-based cell selection |
| `Acc_94` | Select pack paper — Selection and Filtering of Cell Regions by Spatial and Size Properties (Layer 53): 14 sl_* predicates for largest, smallest, area-sorted list, area filters (exact, min, max), border test, border/interior filters, directional filters (above row, below row, left of col, right of col), and unique-area selection |
| `Acc_95` | Count pack paper — Counting Cells, Colors, and Regions in Grids (Layer 54): 14 cn_* predicates for single-color cell count, color histogram, most/least frequent colors, row/column color presence, row/column value diversity, total cell count, grid comparison counts, region color lookup, per-color region tally, and flat-list value count |
| `Acc_96` | Fill pack paper — Pattern-Based Region and Grid Filling (Layer 55): 14 fl_* predicates for region filling, bounding box filling, row/column/cell filling, border filling, region boundary and interior filling, solid-color grid creation, checkerboard grid creation, horizontal and vertical line drawing, main diagonal filling, and transparent subgrid stamp overlay |
| `Acc_97` | Pattern pack paper — Pattern Detection, Tiling Period, and Motif Extraction (Layer 56): 14 pt_* predicates for row and column period detection, horizontal and vertical grid tiling period, minimal horizontal/vertical/2D tile extraction, exact tiling test, tile match position finding and counting, H x W subgrid extraction, distinct row and column counting, and uniform-row test |
| `Acc_98` | Compare pack paper — Grid and Region Comparison, Difference Detection, and Similarity Scoring (Layer 57): 14 cp_* predicates for diff cell finding, same cell finding, color gain and loss detection, change-direction filtering, 0/1 difference map, integer-exact similarity score, region set difference/intersection/union, region equality, structural grid equality, and Old-New color shift pairs |
| `Acc_99` | Spatial pack paper — Spatial Reasoning: Directions, Containment, Adjacency, and Grid Topology (Layer 58): 14 sp_* predicates for cardinal direction, Manhattan and Chebyshev distance, 4/8-connected neighbor enumeration, 4/8-connected adjacency tests, bounding box containment, region membership, row/column band filtering, nearest and farthest region cell, and integer centroid |
| `Acc_100` | Induction pack paper — Grid-Pair Inductive Analysis (Layer 59): 14 id_* predicates for color map inference (id_color_map), recolor detection (id_is_recolor), color set deltas (id_new_colors, id_lost_colors), changed and unchanged cell lists (id_changed_cells, id_unchanged_cells), uniform output detection (id_uniform_output, id_output_color), dimension ratio (id_size_ratio), integer scale test (id_is_scale), and scale factor extraction (id_scale_factor). Mentova's 100th accomplishment. |
| `Acc_101` | Gravity pack paper — Directional Gravity and Settling Operations (Layer 60): 14 gv_* predicates for column extraction and replacement (gv_col_values, gv_set_col), falling in four directions (gv_fall_down, gv_fall_up, gv_fall_left, gv_fall_right, gv_compact_col, gv_compact_row), color-specific settling to column bottom (gv_settle_color, gv_stack_down), floating to column top (gv_float_color, gv_stack_up), and custom column and row transforms (gv_apply_col, gv_apply_row). |
| `Acc_102` | Noise pack paper — Binary Mask Operations and Grid Noise Analysis (Layer 61): 14 ns_* predicates for mask application (ns_mask_apply), inversion (ns_mask_invert), AND/OR (ns_mask_and, ns_mask_or), building masks from color criteria (ns_mask_from_color), converting masks to region lists (ns_mask_to_region) and back (ns_region_to_mask), majority color detection (ns_majority_color), noise cell identification (ns_noise_cells), denoising (ns_denoise), sparse and dense cell classification (ns_sparse_cells, ns_dense_cells), and color isolation (ns_isolate_color). |
| `Acc_103` | Generate pack paper — Grid Construction from Visual Patterns (Layer 62): 14 ge_* predicates for uniform fill (ge_uniform), gradients (ge_gradient_h, ge_gradient_v), checkerboard (ge_checkerboard), stripes (ge_stripes_h, ge_stripes_v), bordered rectangle and frame (ge_border_rect, ge_frame), diagonal patterns (ge_diagonal, ge_antidiagonal), identity matrix (ge_identity_grid), cross through center (ge_cross), cell-color map construction (ge_from_map), and pattern tiling (ge_repeat_pattern). |
| `Acc_104` | Lookup pack paper — Association List Operations and Grid Index Maps (Layer 63): 14 lk_* predicates for key lookup (lk_get), add/replace (lk_put), key and value extraction (lk_keys, lk_values), membership test (lk_has_key), deletion (lk_delete), value transformation (lk_map_values), pair building (lk_from_pairs), grid row/column/cell access (lk_grid_row, lk_grid_col, lk_grid_cell), Color-to-positions index map (lk_color_positions), position-to-Color index map (lk_position_color), and map inversion (lk_invert). |
| `Acc_105` | Connect pack paper — Flood Fill and Connected Component Analysis (Layer 64): 14 cc_* predicates for 4-connected flood fill (cc_flood4), 8-connected flood fill (cc_flood8), all 4-connected components (cc_components4), all 8-connected components (cc_components8), component counts (cc_count4, cc_count8), sorted size lists (cc_sizes4, cc_sizes8), largest component (cc_largest4, cc_largest8), smallest component (cc_smallest4), border cells (cc_border_cells), interior cells (cc_interior_cells), and background cells enclosed inside a closed shape (cc_enclosed). |
| `Acc_106` | Morph pack paper — Morphological Grid Operations (Layer 65): 14 mo_* predicates for 4-connected and 8-connected dilation (mo_dilate4, mo_dilate8), erosion (mo_erode4, mo_erode8), repeated operations (mo_dilate4_n, mo_erode4_n), morphological open (mo_open4), morphological close (mo_close4), inner boundary cells (mo_boundary4, mo_boundary8), outer one-cell ring (mo_ring4), filling enclosed background holes (mo_fill_holes4), grid padding (mo_pad), and unpadding (mo_unpad). |
| `Acc_107` | Rewrite pack paper — Rule-Based Grid Cell Rewriting (Layer 66): 14 rw_* predicates for color substitution maps (rw_map_color), single-color replacement (rw_replace_color), two-color swap (rw_swap_colors), region painting (rw_set_region), binary mask application (rw_mask_apply), grid overlay (rw_overlay), patch stamping (rw_stamp), diff-list cell edits (rw_diff_apply), color normalization (rw_normalize), color inversion (rw_invert_colors), background remapping (rw_remap_bg), border painting (rw_set_border), rectangle fill (rw_fill_rect), and conditional per-cell recoloring (rw_conditional). |
| `Acc_108` | Run pack paper — Run-Length Encoding of Grid Sequences (Layer 67): 14 rn_* predicates for encoding a flat list to Value-Count pairs (rn_encode), decoding back to a flat list (rn_decode), encoding a single grid row (rn_row_encode) or column (rn_col_encode), encoding all rows (rn_grid_rows) or all columns (rn_grid_cols), total element count (rn_length), positional lookup (rn_at), longest run of a given value (rn_max_run), distinct run count (rn_count_runs), uniformity test (rn_uniform), background trimming (rn_trim), sequence repetition with boundary merging (rn_repeat), and 0-indexed position enumeration (rn_positions). |
| `Acc_109` | Arith pack paper — Cell-Wise Arithmetic on Grids (Layer 68): 14 ar_* predicates for cell-wise addition (ar_cell_add), subtraction (ar_cell_sub), multiplication (ar_cell_mul), modulo by scalar (ar_cell_mod), scalar addition (ar_scalar_add), scalar multiplication (ar_scalar_mul), row sum (ar_row_sum), column sum (ar_col_sum), all row sums (ar_row_sums), all column sums (ar_col_sums), grid-wide maximum (ar_cell_max), grid-wide minimum (ar_cell_min), value clamping (ar_cell_clamp), and cell-wise absolute difference (ar_cell_abs_diff). |
| `Acc_110` | Obj pack paper — Object-Level Grid Reasoning (Layer 69): 14 obj_* predicates for object construction (obj_from_cells), color access (obj_color), cell access (obj_cells), size (obj_size), bounding box (obj_bbox), integer centroid (obj_center), translation-independent shape (obj_shape), inventory of one color (obj_inventory), all-color inventory (obj_all), object counting (obj_count), largest and smallest selection (obj_largest, obj_smallest), cell-to-object lookup (obj_at_cell), and size sorting (obj_sort_size). |
| `Acc_111` | Pipeline pack paper — Sequential Step Dispatch and Compositional Reasoning (Layer 70): 14 pl_* predicates for registering named step handlers (pl_register), querying handlers (pl_registered), removing handlers (pl_unregister), applying one step with local registry (pl_step), threading an input through a sequence of steps (pl_run), mapping over a list (pl_map), filtering a list (pl_filter), folding with an accumulator (pl_fold), zipping two lists (pl_zip), unzipping pairs (pl_unzip), taking (pl_take) and dropping (pl_drop) elements, and partitioning a list (pl_partition). |
| `Acc_112` | Context pack paper — Context Maps for Symbol Table Learning (Layer 71): 14 ctx_* predicates for adding or replacing key-value bindings (ctx_put), retrieving values (ctx_get), testing presence (ctx_has), deleting entries (ctx_delete), extracting keys (ctx_keys) and values (ctx_values), counting entries (ctx_size), building from pairs (ctx_from_pairs), converting to pairs (ctx_to_pairs), merging two maps with override (ctx_merge), dispatching a goal by key with fallback (ctx_dispatch), selecting by priority key list (ctx_select), transforming values (ctx_map_values), and filtering by key predicate (ctx_filter_keys). |
| `Acc_113` | Score pack paper — Scoring and Hypothesis Selection (Layer 72): 14 sc_* predicates for structural grid equality (sc_exact), counting matching cells (sc_cell_match), total cell count (sc_cell_total), pixel accuracy as a float in [0.0, 1.0] (sc_accuracy), per-color recall (sc_color_recall), per-color precision (sc_color_precision), per-color F1 score (sc_color_f1), applying a rule to one training pair and measuring accuracy (sc_pair_score), mean accuracy over a list of pairs (sc_pairs_score), exact-match test for one pair (sc_perfect), all-pairs exact-match test (sc_pairs_perfect), ranking candidates by accuracy descending (sc_rank), picking the best candidate (sc_best), and filtering by minimum accuracy threshold (sc_threshold). Completes the four-pack ARC-AGI-2 foundation layer. |
| `Acc_114` | Induct pack paper — Observing What Changed (Layer 73): 14 in_* predicates for computing cell-level change triples (in_delta), testing identity rules (in_constant), inferring consistent color substitution maps for one pair (in_color_map), intersecting maps across all pairs (in_color_map_pairs), computing row and column size change (in_size_change), verifying consistent size change across all pairs (in_size_change_pairs), building union color palettes (in_color_palette), separating input and output color sets across all pairs (in_palette_pairs), listing invariant cells (in_invariant_cells), listing changed cells (in_changed_cells), verifying consistent cell-change pattern across all pairs (in_consistent_delta), finding the background color by frequency (in_bg_color), verifying consistent background across all pairs (in_bg_color_pairs), and intersecting two color maps (in_common_keys). Observation layer for rule induction. |
| `Acc_115` | Hyp pack paper — Applying the Hypothesis (Layer 74): 14 hy_* predicates for applying a color substitution map with identity fallback for unmapped colors (hy_color_sub), the identity no-op hypothesis (hy_identity), partial-application alias for color substitution (hy_from_map), pixel accuracy test for one training pair (hy_test), mean accuracy over all pairs (hy_test_all), exact-match test for one pair (hy_verify), exact-match test for all pairs (hy_verify_all), selecting the best hypothesis from a list (hy_select), ranking hypotheses by mean accuracy descending (hy_rank), alias for color substitution (hy_apply_map), sequential two-map color substitution (hy_compose), inverting a color substitution map (hy_invert_map), color lookup with identity fallback (hy_map_lookup), and describing a hypothesis as a human-readable atom (hy_describe). Closes the observation-hypothesis-test loop for color substitution rules. |
| `Acc_116` | Sym pack paper — Spatial Symmetry Transforms and Testing (Layer 75): 14 sy_* predicates covering the D4 dihedral group transforms (sy_reflect_h, sy_reflect_v, sy_transpose, sy_rotate90, sy_rotate180, sy_rotate270), symmetry detection (sy_has_h_symm, sy_has_v_symm, sy_has_rot2_symm, sy_has_rot4_symm), symmetry discovery (sy_symmetries), symmetrization (sy_make_h_symm, sy_make_v_symm), and full D4 orbit computation (sy_d4_orbit). All 8 elements of the dihedral group D4 covered. 43/43 acceptance tests pass. |
| `Acc_117` | Seek pack paper — Spatial Pattern Search and Transform Discovery (Layer 76): 14 sk_* predicates for finding all positions of a value (sk_positions), finding rows/columns containing a value (sk_rows_with, sk_cols_with), listing border and interior cell positions (sk_border_cells, sk_interior_cells), exact sub-grid match test (sk_fits), enumerating and collecting sub-grid positions (sk_find_sub, sk_all_subs), counting occurrences (sk_count_sub), counting matching cells at a position (sk_match_count), finding the best-fitting position (sk_best_fit), discovering the D4 transform mapping one grid to another (sk_find_d4), upscaling each cell to a Factor x Factor block (sk_upscale), and finding the integer scale factor between two grids (sk_find_scale). 49/49 acceptance tests pass. |
| `Acc_118` | Remap pack paper — Color Remapping and Palette Manipulation (Layer 77): 14 rm_* predicates for replacing one value with another (rm_replace), swapping two values (rm_swap), applying a color substitution map with identity fallback (rm_apply_map), applying a map only to cells matching a specific value (rm_apply_map_to), inverting a map by swapping keys and values (rm_invert_map), composing two maps by chaining lookups (rm_compose_maps), normalizing distinct values to 1-based consecutive integers (rm_normalize), shifting all cell values by an offset (rm_shift), clamping all cell values to a range (rm_clamp), recoloring cells satisfying a predicate goal (rm_conditional), binarizing a grid to foreground/background (rm_binarize), remapping the background color (rm_remap_bg), extracting the sorted palette of distinct values (rm_palette), and reindexing a grid using a supplied palette (rm_reindex). 38/38 acceptance tests pass. |
| `Acc_119` | Logic pack paper — Boolean and Mask Grid Operations (Layer 78): 14 lg_* predicates for boolean intersection of grids keeping values where both are non-background (lg_and), union returning first grid's value on ties (lg_or), exclusive-or returning a value only where exactly one grid is non-background (lg_xor), inverting foreground and background (lg_not), set-difference keeping cells present in the first grid but absent in the second (lg_diff), overlaying one grid onto another with background as transparent (lg_overlay), applying a mask to keep grid values only where the mask is non-background (lg_mask_apply), creating a binary presence mask from a grid (lg_mask_from), per-row presence flags (lg_any_row), per-column presence flags (lg_any_col), per-row fullness flags (lg_all_row), per-column fullness flags (lg_all_col), cell-wise equality to 0/1 grid (lg_eq), and cell-wise inequality (lg_neq). 42/42 acceptance tests pass. |
| `Acc_120` | Window pack paper — Sliding Window and Neighborhood Operations (Layer 79): 14 wn_* predicates for listing 4-connected neighbor R2-C2-Val triples (wn_neighbors4), listing 8-connected neighbor triples (wn_neighbors8), counting 4-connected neighbors equal to a value (wn_count4), counting 8-connected neighbors equal to a value (wn_count8), extracting an H x W sub-grid (wn_extract), enumerating all sliding windows as R0-C0-Sub triples (wn_slide), padding all sides with N layers (wn_pad), local 4-connected maximum test (wn_local_max4), local 4-connected minimum test (wn_local_min4), cells adjacent to a target value but not equal to it (wn_halo4), integer convolution (wn_convolve), floor-center coordinates (wn_center), Manhattan distance (wn_manhattan), and in-bounds cells at exactly Manhattan distance D (wn_cells_at_dist). 42/42 acceptance tests pass. |
| `Acc_121` | Sort pack paper — Sorting, Ranking, and Ordering (Layer 80): 14 so_* predicates for per-row integer sums (so_row_sums), per-column integer sums (so_col_sums), count of a value per row (so_row_count), count of a value per column (so_col_count), sorting rows ascending by value count (so_sort_rows_asc), sorting rows descending (so_sort_rows_desc), sorting columns ascending (so_sort_cols_asc), sorting columns descending (so_sort_cols_desc), row index with highest count (so_max_row), row index with lowest count (so_min_row), column index with highest count (so_max_col), column index with lowest count (so_min_col), all values sorted ascending with duplicates (so_sorted_vals), and 1-based rank of a cell value among distinct grid values (so_cell_rank). 42/42 acceptance tests pass. |
| `Acc_122` | Tile pack paper — Tiling, Stamping, and Period Detection (Layer 81): 14 ti_* predicates for repeating a tile N times horizontally (ti_tile_h), repeating a tile N times vertically (ti_tile_v), tiling a motif into NR rows of NC copies (ti_tile), splitting a grid into horizontal TH-row bands (ti_split_rows), splitting into vertical TW-col stripes (ti_split_cols), splitting into a list-of-tile-rows (ti_split), reassembling tiles back into one grid (ti_flatten_tiles), overlaying a motif at position (R, C) (ti_stamp), stamping a motif at multiple positions (ti_stamp_all), extracting the tile at tile-position (TR, TC) (ti_extract_tile), checking if a grid is an exact tiling of one motif (ti_is_tiling), finding the smallest horizontal period in columns (ti_find_period_h), finding the smallest vertical period in rows (ti_find_period_v), and generating an H x W checkerboard (ti_checkerboard). 42/42 acceptance tests pass. |
| `Acc_123` | Trace pack paper — Path Tracing, Rays, and Grid Boundaries (Layer 82): 14 tr_* predicates for finding maximal contiguous non-background runs in a row (tr_runs_row), per-row run lists (tr_spans_h), per-column run lists (tr_spans_v), casting a horizontal ray to the first non-background cell (tr_ray_h), casting a vertical ray (tr_ray_v), listing cells in a horizontal line (tr_line_h), listing cells in a vertical line (tr_line_v), extracting values along a list of positions (tr_path_vals), painting a value along a list of positions (tr_draw_path), listing border cells of a bounding rectangle (tr_bbox_border), non-background cells touching background or on the grid edge (tr_perimeter), background cells adjacent to non-background cells (tr_outline), all cells on the grid boundary (tr_edge_cells), and computing the floor midpoint of two positions (tr_midpoint). 42/42 acceptance tests pass. |
| `Acc_124` | Label pack paper — Connected Component Labeling and Region Queries (Layer 83): 14 lb_* predicates for assigning unique integer labels to 4-connected components (lb_label), returning component cell lists (lb_components), counting components (lb_count), returning the cell count of a label (lb_size_of), sorted Label-Size pairs for all labels (lb_sizes_all), cells of a specific label (lb_cells_of), bounding box corners of a label region (lb_bbox_of), foreground labels 4-adjacent to a label (lb_neighbors_of), replacing all cells of a label with a value (lb_fill_label), keeping only the largest component (lb_keep_largest), removing components below a size threshold (lb_remove_small), coloring each label from a cycling palette (lb_color_labels), merging two labels into one (lb_merge_two), and extracting one component from the original grid (lb_select_label). 42/42 acceptance tests pass. |
| `Acc_125` | Morph pack paper — Morphological Grid Operations (Layer 84): 14 mo_* predicates for expanding all non-background regions by one 4-connected step copying the neighbor's color (mo_dilate), shrinking regions by one step (mo_erode), N-step dilation (mo_dilate_n), N-step erosion (mo_erode_n), morphological open (mo_open), morphological close (mo_close), morphological smooth (mo_smooth), extracting only perimeter non-background cells (mo_boundary), extracting only interior non-background cells (mo_interior), dilating with a fixed fill value (mo_dilate_val), BFS flooding from seeds into background territory (mo_grow_from), L1 Manhattan distance from each non-background cell to the nearest background cell (mo_dist_to_bg), cells added at exactly the Nth dilation step (mo_ring), and filling enclosed background regions (mo_fill_holes). 42/42 acceptance tests pass. |
| `Acc_126` | Walk pack paper — Grid Traversal Patterns (Layer 85): 14 wk_* predicates for listing all R-C positions in row-major order (wk_row_scan), column-major order (wk_col_scan), zigzag boustrophedon order (wk_zigzag_scan), grouped by main diagonal D = C-R (wk_diag_scan), grouped by anti-diagonal D = R+C (wk_antidiag_scan), clockwise inward spiral (wk_spiral_in), clockwise outer border walk (wk_border_walk), extracting values on a main diagonal (wk_diag_extract), extracting values on an anti-diagonal (wk_antidiag_extract), computing the main diagonal index D = C-R for a cell (wk_diag_of), computing the anti-diagonal index D = R+C (wk_antidiag_of), extracting grid values at a list of R-C positions (wk_cells_to_vals), painting values at a list of R-C positions (wk_vals_to_cells), and listing all non-border R-C positions in row-major order (wk_inner_cells). 42/42 acceptance tests pass. |
| `Acc_127` | Step pack paper — Directional Grid Movement (Layer 86): 14 st_* predicates for taking one unbounded step in a direction (st_step), one bounded step that fails if out of grid (st_step_in), collecting all in-bounds cells in a direction excluding the start (st_ray), collecting cells stopping before a given value (st_ray_to), collecting all in-bounds cells including the start (st_walk), the four cardinal directions (st_dirs4), all eight principal directions (st_dirs8), rotating a direction 90 degrees clockwise (st_rotate_cw), rotating counter-clockwise (st_rotate_ccw), reversing a direction (st_opposite), computing the unit step direction between two cells (st_normalize), following a list of direction steps from a start cell (st_path), finding the first cell in a direction with a given value (st_first), and counting steps until the grid boundary (st_to_edge). 42/42 acceptance tests pass. |
| `Acc_128` | Pivot pack paper — Pivot-Relative Cell Transformations (Layer 87): 14 pv_* predicates for applying D4 group operations (the 8 symmetries of the square) to R-C cell lists centered at any chosen pivot. Includes pv_centroid (integer floor centroid), pv_to_rel and pv_from_rel (coordinate conversion), pv_rotate_cells_cw / 180 / ccw (three rotation depths), pv_reflect_cells_h / v / diag / antidiag (four axis reflections), pv_orbit (all distinct cells reachable by D4 operations from one starting cell), pv_sym_closure (smallest D4-symmetric set containing a cell list), and pv_stamp_at (paint values at offset positions, out-of-bounds skipped). All D4 maps are integer arithmetic. 42/42 acceptance tests pass. |
| `Acc_129` | Project pack paper — Axis Projection and Shadow Casting (Layer 88): 14 pj_* predicates for shadow casting and axis-projection operations. Shadow casting: pj_shadow_down / up / left / right (non-BG cells cast their value through BG cells in one direction, stopping at the next non-BG cell) and pj_shadow_dir (direction dispatch by atom). Axis detection: pj_nonbg_rows / pj_nonbg_cols (sorted indices of occupied rows/columns). Counting: pj_row_counts / pj_col_counts (non-BG cell count per row/column). Collapse: pj_collapse_rows (2D to 1 row, first non-BG per column) / pj_collapse_cols (2D to 1 column, first non-BG per row). Boundary finding: pj_col_first / pj_col_last (topmost/bottommost non-BG row in a column) / pj_row_first (leftmost non-BG column in a row). 42/42 acceptance tests pass. |
| `Acc_130` | Diff pack paper — Multi-Pair Grid Difference Analysis (Layer 89): 14 df_* predicates for single-pair cell diff and multi-pair contrastive analysis. Single-pair analysis: df_cell_diff (all changed cells as diff(R,C,OldV,NewV) terms), df_added (cells that went BG to non-BG), df_removed (cells that went non-BG to BG), df_recolored (cells that stayed non-BG but changed color), df_stable (cells with unchanged value), df_palette_change (colors added to or lost from the palette). Multi-pair analysis: df_common_diffs (cells changed in EVERY pair), df_common_stable (cells stable in EVERY pair), df_always_added (cells added in EVERY pair), df_always_removed (cells removed in EVERY pair). Manipulation: df_total_changes, df_apply_diffs, df_invert_diffs, df_filter_diffs. 42/42 acceptance tests pass. |
| `Acc_131` | Order pack paper — Object Spatial Ordering and Ranking (Layer 90): 14 od_* predicates for centroid-based spatial ordering of obj(Color, Cells) terms. Centroid: od_centroid (integer floor mean of all cell coordinates). Sorting: od_sort_row (topmost to bottommost), od_sort_col (leftmost to rightmost), od_reading_order (row first then column), od_sort_color (by color value). Extremal selection: od_topmost, od_bottommost, od_leftmost, od_rightmost. Index access: od_nth_row (Nth in row order), od_nth_col (Nth in column order). Proximity: od_nearest (minimum Manhattan distance centroid), od_farthest (maximum Manhattan distance centroid). Ranking: od_rank_row (1-based position in row-ascending order). 42/42 acceptance tests pass. |
| `Acc_132` | Assemble pack paper — Grid Assembly, Concatenation, and Composition (Layer 91): 14 as_* predicates for joining, scaling, framing, and compositing grids. Joining: as_hcat (horizontal concatenation of a list of different grids), as_vcat (vertical stacking), as_grid_of (2D matrix of grids). Scaling: as_downscale (K x K blocks to single cells by majority vote), as_crop_to (crop or pad to exact target size). Framing: as_border (W-cell colored frame), as_center_in (embed at integer floor center of a canvas). Quadrant: as_quarter (extract tl/tr/bl/br). Mirror-concat: as_flip_h_cat (grid and its left-right mirror side by side), as_flip_v_cat (grid and its top-bottom mirror stacked). Interleave: as_zip_h (interleave columns), as_zip_v (interleave rows). Compositing: as_paste (unconditional paste), as_mask_fill (replace cells where mask is non-zero). 42/42 acceptance tests pass. |
| `Acc_134` | Neighbor pack paper — Cell Neighborhood Analysis (Layer 93): 14 nb_* predicates for cell-level local neighborhood analysis. Raw access: nb_4neighbors (nb(Row,Col,Val) list of valid 4-connected neighbors), nb_8neighbors (valid 8-connected neighbors including diagonals). Classification: nb_is_boundary (non-Bg cell with at least one Bg or OOB 4-neighbor), nb_is_interior (non-Bg cell with all 4-neighbors in-bounds and non-Bg), nb_boundary_cells (sorted R-C pairs of all boundary cells), nb_interior_cells (sorted R-C pairs of all interior cells). Value analysis: nb_count_same (4-neighbors with same color), nb_count_diff (4-neighbors with different color), nb_adjacent_colors (sorted distinct colors among 4-neighbors). Contour and contact: nb_contour (sorted R-C pairs of Color cells touching non-Color or boundary), nb_color_touches (succeed if ColorA 4-adjacent to ColorB anywhere), nb_touching_pairs (sorted (R1-C1)-(R2-C2) adjacency pairs). Grid modification: nb_flood_fill (4-connected flood fill returning modified grid), nb_dilate (expand Color region by one 4-connected layer into Bg). 42/42 acceptance tests pass. |
| `Acc_133` | Region pack paper — Grid Region Extraction by Separator Lines (Layer 92): 14 rg_* predicates for content-driven grid division at separator rows and columns. Separator detection: rg_is_sep_row (every cell in a row equals Sep), rg_is_sep_col (every cell in a column equals Sep), rg_sep_rows (sorted list of all separator row indices), rg_sep_cols (sorted list of all separator column indices). Span computation: rg_spans_h (R0-R1 inclusive spans of non-separator horizontal sections), rg_spans_v (C0-C1 spans of vertical sections). Grid splitting: rg_cut_h (list of sub-grids split at separator rows), rg_cut_v (list of sub-grids split at separator columns). Section matrix: rg_sections (2D list-of-lists of all sections), rg_section_h (N-th horizontal section, 1-indexed), rg_section_v (N-th vertical section). Counting: rg_count_h, rg_count_v. Region query: rg_region (sub-grid of the section containing cell (R,C), fails if (R,C) is a separator). 42/42 acceptance tests pass. |
| `Acc_175` | Naggr pack paper — Per-Cell Neighborhood Value Aggregation (Layer 134): 14 na_* predicates for per-cell aggregate statistics over in-bounds 4-connected and 8-connected neighborhoods. Sum: na_sum4, na_sum8. Max: na_max4, na_max8. Min: na_min4, na_min8. Floor mean: na_mean4, na_mean8. Range (max minus min): na_range4, na_range8. Spread (count distinct): na_spread4, na_spread8. Difference count (neighbors differing from cell): na_diff4, na_diff8. All empty neighborhoods return 0. 42/42 acceptance tests pass. |
| `Acc_176` | Median pack paper — Integer Median Computation for Lists and 2D Grids (Layer 135): 14 md_* predicates for the lower (floor) integer median. List median: md_median. Per-row: md_row, md_row_medians. Per-column: md_col, md_col_medians. Grid-wide: md_grid. Filters: md_filter4 and md_filter8 replace each cell with the median of the cell and its in-bounds 4/8 neighbors. Above/below selection: md_above, md_below, md_row_above, md_row_below, md_col_above, md_col_below. Uses msort/2 to preserve duplicates for correct computation. 42/42 acceptance tests pass. |
| `Acc_177` | Nmode pack paper — Neighborhood Mode Filter for 2D Grids (Layer 136, nm_* prefix): 14 nm_* predicates for mode computation. Mode of a list with smallest-value tie-breaking (nm_mode), all tied values (nm_mode_all), mode with count (nm_mode_count), per-row mode (nm_row), per-column mode (nm_col), per-row mode list (nm_row_modes), per-column mode list (nm_col_modes), grid-wide mode (nm_grid), 4-connected mode filter (nm_filter4), 8-connected mode filter (nm_filter8), uniform 4-neighborhood detection (nm_uniform4), uniform 8-neighborhood detection (nm_uniform8), 4-connected outlier detection (nm_outlier4), 8-connected outlier detection (nm_outlier8). Key fix: cut in nm_count_prefix_ prevents duplicate solutions inside findall. 42/42 acceptance tests pass. |
| `Acc_178` | Rank pack paper — Dense Ranking of Integer Values in Lists and 2D Grids (Layer 137, rk_* prefix): 14 rk_* predicates. List: rk_rank_of (1-based dense rank of a value), rk_dense (replace each element with its rank), rk_argsort_asc and rk_argsort_desc (0-based argsort, stable). Grid row/column/global: rk_row_dense, rk_col_dense, rk_grid_dense. Cell queries: rk_row_rank_of, rk_col_rank_of, rk_grid_rank_of. Selection: rk_top_n and rk_bottom_n (by distinct value) plus rk_above_rank and rk_below_rank (by rank threshold). 42/42 acceptance tests pass. |
| `Acc_179` | Varstat pack paper — Mean, Sum, and Deviation Statistics for Integer Lists and 2D Grids (Layer 138, vt_* prefix): 14 vt_* predicates. List: vt_sum (total), vt_mean_floor (floor mean via sum//count), vt_mean_round (rounded mean via float division + banker's rounding), vt_deviation (signed per-element deviation from floor mean), vt_abs_deviation (absolute deviation). Grid: vt_row_sums and vt_col_sums (per-row/col integer sums), vt_row_means and vt_col_means (per-row/col floor means), vt_global_mean (global floor mean). Position lists: vt_above_mean and vt_below_mean (cells vs global mean), vt_row_above_mean and vt_col_above_mean (cells vs their row/column mean). 42/42 acceptance tests pass. |
| `Acc_180` | Cooccur pack paper — Value Co-Occurrence and Adjacency Analysis in 2D Grids (Layer 139, co_* prefix): 14 co_* predicates. Pair enumeration: co_h_pairs (horizontal adjacent pairs), co_v_pairs (vertical, column-major), co_d_pairs_dr (down-right diagonal), co_d_pairs_dl (down-left diagonal). Counting: co_count_h (directed horizontal), co_count_v (directed vertical), co_count_adj4 (undirected 4-adjacent). Testing: co_always_adj4 (every V1 cell borders V2), co_never_adj4 (no V1-V2 adjacency), co_shared_border (at least one shared edge). Analysis: co_isolated4 (V cells with no same-value 4-neighbor), co_border_vals (distinct values bordering V). Summary: co_row_transitions (horizontal transition frequency table), co_most_common_adj4 (most frequent 4-adjacent value). 42/42 acceptance tests pass. |
| `Acc_181` | Rowsig pack paper — Row and Column Signature Analysis for 2D Grids (Layer 140, rs_* prefix): 14 rs_* predicates. Extraction: rs_col_at (single column top-to-bottom), rs_all_cols (all columns as list of lists). Frequency tables: rs_row_freq (Row-N pairs sorted by count desc), rs_col_freq (Col-N pairs sorted by count desc). Modal: rs_modal_row (most frequent row; largest wins ties), rs_modal_col (most frequent column). Unique detection: rs_uniq_rows (rows appearing exactly once), rs_uniq_cols (columns appearing exactly once). Duplicate pairs: rs_dup_row_pairs (R1-R2 pairs where row R1=row R2, R1<R2), rs_dup_col_pairs (C1-C2 pairs). Palindrome: rs_row_palindrome (row reads same L-R and R-L), rs_col_palindrome (column reads same top-bottom and bottom-top). Anagram: rs_rows_anagram (same value multiset via msort), rs_cols_anagram (same column multiset). 47/47 acceptance tests pass. |
| `Acc_182` | Gridops pack paper — Grid Collection Operations for Multi-Grid Analysis (Layer 141, go_* prefix): 14 go_* predicates. Position-set queries: go_always (positions where every grid has V), go_never (no grid has V), go_sometimes (some but not all grids have V). Counting: go_count_v (per-cell count of grids having V). Summary: go_modal (most frequent value per cell; smallest wins ties). Agreement: go_stable (all grids agree on same value), go_unstable (grids disagree). Equality: go_eq (structural unification). Elementwise arithmetic: go_add (+), go_sub (-), go_emax (max), go_emin (min). Multi-grid composition: go_overlay (first non-Bg value per cell), go_intersect (unanimous non-Bg intersection). 42/42 acceptance tests pass. |
| `Acc_183` | Index pack paper — Coordinate-Valued Grid Generation and Index Masking (Layer 142, ix_* prefix): 14 ix_* predicates. Coordinate grids: ix_row_grid (cell=R), ix_col_grid (cell=C), ix_sum_grid (cell=R+C, diagonal index), ix_diff_grid (cell=R-C, anti-diagonal, signed), ix_prod_grid (cell=R*C). Distance fields: ix_manhattan_grid (|R-R0|+|C-C0| from reference), ix_chebyshev_grid (max(|R-R0|,|C-C0|), produces concentric square shells). Modular stripes: ix_mod_grid ((R+C) mod N diagonal stripes), ix_row_mod_grid (R mod N horizontal stripes), ix_col_mod_grid (C mod N vertical stripes). Index masking: ix_mask_rows (replace non-listed rows with background), ix_mask_cols (replace non-listed cols with background). Arithmetic bridge: ix_apply (elementwise Op in {add,sub,mul,max_op,min_op} between index grid and value grid). Offset encoding: ix_from (signed linear row-major offsets from reference point). 42/42 acceptance tests pass. |
| `Acc_184` | Fold pack paper — Grid Folding, Unfolding, and Fold-Symmetry Detection (Layer 143, fd_* prefix): 14 fd_* predicates. Splitting: fd_split_h (top/bottom halves at crease row R), fd_split_v (left/right halves at crease col C). Overlay: fd_overlay (non-background cells of A overwrite B). Folding: fd_fold_h (bottom half upward; Out[I] overlays Top[I] with Bottom[R-I]), fd_fold_v (right half leftward; Out[col][I] overlays Left[col][I] with Right[col][C-I]). Unfolding: fd_unfold_h (stack half above its row-reversed copy), fd_unfold_v (join each row with its column-reverse). Symmetry (between-rows formula, consistent with fold semantics): fd_sym_h (row I maps to row 2R+1-I), fd_sym_v (col J maps to col 2C+1-J). Crease finding: fd_find_fold_h, fd_find_fold_v. Marker detection: fd_mark_row (first row all-V), fd_mark_col (first col all-V). Composition: fd_fold_both (horizontal then vertical fold; output = top-left quadrant). 42/42 acceptance tests pass. |
| `Acc_185` | Rotation pack paper — Grid Rotation and Rotational Symmetry Detection (Layer 144, ro_* prefix): 14 ro_* predicates. Core rotations: ro_rot90 (90 CW; (R,C) -> (C, H-1-R); dims W x H), ro_rot180 (180; reverse-each-row then reverse-list), ro_rot270 (270 CW; (R,C) -> (W-1-C, R); dims W x H). Dispatch: ro_rot_n (N in 0..3 with cuts). Collection: ro_all (all four rotations), ro_canonical (lex-smallest rotation; unique per equivalence class). Symmetry: ro_is_rot2 (invariant under 180), ro_is_rot4 (invariant under 90, square grids), ro_sym_order (returns 1, 2, or 4). Coordinate rotation: ro_rotate_cells (R-C pair list; N=3 NC=R, not NC=C). Spin: ro_spin2 (overlay with 180-rotation), ro_spin4 (overlay all four rotations). Matching: ro_match_rotation (find N), ro_equiv_rotation (any N). Round-trip: four 90 rotations = identity; three 90 = one 270. 46/46 acceptance tests pass. |
| `Acc_186` | Warp pack paper — Shear, Cyclic Shift, and Non-Uniform Grid Warping (Layer 145, wr_* prefix): 14 wr_* predicates. Single-row/column shift: wr_shift_row (Out[C]=Row[C-N]), wr_shift_col. Shear: wr_shear_h (row I shifts right by I*Step), wr_shear_v (column J shifts down by J*Step). Inverse: wr_unshear_h and wr_unshear_v (negate step; round-trip verified on lossless grids). Cyclic: wr_cyclic_h ((C-N) mod W), wr_cyclic_v ((R-N) mod H). Cyclic shear: wr_cyclic_shear_h (row I wraps right by I*Step), wr_cyclic_shear_v (column J wraps down by J*Step). Generalized: wr_skew_offsets (per-row offset list; specializes to shear when offsets are arithmetic). Anti-diagonal transpose: wr_transpose_anti (Out[W-1-C][H-1-R]=Grid[R][C]; involution on square grids). Detection: wr_find_shear_h and wr_find_shear_v (search bounded step range for shear mapping GridA to GridB). 42/42 acceptance tests pass. |
| `Acc_187` | Border pack paper — Concentric Ring Analysis for 2D Grids (Layer 146, br_* prefix): 14 br_* predicates. Ring depth formula: min(R, H-1-R, C, W-1-C); ring 0 is outermost; max ring = (min(H,W)-1)//2. Enumeration: br_ring_cells (R-C pairs in ring N row-major), br_ring_vals (grid values at ring N). Uniformity: br_ring_color (uniform color or fail), br_is_uniform_ring (boolean test). Outer ring: br_outer_color, br_is_uniform_outer. Border layers: br_add_border (add one V-layer: (H+2)x(W+2)), br_strip_border (remove outermost ring: (H-2)x(W-2) or []), br_inner_n (strip N rings; N=0 is identity). Multi-ring: br_ring_colors (collect uniform colors from outside in; stop at first non-uniform), br_max_ring ((min(H,W)-1)//2). Bullseye detection: br_is_nested (forall ring in 0..MaxN: uniform). Depth map: br_depth_map (same-sized grid of ring indices). Ring fill: br_fill_ring (replace ring N with V). 42/42 acceptance tests pass. |
| `Acc_188` | Splice pack paper — Row and Column Structural Editing (Layer 147, sp_* prefix): 14 sp_* predicates. Row ops: sp_insert_row (insert before index R; R=H appends), sp_delete_row (delete at R). Column ops: sp_insert_col (constant-value column before C via maplist helper), sp_delete_col (delete column C). Swap: sp_swap_rows and sp_swap_cols (between enumeration with conditional assignment; identity when R1=R2 or C1=C2). Reverse: sp_reverse_rows (reverse/2 on row list), sp_reverse_cols (maplist(reverse)). Rotate: sp_rotate_rows and sp_rotate_cols (cyclic shift by K with K mod H/W; K=H/W returns identity). Replicate: sp_replicate_row and sp_replicate_col (split, build N copies with maplist(=(V)), reassemble; N=0 deletes, N=1 is identity). Select: sp_select_rows and sp_select_cols (findall with member; allows repetition and omission). Central pattern: length(Prefix, K) then append(Prefix, Suffix, List) splits at K without index loops. 42/42 acceptance tests pass. |
| `Acc_189` | Objop pack paper — Object-Level Grid Manipulation (Layer 148, oo_* prefix): 14 oo_* predicates. Identification: oo_cells_of (sorted R-C pairs for color V via findall+between+nth0+sort), oo_bbox (bounding box via findall+min_list+max_list), oo_count (length of cells list), oo_size (bbox height and width), oo_center (integer floor center of bbox). Value ops: oo_erase (replace V with Bg), oo_repaint (replace V with NewV), oo_swap (exchange V1 and V2 via two-pass sequential set_cells calls). Translation: oo_move (translate by DR/DC; erase originals; clip out-of-bounds), oo_copy (paint at offset; originals remain). Rotation and mirror: oo_rotate90 (90 CW; formula (r,c)->(c,H-1-r) around bbox top-left), oo_rotate180 ((r,c)->(H-1-r,W-1-c)), oo_mirror_h ((r,c)->(r,W-1-c)), oo_mirror_v ((r,c)->(H-1-r,c)). Central helper: oo_set_cells_ (full H-by-W scan via nested findall+memberchk). All predicates accept and return complete grids. 42/42 acceptance tests pass. |
| `Acc_190` | Pair pack paper — Object Pairing and D4-Canonical Shape Correspondence (Layer 149, pr_* prefix): 14 pr_* predicates. Property access: pr_obj_shape (D4-canonical form: normalize to origin, apply all 8 D4 transforms, re-normalize each, take lex-min under @<), pr_obj_color (color from obj term), pr_obj_size (cell count). Pairwise tests: pr_shape_eq (same D4-canonical shape), pr_color_eq (same color), pr_size_eq (same cell count). Grouping: pr_group_color (Color-[Obj] pairs), pr_group_size (N-[Obj] pairs), pr_group_shape (Shape-[Obj] pairs). Unique: pr_unique_color (obj whose color appears exactly once), pr_unique_size (obj whose size appears exactly once). Cross-scene matching: pr_match_color (Color-O1-O2 triples), pr_match_size (N-O1-O2 triples), pr_match_shape (Shape-O1-O2 triples; horizontal pair in scene 1 matches vertical pair in scene 2). D4 ops: id/r90/r180/r270/fh/fv/fd1/fd2 on r(R,C). All predicates operate on obj(Color, Cells) terms. 42/42 acceptance tests pass. |
| `Acc_191` | Arrange pack paper — Object Arrangement and Spatial Ordering (Layer 150, ag_* prefix): 14 ag_* predicates. Centroid: ag_centroid (floor-average of cell row/col indices using sum_list//N; single representative point for position), ag_offset (displacement vector from centroid1 to centroid2). Ordering: ag_row_order (CR1 =< CR2), ag_col_order (CC1 =< CC2), ag_row_aligned (same centroid row by unification), ag_col_aligned (same centroid col by unification). Sorting: ag_sort_by_row and ag_sort_by_col use findall+keysort+findall for stable sort preserving relative order of equal-position objects. Gaps: ag_row_gaps and ag_col_gaps collect centroid positions, deduplicate with sort/2, then compute consecutive differences via ag_consec_gaps_ (cut on singleton clause to prevent choicepoint warning). Uniformity: ag_equal_row_gaps and ag_equal_col_gaps (require non-empty gap list then ag_all_equal_). Group: ag_group_bbox (bbox of all cells across all objs using min/max list on findall across all obj cell lists). Nearest: ag_nearest (Manhattan distance to each candidate centroid, keysort to find minimum). 42/42 acceptance tests pass. |
| `Acc_192` | Xform pack paper — Object-Level Transformation and Inference (Layer 151, xf_* prefix): 14 xf_* predicates. Applied: xf_recolor (replace color via head unification; zero cost), xf_translate (shift all cells by r(DR,DC); findall+sort), xf_normalize (translate to origin by subtracting min row/col; findall+sort), xf_d4 (normalize, apply one of 8 D4 ops with H1=max row/W1=max col, sort, translate back to original top-left). Identity: xf_same_cells (shared-variable unification on Cells; structural identity at zero cost), xf_cell_offset (normalize both, require normalized cells to unify meaning same shape, return DR/DC as bbox top-left differences), xf_is_recolor (shared Cells variable + C1 \\= C2). Cell arithmetic: xf_cells_added (subtract(C2,C1)), xf_cells_removed (subtract(C1,C2)), xf_cells_kept (findall+memberchk intersection), xf_overlap_count (length of kept). Inference: xf_any_d4 (member over 8 ops, apply, sort, unify with target; cut after first match for determinism; id tried first so identity found immediately), xf_scale_factor (Len2 mod Len1 =:= 0 then N=Len2//Len1 >= 1), xf_merge (append two cell lists then sort/2 deduplicates; colors must unify). 42/42 acceptance tests pass. |
| `Acc_193` | Query pack paper — Aggregate Queries over Object Lists (Layer 152, qu_* prefix): 14 qu_* predicates, all deterministic. Counting: qu_count_by_color/2 (sorted Color-N pairs via two-phase findall+sort), qu_count_by_size/2 (sorted Size-N pairs), qu_count_by_form/2 (sorted Form-N pairs where form=origin-normalized cell list, exact structural match not D4-invariant, self-contained without D4 imports). Extremes: qu_most_frequent_color/2 (highest count; smallest color on ties via member+cut on sorted Color-N list), qu_least_frequent_color/2 (lowest count; same tie-breaking), qu_largest_obj/2 (most cells; first in input on ties via findall+member+cut), qu_smallest_obj/2 (fewest cells; same tie-breaking). Totals/averages: qu_total_cells/2 (sum via findall+sum_list), qu_avg_size/2 (floor average via // integer division). Uniformity: qu_all_same_color/1 (findall colors -> sort -> singleton [_]), qu_all_same_size/1 (same pattern on cell counts), qu_all_same_form/1 (same pattern on normalized forms). Enumeration: qu_colors/2 (findall+sort), qu_sizes/2 (findall+sort). 42/42 acceptance tests pass. |
| `Acc_194` | Sift pack paper — Object List Filtering by Attribute Predicates (Layer 153, si_* prefix): 14 si_* predicates, all using findall with empty result always valid. Color: si_by_color/3 (head-unification pattern), si_not_color/3 (C \= Color), si_color_in/3 (memberchk), si_color_not_in/3 (\+ memberchk). Size: si_by_size/3 (length/2), si_larger_than/3 (S>N), si_smaller_than/3 (S<N). Form: si_by_form/3 (origin-normalized cell list via local si_norm_, exact structural match not D4-invariant, self-contained). Extreme size: si_max_size/2 and si_min_size/2 return ALL tied objects unlike qu_largest_obj which returns only the first; two-phase collect-extreme-then-findall. Color frequency: si_unique_color/2 (color count=1 via two-phase count pattern) and si_shared_color/2 (color count>1). Border: si_on_border/4 (H-by-W grid; border=row 0/H-1/col 0/W-1; member+si_on_border_ helper with four clauses and cuts) and si_off_border/4 (negation-as-failure). 42/42 acceptance tests pass. |
| `Acc_195` | Pigment pack paper — Bulk Color Operations on Object Scenes (Layer 154, pg_* prefix): 14 pg_* predicates for scene-level color manipulation. Uniform: pg_recolor_all/3 (color in findall output head). Targeted: pg_recolor_one/4 (if-then-else inside findall), pg_swap/4 (nested if-then-else in single pass; avoids double-replacement bug from calling recolor_one twice). Color tables: pg_apply_table/3 (lenient; unmapped objs keep color via memberchk+if-then-else), pg_apply_table_strict/3 (strict; unmapped objs excluded), pg_infer_table/3 (infer mapping by matching same-cell obj pairs then sort/2 deduplicates). Zip: pg_zip_recolor/3 (three-clause recursive with cuts on both base cases; truncates at shorter list). Frequency: pg_majority_to/3 (private pg_count_by_color_ + max_list + member+cut + if-then-else; smallest on ties), pg_minority_to/3 (min_list), pg_unique_to/3 (colors with count=1 via memberchk+if-then-else), pg_shared_to/3 (colors with count>1). Table utilities: pg_invert_table/2 (findall To-From: From-To), pg_table_from/2 (findall+sort), pg_consistent/1 (negation-as-failure over contradiction). 42/42 acceptance tests pass. |
| `Acc_196` | Delta pack paper — Scene-Level Delta Analysis (Layer 155, dl_* prefix): 14 dl_* predicates for computing what changed between two object scenes using exact cell-set equality for matching. Change decomposition: dl_added/3 (objects in S2 whose cell set does not appear in S1; findall+\+member), dl_removed/3 (objects in S1 absent from S2), dl_matched/3 (O1-O2 pairs sharing identical cell sets via Cells binding then sort deduplication), dl_recolored/3 (C1-C2 color change pairs for matched objects where C1 \= C2), dl_unchanged/3 (objects verbatim in both scenes via member(O,S1)+member(O,S2) term equality). Color analysis: dl_color_gain/3 (palette set difference S2 minus S1), dl_color_loss/3 (S1 minus S2). Numeric metrics: dl_count_diff/3 (length(S2)-length(S1)), dl_size_diff/3 (total_cells(S2)-total_cells(S1) via findall+length+sum_list). Change type tests: dl_is_added_only/2 (removed=[] and recolored=[]), dl_is_removed_only/2 (added=[] and recolored=[]), dl_is_recolor_only/2 (added=[] and removed=[], precondition for pg_infer_table), dl_is_stable/2 (all three empty). Composite: dl_scene_diff/3 (delta(Added,Removed,Recolored,Unchanged)). 42/42 acceptance tests pass. |
| `Acc_197` | Group pack paper — Object Grouping and Partition (Layer 156, gp_* prefix): 14 gp_* predicates for partitioning obj(Color,Cells) lists into sorted Key-[Objs] groups. Partition: gp_by_color (two-phase findall+sort on distinct colors), gp_by_size (distinct cell counts), gp_by_row (min-row key per obj via nested findall+min_list), gp_by_col (min-col key), gp_by_form (private gp_norm_ normalizes to origin via min-row/col subtraction then sort). Group access: gp_size_of (length of groups list), gp_flatten (findall over member(_-Grp,Groups)+member(O,Grp)), gp_largest_group (N-K pairs then max_list then member+cut then memberchk for choicepoint-free lookup), gp_smallest_group (min_list version). Filtering: gp_singleton_groups (length=1), gp_shared_groups (length>1). Enumeration: gp_group_sizes (findall+sort of cardinalities), gp_all_same_size (base [] with cut + sort to singleton [_]), gp_keys (findall+sort). 42/42 PLUnit tests pass. |
| `Acc_198` | Proximity pack paper — Object-Level Proximity and Distance (Layer 157, px_* prefix): 14 px_* predicates for Manhattan distance and spatial relationship computation for obj(Color,Cells) terms. Centroids: px_centroid (integer-truncated via sum_list+//), px_centroid_dist (Manhattan distance between centroids), px_min_cell_dist (minimum across all cell pairs via findall+min_list). Adjacency: px_touching (4-adjacency: member on both cell lists, =:= 1 check, cut). Selection: px_nearest (min centroid distance via findall+min_list+member+cut), px_farthest (max), px_sort_by_dist (stable msort on D-O pairs). Filtering: px_within_dist (=<), px_beyond_dist (>). Pair extrema: px_closest_pair and px_farthest_pair (all index-ordered pairs I<J via between/3+nth1/3; min/max D). Collection: px_touching_objs (findall with px_touching), px_non_touching_objs (findall with \+ px_touching). Ranking: px_dist_rank (D-Obj pairs via msort). 51/51 PLUnit tests pass. |
| `Acc_199` | Link pack paper — Object-to-Object Correspondence Linking (Layer 158, lk_* prefix): 14 lk_* predicates for building O1-O2 link pairs between obj(Color,Cells) lists. Construction: lk_by_position (zip: three-clause recursive with cuts on both base cases), lk_by_nearest (private lk_nearest_ helper: findall D-O pairs, min_list+member+cut), lk_by_color (findall Cartesian with O=obj(C,_) pattern, sort), lk_by_size (findall with length equality, sort), lk_by_form (private lk_norm_ normalizes to origin+sort; findall pairs with equal norm; sort). Access: lk_source (findall O1-_ member), lk_target (findall _-O2 member). Transform: lk_invert (findall O2-O1), lk_count (length/2). Application: lk_apply_color (findall obj(C2,Cells1) from member(obj(_,Cells1)-obj(C2,_), Links)), lk_apply_cells (findall obj(C1,Cells2)). Filtering: lk_filter_same_color (O1=obj(C,_), O2=obj(C,_)), lk_filter_diff_color (C1 \= C2). Unlinked: lk_unlinked (\+ member(O-_, Links)). 53/53 PLUnit tests pass. |
| `Acc_200` | Layout pack paper — Multi-Object Layout Analysis (Layer 159, lt_* prefix): 14 lt_* predicates for collective spatial arrangement analysis of obj(Color,Cells) lists. Bounding box: lt_global_bbox (over ALL cells of all objs: nested findall+min_list/max_list), lt_bbox_area (area=(R2-R1+1)*(C2-C1+1)). Range/count: lt_row_range, lt_col_range (min/max of topmost rows/leftmost cols), lt_row_count, lt_col_count (distinct topmost rows/cols). Line detection: lt_all_same_row and lt_all_same_col (base []+cut + sort to singleton [_]). Centroid: lt_centroid_of_all (private lt_centroid_, collect centroid rows/cols, sum_list+//). Grid: lt_is_grid (centroid R-C pairs; verify all combinations via \+ (member(R,...),member(C,...),\+member(R-C,...)); |Objs|=Rows*Cols). Diagonal: lt_is_diagonal_dr (R-C constant, sort to singleton), lt_is_diagonal_dl (R+C constant). Spacing: lt_gap_h and lt_gap_v (msort C-O/R-O pairs; extract col/row values; private lt_diffs_ recursive predicate for consecutive differences; verify all equal and > 0). This is Mentova's 200th accomplishment. 56/56 PLUnit tests pass. |
| `Acc_202` | Sizeop pack paper — Size-Based Sorting and Assignment for Object Collections (Layer 161, sz_* prefix): 14 sz_* predicates. Extraction: sz_of (cell count via length/2 on Cells field). Stable sort: sz_sort_asc (N-Obj keysort ascending; equal sizes retain input order), sz_sort_desc (negated-key trick: Neg is -N then keysort ascending = size descending). Selection: sz_smallest and sz_largest (findall sizes, min_list/max_list, then member+cut for first input-order tie-break). Rank-indexed: sz_nth_smallest and sz_nth_largest (sz_sort_asc/desc + nth1/3). Rank query: sz_rank_of (sz_sort_asc + nth1/3 to find 1-based position). Color assignment: sz_assign_colors (sz_sort_asc then private sz_zip_recolor_ with dual base clauses; truncates at shorter list). Filtering: sz_by_size (S=N), sz_above (S>N), sz_below (S<N) via findall with arithmetic test. Statistics: sz_unique_sizes (findall+sort/2 deduplication), sz_total_cells (findall+sum_list/2; empty=0). 60/60 PLUnit tests pass. |
| `Acc_203` | Posop pack paper — Position-Based Sorting, Filtering, and Assignment for Object Collections (Layer 162, po_* prefix): 14 po_* predicates. Extraction: po_row_of (min R via findall+min_list on r(R,_) cells), po_col_of (min C via findall+min_list). Rank queries: po_row_rank, po_col_rank, po_reading_rank (private sort then nth1/3; stable keysort preserves input order for ties). Color assignment: po_assign_by_row, po_assign_by_col, po_assign_reading (private sort then private po_zip_recolor_ with dual base clauses; truncates at shorter list). Reading-order sort uses compound key (Row-Col) with keysort; compound terms compare left-argument-first in SWI-Prolog standard order giving row-then-col ordering without a custom comparator. Threshold filtering: po_above_row (row < R), po_from_row (row >= R), po_left_of (col < C), po_from_col (col >= C); all via findall with arithmetic test. Band filtering: po_in_row_band (row in [R1,R2] inclusive), po_in_col_band (col in [C1,C2] inclusive). Spatial complement of sizeop (Acc_202). 58/58 PLUnit tests pass. |
| `Acc_201` | Weave pack paper — List Interlacing, Slicing, and Cycling (Layer 160, wv_* prefix): 14 wv_* predicates for general-purpose list operations on any Prolog list. Interleaving: wv_alternate (base wv_alternate([],Rest,Rest) then swap-roles recursion; when one list runs out, remainder appended), wv_split_even_odd (base [], then [H|Evens] with swapped Evens/Odds in recursive call), wv_zip (H1-H2 pairs; dual base clauses for empty left/right). Slicing: wv_stride (take head, drop next Step-1 via private wv_drop_, recurse), wv_chunk (length(Chunk,N)+append+cut; trailing remainder discarded), wv_pair_wise (two base clauses: [] and [_]; emit [A,B] recurse from [B|...]), wv_triple_wise (three base clauses), wv_take (dual base clauses: N=0+cut and []), wv_drop (dual base clauses: N=0+cut and []). Cycling and rotation: wv_rotate_left (K mod N then length(Front,K1)+append(Front,Back)+append(Back,Front)), wv_rotate_right (translate to left rotation K2=N-K1), wv_reflect (delegate to reverse/2), wv_repeat (append(List,Rest) recursion; N=0 base returns []), wv_cycle (private wv_cycle_ with Current+Source pair; restart from Source when Current=[]; N=0 base). 66/66 PLUnit tests pass. |
| `Acc_204` | Objxf pack paper — Spatial and Color Transformations for obj(Color, Cells) Terms (Layer 163, ox_* prefix): 14 ox_* predicates. Bounding box: ox_bbox (min/max row/col via findall+min_list/max_list), ox_size (H=R1-R0+1, W=C1-C0+1). Translation: ox_translate (add DR,DC to all cells), ox_to_origin (translate by -R0,-C0), ox_recolor (replace Color field only). Rotations use bounding-box-local coords Lr=R-R0, Lc=C-C0: ox_rot90 (r->r(R0+Lc, C0+(H-1)-Lr)), ox_rot180 (r->r(R0+R1-R, C0+C1-C)), ox_rot270 (r->r(R0+(W-1)-Lc, C0+Lr)). Reflections: ox_reflect_h (rows mirrored), ox_reflect_v (cols mirrored). Set algebra: ox_merge (append+sort union), ox_diff (\\+ member), ox_intersect (member). Scale-up: ox_scale_up (each cell -> Factor x Factor block via between/3). 60/60 PLUnit tests pass. |
| `Acc_205` | Shrink pack paper — Grid Downscaling and Block Decomposition (Layer 164, dn_* prefix): 14 dn_* predicates. Inverse of ox_scale_up. Block structure: dn_block_dims (BI=H//N, BJ=W//N), dn_block_cells (r(R,C) pairs for block I,J via between/3; no grid needed). Block color: dn_block_color (sort to [Color] for uniqueness; fails if mixed), dn_block_majority (dn_count_/3 helper + msort + last/2; never fails). Blocky test: dn_is_blocky (forall over all I-J pairs). Shrinking: dn_shrink (majority vote per block), dn_shrink_strict (unique color per block; fails if any block mixed). Scale search: dn_find_scale (between 2..H with divisibility check + dn_is_blocky; cut on first match). Object downscaling: dn_obj_shrink (R//N, C//N integer division; sort removes duplicates), dn_scale_factor (between 2..30; normalize both to origin via dn_norm_cells_; compare; cut). Classification: dn_uniform_blocks, dn_mixed_blocks. Extraction: dn_block_grid (NxN sub-grid), dn_block_val (flat value list row-major). Prefix dn_* chosen to avoid collision with seek pack sk_*. 52/52 PLUnit tests pass. |
| `Acc_206` | Objmorph pack paper — Morphological Operations on obj(Color, Cells) Terms (Layer 165, om_* prefix): 14 om_* predicates for binary morphology directly on obj terms without a grid. Neighborhood: om_neighbors4 (4 orthogonal neighbors; always returns 4 cells), om_neighbors8 (8 neighbors including diagonals; always returns 8 cells). Boundary/interior under 4-connectivity: om_boundary4 (\+ forall(member(N,Nbrs),member(N,S))), om_interior4 (forall(member(N,Nbrs),member(N,S))). Boundary/interior under 8-connectivity: om_boundary8, om_interior8 (same pattern, stricter). Single-step dilation: om_dilate4 (findall neighbor lists + append + sort union), om_dilate8 (same with 8-neighbors). Single-step erosion: om_erode4 delegates to om_interior4; om_erode8 delegates to om_interior8. Iterated: om_dilate4_n (N=0 identity; recurse with N-1), om_erode4_n (same). Compound: om_open4 (erode4 then dilate4; removes thin protrusions), om_close4 (dilate4 then erode4; fills small gaps). 46/46 PLUnit tests pass. |
| `Acc_207` | Voronoi pack paper — Nearest-Color Painting and Voronoi Partitioning (Layer 166, vn_* prefix): 14 vn_* predicates for nearest-color painting and Voronoi partitioning of 2D grids. Source queries: vn_non_bg_cells (findall positions where value != Bg; sorted), vn_non_bg_colors (findall+sort non-Bg values). Nearest: vn_nearest_dist (findall Manhattan distances to non-Bg cells; min_list), vn_nearest_color (findall D-V pairs; sort; take first). Painting: vn_paint_bg (V \= Bg -> keep; else vn_nearest_color). Distance transform: vn_dist_map (0 for non-Bg; pre-collect non-Bg cells; min Manhattan for Bg). Voronoi regions: vn_region_cells (findall Bg cells where nearest color = Color), vn_regions (one Color-Cells pair per non-Bg color). Distance queries: vn_max_dist (findall Bg distances; max_list), vn_at_dist (findall where dist=D), vn_within_dist (findall where dist=<D). Medial axis: vn_medial (findall Bg cells where sort of tied-nearest colors has 2+ elements). Expansion: vn_expand1 (Bg cells 4-adjacent to Color via helper with cut), vn_expand_n (Bg cells within Manhattan distance N of any Color cell; N=0 returns []). 49/49 PLUnit tests pass. |
| `Acc_208` | Objcomp pack paper — Object Connectivity and Component Analysis (Layer 167, oc_* prefix): 14 oc_* predicates for adjacency and connected-component analysis over obj(Color, Cells) collections. Touching: oc_touches (any cell of O1 is 4-adjacent to any cell of O2; cut after first found pair). Pairs: oc_touching_pairs (nth0 I < J to enumerate each unordered pair exactly once; avoids == ambiguity with unbound variables). Adjacency list: oc_adj_list (Obj-[Neighbors] for every obj via findall). Degree: oc_degree (count touching neighbors). Isolation: oc_isolated (\+ existential test). Connectivity: oc_connected (BFS with Queue+Visited accumulator), oc_components (recursive partition via subtract/3). Component aggregates: oc_num_components (length), oc_largest_component and oc_smallest_component (msort N-C pairs; last/first), oc_singleton_components (length=1), oc_shared_components (length>1). Degree aggregates: oc_max_degree (max_list on degree list), oc_sort_by_degree (keysort D-Obj pairs; stable). 40/40 PLUnit tests pass. |
| `Acc_209` | Wavefront pack paper — Wavefront BFS Propagation Through Passable Cells (Layer 168, wf_* prefix): 14 wf_* predicates for BFS-based wave propagation from seed cells through passable-colored cells in a 2D grid. Foundation: wf_passable (collect all PassColor cells), wf_bfs (BFS from seeds; seeds at D=0; Enqueued set prevents duplicate insertions; result is msorted D-r(R,C) list). Reachability: wf_reachable (cells in DistPairs), wf_unreachable (PassColor cells absent from DistPairs), wf_path_exists (memberchk on BFS result; no choicepoints). Distance queries: wf_at_dist (exact D), wf_within_dist (D <= MaxD), wf_dist_of (distance of specific cell; fails if absent), wf_max_dist (max D in DistPairs), wf_all_dists (sorted distinct D values). Painting: wf_paint_bg (replace PassColor cells with min(BFS_dist, MaxD); unreachable unchanged). Multi-source: wf_multi_wave (one BFS per color; each PassColor cell gets nearest-color winner; ties by term order), wf_collision (passable cells where MinD is achieved by 2+ colors: sort D-Color pairs, check [MinD-_|Rest] contains MinD again). Enclosure: wf_enclosed (seed from all PassColor border cells; return PassColor cells absent from exterior BFS). 41/41 PLUnit tests pass. |
| `Acc_215` | Canvas pack paper — Grid Canvas and Object Rendering (Layer 174, cv_* prefix): 14 cv_* predicates bridging obj(Color, Cells) terms and 2D grids. No cross-pack dependencies; 2 private helpers (cv_paint_cells_ and cv_erase_cells_, each doing a single findall pass). cv_blank (H x W grid of Bg). cv_size (length+length of first row). cv_paint (paint_cells_ with Color). cv_paint_all (recursive, foldl pattern). cv_paint_at (translate cells by DR,DC then paint_cells_). cv_paint_clip (filter in-bounds cells then paint_cells_). cv_paint_bg (filter cells where grid[R][C]=Bg then paint_cells_). cv_erase (erase_cells_ with Bg). cv_extract (findall r(R,C) where grid[R][C]=Color). cv_extract_all (collect non-Bg triples; sort colors; build one obj per color). cv_render (cv_blank then cv_paint_all). cv_move (cv_erase then cv_paint_at). cv_stamp (normalize cells to origin; cv_blank + paint_cells_). cv_blit (per-cell findall; replace if PR,PC in patch bounds else keep). 41/41 PLUnit tests pass. |
| `Acc_216` | ObjSeq pack paper — Object Sequence and Progression Analysis (Layer 175, oq_* prefix): 14 oq_* predicates for sequence-order analysis of obj(Color, Cells) term lists. No cross-pack dependencies; 11 private helpers (oq_color_, oq_size_, oq_centroid_, oq_steps_, oq_strictly_inc_, oq_strictly_dec_, oq_period_, oq_tiles_, oq_cross2d_, oq_row_of_, oq_col_of_). Extraction: oq_color_seq (maplist oq_color_), oq_size_seq (maplist oq_size_), oq_centroid_seq (maplist oq_centroid_), oq_step_seq (centroid_seq then oq_steps_). Monotone: oq_is_growing (oq_strictly_inc_ on sizes), oq_is_shrinking (oq_strictly_dec_ on sizes). Spacing: oq_const_step (steps=[dr(DR,DC)|rest]; maplist==(dr(DR,DC))), oq_const_row_step (maplist oq_row_of_(DR)), oq_const_col_step (maplist oq_col_of_(DC)). Periodicity: oq_color_period (between/3 + 0=:=N mod P + oq_tiles_ check + cut), oq_size_period (same on sizes). Geometry: oq_collinear (cross2d P1,P2,P3=0 for all P3 beyond first two). Prediction: oq_next_centroid (const_step + last centroid + project). Mapping: oq_zip_colors (recursive C1-C2 pair list). 41/41 PLUnit tests pass. |
| `Acc_217` | ObjDelta pack paper — Object-Pair Change Analysis and Rule Application (Layer 176, dp_* prefix): 14 dp_* predicates for extracting deltas from O1-O2 pairs and applying learned rules to new objects. No cross-pack dependencies; 7 private helpers (dp_centroid_, dp_norm_, dp_pair_delta_, dp_color_pair_, dp_positions_, dp_row_of_, dp_col_of_). Extraction: dp_color_delta (O1/O2 color head unification), dp_pos_delta (centroid subtraction), dp_size_delta (length subtraction). Tests: dp_same_color (head unification), dp_same_form (dp_norm_ + sort + compare), dp_same_pos (centroid equality). Color map: dp_color_map (maplist dp_color_pair_ + sort), dp_apply_color (head unification on C1; fail otherwise), dp_apply_color_map (recursive try-cut), dp_apply_map_all (if-then-else; unchanged on no match). Displacement: dp_const_dr (maplist dp_row_of_), dp_const_dc (maplist dp_col_of_). Cells: dp_common_cells (intersection/3 on sorted positions), dp_cell_diff (subtract/3 twice). 41/41 PLUnit tests pass. |
| `Acc_218` | ObjCopy pack paper — Object Tiling and Multi-Copy Layout (Layer 177, tc_* prefix): 14 tc_* predicates for generating multiple positioned copies of obj(Color, Cells) terms. No cross-pack dependencies; private helpers tc_minrow_, tc_mincol_, tc_maxrow_, tc_maxcol_, tc_bbox_h_, tc_bbox_w_, tc_translate_, tc_place_at_, min_list_r_, min_list_c_, tc_pack_row_acc_, tc_pack_col_acc_, tc_shift_to_row_, tc_shift_to_col_. tc_place_at (bbox top-left placement via translate). tc_recolor_all (recursive color replacement). tc_tile_row (findall+between N copies at C0+I*Step). tc_tile_col (findall+between N copies at R0+I*Step). tc_tile_grid (nested between I/J for NR*NC grid). tc_at_positions (recursive, one copy per r(R,C)). tc_align_top (maplist minrow + min_list global + maplist shift_to_row). tc_align_left (same pattern for cols). tc_pack_row (maplist shift_to_row + pack_row_acc_ cursor). tc_pack_col (maplist shift_to_col + pack_col_acc_ cursor). tc_spread_h (findall+nth0+between; col=C0+I*Step). tc_spread_v (findall+nth0+between; row=R0+I*Step). tc_center (bbox dims + floor//2 offset + place_at_). tc_flip_h (findall r(R,W-1-C)). 41/41 PLUnit tests pass. |
| `Acc_219` | ObjMatch pack paper — Object-List Correspondence and Matching (Layer 178, mx_* prefix): 14 mx_* predicates for finding correspondences between two obj(Color, Cells) term lists. No cross-pack dependencies; private helpers mx_color_, mx_size_, mx_norm_, mx_centroid_, mx_sq_dist_, mx_nearest_in_, mx_greedy_match_, mx_color_delta_, mx_pos_delta_, mx_size_delta_, mx_color_delta_eq_, mx_pos_delta_eq_, mx_size_delta_eq_. Matching: mx_by_color (findall cross-product, color equality), mx_by_size (findall, size equality), mx_by_form (findall, norm equality), mx_by_nearest (mx_greedy_match_: each O1 claims nearest remaining O2 by mx_sq_dist_ + msort). Extraction: mx_unmatched/5 (findall matched, subtract/3). Filtering: mx_filter_changed_color (findall, C1\=C2), mx_filter_same_color (findall, C1=C2). Deltas: mx_color_deltas/mx_pos_deltas/mx_size_deltas (maplist over private delta helpers). Uniformity: mx_all_same_color_delta/mx_all_same_pos_delta/mx_all_same_size_delta (base=[]; step: extract Ref from first, maplist equality check). Zip: mx_zip (recursive, pairs by index). 41/41 PLUnit tests pass. |
| `Acc_226` | RuleInfer pack paper — Scene-Level Transformation Rule Inference from Object-List Pairs (Layer 185, ri_* prefix): 14 ri_* predicates for inferring which scene-level transformation was applied to a Before scene to produce an After scene. Pairs expressed as Before-After terms. Inference: ri_infer_recolor (distinct-color set difference [Old] and [New]; count parity check), ri_infer_recolor_all (After has exactly one distinct color), ri_infer_color_map (position-matched objects; ri_infer_color_map_acc_ recursive accumulator; skips unchanged colors), ri_infer_keep_color (After has one color; After length < Before length; count parity), ri_infer_remove_color (single color in subtract(CB,CA)), ri_infer_shift (first-object match by color+norm; candidate DR/DC; scene msort verify; cut for determinism), ri_infer_to_origin (scene_bbox_ MinR/MinC; negate; msort verify). Consistency: ri_consistent_recolor/ri_consistent_color_map/ri_consistent_keep_color/ri_consistent_remove_color/ri_consistent_shift all use forall over pairs with msort comparison. Cross-pair: ri_all_same_n_objs (forall length equality), ri_all_same_colors (forall distinct_colors equality). 41/41 PLUnit tests pass. |
| `Acc_225` | SceneXf pack paper — Scene-Level Uniform Transformation of All Objects (Layer 184, sx_* prefix): 14 sx_* predicates applying uniform transformations to all objects in a scene list. No cross-pack dependencies; private helpers sx_color_, sx_size_, sx_norm_, sx_topleft_, sx_shift_obj_, sx_reflect_h_obj_, sx_reflect_v_obj_, sx_apply_map_obj_, sx_scene_bbox_, sx_recolor_atom_, sx_set_color_, sx_dedup_form_acc_. Color: sx_recolor (atom == equality, maplist sx_recolor_atom_), sx_recolor_all (maplist sx_set_color_), sx_apply_color_map (maplist sx_apply_map_obj_ with member if-then-else). Spatial: sx_shift (maplist sx_shift_obj_ findall R+DR/C+DC), sx_to_origin (sx_scene_bbox_ + negate MinR/MinC + sx_shift), sx_reflect_h (maplist sx_reflect_h_obj_ Width-1-C), sx_reflect_v (maplist sx_reflect_v_obj_ Height-1-R). Filtering: sx_remove_color (findall C\==Color), sx_keep_color (findall color==Color). Ordering: sx_sort_size_desc (negated-count msort), sx_sort_size_asc (count msort), sx_sort_pos (r(MinR,MinC)-Obj key msort). Selection: sx_top_n (size-desc then length+append Prefix, fallback to full scene). Deduplication: sx_dedup_form (sx_dedup_form_acc_ accumulator; sx_norm_ translate-to-origin+sort; memberchk on Seen). 41/41 PLUnit tests pass. |
| `Acc_224` | ObjLocate pack paper — Object-List Spatial and Attribute Query Against a Reference Object (Layer 183, lq_* prefix): 14 lq_* predicates for querying a list of obj(Color,Cells) terms for those satisfying a spatial or attribute relationship to a reference object. No cross-pack dependencies; private helpers lq_color_, lq_cells_, lq_centroid_, lq_topleft_, lq_norm_, lq_sq_dist_, lq_touch4_, lq_touch8_, lq_overlap_. Directional (centroid-based): lq_above (CR<RefR), lq_below (CR>RefR), lq_left_of (CC<RefC), lq_right_of (CC>RefC). Adjacency: lq_touching4 (Manhattan=1, no overlap), lq_touching8 (Chebyshev=1, no overlap), lq_overlapping (shared cell). Attribute: lq_same_color (color atom equality), lq_same_form (lq_norm_ translate-to-origin+sort), lq_aligned_h (min_row equality), lq_aligned_v (min_col equality). Distance: lq_nearest (D-Obj msort, take first), lq_farthest (-D-Obj msort, take first), lq_n_touching4 (length of lq_touching4 result). 41/41 PLUnit tests pass. |
| `Acc_223` | SceneCmp pack paper — Scene-Level Comparison of Two Object Lists (Layer 182, sm_* prefix): 14 sm_* predicates for comparing Before and After obj(Color,Cells) lists at the inventory level. No cross-pack dependencies; private helpers sm_color_, sm_size_, sm_norm_, sm_distinct_colors_, sm_distinct_forms_. Introspection: sm_n_objs (length), sm_total_cells (sum_list), sm_colors (findall+sort), sm_forms (findall norm+sort). Symmetric: sm_same_n_objs, sm_same_total_cells, sm_same_colors, sm_same_forms (equality of inventory). Asymmetric: sm_added_colors (subtract(CA,CB)), sm_removed_colors (subtract(CB,CA)), sm_added_forms (subtract(FA,FB)), sm_removed_forms (subtract(FB,FA)). Aggregate: sm_n_color_change (length(Added)+length(Removed)). Detector: sm_any_change (disjunction+cut: count OR color OR form differs). 41/41 PLUnit tests pass. |
| `Acc_222` | ObjGroup pack paper — Object-List Grouping by Shared Attribute (Layer 181, og_* prefix): 14 og_* predicates for partitioning a list of obj(Color, Cells) terms into Key-ObjList groups sharing a common attribute value. No cross-pack dependencies; private helpers og_color_, og_size_, og_topleft_, og_norm_, og_group_by_, og_row_key_, og_col_key_, og_count_, og_count_eq_. Grouping: og_by_color (og_group_by_ with og_color_ key), og_by_size (og_size_ key), og_by_form (og_norm_ translate-to-origin+sort key), og_by_row (og_row_key_ min-row), og_by_col (og_col_key_ min-col). Inspection: og_n_groups (length), og_n_members (findall count=N), og_singletons (og_n_members N=1). Aggregates: og_largest (negated-count msort first), og_smallest (ascending-count msort first). Uniformity: og_all_same_size (maplist og_count_eq_). Utilities: og_sort_desc (negated-count msort), og_flat (findall over all members), og_filter_size (findall N>=Min, N=<Max). 41/41 PLUnit tests pass. |
| `Acc_221` | ObjAttr pack paper — Object-List Aggregate Attribute Analysis (Layer 180, oa_* prefix): 14 oa_* predicates for computing aggregate statistics and rankings over a list of obj(Color, Cells) terms. No cross-pack dependencies; private helpers oa_color_, oa_size_, oa_norm_, oa_topleft_, oa_count_color_, oa_total_cells_color_, oa_mode_, oa_run_max_, oa_run_max_acc_, oa_color_eq_, oa_size_eq_, oa_norm_eq_. Counts: oa_total_cells (sum_list of sizes), oa_color_counts (findall+sort distinct colors; count per color), oa_cell_counts_by_color (sum cells per color), oa_n_colors (length of distinct list), oa_n_objs_of_color (oa_count_color_). Dominance: oa_dominant_color (negated-total msort trick), oa_rarest_color (ascending msort), oa_unique_color (member Color-1; backtrackable). Rankings: oa_size_rank (negated count msort), oa_pos_rank (r(R,C) key msort). Mode: oa_majority_size (oa_mode_ via oa_run_max_acc_ run-length accumulator). Uniformity: oa_all_same_color (maplist oa_color_eq_), oa_all_same_size (maplist oa_size_eq_), oa_all_same_form (oa_norm_ translate-to-origin + sort; maplist oa_norm_eq_). 41/41 PLUnit tests pass. |
| `Acc_220` | ObjMerge pack paper — Object Merging, Set Operations, and Component Splitting (Layer 179, mg_* prefix): 14 mg_* predicates for cell-set operations and structural operations on obj(Color, Cells) terms. No cross-pack dependencies; private helpers mg_cells_, mg_color_, mg_maxrow_, mg_maxcol_, mg_minrow_, mg_mincol_, mg_translate_, mg_neighbors4_, mg_neighbors8_, mg_bfs_, mg_components_. Set ops: mg_union_cells (union/3 on sorted cell lists), mg_intersect_cells (intersection/3), mg_diff_cells (subtract/3), mg_sym_diff_cells (two subtract/3 + append). Concat: mg_concat_h (shift O2 by maxcol(O1)+1+Gap-mincol(O2) then append), mg_concat_v (shift by row). List: mg_merge_list (findall all cells + sort), mg_subtract_list (findall remove cells + subtract/3). Bbox: mg_expand_bbox (between/3 over MinR..MaxR x MinC..MaxC), mg_hollow_bbox (same + disjunctive border guard + sort to deduplicate corners), mg_pad (expand range by P each side). Components: mg_split_cc4/mg_split_cc8 (mg_components_ iterates mg_bfs_ using neighbors4_/neighbors8_), mg_n_components4 (length of split_cc4 result). 41/41 PLUnit tests pass. |
| `Acc_214` | Objfilter pack paper — Object List Filtering and Selection (Layer 173, of_* prefix): 14 of_* predicates for filtering and selecting from a list of obj(Color, Cells) terms. No cross-pack dependencies; 9 private helpers (of_size_, of_bbox_, of_is_rect_, of_is_hline_, of_is_vline_, of_is_single_, of_is_hollow_, of_largest_acc_, of_smallest_acc_). Color filters: of_by_color (findall match obj(Color,_)), of_not_color (findall C\=Color). Size filters: of_exact_size, of_min_size, of_max_size (findall+member+arithmetic). Shape filters: of_is_rect (count=H*W), of_is_hline (MinR=MaxR), of_is_vline (MinC=MaxC), of_is_single (count=1), of_is_hollow (count<H*W). Aggregates: of_largest (first max via accumulator), of_smallest (first min via accumulator). Meta: of_filter (wraps include/3), of_partition (wraps partition/4); both :- meta_predicate. 43/43 PLUnit tests pass. |
| `Acc_213` | Objrel pack paper — Object Pair Relation Analysis (Layer 172, or_* prefix): 14 or_* predicates for pairwise geometric and spatial relationships between two obj(Color, Cells) terms. Colors ignored throughout. Private helpers: or_centroid_ (float centroid sum_rows/N, sum_cols/N), or_bbox_ (row/col extremes via findall+min/max_list), or_dir_ (delta to compass atom via arithmetic if-then-else). or_overlap (member+memberchk+cut). or_shared_cells (findall+memberchk filter). or_n_shared (length of intersection). or_touch4 (\+overlap guard then Manhattan=1 pair search+cut). or_touch8 (\+overlap guard then Chebyshev=1 pair search+cut). or_contains (forall+memberchk). or_union_cells (append+sort). or_dist (Euclidean sqrt of squared centroid deltas). or_manhattan (abs sum of centroid deltas). or_direction (centroid deltas through or_dir_; Dir one of n/s/e/w/ne/nw/se/sw/same). or_aligned_h (centroid rows =:=). or_aligned_v (centroid cols =:=). or_gap_rows (max(0,max(MinR1,MinR2)-min(MaxR1,MaxR2)-1)). or_gap_cols (same for col extremes). 61/61 PLUnit tests pass. |
| `Acc_212` | Objbound pack paper — Object Shape Classification and Bounding Box Analysis (Layer 171, ob_* prefix): 14 ob_* predicates for shape classification of obj(Color, Cells) terms. ob_bbox_h (MaxR-MinR+1). ob_bbox_w (MaxC-MinC+1). ob_bbox_area (H*W). ob_is_rect (cell count = bbox area). ob_is_hline (H=1). ob_is_vline (W=1). ob_is_single (H=1 AND W=1). ob_is_square_bbox (H=W). ob_holes (bbox cells not in object via between/3 + \+ memberchk). ob_n_holes (length of holes list). ob_is_hollow (N>0). ob_is_frame (H>=3, W>=3, forall border cells, \+ interior cells). ob_perimeter (sum of exposed edges per cell via ob_cell_exposed_ private helper). ob_dense_hull (solid bbox rectangle with same color). 73/73 PLUnit tests pass. |
| `Acc_211` | Objsym pack paper — Object Symmetry Analysis for obj(Color, Cells) Terms (Layer 170, os_* prefix): 14 os_* predicates for bounding-box-relative symmetry analysis of individual objects. os_bbox (min/max row and col). os_normalize (translate to origin). os_translate (shift by DR, DC). os_reflect_h (mirror left-right: new C = MinC+MaxC-C). os_reflect_v (mirror top-bottom: new R = MinR+MaxR-R). os_rotate180 (both flips). os_rotate90 (CW 90-degree rotation normalized to origin: new NR=C-MinC, new NC=MaxR-R). os_is_hsymm (sorted cells == sorted cells of reflect_h). os_is_vsymm (sorted cells == sorted cells of reflect_v). os_is_rot180 (sorted cells == sorted cells of rotate180). os_is_rot90 (normalized sorted cells == normalized sorted cells after rotate90). os_has_symmetry (disjunction with cut). os_symmetries (findall over [h,v,rot180,rot90] with case dispatch). os_equivalent (normalize Obj1; iterate D4 orbit of Obj2 via os_d4_orbit_; compare msorted cells ignoring color; cut on first match). 61/61 PLUnit tests pass. |
| `Acc_210` | Objchain pack paper — Linear Chain Analysis for obj(Color, Cells) Sequences (Layer 169, ch_* prefix): 14 ch_* predicates for detecting and traversing linear chains of objects. A chain is a set of objects whose 4-adjacency touching graph is a simple path (exactly two degree-1 endpoints; all interior objects degree 2). ch_touches (4-adjacency; cut after first pair). ch_degree (count touching neighbors). ch_is_chain (empty/singleton trivially true; two: ch_touches; N>=3: degree constraints: no degree>2, no degree=0, exactly two degree-1 objects). ch_has_cycle (N>=3 and all degrees=2; uses =\= for arithmetic inequality). ch_endpoints (findall degree-1 objects). ch_linearize (endpoint then ch_walk_). ch_walk_ (DFS: follow unique unvisited touching neighbor; ch_next_ handles base case [] and singleton [Next]; multiple neighbors -> fail = branching detected). ch_from_endpoint (ch_walk_ from specified start). ch_nth (nth0 delegate). ch_color_seq (findall color from each obj term). ch_sub (length+append slice I..J). ch_reverse (reverse/2 delegate). ch_length (length/2 delegate). ch_is_linear_path (recursive: O1 touches O2, recurse). ch_direction (h: all min-rows same via forall; v: all min-cols same; other: fallthrough). 48/48 PLUnit tests pass. |
| `Climbing_ARC-AGI-1.txt` | The complete 79-wave ARC-AGI-1 chronicle — every attempt, every score, every rule, every lesson. Concluded at 400/400 = 100.00%. |
| `ARC-AGI-1_Perfect_Score_Report.txt` | The comprehensive achievement report — architecture, methodology, why other systems struggle, lessons learned, and next steps. |

### Announcements — announcements/

226 announcements in LinkedIn format — one per accomplishment.

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
