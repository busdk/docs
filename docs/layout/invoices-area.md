---
title: Invoices area (headers and lines)
description: The invoices area contains invoicing data.
---

## Invoices area (headers and lines)

The invoices area contains invoicing data. Sales and purchase invoices are separated for clarity. A typical structure includes `sales-invoices.csv` for invoice headers and `sales-invoice-lines.csv` for line items, and similarly `purchase-invoices.csv` and `purchase-invoice-lines.csv` for purchases. Header records include invoice number, date, counterparty identifier, due date, total amount, VAT amount, and status such as unpaid or paid. Line items include invoice number as a foreign key, description, quantity, unit price, line total, VAT rate, and ledger account mapping. Schemas enforce referential integrity and numeric constraints such as non-negative totals. A combined `invoices.csv` with a type column is possible, but separation is preferred to simplify VAT handling differences.

For Finnish compliance, invoice headers and lines MUST carry identifiers and references that make the voucher trail verifiable. At minimum: unique invoice identifier, invoice number, invoice date, counterparty, totals, VAT breakdown, and links to attachments and voucher/posting references. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./invoice-pdf-storage">Invoice PDF storage</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./journal-area">Journal area (general ledger transactions)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
