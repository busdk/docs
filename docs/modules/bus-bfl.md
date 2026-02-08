## bus-bfl

### Name

`bus bfl` — developer CLI for BusDK Formula Language expressions.

### Synopsis

`bus bfl <command> [options]`  
`bus-bfl <command> [options]`

### Description

BusDK Formula Language (BFL) is a small, deterministic expression language used to define computed fields in workspace datasets. It is not a general programming language and has no I/O, no external state, and no side effects. End users interact with BFL by placing formula metadata in Table Schema field descriptors and by storing formula source strings in CSV cells when a field is configured for inline formulas. The `bus bfl` and `bus-bfl` CLI surface is a lightweight developer and debugging tool for these expressions and is not a production integration surface.

BFL is consumed by `bus-data` and `bus-validate` as part of schema validation and table reads. Validation checks that formulas are well-formed, that references resolve, and that result types match the declared output type. Projection computes formula results at read time without writing back to CSV, so the repository data remains the source of truth and computed values remain a derived view. The developer CLI runs the same parse, validate, and evaluation pipeline as the Go library, but it only operates on the explicit expression and JSON inputs you provide and never attempts to read or discover workspace data.

### Commands

- `parse` inspects the expression and prints a deterministic AST, with location-aware diagnostics when syntax errors occur.
- `validate` checks unknown identifiers, type errors, and unregistered functions against a caller-provided context schema and function set.
- `eval` evaluates the expression against a concrete context and prints the typed result, optionally including the resolved type.
- `format` rewrites the expression into a canonical form for diffing and reproducibility when canonicalization is needed.
- `funcset list` prints the function sets available in the current build so you can select one explicitly.

### Formula storage and schema metadata

BFL formulas are stored as UTF-8 strings and described via BusDK metadata in Frictionless Table Schema field descriptors. Inline formulas store the expression in each row, while constant formulas store the expression in schema metadata and apply it to every row.

```json
{
  "name": "total",
  "type": "string",
  "busdk": {
    "semantic_type": "formula",
    "formula": {
      "language": "bfl",
      "mode": "inline",
      "result": { "type": "number" },
      "on_error": "fail"
    }
  }
}
```

For constant formulas, set `mode` to `constant` and provide the expression in `formula.expression`. The stored CSV value remains the formula source when inline mode is used, and the computed value is validated against the declared `result` type without changing the stored data.

### Options

Use `--expr <string>` to provide the expression directly. If `--expr` is omitted, the expression is read from standard input, which keeps scripted workflows minimal and explicit.

Use `--schema <file>` to provide a context schema for `validate`, and `--context <file>` to provide concrete JSON values for `eval`. The schema and context are caller-provided JSON documents and are not inferred from workspace data.

Use `--funcset <name>` to select the registered function set, or `funcset list` to discover which sets are available in the current build.

Output defaults to deterministic, human-readable text. Use `--json` for machine-readable output that includes structured diagnostics, ASTs, and typed results.

### Examples

```text
bus-bfl validate --expr 'a + b' --schema context.json --funcset none
```

```text
bus-bfl eval --expr 'price * qty' --context row.json --funcset gsheets
```

### Files

The developer CLI reads only the explicit inputs you provide, such as the expression string and JSON files for schema or context, and it does not read workspace CSV, Table Schema files, or `datapackage.json`. Computed values are printed to standard output and never written back to the repository data.

### Exit status

`0` on success. Non-zero on parse, validation, or evaluation errors, or on invalid usage.

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
