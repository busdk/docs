---
title: Governance of core schemas
description: As modularity increases, schema divergence becomes a risk.
---

## Governance of core schemas

As modularity increases, schema divergence becomes a risk. BusDK treats core schemas — particularly accounts and journal — as public APIs that require lightweight governance. Schema changes are expected to preserve backward compatibility or provide explicit migrations. New modules should reuse existing keys and fields where appropriate and should integrate financial value changes through the ledger to preserve a comprehensive financial picture. Cross-links such as invoice IDs referencing journal transaction IDs are encouraged for traceability.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-and-external-services">AI and external service integration</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../extensibility/index">BusDK Design Spec: Extensibility model</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./event-hooks-and-automation">Event hooks and automation</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
