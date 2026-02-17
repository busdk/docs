---
title: Regulated report PDFs (TASE and tuloslaskelma)
description: Design contract for producing Finnish balance sheet (TASE) and income statement (tuloslaskelma) PDFs from BusDK with explicit statutory layouts and compliance metadata.
---

## Regulated report PDFs (TASE and tuloslaskelma)

### Requirement

Finnish filing-facing financial statement workflows require at least the balance sheet and income statement outputs, with comparative figures when applicable, and with statement documents that are dated and signed according to accounting-law practice. BusDK must support producing these documents from workspace data via the CLI so users do not depend on external conversion tools.

### Current BusDK state

The [bus-reports](../modules/bus-reports) module exposes `bus reports balance-sheet --as-of <YYYY-MM-DD>` and `bus reports profit-and-loss --period <period>`. These commands produce text, CSV, JSON, KPA/PMA family outputs, and PDF output for statutory statements. Statutory support is specified with stable layout identifiers, not only with generic KPA/PMA format labels. Canonical built-ins include `fi-kpa-tase`, `fi-kpa-tase-lyhennetty`, `fi-kpa-tuloslaskelma-kululaji`, `fi-kpa-tuloslaskelma-toiminto`, and parallel `fi-pma-*` layout ids where applicable.

Users can obtain deterministic statement PDFs from workspace data via the CLI, for example `bus reports balance-sheet --as-of 2026-12-31 --layout-id fi-kpa-tase --format pdf -o tase.pdf` and `bus reports profit-and-loss --period 2026 --layout-id fi-kpa-tuloslaskelma-kululaji --format pdf -o tuloslaskelma.pdf`.

The [bus-pdf](../modules/bus-pdf) module provides `bus pdf render` (template-based PDF from JSON) and `bus pdf list-templates`. Built-in templates are **fi-invoice-a4** and **plain-a4**. TASE and tuloslaskelma PDFs are produced by bus-reports with `--format pdf`, not by bus-pdf templates.

### Implemented approach

**Option A — PDF format in bus-reports.** `bus reports balance-sheet` and `bus reports profit-and-loss` accept `--format pdf` and write a PDF to the path given by `-o`. Layout and wording follow the selected statutory layout id and mapping contract defined in [bus-reports SDD](../sdd/bus-reports). For filing-readiness, PDF output includes entity name and Business ID when available, period boundaries, balance-sheet date, selected scheme and layout id, presentation unit, comparative column behavior, and a deterministic dated-and-signed section (either signed names and dates from configuration or a placeholder block for signing workflows).

For PMA small/micro outputs, the PDF contract includes the "prepared under small/micro provisions" note when `prepared_under_pma` is explicitly enabled in the workspace reporting profile and the statement does not already make this status explicit in another required element.

Other options that were considered (report templates in bus-pdf with a pipeline, or a dedicated report-PDF subcommand) are not required for the current requirement; they could be revisited if the product needed a different integration pattern.

### Traceability

Compliance requirements are grounded in PRH filing-document guidance and the accounting framework references to KPL, KPA, and PMA. PRH guidance also identifies iXBRL as an available reporting channel for eligible entities; this design page covers PDF statement outputs and metadata, not iXBRL transport. BusDK filing channel modules can build on the same deterministic layout and metadata contracts.

Module traceability is anchored in [bus-reports SDD](../sdd/bus-reports) and [bus-pdf SDD](../sdd/bus-pdf). The SDD defines layout identifiers, mapping requirements, comparative behavior, and validations that this PDF contract relies on.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./development-status">Development status</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./cost-summary">Cost summary</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
- [bus-reports — CLI reference](../modules/bus-reports)
- [bus-pdf — CLI reference](../modules/bus-pdf)
- [bus-reports SDD](../sdd/bus-reports)
- [bus-pdf SDD](../sdd/bus-pdf)
- [PRH: Tilinpäätösilmoituksen asiakirjat kaupparekisteriin](https://www.prh.fi/fi/yrityksetjayhteisot/tilinpaatokset/ilmoituksen_liitteet.html)
- [PRH: Digitaalinen iXBRL-rajapinta ohjelmistoyrityksille](https://www.prh.fi/fi/yrityksetjayhteisot/tilinpaatokset/digitaalinen-tilinpaatosraportointi/rajapinta.html)
- [Finlex: Kirjanpitolaki 1336/1997](https://www.finlex.fi/fi/lainsaadanto/1997/1336)
- [Finlex: Kirjanpitoasetus 1339/1997](https://www.finlex.fi/fi/lainsaadanto/1997/1339)
- [Finlex: Valtioneuvoston asetus 1753/2015 (PMA)](https://www.finlex.fi/fi/lainsaadanto/saadoskokoelma/2015/1753)
