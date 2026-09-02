---
name: shopware
description: Use when working on Shopware 5 or Shopware 6 — entry point that explains the architecture, the plugin concept, and which focused Shopware skill covers a given task. Triggers on any Shopware plugin, theme, app or store question, on Shopware project setup, and on choosing between Shopware 5 and Shopware 6 approaches.
---

# Shopware Plugin Development

Entry point for Shopware work. This skill carries what applies to every Shopware
task; the detail lives in the focused skills listed below.

## Coding conventions come from `rules/`, not from this skill

The Shopware Core writes `<?php declare(strict_types=1);` on a single line. This
project does not: per PSR-12 and `rules/01-coding-standard.md`, `<?php` stands
alone, then a blank line, then `declare(strict_types=1);` on its own line. Where
a Shopware example conflicts with `rules/`, the rules win — they are binding,
skills are recommendations.

## Which skill for which task

| Task | Skill |
|------|-------|
| Entities, criteria, associations, custom fields | `shopware-dal` |
| Event subscribers, service registration and decoration, Store API routes, scheduled tasks, `config.xml` | `shopware-services` |
| Controllers, pages, Twig blocks, storefront JavaScript | `shopware-storefront` |
| Administration Vue components, modules, overrides | `shopware-administration` |
| Custom CMS elements and blocks (Erlebniswelten) | `shopware-cms-elements` |
| Where plugin code lives, Composer path repos, Store as repository | `shopware-deployment` |
| Version compatibility, breaking changes, upgrade planning, Vue 2 to Vue 3 admin migration | `shopware-versions` |
| Something does not take effect: Twig overrides, already-written JS plugins that don't run, cache, install and upgrade failures, gotchas | `shopware-troubleshooting` |
| Headless frontends | `shopware-composable-frontends` |
| Anything Shopware 5 | `shopware5` |
| DDEV commands for Shopware | `shopware-ddev` |
| `dustin/shopware-utils` library | `shopware-utils` |

## Related Skills

| Need | Skill |
|------|-------|
| **PHP** (types, security, PSR standards) | `php` |
| **Symfony framework** (DI, events, routing, forms, serializer, etc.) | `symfony` |
| **Vue.js** (Shopware 6 Administration is built on Vue) | `vue` |
| **TypeScript** (type system, generics, utility types) | `typescript` |
| DDEV config, PHP/Node/DB version changes, port setup | `ddev-development` |

> **Shopware 6 is built on Symfony.** All Symfony patterns (service container, event dispatcher, routing, console, forms, serializer, messenger, etc.) apply directly. See the `symfony` skill for the full Symfony reference.

---

## Overview

Shopware 5 (Enlight/Symfony 3, Smarty, ExtJS backend) and Shopware 6 (Symfony 4+, Twig, Vue.js admin) share the plugin concept but differ fundamentally in architecture. Both use a service-container-based DI and event-driven extension model.

---

## Shopware 6

### Architecture

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Core | Symfony | Business logic, DAL, APIs, rules |
| Storefront | Twig + SCSS + JS | Customer-facing shop |
| Administration | Vue.js (Meteor) | Merchant backend |

**Key objects:** `Context` (admin/background), `SalesChannelContext` (storefront, carries customer/currency/language state).

### Plugin vs. App

| Capability | Plugin | App |
|---|---|---|
| Modify database structure | Yes | No |
| Run in Cloud shops | No | Yes |
| Add custom logic/routes/commands | Yes | Partial (external only) |
| Full Storefront/Admin control | Yes | Yes |

Plugins are Symfony bundles with full system access. Apps are HTTP-API-based and run externally.

### Plugin Structure

```
custom/plugins/SwagExample/
├── src/
│   ├── SwagExample.php          # Plugin class
│   ├── Core/Content/Example/    # Custom entity domain
│   ├── Storefront/Controller/
│   ├── Subscriber/
│   └── Resources/
│       ├── config/
│       │   ├── services.xml     # (or services.php)
│       │   ├── config.xml       # Plugin config form
│       │   └── plugin.png       # 128×128 plugin icon
│       ├── views/storefront/    # Twig overrides
│       ├── app/
│       │   ├── storefront/src/  # JS plugins + SCSS
│       │   └── administration/  # Vue.js
│       └── snippet/
└── composer.json
```

