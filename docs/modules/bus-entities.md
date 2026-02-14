---
title: bus-entities — manage counterparty reference data
description: bus entities maintains counterparty reference datasets with stable entity identifiers used by invoices, bank imports, reconciliation, and other modules.
---

## bus-entities

### Name

`bus entities` — manage counterparty reference data.

### Synopsis

`bus entities init [-C <dir>] [global flags]`  
`bus entities list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus entities add --id <entity-id> --name <display-name> [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus entities` maintains counterparty reference datasets with stable entity identifiers used by invoices, bank imports, reconciliation, and other modules. Entity data is schema-validated and append-only for auditability.

### Commands

- `init` creates the baseline entity datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `list` prints the entity registry in stable identifier order.
- `add` adds a new entity record.

### Options

`add` accepts `--id <entity-id>` and `--name <display-name>`. `list` has no module-specific filters. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus entities --help`.

### Write path and field coverage

The CLI surface is intentionally small. `bus entities add` writes the stable entity identifier and display name, and it refuses to write rows that would violate schema or invariants.

If your `entities.csv` schema includes additional identity or bookkeeping columns (for example business identifiers, VAT numbers, country codes, payment identifiers, or default handling fields), those fields are currently edited by updating `entities.csv` directly and then validating the workspace with `bus validate`. This makes the “owner write path” explicit: `bus entities` owns the dataset, but not every column is maintained through flags.

### Files

`entities.csv` and its beside-the-dataset schema `entities.schema.json` live in the [accounts area](../layout/accounts-area) at the workspace root, alongside other canonical datasets such as `accounts.csv`. The module does not create or use a dedicated `entities/` subdirectory; layout follows the [minimal workspace baseline](../layout/minimal-workspace-baseline) and matches other BusDK modules.

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### Development state

Init, list, and add work today; e2e tests cover init and list. Planned next: align `add` with SDD (e.g. `--id` / `--name` or document current `--entity-id` / `--display-name`); interactive and scripting parity (prompt when TTY, usage error otherwise); align public surface with docs (document or remove `validate` and `update`). [bus-loans](./bus-loans) validates counterparty IDs when reference datasets exist. See [Development status](../implementation/development-status).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-accounts">bus-accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-period">bus-period</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounts area](../layout/accounts-area)
- [Minimal workspace baseline](../layout/minimal-workspace-baseline)
- [Owns master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module SDD: bus-entities](../sdd/bus-entities)
- [Data organization: Data package organization](../data/data-package-organization)

