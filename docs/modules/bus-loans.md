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

`add` records a loan contract in the register. `event` appends a disbursement, repayment, interest, fee, or adjustment event and can produce postings. `amortize` generates amortization and posting output for a period.

### Options

For `add`, required flags are `--loan-id`, `--counterparty`, `--principal`, `--start-date`, `--maturity-date`, `--interest-rate`, `--principal-account`, `--interest-account`, and `--cash-account`. Optional flags are `--name`, `--rate-type`, `--payment-frequency`, and `--desc`.

`event` requires `--loan-id`, `--date`, `--type`, and `--amount`, and also supports allocation and voucher flags. `amortize` requires `--period` and supports `--loan-id` and `--post-date`.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus loans --help`.

### Files

Loan register and event datasets and their beside-the-table schemas in the loans area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `loans/` folder). Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

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
For planned extension notes, see [Suggested extensions](../sdd/bus-loans#suggested-extensions-loan-payment-classifier-from-bank-rows).


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


### Development state

**Value promise:** Maintain loan register and events so amortization and event postings feed the [bus-journal](./bus-journal) and loan accounts appear in [bus-reports](./bus-reports).

**Use cases:** [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 70% (Core workflow implemented and verified) — init, add, event, amortize, list, update, validate, balances, schedule, and postings are implemented and verified by unit and e2e tests.

**Use case readiness:** Finnish company reorganisation: 70% — core loan lifecycle (register, events, amortization, validation, balances, schedules, postings) is implemented and test-covered.

**Current:** Init/add/event/amortize and related lifecycle commands are test-verified, including global-flag behavior.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-loans](../sdd/bus-loans).

**Planned next:** Follow-up priorities are incremental SDD alignment and additional output-format/integration coverage; implementing event and amortize is no longer planned work.

**Blockers:** None known.

**Depends on:** [bus-accounts](./bus-accounts), [bus-entities](./bus-entities) (reference validation when datasets exist).

**Used by:** Loan postings feed [bus-journal](./bus-journal); loan accounts in [bus-reports](./bus-reports).

See [Development status](../implementation/development-status).

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
- [Module SDD: bus-loans](../sdd/bus-loans)
- [Data contract: Table schema contract](../data/table-schema-contract)
