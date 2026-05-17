---
title: Library assistant workbench
description: BusDK UI library assistant component map.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Expression children](../v0.1.5/expression-children)

## Purpose

This page maps the first assistant workbench pieces. FC-009 owns the workbench
shell and pane frame only: product content stays in the business slot, and
assistant content is passed into the assistant slot.

## Assistant Pages

[`AssistantShell`](./assistant-shell) owns the two-pane layout and collapse
behavior. [`AIPanel`](./ai-panel) owns the assistant-pane frame that later
assistant components can use as children.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AssistantShell](../fc-009-assistant-workbench-shell/assistant-shell)
- [AIPanel](./ai-panel)
