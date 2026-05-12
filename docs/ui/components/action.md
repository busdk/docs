---
title: Action UI runtime block
description: Dedicated BusDK UI reference for Action.
---

## Purpose

`Action` is an action/resource/effect runtime block. Stable user-triggered command. Use for submit, approve, archive, upload, send, stop, and jobs.

## Inputs

Action routing has three modes. A Go-routed action provides `handler` and the
Go/WASM runtime executes that typed handler. A server-routed action provides
`target` with `method: GET` or `method: POST` and submits to that endpoint. A
link action uses `method: link` with `target` and performs navigation.

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `token` | yes | lower-case hyphen token | Must match the enclosing `actions` map key when declared in a document; mismatches fail validation. |
| `handler` | required for Go-routed actions | registered Go handler | Executes command for this token. Go-routed `GET` and `POST` actions use `handler`; link actions omit it and navigate through `target`. |
| `method` | no | GET, POST, or link | Default `POST`; `GET` serializes query values, `POST` sends payload, `link` navigates. Values are case-insensitive and normalized to upper-case except `link`. |
| `target` | required for server-routed `GET`, server-routed `POST`, and `link` | resolver object or safe URL/path | Route for server forms or links. Resolver objects use `{ base, path }`, where `base` is `module`, `portal`, or a named host resolver, and `path` starts with `/` without `..`. String targets must be same-origin paths unless the host explicitly allowlists the external origin. When both `handler` and `target` are present, `handler` runs first and may return/override the target; otherwise the target is used directly. |
| `payload` | no | binding map | Omitted payload sends no body. `POST` sends body fields, `GET` serializes query fields, and `link` rejects payload. |

## Boundary

A button using `action: save-draft` dispatches this handler.

## Example

```yaml
actions:
  save-draft:
    token: save-draft
    method: POST
    handler: saveDraft
    target: { base: module, path: /draft/save }
    payload:
      title: { bind: draft.title }
view:
  kind: Button
  props:
    label: Save
    action: save-draft
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./session">Session</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./resource">Resource</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
