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
| `evidence` | yes | array of evidence items | Evidence items use `id`, `label`, `url`, and optional `type` fields. `id`, `label`, and `url` are required; `id` is stable and unique, `label` is the visible link text, and `url` follows the safe URL rules below. `type` is optional and defaults to `link`; supplied values are display/media hints such as `pdf`, `image`, `text`, or `link`. Unknown evidence IDs referenced by lines render as unavailable links and are reported through [ErrorHost](../v0.1.9/error-host). |
| `selectedLine` | no | line id or zero-based index | Highlights the matching `detail.lines` entry. String values match line `id`; numbers match zero-based line index. Missing, out-of-range, or unknown values select nothing. |

## Boundary

Ledger semantics stay in product modules. `ProjectionDetail` only renders the
already-projected view model and evidence links; it does not compute balances,
classify accounts, or infer accounting meaning from labels.

Evidence URLs must be same-origin paths beginning with `/` and containing no
`..`, or host artifact resolver objects with string `base` and `path` fields.
Resolver `base` names a host-registered artifact resolver; `path` begins with
`/`, contains no `..`, and resolves to an authorized same-origin artifact URL
before rendering. External origins are rejected unless the portal or local app
host explicitly lists the origin in its artifact URL allowlist before
rendering. `javascript:`, `data:`, path traversal, and unresolved authorization
fail validation.

## Example

```yaml
kind: ProjectionDetail
props:
  detail:
    bind: entry.detail
  evidence:
    bind: entry.evidence
```

## Runtime Terms

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
