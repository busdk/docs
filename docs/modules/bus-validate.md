## bus-validate

Bus Validate validates every CSV dataset against its Table Schema, verifies
cross-table integrity and double-entry invariants, and produces actionable
diagnostics for invalid workspaces.

### How to run

Run `bus validate` … and use `--help` for
available subcommands and arguments.

### Data it reads and writes

It reads all workspace datasets and schemas. It does not modify data unless a
command explicitly requests it.

### Outputs and side effects

It prints validation diagnostics and summaries, and returns non-zero exit codes
on validation failures.

### Integrations

It is used as a prerequisite for [`bus period`](./bus-period)
close and [`bus filing`](./bus-filing) exports, and enables CI
checks and scripted validations.

### See also

Repository: https://github.com/busdk/bus-validate

For shared validation architecture and CLI safety behavior, see [Shared validation layer](../spec/architecture/shared-validation-layer) and [Validation and safety checks](../spec/cli/validation-and-safety-checks).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-inventory">bus-inventory</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vat">bus-vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
