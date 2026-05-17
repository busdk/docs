---
title: Resource UI runtime block
description: Dedicated BusDK UI reference for Resource.
---

## Purpose

`Resource` declares transport intent for APIs, uploads, artifact links,
previews, and provider calls. Rendering a `Resource` does not fetch data. A Go
action, effect, or test fixture triggers the named resource through the runtime
resource client, and the result is delivered back to the invoking Go action
state or callback result.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes unless map key supplies it | string | Stable resource identifier. In a top-level `resources` map, the map key is the name. Names must be unique within the controller. |
| `kind` | no | resource or link | Defaults to ordinary request resource behavior. Use `link` for artifact/navigation URLs that must be resolved but not fetched; link resources reject `method` and `payload`. |
| `method` | no | GET, POST, PUT, PATCH, DELETE, UPLOAD | Operation type for request resources. Defaults to `GET`. `UPLOAD` sends multipart file items. |
| `base` | no | module, portal, or named host resolver | Resolution base for `path`. Default is `module`. Named host resolvers are declared by the portal or local app host in `RuntimeConfig` as stable resolver keys mapped to same-origin prefixes or explicitly allowed API origins. Unknown bases fail validation. |
| `path` | yes | same-origin or host-resolved path, or Go value | Starts with `/` after Go value resolution and must not contain `..`. `Resource.path` never accepts a direct `https:` URL; external APIs must be reached through a named `base` resolver and a path. Resolution failures, unsafe schemes, and unauthorized paths fail before request execution. |
| `payload` | no | Go data map | Optional default fields for the request. The declared shape is a Go value such as `map[string]any`, a typed struct converted by the resource helper, or an upload field map. The triggering action or effect may pass the same shape at dispatch time; dispatch data overrides matching declared keys. `GET` and `DELETE` serialize merged fields as query values, `POST`, `PUT`, and `PATCH` send them as JSON, `UPLOAD` sends multipart file fields, and `kind: link` rejects payload. For `UPLOAD`, file fields resolve to one file item or an array of file items from DropZone or a file input; each item has string `name`, MIME `type`, byte-count `size`, and exactly one of `fileHandle`, local `path`, or `uploadToken`. |

## Boundary

Resource clients can be faked in unit tests. Resource definitions describe
transport intent only; authorization, tenant scoping, and provider semantics
stay in the host API or product module.

## Example

```gx
package notesui

var notesResource = (
  <Resource name="notes" method="GET" base="module" path="/api/notes"></Resource>
)
```

Actions and effects execute the named resource with ordinary Go values such as
`map[string]any{"status": "open"}` or a typed request struct. The resource
client returns public success data, validation errors, provider errors, or
navigation/link results to the action or effect that started the request.
Components render those results through normal Go state and props.

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

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
