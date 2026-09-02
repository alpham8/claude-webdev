#!/usr/bin/env bash
# Validates skills against the Agent Skills spec (agentskills.io).
set -euo pipefail

declare -r SKILLS_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)/skills}"
declare -r MAX_DESCRIPTION=1024
declare -r WARN_LINES=500

declare -i errors=0
declare -i warnings=0

fail()
{
    echo "  FAIL  $1"
    errors=$((errors + 1))
}

warn()
{
    echo "  WARN  $1"
    warnings=$((warnings + 1))
}

# A loose .md directly under skills/ is never discovered as a skill.
while IFS= read -r loose; do
    fail "$(basename "$loose"): loose file in skills/ — must be <name>/SKILL.md"
done < <(find "$SKILLS_DIR" -maxdepth 1 -type f -name '*.md')

for dir in "$SKILLS_DIR"/*/; do
    [ -d "$dir" ] || continue

    declare skill_name
    skill_name="$(basename "$dir")"

    # A container of sub-skills (e.g. wondelai/) is valid: no SKILL.md of its own.
    if [ ! -f "$dir/SKILL.md" ]; then
        if find "$dir" -mindepth 2 -name 'SKILL.md' -print -quit | grep -q .; then
            continue
        fi
        fail "$skill_name: no SKILL.md and no nested skills"
        continue
    fi

    declare front name desc
    front="$(awk 'NR==1 && $0=="---" {inside=1; next} inside && $0=="---" {exit} inside' "$dir/SKILL.md")"

    if [ -z "$front" ]; then
        fail "$skill_name: missing YAML frontmatter"
        continue
    fi

    name="$(printf '%s\n' "$front" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
    desc="$(printf '%s\n' "$front" | sed -n 's/^description:[[:space:]]*//p' | head -1)"

    if [ "$name" = "" ]; then
        fail "$skill_name: frontmatter has no name"
    elif [ "$name" != "$skill_name" ]; then
        fail "$skill_name: name '$name' does not match directory"
    elif ! printf '%s' "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        fail "$skill_name: name '$name' violates the spec charset"
    fi

    if [ "$desc" = "" ]; then
        fail "$skill_name: frontmatter has no description"
    elif [ "${#desc}" -gt "$MAX_DESCRIPTION" ]; then
        fail "$skill_name: description ${#desc} chars, max $MAX_DESCRIPTION"
    fi

    declare -i lines
    lines="$(wc -l < "$dir/SKILL.md")"
    if [ "$lines" -gt "$WARN_LINES" ]; then
        warn "$skill_name: $lines lines, above the $WARN_LINES-line guideline"
    fi
done

echo ""
echo "Skills: $errors error(s), $warnings warning(s)."
[ "$errors" -eq 0 ]
