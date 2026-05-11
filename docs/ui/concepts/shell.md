---
title: Shell UI concept
description: Dedicated BusDK UI framework concept page for Shell.
---

## Purpose

A shell owns durable page slots such as navigation, body, assistant, and footer. It frames content but does not decide product policy.

## Boundary

Use shells for app or portal chrome. Choose the host shell outside the UI
document: portal modules receive it from the portal mount configuration, local
Go/WASM apps choose it in their app host setup, and static/sample rendering
chooses it with the renderer command or test harness options described in
[Rendering](../architecture/rendering). The UI document should describe content and named
actions/resources, not deployment shell selection.

## Example

```yaml
concept: shell
usedBy:
  - component-reference
  - declarative-documents
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./component">Component</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./collection">Collection</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
