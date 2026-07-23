# UI Framework Design Review Runbook

Read this before reviewing, rewriting, or restructuring the public UI
framework documentation under `docs/docs/ui/**`, before promoting a UI
feature candidate, or before changing UI docs page structure, versioning, or
sidebar ordering. It expands the UI framework design review trigger in this
repository's root `AGENTS.md`.

When reviewing or rewriting `docs/docs/ui/**`, do not treat the current pages
as fixed specifications. Treat them as editable design material for a system
that should feel simple because the parts fit together naturally.

The target design has a small `bus-gx` core with most higher-level UI built by
dogfooding smaller Bus UI pieces. `bus-gx` owns the pure low-level GX template
framework: source tools, parser, formatter, linter, render tree, safe
elements, props, templates, component body markup, expression children,
callback props, lifecycle, diagnostics, and core test helpers. `bus-ui` owns the
higher-level component library built on top of `bus-gx`, such as shells, forms,
input controls, tables, assistant panels, terminal panes, evidence surfaces,
and other reusable product-facing components. Raw Go, JavaScript, or
host-specific code belongs only in core
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
  `bus gx validate` for template plus callback/runtime validation. Document generated
  output paths as normal `.go` files, such as `view.go`, not `_gx.go` files.
  Public end-user command examples must use the dispatcher form `bus gx ...`
  instead of invoking `bus-gx ...` directly. It is fine to mention the
  `bus-gx` module or binary when describing implementation details, local
  module builds, or test aliases, but copyable user commands should go through
  `bus`.
  The future `bus-gx` module owns the `bus gx` command surface and the core GX
  libraries; optional submodules such as `bus-gx-fmt` or `bus-gx-lint` may own
  implementation internals later, but do not document them as initialized
  modules until they exist.
  When documenting AI-agent workflows, prefer machine-readable diagnostic
  examples such as `--format json` and stable file/line/column output.
  Do not mention discarded template shapes such as a top-level `<Template>`
  wrapper in public UI docs unless a current patch explicitly implements that
  shape. Do not teach superproject checkout, Git submodule, or installation
  mechanics inside UI patch pages; keep patch pages focused on what the patch
  implements and what public result authors can observe.
- Data reaches GX through ordinary Go values in lexical scope, function
  arguments, and typed component props. Do not introduce a separate `gx.Bindings`
  map, selector grammar, YAML binding document, or JSON binding document unless
  a later concrete runtime owner needs it.
- Runtime code should stay Go-first and small. The first browser runtime mounts
  a Go function component, wires callback props to browser events, schedules
  rerenders, and reports framework errors through Go callbacks. Do not
  introduce YAML/JSON runtime files, effect registries, logging components,
  or shared controller implementations unless a later concrete runtime feature
  owns them.
- The extension path should resemble HTML: users and agents can define new
  reusable tags using the system itself, then consume those tags like built-in
  components.
- GX compile examples should preserve the surrounding Go shape. A `var`
  initialized with markup lowers to a `var` initialized with a `gx.Node`
  expression; markup inside a function lowers inside that function. Do not show
  generated constructor functions unless the `.gx` source itself declares a
  function.
- Do not document `bus gx render` as part of `v0.1.3`. The first compiler
  patch only lowers `.gx` to `.go`. A later HTML render command should compile
  through generated Go and execute a trusted temporary Go harness in a
  subprocess.
- GX reusable components should be ordinary typed Go function components, not a
  custom GX declaration syntax. Document uppercase tags as calls to Go
  functions or method values with typed props structs, similar to React
  function components but compiled through Go. The first component model should
  accept `func(P) gx.Node` only; do not add `(gx.Node, error)` component
  returns unless a later explicit patch defines how errors flow through every
  markup expression context. Do not introduce a component registry for
  uppercase tags; authors make components available through ordinary Go package
  scope and imports.
- Lowercase GX tags are safe HTML-compatible elements. Do not document
  replacing lowercase standard element names or adding lowercase element
  adapter registries unless the design is explicitly reopened later; prefer
  uppercase function components for reusable behavior.
- Custom tags should support React-style Go callback props. A tag may expose
  callback fields such as `Click func()` or `Submit func()` in its props
  struct. Future examples should use HTML/DOM-compatible Go/GX event names
  such as `onClick={saveDraft}` and `onSubmit={saveDraft}` rather than bare
  event nouns. Do not document string event names such as
  `click="save-draft"` or a shared `gx.Controller` implementation for the core
  callback patch.
- Lowercase GX element tags also need typed callback properties so native
  elements such as `<button onClick={saveDraft}>` can carry function values in
  the node tree before the browser runtime exists. Document this as an
  intrinsic element property table owned by `bus-gx`, similar to TSX intrinsic
  element typing. The callback patch stores and validates these functions; the
  later browser runtime wires supported properties such as `onClick`,
  `onSubmit`, `onInput`, and `onChange` to DOM events. The first interactive
  intrinsic table should be deliberately small but must be usable: `button`,
  `form`, `input`, and `label` are enough for button clicks and basic form
  input callbacks.
- Do not keep `bus gx render` in the v0.1.x roadmap unless the user explicitly
  reopens that feature. The first v0.1.x completion target is a working Go
  WebAssembly frontend that compiles `.gx` to `.go` and mounts pure Go
  component functions in the browser.
- Public UI examples should introduce lower-level foundations before showing
  high-level components. Treat `Form`, `TextInput`, `SubmitState`, and similar
  controls as components that should be dogfooded from GX/foundation pieces
  unless there is a clear primitive or host-bridge reason they cannot be.

Apply a "click test" during review. A design does not click yet when a concept
has two owners, a page repeats another page's rules, a component requires raw
code even though it could be composed from existing blocks, a data path
requires duplicate boilerplate, a template has to know provider/runtime
details, or callback behavior has two owners. A design is closer when each
concept has one source of truth, each layer depends only on the layer below it,
and an author can predict where a new concern belongs.

Review UI design top-down before editing lower-level references. Start with
the design decisions, then the independent Core section, then the Library
section built from Core, then architecture/detail contracts, core concepts,
individual component pages, references, and guides. Higher-level components
such as forms belong under Library, preferably as their own focused pages.
Preserve the implemented UI patch order in public docs and sidebar labels:
Core starts with the smallest independent `v0.1.x` patches, and implemented
Library features/components are ordered by the version where they were
implemented from completed lower iterations. Public pages for implemented
patches live in patch-level semver directories such as
`docs/docs/ui/v0.1.1/` and `docs/docs/ui/v0.3.5/`, not only grouped
minor-version directories. Unfinished future patch docs live outside the
semver sequence in feature-candidate directories named
`docs/docs/ui/fc-<id>-<identifier>/`, where `<id>` is a deterministic
zero-padded candidate identifier such as `fc-001-runtime-state`. The candidate
identifier is for stable links and review grouping only; it is not a required
implementation order. Process multiple feature candidates in parallel when
their real prerequisites and write scopes are independent.
In the left sidebar, keep UI version subpages collapsed except for the
currently open `v0.X.Y` version section so the roadmap remains scannable.
When a version page initializes a submodule or command surface, state exactly
which repository/module files, packages, commands, tests, and development
targets appear in that patch, and which related parts are intentionally absent.
Default DoD for promoting any UI feature candidate to an implemented patch
under `docs/docs/ui/v*/`:
the implementation for that patch is complete, unit tests are complete for the
implemented public contract, public UI docs for that version are updated when
implementation or testing changes the original spec or needs clarification,
the owning module SDD such as `sdd/docs/modules/bus-gx.md` is complete through
that version, and the end-user module page such as
`docs/docs/modules/bus-gx.md` matches the actual implementation with the
current implemented version clearly visible. When a feature candidate is
finished, implemented, reviewed, accepted, and no ordering or versioning blocker
remains, promote it to the next actual semver patch number and rename it from
`docs/docs/ui/fc-<order>-<identifier>/` to `docs/docs/ui/v0.X.Y/`. If promotion
is not yet possible, record the concrete blocker in the owning module `PLAN.md`
or docs plan rather than leaving the completed candidate status ambiguous.
Keep concrete API names, command behavior, file formats, validation rules, and
examples on the first version page that implements them. Higher-level design,
architecture, design-system, rendering, and reference pages should summarize
the intent and link to those version pages instead of repeating version-specific
contracts.
Public UI framework documentation under `docs/docs/ui/` must use implemented
versions plus feature candidates: the directory may contain a minimal
`index.md`, implemented semver patch directories named `v0.X.Y/`, and
unfinished future candidate directories named `fc-<order>-<identifier>/`. Do
not add public UI docs under non-version/non-candidate directories such as
`architecture/`, `components/`, `design/`, `examples/`, `guides/`,
`reference/`, or `roadmap/`. Every version and feature-candidate directory
must have a compact `index.md` that only links to inner pages. Put the actual
documentation in uniquely named inner pages such as
`docs/docs/ui/v0.1.2/source-tools.md` or
`docs/docs/ui/fc-001-runtime-state/state-runtime.md` so roadmap refactors can
move pages without splitting index content. Each implemented patch version
should be the smallest complete implementation increment accepted into the
main sequence. Each feature candidate should be independently reviewable and
may be implemented when its prerequisites exist; unrelated candidates do not
need to form one strict future sequence. Later implemented versions and
feature candidates may link to implemented prerequisites or earlier candidates
they depend on; implemented pages must not link forward to feature candidates.
When a page uses a UI framework term, link the first plain-language mention to
the same-version, same-candidate, or latest earlier implemented page that
defines it.
Do not create abstract UI roadmap versions whose only purpose is to state
future design intent. Put unfinished future design material in feature
candidates, and promote it into the first semver patch version that implements
or uses it, so `bus-gx`, `bus-ui`, host, callback, and browser-runtime
concerns appear next to the actual work that needs them.
Do not combine two design concepts into one public page. Pages such as
"navigation and events", "shells and layout", or "provider and session" should
be split into one page per concept, with any group page reduced to a compact
link map.
When lower-level pages conflict with a higher-level decision, fix or question
the higher-level decision first instead of patching every dependent page
independently.

For each component, record or infer this composition review before changing the
page: purpose, smaller Bus UI primitives it can use, required raw runtime
bridge if any, props and defaults, data expectations, event/resource/
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

When implementation or review of a current UI patch finds a defect, missing
test, missing documentation, or incomplete behavior from an earlier patch, it
may be fixed in the current patch. Document the correction in the current
version's scope and acceptance evidence, keep older version pages historically
coherent, and avoid pretending the correction was already complete in the older
patch unless that older page is being deliberately clarified rather than
rewritten.

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
