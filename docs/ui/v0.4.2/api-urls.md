---
title: Library API URLs
description: BusDK UI library API URL resolution contract.
---

## Design References

- [Portal host contract](../v0.4.2/portal-host-contract)
- [Binding](../v0.1.5/binding)

## Contract

[`APIURLResolver`](./apiurl-resolver) resolves provider API paths.
It requires `base` and `path`. `base: module` prepends the current module
mount, `base: portal` prepends the portal root, and `base: absolute` requires
an `https:` origin listed in the host [runtime config](./runtime-config)
`externalAPIOrigins` set. Unknown bases, relative paths without a leading `/`,
non-HTTPS absolute URLs, and unlisted origins fail validation before render.

With module mount `/modules/notes`, `base: module` and `path: /api/notes`
resolves to `/modules/notes/api/notes`. With portal root `/portal`,
`base: portal` and `path: /session` resolves to `/portal/session`.

```yaml
kind: APIURLResolver
props:
  base: module
  path: /api/notes
```

Absolute URLs keep the full URL in `path` and require an exact origin in
runtime config:

```yaml
kind: RuntimeConfig
props:
  config:
    moduleBase: /modules/notes/
    apiBase: /modules/notes/api
    externalAPIOrigins:
      - https://api.example.com
```

```yaml
kind: APIURLResolver
props:
  base: absolute
  path: https://api.example.com/v1/notes
```

## Consequence

URL resolution is deterministic and host-owned. Product modules decide endpoint
paths and provider policy.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [APIURLResolver](./apiurl-resolver)
- [Resource UI concept](../v0.4.1/resource)
