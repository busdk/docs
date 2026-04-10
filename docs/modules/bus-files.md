---
title: bus-files — parse and find local evidence files
description: bus files parses local evidence files, extracts supported row-level content, scans directories with deterministic duplicate detection, and asserts plain CSV/TSV artifacts without shell pipelines.
---

## `bus files` — parse and find local evidence files

`bus files` is the BusDK module for local filesystem work on evidence files such as receipts, bank statements, and other imported accounting source documents. Its job is to inspect files and directories directly, print deterministic parsed output, offer Bus-native filesystem and plain CSV/TSV artifact assertions, and stay clearly separate from workspace attachment storage and journal creation.

The module now ships a practical parse/find surface. `bus files parse` emits file-level summaries with inferred format, file kind, size, `sha256`, and lightweight structure details such as line count or table headers. `bus files parse rows` extracts logical rows from supported file formats. `bus files find` walks directories recursively and annotates deterministic duplicate groups by identical file content. Use `bus files --help`, `bus files parse --help`, `bus files parse rows --help`, `bus files find --help`, and `bus files assert --help` to inspect the exact CLI shapes directly from the binary.

### Shipped assertion surface

`bus files assert` is the first Bus-native control surface in this module. It lets you check local file conditions and generated CSV/TSV artifact values without `test`, `find`, `wc`, `grep`, or other shell pipelines.

```bash
bus files assert exists receipt.pdf
bus files assert missing archive/old.pdf
bus files assert count 2 a.pdf b.pdf missing.pdf
bus files assert count '>=1' receipts/*.pdf
bus files assert row reports/20241231-tuloslaskelma.csv --filter section=Liikevaihto
bus files assert cell reports/20241231-tuloslaskelma.csv --row-filter section=Liikevaihto --column amount --equals 36794.17
bus files assert expr reports/20241231-tase-accounts.csv --select-many cash 'account_code=1910|1911|1930' --eval 'sum(cash.amount)' --equals 129.27
```

The shipped forms are:

- `bus files assert exists <path...>`
- `bus files assert missing <path...>`
- `bus files assert count <EXPECTED> <path...>`
- `bus files assert row <file> --filter column=value ...`
- `bus files assert cell <file> --row-filter column=value ... --column NAME --equals VALUE`
- `bus files assert expr <file> --select-one/--select-many/--select ... --eval EXPR --equals VALUE`

The command prints deterministic TSV output with `assertion`, `target`, `expected`, `observed`, and `status`. It exits `0` when the assertion passes, `1` on mismatch, and `2` on malformed usage. `count` compares how many provided paths currently exist, so shell-expanded globs remain useful without text-processing pipelines.

`row` and `cell` work on plain `.csv` and `.tsv` files without adjacent schema files. They use the first row as headers and select logical rows by exact `column=value` filters. `row` asserts how many matching rows exist, defaulting to `>=1`. `cell` requires exactly one matching logical row and then checks one exact value in one named column, which is the common report-control case for columns such as `amount` and `prior`.

`expr` adds a small aggregate/arithmetic layer on top of the same plain-file model. It auto-detects `csv` or `tsv` from file extension or the first non-empty data line unless `--format` overrides it. Use:

- `--select-one NAME FILTER` for exactly one required row
- `--select-many NAME FILTER` for one or more required rows
- `--select NAME FILTER` for an optional row-set that may also be empty

The filter still uses header keys from the first row. `account_code=1910|1911|1930` means one column with several accepted alternatives. `*` or `all` selects every row.

Expression references follow the binding names. For one-row bindings, `a.amount` is one scalar value. For row-set bindings, `cash.amount` is the projected array of `amount` values from every matched row. The supported aggregate functions are `sum(...)`, `avg(...)`, `min(...)`, `max(...)`, and `count(...)`. Top-level arithmetic currently supports `+` and `-` between scalar results such as:

```bash
bus files assert expr report.csv --select-one a 'account_code=1940' --eval 'a.debit + a.credit' --equals 0
bus files assert expr report.csv --select-many cash 'account_code=1910|1911|1930' --eval 'sum(cash.amount)' --equals 129.27
```

### Parse and find command shapes

The shipped first-class commands are:

```bash
bus files parse receipt.pdf
bus files parse receipt-a.pdf receipt-b.pdf
bus files parse rows receipt.pdf
bus files find ./evidence
```

`parse` is the file-level command. It reads one or many local files and prints deterministic parsed metadata without mutating the workspace. With one file it defaults to a human-readable text block. With several files it defaults to TSV. Explicit machine output is available through `--format json`, and explicit TSV is available through `--format tsv`.

`parse rows` is the narrower row or item-line extraction command. Use it when the file type supports structured row extraction and you want line-level output instead of only receipt- or statement-level metadata. CSV/TSV files emit one row per data row using stable `header=value` pairs. Plain UTF-8 text and JSON files emit one row per non-empty line. Binary and PDF files still remain valid `parse` targets, but `parse rows` returns an explicit unsupported-format error for them.

`find` is the directory scan and duplicate-control command. It walks one or many local directories, fingerprints files deterministically, reports duplicates using explicit non-fuzzy signals such as hashes, and prints a stable inventory-style result. `--duplicates-only` keeps only files that belong to a duplicate group.

### Current shipped behavior

The currently shipped behavior is intentionally minimal:

```bash
bus files --help
bus files parse --help
bus files parse rows --help
bus files find --help
bus files assert --help
bus files --version
bus files assert exists receipt.pdf
bus files assert count '>=1' receipts/*.pdf
bus files assert row reports/20241231-tuloslaskelma.csv --filter section=Liikevaihto
bus files assert cell reports/20241231-tuloslaskelma.csv --row-filter section=Liikevaihto --column prior --equals 69655.71
bus files assert expr reports/20241231-tase-accounts.csv --select-many cash 'account_code=1910|1911|1930' --eval 'sum(cash.amount)' --equals 129.27
bus files parse receipt.pdf
bus files parse report.csv notes.txt
bus files parse rows report.csv
bus files find ./evidence
bus files find --duplicates-only ./evidence
```

Help and version work like other BusDK modules. Command-local help is available for `parse`, `parse rows`, `find`, and `assert`. `parse`, `parse rows`, and `find` now run for real instead of being placeholders. The current practical support level is:

- file-level parse summaries for local files including `csv`, `tsv`, `text`, `json`, `pdf`, and generic binary detection
- row extraction for `csv`, `tsv`, `text`, and `json`
- directory scan plus deterministic duplicate grouping by `sha256`
- first-class assert support for existence, count, row, cell, and aggregate expression checks

Native bank-statement PDF row extraction is still narrower than the long-term goal. Today PDFs are valid `parse` inputs but not yet row-extraction inputs.

### How this differs from nearby modules

`bus files` is intentionally not the same thing as [bus attachments](./bus-attachments). `bus attachments` stores evidence inside the workspace and records attachment metadata in canonical datasets. `bus files` is the earlier filesystem-facing tool that inspects local files before they are attached, posted, or otherwise brought into a BusDK workflow.

It is also intentionally separate from [bus bank](./bus-bank) and [bus journal](./bus-journal). `bus bank` owns canonical bank datasets after import, statement checkpoints, and reconciliation-ready bank rows. `bus journal` creates bookkeeping postings. `bus files` should stay a parser and finder tool, not a posting tool.

### Output intent

The intended default ergonomics are lightweight and human-readable. With one file, `parse` may print one readable block. With several files, it may print one block per file separated by blank lines, or one stable line per file when that is clearer for the chosen subcommand. Machine-readable output still belongs behind explicit `--format` selection.

For `find`, duplicate detection should remain deterministic. Exact file hashes, normalized content hashes, and other explicit identity signals are acceptable. Fuzzy similarity guesses should not be the default behavior.

### Current status

The `bus-files` module is a normal buildable/installable BusDK CLI module and now ships the parse/find/assert surface described above. The remaining gap relative to the long-term goal is deeper native row extraction for evidence formats such as text-extractable bank-statement PDFs.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-attachments">bus-attachments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-invoices">bus-invoices</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module reference: bus-attachments](./bus-attachments)
- [Module reference: bus-bank](./bus-bank)
- [Module reference: bus-journal](./bus-journal)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [Master data: Bank transactions](../master-data/bank-transactions/index)
