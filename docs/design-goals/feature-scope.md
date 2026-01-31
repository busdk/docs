## Initial feature scope (modules)

BusDK’s initial feature scope is an end-to-end bookkeeping workflow implemented as dedicated `bus-*` modules that operate on workspace datasets (CSV + schemas) stored alongside supporting evidence in the repository. The preferred default is that the repository is a Git repository, but Git is an implementation choice rather than the definition of the goal, consistent with [Git as the canonical, append-only source of truth](./git-as-source-of-truth). The double-entry ledger is the canonical dataset that other modules produce, validate, and report from, and the audit trail from evidence to postings and back from reported figures to vouchers is treated as a first-class requirement, consistent with [Double-entry ledger accounting](./double-entry-ledger) and [Auditability through append-only changes](./append-only-auditability).

The initial planned modules cover the minimum building blocks used in the intended workflow:

- Chart of accounts with [`bus accounts`](../modules/bus-accounts)
- Counterparties with [`bus entities`](../modules/bus-entities)
- Accounting periods with [`bus period`](../modules/bus-period)
- Evidence archiving with [`bus attachments`](../modules/bus-attachments)
- Sales and purchase invoices with [`bus invoices`](../modules/bus-invoices)
- Balanced ledger postings with [`bus journal`](../modules/bus-journal)
- Bank import with [`bus bank`](../modules/bus-bank)
- Reconciliation with [`bus reconcile`](../modules/bus-reconcile)
- Finnish VAT (ALV) calculation and reporting with [`bus vat`](../modules/bus-vat)
- Validation and safety checks with [`bus validate`](../modules/bus-validate)
- Reporting outputs with [`bus reports`](../modules/bus-reports)
- Fixed-asset tracking with [`bus assets`](../modules/bus-assets)

Budgeting and budget-versus-actual reporting with [`bus budget`](../modules/bus-budget) is in scope as an analysis and planning capability, but it is not the defining backbone of the statutory bookkeeping chain in BusDK terms.

BusDK does not execute Git commands and it does not make discretionary accounting judgments (classification, valuation, materiality). In practice this means BusDK does not “decide accounting” on the user’s behalf in areas where real-world bookkeeping requires a policy choice or professional judgment, such as whether a purchase is expensed immediately or capitalized as a fixed asset, which depreciation method and lifetime is used, how inventory is valued, or which simplifications are acceptable based on materiality. BusDK is deterministic and policy-driven: it validates, calculates, and records based on explicit rules, configuration, and inputs the user (or their accountant) provides, and it keeps those choices transparent and reviewable through the audit trail.

The default assumption is that modules operate locally on the workspace datasets and do not require third-party API integration; when integration is needed, it is provided by dedicated, optional modules that target a specific external interface (for example Maventa for e-invoicing, Vero for VAT-related exchanges, or PRH for company record lookups). These integration modules do not change the compliance boundary that BusDK is tooling for producing, validating, and exporting bookkeeping material rather than acting as legal representation or performing statutory submissions on the user’s behalf.

Corrections are represented as additional bookkeeping that preserves history rather than overwriting prior vouchers or postings, so the repository data remains reviewable and exportable across the retention period.

BusDK is intended to grow into a broader suite of tools for running a business, but the initial scope defined here is deliberately limited to the bookkeeping workflow and its supporting datasets, evidence, validation, and reporting.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./extensibility">Extensibility as a first-class goal</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">BusDK Design Spec: Design goals and requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./git-as-source-of-truth">Git as the canonical, append-only source of truth</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
