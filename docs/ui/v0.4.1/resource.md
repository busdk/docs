---
title: Resource UI concept
description: Dedicated BusDK UI framework concept page for Resource.
---

## Purpose

A resource is a named contract for data or media that the UI can request through
the host runtime. Create one when a component or effect needs provider data, an
upload target, an artifact link, an evidence preview, or a request adapter that
must be faked in tests.

## Design References

- [Expression children](../v0.1.5/expression-children)
- [UI design system](../v0.2.0/design-system)

## Boundary

Use resources to centralize path resolution, auth headers, decoding, and fake
clients. Renderer target, shell selection, mount path, and host choice stay
outside the template in the renderer command, portal host, local app host, or
test harness configuration.

Safe URLs are same-origin absolute paths beginning with `/`, host-resolved
resource URLs, or `https:` URLs when the component explicitly allows external
links and the host allowlists the origin. `javascript:`, `data:`, path
traversal, and unresolved authorization failures are rejected.

Evidence preview URLs must come from a host-owned evidence URL resolver or an
authorized provider API path. The resolver is the portal or product host code
that verifies access, normalizes the evidence id, and returns a safe same-origin
proxy URL. External evidence previews are rejected unless that resolver
explicitly authorizes and proxies them.

## Example

```yaml
resources:
  notes:
    method: GET
    base: module
    path: /api/notes
```

This declares a read resource named `notes`. Components and effects can refer
to `notes`; the host resolves `/api/notes`, attaches credentials, and decodes
the response.

`method` is required and is one of `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, or
`UPLOAD`. `base` is required and is one of `module`, `portal`, or a named host
resolver. `path` is required and must be a same-origin absolute path beginning
with `/`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Callback props](../v0.1.6/callback-props)
- [Mounting and updates](../v0.1.7/mounting-updates)
