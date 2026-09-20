#!/usr/bin/env bash
# Asserts the start skill's templates are byte-identical to the originals they were copied from.
# The start skill writes these files into a new workspace, so a drift here ships a wrong workspace.
# Usage: test/check-templates.sh
set -uo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
S="$ROOT/plugins/deal-intel/skills/start/templates"
fail=0
chk() { cmp -s "$2" "$3" && echo "PASS $1" || { echo "FAIL $1: $2 differs from $3"; fail=1; }; }
chk "sample transcript matches fixture" "$S/sample-transcript.md" "$ROOT/fixtures/inbox/2026-09-10 Pinecrest Family Law Group - discovery call.md"
chk "deal-judgment template matches deal-room's" "$S/deal-judgment.md" "$ROOT/plugins/deal-intel/skills/deal-room/templates/deal-judgment.md"
chk "forecast-message template matches forecast's" "$S/forecast-message.md" "$ROOT/plugins/deal-intel/skills/forecast/templates/forecast-message.md"
exit $fail
