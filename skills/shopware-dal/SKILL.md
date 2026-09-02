---
name: shopware-dal
description: Use when querying or writing Shopware 6 data through the Data Abstraction Layer — entity definitions, criteria, associations, filters, aggregations, EntityExtension, and custom fields. Triggers on EntityRepository, Criteria, EntityDefinition, custom field sets, or extending core entities.
---

# Shopware 6 — Data Abstraction Layer

PHP conventions come from `rules/`, not from this skill. See the `shopware` skill for the map of Shopware skills.

### Data Abstraction Layer (DAL)

The DAL replaces direct ORM/SQL. Use repositories, not Doctrine EntityManager.

**Inject repository** (`services.xml`):

```xml
<service id="Swag\Example\Service\ProductService">
    <argument type="service" id="product.repository"/>
</service>
```

Or with `services.php` (modern format):

```php
$services->set(ProductService::class)
    ->args([service('product.repository')]);
```

Repository service names follow the pattern: `entity_name.repository`.

#### Reading Data

```php
use Shopware\Core\Framework\DataAbstractionLayer\Search\Criteria;
use Shopware\Core\Framework\DataAbstractionLayer\Search\Filter\EqualsFilter;
use Shopware\Core\Framework\DataAbstractionLayer\Search\Filter\RangeFilter;
use Shopware\Core\Framework\DataAbstractionLayer\Search\Sorting\FieldSorting;
use Shopware\Core\Framework\DataAbstractionLayer\Search\Aggregation\Metric\AvgAggregation;

$criteria = new Criteria();
$criteria->addFilter(new EqualsFilter('active', true));
$criteria->addFilter(new RangeFilter('price', ['gte' => 10]));
$criteria->addAssociation('manufacturer');
$criteria->addSorting(new FieldSorting('name', FieldSorting::ASCENDING));
$criteria->setLimit(25)->setOffset(0);

// Standard search — returns EntitySearchResult
$result = $this->productRepository->search($criteria, $context);
$entity = $result->first();

// Get only IDs — more efficient when you don't need the full entity
$ids = $this->productRepository->searchIds($criteria, $context);
$firstId = $ids->firstId();

// Post-filter: applies to result but NOT to aggregations
$criteria->addPostFilter(new EqualsFilter('name', 'Foo'));

// Aggregations — do NOT call ->first() when using aggregations
$criteria->addAggregation(new AvgAggregation('avg-rating', 'productReviews.points'));
$result = $this->productRepository->search($criteria, $context);
$rating = $result->getAggregations()->get('avg-rating');
```

#### Writing Data

```php
use Shopware\Core\Framework\Uuid\Uuid;

// Create
$this->repository->create([
    ['id' => Uuid::randomHex(), 'name' => 'New', ...]
], $context);

// Update
$this->repository->update([
    ['id' => $id, 'name' => 'Updated']
], $context);

// Delete
$this->repository->delete([['id' => $id]], $context);

// Upsert — always provide ID, otherwise data is always created (never updated)
$this->repository->upsert([
    ['id' => $knownId, 'name' => 'Upserted']
], $context);
```

> **ManyToMany pitfall:** You cannot update a `ManyToMany` mapping entity directly (e.g. `productCategoryRepository->update()`). Assign associations through the owning entity's repository instead.

#### Custom Entity

Full pattern: `EntityDefinition` + `Entity` + `EntityCollection` + Migration + service registration.

**Migration** (`src/Migration/Migration1611664789Example.php`):
```php
public function update(Connection $connection): void
{
    $connection->executeStatement(<<<SQL
        CREATE TABLE IF NOT EXISTS `swag_example` (
            `id`          BINARY(16) NOT NULL,
            `name`        VARCHAR(255) COLLATE utf8mb4_unicode_ci,
            `description` VARCHAR(255) COLLATE utf8mb4_unicode_ci,
            `active`      TINYINT(1),
            `custom_fields` JSON NULL,
            `created_at`  DATETIME(3) NOT NULL,
            `updated_at`  DATETIME(3),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    SQL);
}

public function updateDestructive(Connection $connection): void
{
    // DROP TABLE only in destructive migrations
}
```

Generate skeleton: `bin/console database:create-migration -p SwagExample --name ExampleDescription`

**EntityDefinition** (`src/Core/Content/Example/ExampleDefinition.php`):
```php
use Shopware\Core\Framework\DataAbstractionLayer\EntityDefinition;
use Shopware\Core\Framework\DataAbstractionLayer\Field\Flag\ApiAware;
use Shopware\Core\Framework\DataAbstractionLayer\Field\Flag\Required;
use Shopware\Core\Framework\DataAbstractionLayer\Field\{IdField, StringField, BoolField, CustomFields, CreatedAtField, UpdatedAtField};
use Shopware\Core\Framework\DataAbstractionLayer\FieldCollection;

class ExampleDefinition extends EntityDefinition
{
    public const ENTITY_NAME = 'swag_example';

    public function getEntityName(): string { return self::ENTITY_NAME; }
    public function getEntityClass(): string { return ExampleEntity::class; }
    public function getCollectionClass(): string { return ExampleCollection::class; }

    protected function defineFields(): FieldCollection
    {
        return new FieldCollection([
            (new IdField('id', 'id'))->addFlags(new Required(), new ApiAware()),
            (new StringField('name', 'name'))->addFlags(new ApiAware()),
            (new StringField('description', 'description'))->addFlags(new ApiAware()),
            (new BoolField('active', 'active'))->addFlags(new ApiAware()),
            new CustomFields(),
            new CreatedAtField(),
            new UpdatedAtField(),
        ]);
    }
}
```

**Entity** (`src/Core/Content/Example/ExampleEntity.php`):
```php
use Shopware\Core\Framework\DataAbstractionLayer\Entity;
use Shopware\Core\Framework\DataAbstractionLayer\EntityCustomFieldsTrait;
use Shopware\Core\Framework\DataAbstractionLayer\EntityIdTrait;

class ExampleEntity extends Entity
{
    use EntityIdTrait;
    use EntityCustomFieldsTrait;

    protected ?string $name = null;
    protected ?bool $active = null;

    public function getName(): ?string { return $this->name; }
    public function setName(?string $name): void { $this->name = $name; }
    public function isActive(): ?bool { return $this->active; }
    public function setActive(?bool $active): void { $this->active = $active; }
}
```

**EntityCollection** (`src/Core/Content/Example/ExampleCollection.php`):
```php
use Shopware\Core\Framework\DataAbstractionLayer\EntityCollection;

/** @extends EntityCollection<ExampleEntity> */
class ExampleCollection extends EntityCollection
{
    protected function getExpectedClass(): string { return ExampleEntity::class; }
}
```

**Service registration** (`services.xml`):
```xml
<service id="Swag\Example\Core\Content\Example\ExampleDefinition">
    <tag name="shopware.entity.definition" entity="swag_example"/>
</service>
```

Shopware auto-creates the `swag_example.repository` service. Inject it by that name.

---


### Custom Fields

Custom fields extend existing entities without a full entity extension. They store scalar values in a JSON column. For associations, use an EntityExtension instead.

**Add custom fields via plugin lifecycle:**

```php
// Inject custom_field_set.repository
$this->customFieldSetRepository->create([[
    'name' => 'swag_example_set',
    'config' => ['label' => ['en-GB' => 'Example Set', 'de-DE' => 'Beispiel Set']],
    'customFields' => [[
        'name' => 'swag_example_field',
        'type' => CustomFieldTypes::TEXT,
        'config' => ['label' => ['en-GB' => 'Example Field', 'de-DE' => 'Beispiel Feld']],
    ]],
    'relations' => [['entityName' => 'product']],
]], $context);
```

Available `CustomFieldTypes` constants: `TEXT`, `TEXTAREA`, `INT`, `FLOAT`, `BOOL`, `DATETIME`, `COLOR`, `MEDIA`, `SELECT`, `ENTITY_SELECT`, `HTML`, `PRICE`.

---


## EntityExtension — Version Compatibility

| Version | Abstract method |
|---------|----------------|
| 6.4 / 6.5 | `getDefinitionClass(): string` → returns FQCN, e.g. `CategoryDefinition::class` |
| 6.6 | Both (deprecated `getDefinitionClass()`) |
| 6.7 | `getEntityName(): string` → returns entity name, e.g. `'category'` |

**Cross-version plugin (6.4–6.7):** implement both — PHP does not complain about extra non-abstract methods.

---

