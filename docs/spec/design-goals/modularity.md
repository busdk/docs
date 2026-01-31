# Modularity as a first-class requirement

The system is modular from the start. Each major feature area is implemented as an independent, small tool or service that interacts through shared data rather than tight coupling. Ledger, invoicing, tax reporting, bank import, budgeting, and document generation are intended to be independently developed, tested, and deployed in isolation. Modules communicate via the common data repository rather than through direct function calls or internal APIs, increasing robustness, reducing integration risk, and supporting parallel development.

---

<!-- busdk-docs-nav start -->
**Prev:** [Git as the canonical, append-only source of truth](./git-as-source-of-truth) · **Index:** [BusDK Design Document](../../index) · **Next:** [Plain-text CSV for longevity](./plaintext-csv-longevity)
<!-- busdk-docs-nav end -->
