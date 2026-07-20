---
title: CLI output style
description: BusDK CLI commands keep deterministic machine output separate from readable human output, using a small, consistent set of hierarchy and detail conventions.
---

BusDK CLI commands write two different kinds of output from the same result data. Human output is meant to be read at a terminal and may use light formatting to improve scanability. Machine output, selected with [`--format`](./global-flags) values such as `json`, `tsv`, or `csv`, is meant to be parsed by scripts and other tools, so it stays deterministic, stable, and free of ANSI escape codes or presentation glyphs. As described in [Error handling, dry-run, and diagnostics](./error-handling-dry-run-diagnostics), command results go to standard output by default and diagnostics go to standard error. The documented `--quiet` and `--output` exceptions suppress or redirect normal result output.

Whichever format is selected, the answer to the user's actual question comes first. A `list` command's rows, a `show` command's fields, or a failed command's error message is the primary content. Labels, identifiers, statuses, ordering, empty-result wording, and error text stay concise and deterministic, consistent with the ordering and stability requirements in [Reporting and query commands](./reporting-and-queries).

## Human-readable hierarchy

Human output that shows a set of records as a nested parent/child hierarchy, such as a `list` command's default view, uses box-drawing tree connectors: `├─` for every sibling except the last one at that level, and `└─` for the last sibling actually rendered. Each level below the top adds another three-column indent under its parent's connector before printing the next connector. A record row keeps one stable identifier-title-marker order, `#N Title [status, supplementary metadata]` for Thread-shaped records, or the equivalent stable identifier syntax a given module already uses for its own records. Whichever record is selected as the root of a scoped view renders through the same row formatter as when that identical record appears as a descendant elsewhere, so selecting a record as root only changes whether a connector prefix is present, never the row's text or color.

The record's status, when relevant, is a plain textual `[status]` suffix, not a color or icon standing in for it; [Encoding, layout, and status color](#encoding-layout-and-status-color) below describes how color supplements this text. A parent row that also carries a computed aggregate over its own current descendants, such as a completion percentage, appends that aggregate inside the same bracket after the status, using whole numbers rather than ratios, parentheses, or decimals; a row with no current descendants keeps the shorter status-only form and never shows a synthetic `0%` aggregate. When the aggregate already conveys the same state the stored status word does, the redundant status word is omitted rather than repeated in the bracket:

```text
└─ #10 Launch checklist [active, 50% complete]
   ├─ #11 Update changelog [completed]
   └─ #12 Support runbook [active, 50% complete]
      └─ #14 Rollback drill [deferred]
```

When a command's rows are explicitly reordered by a scriptable key such as `--order activity`, sibling adjacency no longer matches parent/child structure, so those rows drop the tree connectors and use a flat `•` bullet form instead: one `•`, one space, then the row content, keeping the same `[status]` or `[status, aggregate]` bracket:

```text
• #12  Support runbook [active, 50% complete] activity: 2026-03-05T00:00:00Z
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

## Encoding, layout, and status color

Human output is UTF-8 plain text. Commands must not depend on terminal width for alignment: no fixed-width column padding that breaks when an identifier or label is longer than expected.

ANSI color is enabled by command/module rules via `--color` and `NO_COLOR`, matching the mode semantics in [Standard global flags](./global-flags): `auto` emits color only when standard output is a compatible terminal and no `NO_COLOR` value is set, `always` is an explicit override that ignores terminal detection, and `never` (or a module's `--no-color` spelling) hard-disables ANSI regardless of the terminal. Redirected human output in `auto` mode is uncolored. Structured formats such as `json`, `tsv`, and `csv` are always color- and glyph-free regardless of the color flag, and the textual `[status]` suffix and row content stay readable and deterministic even when color is disabled.

Where a command colors its rows, color applies to the whole effective row — connector, identifier, title, status, priority, and any aggregate text — rather than to an isolated character or icon standing in for the status text, and color is always supplementary to the textual state, never a replacement for it. A shared connector segment that represents more than one visible row, such as a branch prefix drawn once above several children, takes on a color only when every row it represents resolves to that same color; a branch mixing different effective colors keeps that shared segment in the connector's ordinary, uncolored form.

The standard semantic palette shared across Bus CLIs is completed green, active yellow, queued cyan, critical priority magenta, and archived muted gray/dim. A module may document further exact status colors of its own without aliasing or silently remapping one of these standard values to a different meaning.

A parent row's effective color is computed from its own current, non-archived descendants rather than from its stored status alone: a parent whose current descendants are all completed uses effective completed green for its whole row even when its stored status word is still, for example, `tracking`; otherwise a parent with any active descendant uses effective active yellow; otherwise a parent with any queued descendant uses queued cyan; further recognized descendant states fall back through the module's own documented remaining precedence; and a leaf, a parent with no current descendants, or a parent whose only descendants carry an unrecognized custom status, uses its own stored-status color. This effective-color computation never mutates the stored status metadata, and it is computed before any redundant status-marker text is elided, so removing duplicate text never changes which color a row uses.

An explicitly listed archived record, for example a `list --archived` row, renders in the muted archived style for its whole row, overriding whatever historical active, queued, completed, or priority color it would otherwise carry, while its historical status and priority text stay exactly as recorded. Archive visibility is a historical-inspection concern only: showing archived rows does not add them back into a parent's current completion aggregate, status distribution, or effective color.

Human completion aggregates use whole-number percentages, allocated with a deterministic largest-remainder rule so the displayed buckets always sum to 100, rather than ratios, parentheses, or decimal percentages. A parent with more than one current descendant status shows every non-zero status bucket, ordered as completed (labeled `complete`), active, queued, any further exact or custom status in lexical order, and a final bucket for records with no status; a bucket keeps a non-zero count visible even when its allocated share rounds to `0%`. Machine output exposes only the exact total and per-status counts, never a rounded presentation percentage, so a consumer can compute its own percentage without rounding loss. When a rendered aggregate bucket already reports the same state as the parent's stored status word — for example a `tracking` parent with any non-empty current aggregate, or a `completed` parent whose aggregate is entirely the `complete` bucket — the redundant stored-status word is omitted from the bracket rather than shown twice; a stored status that adds information the aggregate does not carry, such as `held` alongside a `complete`/`queued` split, stays visible.

Every human-output change to row color, aggregate, or archive presentation needs golden text coverage plus real PTY coverage across `--color always`, `auto` on and off a TTY, `never`, `--no-color`, `NO_COLOR`, and redirected output, and colored output must strip to byte-identical canonical uncolored text. Structured-format fixtures for the same change assert exact counts, shape, and ordering, and stay free of color codes and presentation glyphs.

## Flags, errors, and help

Long flags use their full, correctly spelled canonical form (`--format`, `--chdir`, `--dry-run`) in help text and examples; commands do not invent alternate spellings for the same flag. Conflicting flags produce an actionable error naming both flags and what to do instead, for example `--quiet and --verbose cannot be combined; drop one of them`, consistent with the exit-status-2 usage-error contract in [Standard global flags](./global-flags). Help output stays short and example-driven, closer to `git add -h` than to a prose manual, per [Command structure and discoverability](./command-structure). Empty-result behavior is deterministic per command rather than governed by one universal rule. Each command documents what its text output does when there is nothing to show; an empty text result may be intentionally silent (for example a `--quiet` scripting mode) or may state the empty condition explicitly, such as `no invoices found for period 2026-03`, but the chosen behavior must be documented and stable. Machine formats such as `json`, `tsv`, or `csv` are never silently blank: an empty result emits the format's documented empty structured value, such as `[]` for a JSON array result, and remains complete and lossless, keeping the same fields and shape a non-empty result would carry unless the command's docs describe a narrower projection for the empty case.

The tree-connector and bullet forms shown above, and basic status/priority row coloring in explicit `--color` modes, reflect installed `bus thread list` behavior today. Root/descendant color parity for a selected-root header, effective descendant-state parent color, the muted archived-row style, multi-bucket status distributions, and stored-status de-duplication against a rendered aggregate are target conventions that individual module commands, including `bus thread list` itself, may still be adopting; a single current whole-percent completion aggregate without a full status-bucket breakdown is a valid installed intermediate form. Archived-record filtering, positional shorthand for addressing one record directly (for example `bus invoices <invoice-id> show` instead of a separate lookup flag), and structured `show` output remain target conventions as well. Do not rely on any of these behaviors in a script unless the relevant `bus <module> --help` output confirms the option or behavior; consult command-level help by name only when that exact help invocation is explicitly documented as supported by the module help or reference.

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
