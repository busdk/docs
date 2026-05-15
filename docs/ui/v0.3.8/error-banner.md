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
| `dismiss` | no | event name | Optional event emitted by the close control. The parent clears the error state after the handler succeeds; omitted keeps the banner visible until parent state changes. |

## Boundary

Error text is escaped.

## Example

```yaml
events:
  dismiss-error:
    handler: clearCurrentError
body:
  kind: ErrorBanner
  props:
    message: Upload failed
    dismiss: dismiss-error
```

## Runtime Terms

[Event](../v0.1.6/event) defines event names, handler registration, validation, and confirmation policy.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
