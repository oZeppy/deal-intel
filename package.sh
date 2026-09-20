#!/usr/bin/env bash
# Builds dist/deal-intel-v<version>.zip: what the rep receives.
#
# Layout inside the zip (install path verified against Anthropic's help pages 2026-09-20):
#   TRY-IT.md, README.md
#   skills-to-upload/deal-room.zip, forecast.zip, closed-lost.zip
#       one zip per skill, each containing the skill FOLDER (Customize > Skills > + > + Create skill > Upload a skill)
#   plugin-package/deal-intel-plugin.zip
#       the whole plugin (.claude-plugin + skills) for the Plugins tab's upload option; format not documented precisely, optional path
#   workspace-example/   with the synthetic sample transcript already in inbox/ so the first test needs no Salesforce
# Excluded: .git, test/, fixtures/salesforce, .gitignore, dist/. Nothing in the zip is real customer data.
# Usage: ./package.sh            (prints the zip path, then its file list)
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
SRC="$ROOT/plugins/deal-intel"
VER=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$SRC/.claude-plugin/plugin.json")
OUT="$ROOT/dist"; mkdir -p "$OUT"
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/deal-intel-pkg.XXXXXX")
PKG="$STAGE/deal-intel"; mkdir -p "$PKG/skills-to-upload" "$PKG/plugin-package"

# 1. one zip per skill, folder as the zip root
for s in start deal-room forecast closed-lost; do
  (cd "$SRC/skills" && zip -qr "$PKG/skills-to-upload/$s.zip" "$s" -x '*.DS_Store')
done

# 2. the whole plugin as one package (optional path)
PLUG="$STAGE/plugin-src/deal-intel"; mkdir -p "$PLUG"
cp -R "$SRC/.claude-plugin" "$SRC/skills" "$PLUG/"; cp "$ROOT/README.md" "$PLUG/"
find "$PLUG" -name .DS_Store -delete
(cd "$STAGE/plugin-src" && zip -qr "$PKG/plugin-package/deal-intel-plugin.zip" deal-intel)

# 3. docs and the example workspace with the sample transcript
cp "$ROOT/README.md" "$ROOT/TRY-IT.md" "$PKG/"
cp -R "$ROOT/workspace-example" "$PKG/"
for f in "$ROOT"/fixtures/inbox/*.md; do cp "$f" "$PKG/workspace-example/inbox/SAMPLE (not real) - $(basename "$f")"; done
find "$PKG" \( -name .DS_Store -o -name .gitkeep \) -delete

ZIP="$OUT/deal-intel-v$VER.zip"; rm -f "$ZIP"
(cd "$STAGE" && zip -qr "$ZIP" deal-intel)
rm -rf "$STAGE"
echo "$ZIP"
unzip -Z1 "$ZIP" | grep -v '/$' | sort
