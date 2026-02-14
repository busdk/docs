---
title: bus-filing-prh — produce PRH export bundles
description: bus filing prh converts validated workspace data into PRH-ready export bundles with deterministic packaging, manifests, and hashes.
---

## bus-filing-prh

### Name

`bus filing prh` — produce PRH export bundles.

### Synopsis

`bus filing prh [module-specific parameters] [-C <dir>] [-o <file>] [--color <mode>] [-v] [-q] [-h] [-V]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus filing prh` converts validated workspace data into PRH-ready export bundles with deterministic packaging, manifests, and hashes. It is invoked via `bus filing prh` and consumes outputs from `bus reports`, `bus vat`, and closed-period data.

### Options

Module-specific parameters are documented in the tool help. Global flags are defined in [Standard global flags](../cli/global-flags). For the full list, run `bus filing prh --help`.

### Files

Reads validated datasets and report outputs; writes PRH-specific bundle directories or archives with manifests and hashes.

### Exit status

`0` on success. Non-zero on invalid usage or missing prerequisites.

### Development state

**Value:** Produce PRH (Finnish Business Register) export bundles from closed-period data when invoked as the `prh` target of [bus-filing](./bus-filing).

**Completeness:** 40% (Meaningful task, partial verification) — bundle and validate workflows are implemented; unit tests cover run, bundle, and sanitize. No e2e.

**Current:** Unit tests in `internal/app/run_test.go`, `internal/bundle/bundle_test.go`, and `internal/bundle/sanitize_test.go` prove run dispatch, bundle building, and sanitization. No e2e against a fixture workspace; PRH content and SBR taxonomy are in PLAN.

**Planned next:** PRH-required content in bundles; full PRH SBR taxonomy in iXBRL; e2e against fixture; README links.

**Blockers:** bus-filing bundle contract must be stable for target consumption.

**Depends on:** [bus-filing](./bus-filing) (invoked as target); [bus-period](./bus-period) closed.

**Used by:** [bus-filing](./bus-filing) invokes this module when the target is prh.

See [Development status](../implementation/development-status).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing">bus-filing</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing-vero">bus-filing-vero</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [Module SDD: bus-filing-prh](../sdd/bus-filing-prh)
- [Compliance: Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)

