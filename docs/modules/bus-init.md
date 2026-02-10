## bus-init

### Name

`bus init` — initialize a new BusDK workspace.

### Synopsis

`bus init [options]`  
`bus init configure [options]`

### Description

`bus init` bootstraps a new workspace by writing workspace-level configuration and by running each module’s `init` command in a deterministic sequence. Each module owns its own datasets and schemas; `bus init` does not perform Git or network operations. The result is the standard workspace layout with baseline datasets and schemas, plus an initial `datapackage.json` that stores accounting entity settings for the workspace as BusDK metadata.

`bus init configure` updates accounting entity settings in an existing workspace `datapackage.json`. The workspace must already contain `datapackage.json` with a `busdk.accounting_entity` object (created by `bus init`). Only the properties you pass via flags are changed; others remain unchanged.

### Commands

`init` — Bootstrap a new workspace. Run from the workspace root (the directory that will contain the workspace datasets).

`init configure` — Edit accounting entity settings (base currency, fiscal year boundaries, VAT registration, VAT reporting cadence) in the workspace `datapackage.json`.

### Options

For `bus init`: no module-specific flags. Global flags such as `-C`, `--help`, and `--verbose` apply.

For `bus init configure`, the following flags update the corresponding property in `busdk.accounting_entity`. Omit a flag to leave that property unchanged.

`--base-currency <code>` — ISO 4217 currency code (for example `EUR`, `SEK`).

`--fiscal-year-start <date>` — Fiscal year start date in `YYYY-MM-DD` form.

`--fiscal-year-end <date>` — Fiscal year end date in `YYYY-MM-DD` form.

`--vat-registered <true|false>` — Whether the entity is VAT registered.

`--vat-reporting-period <period>` — VAT reporting cadence (for example `monthly`, `quarterly`).

Run `bus init configure --help` for details. Global flags such as `-C`, `--help`, and `--verbose` apply.

### Files

Creates or updates workspace-level metadata (`datapackage.json`) and invokes module inits that create datasets and schemas in their respective areas. The `configure` subcommand updates only the `busdk.accounting_entity` subtree in `datapackage.json`.

### Exit status

`0` on success. Non-zero on invalid usage, if any module `init` fails, or if `configure` is run in a workspace that lacks `datapackage.json` or `busdk.accounting_entity`; diagnostics identify the failing command.

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

