---
name: shopware-cms-elements
description: Use when building custom CMS elements or blocks for Shopware 6 Erlebniswelten — element registration, admin component and config, data resolver, and storefront template. Triggers on CmsElementResolver, Shopware.Service cmsService, registerCmsElement, or shopping experience extensions.
---

# Shopware 6 — Custom CMS Elements

See the `shopware-administration` skill for the admin side and the `shopware` skill for the map of Shopware skills.

### Custom CMS Elements (Erlebniswelten)

Custom CMS elements require a PHP DataResolver, a DI registration, and an admin JS module.

#### PHP — Two Resolver Patterns

**Pattern A — Extend `TextCmsElementResolver`** (text/content fields):

```php
use Shopware\Core\Content\Cms\DataResolver\Element\TextCmsElementResolver;

class HeadlineCmsElementResolver extends TextCmsElementResolver
{
    public function getType(): string { return 'lnx-headline'; }
}
```

DI: inject `Shopware\Core\Framework\Util\HtmlSanitizer` as first argument.

**Pattern B — Implement `CmsElementResolverInterface`** (elements needing DAL queries):

```php
use Shopware\Core\Content\Cms\DataResolver\Element\CmsElementResolverInterface;
use Shopware\Core\Content\Cms\DataResolver\Element\ElementDataCollection;
use Shopware\Core\Content\Cms\DataResolver\ResolverContext\ResolverContext;
use Shopware\Core\Framework\Struct\ArrayStruct;

class PdfSectionCmsElementResolver implements CmsElementResolverInterface
{
    public function __construct(
        private readonly EntityRepository $mediaFolderRepository,
        private readonly EntityRepository $mediaRepository,
    ) {}

    public function getType(): string { return 'lnx-pdf-katalog-section'; }

    public function collect(CmsSlotEntity $slot, ResolverContext $resolverContext): ?CriteriaCollection
    {
        return null; // resolve everything in enrich()
    }

    public function enrich(CmsSlotEntity $slot, ResolverContext $resolverContext, ElementDataCollection $result): void
    {
        $folderName = (string) ($slot->getFieldConfig()->get('folderName')?->getValue() ?? '');

        if ($folderName === '') {
            $slot->setData(new ArrayStruct(['media' => []]));
            return;
        }

        $context = $resolverContext->getSalesChannelContext()->getContext();
        // ... DAL queries ...
        $slot->setData(new ArrayStruct(['media' => $media->getElements()]));
    }
}
```

#### DI Registration (`cms.xml`)

```xml
<service id="Vendor\Plugin\...\HeadlineCmsElementResolver">
    <argument type="service" id="Shopware\Core\Framework\Util\HtmlSanitizer" />
    <tag name="shopware.cms.data_resolver" />
</service>

<service id="Vendor\Plugin\...\PdfSectionCmsElementResolver">
    <argument type="service" id="media_folder.repository" />
    <argument type="service" id="media.repository" />
    <tag name="shopware.cms.data_resolver" />
</service>
```

Tag: `shopware.cms.data_resolver` — required on every resolver.

#### Admin JS Structure

```
module/sw-cms/
├── index.js                        ← imports all elements
└── element/
    └── lnx-headline/
        ├── index.js                ← registerCmsElement() + component registration
        ├── component/index.js
        ├── config/index.js
        └── preview/index.js
```

**`element/lnx-headline/index.js`:**
```javascript
Shopware.Component.register('lnx-cms-el-headline', () => import('./component'));
Shopware.Component.register('lnx-cms-el-config-headline', () => import('./config'));
Shopware.Component.register('lnx-cms-el-preview-headline', () => import('./preview'));

Shopware.Service('cmsService').registerCmsElement({
    name: 'lnx-headline',
    label: 'sw-cms.elements.headline.label',
    component: 'lnx-cms-el-headline',
    configComponent: 'lnx-cms-el-config-headline',
    previewComponent: 'lnx-cms-el-preview-headline',
    defaultConfig: {
        content: { source: 'static', value: 'Lorem ipsum dolor sit amet.' },
        level:   { source: 'static', value: 'h1' },
    },
});
```

**Component/config `index.js`** — always call `initElementConfig()`:
```javascript
import { Mixin } = Shopware;
export default {
    template,
    mixins: [Mixin.getByName('cms-element')],
    created() {
        this.initElementConfig('lnx-headline'); // must be called in BOTH component and config
    },
};
```

**Auto-mapping** (product.name / category.name based on page type):
```javascript
created() {
    this.initElementConfig('lnx-headline');
    const pageType = this.cmsPageState?.currentPage?.type ?? '';
    if (pageType === 'product_detail' && !this.element?.translated?.config?.content) {
        this.element.config.content.source = 'mapped';
        this.element.config.content.value = 'product.name';
    } else if (pageType === 'product_list' && !this.element?.translated?.config?.content) {
        this.element.config.content.source = 'mapped';
        this.element.config.content.value = 'category.name';
    }
},
```

**Storefront template** (`Resources/views/storefront/element/cms-element-lnx-headline.html.twig`):
```twig
{% block element_lnx_headline %}
    <{{ element.config.level.value }}>{{ element.data.content }}</{{ element.config.level.value }}>
{% endblock %}
```

Access slot config via `element.config.*`, resolved data via `element.data.*`.

#### Key Rules

- Element `name` in `registerCmsElement` must exactly match PHP `getType()`.
- `initElementConfig()` must be called in both `component` and `config`.
- `source: 'static'` for user-entered values; `source: 'mapped'` for entity field references.
- Config field values in PHP: `$slot->getFieldConfig()->get('fieldName')?->getValue()`.

#### CMS Block

Blocks define layout structure (which elements go in which slots). Register with `registerCmsBlock`:

```javascript
Shopware.Service('cmsService').registerCmsBlock({
    name: 'image-text-reversed',
    category: 'text-image',    // text | image | text-image | commerce | form | video | sidebar
    label: 'cms.blocks.imageTextReversed.label',
    component: 'cms-block-image-text-reversed',
    previewComponent: 'cms-block-preview-image-text-reversed',
    defaultConfig: { marginBottom: '20px', marginTop: '20px', sizingMode: 'boxed' },
    slots: { left: 'text', right: 'image' },
});
```

Storefront block template (`storefront/block/cms-block-image-text-reversed.html.twig`):
```twig
<div class="col-md-6">
    {% set element = block.slots.getSlot('left') %}
    {% sw_include '@Storefront/storefront/element/cms-element-' ~ element.type ~ '.html.twig' with { 'element': element } %}
</div>
<div class="col-md-6">
    {% set element = block.slots.getSlot('right') %}
    {% sw_include '@Storefront/storefront/element/cms-element-' ~ element.type ~ '.html.twig' with { 'element': element } %}
</div>
```

---

