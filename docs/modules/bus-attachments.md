## bus-attachments

### Name

`bus attachments` — register and list evidence files.

### Synopsis

`bus attachments <command> [options]`

### Description

`bus attachments` registers evidence files and stores attachment metadata in `attachments.csv` so other modules can link to evidence without embedding file paths directly in domain datasets.

### Commands

- `add` registers a file and writes attachment metadata.
- `list` prints registered attachments in deterministic order.

### Options

`add` accepts a positional `<file>` plus `--desc <text>`. For global flags and command-specific help, run `bus attachments --help`.

### Files

`attachments.csv` and its beside-the-table schema at the repository root, plus evidence files stored under a predictable period path such as `2026/attachments/`.

### Exit status

`0` on success. Non-zero on errors, including missing files or schema violations.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-period">bus-period</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-invoices">bus-invoices</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Documents (evidence)](../master-data/documents/index)
- [Master data: Bookkeeping status and review workflow](../master-data/workflow-metadata/index)
- [Module SDD: bus-attachments](../sdd/bus-attachments)
- [Attachment storage: Invoice PDF storage](../layout/invoice-pdf-storage)

