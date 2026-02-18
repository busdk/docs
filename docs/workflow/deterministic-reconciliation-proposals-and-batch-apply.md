---
title: Deterministic reconciliation proposals and batch apply
description: Two-phase reconciliation workflow where bus reconcile generates deterministic proposal rows and then applies approved rows in batch with dry-run and idempotent semantics.
---

## Deterministic reconciliation proposals and batch apply

The reconciliation workflow is a two-phase command flow. First, the system generates deterministic proposal rows from bank and invoice or journal datasets. Second, operators review and approve proposal rows, then apply those approved rows in batch. This keeps candidate planning and write operations separate, reviewable, and script-friendly.

### Two-phase flow (implemented)

`bus reconcile propose` and `bus reconcile apply` provide the flow. Direct writes via `bus reconcile match`, `bus reconcile allocate`, and `bus reconcile list` remain available for one-off use. Script-based candidate planning (e.g. `exports/2024/025-reconcile-sales-candidates-2024.sh`) remains an alternative where teams prefer it.

```bash
bus reconcile propose --out reconcile-proposals-2024.tsv
bus reconcile apply --in reconcile-proposals-2024-approved.tsv --dry-run
bus reconcile apply --in reconcile-proposals-2024-approved.tsv
```

Proposal output includes deterministic candidate rows with confidence and reason fields so reviewers can audit why each row was suggested. Apply consumes only approved rows, writes canonical reconciliation records deterministically, and supports idempotent re-apply so rerunning the same approved file does not create duplicates.

These artifacts feed migration-quality controls in [Source import parity and journal gap checks](./source-import-parity-and-journal-gap-checks). An optional CI-friendly extension is not yet specified: thresholds or strict exit codes for "no proposals" vs "partial apply" would let scripts fail on backlog or incomplete apply without parsing output; when adopted, exit codes and optional CI flags will be documented in the [bus-reconcile](../modules/bus-reconcile) module reference.

### Scope and ownership

[bus-reconcile](../modules/bus-reconcile) owns proposal generation and apply behavior. [bus-bank](../modules/bus-bank) provides deterministic bank transaction identity and normalized read fields used as proposal input. When [counterparty normalization](../sdd/bus-bank#suggested-capabilities-out-of-current-scope) is implemented in bus-bank, proposal inputs will include a normalized counterparty field so rules can key off canonical names; the config format and field semantics will be documented in the bus-bank SDD and module reference. When [reference extractors](../sdd/bus-bank#suggested-capabilities-out-of-current-scope) from bank message/reference are implemented, bank list and export will expose normalized fields (e.g. `erp_id`, `invoice_number_hint`) so bus-reconcile and other modules can use them without parsing raw text; extractor config and new dataset fields will be documented in the bus-bank SDD and module reference. [bus-reconcile](../modules/bus-reconcile) would then use those fields in propose and match (optional [match by extracted reference keys](../modules/bus-reconcile#match-by-extracted-reference-keys) path) when joining to invoice or purchase-invoice ids; expected field names and match semantics would be documented in the bus-reconcile SDD and module reference. [bus-invoices](../modules/bus-invoices) provides deterministic open-item invoice identity and status or amount semantics used as proposal input.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./import-bank-transactions-and-apply-payment">Import bank transactions and apply payments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./import-erp-history-into-canonical-datasets">Import ERP history into canonical invoices and bank datasets</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-reconcile module CLI reference](../modules/bus-reconcile)
- [bus-bank module CLI reference](../modules/bus-bank)
- [bus-invoices module CLI reference](../modules/bus-invoices)
- [bus-reconcile SDD](../sdd/bus-reconcile)
- [bus-bank SDD](../sdd/bus-bank)
- [bus-invoices SDD](../sdd/bus-invoices)
- [Import bank transactions and apply payment](./import-bank-transactions-and-apply-payment)
- [Source import parity and journal gap checks](./source-import-parity-and-journal-gap-checks)
