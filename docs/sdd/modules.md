---
title: Module design documents — requirements, interfaces, and data design
description: List of BusDK module SDDs — requirements, interfaces, and data design for bus-init, bus-data, bus-accounts, and all modules.
---

## Module design documents — requirements, interfaces, and data design

BusDK is organized as a set of independent modules that operate on workspace datasets. Each module is implemented as a CLI program that plugs into the `bus` dispatcher (for example `bus accounts`, `bus journal`, or `bus vat`). A module owns its datasets and schemas, provides commands to initialize and maintain them, and emits deterministic diagnostics so that workflows remain reviewable in the Git repository. BusDK includes both domain modules and a small number of infrastructure modules, and infrastructure modules may primarily exist to provide shared mechanical behavior as Go libraries.

This section collects the module Software Design Documents. For end user command references in a man-page style, see the [BusDK module CLI reference](../modules/index).

For the architectural rationale behind independent modules and the design goals that shape their boundaries, see [Independent modules](../architecture/independent-modules) and [Modularity](../design-goals/modularity).

### Data path contract for read-only cross-module access

Every module that owns workspace data (datasets and/or schemas in the workspace) MUST expose the path(s) to its owned data file(s) via its Go library. Other modules that need read-only, pure-data access to another module’s raw files MUST obtain the path(s) from that owning module’s library; they MUST NOT hardcode file names or paths outside the module that owns the data.

Providing a path grants read-only access only. All write access and business logic (e.g. balance computation, validation, posting) remain in the owning module. Consumers may use the path to read raw file contents for their own logic (e.g. computing opening balances from a prior workspace’s journal); they must not perform writes or rely on the owning module’s domain logic except by calling the owning module’s APIs.

Path accessors MUST be designed so that future dynamic configuration is possible without breaking consumers. Today, default paths may be conventional names (e.g. `accounts.csv` at the workspace root). The API MUST resolve paths in a way that allows, in a later phase, resolving from workspace or data package configuration (e.g. end users configuring paths in a data package) so that only the owning module’s implementation changes; consuming modules continue to call the same library to obtain the path. Each data-owning module SDD specifies its path-accessor interface and owned file set. For example, [bus-journal](./bus-journal) obtains the chart of accounts path from the bus-accounts library and the period control path (and effective state) from the bus-period library when validating account names and enforcing period boundaries; it does not hardcode `accounts.csv` or `periods.csv`.

- [`bus`](./bus): Top-level dispatcher; runs `bus <command> [args...]` by invoking the corresponding `bus-<command>` executable on PATH.
- [`bus init`](./bus-init): Bootstraps a new workspace by orchestrating `bus config init` and then module-owned `init` commands for the standard workspace layout.
- [`bus config`](./bus-config): Owns workspace-level configuration (`datapackage.json`, accounting entity settings); provides `init` and `configure` so workspace settings can be created or updated without re-running full bootstrap.
- [`bus data`](./bus-data): Tabular data layer: schema-validated dataset I/O and validation for BusDK workspaces (CSV + JSON Table Schema), providing a Go library (and a thin 'bus data ...' CLI) for deterministic CRUD-style table and schema handling, including mechanical import-profile parsing and execution helpers used by domain modules.
- [`bus dev`](./bus-dev): Developer-only companion: centralizes workflow logic for BusDK module repositories (commit, work, spec, e2e); operates on source repositories and developer workflows, not on accounting datasets.
- [`bus run`](./bus-run): End-user runner for user-defined prompts, pipelines, and scripts with agentic execution via the bus-agent library; no built-in developer workflows and no dependency on bus-dev.
- [`bus-secrets`](./bus-secrets): Stores and resolves secret references for workflow modules, with deterministic user and repository scopes and user-first auto precedence.
- [`bus shell`](./bus-shell): Interactive and one-shot shell wrapper that executes BusDK commands through the `bus` dispatcher.
- [`bus books`](./bus-books): Local bookkeeping web UI for end users; accounting screens (journal, periods, VAT, bank, invoices, attachments) over workspace; embeds Bus API.
- [`bus bfl`](./bus-bfl): Defines the deterministic formula language used for computed fields; end users interact with it through schema metadata, validation, and projections rather than a dedicated CLI.
- [`bus accounts`](./bus-accounts): Maintains the chart of accounts as schema-validated CSV datasets used as shared reference data across the workspace.
- [`bus entities`](./bus-entities): Maintains counterparty reference datasets and stable entity IDs used for linking and matching across modules.
- [`bus period`](./bus-period): Opens and closes accounting periods, generates closing and opening balance entries, and locks closed periods to prevent changes after close.
- [`bus balances`](./bus-balances): Owns an append-only balance snapshot dataset; add/import build snapshots, apply materializes one balanced journal transaction for opening or cutover.
- [`bus attachments`](./bus-attachments): Stores evidence files and attachment metadata with stable IDs, enabling cross-module links from invoices, journal entries, bank data, and reconciliation records.
- [`bus invoices`](./bus-invoices): Maintains sales and purchase invoices as datasets, validates totals and VAT breakdowns, can emit posting outputs for the ledger, and specifies profile-driven ERP invoice import into canonical invoice datasets.
- [`bus journal`](./bus-journal): Maintains append-only journal entries as the authoritative ledger postings and validates balanced transaction invariants.
- [`bus bank`](./bus-bank): Imports bank statements into normalized datasets, matches transactions to references, and specifies profile-driven ERP bank import into canonical bank datasets.
- [`bus reconcile`](./bus-reconcile): Links bank transactions to invoices or journal entries, records allocations (partials, splits, fees), and provides deterministic proposal generation plus batch apply commands and coverage artifacts for reconciliation workflows.
- [`bus assets`](./bus-assets): Maintains a fixed-asset register, generates depreciation schedules, and produces depreciation postings for period workflows and the journal.
- [`bus loans`](./bus-loans): Maintains a loan register and event logs, generates amortization schedules from contract terms, and produces posting suggestions for loan activity.
- [`bus inventory`](./bus-inventory): Maintains inventory master data and stock movement ledgers and produces valuation outputs for accounting and reporting.
- [`bus payroll`](./bus-payroll): Maintains payroll datasets, validates payroll runs, and produces journal posting outputs for salaries and taxes.
- [`bus budget`](./bus-budget): Maintains budgets keyed by account and period and produces budget vs actual variance outputs against ledger actuals.
- [`bus reports`](./bus-reports): Computes financial and management reports from journal entries and reference data and emits reports in text and structured formats, with planned non-opening journal coverage reporting for migration checks.
- [`bus replay`](./bus-replay): Exports a deterministic, append-only replay log (JSONL and shell script) from a workspace for migration and parity; apply runs the log into a target workspace with idempotent guards, including planned profile-import migration operations for invoices and bank.
- [`bus validate`](./bus-validate): Validates workspace datasets against schemas and cross-table invariants, with planned first-class parity and journal-gap threshold checks for CI and scripted migration workflows.
- [`bus vat`](./bus-vat): Computes VAT totals per reporting period, validates VAT mappings, and reconciles invoice VAT with ledger postings before emitting VAT summaries and exports.
- [`bus pdf`](./bus-pdf): Renders deterministic PDFs from prepared JSON render models without modifying any canonical workspace datasets.
- [`bus filing`](./bus-filing): Produces deterministic filing bundles from validated workspace data and delegates target-specific formats to filing target modules.
- [`bus filing prh`](./bus-filing-prh): Converts validated workspace data into PRH-ready export bundles with deterministic packaging, manifests, and hashes.
- [`bus filing vero`](./bus-filing-vero): Converts validated workspace data into Vero-ready export bundles with deterministic packaging, manifests, and hashes.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-init">bus-init</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [SDD index](./index)
- [BusDK module CLI reference](../modules/index)
- [Independent modules](../architecture/independent-modules)
- [Modularity](../design-goals/modularity)
