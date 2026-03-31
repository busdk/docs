---
title: bus attachments — register and link evidence files
description: bus attachments stores evidence files in the workspace, records metadata in canonical datasets, and links those files to invoices, vouchers, bank rows, or other resources.
---

## `bus attachments` — register and link evidence files

`bus attachments` gives source documents a stable place in the workspace. Use it when you want to copy a file into the repository, give it an attachment ID, and link that file to a voucher, invoice, bank row, or another resource.

This is the module that keeps evidence files separate from business data while still making them auditable and easy to query.

### Common tasks

Create the attachment datasets:

```bash
bus attachments init
```

Register one PDF and reserve its visible voucher number immediately:

```bash
bus attachments add ./evidence/receipt.pdf --voucher V-2026-000123 --desc "Card receipt"
```

Link the same file later to a bank row without looking up the attachment ID first:

```bash
bus attachments link \
  --path attachments/2026/01/20260115-INV-1001.pdf \
  --bank-row bank_row:27201 \
  --if-missing
```

List unlinked evidence so nothing is forgotten before close:

```bash
bus attachments --format tsv -o ./out/unlinked-attachments.tsv list --unlinked-only
```

List everything linked to one voucher in a graph-style view:

```bash
bus attachments list --by-voucher V-2026-000123 --graph
```

### Synopsis

`bus attachments init [-C <dir>] [global flags]`  
`bus attachments add <file> [<voucher_id>] [--desc <text>] [--voucher <id>] [-C <dir>] [global flags]`  
`bus attachments link <attachment_id> [--if-missing] [--kind <kind> --id <resource_id> | --bank-row <id> | --voucher <id> | --invoice <id>] [-C <dir>] [global flags]`  
`bus attachments link [--path <relpath>|--desc-exact <text>|--source-hash <sha256>] [--if-missing] [--kind <kind> --id <resource_id> | --bank-row <id> | --voucher <id> | --invoice <id>] [-C <dir>] [global flags]`  
`bus attachments list [filters] [-C <dir>] [global flags]`

### The basic model

`add` registers a file and copies it into the workspace attachment area. The file gets metadata such as attachment ID, filename, MIME type, hash, and repository-relative path. If you already know the visible voucher number that should own that evidence, pass `--voucher <id>` and `add` writes the voucher link immediately instead of requiring a separate `link` command later.

`link` connects that attachment to a business resource. The most common shortcuts are `--invoice`, `--voucher`, and `--bank-row`, but you can also use a custom `--kind` and `--id`.

`list` is your audit view. It helps answer questions like “which files are not linked yet?” or “what evidence belongs to this voucher?”.

### Finding the attachment to link

If you already know the attachment ID, use it directly.

If you do not know the ID, `link` can resolve the attachment deterministically by path, exact description, or source hash. This is useful in replay scripts and automation because you do not need a separate lookup step.

### Typical workflow

Many users use this module alongside invoices, bank import, and journal work:

```bash
bus attachments add ./evidence/receipt-2026-01-15.pdf V-2026-000045 --desc "Card receipt"
bus attachments list --by-voucher V-2026-000045 --graph
```

If two positional arguments are given to `add`, one of them must resolve to the existing input file path and the other is treated as the voucher id. If both look like files or neither does, the command fails as ambiguous instead of guessing.

For periodic cleanup before close:

```bash
bus attachments list --unlinked-only
bus status evidence-coverage --year 2026
```

### Files

Attachment metadata lives in `attachments.csv` and `attachment-links.csv` at the workspace root. The copied evidence files themselves are stored under dated subdirectories such as `attachments/2026/01/20260115-invoice.pdf`.

### Output and flags

These commands use [Standard global flags](../cli/global-flags). In practice, `--graph`, `--unlinked-only`, `--by-voucher`, `--by-invoice`, and `--by-bank-row` are the most useful list options for day-to-day work.

Use `--if-missing` when your automation should behave idempotently and skip an already-existing link instead of failing.

For the full command and filter list, run `bus attachments --help`.

### Exit status

`0` on success. Non-zero on invalid usage, missing files, ambiguous attachment selectors, or dataset validation errors.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus attachments add ./evidence/BANK-2026-01.pdf --desc "January bank statement"
attachments add ./evidence/BANK-2026-01.pdf --desc "January bank statement"

# same as: bus attachments link --source-hash 9f0d2c... --voucher V-2026-000123 --if-missing
attachments link --source-hash 9f0d2c... --voucher V-2026-000123 --if-missing

# same as: bus attachments list --unlinked-only --graph
attachments list --unlinked-only --graph
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-period">bus-period</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-invoices">bus-invoices</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Documents (evidence)](../master-data/documents/index)
- [Module reference: bus-attachments](../modules/bus-attachments)
- [Attachment storage: Invoice PDF storage](../layout/invoice-pdf-storage)
- [Module reference: bus-status](../modules/bus-status)
- [Finnish closing adjustments and evidence controls](../compliance/fi-closing-adjustments-and-evidence-controls)
