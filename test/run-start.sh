#!/usr/bin/env bash
# Exercises the start skill in an EMPTY folder with Claude Code in non-interactive mode: the one-install,
# no-zip path a new rep takes (install the plugin, open an empty folder in Cowork, type /start).
# Usage: [PLUGIN_DIR=<plugin folder>] test/run-start.sh [--model <model>]
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
MODEL_ARGS=()
while [ $# -gt 0 ]; do case "$1" in --model) MODEL_ARGS=(--model "$2"); shift;; esac; shift; done
WS=$(mktemp -d "${TMPDIR:-/tmp}/deal-intel-start.XXXXXX")
LOG=$(mktemp "${TMPDIR:-/tmp}/deal-intel-start-log.XXXXXX")   # outside WS: the workspace contents are an assertion
# Same PLUGIN_DIR pattern as test/run.sh; default is the plugin in this repo.
PLUGIN_ARGS=(--plugin-dir "${PLUGIN_DIR:-$ROOT/plugins/deal-intel}")
SAMPLE="SAMPLE (not real) - 2026-09-10 Pinecrest Family Law Group - discovery call.md"
FIX="$ROOT/fixtures/inbox/2026-09-10 Pinecrest Family Law Group - discovery call.md"
TPL="$ROOT/plugins/deal-intel/skills/start/templates"
PROMPT="Use the /start skill and run: /start. This empty folder is my deals folder, go ahead without asking."
echo "workspace: $WS"; echo "log: $LOG"
cd "$WS"
claude -p "$PROMPT" --dangerously-skip-permissions ${MODEL_ARGS[@]+"${MODEL_ARGS[@]}"} "${PLUGIN_ARGS[@]}" > "$LOG" 2>&1 || { echo "claude exited non-zero"; tail -40 "$LOG"; exit 1; }
echo "--- assertions ---"
fail=0
ok() { echo "PASS $1"; }
no() { echo "FAIL $1"; fail=1; }
for d in inbox deals closed-lost forecasts; do [ -d "$WS/$d" ] && ok "folder $d" || no "folder $d missing"; done
[ -f "$WS/deal-judgment.md" ] && ok "deal-judgment.md exists" || no "deal-judgment.md missing"
cmp -s "$WS/deal-judgment.md" "$TPL/deal-judgment.md" && ok "deal-judgment.md matches template" || no "deal-judgment.md differs from template"
[ -f "$WS/templates/forecast-message.md" ] && ok "templates/forecast-message.md exists" || no "templates/forecast-message.md missing"
cmp -s "$WS/templates/forecast-message.md" "$TPL/forecast-message.md" && ok "forecast-message.md matches template" || no "forecast-message.md differs from template"
[ -f "$WS/inbox/$SAMPLE" ] && ok "sample transcript in inbox" || no "sample transcript missing from inbox"
cmp -s "$WS/inbox/$SAMPLE" "$FIX" && ok "sample transcript byte-identical to fixture" || no "sample transcript differs from fixture"
# Nothing else: every path under the workspace must be one of the eight expected ones (.DS_Store aside).
EXPECTED=$(printf '%s\n' "closed-lost" "deal-judgment.md" "deals" "forecasts" "inbox" "inbox/$SAMPLE" "templates" "templates/forecast-message.md" | sort)
ACTUAL=$(cd "$WS" && find . -mindepth 1 -name .DS_Store -prune -o -print | sed 's|^\./||' | sort)
EXTRA=$(comm -13 <(printf '%s\n' "$EXPECTED") <(printf '%s\n' "$ACTUAL"))
[ -z "$EXTRA" ] && ok "nothing else created" || { no "unexpected paths created: $(printf '%s' "$EXTRA" | tr '\n' ' ')"; }
grep -q "/deal-room ingest" "$LOG" && ok "final message names /deal-room ingest" || no "final message does not name /deal-room ingest"
echo "--- final message ---"; tail -30 "$LOG"
echo "result: $([ $fail = 0 ] && echo ALL PASS || echo FAILURES)"
exit $fail
