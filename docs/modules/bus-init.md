## bus-init

### Name

`bus init` — initialize a new BusDK workspace.

### Synopsis

`bus init [options]`

### Description

`bus init` bootstraps a new workspace by writing workspace-level configuration and by running each module’s `init` command in a deterministic sequence. Each module owns its own datasets and schemas; `bus init` does not perform Git or network operations. The result is the standard workspace layout with baseline datasets and schemas, plus an initial `bus.yml` that defines accounting entity settings for the workspace.

### Commands

This module has no subcommands. Run `bus init` from the workspace root (the directory that will contain the workspace datasets).

### Options

No module-specific flags. Global flags such as `-C`, `--help`, and `--verbose` apply. Run `bus init --help` for details.

### Files

Creates or updates workspace-level metadata (e.g. `datapackage.json` and `bus.yml`) and invokes module inits that create datasets and schemas in their respective areas.

### Exit status

`0` on success. Non-zero on invalid usage or if any module `init` fails; diagnostics identify the failing command.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-data">bus-data</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Module SDD: bus-init](../sdd/bus-init)
- [Layout: Layout principles](../layout/layout-principles)
- [Workflow: Initialize repo](../workflow/initialize-repo)

