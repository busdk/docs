---
title: BusDK module CLI reference
description: End-user reference for all BusDK module CLIs — bus init, bus config, bus data, bus accounts, and the full command surface.
---

## BusDK module CLI reference

This section is the end user reference for the BusDK module CLIs. Each page is structured like a man page so you can quickly find the command surface, data files, and how to discover flags and subcommands. Command names follow [CLI command naming](../cli/command-naming). In synopsis lines, **[global flags]** denotes the [standard global flags](../cli/global-flags) accepted by most modules; run `bus <module> --help` for the full list for each module. For the design and implementation rationale behind each module, see the module SDDs in [Modules (SDD)](../sdd/modules).

If you need architectural background on why modules are independent and how they integrate, see [Independent modules](../architecture/independent-modules) and [Modularity](../design-goals/modularity).

- [`bus init`](./bus-init): Initialize a new workspace by orchestrating `bus config init` and module-owned `init` commands.
- [`bus config`](./bus-config): Create and update workspace configuration (accounting entity settings in `datapackage.json`).
- [`bus data`](./bus-data): Inspect workspace datasets and schemas through a minimal data-layer CLI.
- [`bus api`](./bus-api): Local REST JSON API gateway for BusDK workspaces.
- [`bus sheets`](./bus-sheets): Local spreadsheet-like web UI for workspaces (workbook, sheet tabs, optional agent chat).
- [`bus dev`](./bus-dev): Developer workflows for module repos (commit, work, spec, e2e); not for end-user bookkeeping.
- [`bus agent`](./bus-agent): Diagnostics and development helper for the agent runner (detect, render, run, format).
- [`bus bfl`](./bus-bfl): Developer CLI for BusDK Formula Language expressions.
- [`bus accounts`](./bus-accounts): Manage the chart of accounts.
- [`bus entities`](./bus-entities): Manage counterparty reference data.
- [`bus period`](./bus-period): Open, close, and lock accounting periods.
- [`bus attachments`](./bus-attachments): Register evidence files and attachment metadata.
- [`bus invoices`](./bus-invoices): Create and manage sales and purchase invoices.
- [`bus journal`](./bus-journal): Post and query ledger journal entries.
- [`bus bank`](./bus-bank): Import and list bank transactions.
- [`bus reconcile`](./bus-reconcile): Match bank transactions to invoices or journal entries.
- [`bus assets`](./bus-assets): Manage fixed-asset records and depreciation.
- [`bus loans`](./bus-loans): Manage loans and amortization schedules.
- [`bus inventory`](./bus-inventory): Manage inventory items and movements.
- [`bus payroll`](./bus-payroll): Run payroll and generate postings.
- [`bus budget`](./bus-budget): Record budgets and run budget vs actual reports.
- [`bus reports`](./bus-reports): Generate trial balance, ledger, and statement reports.
- [`bus validate`](./bus-validate): Validate workspace datasets and invariants.
- [`bus vat`](./bus-vat): Compute VAT reports and exports.
- [`bus pdf`](./bus-pdf): Render PDFs from JSON render models.
- [`bus filing`](./bus-filing): Build deterministic filing bundles.
- [`bus filing prh`](./bus-filing-prh): Produce PRH export bundles.
- [`bus filing vero`](./bus-filing-vero): Produce Vero export bundles.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../workflow/year-end-close">Year-end close (closing entries)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-init">bus-init</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
