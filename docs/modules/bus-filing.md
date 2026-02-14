---
title: bus-filing — build deterministic filing bundles
description: bus filing produces deterministic filing bundles from validated, closed-period workspace data.
---

## bus-filing

### Name

`bus filing` — build deterministic filing bundles.

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

Delegation to target executables (e.g. bus-filing-prh, bus-filing-vero) works today. Invokes [bus-filing-prh](./bus-filing-prh) and [bus-filing-vero](./bus-filing-vero) as targets; users run `bus filing <target>` to build bundles. Planned next: clarify or implement FR-FIL-001 (bundle assembly from validated closed-period data); define parameter set for tax-audit-pack and targets; document standard targets and link module docs; test that args after target token are passed through; test tax-audit-pack delegation. Depends on [bus-period](./bus-period) and [bus-journal](./bus-journal). See [Development status](../implementation/development-status).

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

