---
title: AIMarkdown UI component
description: Dedicated BusDK UI reference for AIMarkdown.
---

## Purpose

`AIMarkdown` is an assistant component. Safe assistant Markdown renderer. Use before passing rich assistant output to `AIMessage`.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `text` | yes | string/binding | Markdown source. |
| `links` | no | workspace-paths, external-safe, none | Default `external-safe`. `workspace-paths` allows host-resolved workspace links, `external-safe` allows `https:` links with safe target attributes, and `none` renders link text without anchors. |
| `code` | no | boolean | Enable code blocks; default true. When false, fenced code blocks render as escaped plain text, not executable or highlighted HTML. |

## Boundary

Output is sanitized HTML. Blocked links render as plain text so the transcript
remains readable without creating unsafe navigation.

## Example

```yaml
kind: AIMarkdown
props:
  text: { bind: message.text }
  links: workspace-paths
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-message">AIMessage</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-model-select">AIModelSelect</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
