---
title: bus-config — create and update workspace configuration
description: bus config stores workspace identity, VAT, reporting, ID generation, and storage defaults in datapackage.json for the whole workspace.
---

## `bus-config` — create and update workspace configuration

`bus config` writes the workspace-wide settings that other BusDK modules read automatically. In practice this means company or personal-workspace identity, fiscal year, VAT defaults, reporting defaults, voucher numbering policy, and optional storage defaults in `datapackage.json`.

The same file also carries shared storage policy for modules that use `bus-data`. Top-level `_pcsv` sets the workspace default. Optional `busdk.storage.modules.<module>` entries override that workspace default for one module. A resource-level `_pcsv` override inside the resource descriptor is still the most specific layer. When none of those layers is present, the default is ordinary CSV.

For Finnish reporting, the same configuration surface also stores `reporting_context.fi`. That entity-context block now includes `evidence-pack` defaults, so [bus-reports](./bus-reports) can pick a default package profile and deterministic filename-template rules without repo-local cleanup scripts.

Use this module near the start of a new workspace, and later whenever workspace-level settings change.

The shared numbering policy now has its own first-class CLI surface. `bus config id-generation` lets you inspect and edit one ID kind or one conditional series at a time instead of forcing every small numbering change through shell-quoted nested JSON.

### Common tasks

Create the workspace configuration with the most common Finnish accounting defaults in one command:

```bash
bus config init \
  --business-name "Example Oy" \
  --business-id 1234567-8 \
  --business-form oy \
  --base-currency EUR \
  --fiscal-year-start 2026-01-01 \
  --fiscal-year-end 2026-12-31 \
  --vat-registered true \
  --vat-reporting-period monthly \
  --vat-timing performance
```

Update only the fields that changed. `bus config set` never rewrites unrelated settings:

```bash
bus config set \
  --business-name "Example Group Oy" \
  --vat-reporting-period quarterly \
  --reporting-standard fi-pma
```

Set a clear yearly voucher numbering policy for the whole workspace:

```bash
bus config id-generation set-type voucher_id \
  --strategy sequence \
  --template V-{yyyy}-{inc}
```

Add an opening-entry series with its own visible prefix:

```bash
bus config id-generation add-series voucher_id \
  --name opening \
  --match source_prefix=opening \
  --template T-{inc} \
  --range 1:999:3
```

Explain which effective policy Bus would use for that selector:

```bash
bus config id-generation explain voucher_id --attr source_prefix=opening
```

Switch BusDK-owned datasets to `PCSV-1` while keeping the command surface the same:

```bash
bus config set \
  --storage-format PCSV-1 \
  --storage-padding-field _pad \
  --storage-record-bytes 256 \
  --storage-padding-char " "
```

Return to ordinary CSV later if you want:

```bash
bus config set storage-format csv
```

Override one module without changing the whole workspace:

```bash
bus config set \
  --storage-format PCSV-1 \
  --storage-padding-field _pad \
  --storage-record-bytes 256 \
  --module-storage-format bus-journal=csv
```

Set default `evidence-pack` profile and naming rules for the workspace:

```bash
bus config set \
  --evidence-pack-profile accountant \
  --evidence-pack-filename-template '*=pkg-{period}-{report}-{format}' \
  --evidence-pack-filename-template 'balance-sheet:pdf=approved-tase-{as_of}.pdf'
```

### Synopsis

`bus config init [common options] [-C <dir>] [global flags]`  
`bus config set [common options] [-C <dir>] [global flags]`  
`bus config set <key> <value>`  
`bus config id-generation <action> ...`

### What this module owns

`bus config` owns the workspace descriptor file `datapackage.json` at the workspace root. The most important subtree for BusDK users is `busdk.accounting_entity`.

Other modules read this file instead of asking you to repeat the same settings elsewhere. For example, [bus-vat](./bus-vat) reads VAT defaults from here, [bus-reports](./bus-reports) reads reporting defaults from here, and [bus-journal](./bus-journal) can read shared ID-generation policy from here.

This is also the right place for workspace-wide identity defaults that are not row-level facts. `busdk.accounting_entity.entity_kind` is now the canonical workspace-level tag for that purpose. Use `business` for company/statutory-default workspaces and `personal` for household or natural-person workspaces. Older workspaces that do not yet store the key still resolve as `business` by default.

### Commands

`init` creates `datapackage.json` when it does not exist yet, or adds the `busdk.accounting_entity` block when the file exists but does not contain it. If the block already exists, `init` prints a warning and leaves the file unchanged.

`set` updates an existing workspace configuration. You can use the batch form with several flags in one call, or the per-property form `bus config set <key> <value>` when you want to change exactly one field.

`id-generation` manages the shared numbering policy without forcing you to rewrite nested JSON. Use `list` and `show` when you want to inspect the current policy, `set-type` and `add-series` when you want to change one visible series or technical ID kind, `remove-series` when you want to delete one named selector, `validate` when you want a quick deterministic check, and `explain` when you want to see which effective policy Bus would resolve for one selector set.

### Settings most users care about

These are the settings most people configure first:

| What you are setting | Typical flags |
| --- | --- |
| Workspace kind | `--entity-kind` |
| Company identity | `--business-name`, `--business-id`, `--business-form` |
| Fiscal year | `--fiscal-year-start`, `--fiscal-year-end` |
| VAT defaults | `--vat-registered`, `--vat-reporting-period`, `--vat-timing`, `--vat-default-source`, `--vat-default-basis` |
| Report defaults | `--reporting-standard`, `--report-language`, `--income-statement-scheme`, `--comparatives`, `--presentation-unit` |
| Report signing | `--signature-date`, repeatable `--signature-signer` |
| Shared IDs | `--id-generation` |
| Storage defaults | `--storage-format`, `--storage-padding-field`, `--storage-record-bytes`, `--storage-padding-char`, `--module-storage-*` |

If you are working with Finnish statutory reports, the configuration can also carry taxonomy and filing-context defaults such as taxonomy family, taxonomy version, size class, and reporting scope. That keeps report generation consistent across the workspace.

### Typical update patterns

Use the per-property form when the change is small and obvious:

```bash
bus config set business-name "Example Oy"
bus config set entity-kind personal
bus config set vat-reporting-period yearly
bus config set signature-date 2026-03-31
```

Use the batch form when you want one auditable change that updates several related defaults together:

```bash
bus config set \
  --reporting-standard fi-kpa \
  --report-language fi \
  --income-statement-scheme by_nature \
  --comparatives true \
  --presentation-unit EUR \
  --signature-date 2026-03-31 \
  --signature-signer "Hallitus:board"
```

If you keep the ID policy in a separate JSON file, load it directly:

```bash
bus config set id-generation @./id_generation.json
```

`bus config init` now writes the shared default `id_generation` policy
explicitly into new workspaces. That default keeps visible accountant-facing
series such as `voucher_id`, `invoice_number`, and `loan_event_id` separate
from technical immutable IDs such as `transaction_id`, `entry_id`,
`attachment_id`, `bank_import_id`, and `bank_txn_id`. If you override only one
kind, Bus keeps the rest of the shared defaults in place instead of replacing
the entire policy tree. The raw JSON setter still works when you already keep a
reviewed policy file in version control, but day-to-day edits are usually
clearer through `bus config id-generation ...`.

### Notes that save time

`bus init` already runs `bus config init` for you. Use `bus config init` directly when you want to create or repair the configuration without running the rest of the workspace bootstrap.

`bus config set` changes only the values you pass. Running it with no property flags is a no-op.

Use `-C` when you want to edit another workspace without changing your shell directory:

```bash
bus config -C ./customer-a set --vat-reporting-period quarterly
```

These commands use [Standard global flags](../cli/global-flags). The most useful ones here are `-C` for workspace selection, `-q` and `-v` for output control, and `--output` if you are capturing diagnostics in automation. For the complete flag list, run `bus config --help`.

### Files

This module reads and writes `datapackage.json` at the workspace root. It does not write journal rows, account rows, or report mappings directly.

### Exit status

`0` on success. Invalid usage returns exit `2`. `set` returns non-zero if the workspace does not have `datapackage.json` or if `busdk.accounting_entity` is missing.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus config set --base-currency EUR --vat-registered true --vat-reporting-period monthly
config set --base-currency EUR --vat-registered true --vat-reporting-period monthly

# same as: bus config set reporting-standard fi-pma
config set reporting-standard fi-pma
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-init">bus-init</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-data">bus-data</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Workspace configuration (datapackage.json extension)](../data/workspace-configuration)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module reference: bus-config](../modules/bus-config)
- [Module reference: bus-journal](../modules/bus-journal)
- [Module reference: bus-reports](../modules/bus-reports)
- [Workflow: Initialize repo](../workflow/initialize-repo)
- [Finnish reporting taxonomy and account classification](../compliance/fi-reporting-taxonomy-and-account-classification)
- [Household accounting and personal-finance workspaces](../compliance/fi-household-accounting-and-personal-finance)
