# bus-init

Bus Init bootstraps a new BusDK workspace by orchestrating module-owned init
commands. It creates the chosen workspace layout (for example `fi`) by calling
subcommands like `bus accounts init`, `bus journal init`, and `bus invoices init`
so that each module remains the sole owner of its datasets and schemas.

## How to run

Run `bus init` … and use `--help` for available arguments.

## Data it reads and writes

It may create or update workspace-level metadata at the workspace root
(`datapackage.json`). All other datasets are created by the module init commands
that `bus init` invokes.

## Outputs and side effects

It executes a deterministic sequence of `bus <module> init …` calls and checks
that the expected workspace directories and baseline files exist afterwards. It
prints subcommand output to stdout/stderr and stops on the first failure. It
does not run any git commands and performs no network operations.

## Integrations

It invokes [`bus accounts`](./bus-accounts),
[`bus journal`](./bus-journal),
[`bus invoices`](./bus-invoices),
[`bus vat`](./bus-vat),
[`bus attachments`](./bus-attachments),
[`bus bank`](./bus-bank), and
[`bus reports`](./bus-reports) to scaffold their module-owned workspace areas.

## See also

Repository: ./modules/bus-init

---

<!-- busdk-docs-nav start -->
**Prev:** [Link list (original numbered references)](../spec/references/link-list) · **Index:** [BusDK Design Document](../index) · **Next:** [bus-accounts](./bus-accounts)
<!-- busdk-docs-nav end -->
