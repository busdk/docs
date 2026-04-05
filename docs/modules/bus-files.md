---
title: bus-files — parse and find local evidence files
description: bus files is the planned BusDK surface for parsing local evidence files, extracting rows when a file type supports it, and scanning directories with deterministic duplicate detection.
---

## `bus files` — parse and find local evidence files

`bus files` is the BusDK module for local filesystem work on evidence files such as receipts, bank statements, and other imported accounting source documents. Its job is to inspect files and directories directly, print deterministic parsed output, offer Bus-native filesystem and plain CSV/TSV artifact assertions, and stay clearly separate from workspace attachment storage and journal creation.

The module now exists as a normal BusDK CLI module in the superproject and provides the standard binary, help, version, build, install, test, and e2e surfaces. The larger parse/find feature family is still planned work, but the module already ships a small `assert` surface for common local file checks. The planned parse/find command names still exist as explicit placeholders and fail with deterministic `not implemented yet` diagnostics instead of pretending the parser surface is already shipped.
Use `bus files --help`, `bus files parse --help`, `bus files parse rows --help`, `bus files find --help`, and `bus files assert --help` to see the command shapes directly from the binary.

### Shipped assertion surface

`bus files assert` is the first Bus-native control surface in this module. It lets you check local file conditions and generated CSV/TSV artifact values without `test`, `find`, `wc`, `grep`, or other shell pipelines.

```bash
bus files assert exists receipt.pdf
bus files assert missing archive/old.pdf
bus files assert count 2 a.pdf b.pdf missing.pdf
bus files assert count '>=1' receipts/*.pdf
bus files assert row reports/20241231-tuloslaskelma.csv --filter section=Liikevaihto
bus files assert cell reports/20241231-tuloslaskelma.csv --row-filter section=Liikevaihto --column amount --equals 36794.17
```

The shipped forms are:

- `bus files assert exists <path...>`
- `bus files assert missing <path...>`
- `bus files assert count <EXPECTED> <path...>`
- `bus files assert row <file> --filter column=value ...`
- `bus files assert cell <file> --row-filter column=value ... --column NAME --equals VALUE`

The command prints deterministic TSV output with `assertion`, `target`, `expected`, `observed`, and `status`. It exits `0` when the assertion passes, `1` on mismatch, and `2` on malformed usage. `count` compares how many provided paths currently exist, so shell-expanded globs remain useful without text-processing pipelines.

`row` and `cell` work on plain `.csv` and `.tsv` files without adjacent schema files. They use the first row as headers and select logical rows by exact `column=value` filters. `row` asserts how many matching rows exist, defaulting to `>=1`. `cell` requires exactly one matching logical row and then checks one exact value in one named column, which is the common report-control case for columns such as `amount` and `prior`.

### Planned command shapes

The intended first-class commands are:

```bash
bus files parse receipt.pdf
bus files parse receipt-a.pdf receipt-b.pdf
bus files parse rows receipt.pdf
bus files find ./evidence
```

`parse` is the file-level command. It should eventually read one or many local files and print deterministic parsed metadata or text extraction results without mutating the workspace.

`parse rows` is the narrower row or item-line extraction command. Use it when the file type supports structured row extraction and you want line-level output instead of only receipt- or statement-level metadata.

`find` is the directory scan and duplicate-control command. It should walk one or many local directories, fingerprint files deterministically, report duplicates using explicit non-fuzzy signals such as hashes, and print a stable inventory-style result.

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
bus files parse receipt.pdf
bus files parse rows receipt.pdf
bus files find ./evidence
```

Help and version work like other BusDK modules. Command-local help is available for `parse`, `parse rows`, `find`, and `assert`, so the reserved syntax can be discovered in place directly from the binary. `assert` already works and returns a real pass/fail result surface. The three planned parser/discovery command families still fail explicitly with a deterministic `not implemented yet` diagnostic and non-zero exit status when run without `--help`. This keeps the superproject and dispatcher surfaces consistent while the larger parser functionality is still under implementation.

### How this differs from nearby modules

`bus files` is intentionally not the same thing as [bus attachments](./bus-attachments). `bus attachments` stores evidence inside the workspace and records attachment metadata in canonical datasets. `bus files` is the earlier filesystem-facing tool that inspects local files before they are attached, posted, or otherwise brought into a BusDK workflow.

It is also intentionally separate from [bus bank](./bus-bank) and [bus journal](./bus-journal). `bus bank` owns canonical bank datasets after import, statement checkpoints, and reconciliation-ready bank rows. `bus journal` creates bookkeeping postings. `bus files` should stay a parser and finder tool, not a posting tool.

### Output intent

The intended default ergonomics are lightweight and human-readable. With one file, `parse` may print one readable block. With several files, it may print one block per file separated by blank lines, or one stable line per file when that is clearer for the chosen subcommand. Machine-readable output still belongs behind explicit `--format` selection.

For `find`, duplicate detection should remain deterministic. Exact file hashes, normalized content hashes, and other explicit identity signals are acceptable. Fuzzy similarity guesses should not be the default behavior.

### Current status

The `bus-files` module has been added to the BusDK superproject as a normal buildable/installable CLI module, and its planned scope is tracked in the module plan. The command surface described here remains the intended first implementation target, especially for generic native parsing of local evidence files and common bank-statement PDFs without sidecar-first workflows.

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
