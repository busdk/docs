## bus-init

Bus Init bootstraps a new BusDK workspace by orchestrating module-owned init
commands. It creates the chosen workspace layout (for example `fi`) by calling
subcommands like `bus accounts init`, `bus journal init`, and `bus invoices init`
so that each module remains the sole owner of its datasets and schemas.

### How to run

Run `bus init` … and use `--help` for available arguments.

### Subcommands

Bus Init does not define additional subcommands. It is invoked as `bus init` with flags.

### Data it reads and writes

It may create or update workspace-level metadata at the workspace root
(`datapackage.json`). All other datasets are created by the module init commands
that `bus init` invokes.

### Outputs and side effects

It executes a deterministic sequence of `bus <module> init …` calls and checks
that the expected workspace directories and baseline files exist afterwards. It
prints subcommand output to stdout/stderr and stops on the first failure. It
does not run any git commands and performs no network operations.

### Finnish compliance responsibilities

Bus Init MUST create a workspace layout that supports the methods description and dataset list required for Finnish bookkeeping and ensures baseline schemas and directories exist for long-term retention and auditability.

### Integrations

It invokes [`bus accounts`](./bus-accounts),
[`bus journal`](./bus-journal),
[`bus invoices`](./bus-invoices),
[`bus vat`](./bus-vat),
[`bus attachments`](./bus-attachments),
[`bus bank`](./bus-bank), and
[`bus reports`](./bus-reports) to scaffold their module-owned workspace areas.

### See also

Repository: https://github.com/busdk/bus-init

For workspace layout choices and the initialization workflow, see [Layout principles](../layout/layout-principles) and [Initialize repo](../workflow/initialize-repo).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-data">bus-data</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
