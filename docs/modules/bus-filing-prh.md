---
title: bus-filing-prh — produce PRH export bundles
description: bus filing prh converts validated workspace data into PRH-ready export bundles with deterministic packaging, manifests, and hashes.
---

## `bus-filing-prh` — produce PRH export bundles

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

**Value promise:** Produce PRH (Finnish Business Register) export bundles from closed-period data when invoked as the `prh` target of [bus-filing](./bus-filing).

**Use cases:** [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

**Completeness:** 50% — Validate and bundle from a fixture workspace are verified by e2e and unit tests; PRH-required content and SBR taxonomy would complete the filing journey.

**Use case readiness:** Finnish bookkeeping and tax-audit compliance: 50% — validate and bundle verified by e2e; PRH content convention and SBR taxonomy would unlock PRH filing.

**Current:** E2e `tests/e2e_bus_filing-prh.sh` proves help, version, subcommand help, invalid usage (quiet+verbose, unknown `--color`/`--format`), `--` stops parsing, validate success, bundle with fixture (manifest, iXBRL, inputs), `--output`, `--quiet`, `--format json`, `--dry-run`, `-C`, and errors on stderr. Unit tests in `internal/app/run_test.go`, `internal/bundle/bundle_test.go`, `internal/bundle/sanitize_test.go`, and `internal/cli/flags_test.go` prove run dispatch and global flags, deterministic bundle and validation gating, path sanitization, and flag parsing.

**Planned next:** PRH-required content in bundles (journal, reports, voucher refs, attachments metadata) per FR-PRH-002; full PRH SBR taxonomy in iXBRL; README links. Advances Finnish bookkeeping and tax-audit compliance.

**Blockers:** [bus-filing](./bus-filing) bundle contract must be stable for target consumption.

**Depends on:** [bus-filing](./bus-filing) (invoked as target); [bus-period](./bus-period) closed.

**Used by:** [bus-filing](./bus-filing) invokes this module when the target is prh.

See [Development status](../implementation/development-status).

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

