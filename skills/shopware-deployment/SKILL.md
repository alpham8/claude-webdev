---
name: shopware-deployment
description: Use when deciding where Shopware plugin code lives and how it is installed — custom/static-plugins as a Composer path repository, the Shopware Store as a Composer repository, and partner wildcard test environments. Triggers on composer path repositories, store.shopware.com requires, or project plugin layout questions.
---

# Shopware 6 — Plugin Deployment Patterns

See the `shopware` skill for the map of Shopware skills.

### Plugin Deployment Patterns

**`custom/static-plugins/` for project-specific code:**

For larger Shopware projects, client-specific plugins and themes that are not published to the Shopware Store are placed in `custom/static-plugins/` instead of `custom/plugins/`. This directory is symlinked into `vendor/` via Composer's `path` repository type:

```json
{
    "repositories": [
        { "type": "path", "url": "custom/static-plugins/MyPlugin" }
    ],
    "require": {
        "vendor/my-plugin": "*"
    }
}
```

Composer creates a symlink `vendor/vendor/my-plugin → ../../custom/static-plugins/MyPlugin/`. This ensures the plugin is autoloaded via Composer's classloader and follows the same dependency resolution as Store plugins, while keeping project-specific code clearly separated and version-controlled in the project repository.

**Shopware Store as Composer repository:**

The Shopware Plugin Store can be added as a Composer repository to install Store plugins via `composer require` instead of manual upload:

```json
{
    "repositories": [
        {
            "type": "composer",
            "url": "https://packages.shopware.com"
        }
    ]
}
```

Store plugins are then installed with: `composer require store.shopware.com/pluginname`.

**Shopware Partner wildcard environments:**

Shopware Partners can set up wildcard test environments. These allow testing any Store plugin before purchasing, so agencies can evaluate plugins for clients without incurring costs upfront. The wildcard license covers all plugins on the test domain.

**Plugin base class** (`src/SwagExample.php`):

```php
namespace Swag\Example;

use Doctrine\DBAL\Connection;
use Shopware\Core\Framework\Plugin;
use Shopware\Core\Framework\Plugin\Context\UninstallContext;

class SwagExample extends Plugin
{
    public function uninstall(UninstallContext $context): void
    {
        parent::uninstall($context);

        if ($context->keepUserData()) {
            return;
        }

        /** @var Connection $connection */
        $connection = $this->container->get(Connection::class);

        // Check existence before dropping (idempotency)
        $columns = $connection->fetchAllAssociative(
            'SHOW COLUMNS FROM `my_table` LIKE :col',
            ['col' => 'my_column']
        );

        if (count($columns) === 0) {
            return;
        }

        $connection->executeStatement(
            'ALTER TABLE `my_table` DROP FOREIGN KEY `fk.my_table.my_column`, DROP COLUMN `my_column`'
        );
    }
}
```

> Always check `keepUserData()` before touching the database in `uninstall()`. Drop FK constraints before columns.

**`composer.json`** (complete recommended structure):

```json
{
    "name": "vendor/plugin-name",
    "description": "Short description.",
    "version": "1.0.0",
    "type": "shopware-platform-plugin",
    "license": "MIT",
    "authors": [
        { "name": "Developer Name", "email": "dev@example.com", "role": "Developer" },
        { "name": "Company GmbH", "email": "info@example.com", "homepage": "https://example.com/", "role": "Manufacturer" }
    ],
    "require": {
        "shopware/core": ">=6.6.0 <6.8.0",
        "shopware/administration": ">=6.6.0 <6.8.0"
    },
    "extra": {
        "shopware-plugin-class": "Vendor\\PluginName\\PluginName",
        "manufacturerLink": { "de-DE": "https://example.com/", "en-GB": "https://example.com/" },
        "supportLink":      { "de-DE": "https://example.com/kontakt/", "en-GB": "https://example.com/contact/" },
        "label":       { "de-DE": "Plugin Name DE", "en-GB": "Plugin Name EN" },
        "description": { "de-DE": "Beschreibung DE", "en-GB": "Description EN" }
    },
    "autoload": {
        "psr-4": { "Vendor\\PluginName\\": "src/" }
    }
}
```

> **Critical:** `manufacturerLink` and `supportLink` must be **locale-keyed objects**, not plain strings. `PluginService::getTranslations()` iterates all four extra keys with `foreach` — a plain string causes a fatal error on `plugin:refresh`.

> **Admin dependency:** Always require `shopware/administration` (same version range) for plugins that add or override admin components.

**Plugin icon:** Place a 128×128 PNG at `src/Resources/config/plugin.png`. Shopware stores it as a blob in `plugin.icon` on `plugin:refresh`.

Scaffold with: `bin/console plugin:create SwagExample`

---

