#!/usr/bin/env bash
# run_tests.sh — Mentova per-module PLUnit regression.
# Mentova's 71 src modules had no unit tests and were in no regression, so rot in
# them was invisible (the same gap closed on the PrologAI side on 2026-07-15).
# Each module now has test/test_<module>.pl; this runner executes every one in its
# own swipl process, over the full PrologAI pack library path plus the Mentova
# source, with a per-suite timeout.
#
# Usage:  bin/run_tests.sh              # run every test/test_*.pl
#         bin/run_tests.sh bayesian     # run named module tests
# Exit 0 = all green; exit 1 = at least one suite failed or timed out.
set -u
MENTOVA="$(cd "$(dirname "$0")/.." && pwd)"
PACKS=/home/ccaitwo/PrologAI/packs
TIMEOUT="${MENTOVA_TEST_TIMEOUT:-60}"

# Build the library path: every PrologAI pack plus the Mentova source tree.
LIB=""
for d in "$PACKS"/*/prolog; do LIB="$LIB -p library=$d"; done
LIB="$LIB -p library=$MENTOVA/src/mentova"

# Resolve the target suites.
if [ "$#" -gt 0 ]; then
  targets=(); for n in "$@"; do targets+=("$MENTOVA/test/test_$n.pl"); done
else
  targets=("$MENTOVA"/test/test_*.pl)
fi

pass=0; fail=0; timeout_n=0; failed=""
for f in "${targets[@]}"; do
  [ -f "$f" ] || continue
  m=$(basename "$f" .pl); m=${m#test_}
  timeout "$TIMEOUT" swipl $LIB -g "run_tests, halt" -t "halt(1)" "$f" >/tmp/mtest_$m.log 2>&1
  rc=$?
  if [ "$rc" -eq 124 ]; then timeout_n=$((timeout_n+1)); failed="$failed $m(timeout)"
  elif [ "$rc" -eq 0 ] && grep -qE 'tests passed|tests are blocked' /tmp/mtest_$m.log; then pass=$((pass+1))
  else fail=$((fail+1)); failed="$failed $m(fail)"; fi
done
echo "Mentova module tests: $pass passed, $fail failed, $timeout_n timed out.${failed:+  NON-GREEN:$failed}"
[ "$fail" -eq 0 ] && [ "$timeout_n" -eq 0 ] && exit 0 || exit 1
