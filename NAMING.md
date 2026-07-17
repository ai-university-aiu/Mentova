# Naming conventions

Mentova's public naming conventions. Mentova is a glass-box synthetic mind built
on SWI-Prolog and the PrologAI packs, contributing to and reading from the
Causalontology commons — so its identifiers follow the same whole-word discipline
as its substrate.

## Whole words, never abbreviations

- **Modules and predicates** are whole-word `snake_case`, qualified by their
  module (`draft_ingest_…`, `observe_game_play_…`), never terse two-letter
  stubs. An identifier should read like what it does.
- Mentova consumes PrologAI's pack-qualified predicates as-is; it does not
  re-abbreviate them.

## The causal-relation primitive: `causal_relation_object`

Everything Mentova reads or writes in the Causalontology vocabulary spells the
reified Causal Relation Object in full as **`causal_relation_object`** — the
`causal_relation_object/8` functor and its `causal_relation_object_` ids, the
`causal_core_…` and `ci_…` interface predicates, the lattice snapshot
[`data/lattice_snapshot/causalontology_causal_relation_objects.pl`](data/lattice_snapshot/causalontology_causal_relation_objects.pl),
and prose. The former abbreviation **`cro` is retired** in code and prose alike.
This aligns Mentova with the Causalontology standard's whole-word Principle P7.

## Alignment with the Causalontology standard

Mentova speaks the standard's seventeen whole-word object kinds — `occurrent`,
`continuant`, `realizable`, `causal_relation_object`, `quality`, `stratum`,
`bridge`, `port`, `conduit` (type tier); `token_individual`, `token_occurrence`,
`state_assertion`, `token_causal_claim` (token tier); `assertion`, `enrichment`,
`retraction`, `succession` (provenance). The full abbreviation mapping and the
field renames (`dmin` → `minimum_delay`, `dmax` → `maximum_delay`) live in the
standard's own
[NAMING.md](https://github.com/ai-university-aiu/causalontology/blob/main/NAMING.md).

## Exempt external proper names

Whole-word spelling governs Mentova's own identifiers. It does not rewrite the
proper names of external standards and algorithms, kept verbatim: `ed25519`
(Ed25519, RFC 8032), `SHA-256`, `RFC 8785` (JCS), `RFC 3339`, `UCUM`, `UTC`,
`JSON`, `JSON-LD`, `BFO`, `RO`, `PROV`. These are never abbreviated further or
re-minted.
