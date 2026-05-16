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
| `dismiss` | no | callback | Optional callback invoked by the close control. The parent clears the error state after the handler succeeds; omitted keeps the banner visible until parent state changes. |

## Boundary

Error text is escaped.

## Example

```gx
package notesui

var uploadError = (
  <ErrorBanner
    message="Upload failed"
    dismiss={clearCurrentError}
  ></ErrorBanner>
)
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
