---
title: Library timelines
description: BusDK UI library ordered event history contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`Timeline`](./timeline) renders ordered event history supplied by
the controller. Items need public-safe body text and may include time, sequence
text, status, and metadata.

| Field | Required | Behavior |
| --- | --- | --- |
| `body` | yes | Escaped public-safe string. Remove or project tokens, secrets, raw payloads, stack traces, SQL, and private customer data before render. |
| `time` | no | RFC 3339 timestamp string; omitted when time is not shown. |
| `sequence` | no | Public-safe ordering label; omitted when time is enough. |
| `status` | no | `neutral`, `working`, `success`, `warning`, `danger`, or `muted`; defaults to `neutral`. |
| `meta` | no | Ordered array of `{label, value}` objects; both fields are required public-safe strings. Defaults empty. |

The controller owns sorting and filtering. The component renders the supplied
order and reports invalid item shapes before render.

## Consequence

Timeline rendering is reusable because temporal meaning and event selection
stay in the product view model.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Timeline](./timeline)
- State UI concept
