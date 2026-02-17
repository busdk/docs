---
title: bus-filing-vero — produce Vero export bundles
description: bus filing vero produces Vero export bundles from the canonical VAT and report layout; no manual reports or vat directories needed.
---

## `bus-filing-vero` — produce Vero export bundles

### Synopsis

`bus filing vero [module-specific parameters] [-C <dir>] [-o <file>] [--color <mode>] [-v] [-q] [-h] [-V]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus filing vero` converts validated workspace data into Vero-ready export bundles with deterministic packaging, manifests, and hashes. It consumes VAT and report outputs and closed-period data in the layout produced by [bus vat](./bus-vat) and the reports module; no manual creation of `reports/` or `vat/` directories or other preprocessing is required. Invoked via `bus filing vero`.

### Prerequisites

Export expects the canonical workspace layout produced by the upstream modules. Run `bus config init`, `bus invoices init`, and `bus vat init` so that VAT datasets and their schemas exist at the workspace root as defined by [bus vat](./bus-vat). When the bundle requires report outputs, generate them with the reports module first. The tool resolves paths to VAT and report files via those modules’ APIs; you do not need to create or populate `reports/` or `vat/` yourself.

### Options

Module-specific parameters are documented in the tool help. Global flags are defined in [Standard global flags](../cli/global-flags). For the full list, run `bus filing vero --help`.

### Files

Reads validated datasets and VAT and report outputs from the canonical layout (workspace root for VAT data, per [bus vat](./bus-vat) and the reports module). Writes Vero-specific bundle directories or archives with manifests and hashes.

### Exit status

`0` on success. Non-zero on invalid usage or missing prerequisites.

### Development state

**Value promise:** Produce Vero (Finnish Tax Administration) export bundles from closed-period data when invoked as the `vero` target of [bus-filing](./bus-filing).

**Use cases:** [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

**Completeness:** 50% — export and verify from fixture verified by e2e and unit tests; full Vero-filing journey step blocked by [bus-filing](./bus-filing) bundle contract.

**Use case readiness:** Finnish bookkeeping and tax-audit compliance: 50% — produce and verify Vero bundle from fixture; FR-VERO-002, NFR-VERO-001, NFR-VERO-002 verified by e2e and unit tests; full journey blocked by [bus-filing](./bus-filing) bundle contract.

**Current:** E2e `tests/e2e_bus_filing-vero.sh` verifies help, version, export, verify, global flags (-C, -o, -f, --color, -q, --, --dry-run), invalid usage, bundle layout (manifest, checksums, data, source_refs, voucher_posting_refs), root VAT path and both schema conventions, verify success, --output/--format json, -vv, deterministic export, --dry-run, --no-color, quiet and quiet+--output. Unit tests: `internal/app/app_test.go` (help/version ignore args, quiet+verbose conflict, invalid color/format, -C, --output write/truncate, quiet suppresses output and output file, requires .git); `internal/bundle/bundle_test.go` (export/verify/dry-run, missing schema, manifest source_refs and voucher_posting_refs, bus-vat schema naming, works without reports or vat dirs, prereq checker, verify mismatch/success); `internal/cli/flags_test.go` (-vv, --, help); `internal/paths/paths_test.go` (VAT paths at root, ignores subdirs, both schema conventions).

**Planned next:** Apply DOCS_UPDATE in docs repo (SDD Risks, pre-export layout, OQ-VERO-001 per PLAN.md). Advances Finnish bookkeeping and tax-audit compliance when docs align.

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

- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [Module SDD: bus-filing-vero](../sdd/bus-filing-vero)
- [Workflow: VAT reporting and payment](../workflow/vat-reporting-and-payment)

