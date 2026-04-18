---
title: Go optimization guide
description: Implementation-focused performance guidance is maintained in the private SDD workspace.
---

## Go optimization guide

Implementation-focused optimization guidance moved to the private SDD workspace.

For end-user guidance, use:

- [Module CLI reference](../modules/)
- [Workflow guides](../workflow/)

## Pattern Compilation Inside Row Validation Loops

Anti-pattern:

- Compiling the same regexp from schema field constraints inside the per-row validation loop. In `bus-accounts`, `ensurePatternMatch` currently calls `regexp.Compile` for every validated value, so schema patterns pay compile cost repeatedly instead of once per schema.

Benchmark evidence:

- `BenchmarkEnsurePatternMatchCompiledEachCall1000`: `1309457 ns/op`, `2809602 B/op`, `40005 allocs/op`
- `BenchmarkRegexpMatchStringCompiledOnce1000`: `44232 ns/op`, `0 B/op`, `0 allocs/op`
- `BenchmarkValidateTablePatternRows1000`: `1790114 ns/op`, `3424837 B/op`, `44090 allocs/op`
- Shape: the isolated 1,000-match workload is about 30x slower when the regexp is recompiled per call, and the full table-validation path shows the same allocation-heavy profile.

Runnable benchmark command:

```sh
go test ./internal/validate -run '^$' -bench 'Benchmark(Validate(Table|Rows)PatternRows1000|EnsurePatternMatchCompiledEachCall1000|RegexpMatchStringCompiledOnce1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current error text for invalid schema patterns.
- Compile patterns once per parsed schema or per validation pass, not globally across unrelated schemas/workspaces.
- Keep nil/empty-pattern handling unchanged so unpatterned fields still skip regexp work entirely.

## Rebuilding Grouped Report Trees For Every Snapshot

Anti-pattern:

- Re-running grouped tree construction once per balance snapshot in grouped report generation. `BuildGroupedReportRowsWithSnapshots` currently calls `groups.BuildTreeLines` for each snapshot, rebuilding the same deterministic hierarchy and merge keys even though only balances change between snapshots.

Benchmark evidence:

- `BenchmarkBuildGroupedReportRowsWithSnapshots1x500`: `337158 ns/op`, `803221 B/op`, `10916 allocs/op`
- `BenchmarkBuildGroupedReportRowsWithSnapshots4x500`: `1106864 ns/op`, `2361460 B/op`, `36503 allocs/op`
- `BenchmarkBuildGroupedReportRowsWithSnapshots8x500`: `2390445 ns/op`, `4428405 B/op`, `69176 allocs/op`
- Shape: cost and allocations scale almost linearly with snapshot count for the same 500-account / 50-group hierarchy, which indicates the fixed tree/topology work is being repeated per snapshot.

Runnable benchmark command:

```sh
go test ./internal/accounts -run '^$' -bench 'BenchmarkBuildGroupedReportRowsWithSnapshots(1x500|4x500|8x500)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the existing deterministic row order, depth, group/account/subtotal typing, and zero-filled balance semantics.
- Keep grouped and ungrouped account handling identical to current output, especially for accounts without `group_id`.
- Do not change `groups.BuildTreeLines` externally visible behavior unless the report path is explicitly moved to a shared cached topology helper with equivalent output coverage.

## Rebuilding `map[string]string` Views For Every Attachment/List Row

Anti-pattern:

- Materializing a fresh `map[string]string` for every CSV row scan in `bus-attachments` list/graph assembly. In [internal/attachments/list.go](/Users/jhh/git/busdk/busdk/bus-attachments/internal/attachments/list.go), the current path builds `rowValues(...)` maps for every link row and every attachment row, then keeps many of those maps alive inside `linksByAttachment`, even though the hot path only needs a small fixed set of indexed columns.

Benchmark evidence:

- `BenchmarkListGraphRowsRowValuesMaps1000x3`: `1272455 ns/op`, `1623855 B/op`, `15025 allocs/op`
- `BenchmarkListGraphRowsIndexed1000x3`: `482957 ns/op`, `691642 B/op`, `9010 allocs/op`
- Shape: for a 1,000-attachment / 3,000-link list+graph workload, the indexed benchmark helper is about 2.6x faster and cuts allocation volume by about 57%, which points to row-map hydration as a primary hotspot in list assembly.

Runnable benchmark command:

```sh
go test ./internal/attachments -run '^$' -bench 'BenchmarkListGraphRows(RowValuesMaps1000x3|Indexed1000x3)$' -benchmem
```

Behavior and safety guardrails:

- Preserve deterministic output ordering by `attachment_id` and existing per-attachment sorted graph token ordering.
- Keep filter semantics unchanged for date windows, link-kind selectors, unlinked-only output, and audit modes such as `--fail-if-missing-kind`.
- Avoid introducing shared mutable row views that can leak values across iterations; any indexed accessor or typed view must remain per-table deterministic and read-only.

## Rebuilding Row Maps During Schema Validation

Anti-pattern:

- Reconstructing `map[string]string` row views inside validation passes in [internal/attachments/validate.go](/Users/jhh/git/busdk/busdk/bus-attachments/internal/attachments/validate.go). `validateTable` and `validatePrimaryKey` both call `rowValues(...)` while walking every row, even though validation already has stable `FieldIndex` metadata and only needs direct indexed reads.

Benchmark evidence:

- `BenchmarkValidateTableRowValuesMaps1000`: `1156202 ns/op`, `162571 B/op`, `2243 allocs/op`
- `BenchmarkValidateTableIndexed1000`: `842501 ns/op`, `162566 B/op`, `2243 allocs/op`
- Shape: for a 1,000-row attachments table, the indexed benchmark helper is about 27% faster with the same validation rules, which shows the repeated row-map hydration and field-name lookup work is measurable even before wider I/O costs.

Runnable benchmark command:

```sh
go test ./internal/attachments -run '^$' -bench 'BenchmarkValidateTable(RowValuesMaps1000|Indexed1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current validation error text and row numbering for required fields, enum mismatches, type failures, pattern failures, and duplicate primary keys.
- Keep schema-driven behavior unchanged: validators must still respect optional empty values, current `primaryKey` handling, and the same `FieldIndex`/header contract.
- Any optimization should remain local to one validation pass or parsed table instance; do not introduce cross-workspace caches that could retain stale schema state.

## Rescanning `accounts.csv` For Every Account Validation

Anti-pattern:

- Reopening, reparsing, and rescanning the full chart file for every `HasAccount` call in [internal/workspace/chart.go](/Users/jhh/git/busdk/busdk/bus-balances/internal/workspace/chart.go). `runImport` and `runApply` validate one account at a time, so the current `FSChart.HasAccount` path pays `csv.ReadAll` and a linear scan once per snapshot row instead of once per command.

Benchmark evidence:

- `BenchmarkValidateAccountCodesFSChart1000x200`: `36249741 ns/op`, `27267242 B/op`, `405800 allocs/op`
- `BenchmarkValidateAccountCodesPreloadedSet1000x200`: `1824 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: validating 200 account codes against a 1,000-row chart is about 19,000x slower when every lookup reparses `accounts.csv`, with about 27 MB and 405k allocations per operation in the repeated-scan path.

Runnable benchmark command:

```sh
go test ./internal/workspace -run '^$' -bench 'BenchmarkValidateAccountCodes(FSChart1000x200|PreloadedSet1000x200)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current trimmed-header and trimmed-account matching semantics for the `code` column.
- Keep the current missing-file behavior: a missing `accounts.csv` must still behave like "account not found", not a cached success.
- Scope any cache or preloaded set to one command/workspace view; do not introduce a long-lived global cache that can outlive chart edits.

## Hydrating `map[string]string` For Every Journal Period Row

Anti-pattern:

- Building a fresh `map[string]string` for every row returned by `readPeriodCSV` in [internal/workspace/journal.go](/Users/jhh/git/busdk/busdk/bus-balances/internal/workspace/journal.go). `AppendTransaction` and `RemoveTransactionsByMarker` only need a small fixed column subset for filtering and appending, but the current path eagerly materializes maps for the whole file before rewriting it.

Benchmark evidence:

- `BenchmarkReadPeriodCSVRowMaps10000`: `6769218 ns/op`, `13048659 B/op`, `70041 allocs/op`
- `BenchmarkReadPeriodCSVIndexed10000`: `2556328 ns/op`, `3446674 B/op`, `20040 allocs/op`
- Shape: on a 10,000-row journal period file, the indexed row benchmark is about 2.6x faster and cuts allocation volume by about 74%, which indicates row-map hydration is a major cost in journal rewrite paths.

Runnable benchmark command:

```sh
go test ./internal/workspace -run '^$' -bench 'BenchmarkReadPeriodCSV(RowMaps10000|Indexed10000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the existing journal column names, output ordering, and marker-matching behavior used for replace detection.
- Keep append/remove flows compatible with both single-file and indexed journal layouts.
- If a typed or indexed row representation is introduced internally, convert to the exact `store.WriteEntries` shape only at the write boundary so externally visible journal bytes remain unchanged.

## Recompiling PDF Statement Parse Regexes Per Document And Per Line

Anti-pattern:

- Rebuilding the same regular expressions inside hot PDF statement-parse helpers in `bus-bank`. [internal/bank/statement_parse.go](/Users/jhh/git/busdk/busdk/bus-bank/internal/bank/statement_parse.go) currently calls `regexp.MustCompile` or `regexp.Compile` inside `extractStatementDocumentIdentityFromText`, `parseCountAmountLine`, `parseTrailingAmount`, `parsePDFTransactionLines`, and `normalizeTransactionDescription`, so every parsed PDF document and many individual lines pay pattern compilation cost again.

Benchmark evidence:

- `BenchmarkExtractStatementDocumentIdentityFromTextCompiledEachCall200`: `19453 ns/op`, `24452 B/op`, `166 allocs/op`
- `BenchmarkExtractStatementDocumentIdentityFromTextPrecompiled200`: `11069 ns/op`, `3686 B/op`, `8 allocs/op`
- `BenchmarkExtractStatementDocumentSummaryFromTextCompiledRegexes200`: `9126932 ns/op`, `17164248 B/op`, `162657 allocs/op`
- `BenchmarkExtractStatementDocumentSummaryFromTextPrecompiledRegexes200`: `2439726 ns/op`, `429590 B/op`, `12203 allocs/op`
- `BenchmarkParsePDFTransactionLinesCompiledRegexes200`: `1506546 ns/op`, `1890820 B/op`, `25145 allocs/op`
- `BenchmarkParsePDFTransactionLinesPrecompiledRegexes200`: `981260 ns/op`, `510524 B/op`, `11412 allocs/op`
- Shape: on the current benchmark corpus, summary extraction is about 3.7x slower with per-line compilation and allocates about 40x more memory, while identity extraction and transaction-line parsing also show clear per-call compilation overhead.

Runnable benchmark command:

```sh
go test ./internal/bank -run '^$' -bench 'Benchmark(ExtractStatementDocument(IdentityFromText(CompiledEachCall200|Precompiled200)|SummaryFromText(CompiledRegexes200|PrecompiledRegexes200))|ParsePDFTransactionLines(CompiledRegexes200|PrecompiledRegexes200))$' -benchmem
```

Behavior and safety guardrails:

- Preserve current extracted field values, confidence/provenance strings, and the existing line-skipping heuristics for `saldo`, `IBAN`, `BIC`, and summary rows.
- Keep regex ownership local to the `statement_parse` package or to one parse pass; do not introduce mutable global caches keyed by workspace or document contents.
- Preserve current normalization behavior for Finnish/English labels, trailing sequence stripping, and number/date parsing so parse output and diagnostics remain byte-stable.

## Recompiling Schema Field Patterns For Every Validated Row

Anti-pattern:

- Re-anchoring and recompiling field constraint patterns inside `validateRow` in [internal/bank/validate.go](/Users/jhh/git/busdk/busdk/bus-bank/internal/bank/validate.go). Schema-backed loaders such as [internal/bank/mapping.go](/Users/jhh/git/busdk/busdk/bus-bank/internal/bank/mapping.go), [internal/bank/statement_checkpoints.go](/Users/jhh/git/busdk/busdk/bus-bank/internal/bank/statement_checkpoints.go), and [internal/bank/datasets.go](/Users/jhh/git/busdk/busdk/bus-bank/internal/bank/datasets.go) call `validateRow` for every row, and the current implementation rebuilds `^(?:pattern)$` and calls `regexp.Compile` for every non-empty constrained cell.

Benchmark evidence:

- `BenchmarkValidateRowCompiledPatternEachCall1000`: `1591133 ns/op`, `2786319 B/op`, `39007 allocs/op`
- `BenchmarkValidateRowPrecompiledPattern1000`: `174543 ns/op`, `54 B/op`, `0 allocs/op`
- Shape: for a 1,000-row validation workload, recompiling the same field pattern on every row is about 9x slower and turns an allocation-free match loop into a multi-megabyte allocation hotspot.

Runnable benchmark command:

```sh
go test ./internal/bank -run '^$' -bench 'BenchmarkValidateRow(CompiledPatternEachCall1000|PrecompiledPattern1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current validation error text, especially `invalid pattern for <field>` and `<field> does not match pattern`.
- Compile patterns once per parsed schema, once per validation pass, or in another workspace-local scope; do not retain long-lived caches across unrelated schema files or workspaces.
- Keep existing enum, required-field, date/number, and row-numbering behavior unchanged so storage and import diagnostics remain deterministic.

## Recompiling Customer Schema Regexes For Every Validated Cell

Anti-pattern:

- Re-anchoring and recompiling `customers.schema.json` field patterns inside the per-cell validation loop in `bus-customers`. In [internal/customers/validator.go](/Users/jhh/git/busdk/busdk/bus-customers/internal/customers/validator.go), `validateCell` currently calls `regexp.MatchString` for every non-empty patterned value, so `validateDataset` recompiles the same `customer_id` and `entity_id` regexes once per row instead of once per validation pass.

Benchmark evidence:

- `BenchmarkValidateCellPatternCompiledEachCall1000`: `1386701 ns/op`, `2673478 B/op`, `38002 allocs/op`
- `BenchmarkValidateCellPatternPrecompiled1000`: `126727 ns/op`, `0 B/op`, `0 allocs/op`
- `BenchmarkValidateDatasetPatternRowsCurrent1000`: `3282705 ns/op`, `5746808 B/op`, `78028 allocs/op`
- `BenchmarkValidateDatasetPatternRowsPrecompiled1000`: `642202 ns/op`, `399122 B/op`, `2009 allocs/op`
- Shape: on a 1,000-row customers dataset with the current `customer_id` and `entity_id` patterns, the current row-validation path is about 5x slower and allocates about 14x more memory than an equivalent precompiled-pattern pass.

Runnable benchmark command:

```sh
go test ./internal/customers -run '^$' -bench 'BenchmarkValidate(CellPattern(CompiledEachCall1000|Precompiled1000)|DatasetPatternRows(Current1000|Precompiled1000))$' -benchmem
```

Behavior and safety guardrails:

- Preserve current anchored-pattern semantics exactly, including the existing `^...$` wrapping behavior for schema patterns.
- Preserve current validation errors and row numbering for required fields, invalid patterns, mismatch failures, and duplicate primary keys.
- Scope compiled regexes to one parsed schema or one validation pass inside `bus-customers`; do not add process-wide caches that can outlive schema edits in the workspace.

## Rebuilding Import-Profile Lookup Indexes For Every Source Row

Anti-pattern:

- Recomputing lookup-step metadata and rebuilding the full lookup-table key/value map inside `applyLookupWithRecords` for every source row in [pkg/data/profile_exec.go](/Users/jhh/git/busdk/busdk/bus-data/pkg/data/profile_exec.go). During `ExecuteProfile`, a `lookup` step already loads the lookup table once, but the current helper still rescans the lookup header and rebuilds the map once per row instead of once per step.

Benchmark evidence:

- `BenchmarkApplyLookupWithRecordsBuildsLookupEachRow1000x1000`: `65532854 ns/op`, `159992860 B/op`, `20008 allocs/op`
- `BenchmarkApplyLookupWithRecordsPreindexed1000x1000`: `94597 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for a 1,000-row source table with a 1,000-row lookup table, the per-row rebuild path is about 690x slower and allocates about 160 MB per operation, which isolates the lookup-index rebuild as the dominant cost.

Runnable benchmark command:

```sh
go test ./pkg/data -run '^$' -bench 'BenchmarkApplyLookupWithRecords(BuildsLookupEachRow1000x1000|Preindexed1000x1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current first-match-wins semantics when duplicate lookup keys exist in the lookup table.
- Keep lookup defaults unchanged when the source-row key is missing or not found.

## Recompiling Vendor Schema Regexes For Every Validated Cell

Anti-pattern:

- Re-anchoring and recompiling schema field patterns inside `validateCell` in [internal/vendors/validator.go](/Users/jhh/git/busdk/busdk/bus-vendors/internal/vendors/validator.go). `ValidateVendors` and `AddVendor` both call `validateDataset`, and the current `regexp.MatchString("^"+...+"$", value)` path recompiles the same `vendor_id` and `entity_id` patterns for every non-empty constrained cell.

Benchmark evidence:

- `BenchmarkValidateCellPatternCompiledEachCall1000`: `1476400 ns/op`, `2673510 B/op`, `38002 allocs/op`
- `BenchmarkValidateCellPatternPrecompiled1000`: `162861 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for a 1,000-value validation workload using the current vendor ID pattern, recompiling the regexp per cell is about 9x slower and turns a zero-allocation match loop into a multi-megabyte allocation hotspot.

Runnable benchmark command:

```sh
go test ./internal/vendors -run '^$' -bench 'BenchmarkValidateCellPattern(CompiledEachCall1000|Precompiled1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current anchored-pattern semantics exactly, including the existing `^...$` wrapping behavior for schema patterns that may already include anchors.
- Preserve current validation errors for required fields, invalid patterns, mismatch failures, and row numbering.
- Scope compiled regexes to one parsed schema or one validation pass in `bus-vendors`; do not introduce long-lived process-wide caches that can outlive schema edits.

## Hydrating `map[string]string` For Every Vendor Row During Validation

Anti-pattern:

- Materializing a fresh `map[string]string` for every row in `validateDataset` in [internal/vendors/validator.go](/Users/jhh/git/busdk/busdk/bus-vendors/internal/vendors/validator.go). The current path builds row maps for every schema field before primary-key checks and later linked-entity/output assembly, even though the hot path only needs indexed field access for validation plus a small fixed vendor shape.

Benchmark evidence:

- `BenchmarkValidateDatasetRowMapsNoPatterns1000`: `174138 ns/op`, `398802 B/op`, `2006 allocs/op`
- `BenchmarkValidateDatasetIndexedNoMaps1000`: `78719 ns/op`, `103760 B/op`, `6 allocs/op`
- Shape: on a 1,000-row vendor dataset without regex costs in the loop, avoiding per-row map hydration is about 2.2x faster and cuts allocation volume by about 74%, which isolates row-map construction as a measurable validation hotspot on its own.

Runnable benchmark command:

```sh
go test ./internal/vendors -run '^$' -bench 'BenchmarkValidateDataset(RowMapsNoPatterns1000|IndexedNoMaps1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current required-field checks, primary-key duplicate detection, row numbering, and entity-link validation behavior.
- Keep `ValidateVendors` output byte-stable apart from performance: same vendor field mapping and same final sort by `vendor_id`.
- Any typed or indexed row view should remain local to one validation pass and should not leak mutable shared state across rows or commands.

## Rebuilding `map[string]string` Rows During VAT Table Validation

Anti-pattern:

- Materializing a fresh `map[string]string` for every CSV row in [internal/vat/validate.go](/Users/jhh/git/busdk/busdk/bus-vat/internal/vat/validate.go) before validation and then keeping those maps for downstream invoice parsing. `readTable` currently copies every header/value pair into a map, and `validateRowFields` then rereads the same cells by field name instead of using stable header indexes.

Benchmark evidence:

- `BenchmarkReadTableValidationRowMaps1000`: `7896362 ns/op`, `17732110 B/op`, `180023 allocs/op`
- `BenchmarkReadTableValidationIndexed1000`: `629979 ns/op`, `65622 B/op`, `3177 allocs/op`
- Shape: on a 1,000-row VAT invoice-like schema, the indexed benchmark helper is about 12.5x faster and cuts allocation volume by about 270x, which points to row-map hydration as the dominant cost in the current validation path.

Runnable benchmark command:

```sh
go test ./internal/vat -run '^$' -bench 'BenchmarkReadTableValidation(RowMaps1000|Indexed1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current validation diagnostics, including row numbering and field names in `row N field ...` errors.
- Keep downstream invoice/header lookup semantics unchanged for optional aliases such as `line_id`/`line_no`, `delivery_date`/`performance_date`, and `payment_date`/`paid_date`.
- If an indexed or typed row representation is introduced, only convert to map form at the narrowest remaining compatibility boundary so validation no longer pays whole-row map allocation by default.

## Recompiling VAT Schema Regexes For Every Validated Cell

Anti-pattern:

- Calling `regexp.Compile` inside `matchPattern` for every non-empty constrained cell in [internal/vat/validate.go](/Users/jhh/git/busdk/busdk/bus-vat/internal/vat/validate.go). The current `validateRowFields` loop recompiles the same schema patterns once per row instead of once per schema or validation pass.

Benchmark evidence:

- `BenchmarkValidateRowFieldsPatternCompiledEachCall1000`: `7615294 ns/op`, `17387692 B/op`, `178021 allocs/op`
- `BenchmarkValidateRowFieldsPatternPrecompiled1000`: `625046 ns/op`, `48027 B/op`, `3000 allocs/op`
- Shape: for a 1,000-row patterned VAT validation workload, precompiling the schema regexes is about 12x faster and removes nearly all allocation pressure from the pattern-matching path.

Runnable benchmark command:

```sh
go test ./internal/vat -run '^$' -bench 'BenchmarkValidateRowFieldsPattern(CompiledEachCall1000|Precompiled1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current anchored full-cell semantics: a value must still match the entire pattern, not just a substring.
- Preserve current invalid-pattern and mismatch diagnostics so existing tests and operator guidance remain stable.
- Scope compiled regex ownership to one parsed schema or validation pass; do not introduce a process-global cache that can outlive workspace schema edits.

## Resorting Invoice Lines For Every Reconcile Match

Anti-pattern:

- Resorting the same per-invoice line slice inside the `for _, match := range matches` loop in [internal/vat/reconcile.go](/Users/jhh/git/busdk/busdk/bus-vat/internal/vat/reconcile.go). `LoadReconcileRows` currently calls `sort.Slice` every time it processes another payment match for an invoice, even though line order only depends on `LineID` and `SourceRef`.

Benchmark evidence:

- `BenchmarkLoadReconcileRowsSortLinesPerMatch100x20x10`: `1984451 ns/op`, `3216029 B/op`, `8000 allocs/op`
- `BenchmarkLoadReconcileRowsPresortedLines100x20x10`: `16653 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for 100 invoices with 20 payment matches and 10 lines each, re-sorting on every match is about 119x slower than reusing a once-sorted per-invoice slice, which makes repeated partial-payment workloads disproportionately expensive.

Runnable benchmark command:

```sh
go test ./internal/vat -run '^$' -bench 'BenchmarkLoadReconcileRows(SortLinesPerMatch100x20x10|PresortedLines100x20x10)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the existing deterministic order by `LineID` and then `SourceRef`, because that order drives stable proportional allocation and output row ordering.
- Do not share mutable invoice line slices across invoices or between callers in a way that could let later code mutate cached order accidentally.
- Keep partial-payment allocation semantics unchanged: only the repeated sorting work should move, not the gross/weight calculations or match clamping rules.

## Repeating Header-Name Lookups Inside Evidence Coverage Row Scans

Anti-pattern:

- Resolving the same field names through `map[string]int` on every scanned row in [internal/status/evidence_coverage.go](/Users/jhh/git/busdk/busdk/bus-status/internal/status/evidence_coverage.go). `CollectEvidenceCoverage` currently routes journal, bank, sales, and purchase rows through `rowMatchesYear(...fields...)` and repeated `valueByName(...)` calls, so the hot path pays header-map lookups and field-dispatch work for each row even though the relevant column set is fixed after reading the header.

Benchmark evidence:

- `BenchmarkEvidenceCoverageRowScansMapLookups4x10000`: `5118117 ns/op`, `0 B/op`, `0 allocs/op`
- `BenchmarkEvidenceCoverageRowScansIndexed4x10000`: `3982414 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: across four 10,000-row evidence scopes, precomputing the needed date/id/source columns is about 22-24% faster than repeating header-name lookups inside every row walk.

Runnable benchmark command:

```sh
go test ./internal/status -run '^$' -bench 'BenchmarkEvidenceCoverageRowScans(MapLookups4x10000|Indexed4x10000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the current scope-specific year filters, especially the existing date-field priority order for journal, bank, sales, and purchase rows.
- Keep `invoice_id` vs `id` fallback behavior unchanged for invoice datasets, and preserve the current link matching semantics for voucher, bank row, invoice, and `source_id` coverage.
- Do not introduce mutable shared column state across unrelated CSV files; any indexed-column helper should stay local to one loaded header.

## Materializing Full VAT Period CSVs Before Building A Year Set

Anti-pattern:

- Calling `csv.ReadAll` inside [internal/status/close_readiness.go](/Users/jhh/git/busdk/busdk/bus-status/internal/status/close_readiness.go) `loadYearPeriods` even though the function only needs the `period` column and a deduplicated set for one target year. `collectVATParity` invokes this for both `vat-filed.csv` and `vat-returns.csv`, so close-readiness checks pay full-file materialization before discarding most rows.

Benchmark evidence:

- `BenchmarkLoadYearPeriodsReadAll50000`: `8046575 ns/op`, `9123233 B/op`, `100043 allocs/op`
- `BenchmarkLoadYearPeriodsStreaming50000`: `6739200 ns/op`, `2805127 B/op`, `100018 allocs/op`
- Shape: on a 50,000-row VAT periods file, the streaming helper cuts allocation volume by about 69% and improves runtime by about 16% in representative runs while preserving the same per-year set result.

Runnable benchmark command:

```sh
go test ./internal/status -run '^$' -bench 'BenchmarkLoadYearPeriods(ReadAll50000|Streaming50000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current missing-file and missing-column behavior so close-readiness parity checks fail the same way they do today when `period` is absent or the file cannot be opened.
- Keep trimmed `period` parsing semantics unchanged, including the current `parseYear` acceptance rules and deduplicated set output.
- Limit any streaming rewrite to one call/site; do not add process-wide caches for VAT files because the workspace contents can change between command runs.

## Re-Canonicalizing Preference JSON During Read-Only CLI Rendering

Anti-pattern:

- Re-unmarshaling and re-encoding non-string JSON preference values every time `get` or `list` renders them to stdout. In [internal/run/run.go](/Users/jhh/git/busdk/busdk/bus-preferences/internal/run/run.go), the current output path first probes `json.Unmarshal(..., &string)` and then calls `preferences.CanonicalValue(...)` for every non-string value, so object/array preferences pay full canonicalization cost on every read instead of once when values enter or leave the store.

Benchmark evidence:

- `BenchmarkRenderGetCanonicalizesJSONObjectEachCall`: `4889 ns/op`, `3331 B/op`, `79 allocs/op`
- `BenchmarkRenderGetWritesCanonicalJSONObjectDirect`: `95.40 ns/op`, `256 B/op`, `4 allocs/op`
- `BenchmarkRenderListCanonicalizesJSONObjectsEachCall1000`: `4907641 ns/op`, `3466108 B/op`, `78028 allocs/op`
- `BenchmarkRenderListWritesCanonicalJSONObjectsDirect1000`: `107151 ns/op`, `389802 B/op`, `3012 allocs/op`
- Shape: for a 1,000-item line-oriented list of object-valued preferences, the current render path is about 46x slower and allocates about 8.9x more memory than writing already-canonical JSON bytes directly.

Runnable benchmark command:

```sh
go test ./internal/run -run '^$' -bench 'BenchmarkRender(GetCanonicalizesJSONObjectEachCall|GetWritesCanonicalJSONObjectDirect|ListCanonicalizesJSONObjectsEachCall1000|ListWritesCanonicalJSONObjectsDirect1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the current CLI contract exactly: JSON strings must still print raw string contents without quotes, while non-string values must still print canonical JSON.
- If canonicalization moves to a write or load boundary, keep file bytes deterministic and ensure existing malformed-value/error behavior stays unchanged.
- Do not introduce caches that can return stale preference values after the underlying preferences file changes; any reuse of canonical bytes should stay scoped to the current read/write operation or persisted file content.

## Rescanning Loaded Journal Rows To Allocate The Next `MU-*` Voucher

Anti-pattern:

- Loading the journal once through `journalstore.Load`, then rescanning every loaded row map in [internal/memo/add.go](/Users/jhh/git/busdk/busdk/bus-memo/internal/memo/add.go) to derive the next memorandum voucher id. `nextMemorandumVoucherID` currently trims, prefix-checks, reparses, and compares every `voucher_id` string after the load has already materialized the full row set.

Benchmark evidence:

- `BenchmarkNextMemorandumVoucherIDRowScan100000`: `2366791 ns/op`, `84049 B/op`, `914 allocs/op`
- `BenchmarkNextMemorandumVoucherIDCachedMax100000`: `32.16 ns/op`, `16 B/op`, `2 allocs/op`
- Shape: on a 100,000-row journal snapshot, formatting the next id from a cached maximum is about 73,000x faster than rescanning the full `[]map[string]string`, which isolates post-load voucher-id rescanning as avoidable work in large memo workspaces.

Runnable benchmark command:

```sh
go test ./internal/memo -run '^$' -bench 'BenchmarkNextMemorandumVoucherID(RowScan100000|CachedMax100000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current `MU-*` numbering semantics exactly, including ignoring malformed, zero, negative, or non-`MU-` voucher ids.
- Keep numbering scoped to the currently loaded workspace/journal view; do not introduce a long-lived process-global cache that can outlive journal edits.
- If the optimization requires help from `bus-journal`, expose the maximum memorandum voucher number through a Go library surface instead of shelling out or reimplementing journal storage in `bus-memo`.

## Building JSON Payloads Through Nested Maps For Large Memo Postings

Anti-pattern:

- Materializing debit rows, credit rows, and the top-level journal payload as nested `map[string]string` and `map[string]any` values in [internal/memo/add.go](/Users/jhh/git/busdk/busdk/bus-memo/internal/memo/add.go) before calling `json.Marshal`. The current `buildJournalPayload` path pays hashing and map allocation costs for every posting row even though the JSON shape is fixed.

Benchmark evidence:

- `BenchmarkBuildJournalPayloadMapRows100x100`: `106305 ns/op`, `135903 B/op`, `2070 allocs/op`
- `BenchmarkBuildJournalPayloadTypedRows100x100`: `38557 ns/op`, `27957 B/op`, `214 allocs/op`
- Shape: for a 200-row memo payload with representative source metadata, the typed-payload benchmark is about 2.8x faster and cuts allocation volume by about 79%, which points to map-backed JSON assembly as the dominant local cost in payload building.

Runnable benchmark command:

```sh
go test ./internal/memo -run '^$' -bench 'BenchmarkBuildJournalPayload(MapRows100x100|TypedRows100x100)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the exact JSON field names and omission behavior expected by the `bus-journal` Go entrypoint, including `source_object` alias precedence, optional `source_links`, and `dimensions`/`allow_create` emission.
- Keep row ordering deterministic: debit rows, credit rows, and repeated source links must stay in the same order currently produced from CLI input.
- Do not change amount rendering, memo source-voucher metadata, or any downstream journal validation behavior while replacing maps with typed structs.

## Splitting And Padding Decimal Amount Strings For Every Posting Line

Anti-pattern:

- Parsing memo amounts in [internal/memo/add.go](/Users/jhh/git/busdk/busdk/bus-memo/internal/memo/add.go) by calling `strings.Split`, growing the fractional part with repeated string concatenation, and then `strconv.ParseInt` on newly sliced substrings. `parseDecimalMinor` is on the hot path for every `--debit` and `--credit` amount.

Benchmark evidence:

- `BenchmarkParseDecimalMinorSplit100000`: `5382625 ns/op`, `3200006 B/op`, `100000 allocs/op`
- `BenchmarkParseDecimalMinorIndexed100000`: `1122759 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: across 100,000 representative decimal amounts, an indexed scanner is about 4.8x faster and removes all heap allocation compared with the current split-and-pad implementation.

Runnable benchmark command:

```sh
go test ./internal/memo -run '^$' -bench 'BenchmarkParseDecimalMinor(Split100000|Indexed100000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve exact acceptance and rejection behavior for empty values, optional leading `-`, integer-only values, one-digit fractions, two-digit fractions, and invalid extra separators or non-digit characters.
- Keep minor-unit math exact and free of floating-point conversion.
- Maintain the existing user-facing `debit amount must be a decimal` / `credit amount must be a decimal` error behavior through the surrounding parser.

## Recompiling Entity Schema Regexes For Every Validated Cell

Anti-pattern:

- Rebuilding the same schema constraint regex inside `validateCell` for every non-empty patterned value in [internal/entities/validator.go](/Users/jhh/git/busdk/busdk/bus-entities/internal/entities/validator.go). `ValidateEntities`, `AddEntity`, and `UpdateEntity` all flow through `matchesPattern`, which currently calls `regexp.Compile` once per cell instead of once per parsed schema or validation pass.

Benchmark evidence:

- `BenchmarkValidateCellPatternCompiledEachCall1000`: `2686485 ns/op`, `5467327 B/op`, `67009 allocs/op`
- `BenchmarkValidateCellPatternPrecompiled1000`: `403937 ns/op`, `16020 B/op`, `1000 allocs/op`
- Shape: on a 1,000-cell validation workload with the module’s email-style schema pattern, compiling per cell is about 6.7x slower and allocates roughly 5.4 MB more per operation than reusing one compiled regexp.

Runnable benchmark command:

```sh
go test ./internal/entities -run '^$' -bench 'BenchmarkValidateCellPattern(CompiledEachCall1000|Precompiled1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current validation errors for invalid schema patterns and pattern mismatches, including row/field context.
- Preserve the current full-string match behavior for schema patterns; if patterns are normalized or re-anchored once up front, they must reject and accept the same values as today.
- Keep compiled regex lifetime scoped to one parsed schema or one validation pass; do not introduce process-global mutable caches that can outlive schema edits in a workspace.

## Hydrating `map[string]string` Rows During Entity Validation

Anti-pattern:

- Materializing a fresh `map[string]string` for every CSV row in [internal/entities/validator.go](/Users/jhh/git/busdk/busdk/bus-entities/internal/entities/validator.go) before uniqueness checks and entity projection. `validateDataset` currently builds full row maps even for `ValidateEntities`, where the hot path only needs indexed field reads plus canonical-ID and duplicate checks.

Benchmark evidence:

- `BenchmarkValidateEntitiesRowMaps1000`: `602268 ns/op`, `963328 B/op`, `5032 allocs/op`
- `BenchmarkValidateEntitiesIndexed1000`: `249707 ns/op`, `236976 B/op`, `1016 allocs/op`
- Shape: for a 1,000-row entities dataset, the indexed benchmark helper is about 2.4x faster and cuts allocation volume by about 75%, which isolates row-map hydration and map-based second passes as a measurable hotspot in the read/validate path.

Runnable benchmark command:

```sh
go test ./internal/entities -run '^$' -bench 'BenchmarkValidateEntities(RowMaps1000|Indexed1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current validation outcomes and diagnostics for required fields, enum/type failures, canonical identifier mismatches, duplicate primary keys, and duplicate optional official identifiers.
- Keep row ordering and projected entity fields (`entity_id`, `entity_type`, `display_name`) byte-for-byte identical to current `ValidateEntities` output.
- If the implementation switches to indexed access or a typed row view, keep it local to one loaded dataset and avoid shared mutable row state across validation passes.

## Reparsing Topic Money Fields Multiple Times During Store Validation

Anti-pattern:

- Reparsing the same topic money strings multiple times inside one `ValidateStore` pass in `bus-debts`. In [internal/debts/debts.go](/Users/jhh/git/busdk/busdk/bus-debts/internal/debts/debts.go), each topic currently flows through both `validateTopicArithmetic` and `topicEffectiveAmount`, so `allocated_amount`, `enforcement_fee`, `partial_payment_total`, and `receipt_amount` can be converted from string to cents more than once per topic.

Benchmark evidence:

- `BenchmarkValidateStoreRepeatedMoneyParsing1000`: `677456 ns/op`, `913598 B/op`, `11030 allocs/op`
- `BenchmarkValidateStorePreparsedMoney1000`: `274203 ns/op`, `699441 B/op`, `3015 allocs/op`
- Shape: on a 1,000-topic validation workload, reparsing the same money fields across the two validation helpers is about 2.5x slower and adds about 8,000 extra allocations per operation compared with a once-per-topic parsed representation.

Runnable benchmark command:

```sh
go test ./internal/debts -run '^$' -bench 'BenchmarkValidateStore(RepeatedMoneyParsing1000|PreparsedMoney1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current validation errors and receipt/topic/line identity checks, including duplicate ID failures and unknown parent-reference diagnostics.
- Keep money parsing semantics byte-for-byte compatible with current Finnish and ISO amount handling, including blank optional fields, sign handling, and decimal precision rules.
- Scope any parsed amount cache to one `ValidateStore` pass or one loaded in-memory store; do not retain mutable cross-workspace state.

## Materializing Flattened String Rows Before JSON Encoding

Anti-pattern:

- Building a full `[][]string` union row set and then hydrating a `map[string]string` for every JSON row in `bus-debts` list rendering. In [internal/debts/debts.go](/Users/jhh/git/busdk/busdk/bus-debts/internal/debts/debts.go), `writeJSONList` first calls `flattenedRows`, then copies each row into a keyed map before `json.Encoder` sees the data.

Benchmark evidence:

- `BenchmarkWriteJSONListFlattenedRows100x10x5`: `9355222 ns/op`, `13829449 B/op`, `76833 allocs/op`
- `BenchmarkWriteJSONListDirectRows100x10x5`: `4498345 ns/op`, `6735447 B/op`, `653 allocs/op`
- Shape: for a 100-receipt / 1,000-topic listing workload, the current flatten-then-map JSON path is about 2.1x slower, uses about 2x the memory, and allocates over 100x more objects than a direct typed-row encode.

Runnable benchmark command:

```sh
go test ./internal/debts -run '^$' -bench 'BenchmarkWriteJSONList(FlattenedRows100x10x5|DirectRows100x10x5)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the current JSON field names and output ordering for receipt, topic, and line rows.
- Keep `--level`, `--receipt-id`, and `--topic-id` filtering semantics unchanged, including which rows are emitted for each scope.
- If the encoder moves to typed rows or streaming output, keep empty-string fields present so downstream tooling sees the same union-row shape as today.

## Materializing `[]map[string]string` Before `table read --format json`

Anti-pattern:

- Building a fresh `map[string]string` for every output row before JSON encoding in [internal/cli/run.go](/Users/jhh/git/busdk/busdk/bus-data/internal/cli/run.go). `formatReadJSON` currently converts `[][]string` into `[]map[string]string` and only then calls `json.MarshalIndent`, even though the CLI already has ordered headers and row slices that can be streamed directly.

Benchmark evidence:

- `BenchmarkFormatReadJSONRowMaps5000x8`: `9351865 ns/op`, `8899143 B/op`, `95035 allocs/op`
- `BenchmarkFormatReadJSONStreaming5000x8`: `3673206 ns/op`, `5476667 B/op`, `80039 allocs/op`
- Shape: for a 5,000-row / 8-column table-read payload, the row-map materialization path is about 2.5x slower and allocates about 3.4 MB more per operation than a direct streaming formatter with equivalent output semantics.

Runnable benchmark command:

```sh
go test ./internal/cli -run '^$' -bench 'BenchmarkFormatReadJSON(RowMaps5000x8|Streaming5000x8)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current JSON object key order, which follows the table header order.
- Keep current missing-cell behavior unchanged: columns beyond the row length still emit as empty strings.
- Maintain the CLI guarantee that validation failures emit no partial structured output; any streaming implementation still needs a fully validated input before writing bytes to stdout or an output file.

## Re-parsing CSV/TSV Tables During `bus files parse rows`

Anti-pattern:

- Parsing the same delimited file twice in one `parse rows` command in `bus-files`. In [cmd/bus-files/main.go](/Users/jhh/git/busdk/busdk/bus-files/cmd/bus-files/main.go), `runParse` first calls `parseFiles` / `parseOneFile`, which already parses CSV/TSV files to compute headers and row counts, and then `extractRowsFromFiles` / `extractRowsFromFile` calls `loadDelimitedFile` again to emit row lines.

Benchmark evidence:

- `BenchmarkParseRowsCSVCurrentDoubleParse10000`: `9515539 ns/op`, `17245441 B/op`, `160097 allocs/op`
- `BenchmarkParseRowsCSVSinglePass10000`: `6179709 ns/op`, `10578067 B/op`, `120051 allocs/op`
- Shape: on a 10,000-row CSV fixture, the single-pass benchmark helper is about 1.5x faster and cuts allocation volume by about 39%, which shows the second full CSV parse is a measurable cost in the current `parse rows` flow.

Runnable benchmark command:

```sh
go test ./cmd/bus-files -run '^$' -bench 'BenchmarkParseRowsCSV(CurrentDoubleParse10000|SinglePass10000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current `parse rows` output ordering, `row_index` numbering, and `header=value` formatting exactly.
- Keep current `parse` summary fields unchanged, including inferred format/kind, sorted headers, line counts, and SHA256 values.
- Any shared parsed-table state should stay local to one command invocation or one file summary/extraction pass; do not introduce process-global caches that can mask file edits.

## Hydrating `map[string]string` Rows In `bus-files` Table Assertions

Anti-pattern:

- Building full `map[string]string` row views for every CSV/TSV record before assertion selection in `bus-files`. In [cmd/bus-files/main.go](/Users/jhh/git/busdk/busdk/bus-files/cmd/bus-files/main.go), `loadDelimitedFile` constructs one map per row and the selection/evaluation path (`selectRows`, `selectRowsBySelection`, `resolveBindings`, and `evaluateReference`) repeatedly reads through those maps even though assertions operate on a small fixed set of named columns.

Benchmark evidence:

- `BenchmarkAssertExprSelectionCurrentRowMaps10000x3`: `9752751 ns/op`, `10619595 B/op`, `246835 allocs/op`
- `BenchmarkAssertExprSelectionIndexed10000x3`: `6416527 ns/op`, `5221367 B/op`, `162732 allocs/op`
- Shape: for a 10,000-row expression-assert workload with three selection predicates per binding, the indexed benchmark helper is about 1.5x faster and cuts allocation volume by about 51%, which isolates row-map hydration and map-based selection as a meaningful hotspot in assertion execution.

Runnable benchmark command:

```sh
go test ./cmd/bus-files -run '^$' -bench 'BenchmarkAssertExprSelection(CurrentRowMaps10000x3|Indexed10000x3)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current string-matching semantics, including default case-insensitive and whitespace-normalized comparison plus the `--strict` / `--strict-space` opt-outs.
- Keep existing assertion diagnostics and cardinality behavior unchanged for missing headers, missing columns, zero-row matches, multi-row matches, and non-numeric expression cells.
- Scope any indexed/header-position representation to one loaded file or one assertion pass; do not share mutable row state across commands.

## Hydrating `map[string]string` Rows Through Inventory Validation And Parsing

Anti-pattern:

- Building `map[string]string` row views for every inventory row in [internal/inventory/inventory.go](/Users/jhh/git/busdk/busdk/bus-inventory/internal/inventory/inventory.go) and then re-reading those maps across `validateRows`, `validatePrimaryKey`, `validateForeignKeys`, `parseItems`, and `parseMovements`. The current `bus-inventory` path validates cells once, materializes a map per row, and then pays additional map lookup costs in every downstream pass even though schema field order and column indexes are already stable.

Benchmark evidence:

- `BenchmarkValidateAndParseRowMaps200x5000`: `5080648 ns/op`, `3862678 B/op`, `20823 allocs/op`
- `BenchmarkValidateAndParseTyped200x5000`: `4085165 ns/op`, `870298 B/op`, `169 allocs/op`
- Shape: on a 200-item / 5,000-movement workload, the typed/indexed benchmark helper is about 20% faster and cuts allocation volume by about 77% while exercising the same validation, primary-key, foreign-key, and parse stages.

Runnable benchmark command:

```sh
go test ./internal/inventory -run '^$' -bench 'BenchmarkValidateAndParse(RowMaps|Typed)200x5000$' -benchmem
```

Behavior and safety guardrails:

- Preserve current diagnostics that cite dataset and stable identifiers rather than row numbers.
- Keep schema-driven behavior unchanged for required fields, enum checks, pattern checks, type validation, primary keys, and foreign keys.
- Any indexed or typed row representation should stay local to one validation/load pass; do not introduce process-wide caches tied to mutable workspace data.

## Re-Sorting Inventory Movements For On-Hand And Valuation Passes

Anti-pattern:

- Sorting the same movement slice separately in both `computeOnHand` and `computeValuation` in [internal/inventory/inventory.go](/Users/jhh/git/busdk/busdk/bus-inventory/internal/inventory/inventory.go). `StatusReport` and `ValuationReport` need both metrics for the same as-of movement set, but the current implementation still runs two sort passes before traversing the movements again for valuation logic.

Benchmark evidence:

- `BenchmarkStatusMetricsResortsMovements200x5000`: `710245 ns/op`, `2280749 B/op`, `1817 allocs/op`
- `BenchmarkStatusMetricsSharedSort200x5000`: `327269 ns/op`, `61152 B/op`, `787 allocs/op`
- Shape: for a 200-item / 5,000-movement workload, a single shared sorted traversal is about 2.2x faster and reduces allocation volume by about 97%, which isolates redundant sort/setup work as a real cost in status/valuation reporting.

Runnable benchmark command:

```sh
go test ./internal/inventory -run '^$' -bench 'BenchmarkStatusMetrics(ResortsMovements|SharedSort)200x5000$' -benchmem
```

Behavior and safety guardrails:

- Preserve the existing movement ordering contract of date then `id`, including same-day tie handling.
- Keep FIFO and weighted-average valuation semantics byte-for-byte compatible with current status/valuation output and errors.
- Preserve current unknown-item, unknown-method, and negative-stock failures; an optimization may share sorted traversal state, but it must not silently skip validation or change deterministic output ordering.

## Rescanning Invoice Lines For Every Posting Header

Anti-pattern:

- Re-filtering the full line table once per invoice header in `bus-invoices` posting generation. In [internal/posting/posting.go](/Users/jhh/git/busdk/busdk/bus-invoices/internal/posting/posting.go), `BuildPostings` calls `buildSalesPostings` / `buildPurchasePostings`, and each helper walks the entire line slice to collect one invoice's rows before computing totals and entry rows.

Benchmark evidence:

- `BenchmarkBuildPostingsRescansLinesPerHeader1000x10`: `128851141 ns/op`, `11750241 B/op`, `11020 allocs/op`
- `BenchmarkBuildPostingsPreindexedLines1000x10`: `3251754 ns/op`, `7206809 B/op`, `16006 allocs/op`
- Shape: on a 1,000-invoice / 10-line-per-invoice workload, grouping lines by `invoice_id` once is about 40x faster than rescanning the full line set for each header; allocation count rises slightly in the benchmark helper because it pays an explicit grouping slice build, but total bytes still drop materially and the dominant repeated-scan cost disappears.

Runnable benchmark command:

```sh
go test ./internal/posting -run '^$' -bench 'BenchmarkBuildPostings(RescansLinesPerHeader1000x10|PreindexedLines1000x10)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current posting row order: headers must still emit rows in deterministic header order, with per-invoice entries in the same debit/credit sequence as today.
- Keep current rounding, default account fallback, VAT accumulation, and empty-line handling byte-for-byte compatible with existing posting output.
- Scope any line index to one `BuildPostings` call so it cannot retain stale workspace data across commands.

## Hydrating Header-Keyed Row Maps During Validation Passes

Anti-pattern:

- Building `map[string]string` rows inside the table-validation loop even though the hot path only needs indexed field reads. In [internal/validate/validate.go](/Users/jhh/git/busdk/busdk/bus-invoices/internal/validate/validate.go), `validateTable` allocates a per-row map before checking required fields, enum/pattern rules, types, and primary keys.

Benchmark evidence:

- `BenchmarkValidateTableRowMaps5000`: `2661924 ns/op`, `2350519 B/op`, `15063 allocs/op`
- `BenchmarkValidateTableIndexedRows5000`: `1170802 ns/op`, `297633 B/op`, `5017 allocs/op`
- Shape: for a 5,000-row invoice-line table, validating directly against indexed CSV records is about 2.3x faster and cuts allocation volume by about 87%, which isolates row-map hydration as a measurable part of the validation cost.

Runnable benchmark command:

```sh
go test ./internal/validate -run '^$' -bench 'BenchmarkValidateTable(RowMaps5000|IndexedRows5000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current validation diagnostics, especially row numbering and error text for missing required fields, enum mismatches, pattern failures, type failures, and duplicate primary keys.
- Keep the current CSV header contract unchanged: missing required schema columns must still fail before row validation, and extra columns must remain allowed.
- If row hydration is deferred or reduced, materialize the exact same logical values before any downstream code that depends on `Table.Rows` map access so list, posting, PDF, and classification behavior remain deterministic.

## Rechecking Update Row Membership With `slices.Contains`

Anti-pattern:

- Re-testing whether each journal row belongs to the rewritten transaction by calling `slices.Contains(state.RowIndexes, rowIndex)` inside the full-row loop in `bus-journal` [internal/journal/update.go](/Users/jhh/git/busdk/busdk/bus-journal/internal/journal/update.go). In `rewriteTransactionRows`, that makes the source-period filtering pass scale as O(total_rows * updated_rows) before the file rewrite even starts.

Benchmark evidence:

- `BenchmarkRewriteTransactionRowsFilterCurrent10000x200`: `694681 ns/op`, `245761 B/op`, `1 allocs/op`
- `BenchmarkRewriteTransactionRowsFilterIndexed10000x200`: `166314 ns/op`, `242472 B/op`, `4 allocs/op`
- Shape: on a 10,000-row period file removing a 200-row transaction, the indexed membership pass is about 4.2x faster with similar memory footprint, which isolates repeated linear membership checks as the avoidable CPU cost.

Runnable benchmark command:

```sh
go test ./internal/journal -run '^$' -bench 'BenchmarkRewriteTransactionRowsFilter(Current10000x200|Indexed10000x200)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current row ordering for both same-period and cross-period rewrites.
- Keep the exact set of removed rows identical to the existing `RowIndexes` contract, including duplicate-free semantics and stable handling when the target period changes.
- Limit any indexing structure to one rewrite operation; do not retain mutable row-position caches across journal mutations.

## Buffering And Stringifying Whole NDJSON Replay Inputs

Anti-pattern:

- Reading the full structured replay stream into memory and then converting it to `string` before line scanning in `bus-journal` [internal/journal/bulk_add.go](/Users/jhh/git/busdk/busdk/bus-journal/internal/journal/bulk_add.go) and [internal/journal/stdin_add.go](/Users/jhh/git/busdk/busdk/bus-journal/internal/journal/stdin_add.go). The current `io.ReadAll` + `strings.NewReader(string(raw))` path duplicates large NDJSON payloads even though line-oriented decoding can stream directly from the reader.

Benchmark evidence:

- `BenchmarkLoadBulkEntriesNDJSONCurrent1000`: `6148097 ns/op`, `6941850 B/op`, `24057 allocs/op`
- `BenchmarkLoadBulkEntriesNDJSONStreamed1000`: `5560224 ns/op`, `3231508 B/op`, `22006 allocs/op`
- Shape: for a 1,000-transaction NDJSON replay payload, the streamed benchmark helper is about 10% faster and cuts allocation volume by about 53%, which points to whole-input buffering and `[]byte`→`string` duplication as the main avoidable cost rather than JSON-to-`addArgs` conversion itself.

Runnable benchmark command:

```sh
go test ./internal/journal -run '^$' -bench 'BenchmarkLoadBulkEntriesNDJSON(Current1000|Streamed1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current support for the existing three structured-input shapes: single JSON object, JSON array for bulk replay, and NDJSON.
- Keep current line-numbered NDJSON error messages, empty-input handling, and BOM trimming semantics unchanged.
- Do not introduce behavior that guesses between array/object/NDJSON based on partial reads unless the fallback rules remain deterministic and compatible with the current CLI contract.

## Recompiling Loan Schema Patterns For Every Validated Row

Anti-pattern:

- Re-anchoring and recompiling field constraint patterns inside `validateRow` in [internal/loans/csv.go](/Users/jhh/git/busdk/busdk/bus-loans/internal/loans/csv.go). The current `loadCSVRows` path calls `compilePattern` for every non-empty patterned cell, so patterned loan/event datasets pay regexp compile cost once per row instead of once per schema or validation pass.

Benchmark evidence:

- `BenchmarkValidateRowsPatternCompileEachCall1000`: `8386479 ns/op`, `18915147 B/op`, `241016 allocs/op`
- `BenchmarkValidateRowsPatternPrecompiled1000`: `356801 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: on a 1,000-row patterned validation workload, the current per-cell compile path is about 23x slower and turns validation into a high-allocation hotspot, while an equivalent precompiled-pattern pass eliminates the allocations entirely.

Runnable benchmark command:

```sh
go test ./internal/loans -run '^$' -bench 'BenchmarkValidateRowsPattern(CompileEachCall1000|Precompiled1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current anchored-pattern semantics exactly, including the existing `^(?:pattern)$` wrapping behavior.
- Preserve existing validation errors for invalid schema patterns, required fields, enum mismatches, type failures, and row numbering.
- Scope compiled regexes to one parsed schema or one validation pass inside `bus-loans`; do not introduce a process-wide cache that can outlive workspace schema edits.

## Rebuilding Loan Row Maps Before Parsing Typed Records

Anti-pattern:

- Materializing `map[string]string` row views for every validated loan row in [internal/loans/csv.go](/Users/jhh/git/busdk/busdk/bus-loans/internal/loans/csv.go), then reparsing those maps in [internal/loans/validate.go](/Users/jhh/git/busdk/busdk/bus-loans/internal/loans/validate.go). The current `loadCSVRows` + `parseLoans` path pays per-field map writes, string-key lookups, and repeated trims/parses before building typed `Loan` structs.

Benchmark evidence:

- `BenchmarkParseLoansRowMaps1000`: `2957076 ns/op`, `4490489 B/op`, `45015 allocs/op`
- `BenchmarkParseLoansIndexed1000`: `427645 ns/op`, `406413 B/op`, `2007 allocs/op`
- Shape: for a 1,000-row loans dataset, an indexed typed parse is about 6.9x faster and reduces allocation volume by about 91%, which makes row-map hydration a measurable hotspot in the module load path.

Runnable benchmark command:

```sh
go test ./internal/loans -run '^$' -bench 'BenchmarkParseLoans(RowMaps1000|Indexed1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current schema-driven validation order and error text from `validateRow` and `parseLoans`, including field names and row numbers.
- Keep current trimming, currency/date/number parsing, and `Loan` field population semantics byte-for-byte compatible with existing outputs.
- Any indexed or typed row representation should stay local to one load/parse pass; do not introduce shared mutable row views or caches across workspaces.

## Recompiling Period Schema Regexes For Every Validated Row

Anti-pattern:

- Recompiling schema field patterns inside `validateRows` in [internal/validate/validate.go](/Users/jhh/git/busdk/busdk/bus-period/internal/validate/validate.go). The current `bus-period` validation path calls `regexp.Compile` for every patterned cell, so a fixed schema pattern pays compile cost again on every row instead of once per validation pass or once per parsed schema.

Benchmark evidence:

- `BenchmarkValidateRowsCompiledPatternEachRow1000`: `2130793 ns/op`, `5043181 B/op`, `63004 allocs/op`
- `BenchmarkValidateRowsPrecompiledPattern1000`: `117518 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: on a 1,000-row patterned validation workload, the per-row compile path is about 18x slower and turns a zero-allocation pass into a multi-megabyte allocation hotspot.

Runnable benchmark command:

```sh
go test ./internal/validate -run '^$' -bench 'BenchmarkValidateRows(CompiledPatternEachRow1000|PrecompiledPattern1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current validation error text, especially `schema invalid pattern for` and `value ... fails pattern`.
- Keep required-field, enum, type, and row-numbering behavior byte-for-byte stable.
- Scope compiled regexes to one validation pass or one parsed schema instance; do not introduce process-wide mutable caches that can outlive schema edits.

## Linearly Scanning All Period Windows For Every Journal Posting

Anti-pattern:

- Rechecking every effective period window for every journal row in `validateJournalPostingBoundaries` in [internal/validate/validate.go](/Users/jhh/git/busdk/busdk/bus-period/internal/validate/validate.go). The function sorts windows once, but the hot path still does an O(journal rows × periods) linear scan instead of resolving the candidate window directly from the posting date.

Benchmark evidence:

- `BenchmarkValidateJournalPostingBoundariesLinearScan10000x120`: `3170515 ns/op`, `9880 B/op`, `4 allocs/op`
- `BenchmarkValidateJournalPostingBoundariesBinarySearch10000x120`: `1090891 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for 10,000 journal rows checked against 120 effective periods, a pre-sorted binary-search lookup is about 2.9x faster and removes the residual allocation in the current scan path.

Runnable benchmark command:

```sh
go test ./internal/validate -run '^$' -bench 'BenchmarkValidateJournalPostingBoundaries(LinearScan10000x120|BinarySearch10000x120)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the current deterministic diagnostics for `outside all defined periods` and `future period` failures.
- Keep the same effective-period semantics, including overlap assumptions, inclusive date boundaries, and index-layout vs single-file journal field selection.
- Restrict any optimized lookup structure to one validation pass so it cannot retain stale workspace period data across commands.

## Rescanning Full Proposal Target Maps For Every Unreconciled Bank Transaction

Anti-pattern:

- In `bus-reconcile`, [internal/reconcile/propose.go](/Users/jhh/git/busdk/busdk/bus-reconcile/internal/reconcile/propose.go) currently loops over every invoice candidate in `invByID` and every journal candidate in `journalEntries` for each unreconciled bank row. The hot path only needs targets whose `(currency, absolute amount)` can possibly match, but the current implementation pays full-map scan cost before it can apply extracted-key and source-link filters.

Benchmark evidence:

- `BenchmarkProposalCandidateGenerationInvoiceNestedScan100x5000`: `4619501 ns/op`, `0 B/op`, `0 allocs/op`
- `BenchmarkProposalCandidateGenerationInvoiceAmountCurrencyIndex100x5000`: `3468 ns/op`, `0 B/op`, `0 allocs/op`
- `BenchmarkProposalCandidateGenerationJournalNestedScan100x5000`: `4051180 ns/op`, `0 B/op`, `0 allocs/op`
- `BenchmarkProposalCandidateGenerationJournalAmountCurrencyIndex100x5000`: `3479 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for 100 unreconciled rows matched against 5,000 invoices or 5,000 journal entries, the indexed amount/currency lookup is about 1,100x to 1,300x faster than the current nested scan shape before any I/O is counted.

Runnable benchmark command:

```sh
go test ./internal/reconcile -run '^$' -bench 'BenchmarkProposalCandidateGeneration(Invoice(NestedScan100x5000|AmountCurrencyIndex100x5000)|Journal(NestedScan100x5000|AmountCurrencyIndex100x5000))$' -benchmem
```

Behavior and safety guardrails:

- Preserve the current deterministic proposal ordering by `bank_txn_id`, `target_kind`, and `target_id`.
- Keep extracted-key filtering (`erp_id`, `invoice_number_hint`), source-link filtering, and historical-invoice fallback behavior identical; the index should narrow candidates, not replace those checks.
- Scope any amount/currency index to one `propose` call so it cannot leak stale invoice or journal state across workspace edits.

## Reading Entire CSV Files Before Single-Pass Aggregation

Anti-pattern:

- Using `csv.Reader.ReadAll` in single-pass aggregation helpers that only need the header plus one forward scan. In `bus-validate`, [internal/parity/workspace_stats.go](/Users/jhh/git/busdk/busdk/bus-validate/internal/parity/workspace_stats.go) currently materializes full record matrices in `countAndSumRowsByPeriod`, `journalStatsForResource`, and `LoadAccountsBucketMap` before reducing them into small per-period or per-account maps.

Benchmark evidence:

- `BenchmarkCountAndSumRowsByPeriodReadAll50000`: `11865733 ns/op`, `9124074 B/op`, `150048 allocs/op`
- `BenchmarkCountAndSumRowsByPeriodStreaming50000`: `11001860 ns/op`, `2806001 B/op`, `150023 allocs/op`
- `BenchmarkJournalStatsForResourceReadAll50000`: `16771472 ns/op`, `13924076 B/op`, `150049 allocs/op`
- `BenchmarkJournalStatsForResourceStreaming50000`: `15534654 ns/op`, `7606043 B/op`, `150024 allocs/op`
- `BenchmarkLoadAccountsBucketMapReadAll50000`: `8867568 ns/op`, `15540425 B/op`, `100316 allocs/op`
- `BenchmarkLoadAccountsBucketMapStreaming50000`: `8113902 ns/op`, `9222364 B/op`, `100291 allocs/op`
- Shape: on 50,000-row synthetic CSVs, a streaming pass is about 7-9% faster while cutting allocation volume by about 41-69%, which indicates the full-record slice is a measurable cost even when per-cell string allocations stay unchanged.

Runnable benchmark command:

```sh
go test ./internal/parity -run '^$' -bench 'Benchmark(CountAndSumRowsByPeriod(ReadAll50000|Streaming50000)|LoadAccountsBucketMap(ReadAll50000|Streaming50000)|JournalStatsForResource(ReadAll50000|Streaming50000))$' -benchmem
```

Behavior and safety guardrails:

- Preserve current header normalization and missing-column errors for `date`, `amount`, `code`, `ledger_account_id`, `bucket`, and `activity_class`.
- Keep period bucketing and opening-row exclusion identical to current behavior, including empty-period handling and `"true"`, `"1"`, `"yes"` semantics for `is_opening`.
- Do not change deterministic map contents or downstream ordering contracts; this is only about how rows are consumed, not about changing aggregation rules.

## Reparsing Date Constraint Bounds On Every Validated Row

Anti-pattern:

- Parsing schema-level `minimum` and `maximum` date bounds from strings inside the per-row validation path. In [internal/validate/validator.go](/Users/jhh/git/busdk/busdk/bus-validate/internal/validate/validator.go), `validateMinimumConstraint` and `validateMaximumConstraint` call `time.Parse` on `field.Constraints.MinimumStr` and `field.Constraints.MaximumStr` for every validated date or datetime cell instead of once per field.

Benchmark evidence:

- `BenchmarkValidateDateBoundsConstraintStringsParsedEachRow10000`: `2154069 ns/op`, `0 B/op`, `0 allocs/op`
- `BenchmarkValidateDateBoundsConstraintStringsPreparsed10000`: `584515 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for 10,000 valid date cells, pre-parsing the schema bounds once is about 3.7x faster while preserving the same per-row value parse cost, which isolates repeated constraint parsing as the dominant overhead.

Runnable benchmark command:

```sh
go test ./internal/validate -run '^$' -bench 'BenchmarkValidateDateBoundsConstraintStrings(ParsedEachRow10000|Preparsed10000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current error text and comparison semantics for date and datetime minimum/maximum violations.
- Keep invalid schema-bound strings non-fatal in the same way they are today: if a bound cannot be parsed, validation should continue to behave as though that bound is ineffective rather than introducing a new schema error surface.
- Scope any pre-parsed bound cache to one parsed schema or one validation pass so workspace schema edits cannot be hidden behind process-global state.
