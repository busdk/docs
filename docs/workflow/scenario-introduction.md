---
title: Scenario introduction
description: Consider Alice, a freelance consultant using BusDK to run bookkeeping in a dedicated repository workspace.
---

## Scenario introduction

Consider Alice, a freelance consultant using BusDK to run bookkeeping in a dedicated repository workspace. She uses the `bus` dispatcher and a small set of focused modules (accounts, entities, journal, invoices, bank, reconcile, VAT, reports) to keep her CSV-based records validated, auditable, and reproducible, while handling version control operations outside BusDK.

In practice her workflow is a small sequence of repeatable module commands that produce and validate repository data:

1. She bootstraps the workspace datasets and schemas:

```bash
bus init
```

2. She configures master data such as the chart of accounts:

```bash
bus accounts add --code 3000 --name "Sales income 25.5%" --type income
bus entities add --id CUST-ACME --name "Acme Oy"
```

3. She records day-to-day activity using subledger commands and append-only journal postings:

```bash
bus invoices add --type sales --invoice-id INV-1001 --invoice-date 2026-02-14 --due-date 2026-03-14 --customer "Acme Oy"
bus journal add --date 2026-02-14 --desc "Sales invoice INV-1001" --debit 1700=125.50 --credit 3000=100.00 --credit 2930=25.50
```

4. She imports evidence such as bank statements, then records the ledger impact explicitly:

```bash
bus bank import --file 202602-bank-statement.csv
bus reconcile match --bank-id BANK-2026-02-14-001 --invoice-id INV-1001
```

5. She closes reporting periods by computing VAT and producing report outputs:

```bash
bus vat report --period 2026-02
bus reports trial-balance --as-of 2026-02-28
```

The full, module-level flow is summarized in `workflow/accounting-workflow-overview.md`, and the rest of this section walks through concrete examples of how the pieces fit together.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./record-purchase-journal-transaction">Record a purchase as a journal transaction</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-reporting-and-payment">VAT reporting and payment</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting workflow overview](./accounting-workflow-overview)
- [bus-accounts module CLI reference](../modules/bus-accounts)
- [bus-entities module CLI reference](../modules/bus-entities)
- [bus-invoices module CLI reference](../modules/bus-invoices)
- [bus-journal module CLI reference](../modules/bus-journal)
- [bus-bank module CLI reference](../modules/bus-bank)
- [bus-reconcile module CLI reference](../modules/bus-reconcile)
- [bus-vat module CLI reference](../modules/bus-vat)
- [bus-reports module CLI reference](../modules/bus-reports)
