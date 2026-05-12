---
title: ErrorBanner UI component
description: Dedicated BusDK UI reference for ErrorBanner.
---

## Purpose

`ErrorBanner` is a data display component. Recoverable error alert. Use for current-page retryable failures.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `message` | yes | string | Visible error. |
| `dismissAction` | no | action token | Optional clear command. Omitted keeps the banner visible until parent state changes. |

## Boundary

Error text is escaped.

## Example

```yaml
actions:
  dismiss-error:
    handler: clearCurrentError
body:
  kind: ErrorBanner
  props:
    message: Upload failed
    dismissAction: dismiss-error
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./result-panel">ResultPanel</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./runtime-config">RuntimeConfig</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
