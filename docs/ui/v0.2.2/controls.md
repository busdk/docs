---
title: UI controls
description: BusDK UI design rule for choosing controls and stable event names.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Rule

Use familiar controls for the job: icon buttons for compact tools, text
buttons for clear commands, tabs or sidebar nav for views, toggles or
checkboxes for binary settings, select menus for bounded options, and inputs or
textareas for free-form values.

Icon-only controls must provide `aria-label` or equivalent text. A tooltip or
HTML `title` alone is not a reliable accessible name.

Events must have stable names. Rendered buttons expose deterministic event
names such as `save-draft` or `send`, and the Go WebAssembly event router maps
those names to typed handlers.

## Consequence

Do not invent local browser behavior for standard event dispatch, mode
switching, input collection, or navigation controls.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Callback props](../v0.1.6/callback-props)
- [Button](./button)
- [IconButton](./icon-button)
