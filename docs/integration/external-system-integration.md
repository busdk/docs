---
title: External system integration patterns
description: External systems can integrate by exchanging CSV resources or by operating on the Git repository itself.
---

## External system integration patterns

External systems can integrate by exchanging CSV resources or by operating on the Git repository itself. Examples include a web store exporting daily sales as CSV for invoice import, or a CRM integration that triggers creation of customer records via external Git commits or webhook-driven automation. The design aims to prevent vendor lock-in by relying on open, widely supported formats.

For historical ERP onboarding into canonical invoice and bank datasets, the integration direction is profile-driven import: versioned mapping profiles define deterministic source-to-target mapping rules and import runs emit auditable artifacts. This keeps mapping intent in repository data and avoids repository-specific one-off logic.

Current production migrations still use generated explicit append scripts derived from ERP TSV mappings. The target first-class workflow is documented in [Import ERP history into canonical invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets), with domain ownership in [bus-invoices](../modules/bus-invoices) and [bus-bank](../modules/bus-bank), mapping mechanics in [bus-data](../modules/bus-data), and deterministic migration replay in [bus-replay](../modules/bus-replay).

Reconciliation planning in these onboarding flows follows the same direction: script-assisted candidate generation today, moving to first-class deterministic proposal and batch-apply commands in [bus-reconcile](../modules/bus-reconcile) as documented in [Deterministic reconciliation proposals and batch apply](../workflow/deterministic-reconciliation-proposals-and-batch-apply).

Migration-quality controls follow the same pattern: script-based source parity and journal-gap diagnostics today, moving to first-class parity and coverage command surfaces in [bus-validate](../modules/bus-validate) and [bus-reports](../modules/bus-reports) as documented in [Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../integration/index">BusDK Design Spec: Integration and future interfaces</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./future-interfaces">Future interfaces (APIs, dashboards, wrappers)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Import ERP history into canonical invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets)
- [bus-invoices module CLI reference](../modules/bus-invoices)
- [bus-bank module CLI reference](../modules/bus-bank)
- [bus-data module CLI reference](../modules/bus-data)
- [bus-replay module CLI reference](../modules/bus-replay)
- [bus-reconcile module CLI reference](../modules/bus-reconcile)
- [Deterministic reconciliation proposals and batch apply](../workflow/deterministic-reconciliation-proposals-and-batch-apply)
- [bus-validate module CLI reference](../modules/bus-validate)
- [bus-reports module CLI reference](../modules/bus-reports)
- [Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
