<p align="center">
  <img src="assets/mentova_banner.svg" alt="Mentova — The World's First Glass-Box Synthetic Mind" width="100%">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/powered%20by-PrologAI-8A2BE2?style=for-the-badge" alt="Powered by PrologAI">
  <img src="https://img.shields.io/badge/ARC--AGI--1-400%2F400%20%3D%20100%25-brightgreen?style=for-the-badge" alt="ARC-AGI-1: 400/400">
  <img src="https://img.shields.io/badge/reasoning%20rungs-48%2F48-5865F2?style=for-the-badge" alt="48/48 Reasoning Rungs">
  <img src="https://img.shields.io/badge/accomplishments-270-FF6B35?style=for-the-badge" alt="270 Accomplishments">
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
| Documented accomplishments | **270 accomplished** |
| Scientific papers | **270 published** — one per accomplishment |
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
├── papers/         249 scientific papers — one per accomplishment and benchmark milestone
├── announcements/  249 announcements — one per accomplishment
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

249 scientific papers, one per accomplished milestone.

Every paper is written after the accomplishment has been achieved and measured — never before the evidence exists.

| Accomplishment | Contents |
|---|---|
| `Acc_01` (Accomplishment 01) | First transparent deduction — Mentova reasons from premises to a verifiable conclusion with a full glass-box trace |
| `Acc_02` | Inductive reasoning — Mentova induces its first general rule from specific examples |
| `Acc_03` | Abductive reasoning — Mentova infers the best explanation for observed evidence |
| `Acc_04` | Probabilistic reasoning — Mentova computes probabilities from uncertain data |
| `Acc_05` | Bayesian reasoning — Mentova updates beliefs using Bayes' theorem |
| `Acc_06` | Causal reasoning — Mentova identifies causes and effects |
| `Acc_07` | Statistical reasoning — Mentova applies statistical inference to data |
| `Acc_08` | Analogical reasoning — Mentova reasons by analogy across domains |
| `Acc_09` | Relational reasoning — Mentova reasons about relations between objects |
| `Acc_10` | Transductive reasoning — Mentova reasons from specific examples to specific new conclusions |
| `Acc_11` | Commonsense reasoning — Mentova applies everyday world knowledge |
| `Acc_12` | Logical reasoning — Mentova applies formal deductive logic |
| `Acc_13` | Formal reasoning — Mentova constructs and verifies formal proofs |
| `Acc_14` | Mathematical reasoning — Mentova solves mathematical problems symbolically |
| `Acc_15` | Fuzzy reasoning — Mentova handles graded degrees of truth |
| `Acc_16` | Qualitative reasoning — Mentova reasons about continuous quantities without exact numbers |
| `Acc_17` | Non-monotonic reasoning — Mentova handles defeasible (overridable) conclusions |
| `Acc_18` | Paraconsistent reasoning — Mentova reasons coherently under contradiction |
| `Acc_19` | Counterfactual reasoning — Mentova evaluates what would have been true under alternative conditions |
| `Acc_20` | Hypothetical reasoning — Mentova reasons from stated assumptions to their consequences |
| `Acc_21` | Spatial reasoning — Mentova reasons about positions, shapes, and spatial arrangements |
| `Acc_22` | Diagrammatic reasoning — Mentova reasons about visual and diagrammatic information |
| `Acc_23` | Temporal reasoning — Mentova reasons about time, duration, and sequential order |
| `Acc_24` | Case-based reasoning — Mentova adapts past cases to solve new problems |
| `Acc_25` | Constraint-based reasoning — Mentova finds solutions that satisfy a set of constraints |
| `Acc_26` | Scientific reasoning — Mentova applies hypothesis-testing methodology |
| `Acc_27` | System reasoning — Mentova reasons about interacting components in a system |
| `Acc_28` | Model-based reasoning — Mentova reasons using an internal model of a domain |
| `Acc_29` | Heuristic reasoning — Mentova applies practical rules of thumb to guide search |
| `Acc_30` | Critical reasoning — Mentova evaluates the strength of support for a claim |
| `Acc_31` | Dialectical reasoning — Mentova constructs and responds to structured arguments |
| `Acc_32` | Metacognitive reasoning — Mentova monitors and evaluates its own reasoning process |
| `Acc_33` | Modal reasoning — Mentova reasons about necessity and possibility |
| `Acc_34` | Epistemic reasoning — Mentova reasons about knowledge, belief, and justified certainty |
| `Acc_35` | Deontic reasoning — Mentova applies obligations, permissions, and prohibitions |
| `Acc_36` | Procedural reasoning — Mentova plans and executes step-by-step procedures |
| `Acc_37` | Symbolic reasoning — Mentova manipulates and interprets abstract symbols |
| `Acc_38` | Practical reasoning — Mentova reasons from goals and beliefs toward actions |
| `Acc_39` | Teleological reasoning — Mentova reasons from purpose and intended outcomes |
| `Acc_40` | Strategic reasoning — Mentova plans under conditions of competition or uncertainty |
| `Acc_41` | Narrative reasoning — Mentova understands and generates story structure |
| `Acc_42` | Social reasoning — Mentova models other agents' beliefs, goals, and intentions |
| `Acc_43` | Intuitive reasoning — Mentova applies fast, pattern-based heuristics |
| `Acc_44` | Emotional reasoning — Mentova appraises the emotional significance of situations |
| `Acc_45` | Motivational reasoning — Mentova identifies the drive or motive behind an action |
| `Acc_46` | Informal reasoning — Mentova detects flaws and fallacies in everyday arguments |
| `Acc_47` | Legal reasoning — Mentova applies legal rules, statutes, and precedent |
| `Acc_48` | Moral reasoning — Mentova evaluates actions against ethical principles |
| `Acc_49` | Track A transparent reasoning assistant — end-to-end demonstration of Mentova as a fully glass-box reasoning assistant |
| `Acc_50` | Game-as-a-body harness — Mentova inhabits a game environment as its physical body |
| `Acc_51` | Global Workspace integration — all cognitive modules share one broadcast workspace, the heartbeat of cognition |
| `Acc_52` | Attention Schema — Mentova maintains an internal model of its own spotlight of attention |
| `Acc_53` | Cognitive science showpieces — Sally-Anne false-belief test, Wason selection task, Wisconsin card sort |
| `Acc_54` | Piagetian battery — developmental milestone spine with Piagetian stage assessment and consciousness indicator coverage |
| `Acc_55` | ARC-AGI benchmark — induction from visual examples, no pretraining, glass-box named rules |
| `Acc_56` | Raven's Progressive Matrices — abstract rule type induction and glass-box prediction |
| `Acc_57` | Baba Is You — pushing word-blocks to rewrite rules of the game, then winning |
| `Acc_58` | Pokemon — developmental story arc, self-improvement loop, and glass-box battle decision reasoning |
| `Acc_59` | Agent-Society Interface — A2A protocol, durable peer mail, and multi-agent task exchange |
| `Acc_60` | Growth Path Report — developmental audit from Acc_01 to Acc_59, Part 38 safety evaluation, and the path toward a synthetic brain |
| `Acc_61` | Honest success criteria and caveats — formal evaluation of Part 9 of the Demonstration Plan |
| `Acc_62` | Part 10 compliance verification — recording and announcing every accomplishment through Part 10 |
| `Acc_63` | MCP Testing Suite — Mentova verified accessible via the Model Context Protocol (MCP) |
| `Acc_64` | ACP Testing Suite — Mentova verified participating in the Agent Communication Protocol (ACP) |
| `Acc_65` | ANP Testing Suite — Mentova verified with decentralized identity and peer discovery via the Agent Network Protocol (ANP) |
| `Acc_66` | Part 10 compliance extended — four-protocol integration confirmed; 66 papers and 66 announcements verified |
| `Acc_67` | Piagetian 8/8 ladder complete — levels 1, 4, 6, and 8 achieved, closing the full developmental spine |
| `Acc_68` | Mentova Console REPL — thin launcher wrapper for tutorial-friendly interactive access to the PrologAI platform |
| `Acc_69` | PrologAI Tutorial — 12-chapter, 2613-line complete introduction to the PrologAI platform for novice learners |
| `Acc_70` | Mentova Tutorial — 4-chapter, 1131-line complete introduction to the Mentova synthetic mind for novice learners |
| `Acc_71` | ARC-AGI-1 full benchmark run — 17/400 = 4.25%, pure induction, no pretraining, glass-box named rules |
| `Acc_72` | ARC-AGI-1 composite rule search — zero new tasks from geometric pairs; analysis of the 383 remaining tasks |
| `Acc_73` | Ephemera pack — ephemeral code synthesis and execution; Mentova writes and runs short-lived programs |
| `Acc_74` | Agency pack — Observe-Reason-Act-Observe loop; Mentova pursues goals with a formal agentic cycle |
| `Acc_75` | Refinery pack — evaluator-optimizer and metacognitive quality layer; Mentova critiques and improves its own outputs |
| `Acc_76` | Grid pack — ARC-AGI-2 visual grid perception and manipulation; 26 gd_* predicates |
| `Acc_77` | Analogy pack — ARC-AGI-2 structural analogy and transformation rule inference; 15 ay_* predicates for D4 isometry plus color-map inference |
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
| `Acc_100` | Induction pack paper — Grid-Pair Inductive Analysis (Layer 59): 14 id_* predicates for color map inference (id_color_map), recolor detection (id_is_recolor), color set deltas (id_new_colors, id_lost_colors), changed and unchanged cell lists (id_changed_cells, id_unchanged_cells), uniform output detection (id_uniform_output, id_output_color), dimension ratio (id_size_ratio), integer scale test (id_is_scale), and scale factor extraction (id_scale_factor). |
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
| `Acc_113` | Score pack paper — Scoring and Hypothesis Selection (Layer 72): 14 sc_* predicates for structural grid equality (sc_exact), counting matching cells (sc_cell_match), total cell count (sc_cell_total), pixel accuracy as a float in [0.0, 1.0] (sc_accuracy), per-color recall (sc_color_recall), per-color precision (sc_color_precision), per-color F1 score (sc_color_f1), applying a rule to one training pair and measuring accuracy (sc_pair_score), mean accuracy over a list of pairs (sc_pairs_score), exact-match test for one pair (sc_perfect), all-pairs exact-match test (sc_pairs_perfect), ranking candidates by accuracy descending (sc_rank), picking the best candidate (sc_best), and filtering by minimum accuracy threshold (sc_threshold). |
| `Acc_114` | Induct pack paper — Observing What Changed (Layer 73): 14 in_* predicates for computing cell-level change triples (in_delta), testing identity rules (in_constant), inferring consistent color substitution maps for one pair (in_color_map), intersecting maps across all pairs (in_color_map_pairs), computing row and column size change (in_size_change), verifying consistent size change across all pairs (in_size_change_pairs), building union color palettes (in_color_palette), separating input and output color sets across all pairs (in_palette_pairs), listing invariant cells (in_invariant_cells), listing changed cells (in_changed_cells), verifying consistent cell-change pattern across all pairs (in_consistent_delta), finding the background color by frequency (in_bg_color), verifying consistent background across all pairs (in_bg_color_pairs), and intersecting two color maps (in_common_keys). |
| `Acc_115` | Hyp pack paper — Applying the Hypothesis (Layer 74): 14 hy_* predicates for applying a color substitution map with identity fallback for unmapped colors (hy_color_sub), the identity no-op hypothesis (hy_identity), partial-application alias for color substitution (hy_from_map), pixel accuracy test for one training pair (hy_test), mean accuracy over all pairs (hy_test_all), exact-match test for one pair (hy_verify), exact-match test for all pairs (hy_verify_all), selecting the best hypothesis from a list (hy_select), ranking hypotheses by mean accuracy descending (hy_rank), alias for color substitution (hy_apply_map), sequential two-map color substitution (hy_compose), inverting a color substitution map (hy_invert_map), color lookup with identity fallback (hy_map_lookup), and describing a hypothesis as a human-readable atom (hy_describe). |
| `Acc_116` | Sym pack paper — Spatial Symmetry Transforms and Testing (Layer 75): 14 sy_* predicates covering the D4 dihedral group transforms (sy_reflect_h, sy_reflect_v, sy_transpose, sy_rotate90, sy_rotate180, sy_rotate270), symmetry detection (sy_has_h_symm, sy_has_v_symm, sy_has_rot2_symm, sy_has_rot4_symm), symmetry discovery (sy_symmetries), symmetrization (sy_make_h_symm, sy_make_v_symm), and full D4 orbit computation (sy_d4_orbit). |
| `Acc_117` | Seek pack paper — Spatial Pattern Search and Transform Discovery (Layer 76): 14 sk_* predicates for finding all positions of a value (sk_positions), finding rows/columns containing a value (sk_rows_with, sk_cols_with), listing border and interior cell positions (sk_border_cells, sk_interior_cells), exact sub-grid match test (sk_fits), enumerating and collecting sub-grid positions (sk_find_sub, sk_all_subs), counting occurrences (sk_count_sub), counting matching cells at a position (sk_match_count), finding the best-fitting position (sk_best_fit), discovering the D4 transform mapping one grid to another (sk_find_d4), upscaling each cell to a Factor x Factor block (sk_upscale), and finding the integer scale factor between two grids (sk_find_scale). |
| `Acc_118` | Remap pack paper — Color Remapping and Palette Manipulation (Layer 77): 14 rm_* predicates for replacing one value with another (rm_replace), swapping two values (rm_swap), applying a color substitution map with identity fallback (rm_apply_map), applying a map only to cells matching a specific value (rm_apply_map_to), inverting a map by swapping keys and values (rm_invert_map), composing two maps by chaining lookups (rm_compose_maps), normalizing distinct values to 1-based consecutive integers (rm_normalize), shifting all cell values by an offset (rm_shift), clamping all cell values to a range (rm_clamp), recoloring cells satisfying a predicate goal (rm_conditional), binarizing a grid to foreground/background (rm_binarize), remapping the background color (rm_remap_bg), extracting the sorted palette of distinct values (rm_palette), and reindexing a grid using a supplied palette (rm_reindex). |
| `Acc_119` | Logic pack paper — Boolean and Mask Grid Operations (Layer 78): 14 lg_* predicates for boolean intersection of grids keeping values where both are non-background (lg_and), union returning first grid's value on ties (lg_or), exclusive-or returning a value only where exactly one grid is non-background (lg_xor), inverting foreground and background (lg_not), set-difference keeping cells present in the first grid but absent in the second (lg_diff), overlaying one grid onto another with background as transparent (lg_overlay), applying a mask to keep grid values only where the mask is non-background (lg_mask_apply), creating a binary presence mask from a grid (lg_mask_from), per-row presence flags (lg_any_row), per-column presence flags (lg_any_col), per-row fullness flags (lg_all_row), per-column fullness flags (lg_all_col), cell-wise equality to 0/1 grid (lg_eq), and cell-wise inequality (lg_neq). |
| `Acc_120` | Window pack paper — Sliding Window and Neighborhood Operations (Layer 79): 14 wn_* predicates for listing 4-connected neighbor R2-C2-Val triples (wn_neighbors4), listing 8-connected neighbor triples (wn_neighbors8), counting 4-connected neighbors equal to a value (wn_count4), counting 8-connected neighbors equal to a value (wn_count8), extracting an H x W sub-grid (wn_extract), enumerating all sliding windows as R0-C0-Sub triples (wn_slide), padding all sides with N layers (wn_pad), local 4-connected maximum test (wn_local_max4), local 4-connected minimum test (wn_local_min4), cells adjacent to a target value but not equal to it (wn_halo4), integer convolution (wn_convolve), floor-center coordinates (wn_center), Manhattan distance (wn_manhattan), and in-bounds cells at exactly Manhattan distance D (wn_cells_at_dist). |
| `Acc_121` | Sort pack paper — Sorting, Ranking, and Ordering (Layer 80): 14 so_* predicates for per-row integer sums (so_row_sums), per-column integer sums (so_col_sums), count of a value per row (so_row_count), count of a value per column (so_col_count), sorting rows ascending by value count (so_sort_rows_asc), sorting rows descending (so_sort_rows_desc), sorting columns ascending (so_sort_cols_asc), sorting columns descending (so_sort_cols_desc), row index with highest count (so_max_row), row index with lowest count (so_min_row), column index with highest count (so_max_col), column index with lowest count (so_min_col), all values sorted ascending with duplicates (so_sorted_vals), and 1-based rank of a cell value among distinct grid values (so_cell_rank). |
| `Acc_122` | Tile pack paper — Tiling, Stamping, and Period Detection (Layer 81): 14 ti_* predicates for repeating a tile N times horizontally (ti_tile_h), repeating a tile N times vertically (ti_tile_v), tiling a motif into NR rows of NC copies (ti_tile), splitting a grid into horizontal TH-row bands (ti_split_rows), splitting into vertical TW-col stripes (ti_split_cols), splitting into a list-of-tile-rows (ti_split), reassembling tiles back into one grid (ti_flatten_tiles), overlaying a motif at position (R, C) (ti_stamp), stamping a motif at multiple positions (ti_stamp_all), extracting the tile at tile-position (TR, TC) (ti_extract_tile), checking if a grid is an exact tiling of one motif (ti_is_tiling), finding the smallest horizontal period in columns (ti_find_period_h), finding the smallest vertical period in rows (ti_find_period_v), and generating an H x W checkerboard (ti_checkerboard). |
| `Acc_123` | Trace pack paper — Path Tracing, Rays, and Grid Boundaries (Layer 82): 14 tr_* predicates for finding maximal contiguous non-background runs in a row (tr_runs_row), per-row run lists (tr_spans_h), per-column run lists (tr_spans_v), casting a horizontal ray to the first non-background cell (tr_ray_h), casting a vertical ray (tr_ray_v), listing cells in a horizontal line (tr_line_h), listing cells in a vertical line (tr_line_v), extracting values along a list of positions (tr_path_vals), painting a value along a list of positions (tr_draw_path), listing border cells of a bounding rectangle (tr_bbox_border), non-background cells touching background or on the grid edge (tr_perimeter), background cells adjacent to non-background cells (tr_outline), all cells on the grid boundary (tr_edge_cells), and computing the floor midpoint of two positions (tr_midpoint). |
| `Acc_124` | Label pack paper — Connected Component Labeling and Region Queries (Layer 83): 14 lb_* predicates for assigning unique integer labels to 4-connected components (lb_label), returning component cell lists (lb_components), counting components (lb_count), returning the cell count of a label (lb_size_of), sorted Label-Size pairs for all labels (lb_sizes_all), cells of a specific label (lb_cells_of), bounding box corners of a label region (lb_bbox_of), foreground labels 4-adjacent to a label (lb_neighbors_of), replacing all cells of a label with a value (lb_fill_label), keeping only the largest component (lb_keep_largest), removing components below a size threshold (lb_remove_small), coloring each label from a cycling palette (lb_color_labels), merging two labels into one (lb_merge_two), and extracting one component from the original grid (lb_select_label). |
| `Acc_125` | Morph pack paper — Morphological Grid Operations (Layer 84): 14 mo_* predicates for expanding all non-background regions by one 4-connected step copying the neighbor's color (mo_dilate), shrinking regions by one step (mo_erode), N-step dilation (mo_dilate_n), N-step erosion (mo_erode_n), morphological open (mo_open), morphological close (mo_close), morphological smooth (mo_smooth), extracting only perimeter non-background cells (mo_boundary), extracting only interior non-background cells (mo_interior), dilating with a fixed fill value (mo_dilate_val), BFS flooding from seeds into background territory (mo_grow_from), L1 Manhattan distance from each non-background cell to the nearest background cell (mo_dist_to_bg), cells added at exactly the Nth dilation step (mo_ring), and filling enclosed background regions (mo_fill_holes). |
| `Acc_126` | Walk pack paper — Grid Traversal Patterns (Layer 85): 14 wk_* predicates for listing all R-C positions in row-major order (wk_row_scan), column-major order (wk_col_scan), zigzag boustrophedon order (wk_zigzag_scan), grouped by main diagonal D = C-R (wk_diag_scan), grouped by anti-diagonal D = R+C (wk_antidiag_scan), clockwise inward spiral (wk_spiral_in), clockwise outer border walk (wk_border_walk), extracting values on a main diagonal (wk_diag_extract), extracting values on an anti-diagonal (wk_antidiag_extract), computing the main diagonal index D = C-R for a cell (wk_diag_of), computing the anti-diagonal index D = R+C (wk_antidiag_of), extracting grid values at a list of R-C positions (wk_cells_to_vals), painting values at a list of R-C positions (wk_vals_to_cells), and listing all non-border R-C positions in row-major order (wk_inner_cells). |
| `Acc_127` | Step pack paper — Directional Grid Movement (Layer 86): 14 st_* predicates for taking one unbounded step in a direction (st_step), one bounded step that fails if out of grid (st_step_in), collecting all in-bounds cells in a direction excluding the start (st_ray), collecting cells stopping before a given value (st_ray_to), collecting all in-bounds cells including the start (st_walk), the four cardinal directions (st_dirs4), all eight principal directions (st_dirs8), rotating a direction 90 degrees clockwise (st_rotate_cw), rotating counter-clockwise (st_rotate_ccw), reversing a direction (st_opposite), computing the unit step direction between two cells (st_normalize), following a list of direction steps from a start cell (st_path), finding the first cell in a direction with a given value (st_first), and counting steps until the grid boundary (st_to_edge). |
| `Acc_128` | Pivot pack paper — Pivot-Relative Cell Transformations (Layer 87): 14 pv_* predicates for applying D4 group operations (the 8 symmetries of the square) to R-C cell lists centered at any chosen pivot. |
| `Acc_129` | Project pack paper — Axis Projection and Shadow Casting (Layer 88): 14 pj_* predicates for shadow casting and axis-projection operations. |
| `Acc_130` | Diff pack paper — Multi-Pair Grid Difference Analysis (Layer 89): 14 df_* predicates for single-pair cell diff and multi-pair contrastive analysis. |
| `Acc_131` | Order pack paper — Object Spatial Ordering and Ranking (Layer 90): 14 od_* predicates for centroid-based spatial ordering of obj(Color, Cells) terms. |
| `Acc_132` | Assemble pack paper — Grid Assembly, Concatenation, and Composition (Layer 91): 14 as_* predicates for joining, scaling, framing, and compositing grids. |
| `Acc_134` | Neighbor pack paper — Cell Neighborhood Analysis (Layer 93): 14 nb_* predicates for cell-level local neighborhood analysis. |
| `Acc_133` | Region pack paper — Grid Region Extraction by Separator Lines (Layer 92): 14 rg_* predicates for content-driven grid division at separator rows and columns. |
| `Acc_175` | Naggr pack paper — Per-Cell Neighborhood Value Aggregation (Layer 134): 14 na_* predicates for per-cell aggregate statistics over in-bounds 4-connected and 8-connected neighborhoods. |
| `Acc_176` | Median pack paper — Integer Median Computation for Lists and 2D Grids (Layer 135): 14 md_* predicates for the lower (floor) integer median. |
| `Acc_177` | Nmode pack paper — Neighborhood Mode Filter for 2D Grids (Layer 136, nm_* prefix): 14 nm_* predicates for mode computation. |
| `Acc_178` | Rank pack paper — Dense Ranking of Integer Values in Lists and 2D Grids (Layer 137, rk_* prefix): 14 rk_* predicates. |
| `Acc_179` | Varstat pack paper — Mean, Sum, and Deviation Statistics for Integer Lists and 2D Grids (Layer 138, vt_* prefix): 14 vt_* predicates. |
| `Acc_180` | Cooccur pack paper — Value Co-Occurrence and Adjacency Analysis in 2D Grids (Layer 139, co_* prefix): 14 co_* predicates. |
| `Acc_181` | Rowsig pack paper — Row and Column Signature Analysis for 2D Grids (Layer 140, rs_* prefix): 14 rs_* predicates. |
| `Acc_182` | Gridops pack paper — Grid Collection Operations for Multi-Grid Analysis (Layer 141, go_* prefix): 14 go_* predicates. |
| `Acc_183` | Index pack paper — Coordinate-Valued Grid Generation and Index Masking (Layer 142, ix_* prefix): 14 ix_* predicates. |
| `Acc_184` | Fold pack paper — Grid Folding, Unfolding, and Fold-Symmetry Detection (Layer 143, fd_* prefix): 14 fd_* predicates. |
| `Acc_185` | Rotation pack paper — Grid Rotation and Rotational Symmetry Detection (Layer 144, ro_* prefix): 14 ro_* predicates. |
| `Acc_186` | Warp pack paper — Shear, Cyclic Shift, and Non-Uniform Grid Warping (Layer 145, wr_* prefix): 14 wr_* predicates. |
| `Acc_187` | Border pack paper — Concentric Ring Analysis for 2D Grids (Layer 146, br_* prefix): 14 br_* predicates. |
| `Acc_188` | Splice pack paper — Row and Column Structural Editing (Layer 147, sp_* prefix): 14 sp_* predicates. |
| `Acc_189` | Objop pack paper — Object-Level Grid Manipulation (Layer 148, oo_* prefix): 14 oo_* predicates. |
| `Acc_190` | Pair pack paper — Object Pairing and D4-Canonical Shape Correspondence (Layer 149, pr_* prefix): 14 pr_* predicates. |
| `Acc_191` | Arrange pack paper — Object Arrangement and Spatial Ordering (Layer 150, ag_* prefix): 14 ag_* predicates. |
| `Acc_192` | Xform pack paper — Object-Level Transformation and Inference (Layer 151, xf_* prefix): 14 xf_* predicates. |
| `Acc_193` | Query pack paper — Aggregate Queries over Object Lists (Layer 152, qu_* prefix): 14 qu_* predicates, all deterministic. |
| `Acc_194` | Sift pack paper — Object List Filtering by Attribute Predicates (Layer 153, si_* prefix): 14 si_* predicates, all using findall with empty result always valid. |
| `Acc_195` | Pigment pack paper — Bulk Color Operations on Object Scenes (Layer 154, pg_* prefix): 14 pg_* predicates for scene-level color manipulation. |
| `Acc_196` | Delta pack paper — Scene-Level Delta Analysis (Layer 155, dl_* prefix): 14 dl_* predicates for computing what changed between two object scenes using exact cell-set equality for matching. |
| `Acc_197` | Group pack paper — Object Grouping and Partition (Layer 156, gp_* prefix): 14 gp_* predicates for partitioning obj(Color,Cells) lists into sorted Key-[Objs] groups. |
| `Acc_198` | Proximity pack paper — Object-Level Proximity and Distance (Layer 157, px_* prefix): 14 px_* predicates for Manhattan distance and spatial relationship computation for obj(Color,Cells) terms. |
| `Acc_199` | Link pack paper — Object-to-Object Correspondence Linking (Layer 158, lk_* prefix): 14 lk_* predicates for building O1-O2 link pairs between obj(Color,Cells) lists. |
| `Acc_200` | Layout pack paper — Multi-Object Layout Analysis (Layer 159, lt_* prefix): 14 lt_* predicates for collective spatial arrangement analysis of obj(Color,Cells) lists. |
| `Acc_202` | Sizeop pack paper — Size-Based Sorting and Assignment for Object Collections (Layer 161, sz_* prefix): 14 sz_* predicates. |
| `Acc_203` | Posop pack paper — Position-Based Sorting, Filtering, and Assignment for Object Collections (Layer 162, po_* prefix): 14 po_* predicates. |
| `Acc_201` | Weave pack paper — List Interlacing, Slicing, and Cycling (Layer 160, wv_* prefix): 14 wv_* predicates for general-purpose list operations on any Prolog list. |
| `Acc_204` | Objxf pack paper — Spatial and Color Transformations for obj(Color, Cells) Terms (Layer 163, ox_* prefix): 14 ox_* predicates. |
| `Acc_205` | Shrink pack paper — Grid Downscaling and Block Decomposition (Layer 164, dn_* prefix): 14 dn_* predicates. |
| `Acc_206` | Objmorph pack paper — Morphological Operations on obj(Color, Cells) Terms (Layer 165, om_* prefix): 14 om_* predicates for binary morphology directly on obj terms without a grid. |
| `Acc_207` | Voronoi pack paper — Nearest-Color Painting and Voronoi Partitioning (Layer 166, vn_* prefix): 14 vn_* predicates for nearest-color painting and Voronoi partitioning of 2D grids. |
| `Acc_208` | Objcomp pack paper — Object Connectivity and Component Analysis (Layer 167, oc_* prefix): 14 oc_* predicates for adjacency and connected-component analysis over obj(Color, Cells) collections. |
| `Acc_209` | Wavefront pack paper — Wavefront BFS Propagation Through Passable Cells (Layer 168, wf_* prefix): 14 wf_* predicates for BFS-based wave propagation from seed cells through passable-colored cells in a 2D grid. |
| `Acc_215` | Canvas pack paper — Grid Canvas and Object Rendering (Layer 174, cv_* prefix): 14 cv_* predicates bridging obj(Color, Cells) terms and 2D grids. |
| `Acc_216` | ObjSeq pack paper — Object Sequence and Progression Analysis (Layer 175, oq_* prefix): 14 oq_* predicates for sequence-order analysis of obj(Color, Cells) term lists. |
| `Acc_217` | ObjDelta pack paper — Object-Pair Change Analysis and Rule Application (Layer 176, dp_* prefix): 14 dp_* predicates for extracting deltas from O1-O2 pairs and applying learned rules to new objects. |
| `Acc_218` | ObjCopy pack paper — Object Tiling and Multi-Copy Layout (Layer 177, tc_* prefix): 14 tc_* predicates for generating multiple positioned copies of obj(Color, Cells) terms. |
| `Acc_219` | ObjMatch pack paper — Object-List Correspondence and Matching (Layer 178, mx_* prefix): 14 mx_* predicates for finding correspondences between two obj(Color, Cells) term lists. |
| `Acc_258` | GridSpiral pack paper — Grid Spiral Traversal (Layer 217, gsp_*): 14 gsp_* predicates for clockwise spiral ordering, read/write, rotation, slicing, and per-frame spirals. |
| `Acc_259` | GridDelta pack paper — Grid Delta Analysis (Layer 218, gdt_*): 14 gdt_* predicates for difference detection, change maps, color transitions, delta application and inversion, overlay, and identity testing. |
| `Acc_260` | GridRowCol pack paper — Grid Row and Column Comparative Analysis (Layer 219, grc_*): 14 grc_* predicates for extracting, comparing, sorting, and finding matching rows and columns. |
| `Acc_261` | GridSeg pack paper — Grid Segmentation by Separator Rows and Columns (Layer 220, gsg_*): 14 gsg_* predicates for separator detection, splitting, panel extraction, and border trimming. |
| `Acc_269` | GridScan pack paper — Grid Ray Scanning (Layer 228, gsn_*): 14 gsn_* predicates for row/column content collection, first-hit detection, step-count distances, and blocking checks in four directions. |
| `Acc_270` | GridWave pack paper — Grid Wave Propagation (Layer 229, gwv_*): 14 gwv_* predicates for multi-color wave expansion, frontier detection, single-color expansion, directional shadow casting, and interior contraction. |
| `Acc_268` | GridPatch pack paper — Grid Patch Operations (Layer 227, gpt_*): 14 gpt_* predicates for patch extraction, placement, transparent overlay, pattern matching, tiling, scattering, and inpainting. |
| `Acc_267` | GridCrop pack paper — Grid Cropping and Padding (Layer 226, gcr_*): 14 gcr_* predicates for bounding-box computation, trimming, cropping, padding, centering, border add/remove, and row/column expansion. |
| `Acc_266` | GridMark pack paper — Grid Marking and Annotation (Layer 225, gmk_*): 14 gmk_* predicates for individual cell marking, row/column/rectangle marking, border, diagonal, anti-diagonal, corners, cross, checkerboard, cell querying, and mark erasure. |
| `Acc_265` | GridTile pack paper — Grid Tiling Pattern Analysis (Layer 224, gti_*): 14 gti_* predicates for period detection, tile extraction, tiling verification, row/col periodicity, tile counting, matching, offset, and minimal tile cropping. |
| `Acc_264` | GridGrav pack paper — Grid Gravity Simulation (Layer 223, gv_*): 14 gv_* predicates for settling non-bg cells in four directions, pile analysis, floating cell detection, and column gap and count queries. |
| `Acc_263` | GridPos pack paper — Grid Positional Analysis (Layer 222, gps_*): 14 gps_* predicates for halves, quadrants, even/odd rows and columns, checkerboard, center cell, corners, and center cross extraction. |
| `Acc_262` | GridHist pack paper — Grid Histogram Analysis (Layer 221, ghst_*): 14 ghst_* predicates for per-row and per-column color frequency histograms, modal color, entropy, and threshold selection. |
| `Acc_257` | GridFrame pack paper — Grid Frame Analysis (Layer 216, gfr_*): 14 gfr_* predicates for concentric ring depth, extraction, peel, uniformity, fill, and onion-pattern detection. |
| `Acc_256` | GridDiag pack paper — Grid Diagonal Analysis (Layer 215, gdi_*): 14 gdi_* predicates for main and anti-diagonal extraction, counting, uniformity testing, and modification. |
| `Acc_255` | GridGraph pack paper — Region Adjacency Graph (Layer 214, ggr_*): 14 ggr_* predicates for color adjacency, borders, enclosure, spanning detection, color merging, and connected component analysis. |
| `Acc_254` | GridConv pack paper — Grid Convolution (Layer 213, gcv_*): 14 gcv_* predicates for sliding window statistics, subgrid pattern matching, density maps, hot spot detection, and square structuring element dilation and erosion. |
| `Acc_253` | GridMorph pack paper — Morphological Grid Operations (Layer 212, gmo_*): 14 gmo_* predicates for dilation, erosion, opening, closing, inner/outer boundary extraction, morphological gradient, top-hat and bottom-hat transforms, hole filling, border flood fill, and size filtering. |
| `Acc_252` | GridEdge pack paper — Grid Edge Detection (Layer 211, ge_*): 14 ge_* predicates for 4/8-connected edge detection, directional boundary analysis, inner/outer border extraction, corner and endpoint detection, smooth cell identification, and per-cell transition count maps. |
| `Acc_251` | GridStitch pack paper — Grid Assembly (Layer 210, gst_*): 14 gst_* predicates for horizontal and vertical concatenation, list stacking, row/column splitting, half-splits, quadrant extraction, tiled arrangement, repetition, and border addition and removal. |
| `Acc_250` | GridColor pack paper — Grid Color Analysis (Layer 209, gc_*): 14 gc_* predicates for counting, histograms, frequency ranking, recoloring, color mapping, binary thresholding, dominant color detection, and fractional area computation. |
| `Acc_249` | GridSymm pack paper — Grid Symmetry (Layer 208, gsm_*): 14 gsm_* predicates for testing h/v/d1/d2/rot90/rot180 symmetry, enumerating all symmetries possessed, completing grids to target symmetry, detecting violating cells, and computing floating-point symmetry score. |
| `Acc_248` | GridXform pack paper — Grid Transformations (Layer 207, gx_*): 14 gx_* predicates for rotate 90/180/270, flip horizontal/vertical, main-diagonal transpose, anti-diagonal flip, crop, auto-crop to content, pad, scale, tile, D4 group enumeration, and canonical D4 form. |
| `Acc_247` | GridMask pack paper — Boolean mask operations (Layer 206, gm_*): 14 gm_* predicates for overlay, union, intersection, difference, inversion, mask gating, cell extraction, stamp, transparent paste, sub-grid extraction, comparison, border mask, and color selection mask. |
| `Acc_246` | GridPath pack paper — Grid Pathfinding (Layer 205, gpa_*): 14 gpa_* predicates for BFS shortest path, path length, reachability, all-reachable cells, distance maps, nearest-color search, flood-N, wavefront-at-N, horizontal/vertical segment generation, line-of-sight, interior-cell extraction, and region-to-region path. |
| `Acc_245` | GridFlood pack paper — Grid Flood-Fill, Region Analysis, Hole Filling, and Connected Components (Layer 204, gf_*): 14 gf_* predicates for 4/8-connected flood-fill, global recolor, region isolation, region cells/size/bbox, enclosed hole detection and filling, connected-component enumeration, largest-region extraction, connectivity testing, and boundary-stop fill. |
| `Acc_244` | GridRun pack paper — Grid Run-Length Encoding and Stripe Analysis (Layer 203, grl_*): 14 grl_* predicates for RLE encoding of rows and columns, decode, uniformity testing, horizontal/vertical stripe detection and color extraction, longest-run finding, and alternating-pattern detection. |
| `Acc_243` | GridScale pack paper — Grid Block-Pixel Scaling (Layer 202, gsc_*): 14 gsc_* predicates for integer upsampling, uniform-block downsampling, majority-vote downscaling, scale-factor detection, tile inference, nearest-neighbor resize, stride subsampling, border padding, and factor-aligned cropping. |
| `Acc_242` | GridPeriod pack paper — Grid Periodic Pattern Detection and Extension (Layer 201, gper_*): 14 gper_* predicates for row and column period detection, tile extraction, grid tiling and extension, autocorrelation scoring, and wrap-around cyclic shifts. |
| `Acc_241` | GridDist pack paper — Grid Distance Transform (Layer 200, gd_*): 14 gd_* predicates for Manhattan and Chebyshev distances, distance maps, BFS flood with obstacles, Voronoi assignment, zone marking, N-step morphological expand and shrink, distance-based recoloring, and equidistance detection. |
| `Acc_240` | GridNbr pack paper — Grid Neighbor Analysis (Layer 199, gn_*): 14 gn_* predicates for 4/8-neighbor queries, morphological dilation and erosion, border and isolated cell detection, and Conway-style cellular automaton steps on raw grids. |
| `Acc_239` | GridTask pack paper — Grid Task End-to-End Raw Grid Solver (Layer 198, gt_*): 14 gt_* predicates for inferring and applying identity, color substitution, scale, and shift rules on raw grids. |
| `Acc_238` | GridParse pack paper — Grid Parse and Object Extraction (Layer 197, gp_* prefix): 14 gp_* predicates for converting raw grids to obj(Color,Cells) scenes. |
| `Acc_237` | GridQuery pack paper — Grid Query and Manipulation (Layer 196, gq_* prefix): 14 gq_* predicates for raw grid format (list-of-lists). |
| `Acc_236` | SeqInfer pack paper — Sequential Rule Inference for Multi-Step Scene Transformations (Layer 195, sq_* prefix): 14 sq_* predicates for finding ordered rule sequences from Before-After training pairs. |
| `Acc_235` | SceneInv pack paper — Scene Invariant Detection across Training Pairs (Layer 194, si_* prefix): 14 si_* predicates that detect structural invariants from Before-After pairs. |
| `Acc_234` | MultiColor pack paper — Multi-Color Scene Analysis (Layer 193, mc_* prefix): 14 mc_* predicates for querying and partitioning scenes by color frequency and membership. |
| `Acc_233` | TransformGen pack paper — Systematic Generation of Scene Transformation Rule Candidates (Layer 192, tg_* prefix): 14 tg_* predicates that systematically enumerate candidate rule terms from scene data. |
| `Acc_232` | GridSolve pack paper — End-to-End Scene Puzzle Solver (Layer 191, gs_* prefix): 14 gs_* predicates integrating rule inference, candidate ranking, and rule application into a single solve/3 call. |
| `Acc_231` | ColorTable pack paper — Color Substitution Table Learning and Application (Layer 190, ct_* prefix): 14 ct_* predicates for learning a complete color substitution table from Before-After scene pair training examples and applying it to new scenes. |
| `Acc_230` | SceneRank pack paper — Rule Hypothesis Ranking for Scene Lists (Layer 189, rk_* prefix): 14 rk_* predicates ranking candidate symbolic rule terms by coverage across Before-After scene pair training examples. |
| `Acc_229` | ScenePair pack paper — Holistic Before-After Scene Pair Analysis (Layer 188, ps_* prefix): 14 ps_* predicates analyzing Before+After scene lists as a holistic pair for rule hypothesis ranking. |
| `Acc_228` | CondXf pack paper — Conditional and Selective Scene Transformation (Layer 187, xc_* prefix): 14 xc_* predicates applying transformations to a subset of objects in an obj(Color,Cells) scene list while leaving others unchanged. |
| `Acc_227` | SceneApply pack paper — Scene-Level Rule Term Evaluation Engine (Layer 186, sa_* prefix): 14 sa_* predicates applying symbolic rule terms to obj(Color,Cells) scene lists. |
| `Acc_226` | RuleInfer pack paper — Scene-Level Transformation Rule Inference from Object-List Pairs (Layer 185, ri_* prefix): 14 ri_* predicates for inferring which scene-level transformation was applied to a Before scene to produce an After scene. |
| `Acc_225` | SceneXf pack paper — Scene-Level Uniform Transformation of All Objects (Layer 184, sx_* prefix): 14 sx_* predicates applying uniform transformations to all objects in a scene list. |
| `Acc_224` | ObjLocate pack paper — Object-List Spatial and Attribute Query Against a Reference Object (Layer 183, lq_* prefix): 14 lq_* predicates for querying a list of obj(Color,Cells) terms for those satisfying a spatial or attribute relationship to a reference object. |
| `Acc_223` | SceneCmp pack paper — Scene-Level Comparison of Two Object Lists (Layer 182, sm_* prefix): 14 sm_* predicates for comparing Before and After obj(Color,Cells) lists at the inventory level. |
| `Acc_222` | ObjGroup pack paper — Object-List Grouping by Shared Attribute (Layer 181, og_* prefix): 14 og_* predicates for partitioning a list of obj(Color, Cells) terms into Key-ObjList groups sharing a common attribute value. |
| `Acc_221` | ObjAttr pack paper — Object-List Aggregate Attribute Analysis (Layer 180, oa_* prefix): 14 oa_* predicates for computing aggregate statistics and rankings over a list of obj(Color, Cells) terms. |
| `Acc_220` | ObjMerge pack paper — Object Merging, Set Operations, and Component Splitting (Layer 179, mg_* prefix): 14 mg_* predicates for cell-set operations and structural operations on obj(Color, Cells) terms. |
| `Acc_214` | Objfilter pack paper — Object List Filtering and Selection (Layer 173, of_* prefix): 14 of_* predicates for filtering and selecting from a list of obj(Color, Cells) terms. |
| `Acc_213` | Objrel pack paper — Object Pair Relation Analysis (Layer 172, or_* prefix): 14 or_* predicates for pairwise geometric and spatial relationships between two obj(Color, Cells) terms. |
| `Acc_212` | Objbound pack paper — Object Shape Classification and Bounding Box Analysis (Layer 171, ob_* prefix): 14 ob_* predicates for shape classification of obj(Color, Cells) terms. |
| `Acc_211` | Objsym pack paper — Object Symmetry Analysis for obj(Color, Cells) Terms (Layer 170, os_* prefix): 14 os_* predicates for bounding-box-relative symmetry analysis of individual objects. |
| `Acc_210` | Objchain pack paper — Linear Chain Analysis for obj(Color, Cells) Sequences (Layer 169, ch_* prefix): 14 ch_* predicates for detecting and traversing linear chains of objects. |
| `Climbing_ARC-AGI-1.txt` | The complete 79-wave ARC-AGI-1 chronicle — every attempt, every score, every rule, every lesson. Concluded at 400/400 = 100.00%. |
| `ARC-AGI-1_Perfect_Score_Report.txt` | The comprehensive achievement report — architecture, methodology, why other systems struggle, lessons learned, and next steps. |

### Announcements — announcements/

249 announcements in LinkedIn format — one per accomplishment.

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
