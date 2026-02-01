## bus-filing-vero

Bus Filing VERO generates
Vero-ready tax filing bundles for use through
`bus filing vero`.

Bus Filing Vero converts validated workspace data into Vero export bundles,
applies Vero-specific packaging rules and metadata, and ensures bundle
structure is deterministic and auditable.

### How to run

Run `bus filing vero` … and use `--help`
for available subcommands and arguments.

### Subcommands

Bus Filing Vero does not define additional subcommands. It is invoked as `bus filing vero` with flags.

### Data it reads and writes

It reads validated data, reports, and VAT outputs, and writes Vero-specific
bundle directories or archives.

### Outputs and side effects

It produces Vero-ready export bundles with manifests and hashes, and emits
diagnostics for missing prerequisites or invalid formats.

### Finnish compliance responsibilities

Bus Filing Vero MUST generate VAT filing bundles that retain references to the underlying postings, vouchers, and VAT summaries, and it MUST keep the electronic export demonstrably traceable for tax-audit review.

### Integrations

It requires [`bus filing`](./bus-filing) orchestration and
[`bus period`](./bus-period) closed data, and consumes VAT
outputs from [`bus vat`](./bus-vat) and reports from
[`bus reports`](./bus-reports).

### See also

Repository: https://github.com/busdk/bus-filing-vero

For VAT filing workflow and compliance context, see [VAT reporting and payment](../workflow/vat-reporting-and-payment) and [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing-prh">bus-filing-prh</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../integration/index">BusDK Design Spec: Integration and future interfaces</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
