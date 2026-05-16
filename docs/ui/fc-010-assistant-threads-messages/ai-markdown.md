---
title: AIMarkdown UI component
description: Dedicated BusDK UI reference for AIMarkdown.
---

## Purpose

`AIMarkdown` is an assistant component. Safe assistant Markdown renderer. Use before passing rich assistant output to `AIMessage`.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `text` | yes | string or Go value | Markdown source. |
| `links` | no | workspace-paths, external-safe, none | Default `external-safe`. `workspace-paths` allows host-resolved workspace links, `external-safe` allows `https:` links with safe target attributes, and `none` renders link text without anchors. |
| `code` | no | boolean | Enable code blocks; default true. When false, fenced code blocks render as escaped plain text, not executable or highlighted HTML. |

## Boundary

Output is sanitized HTML. Blocked links render as plain text so the transcript
remains readable without creating unsafe navigation.

## Example

```gx
var rendered = <AIMarkdown text={message.Text} links="workspace-paths"></AIMarkdown>
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

[Resource](../fc-003-resources/resource) defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
