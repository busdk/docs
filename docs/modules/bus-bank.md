---
title: bus-bank — import and list bank transactions
description: bus bank normalizes bank statement data into schema-validated datasets, supports adding bank accounts and transactions manually, and provides listing output for reconciliation and posting workflows.
---

## `bus-bank` — import and list bank transactions

### Synopsis

`bus bank init [-C <dir>] [global flags]`  
`bus bank import --file <path> [-C <dir>] [global flags]`  
`bus bank import --profile <path> --source <path> [--year <YYYY>] [--fail-on-ambiguity] [-C <dir>] [global flags]`  
`bus bank config [<subcommand>] [options] [-C <dir>] [global flags]`  
`bus bank list [--month <YYYY-M>] [--from <date>] [--to <date>] [--counterparty <id>] [--invoice-ref <ref>] [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus bank backlog [--month <YYYY-M>] [--from <date>] [--to <date>] [--detail] [--fail-on-backlog] [--max-unposted <n>] [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus bank statement extract --file <path> [--profile <name>|--profile-name <name>] [--account <id>] [--iban <iban>] [--attachment-id <uuid>] [--header-row <n>] [--map <field=header-or-column>] [--date-format <format>] [--decimal-sep <char>] [--group-sep <char|space|nbsp|none>] [--unicode-minus] [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus bank statement parse --file <path> [--profile <name>|--profile-name <name>] [--account <id>] [--iban <iban>] [--attachment-id <uuid>] [--header-row <n>] [--map <field=header-or-column>] [--date-format <format>] [--decimal-sep <char>] [--group-sep <char|space|nbsp|none>] [--unicode-minus] [-C <dir>] [-o <file>] [-f <csv|json>] [global flags]`  
`bus bank statement transactions --file <path> [--profile <name>|--profile-name <name>] [--account <id>] [--iban <iban>] [--attachment-id <uuid>] [--header-row <n>] [--map <field=header-or-column>] [--date-format <format>] [--decimal-sep <char>] [--group-sep <char|space|nbsp|none>] [--unicode-minus] [-C <dir>] [-o <file>] [-f <csv|json>] [global flags]`  
`bus bank statement verify [--statement <parsed.json|attachment-id>] [--bank-rows <path>] [--year <YYYY>] [--account <id>] [--fail-if-diff-over <amount>] [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus bank` normalizes bank statement data into schema-validated datasets.

It provides deterministic listing output used by reconciliation and posting workflows.

Ingest supports both single-statement files (`--file`) and profile-driven ERP import (`--profile --source`, optional `--year`).

### Commands

`init` creates baseline bank datasets and schemas. If they already exist in full, `init` warns and exits 0 without changes. If they exist only partially, `init` fails and does not modify files.

`import` ingests either a statement file (`--file <path>`) or profile-driven ERP input (`--profile <path> --source <path>`, optional `--year`) into normalized datasets. Built-in `erp-tsv` mode adds malformed-tab-tolerant import with deterministic parse diagnostics (`recovered_rows`, `ambiguous_rows`, `dropped_rows`) and optional `--fail-on-ambiguity`. Generated `import_id` and `bank_txn_id` values follow shared workspace `bus-config` `id_generation` policy when configured; without workspace policy, statement import keeps its legacy runtime fallback and profile import keeps its deterministic content-hash fallback.

`config` manages counterparty normalization and reference extractors. `config counterparty add` stores canonical names and aliases, and `config extractors add` stores extraction patterns for message/reference fields. With config present, `list` output includes normalized counterparty and extracted hint columns.

`list` prints filtered bank transactions deterministically. `backlog` reports posted versus unposted transactions for coverage checks and CI gates. `statement extract` appends normalized checkpoints to `bank-statement-checkpoints.csv`, `statement parse` emits canonical parse output for statement evidence, `statement transactions` emits flattened parsed transaction lines, and `statement verify` compares parsed statements (or stored checkpoints) to running balances in `bank-transactions.csv` with optional fail thresholds.

### Options

`import` supports `--file <path>` for statement files, profile-driven mode with `--profile <path> --source <path>` and optional `--year`, and robust ERP TSV mode with `--profile erp-tsv` and optional `--fail-on-ambiguity`.

`list` supports `--month`, `--from`, `--to`, `--counterparty`, and `--invoice-ref`.

`backlog` supports `--month`, `--from`, `--to`, `--detail`, `--fail-on-backlog`, and `--max-unposted <n>`.

`statement extract` supports `--file <path>` plus optional profile/account/IBAN/attachment selectors, `--header-row`, and repeatable `--map <field=header-or-column>`. It also accepts parsing hints: `--date-format` for statement dates, `--decimal-sep` and `--group-sep` for numbers (including `space`, `nbsp`, or `none`), and `--unicode-minus` to normalize Unicode minus characters. Reusable mappings accept both `--profile <name>` and `--profile-name <name>`. When both a profile and CLI hints are provided, CLI hints override profile defaults. For schema-based summary CSV input, these hints are applied as parser defaults when schema fields do not define explicit date/number formats. For PDF evidence, extraction attempts native text extraction first, then falls back to sibling text exports or statement sidecars, and built-in text-literal fallback extraction is used when `pdftotext` is unavailable. `statement parse` and `statement transactions` use the same mapping and hint flags and support `-f csv` and `-f json` (default `csv` when format is omitted). `statement transactions` emits one row per parsed bank statement transaction line with checkpoint context. `statement verify` supports `--statement` for parsed JSON or attachment IDs, optional `--bank-rows` for alternate bank transaction data, and the existing `--year`, `--account`, and `--fail-if-diff-over` filters.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus bank --help`.

### Profile-driven ERP history import

Profile-driven import is available: `bus bank import --profile <path> --source <path> [--year <YYYY>]` runs deterministic mapping from ERP export data into canonical bank datasets. The profile defines column mappings, direction normalization, and optional year filtering. Each run emits auditable plan and result artifacts; re-runs with the same profile and source yield byte-identical artifacts. Supported by e2e and unit tests (`tests/e2e.sh`, `internal/bank/profile_import_test.go`). See [Import ERP history into canonical invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets).

### Reconciliation proposal flow

Deterministic reconciliation proposal generation in [bus-reconcile](./bus-reconcile) depends on stable bank transaction identity and normalized read fields from this module. The two-phase flow uses bank transaction ID, amount, currency, booking date, and reference fields as deterministic proposal inputs; when counterparty and extractor config are configured, normalized counterparty and extracted reference hints (e.g. `erp_id`, `invoice_number_hint`) are available for match-by-reference in bus-reconcile. Script-based candidate workflows (e.g. `exports/2024/025-reconcile-sales-candidates-2024.sh`) remain an alternative. The built-in `backlog` command provides classification coverage (posted vs unposted) for review and CI gates.

### Files

`bank-imports.csv`, `bank-transactions.csv`, and `bank-statement-checkpoints.csv` live at workspace root with beside schemas.

`bank-statement-checkpoints.csv` includes provenance columns (`attachment_id`, `source_path`, `extracted_at`).

The module does not use a `bank/` subdirectory. Path resolution is owned by this module.

Statement extract profiles live in `statement-extract-profiles.csv` at workspace root. Each row includes the profile name, optional `header_row`, optional parsing hints (`date_format`, `decimal_char`, `group_char`, `unicode_minus`), and the `field` to `selector` mappings used for statement extraction.

For raw CSV/TSV/TXT files without schema, extraction auto-detects common summary headers and can be configured with `--header-row` and `--map`. For PDF evidence, extraction attempts native text extraction (using `pdftotext` when available), then falls back to sibling text exports or statement sidecars.

When summary columns are missing, extraction can infer checkpoints from transaction-export rows with mapped `date`, `amount`, and `balance`.

### Examples

```bash
bus bank init
bus bank import --file ./imports/bank/january-2026.csv
bus bank import --profile erp-tsv --source ./imports/erp-bank.tsv --year 2026
bus bank backlog --month 2026-1 --detail --max-unposted 10
bus bank -f json statement parse --file ./imports/bank/january-2026.csv
bus bank statement transactions --file ./imports/bank/january-2026.pdf
```

### Exit status

`0` on success. Non-zero on errors, including invalid filters or schema violations.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus bank --help
bank --help

# same as: bus bank -V
bank -V

# file import + review backlog
bank import --file ./imports/bank/january-2026.csv
bank backlog --month 2026-1 --detail
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-journal">bus-journal</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-reconcile">bus-reconcile</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Bank accounts](../master-data/bank-accounts/index)
- [Owns master data: Bank transactions](../master-data/bank-transactions/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Module reference: bus-bank](../modules/bus-bank)
- [Workflow context: Import bank transactions and apply payment](../workflow/import-bank-transactions-and-apply-payment)
- [Workflow: Import ERP history into invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets)
- [Workflow: Deterministic reconciliation proposals and batch apply](../workflow/deterministic-reconciliation-proposals-and-batch-apply)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)
