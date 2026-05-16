---
title: Library assistant messages
description: BusDK UI library assistant message rendering contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Expression children](../v0.1.5/expression-children)

## Contract

[`AIMessage`](./ai-message) renders role-specific assistant
messages. [`AIMarkdown`](./ai-markdown) renders safe assistant
Markdown. Raw provider text is escaped. Trusted HTML must identify the
sanitizer before it reaches rendering.

Messages need role plus text or trusted HTML.

| Field | Required | Behavior |
| --- | --- | --- |
| `role` | yes | `user`, `assistant`, `system`, or `tool`. Unknown roles fail validation. |
| `text` | no | Escaped message text. Used when `trustedHTML` is absent. |
| `trustedHTML` | no | Sanitized HTML fragment. Takes precedence over `text` only when `sanitizer` is present. |
| `sanitizer` | required with `trustedHTML` | Stable sanitizer id and version, for example `bus-markdown/v1`. |

The product view model owns redaction, ordering, and visibility.

## Consequence

Assistant transcripts render consistently without trusting raw provider output.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIMessage](./ai-message)
- [AIMarkdown](./ai-markdown)
