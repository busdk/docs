---
title: Formula options for workbook extraction
description: End-user guide for formula-related flags in bus data workbook extraction and what results to expect.
---

## Formula options for workbook extraction

This page explains how formula-related options behave when you run workbook-style table reads through `bus data`.

Use this page when you need to run commands and verify outputs. Detailed implementation contracts are maintained in the private SDD workspace.

### What the options do

`--formula` enables formula evaluation when formula-enabled fields are declared in a beside-the-table schema.

`--formula-source` includes the formula source text in output together with evaluated values.

`--formula-dialect <name>` selects a source profile (`spreadsheet`, `excel_like`, or `sheets_like`) when source expression syntax differs.

`--decimal-sep <char>` and `--thousands-sep <char>` control locale parsing and output normalization for numeric values.

### Typical command

```bash
bus data table workbook source.csv A1:C10 \
  --formula \
  --decimal-sep "," \
  --thousands-sep " " \
  -f tsv
```

### Expected results

When `--formula` is active and schema metadata enables formulas, formula cells output evaluated values. Without schema metadata or without `--formula`, formula evaluation is not applied.

When locale flags are set, locale-formatted numbers are normalized in output to canonical decimal form.

### Quick verification checklist

1. Formula cells return evaluated values when `--formula` is enabled.
2. `--formula-source` adds source expressions without removing evaluated output.
3. Locale-formatted values normalize as expected with separator flags.
4. Re-running the same command on unchanged input returns the same output.

### Using from `.bus` files

```bus
# same as: bus data table workbook source.csv A1:C10 --formula -f tsv
data table workbook source.csv A1:C10 --formula -f tsv
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bfl">bus-bfl</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-data module reference](https://docs.busdk.com/modules/bus-data)
- [bus-bfl module reference](https://docs.busdk.com/modules/bus-bfl)
- [Table Schema contract](https://docs.busdk.com/data/table-schema-contract)
