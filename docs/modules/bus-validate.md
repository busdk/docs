## bus-validate

### Name

`bus validate` — validate workspace datasets and invariants.

### Synopsis

`bus validate [options]`

### Description

`bus validate` checks all workspace datasets against their schemas and enforces cross-table invariants (e.g. balanced debits/credits, valid references, period integrity). It does not modify data. Use before period close and filing. Diagnostics go to stderr; stdout is empty on success.

### Commands

This module has no subcommands. Run `bus validate` from the workspace (or use `-C <dir>`).

### Options

`--format text` (default) or `--format tsv` controls diagnostics format. TSV columns are `dataset`, `record_id`, `field`, `rule`, `message`. For global flags and help, run `bus validate --help`.

### Files

Reads all workspace datasets and schemas. Does not write.

### Exit status

`0` when the workspace is valid. Non-zero on invalid usage or when schema or invariant violations are found.

### See also

Module SDD: [bus-validate](../sdd/bus-validate)  
Architecture: [Shared validation layer](../architecture/shared-validation-layer)  
CLI: [Validation and safety checks](../cli/validation-and-safety-checks)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reports">bus-reports</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vat">bus-vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
