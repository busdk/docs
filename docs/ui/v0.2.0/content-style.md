---
title: UI content style
description: BusDK UI design rule for operational app copy and errors.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Rule

App copy should be direct and operational. Prefer "Approval required",
"No notes match the current filters", or "Upload failed" over vague messages.

Avoid in-app teaching text about the framework, implementation details,
keyboard shortcuts, or visual design. The UI should reveal possible operations
through structure and controls.

## Consequence

Error messages should name the failed operation and the next useful step when
known. Do not show secrets, raw tokens, private customer data, or unfiltered
provider payloads in UI diagnostics.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- ProviderError
- ErrorBanner
