---
title: UI implementation roadmap
description: Versioned implementation order for the BusDK UI framework.
---

## Rule

Each version directory is the source of truth for that implementation step.
The roadmap only gives the reading order. Implementation details, examples,
concept pages, and acceptance checks live under the version that first
implements them.

Earlier version pages may link to completed prerequisites. They must not link
forward to later work. When a later version changes a concept, add the change
under that later version instead of rewriting older version intent.

## Order

| Version | Patch | Module |
| --- | --- | --- |
| [v0.1.1](../v0.1.1/) | Core node foundation | `bus-gx` |
| [v0.1.2](../v0.1.2/) | GX source tools | `bus-gx` |
| [v0.1.3](../v0.1.3/) | GX compiler | `bus-gx` |
| [v0.1.4](../v0.1.4/) | Component calls | `bus-gx` |
| [v0.1.5](../v0.1.5/) | Component composition | `bus-gx` |
| [v0.1.6](../v0.1.6/) | Callback props | `bus-gx` |
| [v0.1.7](../v0.1.7/) | Go WASM frontend runtime | `bus-gx` |
| [v0.1.8](../v0.1.8/) | Runtime diagnostics | `bus-gx` |
| [v0.1.9](../v0.1.9/) | Browser API boundaries | `bus-gx` |
| [v0.1.10](../v0.1.10/) | Core test helpers | `bus-gx` |
| [v0.2.0](../v0.2.0/) | Bus UI module baseline | `bus-ui` |
| [v0.2.1](../v0.2.1/) | Icons | `bus-ui` |
| [v0.2.2](../v0.2.2/) | Buttons and links | `bus-ui` |
| [v0.2.3](../v0.2.3/) | Menus and tabs | `bus-ui` |
| [v0.2.4](../v0.2.4/) | Panels and cards | `bus-ui` |
| [v0.2.5](../v0.2.5/) | Layout helpers | `bus-ui` |
| [v0.2.6](../v0.2.6/) | Shells | `bus-ui` |
| [v0.3.1](../v0.3.1/) | Forms | `bus-ui` |
| [v0.3.2](../v0.3.2/) | Form fields | `bus-ui` |
| [v0.3.3](../v0.3.3/) | Input controls | `bus-ui` |
| [v0.3.4](../v0.3.4/) | Submit state | `bus-ui` |
| [v0.3.5](../v0.3.5/) | Tables | `bus-ui` |
| [v0.3.6](../v0.3.6/) | Lists | `bus-ui` |
| [v0.3.7](../v0.3.7/) | Timelines | `bus-ui` |
| [v0.3.8](../v0.3.8/) | Status surfaces | `bus-ui` |
| [v0.4.1](../v0.4.1/) | Resources | `bus-ui` |
| [v0.4.2](../v0.4.2/) | Runtime config and API URLs | `bus-ui` |
| [v0.4.3](../v0.4.3/) | Sessions | `bus-ui` |
| [v0.4.4](../v0.4.4/) | Credentials | `bus-ui` |
| [v0.4.5](../v0.4.5/) | Provider errors | `bus-ui` |
| [v0.4.6](../v0.4.6/) | Assets and host tools | `bus-ui` |
| [v0.5.1](../v0.5.1/) | Assistant workbench shell | `bus-ui` |
| [v0.5.2](../v0.5.2/) | Assistant threads and messages | `bus-ui` |
| [v0.5.3](../v0.5.3/) | Assistant composer and attachments | `bus-ui` |
| [v0.5.4](../v0.5.4/) | Assistant model selection | `bus-ui` |
| [v0.5.5](../v0.5.5/) | Assistant review controls | `bus-ui` |
| [v0.6.1](../v0.6.1/) | Terminal sessions | `bus-ui` |
| [v0.6.2](../v0.6.2/) | Terminal IO | `bus-ui` |
| [v0.6.3](../v0.6.3/) | Terminal approvals | `bus-ui` |
| [v0.6.4](../v0.6.4/) | Terminal adapter | `bus-ui` |
| [v0.7.1](../v0.7.1/) | Evidence URLs and links | `bus-ui` |
| [v0.7.2](../v0.7.2/) | Evidence previews | `bus-ui` |
| [v0.7.3](../v0.7.3/) | Projection details | `bus-ui` |
| [v0.8.1](../v0.8.1/) | File drops | `bus-ui` |
| [v0.8.2](../v0.8.2/) | Image galleries | `bus-ui` |
| [v0.9.1](../v0.9.1/) | Component catalog | `docs` |
| [v0.9.2](../v0.9.2/) | Declarative artifacts | `docs` |
| [v0.9.3](../v0.9.3/) | Product module integration | `docs` |
| [v0.9.4](../v0.9.4/) | Examples, testing, and release review | `docs` |

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
