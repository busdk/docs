## bus-filing-prh

### Name

`bus filing prh` — produce PRH export bundles.

### Synopsis

`bus filing prh [options]`

### Description

`bus filing prh` converts validated workspace data into PRH-ready export bundles with deterministic packaging, manifests, and hashes. It is invoked via `bus filing prh` and consumes outputs from `bus reports`, `bus vat`, and closed-period data.

### Options

Module-specific parameters are documented in the tool help. For global flags, run `bus filing prh --help`.

### Files

Reads validated datasets and report outputs; writes PRH-specific bundle directories or archives with manifests and hashes.

### Exit status

`0` on success. Non-zero on invalid usage or missing prerequisites.

### See also

Module SDD: [bus-filing-prh](../sdd/bus-filing-prh)  
Compliance: [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing">bus-filing</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing-vero">bus-filing-vero</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
