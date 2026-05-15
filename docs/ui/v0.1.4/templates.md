---
title: UI templates
description: BusDK UI versioned template contract map.
---

## Contract

Compiled templates come from `.gx` files owned by `bus-gx`. The concrete
template contract is versioned:

1. [v0.1.2 GX source tools](../v0.1.2/) define `.gx` source shape,
   formatting, linting, and diagnostics.
2. [v0.1.3 GX compiler](../v0.1.3/) defines generated Go output and static
   render checks.
3. [v0.1.4 custom components](../v0.1.4/) defines reusable component tags,
   props, children, slots, and safe element adapter replacement.

Use GX templates when stable structure is clearer as markup than as direct Go
node construction. Use ordinary Go components when the tree shape changes
substantially by state.

## Consequence

Architecture pages link to the versioned template contracts instead of
restating parser, compiler, command, or diagnostic behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [v0.1.2 GX source tools](../v0.1.2/)
- [v0.1.3 GX compiler](../v0.1.3/)
- [v0.1.4 custom components](../v0.1.4/)
