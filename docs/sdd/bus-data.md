## bus-data

### Introduction and Overview

Bus Data provides the shared tabular data layer for BusDK by implementing deterministic Frictionless Table Schema and Data Package handling for workspace datasets. Its primary surface is a Go library that other modules import directly for schema, data package, and CSV operations, and it also provides the `bus-data` CLI as a thin wrapper for inspection and mechanical maintenance. The module remains library-first, CLI-first, deterministic, and non-interactive, with no Git or network behavior.

### Requirements

FR-DAT-001 Deterministic dataset I/O. The module MUST provide deterministic read, write, and validation behavior for workspace datasets. Acceptance criteria: table reads and writes are schema-validated and refuse invalid writes, and the same input files and commands yield byte-for-byte identical outputs.

FR-DAT-002 Library-first integration. The Go library MUST be the primary integration surface for other modules. Acceptance criteria: module integrations rely on the library rather than shelling out to the `bus-data` CLI.

FR-DAT-003 Table initialization. The module MUST support initializing a new CSV file alongside a beside-the-table schema file using explicit commands. Acceptance criteria: initialization writes a schema file that matches the table and does not overwrite existing data unless explicitly requested.

FR-DAT-004 Schema extension. The module MUST support extending an existing schema by adding columns through explicit commands. Acceptance criteria: added columns are appended deterministically and existing columns retain their order and definitions.

FR-DAT-005 Row append. The module MUST support appending a new row to an existing CSV through an explicit CLI option. Acceptance criteria: the appended row is validated against the beside-the-table schema and appended in canonical column order without modifying existing rows.

FR-DAT-006 Controlled row mutation. The module MUST support row add, update, and delete operations that obey the constraints and mutation policies defined by the table schema. Acceptance criteria: all row mutations validate against the schema and refuse changes that violate schema-defined requirements, and update or delete operations are permitted only when the schema explicitly allows them, including composite primary keys.

FR-DAT-007 Schema inference. The module MUST support initializing a Table Schema by analyzing an existing CSV and inferring field types and constraints. Acceptance criteria: inferred schemas are deterministic for the same input and do not modify the CSV contents.

FR-DAT-008 Type changes with compatibility checks. The module MUST support changing a field type only when the change is non-destructive for existing data. Acceptance criteria: incompatible type changes are rejected with a clear diagnostic, and compatible changes update the schema while leaving table data unchanged.

FR-DAT-009 Data Package management. The module MUST support creating, reading, updating, and patching `datapackage.json` for workspace datasets. Acceptance criteria: `datapackage.json` can be initialized deterministically, round-tripped without loss of unknown properties, and updated through explicit commands and JSON patches with no interactive prompts.

FR-DAT-010 Resource management. The module MUST support adding, removing, and renaming resources in `datapackage.json` while creating or deleting the underlying CSV and schema artifacts when explicitly requested. Acceptance criteria: resource add creates the CSV and schema artifacts in deterministic locations and names, resource remove refuses when the resource is referenced by any foreign key in the workspace, and resource rename updates foreign key references deterministically.

FR-DAT-011 Complete Table Schema coverage. The module MUST support all Table Schema descriptor attributes, including field descriptors, types and formats, constraints, missingValues, primaryKey, foreignKeys, rdfType, and additional properties beyond the spec. Acceptance criteria: schema show and schema patch round-trip every property without loss, and unknown properties are preserved on write.

FR-DAT-012 Foreign key integrity validation. The module MUST validate foreign key references across resources using the Data Package resource definitions. Acceptance criteria: validation fails deterministically when a referenced resource or key is missing or when key values do not match, and diagnostics identify the resource, field, and key values involved.

FR-DAT-013 Workspace-level validation. The module MUST validate the entire workspace data package across all resources. Acceptance criteria: `datapackage.json` and each resource are validated with deterministic reporting, and any failure returns non-zero without partial writes.

FR-DAT-014 Safe patching and destructive refusal. The module MUST support safe schema and package patching that preserves unknown properties, and it MUST refuse destructive structural operations unless explicitly forced. Acceptance criteria: field removal, resource deletion, and schema changes that would discard data are rejected by default, and only proceed with an explicit force flag after all integrity checks pass, while row-level deletes remain governed by `busdk.delete_policy`.

FR-DAT-015 Non-interactive, flags-only UX. The module MUST operate without prompts and must express every operation as a single deterministic command with explicit flags and arguments. Acceptance criteria: every mutating command supports `--dry-run`, produces deterministic log messages to standard error that describe planned file and schema changes, and does not modify files.

FR-DAT-016 Deterministic serialization. The module MUST serialize schemas and data packages deterministically. Acceptance criteria: JSON output uses UTF-8, LF line endings, two-space indentation, and lexicographic object key ordering; resource arrays are ordered lexicographically by resource name; schema field arrays preserve their declared order.

NFR-DAT-001 Mechanical scope. The module MUST remain a mechanical data layer and MUST NOT implement domain-specific accounting logic. Acceptance criteria: domain invariants are enforced by domain modules, not by `bus-data`.

NFR-DAT-002 No Git or network behavior. The module MUST NOT perform Git operations or network access. Acceptance criteria: the library and CLI only read and write local workspace files.

NFR-DAT-003 Deterministic diagnostics. The module MUST emit deterministic diagnostics with stable identifiers. Acceptance criteria: error messages mention dataset paths, resource names, and field identifiers consistently and are written only to standard error.
NFR-DAT-004 Security boundaries. The module MUST rely on OS-level filesystem permissions and schema-defined mutation policies, and MUST NOT embed authentication or authorization logic. Acceptance criteria: the library and CLI do not prompt for credentials, do not store secrets, and refuse mutations that are not permitted by schema policy.
NFR-DAT-005 Performance. The module SHOULD remain responsive for day-to-day use on typical workspace datasets. Acceptance criteria: table read, validation, and row mutation operations complete in time proportional to table size, and diagnostics remain deterministic regardless of data volume.
NFR-DAT-006 Scalability. The module MUST support workspaces that segment datasets across multiple files without changing the schema contract. Acceptance criteria: `datapackage.json` can reference multiple resources for a module, and validation works across all referenced resources deterministically.
NFR-DAT-007 Reliability. The module MUST fail fast without partial writes when validation or filesystem errors occur. Acceptance criteria: any operation that fails leaves the workspace datasets and schemas unchanged and returns a non-zero exit code.
NFR-DAT-008 Maintainability. The module MUST keep the library as the authoritative integration surface with the CLI as a thin wrapper. Acceptance criteria: the CLI delegates all data and schema logic to library calls, and tests can exercise behavior through library APIs without invoking the CLI.

### System Architecture

Bus Data implements the workspace store interface and dataset I/O mechanics used by other modules, satisfying FR-DAT-001, FR-DAT-002, FR-DAT-009, FR-DAT-012, and FR-DAT-013. The library is the authoritative integration surface for reading, writing, validating, and patching CSV, Table Schema, and Data Package descriptors, satisfying FR-DAT-002, FR-DAT-011, and FR-DAT-016. The CLI delegates directly to the library for inspection, validation, and explicit, mechanical maintenance of schemas, data packages, resources, and rows, satisfying FR-DAT-015 and NFR-DAT-008.

### Key Decisions

KD-DAT-001 Shared library for data mechanics. Dataset I/O and schema handling are centralized in a library to keep module behavior consistent.
KD-DAT-002 Frictionless-native data package support. Data Package descriptors are treated as first-class workspace metadata and remain fully compatible with Frictionless Table Schema and Data Package rules.

### Component Design and Interfaces

Interface IF-DAT-001 (data library). The module exposes a Go library interface for reading, validating, and writing tables, schemas, and data packages deterministically, satisfying FR-DAT-001, FR-DAT-007, FR-DAT-009, FR-DAT-011, and FR-DAT-016. The library provides explicit operations for schema inference, schema patching, resource add/remove/rename, and cross-resource validation, satisfying FR-DAT-007, FR-DAT-009, FR-DAT-010, FR-DAT-012, and FR-DAT-013. JSON patching uses a deterministic, safe merge approach and preserves unknown properties on both Table Schema and Data Package descriptors, satisfying FR-DAT-009, FR-DAT-011, and FR-DAT-014.

Interface IF-DAT-002 (module CLI). The module exposes `bus-data` as a thin wrapper over the library for deterministic inspection and maintenance of workspace tables, schemas, and data packages, satisfying FR-DAT-002, FR-DAT-015, NFR-DAT-003, and NFR-DAT-008. It accepts workspace-relative resource names and table paths, resolves beside-the-table schema files by replacing the `.csv` suffix with `.schema.json` in the same directory, and never shells out to other CLIs. All commands are explicit, non-interactive, and map directly to library operations so that other modules can call the library without invoking the CLI.

Command `bus-data package init` creates `datapackage.json` at the workspace root with the `tabular-data-package` profile and includes one resource entry per existing table that has a beside-the-table schema. Resource names are derived from the CSV basename without the `.csv` suffix, paths are stored as workspace-relative CSV paths, and resources are ordered lexicographically by name. Command `bus-data package show` emits the `datapackage.json` content as stored on disk, and command `bus-data package patch` applies a JSON merge patch while preserving unknown properties and enforcing deterministic formatting. Command `bus-data package validate` validates all resources and foreign keys defined in the data package and returns a deterministic report.

Command `bus-data resource list` emits a deterministic TSV of resource name and path from `datapackage.json`, ordered lexicographically by name. Command `bus-data resource add` requires an explicit resource name, CSV path, and schema source, and creates the CSV and beside-the-table schema artifacts before inserting the resource into `datapackage.json`. Command `bus-data resource remove` refuses to remove a resource if it is referenced by any foreign key in the workspace, and it deletes the CSV and schema artifacts only when `--delete-files` is provided. Command `bus-data resource rename` updates the resource name and any foreign key references deterministically, and it only renames files when `--rename-files` is provided. Command `bus-data resource validate <resource>` validates a single resource’s schema and data and reports any errors deterministically without modifying files.

Command `bus-data table list` takes no parameters and emits a deterministic TSV with columns `table_path` and `schema_path`, one row per table. A table is any `*.csv` file that has a beside-the-table schema file. Output ordering is lexicographic by `table_path` so the results are stable across machines.

Command `bus-data schema show --table <table>` writes the schema file content exactly as stored on disk to standard output. Command `bus-data schema show --resource <name>` resolves the resource in `datapackage.json` and writes the resolved schema. If the schema file is missing or unreadable, the command exits non-zero with a concise diagnostic.

Command `bus-data table read <table>` takes a required table path, loads the beside-the-table schema, validates the table against the schema, and writes canonical CSV or JSON to standard output. It preserves the row order from the file and performs no normalization beyond validation. On validation failure, the command exits non-zero and does not emit partial output. Read flags may select specific rows, filters, and columns without changing validation behavior.

Command `bus-data schema init <table>` creates a new CSV file and beside-the-table schema. It writes a header row that matches the schema field order and refuses to overwrite existing files unless explicitly forced.

Command `bus-data schema infer <table>` reads an existing CSV and writes a beside-the-table schema inferred from the data. It does not modify the CSV and refuses to overwrite an existing schema unless explicitly forced.

Command `bus-data schema field add --resource <name>` appends a new field definition to the schema and updates the CSV by appending a new column. Existing rows receive the field’s default value when provided, or an empty value when no default is specified.

Command `bus-data schema field set-type --resource <name>` changes a field type only when the existing values are compatible with the new type. The command updates the schema and does not rewrite table data.

Schema field remove and rename commands update both the schema and CSV deterministically. Field removal is refused unless `--force` is provided, and even when forced it must still refuse if the change would break primary key or foreign key integrity. Primary key and foreign key commands validate existing data before applying changes, and failures produce deterministic diagnostics without writing.

Command `bus-data row add <table>` appends a new row. Row input is provided as repeated `--set col=value` flags or as a JSON object via `--json`. The row is validated against the schema and written in canonical column order.

Command `bus-data row update <table>` replaces or updates a row identified by the primary key only when schema mutation policy allows in-place updates. Row selection uses repeated `--key field=value` flags in the same order as the schema’s `primaryKey`, and all primary key fields must be provided. It revalidates the resulting row and writes changes only when the schema permits in-place updates.

Command `bus-data row delete <table>` removes a row identified by the primary key only when the schema permits deletion. Row selection uses repeated `--key field=value` flags in the same order as the schema’s `primaryKey`, and all primary key fields must be provided. Soft deletion uses the schema’s configured soft-delete field and value, while hard deletion removes the row entirely.

Initialization, schema extension, package and resource mutation, and row mutation commands write or modify files only when explicitly invoked and operate in the same workspace-relative path conventions as the inspection commands. Schema extension only adds columns and must not reorder or delete existing columns unless explicitly forced and compatible. Row mutation operations validate against the schema and mutation policy and write changes without altering unrelated rows.

Usage:

```bash
bus-data [global flags] <command> [args]

Commands:
  package init                        Initialize datapackage.json deterministically.
  package show                        Print datapackage.json as stored.
  package patch                        Apply a JSON merge patch to datapackage.json.
  package validate                    Validate the full workspace data package.
  resource list                       List resources from datapackage.json.
  resource validate <resource>        Validate a single resource.
  resource add                         Add a resource and create CSV and schema artifacts.
  resource remove <resource>          Remove a resource; refuse if referenced by foreign keys.
  resource rename <resource>          Rename a resource and update references.
  table list                          List tables with beside-the-table schemas.
  table read <table_path>             Validate a table and emit CSV or JSON.
  schema show --table <table_path>    Print the Table Schema JSON for a table.
  schema show --resource <resource>   Print the Table Schema JSON for a resource.
  schema init <table_path>            Initialize a CSV and beside-the-table schema.
  schema infer <table_path>           Infer a schema from an existing CSV.
  schema patch --resource <resource>  Apply a JSON merge patch to a schema.
  schema field add --resource <resource>
  schema field remove --resource <resource>
  schema field rename --resource <resource>
  schema field set-type --resource <resource>
  schema field set-format --resource <resource>
  schema field set-constraints --resource <resource>
  schema field set-missing-values --resource <resource>
  schema key set --resource <resource>
  schema foreign-key add --resource <resource>
  schema foreign-key remove --resource <resource>
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
  -f, --format <format>    Output format: list tsv|json (default tsv), read csv|json (default csv),
                           resource validate tsv|json (default tsv), package validate tsv|json (default tsv).
      --row <n>            (read only) Emit only the nth data row (1-based). Use N:NN for a range.
      --key <field=value>  (read only) Emit only the row matching primary key fields; repeat for composites.
      --filter <col=val>   (read only) Keep rows where column equals value; repeat for AND.
      --column <name>      (read only) Emit only selected columns; repeat to keep multiple.
      Read flags (--row, --key, --filter, --column) may appear before or after the table path.
      --dry-run            Show planned file and schema changes as stderr logs without writing.
      --color <mode>       auto|always|never for stderr messages (default: auto).
      --no-color           Alias for --color=never.
  --                       Stop parsing flags.

Write flags:
  --schema <file>          (schema init, resource add) Source schema JSON to write beside the table.
  --sample <n>             (schema infer) Limit inference to the first n data rows.
  --field <name>           (schema field commands) Field name to append or update.
  --type <type>            (schema field commands) Field type to append or apply.
  --format <format>        (schema field commands) Field format to apply.
  --constraints <json>     (schema field commands) JSON object for field constraints.
  --missing-values <json>  (schema field commands) JSON array for missingValues.
  --required               (schema field add) Mark the field as required.
  --description <text>     (schema field add) Field description text.
  --rdf-type <uri>         (schema field add) rdfType to apply.
  --default <value>        (schema field add) Default value written to existing rows.
  --key <field=value>      (row update/delete) Select a row by primary key; repeat for composites.
  --set <col=val>          (row add/update) Set a column value; repeatable.
  --json <file>            (row add/update) JSON object row input; use - for stdin.
  --patch <file>           (package patch, schema patch) JSON merge patch file.
  --resource <name>        (schema, resource commands) Resource name in datapackage.json.
  --name <name>            (resource add/rename) Resource name to add or set.
  --path <path>            (resource add) CSV path relative to workspace root.
  --delete-files           (resource remove) Delete CSV and schema artifacts.
  --rename-files           (resource rename) Rename CSV and schema to match resource name.
  --primary <fields>       (schema key set) Comma-separated primary key fields.
  --reference <resource>   (schema foreign-key add) Referenced resource name.
  --reference-fields <fields>
                           (schema foreign-key add) Comma-separated referenced fields.
  --force                  Allow destructive operations and overwrites.

Examples:
  bus-data -vv table list
  bus-data --format json resource list
  bus-data table read people
  bus-data --format json --filter name=alice --row 1 table read people
  bus-data --key id=p-001 --column name --column age table read people
  bus-data package init
  bus-data resource add --name people --path people.csv --schema people.schema.json
  bus-data schema init people --schema people.schema.json
  bus-data schema infer people
  bus-data schema field add --resource people --field nickname --type string
  bus-data schema field set-type --resource people --field age --type integer
  bus-data row add people --set id=p-001 --set name=Alice
  bus-data row update people --key id=p-001 --set name=Alice A.
  bus-data row delete people --key id=p-001
  bus-data -- table read --weird.csv   (use -- when the table path starts with '-')
```

### Data Design

The module operates on workspace datasets as CSV resources with beside-the-table Table Schema JSON files. The canonical schema for a table is the beside-the-table file with the `.schema.json` suffix. A workspace `datapackage.json` is stored at the workspace root and references resources by a deterministic name and a relative `path` to the CSV file. Resource names default to the CSV basename without the `.csv` suffix, and paths are stored as workspace-relative CSV paths. Each resource embeds its Table Schema descriptor inline, sourced from the beside-the-table schema file; when schema changes are applied, the schema file and the embedded resource schema are updated together to remain consistent.

BusDK extends Table Schema metadata with a `busdk` object used by `bus-data` to determine whether in-place updates and deletions are permitted. The `busdk.update_policy` field may be `forbid` or `in_place`, and the `busdk.delete_policy` field may be `forbid`, `soft`, or `hard`. When `busdk.delete_policy` is `soft`, `busdk.soft_delete_field` and `busdk.soft_delete_value` must be set so the command can apply a deterministic soft deletion update, and the updated row must still satisfy schema constraints and key uniqueness. The default is that updates and deletions are forbidden unless the schema explicitly enables them, and the CLI provides explicit schema commands to set or change these policies. The `busdk` extension coexists with Frictionless descriptors and is preserved verbatim when schemas and data packages are rewritten.

Bus Data owns mechanical concerns only: reading and writing CSV, reading and writing schema JSON, creating and patching `datapackage.json`, enforcing Table Schema constraints, and validating foreign key integrity. Domain modules own business rules, domain invariants, and any accounting classification decisions; `bus-data` does not infer or enforce those semantics.

### Assumptions and Dependencies

Bus Data depends on the workspace layout conventions for CSV, beside-the-table schema files, and an optional `datapackage.json` at the workspace root. If datasets or schemas are missing or invalid, the library and CLI return deterministic diagnostics and do not modify files.

### Security Considerations

Bus Data does not perform network or Git operations. It preserves auditability by refusing invalid or destructive writes, requiring explicit force flags for destructive operations, and supporting `--dry-run` for all mutating commands.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths, resource names, and identifiers. Verbose output is written to standard error so it does not interfere with command results. Diagnostics are stable and citeable so tests and automated tools can rely on them.

### Error Handling and Resilience

Invalid usage exits with status code 2 and a concise usage error. Schema violations, foreign key integrity failures, disallowed mutation attempts, or filesystem errors exit non-zero without modifying datasets, schemas, or `datapackage.json`, and without emitting partial output.

### Testing Strategy

Unit tests cover Table Schema and Data Package parsing, safe patching with preservation of unknown properties, deterministic JSON serialization, deterministic CSV write behavior, schema inference determinism, and foreign key validation logic. Command-level end-to-end tests validate outputs, exit codes, and on-disk changes using fixture workspaces, including at least one test that verifies cross-resource foreign key integrity and one test that proves resource deletion is refused when referenced.

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
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bfl">bus-bfl</a> &rarr;</span>
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
