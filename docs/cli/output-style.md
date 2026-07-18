---
title: CLI output style
description: BusDK CLI commands keep deterministic machine output separate from readable human output, using a small, consistent set of hierarchy and detail conventions.
---

BusDK CLI commands write two different kinds of output from the same result data. Human output is meant to be read at a terminal and may use light formatting to improve scanability. Machine output, selected with [`--format`](./global-flags) values such as `json`, `tsv`, or `csv`, is meant to be parsed by scripts and other tools, so it stays deterministic, stable, and free of ANSI escape codes or presentation glyphs. As described in [Error handling, dry-run, and diagnostics](./error-handling-dry-run-diagnostics), command results go to standard output by default and diagnostics go to standard error. The documented `--quiet` and `--output` exceptions suppress or redirect normal result output.

Whichever format is selected, the answer to the user's actual question comes first. A `list` command's rows, a `show` command's fields, or a failed command's error message is the primary content. Labels, identifiers, statuses, ordering, empty-result wording, and error text stay concise and deterministic, consistent with the ordering and stability requirements in [Reporting and query commands](./reporting-and-queries).

### Human-readable hierarchy

Human output that shows a list of records as a hierarchy uses a literal `•` followed by one space, then the row content. Each depth below the top level adds two more spaces before the `•`. The record's status, when relevant, is a plain textual `[status]` suffix, not a color or icon standing in for it:

```text
• 41  Thread list output behavior [completed]
  • 219  Add bullet markers to human-readable Thread list rows [completed]
  • 220  Hide archived Threads from default list and add --archived [completed]
```

Glyphs decorate a row; they never replace the identifier, label, or status text next to them. A row must still be unambiguous if the bullet and connector characters are stripped out.

### Detail connectors

When a single record's related fields or sub-items are shown as a flat detail list rather than a nested hierarchy, use detail-list box-drawing connectors `├─` for every row except the last, and `└─` for the last row actually rendered. The `•` hierarchy bullet and the `├─`/`└─` detail connectors belong to different layouts:

```text
INV-2026-014  Acme Oy  [open]
├─ Total 1 240,00 EUR
├─ VAT 240,00 EUR
└─ Due 2026-08-15
```

The final connector is computed from what is actually printed, not hard-coded to a fixed row count. If a field is omitted (for example because it is empty and the command skips blank fields), the row above it becomes the new last row and gets `└─` instead of `├─`.

### Bounded multiline text

Descriptions, messages, and other multiline text that must stay visually bounded use a separate boundary glyph set: `╭─` opens, `│` prefixes every content line, and `╰─` closes. These boundary glyphs are for multiline text only; they are not hierarchy bullets or detail-list connectors. Blank lines inside the text are preserved as a bare `│` so the boundary stays continuous:

```text
Description
╭─
│ Quarterly consulting retainer.
│
│ Includes one on-site workshop day per quarter.
╰─
```

Message envelopes keep the ordinal, author, and message ID on the opening line:

```text
Messages · 1 total · 1 shown · 0 omitted
╭─ 1/1 · human/alice · t222-m1
│ Connected.
╰─
```

### Child resources

Direct child resources attached to a record, such as attachment files listed under an invoice, use a plain Markdown `-` bullet rather than box-drawing characters:

```text
Attachments
- receipt-2026-03-14.pdf
- contract-addendum.pdf
```

Box-drawing characters are reserved for the hierarchy, detail, and bounded-multiline conventions above; they are not a general-purpose tree or table framework, and commands should not invent new box shapes for other content.

### Encoding, layout, and color

Human output is UTF-8 plain text. Commands must not depend on terminal width for alignment: no fixed-width column padding that breaks when an identifier or label is longer than expected. ANSI color, where `--color` enables it, is confined to human-facing diagnostics and help text on standard error; result rows on standard output or in `--output` remain uncolored. The textual `[status]` suffix and row content carry the meaning on their own, matching the color behavior defined in [Standard global flags](./global-flags).

### Flags, errors, and help

Long flags use their full, correctly spelled canonical form (`--format`, `--chdir`, `--dry-run`) in help text and examples; commands do not invent alternate spellings for the same flag. Conflicting flags produce an actionable error naming both flags and what to do instead, for example `--quiet and --verbose cannot be combined; drop one of them`, consistent with the exit-status-2 usage-error contract in [Standard global flags](./global-flags). Help output stays short and example-driven, closer to `git add -h` than to a prose manual, per [Command structure and discoverability](./command-structure). An empty result is stated explicitly, such as `no invoices found for period 2026-03`, rather than printed as blank output that could be mistaken for an error or a hang.

The bullet hierarchy shown above reflects the installed `bus thread list` behavior. Archived-record filtering, positional shorthand for addressing one record directly (for example `bus invoices <invoice-id> show` instead of a separate lookup flag), and structured `show` output are target conventions that module commands may still be adopting. Do not rely on any of them in a script unless the relevant `bus <module> <command> --help` output lists the option or behavior.

Human-output changes require focused golden/fixture coverage. Machine output requires separate shape and ordering coverage. User-visible command changes require help/docs updates and exact local CLI E2E coverage.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./reporting-and-queries">Reporting and query commands</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./validation-and-safety-checks">Validation and safety checks</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Standard global flags](./global-flags)
- [Error handling, dry-run, and diagnostics](./error-handling-dry-run-diagnostics)
- [Reporting and query commands](./reporting-and-queries)
- [Command structure and discoverability](./command-structure)
