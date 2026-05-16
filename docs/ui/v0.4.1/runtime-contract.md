---
title: UI runtime contract
description: BusDK UI runtime contract for resources and Go callback helpers.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Runtime helpers are small and composable. The runtime accepts typed Go callback
props and [resource declarations](resource) from application code. Browser and
e2e fixtures may also declare the same resource records in
`testdata/runtime.yaml` next to the test that uses them.

- Callback props call Go functions directly. A callback may update Go state,
  request a resource, navigate through a host helper, or call another product
  function.
- `resources.*` declares `base`, `path`, optional `method`, and optional
  payload or decode settings. `base` is `module`, `portal`, or a named host
  resolver. `path` begins with `/` and contains no `..`.

```gx
package notesui

var notesResource = (
  <Resource name="notes" method="GET" base="module" path="/api/notes"></Resource>
)
```

Named host resolvers are declared by the host before fixture validation. A
resolver name is lower-case kebab-case, maps to a same-origin base path or an
explicitly allowlisted HTTPS origin, and rejects generated URLs with
`javascript:`, `data:`, `..`, or an unallowlisted origin.

```go
type HostResolver interface {
	Resolve(base string, path string) (string, error)
}

func RegisterHostResolver(name string, resolver HostResolver) error
```

Callback helper object forms are mutually exclusive when fixtures need a
portable shape:

| Receiver | Required Fields | Behavior |
| --- | --- | --- |
| `handler` | `handler` string | Calls a named Go fixture helper. Unknown names fail validation. |
| `resource` | `resource` string | Executes a named resource. The payload comes from the callback's current Go state or fixture data. |
| `navigate` | `navigate` string or object | Requests host navigation. Strings are same-origin absolute paths beginning with `/`. Object form uses `base` and `path`; `base` defaults to `module` and is `module`, `portal`, or a named host resolver. Unsafe paths and external origins without allowlist fail validation. |

Examples use ordinary GX callback props:

```gx
package notesui

var saveAction = (
  <Button id="save-button" onClick={saveDraft} variant="primary">
    Save
  </Button>
)
```

```gx
package notesui

var noteForm = (
  <Form id="note-editor" method="POST" onSubmit={submitNotes}>
    <Button id="save-note" type="submit" variant="primary">
      Save
    </Button>
  </Form>
)
```

```gx
package notesui

var notesNavigation = (
  <Button id="open-notes" onClick={openNotes}>
    Open notes
  </Button>
)
```

The referenced callbacks are ordinary Go functions. `onClick` callbacks do not
receive browser state. `onSubmit` callbacks receive the submitted form state.

```go
func saveDraft() gx.Result {
	return gx.Noop()
}

func submitNotes(event gx.SubmitEvent) gx.Result {
	return gx.Success(map[string]string{"id": event.FormID})
}

func openNotes() gx.Result {
	return gx.Navigate("/notes")
}
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

Callback results use one canonical Go value. Fixture encoders serialize the
`Kind` field as `type` and omit zero-value optional fields.

```go
type Result struct {
	Kind      string
	Data      any
	Fields    []FieldError
	Title     string
	Summary   string
	Status    int
	RequestID string
	Path      string
	Base      string
}
```

Allowed `Kind` values are `success`, `validation-error`, `provider-error`,
`navigate`, and `noop`. Success may carry public result data. Validation errors
use `Fields`. Provider errors use `Title` plus optional `Summary`, `Status`,
`RequestID`, and `Fields`. Navigation uses `Path` and optional resolver `Base`.
No-op clears pending event state without changing application state.

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
