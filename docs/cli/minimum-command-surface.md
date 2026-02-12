## Minimum required command surface (end-to-end workflow)

This page defines the minimum CLI surface that must exist for the end-to-end bookkeeping workflow described in the design spec. It is derived from the workflow narrative in [Accounting workflow overview](../workflow/accounting-workflow-overview) and the current planned module set in [Modules](../modules/index).

The purpose of this contract is to make the CLI testable as a stable interface. “Minimum required” means a conforming BusDK implementation provides these commands and subcommands by name, with deterministic behavior, deterministic diagnostics, and predictable outputs suitable for both human use and scripting.

This page specifies command names and output expectations at a contract level. The detailed CLI conventions for diagnostics, exit codes, interactive behavior, and reporting determinism are defined in the shared CLI pages: [Error handling, dry-run, and diagnostics](./error-handling-dry-run-diagnostics), [Interactive use and scripting parity](./interactive-and-scripting-parity), [Reporting and query commands](./reporting-and-queries), and [Validation and safety checks](./validation-and-safety-checks).

### Minimum required commands

The following command surface is the minimum needed to execute the workflow as described in the spec.

- `bus init`
  
  Creates a workspace by orchestrating module-owned initialization so each module remains the authoritative owner of its datasets and schemas. If the command emits a result on standard output, it must be stable across machines and should be limited to workspace-relative paths and stable identifiers.

- `bus accounts add`
  
  Appends chart-of-accounts reference data. The command must fail with deterministic diagnostics when inputs violate schema or invariants. If it emits a result on standard output, it should be limited to stable identifiers (for example the account code) and must not rely on unstable row numbering.

- `bus entities add`
  
  Appends counterparty reference data and establishes stable entity identifiers for cross-dataset links. If it emits a result on standard output, it should include the stable entity identifier.

- `bus period open`, `bus period close`, `bus period lock`
  
  Establishes the boundaries that make “period close” repeatable and prevents later drift. These commands must fail deterministically when asked to violate close and lock invariants. If they emit results, they should reference stable period identifiers.

- `bus attachments add`
  
  Registers evidence files and creates attachment identifiers that other datasets can reference. If it emits a result on standard output, it should include the stable attachment identifier and any workspace-relative path needed to locate the evidence.

- `bus invoices add`
  
  Appends invoice datasets and validates totals and VAT breakdowns. If it emits a result on standard output, it should include the stable invoice identifier.

- `bus journal add`
  
  Appends balanced journal transactions and enforces balance invariants. If it emits a result on standard output, it should include the stable transaction or voucher identifier used for traceability.

- `bus bank import`
  
  Imports and normalizes bank statement data into workspace datasets. The command must be usable non-interactively so it can run in automation. If it emits a result on standard output, it should be a stable summary that does not depend on environment-specific strings.

- `bus reconcile match`
  
  Links bank transactions to invoices or journal entries and records allocations as reconciliation datasets. If it emits a result on standard output, it should reference stable identifiers (bank transaction IDs and the linked record IDs).

- `bus validate`
  
  Validates workspace datasets against schemas and cross-table invariants. This command must be usable in CI and other scripted contexts, and it must emit deterministic diagnostics that cite datasets and stable identifiers. In addition to human-readable diagnostics, it should provide at least one machine-readable diagnostics mode suitable for automation.

- `bus vat report`, `bus vat export`
  
  Computes VAT summaries per reporting period and produces export material as repository data for archiving and filing. These commands must support a machine-readable output mode for the computed result set, with a stable schema, stable column order, and stable record ordering as described in [Reporting and query commands](./reporting-and-queries).

- `bus reports trial-balance`
  
  Produces the period-close report output set. This command must support a machine-readable output mode, with a stable schema, stable column order, and stable record ordering.

### Scope and evolution

This is the minimum workflow surface implied by the spec’s current planned modules. As BusDK grows, new modules may add new commands without breaking this minimum surface, consistent with [Extensible CLI surface and API parity](./api-parity).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./command-naming">CLI command naming</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../cli/index">BusDK Design Spec: CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./error-handling-dry-run-diagnostics">Error handling, dry-run, and diagnostics</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

