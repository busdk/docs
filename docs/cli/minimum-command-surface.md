---
title: Minimum required command surface (end-to-end workflow)
description: This page defines the minimum CLI surface that must exist for the end-to-end bookkeeping workflow described in the design spec.
---

## Minimum required command surface (end-to-end workflow)

This page defines the minimum CLI surface that must exist for the end-to-end bookkeeping workflow described in the design spec. It is derived from the workflow narrative in [Accounting workflow overview](../workflow/accounting-workflow-overview) and the current module set in [Modules](../modules/index).

The purpose of this contract is to make the CLI testable as a stable interface. “Minimum required” means a conforming BusDK implementation provides these commands and subcommands by name, with deterministic behavior, deterministic diagnostics, and predictable outputs suitable for both human use and scripting.

This page specifies command names and output expectations at a contract level. The detailed CLI conventions for diagnostics, exit codes, non-interactive behavior, and reporting determinism are defined in the shared CLI pages: [Error handling, dry-run, and diagnostics](./error-handling-dry-run-diagnostics), [Non-interactive use and scripting](./interactive-and-scripting-parity), [Reporting and query commands](./reporting-and-queries), and [Validation and safety checks](./validation-and-safety-checks).

### Minimum required commands

The following command surface is the minimum needed to execute the workflow as described in the spec.

`bus init` creates workspaces by orchestrating module-owned initialization so each module remains owner of its datasets and schemas. If it emits stdout results, they must be stable across machines and limited to workspace-relative paths and stable identifiers.

`bus accounts add` appends chart-of-accounts reference data and must fail with deterministic diagnostics when schema or invariants are violated. Any stdout result should contain stable identifiers, such as account code, and must not depend on row order.

`bus entities add` appends counterparty reference data and establishes stable entity identifiers used by cross-dataset links. If it emits stdout results, they should include stable entity identifiers.

`bus period add`, `bus period open`, `bus period close`, and `bus period lock` create periods in **future** state and enforce deterministic state transitions (`open` → `close` → `lock`) for repeatable period control. They must fail deterministically on state/invariant violations and should emit stable period identifiers when returning results.

`bus attachments add` registers evidence files and creates attachment identifiers that other datasets can reference. Any stdout result should include stable attachment identifiers and, when needed, workspace-relative evidence paths.

`bus invoices add` appends invoice datasets and validates totals and VAT breakdowns. If it emits stdout results, they should include stable invoice identifiers.

`bus journal add` appends balanced journal transactions and enforces balance invariants. If it emits stdout results, they should include stable transaction or voucher identifiers used for traceability.

`bus bank import` imports and normalizes bank statement data into workspace datasets and must be fully non-interactive for automation. Any stdout result should be a stable summary that is not environment-dependent.

`bus reconcile match` links bank transactions to invoices or journal entries and writes reconciliation datasets. Any stdout result should reference stable identifiers for both bank transactions and linked records.

`bus validate` checks workspace datasets against schemas and cross-table invariants. It must work in CI and scripted contexts and emit deterministic diagnostics with dataset names and stable identifiers. Alongside human-readable diagnostics, it should provide at least one machine-readable diagnostics mode.

`bus vat report` and `bus vat export` compute period VAT summaries and generate export artifacts as repository data for archiving and filing. They must support machine-readable output with stable schema, column order, and record ordering as defined in [Reporting and query commands](./reporting-and-queries).

`bus reports trial-balance` produces period-close reporting output and must support machine-readable output with stable schema, column order, and record ordering.

### Scope and evolution

This is the minimum workflow surface implied by the current module set. As BusDK grows, new modules may add new commands without breaking this minimum surface, consistent with [Extensible CLI surface and API parity](./api-parity).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./command-naming">CLI command naming</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../cli/index">BusDK Design Spec: CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./error-handling-dry-run-diagnostics">Error handling, dry-run, and diagnostics</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [BusDK module CLI reference](../modules/index)
- [Error handling, dry-run, and diagnostics](./error-handling-dry-run-diagnostics)
- [Non-interactive use and scripting](./interactive-and-scripting-parity)
- [Reporting and query commands](./reporting-and-queries)
- [Validation and safety checks](./validation-and-safety-checks)
- [Extensible CLI surface and API parity](./api-parity)
