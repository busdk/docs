# AGENTS

## Global documentation writing rules

You are writing BusDK documentation. Prefer readable, self-contained paragraphs
that explain intent, context, and implications. Do not default to bullet lists;
use lists only when they are clearly the best structure for a tight, related
set of items. If items are mixed or unrelated, split into separate paragraphs.

Use BusDK-native wording and concrete scope terms:

- Use `repository` or `Git repository` for the concrete repo on disk.
- Use `workspace data` or `repository data` for authoritative workspace
  content.
- Use `workspace datasets` or `canonical dataset` for tabular accounting or
  business data plus schemas.
- Use `dataset`, `table`, `record`, and `row` for precise data granularity.
- Use `change history` or `revision history` for the append-only audit trail.

Avoid ambiguous terms like `corpus` and `state` unless explicitly defined.

Use direct, declarative domain statements; avoid meta-commentary about the
documentation process (for example, "this page intentionally..." or "in this
section...").

Each page must stay focused on a single clear topic. If content belongs
elsewhere, move it to the most appropriate page and link only where that helps
reader discovery without derailing the page.

Embed cross-links directly in body text where concepts are introduced. Keep
link text natural; do not add link-only phrases like "See..." to force links.
Avoid separate "See also" sections unless explicitly required.

Every documentation page should end with a `### Sources` section after the
prev/index/next navigation block. Keep it as a simple link list of relevant
internal and external references. Do not introduce new claims in Sources.

When citing authority (law, standards, guidance), link the authority directly
with descriptive anchor text in the sentence where the claim is made.

## Layout and styling contracts

The page heading contract: the layout outputs front matter `title` as the
single `<h1>` in the content area. The site header (`.busdk-site-header`)
shows the site title and links to home; it is not repeated as page h1. Each
page should use a meaningful first `##` in the body (for example, Overview or
In this section) so h1 and first h2 are complementary; do not repeat page title
as first `##`.

This repository has two documentation page layouts that must stay consistent:

- Front page: home layout without the left navigation sidebar.
- Inner pages: documentation layout with the left sidebar navigation.

Section backgrounds must span the full visible content area, while text remains
in constrained readable columns. Keep max-width constraints on
`.busdk-content-inner` and related inner wrappers, and apply backgrounds on
outer section wrappers (for example chapter and home section wrappers).

Body section headings must preserve the accent heading style. Ensure selectors
cover both chapter structures:

- headings under `.busdk-chapter-inner`
- headings under `.busdk-chapter-section-inner`

When making style changes, edit source files under `docs/docs/_sass` and
`docs/docs/_layouts`, not generated files under `_site`. Use `git diff` to
verify layout and styling changes are intentional.

## SDD rules (`docs/**/*.md`, strongest for `docs/modules`)

Treat software design documents as deterministic source-of-truth artifacts for
human verification first, then AI implementation use.

Do not invent project facts. If required facts are missing, ask targeted
questions in **bold** and record uncertainty explicitly as assumptions or open
questions.

For BusDK module SDDs in `docs/modules`, keep document control at the end of
the page, after prev/index/next navigation and after `### Sources` when
present. Include at least: title, project identifier/name, document identifier,
version, status, last updated date, and owner/maintainer.

Use status terms including at least `Draft` and `Verified`. `Verified` means
human-approved. Do not silently rewrite verified content; propose labeled
changes until explicit approval to update.

Use deterministic, consistent structure and stable IDs for requirements,
interfaces, and key decisions. Requirements must be testable and traceable to
design elements.

Unless explicitly not applicable, SDDs should keep this minimum section order:
Introduction and Overview; Requirements; System Architecture; Component Design
and Interfaces; Data Design; Assumptions and Dependencies; Glossary and
Terminology. If a section is not applicable, keep it and mark it Not Applicable
with a short rationale.

When adding/refining a new SDD, update cross-links both ways:

- include it in SDD/module indexes and module CLI references
- link related module pages and "Used by"/"Uses" relationships
- link from relevant workflow/overview pages
- embed relevant links inside the new SDD naturally

When refining an existing SDD: normalize structure, preserve meaning, surface
conflicts without silently choosing one side, and keep terminology consistent.
Use an Open Questions section only when unresolved items exist.

Do not introduce scope not present in requirements or explicit user direction.
If something appears missing, add it as a clearly labeled suggested requirement
for confirmation.

## SEO metadata rules (`**/*.md`, `**/*.html`)

When editing metadata (`title`, `description`, HTML `<title>`, and
`<meta name="description">`), derive it from what the page actually states:
purpose, intent, first-screen content, differentiators, and explicit
constraints.

Metadata must be unique per URL, accurate, non-clickbait, and aligned with H1
and on-page copy. Do not include claims unsupported by page content.

In this repo, Markdown pages set metadata via front matter `title` and
`description` (consumed by `jekyll-seo-tag`). HTML pages with custom head must
set unique title and description directly.

Prefer front-loaded specificity over filler. Typical display lengths are about
50-60 chars for titles and 155-160 chars for descriptions, but correctness and
uniqueness take priority.

Avoid generic titles, duplicate descriptions, keyword stuffing, unsupported
claims, and missing qualifiers. Reference:
`docs/seo-metadata-standard.md`.

## File-specific rules: `implementation/development-status.md`

When this docs project is part of a superproject, module source code is in
sibling directories `../bus-{NAME}`. Use those module repos (tests, `README.md`,
`PLAN.md`) as evidence for module behavior and readiness documented on this
page.

This page must start with a **Use cases index** after the opening paragraph.
Each index item must include:

1. Internal link to the section on this page.
2. Link to the canonical use-case document.
3. One-sentence journey value description.

Include an index item for **Orphan modules** linking to the orphan section.

Each use-case section must include:

1. A heading.
2. Link to the canonical document.
3. Optional short paragraph.
4. A **module readiness table** with columns:
   `Module`, `Readiness`, `Biggest next`, `Biggest blocker`.

In readiness tables, module labels omit `bus-` but link to each module's end
user doc. Readiness values must match each module page's "Use case readiness"
lines and use percentages in `0/10/20/.../100` increments plus compact journey
status.

For workflows on this page, include only workflow name plus link to the inner
workflow page and the readiness table. Do not inline workflow descriptions, e2e
details, or runtime behavior.

When this page's structure or behavior expectations change, update
`.cursor/rules/development-status.mdc` in the same change so rule and page stay
aligned.
