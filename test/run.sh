#!/usr/bin/env bash
# Exercises the deal-room skill end to end on a synthetic workspace with Claude Code in non-interactive mode.
# Usage: [PLUGIN_DIR=<plugin folder>] test/run.sh [--long] [--model <model>]
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
LONG=0; MODEL_ARGS=()
while [ $# -gt 0 ]; do case "$1" in --long) LONG=1;; --model) MODEL_ARGS=(--model "$2"); shift;; esac; shift; done
WS=$(mktemp -d "${TMPDIR:-/tmp}/deal-intel-test.XXXXXX")
cp -R "$ROOT/workspace-example/." "$WS/"
# PLUGIN_DIR=<path to a plugin folder> loads the skills through Claude Code's plugin loader instead of local symlinks
# (e.g. a fresh clone of the published repo: PLUGIN_DIR=/tmp/clone/plugins/deal-intel test/run.sh).
PLUGIN_ARGS=(); if [ -n "${PLUGIN_DIR:-}" ]; then PLUGIN_ARGS=(--plugin-dir "$PLUGIN_DIR"); else
mkdir -p "$WS/.claude/skills"
for s in deal-room forecast closed-lost; do ln -s "$ROOT/plugins/deal-intel/skills/$s" "$WS/.claude/skills/$s"; done
fi
if [ "$LONG" = 1 ]; then "$ROOT/test/make-long-fixture.sh" "$WS/inbox/2026-09-24 Pinecrest Family Law Group - demo (long).md" >/dev/null; else cp "$ROOT/fixtures/inbox/"* "$WS/inbox/"; fi
FIX=$(ls "$WS/inbox/")
FIELDS=$(cat "$ROOT/fixtures/salesforce/opportunities.json")
PROMPT="The Salesforce connector is NOT available in this session, so do not try to call it. Use the /deal-room skill and run: /deal-room ingest. When you need opportunity fields to create a room, use exactly these (do not ask): $FIELDS . Do not ask any questions; make reasonable choices and finish the whole job."
echo "workspace: $WS"; echo "fixture: $FIX"
cd "$WS"
claude -p "$PROMPT" --dangerously-skip-permissions ${MODEL_ARGS[@]+"${MODEL_ARGS[@]}"} ${PLUGIN_ARGS[@]+"${PLUGIN_ARGS[@]}"} > "$WS/run.log" 2>&1 || { echo "claude exited non-zero"; tail -40 "$WS/run.log"; exit 1; }
echo "--- assertions ---"
fail=0
DEAL=$(ls -d "$WS"/deals/*/ 2>/dev/null | head -1 || true)
[ -n "$DEAL" ] && echo "PASS deal folder: $DEAL" || { echo "FAIL no deal folder"; fail=1; }
[ -f "$DEAL/DEAL.md" ] && echo "PASS DEAL.md exists" || { echo "FAIL DEAL.md missing"; fail=1; }
for sec in "## Summary" "## Read" "## Firm facts" "## Call log"; do grep -q "$sec" "$DEAL/DEAL.md" 2>/dev/null && echo "PASS section $sec" || { echo "FAIL section $sec"; fail=1; }; done
ls "$DEAL"/calls/*.notes.md >/dev/null 2>&1 && echo "PASS notes file" || { echo "FAIL no .notes.md"; fail=1; }
[ -z "$(ls -A "$WS/inbox" | grep -v .gitkeep)" ] && echo "PASS inbox emptied" || { echo "FAIL inbox not emptied"; fail=1; }
T=$(ls "$DEAL"/calls/*.md 2>/dev/null | grep -v notes.md | grep -v gong-summary | head -1 || true)
if [ -n "$T" ]; then SRC=$([ "$LONG" = 1 ] && echo "$WS/../nonexistent" || echo "$ROOT/fixtures/inbox/$FIX"); if [ "$LONG" = 1 ] || cmp -s "$T" "$SRC"; then echo "PASS transcript moved verbatim"; else echo "FAIL transcript altered"; fail=1; fi; fi
grep -qi "thirty-eight\|38 attorneys\|38" "$DEAL/DEAL.md" && echo "PASS attorney count captured" || { echo "FAIL attorney count missing"; fail=1; }
grep -qi "February\|2027-02-01\|Feb" "$DEAL/DEAL.md" && echo "PASS renewal date captured" || { echo "FAIL renewal date missing"; fail=1; }
grep -qi "Marcus" "$DEAL/DEAL.md" && echo "PASS skeptic captured" || { echo "FAIL Marcus missing"; fail=1; }
grep -qi "CaseSpring" "$DEAL/DEAL.md" && echo "PASS competitor captured" || { echo "FAIL competitor missing"; fail=1; }
grep -Eiq "[0-9]+ ?% ?(chance|likely|probab|close)|(chance|probability|likelihood|odds)[^.\n]{0,25}[0-9]+ ?%" "$DEAL/DEAL.md" && { echo "FAIL probability number present"; fail=1; } || echo "PASS no probability number"
echo "--- DEAL.md ---"; cat "$DEAL/DEAL.md"
echo "--- run log tail ---"; tail -5 "$WS/run.log"
exit $fail
