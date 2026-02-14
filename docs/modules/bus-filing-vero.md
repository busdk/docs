---
title: bus-filing-vero — produce Vero export bundles
description: bus filing vero converts validated workspace data into Vero-ready export bundles with deterministic packaging, manifests, and hashes.
---

## `bus-filing-vero` — produce Vero export bundles

### Synopsis

`bus filing vero [module-specific parameters] [-C <dir>] [-o <file>] [--color <mode>] [-v] [-q] [-h] [-V]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus filing vero` converts validated workspace data into Vero-ready export bundles with deterministic packaging, manifests, and hashes. It consumes VAT and report outputs and closed-period data. Invoked via `bus filing vero`.

### Options

Module-specific parameters are documented in the tool help. Global flags are defined in [Standard global flags](../cli/global-flags). For the full list, run `bus filing vero --help`.

### Files

Reads validated datasets, VAT outputs, and report outputs; writes Vero-specific bundle directories or archives with manifests and hashes.

### Exit status

`0` on success. Non-zero on invalid usage or missing prerequisites.

### Development state

**Value:** Produce Vero (Finnish Tax Administration) export bundles from closed-period data when invoked as the `vero` target of [bus-filing](./bus-filing).

**Completeness:** 40% (Meaningful task, partial verification) — bundle workflows are implemented; unit tests cover app, bundle, and output. No e2e.

**Current:** Unit tests in `internal/app/app_test.go`, `internal/bundle/bundle_test.go`, and `internal/output/` prove app and bundle behavior. No e2e against fixture; source refs (FR-VERO-002) and prerequisites diagnostics are in PLAN.

**Planned next:** E2e against fixture; FR-VERO-002 source refs in bundle; deterministic diagnostics for missing prerequisites.

**Blockers:** bus-filing bundle contract must be stable for target consumption.

**Depends on:** [bus-filing](./bus-filing) (invoked as target); [bus-period](./bus-period) closed.

**Used by:** [bus-filing](./bus-filing) invokes this module when the target is vero.

See [Development status](../implementation/development-status).

---

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

