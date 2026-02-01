## Create a sales invoice (interactive workflow)

When Alice needs to bill a client, she creates a sales invoice as repository data and then generates a PDF as a derived artifact linked back to the invoice records. The important invariant is that invoice totals, VAT, and references are validated at write time so later reporting and postings can treat invoices as trustworthy inputs.

1. Alice confirms she has the account references she will use for invoice line mapping:

```bash
bus accounts list
```

If she maintains counterparties as reference data, she also checks the customer exists:

```bash
bus entities list
```

2. Alice creates the invoice using interactive prompting. She intentionally omits some fields so the tool asks for them:

```bash
bus invoices create --help
bus invoices create --type sales
```

The tool requests the invoice number (for example `INV-1001`, with optional auto-generation), invoice date (for example `2026-01-15`), customer name (for example `Acme Corp`), and line items. Alice enters a consulting line for 10 hours at €100/hour, maps it to her consulting revenue account, and selects a 24% VAT rate. The module calculates subtotal €1000, VAT €240, and total €1240, and defaults the due date to 30 days from the invoice date (for example `2026-02-14`) unless she overrides it.

On confirmation, the module appends rows to `sales-invoices.csv` and `sales-invoice-lines.csv` and rejects mismatched totals or missing references rather than writing partial data.

3. Alice generates the PDF representation and stores it as an attachment:

```bash
bus invoices pdf --help
bus invoices pdf ...
```

The PDF file path lives inside the repository data alongside other evidence and is referenced from `attachments.csv` so the invoice records and their rendered document remain linked for later review.

4. Alice verifies the invoice is present and consistent by listing invoices:

```bash
bus invoices list
```

5. Alice records the result as a new revision using her version control tooling.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./configure-chart-of-accounts">Configure the chart of accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./evolution-over-time">Evolution over time (extending the model)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
