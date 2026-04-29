---
title: Architectural overview
description: BusDK is a collection of loosely coupled modules for CLIs, APIs, events, portals, runtime workers, and auditable workspace datasets.
---

## Module architecture

BusDK is a collection of loosely coupled modules for CLIs, API providers, event workers, portals, runtime clients, and auditable workspace datasets. It intentionally avoids a monolithic application design. Each feature area is implemented as an independent command, service, provider, or worker with a stable external contract.

For business-data modules, the stable interface is the workspace dataset: tables governed by schemas and organized in a consistent directory structure. For AI product modules, the stable interface may also be an HTTP route, event name, token scope, portal surface, or runtime worker contract. Modules should coordinate through those public contracts instead of calling each other's private internals.

This design mirrors the practical benefits of Unix composability in modern toolchains, where interoperability arises from stable, simple interfaces and predictable conventions. See [The Art of Unix Programming: Basics of the Unix Philosophy](https://www.catb.org/esr/writings/taoup/html/ch01s06.html). The preferred default for workspace data is a Git repository with CSV tables, but Git and CSV are implementation choices rather than the definition of the architectural goal. The broader goal is deterministic operation across local CLIs, self-hosted services, managed deployments, and reviewable data workflows.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./append-only-and-security">Append-only discipline and security model</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../architecture/index">BusDK Design Spec: System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./cli-as-primary-interface">CLI as the primary interface (controlled read/modify/write)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Architecture index](./index)
- [Data directory layout (principles)](../layout/layout-principles)
- [Design goals index](../design-goals/index)
- [Integration and runtime interfaces](../integration/index)
- [Deployment and data control](../integration/deployment-and-data-control)
