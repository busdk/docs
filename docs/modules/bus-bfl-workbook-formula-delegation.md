---
title: Formula metadata and evaluation for workbook extraction
description: How consumers such as bus-data delegate formula evaluation to BFL so workbook extraction and table read produce deterministic, formula-driven results for parity workflows.
---

## Overview

This document describes how consumers (such as [bus-data](https://docs.busdk.com/modules/bus-data)) delegate formula evaluation to the BFL library so that workbook extraction and table read produce deterministic, formula-driven results. It supports parity with formula-driven report totals in source spreadsheets.

The audience is BusDK module maintainers integrating BFL for table projection and workbook-style read (e.g. `bus data table workbook --formula`). Canonical API and language semantics remain the [module SDD](https://docs.busdk.com/sdd/bus-bfl).

### Delegation contract

**Determinism.** For the same expression, context, dialect, function set, and rounding policy, BFL returns the same result across runs and machines for a given BusDK version. To achieve parity with a given workbook, the consumer must use the same dialect (including locale) and, when formulas use functions, the same function set as the source.

**Consumer responsibilities.** The consumer is responsible for discovering formula fields from schema metadata; building dialect and options from schema and source locale; building symbol table and runtime context from the current row and table; and calling BFL’s Parse → Compile → Eval pipeline.

**bus-bfl.** The library is pure and data-source-agnostic. It accepts expression source strings and caller-provided context (symbols, types, registered functions). It does not read CSV, Table Schema, or workspace paths.

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

Invalid rounding or result type in the schema must be rejected at validation time before any evaluation. The normative metadata shape and semantics are in the [bus-bfl SDD — Schema representation](https://docs.busdk.com/sdd/bus-bfl#schema-representation-busdk-extension).

### Locale-aware evaluation

Formula source text may contain locale-dependent numeric literals (e.g. `3,14` with comma as decimal separator, or `1.234,56` with thousands separator). BFL does not infer locale from the machine; the consumer must set the dialect explicitly.

For workbook extraction parity with a given source (Excel, Google Sheets, or locale-specific export):

1. **Dialect profile:** Use `dialect.excel_like` or `dialect.sheets_like` when operator token rules (e.g. equality `=` vs `==`) must match the source; otherwise `dialect.spreadsheet` is the default.
2. **Thousands separator:** If the source uses thousands separators in literals, set `Dialect.AllowThousandsSeparator = true` and `Dialect.ThousandsSeparator` (e.g. ` ` or `,`) to match the source.
3. **Decimal separator:** Set `Dialect.DecimalSeparator` from the source locale (e.g. `,` for many European locales, `.` for en-US).

Example: for a CSV exported from a locale that uses `,` as decimal separator, set `DecimalSeparator: ","` (and optionally thousands separator) on the dialect so a formula such as `=A1 * 2,5` parses and evaluates correctly.

Display vs evaluation: workbook read may normalize raw cell values for display separately; formula evaluation uses the dialect’s decimal and thousands separators for parsing the expression text only.

### Function set for report totals

BFL has **no built-in functions**. All function calls (e.g. `SUM(A1:A10)`, `IF(condition, then, else)`) must be supplied by the consumer via a `FunctionRegistry` passed to `CompileOptions.Functions`. If no registry is provided or a name is not registered, Compile fails with a deterministic bind error.

For **formula-driven report totals** and common workbook-style expressions to be reproducible in Bus parity workflows, the consumer should register a minimal set of functions. Recommended names and intent (implementation is in the consumer or a shared package, not in bus-bfl):

| Function | Purpose | Notes |
|----------|---------|-------|
| `SUM` | Sum of numeric values in a range or array | Signature: single argument of kind `array` (or range), return `number`. |
| `IF` | Conditional value | Signature: (condition: bool, thenValue: any, elseValue: any) → any. |
| `ROUND` | Round a number to a given scale | Signature: (number, scale: integer) → number. |

Additional functions (e.g. `AVERAGE`, `MIN`, `MAX`, `COUNT`) can be added by the consumer for closer parity with a specific source. BFL’s type system and `Registry` support overloads and varargs as defined in the SDD; the consumer is responsible for implementing them in a pure, deterministic way.

Use the same function set for both validation and evaluation when integrating with bus-data workbook read or table read.

### Relation to bus-data and FR-DAT-025

Formula evaluation for table read and workbook-style read (`bus data table workbook --formula`, `--formula-source`) is specified in the bus-data module and aligns with FR-DAT-025. bus-data owns discovery of formula fields from schema, building dialect and options from schema and locale, and registering the function set; it delegates parsing, compilation, and evaluation to the BFL library per this contract.

For the integration contract and Table Schema formula metadata, see [IF-BFL-002 Integration contract with bus-data](https://docs.busdk.com/sdd/bus-bfl#if-bfl-002-integration-contract-with-bus-data) and the [Table Schema formula metadata](https://docs.busdk.com/sdd/bus-bfl#schema-representation-busdk-extension) in the bus-bfl SDD.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bfl">bus-bfl</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-data (module CLI)](https://docs.busdk.com/modules/bus-data)
- [bus-data (module SDD)](https://docs.busdk.com/sdd/bus-data)
- [bus-bfl (module SDD)](https://docs.busdk.com/sdd/bus-bfl)
- [Table Schema contract](https://docs.busdk.com/data/table-schema-contract)
