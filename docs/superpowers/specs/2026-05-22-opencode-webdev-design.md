# Design: opencode-webdev

**Date:** 2026-05-22  
**Status:** Approved  
**Target repo:** `~/Projekte/opencode-webdev`

## Ziel

Ein eigenständiges Konfigurations-Repository für [sst/opencode](https://opencode.ai) als zweiten Coding-Harness neben Qwen Code. opencode verbindet sich über LiteLLM mit einem vLLM/Podman-Backend (Qwen3.6-35B-A3B-FP8) auf einem Hetzner Dedicated Server.

Das Repo ist das opencode-Pendant zu `claude-webdev` und soll für sich allein funktionieren — unabhängig davon, ob `~/.claude` existiert.

## Architektur

```
Client (opencode)
  → LiteLLM Proxy (OpenAI-kompatibler Endpunkt, env: LITELLM_BASE_URL)
    → vLLM in Podman (Qwen3.6-35B-A3B-FP8)
```

opencode verwendet `provider: openai` mit einer custom `baseURL` — damit ist LiteLLM ein transparentes Drop-in.

## Repo-Struktur

```
opencode-webdev/
├── AGENTS.md                    ← Haupt-Kontextdatei (aus CLAUDE.md abgeleitet)
├── opencode.json                ← Globale Config (LiteLLM, Permissions, MCP, Skills)
├── install.sh                   ← Kopiert alles nach ~/.config/opencode/
├── README.md
├── rules/                       ← Alle 19 Coding-Regeln (identisch zu claude-webdev)
│   ├── 01-coding-standard.md
│   ├── 02-security.md
│   ├── 03-type-system.md
│   ├── 04-clean-code.md
│   ├── 05-complexity.md
│   ├── 06-maintainability.md
│   ├── 07-js-ts-tooling.md
│   ├── 08-vue-svelte.md
│   ├── 09-testing.md
│   ├── 10-environment.md
│   ├── 11-boundaries.md
│   ├── 12-performance.md
│   ├── 13-database.md
│   ├── 14-dependencies.md
│   ├── 15-observability.md
│   ├── 16-accessibility.md
│   ├── 17-i18n.md
│   ├── 18-git-workflow.md
│   └── 19-css.md
├── skills/                      ← Alle 18 Domain-Skills + wondelai (identisch zu claude-webdev)
│   ├── aspnet-core/SKILL.md
│   ├── content-testing/SKILL.md
│   ├── copywriter-de/SKILL.md
│   ├── csharp/SKILL.md
│   ├── ddev-development/SKILL.md
│   ├── marketing-copywriter-de/SKILL.md
│   ├── php/SKILL.md
│   ├── shopware/SKILL.md
│   ├── shopware-ddev/SKILL.md
│   ├── shopware-utils/SKILL.md
│   ├── svelte/SKILL.md
│   ├── symfony/SKILL.md
│   ├── symfony-project-setup/SKILL.md
│   ├── tech-colleague-de/SKILL.md
│   ├── typescript/SKILL.md
│   ├── ui-animation-engineering/SKILL.md
│   ├── ui-audit-redesign/SKILL.md
│   ├── vue/SKILL.md
│   └── wondelai/                ← 24 Knowledge-Skills mit references/
│       ├── clean-architecture/
│       ├── clean-code/
│       └── ... (alle 24)
└── plugins/
    └── hooks.ts                 ← opencode-Plugin: wraps die 4 Shell-Hooks
```

**Bewusst weggelassen:**
- `context-mode-cache-heal.mjs` — Claude Code / context-mode-Plugin-spezifisch
- Superpowers-Plugin-Konfiguration — kein opencode-Äquivalent
- `claude-mem`, `context-mode` MCP-Server — Claude Code-spezifisch
- `.claude/settings.local.json` — nicht übertragbar

## Installationspfad

`~/.config/opencode/` (opencode-Standard gemäß `opencode debug paths`)

```
~/.config/opencode/
├── opencode.json
├── AGENTS.md
├── rules/
├── skills/
├── hooks/          ← Shell-Skripte (aus ~/.claude/hooks/ übernommen)
└── plugins/
    └── hooks.ts
```

## opencode.json

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "openai/mai-coding-default",
  "provider": {
    "openai": {
      "options": {
        "baseURL": "env(LITELLM_BASE_URL)",
        "apiKey": "env(LITELLM_API_KEY)"
      }
    }
  },
  "instructions": [
    "~/.config/opencode/AGENTS.md",
    "~/.config/opencode/rules/01-coding-standard.md",
    "~/.config/opencode/rules/02-security.md",
    "~/.config/opencode/rules/03-type-system.md",
    "~/.config/opencode/rules/04-clean-code.md",
    "~/.config/opencode/rules/05-complexity.md",
    "~/.config/opencode/rules/06-maintainability.md",
    "~/.config/opencode/rules/07-js-ts-tooling.md",
    "~/.config/opencode/rules/08-vue-svelte.md",
    "~/.config/opencode/rules/09-testing.md",
    "~/.config/opencode/rules/10-environment.md",
    "~/.config/opencode/rules/11-boundaries.md",
    "~/.config/opencode/rules/12-performance.md",
    "~/.config/opencode/rules/13-database.md",
    "~/.config/opencode/rules/14-dependencies.md",
    "~/.config/opencode/rules/15-observability.md",
    "~/.config/opencode/rules/16-accessibility.md",
    "~/.config/opencode/rules/17-i18n.md",
    "~/.config/opencode/rules/18-git-workflow.md",
    "~/.config/opencode/rules/19-css.md"
  ],
  "skills": {
    "paths": ["~/.config/opencode/skills"]
  },
  "permission": {
    "bash": {
      "git push*":                      "deny",
      "git commit":                     "deny",
      "flatpak install*":               "deny",
      "snap install*":                  "deny",
      "pip install*":                   "deny",
      "pip3 install*":                  "deny",
      "npm install -g*":                "deny",
      "cargo install*":                 "deny",
      "gem install*":                   "deny",
      "sudo rpm*":                      "deny",
      "sudo systemctl*":                "deny",
      "sudo rm*":                       "deny",
      "sudo chmod*":                    "deny",
      "sudo chown*":                    "deny",
      "sudo dd*":                       "deny",
      "sudo mkfs*":                     "deny",
      "sudo fdisk*":                    "deny",
      "sudo parted*":                   "deny",
      "sudo passwd*":                   "deny",
      "sudo userdel*":                  "deny",
      "sudo groupdel*":                 "deny",
      "sudo visudo*":                   "deny",
      "sudo crontab*":                  "deny",
      "sudo mount*":                    "deny",
      "sudo umount*":                   "deny",
      "sudo iptables*":                 "deny",
      "sudo firewall-cmd --permanent*": "deny",
      "sudo sysctl -w*":                "deny",
      "rm -rf /*":                      "deny",
      "*":                              "allow"
    }
  },
  "mcp": {
    "context7": {
      "type": "local",
      "command": ["npx", "-y", "@upstash/context7-mcp"]
    },
    "playwright-chromium": {
      "type": "local",
      "command": ["npx", "@playwright/mcp@latest", "--browser", "chromium"]
    },
    "playwright-firefox": {
      "type": "local",
      "command": ["npx", "@playwright/mcp@latest", "--browser", "firefox"]
    },
    "mysql": {
      "type": "local",
      "command": ["npx", "-y", "@benborla29/mcp-server-mysql"],
      "env": {
        "MYSQL_HOST": "127.0.0.1",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "db",
        "MYSQL_PASS": "db",
        "MYSQL_DB": "",
        "ALLOW_INSERT_OPERATION": "false",
        "ALLOW_UPDATE_OPERATION": "false",
        "ALLOW_DELETE_OPERATION": "false"
      }
    },
    "github": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  },
  "compaction": { "auto": true, "tail_turns": 15 }
}
```

## AGENTS.md

Abgeleitet aus `~/.claude/CLAUDE.md`. Die `@rules/`-Include-Syntax von Claude Code entfällt — Regeln werden über das `instructions`-Array in `opencode.json` geladen.

Inhalt: Abschnitt 0 „Always Start Here" mit den 5 Grundregeln, plus ein Verweis auf die 19 geladenen Regel-Dateien. Kein Inline-Wiederholen der Regelinhalte.

## Hooks

opencode hat kein Shell-Skript-Hook-System in der Config. Hooks werden als TypeScript-Plugin unter `plugins/hooks.ts` implementiert.

Das Plugin verwendet `execFile` (nicht `exec`) um Shell-Injection zu verhindern — Kommando und Argumente werden getrennt übergeben:

```typescript
import { execFile } from 'child_process'
import { promisify } from 'util'
import type { Plugin } from '@opencode-ai/plugin'

const execFileAsync = promisify(execFile)

const HOOKS_DIR = `${process.env.HOME}/.config/opencode/hooks`

export default (async () =>
{
    return {
        'tool.execute.before': async (input) => {
            if (input.tool === 'bash') {
                const command = input.args.command ?? ''
                await execFileAsync(`${HOOKS_DIR}/guard-bash.sh`, [command])
            }
        },
        'tool.execute.after': async (input) => {
            if (input.tool === 'edit' || input.tool === 'write') {
                const file = input.args.file_path ?? ''
                await execFileAsync(`${HOOKS_DIR}/format-on-save.sh`, [file])
                await execFileAsync(`${HOOKS_DIR}/phpstan-check.sh`, [file])
                await execFileAsync(`${HOOKS_DIR}/tsc-check.sh`, [file])
            }
        },
    }
}) satisfies Plugin
```

Die Shell-Skripte selbst (`format-on-save.sh`, `guard-bash.sh`, `phpstan-check.sh`, `tsc-check.sh`) sind identisch zu `claude-webdev` und werden **nicht dupliziert** — `install.sh` kopiert sie aus `~/.claude/hooks/` wenn vorhanden.

## install.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

DEST="$HOME/.config/opencode"
mkdir -p "$DEST/rules" "$DEST/skills" "$DEST/hooks" "$DEST/plugins"

cp AGENTS.md       "$DEST/AGENTS.md"
cp opencode.json   "$DEST/opencode.json"
cp rules/*.md      "$DEST/rules/"
cp -r skills/.     "$DEST/skills/"
cp -r plugins/.    "$DEST/plugins/"

CLAUDE_HOOKS="$HOME/.claude/hooks"
if [ -d "$CLAUDE_HOOKS" ]; then
    cp "$CLAUDE_HOOKS/format-on-save.sh" "$DEST/hooks/"
    cp "$CLAUDE_HOOKS/guard-bash.sh"     "$DEST/hooks/"
    cp "$CLAUDE_HOOKS/phpstan-check.sh"  "$DEST/hooks/"
    cp "$CLAUDE_HOOKS/tsc-check.sh"      "$DEST/hooks/"
else
    echo "WARN: ~/.claude/hooks nicht gefunden — Hooks manuell kopieren"
fi

echo "Fertig. LITELLM_BASE_URL und LITELLM_API_KEY in ~/.zshrc/.bashrc setzen."
```

## Skills

Alle 18 Domain-Skills und alle 24 wondelai-Knowledge-Skills aus `claude-webdev` werden 1:1 übernommen. Das Format (`SKILL.md` mit YAML-Frontmatter `name` + `description`) ist mit opencode nativ kompatibel — opencode scannt `**/SKILL.md` in den konfigurierten `skills.paths`.

Per-Projekt-Skills können durch ein lokales `opencode.json` hinzugefügt werden:

```json
{
  "skills": {
    "paths": [".opencode/skills"]
  }
}
```

## Offene Punkte / Verifikation

- **`@opencode-ai/plugin` Typ-Paket:** Muss bei der Implementierung auf tatsächliche Verfügbarkeit und exakte Plugin-API geprüft werden (Tool-Namen, Input-Shape). Ggf. auf `any` ausweichen und nachträglich typisieren.
- **`permission`-Schlüssel:** opencode validiert die Config strikt. Nach dem Erstellen mit `opencode debug config` verifizieren, dass alle Deny-Patterns korrekt angewendet werden.
- **Env-Var-Syntax:** `env(LITELLM_BASE_URL)` ist die opencode-eigene Interpolations-Syntax — im Test gegen die installierte Version verifizieren.
- **LITELLM_BASE_URL / LITELLM_API_KEY:** Müssen in `~/.zshrc` oder `~/.bashrc` gesetzt sein, bevor opencode gestartet wird.