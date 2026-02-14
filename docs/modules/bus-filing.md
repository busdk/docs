---
title: bus-filing — build deterministic filing bundles
description: bus filing produces deterministic filing bundles from validated, closed-period workspace data.
---

## `bus-filing` — build deterministic filing bundles

### Synopsis

`bus filing prh [module-specific options] [-C <dir>] [global flags]`  
`bus filing vero [module-specific options] [-C <dir>] [global flags]`  
`bus filing tax-audit-pack [module-specific options] [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus filing` produces deterministic filing bundles from validated, closed-period workspace data. It assembles manifests and checksums and delegates target-specific formats to `bus filing prh` and `bus filing vero`. Use after validation and period close.

### Commands

- `prh` produces a PRH-ready export bundle (invokes the bus-filing-prh module).
- `vero` produces a Vero-ready export bundle (invokes the bus-filing-vero module).
- `tax-audit-pack` produces a tax-audit filing bundle.

### Options

Target-specific parameters are documented in each module’s help. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus filing --help`.

### Files

Reads validated datasets and reports; writes export bundle directories or archives (datasets, schemas, manifests). Does not modify canonical workspace datasets.

### Exit status

`0` on success. Non-zero on invalid usage or missing prerequisites (e.g. unvalidated or open period).

### Development state

**Value:** Orchestrate filing by delegating to target executables (e.g. bus-filing-prh, bus-filing-vero) so users can run `bus filing <target>` and produce PRH/Vero bundles from closed-period data.

**Completeness:** 50% (Primary journey) — delegation to targets and list_targets are implemented; unit tests cover run, list_targets, and flags. Bundle assembly and pass-through args are not fully verified.

**Current:** Unit tests in `internal/busfiling/run_test.go`, `internal/busfiling/list_targets_test.go`, and `internal/cli/flags_test.go` prove run, list targets, and flag parsing. No e2e; bundle assembly (FR-FIL-001) and args pass-through are in PLAN.

**Planned next:** Bundle assembly from validated closed-period data; parameter set for tax-audit-pack; document targets; test args pass-through and tax-audit-pack delegation.

**Blockers:** Stable bundle contract needed for filing targets to consume.

**Depends on:** [bus-period](./bus-period), [bus-journal](./bus-journal) (closed-period, validated data).

**Used by:** Invokes [bus-filing-prh](./bus-filing-prh) and [bus-filing-vero](./bus-filing-vero) as targets when users run `bus filing <target>`.

See [Development status](../implementation/development-status).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-pdf">bus-pdf</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing-prh">bus-filing-prh</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Module SDD: bus-filing](../sdd/bus-filing)
- [Compliance: Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
- [Workflow: Year-end close (closing entries)](../workflow/year-end-close)

