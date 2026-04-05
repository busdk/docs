---
title: bus-journal — post and query ledger journal entries
description: bus journal is the authoritative ledger module for BusDK. Use it to add balanced entries, list and inspect journal rows, materialize opening balances, import legacy journals, and automate classified or template-based postings.
---

## `bus-journal` — post and query ledger journal entries

`bus journal` maintains the authoritative double-entry ledger for a workspace. If a row should become accounting, this is the module that writes it.

Use it for manual entries, corrective updates to earlier transactions, neutral journal-row listing, replay-safe automated postings, account activity review, legacy journal import, and bank-driven posting automation. Stored journal rows carry separate voucher-level, posting-level, and row-level text fields plus audit metadata for creation and latest update. Closed or locked periods are rejected automatically.
For exact operator syntax, use `bus journal --help` for the command family and `bus journal <subcommand> --help` for the structured local contract. This is especially useful for the shorthand-heavy `assert`, `list`, and `match` surfaces.

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

Replay imported history while preserving original audit metadata and row descriptions:

```bash
bus journal add \
  --date 2026-01-31 \
  --desc "Imported receipt" \
  --created-at 2025-12-31T09:00:00Z \
  --updated-at 2026-01-02T14:15:16Z \
  --created-by legacy-import \
  --updated-by legacy-import \
  --debit 6300=24.00=Office supplies \
  --credit 1910=24.00=Card payment
```

Correct one earlier transaction in place while keeping `created_*` history and restamping `updated_*`:

```bash
bus journal update \
  --transaction-id tx-123 \
  --date 2026-02-01 \
  --desc "Corrected receipt booking" \
  --updated-by meri \
  --debit 6310=24.00=Software \
  --credit 1910=24.00=Card payment
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
bus journal assert match count 1999 --unsettled --older-than 7d --as-of 2026-01-31 0
bus journal --format tsv account-activity 1910 --period 2026 --opening exclude
```

List actual journal rows in neutral review formats:

```bash
bus journal list
bus journal list --format csv 1700
bus journal list --fields posting_date,entry_id,account_id,account_name,counterpart_accounts,counterpart_account_names,amount,debit,credit,voucher_description,posting_description,row_description,updated_by 1700
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
`bus journal add --date <YYYY-MM-DD> --desc <text> [--posting-desc <text>] [--sort-accounts] [--source-id <key>] [--source-object <kind:id>] [--source-kind <kind>] [--source-entry <n>] [--external-source-ref <text>] [--source-link <kind=value|short>] [--vat-treatment <code>] [--source-voucher-context <text>] [--source-voucher-number <text>] [--source-voucher-label <text>] [--source-voucher-group <token>] [--if-missing] --debit <account>=<amount>[=<row-text>] ... --credit <account>=<amount>[=<row-text>] ... [-C <dir>] [global flags]`  
`bus journal opening (--from <workspace> | --balances-file <csv>) --as-of <YYYY-MM-DD> --date <YYYY-MM-DD> [--desc <text>] [--source-id <key>] [--if-missing] [-C <dir>] [global flags]`  
`bus journal add --bulk-in <file|-> [-C <dir>] [global flags]`  
`bus journal balance [--as-of <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus journal balance assert <account> <YYYY-MM-DD> <amount> [-C <dir>] [global flags]`  
`bus journal balance assert <account> --as-of <YYYY-MM-DD> --amount <amount> [-C <dir>] [global flags]`  
`bus journal balance assert opening <account> <YYYY-MM-DD> <amount> [-C <dir>] [global flags]`  
`bus journal balance assert <account> opening <YYYY-MM-DD> <amount> [-C <dir>] [global flags]`  
`bus journal balance assert <account> <YYYY-MM-DD> --opening <amount> [--closing <amount>] [-C <dir>] [global flags]`  
`bus journal assert <balance|debit|credit|net> ... [-C <dir>] [global flags]`  
`bus journal assert match count <match-selector...> <expected-count> [-C <dir>] [global flags]`  
`bus journal assert match distinct source-id count <match-selector...> <expected-count> [-C <dir>] [global flags]`  
`bus journal assert match each source-id <debit|credit|net> <match-selector...> <expected-amount> [-C <dir>] [global flags]`  
`bus journal account-activity <code[,code]|code...> [--period <id>] [--from-date <YYYY-MM-DD>] [--to-date <YYYY-MM-DD>] [--opening <all|exclude|only>] [--top <n>] [-C <dir>] [global flags]`  
`bus journal list [<selector...>] [--unsettled] [--older-than <Nd|Nw>] [--as-of <YYYY-MM-DD>] [--fields <name[,name...]>] [-C <dir>] [global flags]`  
`bus journal match <selector...> [--unsettled] [--older-than <Nd|Nw>] [--as-of <YYYY-MM-DD>] [apply [--print|--dry-run] [--desc <text>] <target|split...>] [-C <dir>] [global flags]`  
`bus journal import --profile <name> --file <path> [--source-id-from <column>] [--external-source-ref-from <column>] [--source-link-from <kind=column>] [--source-voucher-context-from <column>] [--source-voucher-number-from <column>] [--source-voucher-label-from <column>] [--source-voucher-group-from <column>] [--mapping-profile <name>] [--header-row <n>] [--map <field=header|column>] ... [-C <dir>] [global flags]`  
`bus journal classify <subcommand> ...`  
`bus journal template <post|apply> ...`

Command-local help is available for the practical operator entrypoints too, for example `bus journal add --help`, `bus journal assert --help`, `bus journal list --help`, and `bus journal match --help`.

### What most users do with this module

`init` prepares the journal datasets and schemas.

`add` is the normal command for manual postings and for simple automation. It requires a balanced debit and credit set, and it also requires `--desc` even when the intended voucher description is explicitly empty as `--desc ""`. Bus Journal now keeps three description levels separate: `--desc` / `--description` is the voucher description, `--posting-desc` is the posting description shared by the transaction rows, and the optional third segment in `ACCOUNT=AMOUNT=ROW_DESCRIPTION` is the row-level description for one debit or credit line. This fixes the earlier misleading behavior where every debit and credit row inherited the same one shared text. Description text is preserved as UTF-8 through both journal storage and `list` output, so ordinary non-ASCII bookkeeping text such as Finnish `ä/ö/å`, check marks, and other Unicode letters can be used directly. When the row description contains spaces or punctuation-like text, prefer quoting the whole posting token, for example `--credit '3001=924.10=Muistutusmaksut Reminder Fee -rivistä'`. Simple unquoted multi-word continuation remains accepted for compatibility when no continuation word looks like a flag, for example `--debit 1911=924.10=Asiakkaan maksusuoritus pankkiin`, but replay files should use the quoted form whenever free text might be mistaken for option syntax. Repeated `--debit` and `--credit` flags are written to the journal in exactly the same order they were given on the command line, so replayed manual postings preserve the intended line sequence by default. When the same content needs one stable account-oriented order instead, `--sort-accounts` changes only that one posting surface and stores the final lines in stable resolved-account-code order after account-name resolution. `--source-id` stays the canonical Bus duplicate-source and traceability key, while `--external-source-ref` preserves one separate legacy or migration pointer when parity review still needs the original foreign-system reference. The workspace-level setting `busdk.accounting_entity.duplicate_source_policy` is now the canonical Bus duplicate-source policy surface. New workspaces default to `strict`: if the same `(source_system, source_id)` already exists in that period, the command fails non-zero and prints a deterministic conflict diagnostic. Setting the workspace policy to `if_missing` turns the same duplicate into a deterministic replay-safe skip, and `--if-missing` remains the explicit per-run no-op override for intentional reruns. For manual replay, the command also accepts shorthand business-object references such as `--source-object sales_invoice:s6203 --source-entry 2` or `--source-id s6203 --source-kind sales_invoice --source-entry 2`. Workspace `source_kinds` infers kinds from the same operator-defined prefixes across `--source-object`, plain `--source-id`, and `--source-link`, so defaults like `s -> sales_invoice`, `p -> purchase_invoice`, and `b -> bank_row` make `--source-object s6203 --source-entry 2` resolve to `sales_invoice:s6203:journal:2`, plain `--source-id s6203` resolve to `sales_invoice:s6203`, plain `--source-id b24915` resolve to `bank_row:24915`, and `--source-link b24889` resolve to `bank_row=bank_row:24889`. The same kind-driven surface also gives a Bus-native close-source identifier for explicit year-end result postings: `--source-id FY2025 --source-kind closing-result` stores `close-result:FY2025:1`. The preferred form is the shorter `closing-result` plus a user-defined fiscal-period or close identifier, but equivalent separator aliases such as `closing_result` are accepted too; the older alias `closing_current_year_result` remains accepted only for compatibility. The same close-source meaning is shared across Bus modules, so replayed close rows behave consistently in posting, reporting, and validation flows instead of depending on module-specific prefix interpretation. When one posting needs more than one machine-readable source relation, repeat `--source-link kind=value`. If the posting has no canonical source invoice line but it still needs an explicit tax-treatment marker, store that separately with `--vat-treatment` instead of hiding it inside the free-text description. If the upstream document has its own visible voucher notation, preserve it separately with `--source-voucher-context`, `--source-voucher-number`, `--source-voucher-label`, and `--source-voucher-group` instead of replacing canonical Bus IDs.

`opening` is the year-split helper. It turns prior end-of-period balance-sheet balances into ordinary stored journal rows in the new workspace instead of relying on hidden cross-workspace lookups.

`balance` is the fastest way to answer “what is the balance as of this date?”. The same command also supports replay-time balance assertions without shell glue. Use `bus journal balance assert 1910 2026-03-31 1240.55` or keep the date and amount explicit with flags. When replay needs day-start versus day-end checks, use the explicit opening/closing forms such as `bus journal balance assert opening 1910 2026-01-01 190.00` or `bus journal balance assert 1910 2026-03-31 --opening 190.00 --closing 93.85`. The legacy closing-only form prints one TSV row with `account_id`, `as_of`, `expected`, `observed`, and `status`. Explicit opening/closing forms print `account_id`, `as_of`, `point`, `expected`, `observed`, and `status`, one row per requested point in opening-then-closing order. The command returns `0` on an exact match and returns `1` when any requested saldo differs.

`assert` is the first-class journal-total assertion surface. Use it when the thing you want to prove is not “one account balance as-of one date” but a filtered journal subset total. Supported measures are `balance`, `debit`, `credit`, `net`, `match count`, grouped `match distinct source-id count`, and grouped `match each source-id debit|credit|net`. `balance` uses the simple form `bus journal assert balance 1910 2026-03-31 1240.55`. `debit`, `credit`, and `net` accept one positional date or date range plus explicit filters such as `--account`, `--source-id`, `--source-id-prefix`, `--desc`, and `--desc-prefix`, and they also accept comparison operators like `>=1000` and `<=0`. `match count` reuses the plain `match` selector surface directly and compares the resulting row count, which makes control checks such as `bus journal assert match count 1999 --unsettled --older-than 7d --as-of 2026-01-31 0` first-class without shell pipelines. The grouped forms use that same selector-side language but then group the matched rows by explicit `source-id` / `source_id`: `match distinct source-id count` compares how many grouped source ids exist, and `match each source-id debit|credit|net` checks that every grouped source satisfies one expected amount or comparison. The output stays one deterministic TSV row with `measure`, `scope`, `expected`, `observed`, and `status`.

`account-activity` is the best review tool when one account needs explanation. It shows movement rows together with voucher, source, and external parity-reference identifiers. Exact account codes can be given either with `--account` or positionally, so `bus journal account-activity 1700` and `bus journal account-activity --account 1700` mean the same thing.

`list` is the neutral journal-row listing surface. Use it when you want actual journal rows without `match apply` semantics and without the account-review framing of `account-activity`. It accepts the same exact account selectors, `x`-wildcards, regex matchers, `--unsettled`, `--older-than`, `--as-of`, `--fields`, and `-f/--format tsv|csv|json` choices as plain `match`, but it also works with no selector at all so the whole journal can be listed deterministically. Selectors and matchers choose transactions, and the output then expands every selected transaction into all of its stored journal rows, one operation per line and in stored row order. By default you now see a narrower operator-facing subset: `posting_date`, `transaction_id`, `entry_id`, `entry_sequence`, `voucher_id`, `account_id`, `account_name`, `counterpart_accounts`, `counterpart_account_names`, signed `amount`, `debit`, `credit`, `voucher_description`, `posting_description`, `row_description`, and `source_id`. Use `-F all` / `--fields all` to restore the full raw row shape including `period`, `currency`, `source_system`, `dimensions`, `description`, audit columns, links, VAT treatment, and flattened `source_voucher.*` fields. Signed `amount` uses debit-positive / credit-negative semantics. Field selection also supports the short alias `-F`, and the format flag may appear after the subcommand, so `bus journal list 1700 -f csv -F posting_date,account_id,account_name,counterpart_accounts,counterpart_account_names,voucher_description,posting_description,row_description` is valid.

`match` is the quick Unix-style selector/apply tool for existing journal rows. Use it first as a grep-like surface that lists matching entries from one or many exact or wildcard account selectors, and then add `apply` when you want Bus to create one deterministic reclassification posting per matched row. Selector-side filters also support `--unsettled`, `--older-than <Nd|Nw>`, and `--as-of <YYYY-MM-DD>`. `--unsettled` is intended for clearing-account work: a row stays selected only when the same account still lacks a later opposite-sign row with the same absolute amount by the chosen as-of date. That makes queries such as “show everything on 1999 that is still unresolved and older than a week” deterministic and replay-friendly. Without `apply`, use global `-f/--format tsv` (default), `csv`, or `json` to choose the output shape. Plain match rows now default to a narrower review subset: `posting_date`, `transaction_id`, `entry_id`, `voucher_id`, `account_id`, `account_name`, `counterpart_accounts`, `counterpart_account_names`, signed `amount`, `debit`, `credit`, `voucher_description`, `posting_description`, and `row_description`. Use `--fields field1,field2,...` or `-F ...` for a custom subset, or `-F all` / `--fields all` to restore the full review row shape including `period`, `entry_sequence`, `transaction_debits`, `transaction_credits`, `source_id`, `external_source_ref`, and compatibility field `description`. The same format flag also works after the subcommand, so `bus journal match 1700 -f csv -F posting_date,account_id,account_name,amount,voucher_description,posting_description,row_description` is valid. `apply --print` prints the exact `bus journal add` commands it would create and does not use `--format`; `apply --dry-run` validates the same path without writing anything and can emit TSV, CSV, or JSON status rows with signed `amount`, where debit is positive and credit is negative. `--desc` may be a template and interpolate values from the matched row with placeholders such as `%(desc)`, `%(voucher_description)`, `%(posting_description)`, `%(row_description)`, `%(account_id)`, `%(transaction_id)`, `%(voucher_id)`, `%(posting_date)`, `%(amount)`, `%(debit)`, `%(credit)`, `%(source_id)`, and `%(external_source_ref)`.

`assert` is the human-readable control surface for replay-side audit checks. `assert balance` remains the strict account plus cut-off-date check, while `assert debit`, `assert credit`, and `assert net` accept one day token such as `2026-01-31` or one inclusive range such as `2026-01-01..2026-03-31`, together with explicit subset filters like `--account`, `--source-id`, `--source-id-prefix`, `--desc`, and `--desc-prefix`. `assert match count` is the selector-side sibling: it accepts the same exact accounts, `x`-wildcards, regex matchers, `--unsettled`, `--older-than`, and `--as-of` controls as `bus journal match`, but returns an assertion result against the matched-row count instead of the row list. The grouped siblings `assert match distinct source-id count` and `assert match each source-id debit|credit|net` use that same selector side too, but then group the matched rows by explicit `source-id` / `source_id` so receipt-split and replay-coverage audits can stay Bus-native. Expected values can be exact amounts or explicit comparisons such as `>=1000` and `<=0.00`; `match count` and `match distinct source-id count` expect integer counts such as `0` or `>=1`. The easiest way to learn the exact accepted shorthand in place is `bus journal assert --help`.

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

These commands use [Standard global flags](../cli/global-flags). The most important detail is that `--format` is mainly for `balance`, `account-activity`, `list`, and plain `match`. `list` and plain `match` support `tsv` (default), `csv`, and `json`, and `--fields` lets you choose which review columns are shown. `list` now includes a signed `amount` column by default, and `match apply --dry-run` uses the same format choices for its status rows, including signed `amount`. `match apply --print` always prints `bus journal add` commands instead. Commands that write data, such as `add`, `match apply`, `import`, `classify apply`, and `template post`, are about mutation rather than report formatting.

Use `--dry-run` before `opening`, `match apply`, `import`, `classify apply`, `template post`, or `template apply` when you want to preview the effect without writing.

For the full option list, run `bus journal --help`. For exact `assert`, `list`, and `match` shorthand, use `bus journal assert --help`, `bus journal list --help`, and `bus journal match --help`.

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
journal --format tsv account-activity 1910 --period 2026

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
