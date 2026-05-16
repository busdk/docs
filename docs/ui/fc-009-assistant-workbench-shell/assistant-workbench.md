---
title: Library assistant workbench
description: BusDK UI library assistant component map.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Expression children](../v0.1.5/expression-children)

## Purpose

This page maps the assistant workbench UI pieces. Use it when a product screen
supervises assistant threads, messages, drafts, model choice, attachments,
approvals, or isolated work state.

## Assistant Pages

1. [Assistant panel](./assistant-panel) composes the assistant pane.
2. Assistant threads renders thread selection.
3. Assistant messages renders transcript content.
4. Assistant composer renders draft input.
5. Assistant models renders model selection.
6. Assistant attachments renders approved attachment chips.
7. Assistant approvals renders pending decisions.
8. Assistant review status renders review-before-apply state.
9. Assistant work isolation renders work ownership and drop intake.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AssistantShell](../fc-009-assistant-workbench-shell/assistant-shell)
- [AIPanel](./ai-panel)
