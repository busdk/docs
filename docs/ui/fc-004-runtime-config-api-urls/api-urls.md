---
title: Library API URLs
description: BusDK UI library API URL resolution contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)

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

```gx
package notesui

var notesURL = (
  <APIURLResolver base="module" path="/api/notes"></APIURLResolver>
)
```

Absolute URLs keep the full URL in `path` and require an exact origin in
runtime config:

```gx
package notesui

var runtimeConfig = (
  <RuntimeConfig config={map[string]any{
    "moduleBase": "/modules/notes/",
    "apiBase": "/modules/notes/api",
    "externalAPIOrigins": []string{"https://api.example.com"},
  }}></RuntimeConfig>
)
```

```gx
package notesui

var externalNotesURL = (
  <APIURLResolver base="absolute" path="https://api.example.com/v1/notes"></APIURLResolver>
)
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
- [Resource UI concept](../fc-003-resources/resource)
