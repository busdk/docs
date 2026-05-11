---
title: APIURLResolver UI runtime block
description: Dedicated BusDK UI reference for APIURLResolver.
---

## Purpose

`APIURLResolver` resolves a mounted API path from a known host base plus a
component or resource path. Use it behind resources and provider adapters when
the same UI may run under a portal module path or a local app path.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `base` | yes | module, portal, absolute | `module` prefixes the current module mount, `portal` prefixes the portal root, and `absolute` means `path` must be an `https:` URL allowed by host `externalAPIOrigins`. That allowlist lives in host runtime config as exact origins such as `https://api.example.com`; scheme, host, and port must match. Invalid combinations fail validation. |
| `path` | yes | path string or absolute URL | For `module` and `portal`, must start with `/` and contain no `..`; for `absolute`, must be an allowed `https:` URL. |
| `query` | no | map of scalar values | Values may be string, number, or boolean. `null` is omitted, `false` encodes as `false`, `0` encodes as `0`, and empty string encodes as an empty value. Keys are encoded in stable order. |

## Boundary

With module base `/modules/notes`, `path: /api/notes` resolves to
`/modules/notes/api/notes`. With `query.q: evidence`, the final URL is
`/modules/notes/api/notes?q=evidence`.

The resolver returns a string URL. Components and resources read that returned
string as the resolved endpoint; the resolver does not fetch data itself.

## Example

```yaml
kind: APIURLResolver
props:
  base: module
  path: /api/notes
  query:
    q: evidence
```

## Runtime Terms

A safe URL is either a same-origin absolute path beginning with `/`, a
host-resolved resource URL, or an `https:` URL allowed by `externalAPIOrigins`.
`javascript:`, `data:`, path traversal, and origins not in the allowlist are
rejected during validation.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./runtime-config">RuntimeConfig</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./session">Session</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
