## bus-bfl

### Name

`bus bfl` — developer CLI for BusDK Formula Language expressions.

### Synopsis

`bus bfl <command> [options]`  
`bus-bfl <command> [options]`

### Description

BusDK Formula Language (BFL) is a small, deterministic expression language used to define computed fields in workspace datasets. It supports spreadsheet-style references and ranges and can return array values from ranges or registered functions. The `bus-bfl` CLI lets you parse, format, validate, and evaluate BFL expressions from the command line. It does not read workspace datasets or write results back; it operates only on the expression and JSON files you provide. Output goes to standard output unless redirected, and diagnostics go to standard error. Colored output only applies to human-facing text on stderr.

### Getting started

Install the BusDK toolchain and run `bus-bfl` from your PATH, or invoke the binary directly (for example `./bin/bus-bfl`). To see available commands and global flags, run `bus-bfl --help`. To see the tool version, run `bus-bfl --version`. Both help and version exit immediately and ignore any other flags or arguments.

You can control colored output for help and error messages with `--color auto`, `--color always`, or `--color never`. The default is `auto` (color when stderr is a terminal). `--color always` forces ANSI color escapes on stderr diagnostics, while `--color never` disables them. The `--no-color` flag is an alias for `--color never`, and if both are provided, color is disabled. If you pass an invalid color mode, the tool prints a usage error to stderr and exits with status 2. The flags `--quiet` and `--verbose` cannot be used together; combining them is invalid usage and exits with status 2.

Structured command output can be requested with `--format json`. The default format is plain text. If you specify an unsupported format, the tool reports invalid usage and exits with status 2. The short form `--json` is an alias for `--format json`. Format selection affects only command result output and never changes validation behavior or diagnostics.

To send command output to a file instead of stdout, use `--output <file>`. The file is created or truncated. If you also use `--quiet`, the command still runs but nothing is written to the output file or to stdout. If the file cannot be created or written, the tool prints an error to stderr and exits with status 1. Errors are always written to stderr.

When your schema or context files live in another directory, use `--chdir <dir>` so that relative paths are resolved from that directory. The working directory is changed before any file reads. If the directory does not exist or is not accessible, the tool prints an error to stderr and exits with status 1.

If you need to pass arguments that look like flags to a subcommand, use `--` to stop global flag parsing. Everything after `--` is passed to the subcommand as positional arguments and is not interpreted as a global flag, even if it begins with `-`.

The `--help` and `--version` flags are immediate-exit flags. They ignore all other flags and arguments and return status 0. The short forms `-h` and `-V` behave the same way. When a subcommand name is present, help output is for that subcommand and includes its usage, options, and which global flags affect it. The version output is a single line in the form `bus-bfl <version>`. The `--verbose` flag (`-v`) can be repeated and accumulates (`-vv` is verbosity level 2 and `--verbose --verbose` is also level 2); verbose output goes to stderr and does not change the command result on stdout or in `--output`. The `--quiet` flag (`-q`) suppresses normal output to stdout or `--output` but still performs the command work.

### Listing function sets

The compiled-in function sets determine which functions are available in expressions. To list them, run `funcset list`. The default output is one name per line (for example `basic` and `none`). With `--format json` you get a JSON object with a `funcsets` array. The order is deterministic. The default build currently reports `basic` and `none`.

### Parsing expressions

Use `parse` to see how the tool interprets an expression. Give the expression with `--expr` and optionally set a dialect or source name for diagnostics:

```sh
bus-bfl parse --expr "1 + 2"
```

The output is a single line showing the abstract syntax tree, for example `(binary + (literal 1) (literal 2))`. With `--format json` you get a JSON object with an `ast` field whose `expr` property is that same string. The parse command accepts `--dialect <name>` (default `dialect.spreadsheet`) and `--source-name <name>` for diagnostics. If the expression is invalid, the tool prints diagnostics to stderr and exits with a non-zero status; stdout is left empty.

Range expressions are supported using Excel-like A1 notation and the colon operator. Examples include `A1:B10`, `A1:A`, and `A:A`. Parsing a range yields a deterministic AST like `(range A1:B2)`. Range expressions evaluate to array values and can only be used where the language expects an array, such as a function parameter. The core language has no array literals, so arrays are only produced by ranges, by registered functions, or by array-typed symbols supplied through the evaluation context.

### Formatting expressions

Use `format` to rewrite an expression into canonical form (spacing and structure normalized). Pass the expression with `--expr`:

```sh
bus-bfl format --expr "1+2"
```

The result is printed to stdout, for example `1 + 2`. With `--format json` (or `--json`) you get a JSON object with an `expression` field. You can also omit `--expr` and supply the expression on standard input, which is useful in pipelines:

```sh
printf '%s' '1+2' | bus-bfl format
```

The `--dialect` option selects a formatting profile (for example `dialect.sheets_like`). Supported profiles include `dialect.spreadsheet`, `dialect.excel_like`, `dialect.sheets_like`, and `dialect.programmer`. The default is `dialect.spreadsheet`. Range expressions are preserved in canonical form, so `A1:B2` formats as `A1:B2`.

### Validating expressions

Use `validate` to check that an expression parses and typechecks against a schema. You must supply the expression with `--expr` and the schema with `--schema`:

```sh
bus-bfl validate --expr "price * qty" --schema schema.json
```

On success the default output is the single line `ok`. With `--format json` you get `{ "status": "ok" }`. If you omit `--schema`, the tool prints an error to stderr and exits with a non-zero status. Range expressions are accepted when the schema provides a compatible typing environment. Array-typed symbols are accepted when declared in the schema.

The schema file is a JSON object that defines identifiers and their types. For example:

```json
{
  "symbols": {
    "price": { "kind": "number", "nullable": false },
    "qty": { "kind": "integer", "nullable": false }
  }
}
```

Valid `kind` values are `null`, `bool`, `string`, `integer`, `number`, `date`, `datetime`, `array`, and `any`. Each symbol can have `nullable` set to `true` or `false`. Array symbols use `kind: "array"` with an `elem` definition describing the element type.

### Evaluating expressions

Use `eval` to evaluate an expression against a concrete context. You must supply the expression with `--expr` and the context with `--context`. You may optionally supply a schema with `--schema`; if you omit it, the tool infers types from the context.

```sh
bus-bfl eval --expr "price * qty" --context context.json --schema schema.json
```

The default output is a typed value on one line, for example `number 59.85`. Array values are rendered as a shape plus a flattened item list, for example `array 2x2 [integer 1, integer 2, integer 3, integer 4]`. With `--format json` you get a JSON object with `type` and `value` (for example `{ "type": "number", "value": "59.85" }`, or an array value with `rows`, `cols`, and `items`). If you omit `--context`, the tool prints an error to stderr and exits with a non-zero status.

Range evaluation requires a runtime context that can resolve ranges deterministically. If you evaluate an expression containing a range and the context does not provide range resolution, evaluation fails with a deterministic error. Array values in the context must have a consistent `rows`, `cols`, and `items` length; if the shape does not match the item count, evaluation fails with an error.

The context file is a JSON object that supplies values for the symbols used in the expression. Numbers and integers are encoded as strings to preserve precision:

```json
{
  "values": {
    "price": { "type": "number", "value": "19.95" },
    "qty": { "type": "integer", "value": "3" }
  }
}
```

Date values use `YYYY-MM-DD`; datetime values use RFC3339 with an explicit time zone. A null value uses `{ "type": "null", "value": null }`. Array values use `type: "array"` with a `value` object containing `rows`, `cols`, and a row-major `items` array of typed values.

### Exit status

The tool exits with status 0 on success. It exits with status 2 on invalid usage such as invalid `--color`, unknown `--format`, both `--quiet` and `--verbose`, or a subcommand invoked without required arguments after `--` terminates global flag parsing. It exits with status 1 when a required file or directory is missing or unreadable, or when an output file cannot be written. It exits with a non-zero status on parse errors, validation failures, or evaluation failures. Error messages are always written to standard error.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-dev">bus-dev</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [Module SDD: bus-bfl](../sdd/bus-bfl)
- [Data model: Table Schema contract](../data/table-schema-contract)

