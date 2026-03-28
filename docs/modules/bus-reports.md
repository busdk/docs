---
title: bus-reports
description: bus reports generates trial balances, ledgers, statutory statements, close packages, and audit/control reports from a BusDK workspace.
---

## `bus-reports` — generate trial balance, ledgers, statements, and close packages

`bus reports` reads workspace accounting data and turns it into review, close, audit, and filing outputs. It is the module you use when you want to see what the books say without changing the books.

For everyday work, most users start with `trial-balance`, `general-ledger`, `day-book`, `profit-and-loss`, and `balance-sheet`. For close and audit work, the most important commands are `voucher-list`, `bank-transactions`, `materials-register`, `methods-description`, and `evidence-pack`.

### Common tasks

Generate a trial balance for month-end review:

```bash
bus reports trial-balance \
  --as-of 2026-01-31 \
  --format csv \
  -o ./out/trial-balance-2026-01.csv
```

Export a printable day book and general ledger PDF for one period:

```bash
bus reports day-book \
  --period 2026-01 \
  --format pdf \
  -o ./out/day-book-2026-01.pdf

bus reports general-ledger \
  --period 2026-01 \
  --format pdf \
  -o ./out/general-ledger-2026-01.pdf
```

Create Finnish statutory PDFs for year-end:

```bash
bus reports profit-and-loss \
  --period 2026 \
  --layout-id fi-kpa-tuloslaskelma-kululaji \
  --format pdf \
  -o ./out/tuloslaskelma-2026.pdf

bus reports balance-sheet \
  --as-of 2026-12-31 \
  --layout-id fi-kpa-tase \
  --format pdf \
  -o ./out/tase-2026.pdf
```

By default, `profit-and-loss` and `balance-sheet` hide rows whose values are
zero in both shown periods. Add `--show-zero-rows` when you want to inspect
the full statutory structure, including zero-valued rows.

Build a close package directory in one run:

```bash
bus reports evidence-pack \
  --period 2026 \
  --output-dir ./out/evidence-pack-2026 \
  --format tsv
```

Produce the accounting materials register that many auditors and close checklists need:

```bash
bus reports materials-register \
  --format pdf \
  -o ./out/materials-register-2026.pdf
```

Generate the workspace methods description (`menetelmäkuvaus`) that explains how bookkeeping data, evidence links, locking, and reports are handled:

```bash
bus reports methods-description \
  --format pdf \
  -o ./out/methods-description-2026.pdf
```

Compare imported source totals with journal totals during migration or data validation:

```bash
bus reports journal-coverage --from 2026-01-01 --to 2026-03-31 --format json
bus reports parity --from 2026-01-01 --to 2026-03-31 --source-summary ./imports/source-summary.csv
bus reports journal-gap --from 2026-01-01 --to 2026-03-31 \
  --source-summary ./imports/source-summary.csv \
  --account-buckets ./imports/account-buckets.csv
```

### Synopsis

`bus reports trial-balance --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports account-balances --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports general-ledger --period <YYYY|YYYY-MM|YYYYQn> [--account <code>] [--short-ids] [--format <text|csv|markdown|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports day-book --period <YYYY|YYYY-MM|YYYYQn> [--short-ids] [--format <text|csv|markdown|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports ledger-log --period <YYYY|YYYY-MM|YYYYQn> [options] [-C <dir>] [global flags]`  
`bus reports account-ledger --account <code> --from <YYYY-MM-DD> --to <YYYY-MM-DD> [-C <dir>] [global flags]`  
`bus reports profit-and-loss --period <YYYY|YYYY-MM|YYYYQn> [--layout-id <id>|--layout <file>] [--comparatives <on|off>] [--format <text|csv|markdown|json|kpa|pma|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports statement-explain --report <balance-sheet|profit-and-loss> (--as-of <YYYY-MM-DD> | --period <YYYY|YYYY-MM|YYYYQn>) [--account <code>] [--layout-id <id>|--layout <file>] [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports statement-validate --report <balance-sheet|profit-and-loss> (--as-of <YYYY-MM-DD> | --period <YYYY|YYYY-MM|YYYYQn>) [--account <code>] [--layout-id <id>|--layout <file>] [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports budget-vs-actual --period <YYYY|YYYY-MM|YYYYQn> [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports cashflow --period <YYYY|YYYY-MM|YYYYQn> [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports net-worth --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports account-movement --period <YYYY|YYYY-MM|YYYYQn> [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports transfer-summary --period <YYYY|YYYY-MM|YYYYQn> [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet --as-of <YYYY-MM-DD> [--layout-id <id>|--layout <file>] [--comparatives <on|off>] [--format <text|csv|markdown|json|kpa|pma|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet-specification --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet-reconciliation --as-of <YYYY-MM-DD> [--format <text|csv|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports voucher-list --period <YYYY|YYYY-MM|YYYYQn> [--format <text|csv|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports bank-transactions --period <YYYY|YYYY-MM|YYYYQn> [--account <code>] [--format <text|csv|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports materials-register [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports methods-description [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports evidence-pack (--period <YYYY|YYYY-MM|YYYYQn> | --as-of <YYYY-MM-DD>) --output-dir <dir> [--format <text|csv|tsv|json|markdown>] [-C <dir>] [global flags]`  
`bus reports journal-coverage [options] | parity [options] | journal-gap [options] | compliance-checklist [options] | filing-package [options] | annual-template [options] | annual-validate [options]`

### Choose the right command

| If you need... | Start with... |
| --- | --- |
| A fast period or year-end balance summary | `trial-balance` or `account-balances` |
| Entry-by-entry accounting review | `day-book`, `general-ledger`, `ledger-log`, or `account-ledger` |
| Household/person review over budgets, cash movement, and net worth | `budget-vs-actual`, `cashflow`, `net-worth`, `account-movement`, `transfer-summary` |
| Official-looking year-end statements | `profit-and-loss` and `balance-sheet` |
| Internal close evidence behind the balance sheet | `balance-sheet-specification` and `balance-sheet-reconciliation` |
| A voucher list or bank review document | `voucher-list` and `bank-transactions` |
| A close folder with many standard artifacts | `evidence-pack` |
| A register of accounting materials and storage locations | `materials-register` |
| A bookkeeping methods description for audit/retention | `methods-description` |
| Migration or import-vs-journal diagnostics | `journal-coverage`, `parity`, and `journal-gap` |
| Filing or annual-close checklist outputs | `compliance-checklist`, `filing-package`, `annual-template`, `annual-validate` |
| A quick check that statutory groups and profiles look right | `profit-and-loss` and `balance-sheet` |

### Everyday review reports

`trial-balance` and `account-balances` are the quickest health checks for a period-end or year-end review.

`day-book` shows entries in posting order. `general-ledger` groups them by account and, in human-facing text, Markdown, and PDF output, renders one table section per account with the account code and account name shown before that section's entry rows. If you prefer terminal-style browsing instead of table output, `ledger-log` is the review command to try next.

`account-ledger` is a narrower, date-range-focused tool for one account. It is useful when a single account needs explanation over a smaller time window.

In human-facing `day-book` and `general-ledger` outputs, Bus avoids printing
the same visible voucher number twice. If `Tositenumero` is already derived
from the same voucher value, the separate `Voucher` column is left blank. When
there is a genuinely distinct external document number and voucher id, both
stay visible.

Text, markdown, and PDF review outputs shorten `Tx` by default. The redundant
human-facing `Entry` or `Vienti` column is omitted when `Tx` and `Rivi` are
already visible, while machine-facing outputs such as CSV still retain the
stable `entry_id` field. If you also want the same shortened display value for
`Tx` in CSV, add `--short-ids` to `day-book` or `general-ledger`.

In those human-facing `general-ledger` and `day-book` views, the amount column
is signed: debit rows show a leading plus sign and credit rows a leading minus
sign. `Dr` and `Cr` are used instead of full debit and credit labels, and
day-book compacts the visible account column to `<tilinumero> <tilin nimi>` to
save width. CSV and JSON keep the stable machine-facing split between `side`
and unsigned `amount`.

PDF day-book and general-ledger outputs also size columns from the actual
rendered content instead of using one fixed layout. The resolved columns are
stretched across the full printable page width, but short identifier and other
fixed-value columns stay compact so `Description` absorbs most of that extra
width. Bus also hides the `Voucher` column entirely when it would be blank on
every row. Wrapped PDF cells now share one logical row height so the table
stays visually aligned across columns, and page breaks are computed from those
final wrapped row heights so later pages do not inherit an overfull table
slice. In `general-ledger` PDF, a whole account table starts on a fresh page
when the next section would otherwise begin at the bottom of the current page
and continue immediately onto the following page.

`voucher-list` follows the same rule. The visible `document_number` comes from
the business-facing voucher number first, while any technical or imported
`source_id` stays available as a separate trace field instead of replacing the
human review number.

### Finnish statutory reporting

For Finnish statement output, the most important decision is the layout. The common built-in layout IDs are:

- `fi-kpa-tase`
- `fi-pma-tase`
- `fi-kpa-tuloslaskelma-kululaji`
- `fi-pma-tuloslaskelma-kululaji`

If you want a built-in statutory layout, use `--layout-id`. If you maintain your own statement layout file, use `--layout`.

`balance-sheet-specification` is internal evidence output, not a PRH filing document. Use it when you need a tase-erittely for review, audit, or close documentation.

`balance-sheet-reconciliation` uses the same effective liability-side
classification as the rendered TASE, so a balanced statutory TASE should not
produce a false `VASTATTAVAA` mismatch in the reconciliation summary.

If a statutory PDF comes out with blank signature or company fields, set those defaults in [bus-config](./bus-config) and rerun the report.

If you are using BusDK for household or personal finance, set
`busdk.accounting_entity.entity_kind` to `personal` in
[workspace configuration](../data/workspace-configuration). That profile now
switches `bus-reports` to the household/person review family:
`budget-vs-actual`, `cashflow`, `net-worth`, `account-movement`,
`transfer-summary`, personal `evidence-pack` defaults, and internal
`annual-template` / `filing-package` / `annual-validate` outputs instead of
company-style public-filing defaults. Company-style PDF metadata warnings for
Y-tunnus and signature fields are also suppressed for those personal review
outputs. Because `evidence-pack` is PDF-only, that package currently includes
only the personal/non-company review documents that already have PDF
renderers. Sole-proprietor / `tmi` workspaces still keep the non-public annual
review manifests and checks, but their `evidence-pack` now also includes the
core `tase` and `tuloslaskelma` artifacts so the yearly package contains the
expected financial statements.

### Statement placement and report profiles

For statutory reporting, start from `account-groups.csv`. That group tree is the canonical reporting hierarchy. Every posting account belongs to one group through `accounts.csv:group_id`, and short or full statement variants should differ only by which groups are visible in the selected `report_profiles`.

When you need to inspect that resolution directly, use `statement-explain` or
`statement-validate`. Those commands show the original account group, the
effective canonical group used by the selected statement, the visible line
chosen from the selected layout/profile, an explicit `resolution_chain`, and
the deterministic reason for the placement or failure.

In the internal `*-accounts` drill-down variants, structural heading rows stay visually structural: headings such as `VASTAAVAA`, `VASTATTAVAA`, `Materiaalit ja palvelut`, and `Henkilöstökulut` render with blank amount cells, while the numeric totals stay on the corresponding subtotal and result rows.

This also explains the special rows in Finnish statements. TASE is always one statement split into `VASTAAVA` and `VASTATTAVAA`, and the current-year result is a reporting result that must appear both as the final income-statement row and as a separate equity item in the balance sheet. The background model for those constraints lives in [Finnish reporting hierarchy for TASE and tuloslaskelma](../compliance/fi-reporting-taxonomy-and-account-classification).

### Close and audit package commands

`voucher-list` creates a printable `tositeluettelo`.

`bank-transactions` creates a grouped bank review document. This is useful when you want a readable review artifact instead of raw bank-import rows.

`materials-register` lists accounting datasets, schemas, storage paths, and linkage fields. In Finnish accounting practice this corresponds to the `luettelo kirjanpidoista ja aineistoista`.

`methods-description` is the companion artifact for the bookkeeping method itself. It describes entity context, reporting context, locking/correction model, evidence handling model, report surfaces, and dataset roles in one deterministic review document.

`evidence-pack` is the one-command close bundle. It writes a target directory full of standard artifacts and also writes a manifest of what it created. The package is now PDF-only: it includes `materials-register` and `methods-description` as first-class PDFs, internal `tase-erittelyt`, and explicit compact/full/account-breakdown statutory PDFs alongside the main statements and ledgers, but it no longer writes CSV or TSV artifacts into the output directory. You can trim the package with `--profile accountant|machine` or explicit `--include` / `--exclude` selectors, and you can rename generated artifacts deterministically with repeated `--filename-template SELECTOR=TEMPLATE` rules. Selectors match `*`, `report`, `report:format`, or the default filename; templates support `{report}`, `{format}`, `{period}`, `{as_of}`, `{from}`, and `{filename}`. Workspace configuration can provide the same defaults through `busdk.accounting_entity.reporting_context.fi.evidence_pack_profile` and `evidence_pack_filename_templates`, and command-line flags override those defaults deterministically. If one artifact fails, `evidence-pack` still attempts the remaining artifacts, writes the manifest of successful outputs, and only then exits non-zero with an aggregated stderr summary. For `entity_kind=personal` and other non-company profiles, the package stays on the internal review path, but because it is PDF-only it currently includes only the review documents that already have PDF renderers. Sole-proprietor / `tmi` workspaces additionally keep the core `tase` and `tuloslaskelma` PDFs in that same internal review package.

Comparative figures come only from the current workspace. When comparatives are
enabled, `balance-sheet`, `profit-and-loss`, and `evidence-pack` use prior-year
journal rows that already exist in that workspace. For full-year annual
statements, if those rows are absent, bus-reports falls back to the opening
balances recorded at the start of the year so the prior column still shows how
the year began. `annual-validate` checks for one of those current-workspace
comparative sources before it reports a pass.

`compliance-checklist`, `filing-package`, `annual-template`, and `annual-validate` are the commands to reach for when you are assembling or checking an annual-close package rather than just printing one report. Company-form workspaces keep statutory public-filing package/template output, while non-company legal forms and `entity_kind=personal` workspaces switch to an internal annual review package centered on summaries, tax notes, and evidence indexes instead of PRH filing sections. The checklist now uses that same non-corporate model, so it no longer claims that a sole proprietor must generate company-style balance-sheet and profit-and-loss filing artifacts when the selected package flow is internal review only.

### Migration and quality checks

`journal-coverage` compares journal activity by month and can include imported operational totals.

`parity` compares source-import totals with journal totals by dataset and period.

`journal-gap` goes one level deeper by using account buckets, which makes it easier to see whether a difference belongs to operations, financing, transfers, or unmapped activity.

If you need a pass/fail gate on these outputs, combine them with [bus-validate](./bus-validate).

### Output formats and files

Machine-oriented formats are usually `csv`, `json`, or `tsv`. Human-oriented review outputs are usually `text`, `markdown`, or `pdf`.

`profit-and-loss` and `balance-sheet` additionally support `kpa` and `pma` output. Review documents such as `day-book`, `general-ledger`, `voucher-list`, `bank-transactions`, `balance-sheet-reconciliation`, and `materials-register` support `pdf`.

When you use `-o`, missing parent directories are created automatically before the file is written. Failed runs do not replace an existing successful output file. PDF metadata timestamps are rendered in local time and include the timezone abbreviation plus numeric UTC offset.

These commands use [Standard global flags](../cli/global-flags). The most commonly used extras here are `-C`, `-o`, `--format`, and `--locale`. In human-facing outputs, `--locale fi` changes both decimal formatting and shared report labels such as headers and PDF titles. When `--locale` is omitted, BusDK first uses the workspace reporting profile language from `busdk.accounting_entity.reporting_profile.fi_statutory.language` when it is configured, and only then falls back to the shell locale. For the complete command matrix, run `bus reports --help`.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus reports trial-balance --as-of 2026-01-31 --format csv
reports trial-balance --as-of 2026-01-31 --format csv

# same as: bus reports balance-sheet --as-of 2026-12-31 --layout-id fi-kpa-tase --format pdf
reports balance-sheet --as-of 2026-12-31 --layout-id fi-kpa-tase --format pdf

# same as: bus reports evidence-pack --period 2026 --output-dir ./out/reports --format tsv
reports evidence-pack --period 2026 --output-dir ./out/reports --format tsv
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-budget">bus-budget</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-status">bus-status</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module reference: bus-reports](../modules/bus-reports)
- [Module reference: bus-config](../modules/bus-config)
- [Module reference: bus-validate](../modules/bus-validate)
- [Workflow: Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
- [Finnish balance sheet and income statement regulation](../compliance/fi-balance-sheet-and-income-statement-regulation)
- [Finnish reporting taxonomy and account classification](../compliance/fi-reporting-taxonomy-and-account-classification)
- [Household accounting and personal-finance workspaces](../compliance/fi-household-accounting-and-personal-finance)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
