## bus-data

### Name

`bus data` — inspect workspace datasets and schemas.

### Synopsis

`bus data <command> [options]`  
`bus data list`  
`bus data schema <table>`  
`bus data read <table>`

### Description

`bus data` is a minimal, read-only CLI for workspace tables and schemas. It lists tables, prints schema content, and validates and emits canonical CSV. Other BusDK modules use the bus-data library for dataset I/O; this CLI is for inspection and scripting.

### Commands

- `list` prints a TSV of `table_path` and `schema_path` for every CSV that has a beside-the-table schema. Order is lexicographic by table path.
- `schema <table>` writes the schema file content for the given table path to stdout.
- `read <table>` validates the table against its schema and writes canonical CSV to stdout. Exits non-zero on validation failure.

### Options

`list` has no options. `schema` and `read` take a workspace-relative table path (e.g. `accounts/accounts.csv`). For global flags and command-specific help, run `bus data --help`.

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
