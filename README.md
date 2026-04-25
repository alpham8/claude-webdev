# Claude Code — Web Development Setup

A ready-to-use collection of skills, rules, hooks, and settings for Claude Code, optimised for PHP / Symfony / Shopware / JavaScript / TypeScript development on Linux.

## Why This Exists

AI models are trained on the internet. The internet contains plenty of low-quality, insecure, and outdated code. To get consistently better output from AI coding assistants, you need to guide them with tools and instructions.

I quickly discovered that a single `CLAUDE.md` file is not the right approach for implementing all my rules and techniques. The ecosystem already has many excellent skills, plugins, and hooks — but they are scattered across dozens of repositories, marketplaces, and blog posts. Finding, evaluating, and combining them takes hours.

**This is a curated, ready-to-use collection with a one-command installer.**

### Top Features

- **Frontend Design Skills** — Animation engineering (timing, easing, springs), UI audit & redesign workflow (anti-AI-slop patterns), typography, colour systems, micro-interactions
- **Shopware 5 & 6 Skills** — Plugin architecture, DAL, events, Admin components, Storefront JS, DDEV setup, dustin/shopware-utils
- **Symfony Skills** — Full framework coverage + project scaffolding blueprint (Vite, DDEV, i18n, CAPTCHA, deploy)
- **PHP Skills** — Modern PHP 8.0–8.4, strict typing, security (OWASP Top 10), PSR standards
- **ECMAScript Skills** — TypeScript type system, Vue 2/3, Svelte 5, async patterns, decorators
- **Content Testing** — Deep assertion skill ensuring tests verify actual content, not just status codes. 4-level depth pyramid, checklists for pages, APIs, feeds, forms, SEO, i18n
- **Accessibility** — WCAG 2.1 AA checklist, keyboard navigation, ARIA, form accessibility
- **18 Coding Rules** — PSR-12 baseline, security, type safety, clean code, performance, testing, git workflow
- **4 Safety Hooks** — Format-on-save, static analysis, type checking, destructive command guard

## What's Included

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Global engineering baseline (coding standards, workflow rules) |
| `rules/` | 18 rule files referenced from CLAUDE.md |
| `hooks/` | 4 PostToolUse / PreToolUse hook scripts |
| `skills/` | Domain-specific reference skills for Claude |
| `settings.json` | Claude Code settings (plugins, MCP servers, hooks, permissions) |
| `install.sh` | One-shot installer into `~/.claude` |

### Hooks

| Script | Trigger | Effect |
|---|---|---|
| `guard-bash.sh` | Before every Bash command | Blocks destructive patterns (`rm -rf /`, `dd of=/dev/…`, force-push to main, etc.) |
| `format-on-save.sh` | After Write / Edit | Runs PHP-CS-Fixer (PHP) or Prettier (TS/JS/Vue/CSS) if available in project |
| `phpstan-check.sh` | After Write / Edit on `*.php` | Runs PHPStan if `vendor/bin/phpstan` exists (non-blocking warning) |
| `tsc-check.sh` | After Write / Edit on `*.ts` / `*.tsx` | Runs TypeScript type-check if `tsconfig.json` exists (non-blocking warning) |

### Skills

| Skill | Description |
|---|---|
| `php` | Modern PHP 8.0-8.4, strict typing, enums, readonly, OOP, PSR standards, security (LFI/RFI, SQL injection, XSS, CSRF, sessions, passwords, uploads, OWASP Top 10) |
| `symfony` | Symfony framework components: DI, events, routing, forms, serializer, validator, messenger, mailer, security, cache, console, Twig, Doctrine, real-world patterns |
| `symfony-project-setup` | Project scaffolding blueprint: directory structure, bundles, services, Vite/pentatrion, DDEV, PHPUnit, i18n, Altcha CAPTCHA, deploy scripts |
| `shopware` | Shopware 5 & 6 architecture, DAL, events, templates, CMS elements, version compatibility, Composable Frontends (headless) |
| `shopware-ddev` | Shopware-specific DDEV setup (Elasticsearch, Redis, Varnish, Mailpit) |
| `shopware-utils` | dustin/shopware-utils library (sub-bundles, auto-resources, configuration objects) |
| `vue` | Vue 2 Options API + Vue 3 Composition API, script setup, reactivity, props/emits, slots, Pinia, TypeScript integration, Shopware Admin patterns |
| `svelte` | Svelte 5 runes ($state, $derived, $effect, $props), TypeScript, mounting in Symfony/Twig apps, lifecycle, transitions, real-world patterns |
| `typescript` | Type system, generics, utility types, type guards, discriminated unions, decorators (TC39 + legacy), tsconfig, DOM typing, async patterns |
| `csharp` | Modern C# 12/13, records, pattern matching, nullable refs, LINQ, async/await, sealed classes, primary constructors |
| `aspnet-core` | ASP.NET Core 9 Minimal APIs, DI, middleware, EF Core, SignalR, JWT auth, caching, MassTransit, rate limiting, Docker |
| `ddev-development` | DDEV commands, config reference, PHP/Node/DB version switching, port exposure |
| `ui-animation-engineering` | Production-grade animation decisions: timing tables, easing rules, spring vs duration, transform-origin, interruptibility, stagger patterns, Sonner principles (based on Emil Kowalski) |
| `ui-audit-redesign` | Systematic UI audit & upgrade workflow: Scan/Diagnose/Fix, anti-AI-slop patterns, typography/colour/layout/states audit, fix priority order, pre-output checklist (based on Taste Skill & Impeccable) |
| `content-testing` | Deep assertion skill for tests: 4-level assertion depth pyramid (response → structure → content → semantics), checklists for web pages, APIs, RSS/XML, forms, SEO, multilingual, pagination. Prevents status-code-only tests. |
| `wondelai/clean-code` | Clean Code principles (Martin) |
| `wondelai/clean-architecture` | Clean Architecture (Martin) |
| `wondelai/domain-driven-design` | DDD building blocks, bounded contexts |
| `wondelai/refactoring-patterns` | Refactoring catalog (Fowler) |
| `wondelai/software-design-philosophy` | Philosophy of Software Design (Ousterhout) |
| `wondelai/pragmatic-programmer` | Pragmatic Programmer principles |
| `wondelai/release-it` | Production-readiness, stability patterns |
| `wondelai/high-perf-browser` | Browser performance, Core Web Vitals |
| `wondelai/system-design` | System design fundamentals |
| `wondelai/ddia-systems` | Designing Data-Intensive Applications |
| `wondelai/refactoring-ui` | Visual hierarchy, spacing systems, colour palettes (Wathan & Schoger) |
| `wondelai/ux-heuristics` | Usability evaluation: Krug's laws + Nielsen's 10 heuristics |
| `wondelai/web-typography` | Typeface selection, pairing, responsive typography (Santa Maria) |
| `wondelai/design-everyday-things` | Affordances, signifiers, constraints, feedback, conceptual models (Norman) |
| `wondelai/microinteractions` | Triggers, rules, feedback, loops for interaction polish (Saffer) |
| `wondelai/top-design` | Award-winning web design: typography, motion, scroll, composition |
| `wondelai/gestalt-ui` | 13 Gestalt principles applied to UI design (custom) |
| `wondelai/laws-of-ux` | Behavioural UX laws: Fitts, Hick, Miller, Jakob, Doherty, etc. (custom) |
| `wondelai/ui-patterns` | Scanning patterns, component patterns, UI decision reference (custom) |
| `wondelai/ux-design-principles` | Combined UX design theory: hierarchy, scanning, forms, buttons (custom) |
| `wondelai/html-accessibility` | Accessible HTML: labels, ARIA, keyboard nav, WCAG checklist (custom) |
| `wondelai/cro-methodology` | Conversion rate optimisation (Blanks & Jesson) |
| `wondelai/improve-retention` | Behaviour design for retention using B=MAP (Fogg) |
| `wondelai/hooked-ux` | Habit-forming product design: Hook Model (Eyal) |

### MCP Servers

| Server | Package | Purpose |
|---|---|---|
| `context7` | `@upstash/context7-mcp` | Up-to-date library documentation |
| `playwright-chromium` | `@playwright/mcp` | Browser automation (Chromium) |
| `playwright-firefox` | `@playwright/mcp` | Browser automation (Firefox) |
| `mysql` | `@benborla29/mcp-server-mysql` | MySQL / MariaDB queries (read-only by default) |
| `github` | `@modelcontextprotocol/server-github` | GitHub API (issues, PRs, repos) |

#### Optional: Jira MCP Server

To enable Claude to read and create Jira issues, add this block to the `mcpServers` section of your `~/.claude/settings.json`:

```json
"jira": {
    "command": "npx",
    "args": ["-y", "mcp-atlassian"],
    "env": {
        "JIRA_URL": "https://your-org.atlassian.net",
        "JIRA_USERNAME": "your@email.com",
        "JIRA_API_TOKEN": "your-api-token"
    }
}
```

Generate an API token at: Atlassian Account → Security → API tokens

---

## System Requirements

Works on **Linux** (Ubuntu, openSUSE, Fedora, etc.) and **macOS**. Homebrew is used as the universal package manager across both platforms.

### 1 — Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the post-install instructions to add Homebrew to your PATH:

**macOS** (Apple Silicon):
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

**macOS** (Intel):
```bash
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

**Linux** (Ubuntu, Debian, Fedora, openSUSE, etc.):
```bash
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
source ~/.bashrc
```

### 2 — Install Claude Code

```bash
brew install claude-code
```

### 3 — Install System Dependencies

#### Required

**Ubuntu / Debian:**
```bash
sudo apt-get install -y jq nodejs npm
```

**openSUSE:**
```bash
sudo zypper install -y jq nodejs20 npm20
```

**Fedora:**
```bash
sudo dnf install -y jq nodejs npm
```

**macOS:**
```bash
brew install jq node
```

> **Note:** Node.js 20+ is required for MCP servers (npx) and JS/TS projects. If your distro ships an older version, install via [NodeSource](https://github.com/nodesource/distributions) or [nvm](https://github.com/nvm-sh/nvm).

#### Optional (per-project, installed inside DDEV containers)

The hook scripts auto-detect formatters and linters from the project's `vendor/` and `node_modules/` directories. No global installation is needed:

- **PHP-CS-Fixer** — `composer require --dev friendsofphp/php-cs-fixer`
- **PHPStan** — `composer require --dev phpstan/phpstan`
- **Prettier** — `npm install --save-dev prettier`
- **TypeScript** — `npm install --save-dev typescript`

### 4 — Install DDEV (recommended for PHP projects)

**Linux:**
```bash
# Install Docker first if not present
# Ubuntu/Debian:
sudo apt-get install -y docker.io
# openSUSE:
sudo zypper install -y docker
# Fedora:
sudo dnf install -y docker

sudo usermod -aG docker $USER
newgrp docker
```

**macOS:**
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop/
# Or use Colima as a lightweight alternative:
brew install colima docker
colima start
```

**Then install DDEV (all platforms):**
```bash
brew install ddev/ddev/ddev
```

Or follow the official guide: https://ddev.readthedocs.io/en/stable/users/install/ddev-installation/

### 5 — Install tmux (for Claude Code teammate mode)

**Ubuntu / Debian:**
```bash
sudo apt-get install -y tmux
```

**openSUSE:**
```bash
sudo zypper install -y tmux
```

**Fedora:**
```bash
sudo dnf install -y tmux
```

**macOS:**
```bash
brew install tmux
```

### 6 — Install claude-mem Dependencies (optional)

The [claude-mem](https://github.com/thedotmack/claude-mem) plugin requires **bun** (JavaScript runtime) and **uv** (Python package manager by Astral).

#### bun

Install via Homebrew / Linuxbrew (all platforms):
```bash
brew install bun
```

#### uv (Python package manager)

**Ubuntu / Debian** (via Astral's standalone installer):
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

> Ubuntu does not ship uv in its apt repos. The Astral installer is the officially recommended method. Alternatively: `sudo snap install astral-uv --classic`

**openSUSE Tumbleweed** (in the official repos):
```bash
sudo zypper install -y uv
```

**openSUSE Leap** (via devel:languages:python OBS repo):
```bash
sudo zypper addrepo https://download.opensuse.org/repositories/devel:/languages:/python/openSUSE_Leap_15.6/devel:languages:python.repo
sudo zypper refresh
sudo zypper install -y uv
```

**Fedora:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**macOS:**
```bash
brew install uv
```

---

## Installation

```bash
git clone https://github.com/alpham8/claude-webdev.git
cd claude-webdev
chmod +x install.sh
./install.sh
```

The installer copies all configuration into `~/.claude`. If `~/.claude/settings.json` already exists, it will **not** be overwritten — merge manually.

---

## Post-Install Configuration

### GitHub MCP Server

The GitHub MCP server needs a personal access token:

1. Create a token at: GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Required scopes: `Contents` (read), `Issues` (read/write), `Pull requests` (read/write), `Metadata` (read)
3. Export the token in your shell profile:

```bash
# Linux (bash):
echo 'export GITHUB_TOKEN=ghp_yourtoken' >> ~/.bashrc
source ~/.bashrc

# macOS (zsh):
echo 'export GITHUB_TOKEN=ghp_yourtoken' >> ~/.zprofile
source ~/.zprofile
```

### Jira MCP Server (optional)

See the [Optional: Jira MCP Server](#optional-jira-mcp-server) section under MCP Servers above for setup instructions.

### MySQL MCP Server

The MySQL MCP is pre-configured for DDEV's default credentials (`user: db`, `pass: db`, `host: 127.0.0.1`, `port: 3306`). DDEV maps the database port dynamically — check with `ddev describe` and adjust `MYSQL_PORT` in `settings.json` if needed.

Write operations are **disabled by default**. To enable, set `ALLOW_INSERT_OPERATION`, `ALLOW_UPDATE_OPERATION`, or `ALLOW_DELETE_OPERATION` to `"true"` in `settings.json`.

### Claude Code Plugins

The following plugins are pre-configured in `settings.json` and will be auto-installed by Claude Code on first launch:

- `superpowers` — skill system and agent tooling
- `ask-questions-if-underspecified` — clarifying question prompts
- `skill-improver` — skill quality feedback
- `claude-md-management` — CLAUDE.md file management
- `security-guidance` — security best practices
- `context7` — live library documentation
- `context-mode` — context window management
- `playwright` — Playwright browser automation
- `claude-mem` — persistent cross-session memory with tree-sitter code exploration

### Agent Browser (optional, for AI-driven browser automation)

[agent-browser](https://github.com/vercel-labs/agent-browser) is a native Rust CLI for browser automation via CDP (Chrome DevTools Protocol). It provides accessibility-tree snapshots and compact element references -- useful for testing, scraping, and interacting with web apps from Claude Code.

```bash
# Install the CLI globally
npm i -g agent-browser && agent-browser install

# Or install as a Claude Code skill only
npx skills add https://github.com/vercel-labs/agent-browser --skill agent-browser
```

After installation, load the documentation matching your installed version:

```bash
# Core workflows, patterns, troubleshooting
agent-browser skills get core

# Complete command reference
agent-browser skills get core --full
```

**Key capabilities:**
- Three browser modes: headless Chromium, real Chrome with profiles, cloud-hosted remote
- 15+ command categories: navigation, inspection, interactions, data extraction, cookies, JavaScript
- Session management, authentication vault, state persistence, video recording
- No Playwright/Puppeteer dependency (native Rust binary)

**Specialised skill modules:**

```bash
agent-browser skills get electron    # Desktop apps (Electron)
agent-browser skills get slack       # Slack automation
agent-browser skills get dogfood     # QA testing workflows
```

### claude-mem (persistent memory)

[claude-mem](https://github.com/thedotmack/claude-mem) provides cross-session memory so Claude remembers context between conversations. It runs a lightweight worker service that captures observations during sessions and stores them in a local SQLite database.

**Key capabilities:**
- Automatic session observation (PostToolUse hook captures what you work on)
- Cross-session memory search (`/claude-mem:mem-search`)
- Tree-sitter-powered code exploration (`/claude-mem:smart-explore`) — AST-level structural search without reading full files
- Implementation plan creation and execution (`/claude-mem:make-plan`, `/claude-mem:do`)
- Knowledge agent for building topic-specific "brains" from observation history
- Timeline reports showing project development history
- Plugin version bump automation

**Installation** is handled automatically via `settings.json`. The plugin's hooks start the worker service on session start and capture observations transparently.

**Skills provided:**

| Skill | Description |
|---|---|
| `claude-mem:mem-search` | Search persistent memory database for past work |
| `claude-mem:smart-explore` | Token-optimized AST-based code search |
| `claude-mem:make-plan` | Create phased implementation plans with doc discovery |
| `claude-mem:do` | Execute plans using subagents |
| `claude-mem:knowledge-agent` | Build and query knowledge bases from observations |
| `claude-mem:timeline-report` | Generate narrative project history reports |
| `claude-mem:version-bump` | Automated semantic versioning and release workflow |

---

## Updating

To pull the latest configuration from this repo and reinstall:

```bash
git pull
./install.sh
```

Existing `settings.json` will not be overwritten. Delete `~/.claude/settings.json` first if you want a fresh install.
