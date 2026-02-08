## bus-bfl

### Name

`bus bfl` — developer CLI for BusDK Formula Language expressions.

### Synopsis

`bus bfl <command> [options]`  
`bus-bfl <command> [options]`

### Description

BusDK Formula Language (BFL) is a small, deterministic expression language used to define computed fields in workspace datasets. The `bus-bfl` CLI lets you parse, format, validate, and evaluate BFL expressions from the command line. It does not read workspace datasets or write results back; it operates only on the expression and JSON files you provide. Output goes to standard output and diagnostics to standard error.

### Getting started

Install the BusDK toolchain and run `bus-bfl` from your PATH, or invoke the binary directly (for example `./bin/bus-bfl`). To see available commands and global flags, run `bus-bfl --help`. To see the tool version, run `bus-bfl --version`. Both help and version exit immediately and ignore any other flags or arguments.

You can control colored output for help and error messages with `--color auto`, `--color always`, or `--no-color`. The default is `auto` (color when stderr is a terminal). If you pass an invalid color mode, the tool prints a usage error to stderr and exits with status 2. The flags `--quiet` and `--verbose` cannot be used together; combining them is invalid usage.

Structured command output can be requested with `--format json`. The default format is plain text. If you specify an unsupported format, the tool reports invalid usage and exits with status 2. The short form `--json` is an alias for `--format json`.

To send command output to a file instead of stdout, use `--output <file>`. The file is created or truncated. If you also use `--quiet`, the command still runs but nothing is written to the output file or to stdout. Errors are always written to stderr.

When your schema or context files live in another directory, use `--chdir <dir>` so that relative paths are resolved from that directory. The working directory is changed before any file reads.

If you need to pass arguments that look like flags to a subcommand, use `--` to stop global flag parsing. Everything after `--` is passed to the subcommand as positional arguments.

### Listing function sets

The compiled-in function sets determine which functions are available in expressions. To list them, run `funcset list`. The default output is one name per line (for example `basic` and `none`). With `--format json` you get a JSON object with a `funcsets` array. The order is deterministic.

### Parsing expressions

Use `parse` to see how the tool interprets an expression. Give the expression with `--expr`:

```text
bus-bfl parse --expr "1 + 2"
```

The output is a single line showing the abstract syntax tree, for example `(binary + (literal 1) (literal 2))`. With `--format json` you get a JSON object with an `ast` field whose `expr` property is that same string. If the expression is invalid, the tool prints diagnostics to stderr and exits with a non-zero status; stdout is left empty.

### Formatting expressions

Use `format` to rewrite an expression into canonical form (spacing and structure normalized). Pass the expression with `--expr`:

```text
bus-bfl format --expr "1+2"
```

The result is printed to stdout, for example `1 + 2`. With `--format json` (or `--json`) you get a JSON object with an `expression` field. You can also omit `--expr` and supply the expression on standard input, which is useful in pipelines:

```text
printf '%s' '1+2' | bus-bfl format
```

The `--dialect` option selects a formatting profile (for example `dialect.sheets_like`). Supported profiles include `dialect.spreadsheet`, `dialect.excel_like`, `dialect.sheets_like`, and `dialect.programmer`. The default is `dialect.spreadsheet`.

### Validating expressions

Use `validate` to check that an expression parses and typechecks against a schema. You must supply the expression with `--expr` and the schema with `--schema`:

```text
bus-bfl validate --expr "price * qty" --schema schema.json
```

On success the default output is the single line `ok`. With `--format json` you get `{ "status": "ok" }`. If you omit `--schema`, the tool prints an error to stderr and exits with a non-zero status.

The schema file is a JSON object that defines identifiers and their types. For example:

```json
{
  "symbols": {
    "price": { "kind": "number", "nullable": false },
    "qty": { "kind": "integer", "nullable": false }
  }
}
```

Valid `kind` values are `null`, `bool`, `string`, `integer`, `number`, `date`, `datetime`, and `any`. Each symbol can have `nullable` set to `true` or `false`.

### Evaluating expressions

Use `eval` to evaluate an expression against a concrete context. You must supply the expression with `--expr` and the context with `--context`. You may optionally supply a schema with `--schema`; if you omit it, the tool infers types from the context.

```text
bus-bfl eval --expr "price * qty" --context context.json --schema schema.json
```

The default output is a typed value on one line, for example `number 59.85`. With `--format json` you get a JSON object with `type` and `value` (for example `{ "type": "number", "value": "59.85" }`). If you omit `--context`, the tool prints an error to stderr and exits with a non-zero status.

The context file is a JSON object that supplies values for the symbols used in the expression. Numbers and integers are encoded as strings to preserve precision:

```json
{
  "values": {
    "price": { "type": "number", "value": "19.95" },
    "qty": { "type": "integer", "value": "3" }
  }
}
```

Date values use `YYYY-MM-DD`; datetime values use RFC3339 with an explicit time zone. A null value uses `{ "type": "null", "value": null }`.

### Exit status

The tool exits with status 0 on success. It exits with a non-zero status on parse errors, validation or evaluation failures, invalid usage (for example invalid `--color`, unknown `--format`, or both `--quiet` and `--verbose`), or when a required file is missing or unreadable. Error messages are always written to standard error.

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
