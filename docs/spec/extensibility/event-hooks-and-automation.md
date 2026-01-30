# Event hooks and automation

Although BusDK is CLI-driven rather than event-driven by default, the architecture supports automation via Git hooks or file watchers managed outside BusDK. Post-commit hooks can trigger secondary actions such as generating PDFs when invoices are created, emailing invoices, or notifying the owner for review when large transactions are recorded. BusDK intends to document patterns for such automation and may later provide a lightweight plugin system where modules can subscribe to repository events such as “new invoice” or “new journal entry.”

---

<!-- busdk-docs-nav start -->
**Prev:** [Governance of core schemas](./core-schema-governance) · **Next:** [One-developer contributions and ecosystem](./one-developer-ecosystem)
<!-- busdk-docs-nav end -->
