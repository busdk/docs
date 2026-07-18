---
title: Reporting and query commands
description: In addition to mutating commands, BusDK provides read-only query and reporting commands that compute balances, statuses, and summaries from the workspace…
---

## Reporting and query commands

This page defines the shared design contract for read-only query and reporting commands that compute balances, statuses, and summaries from workspace datasets. It is not a current command reference: the linked module CLI pages and `bus <module> <command> --help` are authoritative for implemented commands, flags, formats, and guarantees.

The contract covers human-readable output, machine-readable integration, deterministic ordering, audit exports, and period-scoped reporting. Individual modules may implement these requirements incrementally; do not assume a command or output mode exists until its module reference or help output documents it.

Reporting outputs must be deterministic when used for auditing, exports, and automation. When a command offers a machine-readable output mode, the format, column set, and column order must be stable and documented, and record ordering must be stable and documented. Stable ordering should be based on stable identifiers and explicit sort keys (for example primary keys and dates) rather than on incidental file ordering.

Human-readable formatting is allowed to optimize terminal readability, but it must not be the only supported mode for commands that are expected to integrate into automated workflows. When a command emits structured results, it should be possible to select a machine-readable output mode that preserves standard output for the result set and uses standard error for diagnostics.

Reporting commands SHOULD support audit-trail exports and period-scoped output suitable for tax-audit packs. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

For Finnish statutory financial statements, reporting commands MUST use explicit layout identifiers and one canonical account-group hierarchy rather than vague format labels or layout-specific account remapping. In BusDK this contract is defined by [bus-reports reference](../modules/bus-reports), which specifies built-in `fi-kpa-*` and `fi-pma-*` layout identifiers, comparative handling, synthetic statutory rows, and statement-level validations required for filing-readiness. The CLI reference for [bus-reports](../modules/bus-reports) documents the command-level surface (`--layout-id`, `--layout`, `--comparatives`) and points to the workspace reporting profile keys in [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration).

For migration-quality checks, reporting includes non-opening journal coverage and related parity outputs that can be compared against source-import totals. The command workflow is documented in [Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks).

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
