---
title: UI portal host contract
description: BusDK UI host responsibilities for portal-mounted feature modules.
---

## Contract

A portal module exposes this contract through `bus-portal/pkg/portal.Module`.
The current Go interface already provides `ID`, `Title`, `State`,
`DefaultEnabled`, `NavItems`, and `Handler`; this UI contract documents the
versioned shape that host metadata and future GX module descriptors must
preserve.

| Field | Required | Type | Rule |
| --- | --- | --- | --- |
| `id` | yes | stable slug | Lowercase module ID used in mounted paths; changing it is a routing break. |
| `title` | yes | public string | Human label for nav and metadata. |
| `ready` | yes | `ready`, `disabled`, or `blocked` | `ready` serves routes; `disabled` hides default navigation; `blocked` shows safe status and does not serve feature routes. |
| `defaultEnabled` | no | boolean | Defaults to `false` when omitted. |
| `navigation` | no | ordered items | Each item is `{id,label,path}` or `{id,label,onClick}`. `id` is stable, `label` is public text, and exactly one of `path` or `onClick` is required. `path` starts with `/` relative to `moduleBasePath`; `onClick` names a handler registered in the module's runtime event map before render, and missing handlers fail validation instead of rendering an inert navigation item. |
| `handler` | yes | HTTP handler | Implements `ServeHTTP(w http.ResponseWriter, r *http.Request)` under the host-provided module base path. The host strips the module prefix before calling the handler, stores the original base path in host context as `moduleBasePath`, and returns unmatched feature routes as `404` through the host error renderer instead of redirecting outside the module. |

The host normalizes modules, exposes metadata, serves shared CSS, and dispatches
mounted routes under `/modules/<id>/...` inside the token-gated portal URL.

`bus-portal` or the embedding app owns routes, assets, public runtime config,
sessions, security headers, client/server logging, and browser artifact
delivery. Feature modules should depend on this host contract instead of
duplicating path resolution, token handling, or asset loading.

The host context provides these values:

| Value | Semantics |
| --- | --- |
| `moduleBasePath` | Canonical mounted path such as `/modules/notes`; modules join relative routes to it. |
| `assetBaseURL` | Shared CSS, JavaScript, and image asset base controlled by the host. |
| `resolveAPI(path)` | Accepts `/`-prefixed paths plus optional query values and returns a same-origin URL under the mounted module route. It rejects external origins and path traversal. |
| `publicRuntimeConfig` | JSON-safe public config only; secrets and bearer tokens are excluded. |
| `session` | Auth/session view with `state`, `user`, `withBearer(req)`, and `withCSRF(req)` helpers. `withBearer` applies only to host-approved API routes that require bearer auth; `withCSRF` applies only to same-origin unsafe methods such as `POST`, `PUT`, `PATCH`, and `DELETE`. Neither helper exposes token values to templates. |
| `log` | Structured client/server diagnostic channel with redaction. |
| `connectSrc` | Exact `https:` origins required by resources or effects for content security policy. Wildcards and credential-bearing URLs are invalid. |

## Consequence

Feature modules should not hard-code standalone `/modules/<id>/...` paths,
relative asset paths, or duplicated runtime config scripts when the host can
provide them.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-portal module reference](../../modules/bus-portal)
- [Portal UI modules](./portal-modules)
