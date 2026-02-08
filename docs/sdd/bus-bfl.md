## bus-bfl

### Introduction and Overview

BusDK Formula Language (BFL) is a small, deterministic expression language for [BusDK workspaces](../overview/index). It is designed for spreadsheet-style formulas and simple predicates expressed as UTF-8 strings. BFL is not a general programming language and has no I/O, no reflection, no loops, and no time-dependent behavior. The intended users are BusDK module developers and maintainers who need deterministic formula evaluation inside the [workspace datasets](../data/index). This document defines the BFL design so that consumers can implement and verify formula behavior consistently.

BFL exists because Frictionless [Table Schema](../data/table-schema-contract) and [Data Package](../data/data-package-organization) descriptors define typing, constraints, and relationships, but they do not define computed fields as a first-class concept. BusDK implements formulas using Frictionless descriptor extensibility — [Table Schema field descriptors](../data/table-schema-contract) may contain additional properties. BFL provides the deterministic expression semantics for those properties.

The primary surface is a Go library that other BusDK modules import directly. BFL is intended to be used by [bus-data](./bus-data) and other modules as a pure evaluation engine.

Versioning follows BusDK versioning. BFL expressions do not carry an internal language version tag. Any changes to BFL semantics must be managed through BusDK module versioning and documented as behavior changes. Out of scope are domain-specific accounting rules, cross-row aggregation, any built-in function set, and any feature that requires external state or side effects.

### Requirements

FR-BFL-001 Deterministic evaluation. The module MUST provide deterministic parsing and evaluation for identical inputs. Acceptance criteria: evaluation results are identical across machines for the same expression and the same input context when using the same BusDK version of the BFL implementation.

FR-BFL-002 Pure and safe evaluation. The module MUST NOT perform network I/O, filesystem I/O, environment access, subprocess execution, or any other side effects. Acceptance criteria: evaluation is a pure function of (expression, context) and cannot access external state.

FR-BFL-003 Library-first integration. The Go library MUST be the primary integration surface for other BusDK modules. Acceptance criteria: `bus-data` and other modules can parse, validate, and evaluate BFL without shelling out to a CLI.

FR-BFL-004 Spreadsheet-style formulas. The module MUST support spreadsheet-style expressions, including arithmetic, comparisons, boolean logic, and conditional evaluation. Acceptance criteria: the language supports a stable set of operators and pure functions and rejects unsupported constructs deterministically.

FR-BFL-005 Row-local formulas. The system MUST support formulas stored per-row (per-cell) where different rows may contain different expressions for the same field. Acceptance criteria: two rows in the same column may evaluate different formulas correctly and independently.

FR-BFL-006 Static validation. The library MUST support validating formulas without mutating data. Acceptance criteria: callers can detect parse errors, unknown references, and type errors deterministically before evaluation.

FR-BFL-007 Data-source agnostic. The library MUST NOT know about CSV, Frictionless schemas, BusDK workspaces, or any file formats. Acceptance criteria: the public API accepts expression source strings and caller-provided context definitions without referencing any BusDK storage or schema types.

FR-BFL-008 Function registration framework. The library MUST provide a function registration framework in which callers supply function names, signatures, and pure implementations. Acceptance criteria: validation and evaluation only allow registered functions, and unregistered function calls are rejected deterministically.

NFR-BFL-001 Mechanical scope only. The module MUST NOT implement accounting rules, discretionary accounting judgments, or domain-specific semantics. Acceptance criteria: the API only exposes expression mechanics and generic type and constraint handling required by the language.

NFR-BFL-002 Security and sandboxing. The module MUST prevent access to external state and must bound resource usage for expression parsing and evaluation. Acceptance criteria: the implementation rejects expressions that exceed configured limits on AST size, recursion depth, or evaluation steps and reports a deterministic error without partial results.

NFR-BFL-003 Performance. Parsing and evaluation MUST meet agreed performance targets for typical workspace datasets. Acceptance criteria: TBD — define target expression sizes, acceptable parse and evaluation latency, and any required benchmarks.

NFR-BFL-004 Scalability. Evaluation MUST remain deterministic and bounded as datasets grow. Acceptance criteria: TBD — define supported dataset sizes and per-row evaluation overhead expectations.

NFR-BFL-005 Reliability. The library MUST return typed errors for invalid inputs and MUST NOT panic on user-provided expressions. Acceptance criteria: invalid inputs return deterministic parse, bind, type, or evaluation errors and do not crash the process.

NFR-BFL-006 Maintainability. The public API MUST remain stable within a BusDK minor version and document breaking changes. Acceptance criteria: TBD — define the public API stability policy and how breaking changes are communicated.

### System Architecture

BFL is a small compiler pipeline that parses UTF-8 source text into an AST, binds and validates identifiers against a provided context, and evaluates the AST to a typed result deterministically. Consumers such as [bus-data](./bus-data) integrate BFL by discovering formula semantics from schema metadata, validating formulas during validate and read operations, and computing a current-state projection during read operations without writing back to CSV.

### Component Design and Interfaces

Interface IF-BFL-001 Go library. The module exposes a Go library for parsing, validating, and evaluating expressions. The public API MUST support parsing expressions into an AST with stable, structured error reporting, validating an AST against a context definition (available identifiers, types, and allowed functions), evaluating an AST against a concrete context, and optionally formatting an AST back into a canonical expression string if canonicalization is required for determinism or tooling.

Interface IF-BFL-002 Integration contract with [bus-data](./bus-data). [bus-data](./bus-data) uses the library to validate formula fields during [package](../data/data-package-organization), resource, and table validation and to compute formula values during table read projection.

BFL itself does not define [workspace layout and discovery](../layout/index), [CSV parsing](../data/csv-conventions), [schema parsing](../data/table-schema-contract), [`datapackage.json` handling](../data/data-package-organization), or file writes. Those belong to [bus-data](./bus-data) or other BusDK modules.

### Data Design

#### Expression storage

BFL expressions are stored as UTF-8 strings.

Two storage modes are supported at the schema metadata level: inline (row-local), where the CSV cell value is the expression source for that row, and constant (column-wide), where the schema provides an expression that applies to all rows. Both modes may coexist, but the selection rules must be explicit in schema metadata. BFL does not rely on heuristics such as string starts with `=` unless the consumer opts into that behavior.

#### Schema representation (BusDK extension)

BFL is represented using BusDK metadata inside Frictionless [Table Schema field descriptors](../data/table-schema-contract). Frictionless allows additional properties on descriptors, so this remains compatible with standard tooling.

A field that stores formula source text SHOULD be represented physically as a standard Frictionless type that can store arbitrary UTF-8 text, typically `"type": "string"` or `"type": "any"`. The BusDK metadata defines formula semantics and the computed result type.

Recommended metadata shape on a field descriptor:

- `field.busdk.semantic_type`: `"formula"`
- `field.busdk.formula.language`: `"bfl"`
- `field.busdk.formula.mode`: `"inline"` or `"constant"`
- `field.busdk.formula.expression`: string (required when mode is constant)
- `field.busdk.formula.result`: an object describing the computed logical type (for example `{ "type": "number" }`)
- `field.busdk.formula.prefix`: optional string, used only if the consumer wants spreadsheet-style `=` prefix behavior
- `field.busdk.formula.on_error`: `"fail"` or `"null"`
- `field.busdk.formula.rounding`: optional rounding configuration for numeric results

Semantics are as follows. If mode is inline, the stored cell value is treated as the expression source. If mode is constant, the schema-provided expression is used for all rows. The computed result MUST be validated against the declared result type and any configured constraints at the BusDK layer, since the physical field type may be string or any.

#### Projection behavior (`bus-data` interaction)

BFL only defines parsing and evaluation. Projection rules belong to [bus-data](./bus-data), but this SDD defines the expected integration outcome.

When reading a table with formula fields enabled, [bus-data](./bus-data) computes formula values and returns a projected current-state view deterministically without writing back to CSV. The consumer may choose to return raw formula strings, computed values, or both, but the choice must be explicit and deterministic.

### Assumptions and Dependencies

BFL assumes the consumer provides the expression source string. If the expression source is missing or invalid, the library returns deterministic parse errors and no evaluation result.

BFL assumes the consumer provides a context mapping identifiers to typed values. If identifiers are missing or types are incompatible, the library returns deterministic bind or type errors.

BFL assumes the consumer provides the allowed function surface by registering functions. If a function reference is not in the allowed set, the library returns a deterministic bind error.

BFL depends on no external services and is a pure library. If a consumer requires I/O, workspace discovery, or schema parsing, those responsibilities remain outside BFL.

### Key Decisions

KD-BFL-001 Schema extension, not spec replacement. BFL is integrated via BusDK metadata inside Frictionless Table Schema and Data Package descriptors, keeping descriptors valid and portable.

KD-BFL-002 Stored value is the formula source. When a field is configured for formulas, the stored CSV cell value is the formula source string as a physical value. Computed values are derived at read time.

KD-BFL-003 Decimal-first numerics. Numeric behavior MUST be deterministic and suitable for business calculations. The implementation SHOULD use decimal arithmetic and an explicit, documented rounding rule rather than exposing binary floating point quirks.

KD-BFL-004 Row-local by default. The default evaluation context is a single row. Cross-row aggregation is out of scope for the initial language surface and should be introduced only with explicit determinism and dependency rules.

### Language Definition

BFL is intentionally small. It supports a stable subset of spreadsheet-style expression features with deterministic typing rules.

#### Lexical rules

UTF-8 input is required. Whitespace is insignificant except inside string literals. String literals use double quotes with JSON-style escapes.

#### Value types

BFL supports null, boolean, string, number (decimal), integer (a restricted number), date, and datetime. Callers provide typed context values. When callers originate from CSV, casting rules are owned by `bus-data` and the Table Schema. BFL assumes it receives typed values or explicit string literals.

#### References

BFL can reference fields from the current row by identifier. Simple column names may be referenced directly. For non-identifier column names, the consumer MUST provide an escape hatch, with `col("column name")` as the recommended form.

#### Operators

The language supports arithmetic operators `+ - * /`, comparison operators `== != < <= > >=`, and boolean operators `and or not`.

#### Functions

BFL does not implement built-in functions. Callers register function sets with names, signatures, and pure implementations, and both validation and evaluation only allow registered functions.

#### Errors

Errors are deterministic and fall into these classes: parse error, bind error, type error, and evaluation error. Parse errors cover invalid syntax. Bind errors cover unknown identifiers or missing references. Type errors cover invalid operand types for an operator or function. Evaluation errors include division by zero and invalid operations.

Errors MUST include stable location information (byte offset or line and column) and a concise message.

### Security Considerations

BFL evaluation is side-effect free. The implementation MUST NOT permit filesystem access, network access, subprocess execution, environment reads, or unbounded computation.

Implementations MUST protect against resource exhaustion by bounding AST size, recursion depth, and evaluation complexity.

### Observability and Logging

The library returns structured errors and does not log by default. If a CLI exists, it prints results to stdout and diagnostics to stderr deterministically.

### Error Handling and Resilience

The library must return typed errors for invalid inputs and must not panic for user-provided expressions. Any CLI that exists must use BusDK conventions for exit codes and diagnostics.

### Testing Strategy

Unit tests cover deterministic parsing and evaluation, stable parse error locations, unknown references, type errors, division by zero, rounding behavior, rejection of unregistered functions, correct execution of registered functions, and row-local evaluation across multiple rows or contexts with different formulas.

Integration tests in [bus-data](./bus-data) cover computing projected values during table reads without writing, deterministic diagnostics when formulas fail, and preservation of raw formula strings in storage.

### Deployment and Operations

Not Applicable. The module ships as a Go library and an optional CLI component in BusDK.

### Migration/Rollout

BFL semantics evolve under BusDK module versioning. Any behavior change must be documented in the module changelog and release notes, including how existing expressions may be affected.

### Risks

R-BFL-001 Ambiguity between identifiers and reserved words. Mitigation: maintain a reserved keyword list and provide the `col("...")` escape hatch.

R-BFL-002 Numeric precision expectations. Mitigation: decimal arithmetic and explicit rounding configuration with deterministic defaults.

R-BFL-003 Future cross-table lookups. Mitigation: keep row-local semantics initially and introduce lookups only with explicit schema-declared dependencies and deterministic failure modes.

### Open Questions

OQ-BFL-001 What are the default rounding mode and tie-breaking rules for numeric rounding when the caller does not provide explicit rounding configuration?

OQ-BFL-002 What are the maximum supported expression length, AST size, and recursion depth limits that define acceptable performance and scalability for typical workspaces?

OQ-BFL-003 What is the public API stability policy for the Go library across BusDK minor and patch versions?

### Glossary and Terminology

BFL: BusDK Formula Language, a deterministic expression language for formulas.  
Formula source: the stored string representation of an expression.  
Computed value: the result of evaluating a formula source against a context.  
Projection: a read-time view of a dataset that may include computed values without writing.

### See also

See also: [Project SDD](https://docs.busdk.com/sdd), [bus-data SDD](./bus-data), [Frictionless Table Schema](https://specs.frictionlessdata.io/table-schema/), and [Frictionless Data Package](https://specs.frictionlessdata.io/data-package/).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-data">bus-data</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-bfl module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-BFL`  
Version: 2026-02-08  
Status: Draft  
Last updated: 2026-02-08  
Owner: BusDK development team  
