---
title: UI component map
description: Compact map from Bus UI Core and Library groups to dedicated component pages.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [GX source tools](../v0.1.2/source-tools)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Component Groups

BusDK UI components are grouped into independently reviewable layers.
[Core](../v0.1.1/) is the `bus-gx` minimal HTML-compatible foundation used by
[GX template entries](../v0.1.3/template-entries) and by component
implementations.
The [Bus UI module baseline](../v0.2.0/design-system) starts `bus-ui` as a
module that can host several libraries. Common component libraries come first,
then runtime helpers, assistant UI, terminal UI, evidence UI, and product or
portal integration. Each layer page links to the canonical
[component reference](./component-reference) for individual component pages.

Core:

1. `v0.1.1` [Foundation](../v0.1.1/)
2. `v0.1.2` [GX source tools](../v0.1.2/)
3. `v0.1.3` [GX compiler](../v0.1.3/)
4. `v0.1.4` [Component calls](../v0.1.4/)
5. `v0.1.5` [Component composition](../v0.1.5/)
6. `v0.1.6` [Callback props](../v0.1.6/)
7. `v0.1.7` [Go WASM frontend runtime](../v0.1.7/)
8. `v0.1.8` [Runtime diagnostics](../v0.1.8/)
9. `v0.1.9` [Browser API boundaries](../v0.1.9/)
10. `v0.1.10` [Test helpers](../v0.1.10/)

Common component libraries:

1. `v0.2.0` [Bus UI module baseline](../v0.2.0/)
2. `v0.2.1` [Icons](../v0.2.1/)
3. `v0.2.2` [Buttons and links](../v0.2.2/)
4. `v0.2.3` [Menus and tabs](../v0.2.3/)
5. `v0.2.4` [Panels and cards](../v0.2.4/)
6. `v0.2.5` [Layout helpers](../v0.2.5/)
7. `v0.2.6` [Shells](../v0.2.6/)
8. `v0.3.1` [Forms](../v0.3.1/)
9. `v0.3.2` [Form fields](../v0.3.2/)
10. `v0.3.3` [Input controls](../v0.3.3/)
11. `v0.3.4` [Submit state](../v0.3.4/)
12. `v0.3.5` [Tables](../v0.3.5/)
13. `v0.3.6` [Lists](../v0.3.6/)
14. `v0.3.7` [Timelines](../v0.3.7/)
15. `v0.3.8` [Status surfaces](../v0.3.8/)
16. `v0.4.1` [Resources](../v0.4.1/)
17. `v0.4.2` [Runtime config and API URLs](../v0.4.2/)
18. `v0.4.3` [Sessions](../v0.4.3/)
19. `v0.4.4` [Credentials](../v0.4.4/)
20. `v0.4.5` [Provider errors](../v0.4.5/)
21. `v0.4.6` [Assets and host tools](../v0.4.6/)

Higher-level Bus UI libraries:

1. `v0.5.1` [Assistant workbench shell](../v0.5.1/)
2. `v0.5.2` [Assistant threads and messages](../v0.5.2/)
3. `v0.5.3` [Assistant composer and attachments](../v0.5.3/)
4. `v0.5.4` [Assistant model selection](../v0.5.4/)
5. `v0.5.5` [Assistant review controls](../v0.5.5/)
6. `v0.6.1` [Terminal sessions](../v0.6.1/)
7. `v0.6.2` [Terminal IO](../v0.6.2/)
8. `v0.6.3` [Terminal approvals](../v0.6.3/)
9. `v0.6.4` [Terminal adapter](../v0.6.4/)
10. `v0.7.1` [Evidence URLs and links](../v0.7.1/)
11. `v0.7.2` [Evidence previews](../v0.7.2/)
12. `v0.7.3` [Projection details](../v0.7.3/)
13. `v0.8.1` [File drops](../v0.8.1/)
14. `v0.8.2` [Image galleries](../v0.8.2/)

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](./component-reference)
- [UI implementation roadmap](../)
- [bus-ui module reference](../../modules/bus-ui)
