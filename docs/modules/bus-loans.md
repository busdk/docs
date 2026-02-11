## bus-loans

### Name

`bus loans` — manage loans and amortization schedules.

### Synopsis

`bus loans <command> [options]`

### Description

`bus loans` maintains loan contracts and event logs as schema-validated repository data, generates amortization schedules, and produces posting suggestions for the journal. Corrections are append-only and traceable.

### Commands

- `init` creates the baseline loan datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `add` records a new loan contract in the loan register.
- `event` appends an event (disbursement, repayment, interest, fee, adjustment) and optionally produces postings.
- `amortize` generates amortization and posting output for a period.

### Options

`add` accepts `--loan-id`, `--counterparty`, `--principal`, `--start-date`, `--maturity-date`, `--interest-rate`, `--principal-account`, `--interest-account`, `--cash-account`, and optional `--name`, `--rate-type`, `--payment-frequency`, `--desc`. `event` accepts `--loan-id`, `--date`, `--type`, `--amount`, and optional allocation and voucher flags. `amortize` accepts `--period` and optional `--loan-id`, `--post-date`. For global flags and command-specific help, run `bus loans --help`.

### Files

Loan register and event datasets and their beside-the-table schemas in the loans area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `loans/` folder).

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

---

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

