---
name: shopware-versions
description: Use when checking Shopware 6 version compatibility or diagnosing environment problems — the PHP, Node, MySQL and admin build matrix, breaking changes from 6.4 through 6.7, common gotchas, and known problems with their solutions. Triggers on version compatibility questions, upgrade planning, or unexplained build and cache failures.
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

---


## Common Gotchas

1. **SW6 DAL — never use raw SQL** for entity data. Use repositories. Direct DBAL only for reporting/aggregations.
2. **SW6 context** — always pass `Context` or `SalesChannelContext` down; never instantiate `Context::createDefaultContext()` in production code (bypasses ACL).
3. **SW5 cache** — call `$context->scheduleClearCache()` in install/update/activate or changes won't appear.
4. **SW6 Twig** — use `{% sw_extends %}` not `{% extends %}` for storefront templates.
5. **SW6 JS** — `PluginBaseClass` comes from `window`, not from an import path.
6. **Don't call `.first()` on aggregation results** — you need the `EntitySearchResult` object.
7. **Upsert requires an ID** — without an ID, every `upsert()` call creates a new record.
8. **ManyToMany updates** — update through the owning entity, not through the mapping repository.
9. **Custom entity tag** — `shopware.entity.definition` entity attribute must match `ENTITY_NAME` constant.
10. **CMS `initElementConfig()`** — must be called in both component AND config; skipping causes undefined config values.
11. **Store API abstract pattern** — always create Abstract → Concrete → optional Decorators; inject `AbstractXRoute` in consumers.
12. **ArrayStruct + Twig `.count`** — `ArrayStruct` implements `\Countable`. In Twig, `.count` resolves to the `count()` method (returns number of keys), not to a key named `count`. Use a different key name like `total` to avoid collision: `new ArrayStruct(['total' => $value])`.
13. **CMS slot `getData()` types** — `$slot->getData()` for a `category-navigation` CMS element returns a `Tree` object, not a generic `Struct`. Use `$data->getTree()` (returns `TreeItem[]`), not `$data->get('tree')`.
14. **Sidebar filter styles must scope to desktop** — Custom SCSS for `.is--sidebar` and `.cms-element-sidebar-filter .filter-panel-wrapper` must be wrapped in `@include media-breakpoint-up(lg)`. Without this, the mobile offcanvas filter panel breaks because `display: block` overrides the offcanvas hidden state.
15. **`.nav-main` is a sibling of `.header-main`** — The main navigation bar is outside the header element in the DOM. It can be made `position: sticky` independently without affecting the header (logo, search, cart).

---

## Common Problems & Solutions (SW6)

### Plugin / Service Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Plugin not visible in admin after upload | `plugin:refresh` not run | `bin/console plugin:refresh` |
| "Service X does not exist" | Service not registered or container not rebuilt | `bin/console cache:clear`, check `services.xml` |
| Entity definition not found | Missing service tag | Add `<tag name="shopware.entity.definition"/>` |
| Subscriber not firing | Missing `kernel.event_subscriber` tag | Add tag in `services.xml` |
| `foreach() argument must be of type array` on plugin:refresh | `manufacturerLink` / `supportLink` set as plain string | Use locale-keyed object: `{"de-DE": "...", "en-GB": "..."}` |
| Custom field not in admin | Plugin not updated after adding field | `bin/console plugin:update PluginName` |
| Migration not executed | Not run after install | `bin/console database:migrate --all` |

### Template / Frontend Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Twig override has no effect | Wrong path, or using `{% extends %}` instead of `{% sw_extends %}` | Mirror path from `vendor/shopware/storefront/Resources/views/`, use `{% sw_extends %}` |
| JS plugin not initialising | Selector not matching, or assets not rebuilt | Check `data-*` attribute; run `bin/console theme:compile` |
| Admin changes not visible | Admin assets not rebuilt | `bin/console bundle:dump` then `npm run build` (see `shopware-ddev` skill) |
| `{{ myData }}` undefined in template | Data not passed via PageLoadedEvent subscriber | Subscribe to correct `*PageLoadedEvent`, call `$event->getPage()->assign()` |

### Cache & Performance Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Stale data in storefront | HTTP cache not purged | `bin/console cache:pool:clear cache.http` |
| Config changes not active | Cache not cleared | `bin/console cache:clear` |
| Scheduled tasks not running | Messenger queue not consumed | `bin/console messenger:consume` (or configure a worker) |

### Installation / Upgrade Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `JSON_OVERLAPS` SQL error on SW 6.6 | MariaDB below 10.11 | Upgrade MariaDB to 10.11+ (snapshot first!) |
| `APP_SECRET` missing error | `.env` not set up | Copy `.env.dist` → `.env`; `bin/console system:generate-app-secret` |
| White page / 500 after update | Plugin incompatible with new SW version | Deactivate plugins one by one; check `var/log/` |
| Build fails: `paths[0] must be of type string` | `bundle:dump` not run before admin build | Run `bin/console bundle:dump` first |


## Frequently Used Dev Tools & Plugins (SW6)

| Tool | Purpose |
|------|---------|
| **FroshDevelopmentHelper** | Debug bar, Twig block name overlay, DAL query log |
| **FroshTools** | Admin UI for cache, queue, feature flags, log viewer |
| **Symfony Profiler** | HTTP request profiler (`/_profiler`), available in `APP_ENV=dev` |
| **SwagPlatformDemoData** | Demo products, categories, customers for fresh installs |

### `.env.local` for Development

```dotenv
APP_ENV=dev
APP_DEBUG=1
APP_SECRET=your-generated-secret
DATABASE_URL="mysql://root:root@db:3306/shopware"
SHOPWARE_HTTP_CACHE_ENABLED=0
SHOPWARE_HTTP_DEFAULT_TTL=0
```

### Useful `bin/console` Commands

```bash
bin/console debug:container | grep product          # Find services by keyword
bin/console debug:event-dispatcher | grep cart      # Find events by keyword
bin/console debug:router                             # All registered routes
bin/console feature:config                           # Show feature flags
bin/console system:config:get SwagExample.config.myKey
bin/console system:config:set SwagExample.config.myKey value
bin/console sales-channel:list
bin/console user:change-password admin
```

---

