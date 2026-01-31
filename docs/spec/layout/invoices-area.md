## Invoices area (headers and lines)

The invoices area contains invoicing data. Sales and purchase invoices are separated for clarity. A typical structure includes `sales_invoices.csv` for invoice headers and `sales_invoice_lines.csv` for line items, and similarly `purchase_invoices.csv` and `purchase_invoice_lines.csv` for purchases. Header records include invoice number, date, customer or supplier identifier, due date, total amount, VAT amount, and status such as unpaid or paid. Line items include invoice number as a foreign key, description, quantity, unit price, line total, VAT rate, and ledger account mapping. Schemas enforce referential integrity and numeric constraints such as non-negative totals. A combined `invoices.csv` with a type column is possible, but separation is preferred to simplify VAT handling differences.

For Finnish compliance, invoice headers and lines MUST carry identifiers and references that make the voucher trail verifiable. At minimum: unique invoice identifier, invoice number, invoice date, counterparty, totals, VAT breakdown, and links to attachments and voucher/posting references. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
**Prev:** [Invoice PDF storage](./invoice-pdf-storage) · **Index:** [BusDK Design Document](../../index) · **Next:** [Journal area (general ledger transactions)](./journal-area)
<!-- busdk-docs-nav end -->
