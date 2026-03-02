---
title: "FAQ: Workspaces, datasets, and compliance boundaries"
description: FAQ on BusDK workspace shape, dataset ownership, replay safety, schema contracts, and compliance-oriented data handling.
---

## FAQ: Workspaces, datasets, and compliance boundaries

### What exactly is stored in a BusDK workspace?

A BusDK workspace stores repository data that includes [canonical datasets](../master-data/index), schema definitions, and deterministic script inputs. This structure is designed so the same inputs can produce the same outputs over time.

### Who owns each dataset file?

Each dataset has an owning module that defines write behavior and business rules for that dataset. Other modules may read the data, but cross-module access should follow [module contracts](../sdd/modules#data-path-contract-for-read-only-cross-module-access) instead of hardcoded assumptions.

### Why are schemas so central in BusDK?

Schemas are the contract layer that keeps data predictable across modules and across time. They support deterministic validation and make drift visible before it turns into hidden business inconsistencies, as defined in the [table schema contract](../data/table-schema-contract).

### Does append-only behavior mean data can never be corrected?

No. Corrections are supported, but they should remain explicit and reviewable through controlled workflow operations instead of silent destructive edits. The goal is traceability, not immutability for its own sake, consistent with [append-only updates and soft deletion](../data/append-only-and-soft-deletion).

### Can we keep sensitive data outside the repository?

Yes. Sensitive material handling should follow module and environment policy boundaries. BusDK includes patterns for reference-based handling and [secret management](../modules/bus-secrets) so operational workflows do not require unsafe inline secrets.

### How does BusDK help with compliance and audit readiness?

BusDK emphasizes explicit workflow steps, reproducible outputs, and evidence mapping. [Compliance pages](../compliance/fi-bookkeeping-and-tax-audit) define jurisdiction-specific expectations, while module flows and validation steps from [`bus-validate`](../modules/bus-validate) and [`bus-reports`](../modules/bus-reports) make controls executable rather than just descriptive.

### Can one repository contain multiple workspaces?

BusDK supports explicit [workspace-scoped operation patterns](../architecture/workspace-scope-and-multi-workspace). Multi-workspace usage is possible, but commands should run with clear workspace boundaries so data ownership and replay behavior stay deterministic.

### What is the practical difference between “workspace data” and generated outputs?

Workspace data is the authoritative operational source. Generated outputs are derived artifacts produced from that source through deterministic command workflows. If output generation logic changes, [`bus replay`](../modules/bus-replay) should regenerate outputs from the same source data.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./getting-started-and-adoption">FAQ: getting started and adoption</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">FAQ index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-automation-and-safety">FAQ: AI assistants, automation, and safety</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Data format and storage](../data/index)
- [Table schema contract](../data/table-schema-contract)
- [Append-only updates and soft deletion](../data/append-only-and-soft-deletion)
- [Architecture: workspace scope and multi-workspace workflows](../architecture/workspace-scope-and-multi-workspace)
- [Compliance](../compliance/fi-bookkeeping-and-tax-audit)
