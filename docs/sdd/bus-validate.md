---
title: bus-validate — workspace-wide validation and integrity checks (SDD)
description: Bus Validate validates all workspace datasets against their schemas, verifies cross-table integrity and double-entry invariants, and produces actionable…
---

## bus-validate — workspace-wide validation and integrity checks

### Introduction and Overview

Bus Validate validates all workspace datasets against their schemas, verifies cross-table integrity and double-entry invariants, and produces actionable diagnostics for invalid workspaces. This SDD defines first-class migration parity and gap checks between source imports and workspace or journal activity; those checks are implemented as subcommands `bus validate parity` and `bus validate journal-gap` (IF-VAL-002).

### Requirements

FR-VAL-001 Workspace validation. The module MUST validate all datasets and schemas in the workspace and enforce cross-table invariants. Acceptance criteria: schema and invariant violations produce deterministic diagnostics and non-zero exit codes.

FR-VAL-002 CLI surface for validation. The module MUST expose a deterministic validation command usable in automation. Acceptance criteria: `bus validate` runs without modifying datasets.

FR-VAL-003 Source import parity report. The module MUST provide a deterministic parity check that compares source import totals and counts against canonical workspace datasets by period and dataset type. Acceptance criteria: parity output includes dataset, period, source count or sum, workspace count or sum, delta, and status fields; repeated runs with the same inputs produce byte-identical output.

FR-VAL-004 Journal gap check. The module MUST provide a deterministic gap check that compares imported operational activity to non-opening journal activity by month. Acceptance criteria: output includes period, imported operational totals, journal non-opening totals, delta, and status fields; opening entries can be explicitly excluded from coverage calculations.

FR-VAL-005 Threshold and CI exit behavior. Parity and gap checks MUST support optional threshold flags and CI-friendly exit behavior. Acceptance criteria: users can define absolute or relative thresholds for counts and sums; commands exit non-zero when thresholds are exceeded and zero otherwise; dry-run emits planned thresholds and evaluated scope without writing artifacts.

NFR-VAL-001 Auditability. Validation diagnostics MUST reference datasets and stable identifiers for traceability. Acceptance criteria: diagnostics cite workspace-relative paths and identifiers.

NFR-VAL-002 Deterministic migration diagnostics. Parity and gap diagnostics MUST identify the source input, comparison basis, and affected period deterministically. Acceptance criteria: diagnostics include stable check IDs and references to dataset names, source snapshot identifiers, and period keys so migration reviews can trace failures without ad-hoc scripts.

### System Architecture

Bus Validate is a cross-module validator that reads all workspace datasets and schemas and reports violations. It does not modify data and is used as a prerequisite for close and filing workflows.

### Key Decisions

KD-VAL-001 Validation is a first-class CLI workflow. Validation is explicit and deterministic rather than implicit during unrelated operations.

KD-VAL-002 Migration quality gates live in validate. Source-import parity checks and journal-gap checks are treated as validation-quality gates with deterministic threshold semantics for CI workflows.

### Component Design and Interfaces

Interface IF-VAL-001 (module CLI). The module is invoked as `bus validate` and follows BusDK CLI conventions for deterministic output and diagnostics.

Validation scope is fixed to the full workspace datasets and schemas, including cross-table invariants. The command does not support partial validation modes or dataset selection parameters because the purpose is to confirm workspace-wide integrity as a single deterministic step.

Interface IF-VAL-002 (parity and gap checks). The command surface includes `bus validate parity --source <file>` and `bus validate journal-gap --source <file>` with optional threshold flags and `--dry-run`. The module consumes deterministic source-summary inputs and canonical workspace datasets, emits machine-readable parity or gap rows (TSV to stdout or `--output`), and applies optional threshold flags for CI exit behavior.

Validation results are diagnostics. The command supports a machine-readable diagnostics format by accepting `--format text` (default) or `--format tsv`, with the selected diagnostics written to standard error. The `tsv` format emits a stable column set of `dataset`, `record_id`, `field`, `rule`, and `message` so automation can filter and join diagnostics across revisions. Standard output remains reserved for command results and is empty on success, so automation should capture diagnostics via standard error redirection. The `--output` flag does not apply because `bus validate` does not emit a result set; when present it has no effect on diagnostics.

For parity and gap subcommands, output is a deterministic result set (TSV) suitable for CI ingestion. Suggested stable columns include `check_id`, `dataset_or_scope`, `period`, `source_value`, `workspace_or_journal_value`, `delta`, `threshold`, and `status`.

Usage example:

```bash
bus validate
```

### Data Design

The module reads all workspace datasets and schemas and does not write to the repository.

### Assumptions and Dependencies

Bus Validate depends on the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics. Parity and gap checks depend on deterministic source import summaries and on comparison read surfaces from [bus-reports](./bus-reports) and [bus-reconcile](./bus-reconcile) where applicable.

### Security Considerations

Validation does not change datasets and should not expose sensitive data beyond necessary diagnostics. Output should remain limited to dataset references and identifiers.

### Observability and Logging

Validation results are emitted as diagnostics to standard error with deterministic references to dataset paths and identifiers. Standard output remains reserved for other command results and is empty on success.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Validation failures exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover schema and invariant checks, and command-level tests exercise `bus validate` against fixture workspaces with known errors. Parity and gap tests MUST verify deterministic counts and sums by period, non-opening journal coverage behavior, threshold semantics, CI exit-code behavior, and byte-identical output for repeated runs with identical inputs.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Script-based migration checks (`exports/2024/022-erp-parity-2024.sh` and `exports/2024/023-erp-journal-gap-2024.sh`) remain available as an alternative to the first-class parity and journal-gap subcommands.

### Suggested capabilities (out of current scope)

**Class-aware gap reporting.** A single aggregate bank/journal or ERP-vs-journal gap can mix operational income/expense with financing liability movements and internal transfers, which obscures whether business-activity classification is improving. A suggested extension is class-aware gap reporting with configurable account buckets (e.g. operational income/expense coverage, financing liability/service coverage, internal transfer coverage), deterministic period-based outputs, and CI-friendly thresholds per bucket. The breakdown report artifact may be supplied by [bus-reports](./bus-reports); see the bus-reports SDD suggested capabilities. Not yet a requirement.

**Class-aware gap validation thresholds (per-bucket thresholds).** Not implemented: `bus validate` has parity and journal-gap but no per-bucket thresholds. A suggested extension is optional validation that compares the gap (e.g. unposted bank vs journal) per account bucket against configurable thresholds, with CI-friendly exit when a bucket exceeds its threshold. This would allow failing on operational backlog while tolerating higher financing or transfer backlog. Implementation options: separate threshold flags per bucket (e.g. `--max-abs-delta-operational`) or a config file mapping bucket → threshold. Exit semantics: non-zero when any bucket exceeds its configured threshold; zero when all buckets are within limits. When adopted, the SDD will specify the new threshold contract (validation rules); module docs will be required for threshold configuration and exit behavior.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic validation.

### Glossary and Terminology

Validation diagnostics: deterministic messages that cite dataset paths and identifiers for errors.  
Invariant: a cross-table rule that must hold for repository data to be valid.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-replay">bus-replay</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vat">bus-vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Bank transactions](../master-data/bank-transactions/index)
- [End user documentation: bus-validate CLI reference](../modules/bus-validate)
- [Repository](https://github.com/busdk/bus-validate)
- [Shared validation layer](../architecture/shared-validation-layer)
- [Validation and safety checks](../cli/validation-and-safety-checks)
- [bus-reports module SDD](./bus-reports)
- [bus-reconcile module SDD](./bus-reconcile)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)

### Document control

Title: bus-validate module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-VALIDATE`  
Version: 2026-02-18  
Status: Draft  
Last updated: 2026-02-18  
Owner: BusDK development team  
