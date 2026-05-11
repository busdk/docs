---
title: Resource UI concept
description: Dedicated BusDK UI framework concept page for Resource.
---

## Purpose

A resource is a named contract for data or media that the UI can request through
the host runtime. Create one when a component or effect needs provider data, an
upload target, an artifact link, an evidence preview, or a request adapter that
must be faked in tests.

## Boundary

Use resources to centralize path resolution, auth headers, decoding, and fake
clients. Renderer target, shell selection, mount path, and host choice stay
outside the UI document in the renderer command, portal host, local app host, or
test harness configuration.

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

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./action">Action</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./effect">Effect</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
