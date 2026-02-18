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

**Completeness:** High — Validate and bundle are verified by e2e and unit tests. Bundles include PRH-required content (journal, reports, voucher references, attachments metadata) per FR-PRH-002 and full PRH SBR taxonomy in iXBRL (balance sheet, income statement, cash flow statement, notes placeholder). Parameter set is stable (OQ-PRH-001 closed). Remaining work: extended bundle metadata and any future filing-target spec updates; see module README and roadmap.

**Use case readiness:** Finnish bookkeeping and tax-audit compliance: High — validate, bundle, PRH-required content (FR-PRH-002), and PRH SBR taxonomy in iXBRL are implemented and covered by e2e; module is ready for PRH filing within the current bundle contract. Depends on bus-filing bundle contract stability.

**Current:** OQ-PRH-001 is closed; FR-PRH-002 and full PRH SBR iXBRL are implemented and covered by e2e. E2e `tests/e2e_bus_filing-prh.sh` proves help, version, subcommand help, invalid usage (quiet+verbose, unknown `--color`/`--format`), `--` stops parsing, validate success, bundle with fixture (manifest, iXBRL, inputs), `--output`, `--quiet`, `--format json`, `--dry-run`, `-C`, and errors on stderr. Unit tests in `internal/app/run_test.go`, `internal/bundle/bundle_test.go`, `internal/bundle/sanitize_test.go`, and `internal/cli/flags_test.go` prove run dispatch and global flags, deterministic bundle and validation gating, path sanitization, and flag parsing.

**Planned next:** Extended bundle metadata when filing-target specs are available; README and doc links alignment; any follow-ups from bus-filing bundle contract. FR-PRH-002 and full PRH SBR iXBRL are implemented.

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

