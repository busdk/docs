---
title: Extensible CLI surface and API parity
description: As new modules are added, they introduce new subcommands without breaking existing behavior.
---

## Extensible CLI surface and API parity

As new modules are added, they introduce new subcommands without breaking existing behavior. The CLI should correspond to underlying library functions where feasible so that future API layers can wrap the same logic. The eventual architecture anticipates an “API parity” model where CLI operations map cleanly to callable functions or REST endpoints.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../cli/index">BusDK Design Spec: CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./automated-git-commits">Git commit conventions per operation (external Git)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
