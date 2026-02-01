## bus-filing-prh

Bus Filing PRH converts validated workspace data into PRH export bundles,
applies PRH-specific packaging rules and metadata, and ensures bundle structure
is deterministic and auditable.

### How to run

Run `bus filing prh` … and use `--help` for
available subcommands and arguments.

### Subcommands

Bus Filing PRH does not define additional subcommands. It is invoked as `bus filing prh` with flags.

### Data it reads and writes

It reads validated data, reports, and period close outputs, and writes
PRH-specific bundle directories or archives.

### Outputs and side effects

It produces PRH-ready export bundles with manifests and hashes, and emits
diagnostics for missing prerequisites or invalid formats.

### Finnish compliance responsibilities

Bus Filing PRH MUST include the required financial statements and supporting datasets in PRH bundles and preserve audit-trail references back to journal postings, vouchers, and evidence. It MUST keep bundle contents deterministic with manifests and hashes so the filing export remains verifiable.

### Integrations

It requires [`bus filing`](./bus-filing) orchestration and
[`bus period`](./bus-period) closed data, and consumes outputs
from [`bus reports`](./bus-reports) and
[`bus vat`](./bus-vat) as needed.

### See also

Repository: https://github.com/busdk/bus-filing-prh

For compliance context and closing package expectations, see [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit) and [Year-end close (closing entries)](../workflow/year-end-close).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing">bus-filing</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing-vero">bus-filing-vero</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
