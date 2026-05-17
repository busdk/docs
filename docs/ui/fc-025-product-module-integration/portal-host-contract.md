---
title: Portal host contract
description: BusDK UI host responsibilities for Go product modules mounted through bus-portal.
---

## Overview

The portal host is the stable mounting boundary for product UI modules. A
module implements `portal.Module`; a module that needs canonical host URLs may
also implement `portal.ContextModule`; a GX-ready module can implement
`portal.FrameworkModule` or expose a lower-level `portal.ModuleContract`.

The host normalizes modules, publishes deterministic metadata at `/v1/modules`,
serves shared CSS assets, applies browser security headers, and dispatches
mounted routes under token-aware `/modules/<id>/...` URLs. Product modules use
the host contract instead of hard-coding standalone roots, asset paths, token
segments, or CSP additions.

## Module Metadata

The public module metadata is derived from Go interfaces, not from an
operator-authored YAML descriptor. Stable IDs use lowercase letters, digits, and
hyphens. Readiness is `stable` for normal opt-in modules or `experimental` for
modules that require explicit experimental enablement. The default-enabled flag
controls the module set mounted when the operator does not request a specific
module list.

| Go value | Metadata | Rule |
| --- | --- | --- |
| `ID()` | `id` | Stable route slug. Changing it changes mounted URLs. |
| `Title()` | `title` | Public label for launchers and navigation. |
| `State()` | `state` | `stable` or `experimental`; unsupported values normalize to `stable`. |
| `DefaultEnabled()` | `default_enabled` | Included in the implicit module set when true. |
| `NavItems()` | `nav_items` | Public labels and same-origin route paths. |
| `UIFramework()` or `ModuleContract()` | `gx_render_roots`, `wasm_runtime`, `required_browser_effects`, `public_runtime_config`, `provider_api_origins`, `assets` | Additive framework metadata derived from Go declarations. |

`ValidateModuleContract` and `ValidateFrameworkContract` enforce the mount-time
rules. A safe name is non-empty and may contain letters, digits, hyphens,
underscores, dots, and colons. Safe route paths start with `/`, do not start
with `//`, and do not contain backslashes, `..`, tabs, or newlines. Safe HTML
mount IDs use the safe-name character set but cannot start with a digit.

`gx_render_roots` entries use safe names, safe route paths, and safe HTML mount
IDs. `wasm_runtime.asset_path` and `assets[].path` are same-origin asset paths:
they cannot be empty, absolute URLs, host-qualified paths, query-only values,
fragment-only values, traversal paths, or paths with backslashes, tabs, or
newlines. `required_browser_effects` entries use safe names for `name`, `kind`,
optional `event`, optional `action`, and projected `fields`; `target_id` uses a
safe HTML mount ID when present. `public_runtime_config` keys use safe names and
must not contain terms such as `secret`, `token`, `password`, `credential`,
`private`, or `jwt`. `provider_api_origins` accepts `'self'` or HTTP(S) origins
without paths, queries, or fragments.

`ModuleContractFor` returns the deterministic live metadata snapshot. It sorts
valid entries and omits unsafe optional entries so `/v1/modules` remains stable
and browser-safe.

## Host Context

`portal.HostContext` is the request and render context passed by the host. It is
available through `HandlerWithContext`, through `portal.HostContextFromRequest`,
and through `portal.UIRenderContext` when a framework page is rendered in a
unit fixture.

| Go field | Semantics |
| --- | --- |
| `ModuleID` | Normalized module ID used by host routing and metadata. |
| `BasePath` | Canonical token-aware module path such as `/tok/modules/notes/`. |
| `ThemeAssetURL` | Host-served `portal-theme.css` URL. |
| `UIKitAssetURL` | Host-served `uikit.css` URL. |
| `PublicRuntimeConfig` | Public string configuration after secret-looking keys have been filtered. |
| `ProviderAPIOrigins` | Declared provider origins that extend the host `connect-src` policy. |

Modules build same-origin links with `HostContext.ModuleURL(path)` or with
typed Bus UI props that receive host context. Go WebAssembly receives only the
JSON-safe runtime subset published through metadata or injected by the host; it
does not receive server-only helpers or secret token values.

## Consequence

Feature modules remain portable across local token URLs, hosted portal routes,
and distribution-specific module sets. Provider APIs continue to enforce
authentication, authorization, CSRF/session policy, account scope, and business
rules; the portal host provides routing and browser delivery, not product
authority.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-portal module reference](../../modules/bus-portal)
- [Portal modules](./portal-modules)
- [Product module shape](./product-module-shape)
