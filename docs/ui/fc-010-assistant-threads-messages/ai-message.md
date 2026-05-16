---
title: AIMessage UI component
description: Dedicated BusDK UI reference for AIMessage.
---

## Purpose

`AIMessage` renders one transcript entry for a user, assistant, system, or tool
message.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `role` | yes | user, assistant, system, tool | Message role. Unknown roles fail validation. |
| `text` | yes unless `html` is provided | plain text | Escaped content. Exactly one of `text` or `html` is required. |
| `html` | yes unless `text` is provided | trusted HTML | Alternative to `text`; accepted only when `sanitizer` identifies `AIMarkdown` or an equivalent audited sanitizer. Both `text` and `html` together fail validation. |
| `sanitizer` | required with `html` | string | Stable sanitizer id and version, such as `bus-markdown/v1`. |

## Boundary

Raw HTML is accepted only after sanitization by `AIMarkdown` or an equivalent
audited renderer. Prefer `text` for normal messages because it is escaped by
default. Product views own message ordering, redaction, and visibility.

## Example

```gx
var message = <AIMessage role="assistant" text="Tests passed"></AIMessage>
```

```gx
var rendered = <AIMessage
  role="assistant"
  html={markdownHTML}
  sanitizer="bus-markdown/v1">
</AIMessage>
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
