## bus-bank

### Name

`bus bank` — import and list bank transactions.

### Synopsis

`bus bank <command> [options]`

### Description

`bus bank` normalizes bank statement data into schema-validated datasets and provides listing output used for reconciliation and posting workflows.

### Commands

- `init` creates the baseline bank datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `import` ingests a bank statement file into normalized datasets.
- `list` prints bank transactions with deterministic filtering.

### Options

`import` accepts `--file <path>`. `list` supports `--month`, `--from`, `--to`, `--counterparty`, and `--invoice-ref`. For global flags and command-specific help, run `bus bank --help`.

### Files

`bank-imports.csv` and `bank-transactions.csv` at the repository root with beside-the-table schemas. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `bank/` folder).

### Exit status

`0` on success. Non-zero on errors, including invalid filters or schema violations.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-journal">bus-journal</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-reconcile">bus-reconcile</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Bank accounts](../master-data/bank-accounts/index)
- [Owns master data: Bank transactions](../master-data/bank-transactions/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Module SDD: bus-bank](../sdd/bus-bank)
- [Workflow context: Import bank transactions and apply payment](../workflow/import-bank-transactions-and-apply-payment)

