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

```gx
package notesui

var notesURL = (
  <APIURLResolver
    base="module"
    path="/api/notes"
    query={map[string]string{"q": "evidence"}}>
  </APIURLResolver>
)
```

## Runtime Terms

[Resource](../fc-003-resources/resource) defines safe URL resolution,
external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
