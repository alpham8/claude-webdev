---
name: shopware-storefront
description: Use when building the Shopware 6 storefront — custom controllers and pages, page loaders, Twig template blocks and overrides, and storefront JavaScript plugins. Triggers on StorefrontController, PageLoader, sw-extends, block overrides, or window.PluginManager.
---

# Shopware 6 — Storefront

PHP conventions come from `rules/`, not from this skill. Twig attribute formatting follows `rules/01`: all attributes on one line. See the `shopware` skill for the map of Shopware skills.

### Storefront — Custom Controller + Page

Full pattern: Controller + Page Loader + Page + PageLoadedEvent.

```php
// src/Storefront/Controller/ExampleController.php
use Shopware\Core\PlatformRequest;
use Shopware\Storefront\Framework\Routing\StorefrontRouteScope;
use Shopware\Storefront\Controller\StorefrontController;
use Symfony\Component\Routing\Attribute\Route;

#[Route(defaults: [PlatformRequest::ATTRIBUTE_ROUTE_SCOPE => [StorefrontRouteScope::ID]])]
class ExampleController extends StorefrontController
{
    public function __construct(private readonly ExamplePageLoader $pageLoader) {}

    #[Route(path: '/example', name: 'frontend.example.page', methods: ['GET'])]
    public function index(Request $request, SalesChannelContext $context): Response
    {
        $page = $this->pageLoader->load($request, $context);

        return $this->renderStorefront('@SwagExample/storefront/page/example/index.html.twig', [
            'page' => $page,
        ]);
    }
}
```

```php
// src/Storefront/Page/Example/ExamplePageLoader.php
class ExamplePageLoader
{
    public function __construct(
        private readonly GenericPageLoaderInterface $genericLoader,
        private readonly EventDispatcherInterface $eventDispatcher,
    ) {}

    public function load(Request $request, SalesChannelContext $context): ExamplePage
    {
        $page = ExamplePage::createFrom($this->genericLoader->load($request, $context));

        // Fetch data from Store API route, not repository directly
        $page->setExampleData(...);

        $this->eventDispatcher->dispatch(new ExamplePageLoadedEvent($page, $context, $request));

        return $page;
    }
}
```

> **Pattern:** Always use `GenericPageLoaderInterface` in page loaders — it loads navigation, header/footer, etc. Fire a `*PageLoadedEvent` so third parties can extend your page.

> **Route attributes:** Use PHP 8 `#[Route]` attributes (not annotations). Require both class-level `_routeScope` and method-level path/name attributes.

---


### Storefront Templates (Twig)

Override by mirroring the path under `Resources/views/storefront/`:

```twig
{# Resources/views/storefront/layout/header/logo.html.twig #}
{% sw_extends '@Storefront/storefront/layout/header/logo.html.twig' %}

{% block layout_header_logo_link %}
    <h2>Hello world!</h2>
    {{ parent() }}
{% endblock %}
```

- Use `{% sw_extends %}` (not plain `{% extends %}`).
- `{{ parent() }}` keeps original content.
- Find block names in `vendor/shopware/storefront/Resources/views/`.
- [FroshDevelopmentHelper](https://github.com/FriendsOfShopware/FroshDevelopmentHelper) overlays block names directly in the rendered HTML.

**Pass data to template** via a Subscriber on the matching `*PageLoadedEvent`:

```php
public function onProductPageLoaded(ProductPageLoadedEvent $event): void
{
    $event->getPage()->assign(['myData' => 'value']);
}
```

> **Attribute rule:** All attributes of an HTML/Twig element must stay on **one line** — Shopware's HTML minifier breaks on multi-line attributes.

---

### Storefront JavaScript Plugin

```javascript
// Resources/app/storefront/src/my-plugin/my-plugin.plugin.js
const { PluginBaseClass } = window;   // use window, not import from src/plugin-system

export default class MyPlugin extends PluginBaseClass
{
    init()   // required entrypoint — called after DOMContentLoaded
    {
        this.el.addEventListener('click', this._onClick.bind(this));
    }

    _onClick(event)
    {
        console.log('clicked', this.el);
    }
}
```

Register in `main.js`:

```javascript
// Synchronous (included in main bundle)
window.PluginManager.register('MyPlugin', MyPlugin, '[data-my-plugin]');

// Async (lazy — only loaded when selector matches on page)
window.PluginManager.register(
    'MyPlugin',
    () => import('./my-plugin/my-plugin.plugin'),
    '[data-my-plugin]'
);
```

`this.el` is the matched DOM element. `init()` is the entrypoint; never put init logic in the constructor.

Build assets: `bin/console theme:compile` / via DDEV see `shopware-ddev` skill.

---

