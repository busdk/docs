---
title: Bus UI module baseline
description: Bus UI common library boundaries and shared design rules.
---

## Design Layers

The `bus-ui` module starts as a set of small reusable libraries built on the
completed `bus-gx` Core patches. The first libraries cover common functional
parts before assistant, terminal, evidence, portal-host, or product-module
concepts.

`bus-ui` is not one monolithic UI library. It can contain independent common
component libraries, runtime helper libraries, assistant UI, terminal UI,
evidence UI, and host integration libraries when those layers become concrete.
Each library should depend on lower layers and keep provider authority,
product-specific workflow policy, and portal hosting in their owning modules.

1. [Product character](./product-character) defines the operational tone that
   higher product surfaces may apply.
2. [Content style](./content-style) defines app copy and error wording.
3. [Accessibility and safety](./accessibility-safety) defines accessible names,
   safe links, and raw-content boundaries.
4. Common component patches then add icons, buttons, links, menus, tabs,
   panels, cards, layout helpers, shells, forms, inputs, tables, lists,
   timelines, and status surfaces.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../../modules/bus-ui)
