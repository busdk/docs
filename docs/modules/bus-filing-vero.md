# bus-filing-vero

Bus Filing VERO generates
Vero-ready tax filing bundles for use through
`bus filing vero`.

Bus Filing Vero converts validated workspace data into Vero export bundles,
applies Vero-specific packaging rules and metadata, and ensures bundle
structure is deterministic and auditable.

## How to run

Run `bus filing vero` … and use `--help`
for available subcommands and arguments.

## Data it reads and writes

It reads validated data, reports, and VAT outputs, and writes Vero-specific
bundle directories or archives.

## Outputs and side effects

It produces Vero-ready export bundles with manifests and hashes, and emits
diagnostics for missing prerequisites or invalid formats.

## Integrations

It requires [`bus filing`](./bus-filing) orchestration and
[`bus period`](./bus-period) closed data, and consumes VAT
outputs from [`bus vat`](./bus-vat) and reports from
[`bus reports`](./bus-reports).

## See also

Repository: ./modules/bus-filing_vero

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-filing-prh](./bus-filing-prh) · **Index:** [BusDK Design Document](../index) · **Next:** —
<!-- busdk-docs-nav end -->
