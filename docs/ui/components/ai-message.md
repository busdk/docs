---
title: AIMessage UI component
description: Dedicated BusDK UI reference for AIMessage.
---

## Purpose

`AIMessage` renders one transcript entry for `user`, `assistant`, or `system`
roles in an assistant conversation.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `role` | yes | user, assistant, system | Message role. |
| `text` | yes unless `html` is provided | plain text | Escaped content. Exactly one of `text` or `html` is required. |
| `html` | yes unless `text` is provided | trusted HTML | Alternative to `text`; accepted only from `AIMarkdown` or an equivalent audited sanitizer. Both `text` and `html` together fail validation. |

## Boundary

Raw HTML is accepted only after sanitization by `AIMarkdown` or an equivalent
audited renderer. Prefer `text` for normal messages because it is escaped by
default.

## Example

```yaml
kind: AIMessage
props:
  role: assistant
  text: Tests passed
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-thread-list">AIThreadList</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-markdown">AIMarkdown</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
