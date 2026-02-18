---
title: bus-filing-vero — Vero export bundles from validated data (SDD)
description: Bus Filing Vero converts validated workspace data into Vero export bundles from the canonical VAT and report layout, using path accessors and no extra preprocessing.
---

## bus-filing-vero — Vero export bundles from validated data

### Introduction and Overview

Bus Filing Vero converts validated workspace data into Vero export bundles, applying Vero-specific packaging rules and metadata while keeping bundle structure deterministic and auditable.

### Requirements

FR-VERO-001 Vero bundle generation. The module MUST produce Vero-ready bundle directories or archives from validated data and VAT outputs. Acceptance criteria: outputs include manifests and hashes and validate internal consistency.

FR-VERO-002 VAT traceability. The module MUST retain references to underlying postings, vouchers, and VAT summaries. Acceptance criteria: bundles include VAT summaries and reference identifiers back to source datasets.

NFR-VERO-001 Deterministic export. Bundle contents MUST be deterministic so exports remain verifiable. Acceptance criteria: manifests and hashes are stable for identical inputs.

NFR-VERO-002 Path resolution for upstream data. The module MUST resolve paths to VAT outputs and report outputs via the owning modules’ Go library path accessors ([bus-vat](../sdd/bus-vat) IF-VAT-002 and the equivalent for reports). It MUST NOT hardcode directory names (e.g. `reports/`, `vat/`) or file names that differ from what `bus vat init` and the reports module produce. Acceptance criteria: after `bus vat init` (and report generation where required), export runs without requiring manual creation of directories or preprocessing; path resolution uses library APIs only.

### System Architecture

Bus Filing Vero is invoked through `bus filing vero` and consumes validated datasets, VAT outputs, and reports produced by other modules. It produces a Vero-specific export bundle.

### Key Decisions

KD-VERO-001 Vero export is a target-specific specialization. The module focuses only on Vero packaging and relies on shared validation and reporting outputs.

KD-VERO-002 Consume canonical layout only. Bus-filing-vero consumes VAT and report data in the layout produced by [bus vat](../sdd/bus-vat) and the reports module. It does not define or require a separate directory structure (e.g. a dedicated `vat/` or `reports/` tree) that those modules do not produce. Required pre-export layout is therefore: workspace initialized with `bus vat init` (and report outputs generated when the bundle requires them), with no extra preprocessing or manual directory creation.

### Component Design and Interfaces

Interface IF-VERO-001 (module CLI). The module is invoked as `bus filing vero` and follows BusDK CLI conventions for deterministic output and diagnostics.

Invocation forms are `bus filing vero` and `bus-filing-vero`. Global flags are parsed before the subcommand, and `--` terminates global flag parsing so remaining tokens are passed to the subcommand.

The command surface is defined as follows.

| Flag | Description | Default | Exit on error |
|------|-------------|---------|---------------|
| `-h`, `--help` | Print help and exit successfully. With a subcommand, show subcommand help. | — | 0 |
| `-V`, `--version` | Print `bus-filing-vero <version>` and exit successfully. | — | 0 |
| `-v`, `--verbose` | Increase diagnostic verbosity on stderr. Repeatable (`-vv`, `-vvv`). | `0` | — |
| `-q`, `--quiet` | Suppress normal and verbose output; only errors are written to stderr. | off | — |
| `-C <dir>`, `--chdir <dir>` | Resolve workspace paths from `<dir>`. | current directory | 1 if invalid |
| `-o <file>`, `--output <file>` | Write command results to `<file>` instead of stdout. | stdout | 1 if write error |
| `-f <format>`, `--format <format>` | Structured result format: `tsv` or `json`. | `tsv` | 2 if unknown |
| `--color <mode>` | Color mode for stderr diagnostics: `auto`, `always`, `never`. | `auto` | 2 if invalid |
| `--no-color` | Alias for `--color=never`. | — | — |
| `--` | End global flag parsing. Remaining arguments are subcommand arguments. | — | — |

`-q` and `-v`/`--verbose` are mutually exclusive and return usage error exit code 2 when combined. `-h` and `-V` are immediate-exit flags that ignore all other flags and arguments and return exit code 0. When `--quiet` and `--output` are both present, quiet mode wins and no output file is written. If both `--color <mode>` and `--no-color` are present, color is disabled.

| Subcommand | Purpose | Flag | Description | Default |
|------------|---------|------|-------------|---------|
| `export` | Build a Vero filing bundle from a validated workspace. | `--bundle <dir>` | Bundle directory to create. | `filing/vero/bundle` |
| `export` | Build a Vero filing bundle from a validated workspace. | `--dry-run` | Preview bundle contents without writing files. | off |
| `verify` | Verify bundle checksums and manifest consistency. | `--bundle <dir>` | Bundle directory to verify. | `filing/vero/bundle` |

Subcommands do not accept positional arguments. Unknown subcommands and unknown subcommand flags are usage errors with exit code 2. An empty `--bundle` value is a usage error with exit code 2.

This interface definition resolves OQ-VERO-001 for the module command surface.

### Data Design

The module reads validated datasets, VAT outputs, and report outputs and writes Vero-specific bundle directories or archives with manifests and hashes.

**Required pre-export layout.** Inputs MUST be in the canonical layout produced by upstream modules. VAT datasets and their schemas live at the workspace root as defined by [bus-vat](../sdd/bus-vat) and [VAT area](../layout/vat-area), and this module only reads a `vat/` subdirectory when the VAT path accessor explicitly returns such paths. Report outputs are likewise read from whatever location the reports path accessor returns, so `reports/` is optional and not a required directory contract.

For every CSV input, a beside-the-CSV table schema is required. The module accepts both schema naming conventions: `name.schema.json` and `name.csv.schema.json`. This keeps exports compatible with canonical outputs from `bus vat init` and with other modules that emit the `.csv.schema.json` form.

### Assumptions and Dependencies

Bus Filing Vero depends on `bus filing` orchestration, `bus period` closed data, and outputs from [bus vat](../sdd/bus-vat) and the reports module. VAT and report file locations and schema naming are defined by the owning modules and resolved through their path accessors; bus-filing-vero does not define or require a different layout (KD-VERO-002, NFR-VERO-002). Missing prerequisites result in deterministic diagnostics that reference the paths resolved via the owning modules’ APIs. Impact if false: requiring a layout that upstream modules do not produce blocks end-to-end export after standard init and report/VAT generation.

### Security Considerations

Vero bundles contain sensitive financial data and must be protected by repository access controls. Manifests and hashes must remain intact for verifiability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to bundle paths and missing prerequisites.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Missing prerequisites or invalid bundles exit non-zero without partial output.

### Testing Strategy

Unit tests cover bundle assembly rules, and command-level tests exercise Vero exports against fixture workspaces with known outputs.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Bundle structure changes are handled by updating the module and documenting the new bundle format.

### Risks

Path-contract behavior aligns with NFR-VERO-002 and KD-VERO-002 in the current release line. VAT and report inputs are resolved through library path accessors only, root-level VAT files are supported, both schema naming conventions are accepted, and no manual directory creation is required beyond standard `bus vat init` and report generation when the selected bundle content requires reports.

### Glossary and Terminology

Vero bundle: an export package formatted for Finnish Vero filing requirements.  
Manifest: a deterministic listing and checksum set for bundle contents.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing-prh">bus-filing-prh</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../integration/index">Integration and future interfaces</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-vat module SDD](./bus-vat) (path accessors, canonical VAT layout)
- [VAT area (layout)](../layout/vat-area)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [End user documentation: bus-filing-vero CLI reference](../modules/bus-filing-vero)
- [Repository](https://github.com/busdk/bus-filing-vero)
- [VAT reporting and payment](../workflow/vat-reporting-and-payment)
- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)

### Document control

Title: bus-filing-vero module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-FILING-VERO`  
Version: 2026-02-18  
Status: Draft  
Last updated: 2026-02-18  
Owner: BusDK development team  
