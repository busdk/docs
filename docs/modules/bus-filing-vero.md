---
title: bus-filing-vero — produce Vero export bundles
description: bus filing vero produces Vero export bundles from the canonical VAT and report layout; no manual reports or vat directories needed.
---

## `bus-filing-vero` — produce Vero export bundles

### Synopsis

`bus filing vero [global flags] <subcommand> [subcommand flags]`

`bus-filing-vero [global flags] <subcommand> [subcommand flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus filing vero` converts validated workspace data into Vero-ready export bundles.
Packaging, manifests, and hashes are deterministic.

It consumes VAT/report outputs and closed-period data.
Path resolution uses module path accessors, so `reports/` and `vat/` folders are optional.

### Prerequisites

Export expects canonical workspace layout from upstream modules.
Run `bus config init`, `bus invoices init`, and `bus vat init` so VAT datasets/schemas exist at workspace root.

When bundle requires reports, generate them first.
No manual `reports/` or `vat/` directory creation is required.

Each CSV input requires beside-the-CSV schema.
Both `name.schema.json` and `name.csv.schema.json` are accepted.

### Options

Use standard global flags (see [Standard global flags](../cli/global-flags)).
Global flags appear before subcommand.

Subcommands:
- `export` with `--bundle <dir>` and optional `--dry-run`
- `verify` with `--bundle <dir>`

Defaults:
- bundle path: `filing/vero/bundle`
- format: `tsv`

Unknown subcommands/flags and empty `--bundle` are usage errors (`2`).
For full flag matrix and edge-case semantics, see [Module SDD: bus-filing-vero](../sdd/bus-filing-vero).

### Files

Reads validated datasets and VAT and report outputs from the canonical layout, with root-level VAT files by default per [bus vat](./bus-vat). `vat/` and `reports/` are optional and are used only when the path accessors return those locations. For each CSV input, the command accepts `name.schema.json` and `name.csv.schema.json`. Writes Vero-specific bundle directories or archives with manifests and hashes.

### Examples

```bash
bus filing vero export --bundle filing/vero/2026-01
bus filing vero verify --bundle filing/vero/2026-01
bus filing vero export --bundle filing/vero/2026-01 --format json --output ./out/vero-export.json
bus filing vero export --bundle filing/vero/2026-01 --dry-run
```

### Exit status

`0` on success. Non-zero on invalid usage or missing prerequisites.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus filing-vero export --bundle filing/vero/2026-02
filing-vero export --bundle filing/vero/2026-02

# same as: bus filing-vero verify --bundle filing/vero/2026-02 --format tsv
filing-vero verify --bundle filing/vero/2026-02 --format tsv
```


### Development state

**Value promise:** Produce Vero (Finnish Tax Administration) export bundles from closed-period data when invoked as the `vero` target of [bus-filing](./bus-filing).

**Use cases:** [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

**Completeness:** 50% — export and verify from fixture verified by e2e and unit tests; full Vero-filing journey step blocked by [bus-filing](./bus-filing) bundle contract.

**Use case readiness:** Finnish bookkeeping and tax-audit compliance: 50% — produce and verify Vero bundle from fixture; FR-VERO-002, NFR-VERO-001, NFR-VERO-002 verified by e2e and unit tests; full journey blocked by [bus-filing](./bus-filing) bundle contract.

**Current:** Export/verify flows, deterministic bundle behavior, schema/path conventions, and global-flag handling are test-verified.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-filing-vero](../sdd/bus-filing-vero).

**Planned next:** Continue bundle-contract alignment with [bus-filing](./bus-filing) for the full end-to-end filing journey.

**Blockers:** [bus-filing](./bus-filing) bundle contract must be stable for target consumption.

**Depends on:** [bus-filing](./bus-filing) (invoked as target); [bus-period](./bus-period) closed; [bus-vat](./bus-vat) and reports module for input layout (canonical VAT and report paths).

**Used by:** [bus-filing](./bus-filing) invokes this module when the target is vero.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing-prh">bus-filing-prh</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../integration/index">Integration and future interfaces</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module CLI reference: bus-vat](../modules/bus-vat)
- [VAT area (layout)](../layout/vat-area)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [Module SDD: bus-filing-vero](../sdd/bus-filing-vero)
- [Workflow: VAT reporting and payment](../workflow/vat-reporting-and-payment)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
