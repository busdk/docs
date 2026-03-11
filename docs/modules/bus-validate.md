---
title: bus-validate — validate workspace data and control checks
description: bus validate checks datasets, schemas, and accounting invariants across the workspace, and adds dedicated parity, journal-gap, and evidence-coverage checks for migration and close workflows.
---

## `bus-validate` — validate workspace data and control checks

`bus validate` is the workspace-wide safety check. Use it before close, before filing work, after imports, and after larger automated changes when you want one command to tell you whether the data is still coherent.

The base command validates schemas and cross-table invariants. The subcommands add dedicated controls for import parity, journal gaps, and missing evidence links.

### Common tasks

Run a full workspace validation:

```bash
bus validate
```

Get machine-readable diagnostics:

```bash
bus validate --format tsv
```

Check import parity against a source summary:

```bash
bus validate parity \
  --source ./imports/source-summary.tsv \
  --max-abs-delta 0.01
```

Check journal gaps with bucket-specific thresholds:

```bash
bus validate journal-gap \
  --source ./imports/journal-gap.tsv \
  --max-abs-delta 0.01 \
  --bucket-thresholds ./config/gap-thresholds.yaml
```

Audit evidence coverage before close:

```bash
bus validate evidence-coverage
bus validate evidence-coverage --vendor vendor-oy --source bank --group-by vendor
```

### Synopsis

`bus validate [--format <text|tsv>] [-C <dir>] [global flags]`  
`bus validate parity --source <file> [--max-abs-delta <n>] [--max-count-delta <n>] [--dry-run] [--bucket-thresholds <file>] [-C <dir>] [-o <file>] [global flags]`  
`bus validate journal-gap --source <file> [--max-abs-delta <n>] [--dry-run] [--bucket-thresholds <file>] [-C <dir>] [-o <file>] [global flags]`  
`bus validate evidence-coverage [--vendor <normalized-key>] [--source <bank|invoice|journal|qred_statement|settlement>] [--group-by <vendor|month|document-type|source>] [-C <dir>] [-o <file>] [global flags]`

### Which command should you use?

Use plain `bus validate` when you want overall workspace correctness.

Use `parity` when you have a source-summary artifact and want to know whether imported counts and sums still match the workspace.

Use `journal-gap` when the main question is “what source activity has not reached the journal yet?”.

Use `evidence-coverage` when the main question is “what rows still do not have supporting attachments or evidence links?”.

### What the validator checks

The base validator reads workspace datasets and schemas through the shared storage-aware data layer. It checks schema constraints, references, and accounting invariants such as balanced journal transactions.

The base command does not modify data. On success, stdout stays empty.

### Migration and reconciliation controls

`parity` and `journal-gap` are especially useful after ERP history imports and replay work.

`parity` is better when you care about dataset- and period-level totals matching an external source.

`journal-gap` is better when you want to separate operational gaps from financing or transfer gaps, especially if you use bucket-specific thresholds.

### Evidence controls

`evidence-coverage` looks at links between business data and attachments. It can narrow the output to one vendor or one source channel, and it can group the output by vendor, month, document type, or source.

This is the control surface to use before year-end close or audit-style evidence review.

### Typical workflow

A common pre-close check sequence is:

```bash
bus validate
bus validate evidence-coverage
bus status close-readiness --year 2026 --compliance fi
```

For migration work, the sequence is often:

```bash
bus validate parity --source ./imports/source-summary.tsv --max-abs-delta 0.01
bus validate journal-gap --source ./imports/source-summary.tsv --max-abs-delta 0.01
```

### Output and flags

The base `validate` command writes diagnostics to stderr and keeps stdout empty. `--format tsv` is the machine-friendly way to capture those diagnostics.

The subcommands `parity`, `journal-gap`, and `evidence-coverage` do produce result sets, so `-o` is useful there.

`--dry-run` is mainly for `parity` and `journal-gap`. It shows planned thresholds and scope without writing the result set.

These commands use [Standard global flags](../cli/global-flags). For the full flag and threshold details, run `bus validate --help`.

### Exit status

`0` when the requested validation or control check passes. Non-zero on invalid usage, schema or invariant violations, exceeded thresholds, or missing evidence.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus validate --format tsv
validate --format tsv

# same as: bus validate parity --source ./imports/source-summary.tsv --max-abs-delta 0.01
validate parity --source ./imports/source-summary.tsv --max-abs-delta 0.01

# same as: bus validate evidence-coverage --source bank --group-by vendor
validate evidence-coverage --source bank --group-by vendor
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reports">bus-reports</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vat">bus-vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module reference: bus-validate](../modules/bus-validate)
- [Architecture: Shared validation layer](../architecture/shared-validation-layer)
- [CLI: Validation and safety checks](../cli/validation-and-safety-checks)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)
- [Finnish closing adjustments and evidence controls](../compliance/fi-closing-adjustments-and-evidence-controls)
