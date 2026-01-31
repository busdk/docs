# Command structure and discoverability

BusDK is CLI-first. Commands are organized by module and generally follow a verb-noun structure. Examples include `busdk accounts add` for chart-of-accounts changes; `busdk journal record` (and, in some contexts, `busdk journal add`) for ledger entry creation; `busdk invoice create` for invoice creation; `busdk invoice generate-pdf` or `busdk invoice pdf` for invoice document generation; `busdk vat report` for VAT summaries; and `busdk budget set` or `busdk budget add` for budgeting operations. The top-level `busdk` command or `busdk help` is expected to list available modules and commands, while module-level help such as `busdk journal --help` provides command usage details.

---

<!-- busdk-docs-nav start -->
**Prev:** [Git commit conventions per operation (external Git)](./automated-git-commits) · **Index:** [BusDK Design Spec: CLI tooling and workflow](../cli/) · **Next:** [Error handling, dry-run, and diagnostics](./error-handling-dry-run-diagnostics)
<!-- busdk-docs-nav end -->
