---
title: Library projection detail
description: BusDK UI library projected evidence detail contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`ProjectionDetail`](./projection-detail-component) renders public-safe
projection summary and evidence references. Provider payloads are projected
before render; raw private payloads are rejected.

Public-safe text may include labels, totals, public request ids, and evidence
names. It must not include credentials, bearer tokens, raw provider responses,
SQL, stack traces, private customer data, file contents, or prompt text.

`ProjectionDetail` receives one props value:

```go
type ProjectionDetailProps struct {
	Title string
	Summary string
	Fields []ProjectionField
	Evidence []ProjectionEvidenceAction
}

type ProjectionField struct {
	Label string
	Value string
}
```

The table names the GX attributes; they map to the exported Go fields shown
above.

| GX attribute | Required | Behavior |
| --- | --- | --- |
| `title` | yes | Non-empty public-safe string. |
| `summary` | no | Public-safe string; omitted when unavailable. |
| `fields` | no | Array of `{label,value}` strings. `label` is non-empty public-safe text; `value` is public-safe text or number formatted by the controller. |
| `evidence` | no | `[]ProjectionEvidenceAction`. `ID` is non-empty provider evidence id, `Label` is public-safe text, and `Operation` is `open`, `download`, or `preview`. `URL` is required for all operations and must be same-origin beginning with `/` or returned by [`EvidenceURLResolver`](../v0.7.1/evidence-url-resolver). External URLs are accepted only when they were produced by a named evidence resolver whose exact origin is present in host runtime config `externalEvidenceOrigins`; `javascript:`, `data:`, path traversal, and other external origins are rejected. `Filename` is required for `download`. `MediaType` is required for `preview` and must be `application/pdf`, `image/png`, `image/jpeg`, or `text/plain`. |

`open` navigates to the safe URL in the current browsing context. `download`
uses the safe URL with the provided `Filename` and requires host permission to
start a download. `preview` renders an embedded or linked preview only for the
allowed `MediaType` values. `externalEvidenceOrigins` is a host runtime config
list of exact origins, for example `https://evidence.example.test`.

```go
type ProjectionEvidenceAction struct {
	ID string
	Label string
	Operation string
	URL string
	Filename string
	MediaType string
}
```

Validation produces a sanitized render model before output. Raw provider
payloads, private customer data, tokens, SQL, stack traces, credential headers,
and other unsafe field values are omitted from the rendered detail. Unsafe
evidence actions render as unavailable links. The component still renders the
remaining safe detail and reports diagnostics through the runtime error path:

```go
var diagnostic = RuntimeDiagnostic{
	Type:      "validation",
	Component: "ProjectionDetail",
	Field:     "fields[0].value",
	Reason:    "unsafe-content",
}
```

The product view model owns which fields are visible and how evidence relates
to the product workflow.

## Consequence

Projection detail displays inspectable evidence context without exposing raw
provider payloads.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [ProjectionDetail](./projection-detail-component)
- [Evidence](../v0.7.1/evidence)
