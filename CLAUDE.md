# Global CLAUDE.md — Engineering Baseline

Project-local files **always override this baseline**:
`CLAUDE.md` · `AGENTS.md` · `README*` · `docs/` · `code-conventions.md` · `.editorconfig`

---

## 0) Always Start Here

1. Read all project-local rules **before touching code**.
2. Read the project's `README`, `package.json` scripts, `composer.json` scripts, or `Makefile` before running any build/test command. Never guess commands.
3. Follow existing patterns unless they violate this baseline or a refactor is explicitly requested.
4. Keep diffs small, focused, and easy to review.
5. Do not introduce new dependencies or tools unless required or explicitly requested.
6. For large projects, keep root `CLAUDE.md` lean. Move detailed domain knowledge into separate files (e.g. `agent_docs/`, `.claude/skills/`) and reference them from the root file.

---

@rules/01-coding-standard.md
@rules/02-security.md
@rules/03-type-system.md
@rules/04-clean-code.md
@rules/05-complexity.md
@rules/06-maintainability.md
@rules/07-js-ts-tooling.md
@rules/08-vue-svelte.md
@rules/09-testing.md
@rules/10-environment.md
@rules/11-boundaries.md
@rules/12-performance.md
@rules/13-database.md
@rules/14-dependencies.md
@rules/15-observability.md
@rules/16-accessibility.md
@rules/17-i18n.md
@rules/18-git-workflow.md