## bus-data

### Name

`bus-data` — inspect and maintain workspace datasets, schemas, and data packages.

### Description

`bus-data` is the workspace dataset tool for BusDK repositories. It reads tables, schemas, and data packages, validates records and foreign keys, and performs schema-governed changes in a deterministic way. The goal is to make dataset maintenance predictable and reviewable while keeping day-to-day operations simple and non-interactive.

### Getting started

Start by defining a schema and letting `bus-data` create the table and its beside-the-table schema file. The table path may omit the `.csv` suffix, and `schema init` writes both the CSV and the `.schema.json` in one deterministic step. Use `--force` when you need to overwrite an existing table and schema with a new definition.

```text
bus-data schema init customers --schema customers.schema.json
bus-data schema init customers --schema customers.schema.json --force
```

If you manage a workspace data package, initialize `datapackage.json` after the table exists so the resource is discovered deterministically.

```text
bus-data package init
```

Add rows with either repeated `--set` assignments or a JSON file. Each row is validated against the schema before it is written.

```text
bus-data row add customers --set id=1 --set name=Ada --set active=true
bus-data row add customers --json row2.json
```

List tables in the workspace to confirm what exists. The output is a deterministic, workspace-relative list of table and schema paths.

```text
bus-data table list
```

Read a table to get its canonical CSV. `bus-data` always validates against the schema before it emits rows.

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

If your tables use a primary key, use `--key <value>` for a single-column key. Repeat `--key` for composite keys in the same order as the schema’s `primaryKey`.

```text
bus-data table read customers --key 1
```

### Update and delete rows

Row updates only succeed when the schema allows in-place edits. The schema’s `busdk.update_policy` must be set to `in_place` for updates to work. Updates accept either repeated `--set` assignments or a JSON file payload.

```text
bus-data row update customers --key 1 --set balance=15.00
bus-data row update customers --key 1 --json row_update.json
```

Row deletes follow the schema’s delete policy. When the policy is `soft`, `bus-data` writes the configured soft-delete field and value rather than removing the row. The schema’s `busdk.delete_policy`, `busdk.soft_delete_field`, and `busdk.soft_delete_value` control that behavior.

```text
bus-data row delete customers --key 2
```

### Manage data packages and resources

Use `package init` to create `datapackage.json` from the current tables and beside-the-table schemas, `package show` to inspect it, `package patch` to apply a JSON merge patch, and `package validate` to validate the full workspace package including foreign keys. Use `resource list` to see the current resources in deterministic order, and `resource validate` to validate a single resource without modifying files.

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

Adding a field extends both the schema and the CSV. A default value is written to existing rows, and you can mark the field as required and add a description.

```text
bus-data schema add-field products --field category --type string --default general --required --description "category"
```

Changing a field type updates the schema only when existing values are compatible with the new type.

```text
bus-data schema set-type products --field price --type number
```

When you need full control over schema metadata, apply a JSON merge patch that preserves unknown properties.

```text
bus-data schema patch --resource products --patch schema.patch.json
```

### Output formats and files

`bus-data` can emit JSON where a command supports structured output. Table and resource listings default to TSV, while table reads default to CSV. Package and resource validation report one row per resource and use TSV by default, or JSON when `--format json` is set.

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

Use `--chdir` to set the workspace root before resolving any paths. This is useful when you run `bus-data` from another directory.

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

Help and diagnostics are printed to standard error. You can disable or force colored output with `--color auto|always|never` or `--no-color`, and the flags are accepted even when you only need help or version output. Version and help are always available through `--version` and `--help`.

### Files

Operates on any workspace CSV and its beside-the-table `.schema.json` (same directory, `.csv` replaced by `.schema.json`), plus `datapackage.json` at the workspace root when present.

### Exit status

`0` on success. `2` on invalid usage. Non-zero on missing files, schema validation failure, or foreign key integrity failure.

### See also

Module SDD: [bus-data](../sdd/bus-data)  
Storage contract: [Storage backends and workspace store interface](../data/storage-backends)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-init">bus-init</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bfl">bus-bfl</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
