---
title: UI runtime contract
description: BusDK UI runtime contract for resources and Go callback helpers.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Runtime helpers are small and composable. The runtime accepts typed Go callback
props and resource declarations from application code or fixture runtime config.

- Callback props call Go functions directly. A callback may update Go state,
  request a resource, navigate through a host helper, or call another product
  function.
- `resources.*` declares `base`, `path`, optional `method`, and optional
  payload or decode settings. `base` is `module`, `portal`, or a named host
  resolver. `path` begins with `/` and contains no `..`.

Named host resolvers are declared by the host before fixture validation. A
resolver name is lower-case kebab-case, maps to a same-origin base path or an
explicitly allowlisted HTTPS origin, and rejects generated URLs with
`javascript:`, `data:`, `..`, or an unallowlisted origin.

Callback helper object forms are mutually exclusive when fixtures need a
portable shape:

| Receiver | Required Fields | Behavior |
| --- | --- | --- |
| `handler` | `handler` string | Calls a named Go fixture helper. Unknown names fail validation. |
| `resource` | `resource` string | Executes a named resource. The payload comes from the callback's current Go state or fixture data. |
| `navigate` | `navigate` string or object | Requests host navigation. Strings are same-origin absolute paths beginning with `/`. Object form uses `base` and `path`; `base` defaults to `module` and is `module`, `portal`, or a named host resolver. Unsafe paths and external origins without allowlist fail validation. |

Examples:

```yaml
click:
  handler: saveDraft
```

```yaml
submit:
  resource: notes
```

```yaml
click:
  navigate:
    base: module
    path: /notes
```

Resource declarations use these constraints:

| Field | Rule |
| --- | --- |
| `kind` | Optional resource kind. Omit for HTTP resources; use `link` for safe navigation/download links. Link resources reject `method`, `payload`, and `decode`. |
| `method` | Defaults to `GET`; allowed values are `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, and `UPLOAD`. Links use `kind: link` and reject payload. |
| `base` | Defaults to `module`; allowed values are `module`, `portal`, or a named host resolver. |
| `path` | Required, begins with `/`, and rejects `..`, `javascript:`, `data:`, and direct external URLs. |
| `payload` | Optional data map supplied by the callback or fixture. `GET` and `DELETE` serialize it as query values, `POST`, `PUT`, and `PATCH` as JSON, `UPLOAD` as multipart file fields, and `kind: link` rejects payload. |
| `decode` | Optional response decoder name; unknown decoders fail validation and decode failures return provider errors. |

Callback results are typed when a helper returns a structured result:

| Result | Required Shape | Handling |
| --- | --- | --- |
| success | `{type:"success"}` plus optional public result data | Controller applies state updates or refreshes resources. |
| validation error | `{type:"validation-error", fields:[...]}` | Field errors are projected into the view model. |
| provider error | `{type:"provider-error", title}` plus optional `summary`, `status`, `requestID`, and `fields` | Render through provider-safe error state. |
| navigation request | `{type:"navigate", path}` or host resolver object | Host performs safe navigation. |
| no-op | `{type:"noop"}` | No state change beyond clearing pending event state. |

Provider errors must not expose secrets, bearer tokens, raw credentials, stack
traces, SQL, or raw provider payloads.

Each field error has required `path` and `code` strings plus optional
public-safe `message`. `path` is a dot-separated field path such as `title` or
`items.0.name`; each segment is an identifier or non-negative index. `code` is
lower-case kebab-case. Multiple errors are represented by multiple objects in
the `fields` array.

Unknown callback helper names fail validation before render or dispatch.
Resource decode failures return typed provider errors. Validation diagnostics
identify the source path, callback or resource name, field, and error code.

## Consequence

Every runtime helper must expose test seams: injectable callback helpers, fake
resource clients, and observable state updates. Unit tests should cover success
and handler/resource failure. E2e tests should cover only the host bridge and
one representative browser workflow for helpers that depend on browser APIs.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Callback props](../v0.1.6/callback-props)
- [Resource UI concept](../v0.4.1/resource)
- [Mounting and updates](../v0.1.7/mounting-updates)
