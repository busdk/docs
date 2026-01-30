# Extensibility as a first-class goal

Extensibility is a first-class goal. The architecture must remain simple enough that a single developer can implement a new module over a weekend using common libraries. The data contracts (CSV + schemas) are the shared interface so that modules can be written in different programming languages and still interoperate. New business capabilities—inventory, payroll, specialized reports—should be addable by defining new datasets and tools without requiring a rewrite of the core.

---

<!-- busdk-docs-nav start -->
**Prev:** [Double-entry ledger accounting](./double-entry-ledger) · **Next:** [Initial feature scope (modules)](./feature-scope)
<!-- busdk-docs-nav end -->
