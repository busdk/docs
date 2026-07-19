---
title: CLI output style
description: BusDK CLI commands keep deterministic machine output separate from readable human output, using a small, consistent set of hierarchy and detail conventions.
---

BusDK CLI commands write two different kinds of output from the same result data. Human output is meant to be read at a terminal and may use light formatting to improve scanability. Machine output, selected with [`--format`](./global-flags) values such as `json`, `tsv`, or `csv`, is meant to be parsed by scripts and other tools, so it stays deterministic, stable, and free of ANSI escape codes or presentation glyphs. As described in [Error handling, dry-run, and diagnostics](./error-handling-dry-run-diagnostics), command results go to standard output by default and diagnostics go to standard error. The documented `--quiet` and `--output` exceptions suppress or redirect normal result output.

Whichever format is selected, the answer to the user's actual question comes first. A `list` command's rows, a `show` command's fields, or a failed command's error message is the primary content. Labels, identifiers, statuses, ordering, empty-result wording, and error text stay concise and deterministic, consistent with the ordering and stability requirements in [Reporting and query commands](./reporting-and-queries).

## Human-readable hierarchy

Human output that shows a set of records as a nested parent/child hierarchy, such as a `list` command's default view, uses box-drawing tree connectors: `├─` for every sibling except the last one at that level, and `└─` for the last sibling actually rendered. Each level below the top adds another three-column indent under its parent's connector before printing the next connector. The record's status, when relevant, is a plain textual `[status]` suffix, not a color or icon standing in for it. A parent row that also carries a computed aggregate over its own descendants, such as a completion count, appends that aggregate inside the same bracket after the status; a row with no descendants keeps the shorter status-only form and never shows a synthetic `0/0` aggregate:

```text
└─ #10 Launch checklist [active, 2/4 complete (50%)]
   ├─ #11 Update changelog [completed]
   └─ #12 Support runbook [active, 1/2 complete (50%)]
      └─ #14 Rollback drill [deferred]
```

When a command's rows are explicitly reordered by a scriptable key such as `--order activity`, sibling adjacency no longer matches parent/child structure, so those rows drop the tree connectors and use a flat `•` bullet form instead: one `•`, one space, then the row content, keeping the same `[status]` or `[status, aggregate]` bracket:

```text
• #12  Support runbook [active, 1/2 complete (50%)] activity: 2026-03-05T00:00:00Z
• #14  Rollback drill [deferred] activity: 2026-03-06T00:00:00Z
```

Glyphs decorate a row; they never replace the identifier, label, or status text next to them. A row must still be unambiguous if the bullet and connector characters are stripped out.

## Detail connectors

When a single record's related fields or sub-items are shown as a flat detail list rather than a nested hierarchy, use detail-list box-drawing connectors `├─` for every row except the last, and `└─` for the last row actually rendered. These connectors reuse the same characters as the nested-hierarchy connectors above but stay flat under exactly one record instead of nesting to arbitrary depth, and neither is the flat `•` bullet form used for explicitly reordered rows:

```text
INV-2026-014  Acme Oy  [open]
├─ Total 1 240,00 EUR
├─ VAT 240,00 EUR
└─ Due 2026-08-15
```

The final connector is computed from what is actually printed, not hard-coded to a fixed row count. If a field is omitted (for example because it is empty and the command skips blank fields), the row above it becomes the new last row and gets `└─` instead of `├─`.

## Bounded multiline text

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

## Child resources

Direct child resources attached to a record, such as attachment files listed under an invoice, use a plain Markdown `-` bullet rather than box-drawing characters:

```text
Attachments
- receipt-2026-03-14.pdf
- contract-addendum.pdf
```

Box-drawing characters are reserved for the hierarchy, detail, and bounded-multiline conventions above; they are not a general-purpose tree or table framework, and commands should not invent new box shapes for other content.

## Encoding, layout, and color

Human output is UTF-8 plain text. Commands must not depend on terminal width for alignment: no fixed-width column padding that breaks when an identifier or label is longer than expected. ANSI color is enabled by command/module rules via `--color` and `NO_COLOR`. It may apply to command result rows in explicit modes for certain commands (for example status markers and hierarchy connectors in `bus thread list`), while JSON and other structured output remains color-free. The textual `[status]` suffix and row content must remain readable and deterministic even when color is disabled, matching the mode semantics in [Standard global flags](./global-flags).

## Flags, errors, and help

Long flags use their full, correctly spelled canonical form (`--format`, `--chdir`, `--dry-run`) in help text and examples; commands do not invent alternate spellings for the same flag. Conflicting flags produce an actionable error naming both flags and what to do instead, for example `--quiet and --verbose cannot be combined; drop one of them`, consistent with the exit-status-2 usage-error contract in [Standard global flags](./global-flags). Help output stays short and example-driven, closer to `git add -h` than to a prose manual, per [Command structure and discoverability](./command-structure). Empty-result behavior is deterministic per command rather than governed by one universal rule. Each command documents what its text output does when there is nothing to show; an empty text result may be intentionally silent (for example a `--quiet` scripting mode) or may state the empty condition explicitly, such as `no invoices found for period 2026-03`, but the chosen behavior must be documented and stable. Machine formats such as `json`, `tsv`, or `csv` are never silently blank: an empty result emits the format's documented empty structured value, such as `[]` for a JSON array result, and remains complete and lossless, keeping the same fields and shape a non-empty result would carry unless the command's docs describe a narrower projection for the empty case.

The tree-connector and bullet forms shown above reflect the installed `bus thread list` behavior. Archived-record filtering, positional shorthand for addressing one record directly (for example `bus invoices <invoice-id> show` instead of a separate lookup flag), and structured `show` output are target conventions that module commands may still be adopting. Do not rely on any of them in a script unless the relevant `bus <module> --help` output confirms the option or behavior; consult command-level help by name only when that exact help invocation is explicitly documented as supported by the module help or reference.

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
