---
title: bus-reports — financial reports from journal and reference data (SDD)
description: Bus Reports computes financial reports from journal and reference data and defines deterministic Finnish statutory balance-sheet and income-statement output contracts.
---

## bus-reports — financial reports from journal and reference data

### Introduction and Overview

Bus Reports computes financial reports from journal and reference data, verifies integrity and balances, and emits deterministic report outputs. For balance sheet (TASE) and income statement (tuloslaskelma), the module supports configurable report layouts so that outputs can match an explicitly defined statutory structure for comparison, audit review, and filing preparation.

The module is the BusDK source of truth for financial-statement output structure, layout identifiers, and statement-level consistency checks. Filing-readiness depends on this module, on workspace configuration owned by [bus-config](./bus-config), on account mapping data owned by [bus-accounts](./bus-accounts), and on period and posting integrity owned by [bus-period](./bus-period) and [bus-journal](./bus-journal).

### Requirements

FR-REP-001 Report outputs. The module MUST generate trial balance, general ledger, profit and loss, and balance sheet outputs. Acceptance criteria: each report command emits deterministic outputs with stable ordering.

FR-REP-002 Integrity checks. The module MUST verify ledger integrity before emitting reports. Acceptance criteria: integrity failures are reported with deterministic diagnostics and non-zero exit codes.

NFR-REP-001 Auditability. Report outputs MUST be fully derivable from repository data and traceable to postings and vouchers. Acceptance criteria: report outputs reference stable identifiers or are reproducible from the same datasets.

FR-REP-003 Regulated report PDFs. The toolchain MUST support producing the balance sheet (TASE) and the income statement (tuloslaskelma) as PDF suitable for Finnish regulated reporting (archiving, auditors, authorities). Acceptance criteria: users can obtain deterministic TASE and tuloslaskelma PDFs from workspace data via the CLI without relying on external conversion tools; the PDF includes the metadata defined in FR-REP-011.

FR-REP-004 Configurable report layout (TASE / tuloslaskelma). The module MUST support selecting a built-in statutory layout or a custom layout definition that specifies report-line hierarchy, labels, and account-to-line mapping. Acceptance criteria: (1) a report layout is expressible as a schema (line tree, label set, mapping contract); (2) users can select a built-in layout id or supply a layout file; (3) `bus reports balance-sheet` and `bus reports profit-and-loss` emit the same line structure and labels for text, CSV, JSON, KPA/PMA, and PDF outputs when the same layout is selected.

FR-REP-005 Finnish reporting profile contract. The module MUST read a deterministic Finnish reporting profile from workspace configuration and apply it as the default statutory-report behavior. Acceptance criteria: profile keys and semantics are documented in this SDD and in [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration); report generation is deterministic for the same profile and dataset revision.

FR-REP-006 Built-in Finnish statutory layout identifiers. The module MUST provide stable built-in layout identifiers for Finnish statutory statements and MUST document which legal scheme each identifier targets. Acceptance criteria: each built-in `fi-*` layout id is stable, documented, selectable from CLI, and linked to the KPA/PMA scheme family.

FR-REP-007 Account mapping determinism. For `fi-*` layouts, every account that contributes to statement output MUST map deterministically to exactly one statement line (or to one explicit rollup rule that resolves to one line) for the selected layout. Acceptance criteria: mapping storage location and schema are documented; duplicate, missing, and ambiguous mappings produce deterministic errors with account id, layout id, and resolution guidance.

FR-REP-008 Comparative figures. For statutory balance sheet and income statement outputs, the module MUST include preceding-period comparatives when available and enabled. Acceptance criteria: comparatives default to enabled through profile configuration; first fiscal year is handled as the explicit exception where no prior-period comparative exists.

FR-REP-009 Balance-sheet equation validation. For `fi-*` layouts, the module MUST validate that assets equal equity plus liabilities for the selected balance-sheet date. Acceptance criteria: mismatch is a deterministic hard error for statutory outputs and the diagnostic reports both sides and the difference.

FR-REP-010 Income-result reconciliation validation. For `fi-*` layouts, the period result from income statement output MUST reconcile to the corresponding balance-sheet presentation of the period result in equity for the same period end. Acceptance criteria: mismatch is a deterministic hard error for statutory outputs because inconsistent statements are not filing-defensible.

FR-REP-011 Statutory PDF metadata and signature section. For statutory PDF outputs, the module MUST include compliance-critical metadata and a dated-and-signed section. Acceptance criteria: the PDF includes entity legal name, Business ID when available, financial period start and end, balance-sheet date, currency and presentation unit, selected statutory scheme and layout id, and comparative column when enabled and available; the signature section contains either provided signer names and dates or a deterministic signing placeholder block.

FR-REP-012 Scope boundary for filing-readiness. The module MUST keep scope boundaries explicit between statements, notes, and balance-sheet specifications. Acceptance criteria: statement output (balance sheet and income statement) is in scope; notes are identified as separate filing documents that may be produced by other modules or external workflows; balance-sheet specifications (`tase-erittelyt`) are explicitly out of filing output scope for PRH and out of generation scope for this module unless a future requirement adds them.

FR-REP-013 Non-opening journal coverage report. The module MUST provide a deterministic report that compares monthly imported operational totals against non-opening journal activity. Acceptance criteria: the report includes period, imported operational total, non-opening journal total, delta, and status fields; opening entries are excluded by explicit rule; output is deterministic and machine-readable for CI workflows.

### Finnish statutory financial statements

Finnish filing-facing financial statements generally include at least the income statement and the balance sheet, and commonly include notes as required by the applicable framework. Bus Reports covers the statement outputs and their deterministic presentation contract. Notes remain a separate document scope and are not generated by this module by default. This boundary is intentional so statement generation and statement validation stay deterministic and auditable in workspace data while notes can be managed through dedicated filing and documentation flows.

The statutory minimum for this module is that statements are prepared from validated workspace data, rendered with explicit statutory layout identifiers, and produced in a form that supports dating and signing practices required by Finnish accounting law. Accounting-law preparation deadlines and signature obligations are legal obligations outside this module’s automation boundary, but the module exposes the period boundaries, statement dates, and signature metadata needed to evidence compliance. The module therefore includes deterministic support for signed-and-dated statement sections in PDF output and keeps required signature metadata in workspace configuration so it is reviewable in the Git repository.

Comparative figures for the preceding period are part of the default statutory contract when prior-period data is available. The first fiscal year is the standard exception where comparative statement columns are not expected. The module does not infer exceptions from heuristics; it derives comparative behavior from deterministic profile settings plus available period data.

`Tase-erittelyt` (balance-sheet specifications) are not filed to PRH and are therefore out of filing output scope for bus-reports. They may still be required for internal bookkeeping evidence and audit trail work, but that generation responsibility is outside this module in the current scope.

Bus Reports targets statutory scheme support through explicit layout choices. Income statement output supports both decree-level Finnish schemes: expense-by-nature (`kululajikohtainen`) and function-of-expense (`toimintokohtainen`). Balance sheet output follows the Finnish `Vastaavaa` and `Vastattavaa` structure with statutory groupings including `pysyvät vastaavat`, `vaihtuvat vastaavat`, `oma pääoma`, `tilinpäätössiirtojen kertymä`, `pakolliset varaukset`, and `vieras pääoma`. Where scheme rules require long-term portions to be shown separately for receivables or liabilities, built-in layouts and validators enforce that split.

The shortened balance sheet (`lyhennetty tase`) is treated as a recognized presentation option that must be selected explicitly by layout id. Bus Reports does not automatically choose shortened presentation from company-size inference. If a future size-classification mechanism is added, it may propose defaults, but explicit layout selection remains authoritative.

### System Architecture

Bus Reports reads journal and account datasets and optionally budget datasets to compute reports. It uses period boundaries and period state from [bus-period](./bus-period) and posting integrity from [bus-journal](./bus-journal), and it reads workspace-level reporting profile settings from [bus-config](./bus-config). Reports are therefore produced from validated journal data within explicit period boundaries, including year-end close and opening workflows that establish consistent boundary dates across fiscal years. The module produces report outputs used for filing preparation and management reporting.

### Key Decisions

KD-REP-001 Reports are derived outputs. Reports are computed from canonical datasets and do not modify them.

KD-REP-002 Report layout drives line structure and labels. Balance-sheet and profit-and-loss line hierarchy, labels, and account aggregation are defined by a selected report layout (built-in or custom), not hardcoded per output format. This keeps text, CSV, JSON, KPA/PMA, and PDF outputs aligned for the same selected layout (FR-REP-004, FR-REP-006).

KD-REP-003 Profile-driven defaults with explicit override. Finnish statutory-report defaults come from workspace reporting profile keys, and command-level layout selection can override profile defaults explicitly. This keeps output deterministic and auditable while still allowing explicit per-command selection (FR-REP-005).

KD-REP-004 Filing-readiness as statement consistency, not filing submission. bus-reports defines deterministic statement layouts, mappings, and validations required before filing, but it does not submit filings itself. Filing transport and package generation belong to filing modules (FR-REP-012).

KD-REP-005 Coverage reporting is a report concern. Monthly non-opening journal coverage outputs are modeled as report artifacts, while threshold decisions and CI pass/fail behavior remain validation concerns in [bus-validate](./bus-validate).

### Component Design and Interfaces

Interface IF-REP-001 (module CLI). The module exposes `bus reports` with subcommands `trial-balance`, `general-ledger`, `profit-and-loss`, and `balance-sheet` and follows BusDK CLI conventions for deterministic output and diagnostics.

Interface IF-REP-002 (coverage report, planned). The planned command surface includes `bus reports journal-coverage --from <YYYY-MM> --to <YYYY-MM> [--source-summary <path>] [--exclude-opening] [--format <text|csv|json>]`. The command emits a deterministic monthly comparison between imported operational totals and non-opening journal totals. It does not make pass/fail threshold decisions; it emits coverage data that can be consumed by [bus-validate](./bus-validate) parity or gap checks.

Report scoping is explicit and deterministic. `trial-balance` and `balance-sheet` require `--as-of <YYYY-MM-DD>` and include postings on or before the as-of date. `general-ledger` and `profit-and-loss` require `--period <period>` using the same period identifier form as `bus period` and `bus vat`. `general-ledger` accepts an optional `--account <account-id>` to emit a single-account ledger; when omitted it emits all accounts in deterministic order.

All report commands accept `--format <format>` with supported values `text`, `csv`, and `markdown`. For balance-sheet and profit-and-loss, `json`, `kpa`, `pma`, and `pdf` are also supported. The default is `text`, which emits a plain, non-aligned table with stable column order and a literal `|` separator so output does not vary by terminal width. The `csv` format emits UTF-8 CSV with a header row and the same deterministic row ordering as text output. The `markdown` format emits a Markdown table with the same row ordering. The `pdf` format writes a PDF to the path given by `-o` and includes the statutory metadata contract in FR-REP-011.

For `profit-and-loss` and `balance-sheet`, layout selection is explicit. Built-in statutory layouts are selected with `--layout-id <id>` and custom layouts are selected with `--layout <file>`. The selected layout controls the line hierarchy and labels for all output formats. For Finnish statutory reporting, the module provides at least the following built-in layout ids:

- `fi-kpa-tuloslaskelma-kululaji` (KPA income statement, expense-by-nature)
- `fi-kpa-tuloslaskelma-toiminto` (KPA income statement, function-of-expense)
- `fi-kpa-tase` (KPA full balance sheet)
- `fi-kpa-tase-lyhennetty` (KPA shortened balance sheet presentation)
- `fi-pma-tuloslaskelma-kululaji` (PMA income statement, expense-by-nature, small/micro regime)
- `fi-pma-tuloslaskelma-toiminto` (PMA income statement, function-of-expense, where applicable)
- `fi-pma-tase` (PMA balance sheet, small/micro regime)
- `fi-pma-tase-lyhennetty` (PMA shortened balance sheet presentation for applicable regime)

Report layout contract (FR-REP-004, FR-REP-006, FR-REP-007). A report layout defines the line tree, label set, and the account-mapping contract needed to populate each line. Layout ids are stable and versioned in module documentation so downstream modules and automation can depend on them.

Sign handling is part of the layout contract. Users do not manually negate amounts for statutory presentation. The module applies normal-side metadata and statement-line presentation rules so that printed lines follow Finnish statement conventions even when ledger signs differ internally.

Usage example:

```bash
bus reports trial-balance --as-of 2026-03-31 --format csv
bus reports profit-and-loss --period 2026 --layout-id fi-kpa-tuloslaskelma-kululaji --format pdf -o tuloslaskelma-2026.pdf
bus reports balance-sheet --as-of 2026-12-31 --layout-id fi-kpa-tase --format pdf -o tase-2026.pdf
```

### Data Design

The module reads journal data from `bus journal`, account master data from `bus accounts`, period metadata from `bus period`, and optional budgets from `bus budget`, all as schema-validated datasets.

For planned coverage reporting, the module also reads deterministic source-import summary inputs and reconciliation context from [bus-reconcile](./bus-reconcile) where needed to classify operational activity versus opening adjustments.

Finnish reporting profile (FR-REP-005) is stored in workspace configuration (`datapackage.json`) as BusDK metadata under `busdk.accounting_entity.reporting_profile.fi_statutory`. The profile keys are deterministic presentation settings, not posting business logic, and must be committed and auditable in workspace data:

```json
{
  "busdk": {
    "accounting_entity": {
      "reporting_profile": {
        "fi_statutory": {
          "reporting_standard": "fi-kpa",
          "language": "fi",
          "income_statement_scheme": "by_nature",
          "comparatives": true,
          "presentation_currency": "EUR",
          "presentation_unit": "EUR",
          "prepared_under_pma": false,
          "signature": {
            "signers": [
              {"name": "Hallitus / Board", "role": "board"}
            ],
            "date": null
          }
        }
      }
    }
  }
}
```

Profile semantics are as follows: `reporting_standard` selects `fi-kpa` or `fi-pma`; `language` is currently `fi` and reserves `sv` for later support; `income_statement_scheme` selects `by_nature` or `by_function`; `comparatives` defaults to `true`; `presentation_currency` is currently `EUR`; `presentation_unit` is currently `EUR` and reserves `TEUR` for later; `prepared_under_pma` controls inclusion of the required small/micro preparation note; `signature` carries signer and date metadata for PDF signature sections.

Account mapping for statutory layouts (FR-REP-007) is stored in a dedicated dataset `report-account-mapping.csv` with a beside-the-table schema `report-account-mapping.schema.json`, owned by bus-accounts and consumed by bus-reports. The dataset is joined to accounts by account code and to layouts by `layout_id`. Minimum fields are `layout_id`, `account_code`, `statement_target` (`tuloslaskelma` or `tase`), `layout_line_id`, `normal_side` (`debit` or `credit`), and optional `rollup_rule`. The mapping contract requires exactly one effective target line per account per selected layout and statement target.

For `fi-*` layouts, unmapped accounts are hard errors unless the account is explicitly assigned to a permitted statutory other-bucket line in the selected layout. Deterministic diagnostics include account code, layout id, missing or conflicting line id, and a direct resolution action.

Report layout schema (FR-REP-004) is a structured definition that drives balance-sheet and profit-and-loss line structure and labels. It comprises a line schema (ordered tree with stable ids), account-mapping contract, and label set. Layouts may be built-in or supplied as a custom layout file (YAML or JSON).

### Assumptions and Dependencies

Bus Reports depends on valid journal and account datasets, valid period metadata, valid reporting profile metadata in workspace configuration, and workspace layout and schema conventions. Missing datasets, schemas, or required profile keys result in deterministic diagnostics. Planned coverage reporting depends on deterministic source-import summary inputs and explicit opening-entry classification rules.

### Security Considerations

Report outputs may contain sensitive financial data and should be protected by repository access controls. Derived outputs must not alter canonical datasets.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. For statutory `fi-*` layouts, integrity, mapping, or reconciliation failures exit non-zero without modifying datasets and without emitting filing-facing output.

### Testing Strategy

Unit tests cover report calculations, mapping validation, sign handling, statutory balance equation checks, and profit-and-loss to equity reconciliation checks. Command-level tests exercise each report command against fixture workspaces, including comparatives on/off behavior, first fiscal-year comparative exception, PDF metadata and signature block output, and deterministic diagnostics for mapping and reconciliation failures. Planned journal-coverage tests MUST verify non-opening filtering, monthly deterministic aggregation, and byte-identical output for repeated runs with identical inputs.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Report schema changes are handled by updating the module and documenting new output expectations.

### Implementation status (Finnish full layout parity)

Built-in Finnish layouts (e.g. `pma-full`, `kpa-full` or equivalent `fi-*` layout ids) execute successfully for balance-sheet and profit-and-loss and emit Finnish section labels (e.g. Pysyvät vastaavat, LIIKEVAIHTO). Outputs remain section-level summaries; full line-by-line parity with a source report — same structure and labels as the original TASE or tuloslaskelma — still requires a robust customizable line-mapping path. A built-in “Finnish full” layout or custom YAML/JSON layout that maps accounts to report lines with the same hierarchy and labels as a given source is not yet fully implemented; parity work for comparison and filing may rely on custom layout files and account-mapping refinement until that path is complete.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic report outputs.

### Glossary and Terminology

**Account→line mapping:** Rules that assign account codes or account types from the chart of accounts to specific report lines so that balances are aggregated into the correct line in balance-sheet or profit-and-loss output.

**Finnish reporting profile:** Workspace-level presentation configuration for statutory Finnish statements (`fi-kpa` or `fi-pma`), including language, scheme, comparatives, currency/unit, and signature metadata.

**General ledger:** A report listing detailed postings by account.

**Layout id:** A stable built-in identifier for a statutory or custom statement layout (for example `fi-kpa-tase`).

**Report layout:** A definition of the report-line tree (hierarchy), label set, and account→line mapping used to produce balance-sheet or profit-and-loss output. Layouts may be built-in or supplied via a layout file.

**Report line:** A single row in a balance-sheet or profit-and-loss report, identified by a stable id and optional parent, with a display label and aggregated amount(s).

**Tase-erittelyt:** Balance-sheet specifications used for internal bookkeeping evidence and audit support, not filed to PRH with the standard financial-statement filing package.

**TASE:** Tasapainolaskelma; the Finnish balance sheet. Required for regulated reporting and archiving.

**Trial balance:** A report summarizing balances by account.

**Tuloslaskelma:** The Finnish income statement (profit and loss). Required for regulated reporting and archiving.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-budget">bus-budget</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-replay">bus-replay</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [End user documentation: bus-reports CLI reference](../modules/bus-reports)
- [Repository](https://github.com/busdk/bus-reports)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [bus-validate module SDD](./bus-validate)
- [bus-reconcile module SDD](./bus-reconcile)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
- [Append-only and soft deletion](../data/append-only-and-soft-deletion)
- [Regulated report PDFs (TASE and tuloslaskelma)](../implementation/regulated-report-pdfs)
- [bus-period module SDD](./bus-period)
- [bus-journal module SDD](./bus-journal)
- [bus-config module SDD](./bus-config)
- [PRH: Tilinpäätösilmoituksen asiakirjat kaupparekisteriin](https://www.prh.fi/fi/yrityksetjayhteisot/tilinpaatokset/ilmoituksen_liitteet.html)
- [PRH: Digitaalinen iXBRL-rajapinta ohjelmistoyrityksille](https://www.prh.fi/fi/yrityksetjayhteisot/tilinpaatokset/digitaalinen-tilinpaatosraportointi/rajapinta.html)
- [Finlex: Kirjanpitolaki 1336/1997](https://www.finlex.fi/fi/lainsaadanto/1997/1336)
- [Finlex: Kirjanpitoasetus 1339/1997](https://www.finlex.fi/fi/lainsaadanto/1997/1339)
- [Finlex: Valtioneuvoston asetus 1753/2015 (PMA)](https://www.finlex.fi/fi/lainsaadanto/saadoskokoelma/2015/1753)

### Document control

Title: bus-reports module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-REPORTS`  
Version: 2026-02-18  
Status: Draft  
Last updated: 2026-02-18  
Owner: BusDK development team  
