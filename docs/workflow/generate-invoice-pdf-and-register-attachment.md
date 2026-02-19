---
title: Generate invoice PDF and register it as evidence
description: An invoice PDF is derived output.
---

## Generate invoice PDF and register it as evidence

An invoice PDF is derived output. The workflow keeps it reviewable by storing the rendered document as repository data and registering it in the attachments dataset so it remains linked to the invoice records that justify it.

1. Alice renders a PDF for a specific invoice:

```bash
bus invoices pdf 1001 --out tmp/INV-1001.pdf
```

The module must render deterministically from the stored invoice and invoice-line rows. If the output file already exists, it must be overwritten only when explicitly requested, because the PDF file is evidence that is expected to remain stable once issued.

2. Alice registers the rendered PDF in the attachments dataset so other records can reference it:

```bash
bus attachments add --help

bus attachments add tmp/INV-1001.pdf \
  --desc "Invoice INV-1001 (PDF)"
```

3. Alice confirms the attachment is discoverable as repository data:

```bash
bus attachments list
```

4. Alice records the result as a new revision using her version control tooling.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./create-sales-invoice">Add a sales invoice (interactive workflow)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./invoice-ledger-impact">Invoice ledger impact (integration through journal entries)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-invoices module CLI reference](../modules/bus-invoices)
- [bus-pdf module CLI reference](../modules/bus-pdf)
- [bus-attachments module CLI reference](../modules/bus-attachments)
