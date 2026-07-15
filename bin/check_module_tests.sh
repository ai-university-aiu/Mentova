#!/usr/bin/env bash
# check_module_tests.sh — Mentova test-presence merge gate.
# Every top-level reasoning/core module under src/mentova/ must ship a
# test/test_<module>.pl, or it never enters the per-module regression
# (bin/run_tests.sh) and can rot invisibly — the same class of gap closed on the
# PrologAI side, where an untested pack hid a stack-overflow for a long time.
# The games/ subdirectory holds ARC integration drivers, not unit modules, and is
# intentionally out of scope.
#
# Usage:  bin/check_module_tests.sh
# Exit 0 = every module has a test; exit 1 = at least one is missing.
set -u
MENTOVA="$(cd "$(dirname "$0")/.." && pwd)"

violations=0
scanned=0
for f in "$MENTOVA"/src/mentova/*.pl; do
  [ -f "$f" ] || continue
  m=$(basename "$f" .pl)
  scanned=$((scanned+1))
  if [ ! -f "$MENTOVA/test/test_$m.pl" ]; then
    violations=$((violations+1))
    echo "VIOLATION [NO-TEST]  module '$m' has no test/test_$m.pl (not in the per-module regression)"
  fi
done
echo "---"
echo "scanned=$scanned  violations=$violations"
[ "$violations" -eq 0 ] && exit 0 || exit 1
