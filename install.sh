#!/usr/bin/env bash
# Installs agentic-webdev rules and skills for every detected agent.
# Rules are binding; skills are recommendations. They always install together.
set -euo pipefail

declare -r REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r CLAUDE_DIR="$HOME/.claude"
declare -r OPENCODE_DIR="$HOME/.config/opencode"
declare -r QWEN_DIR="$HOME/.qwen"

declare -i installed=0

install_claude()
{
    echo "==> Claude Code -> $CLAUDE_DIR"
    mkdir -p "$CLAUDE_DIR/rules" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/hooks"

    if compgen -G "$CLAUDE_DIR/rules/*.md" > /dev/null || compgen -G "$CLAUDE_DIR/skills/*" > /dev/null || compgen -G "$CLAUDE_DIR/hooks/*" > /dev/null || [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
        declare -r BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        [ -d "$CLAUDE_DIR/rules" ] && cp -r "$CLAUDE_DIR/rules" "$BACKUP_DIR/rules"
        [ -d "$CLAUDE_DIR/skills" ] && cp -r "$CLAUDE_DIR/skills" "$BACKUP_DIR/skills"
        compgen -G "$CLAUDE_DIR/hooks/*" > /dev/null && cp -r "$CLAUDE_DIR/hooks" "$BACKUP_DIR/hooks"
        [ -f "$CLAUDE_DIR/CLAUDE.md" ] && cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/CLAUDE.md"
        echo "    [!] Bestehende Dateien gesichert nach $BACKUP_DIR"
    fi

    cp "$REPO_DIR/rules/"*.md "$CLAUDE_DIR/rules/"
    cp -r "$REPO_DIR/skills/"* "$CLAUDE_DIR/skills/"
    cp "$REPO_DIR/adapters/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    cp "$REPO_DIR/adapters/claude/hooks/"* "$CLAUDE_DIR/hooks/"
    chmod +x "$CLAUDE_DIR/hooks/"*

    if [ -f "$CLAUDE_DIR/settings.json" ]; then
        echo "    [!] settings.json existiert — nicht überschrieben."
        echo "        Vergleiche $REPO_DIR/adapters/claude/settings.json manuell."
    else
        cp "$REPO_DIR/adapters/claude/settings.json" "$CLAUDE_DIR/settings.json"
    fi

    installed=$((installed + 1))
}

# Ergänzt fehlende Regel-Einträge in einer bestehenden opencode.json.
# Nur der instructions-Array wird angefasst; alles andere bleibt Byte-identisch,
# damit handgepflegte Provider-, Permission- und MCP-Blöcke erhalten bleiben.
merge_opencode_instructions()
{
    declare -r CONFIG="$OPENCODE_DIR/opencode.json"

    if ! command -v jq > /dev/null 2>&1; then
        echo "    [!] jq nicht gefunden — opencode.json nicht geprüft."
        echo "        Vergleiche $REPO_DIR/adapters/opencode/opencode.json manuell."
        return 0
    fi

    if ! jq -e . "$CONFIG" > /dev/null 2>&1; then
        echo "    [!] opencode.json ist kein gültiges JSON — nicht verändert."
        echo "        Vergleiche $REPO_DIR/adapters/opencode/opencode.json manuell."
        return 0
    fi

    if ! jq -e 'has("instructions")' "$CONFIG" > /dev/null 2>&1; then
        echo "    [!] opencode.json hat keinen instructions-Block — nicht verändert."
        echo "        Übernimm ihn aus $REPO_DIR/adapters/opencode/opencode.json."
        return 0
    fi

    declare -a wanted=("~/.config/opencode/AGENTS.md")
    declare rule=""
    for rule in "$REPO_DIR/rules/"*.md; do
        wanted+=("~/.config/opencode/rules/$(basename "$rule")")
    done

    declare -a existing=()
    mapfile -t existing < <(jq -r '.instructions[]' "$CONFIG")

    declare -a missing=()
    declare entry=""
    declare suffix=""
    for entry in "${wanted[@]}"; do
        # Verdrahtet gilt ein Eintrag, wenn ein bestehender Pfad auf dieselbe
        # Datei zeigt — unabhängig davon, ob er ~/… oder absolut notiert ist.
        suffix="/${entry#\~/.config/opencode/}"
        if ! printf '%s\n' "${existing[@]}" | grep -qF -- "$suffix"; then
            missing+=("$entry")
        fi
    done

    if [ "${#missing[@]}" -eq 0 ]; then
        echo "    opencode.json: alle ${#wanted[@]} Einträge bereits verdrahtet."
        return 0
    fi

    cp "$CONFIG" "$CONFIG.bak-$(date +%Y%m%d-%H%M%S)"

    declare -a merged=("${existing[@]}" "${missing[@]}")
    declare new_body=""
    new_body="$(printf '%s\n' "${merged[@]}" | jq -Rsr 'split("\n")[:-1] | map("    " + tojson) | join(",\n")')"

    declare -r TMP_CONFIG="$CONFIG.tmp-$$"
    NEW_BODY="$new_body" perl -0777 -pe 's/("instructions"\s*:\s*\[)[^\]]*\]/"$1\n" . $ENV{NEW_BODY} . "\n  ]"/e' "$CONFIG" > "$TMP_CONFIG"

    if ! jq -e . "$TMP_CONFIG" > /dev/null 2>&1; then
        rm -f "$TMP_CONFIG"
        echo "    [!] Zusammenführung hätte ungültiges JSON erzeugt — abgebrochen."
        echo "        Ergänze manuell: ${missing[*]}"
        return 0
    fi

    mv "$TMP_CONFIG" "$CONFIG"
    echo "    opencode.json: ${#missing[@]} fehlende Einträge ergänzt (${missing[*]##*/})"
}

install_opencode()
{
    echo "==> opencode -> $OPENCODE_DIR"
    mkdir -p "$OPENCODE_DIR/rules" "$OPENCODE_DIR/skills" "$OPENCODE_DIR/plugins"

    if compgen -G "$OPENCODE_DIR/rules/*.md" > /dev/null || compgen -G "$OPENCODE_DIR/skills/*" > /dev/null || compgen -G "$OPENCODE_DIR/plugins/*" > /dev/null || [ -f "$OPENCODE_DIR/AGENTS.md" ]; then
        declare -r BACKUP_DIR="$OPENCODE_DIR/backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        [ -d "$OPENCODE_DIR/rules" ] && cp -r "$OPENCODE_DIR/rules" "$BACKUP_DIR/rules"
        [ -d "$OPENCODE_DIR/skills" ] && cp -r "$OPENCODE_DIR/skills" "$BACKUP_DIR/skills"
        compgen -G "$OPENCODE_DIR/plugins/*" > /dev/null && cp -r "$OPENCODE_DIR/plugins" "$BACKUP_DIR/plugins"
        [ -f "$OPENCODE_DIR/AGENTS.md" ] && cp "$OPENCODE_DIR/AGENTS.md" "$BACKUP_DIR/AGENTS.md"
        echo "    [!] Bestehende Dateien gesichert nach $BACKUP_DIR"
    fi

    cp "$REPO_DIR/rules/"*.md "$OPENCODE_DIR/rules/"
    cp -r "$REPO_DIR/skills/"* "$OPENCODE_DIR/skills/"
    cp "$REPO_DIR/adapters/opencode/AGENTS.md" "$OPENCODE_DIR/AGENTS.md"
    cp "$REPO_DIR/adapters/opencode/plugins/hooks.ts" "$OPENCODE_DIR/plugins/hooks.ts"

    if [ -f "$OPENCODE_DIR/opencode.json" ]; then
        merge_opencode_instructions
    else
        cp "$REPO_DIR/adapters/opencode/opencode.json" "$OPENCODE_DIR/opencode.json"
    fi

    installed=$((installed + 1))
}

install_qwen()
{
    echo "==> Qwen Code -> $QWEN_DIR"
    mkdir -p "$QWEN_DIR/rules" "$QWEN_DIR/skills"

    if compgen -G "$QWEN_DIR/rules/*.md" > /dev/null || compgen -G "$QWEN_DIR/skills/*" > /dev/null || [ -f "$QWEN_DIR/QWEN.md" ]; then
        declare -r BACKUP_DIR="$QWEN_DIR/backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        [ -d "$QWEN_DIR/rules" ] && cp -r "$QWEN_DIR/rules" "$BACKUP_DIR/rules"
        [ -d "$QWEN_DIR/skills" ] && cp -r "$QWEN_DIR/skills" "$BACKUP_DIR/skills"
        [ -f "$QWEN_DIR/QWEN.md" ] && cp "$QWEN_DIR/QWEN.md" "$BACKUP_DIR/QWEN.md"
        echo "    [!] Bestehende Dateien gesichert nach $BACKUP_DIR"
    fi

    cp "$REPO_DIR/rules/"*.md "$QWEN_DIR/rules/"
    cp -r "$REPO_DIR/skills/"* "$QWEN_DIR/skills/"
    cp "$REPO_DIR/adapters/qwen/QWEN.md" "$QWEN_DIR/QWEN.md"

    echo "    Kontextdatei: $QWEN_DIR/QWEN.md — mit \`/memory show\` in Qwen prüfbar."

    installed=$((installed + 1))
}

[ -d "$CLAUDE_DIR" ] && install_claude
[ -d "$OPENCODE_DIR" ] && install_opencode
[ -d "$QWEN_DIR" ] && install_qwen

if [ "$installed" -eq 0 ]; then
    echo "Kein Agent erkannt (weder $CLAUDE_DIR noch $OPENCODE_DIR)."
    echo ""
    echo "Für andere Agents (Cursor, Codex, Copilot, Gemini CLI, ...):"
    echo "  npx skills add alpham8/agentic-webdev --agent '*' -g"
    echo ""
    echo "Achtung: npx skills installiert NUR Skills, keine Rules."
    exit 1
fi

echo ""
echo "==> Fertig. $installed Agent(en) konfiguriert."
echo "    $(ls "$REPO_DIR"/rules/*.md | wc -l) Rules (verbindlich), $(ls -d "$REPO_DIR"/skills/*/ | wc -l) Skills."
