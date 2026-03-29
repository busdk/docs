---
title: Year-end close and lock
description: "Year-end close validates and finalizes the year-end cut-off, generates the report set, and locks the reported basis once it has been used externally."
---

## Year-end close and lock

Year-end close is a stricter version of ordinary period close. Alice runs validation, ensures VAT and other year-end adjustments are complete, finalizes the cut-off, generates the report set, and then locks the reported basis once it has been used externally. The outcome is a repository revision that makes the derivation of opening balances for the next year straightforward to review without inventing synthetic close vouchers.

In Finnish closing practice, this workflow should be aligned with statutory milestones: prepare the financial statement package within 4 months from year end, complete Oy general meeting approval within 6 months, and complete Trade Register filing in the applicable filing window (commonly 8 months for Oy/cooperative filing paths). Statement-facing outputs are prepared for Finnish/Swedish presentation in euros and move to formal dating/signing in the governance step.

1. Alice validates that the workspace datasets are internally consistent before finalizing the year-end cut-off:

```bash
bus validate
```

2. Alice completes VAT for the final reporting periods and exports the archived VAT artifacts:

```bash
bus vat report --period 2026-12
bus vat export --period 2026-12
```

3. Alice posts any final year-end adjustments that are required for the financial statement, taxation, or management reporting basis:

```bash
bus journal add ...
```

4. Alice closes the final accounting period as a non-posting cut-off:

```bash
bus period close --period 2026-12
```

The close records period-close metadata as repository data, updates closed-period compatibility markers, and writes the derived carry-forward snapshot used by later opening/reporting logic. It does not add synthetic retained-earnings vouchers to the journal.

5. Alice generates the year-end report set from the closed journal basis:

```bash
bus reports trial-balance --as-of 2026-12-31
bus reports general-ledger --period 2026-12
bus reports profit-and-loss --period 2026-12 --format pma
bus reports balance-sheet --as-of 2026-12-31 --format pma
```

6. Alice locks the period after the year-end outputs have been issued, filed, or otherwise used externally:

```bash
bus period lock --period 2026-12
```

7. Alice records the year-end close as a new revision using her version control tooling, so the closed year is easy to reference and export later.

If a particular jurisdiction, accountant, or workflow needs additional close outputs beyond what the pinned modules provide, the schema-defined repository data still allows Alice to derive those outputs with a script and store them as additional repository data, without rewriting earlier records.

For detailed legal timeline anchors and close-control topics, use [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones), [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations), and [Finnish closing adjustments and evidence controls](../compliance/fi-closing-adjustments-and-evidence-controls).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./workflow-takeaways">Workflow takeaways (transparency, control, automation)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./finnish-payroll-monthly-pay-run">Finnish payroll handling (monthly pay run)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-validate module CLI reference](../modules/bus-validate)
- [bus-vat module CLI reference](../modules/bus-vat)
- [bus-period module CLI reference](../modules/bus-period)
- [bus-journal module CLI reference](../modules/bus-journal)
- [bus-reports module CLI reference](../modules/bus-reports)
- [Accounting workflow overview](./accounting-workflow-overview)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)
- [Finnish closing adjustments and evidence controls](../compliance/fi-closing-adjustments-and-evidence-controls)
