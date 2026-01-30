# bus-validate

Bus Validate validates every CSV dataset against its Table Schema, verifies
cross-table integrity and double-entry invariants, and produces actionable
diagnostics for invalid workspaces.

## How to run

Run `bus validate` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads all workspace datasets and schemas. It does not modify data unless a
command explicitly requests it.

## Outputs and side effects

It prints validation diagnostics and summaries, and returns non-zero exit codes
on validation failures.

## Integrations

It is used as a prerequisite for [`bus period`](./bus-period)
close and [`bus filing`](./bus-filing) exports, and enables CI
checks and scripted validations.

## See also

Repository: ./modules/bus-validate

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-inventory](./bus-inventory) · **Next:** [bus-vat](./bus-vat)
<!-- busdk-docs-nav end -->
