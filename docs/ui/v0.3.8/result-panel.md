---
title: ResultPanel UI component
description: Dedicated BusDK UI reference for ResultPanel.
---

## Purpose

`ResultPanel` is a data display component. Operation result surface. Use after submissions, imports, and provider events.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `status` | yes | success, warning, danger, neutral | Result semantic. Use `success` only when the operation completed, `warning` when it completed with follow-up risk, `danger` when it failed or needs corrective event, and `neutral` for informational results without success/failure meaning. |
| `title` | yes | string | Result heading. |
| `summary` | no | string | Short detail. |
| `events` | no | array | Follow-up controls using the [`EventBar`](../v0.2.5/event-bar) item shape. Each item has public-safe `label`, `click` naming a runtime `events` entry or registered Go handler, and optional `variant` of `primary`, `secondary`, or `danger`. Unknown event names fail validation. Keep the list short enough for the host layout, usually no more than three events. |

## Boundary

Title, summary, and event labels are safe public text. Do not include raw
provider errors, credentials, private customer data, secret identifiers, or
internal stack traces. Use the ProviderError component for
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

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
