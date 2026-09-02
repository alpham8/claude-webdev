---
name: shopware-administration
description: Use when extending the Shopware 6 Administration — Vue components, module registration, twig-based component overrides, and data handling via the admin repository factory. Triggers on Shopware.Component.register, Module.register, sw-admin overrides, or admin criteria building.
---

# Shopware 6 — Administration (Vue.js)

See the `vue` skill for Vue itself and the `shopware` skill for the map of Shopware skills.

### Administration (Vue.js)

```javascript
// Resources/app/administration/src/main.js
import './module/swag-example';
```

```javascript
// module/swag-example/index.js
import './page/swag-example-list';
import deDE from './snippet/de-DE';
import enGB from './snippet/en-GB';

Shopware.Module.register('swag-example', {
    type: 'plugin',
    name: 'SwagExample',
    title: 'swag-example.general.mainMenuItemGeneral',
    color: '#ff3d58',
    icon: 'regular-shopping-bag',

    snippets: { 'de-DE': deDE, 'en-GB': enGB },

    routes: {
        list: {
            component: 'swag-example-list',
            path: 'list',
            meta: { privilege: 'swag_example.viewer' }
        },
    },

    navigation: [{
        id: 'swag-example',
        label: 'swag-example.general.mainMenuItemGeneral',
        color: '#ff3d58',
        path: 'swag.example.list',
        icon: 'regular-shopping-bag',
        parent: 'sw-catalogue',  // inject under Catalogue menu
        position: 100,
        privilege: 'swag_example.viewer'
    }],
});
```

#### Admin — Data Handling (repositoryFactory)

```javascript
// In component:
inject: ['repositoryFactory'],

computed: {
    productRepository() {
        return this.repositoryFactory.create('product');
    },
},

created() {
    const { Criteria } = Shopware.Data;
    const criteria = new Criteria();
    criteria.addFilter(Criteria.equals('active', true));
    criteria.addSorting(Criteria.sort('name', 'ASC'));
    criteria.setLimit(25);

    this.productRepository
        .search(criteria, Shopware.Context.api)
        .then(result => { this.products = result; });
},
```

For new entities: `this.repo.create(Shopware.Context.api)`, then `this.repo.save(entity, context)`.
For delete: `this.repo.delete(id, context)`.

#### Admin — Override / Extend Components

```javascript
// Override (replace in-place):
Shopware.Component.override('sw-dashboard-index', { template });

// Extend (new component based on existing):
Shopware.Component.extend('sw-custom-field', 'sw-text-field', { template });
```

Use `this.$super('methodName')` to call the original method:

```javascript
methods: {
    categoryCriteria() {
        const criteria = this.$super('categoryCriteria');
        criteria.addAssociation('translations.linkMedia');
        return criteria;
    },
}
```

In Twig templates, use `{% parent %}` to include original block content:

```twig
{% block card_content %}
    {% parent %}
    <div>My addition</div>
{% endblock %}
```

#### Admin — Extending Entity Criteria

To add an association when a detail page loads an entity, override the component's criteria computed property:

```javascript
Shopware.Component.override('sw-category-detail', {
    computed: {
        categoryCriteria() {
            const criteria = this.$super('categoryCriteria');
            criteria.addAssociation('translations.linkMedia');
            return criteria;
        },
    },
});
```

Find the right computed/method name by searching for `addAssociation` inside the component's source at `src/Administration/Resources/app/administration/src/module/`.

#### Admin — ACL Permissions

```javascript
// acl/index.js
Shopware.Service('privileges').addPrivilegeMappingEntry({
    category: 'permissions',
    parent: 'catalogues',
    key: 'swag_example',
    roles: {
        viewer:  { privileges: ['swag_example:read'], dependencies: [] },
        editor:  { privileges: ['swag_example:update'], dependencies: ['swag_example.viewer'] },
        creator: { privileges: ['swag_example:create'], dependencies: ['swag_example.viewer', 'swag_example.editor'] },
        deleter: { privileges: ['swag_example:delete'], dependencies: ['swag_example.viewer'] },
    },
});
```

Check in templates: `v-if="acl.can('swag_example.editor')"`. Inject `acl` service to use in JS: `inject: ['acl']`.

---

