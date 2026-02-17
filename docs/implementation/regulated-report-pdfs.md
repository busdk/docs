---
title: Regulated report PDFs (TASE and tuloslaskelma)
description: Design for producing Finnish balance sheet (TASE) and income statement (tuloslaskelma) as PDF from BusDK for archiving, auditors, and authorities.
---

## Regulated report PDFs (TASE and tuloslaskelma)

### Requirement

Finnish bookkeeping regulation requires the balance sheet (TASE) and the income statement (tuloslaskelma) to be available as PDF for archiving, auditors, and authorities. BusDK must support producing these documents from workspace data via the CLI so that users do not depend on external conversion tools.

### Current BusDK state

The [bus-reports](../modules/bus-reports) module exposes `bus reports balance-sheet --as-of <YYYY-MM-DD>` and `bus reports profit-and-loss --period <period>`. These commands produce text, CSV, JSON, Finnish layouts **kpa** (balance sheet) and **pma** (profit-and-loss), and **pdf** (TASE and tuloslaskelma). Users can obtain compliant balance-sheet and income-statement PDFs from workspace data via the CLI (e.g. `bus reports balance-sheet --as-of 2026-12-31 --format pdf -o tase.pdf` and `bus reports profit-and-loss --period 2026Q1 --format pdf -o tuloslaskelma.pdf`) without relying on external conversion tools. KPA and PMA formats are implemented and verified by e2e; PDF output for both reports is implemented and verified by e2e (FR-REP-003).

The [bus-pdf](../modules/bus-pdf) module provides `bus pdf render` (template-based PDF from JSON) and `bus pdf list-templates`. Built-in templates are **fi-invoice-a4** and **plain-a4**. TASE and tuloslaskelma PDFs are produced by bus-reports with `--format pdf`, not by bus-pdf templates.

### Implemented approach

**Option A — PDF format in bus-reports.** `bus reports balance-sheet` and `bus reports profit-and-loss` accept `--format pdf` and write a PDF to the path given by `-o`. Layout and wording are suitable for Finnish regulated reporting and aligned with the kpa/pma structure. The SDDs for [bus-reports](../sdd/bus-reports) and [bus-pdf](../sdd/bus-pdf) reflect this contract.

Other options that were considered (report templates in bus-pdf with a pipeline, or a dedicated report-PDF subcommand) are not required for the current requirement; they could be revisited if the product needed a different integration pattern.

### Traceability

- Compliance: [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit) states the requirement that TASE and tuloslaskelma be available as PDF; BusDK satisfies it via bus-reports `--format pdf`.
- Module SDDs: [bus-reports SDD](../sdd/bus-reports) and [bus-pdf SDD](../sdd/bus-pdf) reference this design and the implemented interfaces.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./development-status">Development status</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./cost-summary">Cost summary</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
- [bus-reports — CLI reference](../modules/bus-reports)
- [bus-pdf — CLI reference](../modules/bus-pdf)
- [bus-reports SDD](../sdd/bus-reports)
- [bus-pdf SDD](../sdd/bus-pdf)
