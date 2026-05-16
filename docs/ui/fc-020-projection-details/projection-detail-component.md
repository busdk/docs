---
title: ProjectionDetail UI component
description: Dedicated BusDK UI reference for ProjectionDetail.
---

## Purpose

`ProjectionDetail` is an evidence/media component. Ledger-like evidence detail. Use for accounting-style detail views linked to documents.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `detail` | yes | `ProjectionDetailModel` | Projected detail object with `Title`, optional `Summary`, and `Lines`. Each line has stable `ID`, display `Label`, display `Value`, and optional `EvidenceID`. Empty or missing `Lines` renders the component empty state instead of failing. |
| `evidence` | yes | `[]ProjectionEvidence` | Evidence items use `ID`, `Label`, `URL`, and optional `Type` fields. `ID`, `Label`, and `URL` are required; `ID` is stable and unique, `Label` is the visible link text, and `URL` is a same-origin path or host-resolved artifact URL. `Type` is optional and defaults to `link`; supplied values are display/media hints such as `pdf`, `image`, `text`, or `link`. Unknown evidence IDs referenced by lines render as unavailable links and may be reported through [runtime diagnostics](../v0.1.8/). |
| `selectedLine` | no | string | Highlights the matching `detail.Lines` entry by line `ID`. Empty, out-of-range, or unknown values select nothing. |

## Boundary

Ledger semantics stay in product modules. `ProjectionDetail` only renders the
already-projected view model and evidence links; it does not compute balances,
classify accounts, or infer accounting meaning from labels.

Evidence URLs must be same-origin paths beginning with `/` and containing no
`..`, or URLs returned by [`EvidenceURLResolver`](../fc-018-evidence-urls-links/evidence-url-resolver).
External origins are rejected unless the portal or local app host explicitly
lists the origin in the resolver allowlist before rendering. `javascript:`,
`data:`, path traversal, and unresolved authorization fail validation.

## Example

```gx
package evidenceui

import . "github.com/busdk/bus-ui/pkg/uievidence"

var entryDetail = (
  <ProjectionDetail
    detail={entry.Detail}
    evidence={entry.Evidence}
  ></ProjectionDetail>
)
```

When `entry.Detail.Lines` is non-empty, the component renders a title, line list,
and safe evidence links for matching `EvidenceID` values. Empty lines render the
component empty state.

```go
type ProjectionDetailModel struct {
	Title string
	Summary string
	Lines []ProjectionLine
}

type ProjectionLine struct {
	ID string
	Label string
	Value string
	EvidenceID string
}

type ProjectionEvidence struct {
	ID string
	Label string
	URL string
	Type string
}
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
