---
title: UI color and status
description: BusDK UI design rule for semantic color and status meaning.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)

## Rule

Use semantic color sparingly. Primary events should be clear but not dominant
across the entire page. Danger events are reserved for destructive or risky
operations.

Status surfaces use consistent meanings:

- neutral for informational or idle state;
- working for active background work;
- success for completed work;
- warning for blocked or attention-needed state;
- danger for errors, destructive events, or failed checks.

## Consequence

Color must not be the only signal. Status labels, titles, icons, and text must
carry the same meaning.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [StatusPill](./status-pill)
- [ResultPanel](./result-panel)
