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

## Materializing The Full Journal Before Summing Debit/Credit Totals

Anti-pattern:

- Reading the entire journal into memory inside `checkJournalBalance` in [internal/status/status.go](/Users/jhh/git/busdk/busdk/bus-status/internal/status/status.go) even though the balance check only needs one pass over the debit/credit columns. The current `csv.ReadAll` path pays full-slice materialization cost before a simple reduction.

Benchmark evidence:

- `BenchmarkCheckJournalBalanceReadAll50000`: `9054723 ns/op`, `11125204 B/op`, `150052 allocs/op`
- `BenchmarkCheckJournalBalanceStreaming50000`: `6727207 ns/op`, `4804976 B/op`, `150021 allocs/op`
- Shape: on a 50,000-row journal fixture, the streaming benchmark is about 26% faster and cuts allocated bytes by about 57%, which isolates `csv.ReadAll` materialization as a measurable part of the balance-check cost.

Runnable benchmark command:

```sh
go test ./internal/status -run '^$' -bench 'BenchmarkCheckJournalBalance(ReadAll50000|Streaming50000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current column precedence exactly: use `debit`/`credit` when both exist, otherwise fall back to `debit_cents`/`credit_cents`.
- Preserve current empty-file, missing-column, and parse-tolerant behavior so user-visible observations and pass/fail outcomes stay identical.
- Keep the emitted observation string byte-stable as `debit_cents=<n> credit_cents=<n>`.

## Materializing `periods.csv` Just To Infer The Max Year

Anti-pattern:

- Loading the full `periods.csv` into memory inside `inferYearFromPeriodsCSV` in [internal/status/year_infer.go](/Users/jhh/git/busdk/busdk/bus-status/internal/status/year_infer.go) even though the helper only needs the maximum parsed year from the `period` column. The current implementation pays `csv.ReadAll` cost for a simple max scan used by implicit year inference.

Benchmark evidence:

- `BenchmarkInferYearFromPeriodsCSVReadAll50000`: `7717942 ns/op`, `8723038 B/op`, `100041 allocs/op`
- `BenchmarkInferYearFromPeriodsCSVStreaming50000`: `6372404 ns/op`, `2404960 B/op`, `100016 allocs/op`
- Shape: on a 50,000-row periods fixture, the streaming max-year scan is about 17% faster and reduces allocated bytes by about 72%, which makes the current `ReadAll` approach a measurable startup hotspot when year inference falls back to `periods.csv`.

Runnable benchmark command:

```sh
go test ./internal/status -run '^$' -bench 'BenchmarkInferYearFromPeriodsCSV(ReadAll50000|Streaming50000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the existing fallback contract: missing `periods.csv`, malformed CSV, or a missing `period` column must still return `(0, false)`.
- Keep current year parsing semantics by reusing `parseYear`, including support for `YYYY-MM-DD`, `YYYY-MM`, and bare `YYYY`.
- Do not retain years across calls; inference should stay scoped to the current workspace state so edits to `periods.csv` are reflected immediately.

## Eager Invoice Evidence Hydration On Journal-Only Apply Batches

Anti-pattern:

- Eagerly hydrating full invoice evidence, including invoice line tables, on `apply` batches that only contain `journal_entry` or `unmatched` rows. In [internal/reconcile/apply.go](/Users/jhh/git/busdk/busdk/bus-reconcile/internal/reconcile/apply.go), `Apply` currently calls `loadInvoiceEvidence()` from [internal/reconcile/post.go](/Users/jhh/git/busdk/busdk/bus-reconcile/internal/reconcile/post.go) before it has inspected whether any proposal group needs `historical_invoice_payment` reviewer-approval checks.

Benchmark evidence:

- `BenchmarkApplyJournalOnlyLargeWorkspaceCurrent`: `15333184 ns/op`, `18482203 B/op`, `110832 allocs/op`
- `BenchmarkApplyJournalOnlyLargeWorkspaceWithoutInvoiceEvidenceSetup`: `406048 ns/op`, `38533 B/op`, `234 allocs/op`
- `BenchmarkLoadInvoiceEvidenceLargeWorkspaceWithLines`: `14599181 ns/op`, `18334943 B/op`, `110582 allocs/op`
- Shape: on a large workspace with 2,500 invoice headers and 25,000 invoice-line rows, journal-only `apply --dry-run` spends essentially all of its time and allocations in eager invoice evidence hydration even though the batch never touches invoice targets.

Runnable benchmark command:

```sh
go test ./internal/reconcile -run '^$' -bench 'Benchmark(ApplyJournalOnlyLargeWorkspace(Current|WithoutInvoiceEvidenceSetup)|LoadInvoiceEvidenceLargeWorkspaceWithLines)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current `historical_invoice_payment` approval rules exactly: lazy-loading is only safe when no proposal row requires `currentInvoiceReferenceExists(...)` checks.
- Keep journal-only, unmatched, and exact `invoice_payment` status ordering and messages deterministic; the optimization must only change when invoice evidence is loaded, not which statuses are emitted.
- If invoice evidence loading is deferred or split into a lighter header-only/reference-only path, keep current invoice-number matching and missing-invoice behavior unchanged for historical review flows.

## Reloading And Unmarshalling `preferences.json` For Every Single-Key Lookup

Anti-pattern:

- Re-reading and unmarshalling the full preferences envelope on every `Get`/`GetString` call in `bus-preferences`. In [pkg/preferences/store.go](/Users/jhh/git/busdk/busdk/bus-preferences/pkg/preferences/store.go), `GetString` delegates to `Get`, and `Get` currently calls `os.ReadFile` plus `json.Unmarshal` for the whole `version`/`values` document on each lookup even when one process performs many reads against the same unchanged file.

Benchmark evidence:

- `BenchmarkGetStringReloadsEnvelopeEachCall1000Keys`: `356765 ns/op`, `267169 B/op`, `3038 allocs/op`
- `BenchmarkGetStringFromCachedEnvelope1000Keys`: `133.1 ns/op`, `176 B/op`, `3 allocs/op`
- Shape: for repeated reads from a 1,000-key preferences file, the current per-call reload path is about 2,700x slower and allocates about 1,500x more memory than reusing one parsed envelope, which makes repeated library lookups a measurable hotspot.

Runnable benchmark command:

```sh
go test ./pkg/preferences -run '^$' -bench 'BenchmarkGetString(ReloadsEnvelopeEachCall1000Keys|FromCachedEnvelope1000Keys)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current missing-file and malformed-file behavior: absent files must still behave like "key not found", and malformed files must still fail deterministically.
- Scope any reuse to one process and one resolved preferences path; invalidate on file changes rather than introducing a stale long-lived global view across edits.
- Keep existing key validation, string-vs-non-string decoding behavior, and deterministic `List`/`Get` semantics unchanged while reducing repeated load/parse work.

## Formatting Posting Amounts With `fmt.Sprintf` In Per-Row Payload Loops

Anti-pattern:

- Rendering every posting `amount` string with `fmt.Sprintf` inside hot payload assembly loops. In [internal/memo/add.go](/Users/jhh/git/busdk/busdk/bus-memo/internal/memo/add.go), `buildJournalPayload` calls `formatMinor` once per debit and credit row, and the current `fmt.Sprintf("%s%d.%02d", ...)` path pays formatting overhead and extra allocations for every emitted amount.

Benchmark evidence:

- `BenchmarkFormatMinorFmtSprintf100000`: `10017104 ns/op`, `1930469 B/op`, `214032 allocs/op`
- `BenchmarkFormatMinorAppendInt100000`: `2079090 ns/op`, `902631 B/op`, `100000 allocs/op`
- Shape: on a 100,000-value mixed-sign formatting workload, the append-based formatter is about 4.8x faster and cuts allocation volume by about 53%, which isolates `fmt.Sprintf` as a measurable hotspot in per-row posting serialization.

Runnable benchmark command:

```sh
go test ./internal/memo -run '^$' -bench 'BenchmarkFormatMinor(FmtSprintf100000|AppendInt100000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the exact canonical amount format expected by `bus-journal`: optional leading `-`, no thousands separators, and exactly two fractional digits.
- Keep zero, one-digit fractional, and large whole-value cases byte-stable relative to current output so journal payloads and downstream snapshots remain unchanged.
- Keep the optimization local to the formatter or payload-build path; do not trade formatting savings for shared mutable buffers that could leak values across rows.

## Rescanning Prior Loan Events For Every Derived Repayment Allocation

Anti-pattern:

- Recomputing loan balance state from the beginning of the event history every time `bus-loans` derives repayment allocations with omitted `--principal/--interest/--fees`. In [internal/loans/output.go](/Users/jhh/git/busdk/busdk/bus-loans/internal/loans/output.go), `DeriveEventAllocation` calls `computeBalance(eventsSoFar)` for each repayment, and [internal/loans/modify.go](/Users/jhh/git/busdk/busdk/bus-loans/internal/loans/modify.go) uses that path from `AddEvent`, so sequential repayment imports over one loan currently turn into repeated full-history rescans.

Benchmark evidence:

- `BenchmarkDeriveRepaymentAllocationsRescanHistory1000`: `8099477 ns/op`, `740049 B/op`, `3758 allocs/op`
- `BenchmarkDeriveRepaymentAllocationsRollingBalance1000`: `15798 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for 1,000 sequential derived repayments on one loan, the rescan path is about 500x slower and allocates about 740 KB per operation relative to a rolling balance/accrual helper that carries forward the previous state.

Runnable benchmark command:

```sh
go test ./internal/loans -run '^$' -bench 'BenchmarkDeriveRepaymentAllocations(RescanHistory1000|RollingBalance1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current allocation semantics for borrower/lender sign handling, accrued-interest priority, and zero-fee derivation when explicit allocation flags are omitted.
- Keep event ordering assumptions unchanged: any rolling-state optimization must still operate on the same sorted event sequence used by current `computeBalance`.
- Scope cached or rolling balance state to one append/import flow or one in-memory loan history; do not retain long-lived process-global state that can survive workspace edits.

## Building Full Loan Posting Slices Before Period Filtering

Anti-pattern:

- Generating the entire loan posting history before applying the amortize period window. In [internal/loans/schedule.go](/Users/jhh/git/busdk/busdk/bus-loans/internal/loans/schedule.go), `WriteAmortize` calls [internal/loans/postings.go](/Users/jhh/git/busdk/busdk/bus-loans/internal/loans/postings.go) `postingsForLoan(...)` for each loan, materializes every posting row, and only then filters by `startStr`/`endStr`, so narrow-period amortize runs allocate rows for historical events that will never be emitted.

Benchmark evidence:

- `BenchmarkPostingsForWindowFilterAfterBuild5000`: `1480009 ns/op`, `3452147 B/op`, `17587 allocs/op`
- `BenchmarkPostingsForWindowFilterDuringBuild5000`: `87891 ns/op`, `744 B/op`, `31 allocs/op`
- Shape: for a 5,000-event loan history with a narrow trailing date window, filtering after full row construction is about 17x slower and allocates about 3.45 MB more than a single-pass window-aware posting writer that preserves the same accrual updates while skipping out-of-window row materialization.

Runnable benchmark command:

```sh
go test ./internal/loans -run '^$' -bench 'BenchmarkPostingsForWindow(FilterAfterBuild5000|FilterDuringBuild5000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve exact amortize/posting TSV content, including posting split rules for principal versus interest, account selection, currency fallback, and event ordering.
- Do not skip accrual-state updates for out-of-window events; only skip allocating or formatting posting rows that are not emitted.
- Keep any optimization local to the amortize/posting generation pass so concurrent commands still observe fresh event data from the workspace.

## Hydrating Full Row Maps Just To Drop Existing Update Entry IDs

Anti-pattern:

- Materializing `map[string]string` rows in `existingTransactionState.rowsForTransaction` inside [internal/journal/update.go](/Users/jhh/git/busdk/busdk/bus-journal/internal/journal/update.go) even though `UpdateCommand` only uses that helper to remove current-transaction `entry_id` values from `prepared.ExistingEntryIDs`. On larger rewrites, the current path allocates one full map per matched row and copies every column only to read one field.

Benchmark evidence:

- `BenchmarkUpdateRowsForTransactionMaps200`: `87875 ns/op`, `249792 B/op`, `801 allocs/op`
- `BenchmarkUpdateRowsForTransactionEntryIDsIndexed200`: `730.3 ns/op`, `3456 B/op`, `1 allocs/op`
- Shape: for a 200-row transaction rewrite, extracting only indexed `entry_id` values is about 120x faster and cuts allocation volume by about 98.6%, which isolates row-map hydration as the avoidable cost.

Runnable benchmark command:

```sh
go test ./internal/journal -run '^$' -bench 'BenchmarkUpdateRowsForTransaction(Maps200|EntryIDsIndexed200)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the exact set of excluded `entry_id` values, including row order over `state.RowIndexes`.
- Keep the optimization local to update-time entry-id extraction; do not change the externally visible journal row shape or update diagnostics.
- Do not introduce shared mutable row caches across commands or workspaces.

## Repeated Header-Name Scans Across Update-State And Source-Key Checks

Anti-pattern:

- Repeatedly calling `valueAtHeader` and `indexColumn` inside update hot paths in [internal/journal/update.go](/Users/jhh/git/busdk/busdk/bus-journal/internal/journal/update.go). `buildExistingTransactionState` rescans the header for nearly every projected field and line item, and `ensureUniqueUpdatedSourceKey` rescans the same header names for every row in the target period while checking duplicate source keys.

Benchmark evidence:

- `BenchmarkBuildExistingTransactionStateHeaderLookupCurrent200`: `200339 ns/op`, `17696 B/op`, `40 allocs/op`
- `BenchmarkBuildExistingTransactionStateHeaderLookupIndexed200`: `13849 ns/op`, `21384 B/op`, `17 allocs/op`
- `BenchmarkEnsureUniqueUpdatedSourceKeyHeaderLookupCurrent10000`: `2817457 ns/op`, `0 B/op`, `0 allocs/op`
- `BenchmarkEnsureUniqueUpdatedSourceKeyHeaderLookupIndexed10000`: `227462 ns/op`, `24 B/op`, `1 allocs/op`
- Shape: precomputing column indexes makes transaction-state projection about 14x faster on a 200-line update and makes duplicate source-key scans about 12x faster on a 10,000-row target period, which shows header-name rescans are still a measurable update-path tax even without extra I/O.

Runnable benchmark command:

```sh
go test ./internal/journal -run '^$' -bench 'Benchmark(BuildExistingTransactionStateHeaderLookup(Current200|Indexed200)|EnsureUniqueUpdatedSourceKeyHeaderLookup(Current10000|Indexed10000))$' -benchmem
```

Behavior and safety guardrails:

- Preserve current transaction line ordering by `entry_sequence`.
- Keep current source-key conflict behavior and diagnostics unchanged, especially the transaction-self skip and the `default` source-system fallback.
- Parse `source_voucher`, dimensions, and other projected fields exactly once per row or once per transaction, but do not change the stored serialization format or rewritten output bytes.

## Deep-Copying Managed-Table Records Before Validation

Anti-pattern:

- Copying every row returned by the managed-table loader before inventory validation starts. In [internal/inventory/storage_support.go](/Users/jhh/git/busdk/busdk/bus-inventory/internal/inventory/storage_support.go), `loadTableRecords` currently clones the header slice and every data row from `bus-data` even though the downstream inventory read path treats those records as read-only.

Benchmark evidence:

- `BenchmarkLoadTableRecordsDeepCopy200x5000`: `225417 ns/op`, `793601 B/op`, `5204 allocs/op`
- `BenchmarkLoadTableRecordsReadOnlyView200x5000`: `1.531 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for a representative 200-item / 5,000-movement managed-table payload, the current deep-copy split adds about 225 microseconds and about 794 KB of transient allocation before schema validation, primary-key checks, or valuation work begin.

Runnable benchmark command:

```sh
go test ./internal/inventory -run '^$' -bench 'BenchmarkLoadTableRecords(DeepCopy200x5000|ReadOnlyView200x5000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the current `bus-data` managed-table behavior and storage-policy semantics; this is only about how `bus-inventory` consumes the returned records.
- Only remove the copy when the downstream path is demonstrably read-only. If any caller still mutates header or row slices, keep isolation there or clone at the narrower mutation boundary.
- Keep the existing missing-header and load-error behavior unchanged so diagnostics and command failures remain byte-stable.

## Re-parsing Numeric `binding.column` References For Every Aggregate Term

Anti-pattern:

- Re-walking the same selected rows and re-running `parseNumericValue` for every repeated `binding.column` reference inside one `assert expr` evaluation in `bus-files`. In [cmd/bus-files/main.go](/Users/jhh/git/busdk/busdk/bus-files/cmd/bus-files/main.go), `evaluateExpression` calls `evaluateTerm`, which calls `evaluateReference` for each term independently, so expressions such as `sum(open.amount)+avg(open.amount)+max(open.amount)-min(open.amount)` rebuild the same `[]*big.Rat` projection four times for the same selected rows.

Benchmark evidence:

- `BenchmarkEvaluateExpressionRepeatedReferenceCurrent10000x4`: `15670164 ns/op`, `12513602 B/op`, `501487 allocs/op`
- `BenchmarkEvaluateExpressionRepeatedReferenceCached10000x4`: `6533171 ns/op`, `6764137 B/op`, `245414 allocs/op`
- Shape: on a 10,000-row CSV fixture with one repeated `open.amount` projection used across four aggregate terms, expression-local caching is about 2.4x faster and cuts allocation count by about 51%, which isolates repeated numeric projection work as a primary hotspot after row selection has already completed.

Runnable benchmark command:

```sh
go test ./cmd/bus-files -run '^$' -bench 'BenchmarkEvaluateExpressionRepeatedReference(Current10000x4|Cached10000x4)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current arithmetic semantics, especially scalar-vs-vector behavior and the exact numeric results produced by `sum`, `avg`, `min`, `max`, and `count`.
- Keep current error reporting for unknown bindings, missing columns, and non-numeric cells unchanged.
- Scope any cache to one expression evaluation; do not introduce process-wide mutable caches that can outlive a file load or leak stale binding data across commands.

## Building A Fresh `[]string` For Every Emitted `parse rows` Table Row

Anti-pattern:

- Materializing a new slice of `header=value` fragments and then joining it for every emitted table row in `bus-files` parse-row output. In [cmd/bus-files/main.go](/Users/jhh/git/busdk/busdk/bus-files/cmd/bus-files/main.go), `extractRowsFromFile` calls `joinRowValues`, which allocates a fresh `[]string` and `strings.Join` result for each CSV/TSV row even though the formatter always emits the same deterministic `header=value; ...` shape in a known header order.

Benchmark evidence:

- `BenchmarkJoinRowValuesCurrent10000x6`: `2862791 ns/op`, `2960006 B/op`, `80000 allocs/op`
- `BenchmarkJoinRowValuesBuilder10000x6`: `1721644 ns/op`, `2480006 B/op`, `50000 allocs/op`
- Shape: for 10,000 emitted rows across 6 headers, a single-builder formatter is about 1.7x faster and reduces allocation count by about 37%, which points to per-row fragment-slice construction as a measurable output-path hotspot independent of CSV reparse cost.

Runnable benchmark command:

```sh
go test ./cmd/bus-files -run '^$' -bench 'BenchmarkJoinRowValues(Current10000x6|Builder10000x6)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the exact emitted row bytes, including `header=value; header=value` formatting, current header order, and empty-cell rendering.
- Keep row ordering and row indexing unchanged for `bus files parse rows`.
- Reuse buffers only within one row render or one command invocation; avoid shared mutable builders that can leak content across rows or concurrent tests.

## Reparsing Topic Amounts For Every Text List Row

Anti-pattern:

- Recomputing topic effective amounts during text rendering in `bus-debts`. In [internal/debts/debts.go](/Users/jhh/git/busdk/busdk/bus-debts/internal/debts/debts.go), `writeTextList` calls `topicEffectiveAmountString(topic)` for every rendered topic row, and that helper reparses `receipt_amount`, `partial_payment_total`, `allocated_amount`, and `enforcement_fee` from strings even though the listing pass already has a fixed topic set.

Benchmark evidence:

- `BenchmarkWriteTextListTopicEffectiveAmountParsing1000x5`: `3498598 ns/op`, `5332362 B/op`, `55028 allocs/op`
- `BenchmarkWriteTextListPrecomputedEffectiveAmounts1000x5`: `2467601 ns/op`, `5090975 B/op`, `40027 allocs/op`
- Shape: on a 1,000-receipt / 5-topic-per-receipt text listing workload, precomputing one effective amount per topic makes rendering about 1.4x faster and removes about 15,000 allocations per operation, which isolates repeated money parsing inside the render loop as a measurable cost.

Runnable benchmark command:

```sh
go test ./internal/debts -run '^$' -bench 'BenchmarkWriteTextList(TopicEffectiveAmountParsing1000x5|PrecomputedEffectiveAmounts1000x5)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current text output exactly, including row order, indentation, field order, and the existing empty-string fallback when topic effective amount resolution fails.
- Scope any precomputed amounts to one `writeTextList` call or one render pass; do not retain cross-workspace caches.
- Keep the current precedence order for effective amount selection: `receipt_amount`, then `partial_payment_total`, then `allocated_amount + enforcement_fee`.

## Materializing Flattened Delimited Rows Before Writing TSV/CSV

Anti-pattern:

- Building a full `[][]string` union in `flattenedRows` before delimited output in `bus-debts`. In [internal/debts/debts.go](/Users/jhh/git/busdk/busdk/bus-debts/internal/debts/debts.go), `writeDelimitedList` first materializes every receipt/topic/line row into memory and only then emits them, even though TSV/CSV output can be streamed directly while traversing the same deterministic hierarchy.

Benchmark evidence:

- `BenchmarkWriteDelimitedListFlattenedRows1000x5`: `4890529 ns/op`, `7787265 B/op`, `22022 allocs/op`
- `BenchmarkWriteDelimitedListStreamingRows1000x5`: `4302911 ns/op`, `4546110 B/op`, `11021 allocs/op`
- Shape: on a 1,000-receipt / 5-topic-per-receipt TSV listing workload, streaming rows during traversal is about 14% faster, cuts allocation volume by about 42%, and halves allocation count compared with building the intermediate flattened matrix first.

Runnable benchmark command:

```sh
go test ./internal/debts -run '^$' -bench 'BenchmarkWriteDelimitedList(FlattenedRows1000x5|StreamingRows1000x5)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the current delimited header, row order, field set, and level filtering semantics for `receipts`, `topics`, `lines`, and `all`.
- Keep CSV escaping and TSV tab-replacement behavior byte-stable relative to the current `writeSeparated` path.
- Limit any streaming rewrite to the delimited render path; JSON rendering can evolve independently because it has different shape and allocation constraints.

## Allocating Primary-Key Tuples While Scanning For One Target Row

Anti-pattern:

- Building a fresh `[]string` key slice and joined tuple string for every scanned record in `findRowByKeys` in [pkg/data/mutate.go](/Users/jhh/git/busdk/busdk/bus-data/pkg/data/mutate.go). `UpdateRow` and `DeleteRow` already resolve the primary-key column indexes once, but the current scan still calls `rowValues(...)` and `keyTuple(...)` per row instead of comparing the primary-key columns directly.

Benchmark evidence:

- `BenchmarkFindRowByKeysKeyTupleScan10000`: `182781 ns/op`, `160026 B/op`, `10002 allocs/op`
- `BenchmarkFindRowByKeysDirectCompare10000`: `23842 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: on a 10,000-row table with the match at the end of the scan, the direct-compare helper is about 7.7x faster and eliminates all per-row allocation churn, which isolates transient tuple construction as the dominant lookup cost.

Runnable benchmark command:

```sh
go test ./pkg/data -run '^$' -bench 'BenchmarkFindRowByKeys(KeyTupleScan10000|DirectCompare10000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current primary-key field ordering and missing-key diagnostics from `resolveKeyValues`.
- Keep first-match row selection unchanged even if duplicate rows exist in an invalid dataset.
- Preserve current row-numbering and downstream update/delete behavior by returning the same record index that the current scan would return.

## Re-reading Workbook Selectors During Profile Validation And Execution

Anti-pattern:

- Calling `ReadWorkbook` once per selector during `ValidateWorkbookProfile` and then calling it again for the same selectors inside `ExecuteWorkbookProfile` in [pkg/data/workbook_profile.go](/Users/jhh/git/busdk/busdk/bus-data/pkg/data/workbook_profile.go). The current execution path validates selector extractability by re-reading the workbook before immediately re-reading it to build the final result.

Benchmark evidence:

- `BenchmarkExecuteWorkbookProfileValidateThenRead10x1000`: `5002463 ns/op`, `5946336 B/op`, `41599 allocs/op`
- `BenchmarkExecuteWorkbookProfileExecuteOnly10x1000`: `2614823 ns/op`, `2973767 B/op`, `20803 allocs/op`
- Shape: on a 1,000-row sheet with 10 selectors, the execute-only helper is about 1.9x faster and roughly halves allocation volume, matching the doubled workbook-read pattern in the current validate-then-execute flow.

Runnable benchmark command:

```sh
go test ./pkg/data -run '^$' -bench 'BenchmarkExecuteWorkbookProfile(ValidateThenRead10x1000|ExecuteOnly10x1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current selector order and duplicate-name handling.
- Keep workbook-address validation and execution diagnostics stable; if validation and execution are fused, selectors must still fail with the same workbook-path-prefixed errors.
- Do not change formula/header/anchor option semantics or the deterministic ordering of returned `WorkbookCell` values.

## Hydrating `map[string]string` For Every Validated Customer Row

Anti-pattern:

- Building a fresh `map[string]string` for every customer row inside the validation path in [internal/customers/validator.go](/Users/jhh/git/busdk/busdk/bus-customers/internal/customers/validator.go). `validateDataset` currently materializes a full row map before `ValidateCustomers`, `AddCustomer`, primary-key validation, and linked-entity checks use only a small fixed subset of fields (`customer_id`, `entity_id`, `display_name`, plus duplicate-key state), so the hot path pays repeated map allocation and hashing work that an indexed/typed pass can avoid.

Benchmark evidence:

- `BenchmarkValidateDatasetRowMapsPrecompiled1000`: `652053 ns/op`, `399123 B/op`, `2009 allocs/op`
- `BenchmarkValidateDatasetTypedRowsPrecompiled1000`: `582099 ns/op`, `103927 B/op`, `9 allocs/op`
- Shape: on a 1,000-row customers dataset with schema patterns already precompiled, the typed/indexed validation helper is about 11% faster, cuts allocation bytes by about 74%, and drops allocation count from 2009 to 9, which isolates row-map hydration as the remaining allocation-heavy cost after regex compilation is removed from the comparison.

Runnable benchmark command:

```sh
go test ./internal/customers -run '^$' -bench 'BenchmarkValidateDataset(RowMapsPrecompiled1000|TypedRowsPrecompiled1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current validation error text and row numbering for required-field failures, duplicate primary keys, invalid linked `entity_id` references, and pattern mismatches.
- Keep `list` output byte-for-byte compatible by preserving the current `customer_id`, `entity_id`, and `display_name` extraction and the final `customer_id` sort order.
- Scope any typed/indexed representation to one validation pass; do not introduce shared mutable row caches that can outlive CSV/schema edits in the workspace.

## Rebuilding Attachment ID Inventories Multiple Times Per Command

Anti-pattern:

- Recomputing full sorted existing-ID inventories more than once inside a single `bus-attachments` mutation. In [internal/attachments/add.go](/Users/jhh/git/busdk/busdk/bus-attachments/internal/attachments/add.go) and [internal/attachments/link.go](/Users/jhh/git/busdk/busdk/bus-attachments/internal/attachments/link.go), `addAttachment` and `linkAttachment` call [existingAttachmentIDs](/Users/jhh/git/busdk/busdk/bus-attachments/internal/attachments/ids.go) or [existingLinkIDs](/Users/jhh/git/busdk/busdk/bus-attachments/internal/attachments/ids.go) to feed the workspace ID policy, then rescan the same table again for `ensureDistinctID`, even though one command already has a validated in-memory table snapshot.

Benchmark evidence:

- `BenchmarkAddAttachmentIDPreparationCurrent50000`: `30976007 ns/op`, `8596519 B/op`, `548 allocs/op`
- `BenchmarkAddAttachmentIDPreparationIndexed50000`: `6892239 ns/op`, `2550645 B/op`, `131 allocs/op`
- Shape: on a 50,000-row attachments table, building the sorted ID slice once and reusing a set for collision checks is about 4.5x faster and cuts allocation volume by about 70%, which isolates repeated inventory scans as a command-time hotspot independent of file I/O.

Runnable benchmark command:

```sh
go test ./internal/attachments -run '^$' -bench 'BenchmarkAddAttachmentIDPreparation(Current50000|Indexed50000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current workspace ID policy behavior: policy generation must still receive the same deterministic sorted `Existing` slice it sees today.
- Keep duplicate-ID diagnostics byte-stable, especially `generated <kind> "<id>" already exists`.
- Scope any set/slice reuse to one loaded table snapshot or one command execution; do not introduce long-lived global caches that can outlive workspace edits.

## Hydrating Header-Keyed Row Maps During Report Balance Loading

Anti-pattern:

- Rebuilding `map[string]string` rows for every journal and periods record before tililuettelo balance aggregation in [run_report_balances.go](/Users/jhh/git/busdk/busdk/bus-accounts/run_report_balances.go). `loadJournalRowsStorageAware` and `loadManagedRowsStorageAware` materialize one map per row, then `loadReportBalancesAsOf` and `loadEffectiveReportPeriods` immediately read a small fixed column subset from those maps.

Benchmark evidence:

- `BenchmarkJournalBalanceAggregationRowMaps10000`: `11490297 ns/op`, `10148488 B/op`, `301399 allocs/op`
- `BenchmarkJournalBalanceAggregationIndexed10000`: `9545435 ns/op`, `6707093 B/op`, `281344 allocs/op`
- Shape: on a 10,000-row journal aggregation workload, keeping indexed column access instead of hydrating row maps is about 17% faster and cuts allocation volume by about 34%.

Runnable benchmark command:

```sh
go test . -run '^$' -bench 'BenchmarkJournalBalanceAggregation(RowMaps10000|Indexed10000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current compatibility column fallback semantics such as `posting_date` vs `date` and `account_id` vs `account`.
- Keep exact decimal parsing and per-account accumulation behavior unchanged, including empty-account skips and current error paths for invalid debit/credit amounts.
- Scope any typed/indexed row view to one table load or one command run; do not introduce process-wide caches tied to workspace files.

## Rebuilding Canonical Group Paths For Every Explained Account

Anti-pattern:

- Re-walking the same `group_id -> parent_group_id` ancestry and rejoining the same path strings for every account in [internal/groups/explain.go](/Users/jhh/git/busdk/busdk/bus-accounts/internal/groups/explain.go). `BuildExplainRows` currently calls `explainGroupPath`, `explainGroupCodePath`, `explainGroupNamePath`, and `explainGroupLabelPath` once per selected account even when many accounts share the same group.

Benchmark evidence:

- `BenchmarkBuildExplainRowsRepeatedPathWalks5000`: `2589143 ns/op`, `3435600 B/op`, `48797 allocs/op`
- `BenchmarkBuildExplainRowsMemoizedPaths5000`: `440923 ns/op`, `1207917 B/op`, `1090 allocs/op`
- Shape: for 5,000 explained accounts spread across a shared group tree, memoizing one rendered path per group is about 5.9x faster and reduces allocation volume by about 65%.

Runnable benchmark command:

```sh
go test ./internal/groups -run '^$' -bench 'BenchmarkBuildExplainRows(RepeatedPathWalks5000|MemoizedPaths5000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current status/reason text for `missing_group`, `unknown_group`, and `ok` rows.
- Keep deterministic account ordering and the current canonical path rendering format for `group_code_path`, `group_name_path`, `group_path`, and joined `report_profiles`.
- Cache only within one `BuildExplainRows` call or another request-local scope so explain output cannot go stale across group-tree mutations.

## Reparsing `recorded_at` Timestamps During Effective Period Selection

Anti-pattern:

- Re-running RFC3339/RFC3339Nano parsing every time `latestReportPeriodRows` compares a candidate row against the current winner in [run_report_balances.go](/Users/jhh/git/busdk/busdk/bus-accounts/run_report_balances.go). The current reduction reparses both `recorded_at` strings on each replacement decision instead of parsing each row once.

Benchmark evidence:

- `BenchmarkLatestReportPeriodRowsParseRecordedAtEachComparison10000`: `1308398 ns/op`, `443048 B/op`, `78 allocs/op`
- `BenchmarkLatestReportPeriodRowsPreparsedRecordedAt10000`: `527840 ns/op`, `1577780 B/op`, `53 allocs/op`
- Shape: for 10,000 period-history rows reduced down to one latest row per `period_id`, pre-parsing `recorded_at` once per row is about 2.5x faster and reduces comparison-time allocations, even though the benchmark helper carries extra cached timestamp state.

Runnable benchmark command:

```sh
go test . -run '^$' -bench 'BenchmarkLatestReportPeriodRows(ParseRecordedAtEachComparison10000|PreparsedRecordedAt10000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current timestamp precedence exactly: RFC3339Nano first, then RFC3339, then raw-string fallback when neither parses.
- Keep the existing `period_id` grouping and winner-selection semantics unchanged, including blank-`period_id` skips.
- Cache parsed timestamps only for the rows participating in one `latestReportPeriodRows` pass; do not retain period state across workspaces or command executions.

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

## Growing Import Record Slices And Capturing Time Per Row

Anti-pattern:

- Building import result slices with repeated growth and calling `time.Now().UTC()` for every parsed source row in [internal/cli/import_cmd.go](/Users/jhh/git/busdk/busdk/bus-balances/internal/cli/import_cmd.go). `parseSignedRows` and `parseDCRows` already know `len(rows)` up front, but they currently append into zero-capacity slices and stamp each row separately instead of treating one import run as one batch.

Benchmark evidence:

- `BenchmarkParseSignedRowsCurrent20000`: `3559057 ns/op`, `10026354 B/op`, `22 allocs/op`
- `BenchmarkParseSignedRowsPreallocSingleTimestamp20000`: `940249 ns/op`, `2080773 B/op`, `1 allocs/op`
- `BenchmarkParseDCRowsCurrent20000`: `5378803 ns/op`, `10355580 B/op`, `19920 allocs/op`
- `BenchmarkParseDCRowsPreallocSingleTimestamp20000`: `2964348 ns/op`, `2409977 B/op`, `19899 allocs/op`
- Shape: on 20,000-row imports, preallocating the output slice and stamping one batch timestamp makes signed parsing about 3.8x faster with about 79% fewer bytes allocated, and makes debit/credit parsing about 1.8x faster with about 77% fewer bytes allocated.

Runnable benchmark command:

```sh
go test ./internal/cli -run '^$' -bench 'BenchmarkParse(SignedRows(Current20000|PreallocSingleTimestamp20000)|DCRows(Current20000|PreallocSingleTimestamp20000))$' -benchmem
```

Behavior and safety guardrails:

- Preserve current trimming, decimal parsing, netting (`debit - credit`), and row-numbered error text.
- Keep import append semantics unchanged: one record per input row, same field values, and no partial writes on failure.
- If `recorded_at` is captured once per import batch, keep it scoped to one command invocation so rows from a single import remain deterministic without introducing cross-command timestamp reuse.

## Rebuilding Header Maps During Balance Table Decoding

Anti-pattern:

- Constructing a generic header-name map and a per-row `value(...)` closure inside [snapshot/record.go](/Users/jhh/git/busdk/busdk/bus-balances/snapshot/record.go) for every `RecordsFromTable` decode. `list` and `validate` always decode the same fixed balances columns, but the current path still builds a map, performs repeated string-key lookups, and routes every field through the closure before populating `snapshot.Record`.

Benchmark evidence:

- `BenchmarkRecordsFromTableHeaderMap20000`: `1853017 ns/op`, `2080768 B/op`, `1 allocs/op`
- `BenchmarkRecordsFromTableIndexed20000`: `1027169 ns/op`, `2080769 B/op`, `1 allocs/op`
- Shape: for a 20,000-row balances table, resolving fixed indexes once and decoding directly from indexed cells is about 1.8x faster than the current generic header-map path.

Runnable benchmark command:

```sh
go test ./snapshot -run '^$' -bench 'BenchmarkRecordsFromTable(HeaderMap20000|Indexed20000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current required-column checks for `recorded_at`, `as_of`, `account_code`, and `amount`.
- Keep current trim semantics, optional `source`/`notes` defaults, RFC3339 parsing, and row-numbered error reporting unchanged.
- Scope any decoded-index helpers to one loaded table/header shape; do not introduce process-wide caches tied to mutable workspace files.

## Rescanning Scoped Transactions For Every Control Checkpoint

Anti-pattern:

- Recomputing checkpoint movement totals by walking the full scoped transaction slice once per statement checkpoint in `bus-bank`. In [internal/bank/control.go](/Users/jhh/git/busdk/busdk/bus-bank/internal/bank/control.go), `ComputeControlReport` currently builds checkpoint rows by calling `sumTransactionsInRange(filteredTransactions, cp.PeriodStart, cp.PeriodEnd)` inside the checkpoint loop, so the same date-filtered transaction set is rescanned for every checkpoint in scope.

Benchmark evidence:

- `BenchmarkBuildControlCheckpointMovementsRescans3650x120`: `3151437 ns/op`, `0 B/op`, `0 allocs/op`
- `BenchmarkBuildControlCheckpointMovementsDateIndex3650x120`: `195486 ns/op`, `316738 B/op`, `19 allocs/op`
- Shape: for a deterministic 3,650-transaction / 120-checkpoint workload, the repeated-scan path is about 16x slower than a benchmark-only date-indexed range-sum helper, which isolates checkpoint movement rescans as the dominant CPU cost in control-row assembly.

Runnable benchmark command:

```sh
go test ./internal/bank -run '^$' -bench 'BenchmarkBuildControlCheckpointMovements(Rescans3650x120|DateIndex3650x120)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current checkpoint row order, `movement_sum`, `computed_closing`, and `diff` values exactly for the same scoped transactions and checkpoints.
- Keep scope filtering semantics unchanged: inclusive `PeriodStart`/`PeriodEnd` bounds must continue matching the current string-date comparisons.
- Build any date index once per control-report scope or equivalent prepared view; do not introduce global mutable caches that can outlive workspace edits.
- Preserve current continuity issue detection, backlog/coverage counts, and rendered TSV/JSON output shape; only the internal movement-total calculation should change.

## Re-Decoding Mutation Schema Metadata On Every Add/Update

Anti-pattern:

- Re-reading and JSON-decoding the same `entities.schema.json` metadata after validation has already loaded it. In [internal/entities/mutate.go](/Users/jhh/git/busdk/busdk/bus-entities/internal/entities/mutate.go), `AddEntity` and `UpdateEntity` call [filterValuesForSchema](/Users/jhh/git/busdk/busdk/bus-entities/internal/entities/storage_support.go) and `schemaHasUpdatePolicy`, and both helpers unmarshal schema JSON again in [internal/entities/storage_support.go](/Users/jhh/git/busdk/busdk/bus-entities/internal/entities/storage_support.go) just to recover declared field names and `busdk.update_policy`.

Benchmark evidence:

- `BenchmarkUpdateSchemaMetadataJSONDecodeTwice1000`: `13477944 ns/op`, `2160010 B/op`, `39000 allocs/op`
- `BenchmarkUpdateSchemaMetadataPredecoded1000`: `116696 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for 1,000 simulated update-side metadata checks, the repeated-decode path is about 115x slower and allocates about 2.1 MB plus 39k allocations per operation, which isolates redundant schema metadata parsing as a standalone mutation-path hotspot.

Runnable benchmark command:

```sh
go test ./internal/entities -run '^$' -bench 'BenchmarkUpdateSchemaMetadata(JSONDecodeTwice1000|Predecoded1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current schema error text for invalid JSON and keep filtering limited to fields declared by the active schema.
- Reuse metadata only within one already-loaded schema/workspace view; do not introduce global mutable caches that can outlive schema edits.
- Keep `busdk.update_policy` semantics unchanged so `in_place` versus rewrite decisions stay byte-for-byte compatible with current mutation behavior.

## Revalidating And Rebuilding The Full Registry For Every Lookup

Anti-pattern:

- Implementing [registry.Lookup](/Users/jhh/git/busdk/busdk/bus-entities/registry/registry.go) by calling `List`, which itself calls `ValidateEntities` and rebuilds the entire validated entity slice before scanning for one `entity_id`. Repeated dependent-module lookups pay the full schema+CSV validation and row projection cost once per lookup instead of once per registry snapshot.

Benchmark evidence:

- `BenchmarkLookupRegistryValidateEachCall1000x200`: `2073741208 ns/op`, `3029001632 B/op`, `34852181 allocs/op`
- `BenchmarkLookupRegistryIndexedResult1000x200`: `2851 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for 200 lookups against a 1,000-entity registry, the current `Lookup` pattern is about 727,000x slower and allocates about 3.0 GB because every query revalidates and rematerializes the full registry.

Runnable benchmark command:

```sh
go test ./registry -run '^$' -bench 'BenchmarkLookupRegistry(ValidateEachCall1000x200|IndexedResult1000x200)$' -benchmem
```

Behavior and safety guardrails:

- Preserve `Lookup`’s current validation guarantees: invalid schema/data must still fail before returning a row.
- Keep returned entity fields and canonical `entity_id` matching unchanged, including the current `ok`/`not found` contract.
- Scope any lookup index or cached validation result to one workspace snapshot or one explicit call chain; do not keep long-lived mutable global caches that can serve stale registry contents after file edits.

## Building Whole-Dataset Invoice Total Maps For Single-Invoice Validation

Anti-pattern:

- Validating one invoice by calling `sumLineAmountsByInvoice` and `sumLineVATByInvoice` over the full line table in [internal/validate/validate.go](/Users/jhh/git/busdk/busdk/bus-invoices/internal/validate/validate.go). `ValidateInvoice` only checks one header row, but it currently builds total maps for every invoice in the dataset before looking up the requested `invoice_id`.

Benchmark evidence:

- `BenchmarkValidateInvoiceScansAllLineTotals4000x10`: `7400907 ns/op`, `873329 B/op`, `96 allocs/op`
- `BenchmarkValidateInvoiceTargetedLineTotals4000x10`: `499501 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: on a 4,000-invoice / 40,000-line workload, the current single-invoice validation shape is about 14.8x slower because it aggregates totals for the whole dataset instead of the requested invoice only.

Runnable benchmark command:

```sh
go test ./internal/validate -run '^$' -bench 'BenchmarkValidateInvoice(ScansAllLineTotals4000x10|TargetedLineTotals4000x10)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the current `ValidateInvoice` error text and row numbering for `total_net`, `total_vat`, due-date, and invoice-not-found failures.
- Keep single-invoice behavior deterministic across sales and purchase datasets; optimization must not change which header row is selected for the requested `invoice_id`.
- Scope any precomputed totals to one validation call or one loaded dataset snapshot so workspace edits cannot be served from stale process-wide state.

## Re-Normalizing Provider And Description Keys In Both Classification Passes

Anti-pattern:

- Recomputing `normalizeKey` for the same supplier names and line descriptions while both building history and generating proposals in [internal/classify/classify.go](/Users/jhh/git/busdk/busdk/bus-invoices/internal/classify/classify.go). `Run` normalizes provider keys per line again after `buildHistory` already normalized the same text for the same rows.

Benchmark evidence:

- `BenchmarkBuildHistoryAndProposalsNormalizeEachPass4000x10`: `18571645 ns/op`, `8935945 B/op`, `282030 allocs/op`
- `BenchmarkBuildHistoryAndProposalsPrecomputedKeys4000x10`: `14623898 ns/op`, `7030857 B/op`, `174046 allocs/op`
- Shape: on a 4,000-invoice / 40,000-line classification workload, precomputing normalized keys is about 27% faster and reduces allocation volume by about 21% while also cutting allocation count by about 38%.

Runnable benchmark command:

```sh
go test ./internal/classify -run '^$' -bench 'BenchmarkBuildHistoryAndProposals(NormalizeEachPass4000x10|PrecomputedKeys4000x10)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current `normalizeKey` semantics exactly, including lowercase conversion and whitespace folding.
- Keep proposal ordering, provider-only fallback behavior, confidence math, and tie-break rules byte-stable.
- Do not introduce shared mutable caches across runs; cached normalized keys should stay local to one `Run` call or one loaded dataset snapshot.

## Revalidating The Entire Journal During Opening Entry Generation

Anti-pattern:

- Re-running `ValidateJournalBalanced` over the full current journal after `bus-period` generates a balanced opening transaction in [internal/period/opening.go](/Users/jhh/git/busdk/busdk/bus-period/internal/period/opening.go). `Opening` already starts from `validate.Data`, so the preexisting journal has passed `ValidateAll`; the current path still rescans every existing row just to prove the appended opening rows keep the journal balanced.

Benchmark evidence:

- `BenchmarkOpeningBalanceCheckFullJournal10000x200`: `403844 ns/op`, `326405 B/op`, `10200 allocs/op`
- `BenchmarkOpeningBalanceCheckOpeningRowsOnly10000x200`: `8059 ns/op`, `6400 B/op`, `200 allocs/op`
- Shape: for a 10,000-row validated journal plus a 200-row opening transaction, the full-journal recheck is about 50x slower and allocates about 51x more memory than validating only the generated opening rows.

Runnable benchmark command:

```sh
go test ./internal/period -run '^$' -bench 'BenchmarkOpeningBalanceCheck(FullJournal10000x200|OpeningRowsOnly10000x200)$' -benchmem
```

Behavior and safety guardrails:

- Preserve the current `opening entry would be unbalanced` failure shape when generated opening rows are not balanced.
- Keep `--replace` semantics unchanged: removing an existing opening entry and adding a replacement must still yield a balanced final journal.
- Only skip the full-journal rebalance when the base journal came from the already-validated `validate.Data` flow; do not silently broaden that assumption to unchecked callers.

## Appending Opening-Balance Artifact Rows Through `AddRow` One Row At A Time

Anti-pattern:

- Building `periods/<period>/opening_balances.csv` by calling `busdata.AddRow` once per row inside [internal/period/storage_support.go](/Users/jhh/git/busdk/busdk/bus-period/internal/period/storage_support.go). `writePeriodArtifactTable` initializes the managed table once, but each subsequent `AddRow` call re-resolves schema/storage, reloads the full table, revalidates prior rows, and appends just one logical row.

Benchmark evidence:

- `BenchmarkWritePeriodArtifactTableAddRowLoop500`: `181585785 ns/op`, `35608961 B/op`, `307287 allocs/op`
- `BenchmarkWritePeriodArtifactTableOpenedAppend500`: `28921688 ns/op`, `53222 B/op`, `916 allocs/op`
- Shape: for a 500-row `opening_balances.csv` artifact, the current per-row `AddRow` loop is about 6.3x slower and allocates about 669x more memory than opening the managed table once and appending all logical rows in one batch.

Runnable benchmark command:

```sh
go test ./internal/period -run '^$' -bench 'BenchmarkWritePeriodArtifactTable(AddRowLoop500|OpenedAppend500)$' -benchmem
```

Behavior and safety guardrails:

- Preserve storage-aware behavior for both CSV and PCSV workspaces, including the same logical schema and row order in `opening_balances.csv`.
- Keep `InitManagedTable` ownership and artifact path conventions unchanged so close/opening interoperability remains deterministic.
- Any batched append path must still write exactly the same logical row set and must not skip schema validation for the rows being emitted.

## Linearly Scanning Enum Slices For Every Validated Cell

Anti-pattern:

- Rechecking `constraints.enum` by walking the full `[]string` for every validated cell in [internal/validate/validator.go](/Users/jhh/git/busdk/busdk/bus-validate/internal/validate/validator.go). `validateRows` currently calls `contains(field.Constraints.Enum, value)` inside the per-row/per-field loop, so larger enum sets turn one validation pass into repeated O(enum-size) string scans.

Benchmark evidence:

- `BenchmarkValidateEnumConstraintLinearScan10000x200`: `1904173 ns/op`, `0 B/op`, `0 allocs/op`
- `BenchmarkValidateEnumConstraintPreindexed10000x200`: `80703 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: on a 10,000-cell / 200-value enum workload, pre-indexing allowed values is about 24x faster than repeated linear scans even before any additional validation work is included.

Runnable benchmark command:

```sh
go test ./internal/validate -run '^$' -bench 'BenchmarkValidateEnumConstraint(LinearScan10000x200|Preindexed10000x200)$' -benchmem
```

Behavior and safety guardrails:

- Preserve exact string matching semantics; this is not a normalization change.
- Keep current error text and validation order unchanged so enum failures still report the same field, record, and message.
- Scope any prebuilt enum index to one parsed schema or one validation pass so schema edits are always observed on the next run.

## Materializing Attachment-Link CSV Rows Before Building The Link Index

Anti-pattern:

- Reading `attachment-links.csv` into an intermediate `[][]string` before indexing it in [internal/evidence/coverage.go](/Users/jhh/git/busdk/busdk/bus-validate/internal/evidence/coverage.go). `readLinkIndex` currently goes through `readCSV`/`readCSVFrom`, which stores every row first even though the hot path only needs a single streaming pass to populate the per-kind resource-id sets.

Benchmark evidence:

- `BenchmarkReadLinkIndexReadCSVRows50000`: `11641625 ns/op`, `17965067 B/op`, `100482 allocs/op`
- `BenchmarkReadLinkIndexStreaming50000`: `11392191 ns/op`, `11647089 B/op`, `100458 allocs/op`
- Shape: on a 50,000-row attachment-link file, a streaming index builder is slightly faster and cuts allocation volume by about 35%, which points to the intermediate row materialization as the avoidable cost.

Runnable benchmark command:

```sh
go test ./internal/evidence -run '^$' -bench 'BenchmarkReadLinkIndex(ReadCSVRows50000|Streaming50000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current `kind` normalization, especially the `bank-row` to `bank_row` alias handling.
- Keep the same missing-column error text for `kind`/`resource_id` failures.
- Preserve deterministic downstream coverage behavior by leaving per-kind set membership and later sorted output unchanged.

## Rebuilding Row Maps While Loading `vat-rates.csv`

Anti-pattern:

- Materializing `RowValues(header, record)` maps inside `LoadAllowedVatRatesBP` in [internal/vat/validate.go](/Users/jhh/git/busdk/busdk/bus-vat/internal/vat/validate.go) just to read the `rate_bp` column. The managed-table path already has the header in hand, so rebuilding a `map[string]string` per row adds avoidable lookup work in a hot validation helper.

Benchmark evidence:

- `BenchmarkLoadAllowedVatRatesBPRowMaps10000`: `665392 ns/op`, `148352 B/op`, `31 allocs/op`
- `BenchmarkLoadAllowedVatRatesBPIndexed10000`: `239077 ns/op`, `148346 B/op`, `31 allocs/op`
- Shape: on a 10,000-row `vat-rates.csv` fixture, resolving `rate_bp` by header index is about 2.8x faster than rebuilding row maps for every record while preserving the same overall allocation profile from the result set itself.

Runnable benchmark command:

```sh
go test ./internal/vat -run '^$' -bench 'BenchmarkLoadAllowedVatRatesBP(RowMaps10000|Indexed10000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current `vat-rates.csv` validation errors, especially empty-file, missing-column, and `rate_bp must be integer` diagnostics.
- Keep the managed-table header contract unchanged: resolve the `rate_bp` column once from the loaded header and continue tolerating short rows the same way the current loop does.
- Scope the optimization to `LoadAllowedVatRatesBP`; do not bypass the shared `LoadOwnedTableRecords` storage-policy path.

## Allocating Temporary Column Slices For Every Review TSV Line

Anti-pattern:

- Building a fresh 14-element slice and calling `strings.Join` for every line in `formatReviewLineTSV` in [internal/vat/review.go](/Users/jhh/git/busdk/busdk/bus-vat/internal/vat/review.go). The review summary TSV shape is fixed-width, so per-line slice construction and joining turns formatting into an allocation-heavy hot path.

Benchmark evidence:

- `BenchmarkFormatReviewSummaryTSVCurrent10000`: `1844756 ns/op`, `4894741 B/op`, `23360 allocs/op`
- `BenchmarkFormatReviewSummaryTSVDirectWrite10000`: `1123408 ns/op`, `3401368 B/op`, `3360 allocs/op`
- Shape: for a 10,000-line mixed summary/rate/coverage review packet, direct field writes are about 1.6x faster and cut allocation count by about 85%, which isolates the temporary slice + `Join` pattern as the dominant formatting cost.

Runnable benchmark command:

```sh
go test ./internal/vat -run '^$' -bench 'BenchmarkFormatReviewSummaryTSV(Current10000|DirectWrite10000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current TSV column order, blank-column placement, and trailing newline behavior for `TOTAL`, `RATE`, and `COVERAGE` rows.
- Keep `source_refs` serialization identical, including semicolon joining and empty-column handling when no refs are present.
- Limit the change to formatter internals; JSON/CSV output and review packet semantics must remain byte-stable.

## Deep-Copying Managed-Table Rows Before Read-Only Vendor Validation

Anti-pattern:

- Copying the managed-table header and every CSV row inside `loadSchemaAndCSV` in [internal/vendors/validator.go](/Users/jhh/git/busdk/busdk/bus-vendors/internal/vendors/validator.go) before `ValidateVendors`, `list`, and `add` do read-only validation work. The current path clones each record even though downstream code only reads field values and then materializes its own validation structures.

Benchmark evidence:

- `BenchmarkCopyManagedTableRecords1000`: `26000 ns/op`, `88640 B/op`, `1002 allocs/op`
- `BenchmarkReuseManagedTableRecords1000`: `0.2865 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for a 1,000-row vendor table, deep-copying rows adds about 88 KB and 1,002 allocations per load before validation starts, while simple slice reuse is effectively free in the benchmark helper.

Runnable benchmark command:

```sh
go test ./internal/vendors -run '^$' -bench 'Benchmark(CopyManagedTableRecords1000|ReuseManagedTableRecords1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve current header validation, short-row handling, and all `ValidateVendors` / `AddVendor` error text.
- Reuse loaded record slices only when downstream code remains read-only; if any caller needs to mutate row contents, keep isolation at that boundary instead of mutating storage-owned slices.
- Keep list output sorting and schema-field lookup behavior unchanged.

## Re-Unmarshaling `vendors.schema.json` In `AddVendor` After It Was Already Parsed

Anti-pattern:

- Re-reading and unmarshaling `vendors.schema.json` in `AddVendor` just to drop unknown keys before `data.AddRow`. [internal/vendors/mutate.go](/Users/jhh/git/busdk/busdk/bus-vendors/internal/vendors/mutate.go) already called `loadSchemaAndCSV`, which parsed the schema once, but the current path opens the schema file again and rebuilds the allowed-field set inside [internal/vendors/storage_support.go](/Users/jhh/git/busdk/busdk/bus-vendors/internal/vendors/storage_support.go).

Benchmark evidence:

- `BenchmarkFilterValuesForSchemaJSONUnmarshal1000`: `2626 ns/op`, `824 B/op`, `17 allocs/op`
- `BenchmarkFilterValuesForSchemaParsedFieldSet1000`: `122.1 ns/op`, `0 B/op`, `0 allocs/op`
- Shape: for a representative vendor row, filtering through a cached parsed field set is about 21x faster and removes the per-call schema JSON allocations from the add path.

Runnable benchmark command:

```sh
go test ./internal/vendors -run '^$' -bench 'BenchmarkFilterValuesForSchema(JSONUnmarshal1000|ParsedFieldSet1000)$' -benchmem
```

Behavior and safety guardrails:

- Preserve schema-driven filtering exactly: only declared fields may reach `data.AddRow`, and omitted optional fields must behave as they do now.
- Keep current invalid-schema failures deterministic; if parsing is moved earlier, surface the same error when schema JSON is malformed.
- Scope any cached allowed-field set to the schema already loaded for the current add operation; do not introduce process-wide schema caches that can outlive workspace edits.
