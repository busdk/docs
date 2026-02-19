---
title: Event hooks and automation
description: Although BusDK is CLI-driven rather than event-driven by default, the architecture supports automation via Git hooks or file watchers managed outside BusDK.
---

## Event hooks and automation

Although BusDK is CLI-driven rather than event-driven by default, the architecture supports automation via Git hooks or file watchers managed outside BusDK. Post-commit hooks can trigger secondary actions such as generating PDFs when invoices are created, emailing invoices, or notifying the owner for review when large transactions are recorded. BusDK intends to document patterns for such automation and may later provide a lightweight plugin system where modules can subscribe to repository events such as “new invoice” or “new journal entry.”

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./core-schema-governance">Governance of core schemas</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./one-developer-ecosystem">One-developer contributions and ecosystem</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Extensibility index](./index)
- [Independent modules](../architecture/independent-modules)
- [Plug-in modules via new datasets](./plugin-modules-via-datasets)
