---
title: Add a sales invoice (interactive workflow)
description: When Alice needs to bill a client, she adds a sales invoice as repository data and then generates a PDF as a derived artifact linked back to the invoice…
---

## Add a sales invoice (interactive workflow)

When Alice needs to bill a client, she adds a sales invoice as repository data and then generates a PDF as a derived artifact linked back to the invoice records. The important invariant is that invoice totals, VAT, and references are validated at write time so later reporting and postings can treat invoices as trustworthy inputs.

1. Alice confirms she has the account references she will use for invoice line mapping:

```bash
cd 2026-bookkeeping
bus accounts list
```

If she maintains counterparties as reference data, she also checks the customer exists:

```bash
bus entities list
```

2. Alice adds the invoice as explicit invoice and invoice-line records using a non-interactive command surface:

```bash
bus invoices add \
  --type sales \
  --invoice-id 1001 \
  --invoice-date 2026-01-15 \
  --due-date 2026-02-14 \
  --customer "Acme Corp"

bus invoices 1001 add \
  --desc "Consulting, 10h @ €100/h" \
  --quantity 10 --unit-price 100 \
  --revenue-account "Consulting Revenue" \
  --vat-rate 25.5

bus invoices 1001 validate
```

This is intentionally low-level: the module must have a command surface that allows scripts and UIs to write the same canonical invoice rows without relying on interactive prompting. Interactive prompting can still exist as a convenience mode, but it is not the definition of the workflow’s invariants.

On write, the module rejects missing references (unknown customer when entities are required, unknown revenue account, unknown VAT class) and rejects internally inconsistent totals rather than writing partial data.

3. Alice verifies the invoice is present and consistent by listing invoices:

```bash
bus invoices list
```

Generating the PDF representation and registering it as evidence is a separate workflow step, because it is derived output that must remain linked to the invoice records. That step is covered in the next page.

4. Alice records the result as a new revision using her version control tooling.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./configure-chart-of-accounts">Configure the chart of accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./evolution-over-time">Evolution over time (extending the model)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
