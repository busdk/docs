# AGENTS

Merged guidance from `.cursor/rules/*.mdc`.

## Audience Boundary

This repository subtree (`./docs`) is for end-user documentation about how to
use BusDK software. Do not use this site for commercial landing-page messaging
(belongs in `./busdk.com/docs`) or for implementation/developer SDD contracts
(belongs in `./sdd/docs`).
Do not link directly to private SDD pages from this public docs site; you may
mention that private implementation design specifications exist.
Current public docs should describe BusDK as a self-hostable platform for
developing, hosting, billing, and operating AI products. Accounting,
bookkeeping, filing, and compliance remain important documented use cases, but
they are no longer the whole product scope. Keep deployment and data-control
guidance factual and user-facing: managed Finnish cloud operation, dedicated
deployment, and customer self-hosting are deployment models; contractual data
processing terms are commercial/legal arrangements, not module behavior.
Pricing pages may show generated source-package estimates, but must not
present them as final quotes. Keep public pricing docs buyer-facing: do not
publish internal cost-pool details, ChatGPT/Cursor/human-labour assumptions, or
mechanics such as open-source dispatcher exclusion unless the user explicitly
asks to expose them.

## Publication Boundary

`./docs/docs/` is the published Jekyll source tree. Do not place `AGENTS.md`
files anywhere under `./docs/docs/`. Keep durable agent instructions in
non-published paths such as `./docs/AGENTS.md`. Treat the Jekyll `_config.yml`
exclude list as defense in depth, not as the primary reason this stays safe.
When running commands from inside this `docs` repository, published module
pages are under `docs/modules/...`; the `docs/docs/modules/...` path is only
correct when the current working directory is the superproject root.
When running `git -C docs ...` from the superproject root, pass paths relative
to the `docs` repository, such as `docs/ui/index.md`; do not pass superproject
paths or `../docs/...` paths.

## Global documentation writing rules

You are writing BusDK documentation. Prefer readable, self-contained paragraphs
that explain intent, context, and implications. Do not default to bullet lists;
use lists only when they are clearly the best structure for a tight, related
set of items. If items are mixed or unrelated, split into separate paragraphs.

For mechanical rewrites across documentation files, do not rely on recursive
`**` shell globs unless `globstar` has been enabled in the current shell. Use
`find docs/docs -name '*.md' -exec ... {} +` or an explicit file list instead.

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

For public UI framework docs, keep human-review workflow guidance out of
`docs/docs/ui/**`. The published pages may be organized from broad design
choices to lower-level references, but they should present that organization as
content structure, not as instructions to reviewers or agents. Keep guidance
such as "review these pages first" or "search links after changing a decision"
in this non-published `AGENTS.md` file only.

In public UI framework YAML examples, prefer expanded YAML mappings over inline
JSON/YAML object shorthand. For example, write `target:` with nested `base` and
`path` keys on separate lines instead of `target: { base: module, path: / }`.

## UI framework design review instructions

When reviewing or rewriting `docs/docs/ui/**`, do not treat the current pages
as fixed specifications. Treat them as editable design material for a system
that should feel simple because the parts fit together naturally.

The target design has a small `bus-gx` core with most higher-level UI built by
dogfooding smaller Bus UI pieces. `bus-gx` owns the pure low-level GX template
framework: source tools, parser, formatter, linter, render tree, safe elements,
props, templates, bindings, event identity, lifecycle, diagnostics, and core
test helpers. `bus-ui` owns the higher-level component library built on top of
`bus-gx`, such as shells, forms, input controls, tables, assistant panels,
terminal panes, evidence surfaces, and other reusable product-facing
components. Raw Go, JavaScript, or host-specific code belongs only in core
primitives, renderers, host bridges, security boundaries, and browser/runtime
integrations that cannot be expressed as Bus UI components. Every higher-level
component should be reviewed as a candidate for composition from smaller Bus UI
components before accepting it as a raw-code component.

Use this product model as the design center:

- Templates are HTML-like view documents with Bus UI tags and user-defined
  custom markup components. The preferred source format is `.gx`: a file-level
  Go package with standard Go syntax except for GX markup literals such as
  `var escapedTextTemplate = <p><Text value={greeting}></Text></p>`. Do not
  design public examples around a required top-level `<Template>` wrapper.
  Public `.gx` documentation should also mention the intended source tools:
  `bus gx fmt` / `bus gx fmt --check` for canonical formatting and
  `bus gx lint` for source-only GX diagnostics, `bus gx compile` for lowering
  `.gx` to pure `.go`, `bus gx inspect` for template inventory, and
  `bus gx validate` for template plus controller validation.
  The future `bus-gx` module owns the `bus gx` command surface and the core GX
  libraries; optional submodules such as `bus-gx-fmt` or `bus-gx-lint` may own
  implementation internals later, but do not document them as initialized
  modules until they exist.
  When documenting AI-agent workflows, prefer machine-readable diagnostic
  examples such as `--format json` and stable file/line/column output.
- Data is a separate Go value, model document, or host object and may be any
  data shape the controller can expose through Go bindings.
- Bindings are Go-first controller adapters that adapt arbitrary data to
  template/component props with minimal duplication, optional fields, defaults,
  scoped loop values, and typed helper functions. YAML and JSON bindings are
  portable fixture/import formats, not the primary runtime path.
- Runtime/controller code defines events, resources, effects, formatters, host
  resolvers, and handler registration. Prefer typed Go controllers and
  generated Go from `.gx`; keep YAML/JSON runtime files for fixtures,
  interchange, and tests unless a small fixture explicitly combines binding
  plus runtime config for testing.
- The extension path should resemble HTML: users and agents can define new
  reusable tags using the system itself, then consume those tags like built-in
  components.
- Custom tags should support event-based design. A tag may declare the events
  it emits and the events or slots it consumes. Templates attach event names to
  tags; emitted events carry interaction identity only, while
  typed controller code decides what model/form/component state to read and
  wires those events to handlers, effects, resources, navigation, or host
  callbacks.
- Public UI examples should introduce lower-level foundations before showing
  high-level components. Treat `Form`, `TextInput`, `SubmitState`, and similar
  controls as components that should be dogfooded from GX/foundation pieces
  unless there is a clear primitive or host-bridge reason they cannot be.

Apply a "click test" during review. A design does not click yet when a concept
has two owners, a page repeats another page's rules, a component requires raw
code even though it could be composed from existing blocks, a binding requires
duplicate boilerplate, a template has to know provider/runtime details, or an
event has to bypass the tag/controller contract. A design is closer when each
concept has one source of truth, each layer depends only on the layer below it,
and an author can predict where a new concern belongs.

Review UI design top-down before editing lower-level references. Start with
the design decisions, then the independent Core section, then the Library
section built from Core, then architecture/detail contracts, core concepts,
individual component pages, references, and guides. Higher-level components
such as forms belong under Library, preferably as their own focused pages.
Preserve the UI implementation roadmap order in public docs and sidebar labels:
Core starts with the smallest independent `v0.1.x` patches, and later Library
features/components should be ordered by the version where they can be
implemented from completed lower iterations. Public implementation pages should
live in patch-level directories such as `docs/docs/ui/v0.1.1/` and
`docs/docs/ui/v0.3.5/`, not only grouped minor-version directories.
When a version page initializes a submodule or command surface, state exactly
which repository/module files, packages, commands, tests, and development
targets appear in that patch, and which related parts are intentionally absent.
Keep concrete API names, command behavior, file formats, validation rules, and
examples on the first version page that implements them. Higher-level design,
architecture, design-system, rendering, and reference pages should summarize
the intent and link to those version pages instead of repeating version-specific
contracts.
Public UI framework documentation under `docs/docs/ui/` must use version-only
information architecture: the directory may contain only a minimal `index.md`
and semver patch directories named `v0.X.Y/`. Do not add public UI docs under
non-version directories such as `architecture/`, `components/`, `design/`,
`examples/`, `guides/`, `reference/`, or `roadmap/`. Every version directory
must have a compact `index.md` that only links to inner pages. Put the actual
documentation in uniquely named inner pages such as
`docs/docs/ui/v0.1.2/source-tools.md` so roadmap refactors can move pages
without splitting index content. Each patch version should be the smallest
complete implementation increment that can be reviewed and implemented in
order. Later versions may link to earlier versions; earlier versions must not
link to later versions. When a page uses a UI framework term, link the first
plain-language mention to the same-version or latest earlier-version page that
defines it.
Do not create abstract UI roadmap versions whose only purpose is to state
future design intent. Move each concept directly into the first patch version
that implements or uses it, so `bus-gx`, `bus-ui`, host, controller, and
browser-runtime concerns appear next to the actual work that needs them.
Do not combine two design concepts into one public page. Pages such as
"navigation and events", "shells and layout", or "provider and session" should
be split into one page per concept, with any group page reduced to a compact
link map.
When lower-level pages conflict with a higher-level decision, fix or question
the higher-level decision first instead of patching every dependent page
independently.

For each component, record or infer this composition review before changing the
page: purpose, smaller Bus UI primitives it can use, required raw runtime
bridge if any, props and defaults, binding/data expectations, event/resource/
effect dependencies, emitted and consumed events, render targets, safety
boundaries, and tests/examples that prove it works. If a component cannot be
built from smaller pieces, the page should make the primitive or host-bridge
reason obvious.

Keep public pages compact and non-meta. Put review process guidance here, not
inside `docs/docs/ui/**`. Public pages should show the resulting design
structure through concise content, internal links, examples, and Sources.

Each page must stay focused on a single clear topic. If content belongs
elsewhere, move it to the most appropriate page and link only where that helps
reader discovery without derailing the page.

Embed cross-links directly in body text where concepts are introduced. Keep
link text natural; do not add link-only phrases like "See..." to force links.
Avoid separate "See also" sections unless explicitly required.
For versioned UI docs under `docs/docs/ui/v*/`, link references to concepts
defined in the same version directory or an earlier version directory. Do not
link from a version page to concepts introduced by a future version; move the
future detail to the later version instead.

Non-legacy documentation pages should end with a `### Sources` section after
the prev/index/next navigation block. Keep it as a simple link list of relevant
internal and external references. Do not introduce new claims in Sources.
Legacy module design documents under `docs/modules` may put document-control
metadata after Sources as described below.

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

## Build and preview

This docs repository does not provide `make check`. Use `make quality` for the
available Makefile quality target, and use `git diff --check` for whitespace
validation on docs-only edits.

## Legacy module design-document rules (`docs/modules/**/*.md`)

Apply this section only to legacy public module pages under `docs/modules` that
already contain document-control or requirements-style design-document
structure. Do not use these rules for `docs/docs/ui/**` or for new public
end-user pages; implementation/developer SDD contracts belong in `./sdd/docs`.

For those legacy module design documents, preserve deterministic
source-of-truth structure for human verification first, then AI implementation
use.

Do not invent project facts. If required facts are missing, ask targeted
questions in **bold** and record uncertainty explicitly as assumptions or open
questions.

Public end-user module pages must describe what users and operators can do
with the module now: purpose, commands, endpoints, configuration, security
boundaries, and usage examples. Do not publish implementation meta-status such
as "being refactored", "migration debt", "temporary", "MVP", "experimental",
"not production ready", or "planned next" unless the content is explicitly a
user-facing limitation that changes how the documented command/API should be
used. Put engineering readiness and remaining work in the module `PLAN.md` or
private `sdd/docs`, not in `docs/docs`.
Public end-user pages must not mention source-code release mechanics,
implementation verification, test suites, e2e tests, quality gates, CI status,
or source-tree-only validation details. Put those in module `PLAN.md`, module
READMEs when developer-facing, or private `sdd/docs`; keep public docs focused
on user/operator behavior and deployment usage.
Avoid SDD-style module ownership rules in public pages. Phrases like "this
module must not expose...", "REST controllers belong in...", or "provider
details do not belong here" are implementation contracts and belong in
`sdd/docs`. In public docs, state the user-visible result instead: which
command/API the operator runs, which credentials or scopes are needed, and
which related module/service provides the next operational step.

For existing BusDK module design documents in `docs/modules`, keep document
control at the end of the page, after prev/index/next navigation and after
`### Sources` when present. Include at least: title, project identifier/name,
document identifier, version, status, last updated date, and owner/maintainer.

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

When adding/refining an applicable legacy module design document, update
cross-links both ways:

- include it in SDD/module indexes and module CLI references
- link related module pages and "Used by"/"Uses" relationships
- link from relevant workflow/overview pages
- embed relevant links inside the new SDD naturally

When refining an applicable existing design document: normalize structure,
preserve meaning, surface conflicts without silently choosing one side, and
keep terminology consistent. Use an Open Questions section only when unresolved
items exist.

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

## Interaction-driven updates

When using `rg` against public docs for Markdown fence patterns, avoid putting
literal triple backticks in shell command strings. Use safer structural
patterns, single-quoted `-e` arguments, or split the scan into simpler
patterns so the shell cannot treat backticks as command substitution.

When user guidance adds or changes working rules, update this `AGENTS.md` in
the same change so future runs follow the new rule without relying on memory.

For end-user documentation (all non-SDD pages under `docs/docs/`), use short,
readable paragraphs and avoid oversized blocks of text. Split long explanations
into smaller paragraphs and reduce repeated wording across a page.

For non-SDD pages, do not default to bullet lists. Use paragraph text unless a
list or table is the only meaningful way to present tightly structured data.

For non-SDD pages, move deep implementation background and exhaustive behavior
detail into module/system SDD pages under `sdd/docs/modules/`. Keep user pages
task-oriented, and when extra depth is needed, create or link focused topic
pages instead of overloading module reference pages.

Public docs navigation (`docs/docs/_data/nav.yml`) must not include a
dedicated "Software Design Documents" section that duplicates end-user module
links. Keep public navigation focused on end-user workflows and CLI usage.

When a topic serves multiple audiences, it may exist in both sites with
audience-specific refinement: keep the `./docs` version end-user focused and
the `./sdd` version implementation/developer focused. Preserve information by
refining and relocating details rather than deleting them.

For module docs that cover developer automation (`bus dev`, `bus run`, and
related `.bus` usage), include practical chained examples with concrete sample
options and include repository-local extension examples (`.bus/dev` and
`.bus/run`) where relevant.

For documentation accuracy checks, treat runnable module evidence as primary
source material: current CLI behavior from module commands, module unit tests
under `../bus-{NAME}/`, and module e2e tests under `../bus-{NAME}/tests/`,
alongside each module's `README.md` and `PLAN.md`.

For BusDK architecture or data-model refactors, keep `./docs/docs/` aligned in
the same change set as implementation and SDD updates. Public end-user docs are
not optional follow-up work; if behavior, supported datasets, or configuration
surfaces change, update the corresponding end-user docs before the work is done.

When module behavior is ambiguous or docs appear stale, prefer current CLI help,
module tests, and command implementation over `README.md`. Treat README text as
supporting context, not as the primary source of truth for end-user command
syntax or current runtime behavior.

## Gitignore Rule

1. .bus MUST be tracked; never add .bus or .bus/ to .gitignore.
2. In private repositories, .bus/ must be tracked; .bus/secrets may be tracked
   only when the tracked files contain encrypted secrets or explicitly
   approved non-secret metadata. Do not track plaintext secrets.
3. Runtime lock artifacts such as .bus-dev.lock may be ignored.

For end-user documentation pages (for example under `docs/modules`,
`docs/workflow`, and topic guides), prefer plain language and short, direct
sentences so the text is easy for humans and agents to follow. Keep strict,
contract-style wording in SDD pages (`./sdd/docs`) and requirement sections where
precision is mandatory.

For module pages under `docs/docs/modules/`, start with the user outcome first:
say what the module is for, when to use it, and what command to try first
before going into exhaustive command surface detail.

For module pages under `docs/docs/modules/`, include several copyable examples
with realistic dates, file names, IDs, and account codes. Prefer concrete
end-to-end examples over placeholder-heavy flag catalogs when the goal is user
onboarding.

For public module docs, keep the page task-oriented. Use `bus <module> --help`
as the escape hatch for exhaustive option lists instead of pasting every flag
combination into the page.

For practical engineering guides (for example performance and optimization
topics), include concrete bad-versus-better code snippets that are easy to grep
from repository code. Keep abstract framing brief and prioritize runnable
command and code examples.

Maintain `docs/docs/robots.txt` as part of docs information architecture. When
BusDK modules evolve (renames, scope changes, purpose changes) or new modules
are added, update the LLM-oriented header comments in `docs/docs/robots.txt` in
the same change set so crawler/agent guidance stays current.

Write documentation pages in English unless the user explicitly requests another
language for that page.

Keep pages strictly on one topic and avoid repeating detailed content that is
already defined on an inner topic page. Summarize only what is needed in the
current page, then link inline to the authoritative inner page and keep the
end-of-page Sources list for discovery.

For end-user module pages under `docs/docs/modules/` (each `docs/docs/modules/{name}.md`),
include a short `### Using from \`.bus\` files` section with at least one concrete
`.bus` command example that maps to the module's CLI usage.

When showing Bus command examples, prefer concrete runnable commands with real
flags and sample values. Avoid placeholder forms like `bus ...` unless omitted
arguments are intentionally the point in that exact context.

BusDK canonical datasets and schemas must be documented as workspace-root files
(the effective working directory). Do not document module-owned datasets under
module-specific subdirectories. The exception is attachment evidence files:
`attachments.csv` stays at the root and may reference files under deterministic
attachment subfolders.

When runnable evidence (tests or source) conflicts with a documented BusDK
contract, document both explicitly: keep the contract statement, and note the
current implementation mismatch with a clear migration/align action.

This docs repository does not provide `make check`. Use `make quality` for the
available Makefile quality target, and use `git diff --check` for whitespace
validation on docs-only edits.
