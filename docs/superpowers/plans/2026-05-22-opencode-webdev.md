# opencode-webdev Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Erstelle das Repo `~/Projekte/opencode-webdev` als vollständigen sst/opencode-Harness für das lokale Qwen3.6-LLM über LiteLLM.

**Architecture:** Git-Repo mit `opencode.json` (globale Config für opencode v1.15.7), `AGENTS.md` (Haupt-Kontext), 19 Coding-Rules, 42 Skills (18 Domain + 24 wondelai), und einem TypeScript-Hook-Plugin. `install.sh` kopiert alles nach `~/.config/opencode/`. Holt Shell-Hooks aus `~/.claude/hooks/` (kein Duplizieren).

**Tech Stack:** sst/opencode 1.15.7 (via Homebrew), TypeScript (hooks.ts Plugin), Bash (install.sh), Markdown (AGENTS.md, rules/, skills/)

---

## File Map

| Datei | Verantwortung |
|---|---|
| `AGENTS.md` | Haupt-Kontextdatei — Always-Start-Here-Regeln |
| `opencode.json` | Globale Config: LiteLLM-Provider, Permissions, MCP, Skills, Instructions |
| `install.sh` | Kopiert Repo-Inhalte nach `~/.config/opencode/` |
| `README.md` | Setup-Anleitung für Entwickler |
| `rules/01-19-*.md` | 19 Coding-Regeln, identisch zu claude-webdev |
| `skills/**` | 18 Domain-Skills + wondelai (24 Knowledge-Skills), identisch zu claude-webdev |
| `plugins/hooks.ts` | opencode-Plugin: wraps guard-bash, format-on-save, phpstan, tsc via execFile |

---

### Task 1: Git-Repo initialisieren

**Files:**
- Create: `~/Projekte/opencode-webdev/.gitignore`

- [ ] **Schritt 1: Verzeichnis anlegen und Git initialisieren**

```bash
mkdir -p ~/Projekte/opencode-webdev
cd ~/Projekte/opencode-webdev
git init
git checkout -b master
```

Erwartete Ausgabe: `Initialized empty Git repository in .../opencode-webdev/.git/`

- [ ] **Schritt 2: .gitignore erstellen**

Datei `~/Projekte/opencode-webdev/.gitignore`:

```
node_modules/
*.js.map
dist/
.DS_Store
```

- [ ] **Schritt 3: Initialen Commit**

```bash
cd ~/Projekte/opencode-webdev
git add .gitignore
git commit -m "chore: init opencode-webdev repo"
```

---

### Task 2: AGENTS.md erstellen

**Files:**
- Create: `~/Projekte/opencode-webdev/AGENTS.md`

- [ ] **Schritt 1: AGENTS.md schreiben**

Datei `~/Projekte/opencode-webdev/AGENTS.md`:

```markdown
# Engineering Baseline — opencode

Project-local files always override this baseline:
`AGENTS.md` · `README*` · `docs/` · `code-conventions.md` · `.editorconfig`

---

## 0) Always Start Here

1. Read all project-local rules **before touching code**.
2. Read the project's `README`, `package.json` scripts, `composer.json` scripts,
   or `Makefile` before running any build/test command. Never guess commands.
3. Follow existing patterns unless they violate this baseline or a refactor
   is explicitly requested.
4. Keep diffs small, focused, and easy to review.
5. Do not introduce new dependencies or tools unless required or explicitly
   requested.

---

## Coding Rules (always active)

The following 19 rule files are loaded via `opencode.json → instructions`
and apply to every session:

01-coding-standard · 02-security · 03-type-system · 04-clean-code ·
05-complexity · 06-maintainability · 07-js-ts-tooling · 08-vue-svelte ·
09-testing · 10-environment · 11-boundaries · 12-performance ·
13-database · 14-dependencies · 15-observability · 16-accessibility ·
17-i18n · 18-git-workflow · 19-css
```

- [ ] **Schritt 2: Committen**

```bash
cd ~/Projekte/opencode-webdev
git add AGENTS.md
git commit -m "feat: add AGENTS.md"
```

---

### Task 3: Coding-Rules kopieren

**Files:**
- Create: `~/Projekte/opencode-webdev/rules/` (19 Dateien, aus claude-webdev)

- [ ] **Schritt 1: Rules-Verzeichnis anlegen und kopieren**

```bash
mkdir -p ~/Projekte/opencode-webdev/rules
cp ~/Projekte/claude-webdev/rules/*.md ~/Projekte/opencode-webdev/rules/
```

- [ ] **Schritt 2: Anzahl verifizieren**

```bash
ls ~/Projekte/opencode-webdev/rules/ | wc -l
```

Erwartete Ausgabe: `19`

- [ ] **Schritt 3: Committen**

```bash
cd ~/Projekte/opencode-webdev
git add rules/
git commit -m "feat: add 19 coding rules"
```

---

### Task 4: Skills kopieren

**Files:**
- Create: `~/Projekte/opencode-webdev/skills/` (18 Domain-Skills + wondelai mit 24 Knowledge-Skills)

- [ ] **Schritt 1: Skills kopieren**

```bash
cp -r ~/Projekte/claude-webdev/skills ~/Projekte/opencode-webdev/skills
```

- [ ] **Schritt 2: Struktur verifizieren**

```bash
ls ~/Projekte/opencode-webdev/skills/ | wc -l
```

Erwartete Ausgabe: `19` (18 Domain-Skills + wondelai-Verzeichnis)

```bash
ls ~/Projekte/opencode-webdev/skills/wondelai/ | wc -l
```

Erwartete Ausgabe: `24`

```bash
find ~/Projekte/opencode-webdev/skills -name "SKILL.md" | wc -l
```

Erwartete Ausgabe: `42` (18 + 24)

- [ ] **Schritt 3: Committen**

```bash
cd ~/Projekte/opencode-webdev
git add skills/
git commit -m "feat: add 42 skills (18 domain + 24 wondelai)"
```

---

### Task 5: opencode.json erstellen und verifizieren

**Files:**
- Create: `~/Projekte/opencode-webdev/opencode.json`

- [ ] **Schritt 1: opencode.json schreiben**

Datei `~/Projekte/opencode-webdev/opencode.json`:

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

- [ ] **Schritt 2: Config gegen opencode validieren (install erst danach)**

```bash
cd ~/Projekte/opencode-webdev
mkdir -p ~/.config/opencode/rules ~/.config/opencode/skills
cp AGENTS.md ~/.config/opencode/AGENTS.md
cp rules/*.md ~/.config/opencode/rules/
cp opencode.json ~/.config/opencode/opencode.json
opencode debug config 2>&1
```

Erwartete Ausgabe: JSON-Objekt ohne Fehlermeldung. Wenn `ConfigInvalidError` erscheint, den genannten Feldnamen in `opencode.json` korrigieren und erneut testen.

- [ ] **Schritt 3: Committen**

```bash
cd ~/Projekte/opencode-webdev
git add opencode.json
git commit -m "feat: add opencode.json with LiteLLM provider and permissions"
```

---

### Task 6: Hook-Plugin erstellen

**Files:**
- Create: `~/Projekte/opencode-webdev/plugins/hooks.ts`

Hinweis: opencode lädt Plugins aus `.opencode/plugin/` (projekt-lokal) und `~/.config/opencode/plugins/` (global, nach Install). Das Plugin wird nach Install von `install.sh` in `~/.config/opencode/plugins/` liegen und dort automatisch erkannt.

- [ ] **Schritt 1: plugins/-Verzeichnis anlegen**

```bash
mkdir -p ~/Projekte/opencode-webdev/plugins
```

- [ ] **Schritt 2: hooks.ts schreiben**

Datei `~/Projekte/opencode-webdev/plugins/hooks.ts`:

```typescript
import { execFile } from 'child_process'
import { promisify } from 'util'

const execFileAsync = promisify(execFile)

const HOOKS_DIR = `${process.env['HOME']}/.config/opencode/hooks`

const hooks = async () =>
{
    return {
        'tool.execute.before': async (input: { tool: string; args: Record<string, unknown> }) => {
            if (input.tool !== 'bash') {
                return
            }

            const command = typeof input.args['command'] === 'string'
                ? input.args['command']
                : ''

            try {
                await execFileAsync(`${HOOKS_DIR}/guard-bash.sh`, [command])
            } catch {
                // guard-bash.sh exits non-zero to signal a blocked command —
                // opencode's permission system handles the actual blocking
            }
        },

        'tool.execute.after': async (input: { tool: string; args: Record<string, unknown> }) => {
            if (input.tool !== 'edit' && input.tool !== 'write') {
                return
            }

            const file = typeof input.args['file_path'] === 'string'
                ? input.args['file_path']
                : ''

            if (file === '') {
                return
            }

            await Promise.allSettled([
                execFileAsync(`${HOOKS_DIR}/format-on-save.sh`, [file]),
                execFileAsync(`${HOOKS_DIR}/phpstan-check.sh`, [file]),
                execFileAsync(`${HOOKS_DIR}/tsc-check.sh`, [file]),
            ])
        },
    }
}

export default hooks
```

Hinweis: `Promise.allSettled` statt `Promise.all` — ein fehlschlagender Formatter soll die anderen nicht blockieren. `guard-bash.sh`-Fehler werden geschluckt, weil opencode die eigentliche Berechtigungsprüfung über `permission.bash` in der Config übernimmt; das Shell-Skript dient als zweite Schicht.

- [ ] **Schritt 3: Committen**

```bash
cd ~/Projekte/opencode-webdev
git add plugins/hooks.ts
git commit -m "feat: add opencode hook plugin (guard-bash, format, phpstan, tsc)"
```

---

### Task 7: install.sh erstellen und testen

**Files:**
- Create: `~/Projekte/opencode-webdev/install.sh`

- [ ] **Schritt 1: install.sh schreiben**

Datei `~/Projekte/opencode-webdev/install.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

DEST="$HOME/.config/opencode"

echo "Installing opencode-webdev to $DEST ..."

mkdir -p "$DEST/rules" "$DEST/skills" "$DEST/hooks" "$DEST/plugins"

cp AGENTS.md     "$DEST/AGENTS.md"
cp opencode.json "$DEST/opencode.json"
cp rules/*.md    "$DEST/rules/"
cp -r skills/.   "$DEST/skills/"
cp -r plugins/.  "$DEST/plugins/"

CLAUDE_HOOKS="$HOME/.claude/hooks"
if [ -d "$CLAUDE_HOOKS" ]; then
    echo "Copying hooks from $CLAUDE_HOOKS ..."
    cp "$CLAUDE_HOOKS/format-on-save.sh" "$DEST/hooks/"
    cp "$CLAUDE_HOOKS/guard-bash.sh"     "$DEST/hooks/"
    cp "$CLAUDE_HOOKS/phpstan-check.sh"  "$DEST/hooks/"
    cp "$CLAUDE_HOOKS/tsc-check.sh"      "$DEST/hooks/"
    chmod +x "$DEST/hooks/"*.sh
else
    echo "WARN: $CLAUDE_HOOKS nicht gefunden."
    echo "      Bitte format-on-save.sh, guard-bash.sh, phpstan-check.sh,"
    echo "      tsc-check.sh manuell nach $DEST/hooks/ kopieren."
fi

echo ""
echo "Fertig. Nächste Schritte:"
echo "  1. LITELLM_BASE_URL und LITELLM_API_KEY in ~/.zshrc oder ~/.bashrc setzen"
echo "  2. Shell neu laden: source ~/.zshrc"
echo "  3. opencode starten: opencode"
```

- [ ] **Schritt 2: Ausführbar machen**

```bash
chmod +x ~/Projekte/opencode-webdev/install.sh
```

- [ ] **Schritt 3: Install ausführen und Ergebnis prüfen**

```bash
cd ~/Projekte/opencode-webdev
./install.sh
```

Erwartete Ausgabe: Keine Fehlermeldungen, Abschluss-Meldung mit nächsten Schritten.

- [ ] **Schritt 4: Installierte Dateien verifizieren**

```bash
ls ~/.config/opencode/rules/ | wc -l
```
Erwartete Ausgabe: `19`

```bash
find ~/.config/opencode/skills -name "SKILL.md" | wc -l
```
Erwartete Ausgabe: `42`

```bash
ls ~/.config/opencode/hooks/
```
Erwartete Ausgabe: `format-on-save.sh  guard-bash.sh  phpstan-check.sh  tsc-check.sh`

- [ ] **Schritt 5: opencode config nach Install verifizieren**

```bash
opencode debug config 2>&1
```

Erwartete Ausgabe: Vollständiges JSON-Objekt. Felder `model`, `provider`, `permission`, `mcp`, `skills`, `instructions` müssen vorhanden sein. Kein `ConfigInvalidError`.

- [ ] **Schritt 6: Committen**

```bash
cd ~/Projekte/opencode-webdev
git add install.sh
git commit -m "feat: add install.sh"
```

---

### Task 8: README.md erstellen

**Files:**
- Create: `~/Projekte/opencode-webdev/README.md`

- [ ] **Schritt 1: README.md schreiben**

Datei `~/Projekte/opencode-webdev/README.md`:

```markdown
# opencode-webdev

opencode-Konfiguration für lokales LLM (Qwen3.6-35B via LiteLLM/vLLM).

## Voraussetzungen

- [opencode](https://opencode.ai) installiert (`brew install sst/tap/opencode`)
- `claude-webdev` installiert (für Shell-Hooks unter `~/.claude/hooks/`)
- LiteLLM-Zugang mit `LITELLM_BASE_URL` und `LITELLM_API_KEY`

## Setup

**1. Env-Variablen setzen** (in `~/.zshrc` oder `~/.bashrc`):

```bash
export LITELLM_BASE_URL="https://litellm.your-host.com/v1"
export LITELLM_API_KEY="sk-xxx"
```

**2. Installieren:**

```bash
cd ~/Projekte/opencode-webdev
./install.sh
source ~/.zshrc
```

**3. opencode starten:**

```bash
opencode
```

## Was installiert wird

| Ziel | Inhalt |
|---|---|
| `~/.config/opencode/opencode.json` | Provider-Config (LiteLLM), Permissions, MCP-Server, Skills |
| `~/.config/opencode/AGENTS.md` | Haupt-Kontext (Always Start Here) |
| `~/.config/opencode/rules/` | 19 Coding-Regeln |
| `~/.config/opencode/skills/` | 18 Domain-Skills + 24 wondelai-Knowledge-Skills |
| `~/.config/opencode/hooks/` | Shell-Hooks (von `~/.claude/hooks/` kopiert) |
| `~/.config/opencode/plugins/hooks.ts` | Hook-Plugin (format-on-save, guard-bash, phpstan, tsc) |

## Per-Projekt-Skills

Projekt-spezifische Skills in `.opencode/skills/<name>/SKILL.md` ablegen,
dann im Projekt-`opencode.json` ergänzen:

```json
{
  "skills": {
    "paths": [".opencode/skills"]
  }
}
```

## Troubleshooting

```bash
opencode debug config   # Config validieren
opencode debug skill    # Geladene Skills auflisten
opencode debug paths    # Installationspfade anzeigen
```
```

- [ ] **Schritt 2: Committen**

```bash
cd ~/Projekte/opencode-webdev
git add README.md
git commit -m "docs: add README"
```

---

### Task 9: Integrationstest

Verifiziert, dass alles zusammenspielt — Config valide, alle Skills geladen, Hooks vorhanden.

- [ ] **Schritt 1: opencode debug config — vollständige Ausgabe prüfen**

```bash
opencode debug config 2>&1
```

Prüfen:
- `"model"` ist `"openai/mai-coding-default"` ✓
- `"permission"` enthält `"bash"` mit mind. 5 deny-Einträgen ✓
- `"mcp"` enthält `"context7"`, `"playwright-chromium"`, `"playwright-firefox"`, `"mysql"`, `"github"` ✓
- `"skills"` enthält `"paths"` ✓
- `"instructions"` ist Array mit 20 Einträgen ✓
- Kein `ConfigInvalidError` ✓

- [ ] **Schritt 2: Skills-Anzahl verifizieren**

```bash
opencode debug skill 2>&1 | grep -c '"name"'
```

Erwartete Ausgabe: `42` oder höher (inkl. Built-in-Skills wie `customize-opencode`).

- [ ] **Schritt 3: Hooks-Dateien vorhanden**

```bash
ls -la ~/.config/opencode/hooks/
```

Erwartete Ausgabe: Vier `.sh`-Dateien, alle ausführbar (`-rwxr-xr-x`).

- [ ] **Schritt 4: Plugin-Datei vorhanden**

```bash
ls ~/.config/opencode/plugins/hooks.ts
```

Erwartete Ausgabe: Datei existiert ohne Fehler.

- [ ] **Schritt 5: Abschluss-Tag setzen**

```bash
cd ~/Projekte/opencode-webdev
git tag v1.0.0
```