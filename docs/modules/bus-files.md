---
title: bus-files — parse and find local evidence files
description: bus files is the planned BusDK surface for parsing local evidence files, extracting rows when a file type supports it, and scanning directories with deterministic duplicate detection.
---

## `bus files` — parse and find local evidence files

`bus files` is the BusDK module for local filesystem work on evidence files such as receipts, bank statements, and other imported accounting source documents. Its job is to inspect files and directories directly, print deterministic parsed output, and stay clearly separate from workspace attachment storage and journal creation.

The module now exists as a normal BusDK CLI module in the superproject and provides the standard binary, help, version, build, install, test, and e2e surfaces. The actual parse/find feature family is still planned work. Today the command names exist only as explicit placeholders and fail with deterministic `not implemented yet` diagnostics instead of pretending the parser surface is already shipped.
Use `bus files --help`, `bus files parse --help`, `bus files parse rows --help`, and `bus files find --help` to see the reserved command shapes directly from the binary.

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
bus files --version
bus files parse receipt.pdf
bus files parse rows receipt.pdf
bus files find ./evidence
```

Help and version work like other BusDK modules. Command-local help is available for `parse`, `parse rows`, and `find`, so the reserved syntax can be discovered in place even before the parser implementation lands. The three planned command families currently fail explicitly with a deterministic `not implemented yet` diagnostic and non-zero exit status when run without `--help`. This keeps the superproject and dispatcher surfaces consistent while the actual parser functionality is still under implementation.

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
