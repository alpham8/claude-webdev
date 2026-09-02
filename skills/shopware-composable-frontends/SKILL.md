---
name: shopware-composable-frontends
description: Use when building a headless Shopware 6 frontend with Composable Frontends — architecture, how it differs from the classic Twig storefront, CMS component resolution, and known gotchas. Triggers on Nuxt or Vue headless storefronts, shopware-frontends packages, or Store API driven frontends.
---

# Shopware — Composable Frontends (Headless)

See the `shopware` skill for the map of Shopware skills.

## Shopware Composable Frontends (Headless)

Headless Vue 3 + Nuxt storefront that communicates exclusively via the **Store API**. Successor to the archived `shopware-pwa` (Vue Storefront). Fully replaces the classic Twig-based Storefront.

> **shopware-pwa is archived** (Oct 2024). All new headless work uses **Shopware Composable Frontends** (`@shopware/*` packages).

### Architecture

| Package | npm | Purpose |
|---------|-----|---------|
| API Client | `@shopware/api-client` | Typed Store API abstraction, auth/context-token management |
| Composables | `@shopware/composables` | Vue 3 composables: `useProduct`, `useCart`, `useListing`, `useCustomer`, etc. |
| CMS Base Layer | `@shopware/cms-base-layer` | Vue components for all default CMS sections/blocks/elements |
| Helpers | `@shopware/helpers` | Price formatting, translations, URL handling |
| Nuxt Module | `@shopware/nuxt-module` | Wires up API client + composables + context for Nuxt |
| API Gen CLI | `@shopware/api-gen` | Generates TypeScript types from your Shopware instance's API schema |

**Tech stack:** Vue 3 + Nuxt 4 + TypeScript + UnoCSS/Tailwind. SSR by default.

### vs. Classic Storefront (Twig)

| Aspect | Classic Storefront | Composable Frontends |
|--------|-------------------|---------------------|
| Rendering | PHP/Twig (server) | Vue/Nuxt (Node.js SSR) |
| Extension | Twig blocks, PHP events | Vue components, Nuxt layers |
| Deployment | Same process as Shopware | Separate Node.js application |
| CMS customization | PHP DataResolver + Twig template | Vue component (naming convention) |
| Plugin effects | Subscribers, decorators, Twig | No effect — Store API only |
| Styling | SCSS + Shopware theme system | Free choice (Tailwind, UnoCSS, etc.) |

### CMS Component Resolution

The Store API returns a nested CMS tree. Each node's `type` is converted to a PascalCase Vue component:

```
CMS type "image-text" → component CmsBlockImageText
CMS type "product-listing" → component CmsElementProductListing
```

Custom CMS blocks from backend plugins have **no Vue implementation by default** — you must create them manually.

### Composable Frontends Gotchas

1. **Sales Channel type must be "Storefront"** — Do NOT use the "Headless" type. The Headless type does not generate SEO URLs. This is counterintuitive but required for proper URL resolution.

2. **`devStorefrontUrl` for local dev** — Customer registration requires a `storefrontUrl` matching a domain in Admin > Sales Channel > Domains. Set in `nuxt.config.ts`:
   ```typescript
   shopware: {
       devStorefrontUrl: 'https://your-production-domain.com',
   }
   ```
   Or via env: `NUXT_PUBLIC_SHOPWARE_DEV_STOREFRONT_URL`.

3. **Store API access token is public** — The token appears in client-side code. Only data visible on a normal storefront should be exposed. Use a Vite proxy for production to hide the backend URL:
   ```typescript
   vite: {
       server: {
           proxy: {
               '/store-api': {
                   target: 'https://your-shopware-backend.com',
                   changeOrigin: true,
                   secure: false,
               },
           },
       },
   }
   ```

4. **SSR + DDEV self-signed certs** — SSR causes 500 errors because Node.js rejects self-signed SSL certificates. Workaround (dev only):
   ```dotenv
   NODE_TLS_REJECT_UNAUTHORIZED=0
   ```

5. **CORS with local frontend** — Frontend at `localhost:3000` is cross-origin to the Shopware backend. Fix with server-side proxy (see above) or set `Access-Control-Allow-Origin` on the backend.

6. **Custom CMS blocks not rendered** — Only default Shopware CMS blocks have Vue implementations in `@shopware/cms-base-layer`. Plugin-added blocks must be manually implemented as Vue components following the `CmsBlock<PascalCaseType>` / `CmsElement<PascalCaseType>` naming convention.

7. **Missing `createShopwareContext`** — Occurs when `@shopware/nuxt-module` is installed but the composables layer is not extended. Fix:
   ```typescript
   // nuxt.config.ts
   extends: ['@shopware/composables/nuxt-layer'],
   ```

8. **Type generation recommended** — Default types may not match your instance's custom entities. Run `@shopware/api-gen` against your Shopware instance for accurate TypeScript types.

9. **Demo Store Template is deprecated** — Use the Vue Starter Template with Nuxt layers pattern instead.

10. **No automated migration from shopware-pwa** — Package names changed (`@shopware-pwa/*` → `@shopware/*`), composable API signatures differ, Vue 2→3 and Nuxt 2→4 migration required. Effectively a frontend rewrite.

11. **Routing via `useNavigationSearch`** — Uses Shopware's `SeoUrl` system. A catch-all route resolves the path to one of three types: `frontend.detail.page` (product), `frontend.navigation.page` (category), `frontend.landing.page` (landing page).

12. **API Client hooks** — Use `onContextChanged`, `onResponseError`, `onSuccessResponse` for global request/response handling. The client manages the `sw-context-token` cookie automatically.
