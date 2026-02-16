---
title: bus-entities — manage counterparty reference data
description: bus entities maintains counterparty reference datasets with stable entity identifiers used by invoices, bank imports, reconciliation, and other modules.
---

## `bus-entities` — manage counterparty reference data

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

`entities.csv` and its beside-the-dataset schema `entities.schema.json` live in the [accounts area](../layout/accounts-area) at the workspace root, alongside other canonical datasets such as `accounts.csv`. The module does not create or use a dedicated `entities/` subdirectory; layout follows the [minimal workspace baseline](../layout/minimal-workspace-baseline) and matches other BusDK modules. Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### Development state

**Value promise:** Maintain counterparty (entity) master data as schema-validated workspace tables so invoices, bank, and loans can reference stable entity identifiers.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Sale invoicing (sending invoices to customers)](../workflow/sale-invoicing), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 50% — Init, add, and list are verified by e2e and unit tests; user can complete the counterparty master-data step for accounting, sale invoicing, and payroll.

**Use case readiness:** Accounting workflow: 50% — init, add, list verified; user can define counterparties. Sale invoicing: 50% — init, add, list verified; user can define customers. Finnish payroll handling: 50% — init, add, list and `--id`/`--name` verified by e2e; user can define party references for employees.

**Current:** Verified in `tests/e2e_bus_entities.sh` and `internal/app/run_test.go`: help, version, global-flag errors (quiet+verbose, color, format, chdir), init (create CSV and schema, idempotent warning, partial-state fail, dry-run no write), add (missing-param exit 2, full add, duplicate reject, `--id`/`--name` aliases, dry-run no append), list (empty and populated TSV, `--output`, `--quiet`, `-f tsv`, `--`, `-vv`, `--no-color`). Flag parsing in `internal/cli/flags_test.go`; schema and foreign-key validation in `internal/entities/validator_test.go`.

**Planned next:** Expose Go library path accessors for entities dataset and schema (NFR-ENT-002, IF-ENT-002) so other modules obtain paths from this module; no use-case-specific next.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-invoices](./bus-invoices) and [bus-loans](./bus-loans) reference entity data; [bus-bank](./bus-bank) and [bus-reconcile](./bus-reconcile) use counterparty identifiers.

See [Development status](../implementation/development-status).

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

