---
title: Validation and safety checks
description: Before any data mutation, the CLI performs schema validation and logical validation.
---

## Validation and safety checks

Before any data mutation, the CLI performs schema validation and logical validation. Schema validation ensures type correctness and referential integrity. Logical validation enforces business rules such as existing account references, balanced debits and credits for transactions, invoice totals matching line items, and VAT classification completeness when generating VAT reports. If errors are found, the command fails with a clear diagnostic and refuses to commit invalid data.

Validation failures must be script-friendly and deterministic. Commands must exit non-zero on validation failure and must write diagnostics to standard error so that standard output remains reserved for command results and exports. Diagnostics should cite datasets and stable identifiers so that validation output can be reviewed and compared across revisions.

For Finnish compliance, validation MUST also enforce audit-trail invariants (stable IDs, required voucher references, deterministic ordering fields) and must prevent changes that would break a closed period or previously reported data. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

For migration-quality controls, validation also needs deterministic parity and gap checks between source imports and workspace or journal activity. The planned first-class command flow is documented in [Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./reporting-and-queries">Reporting and query commands</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../workflow/index">BusDK Design Spec: Example end-to-end workflow</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-validate module CLI reference](../modules/bus-validate)
- [bus-validate SDD](../sdd/bus-validate)
- [Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
