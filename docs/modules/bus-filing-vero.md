## bus-filing-vero

### Name

`bus filing vero` — produce Vero export bundles.

### Synopsis

`bus filing vero [options]`

### Description

`bus filing vero` converts validated workspace data into Vero-ready export bundles with deterministic packaging, manifests, and hashes. It consumes VAT and report outputs and closed-period data. Invoked via `bus filing vero`.

### Options

Module-specific parameters are documented in the tool help. For global flags, run `bus filing vero --help`.

### Files

Reads validated datasets, VAT outputs, and report outputs; writes Vero-specific bundle directories or archives with manifests and hashes.

### Exit status

`0` on success. Non-zero on invalid usage or missing prerequisites.

### See also

Module SDD: [bus-filing-vero](../sdd/bus-filing-vero)  
Workflow: [VAT reporting and payment](../workflow/vat-reporting-and-payment)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing-prh">bus-filing-prh</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../integration/index">Integration and future interfaces</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
