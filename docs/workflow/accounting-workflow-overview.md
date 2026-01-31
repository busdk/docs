## Accounting workflow overview (current planned modules)

This is the intended, end-to-end bookkeeping flow for BusDK based on the current planned modules. It assumes a dedicated repository workspace for the accounting year, with the workspace datasets (tables plus schemas) and supporting evidence living side-by-side as repository data. When Git is used, every change is recorded as a commit using external Git tooling, but Git is an implementation choice rather than the definition of the workflow’s invariants.

### 1) Create the bookkeeping repository

Start a new Git repository for the bookkeeping year. Install the core dispatcher `bus` and the BusDK module binaries you plan to use. Keep the `docs` spec repository nearby when deciding naming, schemas, and conventions. BusDK does not execute any Git commands.

### 2) Define master data (start-of-year setup)

- Chart of accounts with [`bus accounts`](../modules/bus-accounts) (used by all postings and reports).
- Durable counterparties with [`bus entities`](../modules/bus-entities) (customers, vendors, banks, authorities).
- Accounting periods with [`bus period`](../modules/bus-period) (typically monthly, with open/close/lock rules).

### 3) Treat evidence as first-class data

Archive receipts, invoices, bank exports, VAT filings, and other documents with [`bus attachments`](../modules/bus-attachments). Reference attachment IDs from invoices, journal entries, and other datasets to keep the audit trail in the same repository.

### 4) Record day-to-day activity

- Invoicing: record sales/purchase invoices with [`bus invoices`](../modules/bus-invoices) and link evidence.
- Ledger postings: record balanced transactions with [`bus journal`](../modules/bus-journal).
- Assets: track acquisitions, disposals, and depreciation with [`bus assets`](../modules/bus-assets).

The journal is the authoritative source for financial statements, so it must remain balanced and auditable.

### 5) Reconcile bank activity

On a regular cadence (weekly or monthly), import bank statements with [`bus bank`](../modules/bus-bank) and reconcile against invoices or journal entries with [`bus reconcile`](../modules/bus-reconcile). If reconciliation reveals missing bookkeeping (fees, partial payments, unrecorded purchases), add the missing source data with [`bus invoices`](../modules/bus-invoices) or post directly with [`bus journal`](../modules/bus-journal), then re-run reconciliation.

### 6) Close each period

At month end, run a repeatable close:

- Validate schemas and invariants with [`bus validate`](../modules/bus-validate).
- Compute VAT with [`bus vat`](../modules/bus-vat) and archive VAT exports via [`bus attachments`](../modules/bus-attachments).
- Lock the period with [`bus period`](../modules/bus-period).
- Generate financial outputs (trial balance, general ledger, P&L, balance sheet) with [`bus reports`](../modules/bus-reports).

Commit the data, evidence, and reports with Git, and tag the period (for example, `2026-01-closed`).

### 7) Year-end close

Repeat the close flow for the final period, ensure assets and VAT are complete, and run year-level reports with [`bus reports`](../modules/bus-reports). Commit and tag the final revision with Git (for example, `2026-closed`) to preserve a reproducible, audit-friendly year.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../workflow/">BusDK Design Spec: Example end-to-end workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../workflow/">BusDK Design Spec: Example end-to-end workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-assisted-classification-review">AI-assisted classification (review before external commit)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
