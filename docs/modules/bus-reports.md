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
  -o ./out/20260131-day-book.pdf

bus reports general-ledger \
  --period 2026-01 \
  --format pdf \
  -o ./out/20260131-general-ledger.pdf
```

Create Finnish statutory PDFs for year-end:

```bash
bus reports profit-and-loss \
  --period 2026 \
  --layout-id fi-kpa-tuloslaskelma-kululaji \
  --format pdf \
  -o ./out/20261231-tuloslaskelma.pdf

bus reports balance-sheet \
  --as-of 2026-12-31 \
  --layout-id fi-kpa-tase \
  --format pdf \
  -o ./out/20261231-tase.pdf
```

By default, `profit-and-loss` and `balance-sheet` hide rows whose values are
zero in both shown periods. In hierarchical balance-sheet layouts, parent and
heading rows still stay visible when a child row below them carries a non-zero
current or comparative amount. Add `--show-zero-rows` when you want to inspect
the full statutory structure, including fully zero-valued rows. PDF follows
the same zero-row filtering instead of showing extra zero-only statutory rows.
If the journal contains money values with more than two decimals, `bus-reports`
fails during workspace load instead of rounding or silently normalizing them.
Human-facing PDF tables also default to borderless or minimal-line styling
instead of boxed per-cell borders, which keeps the PDFs searchable while
making text selection, highlighting, and annotation work more naturally in
viewers such as Apple Preview. The shared PDF renderer now embeds Unicode
fonts with `/ToUnicode` mappings so copied, selected, and extracted text stays
readable across common viewers and PDF extraction tools. Full and
`*-accounts` statement rows are now emitted through the shared statement text
path so Preview-style annotation and `pdftotext`-style extraction follow the
natural reading order. The accountant-facing review-table family
(`general-ledger`, `day-book`, `voucher-list`, and `bank-transactions`) now
uses one shared visible-only cell renderer with explicit gutters between
columns and no overlapping hidden duplicate row layer. The shared width
resolver budgets those gutters against visible cell width, so short fields
such as dates and compact identifiers do not wrap unnecessarily while a wider
description column on the same page still has reclaimable slack. That keeps
the visible layout readable without forcing text to start right at each cell
edge, which in turn helps neighboring columns stay separately selectable in
Preview-like viewers.
The same shared geometry contract now also keeps a small real vertical gap
between adjacent body rows, and the paginator uses that same row gap in its
page-fit math so body rows do not collapse into one continuous selectable
grid. The same shared table path now also keeps a small gap between the
repeated header row and the first body row instead of letting them touch.
That keeps
the printed table layout intact without the unstable page-by-page selection
behavior that Preview can show for overlapping text layers.
Repeated later-page statement headers now use that same full-row text path, so
`tase-full.pdf`, `tase-accounts.pdf`, and the matching tuloslaskelma variants
do not fall back to cell-style visible text on continuation pages. The same
shared text-based renderer now also covers visible PDF metadata, headers,
wrapped review rows, reconciliation tables, and materials-register rows
instead of older visible `CellFormat` or `MultiCell` text paths.

When you replay year-end close rows manually, use the Bus-native source-kind
surface from `bus journal add`, for example
`--source-id FY2025 --source-kind closing-result`. Reports
then recognize those rows as explicit close entries without depending on one
free-form source-id spelling, and `profit-and-loss` excludes them from normal
period activity while `balance-sheet` can still use them as explicit close
basis.

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
  -o ./out/20261231-materials-register.pdf
```

Generate the workspace methods description (`menetelmäkuvaus`) that explains how bookkeeping data, evidence links, locking, and reports are handled:

```bash
bus reports methods-description \
  --format pdf \
  -o ./out/20261231-methods-description.pdf
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

`bus reports trial-balance --as-of <YYYY-MM-DD> [--grouped] [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports account-balances --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports general-ledger --period <PERIOD_ID> [--account <code>] [--group-by <dim:KEY|source-voucher>] [--short-ids] [--show-source-voucher] [--show-external-source-ref] [--show-source-links] [--format <text|csv|markdown|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports day-book --period <PERIOD_ID> [--group-by <dim:KEY|source-voucher>] [--short-ids] [--show-source-voucher] [--show-external-source-ref] [--show-source-links] [--format <text|csv|markdown|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports ledger-log --period <PERIOD_ID> [options] [-C <dir>] [global flags]`  
`bus reports account-ledger --account <code> --from <YYYY-MM-DD> --to <YYYY-MM-DD> [-C <dir>] [global flags]`  
`bus reports profit-and-loss --period <PERIOD_ID> [--layout-id <id>|--layout <file>] [--comparatives <on|off>] [--comparative-workspace <dir>|--comparative-account-balances <file>] [--format <text|csv|markdown|json|kpa|pma|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports statement-explain --report <balance-sheet|profit-and-loss> (--as-of <YYYY-MM-DD> | --period <PERIOD_ID>) [--account <code>] [--layout-id <id>|--layout <file>] [--allow-implicit-current-year-result] [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports statement-validate --report <balance-sheet|profit-and-loss> (--as-of <YYYY-MM-DD> | --period <PERIOD_ID>) [--account <code>] [--layout-id <id>|--layout <file>] [--allow-implicit-current-year-result] [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports budget-vs-actual --period <PERIOD_ID> [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports cashflow --period <PERIOD_ID> [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports net-worth --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports account-movement --period <PERIOD_ID> [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports transfer-summary --period <PERIOD_ID> [--format <text|csv|markdown|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet --as-of <YYYY-MM-DD> [--layout-id <id>|--layout <file>] [--comparatives <on|off>] [--comparative-workspace <dir>|--comparative-account-balances <file>] [--allow-implicit-current-year-result] [--format <text|csv|markdown|json|kpa|pma|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet-specification --as-of <YYYY-MM-DD> [--layout-id <id>|--layout <file>] [--allow-implicit-current-year-result] [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet-reconciliation --as-of <YYYY-MM-DD> [--layout-id <id>|--layout <file>] [--allow-implicit-current-year-result] [--format <text|csv|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports voucher-list --period <PERIOD_ID> [--format <text|csv|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports bank-transactions --period <PERIOD_ID> [--account <code>] [--format <text|csv|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports materials-register [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports methods-description [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports evidence-pack (--period <PERIOD_ID> | --as-of <YYYY-MM-DD>) --output-dir <dir> [--comparative-workspace <dir>|--comparative-account-balances <file>] [--allow-implicit-current-year-result] [-C <dir>] [global flags]`  
`bus reports journal-coverage [options] | parity [options] | journal-gap [options] | compliance-checklist [options] | filing-package [options] | annual-template [options] | annual-validate [options]`

`PERIOD_ID` accepts the usual Bus shorthand identifiers such as `2024`, `2024-01`, and `2024Q1`, and it also accepts any custom `period_id` defined in the workspace `periods.csv`, such as `FY2024-2025`.

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

`trial-balance` and `account-balances` are the quickest health checks for a period-end or year-end review. When you want the same canonical hierarchy you already use elsewhere in Finnish reporting, add `--grouped` to `trial-balance` and the human-facing text, Markdown, or PDF output will show account-group rows with their subtotal balances above the posting accounts below them.

`day-book` shows entries in posting order and, in human-facing text, Markdown, and PDF output, now adds one summary line after each date with that day's debit total, credit total, debit row count, credit row count, distinct transaction count, and cumulative end-of-day result. `general-ledger` groups entries by account and, in those same human-facing formats, renders one table section per account with the account code and account name shown before that section's entry rows. It now also adds one summary line after each date inside an account section, with that day's debit total, credit total, debit row count, credit row count, and the account's ending saldo after the day, plus one monthly summary line after the last rendered day of each month in that same account section with the month's debit total, credit total, debit row count, credit row count, and ending saldo after the month. Those same human-facing `general-ledger` views also include a `counter_account` / `vastatili` column so you can see the other account or accounts from the same transaction without leaving the current account section. In PDF, `general-ledger` now starts with a table of contents that lists those account sections and their page numbers, and those TOC rows are clickable internal PDF links to the matching account section. `day-book` uses the same shared PDF path and starts with a month-based table of contents for the rendered period, with the same clickable internal-link behavior. In `general-ledger` PDF, each visible counterpart-account label also links internally to the matching transaction row in that counterpart account section. If you prefer terminal-style browsing instead of table output, `ledger-log` is the review command to try next.

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

If a posting also carries imported source voucher notation from `bus-journal`,
add `--show-source-voucher` to `day-book` or `general-ledger` when you want
that human-facing review output to show the preserved source-facing voucher
label or context/number beside the description. If parity review needs the
same imported block structure as the source system, add `--group-by
source-voucher` to subtotal by the stored source voucher group token. If a
posting also carries one legacy or migration pointer, add
`--show-external-source-ref` when you want the deterministic
`external_source_ref` value shown as well. If one posting carries more than
one preserved source relation, add `--show-source-links` too. CSV and JSON
keep `source_voucher`, `external_source_ref`, and `source_links` even without
those human-facing flags only in grouped or machine-facing output paths.
Ungrouped CSV now mirrors the same visible review columns as PDF instead:
signed amounts, summary rows, counterpart-account display values, and the same
optional source-facing review columns when you enable them.

In those human-facing `general-ledger` and `day-book` views, the amount column
is signed: debit rows show a leading plus sign and credit rows a leading minus
sign. `Dr` and `Cr` are used instead of full debit and credit labels, and
day-book compacts the visible account column to `<tilinumero> <tilin nimi>` to
save width. Ungrouped CSV follows that same signed review presentation, while
grouped CSV and JSON keep the stable machine-facing split between `side` and
unsigned `amount`.
When multiple postings share the same date, those review outputs keep the same
append order as the journal instead of re-sorting same-day rows by internal
transaction IDs or stringified line numbers.

PDF day-book and general-ledger outputs also size columns from the actual
rendered content instead of using one fixed layout. The resolved columns are
stretched across the full printable page width, but short identifier and other
fixed-value columns stay compact so `Description` absorbs most of that extra
width. Bus also hides the `Voucher` column entirely when it would be blank on
every row. Wrapped PDF cells now share one logical row height so the table
stays visually aligned across columns, and page breaks are computed from those
final wrapped row heights so later pages do not inherit an overfull table.
The same page-local width policy also keeps visible document-number columns
compact in both `day-book` and `general-ledger`, and reserves enough date
width that bold summary dates stay on one line.
slice. In `general-ledger` PDF, account sections use whatever page space
remains as long as the section heading, repeated header, and at least part of
the current account table fit on that page. If the next row in the same
account no longer fits after that heading/header overhead, Bus moves that row
to a fresh page instead of forcing it into the remaining space. In `day-book`
PDF, that same
page-local width resolution also rebalances width away from `Selite` when the
current page would otherwise wrap the visible `Account` column unnecessarily.
Signed amount cells are kept on one rendered line instead of wrapping across
multiple lines. The page picker only evaluates as many candidate body rows as
can physically fit on the current page, so large real-year day-book and
evidence-pack PDF runs do not stall by rescanning the full remaining journal
slice on every page. The same human-facing PDF table family now also uses one
shared visible row-text path instead of per-cell visible text fragments, so
Apple Preview annotations and `pdftotext`/`pdftohtml` extraction behave the
same way in `day-book`, `general-ledger`, `voucher-list`, `bank-transactions`,
`account-balances`, `balance-sheet-specification`, `materials-register`, and
the statutory statement PDFs. For the ledger/day-book review family
specifically, the visible row layer stays on the real column grid rather than
on one space-padded visible line, so adjacent rows and continuation pages
stay visually aligned under the same headers even when values have mixed
widths. Each non-final visible review cell also carries a literal trailing
space when it contains text, so copied and extracted text keeps a clean
separator between adjacent columns even if the PDF viewer heuristically treats
the page as a table. The same shared style also keeps the light gray cell outlines/fills as
part of the real document appearance and reserves a separate gap between month
or account title boxes and the header row beneath them. In `day-book` and
`general-ledger`, those title boxes also include a compact top-right link back
to the opening table of contents.

`voucher-list` follows the same rule. The visible `document_number` comes from
the business-facing voucher number first, while any technical or imported
`source_id` stays available as a separate trace field instead of replacing the
human review number. In text, markdown, and PDF review outputs, the visible
transaction identifier is shortened in the same human-facing way as the other
review tables.

### Finnish statutory reporting

For Finnish statement output, the most important decision is the layout. The common built-in layout IDs are:

- `fi-kpa-tase`
- `fi-pma-tase`
- `fi-kpa-tuloslaskelma-kululaji`
- `fi-pma-tuloslaskelma-kululaji`

If you want a built-in statutory layout, use `--layout-id`. If you maintain your own statement layout file, use `--layout`.

`balance-sheet-specification` is internal evidence output, not a PRH filing
document. Use it when you need a tase-erittely for review, audit, or close
documentation. Its PDF table now uses the same adaptive wrapped full-width
layout as the other accountant-facing review documents. The printable PDF also
follows the same metadata and signature-block convention as the other review
reports, and the trailing `Allekirjoitukset` block moves to a fresh page if it
would not fit safely at the bottom of the current page.

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
outputs. Personal/non-company `evidence-pack` now writes CSV companions beside
the same review documents that stay in scope. Sole-proprietor / `tmi`
workspaces still keep the non-public annual review manifests and checks, but
their `evidence-pack` now also includes the core `tase` and `tuloslaskelma`
artifacts plus the explicit compact/full/account-breakdown Finnish statutory
statement variants so the yearly package contains the expected financial
statements and deeper review PDF+CSV pairs without switching to a
public-filing annual package.

### Statement placement and report profiles

For statutory reporting, start from `account-groups.csv`. That group tree is the canonical reporting hierarchy. Every posting account belongs to one group through `accounts.csv:group_id`, and short or full statement variants should differ only by which groups are visible in the selected `report_profiles`. In the built-in Finnish `*-full` layouts, bus-reports expands any visible deeper descendants from that canonical tree under the matching statutory parent rows, so lower-level TASE and tuloslaskelma branches remain visible without introducing a second report-only hierarchy.

In the Finnish `*-full-accounts` balance-sheet variants, that same shared tree also drives the account drill-down rows. If a visible TASE line, including an injected descendant group row, carries non-zero balance-sheet account contributions, the report appends deterministic per-account rows under that exact visible line instead of limiting breakdowns to a small built-in row subset. Synthetic current-year-result remapping still affects the `Tilikauden voitto/tappio` total, but ordinary revenue and expense accounts are not shown there as normal TASE account rows. In printable PDFs those account rows use one wrapped visible detail label such as `<tilinumero> <tilin nimi>`, so long account names stay fully visible instead of being clipped by separate fixed code and name columns.

For `fi-kpa-*` balance-sheet layouts, BusDK does that remapping by default
when the workspace has current-period profit-and-loss activity and no explicit
close postings on the canonical `bs_current_year_result` branch. That is the
normal electronic-accounting model: `Tilikauden voitto/tappio` is derived
directly from the live ledger rather than requiring a separate closing voucher.
When the workspace does contain explicit year-end result postings for replay,
migration parity, or imported historical evidence, prefer the Bus-native
journal source-id surface `--source-id FY2025 --source-kind closing-result`,
which stores the stable canonical key `close-result:FY2025:1`. Equivalent
separator aliases such as `closing_result` are accepted too, but they
normalize to the same semantic close meaning. `--allow-implicit-current-year-result`
is still accepted for compatibility, but it no longer changes the default
derived-result behavior.

The same canonical-tree rule applies to the Finnish `fi-*-tuloslaskelma-full` and `fi-*-tuloslaskelma-full-accounts` layouts. If the workspace group tree contains deeper visible descendants below a built-in statutory expense branch, those descendants stay visible as their own rows, they render with the same negative visible statement sign as the parent expense branch, and any direct account contributions stay under that exact visible descendant row in the `*-accounts` variants instead of collapsing back to a higher built-in parent row.

When you need to inspect that resolution directly, use `statement-explain` or
`statement-validate`. Those commands show the original account group, the
canonical group code path, the direct group `report_profiles`, the effective
canonical group used by the selected statement, the effective group code path
and profiles, the visible line chosen from the selected layout/profile, an
explicit `resolution_chain`, and the deterministic reason for the placement or
failure.

For `fi-kpa-*` balance-sheet layouts, those commands also make the
current-year-result rule explicit. When no close-source basis exists they
return `synthetic_current_year_result` as the normal derived balance-sheet
placement path. When explicit close-source basis exists they return
`explicit_current_year_result_basis` instead, so operators can see that the
workspace is relying on replay/parity close evidence rather than the normal
derived result path.

In the internal `*-accounts` drill-down variants, structural heading rows stay visually structural: headings such as `VASTAAVAA`, `VASTATTAVAA`, `Materiaalit ja palvelut`, and `Henkilöstökulut` render with blank amount cells, while the numeric totals stay on the corresponding subtotal and result rows.

This also explains the special rows in Finnish statements. TASE is always one statement split into `VASTAAVA` and `VASTATTAVAA`, and the current-year result is a reporting result that must appear both as the final income-statement row and as a separate equity item in the balance sheet. The background model for those constraints lives in [Finnish reporting hierarchy for TASE and tuloslaskelma](../compliance/fi-reporting-taxonomy-and-account-classification).

### Close and audit package commands

`voucher-list` creates a printable `tositeluettelo`. Its PDF output uses the
same wrapped full-width review-table path as the accountant-facing ledger
documents and keeps the visible transaction identifier short.

`bank-transactions` creates a grouped bank review document. This is useful when
you want a readable review artifact instead of raw bank-import rows. Its PDF
output uses the same shared wrapped review-table path as the other accountant
review documents, including per-account headings, page-safe repeated headers,
and a distinct closing-totals section. The visible `Loppusaldo` column now
shows the running balance after each bank row and also carries the ending
saldo onto the per-account `YHTEENSÄ` rows and the main overall summary row.

`materials-register` lists accounting datasets, schemas, storage paths, and linkage fields. In Finnish accounting practice this corresponds to the `luettelo kirjanpidoista ja aineistoista`.

`methods-description` is the companion artifact for the bookkeeping method itself. It describes entity context, reporting context, locking/correction model, evidence handling model, report surfaces, and dataset roles in one deterministic review document.

`evidence-pack` is the one-command close bundle. It writes a target directory
full of standard artifacts and also writes a manifest of what it created. The
package includes the main statements, ledgers, internal `tase-erittelyt`, and
explicit compact/full/account-breakdown statutory PDFs. For every report
artifact that already has a deterministic CSV renderer, `evidence-pack` also
writes a same-name `.csv` companion into the output directory so the package
contains both printable review documents and machine-readable exports derived
from the same statement/report rows. The default package still excludes
`materials-register` and `methods-description`. Dated default filenames use a
compact `YYYYMMDD-` prefix such as `20241231-tase.pdf`, `20241231-tase.csv`,
`20241231-day-book.pdf`, and `20241231-day-book.csv`. You can trim the package
with `--profile accountant|machine` or explicit `--include` / `--exclude`
selectors, and you can rename generated artifacts deterministically with
repeated `--filename-template SELECTOR=TEMPLATE` rules. Selectors match `*`,
`report`, `report:format`, or the default filename; templates support
`{report}`, `{format}`, `{period}`, `{as_of}`, `{from}`, and `{filename}`.
When a filename template rewrites a PDF artifact, its CSV companion follows the
same resolved basename with `.csv`. Workspace configuration can provide the same defaults through
`busdk.accounting_entity.reporting_context.fi.evidence_pack_profile` and
`evidence_pack_filename_templates`, and command-line flags override those
defaults deterministically. If one artifact fails, `evidence-pack` still
attempts the remaining artifacts, writes the manifest of successful outputs,
and only then exits non-zero with an aggregated stderr summary. For
`entity_kind=personal` and other non-company profiles, the package stays on
the internal review path and writes CSV companions beside the same review/PDF
artifacts that remain in scope. Sole-proprietor / `tmi` workspaces
additionally keep the core `tase` and `tuloslaskelma` PDF+CSV pairs in that
same internal review package. When comparative data is present, the generated
statement PDFs are expected to show the same prior-period column as the CSV
companions, because both are derived from the same resolved statement rows.

Comparative figures use the current workspace only when prior-year data really
exists there. That covers the uncommon multi-year workspace, but a normal Bus
workspace usually covers one fiscal year. Because of that, full-year
`profit-and-loss` no longer falls back to first-day opening balances:
opening balances can support `balance-sheet` comparatives, but they do not
contain prior-year tuloslaskelma detail. When the prior year is not already in
the current workspace, pass it explicitly with `--comparative-workspace DIR`
or `--comparative-account-balances FILE`. The snapshot file uses the
deterministic `account-balances --format csv` shape `code,name,balance`.
`evidence-pack` forwards the same explicit comparative source to each
generated balance-sheet and profit-and-loss artifact, including the generated
CSV companions, and `annual-validate` now checks for one of those real
comparative sources before it reports a pass.

The same forwarding model applies to `--allow-implicit-current-year-result`,
but the flag is kept only for compatibility. `evidence-pack` already uses the
default derived current-period result path for `fi-kpa-*` balance-sheet
artifacts when no explicit close postings exist.
When you intentionally opt into a derived `fi-kpa` current-year-result
fallback, `evidence-pack` forwards that choice to the generated
balance-sheet, balance-sheet specification, and balance-sheet reconciliation
artifacts. Without that explicit opt-in, those artifacts fail when the
workspace has no real close-source basis.

`compliance-checklist`, `filing-package`, `annual-template`, and `annual-validate` are the commands to reach for when you are assembling or checking an annual-close package rather than just printing one report. Company-form workspaces keep statutory public-filing package/template output, while non-company legal forms and `entity_kind=personal` workspaces switch to an internal annual review package centered on summaries, tax notes, and evidence indexes instead of PRH filing sections. The checklist now uses that same non-corporate model, so it no longer claims that a sole proprietor must generate company-style balance-sheet and profit-and-loss filing artifacts when the selected package flow is internal review only.

### Migration and quality checks

`journal-coverage` compares journal activity by month and can include imported operational totals.

`parity` compares source-import totals with journal totals by dataset and period.

`journal-gap` goes one level deeper by using account buckets, which makes it easier to see whether a difference belongs to operations, financing, transfers, or unmapped activity.

If you need a pass/fail gate on these outputs, combine them with [bus-validate](./bus-validate).

### Output formats and files

Machine-oriented formats are usually `csv`, `json`, or `tsv`. Human-oriented review outputs are usually `text`, `markdown`, or `pdf`.

`profit-and-loss` and `balance-sheet` additionally support `kpa` and `pma`
output. Review documents such as `day-book`, `general-ledger`,
`balance-sheet-specification`, `voucher-list`, `bank-transactions`,
`balance-sheet-reconciliation`, and `materials-register` support `pdf`. The
printable review PDFs use adaptive wrapped tables that stretch to the full
printable page width, and printable report variants leave an explicit gap
before `Allekirjoitukset`. Full statutory `tase` and `tuloslaskelma` PDFs keep
the same visible statement order across their plain and `*-accounts` variants,
so structural heading rows remain visible in every variant. In the
`*-accounts` PDFs, non-account statement rows use the full printable label
width instead of wasting separate account-code and account-name cells, and
missing comparative account cells stay blank instead of showing synthetic
`0.00` values.

When you use `-o`, missing parent directories are created automatically before the file is written. Failed runs do not replace an existing successful output file. PDF metadata timestamps and visible `Luotu` lines are rendered in local time and include the timezone abbreviation plus numeric UTC offset, so one document never mixes UTC and local provenance timestamps.

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
