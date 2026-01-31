# Create a sales invoice (interactive workflow)

When Alice needs to bill a client, she issues a sales invoice. She runs `busdk invoice create --type sales` without providing all fields, and the tool enters interactive mode. It requests the invoice number (such as “INV-1001,” with optional auto-generation), invoice date (such as 2026-01-15), customer name (such as “Acme Corp,” optionally selectable from a customer list if maintained), then prompts for line items iteratively. Alice enters a line item for consulting services with a quantity of 10 hours at €100/hour, maps it to her consulting revenue account, and sets VAT rate to 24%. The CLI calculates subtotal €1000, VAT €240, total €1240, and defaults due date to 30 days from invoice date (2026-02-14). After confirmation, the module writes the invoice header to `invoices/sales_invoices.csv`, writes the line item to `invoices/sales_invoice_lines.csv`, generates `invoices/pdf/INV-1001.pdf` with branding and required details, then the change is committed via external Git tooling with a message such as “Add sales invoice INV-1001 for €1240 to Acme Corp.”

---

<!-- busdk-docs-nav start -->
**Prev:** [Configure the chart of accounts](./configure-chart-of-accounts) · **Index:** [BusDK Design Document](../../index) · **Next:** [Evolution over time (extending the model)](./evolution-over-time)
<!-- busdk-docs-nav end -->
