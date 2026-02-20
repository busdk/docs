---
title: Year-end close (closing entries)
description: "Year-end close is a stricter version of period close: Alice runs validation, ensures VAT is complete, generates closing entries deterministically, locks the…"
---

## Year-end close (closing entries)

Year-end close is a stricter version of period close: Alice runs validation, ensures VAT is complete, generates closing entries deterministically, locks the final period, and then produces the year-end report set. The outcome is a repository revision that makes the derivation of opening balances for the next year straightforward to review.

In Finnish closing practice, this workflow should be aligned with statutory milestones: prepare the financial statement package within 4 months from year end, complete Oy general meeting approval within 6 months, and complete Trade Register filing in the applicable filing window (commonly 8 months for Oy/cooperative filing paths). Statement-facing outputs are prepared for Finnish/Swedish presentation in euros and move to formal dating/signing in the governance step.

1. Alice validates that the workspace datasets are internally consistent before generating close outputs:

```bash
bus validate
```

2. Alice completes VAT for the final reporting periods and exports the archived VAT artifacts:

```bash
bus vat report --period 2026-12
bus vat export --period 2026-12
```

3. Alice closes the final accounting period and generates the closing entry outputs:

```bash
bus period close --period 2026-12 --post-date 2026-12-31
```

The close produces deterministic entries that bring the period to a clean boundary and records period-close metadata as repository data. Transfer of profit or loss to equity (retained earnings) is expressed as new append-only postings. Until [bus period](../modules/bus-period) supports automatic result-to-equity transfer, post that transfer with `bus journal add` using your chart’s equity account; see the [bus-period](../modules/bus-period) CLI reference.

4. Alice locks the closed period to prevent later edits from drifting reported results:

```bash
bus period lock --period 2026-12
```

5. Alice generates the year-end report set from the closed, locked journal:

```bash
bus reports trial-balance --as-of 2026-12-31
bus reports general-ledger --period 2026-12
bus reports profit-and-loss --period 2026-12 --format pma
bus reports balance-sheet --as-of 2026-12-31 --format pma
```

6. Alice records the year-end close as a new revision using her version control tooling, so the closed year is easy to reference and export later.

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
