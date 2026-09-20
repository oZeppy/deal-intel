#!/usr/bin/env bash
# Builds a ~20k-word stress transcript from the base fixture so the ingest path is tested at Gong length.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC="$ROOT/fixtures/inbox/2026-09-10 Pinecrest Family Law Group - discovery call.md"
OUT="${1:-$ROOT/fixtures/long/2026-09-24 Pinecrest Family Law Group - demo (long).md}"
mkdir -p "$(dirname "$OUT")"
{
  echo "Pinecrest Family Law Group | Demo with partners (stress fixture)"
  echo "Sep 24, 2026 · 118 min · Recorded by Gong"
  echo "Participants: Sam Rivera (Lumen Legal), Dana Whitfield, Luis Ortega, Priya Natarajan, Marcus Bell (Partner, Boulder)"
  echo
  for i in $(seq 1 14); do
    echo "--- segment $i ---"
    tail -n +5 "$SRC" | sed "s/^\([A-Za-z ]*\) (\([0-9][0-9]\):\([0-9][0-9]\)):/\1 ($((i*8+10)):\3):/"
    echo
  done
  echo "Marcus Bell (119:40): One last thing that was not said earlier. If the trust reconciliation sign-off is not in the contract as a go-live condition, I vote no. Put it in writing."
  echo "Sam Rivera (119:52): It will be in the order form as a go-live condition. You have my word and you'll have it in writing by Friday."
} > "$OUT"
wc -w "$OUT"
