---
name: shopware5
description: Use when working on Shopware 5 — Enlight architecture, SW 5.2+ plugin structure, the Enlight event and hook system, Smarty templates, and the key differences from Shopware 6. Triggers on Enlight, Smarty, SW5 hooks, ExtJS backend, or migration questions between SW5 and SW6.
---

# Shopware 5

See the `shopware` skill for the map of Shopware skills.

## Shopware 5

### Architecture

Built on **Enlight** (custom MVC framework) + Symfony DIC + Zend components. Backend uses ExtJS.

| Layer | Technology |
|-------|-----------|
| Frontend | Smarty templates (`.tpl`) |
| Backend | ExtJS 4 |
| Framework | Enlight (MVC + event bus) |
| DI | Symfony DIC via `services.xml` |

### Plugin Structure (SW 5.2+)

```
SwagExample/
├── Resources/
│   ├── services.xml
│   ├── config.xml
│   └── views/frontend/
├── Subscriber/
├── Components/
├── plugin.xml
└── SwagExample.php
```

**Plugin class** (extends `Shopware\Components\Plugin`):
```php
class SwagExample extends Plugin
{
    public function install(InstallContext $context): void
    {
        $context->scheduleClearCache(InstallContext::CACHE_LIST_ALL);
    }

    public function uninstall(UninstallContext $context): void
    {
        if ($context->keepUserData()) { return; }
        // drop custom tables/attributes here
    }
}
```

### Enlight Event System

```php
public static function getSubscribedEvents(): array
{
    return [
        'Enlight_Controller_Action_PostDispatchSecure_Frontend_Detail' => 'onProductDetail',
        'Enlight_Controller_Action_PreDispatch_Frontend'               => 'onFrontendPreDispatch',
        'Shopware_Modules_Basket_AddArticle_Start'                     => 'onAddToCart',
    ];
}

public function onProductDetail(\Enlight_Event_EventArgs $args): void
{
    $view = $args->getSubject()->View();
    $view->assign('myVariable', 'value');
}
```

### Hook System (SW5)

Hooks intercept specific class methods. Use when no event exists.

```php
// services.xml: tag="shopware.hook"
class ArticleListHook extends \Enlight_Hook_HookHandler
{
    public function afterGetArticleById(\Enlight_Hook_HookArgs $args): void
    {
        $return = $args->getReturn();
        // modify $return
        $args->setReturn($return);
    }
}
```

Hook types: `before`, `after`, `replace` (`replace` calls `executeParent()` to chain).

### Smarty Templates (SW5)

```smarty
{* Resources/views/frontend/detail/index.tpl *}
{extends file="parent:frontend/detail/index.tpl"}

{block name="frontend_detail_index_detail_inner"}
    <div class="custom-badge">Sale!</div>
    {$smarty.block.parent}
{/block}
```

---

## SW5 vs SW6 — Key Differences

| Aspect | Shopware 5 | Shopware 6 |
|--------|-----------|-----------|
| Framework | Enlight + Symfony DIC | Full Symfony |
| Templates | Smarty (`.tpl`) | Twig (`.html.twig`) |
| Backend | ExtJS 4 | Vue.js (Meteor) |
| Data layer | Doctrine ORM + direct SQL | DAL (no raw Doctrine) |
| Events | Enlight string-based | PHP class-based |
| Plugin entry | `Plugin.php` + `plugin.xml` | `Plugin.php` + `composer.json` |
| Hooks | Yes (Enlight Hook) | No — use DAL events or decoration |
| Context | `Shopware()->Shop()` | `Context` / `SalesChannelContext` |
| Assets | LESS + Grunt | SCSS + Webpack/Vite |
| API | REST (`/api/v1/`) | Store API + Admin API (JSON:API) |

---

### Common SW5 Problems

| Symptom | Cause | Fix |
|---------|-------|-----|
| Template override ignored | Cache not cleared or wrong file path | `bin/console sw:cache:clear`, verify path mirrors core |
| Event not firing | Wrong event name | Use `Enlight_Controller_Action_PostDispatchSecure_Frontend_<ControllerName>` |
| Plugin not appearing | Class name doesn't match directory | Both must be identical: `SwagExample/SwagExample.php` |
| Hook not called | `shopware.hook` tag missing | Add `<tag name="shopware.hook"/>` |

---

