# Initial feature scope (modules)

BusDK’s initial feature scope is an end-to-end bookkeeping workflow implemented as dedicated `bus-*` modules that operate on workspace datasets (CSV + schemas) stored in a dedicated Git repository alongside supporting evidence. The double-entry ledger is the canonical dataset that other modules produce, validate, and report from, and the audit trail from evidence to postings and back from reported figures to vouchers is treated as a first-class requirement.

The initial planned modules cover the minimum building blocks used in the intended workflow: chart of accounts with [`bus accounts`](../../modules/bus-accounts), counterparties with [`bus entities`](../../modules/bus-entities), accounting periods with [`bus period`](../../modules/bus-period), evidence archiving with [`bus attachments`](../../modules/bus-attachments), sales and purchase invoices with [`bus invoices`](../../modules/bus-invoices), balanced ledger postings with [`bus journal`](../../modules/bus-journal), bank import with [`bus bank`](../../modules/bus-bank), reconciliation with [`bus reconcile`](../../modules/bus-reconcile), Finnish VAT (ALV) calculation and reporting with [`bus vat`](../../modules/bus-vat), validation and safety checks with [`bus validate`](../../modules/bus-validate), reporting outputs with [`bus reports`](../../modules/bus-reports), and fixed-asset tracking with [`bus assets`](../../modules/bus-assets). Budgeting and budget-versus-actual reporting with [`bus budget`](../../modules/bus-budget) is in scope as an analysis and planning capability, but it is not the defining backbone of the statutory bookkeeping chain in BusDK terms.

BusDK does not execute Git commands, does not file declarations or communicate with authorities on the user’s behalf, and does not make discretionary accounting judgments (classification, valuation, materiality). Corrections are represented as additional bookkeeping that preserves history rather than overwriting prior vouchers or postings, so the repository data remains reviewable and exportable across the retention period.

---

<!-- busdk-docs-nav start -->
**Prev:** [Extensibility as a first-class goal](./extensibility) · **Index:** [BusDK Design Spec: Design goals and requirements](../01-design-goals) · **Next:** [Git as the canonical, append-only source of truth](./git-as-source-of-truth)
<!-- busdk-docs-nav end -->
