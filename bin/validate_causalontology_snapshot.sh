#!/usr/bin/env bash
# validate_causalontology_snapshot.sh — check that the materialized
# Causalontology snapshot (data/lattice_snapshot/causalontology_causal_relation_objects.pl)
# is Causalontology 2.0.0-valid: whole-word causal_relation_object/8 facts with
# a valid modality and temporal unit, Rule 4 window ordering, strength in [0,1],
# and no retired cro/dmin/dmax spellings. Exit 0 iff every fact passes.
set -u
# Resolve the Mentova root from this script's location.
cd "$(dirname "$0")/.." || exit 2
# Run the validator's command-line entry point.
swipl -q -g "use_module('tools/validate_causalontology_snapshot.pl'), causalontology_snapshot_main" -t "halt(1)"
# Propagate the validator's exit code.
exit $?
