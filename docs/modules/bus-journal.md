---
title: bus-journal — post and query ledger journal entries
description: bus journal is the authoritative ledger module for BusDK. Use it to add balanced entries, materialize opening balances, inspect account activity, match and apply deterministic reclassifications, import legacy journals, and automate classified or template-based postings.
---

## `bus-journal` — post and query ledger journal entries

`bus journal` maintains the authoritative double-entry ledger for a workspace. If a row should become accounting, this is the module that writes it.

Use it for manual entries, replay-safe automated postings, account activity review, legacy journal import, and bank-driven posting automation. Closed or locked periods are rejected automatically.

### Common tasks

Create the journal datasets:

```bash
bus journal init
```

Post one simple manual entry:

```bash
bus journal add \
  --date 2026-01-31 \
  --desc "January rent" \
  --debit 6300=1200.00 \
  --credit 1910=1200.00
```

Store one posting in stable account order instead of raw CLI order:

```bash
bus journal add \
  --date 2026-01-31 \
  --desc "Sorted replay posting" \
  --sort-accounts \
  --debit "Office Supplies"=24.00 \
  --credit 3000=12.00 \
  --debit 1910=12.00
```

Post replay-safe automation rows with a stable source key:

```bash
bus journal add \
  --date 2026-01-31 \
  --desc "Payroll January" \
  --debit 5000=4200.00 \
  --credit 1910=4200.00 \
  --source-system payroll \
  --source-id 2026-01 \
  --source-link payroll_run=2026-01 \
  --if-missing
```

Materialize one explicit opening entry from a prior workspace:

```bash
bus journal opening \
  --from ../fy2025 \
  --as-of 2025-12-31 \
  --date 2026-01-01
```

Check balances, assert journal totals, and inspect one account’s movement:

```bash
bus journal balance --as-of 2026-03-31
bus journal balance assert 1910 2026-03-31 1240.55
bus journal assert debit 2026-01-01..2026-03-31 --source-id-prefix receipt-split:meri: '>=1000'
bus journal --format tsv account-activity --account 1910 --period 2026 --opening exclude
```

Match journal rows and preview one deterministic reclassification:

```bash
bus journal match 1999 --unsettled --older-than 7d --as-of 2026-01-31
bus journal match 1910 "K-Market|Prisma" apply --print --desc "Kauppakuitti %(desc)" 50%=4000 50%=4010 1790
```

Import a legacy ledger CSV through a deterministic import profile:

```bash
bus journal import \
  --profile fi-ledger-legacy \
  --file ./legacy/daybook.csv \
  --source-id-from "Source Ref" \
  --external-source-ref-from "Legacy Ref" \
  --source-link-from "invoice_id=Invoice ID" \
  --source-voucher-number-from "Invoice Number" \
  --source-voucher-label-from "Invoice Label"
```

Generate bank-driven posting proposals and then apply them:

```bash
bus journal -o ./out/journal-proposals.tsv classify bank --profile ./rules.yml
bus journal classify apply --proposal ./out/journal-proposals.tsv
```

Post recurring VAT-split entries from a template:

```bash
bus journal template post \
  --template-file ./templates.yml \
  --template office_24 \
  --date 2026-01-15 \
  --gross 124.00 \
  --desc "Office supplies"
```

### Synopsis

`bus journal init [-C <dir>] [global flags]`  
`bus journal add --date <YYYY-MM-DD> --desc <text> [--sort-accounts] [--source-id <key>] [--source-object <kind:id>] [--source-kind <kind>] [--source-entry <n>] [--external-source-ref <text>] [--source-link <kind=value|short>] [--vat-treatment <code>] [--source-voucher-context <text>] [--source-voucher-number <text>] [--source-voucher-label <text>] [--source-voucher-group <token>] [--if-missing] --debit <account>=<amount> ... --credit <account>=<amount> ... [-C <dir>] [global flags]`  
`bus journal opening (--from <workspace> | --balances-file <csv>) --as-of <YYYY-MM-DD> --date <YYYY-MM-DD> [--desc <text>] [--source-id <key>] [--if-missing] [-C <dir>] [global flags]`  
`bus journal add --bulk-in <file|-> [-C <dir>] [global flags]`  
`bus journal balance [--as-of <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus journal balance assert <account> <YYYY-MM-DD> <amount> [-C <dir>] [global flags]`  
`bus journal balance assert <account> --as-of <YYYY-MM-DD> --amount <amount> [-C <dir>] [global flags]`  
`bus journal balance assert opening <account> <YYYY-MM-DD> <amount> [-C <dir>] [global flags]`  
`bus journal balance assert <account> opening <YYYY-MM-DD> <amount> [-C <dir>] [global flags]`  
`bus journal balance assert <account> <YYYY-MM-DD> --opening <amount> [--closing <amount>] [-C <dir>] [global flags]`  
`bus journal assert <balance|debit|credit|net> ... [-C <dir>] [global flags]`  
`bus journal account-activity --account <code[,code]> [--period <id>] [--from-date <YYYY-MM-DD>] [--to-date <YYYY-MM-DD>] [--opening <all|exclude|only>] [--top <n>] [-C <dir>] [global flags]`  
`bus journal match <selector...> [--unsettled] [--older-than <Nd|Nw>] [--as-of <YYYY-MM-DD>] [apply [--print|--dry-run] [--desc <text>] <target|split...>] [-C <dir>] [global flags]`  
`bus journal import --profile <name> --file <path> [--source-id-from <column>] [--external-source-ref-from <column>] [--source-link-from <kind=column>] [--source-voucher-context-from <column>] [--source-voucher-number-from <column>] [--source-voucher-label-from <column>] [--source-voucher-group-from <column>] [--mapping-profile <name>] [--header-row <n>] [--map <field=header|column>] ... [-C <dir>] [global flags]`  
`bus journal classify <subcommand> ...`  
`bus journal template <post|apply> ...`

Command-local help is available too, for example `bus journal add --help`.

### What most users do with this module

`init` prepares the journal datasets and schemas.

`add` is the normal command for manual postings and for simple automation. It requires a balanced debit and credit set, and it also requires `--desc` even when the intended description is explicitly empty as `--desc ""`. Repeated `--debit` and `--credit` flags are written to the journal in exactly the same order they were given on the command line, so replayed manual postings preserve the intended line sequence by default. When the same content needs one stable account-oriented order instead, `--sort-accounts` changes only that one posting surface and stores the final lines in stable resolved-account-code order after account-name resolution. `--source-id` stays the canonical Bus duplicate-source and traceability key, while `--external-source-ref` preserves one separate legacy or migration pointer when parity review still needs the original foreign-system reference. The workspace-level setting `busdk.accounting_entity.duplicate_source_policy` is now the canonical Bus duplicate-source policy surface. New workspaces default to `strict`: if the same `(source_system, source_id)` already exists in that period, the command fails non-zero and prints a deterministic conflict diagnostic. Setting the workspace policy to `if_missing` turns the same duplicate into a deterministic replay-safe skip, and `--if-missing` remains the explicit per-run no-op override for intentional reruns. For manual replay, the command also accepts shorthand business-object references such as `--source-object sales_invoice:s6203 --source-entry 2` or `--source-id s6203 --source-kind sales_invoice --source-entry 2`. Workspace `source_kinds` infers kinds from the same operator-defined prefixes across `--source-object`, plain `--source-id`, and `--source-link`, so defaults like `s -> sales_invoice`, `p -> purchase_invoice`, and `b -> bank_row` make `--source-object s6203 --source-entry 2` resolve to `sales_invoice:s6203:journal:2`, plain `--source-id s6203` resolve to `sales_invoice:s6203`, plain `--source-id b24915` resolve to `bank_row:24915`, and `--source-link b24889` resolve to `bank_row=bank_row:24889`. The same kind-driven surface also gives a Bus-native close-source identifier for explicit year-end result postings: `--source-id FY2025 --source-kind closing-result` stores `close-result:FY2025:1`. The preferred form is the shorter `closing-result` plus a user-defined fiscal-period or close identifier, but equivalent separator aliases such as `closing_result` are accepted too; the older alias `closing_current_year_result` remains accepted only for compatibility. When one posting needs more than one machine-readable source relation, repeat `--source-link kind=value`. If the posting has no canonical source invoice line but it still needs an explicit tax-treatment marker, store that separately with `--vat-treatment` instead of hiding it inside the free-text description. If the upstream document has its own visible voucher notation, preserve it separately with `--source-voucher-context`, `--source-voucher-number`, `--source-voucher-label`, and `--source-voucher-group` instead of replacing canonical Bus IDs.

`opening` is the year-split helper. It turns prior end-of-period balance-sheet balances into ordinary stored journal rows in the new workspace instead of relying on hidden cross-workspace lookups.

`balance` is the fastest way to answer “what is the balance as of this date?”. The same command also supports replay-time balance assertions without shell glue. Use `bus journal balance assert 1910 2026-03-31 1240.55` or keep the date and amount explicit with flags. When replay needs day-start versus day-end checks, use the explicit opening/closing forms such as `bus journal balance assert opening 1910 2026-01-01 190.00` or `bus journal balance assert 1910 2026-03-31 --opening 190.00 --closing 93.85`. The legacy closing-only form prints one TSV row with `account_id`, `as_of`, `expected`, `observed`, and `status`. Explicit opening/closing forms print `account_id`, `as_of`, `point`, `expected`, `observed`, and `status`, one row per requested point in opening-then-closing order. The command returns `0` on an exact match and returns `1` when any requested saldo differs.

`assert` is the first-class journal-total assertion surface. Use it when the thing you want to prove is not “one account balance as-of one date” but a filtered journal subset total. Supported measures are `balance`, `debit`, `credit`, and `net`. `balance` uses the simple form `bus journal assert balance 1910 2026-03-31 1240.55`. `debit`, `credit`, and `net` accept one positional date or date range plus explicit filters such as `--account`, `--source-id`, `--source-id-prefix`, `--desc`, and `--desc-prefix`, and they also accept comparison operators like `>=1000` and `<=0`. The output is one deterministic TSV row with `measure`, `scope`, `expected`, `observed`, and `status`.

`account-activity` is the best review tool when one account needs explanation. It shows movement rows together with voucher, source, and external parity-reference identifiers.

`match` is the quick Unix-style selector/apply tool for existing journal rows. Use it first as a grep-like surface that lists matching entries from one or many exact or wildcard account selectors, and then add `apply` when you want Bus to create one deterministic reclassification posting per matched row. Selector-side filters also support `--unsettled`, `--older-than <Nd|Nw>`, and `--as-of <YYYY-MM-DD>`. `--unsettled` is intended for clearing-account work: a row stays selected only when the same account still lacks a later opposite-sign row with the same absolute amount by the chosen as-of date. That makes queries such as “show everything on 1999 that is still unresolved and older than a week” deterministic and replay-friendly. `apply --print` prints the exact `bus journal add` commands it would create; `apply --dry-run` validates the same path without writing anything. `--desc` may be a template and interpolate values from the matched row with placeholders such as `%(desc)`, `%(account_id)`, `%(transaction_id)`, `%(voucher_id)`, `%(posting_date)`, `%(amount)`, `%(debit)`, `%(credit)`, `%(source_id)`, and `%(external_source_ref)`.

`import` is for legacy journal or day-book migration work where you want deterministic mapping rather than hand-posting old history. `--external-source-ref-from` preserves one dedicated foreign-system reference, `--source-link-from kind=column` preserves extra structured legacy references such as invoice ids or bank-row pointers alongside canonical `source_id`, and the `--source-voucher-*-from` selectors preserve the imported source-facing voucher notation for later review output.

`classify` is the bank-to-journal workflow. It can generate proposals from bank rows, apply approved proposals, learn candidate rules from earlier postings, and handle suspense or loan-split flows.

`template` is the recurring-entry helper. It is useful when one kind of supplier charge repeats with the same VAT logic over and over again.

### Important behavior

Entries must be balanced. If debit and credit totals differ, the command fails.

Accounts can be given as codes or as account names that already exist in the chart of accounts.

Visible voucher numbers follow the shared workspace ID policy when configured in [bus-config](./bus-config). Without a workspace override, the default visible voucher format is a yearly sequence such as `V-2026-000001`, while technical transaction IDs remain machine-friendly.

`--source-id` plus optional `--source-system` makes replay-safe posting possible. The workspace-level duplicate-source policy is `busdk.accounting_entity.duplicate_source_policy`, and its canonical values are `strict` and `if_missing`. New workspaces default to `strict`, while `if_missing` makes duplicate source keys skip deterministically across journal posting flows without adding `--if-missing` to every command. `--if-missing` remains the explicit per-run override on top of that shared policy. When manual work should stay shorter than the final stored key, use `--source-object <kind:id>` or `--source-id <id> --source-kind <kind>` together with `--source-entry <n>`. Workspace `busdk.accounting_entity.source_kinds` can infer the kind from the same shorthand prefixes across source objects, plain source ids, and source links. New workspaces default that map to `s -> sales_invoice`, `p -> purchase_invoice`, and `b -> bank_row`, so `--source-id s6203` resolves to `sales_invoice:s6203`, `--source-id b24915` resolves to `bank_row:24915`, and `--source-link b24889` resolves to `bank_row=bank_row:24889`. The built-in kind `closing-result` gives explicit year-end close postings one stable Bus-native id form, so `--source-id FY2025 --source-kind closing-result` resolves to `close-result:FY2025:1` instead of forcing operators to handcraft a longer free-form string. Equivalent separator aliases such as `closing_result` are accepted too, while the old alias `closing_current_year_result` remains accepted for compatibility. `--external-source-ref` keeps one separate migration/parity reference without changing that canonical duplicate key, repeatable `--source-link` values preserve additional structured audit pointers without changing it either, and `--source-voucher-*` fields keep imported human-facing document numbering visible for review reports without replacing canonical `voucher_id`.

`opening` carries forward only `asset`, `liability`, and `equity` accounts. The carried balances must sum to zero. Rerunning the same opening source follows the same workspace duplicate-source policy as `add`; `--if-missing` stays the explicit per-run no-op override.

The workspace storage format is handled automatically. Users normally do not need different journal commands for CSV and `PCSV-1`.

### A simple monthly flow

One common flow looks like this:

```bash
bus journal add --date 2026-01-31 --desc "Insurance" --debit 6400=350.00 --credit 1910=350.00
bus journal balance --as-of 2026-01-31
bus reports trial-balance --as-of 2026-01-31
```

If the journal lines come from bank automation instead of manual entry, the flow often becomes:

```bash
bus bank import --file ./statements/2026-01.csv
bus journal -o ./out/proposals.tsv classify bank --profile ./rules.yml
bus journal classify apply --proposal ./out/proposals.tsv
# rerun-safe no-op only when explicitly requested
bus journal classify apply --proposal ./out/proposals.tsv --if-missing
bus reports day-book --period 2026-01 --format pdf -o ./out/day-book-2026-01.pdf
```

### Output and flags

These commands use [Standard global flags](../cli/global-flags). The most important detail is that `--format` is mainly for `balance`, `account-activity`, and plain `match`. Commands that write data, such as `add`, `match apply`, `import`, `classify apply`, and `template post`, are about mutation rather than report formatting.

Use `--dry-run` before `opening`, `match apply`, `import`, `classify apply`, `template post`, or `template apply` when you want to preview the effect without writing.

For the full option list, run `bus journal --help`.

### Files

This module owns `journals.csv`, period journal files such as `journal-2026.csv`, and journal dimension tables at the workspace root.

### Exit status

`0` on success. Non-zero on invalid usage, unbalanced postings, schema violations, missing accounts, or attempts to post into closed or locked periods.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus journal add --date 2026-01-31 --desc "Bank fee" --debit 6570=12.50 --credit 1910=12.50
journal add --date 2026-01-31 --desc "Bank fee" --debit 6570=12.50 --credit 1910=12.50

# same as: bus journal --format tsv account-activity --account 1910 --period 2026
journal --format tsv account-activity --account 1910 --period 2026

# same as: bus journal template apply --template-file ./templates.yml --bank-csv ./bank.csv
journal template apply --template-file ./templates.yml --bank-csv ./bank.csv
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-invoices">bus-invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bank">bus-bank</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Module reference: bus-journal](../modules/bus-journal)
- [Module reference: bus-config](../modules/bus-config)
- [Module reference: bus-reports](../modules/bus-reports)
- [Workflow: Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Design: Double-entry ledger](../design-goals/double-entry-ledger)
