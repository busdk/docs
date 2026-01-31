## bus-filing-prh

Bus Filing PRH converts validated workspace data into PRH export bundles,
applies PRH-specific packaging rules and metadata, and ensures bundle structure
is deterministic and auditable.

### How to run

Run `bus filing prh` … and use `--help` for
available subcommands and arguments.

### Data it reads and writes

It reads validated data, reports, and period close outputs, and writes
PRH-specific bundle directories or archives.

### Outputs and side effects

It produces PRH-ready export bundles with manifests and hashes, and emits
diagnostics for missing prerequisites or invalid formats.

### Integrations

It requires [`bus filing`](./bus-filing) orchestration and
[`bus period`](./bus-period) closed data, and consumes outputs
from [`bus reports`](./bus-reports) and
[`bus vat`](./bus-vat) as needed.

### See also

Repository: ./modules/bus-filing_prh

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-filing](./bus-filing) · **Index:** [Modules](./) · **Next:** [bus-filing-vero](./bus-filing-vero)
<!-- busdk-docs-nav end -->
