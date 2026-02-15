---
title: Year-end close (closing entries)
description: "Year-end close is a stricter version of period close: Alice runs validation, ensures VAT is complete, generates closing entries deterministically, locks the…"
---

## Year-end close (closing entries)

Year-end close is a stricter version of period close: Alice runs validation, ensures VAT is complete, generates closing entries deterministically, locks the final period, and then produces the year-end report set. The outcome is a repository revision that makes the derivation of opening balances for the next year straightforward to review.

1. Alice validates that the workspace datasets are internally consistent before generating close outputs:

```bash
bus validate --help
bus validate
```

2. Alice completes VAT for the final reporting periods and exports the archived VAT artifacts:

```bash
bus vat report --help
bus vat report ...
bus vat export --help
bus vat export ...
```

3. Alice closes the final accounting period and generates the closing entry outputs:

```bash
bus period close --help
bus period close ...
```

The close produces deterministic entries that bring the period to a clean boundary and records period-close metadata as repository data. Transfer of profit or loss to equity (retained earnings) is expressed as new append-only postings. Until [bus period](../modules/bus-period) supports automatic result-to-equity transfer, post that transfer with `bus journal add` using your chart’s equity account; see the [bus-period](../modules/bus-period) CLI reference.

4. Alice locks the closed period to prevent later edits from drifting reported results:

```bash
bus period lock --help
bus period lock ...
```

5. Alice generates the year-end report set from the closed, locked journal:

```bash
bus reports trial-balance --help
bus reports trial-balance ...
bus reports general-ledger --help
bus reports general-ledger ...
bus reports profit-and-loss --help
bus reports profit-and-loss ...
bus reports balance-sheet --help
bus reports balance-sheet ...
```

6. Alice records the year-end close as a new revision using her version control tooling, so the closed year is easy to reference and export later.

If a particular jurisdiction, accountant, or workflow needs additional close outputs beyond what the pinned modules provide, the schema-defined repository data still allows Alice to derive those outputs with a script and store them as additional repository data, without rewriting earlier records.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./workflow-takeaways">Workflow takeaways (transparency, control, automation)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./finnish-payroll-monthly-pay-run">Finnish payroll handling (monthly pay run)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
