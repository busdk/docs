---
title: bus-data — shared tabular data layer and schema-validated I/O
description: bus data provides the shared tabular data layer for BusDK with deterministic Frictionless Table Schema and Data Package handling for workspace datasets.
---

## bus data — inspect and maintain workspace datasets, schemas, and data packages

### Overview

Command names follow [CLI command naming](../cli/command-naming). Bus Data provides the shared tabular data layer for BusDK by implementing deterministic [Frictionless](https://specs.frictionlessdata.io/) Table Schema and Data Package handling for workspace datasets. Its primary surface is a Go library that other modules import for schema, data package, and CSV operations. The canonical way to run the module’s CLI is via the BusDK dispatcher as `bus data`; the `bus-data` binary remains available for scripts or direct invocation, but end users and documentation should prefer `bus data`. The module is library-first, deterministic, and non-interactive, with no Git or network behavior. Modules that need to create or ensure `datapackage.json` (e.g. [bus-config](./bus-config), [bus-init](./bus-init)) use the bus-data Go library to initialize the empty descriptor first, not by invoking the CLI.

`bus data` reads tables, schemas, and data packages, validates records and foreign keys, and performs schema-governed changes in a deterministic way. It remains a mechanical data layer and does not implement domain-specific accounting logic; domain invariants are enforced by domain modules. Paths to domain datasets (e.g. accounts, journal) are owned by the module that owns each dataset; callers obtain paths from that module, and bus-data accepts table paths as input and performs schema-validated I/O on them.

### Synopsis

`bus data init [--chdir <dir>] [global flags]`  
`bus data schema init <table> --schema <file> [--force] [--chdir <dir>] [global flags]`  
`bus data schema show <table> | schema show --resource <name> [--chdir <dir>] [global flags]`  
`bus data schema infer <table> [--sample <n>] [--chdir <dir>] [global flags]`  
`bus data schema field add [--resource <name>] --field <name> --type <type> [--default <value>] [--required] [--description <text>] [--chdir <dir>] [global flags]`  
`bus data schema field set-type [--resource <name>] --field <name> --type <type> [--chdir <dir>] [global flags]`  
`bus data schema patch [--resource <name>] --patch <file> [--chdir <dir>] [global flags]`  
`bus data package discover | package show | package patch --patch <file> | package validate [--chdir <dir>] [global flags]`  
`bus data resource list | resource validate <resource> [--chdir <dir>] [global flags]`  
`bus data resource add --name <name> --path <path> --schema <file> [--chdir <dir>] [global flags]`  
`bus data resource remove <resource> [--delete-files] [--chdir <dir>] [global flags]`  
`bus data row add <table> (--set <key>=<value> ... | --json <file>) [--chdir <dir>] [global flags]`  
`bus data row update <table> --key <key>=<value> ... (--set <key>=<value> ... | --json <file>) [--chdir <dir>] [global flags]`  
`bus data row delete <table> --key <key>=<value> ... [--chdir <dir>] [global flags]`  
`bus data table read <table> [--row <index|start:end>] [--column <name>] ... [--filter <field>=<value>] ... [--key <key>=<value>] [--formula-source] [--chdir <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus data table list [--chdir <dir>] [-o <file>] [-f <format>] [global flags]`

### Getting started

To create an empty workspace data package descriptor, run `bus data init`. It creates `datapackage.json` at the workspace root with the standard profile and an empty `resources` array. Init does not scan the workspace for CSV files or add resources. When the file already exists, init is idempotent and leaves it unchanged. Adding resource entries is a separate operation: run `bus data package discover` to scan the workspace for CSV files that have a beside-the-table schema and add or update resource entries in the existing `datapackage.json`. Discover requires `datapackage.json` to exist (e.g. after `bus data init`); if the file is missing, the command fails with a clear diagnostic.

```text
bus data init
```

Start by defining a schema and letting `bus data` create the table and its beside-the-table schema file. The table path may omit the `.csv` suffix, and `schema init` writes both the CSV and the `.schema.json` in one deterministic step. Schema metadata such as `primaryKey`, `foreignKeys`, and `missingValues` is preserved when you initialize the table. Use `--force` when you need to overwrite an existing table and schema with a new definition.

```text
bus data schema init customers --schema customers.schema.json
bus data schema init customers --schema customers.schema.json --force
```

If you manage a workspace data package, run `bus data package discover` after tables exist so that each table with a beside-the-table schema is added as a resource. Discover requires `datapackage.json` to exist (e.g. after `bus data init`).

```text
bus data package discover
```

Add rows with either repeated `--set` assignments or a JSON file. Each row is validated against the schema before it is written, and duplicate primary keys are rejected for both single-column and composite keys.

```text
bus data row add customers --set id=1 --set name=Ada --set active=true
bus data row add customers --json row2.json
```

List tables in the workspace to confirm what exists. The output is a deterministic, workspace-relative list of table and schema paths, and you can request JSON format when you need structured output.

```text
bus data table list
```

Read a table to get its canonical CSV. `bus data` always validates against the schema before it emits rows, and JSON output is available for downstream tooling.

```text
bus data table read customers
```

### Read only what you need

When you want a narrower view, you can select rows and columns without changing validation. The filters are applied after validation, so the table still must pass its schema. Use `--row` with a single index or an inclusive `start:end` range, and repeat `--column` or `--filter` to refine the output.

```text
bus data table read customers --row 1 --column id --column name
bus data table read customers --row 1:2 --column id
bus data table read customers --filter status=active --filter name=Ada
```

If your tables use a primary key, use `--key field=value` for a single-column key. Repeat `--key` for composite keys in the same order as the schema’s `primaryKey`. Primary key uniqueness is enforced on `row add` for both single-column and composite keys.

```text
bus data table read customers --key id=1
```

### Update and delete rows

Row updates only succeed when the schema allows in-place edits. The schema’s `busdk.update_policy` must be set to `in_place` for updates to work. Updates accept either repeated `--set` assignments or a JSON file payload. Updates use the primary key to identify a single row, and composite keys are provided by repeating `--key field=value`.

```text
bus data row update customers --key id=1 --set balance=15.00
bus data row update customers --key id=1 --json row_update.json
```

Row deletes follow the schema’s delete policy. When the policy is `soft`, `bus data` writes the configured soft-delete field and value rather than removing the row. The schema’s `busdk.delete_policy`, `busdk.soft_delete_field`, and `busdk.soft_delete_value` control that behavior.

```text
bus data row delete customers --key id=2
```

### Manage data packages and resources

Use `bus data init` to create an empty `datapackage.json` at the workspace root. Use `package discover` to scan the workspace for tables with beside-the-table schemas and add them as resources. Use `package show` to inspect the descriptor, `package patch` to apply a JSON merge patch, and `package validate` to validate the full workspace package including foreign keys. Resource ordering is deterministic. Use `resource list` to see the current resources in deterministic order, and `resource validate` to validate a single resource without modifying files. Validation outputs a status row per resource, and when foreign key validation fails the command exits non-zero and reports the failure on standard error.

```text
bus data init
bus data package discover
bus data package show
bus data package patch --patch package.patch.json
bus data package validate
bus data resource list
bus data resource validate customers
```

Add resources explicitly with a name and CSV path and provide `--schema` to supply the Table Schema to write beside the table. This creates the CSV and beside-the-table schema artifacts. Remove a resource with `--delete-files` to delete its CSV and schema; the command refuses removal when any foreign key references the resource.

```text
bus data resource add --name customers --path customers.csv --schema customers.schema.json
bus data resource remove customers --delete-files
```

### Inspect and evolve schemas

Use `schema show` when you need the exact schema JSON. It prints the schema file as-is, either by table path or by resource name, so the output matches the bytes on disk. When `datapackage.json` is present, `--resource` resolves the schema path from the package.

```text
bus data schema show customers
bus data schema show --resource customers
```

If you already have a CSV, you can infer a schema from existing data and write it beside the table.

```text
bus data schema infer products --sample 2
```

Adding a field extends both the schema and the CSV. A default value is written to existing rows, and you can mark the field as required and add a description. When you need formula metadata inline, use `schema field add` with formula flags so the schema and table stay in sync.

```text
bus data schema field add --resource products --field category --type string --default general --required --description "category"
bus data schema field add --resource products --field total --type string --formula-mode inline --formula-prefix "=" --formula-result-type number --default "=a + b"
```

Changing a field type updates the schema only when existing values are compatible with the new type.

```text
bus data schema field set-type --resource products --field price --type number
```

Schema metadata can include `primaryKey`, `foreignKeys`, and `missingValues`. These are preserved by `schema init`, and `primaryKey` can be either a single field name or an ordered list for composite keys. Foreign key definitions follow the Table Schema format and are enforced during resource and package validation.

When you need full control over schema metadata, apply a JSON merge patch that preserves unknown properties. Use `--resource` to target a schema by resource name when `datapackage.json` is present.

```text
bus data schema patch --resource products --patch schema.patch.json
```

### Formula-driven columns

Schemas can declare formula columns by adding a `busdk.formula` block under a field. Inline formulas are stored in the CSV cell values and evaluated at read time. Constant formulas ignore cell values and use the schema expression as the source of truth. Formula results are typed and may include rounding rules for numeric results.

Formulas use the BFL language. Inline formulas typically set a `prefix` such as `=` and accept per-cell expressions. Constant formulas set `mode` to `constant` and provide an `expression` string. When `on_error` is set to `null`, formula errors yield empty output values instead of failing the read.

To get started with inline formulas, define a column with a `busdk.formula` block, add rows with the formula expression in the cell, and read the table to see computed values. The formula source stays in the CSV, while `table read` emits the computed value.

```text
cat > laskelmat.schema.json <<'JSON'
{
  "fields": [
    {"name": "a", "type": "integer"},
    {"name": "b", "type": "integer"},
    {
      "name": "total",
      "type": "string",
      "busdk": {
        "formula": {
          "language": "bfl",
          "mode": "inline",
          "prefix": "=",
          "result": {"type": "integer"}
        }
      }
    }
  ]
}
JSON
bus data schema init laskelmat --schema laskelmat.schema.json
bus data row add laskelmat --set a=2 --set b=3 --set total==a + b
bus data table read laskelmat
```

If you need to inspect the raw formula sources, `--formula-source` adds an extra column that captures the original formula expression for each formula field without colliding with existing column names. The source column name is the formula field name with the `__formula_source` suffix.

```text
bus data table read laskelmat --formula-source
```

Constant formulas are driven entirely by the schema. This is useful when you want a computed column that does not depend on per-row input, such as a fixed ratio with controlled rounding.

```text
cat > laskelmat_const.schema.json <<'JSON'
{
  "fields": [
    {"name": "label", "type": "string"},
    {
      "name": "total",
      "type": "string",
      "busdk": {
        "formula": {
          "language": "bfl",
          "mode": "constant",
          "expression": "1 / 8",
          "result": {"type": "number"},
          "rounding": {"scale": 2, "mode": "half_even"}
        }
      }
    }
  ]
}
JSON
bus data schema init laskelmat_const --schema laskelmat_const.schema.json
bus data row add laskelmat_const --set label=ok
bus data table read laskelmat_const
```

Formula evaluation uses a table snapshot, so range expressions resolve against the same read and do not depend on row-by-row mutation. Invalid formula metadata is rejected at read time and reports a formula error to standard error. To treat formula errors as empty values, set `on_error` to `null` in the formula block.

### Output formats and files

`bus data` can emit JSON where a command supports structured output. Table and resource listings default to TSV, while table reads default to CSV. Package and resource validation report one row per resource and use TSV by default, or JSON when `--format json` is set. JSON outputs preserve the CSV string values and keep ordering deterministic.

```text
bus data --format json table list
bus data --format json resource list
bus data --format json table read customers
bus data --format json package validate
bus data --format json resource validate customers
```

To capture output in a file, use `--output`. If you also use `--quiet`, output is suppressed and the file is not written.

```text
bus data --output out_list.tsv table list
bus data --quiet --output out_list.tsv table list
```

### Workspace and safety flags

Global flags (including `--chdir`) are defined in [Standard global flags](../cli/global-flags). Use `--chdir` to set the workspace root before resolving any paths. This is useful when you run `bus data` from another directory.

```text
bus data --chdir /path/to/workspace table list
```

Use `--dry-run` on mutating commands to see what would change without writing files. This keeps existing CSV and schema files unchanged.

```text
bus data --dry-run row add products --set id=P-4 --set name="Product D"
```

If a table name starts with `-`, place `--` before the command arguments to stop flag parsing.

```text
bus data -- table read -taulu
```

Help and version output are printed to standard output. Diagnostics and validation failures are printed to standard error. You can disable or force colored output for diagnostics with `--color auto|always|never` or `--no-color`, and the flags are accepted even when you only need help or version output.

### Files

The module operates on workspace datasets as CSV resources with beside-the-table Table Schema JSON files (same directory, `.csv` replaced by `.schema.json`). A workspace `datapackage.json` is stored at the workspace root and references resources by name and workspace-relative CSV path. Path ownership lies with domain modules: when a consumer needs to read or write a domain table (e.g. accounts, periods, journal), it obtains the path from the owning module’s Go library. Bus-data accepts table paths as input and performs schema-validated I/O on them; it does not define or hardcode which path is “accounts” or “periods” (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Exit status

`0` on success. `2` on invalid usage. Non-zero on missing files, schema validation failure, or foreign key integrity failure.

### Development state

**Value promise:** Inspect and maintain workspace datasets, schemas, and data packages with schema-governed row and schema operations so tables stay valid and reviewable without running domain CLIs.

**Use cases:** [Spreadsheet workbooks (workbook and validated tabular editing)](../workflow/workbook-and-validated-tabular-editing).

**Completeness:** 80% — init, package, resource (add/remove/rename), schema (init/show/infer/patch, key set, foreign-key add/remove, field add/remove/rename/set-type/set-format/set-constraints/set-missing-values), table list/read/workbook, row add/update/delete, and formula projection verified by e2e and unit tests; table workbook command not yet documented in Module SDD and CLI reference (KD-DAT-005).

**Use case readiness:** Spreadsheet workbooks: 80% — user can complete package and resource lifecycle (add/remove/rename with FK reference update), schema evolution (key set, foreign-key add/remove, field remove/rename/set-format/set-constraints/set-missing-values), table and workbook-style read (cell/range, --header, --anchor-col/--anchor-row, --decimal-sep, --formula), and row mutate; workbook command documentation in SDD/CLI reference pending.

**Current:** `tests/e2e_bus_data.sh` verifies init, schema init/show/infer/add-field/set-type/patch (including --resource), schema key set (--dry-run, success, refuse duplicate/empty key), schema foreign-key add/remove (--dry-run, success, refuse duplicate/invalid reference), schema field remove/rename/set-format/set-constraints/set-missing-values (--dry-run, success, refuse PK remove without --force), package discover/show/patch/validate, resource list/validate/add/remove (refused when FK, --dry-run, --delete-files) and resource rename (--rename-files, FK reference update), table list/read (--row, --column, --filter, --key single and composite), table workbook (address/range, --header, --anchor-col, --anchor-row, --decimal-sep, --formula), row add/update/delete (in-place and soft-delete), inline and constant formula projection, --formula-source, range resolution, on_error=null, invalid formula rejection, and global flags (--chdir, --output, --quiet, --dry-run, --). `internal/cli/package_resource_test.go` verifies resource remove refused when referenced, --dry-run, and --delete-files. `internal/cli/run_test.go` and `internal/cli/flags_test.go` verify help/version/quiet/format/chdir. `pkg/data/*_test.go` and `internal/cli/write_commands_test.go` verify mutate, patch, validate, formula, workspace, and serialization; `pkg/data/schema_key_set_test.go` and `pkg/data/schema_foreign_key_test.go` verify key set and foreign-key library behavior.

**Planned next:** Document `table workbook` in Module SDD and module CLI reference (command name, flags, output schema per KD-DAT-005); advances Spreadsheet workbooks when formally documented for [api](./bus-api) and [sheets](./bus-sheets) consumers.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-api](./bus-api) and [bus-sheets](./bus-sheets) depend on it for workspace endpoints and the embedded UI backend.

See [Development status](../implementation/development-status#spreadsheet-workbooks).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-init">bus-init</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [Module SDD: bus-data](../sdd/bus-data)
- [Storage contract: Storage backends and workspace store interface](../data/storage-backends)

