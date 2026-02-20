---
title: bus-filing-vero — produce Vero export bundles
description: bus filing vero produces Vero export bundles from the canonical VAT and report layout; no manual reports or vat directories needed.
---

## `bus-filing-vero` — produce Vero export bundles

### Synopsis

`bus filing vero [global flags] <subcommand> [subcommand flags]`

`bus-filing-vero [global flags] <subcommand> [subcommand flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus filing vero` converts validated workspace data into Vero-ready export bundles with deterministic packaging, manifests, and hashes. It consumes VAT and report outputs and closed-period data in the layout produced by [bus vat](./bus-vat) and the reports module. Path resolution is done through module path accessors, so `reports/` and `vat/` are optional directories that are used only when those accessors return paths under them.

### Prerequisites

Export expects the canonical workspace layout produced by the upstream modules. Run `bus config init`, `bus invoices init`, and `bus vat init` so VAT datasets and schemas exist at the workspace root as defined by [bus vat](./bus-vat) and [VAT area](../layout/vat-area). When the selected bundle requires report outputs, generate them with the reports module first. The tool resolves VAT and report file paths through module path accessors, so no manual creation of `reports/` or `vat/` is required.

For each CSV input, a beside-the-CSV table schema is required. The command accepts both `name.schema.json` and `name.csv.schema.json`, for example `vat-rates.schema.json` and `vat-rates.csv.schema.json`.

### Options

The command surface is explicit and deterministic.

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

Global flags appear before the subcommand. `-q` and `-v`/`--verbose` are mutually exclusive and return usage error exit code 2 when combined. `-h` and `-V` are immediate-exit flags that ignore all other flags and arguments and return exit code 0. When `--quiet` and `--output` are both present, quiet mode wins and no output file is written. If both `--color <mode>` and `--no-color` are present, color is disabled.

| Subcommand | Purpose | Flag | Description | Default |
|------------|---------|------|-------------|---------|
| `export` | Build a Vero filing bundle from a validated workspace. | `--bundle <dir>` | Bundle directory to create. | `filing/vero/bundle` |
| `export` | Build a Vero filing bundle from a validated workspace. | `--dry-run` | Preview bundle contents without writing files. | off |
| `verify` | Verify bundle checksums and manifest consistency. | `--bundle <dir>` | Bundle directory to verify. | `filing/vero/bundle` |

Subcommands accept no positional arguments. Unknown subcommands and unknown subcommand flags are usage errors with exit code 2. An empty `--bundle` value is a usage error with exit code 2.

### Files

Reads validated datasets and VAT and report outputs from the canonical layout, with root-level VAT files by default per [bus vat](./bus-vat). `vat/` and `reports/` are optional and are used only when the path accessors return those locations. For each CSV input, the command accepts `name.schema.json` and `name.csv.schema.json`. Writes Vero-specific bundle directories or archives with manifests and hashes.

### Examples

```bash
bus filing vero export --bundle filing/vero/2026-01
bus filing vero verify --bundle filing/vero/2026-01
```

### Exit status

`0` on success. Non-zero on invalid usage or missing prerequisites.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus filing-vero --help
filing-vero --help

# same as: bus filing-vero -V
filing-vero -V
```


### Development state

**Value promise:** Produce Vero (Finnish Tax Administration) export bundles from closed-period data when invoked as the `vero` target of [bus-filing](./bus-filing).

**Use cases:** [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

**Completeness:** 50% — export and verify from fixture verified by e2e and unit tests; full Vero-filing journey step blocked by [bus-filing](./bus-filing) bundle contract.

**Use case readiness:** Finnish bookkeeping and tax-audit compliance: 50% — produce and verify Vero bundle from fixture; FR-VERO-002, NFR-VERO-001, NFR-VERO-002 verified by e2e and unit tests; full journey blocked by [bus-filing](./bus-filing) bundle contract.

**Current:** E2e `tests/e2e_bus_filing-vero.sh` verifies help, version, export, verify, global flags (-C, -o, -f, --color, -q, --, --dry-run), invalid usage, bundle layout (manifest, checksums, data, source_refs, voucher_posting_refs), root VAT path and both schema conventions, verify success, --output/--format json, -vv, deterministic export, --dry-run, --no-color, quiet and quiet+--output. Unit tests: `internal/app/app_test.go` (help/version ignore args, quiet+verbose conflict, invalid color/format, -C, --output write/truncate, quiet suppresses output and output file, requires .git); `internal/bundle/bundle_test.go` (export/verify/dry-run, missing schema, manifest source_refs and voucher_posting_refs, bus-vat schema naming, works without reports or vat dirs, prereq checker, verify mismatch/success, conflict markers); `internal/cli/flags_test.go` (-vv, --, help); `internal/paths/paths_test.go` (VAT paths at root, ignores subdirs, both schema conventions).

**Planned next:** Continue bundle-contract alignment with [bus-filing](./bus-filing) for the full end-to-end filing journey.

**Blockers:** [bus-filing](./bus-filing) bundle contract must be stable for target consumption.

**Depends on:** [bus-filing](./bus-filing) (invoked as target); [bus-period](./bus-period) closed; [bus-vat](./bus-vat) and reports module for input layout (canonical VAT and report paths).

**Used by:** [bus-filing](./bus-filing) invokes this module when the target is vero.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing-prh">bus-filing-prh</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../integration/index">Integration and future interfaces</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module CLI reference: bus-vat](../modules/bus-vat)
- [VAT area (layout)](../layout/vat-area)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [Module SDD: bus-filing-vero](../sdd/bus-filing-vero)
- [Workflow: VAT reporting and payment](../workflow/vat-reporting-and-payment)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
