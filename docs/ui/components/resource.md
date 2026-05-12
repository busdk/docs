---
title: Resource UI runtime block
description: Dedicated BusDK UI reference for Resource.
---

## Purpose

`Resource` is an action/resource/effect runtime block. External data or media contract. Use for APIs, uploads, artifact links, previews, and provider calls.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes unless map key supplies it | string | Stable resource identifier. In a top-level `resources` map, the map key is the name. Names must be unique within the document. |
| `method` | yes | GET, POST, upload, link | Operation type. `GET` reads data, `POST` submits JSON payloads, `upload` sends file items, and `link` resolves an artifact URL without fetching it. |
| `base` | no | module, portal, or named host resolver | Resolution base for `path`. Default is `module`. Named host resolvers are declared by the portal or local app host in [`RuntimeConfig`](./runtime-config) as stable resolver keys mapped to same-origin prefixes or explicitly allowed API origins. Unknown bases fail validation. |
| `path` | yes | same-origin or host-resolved path, or binding | Starts with `/` after binding resolution and must not contain `..`. `Resource.path` never accepts a direct `https:` URL; external APIs must be reached through a named `base` resolver and a path. Resolution failures, unsafe schemes, and unauthorized paths fail before request execution. |
| `payload` | no | binding map | Request body or query/upload fields. Keys are strings; values are scalars, arrays, objects, or `{ bind: ... }` values that resolve before dispatch. `GET` serializes payload as query values, `POST` sends JSON, `upload` sends file fields, and `link` rejects payload. For `upload`, file fields resolve to one file item or an array of file items from [DropZone](./drop-zone) or a file input; each item has string `name`, MIME `type`, byte-count `size`, and exactly one of `fileHandle`, local `path`, or `uploadToken`. |

## Boundary

Resource clients can be faked in unit tests. Resource definitions describe
transport intent only; authorization, tenant scoping, and provider semantics
stay in the host API or product module.

## Example

```yaml
resources:
  notes:
    method: GET
    base: module
    path: /api/notes
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

`Resource.path` is always a path beginning with `/`. The selected `base`
decides whether that path resolves under the module mount, portal root, or a
named host resolver. Direct `https:` values, `javascript:`, `data:`, path
traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./action">Action</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./effect">Effect</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
