## bus-filing

### Name

`bus filing` — build deterministic filing bundles.

### Synopsis

`bus filing <command> [options]`

### Description

`bus filing` produces deterministic filing bundles from validated, closed-period workspace data. It assembles manifests and checksums and delegates target-specific formats to `bus filing prh` and `bus filing vero`. Use after validation and period close.

### Commands

- `prh` produces a PRH-ready export bundle (invokes the bus-filing-prh module).
- `vero` produces a Vero-ready export bundle (invokes the bus-filing-vero module).
- `tax-audit-pack` produces a tax-audit filing bundle.

### Options

Target-specific parameters are documented in each module’s help. For global flags and command-specific help, run `bus filing --help`.

### Files

Reads validated datasets and reports; writes export bundle directories or archives (datasets, schemas, manifests). Does not modify canonical workspace datasets.

### Exit status

`0` on success. Non-zero on invalid usage or missing prerequisites (e.g. unvalidated or open period).

### See also

Module SDD: [bus-filing](../sdd/bus-filing)  
Compliance: [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)  
Workflow: [Year-end close (closing entries)](../workflow/year-end-close)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reports">bus-reports</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing-prh">bus-filing-prh</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
