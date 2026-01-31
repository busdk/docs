# Governance of core schemas

As modularity increases, schema divergence becomes a risk. BusDK treats core schemas—particularly accounts and journal—as public APIs that require lightweight governance. Schema changes are expected to preserve backward compatibility or provide explicit migrations. New modules should reuse existing keys and fields where appropriate and should integrate financial value changes through the ledger to preserve a comprehensive financial picture. Cross-links such as invoice IDs referencing journal transaction IDs are encouraged for traceability.

---

<!-- busdk-docs-nav start -->
**Prev:** [AI and external service integration](./ai-and-external-services) · **Index:** [BusDK Design Document](../../index) · **Next:** [Event hooks and automation](./event-hooks-and-automation)
<!-- busdk-docs-nav end -->
