## bus-data

### Name

`bus-data` — inspect and maintain workspace datasets and schemas.

### Synopsis

`bus-data [global flags] <command> [args]`

### Description

`bus-data` is a mechanical dataset tool for BusDK repositories. It lists tables, prints schema content, validates and emits CSV or JSON, and performs schema-governed write operations. Other BusDK modules use the bus-data library for dataset I/O; this CLI is for inspection and deterministic maintenance.

### Usage

```text
bus-data is a mechanical dataset tool for BusDK repositories.

Usage:
  bus-data [global flags] <command> [args]

Commands:
  table list                          List tables with beside-the-table schemas.
  table read <table_path>             Validate a table and emit CSV or JSON.
  schema show <table_path>            Print the Table Schema JSON for a table.
  schema init <table_path>            Initialize a CSV and beside-the-table schema.
  schema infer <table_path>           Infer a schema from an existing CSV.
  schema add-field <table_path>       Add a field to the schema and extend the CSV.
  schema set-type <table_path>        Change a field type when compatible.
  row add <table_path>                Append a new row.
  row update <table_path>             Update a row by primary key when allowed.
  row delete <table_path>             Delete a row by primary key when allowed.

  <table_path> may omit the .csv suffix (e.g. "transactions" for transactions.csv).

Global flags:
  -h, --help               Show help and exit.
  -V, --version            Show version and exit.
  -v, --verbose            Increase verbosity (repeatable, e.g. -vv).
  -q, --quiet              Suppress non-error output.
  -C, --chdir <dir>        Use <dir> as the workspace root.
  -o, --output <file>      Write command output to <file>.
  -f, --format <format>    Output format: list tsv|json (default tsv), read csv|json (default csv).
      --row <n>            (read only) Emit only the nth data row (1-based). Use N:NN for a range.
      --key <id>           (read only) Emit only the row whose first column (primary key) equals <id>.
      --filter <col=val>   (read only) Keep rows where column equals value; repeat for AND.
      --column <name>      (read only) Emit only selected columns; repeat to keep multiple.
      Read flags (--row, --key, --filter, --column) may appear before or after the table path.
      --dry-run            Show planned file changes without writing.
      --color <mode>       auto|always|never for stderr messages (default: auto).
      --no-color           Alias for --color=never.
  --                       Stop parsing flags.

Write flags:
  --schema <file>          (schema init) Source schema JSON to write beside the table.
  --sample <n>             (schema infer) Limit inference to the first n data rows.
  --field <name>           (schema add-field/set-type) Field name to append or update.
  --type <type>            (schema add-field/set-type) Field type to append or apply.
  --required               (schema add-field) Mark the field as required.
  --description <text>     (schema add-field) Field description text.
  --default <value>        (schema add-field) Default value written to existing rows.
  --key <id>               (row update/delete) Select a row by primary key.
  --set <col=val>          (row add/update) Set a column value; repeatable.
  --json <file>            (row add/update) JSON object row input; use - for stdin.
  --force                  Allow overwriting existing files during schema init.

Examples:
  bus-data -vv table list
  bus-data --format json table list
  bus-data table read people
  bus-data --format json --filter name=alice --row 1 table read people
  bus-data --key p-001 --column name --column age table read people
  bus-data schema init people --schema people.schema.json
  bus-data schema infer people
  bus-data schema add-field people --field nickname --type string
  bus-data schema set-type people --field age --type integer
  bus-data row add people --set id=p-001 --set name=Alice
  bus-data row update people --key p-001 --set name=Alice A.
  bus-data row delete people --key p-001
  bus-data -- table read --weird.csv   (use -- when the table path starts with '-')
```

### Command behavior

The `table list` command prints a TSV of `table_path` and `schema_path` for every CSV that has a beside-the-table schema. Order is lexicographic by table path.

The `schema show <table_path>` command writes the schema file content for the given table path to standard output.

The `table read <table_path>` command validates the table against its schema and writes canonical CSV or JSON to standard output, exiting non-zero on validation failure. Read filters do not change validation behavior; they only select which validated rows are emitted. Use `--column` with `--key` to emit only specific fields for a single row.

In addition to read-only inspection, bus-data supports initializing a new CSV with a beside-the-table schema, inferring a schema from an existing CSV, extending schemas by adding columns, changing field types when compatible, and performing row-level CRUD operations. These write operations are explicit and operate on workspace-relative table paths in the same way as the inspection commands.

CRUD operations validate against the beside-the-table schema and write changes without modifying unrelated rows. Update and delete are permitted only when the schema’s BusDK metadata explicitly allows the operation and defines the soft-delete behavior when applicable.

The `schema infer` command guesses field types and constraints by scanning data rows and emits a deterministic schema. The `schema set-type` command refuses incompatible changes and does not rewrite table data; it updates the schema only when all existing values can be interpreted as the new type.

BusDK schema metadata for mutability lives in the optional `busdk` object. `busdk.update_policy` may be `forbid` or `in_place`, and `busdk.delete_policy` may be `forbid`, `soft`, or `hard`. When `busdk.delete_policy` is `soft`, `busdk.soft_delete_field` and `busdk.soft_delete_value` must be set so deletions are deterministic.

### Files

Operates on any workspace CSV and its beside-the-table `.schema.json` (same directory, `.csv` replaced by `.schema.json`).

### Exit status

`0` on success. Non-zero on invalid usage, missing files, or schema validation failure.

### See also

Module SDD: [bus-data](../sdd/bus-data)  
Storage contract: [Storage backends and workspace store interface](../data/storage-backends)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-init">bus-init</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
