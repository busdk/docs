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
The implemented catalog is also available through `ComponentCatalog`,
`WriteComponentCatalog`, and `bus-ui catalog --format json` for docs-owned
generation jobs.

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
17. `fc-004` [Runtime config and API URLs](../fc-004-runtime-config-api-urls/)
18. `fc-005` [Sessions](../fc-005-sessions/)
19. `fc-006` [Credentials](../fc-006-credentials/)
20. `fc-007` [Provider errors](../fc-007-provider-errors/)
21. `fc-008` [Assets and host tools](../fc-008-assets-host-tools/)

Higher-level Bus UI libraries:

1. `fc-009` [Assistant workbench shell](../fc-009-assistant-workbench-shell/)
2. `fc-010` [Assistant threads and messages](../fc-010-assistant-threads-messages/)
3. `fc-011` [Assistant composer and attachments](../fc-011-assistant-composer-attachments/)
4. `fc-012` [Assistant model selection](../fc-012-assistant-model-selection/)
5. `fc-013` [Assistant review controls](../fc-013-assistant-review-controls/)
6. `fc-014` [Terminal sessions](../fc-014-terminal-sessions/)
7. `fc-015` [Terminal IO](../fc-015-terminal-io/)
8. `fc-016` [Terminal approvals](../fc-016-terminal-approvals/)
9. `fc-017` [Terminal adapter](../fc-017-terminal-adapter/)
10. `fc-018` [Evidence URLs and links](../fc-018-evidence-urls-links/)
11. `fc-019` [Evidence previews](../fc-019-evidence-previews/)
12. `fc-020` [Projection details](../fc-020-projection-details/)
13. `fc-021` [File drops](../fc-021-file-drops/)
14. `fc-022` [Image galleries](../fc-022-image-galleries/)

Catalog and tooling:

1. `fc-023` [Component catalog](./)
2. `fc-024` [Declarative artifacts](../fc-024-declarative-artifacts/)

The catalog groups entries as concepts, components, runtime helpers, or tools
and marks each entry as implemented, external, or compatibility-only. It records
the public docs path and the package symbols that back implemented entries:
current node-first surfaces use `ui`, `assistantui`, `terminalui`, or
`uiportal`, while compatibility-only entries may still point at `pkg/uikit`
internals. JSON output is limited to catalog metadata; public component
examples remain Go or `.gx`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](./component-reference)
- [UI implementation roadmap](../)
- [bus-ui module reference](../../modules/bus-ui)
