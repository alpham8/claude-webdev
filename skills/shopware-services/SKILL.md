---
name: shopware-services
description: Use when wiring Shopware 6 backend services — event subscribers, Store API routes, the abstract-class service decoration pattern, scheduled tasks, and plugin configuration via config.xml. Triggers on EventSubscriberInterface, AbstractRoute, getDecorated, ScheduledTaskHandler, or plugin config forms.
---

# Shopware 6 — Services, Events and Configuration

PHP conventions come from `rules/`, not from this skill. See the `shopware` skill for the map of Shopware skills.

### Event System

```php
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Shopware\Core\Content\Product\ProductEvents;
use Shopware\Core\Framework\DataAbstractionLayer\Event\EntityLoadedEvent;

class MySubscriber implements EventSubscriberInterface
{
    public static function getSubscribedEvents(): array
    {
        return [
            ProductEvents::PRODUCT_LOADED_EVENT => 'onProductsLoaded',
            'product.written'                   => 'onProductWritten',
        ];
    }

    public function onProductsLoaded(EntityLoadedEvent $event): void
    {
        foreach ($event->getEntities() as $product) {
            // ...
        }
    }
}
```

Register with tag `kernel.event_subscriber` in `services.xml`.

**Important event families:**
- `EntityWrittenEvent` — after DAL writes (`product.written`, `order.written`, …)
- `SalesChannelContextCreatedEvent` — storefront context built
- `PageLoadedEvent` subtypes — page data assembled (add data here, not in controller)
- Business events (flow builder) — order placed, customer registered, etc.

> **Versioned entities note:** Some entities (orders, products) are versioned. Some events are only triggered on the "live" version.

#### Custom Events

Implement one of these interfaces:

| Interface | When to use |
|---|---|
| `ShopwareEvent` | Basic event with `Context` |
| `ShopwareSalesChannelEvent` | Extends `ShopwareEvent`, adds `SalesChannelContext` |
| `SalesChannelAware` | Provides `getSalesChannelId()` |

Dispatch via injected `EventDispatcherInterface` (`event_dispatcher` service ID):

```php
$this->eventDispatcher->dispatch(new MyCustomEvent($entity, $context));
```

---


### Store API Route Pattern

Store API routes must follow the abstract/concrete/decorator pattern so third parties can decorate them.

```php
// AbstractExampleRoute.php
abstract class AbstractExampleRoute
{
    abstract public function getDecorated(): AbstractExampleRoute;
    abstract public function load(Criteria $criteria, SalesChannelContext $context): ExampleRouteResponse;
}
```

```php
// ExampleRoute.php
#[Route(defaults: [PlatformRequest::ATTRIBUTE_ROUTE_SCOPE => [StoreApiRouteScope::ID]])]
class ExampleRoute extends AbstractExampleRoute
{
    public function __construct(private readonly EntityRepository $repository) {}

    public function getDecorated(): AbstractExampleRoute
    {
        throw new DecorationPatternException(self::class);
    }

    #[Route(path: '/store-api/example', name: 'store-api.example.search', methods: ['GET', 'POST'], defaults: ['_entity' => 'swag_example'])]
    public function load(Criteria $criteria, SalesChannelContext $context): ExampleRouteResponse
    {
        return new ExampleRouteResponse($this->repository->search($criteria, $context->getContext()));
    }
}
```

```php
// ExampleRouteResponse.php — extends StoreApiResponse
/** @property EntitySearchResult<ExampleCollection> $object */
class ExampleRouteResponse extends StoreApiResponse
{
    public function getExamples(): ExampleCollection
    {
        return $this->object->getEntities();
    }
}
```

The `DecorationPatternException` is thrown from `getDecorated()` when there is no decorator yet. Inject `AbstractExampleRoute` (not the concrete class) into dependents so decorators are used transparently.

---

### Service Decoration Pattern

Full abstract base + concrete + decorator:

```php
// AbstractExampleService.php
abstract class AbstractExampleService
{
    abstract public function getDecorated(): AbstractExampleService;
    abstract public function doSomething(): string;

    // Add new methods as non-abstract first, delegating to getDecorated()
    // Only make abstract after all decorators are updated
    public function doSomethingNew(): string
    {
        return $this->getDecorated()->doSomethingNew();
    }
}
```

```php
// ExampleService.php — concrete (throws DecorationPatternException)
class ExampleService extends AbstractExampleService
{
    public function getDecorated(): AbstractExampleService
    {
        throw new DecorationPatternException(self::class);
    }

    public function doSomething(): string { return 'original'; }
}
```

```php
// ExampleServiceDecorator.php
class ExampleServiceDecorator extends AbstractExampleService
{
    public function __construct(private readonly AbstractExampleService $decorated) {}

    public function getDecorated(): AbstractExampleService
    {
        return $this->decorated;
    }

    public function doSomething(): string
    {
        return $this->decorated->doSomething() . ' decorated';
    }
}
```

**DI registration** (`services.php`):
```php
$services->set(ExampleServiceDecorator::class)
    ->decorate(ExampleService::class)
    ->args([service('.inner')]);
```

> **Tag inheritance pitfall:** Decorating a service with `kernel.event_subscriber` automatically inherits that tag. Your decorator must then also implement `EventSubscriberInterface`. `inherit-tags="false"` is **not valid** XML in Symfony's schema. Solution: do not decorate event-subscriber-tagged services; use a separate subscriber instead.

---


### Plugin Configuration (`config.xml`)

Creates a settings form in the Administration without custom Vue components.

```xml
<!-- src/Resources/config/config.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="https://raw.githubusercontent.com/shopware/shopware/trunk/src/Core/System/SystemConfig/Schema/config.xsd">

    <card>
        <title>Basic Configuration</title>
        <title lang="de-DE">Grundeinstellungen</title>

        <input-field>
            <name>myTextValue</name>
            <label>Label EN</label>
            <label lang="de-DE">Label DE</label>
            <helpText>Help text EN</helpText>
            <defaultValue>default</defaultValue>
        </input-field>

        <input-field type="single-select">
            <name>mailMethod</name>
            <options>
                <option><id>smtp</id><name>SMTP</name></option>
                <option><id>pop3</id><name>POP3</name></option>
            </options>
            <defaultValue>smtp</defaultValue>
            <label>Mail method</label>
        </input-field>

        <input-field type="bool">
            <name>enabled</name>
            <defaultValue>true</defaultValue>
            <label>Enabled</label>
        </input-field>
    </card>
</config>
```

**Available field types:** `text`, `textarea`, `text-editor`, `url`, `password`, `int`, `float`, `bool`, `checkbox`, `datetime`, `colorpicker`, `single-select`, `multi-select`, `media-selection`.

**Reading config in PHP:**

```php
// Inject: Shopware\Core\System\SystemConfig\SystemConfigService
$this->systemConfigService->get('SwagExample.config.myTextValue');
$this->systemConfigService->getString('SwagExample.config.myTextValue');
$this->systemConfigService->getBool('SwagExample.config.enabled');
$this->systemConfigService->getInt('SwagExample.config.myIntValue');
```

---


### Scheduled Tasks

```php
// src/Service/ScheduledTask/ExampleTask.php
use Shopware\Core\Framework\MessageQueue\ScheduledTask\ScheduledTask;

class ExampleTask extends ScheduledTask
{
    public static function getTaskName(): string { return 'swag.example_task'; }
    public static function getDefaultInterval(): int { return 300; } // seconds
}
```

```php
// src/Service/ScheduledTask/ExampleTaskHandler.php — 6.6+ syntax
use Shopware\Core\Framework\MessageQueue\ScheduledTask\ScheduledTaskHandler;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

#[AsMessageHandler(handles: ExampleTask::class)]
class ExampleTaskHandler extends ScheduledTaskHandler
{
    public function run(): void
    {
        // task logic
    }
}
```

> **6.6 breaking change:** `getHandledMessages()` static method removed from `ScheduledTaskHandler`. Use `#[AsMessageHandler(handles: MyTask::class)]` attribute.

Register both with tags (`services.php`):

```php
$services->set(ExampleTask::class)->tag('shopware.scheduled.task');
$services->set(ExampleTaskHandler::class)->tag('messenger.message_handler');
```

---

