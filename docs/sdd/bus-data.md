## bus-data

### Introduction and Overview

Bus Data provides the shared tabular data layer for BusDK by implementing schema-validated dataset I/O and validation for workspace datasets. Its primary surface is a Go library that other modules import directly for deterministic table and schema handling, and it also provides the `bus-data` CLI for inspection and mechanical dataset maintenance.

### Requirements

FR-DAT-001 Deterministic dataset I/O. The module MUST provide deterministic read, write, and validation behavior for workspace datasets. Acceptance criteria: table reads and writes are schema-validated and refuse invalid writes.

FR-DAT-002 Library-first integration. The Go library MUST be the primary integration surface for other modules. Acceptance criteria: module integrations rely on the library rather than shelling out to the `bus-data` CLI.

FR-DAT-003 Table initialization. The module MUST support initializing a new CSV file alongside a beside-the-table schema file using explicit commands. Acceptance criteria: initialization writes a schema file that matches the table and does not overwrite existing data unless explicitly requested.

FR-DAT-004 Schema extension. The module MUST support extending an existing schema by adding columns through explicit commands. Acceptance criteria: added columns are appended deterministically and existing columns retain their order and definitions.

FR-DAT-005 Row append. The module MUST support appending a new row to an existing CSV through an explicit CLI option. Acceptance criteria: the appended row is validated against the beside-the-table schema and appended in canonical column order without modifying existing rows.

FR-DAT-006 CRUD operations. The module MUST support basic create, read, update, and delete operations that obey the constraints and instructions defined by the table schema. Acceptance criteria: all CRUD operations validate against the schema and refuse changes that violate schema-defined requirements, and update or delete operations are permitted only when the schema explicitly allows them.

FR-DAT-007 Schema inference. The module MUST support initializing a Table Schema by analyzing an existing CSV and inferring field types and constraints. Acceptance criteria: inferred schemas are deterministic for the same input and do not modify the CSV contents.

FR-DAT-008 Type changes with compatibility checks. The module MUST support changing a field type only when the change is non-destructive for existing data. Acceptance criteria: incompatible type changes are rejected with a clear diagnostic, and compatible changes update the schema while leaving table data unchanged.

NFR-DAT-001 Mechanical scope. The module MUST remain a mechanical data layer and MUST NOT implement domain-specific accounting logic. Acceptance criteria: domain invariants are enforced by domain modules, not by `bus-data`.

### System Architecture

Bus Data implements the workspace store interface and dataset I/O mechanics used by other modules. The CLI is a thin wrapper for inspection, validation, and explicit, mechanical schema maintenance and CRUD operations.

### Key Decisions

KD-DAT-001 Shared library for data mechanics. Dataset I/O and schema handling are centralized in a library to keep module behavior consistent.

### Component Design and Interfaces

Interface IF-DAT-001 (data library). The module exposes a Go library interface for reading, validating, and writing tables and schemas deterministically.

Interface IF-DAT-002 (module CLI). The module exposes `bus-data` as a minimal inspection and maintenance CLI for workspace tables and schemas. It accepts a workspace-relative table path that points to a CSV file (for example `accounts.csv`) and resolves the schema beside the table by replacing the `.csv` suffix with `.schema.json` in the same directory. The subcommands are fixed so the surface is deterministic, and explicit commands exist for initialization, schema inference, schema extension, type changes, and row-level CRUD operations. Update and delete operations are allowed only when the schema’s BusDK metadata explicitly permits them.

Command `bus-data table list` takes no parameters and emits a deterministic TSV with columns `table_path` and `schema_path`, one row per table. A table is any `*.csv` file that has a beside-the-table schema file. Output ordering is lexicographic by `table_path` so the results are stable across machines.

Command `bus-data schema show <table>` takes a required table path and writes the schema file content exactly as stored on disk to standard output. If the schema file is missing or unreadable, the command exits non-zero with a concise diagnostic.

Command `bus-data table read <table>` takes a required table path, loads the beside-the-table schema, validates the table against the schema, and writes canonical CSV or JSON to standard output. It preserves the row order from the file and performs no normalization beyond validation. On validation failure, the command exits non-zero and does not emit partial output. Read flags may select specific rows, filters, and columns without changing validation behavior.

Command `bus-data schema init <table>` creates a new CSV file and beside-the-table schema. It writes a header row that matches the schema field order and refuses to overwrite existing files unless explicitly forced.

Command `bus-data schema infer <table>` reads an existing CSV and writes a beside-the-table schema inferred from the data. It does not modify the CSV and refuses to overwrite an existing schema unless explicitly forced.

Command `bus-data schema add-field <table>` appends a new field definition to the schema and updates the CSV by appending a new column. Existing rows receive the field’s default value when provided, or an empty value when no default is specified.

Command `bus-data schema set-type <table>` changes a field type only when the existing values are compatible with the new type. The command updates the schema and does not rewrite table data.

Command `bus-data row add <table>` appends a new row. Row input is provided as repeated `--set col=value` flags or as a JSON object via `--json`. The row is validated against the schema and written in canonical column order.

Command `bus-data row update <table>` replaces or updates a row identified by the primary key. It revalidates the resulting row and writes changes only when the schema permits in-place updates.

Command `bus-data row delete <table>` removes a row identified by the primary key only when the schema permits deletion. Soft deletion uses the schema’s configured soft-delete field and value, while hard deletion removes the row entirely.

Initialization, schema extension, and row mutation commands write or modify files only when explicitly invoked and operate in the same workspace-relative path conventions as the inspection commands. Schema extension only adds columns and must not reorder or delete existing columns. CRUD operations validate against the schema and write changes without altering unrelated rows.

Usage:

```bash
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

### Data Design

The module operates on workspace datasets and beside-the-table schemas (CSV plus Table Schema by default). It may update schema files and table files only when explicitly instructed, including initialization, schema extension, and CRUD actions.

BusDK extends Table Schema metadata with an optional `busdk` object used by `bus-data` to determine whether in-place updates and deletions are permitted. The `busdk.update_policy` field may be `forbid` or `in_place`, and the `busdk.delete_policy` field may be `forbid`, `soft`, or `hard`. When `busdk.delete_policy` is `soft`, `busdk.soft_delete_field` and `busdk.soft_delete_value` must be set so the command can apply a deterministic soft deletion update.

### Assumptions and Dependencies

Bus Data depends on the workspace layout and schema conventions. If datasets or schemas are missing or invalid, the library and CLI return deterministic diagnostics.

### Security Considerations

Bus Data does not perform network or Git operations. It must preserve auditability by refusing invalid or destructive writes.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers. Verbose output is written to standard error so it does not interfere with command results.

### Error Handling and Resilience

Invalid usage exits with status code 2 and a concise usage error. Schema violations or disallowed operations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover schema parsing, deterministic read and write behavior, and validation errors. Command-level tests, if CLI commands exist, validate deterministic output and exit codes.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and library and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic data handling.

### Glossary and Terminology

Workspace store interface: the persistence boundary for deterministic table and schema operations.  
Mechanical data layer: functionality that handles storage and validation without domain rules.  
Schema operation policy: the optional `busdk` metadata in a Table Schema that declares whether in-place update and delete operations are permitted.

### See also

End user documentation: [bus-data CLI reference](../modules/bus-data)  
Repository: https://github.com/busdk/bus-data

For the storage backend boundary and repository rules that the library implements, see [Storage backends and workspace store interface](../data/storage-backends) and [Module repository structure and dependency rules](../implementation/module-repository-structure).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-init">bus-init</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-data module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-DATA`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
Change log: 2026-02-07 — Proposed the BusDK-aligned `bus-data` CLI surface including table, schema, and row verbs with deterministic write options and schema-governed mutability. 2026-02-07 — Defined the minimal `bus-data` inspection subcommands and parameters to close OQ-DAT-001. 2026-02-07 — Reframed the module page as a short SDD with command surface, parameters, and usage examples. 2026-02-07 — Moved module SDDs under `docs/sdd` and linked to end user CLI references.
