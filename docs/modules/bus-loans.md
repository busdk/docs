---
title: bus-loans — manage loans and amortization schedules
description: bus loans maintains loan contracts and event logs as schema-validated repository data, generates amortization schedules, and produces posting suggestions…
---

## `bus-loans` — manage loans and amortization schedules

### Synopsis

`bus loans init [-C <dir>] [global flags]`  
`bus loans add --loan-id <id> --counterparty <entity> --principal <amount> --start-date <date> --maturity-date <date> --interest-rate <rate> --principal-account <account> --interest-account <account> --cash-account <account> [--name <name>] [--rate-type <type>] [--payment-frequency <freq>] [--desc <text>] [-C <dir>] [global flags]`  
`bus loans event --loan-id <id> --date <date> --type <disbursement|repayment|interest|fee|adjustment> --amount <amount> [allocation and voucher flags] [-C <dir>] [global flags]`  
`bus loans amortize --period <period> [--loan-id <id>] [--post-date <date>] [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus loans` maintains loan contracts and event logs as schema-validated repository data.
It generates amortization schedules and posting suggestions for the journal.
Corrections are append-only and traceable.

### Commands

`init` creates the baseline loan datasets and schemas. If they already exist in full, `init` warns and exits 0 without changing anything. If they exist only partially, `init` fails and does not modify files.

`add` records a loan contract in the register. `event` appends a disbursement, repayment, interest, fee, or adjustment event and can produce postings. When `--voucher` is omitted, event primary keys keep the legacy `EV-...` format unless the workspace overrides them through `busdk.accounting_entity.id_generation.types.loan_event_id` in `datapackage.json`. `amortize` generates amortization and posting output for a period.

### Options

For `add`, required flags are `--loan-id`, `--counterparty`, `--principal`, `--start-date`, `--maturity-date`, `--interest-rate`, `--principal-account`, `--interest-account`, and `--cash-account`. Optional flags are `--name`, `--rate-type`, `--payment-frequency`, and `--desc`.

`event` requires `--loan-id`, `--date`, `--type`, and `--amount`, and also supports allocation and voucher flags. `amortize` requires `--period` and supports `--loan-id` and `--post-date`.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus loans --help`.

### Files

Loan register and event datasets and their beside-the-table schemas live at the workspace root. The module does not use subdirectories such as `loans/`. Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../modules/index#data-path-contract-for-read-only-cross-module-access)).

If the workspace `datapackage.json` enables `_pcsv.version = "PCSV-1"`, `bus loans init` bootstraps `loans.csv` and `events.csv` as storage-aware padded tables through shared `bus-data` operations. In that mode the schemas include `_pad`, `loans.csv` supports in-place updates, and `events.csv` remains append-only. Plain CSV workspaces keep the old file layout and behavior unchanged.

### Examples

```bash
bus loans init
bus loans add \
  --loan-id LOAN-2026-01 \
  --counterparty "Nordic Bank" \
  --principal 50000 \
  --start-date 2026-01-01 \
  --maturity-date 2029-12-31 \
  --interest-rate 4.25 \
  --principal-account 2350 \
  --interest-account 8450 \
  --cash-account 1910
bus loans event --loan-id LOAN-2026-01 --date 2026-02-28 --type repayment --amount 1200
bus loans amortize --period 2026-02 --loan-id LOAN-2026-01 --post-date 2026-02-28
```

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

`bus loans` does not currently classify arbitrary bank rows into principal vs interest automatically.
Financing-style bank payments still need manual split or custom integration.
For planned extension notes, see [Suggested extensions](../modules/bus-loans#suggested-extensions-loan-payment-classifier-from-bank-rows).


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus loans add --loan-id LOAN-2026-02 --counterparty "Example Bank" --principal 25000 --start-date 2026-03-01 --maturity-date 2028-12-31 --interest-rate 3.75 --principal-account 2350 --interest-account 8450 --cash-account 1910
loans add --loan-id LOAN-2026-02 --counterparty "Example Bank" --principal 25000 --start-date 2026-03-01 --maturity-date 2028-12-31 --interest-rate 3.75 --principal-account 2350 --interest-account 8450 --cash-account 1910

# same as: bus loans event --loan-id LOAN-2026-02 --date 2026-03-31 --type interest --amount 78.50
loans event --loan-id LOAN-2026-02 --date 2026-03-31 --type interest --amount 78.50

# same as: bus loans amortize --period 2026-03 --loan-id LOAN-2026-02
loans amortize --period 2026-03 --loan-id LOAN-2026-02
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-assets">bus-assets</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-inventory">bus-inventory</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Loans](../master-data/loans/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module reference: bus-loans](../modules/bus-loans)
- [Data contract: Table schema contract](../data/table-schema-contract)
