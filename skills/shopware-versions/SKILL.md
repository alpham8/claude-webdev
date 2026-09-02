---
name: shopware-versions
description: Use when checking Shopware 6 version compatibility or planning an upgrade — the PHP, Node, MySQL and admin build matrix, breaking changes from 6.4 through 6.7, and the Vue 2 to Vue 3 administration migration. Triggers on version compatibility questions, upgrade planning, "which Shopware version supports", or porting admin components from Vue 2 to Vue 3.
---

# Shopware 6 — Versions, Compatibility and Troubleshooting

See the `shopware` skill for the map of Shopware skills.

## Shopware 6 Version Compatibility Matrix

### Node.js & npm

| SW Version | Min. Node.js | npm |
|------------|-------------|-----|
| 6.4.x | ≥ 12.21.0 | ^8.0.0 |
| 6.5.x | **≥ 18** | ^8.0.0 \|\| ^9.0.0 |
| 6.6.x | **≥ 20** | ≥ 10.0.0 |
| 6.7.x | ≥ 20 | ≥ 10.0.0 |

**Breaking jumps:** 6.4→6.5 requires Node 16→18. 6.5→6.6 requires 18→20.

### PHP

| SW Version | PHP Versions |
|------------|-------------|
| 6.4.x | ^7.4.3 \|\| ^8.0 |
| 6.5.x | ~8.1 \|\| ~8.2 \|\| ~8.3 |
| 6.6.x | **min. 8.2** (~8.2 \|\| ~8.3) |
| 6.7.x | ~8.2 \|\| ~8.4 |

### MySQL & MariaDB

| SW Version | MySQL | MariaDB |
|------------|-------|---------|
| 6.4.x | 5.7+ or 8.0 | 10.3+ |
| 6.5.x | 8.0 | 10.4–11.0 (tested) |
| 6.6.x | **min. 8.0** | **min. 10.11** (requires `JSON_OVERLAPS`) |
| 6.7.x | 8.0+ | 11.x |

### Admin Build System

| SW Version | Vue | Build Tool | Bootstrap |
|------------|-----|-----------|-----------|
| 6.4 / 6.5 | Vue 2 | Webpack 4 | 4.x |
| 6.6.x | **Vue 3** | **Webpack 5** | 5.x |
| 6.7.x | Vue 3 | **Vite** | 5.3.3 |

> **Pitfall:** `bin/build-administration.sh` was removed in SW 6.6+. Correct approach: `bin/console bundle:dump` then `cd src/Administration/Resources/app/administration && PROJECT_ROOT=/var/www/html npm run build`.

> **6.7 Admin build:** Vite replaces Webpack. Custom webpack configs must be migrated.

---

## Breaking Changes by Version (Plugin Developer Impact)

### 6.4.0.0
- PHP minimum raised to **7.4** (`sodium` extension now required)
- Route annotations deprecated (`@Captcha`, `@RouteScope`, etc.) → use Symfony Route `defaults`
- `AbstractMessageHandler` deprecated → implement `MessageSubscriberInterface`

### 6.5.0.0
- `AbstractMessageHandler` **removed**
- **Bootstrap 5 upgrade**: data attributes renamed (`data-toggle` → `data-bs-toggle`), JS plugins refactored, CSS classes changed. Twig blocks preserved.
- Auto-loaded DAL associations **removed** — must explicitly add via `$criteria->addAssociation()`:
  - `order.stateMachineState`, `order_transaction.stateMachineState`, `order_delivery.stateMachineState`
  - `order_delivery.shippingOrderAddress`, `tax_rule.type`, `import_export_log.file`

### 6.6.0.0
- **Symfony 7 upgrade** — breaks code relying on removed Symfony 6 APIs
- **PHPUnit 10+**
- **PHP 8.1 dropped** — minimum is now 8.2
- **MySQL 5.7 dropped** — minimum is now MySQL 8.0 / MariaDB 10.11
- **Vue 3 upgrade** — `v-model` → `v-model:value` on custom components; `vue-meta` removed; event names renamed
- **Webpack 5** — plugins with custom webpack config must migrate to Webpack 5 API
- `ScheduledTaskHandler::getHandledMessages()` removed → use `#[AsMessageHandler]` attribute
- `EntityExtension::getDefinitionClass()` deprecated → use `getEntityName()`
- HTTP Cache classes marked `@internal` — decorate via events instead
- Session access in tests: use `session.factory` service

### 6.7.0.0
- **Vite replaces Webpack** for admin build
- **Vuex fully replaced by Pinia** across all core stores
- **All PHP class properties now have native types** — subclasses must match
- **Payment handlers consolidated** into single `AbstractPaymentHandler`; old interfaces deprecated
- `technicalName` required (non-nullable) for payment/shipping methods
- `AccountService::login()` removed → use `loginByCredentials()` / `loginById()`
- `SystemConfigService::trace()` / `getTrace()` deprecated (no-op)
- `SystemConfig` exception classes deprecated → use factory methods on `SystemConfigException`
- **Axios 1.x migration** in admin (`CancelToken` → `AbortController`); default still 0.x in 6.7, becomes 1.x in 6.8
- Twig `spaceless` filter removed

### Vue 2 → Vue 3 (6.5 → 6.6)

| Aspect | Vue 2 (≤ 6.5) | Vue 3 (≥ 6.6) |
|--------|--------------|--------------|
| `v-model` on custom component | `v-model="val"` | `v-model:value="val"` |
| Template event name | `@change` | renamed to specific event |
| `vue-meta` | supported | removed (only `title` via own impl) |

For plugins supporting both version ranges: maintain two separate admin templates.
