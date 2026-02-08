## bus-bfl

### Introduction and Overview

BusDK Formula Language (BFL) is a deterministic expression language for [BusDK workspaces](../overview/index) that evaluates spreadsheet-style formulas and simple predicates expressed as UTF-8 strings. BFL is not a general programming language and has no I/O, no reflection, no loops, and no time-dependent behavior. The intended users are BusDK module developers and maintainers who need deterministic formula evaluation inside the [workspace datasets](../data/index). This document defines the BFL design so that consumers can implement and verify formula behavior consistently.

BFL exists because Frictionless [Table Schema](../data/table-schema-contract) and [Data Package](../data/data-package-organization) descriptors define typing, constraints, and relationships, but they do not define computed fields as a first-class concept. BusDK implements formulas using Frictionless descriptor extensibility — [Table Schema field descriptors](../data/table-schema-contract) may contain additional properties. BFL provides the deterministic expression semantics for those properties.

The primary surface is a Go library that other BusDK modules import directly. BFL is intended to be used by [bus-data](./bus-data) and other modules as a pure evaluation engine.

The goal is to provide a deterministic, row-local formula engine that is portable across BusDK modules and robust for long-lived workspace datasets. Non-goals include domain-specific accounting rules, cross-row aggregation, any built-in function set, and any feature that requires external state or side effects. The audience is BusDK maintainers and reviewers who need an authoritative, implementation-ready description of formula behavior.

Versioning follows BusDK versioning. BFL expressions do not carry an internal language version tag. Any changes to BFL semantics must be managed through BusDK module versioning and documented as behavior changes.

### Requirements

#### Functional Requirements

FR-BFL-001 Deterministic evaluation. The module MUST provide deterministic parsing and evaluation for identical inputs. Acceptance criteria: evaluation results are identical across machines for the same expression and the same input context when using the same BusDK version of the BFL implementation.

FR-BFL-002 Pure and safe evaluation. The module MUST NOT perform network I/O, filesystem I/O, environment access, subprocess execution, or any other side effects. Acceptance criteria: evaluation is a pure function of (expression, context) and cannot access external state.

FR-BFL-003 Library-first integration. The Go library MUST be the primary integration surface for other BusDK modules. Acceptance criteria: [bus-data](./bus-data) and other modules can parse, validate, and evaluate BFL without shelling out to a CLI.

FR-BFL-004 Spreadsheet-style formulas. The module MUST support spreadsheet-style expressions, including arithmetic, comparisons, boolean logic, and conditional evaluation. Acceptance criteria: the language supports a stable set of operators and conditional evaluation can be expressed via registered functions, with no built-in function set.

FR-BFL-005 Row-local formulas. The system MUST support formulas stored per-row (per-cell) where different rows may contain different expressions for the same field. Acceptance criteria: two rows in the same column may evaluate different formulas correctly and independently.

FR-BFL-006 Static validation. The library MUST support validating formulas without mutating data. Acceptance criteria: callers can detect parse errors, unsupported tokens, ambiguous literals, unknown references, and type errors deterministically before evaluation.

FR-BFL-007 Data-source agnostic. The library MUST NOT know about CSV, Frictionless schemas, BusDK workspaces, or any file formats. Acceptance criteria: the public API accepts expression source strings and caller-provided context definitions without referencing any BusDK storage or schema types.

FR-BFL-008 Function registration framework. The library MUST provide a function registration framework in which callers supply function names, signatures, and pure implementations. Acceptance criteria: validation and evaluation only allow registered functions, and unregistered function calls are rejected deterministically.

#### Non-Functional Requirements

NFR-BFL-001 Mechanical scope only. The module MUST NOT implement accounting rules, discretionary accounting judgments, or domain-specific semantics. Acceptance criteria: the API only exposes expression mechanics and generic type and constraint handling required by the language.

NFR-BFL-002 Security and sandboxing. The module MUST prevent access to external state and must bound resource usage for expression parsing and evaluation. Acceptance criteria: the implementation rejects expressions that exceed configured limits on AST size, recursion depth, or evaluation steps and reports a deterministic error without partial results. The library defines strict default numeric caps for expression length (4,096 UTF-8 bytes), AST size (512 nodes), and recursion depth (32) and allows callers to override them for known workloads while preserving deterministic errors.

NFR-BFL-003 Performance. Parsing and evaluation MUST meet agreed performance targets for typical workspace datasets. Acceptance criteria: for expressions up to the default caps, parsing completes in 2 milliseconds or less per expression and evaluation completes in 200 microseconds or less per row on the reference test machine. Benchmarks must include parse-time and evaluation-time microbenchmarks at the default caps and document the reference machine configuration. These defaults may be raised for known workloads only when the benchmarks and acceptance criteria are updated accordingly.

NFR-BFL-004 Scalability. Evaluation MUST remain deterministic and bounded as datasets grow. Acceptance criteria: default scalability targets for [bus-data](./bus-data) projections are up to 100,000 rows per table with average per-row evaluation overhead at or below 150 microseconds and full-table projection at or below 15 seconds on the reference test machine. These defaults may be raised for known workloads only when the benchmarks and acceptance criteria are updated accordingly.

NFR-BFL-005 Reliability. The library MUST return typed errors for invalid inputs and MUST NOT panic on user-provided expressions. Acceptance criteria: invalid inputs return deterministic parse, bind, type, or evaluation errors and do not crash the process.

NFR-BFL-006 Maintainability. The public API MUST remain stable within a BusDK minor version and document breaking changes. Acceptance criteria: the module changelog and release notes explicitly list any public API changes, and any breaking change includes a short migration note that explains the impact and the expected adjustment.

### System Architecture

BFL is a small compiler pipeline that parses UTF-8 source text into an AST, binds and validates identifiers against a provided context, and evaluates the AST to a typed result deterministically. The pipeline includes limit configuration that bounds parse and evaluation work and produces deterministic limit errors. Consumers such as [bus-data](./bus-data) integrate BFL by discovering formula semantics from schema metadata, validating formulas during validate and read operations, and computing a current dataset view during read operations without writing back to CSV.

### Component Design and Interfaces

#### IF-BFL-001 Go library interface

The module exposes a Go library for parsing, validating, and evaluating expressions. The public API MUST support parsing expressions into an AST with stable, structured error reporting, validating an AST against a context definition (available identifiers, types, and allowed functions), evaluating an AST against a concrete context, and optionally formatting an AST back into a canonical expression string if canonicalization is required for determinism or tooling. The API MUST accept a limit configuration so callers can tune expression length, AST size, and recursion depth caps while retaining deterministic errors.

The public API shape is TBD and must be specified with concrete Go types, function signatures, and error types. Until it is specified, the requirements above are authoritative for behavior but not yet for the Go surface.

#### IF-BFL-002 Integration contract with bus-data

[bus-data](./bus-data) uses the library to validate formula fields during [package](../data/data-package-organization), resource, and table validation and to compute formula values during table read projection.

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
- `field.busdk.formula.rounding`: optional rounding configuration for numeric results; when unset, the default is half-up (ties away from zero)

Semantics are as follows. If mode is inline, the stored cell value is treated as the expression source. If mode is constant, the schema-provided expression is used for all rows. The computed result MUST be validated against the declared result type and any configured constraints at the BusDK layer, since the physical field type may be string or any.

#### Projection behavior (bus-data interaction)

BFL only defines parsing and evaluation. Projection rules belong to [bus-data](./bus-data), but this SDD defines the expected integration outcome.

When reading a table with formula fields enabled, [bus-data](./bus-data) computes formula values and returns a projected current dataset view deterministically without writing back to CSV. The consumer may choose to return raw formula strings, computed values, or both, but the choice must be explicit and deterministic.

### Assumptions and Dependencies

BFL assumes the consumer provides the expression source string. If the expression source is missing or invalid, the library returns deterministic parse errors and no evaluation result. Impact if false: callers may treat missing formulas as empty strings and silently produce incorrect computed values.

BFL assumes the consumer provides a context mapping identifiers to typed values. If identifiers are missing or types are incompatible, the library returns deterministic bind or type errors. Impact if false: consumers may incorrectly report evaluation errors instead of bind or type errors, reducing diagnosability.

BFL assumes the consumer provides the allowed function surface by registering functions. If a function reference is not in the allowed set, the library returns a deterministic bind error. Impact if false: consumers may unintentionally execute unregistered functions or accept non-deterministic behavior.

BFL depends on no external services and is a pure library. If a consumer requires I/O, workspace discovery, or schema parsing, those responsibilities remain outside BFL. Impact if false: the library would risk violating determinism and security guarantees.

BFL is in an active pre-1.0 phase and follows semver. Backwards compatibility is a goal, but stability guarantees are not required yet and breaking changes may occur as implementations stabilize. Impact if false: module maintainers may over-assume stability and fail to review changes that affect formula behavior or public APIs.

### Key Decisions

KD-BFL-001 Schema extension, not spec replacement. BFL is integrated via BusDK metadata inside Frictionless Table Schema and Data Package descriptors, keeping descriptors valid and portable.

KD-BFL-002 Stored value is the formula source. When a field is configured for formulas, the stored CSV cell value is the formula source string as a physical value. Computed values are derived at read time.

KD-BFL-003 Decimal-first numerics. Numeric behavior MUST be deterministic and suitable for business calculations. The implementation SHOULD use decimal arithmetic with a spreadsheet-style default rounding rule (half-up, ties away from zero) and support a configurable rounding mode so callers can select alternatives such as half-even when required.

KD-BFL-004 Row-local by default. The default evaluation context is a single row. Cross-row aggregation is out of scope for the initial language surface and should be introduced only with explicit determinism and dependency rules.

KD-BFL-005 Dialect-driven parsing and canonicalization. BFL uses a single core AST and evaluation model, with dialect configuration controlling accepted tokens, keyword casing, and canonical printing. Dialect profiles are deterministic parsing and printing policies over the same semantics.

KD-BFL-006 Normative operator precedence and associativity. BFL defines a fixed precedence order with left-associative arithmetic and boolean operators, unary binding to the right operand, and non-associative comparisons that reject chaining without parentheses.

KD-BFL-007 Deterministic literal grammar and datetime policy. Numeric, string, boolean, and null literal formats are defined explicitly; date and datetime values are typed context values with optional ISO-only parsing when enabled, and datetime offsets are required by default with no implicit timezone.

### Language Definition

BFL is intentionally small. It supports a stable subset of spreadsheet-style expression features with deterministic typing rules.

#### Compatibility profiles and dialect configuration

BFL has a single core AST and evaluation model. Parsing, tokenization, and a small set of edge behaviors are controlled by a caller-provided `Dialect` configuration. Dialect profiles are deterministic parsing and printing policies over the same AST semantics, not different languages. The default profile is `dialect.spreadsheet` and MUST be used unless the consumer explicitly selects another profile.

The `Dialect` configuration defines accepted token spellings, keyword case sensitivity, literal parsing behavior, and optional preprocessing. Locale is never inferred from the machine; any locale-like behavior must come from explicit caller configuration. At minimum, the dialect exposes these normative fields with deterministic defaults: `equality_tokens`, `not_equal_tokens`, `keyword_case_sensitive`, `strip_formula_prefix`, `decimal_separator`, `allow_leading_dot_decimal`, `allow_thousands_separator`, `thousands_separator`, `datetime_parse`, and `datetime_assume_timezone`. `strip_formula_prefix` is disabled by default but may be enabled by a consumer or schema metadata to remove a single leading prefix string before parsing if it is present at byte offset zero; no other trimming or heuristics are applied. The default `decimal_separator` is `.`. Thousands separators are disabled by default with an empty `thousands_separator`. The default `datetime_parse` policy is disabled; when enabled, the only allowed policy is offset-required parsing as defined under Value types. `datetime_assume_timezone` is empty by default and MUST NOT be used unless the caller explicitly enables it.

Named profiles are defined by concrete token rules and defaults. `dialect.spreadsheet` accepts equality tokens `=` and `==`, not-equal tokens `<>` and `!=`, and treats keywords and literal spellings as case-insensitive. It accepts leading-dot decimals when enabled by the dialect and uses `=` and `<>` for canonical printing. `dialect.excel_like` accepts only `=` for equality and `<>` for not-equal, rejects `==` and `!=`, and treats keywords and literal spellings as case-insensitive. `dialect.sheets_like` accepts `=` and `<>` and also accepts `!=` as an alias, rejects `==`, and treats keywords and literal spellings as case-insensitive. `dialect.programmer` accepts only `==` and `!=`, rejects `<>`, and treats keywords and literal spellings as case-sensitive with lowercase-only canonical spellings; it rejects leading-dot decimals by default and prints equality as `==` and not-equal as `!=`.

Custom profiles are supported by directly populating the `Dialect` fields. Consumers may extend acceptance sets, but they must do so explicitly and deterministically; no implicit machine or locale inference is allowed. If canonical printing is enabled, it MUST use the canonical tokens defined by the active dialect.

#### Lexical rules

UTF-8 input is required. Whitespace is insignificant except inside string literals. The tokenizer recognizes identifiers, keywords, literals, operators, commas, and parentheses. Keywords and literal spellings are matched according to the active dialect’s case-sensitivity rules. String literals use double quotes with JSON-style escapes.

#### Value types

BFL supports null, boolean, string, number (decimal), integer (a restricted number), date, and datetime. Callers provide typed context values. When callers originate from CSV, casting rules are owned by [bus-data](./bus-data) and the Table Schema. BFL assumes it receives typed values or explicit literals defined below.

Numeric literals are base-10 with an optional fractional part and an optional exponent. The decimal separator is the dialect’s configured separator, which defaults to `.`. Thousands separators are rejected unless the caller explicitly enables them by setting `allow_thousands_separator` and a specific `thousands_separator` value in the dialect. The exponent marker is `e` or `E` followed by an optional `+` or `-` and at least one digit. A numeric literal without a decimal separator or exponent is an integer literal. If its magnitude fits in signed 64-bit range, it is typed as integer; otherwise it is typed as number. Unary `+` and `-` are operators, not part of the literal token. Leading-dot decimals such as `.5` are accepted only when enabled by the active dialect; otherwise they are rejected deterministically.

String literals are delimited by double quotes and use JSON-style escapes, including `\"`, `\\`, `\n`, `\r`, `\t`, and `\uXXXX`. Input is UTF-8 and no implicit locale conversions are performed.

Boolean and null literals use the spellings `true`, `false`, and `null`. Whether these spellings are case-sensitive is controlled by the dialect.

Date and datetime values are typed values supplied in the evaluation context. BFL does not parse arbitrary date or datetime strings in core evaluation. If string-to-date or string-to-datetime conversion is required, it must be performed by the consumer before evaluation or by a registered function supplied by the consumer.

Optional ISO-only parsing may be enabled by dialect configuration or by a companion utility package. When enabled, the only accepted date literal text format is `YYYY-MM-DD`. The only accepted datetime literal text format is an RFC3339 timestamp with an explicit UTC `Z` or a numeric offset like `+02:00`. The default policy is offset-required, which rejects datetimes without an explicit offset. Locale and timezone are never inferred from the machine; any locale-like behavior must be configured explicitly by the caller.

Datetime values are interpreted as absolute instants. Comparison and ordering are done on the instant timeline, and any provided offset is normalized to UTC internally for comparison. If the caller explicitly enables `datetime_assume_timezone` and provides a timezone identifier, a datetime string without an offset may be interpreted in that timezone as a deterministic policy choice; otherwise datetimes without offsets are rejected.

#### References

BFL can reference fields from the current row by identifier. Identifiers use ASCII letters and underscore for the first character, followed by ASCII letters, digits, or underscore. Identifier matching is case-sensitive or case-insensitive according to the active dialect. For non-identifier column names, the consumer MUST provide an escape hatch, with `col("column name")` as the recommended form implemented via function registration. Identifiers and functions are supplied by consumers outside this core library.

#### Operators

The language supports arithmetic operators `+ - * /`, comparison operators, and boolean operators `and or not`. The exact token spellings that are accepted are controlled by the active dialect, and canonical printing uses the dialect’s canonical token set.

##### Operator precedence and associativity (normative)

Precedence from highest to lowest is: parenthesized and primary expressions (literals, identifiers, function calls); unary operators (`not`, unary `+`, unary `-`); multiplicative (`*`, `/`); additive (`+`, `-`); comparison (`=`, `==`, `<>`, `!=`, `<`, `<=`, `>`, `>=` as accepted by the dialect); boolean `and`; boolean `or`. Unary operators bind to the immediate right operand. `*`, `/`, `+`, `-`, `and`, and `or` are left-associative. Comparisons are non-associative; chained comparisons such as `a < b < c` are rejected with a deterministic parse error. Parentheses override precedence as usual.

Canonical printing is optional, but if implemented it MUST use the dialect’s canonical token set and lowercase keyword spellings. In the default dialect, equality prints as `=` and not-equal prints as `<>`. In `dialect.programmer`, equality prints as `==` and not-equal prints as `!=`.

#### Functions

BFL does not implement built-in functions. Callers register function sets with names, signatures, and pure implementations, and both validation and evaluation only allow registered functions.

#### Errors

Errors are deterministic and fall into these classes: parse error, bind error, type error, and evaluation error. Parse errors cover invalid syntax. Bind errors cover unknown identifiers or missing references. Type errors cover invalid operand types for an operator or function. Evaluation errors include division by zero and invalid operations. Errors MUST include stable location information (byte offset or line and column) and a concise message.

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

A machine-readable conformance corpus is required and must ship with the library. The corpus defines parsing and evaluation outcomes for each named dialect profile and is the authoritative compatibility lock for future changes. It MUST cover operator precedence grouping and associativity, canonical printing, numeric literal parsing including exponent handling and leading-dot acceptance where allowed, rejection cases such as chained comparisons, thousands separators, and datetimes without offsets when ISO parsing is enabled, and date/datetime comparison semantics using typed context values.

### Deployment and Operations

Not Applicable. The module ships as a Go library and an optional CLI component in BusDK.

### Migration/Rollout

BFL semantics evolve under BusDK module versioning. Any behavior change must be documented in the module changelog and release notes, including how existing expressions may be affected.

### Risks

R-BFL-001 Ambiguity between identifiers and reserved words. Mitigation: maintain a reserved keyword list and provide the `col("...")` escape hatch.

R-BFL-002 Numeric precision expectations. Mitigation: decimal arithmetic and explicit rounding configuration with deterministic defaults.

R-BFL-003 Future cross-table lookups. Mitigation: keep row-local semantics initially and introduce lookups only with explicit schema-declared dependencies and deterministic failure modes.

### Open Questions

OQ-BFL-001 What are the exact Go public API types, function signatures, and error types for parsing, validation, evaluation, and canonical printing? The SDD requires stable behavior but the concrete surface is still TBD.

OQ-BFL-002 What is the authoritative representation of the evaluation context and type system in the Go API, including how identifiers map to typed values and how function signatures are expressed?

OQ-BFL-003 For [bus-data](./bus-data) projections, which output mode is normative when a formula field is enabled: computed values only, raw formula strings only, or both? The SDD currently requires the choice to be explicit but does not specify the default.

OQ-BFL-004 Where does the machine-readable conformance corpus live in the repository, and what is its required format and naming convention?

### Glossary and Terminology

BFL is the BusDK Formula Language, a deterministic expression language for formulas.

Formula source is the stored string representation of an expression.

Computed value is the result of evaluating a formula source against a context.

Projection is a read-time view of a dataset that may include computed values without writing.

### See also

See also: [Project SDD](https://docs.busdk.com/sdd), [bus-data SDD](./bus-data), [Frictionless Table Schema](https://specs.frictionlessdata.io/table-schema/), [Frictionless Data Package](https://specs.frictionlessdata.io/data-package/), [OpenDocument Formula (OpenFormula) specification](https://docs.oasis-open.org/office/OpenDocument/v1.3/OpenDocument-v1.3-part4-formula.pdf), [Excel operator precedence guidance](https://support.microsoft.com/en-us/office/calculation-operators-and-precedence-in-excel-48be406d-4975-4d31-b2b8-7af9e0e2878a), [Frictionless Table Schema date/time formats](https://frictionlessdata.io/specs/table-schema/), and [Google Sheets locale and time zone settings](https://support.google.com/docs/answer/58515?co=GENIE.Platform%3DDesktop&hl=en).

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
