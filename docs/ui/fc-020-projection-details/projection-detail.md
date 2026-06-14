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
before render; raw private payloads are not valid input for this component.
Required unsafe title input fails closed, while unsafe optional fields and
evidence actions are omitted or disabled with diagnostics so the remaining safe
detail can still render.

Public-safe text may include labels, totals, public request ids, and evidence
names. It must not include credentials, bearer tokens, raw provider responses,
SQL, stack traces, private customer data, file contents, or prompt text.

`ProjectionDetail` receives one props value:

```go
type ControlLogSink func(level string, msg string)

type ProjectionDetailProps struct {
	Title    string
	Summary  string
	Fields   []ProjectionField
	Evidence []ProjectionEvidenceAction
	Attrs    map[string]string
	Log      ControlLogSink
}

type ProjectionField struct {
	Label string
	Value string
}
```

The table names the exported Go fields shown above.

| Field | Required | Behavior |
| --- | --- | --- |
| `Title` | yes | Non-empty public-safe string. Missing title fails closed before render; unsafe title returns a title diagnostic. Preferred rendering uses `ui.ProjectionDetail` plus `ui.RenderHTML`. |
| `Summary` | no | Public-safe string; unsafe summaries are omitted with diagnostics. |
| `Fields` | no | Public-safe label/value rows. `Value` is already formatted by the controller. |
| `Evidence` | no | `[]ProjectionEvidenceAction`. Each action has a stable `ID`, public-safe `Label`, `Operation` of `open`, `download`, or `preview`, and a host-authorized `URL`. `Filename` is required for `download`. `MediaType` is required for `preview` and must be `application/pdf`, `image/png`, `image/jpeg`, or `text/plain`. |
| `Attrs` | no | Root attributes limited to `id`, `class`, `role`, `title`, `data-*`, and `aria-*`. Event handlers, `style`, `href`, and other attributes are rejected with `ErrProjectionDetailUnsafeAttrs`. |
| `Log` | no | Optional sink for error, warning, and info validation/render events. `nil` is allowed, and logging does not change render output or validation results. |

`open` navigates to the safe URL in the current browsing context. `download`
uses the safe URL with the provided `Filename`. `preview` delegates to
[`EvidencePreview`](../fc-019-evidence-previews/evidence-preview-component) for
the allowed `MediaType` values. Same-origin relative URLs and HTTPS URLs that a
host resolver has already authorized are accepted by href validation. The host
owns exact external-origin allowlists and download policy before the action is
constructed.

```go
type ProjectionEvidenceAction struct {
	ID        string
	Label     string
	Operation string
	URL       string
	Filename  string
	MediaType string
}
```

Validation produces a sanitized render model before output. Raw provider
payloads, private customer data, tokens, SQL, stack traces, credential headers,
and other unsafe field values are omitted from the rendered detail. Unsafe
evidence actions render as unavailable links. The checked helper still renders
the remaining safe detail and returns diagnostics with the result:

```go
var diagnostic = ui.ProjectionDetailDiagnostic{
	Type:      "validation",
	Component: "ProjectionDetail",
	Field:     "fields[0].value",
	Reason:    "unsafe-content",
}
```

The product view model owns which fields are visible and how evidence relates
to the product workflow. `ui.ProjectionDetail` plus `ui.RenderHTML` is the
current-facing node-first path.

## Legacy compatibility

The compatibility helper remains available for callers that still need the
historical checked helper and diagnostics.

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
- [Evidence](../fc-018-evidence-urls-links/evidence)
