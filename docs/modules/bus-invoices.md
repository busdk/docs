## bus-invoices

### Name

`bus invoices` — create and manage sales and purchase invoices.

### Synopsis

`bus invoices <command> [options]`  
`bus invoices <invoice-id> add [options]`  
`bus invoices <invoice-id> validate`

### Description

`bus invoices` stores sales and purchase invoices as schema-validated repository data, validates totals and VAT, and can emit posting outputs for the journal. Invoice headers and lines reference entities, accounts, and attachments.

### Commands

- `init` creates the baseline invoice datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `add` adds a new invoice header (sales or purchase).
- `<invoice-id> add` adds a line item to an existing invoice.
- `<invoice-id> validate` validates line items and totals for an invoice.
- `list` lists invoices with optional filters.
- `pdf` renders an invoice PDF from a prepared render model.

### Options

`add` accepts `--type <sales|purchase>`, `--invoice-id`, `--invoice-date`, `--due-date`, `--customer`. Line `add` accepts `--desc`, `--quantity`, `--unit-price`, `--revenue-account`, `--vat-rate`. `list` supports `--type`, `--status`, `--month`, `--from`, `--to`, `--due-from`, `--due-to`, `--counterparty`, `--invoice-id`. `pdf` accepts `<invoice-id>` and `--out <path>`. For global flags and command-specific help, run `bus invoices --help`.

### Files

Invoice master data is stored only in the project root; it is never under an `invoices/` directory. The files `sales-invoices.csv`, `purchase-invoices.csv`, `sales-invoice-lines.csv`, and `purchase-invoice-lines.csv`, and each dataset’s `.schema.json` file (e.g. `sales-invoices.schema.json`), all live in the same directory at the workspace root.

### Exit status

`0` on success. Non-zero on errors, including invalid usage, schema violations, or reference errors.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-attachments">bus-attachments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-journal">bus-journal</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Sales invoices](../master-data/sales-invoices/index)
- [Owns master data: Sales invoice rows](../master-data/sales-invoice-rows/index)
- [Owns master data: Purchase invoices](../master-data/purchase-invoices/index)
- [Owns master data: Purchase posting specifications](../master-data/purchase-posting-specifications/index)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Owns master data: Bookkeeping status and review workflow](../master-data/workflow-metadata/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module SDD: bus-invoices](../sdd/bus-invoices)
- [Layout: Invoices area](../layout/invoices-area)
- [Workflow: Create a sales invoice](../workflow/create-sales-invoice)

