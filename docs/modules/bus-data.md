---
title: bus-data
description: bus-data is the workspace dataset tool for BusDK repositories.
---

## bus-data

### Name

`bus-data` — inspect and maintain workspace datasets, schemas, and data packages.

### Synopsis

`bus-data schema init <table> --schema <file> [--force] [--chdir <dir>] [global flags]`  
`bus-data schema show <table> | schema show --resource <name> [--chdir <dir>] [global flags]`  
`bus-data schema infer <table> [--sample <n>] [--chdir <dir>] [global flags]`  
`bus-data schema add-field <table> --field <name> --type <type> [--default <value>] [--required] [--description <text>] [--chdir <dir>] [global flags]`  
`bus-data schema field add <table> --field <name> --type <type> [--formula-mode ...] [--formula-prefix ...] [--formula-result-type ...] [--default <value>] [--chdir <dir>] [global flags]`  
`bus-data schema set-type <table> --field <name> --type <type> [--chdir <dir>] [global flags]`  
`bus-data schema patch [--resource <name>] --patch <file> [--chdir <dir>] [global flags]`  
`bus-data package init | package show | package patch --patch <file> | package validate [--chdir <dir>] [global flags]`  
`bus-data resource list | resource validate <resource> [--chdir <dir>] [global flags]`  
`bus-data resource add --name <name> --path <path> --schema <file> [--chdir <dir>] [global flags]`  
`bus-data resource remove <resource> [--delete-files] [--chdir <dir>] [global flags]`  
`bus-data row add <table> (--set <key>=<value> ... | --json <file>) [--chdir <dir>] [global flags]`  
`bus-data row update <table> --key <key>=<value> ... (--set <key>=<value> ... | --json <file>) [--chdir <dir>] [global flags]`  
`bus-data row delete <table> --key <key>=<value> ... [--chdir <dir>] [global flags]`  
`bus-data table read <table> [--row <index|start:end>] [--column <name>] ... [--filter <field>=<value>] ... [--key <key>=<value>] [--formula-source] [--chdir <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus-data table list [--chdir <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus-data` is the workspace dataset tool for BusDK repositories. It reads tables, schemas, and data packages, validates records and foreign keys, and performs schema-governed changes in a deterministic way. The goal is to make dataset maintenance predictable and reviewable while keeping day-to-day operations simple and non-interactive.

### Getting started

Start by defining a schema and letting `bus-data` create the table and its beside-the-table schema file. The table path may omit the `.csv` suffix, and `schema init` writes both the CSV and the `.schema.json` in one deterministic step. Schema metadata such as `primaryKey`, `foreignKeys`, and `missingValues` is preserved when you initialize the table. Use `--force` when you need to overwrite an existing table and schema with a new definition.

```text
bus-data schema init customers --schema customers.schema.json
bus-data schema init customers --schema customers.schema.json --force
```

If you manage a workspace data package, initialize `datapackage.json` after the table exists so the resource is discovered deterministically.

```text
bus-data package init
```

Add rows with either repeated `--set` assignments or a JSON file. Each row is validated against the schema before it is written, and duplicate primary keys are rejected for both single-column and composite keys.

```text
bus-data row add customers --set id=1 --set name=Ada --set active=true
bus-data row add customers --json row2.json
```

List tables in the workspace to confirm what exists. The output is a deterministic, workspace-relative list of table and schema paths, and you can request JSON format when you need structured output.

```text
bus-data table list
```

Read a table to get its canonical CSV. `bus-data` always validates against the schema before it emits rows, and JSON output is available for downstream tooling.

```text
bus-data table read customers
```

### Read only what you need

When you want a narrower view, you can select rows and columns without changing validation. The filters are applied after validation, so the table still must pass its schema. Use `--row` with a single index or an inclusive `start:end` range, and repeat `--column` or `--filter` to refine the output.

```text
bus-data table read customers --row 1 --column id --column name
bus-data table read customers --row 1:2 --column id
bus-data table read customers --filter status=active --filter name=Ada
```

If your tables use a primary key, use `--key field=value` for a single-column key. Repeat `--key` for composite keys in the same order as the schema’s `primaryKey`. Primary key uniqueness is enforced on `row add` for both single-column and composite keys.

```text
bus-data table read customers --key id=1
```

### Update and delete rows

Row updates only succeed when the schema allows in-place edits. The schema’s `busdk.update_policy` must be set to `in_place` for updates to work. Updates accept either repeated `--set` assignments or a JSON file payload. Updates use the primary key to identify a single row, and composite keys are provided by repeating `--key field=value`.

```text
bus-data row update customers --key id=1 --set balance=15.00
bus-data row update customers --key id=1 --json row_update.json
```

Row deletes follow the schema’s delete policy. When the policy is `soft`, `bus-data` writes the configured soft-delete field and value rather than removing the row. The schema’s `busdk.delete_policy`, `busdk.soft_delete_field`, and `busdk.soft_delete_value` control that behavior.

```text
bus-data row delete customers --key id=2
```

### Manage data packages and resources

Use `package init` to create `datapackage.json` from the current tables and beside-the-table schemas, `package show` to inspect it, `package patch` to apply a JSON merge patch, and `package validate` to validate the full workspace package including foreign keys. Package initialization and listing keep resource ordering deterministic. Use `resource list` to see the current resources in deterministic order, and `resource validate` to validate a single resource without modifying files. Validation outputs a status row per resource, and when foreign key validation fails the command exits non-zero and reports the failure on standard error.

```text
bus-data package init
bus-data package show
bus-data package patch --patch package.patch.json
bus-data package validate
bus-data resource list
bus-data resource validate customers
```

Add resources explicitly with a name and CSV path and provide `--schema` to supply the Table Schema to write beside the table. This creates the CSV and beside-the-table schema artifacts. Remove a resource with `--delete-files` to delete its CSV and schema; the command refuses removal when any foreign key references the resource.

```text
bus-data resource add --name customers --path customers.csv --schema customers.schema.json
bus-data resource remove customers --delete-files
```

### Inspect and evolve schemas

Use `schema show` when you need the exact schema JSON. It prints the schema file as-is, either by table path or by resource name, so the output matches the bytes on disk. When `datapackage.json` is present, `--resource` resolves the schema path from the package.

```text
bus-data schema show customers
bus-data schema show --resource customers
```

If you already have a CSV, you can infer a schema from existing data and write it beside the table.

```text
bus-data schema infer products --sample 2
```

Adding a field extends both the schema and the CSV. A default value is written to existing rows, and you can mark the field as required and add a description. When you need formula metadata inline, use `schema field add` with formula flags so the schema and table stay in sync.

```text
bus-data schema add-field products --field category --type string --default general --required --description "category"
bus-data schema field add products --field total --type string --formula-mode inline --formula-prefix "=" --formula-result-type number --default "=a + b"
```

Changing a field type updates the schema only when existing values are compatible with the new type.

```text
bus-data schema set-type products --field price --type number
```

Schema metadata can include `primaryKey`, `foreignKeys`, and `missingValues`. These are preserved by `schema init`, and `primaryKey` can be either a single field name or an ordered list for composite keys. Foreign key definitions follow the Table Schema format and are enforced during resource and package validation.

When you need full control over schema metadata, apply a JSON merge patch that preserves unknown properties. Use `--resource` to target a schema by resource name when `datapackage.json` is present.

```text
bus-data schema patch --resource products --patch schema.patch.json
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
bus-data schema init laskelmat --schema laskelmat.schema.json
bus-data row add laskelmat --set a=2 --set b=3 --set total==a + b
bus-data table read laskelmat
```

If you need to inspect the raw formula sources, `--formula-source` adds an extra column that captures the original formula expression for each formula field without colliding with existing column names. The source column name is the formula field name with the `__formula_source` suffix.

```text
bus-data table read laskelmat --formula-source
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
bus-data schema init laskelmat_const --schema laskelmat_const.schema.json
bus-data row add laskelmat_const --set label=ok
bus-data table read laskelmat_const
```

Formula evaluation uses a table snapshot, so range expressions resolve against the same read and do not depend on row-by-row mutation. Invalid formula metadata is rejected at read time and reports a formula error to standard error. To treat formula errors as empty values, set `on_error` to `null` in the formula block.

### Output formats and files

`bus-data` can emit JSON where a command supports structured output. Table and resource listings default to TSV, while table reads default to CSV. Package and resource validation report one row per resource and use TSV by default, or JSON when `--format json` is set. JSON outputs preserve the CSV string values and keep ordering deterministic.

```text
bus-data --format json table list
bus-data --format json resource list
bus-data --format json table read customers
bus-data --format json package validate
bus-data --format json resource validate customers
```

To capture output in a file, use `--output`. If you also use `--quiet`, output is suppressed and the file is not written.

```text
bus-data --output out_list.tsv table list
bus-data --quiet --output out_list.tsv table list
```

### Workspace and safety flags

Global flags (including `--chdir`) are defined in [Standard global flags](../cli/global-flags). Use `--chdir` to set the workspace root before resolving any paths. This is useful when you run `bus-data` from another directory.

```text
bus-data --chdir /path/to/workspace table list
```

Use `--dry-run` on mutating commands to see what would change without writing files. This keeps existing CSV and schema files unchanged.

```text
bus-data --dry-run row add products --set id=P-4 --set name="Product D"
```

If a table name starts with `-`, place `--` before the command arguments to stop flag parsing.

```text
bus-data -- table read -taulu
```

Help and version output are printed to standard output. Diagnostics and validation failures are printed to standard error. You can disable or force colored output for diagnostics with `--color auto|always|never` or `--no-color`, and the flags are accepted even when you only need help or version output.

### Files

Operates on any workspace CSV and its beside-the-table `.schema.json` (same directory, `.csv` replaced by `.schema.json`), plus `datapackage.json` at the workspace root when present.

### Exit status

`0` on success. `2` on invalid usage. Non-zero on missing files, schema validation failure, or foreign key integrity failure.

### Development state

**Value:** Inspect and maintain workspace datasets, schemas, and data packages with schema-governed row and schema operations so tables stay valid and reviewable without running domain CLIs.

**Completeness:** 60% (Stable for one use case) — schema init/show, package init/validate, table and row operations, and validation are verified by e2e and unit tests.

**Current:** E2e script `tests/e2e_bus_data.sh` proves schema init creates table and schema files, schema show prints exact schema bytes, package init and validate, row add/update/delete, table read with filters and key, and deterministic I/O. Unit tests in `pkg/data/` and `internal/cli/` cover mutate, patch, validate, formula, and workspace behavior.

**Planned next:** Resource add/remove; schema key and foreign-key ops; field add/remove/rename; `--resource` resolution.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-api](./bus-api) and [bus-sheets](./bus-sheets) depend on it for workspace endpoints and the embedded UI backend.

See [Development status](../implementation/development-status).

---

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

