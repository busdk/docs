---
title: Reporting and query commands
description: In addition to mutating commands, BusDK provides read-only query and reporting commands that compute balances, statuses, and summaries from the workspace…
---

## Reporting and query commands

Use the current module commands for read-only queries and reports: [`bus accounts report`](../modules/bus-accounts), [`bus invoices list`](../modules/bus-invoices), [`bus vat report`](../modules/bus-vat), [`bus budget report`](../modules/bus-budget), and the broader [`bus reports`](../modules/bus-reports) family. Each module page documents its available flags, formats, ordering where documented, and prerequisites; `bus <module> <command> --help` is authoritative when the installed command differs.

The module references document deterministic formats and ordering where supported. For example, `bus reports account-balances --as-of 2026-03-31 --format csv` has a documented column shape, while report and invoice list commands document their date, identifier, and filter options. Prefer the machine-readable mode and ordering documented by the specific command rather than relying on incidental file order.

Human-readable formatting is allowed to optimize terminal readability, but it must not be the only supported mode for commands that are expected to integrate into automated workflows. When a command emits structured results, it should be possible to select a machine-readable output mode that writes the result set to standard output by default, or to the selected output destination, and uses standard error for diagnostics.

For audit and period-scoped work, use the documented `bus reports evidence-pack`, `journal-coverage`, `parity`, and `journal-gap` commands. The compliance context is in [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

For Finnish statutory financial statements, the [bus-reports reference](../modules/bus-reports) documents built-in `fi-kpa-*` and `fi-pma-*` layout identifiers, comparative handling, account-group hierarchy, and statement validation. Its command reference covers `--layout-id`, `--layout`, and `--comparatives`, with workspace reporting profile keys described in [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration).

For migration-quality checks, run the documented journal-coverage, parity, and journal-gap commands against the source-import period. The workflow is documented in [Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./interactive-and-scripting-parity">Non-interactive use and scripting</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./output-style">CLI output style</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-reports reference](../modules/bus-reports)
- [bus-reports module CLI reference](../modules/bus-reports)
- [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration)
- [Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
