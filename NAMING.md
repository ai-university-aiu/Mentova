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

## Conformance to Causalontology specification 2.0.0

Conformance to the standard is proven **on the PrologAI side**: PrologAI declares
Causalontology specification 2.0.0 and passes all 107 conformance vectors
(V01–V107). Mentova consumes PrologAI's now-conformant, pack-qualified
Causalontology vocabulary **as-is** — it does not re-abbreviate it and it
introduces no divergent vocabulary of its own.

What Mentova owns is its **materialized records**. The Lattice snapshot
[`data/lattice_snapshot/causalontology_causal_relation_objects.pl`](data/lattice_snapshot/causalontology_causal_relation_objects.pl)
holds Reasoning Objects in PrologAI's native `causal_relation_object/8` term
form (symbolic causes and effects), not the JSON content-addressed record form.
A light Mentova-side check
([`tools/validate_causalontology_snapshot.pl`](tools/validate_causalontology_snapshot.pl),
run by `bin/validate_causalontology_snapshot.sh` and gated by
`test/test_causalontology_snapshot.pl`) validates that every fact speaks
whole-word 2.0.0 vocabulary and obeys the locally decidable rules: the whole-word
`causal_relation_object/8` functor, a modality from the five-member 2.0.0
enumeration (adding `enabling`), a temporal unit from the eight-member set, Rule 4
window ordering (`minimum_delay` ≤ `maximum_delay`), a strength in [0,1], and no
retired `cro`/`dmin`/`dmax` spellings. The shipped snapshot passes (334/334).

## Exempt external proper names

Whole-word spelling governs Mentova's own identifiers. It does not rewrite the
proper names of external standards and algorithms, kept verbatim: `ed25519`
(Ed25519, RFC 8032), `SHA-256`, `RFC 8785` (JCS), `RFC 3339`, `UCUM`, `UTC`,
`JSON`, `JSON-LD`, `BFO`, `RO`, `PROV`. These are never abbreviated further or
re-minted.
