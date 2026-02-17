---
title: Import bank transactions and apply payments
description: When the customer pays, Alice imports the bank statement as evidence, identifies the payment transaction in the normalized bank dataset, and then records…
---

## Import bank transactions and apply payments

When the customer pays, Alice imports the bank statement as evidence, identifies the payment transaction in the normalized bank dataset, and then records reconciliation and any required ledger impact in append-only datasets. This keeps the workflow deterministic and reviewable while the first-class reconciliation proposal and batch-apply command flow is still being implemented.

1. Alice imports the raw bank statement evidence with Bus Bank:

```bash
bus bank import --file 202602-bank-statement.csv
```

Bus Bank writes schema-validated bank datasets and preserves source statement identifiers so each imported transaction remains traceable back to the original evidence.

2. Alice reviews the imported bank transactions and finds the February payment row that corresponds to invoice INV-1001:

```bash
bus bank list --month 2026-2
```

If the module supports filters, she narrows the output to the February date range or to rows that contain the invoice number or counterparty reference. The exact filtering flags are part of the module surface area, so she uses `bus bank list --help` to see what is available in her pinned version.

3. Alice records a direct reconciliation when the payment is an exact one-to-one match:

```bash
bus reconcile match --bank-id BANK-2026-02-14-001 --invoice-id INV-1001
```

For partial payments, batch settlements, or fee splits, she uses allocation instead of one-to-one match.

4. Alice records allocation rows when one bank movement settles multiple targets:

```bash
bus reconcile allocate --bank-id BANK-2026-02-14-002 \
  --invoice INV-1001=900 \
  --journal JRN-2026-014=40 \
  --journal JRN-2026-015=300
```

If reconciliation planning reveals missing bookkeeping (for example bank fees that are not yet posted), she appends the missing journal entry with `bus journal add` and then reruns matching or allocation.

If she is unsure about the available flags in her pinned version, she uses `bus reconcile --help`.

5. Alice verifies the result by reviewing the bank list output and the resulting journal postings, then uses invoice listing as a cross-check:

```bash
bus invoices list
```

When the goal is high-volume or historical reconciliation with deterministic candidate planning and batch application, use [Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply). In this workspace, the candidate planning phase is currently script-driven and the first-class `bus reconcile propose/apply` commands are planned.

When the goal is historical ERP onboarding of invoices and bank datasets, use [Import ERP history into canonical invoices and bank datasets](./import-erp-history-into-canonical-datasets).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./evolution-over-time">Evolution over time (extending the model)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./deterministic-reconciliation-proposals-and-batch-apply">Deterministic reconciliation proposals and batch apply</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-bank module CLI reference](../modules/bus-bank)
- [bus-reconcile module CLI reference](../modules/bus-reconcile)
- [bus-journal module CLI reference](../modules/bus-journal)
- [bus-invoices module CLI reference](../modules/bus-invoices)
- [Workflow: Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply)
- [Import ERP history into canonical invoices and bank datasets](./import-erp-history-into-canonical-datasets)
