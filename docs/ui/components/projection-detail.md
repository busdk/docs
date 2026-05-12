---
title: ProjectionDetail UI component
description: Dedicated BusDK UI reference for ProjectionDetail.
---

## Purpose

`ProjectionDetail` is an evidence/media component. Ledger-like evidence detail. Use for accounting-style detail views linked to documents.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `detail` | yes | view model | Projected detail object with `title` string, optional `summary` string, and `lines` array. Each line has stable `id`, display `label`, display `value`, and optional `evidenceID`. Empty or missing `lines` renders the component empty state instead of failing. |
| `evidence` | yes | array of evidence items | Evidence items use `{id,label,url,type}`. `id`, `label`, and `url` are required; `id` is stable and unique, `label` is the visible link text, and `url` follows the safe URL rules below. `type` is optional and defaults to `link`; supplied values are display/media hints such as `pdf`, `image`, `text`, or `link`. Unknown evidence IDs referenced by lines render as unavailable links and are reported through [ErrorHost](./error-host). |
| `selectedLine` | no | line id or zero-based index | Highlights the matching `detail.lines` entry. String values match line `id`; numbers match zero-based line index. Missing, out-of-range, or unknown values select nothing. |

## Boundary

Ledger semantics stay in product modules. `ProjectionDetail` only renders the
already-projected view model and evidence links; it does not compute balances,
classify accounts, or infer accounting meaning from labels.

Evidence URLs must be one of these forms: a same-origin path beginning with `/`
and containing no `..`, or a host artifact resolver object such as
`{ "base": "artifact", "path": "/evidence/receipt.pdf" }`. External origins
are rejected unless the portal or local app host explicitly lists the origin in
its artifact URL allowlist before rendering. `javascript:`, `data:`, path
traversal, and unresolved authorization fail validation.

## Example

```yaml
kind: ProjectionDetail
props:
  detail: { bind: entry.detail }
  evidence: { bind: entry.evidence }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./evidence-preview">EvidencePreview</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./drop-zone">DropZone</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
