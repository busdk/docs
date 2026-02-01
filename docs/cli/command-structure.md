## Command structure and discoverability

BusDK is CLI-first. Commands are organized by module and generally follow a verb-noun structure. Examples include `bus accounts add` for chart-of-accounts changes; `bus journal add` for ledger transaction creation; `bus invoice create` for invoice creation; `bus invoice generate-pdf` or `bus invoice pdf` for invoice document generation; `bus vat report` for VAT summaries; and `bus budget set` or `bus budget add` for budgeting operations. The top-level `bus` command or `bus help` is expected to list available modules and commands, while module-level help such as `bus journal --help` provides command usage details.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./automated-git-commits">Git commit conventions per operation (external Git)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../cli/index">BusDK Design Spec: CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./error-handling-dry-run-diagnostics">Error handling, dry-run, and diagnostics</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
