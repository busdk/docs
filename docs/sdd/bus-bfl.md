---
title: bus-bfl — deterministic formula language for computed fields (SDD)
description: BusDK Formula Language (BFL) is a deterministic expression language for BusDK workspaces that evaluates spreadsheet-style formulas and simple predicates…
---

## bus-bfl — deterministic formula language for computed fields

### Introduction and Overview

BusDK Formula Language (BFL) is a deterministic expression language for [BusDK workspaces](../overview/index) that evaluates spreadsheet-style formulas and simple predicates expressed as UTF-8 strings. BFL is not a general programming language and has no I/O, no reflection, no loops, and no time-dependent behavior. The intended users are BusDK module developers and maintainers who need deterministic formula evaluation inside the [workspace datasets](../data/index). This document defines the BFL design so that consumers can implement and verify formula behavior consistently.

BFL exists because Frictionless [Table Schema](../data/table-schema-contract) and [Data Package](../data/data-package-organization) descriptors define typing, constraints, and relationships, but they do not define computed fields as a first-class concept. BusDK implements formulas using Frictionless descriptor extensibility — [Table Schema field descriptors](../data/table-schema-contract) may contain additional properties. BFL provides the deterministic expression semantics for those properties.

BusDK’s preferred default is that workspace datasets live in the Git repository as UTF-8 CSV validated with Table Schema. This is a delivery convention rather than the goal; the invariant is that the workspace datasets and their change history remain reviewable and exportable. BFL is storage-agnostic and operates only on expression strings and typed contexts supplied by the consumer.

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
FR-BFL-009 Range expressions. The library MUST support spreadsheet-style range expressions using Excel-like A1 notation and the colon operator. The meaning of references and range resolution MUST be provided by the consumer in a pure, deterministic way. Acceptance criteria: `A1:A`, `A:A`, and `A1:B10` parse, compile, and evaluate deterministically, and evaluation requires a consumer-provided range resolver.
FR-BFL-010 Array values. The Value model MUST support arrays as runtime values so functions can accept arrays and return arrays. Acceptance criteria: arrays are supported as a first-class value kind, function signatures can accept arrays, and functions can return arrays deterministically.

#### Non-Functional Requirements

NFR-BFL-001 Mechanical scope only. The module MUST NOT implement accounting rules, discretionary accounting judgments, or domain-specific semantics. Acceptance criteria: the API only exposes expression mechanics and generic type and constraint handling required by the language.

NFR-BFL-002 Security and sandboxing. The module MUST prevent access to external state and must bound resource usage for expression parsing and evaluation, including range and array materialization. Acceptance criteria: the implementation rejects expressions or evaluations that exceed configured limits on AST size, recursion depth, evaluation steps, or array elements and reports a deterministic error without partial results. The library defines strict default numeric caps for expression length (4,096 UTF-8 bytes), AST size (512 nodes), recursion depth (32), evaluation steps (10,000), and array elements (10,000) and allows callers to override them for known workloads while preserving deterministic errors.

NFR-BFL-003 Performance. Parsing and evaluation MUST meet agreed performance targets for typical workspace datasets. Acceptance criteria: for expressions up to the default caps, parsing completes in 2 milliseconds or less per expression and evaluation completes in 200 microseconds or less per row on the normative CI reference profile. Benchmarks must include parse-time and evaluation-time microbenchmarks at the default caps and document the reference profile and benchmark metadata. These defaults may be raised for known workloads only when the benchmarks and acceptance criteria are updated accordingly.

NFR-BFL-004 Scalability. Evaluation MUST remain deterministic and bounded as datasets grow. Acceptance criteria: default scalability targets for [bus-data](./bus-data) projections are up to 100,000 rows per table with average per-row evaluation overhead at or below 150 microseconds and full-table projection at or below 15 seconds on the normative CI reference profile. These defaults may be raised for known workloads only when the benchmarks and acceptance criteria are updated accordingly.

NFR-BFL-005 Reliability. The library MUST return typed errors for invalid inputs and MUST NOT panic on user-provided expressions. Acceptance criteria: invalid inputs return deterministic parse, bind, type, or evaluation errors and do not crash the process.

NFR-BFL-006 Maintainability. The public API MUST remain stable within a BusDK minor version and document breaking changes. Acceptance criteria: the module changelog and release notes explicitly list any public API changes, and any breaking change includes a short migration note that explains the impact and the expected adjustment.

#### Benchmark reference profile and metadata (normative)

Performance and scalability targets are measured against a pinned, normative CI reference profile with a stable identifier. The primary reference profile is `BFL-REF-UBU-2404`, defined as the standard GitHub-hosted runner label `ubuntu-24.04` selected via `runs-on` as described in [Choosing the runner for a job](https://docs.github.com/actions/using-jobs/choosing-the-runner-for-a-job), with 4 vCPU, 16 GB RAM, and 14 GB SSD on x64 for public repositories, as documented in the [GitHub-hosted runners reference](https://docs.github.com/en/actions/reference/runners/github-hosted-runners). If GitHub changes the underlying runner resources for this label, if the repository’s hosting tier changes and the runner resources differ, or if BusDK changes the CI runner label used for benchmarks, the project MUST re-baseline the performance and scalability measurements and update this reference profile section accordingly. The normative acceptance criteria apply only to this CI reference profile; local developer runs are informative only and MUST NOT be used to accept or reject the absolute timing targets.

If the project chooses to add a second benchmark profile, it MUST be an explicitly named GitHub-hosted larger runner CI profile with documented label and hardware resources, and it remains optional. No developer laptop profiles are normative for acceptance criteria.

Every published benchmark result MUST include benchmark metadata captured at runtime: operating system, kernel, CPU model, number of CPU cores visible to the process, total RAM visible to the process, Go version, `GOARCH`, `GOOS`, and whether the process is running inside a container. The `bus-bfl` repository MUST include a helper that prints this metadata in a stable text form and a stable JSON form. CI MUST store both the metadata and benchmark output as artifacts for each release tag.

### System Architecture

BFL is a small compiler pipeline that parses UTF-8 source text into an AST, binds and validates identifiers against a provided context, and evaluates the AST to a typed result deterministically. The pipeline includes limit configuration that bounds parse and evaluation work and produces deterministic limit errors. Range expressions compile to a distinct `RangeExpr` node and evaluate through a consumer-provided `RangeProvider` that returns an array value. Consumers such as [bus-data](./bus-data) integrate BFL by discovering formula semantics from schema metadata, validating formulas during validate and read operations, and computing a current dataset view during read operations without writing back to CSV.

### Component Design and Interfaces

#### IF-BFL-001 Go library interface

The module exposes a Go library for parsing, validating, and evaluating expressions. The public API MUST support parsing expressions into an AST with stable, structured error reporting, validating an AST against a context definition (available identifiers, types, and allowed functions), evaluating an AST against a concrete context, and optionally formatting an AST back into a canonical expression string if canonicalization is required for determinism or tooling. The API MUST accept a limit configuration so callers can tune expression length, AST size, and recursion depth caps while retaining deterministic errors.

The public API is defined below and is the normative surface for the library. It is data-source agnostic, deterministic, and safe for concurrent use.

#### Go API surface (normative)

The API is centered on the pipeline Parse → Compile (bind + typecheck) → Evaluate, with optional Format for canonical printing. The AST is immutable and safe for concurrent use. Its structure is opaque to callers; the exported handle is `*Expr`, which supports validation, evaluation, and formatting without exposing node types.

The library defines a dialect configuration that is used consistently across parsing, binding, typechecking, and formatting.

```go
type Dialect struct {
	EqualityTokens         []string
	NotEqualTokens         []string
	KeywordCaseSensitive   bool
	StripFormulaPrefix     string
	DecimalSeparator       string
	AllowLeadingDotDecimal bool
	AllowThousandsSeparator bool
	ThousandsSeparator     string
	DateTimeParse          string
	DateTimeAssumeTimezone string
}
```

Defaults are deterministic and match the dialect definition: `EqualityTokens` is `[]string{"=", "=="}`, `NotEqualTokens` is `[]string{"<>", "!="}`, `KeywordCaseSensitive` is false, `StripFormulaPrefix` is empty, `DecimalSeparator` is `.`, `AllowLeadingDotDecimal` is false, `AllowThousandsSeparator` is false, `ThousandsSeparator` is empty, `DateTimeParse` is `disabled`, and `DateTimeAssumeTimezone` is empty. `DateTimeParse` accepts only `disabled` or `iso_offset_required`.

Limits bound work deterministically. Zero values in options use these defaults.

```go
type Limits struct {
	MaxExprBytes      int
	MaxASTNodes       int
	MaxRecursionDepth int
	MaxEvalSteps      int
	MaxArrayElements  int
}
```

Default limits are `MaxExprBytes` 4096 (UTF-8 bytes), `MaxASTNodes` 512, `MaxRecursionDepth` 32, `MaxEvalSteps` 10000, and `MaxArrayElements` 10000.

```go
type ParseOptions struct {
	Dialect    Dialect
	Limits     Limits
	SourceName string
}

type CompileOptions struct {
	Dialect   Dialect
	Limits    Limits
	Symbols   SymbolTable
	Functions FunctionRegistry
}

type EvalOptions struct {
	Limits   Limits
	Rounding *RoundingPolicy
}

type FormatOptions struct {
	Dialect Dialect
}
```

The stable function surface is defined as follows.

```go
type Expr struct{}
type Program struct{}

func Parse(src string, opt ParseOptions) (*Expr, error)
func Compile(expr *Expr, opt CompileOptions) (*Program, error)
func ParseCompile(src string, opt CompileOptions) (*Program, error)
func Eval(p *Program, ctx RuntimeContext, opt EvalOptions) (Value, error)
func Format(expr *Expr, opt FormatOptions) (string, error)
```

Rounding is configurable for numeric evaluation and division results. The default is a deterministic decimal context of scale 18 with half-up rounding (ties away from zero). If provided, `EvalOptions.Rounding` overrides both the default division context and the final numeric result rounding, and its `Scale` MUST be non-negative or evaluation returns a deterministic type error.

```go
type RoundingMode int

const (
	RoundingHalfUp RoundingMode = iota
	RoundingHalfEven
)

type RoundingPolicy struct {
	Scale int
	Mode  RoundingMode
}
```

`ParseCompile` is a convenience helper that calls `Parse` then `Compile` and returns the first deterministic error.
It uses `CompileOptions.Dialect` and `CompileOptions.Limits` for parsing and leaves `SourceName` empty unless the caller chooses to parse separately.

Error typing is a stable, explicit contract. Callers MUST treat `Kind`, `Code`, and `Span` as the stable machine contract. `Message` is concise and human-oriented but is not intended as a long-term parsing target.

```go
type ErrorKind int

const (
	ErrorKindParse ErrorKind = iota
	ErrorKindBind
	ErrorKindType
	ErrorKindEval
	ErrorKindLimit
)

type ErrorCode string

type Position struct {
	Offset int
	Line   int
	Column int
}

type Span struct {
	Start Position
	End   Position
}

type Error struct {
	Kind       ErrorKind
	Code       string
	Message    string
	Span       Span
	SourceName string
}

func (e *Error) Error() string
```

`ErrorCode` values are stable strings such as `BFL_PARSE_UNEXPECTED_TOKEN`, `BFL_BIND_UNKNOWN_IDENTIFIER`, `BFL_TYPE_MISMATCH`, `BFL_EVAL_DIV_BY_ZERO`, `BFL_EVAL_RANGES_UNSUPPORTED`, `BFL_LIMIT_AST_NODES`, and `BFL_LIMIT_ARRAY_ELEMENTS`. `Position.Offset` is the UTF-8 byte offset from the start of the original input, and `Line` and `Column` are 1-based. All library functions MUST return `*Error` for language and limit failures and MUST NOT panic on user input.

#### IF-BFL-002 Integration contract with bus-data

[bus-data](./bus-data) uses the library to validate formula fields during [package](../data/data-package-organization), resource, and table validation and to compute formula values during table read projection.

BFL itself does not define [workspace layout and discovery](../layout/index), [CSV parsing](../data/csv-conventions), [schema parsing](../data/table-schema-contract), [`datapackage.json` handling](../data/data-package-organization), or file writes. Those belong to [bus-data](./bus-data) or other BusDK modules.

For range evaluation, [bus-data](./bus-data) may implement `RangeProvider` by mapping `Ref.ColumnIndex` to the schema field order (1-based) and `Ref.RowIndex` to the physical row order (1-based) in the current resource snapshot. Open-ended ranges such as `A1:A` and `A:A` must resolve the last row deterministically based on the current dataset snapshot as read, without probing or mutating external state. This mapping is a bus-data policy and does not change the BFL core language, which remains storage-agnostic and unaware of tables or schemas.

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
- `field.busdk.formula.rounding`: optional rounding policy for numeric results (mode and scale); when unset, evaluator defaults apply

`field.busdk.formula.rounding` is an object with two required properties when present: `scale` (a non-negative integer) and `mode` (a string value of `half_up` or `half_even`). `scale` is the number of decimal places for rounding, and `mode` defines the deterministic tie-breaking behavior used by the evaluator.

Semantics are as follows. If mode is inline, the stored cell value is treated as the expression source. If mode is constant, the schema-provided expression is used for all rows. The computed result MUST be validated against the declared result type and any configured constraints at the BusDK layer, since the physical field type may be string or any.

#### Projection behavior (bus-data interaction)

BFL only defines parsing and evaluation. Projection rules belong to [bus-data](./bus-data), but this SDD defines the expected integration outcome.

When reading a table with formula fields enabled, [bus-data](./bus-data) computes formula values and returns a projected current dataset view deterministically without writing back to CSV. The default projected dataset view uses computed values as the field value for formula-enabled fields, typed as the declared `field.busdk.formula.result` type, and it does not replace or rewrite the stored formula source in CSV. The formula source remains the physical stored value.

[bus-data](./bus-data) must provide an explicit, deterministic option to include formula source alongside computed values for diagnostics and tooling, but the default projection output mode is computed values only. Any extra output must be opt-in and must not collide with user columns, such as a reserved-prefix companion field or structured metadata in non-CSV output modes. This is a [bus-data](./bus-data) policy choice, not a BFL core responsibility.

When [bus-data](./bus-data) evaluates formulas, it MUST map `field.busdk.formula.rounding` into `EvalOptions.Rounding` deterministically. If the schema has no rounding policy, bus-data passes `Rounding` as nil so evaluator defaults apply. If the schema rounding policy is invalid, bus-data MUST fail validation deterministically before evaluation.

### Assumptions and Dependencies

BFL assumes the consumer provides the expression source string. If the expression source is missing or invalid, the library returns deterministic parse errors and no evaluation result. Impact if false: callers may treat missing formulas as empty strings and silently produce incorrect computed values.

BFL assumes the consumer provides a context mapping identifiers to typed values. If identifiers are missing or types are incompatible, the library returns deterministic bind or type errors. Impact if false: consumers may incorrectly report evaluation errors instead of bind or type errors, reducing diagnosability.

BFL assumes the consumer provides the allowed function surface by registering functions. If a function reference is not in the allowed set, the library returns a deterministic bind error. Impact if false: consumers may unintentionally execute unregistered functions or accept non-deterministic behavior.

BFL assumes that if range expressions are evaluated, the runtime context implements `RangeProvider` and resolves references deterministically. Impact if false: evaluation returns a deterministic unsupported-range error and consumers may misinterpret the cause as a generic failure.

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

KD-BFL-008 Normative Go API surface. The Go API is explicitly defined as Parse → Compile → Eval → Format with immutable AST handles, typed contexts, and deterministic, typed errors.

KD-BFL-009 BusDK-owned numeric and datetime types. The authoritative type system uses BusDK-owned decimal and datetime representations to guarantee deterministic arithmetic and comparison semantics.

KD-BFL-010 bus-data projection default. The default [bus-data](./bus-data) projection output mode is computed values only, with opt-in inclusion of formula source for diagnostics that must not collide with user columns.

KD-BFL-011 Conformance test suite as compatibility lock. The conformance test suite lives under `./tests` as JSONL test vectors with stable IDs and stable expected errors and must run in CI for source code library releases, not for `bus-bfl` CLI binary releases.

KD-BFL-012 Normative CI benchmark profile. Performance and scalability acceptance criteria are measured against `BFL-REF-UBU-2404` (GitHub-hosted `ubuntu-24.04` with 4 vCPU, 16 GB RAM, and 14 GB SSD), and changes to runner resources or labels require re-baselining and SDD updates.

KD-BFL-013 Explicit coercion and evaluation order. Core semantics include only integer-to-number promotion for numeric operators, numeric comparisons, and numeric function parameters, with explicit null handling and deterministic left-to-right evaluation with short-circuiting for `and` and `or`.

KD-BFL-014 BusDK-owned type contracts. `Decimal`, `Date`, and `DateTime` semantics are defined in this SDD and enforced by dedicated conformance tests in `bus-bfl`.

KD-BFL-015 Rounding policy in EvalOptions. Numeric rounding is configured through `EvalOptions.Rounding` with deterministic defaults, and bus-data maps schema rounding metadata into the evaluator configuration.

### Language Definition

BFL is intentionally small. It supports a stable subset of spreadsheet-style expression features with deterministic typing rules.

#### Compatibility profiles and dialect configuration

BFL has a single core AST and evaluation model. Parsing, tokenization, and a small set of edge behaviors are controlled by a caller-provided `Dialect` configuration. Dialect profiles are deterministic parsing and printing policies over the same AST semantics, not different languages. The default profile is `dialect.spreadsheet` and MUST be used unless the consumer explicitly selects another profile.

The `Dialect` configuration defines accepted token spellings, keyword case sensitivity, literal parsing behavior, and optional preprocessing. Locale is never inferred from the machine; any locale-like behavior must come from explicit caller configuration. At minimum, the dialect exposes these normative fields with deterministic defaults: `equality_tokens`, `not_equal_tokens`, `keyword_case_sensitive`, `strip_formula_prefix`, `decimal_separator`, `allow_leading_dot_decimal`, `allow_thousands_separator`, `thousands_separator`, `datetime_parse`, and `datetime_assume_timezone`. `strip_formula_prefix` is disabled by default but may be enabled by a consumer or schema metadata to remove a single leading prefix string before parsing if it is present at byte offset zero; no other trimming or heuristics are applied. The default `decimal_separator` is `.`. Thousands separators are disabled by default with an empty `thousands_separator`. The default `datetime_parse` policy is disabled; when enabled, the only allowed policy is offset-required parsing as defined under Value types. `datetime_assume_timezone` is empty by default and MUST NOT be used unless the caller explicitly enables it.

Named profiles are defined by concrete token rules and defaults. `dialect.spreadsheet` accepts equality tokens `=` and `==`, not-equal tokens `<>` and `!=`, and treats keywords and literal spellings as case-insensitive. It accepts leading-dot decimals when enabled by the dialect and uses `=` and `<>` for canonical printing. `dialect.excel_like` accepts only `=` for equality and `<>` for not-equal, rejects `==` and `!=`, and treats keywords and literal spellings as case-insensitive. `dialect.sheets_like` accepts `=` and `<>` and also accepts `!=` as an alias, rejects `==`, and treats keywords and literal spellings as case-insensitive. `dialect.programmer` accepts only `==` and `!=`, rejects `<>`, and treats keywords and literal spellings as case-sensitive with lowercase-only canonical spellings; it rejects leading-dot decimals by default and prints equality as `==` and not-equal as `!=`.

Custom profiles are supported by directly populating the `Dialect` fields. Consumers may extend acceptance sets, but they must do so explicitly and deterministically; no implicit machine or locale inference is allowed. If canonical printing is enabled, it MUST use the canonical tokens defined by the active dialect.

#### Lexical rules

UTF-8 input is required. Whitespace is insignificant except inside string literals. The tokenizer recognizes identifiers, keywords, literals, operators, commas, and parentheses. Keywords and literal spellings are matched according to the active dialect’s case-sensitivity rules. String literals use double quotes with JSON-style escapes.

The tokenizer recognizes two additional reference token classes for range syntax. A cell reference token consists of one to three ASCII letters `A` through `Z` (case-insensitive in spreadsheet-like dialects), followed by a 1-based positive integer row number with no separators, such as `A1`, `AA12`, or `ZZZ999`. A column reference token consists of one to three ASCII letters `A` through `Z` only, such as `A`, `BC`, or `ZZZ`. These tokens are ASCII-only and do not permit `$` prefixes, separators, or locale-specific variants.

#### Reference and range grammar (normative)

Range expressions are parsed as a distinct primary expression that is only formed from reference tokens. A range expression is defined as `ref_start ":" ref_end` where each side is either a cell reference token or a column reference token. Open-ended ranges are explicitly supported when the end side is a column reference token, such as `A1:A`, which means “from the start cell down to the last row in that column as defined by the consumer.” A full-column range such as `A:A` is also supported and is interpreted by the consumer as the entire column range. There are no implicit range heuristics, and strings or leading `=` are never interpreted as ranges.

Canonical formatting for references and ranges is deterministic. Column letters are uppercased. The colon is printed with no surrounding whitespace. A cell reference prints as `<COL><ROW>` with a base-10 row number with no leading zeros. A column reference prints as `<COL>`. A range prints as `<REF_START>:<REF_END>` with each side formatted as above.

#### Value types

BFL supports null, boolean, string, number (decimal), integer (a restricted number), date, datetime, and array values. Callers provide typed context values. When callers originate from CSV, casting rules are owned by [bus-data](./bus-data) and the Table Schema. BFL assumes it receives typed values or explicit literals defined below. There are no array literals in the core language; arrays are produced by range expressions or by registered functions.

Numeric literals are base-10 with an optional fractional part and an optional exponent. The decimal separator is the dialect’s configured separator, which defaults to `.`. Thousands separators are rejected unless the caller explicitly enables them by setting `allow_thousands_separator` and a specific `thousands_separator` value in the dialect. The exponent marker is `e` or `E` followed by an optional `+` or `-` and at least one digit. A numeric literal without a decimal separator or exponent is an integer literal. If its magnitude fits in signed 64-bit range, it is typed as integer; otherwise it is typed as number. Unary `+` and `-` are operators, not part of the literal token. Leading-dot decimals such as `.5` are accepted only when enabled by the active dialect; otherwise they are rejected deterministically.

String literals are delimited by double quotes and use JSON-style escapes, including `\"`, `\\`, `\n`, `\r`, `\t`, and `\uXXXX`. Input is UTF-8 and no implicit locale conversions are performed.

Boolean and null literals use the spellings `true`, `false`, and `null`. Whether these spellings are case-sensitive is controlled by the dialect.

Date and datetime values are typed values supplied in the evaluation context. BFL does not parse arbitrary date or datetime strings in core evaluation. If string-to-date or string-to-datetime conversion is required, it must be performed by the consumer before evaluation or by a registered function supplied by the consumer.

Optional ISO-only parsing may be enabled by dialect configuration or by a companion utility package. When enabled, the only accepted date literal text format is `YYYY-MM-DD`. The only accepted datetime literal text format is an RFC3339 timestamp with an explicit UTC `Z` or a numeric offset like `+02:00`. The default policy is offset-required, which rejects datetimes without an explicit offset. Locale and timezone are never inferred from the machine; any locale-like behavior must be configured explicitly by the caller.

Datetime values are interpreted as absolute instants. Comparison and ordering are done on the instant timeline, and any provided offset is normalized to UTC internally for comparison. If the caller explicitly enables `datetime_assume_timezone` and provides a timezone identifier, a datetime string without an offset may be interpreted in that timezone as a deterministic policy choice; otherwise datetimes without offsets are rejected.

#### Typing, coercion, and evaluation order (normative)

BFL has a narrow, explicit coercion model. The only implicit conversions are integer-to-number promotion inside numeric operators, integer-to-number promotion for numeric comparisons, and integer-to-number promotion for numeric function parameters when the expected type is number. There are no other implicit conversions. Booleans do not coerce from numbers or strings, strings do not coerce to numbers, and date or datetime conversions require explicit registered functions or pre-conversion by the consumer.

Arithmetic operator typing is defined as follows. The `+`, `-`, and `*` operators accept integer and number operands only. If both operands are integers and the mathematical result fits in signed 64-bit range, the result is an integer; otherwise the result is a number. If either operand is a number, both operands are treated as numbers and the result is a number. The `/` operator accepts integer and number operands and always produces a number. Division by zero is a deterministic evaluation error.

Comparison operator typing is defined as follows. Equality and not-equal are allowed between any two values, but evaluate to true only when both operands are the same kind and the same value, except that integers and numbers compare by numeric value after integer-to-number promotion. Ordering comparisons `<`, `<=`, `>`, and `>=` are defined only for numeric values (integer or number) and for date and datetime values. Ordering comparisons across unrelated kinds are deterministic type errors.

Null handling is explicit. Null is a real value that does not auto-coerce. Arithmetic with null is a type error. Ordering comparisons with null are a type error. Equality against null is allowed and is true only when both operands are null. If spreadsheet-style empty value behavior is desired in the future, it must be introduced only as a fully specified dialect policy or as library-provided helper functions.

Evaluation order is deterministic. `and` and `or` evaluate the left operand first and short-circuit deterministically: for `and`, if the left operand is false, the result is false without evaluating the right operand; for `or`, if the left operand is true, the result is true without evaluating the right operand. `not` evaluates its single operand. All other binary operators evaluate the left operand and then the right operand.

#### Reference and range validation (normative)

Parsing validates that cell references and column references conform to the token rules. Column references are limited to one to three ASCII letters, and cell references must include a row number with no separators and a row index greater than zero. Row numbers are limited to at most 10 ASCII digits and MUST fit in signed 32-bit range. References with invalid shapes or zero or out-of-range row numbers are parse errors with stable byte offsets. Compilation does not infer dataset sizes or resolve open-ended ranges; it only validates syntax, produces a `RangeExpr` node, and assigns it a `KindArray` type. Optional symbol typing for identifiers remains consumer-provided and is not required for core conformance.

#### Type system and evaluation context (normative Go representation)

The type system and evaluation context are defined as a stable Go representation so binding and typechecking are deterministic and independent of runtime values.

```go
type Kind int

const (
	KindNull Kind = iota
	KindBool
	KindString
	KindInteger
	KindNumber
	KindDate
	KindDateTime
	KindArray
	KindAny
)

type Type struct {
	Kind     Kind
	Nullable bool
	Elem     *Type
}

type Value struct {
	Kind     Kind
	Bool     bool
	String   string
	Int      int64
	Number   Decimal
	Date     Date
	DateTime DateTime
	Array    Array
}
```

Only the field matching `Kind` is meaningful. Null is represented as `Kind == KindNull`, not by `Nullable`. `KindAny` is allowed for function signatures and symbol declarations but is not required as a runtime value. `KindArray` is a first-class runtime value kind; when `Type.Kind` is `KindArray`, `Type.Elem` may be set to express an element type, and when it is absent the array is treated as array(any).

`Decimal` is a BusDK-owned decimal type with deterministic string formatting and deterministic arithmetic. Decimal values are normalized and compared deterministically. The library MUST NOT use IEEE float semantics for `KindNumber`.

`Date` is a BusDK-owned calendar date representation with validation rules and ISO formatting.

`DateTime` is a BusDK-owned instant representation in UTC with deterministic comparison by timeline order. Any offsets used during optional ISO parsing are normalized into this UTC instant representation and are not preserved as presentation state.

Array values are deterministic, minimal 2D matrices. `Array.Rows` and `Array.Cols` are non-negative integers, and `Array.Items` is a flat slice in row-major order. `Array.Items` length MUST equal `Rows * Cols`, including when one or both dimensions are zero. Array elements may be any `Value` kind; higher-level constraints are owned by consumers and registered function sets.

```go
type Decimal struct{}
type Date struct {
	Year  int
	Month int
	Day   int
}

type DateTime struct {
	UnixNano int64
}

type Array struct {
	Rows  int
	Cols  int
	Items []Value
}
```

#### BusDK-owned type contracts (normative)

`Decimal` is the authoritative numeric type for BFL. Decimal parsing from numeric literals is exact and preserves the literal’s base-10 value without introducing binary floating point semantics. Canonical decimal strings never use exponent notation, remove trailing zeros after the decimal point, omit a trailing decimal point, and normalize negative zero to `0`. Decimal comparison is by numeric value after normalization. Arithmetic is deterministic and uses a decimal context with a default scale of 18 and default rounding mode half-up (ties away from zero). Division produces a finite decimal by applying the active decimal context; non-terminating divisions are rounded deterministically. If `EvalOptions.Rounding` is provided, its scale and mode override the default context for division and for the final numeric result.

`Date` uses the proleptic Gregorian calendar and validates month and day ranges. `Date` compares lexicographically by `(year, month, day)` and formats as `YYYY-MM-DD`. The valid range is `0001-01-01` through `9999-12-31`; out-of-range values are a deterministic error during parsing or conversion.

`DateTime` is an absolute UTC instant with no stored timezone. `DateTime` comparisons are by timeline order and formatting for tests uses RFC3339 with `Z`. `DateTime` values must fit in signed 64-bit nanoseconds from the Unix epoch; out-of-range values are a deterministic error during parsing or conversion.

The `bus-bfl` repository MUST include dedicated unit tests that verify the `Decimal`, `Date`, and `DateTime` semantics used by evaluation, including edge cases such as `1/3`, rounding ties, and datetime normalization. If a shared BusDK type package is introduced later, it may reuse these tests, but the BFL SDD remains the normative behavioral contract.

Static and runtime contexts are defined separately. Compile uses `SymbolTable` only. Eval uses `RuntimeContext` only. Eval MUST return a deterministic error if a required identifier is missing at runtime even if it existed at compile time. Identifier matching is applied consistently according to the active dialect in both compilation and evaluation.

```go
type SymbolTable interface {
	TypeOf(name string) (Type, bool)
}

type MapSymbols map[string]Type

type RuntimeContext interface {
	ValueOf(name string) (Value, bool)
}

type MapContext map[string]Value
```

References and ranges are represented explicitly in the core library to avoid locale parsing at evaluation time. Column indices and row indices are 1-based. The RowIndex is optional for column references.

```go
type Ref struct {
	ColumnIndex int
	RowIndex    int
	HasRow      bool
}
```

Column letters map to indices deterministically: `A` maps to 1, `B` to 2, `Z` to 26, `AA` to 27, and so on. Parsing produces `Ref` values directly from reference tokens, and the evaluator never re-parses reference text. Range resolution is consumer-provided via an optional interface implemented by the runtime context.

```go
type RangeProvider interface {
	Range(start Ref, end Ref) (Array, bool, error)
}
```

When evaluation encounters a range expression, the runtime context MUST implement `RangeProvider`. If it does not, evaluation returns a deterministic error with a stable error code indicating that ranges are unsupported by the current context. If the interface is present, evaluation calls `Range` and returns its array value. The consumer defines how references map to its data model and how open-ended ranges determine the last row; resolution MUST be pure and deterministic.

Range providers and function implementations MUST respect `Limits.MaxArrayElements` when constructing arrays. If array materialization would exceed the limit, evaluation returns a deterministic limit error. Any evaluation work that iterates array elements counts toward `Limits.MaxEvalSteps` in a deterministic way defined by the function implementation; functions MUST NOT perform unbounded iteration.

Function registration is explicit and deterministic. The canonical `Registry` implementation preserves deterministic registration order so overload selection is stable across runs. Functions are pure and MUST NOT perform I/O, read environment variables, or use time-dependent behavior. They may only use their inputs and the provided call context. Function signatures may use `KindArray` for arguments and return values.

```go
type FunctionRegistry interface {
	Lookup(name string) ([]FunctionOverload, bool)
}

type Registry struct{}

type FunctionOverload struct {
	Name      string
	Signature Signature
	Impl      FunctionImpl
}

type Signature struct {
	Args   []Type
	VarArgs *Type
	Return Type
}

type FunctionImpl func(call CallContext, args []Value) (Value, error)

type CallContext interface {
	Dialect() Dialect
	Lookup(name string) (Value, bool)
}
```

Overload selection is deterministic. Overloads are tried in the order they are registered and the first matching signature is used; if multiple match equally, the first wins; if none match, the result is a type error with a stable error code. Matching is defined as follows. A runtime null value matches a parameter type only if that parameter type is nullable or `KindAny`. An integer argument matches a number parameter type via integer-to-number promotion, but a number argument does not match an integer parameter type. `KindAny` matches any runtime value. All other kinds require exact kind matches with no implicit conversions.

When a parameter kind is `KindArray`, it matches only `KindArray` values or null values when the parameter is nullable. If `Type.Elem` is provided, array elements must match the element type deterministically during evaluation; if `Type.Elem` is absent, the array is treated as array(any) and element matching is not enforced by the core library.

#### References

BFL can reference fields from the current row by identifier. Identifiers use ASCII letters and underscore for the first character, followed by ASCII letters, digits, or underscore. Identifier matching is case-sensitive or case-insensitive according to the active dialect. For non-identifier column names, the consumer MUST provide an escape hatch, with `col("column name")` as the recommended form implemented via function registration. Identifiers and functions are supplied by consumers outside this core library.

In addition to identifiers, BFL supports spreadsheet-style references and ranges as described in the lexical and grammar sections. References are syntactic tokens that compile to `Ref` values, and ranges are parsed into a distinct AST node `RangeExpr` that only accepts reference tokens on each side. Ranges do not imply any data model or dataset size; they are resolved only through the consumer-provided `RangeProvider` at evaluation time.

#### Operators

The language supports arithmetic operators `+ - * /`, comparison operators, and boolean operators `and or not`. The exact token spellings that are accepted are controlled by the active dialect, and canonical printing uses the dialect’s canonical token set.

##### Operator precedence and associativity (normative)

Precedence from highest to lowest is: parenthesized and primary expressions (literals, identifiers, reference tokens, range expressions, and function calls); unary operators (`not`, unary `+`, unary `-`); multiplicative (`*`, `/`); additive (`+`, `-`); comparison (`=`, `==`, `<>`, `!=`, `<`, `<=`, `>`, `>=` as accepted by the dialect); boolean `and`; boolean `or`. Unary operators bind to the immediate right operand. `*`, `/`, `+`, `-`, `and`, and `or` are left-associative. Comparisons are non-associative; chained comparisons such as `a < b < c` are rejected with a deterministic parse error. Parentheses override precedence as usual.

Canonical printing is optional, but if implemented it MUST use the dialect’s canonical token set and lowercase keyword spellings. In the default dialect, equality prints as `=` and not-equal prints as `<>`. In `dialect.programmer`, equality prints as `==` and not-equal prints as `!=`.

Range expressions are a distinct AST node (`RangeExpr`) that can only be formed from reference tokens on each side of the colon. The colon is not a general operator and cannot be used for arbitrary expression slicing. Arithmetic and comparisons do not accept array or range operands, and the core language does not define any operators over arrays. Arrays may only flow into registered functions or be returned by registered functions unless a later version explicitly adds array operators.

#### Functions

BFL does not implement built-in functions. Callers register function sets with names, signatures, and pure implementations, and both validation and evaluation only allow registered functions.

#### Errors

Errors are deterministic and use the exported `Error` type with stable kind, code, and source location. Parse errors cover invalid syntax and invalid reference tokens. Bind errors cover unknown identifiers or missing references. Type errors cover invalid operand types for an operator or function. Evaluation errors include division by zero, invalid operations, and unsupported range evaluation when the runtime context does not implement `RangeProvider`. Limit errors cover configured caps such as expression length, AST nodes, recursion depth, evaluation steps, and array elements. Errors MUST include a stable byte offset and may include line and column information, along with a concise message that is not intended as a long-term parsing target.

### Security Considerations

BFL evaluation is side-effect free. The implementation MUST NOT permit filesystem access, network access, subprocess execution, environment reads, or unbounded computation.

Implementations MUST protect against resource exhaustion by bounding AST size, recursion depth, evaluation complexity, and array materialization size.

### Observability and Logging

The library returns structured errors and does not log by default. If a CLI exists, it prints results to stdout and diagnostics to stderr deterministically.

### Error Handling and Resilience

The library must return typed errors for invalid inputs and must not panic for user-provided expressions. Any CLI that exists must use BusDK conventions for exit codes and diagnostics.

### Testing Strategy

Unit tests cover deterministic parsing and evaluation, stable parse error locations, unknown references, type errors, division by zero, rounding behavior, rejection of unregistered functions, correct execution of registered functions, range parsing and canonical formatting, array materialization limits, and row-local evaluation across multiple rows or contexts with different formulas.

Integration tests in [bus-data](./bus-data) cover computing projected values during table reads without writing, deterministic diagnostics when formulas fail, and preservation of raw formula strings in storage.

A machine-readable conformance test suite is required and must ship with the library. The suite lives under `./tests` in the `bus-bfl` repository and is the authoritative compatibility lock for future changes. It MUST cover operator precedence grouping and associativity, canonical printing, numeric literal parsing including exponent handling and leading-dot acceptance where allowed, rejection cases such as chained comparisons and thousands separators, datetimes without offsets when ISO parsing is enabled, date/datetime comparison semantics using typed context values, and range parsing and formatting for `A1:A`, `A:A`, and `A1:B2` with deterministic offsets. The required file format is JSON Lines with UTF-8 encoding, one test vector per line, so it is easy to stream, diff, and extend. File names use `./tests/dialect.<profile>.jsonl` for each named dialect profile, plus an optional `./tests/README.md` describing the schema.

Each test vector object includes a stable `id` string (for example `BFL-CONF-000001`), the `dialect` profile name, the `expr` source string, optional `limits` overrides only when needed, an optional `symbols` map from identifier to type, an optional `context` map from identifier to typed value, an optional `format_expect` string for canonical printing, and either an `eval_expect` typed value or an `error_expect` object. Values are type-tagged to avoid JSON number ambiguity, with each value encoded as an object containing `type` and `value`, where decimal numbers and integers are encoded as strings, dates use `YYYY-MM-DD`, and datetimes use RFC3339 strings with an offset or `Z` that normalize to the internal UTC instant. The `error_expect` object matches the library error contract and includes `kind`, `code`, and at least `offset` for position; line and column may be included but offset is mandatory. These test vectors must be run in CI for source code library releases and are not required for `bus-bfl` CLI binary releases.

The suite MUST include evaluation vectors that use a minimal test harness context implementing `RangeProvider` and returning known arrays, plus vectors where a user-registered function accepts an array and returns a scalar and where a user-registered function returns an array that is passed into another function. These vectors must demonstrate arrays as first-class runtime values without relying on any real dataset.

Benchmark tests must run against the normative CI reference profile and emit the required benchmark metadata via the helper in stable text and JSON forms. CI MUST store the benchmark output and metadata as artifacts for each release tag so timing targets are auditable and comparable across releases.

### Deployment and Operations

Not Applicable. The module ships as a Go library and an optional CLI component in BusDK.

### Migration/Rollout

BFL semantics evolve under BusDK module versioning. Any behavior change must be documented in the module changelog and release notes, including how existing expressions may be affected.

### Risks

R-BFL-001 Ambiguity between identifiers and reserved words. Mitigation: maintain a reserved keyword list and provide the `col("...")` escape hatch.

R-BFL-002 Numeric precision expectations. Mitigation: decimal arithmetic and explicit rounding configuration with deterministic defaults.

R-BFL-003 Future cross-table lookups. Mitigation: keep row-local semantics initially and introduce lookups only with explicit schema-declared dependencies and deterministic failure modes.

### Suggested extensions (workbook extraction parity)

Formula metadata and evaluation for workbook extraction are implemented in [bus-data](./bus-data): `bus data table workbook --formula`, `--formula-source`, and `--formula-dialect` support deterministic delegation with source-specific token behavior and locale-aware evaluation (decimal and thousands separators). Common parity functions (`SUM`, `IF`, `ROUND`) are provided by the consumer-side function registry in bus-data, while BFL remains pure and function-set agnostic. BFL provides the dialect options and function registration framework; the consumer is responsible for building dialect from source locale and registering the function set. The normative contract is documented in [FR-DAT-025](./bus-data#requirements) and in [Formula metadata and evaluation for workbook extraction](../modules/bus-bfl-workbook-formula-delegation).

### Glossary and Terminology

BFL is the BusDK Formula Language, a deterministic expression language for formulas.

Formula source is the stored string representation of an expression.

Computed value is the result of evaluating a formula source against a context.

Projection is a read-time view of a dataset that may include computed values without writing.

Cell reference is an Excel-like A1 token that identifies a column and row by letters and a 1-based row number.

Column reference is an Excel-like token that identifies a column by letters without a row number.

Range is a `ref_start:ref_end` expression that resolves to an array via a consumer-provided range resolver.

Array value is a 2D, row-major matrix of `Value` elements carried as a first-class runtime kind.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-dev">bus-dev</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [See also: Project SDD](https://docs.busdk.com/sdd)
- [bus-data SDD](./bus-data)
- [Frictionless Table Schema](https://specs.frictionlessdata.io/table-schema/)
- [Frictionless Data Package](https://specs.frictionlessdata.io/data-package/)
- [OpenDocument Formula (OpenFormula) specification](https://docs.oasis-open.org/office/OpenDocument/v1.3/OpenDocument-v1.3-part4-formula.pdf)
- [Excel operator precedence guidance](https://support.microsoft.com/en-us/office/calculation-operators-and-precedence-in-excel-48be406d-4975-4d31-b2b8-7af9e0e2878a)
- [Frictionless Table Schema date/time formats](https://frictionlessdata.io/specs/table-schema/)
- [Google Sheets locale and time zone settings](https://support.google.com/docs/answer/58515?co=GENIE.Platform%3DDesktop&hl=en)

### Document control

Title: bus-bfl module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-BFL`  
Version: 2026-02-08  
Status: Draft  
Last updated: 2026-02-08  
Owner: BusDK development team  
