## bus-bfl

### Name

`bus bfl` — developer CLI for BusDK Formula Language expressions.

### Synopsis

`bus bfl <command> [options]`  
`bus-bfl <command> [options]`

### Description

BusDK Formula Language (BFL) is a small, deterministic expression language used to define computed fields in workspace datasets. It is not a general programming language and has no I/O, no external state, and no side effects. The primary integration surface is the Go library, which is used by `bus-data` for validation and read-time projection. The `bus bfl` and `bus-bfl` CLI surface is an optional, lightweight developer wrapper around the library and is not a production integration surface.

The CLI mirrors the library pipeline and operates only on explicit inputs supplied by the caller. It does not read workspace datasets, Table Schema files, or `datapackage.json`, and it never writes computed values back to repository data. Results are written to standard output and diagnostics to standard error using BusDK exit code conventions.

### Commands

- `parse` parses the expression and reports deterministic syntax diagnostics.
- `validate` parses and typechecks the expression against a caller-provided context schema and the compiled-in function set.
- `eval` evaluates the expression against a caller-provided context and prints the typed result.
- `format` rewrites the expression into its canonical form using the selected dialect.

### Formula storage and schema metadata

BFL formula storage and schema metadata are defined by `bus-data` and the BFL SDD. The CLI does not read or interpret workspace schemas, and it only evaluates the explicit expression and JSON inputs provided by the caller.

### Options

The CLI accepts only explicit inputs such as an expression string and optional JSON files for context or schema data. It never discovers workspace data implicitly.

- `--expr <string>` supplies the expression directly. If omitted, the expression is read from standard input.
- `--dialect <profile>` selects a dialect profile. The default is `dialect.spreadsheet`. Supported profiles are `dialect.spreadsheet`, `dialect.excel_like`, `dialect.sheets_like`, and `dialect.programmer`.
- `--schema <file>` supplies a context schema for `validate`.
- `--context <file>` supplies a concrete context for `eval`.

### Examples

This workflow validates and evaluates a row-local formula with explicit JSON inputs:

```text
bus-bfl validate --expr 'price * qty' --schema schema.json
bus-bfl eval --expr 'price * qty' --context context.json
```

The schema file defines the available identifiers and their types:

```json
{
  "symbols": {
    "price": { "kind": "number", "nullable": false },
    "qty": { "kind": "integer", "nullable": false }
  }
}
```

The context file supplies typed values for evaluation. Numbers and integers are encoded as strings to preserve decimal precision:

```json
{
  "values": {
    "price": { "type": "number", "value": "19.95" },
    "qty": { "type": "integer", "value": "3" }
  }
}
```

Successful evaluation prints a typed value to standard output:

```json
{ "type": "number", "value": "59.85" }
```

### Input formats

The CLI uses a small JSON schema for schema and context files that mirrors the BFL type and value model.

Context schema files contain a `symbols` map from identifier to type. Each type has `kind` and `nullable` fields. Valid `kind` values are `null`, `bool`, `string`, `integer`, `number`, `date`, `datetime`, and `any`.

Context files contain a `values` map from identifier to value. Each value uses `{ "type": "<kind>", "value": "<literal>" }` and matches the same `kind` strings as the schema. `number` and `integer` values are encoded as strings. `date` uses `YYYY-MM-DD`. `datetime` uses RFC3339 with an explicit `Z` or numeric offset. `null` uses `{ "type": "null", "value": null }`.

### Defaults and limits

The CLI uses the BFL defaults unless explicit overrides are added in a future interface. Expression length defaults to 4,096 UTF-8 bytes, AST size defaults to 512 nodes, recursion depth defaults to 32, and evaluation steps default to 10,000.

### Files

The developer CLI reads only the explicit inputs you provide, such as an expression string and JSON files, and it does not read workspace CSV, Table Schema files, or `datapackage.json`. Computed values are printed to standard output and never written back to the repository data.

### Exit status

`0` on success. Non-zero on parse, validation, or evaluation errors, or on invalid usage.

### Open Questions

OQ-BFL-CLI-001 Confirm the command and flag names for the initial CLI release, including whether `--expr`, `--schema`, `--context`, and `--dialect` should be part of the stable interface.

OQ-BFL-CLI-002 Confirm that the JSON formats shown for schema and context files should be the canonical CLI input format, aligned with the conformance test value encoding.

OQ-BFL-CLI-003 Confirm that `parse` and `validate` should emit a structured JSON success response or a simple text confirmation, and whether `format` should emit only the canonical expression.

OQ-BFL-CLI-004 Confirm whether the CLI should expose a way to select or list the compiled-in function set.
git 
### See also

Module SDD: [bus-bfl](../sdd/bus-bfl)  
Data model: [Table Schema contract](../data/table-schema-contract)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-data">bus-data</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
