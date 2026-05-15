---
title: Resource UI runtime block
description: Dedicated BusDK UI reference for Resource.
---

## Purpose

`Resource` is an event/resource/effect runtime block. External data or media contract. Use for APIs, uploads, artifact links, previews, and provider calls.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes unless map key supplies it | string | Stable resource identifier. In a top-level `resources` map, the map key is the name. Names must be unique within the controller. |
| `kind` | no | resource or link | Defaults to ordinary request resource behavior. Use `link` for artifact/navigation URLs that must be resolved but not fetched; link resources reject `method` and `payload`. |
| `method` | no | GET, POST, PUT, PATCH, DELETE, UPLOAD | Operation type for request resources. Defaults to `GET`. `UPLOAD` sends multipart file items. |
| `base` | no | module, portal, or named host resolver | Resolution base for `path`. Default is `module`. Named host resolvers are declared by the portal or local app host in `RuntimeConfig` as stable resolver keys mapped to same-origin prefixes or explicitly allowed API origins. Unknown bases fail validation. |
| `path` | yes | same-origin or host-resolved path, or binding | Starts with `/` after binding resolution and must not contain `..`. `Resource.path` never accepts a direct `https:` URL; external APIs must be reached through a named `base` resolver and a path. Resolution failures, unsafe schemes, and unauthorized paths fail before request execution. |
| `payload` | no | binding map | Request body, query, or upload fields chosen by the controller. Keys are strings; values are scalars, arrays, objects, or `{ bind: ... }` values that resolve when the resource receiver runs. `GET` and `DELETE` serialize payload as query values, `POST`, `PUT`, and `PATCH` send JSON, `UPLOAD` sends multipart file fields, and `kind: link` rejects payload. For `UPLOAD`, file fields resolve to one file item or an array of file items from DropZone or a file input; each item has string `name`, MIME `type`, byte-count `size`, and exactly one of `fileHandle`, local `path`, or `uploadToken`. |

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

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

`Resource.path` is always a path beginning with `/`. The selected `base`
decides whether that path resolves under the module mount, portal root, or a
named host resolver. Direct `https:` values, `javascript:`, `data:`, path
traversal, and unresolved authorization failures are rejected.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
