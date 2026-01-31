## Modules

BusDK is organized as a set of independent modules that operate on workspace datasets. Each module is implemented as a CLI program that plugs into the `bus` dispatcher (for example `bus accounts`, `bus journal`, or `bus vat`). A module owns its datasets and schemas, provides commands to initialize and maintain them, and emits deterministic diagnostics so that workflows remain reviewable in the Git repository.

This section collects the module reference pages that describe what each module does, what data it reads and writes, and how it fits into the overall workflow.

For the architectural rationale behind independent modules and the design goals that shape their boundaries, see [Independent modules](../architecture/independent-modules) and [Modularity](../design-goals/modularity).

- [`bus init`](./bus-init): Bootstraps a new workspace by orchestrating module-owned `init` commands and creating the chosen workspace layout.
- [`bus accounts`](./bus-accounts): Maintains the chart of accounts as schema-validated CSV datasets used as shared reference data across the workspace.
- [`bus entities`](./bus-entities): Maintains counterparty reference datasets and stable entity IDs used for linking and matching across modules.
- [`bus period`](./bus-period): Opens and closes accounting periods, generates closing and opening balance entries, and locks closed periods to prevent changes after close.
- [`bus attachments`](./bus-attachments): Stores evidence files and attachment metadata with stable IDs, enabling cross-module links from invoices, journal entries, bank data, and reconciliation records.
- [`bus invoices`](./bus-invoices): Maintains sales and purchase invoices as datasets, validates totals and VAT breakdowns, and can emit posting outputs for the ledger.
- [`bus journal`](./bus-journal): Maintains append-only journal entries as the authoritative ledger postings and validates balanced transaction invariants.
- [`bus bank`](./bus-bank): Imports bank statements into normalized datasets, matches transactions to references, and emits balanced journal entries for posting into the ledger.
- [`bus reconcile`](./bus-reconcile): Links bank transactions to invoices or journal entries and records allocations (partials, splits, fees) as auditable reconciliation datasets.
- [`bus assets`](./bus-assets): Maintains a fixed-asset register, generates depreciation schedules, and produces depreciation postings for period workflows and the journal.
- [`bus loans`](./bus-loans): Maintains a loan register and event logs, generates amortization schedules from contract terms, and produces posting suggestions for loan activity.
- [`bus inventory`](./bus-inventory): Maintains inventory master data and stock movement ledgers and produces valuation outputs for accounting and reporting.
- [`bus payroll`](./bus-payroll): Maintains payroll datasets, validates payroll runs, and produces journal posting outputs for salaries and taxes.
- [`bus budget`](./bus-budget): Maintains budgets keyed by account and period and produces budget vs actual variance outputs against ledger actuals.
- [`bus reports`](./bus-reports): Computes financial and management reports from journal entries and reference data and emits reports in text and structured formats.
- [`bus validate`](./bus-validate): Validates workspace datasets against schemas and cross-table invariants and emits deterministic diagnostics suitable for CI and scripted workflows.
- [`bus vat`](./bus-vat): Computes VAT totals per reporting period, validates VAT mappings, and reconciles invoice VAT with ledger postings before emitting VAT summaries and exports.
- [`bus pdf`](./bus-pdf): Renders deterministic PDFs from prepared JSON render models without modifying any canonical workspace datasets.
- [`bus filing`](./bus-filing): Produces deterministic filing bundles from validated workspace data and delegates target-specific formats to filing target modules.
- [`bus filing prh`](./bus-filing-prh): Converts validated workspace data into PRH-ready export bundles with deterministic packaging, manifests, and hashes.
- [`bus filing vero`](./bus-filing-vero): Converts validated workspace data into Vero-ready export bundles with deterministic packaging, manifests, and hashes.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../workflow/year-end-close">Year-end close (closing entries)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-init">bus-init</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
