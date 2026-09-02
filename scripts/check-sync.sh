#!/usr/bin/env bash
set -euo pipefail

CLAUDE_HOOKS="$(cd "$(dirname "$0")/.." && pwd)/adapters/claude/hooks"
OPENCODE_HOOKS="$(cd "$(dirname "$0")/.." && pwd)/adapters/opencode/plugins/hooks.ts"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

DRIFT=0

TMPDIR_SYNC=$(mktemp -d)
trap 'rm -rf "$TMPDIR_SYNC"' EXIT

print_header()
{
    echo ""
    echo "=== $1 ==="
}

compare_sets()
{
    local shell_file="$1"
    local ts_file="$2"

    local only_shell only_ts
    only_shell=$(comm -23 "$shell_file" "$ts_file")
    only_ts=$(comm -13 "$shell_file" "$ts_file")

    if [ -z "$only_shell" ] && [ -z "$only_ts" ]; then
        echo -e "  ${GREEN}Synchron${NC}"
        return
    fi

    DRIFT=1

    if [ -n "$only_shell" ]; then
        echo -e "  ${YELLOW}Nur in Shell:${NC}"
        while IFS= read -r line; do
            echo "    - $line"
        done <<< "$only_shell"
    fi

    if [ -n "$only_ts" ]; then
        echo -e "  ${YELLOW}Nur in TypeScript:${NC}"
        while IFS= read -r line; do
            echo "    - $line"
        done <<< "$only_ts"
    fi
}

# --- Dangerous Patterns ---

print_header "Dangerous Patterns (guard-bash)"

GUARD_SHELL="$CLAUDE_HOOKS/guard-bash.sh"
if [ ! -f "$GUARD_SHELL" ]; then
    echo -e "  ${RED}FEHLT: $GUARD_SHELL${NC}"
    DRIFT=1
else
    # Shell: single-quoted strings inside DANGEROUS_PATTERNS=( ... )
    awk '/^DANGEROUS_PATTERNS=/,/^\)/' "$GUARD_SHELL" \
        | grep -oP "(?<=').*(?=')" \
        | sort > "$TMPDIR_SYNC/shell_patterns"

    # TS: regex literals inside DANGEROUS_PATTERNS array — parse escaped slashes
    awk '/^const DANGEROUS_PATTERNS/,/^\]/' "$OPENCODE_HOOKS" \
        | perl -ne 'if (/^\s+\/(.*)\/,?\s*$/) { my $p = $1; $p =~ s|\\\/|/|g; print "$p\n"; }' \
        | sort > "$TMPDIR_SYNC/ts_patterns"

    compare_sets "$TMPDIR_SYNC/shell_patterns" "$TMPDIR_SYNC/ts_patterns"
fi

# --- Prettier Extensions ---

print_header "Prettier Extensions (format-on-save)"

FORMAT_SHELL="$CLAUDE_HOOKS/format-on-save.sh"
if [ ! -f "$FORMAT_SHELL" ]; then
    echo -e "  ${RED}FEHLT: $FORMAT_SHELL${NC}"
    DRIFT=1
else
    # Shell: extensions from case pattern *.ts|*.tsx|... (excluding php)
    grep -oP '\*\.\K[a-z]+' "$FORMAT_SHELL" \
        | grep -v php \
        | sort -u > "$TMPDIR_SYNC/shell_exts"

    # TS: strings from PRETTIER_EXTENSIONS = new Set([...])
    grep 'PRETTIER_EXTENSIONS' "$OPENCODE_HOOKS" \
        | grep -oP "'[a-z]+'" \
        | tr -d "'" \
        | sort -u > "$TMPDIR_SYNC/ts_exts"

    compare_sets "$TMPDIR_SYNC/shell_exts" "$TMPDIR_SYNC/ts_exts"
fi

# --- Tool Paths ---

print_header "Tool-Pfade"

{
    for script in "$CLAUDE_HOOKS"/*.sh; do
        [ -f "$script" ] || continue
        grep -oP '(vendor/bin|node_modules/\.bin)/[a-z_-]+' "$script" || true
    done
} | sort -u > "$TMPDIR_SYNC/shell_tools"

{
    grep -oP '(vendor/bin|node_modules/\.bin)/[a-z_-]+' "$OPENCODE_HOOKS" || true
} | sort -u > "$TMPDIR_SYNC/ts_tools"

compare_sets "$TMPDIR_SYNC/shell_tools" "$TMPDIR_SYNC/ts_tools"

# --- Rules Wiring ---

print_header "Rules-Verdrahtung"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_MD="$REPO_ROOT/adapters/claude/CLAUDE.md"
OPENCODE_JSON="$REPO_ROOT/adapters/opencode/opencode.json"

for rule in "$REPO_ROOT"/rules/*.md; do
    rule_file="$(basename "$rule")"

    if ! grep -q "@rules/$rule_file" "$CLAUDE_MD"; then
        echo -e "  ${RED}Nicht in CLAUDE.md: $rule_file${NC}"
        DRIFT=1
    fi

    if ! grep -q "rules/$rule_file" "$OPENCODE_JSON"; then
        echo -e "  ${RED}Nicht in opencode.json: $rule_file${NC}"
        DRIFT=1
    fi
done

if [ "$DRIFT" -eq 0 ]; then
    echo -e "  ${GREEN}Alle $(ls "$REPO_ROOT"/rules/*.md | wc -l) Rules in beiden Adaptern verdrahtet${NC}"
fi

# --- Result ---

echo ""
if [ "$DRIFT" -eq 0 ]; then
    echo -e "${GREEN}Alles synchron.${NC}"
    exit 0
else
    echo -e "${RED}Drift erkannt! Bitte hooks.ts aktualisieren.${NC}"
    exit 1
fi
