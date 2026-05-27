---
title: ProjectionDetail UI component
description: Dedicated BusDK UI reference for ProjectionDetail.
---

## Purpose

`ProjectionDetail` renders one already-projected public detail with optional
evidence actions. It is generic evidence UI, not a ledger or accounting policy
engine.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `Title` | yes | string | Non-empty public-safe heading. Missing or unsafe title fails closed. |
| `Summary` | no | string | Public-safe summary text. Unsafe summary is omitted with a diagnostic. |
| `Fields` | no | `[]ProjectionField` | Public-safe label/value rows. Missing or unsafe rows are omitted with diagnostics. |
| `Evidence` | no | `[]ProjectionEvidenceAction` | Open, download, or preview actions that already contain host-authorized URLs. Invalid actions render disabled evidence text. |
| `Attrs` | no | `map[string]string` | Root attributes limited to safe identity, class, role, `title`, `data-*`, and `aria-*` keys. |
| `Log` | no | `ControlLogSink` | Receives validation, render, and preview events. |

`ProjectionField` contains `Label` and `Value`; both must be public-safe text.
Rows with missing labels, missing values, or unsafe content are omitted and
reported as diagnostics.

`ProjectionEvidenceAction` contains `ID`, `Label`, `Operation`, `URL`,
`Filename`, and `MediaType`. `Operation` must be `open`, `download`, or
`preview`. `URL` is required for every operation and must pass evidence href
validation. `Filename` is required only for `download`, and `MediaType` is
required only for `preview`. Invalid actions stay in the evidence list as
disabled unavailable controls instead of leaking unsafe hrefs.

## Boundary

Projection semantics stay in product modules. `ProjectionDetail` only renders a
public-safe view model and checked evidence actions; it does not compute
balances, classify accounts, infer accounting meaning, fetch provider payloads,
authorize documents, or access files.

Evidence URLs are safe same-origin paths or host-resolved HTTPS URLs. Exact
external-origin allowlists and provider authorization are host-owned decisions
made before the action reaches this component. `javascript:`, `data:`, path
traversal, unsafe filenames, missing IDs, unsupported operations, and
unsupported preview media render unavailable evidence actions.

## Example

{% raw %}
```go
package evidenceui

import "github.com/busdk/bus-ui/pkg/uikit"

func ReceiptDetail(url string) (uikit.ProjectionDetailResult, error) {
	return uikit.ProjectionDetailChecked(uikit.ProjectionDetailProps{
		Title:   "Receipt 2026-04-18",
		Summary: "Matched to expense report ER-2026-0418.",
		Fields: []uikit.ProjectionField{
			{Label: "Vendor", Value: "Helsinki Office Supplies"},
			{Label: "Total", Value: "EUR 42.80"},
		},
		Evidence: []uikit.ProjectionEvidenceAction{{
			ID:        "receipt-2026-04-18",
			Label:     "Preview receipt",
			Operation: string(uikit.EvidenceOperationPreview),
			URL:       url,
			MediaType: "application/pdf",
		}},
	})
}
```
{% endraw %}

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

`ProjectionDetailChecked` returns `ProjectionDetailResult` with rendered HTML
and `ProjectionDetailDiagnostic` entries for non-fatal omissions. The
compatibility `ProjectionDetail` helper returns an empty node when required
props fail validation.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
