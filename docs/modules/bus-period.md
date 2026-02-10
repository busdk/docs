## bus-period

### Name

`bus period` — open, close, and lock accounting periods.

### Synopsis

`bus period <command> [options]`

### Description

`bus period` manages period open, close, and lock state as schema-validated repository data. Close generates closing entries; lock prevents further changes to closed period data. Period identifiers are `YYYY`, `YYYY-MM`, or `YYYYQn`.

### Commands

- `init` creates the period control dataset and schema.
- `open` marks a period as open.
- `close` generates closing entries and marks the period closed.
- `lock` locks a closed period so it cannot be modified.

### Options

`open`, `close`, and `lock` require `--period <period>`. `close` accepts optional `--post-date <YYYY-MM-DD>` (defaults to last date of period). For global flags and command-specific help, run `bus period --help`.

### Files

`periods.csv` and its beside-the-table schema at the repository root.

### Exit status

`0` on success. Non-zero on invalid usage or close/lock violations.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-entities">bus-entities</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-attachments">bus-attachments</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Accounting periods](../master-data/accounting-periods/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Bookkeeping status and review workflow](../master-data/workflow-metadata/index)
- [Module SDD: bus-period](../sdd/bus-period)
- [Workflow: Year-end close (closing entries)](../workflow/year-end-close)

