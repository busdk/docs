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

**Completeness:** 50% (Primary journey) — export and verify from a minimal workspace are verified by e2e and unit tests; source refs (FR-VERO-002) and prerequisites diagnostics would complete the Vero filing step.

**Use case readiness:** Finnish bookkeeping and tax-audit compliance: 50% — user can produce and verify a Vero bundle from a fixture workspace; source refs and period/filing diagnostics planned.

**Current:** E2e `tests/e2e_bus_filing-vero.sh` proves help, version, export, verify, global flags (-C, -o, -f, --color, -q, --, --dry-run), prerequisite checks (missing dir, required directory), and bundle layout (manifest, checksums, data). Unit tests `internal/app/app_test.go`, `internal/bundle/bundle_test.go`, and `internal/cli/flags_test.go` prove Run behavior, bundle export/verify/dry-run and validation (missing schema, conflict markers), and flag parsing (-vv, --, help).

**Planned next:** FR-VERO-002 source refs in bundle (voucher/posting identifiers); path resolution via bus-vat and reports library accessors so export works after standard init (see [module SDD](../sdd/bus-filing-vero)); deterministic diagnostics for period-closed or filing-orchestration state (PLAN.md). Advances Finnish bookkeeping and tax-audit compliance.

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

