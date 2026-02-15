---
title: Sale invoicing (sending invoices to customers)
description: Journey for creating sales invoices, rendering PDFs, and sending them to customers — distinct from accounting, which also records incoming and third-party invoices.
---

## Sale invoicing (sending invoices to customers)

This workflow describes the journey of creating sales invoices and sending them to customers. It is concerned with outbound invoicing: you generate the invoice content, validate it, produce a PDF, and deliver it to the customer. That is different from the broader [accounting workflow](./accounting-workflow-overview), which records and reports on all kinds of invoices — including purchase invoices from suppliers, invoices received from customers, or invoices produced by third-party systems — as well as the sales invoices you issue. Here the focus is only on the path from “we need to bill this customer” to “the customer has received the invoice.”

### Prerequisites

Sale invoicing relies on the same master data as the rest of bookkeeping for the entities and accounts you reference. Customers are represented as [parties](../master-data/parties/index) in [`bus entities`](../modules/bus-entities). The [chart of accounts](../master-data/chart-of-accounts/index) must include the revenue and VAT accounts used on invoice lines; [`bus accounts`](../modules/bus-accounts) maintains that data. If you use a dedicated workspace for invoicing, you still run [`bus init`](../modules/bus) (or the relevant module inits) so that invoice datasets and schemas exist. See [Add a sales invoice (interactive workflow)](./create-sales-invoice) for the exact sequence of checking accounts and entities before adding an invoice.

### Creating the invoice

You add a sales invoice as schema-validated repository data: a header (invoice id, dates, customer) and one or more lines (description, quantity, unit price, revenue account, VAT rate). The [bus-invoices](../modules/bus-invoices) module owns the sales (and purchase) invoice datasets and provides `bus invoices add`, `bus invoices <invoice-id> add`, and `bus invoices <invoice-id> validate`. Totals and VAT are validated at write time so the record is consistent before you render or send anything. The step-by-step flow is described in [Add a sales invoice (interactive workflow)](./create-sales-invoice).

### Generating the PDF and sending

Once the invoice record exists and validates, you render a PDF using [`bus invoices pdf`](../modules/bus-invoices) (which delegates to [bus-pdf](../modules/bus-pdf)). The PDF is a derived artifact; the source of truth remains the invoice rows in the workspace. You can then send the PDF to the customer by whatever channel you use — email, portal, or post — either manually or via your own script or integration. BusDK does not prescribe or implement the delivery channel; it provides the validated invoice data and the ability to produce a PDF so that sending can be automated or manual as you prefer.

### How this journey relates to accounting

In the [accounting workflow](./accounting-workflow-overview), invoices are one of the inputs to the ledger: you record sales and purchase invoices, post them (or their posting intent) to the journal, and later reconcile with bank and reports. Accounting may consume sales invoices you created in this journey, or it may consume invoices that originated elsewhere (e.g. from a third-party system or received from a customer). The sale-invoicing journey is only about creating and sending your own sales invoices; accounting is about recording, posting, and reporting on all of them.

### Module readiness for this journey

Readiness for the modules involved in creating and sending sales invoices is summarised in [Development status — Sale invoicing (sending invoices to customers)](../implementation/development-status#sale-invoicing-sending-invoices-to-customers).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./accounting-workflow-overview">Accounting workflow overview (current planned modules)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Example end-to-end workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./create-sales-invoice">Add a sales invoice (interactive workflow)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting workflow overview](./accounting-workflow-overview)
- [Add a sales invoice (interactive workflow)](./create-sales-invoice)
- [bus-invoices](../modules/bus-invoices)
- [bus-pdf](../modules/bus-pdf)
- [bus-entities](../modules/bus-entities)
- [Development status: Sale invoicing](../implementation/development-status#sale-invoicing-sending-invoices-to-customers)
