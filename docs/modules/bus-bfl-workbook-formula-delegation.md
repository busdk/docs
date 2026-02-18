---
title: Formula metadata and evaluation for workbook extraction
description: How consumers such as bus-data delegate formula evaluation to BFL so workbook extraction and table read produce deterministic, formula-driven results for parity workflows.
---

## Overview

This document describes how consumers (such as [bus-data](./bus-data)) can delegate formula evaluation to the BFL library so that **workbook extraction** and table read produce deterministic, formula-driven results. It supports parity workflows where formula-driven report totals in source spreadsheets are reproduced in BusDK.

**Audience:** BusDK module maintainers integrating BFL for table projection and workbook-style read (e.g. `bus data table workbook --formula`). The canonical API and language semantics remain the [module SDD](../sdd/bus-bfl).

### Delegation contract

- **bus-bfl** provides a pure, data-source-agnostic library: it accepts expression source strings and caller-provided context (symbols, types, registered functions). It does not read CSV, Table Schema, or workspace paths.
- **bus-data** (or another consumer) owns: discovering formula fields from schema metadata, building dialect and options from schema and locale, building symbol table and runtime context from the current row and table, and calling BFL’s Parse → Compile → Eval pipeline.
- **Determinism:** For the same expression, context, dialect, function set, and rounding policy, BFL returns the same result across runs and machines for a given BusDK version. To achieve parity with a given workbook, the consumer must use the same dialect (including locale) and, when formulas use functions, the same function set as the source.

### Formula metadata (schema → BFL options)

Formula semantics are declared in Frictionless Table Schema via BusDK metadata on field descriptors. The consumer maps this metadata into BFL options as follows.

| Schema / source | BFL usage |
|-----------------|-----------|
| `field.busdk.formula.mode` | `"inline"`: expression source = cell value for that row. `"constant"`: expression source = `field.busdk.formula.expression` for all rows. |
| `field.busdk.formula.expression` | Required when mode is `constant`; used as the expression source for every row. |
| `field.busdk.formula.prefix` | Set `Dialect.StripFormulaPrefix` so a leading prefix (e.g. `=`) is stripped before parsing when present. |
| `field.busdk.formula.result` | Declared result type; map to `SymbolTable` and use to validate the evaluated value. |
| `field.busdk.formula.rounding` | Map to `EvalOptions.Rounding` (scale and mode: `half_up` / `half_even`). Omit when not set so BFL defaults apply. |
| `field.busdk.formula.on_error` | `"fail"`: surface evaluation errors. `"null"`: on evaluation error return null when result type is nullable. |

The normative metadata shape and semantics are defined in the [bus-bfl SDD — Schema representation](../sdd/bus-bfl#schema-representation-busdk-extension). Invalid rounding or result type in the schema must be rejected at validation time before any evaluation.

### Locale-aware evaluation

Formula **source text** may contain locale-dependent numeric literals (e.g. `3,14` with comma as decimal separator, or `1.234,56` with thousands separator). BFL does not infer locale from the machine; the consumer must set the dialect explicitly.

For **workbook extraction parity** with a given source (Excel, Google Sheets, or locale-specific export):

1. **Decimal separator** — Set `Dialect.DecimalSeparator` from the source locale (e.g. `,` for many European locales, `.` for en-US). This affects how numeric literals inside the formula string are parsed.
2. **Thousands separator** — If the source uses thousands separators in literals, set `Dialect.AllowThousandsSeparator = true` and `Dialect.ThousandsSeparator` (e.g. ` ` or `,`) to match the source.
3. **Dialect profile** — Use `dialect.excel_like` or `dialect.sheets_like` when operator token rules (e.g. equality `=` vs `==`) must match the source; otherwise `dialect.spreadsheet` is the default.

Example: for a CSV exported from a locale that uses `,` as decimal separator, the consumer should set `DecimalSeparator: ","` (and optionally thousands separator) on the dialect used for Parse and Compile, so that a formula such as `=A1 * 2,5` parses and evaluates correctly.

**Display vs evaluation:** Workbook read may also normalize **raw cell values** for display (e.g. `--decimal-sep` for output). That is separate from formula evaluation: formula **evaluation** uses the dialect’s decimal/thousands separators for parsing the **expression text**; raw value normalization is a consumer-side display concern.

### Function set for report totals

BFL has **no built-in functions**. All function calls (e.g. `SUM(A1:A10)`, `IF(condition, then, else)`) must be supplied by the consumer via a `FunctionRegistry` passed to `CompileOptions.Functions`. If no registry is provided or a name is not registered, Compile fails with a deterministic bind error.

For **formula-driven report totals** and common workbook-style expressions to be reproducible in Bus parity workflows, the consumer should register a minimal set of functions. Recommended names and intent (implementation is in the consumer or a shared package, not in bus-bfl):

| Function | Purpose | Notes |
|----------|---------|--------|
| `SUM` | Sum of numeric values in a range or array | Signature: single argument of kind `array` (or range), return `number`. |
| `IF` | Conditional value | Signature: (condition: bool, thenValue: any, elseValue: any) → any. |
| `ROUND` | Round a number to a given scale | Signature: (number, scale: integer) → number; use dialect or EvalOptions rounding when scale omitted if desired. |

Additional functions (e.g. `AVERAGE`, `MIN`, `MAX`, `COUNT`) can be added by the consumer for closer parity with a specific source. BFL’s type system and `Registry` support overloads and varargs as defined in the SDD; the consumer is responsible for implementing them in a pure, deterministic way.

When integrating with bus-data workbook read or table read, the same function set must be used for both validation and evaluation so that formulas that use these functions compile and run deterministically.

### Summary

- **Metadata → options:** Map `field.busdk.formula.*` to Dialect (prefix, and optionally locale), EvalOptions.Rounding, and on_error behavior.
- **Locale:** Set `Dialect.DecimalSeparator` (and optionally thousands separator and profile) from the source locale so formula source text parses correctly.
- **Functions:** Register a minimal set (e.g. SUM, IF, ROUND) in the consumer so report-style formulas can be evaluated; BFL does not ship built-ins.
- **Determinism:** Same expression, context, dialect, function set, and rounding yield the same result; use consistent options for parity with the source workbook.

This contract aligns with [IF-BFL-002 Integration contract with bus-data](../sdd/bus-bfl#if-bfl-002-integration-contract-with-bus-data) and the [Table Schema formula metadata](../sdd/bus-bfl#schema-representation-busdk-extension) defined in the SDD.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bfl">bus-bfl</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-data (module CLI)](./bus-data)
- [bus-bfl (module SDD)](../sdd/bus-bfl)
- [Table Schema contract](../data/table-schema-contract)
