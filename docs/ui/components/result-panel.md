---
title: ResultPanel UI component
description: Dedicated BusDK UI reference for ResultPanel.
---

## Purpose

`ResultPanel` is a data display component. Operation result surface. Use after submissions, imports, and provider actions.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `status` | yes | success, warning, danger, neutral | Result semantic. Use `success` only when the operation completed, `warning` when it completed with follow-up risk, `danger` when it failed or needs corrective action, and `neutral` for informational results without success/failure meaning. |
| `title` | yes | string | Result heading. |
| `summary` | no | string | Short detail. |
| `actions` | no | array of `{label,action,variant}` | Follow-up controls. `label` is public-safe text, `action` is a token declared in the document top-level `actions` map or registered in the Go/WASM action handler map, and optional `variant` is `primary`, `secondary`, or `danger`. Unknown action tokens fail validation. Keep the list short enough for the host layout, usually no more than three actions. |

## Boundary

Title, summary, and action labels are safe public text. Do not include raw
provider errors, credentials, private customer data, secret identifiers, or
internal stack traces. Use the [ProviderError](./provider-error) component for
sanitized provider failures, or convert a provider failure into a public
`title` and `summary` before passing it to `ResultPanel`.

## Example

```yaml
kind: ResultPanel
props:
  status: success
  title: Draft saved
  summary: Ready for review
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./loading-state">LoadingState</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./error-banner">ErrorBanner</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
