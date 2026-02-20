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

Command names follow [CLI command naming](../cli/command-naming).

`bus filing` orchestrates deterministic filing bundle creation from validated, closed-period data.
It delegates target-specific formats to `bus filing prh` and `bus filing vero`.
Use after validation and period close.

### Commands

`prh` produces a PRH-ready export bundle by invoking [bus-filing-prh](./bus-filing-prh). `vero` produces a Vero-ready export bundle by invoking [bus-filing-vero](./bus-filing-vero). `tax-audit-pack` produces a tax-audit filing bundle.

### Options

Target-specific parameters are documented in each target module help.
Global flags are defined in [Standard global flags](../cli/global-flags).
For command-specific help, run `bus filing --help`.

### Files

Reads validated datasets and reports; writes export bundle directories or archives (datasets, schemas, manifests). Does not modify canonical workspace datasets.

### Examples

```bash
bus filing prh
bus filing vero
bus filing tax-audit-pack --format json --output ./out/tax-audit-pack.json
bus filing -C ./workspace prh --output ./out/prh-run.tsv
```

### Exit status

`0` on success. Non-zero on invalid usage or missing prerequisites (e.g. unvalidated or open period).


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus filing prh
filing prh

# same as: bus filing vero --format json
filing vero --format json

# same as: bus filing tax-audit-pack --output ./out/tax-audit-pack.tsv
filing tax-audit-pack --output ./out/tax-audit-pack.tsv
```


### Development state

**Value promise:** Orchestrate filing by delegating to target executables (e.g. [bus-filing-prh](./bus-filing-prh), [bus-filing-vero](./bus-filing-vero)) so users can run `bus filing <target>` and produce PRH/Vero bundles from closed-period data.

**Use cases:** [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

**Completeness:** 60% (Stable) — delegation to all three targets (prh, vero, tax-audit-pack), list, global flags, args pass-through, workdir/env, and exit code propagation are verified by e2e and unit tests; bundle assembly (FR-FIL-001) is not yet implemented or documented as delegated (PLAN).

**Use case readiness:** Finnish bookkeeping and tax-audit compliance: 60% — user can run `bus filing prh` / `vero` / `tax-audit-pack` with correct delegation; bundle delivery depends on targets and stable contract.

**Current:** Delegation to `prh`, `vero`, and `tax-audit-pack`, plus global-flag and exit propagation behavior, are test-verified.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-filing](../sdd/bus-filing).

**Planned next:** Clarify or implement FR-FIL-001 (bundle assembly from validated closed-period data or document delegation to targets); define parameter set for tax-audit-pack (OQ-FIL-001). Both advance Finnish bookkeeping and tax-audit compliance when bundle contract is stable.

**Blockers:** Stable bundle contract needed for filing targets to consume.

**Depends on:** [bus-period](./bus-period), [bus-journal](./bus-journal) (closed-period, validated data).

**Used by:** Invokes [bus-filing-prh](./bus-filing-prh) and [bus-filing-vero](./bus-filing-vero) as targets when users run `bus filing <target>`.

See [Development status](../implementation/development-status).

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
- [Finnish balance sheet and income statement regulation](../compliance/fi-balance-sheet-and-income-statement-regulation)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
