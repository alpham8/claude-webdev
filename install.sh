#!/bin/bash
# Claude Code Setup Installer
# Copies all configuration files into ~/.claude

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "==> Installing Claude Code configuration from $REPO_DIR"

# Create directory structure
mkdir -p "$CLAUDE_DIR/rules"
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/skills"

# CLAUDE.md + rules
echo "  -> Copying CLAUDE.md and rules..."
cp "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
cp "$REPO_DIR/rules/"*.md "$CLAUDE_DIR/rules/"

# Hooks
echo "  -> Installing hooks..."
cp "$REPO_DIR/hooks/"*.sh "$CLAUDE_DIR/hooks/"
chmod +x "$CLAUDE_DIR/hooks/"*.sh

# Skills
echo "  -> Installing skills..."
cp -r "$REPO_DIR/skills/"* "$CLAUDE_DIR/skills/"

# settings.json — only install if not already present, otherwise warn
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    echo ""
    echo "  [!] $CLAUDE_DIR/settings.json already exists — skipping to avoid overwrite."
    echo "      Review $REPO_DIR/settings.json and merge manually if needed."
else
    echo "  -> Installing settings.json..."
    cp "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
fi

echo ""
echo "==> Done! Configuration installed to $CLAUDE_DIR"
echo ""
echo "Next steps:"
echo "  1. Set your GitHub token (for GitHub MCP):"
echo "       echo 'export GITHUB_TOKEN=ghp_yourtoken' >> ~/.bashrc"
echo "       source ~/.bashrc"
echo ""
echo "  2. Restart Claude Code to apply all changes."
