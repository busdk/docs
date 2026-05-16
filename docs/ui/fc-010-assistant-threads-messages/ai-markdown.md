---
title: AIMarkdown UI component
description: Dedicated BusDK UI reference for AIMarkdown.
---

## Purpose

`AIMarkdown` renders safe assistant Markdown for transcript content that needs
links or code blocks.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `text` | yes | string | Markdown source. |
| `links` | no | workspace-paths, external-safe, none | Default `external-safe`. `workspace-paths` allows host-resolved workspace links, `external-safe` allows `https:` links with safe target attributes, and `none` renders link text without anchors. |
| `code` | no | boolean | Enable code blocks; default true. When false, fenced code blocks render as escaped plain text, not executable or highlighted HTML. |

## Boundary

The component renders sanitized markup in its own GX node tree. Blocked links
render as plain text so the transcript remains readable without creating unsafe
navigation. Use `AIMessage` with escaped `text` when rich Markdown rendering is
not needed.

## Example

```gx
var rendered = <AIMarkdown text={message.Text} links="workspace-paths"></AIMarkdown>
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

[Resource](../v0.4.1/resource) defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
