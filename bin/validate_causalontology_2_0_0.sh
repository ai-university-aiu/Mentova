#!/usr/bin/env bash
# validate_causalontology_2_0_0.sh — THE LATTICE BRIDGE gate (Order Two).
# Check that the exported Causalontology 2.0.0 type-tier snapshot
# (data/lattice_snapshot/causalontology_2_0_0/type_tier.ndjson) is
# 2.0.0-conformant and self-verifying: every record satisfies its schema and the
# local semantics, every content id is the true SHA-256 of its canonical bytes,
# and every provenance assertion carries a verifying Ed25519 signature — and the
# 107 conformance vectors (Order One's harness) still pass. Exit 0 iff clean.
set -u
# Resolve the Mentova root from this script's location.
cd "$(dirname "$0")/.." || exit 2
# Run the 2.0.0 validator's command-line gate.
swipl -q -g v2_main -t "halt(1)" tools/validate_causalontology_2_0_0.pl
# Propagate the validator's exit code.
exit $?
