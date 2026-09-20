#!/usr/bin/env bash
# Asserts the deal-room ingest result in an existing workspace (e.g. one Cowork wrote), without running Claude.
# Usage: test/check-workspace.sh <workspace> [<original transcript to compare verbatim>]
set -uo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
WS=${1:?workspace path}; SRC=${2:-}
fail=0
DEAL=$(ls -d "$WS"/deals/*/ 2>/dev/null | head -1 || true)
[ -n "$DEAL" ] && echo "PASS deal folder: $DEAL" || { echo "FAIL no deal folder"; fail=1; }
[ -f "$DEAL/DEAL.md" ] && echo "PASS DEAL.md exists" || { echo "FAIL DEAL.md missing"; fail=1; }
for sec in "## Summary" "## Read" "## Firm facts" "## Call log"; do grep -q "$sec" "$DEAL/DEAL.md" 2>/dev/null && echo "PASS section $sec" || { echo "FAIL section $sec"; fail=1; }; done
ls "$DEAL"/calls/*.notes.md >/dev/null 2>&1 && echo "PASS notes file" || { echo "FAIL no .notes.md"; fail=1; }
[ -z "$(ls -A "$WS/inbox" 2>/dev/null | grep -v -E '^\.gitkeep$|^\.DS_Store$')" ] && echo "PASS inbox emptied" || { echo "FAIL inbox not emptied: $(ls -A "$WS/inbox" | tr '\n' ' ')"; fail=1; }
T=$(ls "$DEAL"/calls/*.md 2>/dev/null | grep -v notes.md | grep -v gong-summary | head -1 || true)
if [ -n "$T" ] && [ -n "$SRC" ]; then cmp -s "$T" "$SRC" && echo "PASS transcript moved verbatim" || { echo "FAIL transcript differs from source"; fail=1; }; fi
grep -qi "thirty-eight\|38 attorneys\|38" "$DEAL/DEAL.md" 2>/dev/null && echo "PASS attorney count captured" || { echo "FAIL attorney count missing"; fail=1; }
grep -qi "February\|2027-02-01\|Feb" "$DEAL/DEAL.md" 2>/dev/null && echo "PASS renewal date captured" || { echo "FAIL renewal date missing"; fail=1; }
grep -qi "Marcus" "$DEAL/DEAL.md" 2>/dev/null && echo "PASS skeptic captured" || { echo "FAIL Marcus missing"; fail=1; }
grep -qi "CaseSpring" "$DEAL/DEAL.md" 2>/dev/null && echo "PASS competitor captured" || { echo "FAIL competitor missing"; fail=1; }
grep -Eiq "[0-9]+ ?% ?(chance|likely|probab|close)|(chance|probability|likelihood|odds)[^.]{0,25}[0-9]+ ?%" "$DEAL/DEAL.md" 2>/dev/null && { echo "FAIL probability number present"; fail=1; } || echo "PASS no probability number"
grep -q "rule" "$DEAL/DEAL.md" 2>/dev/null && echo "PASS cites rules" || { echo "FAIL no rule citation in DEAL.md"; fail=1; }
echo "result: $([ $fail = 0 ] && echo ALL PASS || echo FAILURES)"; exit $fail
