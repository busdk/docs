---
title: UI feature candidate model
description: Feature candidate directories for future BusDK UI framework work.
---

## Current model

Implemented UI framework work uses semver patch directories. Unimplemented
future work uses `fc-<order>-<identifier>` directories until it is finished,
reviewed, implemented, and accepted. The [UI framework index](../) is the
source of truth for the current implemented sequence, feature candidate review
order, and promotion rule.

## Implemented sequence

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
| [v0.1.11](../v0.1.11/) | WASM app acceptance | `bus-gx` |
| [v0.1.12](../v0.1.12/) | Intrinsic callback naming | `bus-gx` |
| [v0.1.13](../v0.1.13/) | Handle render scheduling | `bus-gx` |
| [v0.1.14](../v0.1.14/) | Expanded intrinsic elements | `bus-gx` |
| [v0.1.15](../v0.1.15/) | Typed event payloads | `bus-gx` |
| [v0.1.16](../v0.1.16/) | Minimal browser adapters | `bus-gx` |
| [v0.1.17](../v0.1.17/) | State runtime | `bus-ui` |
| [v0.1.18](../v0.1.18/) | Effect runtime | `bus-ui` |
| [v0.1.19](../v0.1.19/) | Event and form helpers | `bus-ui` |
| [v0.1.20](../v0.1.20/) | UI testkit renderer | `bus-ui` |
| [v0.1.21](../v0.1.21/) | UI testkit browser parity | `bus-ui` |
| [v0.1.22](../v0.1.22/) | Action primitives | `bus-ui` |
| [v0.1.23](../v0.1.23/) | Resource primitives | `bus-ui` |
| [v0.1.24](../v0.1.24/) | Session primitives | `bus-ui` |
| [v0.1.25](../v0.1.25/) | Portal context consumption | `bus-ui` |
| [v0.1.26](../v0.1.26/) | Streaming ownership | `bus-ui` |
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

## Feature candidates

| Candidate | Review focus |
| --- | --- |
| `fc-004` through `fc-008` | Host-adjacent runtime surfaces. |
| `fc-009` through `fc-017` | Assistant and terminal product surfaces. |
| `fc-018` through `fc-026` | Evidence, media, product integration, references, and release review. |

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
