---
title: Accounting workflow overview (current planned modules)
description: This is the intended, end-to-end bookkeeping flow for BusDK based on the current planned modules.
---

## Accounting workflow overview (current planned modules)

This is the intended, end-to-end bookkeeping flow for BusDK based on the current planned modules. It assumes a dedicated repository workspace for the accounting year, with the workspace datasets (tables plus schemas) and supporting evidence living side-by-side as repository data. Version control is an implementation choice, not the definition of the workflow’s invariants — the invariant is that the workspace datasets and their revision history remain reviewable and exportable. End users can run the local bookkeeping UI ([bus books](../sdd/bus-books)) to work through this flow in a browser.

1. Create the bookkeeping repository and scaffold baseline datasets:

```bash
bus init
```

`bus init` orchestrates module-owned init commands so each module remains the authoritative owner of its datasets and schemas.

2. Define master data that other modules depend on:

```bash
bus accounts add ...
bus entities add ...
bus period add ...
bus period open ...
```

The chart of accounts maintained by [`bus accounts`](../modules/bus-accounts) becomes the shared reference for postings and reports. Durable counterparties maintained by [`bus entities`](../modules/bus-entities) keep names and identifiers consistent across invoices, bank imports, and filings. Period control managed by [`bus period`](../modules/bus-period) is created with `bus period add` (periods start in state **future**); `bus period open` then transitions the chosen period to **open** so posting can begin. Close and lock establish the boundaries that prevent later drift.

3. Treat evidence as first-class repository data by registering attachments:

```bash
bus attachments add ...
```

Receipts, invoice PDFs, bank exports, VAT filings, and other documents are archived through [`bus attachments`](../modules/bus-attachments), and other datasets reference attachment identifiers so provenance remains attached to the records that rely on it.

4. Record day-to-day activity as explicit invoice and journal records:

```bash
bus invoices add ...
bus journal add ...
```

Invoicing via [`bus invoices`](../modules/bus-invoices) writes validated invoice rows and can produce postings by appending to the shared journal dataset. Direct ledger postings via [`bus journal`](../modules/bus-journal) remain balanced and append-only, because the journal is authoritative for the financial statements.

5. Import bank activity and reconcile it against invoices and postings:

```bash
bus bank import ...
bus reconcile match ...
```

[`bus bank`](../modules/bus-bank) normalizes and validates bank statement data, and [`bus reconcile`](../modules/bus-reconcile) links bank transactions to invoices or journal entries. When reconciliation reveals missing bookkeeping (fees, partial payments, unrecorded purchases), Alice records the missing source data with `bus invoices add` or posts directly with `bus journal add`, then re-runs matching so the reconciliation history remains explicit.

For deterministic high-volume planning and approval flows, use [Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply). The current production fallback for that phase remains script-generated candidate plans until first-class proposal/apply commands are implemented.

When onboarding historical data from an external ERP, teams can follow the dedicated [Import ERP history into canonical invoices and bank datasets](./import-erp-history-into-canonical-datasets) workflow. The current migration path uses generated append scripts, while the planned first-class workflow is profile-driven import into canonical invoice and bank datasets.

6. Close each period with a repeatable, script-friendly sequence:

```bash
bus validate
bus vat report ...
bus vat export ...
bus period close ...
bus period lock ...
bus reports trial-balance ...
```

Validation via [`bus validate`](../modules/bus-validate) ensures schemas and invariants are still satisfied. VAT is computed and exported via [`bus vat`](../modules/bus-vat) as repository data for archiving and filing. The period is closed and locked via [`bus period`](../modules/bus-period), and the financial output set is generated via [`bus reports`](../modules/bus-reports).

For migration-quality controls before close, use [Source import parity and journal gap checks](./source-import-parity-and-journal-gap-checks). Current production fallback in this repository is script-based parity and gap diagnostics until first-class command surfaces are implemented.

7. Record close boundaries as revisions:

After the close outputs are generated and reviewed, Alice records a revision using her version control tooling so the period boundary is easy to return to later.

At year end, the same pattern applies to the final period, producing a reproducible, audit-friendly year-end revision for long-term retention.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../workflow/index">BusDK Design Spec: Example end-to-end workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../workflow/index">BusDK Design Spec: Example end-to-end workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-assisted-classification-review">AI-assisted classification (review before external commit)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Import bank transactions and apply payments](./import-bank-transactions-and-apply-payment)
- [Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply)
- [Import ERP history into canonical invoices and bank datasets](./import-erp-history-into-canonical-datasets)
- [Source import parity and journal gap checks](./source-import-parity-and-journal-gap-checks)
- [bus-invoices module CLI reference](../modules/bus-invoices)
- [bus-bank module CLI reference](../modules/bus-bank)
- [bus-reconcile module CLI reference](../modules/bus-reconcile)
