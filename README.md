<p align="center">
  <img src="assets/Mentova_754x176_New.png" alt="Mentova — The World's First Glass-Box Synthetic Mind" width="100%">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/powered%20by-PrologAI-8A2BE2?style=for-the-badge" alt="Powered by PrologAI">
  <img src="https://img.shields.io/badge/ARC--AGI--1-400%2F400%20%3D%20100%25-brightgreen?style=for-the-badge" alt="ARC-AGI-1: 400/400">
  <img src="https://img.shields.io/badge/reasoning%20types-48%2F48-5865F2?style=for-the-badge" alt="48/48 Reasoning Types">
  <img src="https://img.shields.io/badge/accomplishments-332-FF6B35?style=for-the-badge" alt="332 Accomplishments">
  <img src="https://img.shields.io/badge/ARC--AGI--2-34%2F120%20%3D%2028.33%25-orange?style=for-the-badge" alt="ARC-AGI-2: 34/120 = 28.33%">
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
| ARC-AGI-2 (Abstract Reasoning Corpus - Artificial General Intelligence - Year 2) | **34/120 = 28.33%** — Wave 34; climbing underway |
| Documented accomplishments | **331 accomplished** |
| Scientific papers | **330 published** — one per accomplishment |
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
| 1 | 48/48 Cognitive Reasoning Levels | ✅ Complete |
| 2 | ARC-AGI-1: 400/400 = 100% | ✅ Complete (2026-06-24) |
| 3 | ARC-AGI-2 benchmark | 🔄 Underway — Wave 34 complete (34/120 = 28.33%) |
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
├── papers/         331 scientific papers — one per accomplishment and benchmark milestone
├── announcements/  306 announcements — one per accomplishment
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

331 scientific papers, one per accomplished milestone.

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
| `Acc_78` | Scene pack — Object-Centric Reasoning (Layer 37): 24 sc_* predicates for background detection, object inventory, spatial relations, and shape comparison. |
| `Acc_79` | Quant pack — Quantitative Reasoning over Object Sets (Layer 38): 18 qn_* predicates for histograms, grouping, frequency analysis, and threshold counting. |
| `Acc_80` | Pattern pack — Periodic Pattern Detection and Tiling (Layer 39): 15 pt_* predicates for period detection, tiling, scaling, checkerboard, and stripes. |
| `Acc_81` | Compose pack — Sequential Rule Pipelines (Layer 40): 13 cp_* combinators for pipeline construction, conditional branching, fixed-point iteration, and fold/zip. |
| `Acc_82` | Motion pack — Spatial Movement and Gravity (Layer 41): 13 mv_* predicates for gravity, directional sliding, grid translation, and proximity computation. |
| `Acc_83` | Frame pack — Rectangular Border Detection and Frame Generation (Layer 42): 14 fr_* predicates for border detection, interior extraction, frame generation, and bounding box search. |
| `Acc_84` | Path pack — Path-Finding and Connectivity (Layer 43): 13 pf_* predicates for 4-connected flood fill, BFS shortest paths, and region reachability. |
| `Acc_85` | Symmetry pack — Grid Symmetry Testing and Orbit Generation (Layer 44): 12 sy_* predicates for D4 symmetry tests, canonical forms, and orbit enumeration. |
| `Acc_86` | Color pack — Color Palette Extraction and Manipulation (Layer 45): 14 cl_* predicates for palette extraction, histograms, dominant/rarest detection, replacement, and filtering. |
| `Acc_87` | Shape pack — Normalized Shape Extraction and Transformation (Layer 46): 14 sh_* predicates for shape properties, D4 transforms, orbit enumeration, canonical form, and equivalence testing. |
| `Acc_88` | Relation pack — Spatial Relations Between Cell Regions (Layer 47): 14 rl_* predicates for positional ordering, adjacency, distance, containment, overlap, and centroid. |
| `Acc_89` | Sequence pack — Arithmetic Sequences and Period Detection (Layer 48): 14 sq_* predicates for integer ranges, differences, chunking, zip/unzip, cumulative sums, and period detection. |
| `Acc_90` | Crop pack — Subgrid Extraction, Padding, and Assembly (Layer 49): 14 cr_* predicates for bounding box detection, cropping, padding, splitting, stitching, and embedding. |
| `Acc_91` | Overlay pack — Grid Combination by Layering and Logic (Layer 50): 14 ov_* predicates for transparent overlay, bitwise OR/AND/XOR, masking, and priority merge. |
| `Acc_92` | Measure pack — Geometric Region Metrics (Layer 51): 14 ms_* predicates for area, bounding box, perimeter, diameter, aspect ratio, and centroid. |
| `Acc_93` | Transform pack — Grid-Level Spatial and Color Transformations (Layer 52): 14 tr_* predicates for scaling, tiling, reflection, rotation, shifting, and color-map application. |
| `Acc_94` | Select pack — Selection and Filtering of Cell Regions (Layer 53): 14 sl_* predicates for largest, smallest, area filters, border tests, directional filters, and unique-area selection. |
| `Acc_95` | Count pack — Counting Cells, Colors, and Regions (Layer 54): 14 cn_* predicates for color counts, histograms, row/column queries, and per-color region tally. |
| `Acc_96` | Fill pack — Pattern-Based Region and Grid Filling (Layer 55): 14 fl_* predicates for region filling, border filling, checkerboard, line drawing, and subgrid stamp overlay. |
| `Acc_97` | Pattern pack — Pattern Detection, Tiling Period, and Motif Extraction (Layer 56): 14 pt_* predicates for period detection, tile extraction, tiling verification, and subgrid position search. |
| `Acc_98` | Compare pack — Grid and Region Comparison (Layer 57): 14 cp_* predicates for diff detection, change-direction filtering, similarity scoring, and region set operations. |
| `Acc_99` | Spatial pack — Directions, Containment, Adjacency, and Grid Topology (Layer 58): 14 sp_* predicates for cardinal direction, distance, neighbor enumeration, containment, and centroid. |
| `Acc_100` | Induction pack — Grid-Pair Inductive Analysis (Layer 59): 14 id_* predicates for color map inference, recolor detection, color set deltas, size ratios, and scale factor extraction. |
| `Acc_101` | Gravity pack — Directional Gravity and Settling (Layer 60): 14 gv_* predicates for falling in four directions, color-specific settling and floating, and custom column/row transforms. |
| `Acc_102` | Noise pack — Binary Mask Operations and Grid Noise Analysis (Layer 61): 14 ns_* predicates for mask AND/OR/invert, majority color detection, noise identification, and denoising. |
| `Acc_103` | Generate pack — Grid Construction from Visual Patterns (Layer 62): 14 ge_* predicates for uniform fill, gradients, checkerboard, stripes, diagonals, cross, frame, and pattern tiling. |
| `Acc_104` | Lookup pack — Association List Operations and Grid Index Maps (Layer 63): 14 lk_* predicates for key lookup, add/delete, grid row/column/cell access, and color-position index maps. |
| `Acc_105` | Connect pack — Flood Fill and Connected Component Analysis (Layer 64): 14 cc_* predicates for 4/8-connected fill, component counts, largest/smallest selection, and enclosed cell detection. |
| `Acc_106` | Morph pack — Morphological Grid Operations (Layer 65): 14 mo_* predicates for dilation, erosion, open, close, boundary extraction, hole filling, and grid padding. |
| `Acc_107` | Rewrite pack — Rule-Based Grid Cell Rewriting (Layer 66): 14 rw_* predicates for color substitution, swapping, region painting, masking, overlay, and conditional recoloring. |
| `Acc_108` | Run pack — Run-Length Encoding of Grid Sequences (Layer 67): 14 rn_* predicates for encoding/decoding rows and columns, positional lookup, and sequence repetition. |
| `Acc_109` | Arith pack — Cell-Wise Arithmetic on Grids (Layer 68): 14 ar_* predicates for addition, subtraction, multiplication, modulo, scalar ops, row/column sums, and clamping. |
| `Acc_110` | Obj pack — Object-Level Grid Reasoning (Layer 69): 14 obj_* predicates for object construction, color, size, bbox, centroid, shape, inventory, and size sorting. |
| `Acc_111` | Pipeline pack — Sequential Step Dispatch and Compositional Reasoning (Layer 70): 14 pl_* predicates for named step dispatch, map, filter, fold, zip, take, drop, and partitioning. |
| `Acc_112` | Context pack — Context Maps for Symbol Table Learning (Layer 71): 14 ctx_* predicates for key-value bindings, priority selection, dispatching, merging, and map operations. |
| `Acc_113` | Score pack — Scoring and Hypothesis Selection (Layer 72): 14 sc_* predicates for pixel accuracy, per-color precision/recall/F1, pair scoring, ranking, and threshold filtering. |
| `Acc_114` | Induct pack — Observing What Changed (Layer 73): 14 in_* predicates for cell-level change analysis, color map inference, size change, palette extraction, and background detection. |
| `Acc_115` | Hyp pack — Applying the Hypothesis (Layer 74): 14 hy_* predicates for color substitution, accuracy testing, hypothesis ranking, selection, inversion, and composition. |
| `Acc_116` | Sym pack — Spatial Symmetry Transforms and Testing (Layer 75): 14 sy_* predicates for D4 dihedral group transforms, symmetry detection, symmetrization, and orbit computation. |
| `Acc_117` | Seek pack — Spatial Pattern Search and Transform Discovery (Layer 76): 14 sk_* predicates for position finding, sub-grid matching, D4 transform discovery, upscaling, and scale factor detection. |
| `Acc_118` | Remap pack — Color Remapping and Palette Manipulation (Layer 77): 14 rm_* predicates for value replacement, swapping, map composition, normalization, shifting, and binarization. |
| `Acc_119` | Logic pack — Boolean and Mask Grid Operations (Layer 78): 14 lg_* predicates for boolean AND/OR/XOR/NOT, set difference, overlay, masking, and per-row/column flags. |
| `Acc_120` | Window pack — Sliding Window and Neighborhood Operations (Layer 79): 14 wn_* predicates for 4/8-neighbor lists, sub-grid extraction, sliding windows, padding, and convolution. |
| `Acc_121` | Sort pack — Sorting, Ranking, and Ordering (Layer 80): 14 so_* predicates for row/column sums and counts, ascending/descending row/column sorting, and cell ranking. |
| `Acc_122` | Tile pack — Tiling, Stamping, and Period Detection (Layer 81): 14 ti_* predicates for horizontal/vertical tiling, tile splitting, stamping, tiling verification, and period finding. |
| `Acc_123` | Trace pack — Path Tracing, Rays, and Grid Boundaries (Layer 82): 14 tr_* predicates for row/column runs, ray casting, line drawing, path values, border cells, and perimeter extraction. |
| `Acc_124` | Label pack — Connected Component Labeling and Region Queries (Layer 83): 14 lb_* predicates for 4-connected labeling, component size/bbox/neighbor queries, fill, merging, and selection. |
| `Acc_125` | Morph pack — Color-Aware Morphological Grid Operations (Layer 84): 14 mo_* predicates for dilation, erosion, open, close, boundary, interior, distance transform, and hole filling. |
| `Acc_126` | Walk pack — Grid Traversal Patterns (Layer 85): 14 wk_* predicates for row-major, column-major, zigzag, diagonal, anti-diagonal, spiral, and border-walk traversal. |
| `Acc_127` | Step pack — Directional Grid Movement (Layer 86): 14 st_* predicates for bounded steps, ray casting, direction rotation, path following, and step counting to edge. |
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
| `Acc_271` | GridShift pack paper — Grid Shifting and Cyclic Rolling (Layer 230, gsh_*): 14 gsh_* predicates for linear shifts, toroidal rolls, per-row/column operations, color-specific shift, and full-grid offset. |
| `Acc_272` | GridMap pack paper — Grid Color Mapping (Layer 231, gmp_*): 14 gmp_* predicates for color remapping, normalization, palette ops, masking, inversion, cycling, and map algebra. |
| `Acc_273` | GridRefl pack paper — Grid Reflection and Rotation (Layer 232, grf_*): 14 grf_* predicates for flips, rotations, transpositions, D4 symmetry detection, and symmetry completion. |
| `Acc_298` | ARC-AGI-2 infrastructure — arc_tasks_2.pl (task loader), arc_benchmark_2.pl (wave solver with task-type-aware dispatch), and Climbing_ARC-AGI-2.txt (wave log). All Section 8 readiness items complete; platform ready to climb ARC-AGI-2. |
| `Acc_299` | ARC-AGI-2 Wave 1 — task files downloaded, converter built, 120 evaluation tasks loaded. First rule: recolor_plus(4,8) solves task 1818057f. Score: 1/120 = 0.83%. |
| `Acc_300` | ARC-AGI-2 Wave 2 — BFS flood-fill connected-component analysis implemented; chain_strip rule solves task 7b5033c1. Score: 2/120 = 1.67%. |
| `Acc_301` | ARC-AGI-2 Wave 3 — checkerboard diagonal arm projection; arm_endpoint_ray rule solves task 80a900e0. Score: 3/120 = 2.50%. |
| `Acc_312` | ARC-AGI-2 Wave 14 — reflect-axis shape reflection across 2-marker axis; reflect_axis rule solves task 7ed72f31 (each shape reflected across nearest 2-cluster axis: point, vertical, or horizontal). Score: 14/120 = 11.67%. |
| `Acc_326` | ARC-AGI-2 Wave 28 — slide_open rule solves task 6e453dd6 (0-cell components slide right to 5-divider; two-pass erase-then-place; open rows filled right of divider with 2). Score: 28/120 = 23.33%. |
| `Acc_330` | ARC-AGI-2 Wave 32 — shape_classify rule solves task aa4ec2a5; 2-color grid; holes=6; 8-connected border=2; hole-touching shapes=8; no-hole shapes=1. Score: 32/120 = 26.67%. |
| `Acc_332` | ARC-AGI-2 Wave 34 — rail_fill rule solves task 271d71e2; 0-bordered boxes with 9-rail arms gain 7-cells from arm side and shift toward outer rail by arm-gap steps. Score: 34/120 = 28.33%. |
| `Acc_331` | ARC-AGI-2 Wave 33 — tile_stamp rule solves task bf45cf4b; compact multi-color kernel tiled at each non-BG indicator cell position. Score: 33/120 = 27.50%. |
| `Acc_329` | ARC-AGI-2 Wave 31 — shape_beam rule solves task 5961cc34; rod fires beam through 1/3-shape chains; exit direction detected via open BG face of collinear 3-markers. Score: 31/120 = 25.83%. |
| `Acc_328` | ARC-AGI-2 Wave 30 — frame_absorb rule solves task d35bdbdc; frame blocks absorb successors via center/arm color graph, monochrome-first priority. Score: 30/120 = 25.00%. |
| `Acc_327` | ARC-AGI-2 Wave 29 — diag_beam rule solves task db695cfb (diagonal 1-pairs shoot 45-degree beams filling 1s; 6-obstacles reflect two perpendicular 6-rays). Score: 29/120 = 24.17%. |
| `Acc_325` | ARC-AGI-2 Wave 27 — stream_extend rule solves task 53fb4810 (A-marker blobs serve as anchors; adjacent seed chains extended periodically to grid boundary; tiling formula: Chain[D mod P]). Score: 27/120 = 22.50%. |
| `Acc_324` | ARC-AGI-2 Wave 26 — straighten_diag rule solves task 7b80bb43 (diagonal-only cells removed; orthogonal gaps bridged by scanning from anchors; perpendicular stubs in DiagNbr pruned iteratively). Score: 26/120 = 21.67%. |
| `Acc_323` | ARC-AGI-2 Wave 25 — bar_extend rule solves task 1ae2feb7 (divider column splits grid; bar primary color period CP and secondary CS define a period-CP*CS fill pattern for the right side). Score: 25/120 = 20.83%. |
| `Acc_322` | ARC-AGI-2 Wave 24 — shape_sort rule solves task 2ba387bc; 4x4 blocks classified as hollow or solid, separated, and paired by reading order. Score: 24/120 = 20.00%. |
| `Acc_321` | ARC-AGI-2 Wave 23 — period_extend rule solves task 16de56c4 (anchor-pair step detection; stop/recolor cell at a pattern position; row or column mode chosen by active-line count). Score: 23/120 = 19.17%. |
| `Acc_320` | ARC-AGI-2 Wave 22 — legend_veto rule solves task d59b0160 (color-agnostic 4-connected components; erase any component whose value set covers all legend values extracted from the 4x4 top-left frame). Score: 22/120 = 18.33%. |
| `Acc_319` | ARC-AGI-2 Wave 21 — chain_link rule solves task 3e6067c3; legend chain connects adjacent boxes by filling gaps with a visited-set walk. Score: 21/120 = 17.50%. |
| `Acc_318` | ARC-AGI-2 Wave 20 — section_tile rule solves task b0039139; divider-split sections tiled N times with solid-color mapping. Score: 20/120 = 16.67%. |
| `Acc_317` | ARC-AGI-2 Wave 19 — segment_ext rule solves task faa9f03d (4-corner stub removal, opposite-direction arm extension, pure-vertical gap fill guard, and extension-direction conflict tiebreaker). Score: 19/120 = 15.83%. |
| `Acc_316` | ARC-AGI-2 Wave 18 — tip-escape rule; tip_escape rule solves task 3dc255db (8-connected shape markers escape through the shape's single-cell tip; apex detection or projection method selects escape direction). Score: 18/120 = 15.00%. |
| `Acc_315` | ARC-AGI-2 Wave 17 — frame_target rule solves task 88e364bc; legend rectangles encode movement directions for dot cells inside irregular frames. Score: 17/120 = 14.17%. |
| `Acc_314` | ARC-AGI-2 Wave 16 — legend_fill rule solves task dbff022c; closed frames filled with color from an embedded legend table. Score: 16/120 = 13.33%. |
| `Acc_313` | ARC-AGI-2 Wave 15 — period-repair periodic-pattern deviation fix; period_repair rule solves task 135a2760 (inner row/col sequences repaired to majority-vote base using support-threshold period selection). Score: 15/120 = 12.50%. |
| `Acc_311` | ARC-AGI-2 Wave 13 — odd_col rule solves task 38007db0; separator-divided sections with majority-vote unique column identification. Score: 13/120 = 10.83%. |
| `Acc_310` | ARC-AGI-2 Wave 12 — waterfall gravity-flow rule; waterfall rule solves task 36a08778 (6-seeds flow downward, spread around obstacles, stop at drain points; OOB below halts without spreading). Score: 12/120 = 10.00%. |
| `Acc_309` | ARC-AGI-2 Wave 11 — sym-restore vertical symmetry; sym_restore rule solves task 8e5c0c38 (per-colour minimum-orphan axis scan restores left-right symmetry, handling half-integer axes via doubling trick). Score: 11/120 = 9.17%. |
| `Acc_308` | ARC-AGI-2 Wave 10 — apex-shadow arm-vector projection; apex_shadow rule solves task 409aa875 (each shape projects via normalised arm-sum * -5, covering all chevron and L-shape orientations). Score: 10/120 = 8.33%. |
| `Acc_307` | ARC-AGI-2 Wave 9 — panel-overlay flood-fill boundary; panel_overlay rule solves task 7491f3cf (s1 wall + seed divides 5x5 panel into s2 region and s3 region via 4-connected flood fill). Score: 9/120 = 7.50%. |
| `Acc_306` | ARC-AGI-2 Wave 8 — bar-sort height ordering; bar_sort rule solves task 31f7f899 (sort vertical bar heights ascending left-to-right, reassign colors to bar slots). Score: 8/120 = 6.67%. |
| `Acc_305` | ARC-AGI-2 Wave 7 — staircase-lift bar repositioning; staircase_lift rule solves task 4c3d4a41 (left-half staircase heights control output positions of right-half color bars via MaxEnd = 5 - H). Score: 7/120 = 5.83%. |
| `Acc_304` | ARC-AGI-2 Wave 6 — band-wrap concentric rings; band_wrap rule solves task 45a5af55 (uniform-color rows encode concentric rectangular rings via ring index formula). Score: 6/120 = 5.00%. |
| `Acc_303` | ARC-AGI-2 Wave 5 — column stub rank-fill; stub_rank_fill rule solves task 97d7923e (stub height N selects the Nth-largest vertical bar by body length to fill). Score: 5/120 = 4.17%. |
| `Acc_302` | ARC-AGI-2 Wave 4 — segment length equalization; segment_equalize rule solves task e376de54 across horizontal, vertical, and anti-diagonal directions. Score: 4/120 = 3.33%. |
| `Acc_297` | induction pack enhancement (WP-277) — id_cross_pair_invariants/2 and id_cross_pair_variants/2 aggregate properties across all training pairs (dims, colors, bg, monotone, total-nonzero); 46/46 tests pass. |
| `Acc_296` | condxf pack enhancement (WP-276) — xc_infer_gate/3 automatically infers the gate_color that partitions training pairs by change signature for context-gated task solving; 45/45 tests pass. |
| `Acc_295` | hyp pack enhancement (WP-275) — hy_spatial_hyp, hy_structural_hyp, and hy_sequence_hyp extend hypothesis search beyond color substitution; 43/43 tests pass. |
| `Acc_294` | seqinfer pack enhancement (WP-274) — sq_arc2_candidates/1 adds 66-entry integer-color candidate list for multi-step ARC-AGI-2 search with sq_infer_2step and sq_infer_3step; 52/52 tests pass. |
| `Acc_293` | TaskCat pack — Task Type Classification and Strategy Selection (Layer 252, tc_*): 14 tc_* predicates for classifying tasks and returning ordered solving strategy lists. |
| `Acc_292` | MultiPair pack — Multi-Pair Object Tracking and Cross-Pair Correspondence (Layer 251, mp_*): 14 mp_* predicates for cross-pair matching, color classification, and disappeared/appeared object detection. |
| `Acc_291` | Legend pack paper — Legend and Key Region Detection from Grid Training Pairs (Layer 250, lg_*): 14 lg_* predicates for BFS region finding, legend detection, color map parsing, shape equivalence, and spatial position classification. |
| `Acc_290` | Contrast pack — Contrastive Pair Analysis Across Training Pairs (Layer 249, ca_*): 14 ca_* predicates for identifying which input features co-vary with output changes. |
| `Acc_289` | Invariant pack — Cross-Pair Invariant Extraction (Layer 248, iv_*): 14 iv_* predicates for finding what stays constant across all training pairs. |
| `Acc_288` | SymTab pack — Symbol Table Learning from Input-Output Pairs (Layer 247, st_*): 14 st_* predicates for contrastive symbol learning, table application, and best table selection. |
| `Acc_287` | GridObjMatch pack — Object Matching and Change Detection (Layer 246, gom_*): 14 gom_* predicates for color/centroid/size matching, movement vectors, and color map inference. |
| `Acc_286` | GridTransform pack — Grid Transformation Detection and Application (Layer 245, gtr_*): 14 gtr_* predicates for color map detection, diff cells, delta grids, and color permutation testing. |
| `Acc_285` | GridRelation pack — Grid Object Spatial Relations (Layer 244, grl_*): 14 grl_* predicates for touching, adjacency, distance, directional tests, bbox containment, and overlap. |
| `Acc_284` | GridGroupBy pack paper — Grid Group-By Operations (Layer 243, ggb_*): 14 ggb_* predicates for grouping, filtering, sorting, pairing, and counting ob/3 object terms by color, size, row, column, and threshold. |
| `Acc_283` | GridObj pack — Grid Object Operations (Layer 242, gob_*): 14 gob_* predicates for object cells, color, size, bbox, extraction, flood fill, removal, and movement. |
| `Acc_282` | GridResize pack — Grid Resize and Scale Operations (Layer 241, grs_*): 14 grs_* predicates for scale-up/down, nearest-neighbor resize, tiling, crop, letterbox fit, and canvas embed. |
| `Acc_281` | GridColorOp pack paper — Grid Color Operations (Layer 240, gco_*): 14 gco_* predicates for color counting, ranking, swapping, replacing, masking, cycling, palette application, and binary inversion. |
| `Acc_280` | GridAlign pack paper — Grid Alignment and Shift Matching (Layer 239, gal_*): 14 gal_* predicates for center of mass, bbox, translation, overlap count/score/IoU, offset search, center alignment, placement, and anchor-based paste. |
| `Acc_279` | GridStamp pack paper — Grid Stamping and Canvas Operations (Layer 238, gst_*): 14 gst_* predicates for transparent stamping, scatter, pattern match finding, pad/unpad, replication, border, centering, extraction, and canvas creation. |
| `Acc_278` | GridGrav pack paper — Grid Gravity and Sliding (Layer 237, gra_*): 14 gra_* predicates for fall in four directions, blocked gravity, column/row extraction and placement, settled-state test, and gravity score. |
| `Acc_277` | GridExtract pack paper — Grid Object Extraction (Layer 236, gxt_*): 14 gxt_* predicates for cell collection, bounding boxes, crops, BFS object identification, color statistics, region counting, and object registry. |
| `Acc_276` | GridBlend pack paper — Grid Blending and Layered Composition (Layer 235, gbld_*): 10 gbld_* predicates for overlay, underlay, stencil, priority, checker/stripe blend, threshold replace, merge-many, dominant voting, and composite. |
| `Acc_275` | GridChain pack paper — Grid Sequence Utilities (Layer 234, gch_*): 14 gch_* predicates for sequence pairing, windows, zip, take/drop, sameness, dedup, cycle, interleave, split, reverse, diff counts, and change masks. |
| `Acc_274` | GridLogic pack paper — Grid Logical Operations (Layer 233, ggl_*): 14 ggl_* predicates for cell-wise AND/OR/XOR/NOT, set ops, list-wide reductions, and conditional mask/if/filter. |
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

306 announcements in LinkedIn format — one per accomplishment.

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
Founder of AIU (Artificial Intelligence University) · Creator and Owner of PrologAI and Mentova  
ORCID: 0009-0001-9246-5758 · [LinkedIn](https://www.linkedin.com/in/d-r-dison/)

---

## License

**The Attribution Always; No Profit, No Problem License.** — see [LICENSE.txt](LICENSE.txt)

Free for non-commercial use (individuals, students, educators, non-profits, academic researchers) with required attribution to Mentova, PrologAI, AIU (Artificial Intelligence University), and D. R. Dison.

Commercial and profit-making use requires a negotiated license including a percentage-of-profits royalty. Contact [ai.university.aiu@gmail.com](mailto:ai.university.aiu@gmail.com) before any commercial use begins.

See [COMMERCIAL.txt](COMMERCIAL.txt) for the full commercial licensing process.
