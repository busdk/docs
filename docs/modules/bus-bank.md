---
title: bus-bank — import and review bank transactions
description: bus bank imports bank statements into canonical workspace datasets, lets you inspect imported rows, and helps you verify coverage and statement totals before posting.
---

## `bus-bank` — import and review bank transactions

`bus bank` is where bank data usually enters a BusDK workspace. It turns source files into normalized bank rows, lets you inspect the imported result, and gives you control reports for backlog, posting coverage, and statement balance verification.

This module does not create journal entries by itself. After import, the next steps are usually [bus-reconcile](./bus-reconcile), [bus-journal](./bus-journal), or both.

### Common tasks

Create the bank datasets for a new workspace:

```bash
bus bank init
```

Import a statement file and list the imported rows for one month:

```bash
bus bank import --file ./statements/2026-01.csv
bus bank list --month 2026-01
```

Import a year of ERP-exported bank history with a deterministic profile:

```bash
bus bank import \
  --profile ./profiles/erp-bank.yaml \
  --source ./exports/bank-2024.tsv \
  --year 2024
```

Find bank rows that are still not matched or posted:

```bash
bus bank backlog --month 2026-01 --detail
bus bank --format json -o ./out/bank-coverage-2026.json coverage --year 2026
bus bank control --month 2026-01 --account acct-1
```

Parse and verify a statement before trusting the closing balance:

```bash
bus bank -f json statement parse --file ./statements/2026-01.pdf \
  -o ./out/statement-2026-01.json
bus bank statement verify --statement ./out/statement-2026-01.json \
  --fail-if-diff-over 0.01
```

Teach BusDK how to normalize one counterparty name and extract invoice hints from bank messages:

```bash
bus bank config counterparty add \
  --canonical "Sendanor Oy" \
  --alias "SENDANOR" \
  --alias "Sendanor Oy"

bus bank config extractors add \
  --field invoice_number_hint \
  --pattern 'Viite[: ]+([0-9]+)' \
  --source message
```

### Synopsis

`bus bank init [-C <dir>] [global flags]`  
`bus bank import --file <path> [-C <dir>] [global flags]`  
`bus bank import --profile <path|erp-tsv> --source <path> [--year <YYYY>] [--fail-on-ambiguity] [-C <dir>] [global flags]`  
`bus bank list [--month <YYYY-MM>] [--from <YYYY-MM-DD>] [--to <YYYY-MM-DD>] [--counterparty <id>] [--invoice-ref <ref>] [-C <dir>] [global flags]`  
`bus bank backlog [--month <YYYY-MM>] [--from <YYYY-MM-DD>] [--to <YYYY-MM-DD>] [--detail] [--fail-on-backlog] [--max-unposted <n>] [-C <dir>] [global flags]`  
`bus bank coverage --year <YYYY> [-C <dir>] [global flags]`  
`bus bank control [--month <YYYY-MM> | --year <YYYY> | --from <YYYY-MM-DD> --to <YYYY-MM-DD>] [--account <id>] [-C <dir>] [global flags]`  
`bus bank statement extract --file <path> [options] [-C <dir>] [global flags]`  
`bus bank statement parse --file <path> [options] [-C <dir>] [global flags]`  
`bus bank statement verify [--statement <parsed.json|attachment-id>] [--year <YYYY>] [--account <id>] [--fail-if-diff-over <amount>] [-C <dir>] [global flags]`  
`bus bank config <subcommand> ...`

### Import modes

Use `import --file` when you already have a bank statement or a normalized source file for one import run.

Use `import --profile --source` when you are migrating history or importing provider-specific exports repeatedly. The profile keeps the mapping rules versioned and reusable.

If the input is messy ERP TSV, the built-in `erp-tsv` profile is the fast path:

```bash
bus bank import --profile erp-tsv --source ./exports/bank.tsv --year 2024 --fail-on-ambiguity
```

### The commands most people use after import

`list` is the day-to-day inspection command. It prints deterministic rows in a stable order, and it is usually the first thing to run after import.

`backlog` tells you which rows are still unreconciled. This is the best command when you want to answer “what is still left to process?”.

`coverage` goes one step further and tells you whether bank rows are linked into reconciliation records, journal records, both, or neither.

`control` is the accountant-facing period control view. It combines statement continuity, checkpoint balance math, bank movement totals, unresolved backlog, and coverage counts into one deterministic report.

`statement extract`, `statement parse`, and `statement verify` are the lower-level checkpoint path. Use them when you need to inspect or troubleshoot the underlying statement evidence itself.

### Counterparties and reference hints

Two small configuration tables can make bank automation much better over time.

Counterparty aliases let you normalize many name variants to one canonical name, which makes rules and reports easier to read.

Reference extractors pull structured hints such as `erp_id` or `invoice_number_hint` out of free-text message or reference fields. These hints are especially useful for [bus-reconcile](./bus-reconcile).

### Typical workflow

For a normal monthly flow, many users do something close to this:

```bash
bus bank import --file ./statements/2026-01.csv
bus bank list --month 2026-01
bus bank backlog --month 2026-01 --detail
bus reconcile -o ./out/reconcile-proposals.tsv propose
bus reconcile apply --in ./out/reconcile-proposals.tsv
bus bank coverage --year 2026
bus bank control --month 2026-01 --account acct-1
```

### Files

`bus bank` owns `bank-imports.csv`, `bank-transactions.csv`, and the statement checkpoint dataset. It can also create optional configuration tables for counterparty aliases, reference extractors, and statement-extract profiles.

### Output and flags

These commands use [Standard global flags](../cli/global-flags). In practice:

`list` is most often used as plain terminal output. `backlog`, `coverage`, `control`, and `statement parse` are the commands that most often benefit from `-f json` and `-o`.

When one month or year has more than one statement account in scope, `control` requires `--account` so the result stays deterministic. If only one statement account overlaps the selected scope, the command resolves it automatically.

Use `--dry-run` when you want to preview an import or configuration change without writing datasets.

For the full command and flag matrix, run `bus bank --help`.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus bank import --file ./statements/2026-01.csv
bank import --file ./statements/2026-01.csv

# same as: bus bank backlog --month 2026-01 --detail
bank backlog --month 2026-01 --detail

# same as: bus bank --format json coverage --year 2026
bank --format json coverage --year 2026
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-journal">bus-journal</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-reconcile">bus-reconcile</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Bank transactions](../master-data/bank-transactions/index)
- [Module reference: bus-bank](../modules/bus-bank)
- [Module reference: bus-reconcile](../modules/bus-reconcile)
- [Module reference: bus-journal](../modules/bus-journal)
- [Workflow: Import bank transactions and apply payment](../workflow/import-bank-transactions-and-apply-payment)
- [Workflow: Deterministic reconciliation proposals and batch apply](../workflow/deterministic-reconciliation-proposals-and-batch-apply)
