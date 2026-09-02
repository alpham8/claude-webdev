#!/usr/bin/env bash
# Verifies the Shopware split lost no content: every substantive line of the
# pre-split SKILL.md must survive in one of the shopware* skills.
set -euo pipefail

declare -r BASELINE_REF="${1:-master}"
declare -r REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
declare -r ORIGINAL="skills/shopware/SKILL.md"

declare -r TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git -C "$REPO_ROOT" show "$BASELINE_REF:$ORIGINAL" > "$TMP/original.md"

# Strips the YAML frontmatter block: every skill gets its own name and
# description, so those lines are rewritten by design, not lost.
strip_frontmatter()
{
    awk 'NR==1 && $0=="---" {infm=1; next} infm && $0=="---" {infm=0; next} !infm'
}

# Substantive = non-empty and not a heading. Headings are excluded because
# the split deliberately rewrites the heading structure.
strip_frontmatter < "$TMP/original.md" \
    | grep -vE '^\s*$|^#{1,6} ' | sed 's/[[:space:]]*$//' | sort -u > "$TMP/want"

for skill in "$REPO_ROOT"/skills/shopware*/SKILL.md; do
    strip_frontmatter < "$skill"
done | grep -vE '^\s*$|^#{1,6} ' | sed 's/[[:space:]]*$//' | sort -u > "$TMP/have"

comm -23 "$TMP/want" "$TMP/have" > "$TMP/missing"

declare -i missing_count
missing_count="$(wc -l < "$TMP/missing")"

echo "Baseline:  $BASELINE_REF:$ORIGINAL ($(wc -l < "$TMP/want") substantive lines)"
echo "Nachher:   $(ls -d "$REPO_ROOT"/skills/shopware*/ | wc -l) Skills ($(wc -l < "$TMP/have") substantive lines)"
echo ""

if [ "$missing_count" -eq 0 ]; then
    echo "Vollstaendig — keine Zeile verloren."
    exit 0
fi

echo "FEHLEND: $missing_count Zeile(n)"
head -40 "$TMP/missing" | sed 's/^/  /'
[ "$missing_count" -gt 40 ] && echo "  ... und $((missing_count - 40)) weitere"
exit 1
