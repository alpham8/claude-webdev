#!/usr/bin/env bash
# Installs agentic-webdev rules and skills for every detected agent.
# Rules are binding; skills are recommendations. They always install together.
set -euo pipefail

declare -r REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r CLAUDE_DIR="$HOME/.claude"
declare -r OPENCODE_DIR="$HOME/.config/opencode"

declare -i installed=0

install_claude()
{
    echo "==> Claude Code -> $CLAUDE_DIR"
    mkdir -p "$CLAUDE_DIR/rules" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/hooks"

    if compgen -G "$CLAUDE_DIR/rules/*.md" > /dev/null || compgen -G "$CLAUDE_DIR/skills/*" > /dev/null || [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
        declare -r BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        [ -d "$CLAUDE_DIR/rules" ] && cp -r "$CLAUDE_DIR/rules" "$BACKUP_DIR/rules"
        [ -d "$CLAUDE_DIR/skills" ] && cp -r "$CLAUDE_DIR/skills" "$BACKUP_DIR/skills"
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

install_opencode()
{
    echo "==> opencode -> $OPENCODE_DIR"
    mkdir -p "$OPENCODE_DIR/rules" "$OPENCODE_DIR/skills" "$OPENCODE_DIR/plugins"

    if compgen -G "$OPENCODE_DIR/rules/*.md" > /dev/null || compgen -G "$OPENCODE_DIR/skills/*" > /dev/null || [ -f "$OPENCODE_DIR/AGENTS.md" ]; then
        declare -r BACKUP_DIR="$OPENCODE_DIR/backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        [ -d "$OPENCODE_DIR/rules" ] && cp -r "$OPENCODE_DIR/rules" "$BACKUP_DIR/rules"
        [ -d "$OPENCODE_DIR/skills" ] && cp -r "$OPENCODE_DIR/skills" "$BACKUP_DIR/skills"
        [ -f "$OPENCODE_DIR/AGENTS.md" ] && cp "$OPENCODE_DIR/AGENTS.md" "$BACKUP_DIR/AGENTS.md"
        echo "    [!] Bestehende Dateien gesichert nach $BACKUP_DIR"
    fi

    cp "$REPO_DIR/rules/"*.md "$OPENCODE_DIR/rules/"
    cp -r "$REPO_DIR/skills/"* "$OPENCODE_DIR/skills/"
    cp "$REPO_DIR/adapters/opencode/AGENTS.md" "$OPENCODE_DIR/AGENTS.md"
    cp "$REPO_DIR/adapters/opencode/plugins/hooks.ts" "$OPENCODE_DIR/plugins/hooks.ts"

    if [ -f "$OPENCODE_DIR/opencode.json" ]; then
        echo "    [!] opencode.json existiert — nicht überschrieben."
        echo "        Vergleiche $REPO_DIR/adapters/opencode/opencode.json manuell."
    else
        cp "$REPO_DIR/adapters/opencode/opencode.json" "$OPENCODE_DIR/opencode.json"
    fi

    installed=$((installed + 1))
}

[ -d "$CLAUDE_DIR" ] && install_claude
[ -d "$OPENCODE_DIR" ] && install_opencode

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
