---
title: "BusDK Design Spec: System architecture"
description: System architecture section — CLI as primary interface, Git-backed data, independent modules, validation.
---

## In this section

This section is split into **single-concept** documents:

- [Append-only discipline and security model](./append-only-and-security)
- [Architectural overview](./architectural-overview)
- [CLI as the primary interface (controlled read/modify/write)](./cli-as-primary-interface)
- [Git-backed data repository (the data store)](./git-backed-data-store)
- [Independent modules (integration through shared datasets)](./independent-modules)
- [Workspace scope and multi-workspace workflows](./workspace-scope-and-multi-workspace)
- [Shared validation layer (schema + logical validation)](./shared-validation-layer)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../design-goals/unix-composability">Unix-style composability (micro-tools)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./append-only-and-security">Append-only discipline and security model</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
