---
title: Regulated report PDFs (TASE and tuloslaskelma)
description: Design for producing Finnish balance sheet (TASE) and income statement (tuloslaskelma) as PDF from BusDK for archiving, auditors, and authorities.
---

## Regulated report PDFs (TASE and tuloslaskelma)

### Requirement

Finnish bookkeeping regulation requires the balance sheet (TASE) and the income statement (tuloslaskelma) to be available as PDF for archiving, auditors, and authorities. BusDK must support producing these documents from workspace data via the CLI so that users do not depend on external conversion tools.

### Current BusDK state

The [bus-reports](../modules/bus-reports) module exposes `bus reports balance-sheet --as-of <YYYY-MM-DD>` and `bus reports profit-and-loss --period <period>`. These commands produce text, CSV, and JSON, and Finnish layouts **kpa** (balance sheet) and **pma** (profit-and-loss). They do not produce PDF.

The [bus-pdf](../modules/bus-pdf) module provides `bus pdf render` (template-based PDF from JSON) and `bus pdf list-templates`. Built-in templates are **fi-invoice-a4** and **plain-a4**. There are no TASE or tuloslaskelma templates, and no documented or supported pipeline (e.g. `bus reports … -f json | bus pdf render …`) that produces compliant TASE or tuloslaskelma PDFs from workspace data.

Without one of the implementation options below, users cannot produce regulated TASE and tuloslaskelma as PDF from BusDK alone; they must rely on external tools (e.g. converting CSV to PDF or custom scripts and templates), which is brittle and not auditable from the CLI.

### Implementation options

The following options are mutually compatible; one may be chosen or options combined.

**Option A — PDF format in bus-reports.** Extend `bus reports balance-sheet` and `bus reports profit-and-loss` to accept `--format pdf` and write a PDF to the path given by `-o` (e.g. `bus reports balance-sheet --as-of 2026-12-31 --format pdf -o tase.pdf`). Layout and wording would be suitable for Finnish regulated reporting and aligned with the existing kpa/pma structure. Implementation may delegate rendering to bus-pdf internally or embed a dedicated renderer; the SDDs for [bus-reports](../sdd/bus-reports) and [bus-pdf](../sdd/bus-pdf) would be updated to reflect the chosen contract.

**Option B — Report templates in bus-pdf plus documented pipeline.** Add built-in [bus-pdf](../modules/bus-pdf) templates for TASE and tuloslaskelma (e.g. `fi-tase-a4`, `fi-tuloslaskelma-a4`), define a stable JSON render model schema for each so that report data can be fed into `bus pdf render`, and document the pipeline (e.g. `bus reports balance-sheet … -f json -o - | bus pdf render --data @- --out tase.pdf --template fi-tase-a4`). The JSON schema for report render models would match what the templates expect and would be documented in the [bus-pdf SDD](../sdd/bus-pdf). bus-reports would need to emit JSON in that schema when `--format json` is used for balance-sheet and profit-and-loss, or a small adapter could transform existing report JSON into the render model.

**Option C — Dedicated report-PDF subcommand.** Introduce a subcommand such as `bus reports pdf --balance-sheet --as-of … --profit-and-loss --period … -o dir/` that writes one PDF per requested report using Bus-maintained layouts. This centralises the report-to-PDF flow in one place and can be implemented by composing bus-reports and bus-pdf or by a single module that owns the workflow.

### Traceability

- Compliance: [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit) states the requirement that TASE and tuloslaskelma be available as PDF; this page describes how BusDK will satisfy it.
- Module SDDs: [bus-reports SDD](../sdd/bus-reports) and [bus-pdf SDD](../sdd/bus-pdf) reference this design for the chosen option(s) and any new requirements or interfaces.

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
