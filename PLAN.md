# Docs Refactor Plan

Status: completed archive. New documentation work should be opened as fresh
items in the owning module `PLAN.md`; UI implementation roadmap work now lives
in the relevant `bus-gx`, `bus-ui`, or infrastructure module plan.

Current unchecked items use paths relative to the `docs` module root unless an
item explicitly names a superproject command such as `make -C docs quality`.
Older checked entries may preserve the superproject-relative paths and commands
that were used when those entries were completed.

- [ ] UI roadmap GX/Go example audit: review `docs/docs/ui/` for remaining
  YAML/JSON examples or declarative-template wording that conflicts with the
  current GX/Go, React-like component direction. Preserve JSON only where it is
  genuinely CLI machine output, public runtime metadata, or HTTP/resource data;
  preserve YAML only where it is a test fixture or external operator config
  with a clearly documented boundary. Convert component/template examples to
  `.gx` or Go, remove obsolete legacy/declarative binding language, verify
  internal links, run `bus lint` individually on every changed Markdown file,
  run docs quality where available, and keep changes compact.

- [x] UI future roadmap feature-candidate model for busdk#80.1: keep
  implemented public UI patch directories as semver `v0.X.Y` entries through
  the current implementation cutoff, move unfinished future UI docs into
  deterministic `fc-<order>-<identifier>` directories, update the UI index and
  navigation, document candidate promotion into the next accepted semver patch,
  and verify changed Markdown/YAML docs with available lint and quality gates.

- [x] Split public Go peer review guide for busdk#44.1: refactor
  `docs/implementation/go-peer-review-guide.md` into a compact index and
  focused subpages under `docs/implementation/go-peer-review-guide/`; preserve
  current examples, bad/better snippets, LLM review finding shapes, and stable
  internal links; update implementation navigation as needed; run per-file
  `bus lint` on every changed Markdown file, YAML structural validation if
  `docs/_data/nav.yml` changes, `make quality`, and `git diff --check`. The
  host-side supervisor pass completed the per-file `bus lint` verification
  after the worker runtime blocker was recorded separately below.

- [x] UI `v0.2.x` through `v0.9.x` roadmap rescope for busdk#42.1:
  review the future public UI roadmap after the GX `v0.1.x` foundation,
  reorder common reusable `bus-ui` libraries before assistant, terminal,
  evidence, portal-host, and product-module concepts, clarify that `bus-ui`
  can host multiple libraries rather than one monolithic library, update
  `docs/ui/index.md` and `docs/_data/nav.yml`, keep internal links coherent,
  run per-file `bus lint` on changed public UI Markdown files, run YAML parse
  validation for `docs/_data/nav.yml`, run `make quality`, and run
  `git diff --check`. Verified during busdk#46.1 docs mapping: the existing
  `v0.2.x` through `v0.9.x` sequence was already promoted, the `v0.9.4`
  roadmap table was brought up to date with the full `v0.1.11` through
  `v0.1.26` sequence, and `v0.2.3` menu/tab examples were normalized to
  GX/Go callback examples instead of YAML event-name examples. Standard YAML
  parsers were absent in the worker (`ruby` missing, PyYAML unavailable, Node
  `yaml` module missing), so YAML parse validation used a temporary `/tmp`
  `yq` binary only for this run; do not treat that as a durable project check
  or vendor it.

- [x] UI `v0.1.16` browser-adapter rescope: review and narrow the current
  minimal browser adapter patch before treating it as reviewable public UI
  roadmap material. The implementation evidence for `v0.1.13` through
  `v0.1.15` indicates that `v0.1.16` is too broad as one clean patch slice.
  Decide whether it should be split into smaller `bus-gx` and `bus-ui`
  increments, record any unresolved implementation/design questions here, and
  only then update `docs/ui/v0.1.16/` with public, non-meta documentation.
  Resolved during busdk#46.1 docs mapping: keep `v0.1.16` as the minimal
  `bus-gx` browser-adapter checkpoint and split the post-GX `bus-ui` runtime
  work into `v0.1.17` through `v0.1.26`.

- [x] Docs worker lint runtime: provide a worker image or configuration where
  `bus lint` can run the configured agent runtime from docs task worktrees.
  Current `bus lint --agent codex <file>` attempts fail before content linting
  because Codex session initialization hits a read-only filesystem; `codex:local`
  also has no local OSS provider configured. During busdk#46.1,
  `bus lint --agent codex --timeout 1m <file>` was run individually for each
  changed public UI Markdown file and failed before content linting with:
  `WARNING: proceeding, even though we could not update PATH: Read-only file
  system (os error 30)`, `Failed to create session: Read-only file system (os
  error 30)`, and `Fatal error: Failed to initialize session: Read-only file
  system (os error 30)`. Keep this as infrastructure follow-up until per-file
  docs lint can run without changing public docs. Fixed by the
  `bus-integration-dev-task` App Server environment change that seeds a
  task-scoped writable `CODEX_HOME` and defaults nested lint invocations to
  `BUS_LINT_AGENT=codex` while preserving explicit operator runtime choices.
  Verification: live dev-task container `bus lint` found `/usr/local/bin/bus-lint`,
  printed `BUS_LINT_AGENT=codex`, reached the agent runtime, and returned a
  content finding instead of an authentication or read-only-session failure;
  `bus-integration-dev-task` module gates and root `make test`/`make e2e`
  passed.

- [x] UI `v0.1.12` GX event naming docs: add a small semver patch under
  `docs/docs/ui/v0.1.12/` that replaces bare intrinsic callback examples
  such as `click={...}`, `submit={...}`, `input={...}`, and `change={...}`
  with HTML/DOM-compatible Go/GX names such as `onClick`, `onSubmit`,
  `onInput`, and `onChange`. The page must state that GX has no legacy
  callback aliases and must link only to already implemented earlier patches.
  Update older public UI examples so they do not teach the removed bare names.
- [x] UI future state/runtime docs: add versioned pages that describe the
  `bus-gx` handle-scoped render scheduling prerequisite and the `bus-ui`
  React-like Go state layer (`UseState`, `UseRef`, `UseMemo`, and only
  necessary callback memoization) as separate implementation patches.
  Implemented by `docs/ui/v0.1.17/`.
- [x] UI future effects and event payload docs: add compact versioned pages for
  `bus-ui` effect cleanup semantics and `bus-gx`/`bus-ui` typed event payloads
  covering form submit, form data, submitter, dataset, input/change, keyboard,
  focus/blur, file input, drag/drop, and prevent-default behavior. Implemented
  by `docs/ui/v0.1.18/` and `docs/ui/v0.1.19/`.
- [x] UI future intrinsic/resource/streaming docs: add compact versioned pages
  for the expanded safe intrinsic table, Go/WASM-first resource and session
  adapters, multipart upload, redirects, provider errors, fetch streaming
  browser adapters, abort signals, terminal UI integration, and portal host
  context consumption. The docs must distinguish the `bus-ui` module from the
  reusable GX framework/runtime packages inside it: `bus-ui` may host separate
  higher-level libraries such as terminal UI, while the minimal framework
  should only own framework/runtime integration. Keep JavaScript documented
  only as a narrow browser API boundary. Implemented by `docs/ui/v0.1.20/`
  through `docs/ui/v0.1.26/`, with `docs/ui/v0.1.14/` and
  `docs/ui/v0.1.16/` retained as the earlier `bus-gx` safe-intrinsic and
  browser-adapter prerequisites.

- [x] UI version-only documentation IA: ensure `docs/docs/ui/` contains only
  `index.md` plus semver patch directories named `v0.X.Y/`; move every current
  non-version page from `architecture/`, `components/`, `design/`,
  `examples/`, `guides/`, `reference/`, and `roadmap/` into the first patch
  version that owns the concept; delete empty non-version directories; update
  navigation and internal links.

- [x] UI root index cleanup: keep `docs/docs/ui/index.md` as a minimal
  roadmap/link map to patch versions only, without architecture/reference
  content that should live in a version page.

- [x] UI `v0.1.0` retirement: remove the abstract design-foundation patch and
  relocate its concepts to the first concrete implementation patch that uses
  each concept, so the public roadmap starts with `v0.1.1`.

- [x] UI `v0.1.1` core node foundation: keep `Node`, shared interfaces,
  `VNode`, `Text`, `Element`, `Fragment`, `Props`, and render-tree API docs
  together; move any remaining node/render-tree architecture material here;
  make `index.md` a link-only page.

- [x] UI `v0.1.2` GX source tools: split source shape, `bus gx fmt`,
  `bus gx lint`, source diagnostics, and acceptance checks into focused pages;
  remove references to discarded template wrappers and setup mechanics; make
  `index.md` a link-only page.

- [x] UI `v0.1.3` GX compiler: keep generated Go output, compile/static render
  behavior, declarative renderer, and template compile checks here; make
  `index.md` a link-only page.

- [x] UI `v0.1.4` custom components: keep reusable component tags, props,
  children, slots, lowercase element adapters, component concept, and template
  composition docs here; make `index.md` a link-only page.

- [x] UI `v0.1.5` Go bindings: keep binding concept, typed binding helpers,
  fixture binding formats, defaults, and missing-binding validation here; make
  `index.md` a link-only page.

- [x] UI `v0.1.6` Go controllers and events: keep event identity, trigger
  attributes, controller handler registration, runtime contract basics, and
  form submit event flow here; make `index.md` a link-only page.

- [x] UI `v0.1.7` lifecycle: keep effect/disposer/lifecycle cleanup material
  here; make `index.md` a link-only page.

- [x] UI `v0.1.8` diagnostics: keep client logging, runtime errors,
  close-guard diagnostics, and browser API diagnostic boundaries here; make
  `index.md` a link-only page.

- [x] UI `v0.1.9` browser safety blocks: split browser API boundaries,
  close guard, error host, and raw HTML into their own patch between
  diagnostics and test helpers.

- [x] UI `v0.1.10` core test helpers: keep core test helper, renderer test,
  GX validation test, and compact testing workflow material here; make
  `index.md` a link-only page.

- [x] UI `v0.2.0` library design baseline: move product character, content
  style, accessibility/safety, design-system overview, and visual design
  foundations here; make `index.md` a link-only page.

- [x] UI `v0.2.1` shells: keep shell concept and shell components here; make
  `index.md` a link-only page.

- [x] UI `v0.2.2` layouts: keep layout contract, sidebar navigation, and split
  layout here; make `index.md` a link-only page.

- [x] UI `v0.2.3` surfaces: keep panel, surface card, metric card, layout
  surface rules, density, and typography material here; make `index.md` a
  link-only page.

- [x] UI `v0.2.4` navigation: keep link button, menu, tabs, and navigation
  component rules here; make `index.md` a link-only page.

- [x] UI `v0.2.5` event controls: keep button, icon button, event bar, and
  controls guidance here; make `index.md` a link-only page.

- [x] UI `v0.2.6` icons: keep icon component and icon usage guidance here;
  make `index.md` a link-only page.

- [x] UI `v0.3.1` forms: keep form component and form-submission flow here;
  make `index.md` a link-only page.

- [x] UI `v0.3.2` form fields: keep field and filter toolbar material here;
  make `index.md` a link-only page.

- [x] UI `v0.3.3` input controls: keep input, text input, password input,
  date input, text area, and select material here; make `index.md` a link-only
  page.

- [x] UI `v0.3.3` input controls GX example correction: replace YAML
  component markup and string event-name language in the input controls,
  input, text input, password input, date input, text area, and select pages
  with `.gx`/Go examples, DOM-compatible `onInput`/`onChange` callback
  language, checked input helper language, and no v0.3.3 file input/upload
  behavior. Verification: `make quality` and `git diff --check` passed.
  Per-file `bus lint` was run for each changed Markdown file, but content
  linting could not complete because the `codex` runtime failed session
  creation on the read-only filesystem; a writable-home retry reached the API
  and failed with missing authentication, and `codex:local` had no local
  provider configured.

- [x] Audit public UI version docs for YAML/JSON component markup: scan
  superproject-relative `docs/docs/ui/v*/` (`docs/ui/v*/` inside this module)
  for YAML or JSON examples that describe rendered
  components/templates, replace those examples with `.gx` or Go, and keep
  YAML/JSON only on pages that specifically document data or configuration
  formats.

- [x] UI `v0.3.4` submit state: keep submit state material here; make
  `index.md` a link-only page.

- [x] UI `v0.3.5` tables: keep table and dense data material here; move list,
  timeline, and status material to later patches; make `index.md` a link-only
  page.

- [x] UI `v0.3.6` lists: create a list patch for collection/list records and
  summary items; make `index.md` a link-only page.

- [x] UI `v0.3.7` timelines: create a timeline patch for ordered event history
  components; make `index.md` a link-only page.

- [x] UI `v0.3.8` status surfaces: create a status-surface patch for status
  pill, empty, loading, result, and error banner components plus color/status
  rules; make `index.md` a link-only page.

- [x] UI `v0.4.1` resources: keep resource concept and host resource behavior
  here; make `index.md` a link-only page.

- [x] UI `v0.4.2` runtime config and API URLs: create a runtime host patch for
  runtime config, API URL resolver, portal host contract, and renderer targets;
  make `index.md` a link-only page.

- [x] UI `v0.4.3` sessions: create a session patch for safe browser session
  views; make `index.md` a link-only page.

- [x] UI `v0.4.4` credentials: create a credentials patch for credential login
  surfaces; make `index.md` a link-only page.

- [x] UI `v0.4.5` provider errors: create a provider-error patch for provider
  failure projection; make `index.md` a link-only page.

- [x] UI `v0.4.6` assets and host tools: create a small patch for CSS bundle,
  CLI runtime flags, browser open, and host-adjacent tooling docs; make
  `index.md` a link-only page.

- [x] UI `v0.5.1` assistant workbench shell: keep only assistant workbench and
  assistant panel material here; move unrelated assistant details to later
  patches; make `index.md` a link-only page.

- [x] UI `v0.5.2` assistant threads and messages: create a focused patch for
  assistant threads, thread list, messages, and safe Markdown; make `index.md`
  a link-only page.

- [x] UI `v0.5.3` assistant composer and attachments: create a focused patch
  for composer, attachments, and assistant drop controller; make `index.md` a
  link-only page.

- [x] UI `v0.5.4` assistant model selection: create a focused patch for model
  select/picker behavior; make `index.md` a link-only page.

- [x] UI `v0.5.5` assistant review controls: create a focused patch for
  approvals, review status, and work isolation; make `index.md` a link-only
  page.

- [x] UI `v0.6.1` terminal sessions: create a focused patch for terminal
  session and panel surfaces; make `index.md` a link-only page.

- [x] UI `v0.6.2` terminal IO: create a focused patch for terminal output and
  input controls; make `index.md` a link-only page.

- [x] UI `v0.6.3` terminal approvals: create a focused patch for terminal
  approval prompts; make `index.md` a link-only page.

- [x] UI `v0.6.4` terminal adapter: create a focused patch for the
  event-to-terminal adapter; make `index.md` a link-only page.

- [x] UI `v0.7.1` evidence URLs and links: create a focused patch for evidence
  URL resolver and evidence links; make `index.md` a link-only page.

- [x] UI `v0.7.2` evidence previews: create a focused patch for evidence
  preview behavior; make `index.md` a link-only page.

- [x] UI `v0.7.3` projection details: create a focused patch for projection
  detail surfaces; make `index.md` a link-only page.

- [x] UI `v0.8.1` file drops: create a focused patch for drop zone/file drop
  surfaces; make `index.md` a link-only page.

- [x] UI `v0.8.2` image galleries: create a focused patch for image gallery
  surfaces; make `index.md` a link-only page.

- [x] UI `v0.9.1` component catalog: keep the component map and component
  reference here as compact retrospective maps that link only to previous
  versions; make `index.md` a link-only page.

- [x] UI `v0.9.2` declarative artifacts: keep the cross-version declarative
  artifact map here after the component catalog; make `index.md` a link-only
  page.

- [x] UI `v0.9.3` product module integration: keep product module shape and
  portal module integration here; make `index.md` a link-only page.

- [x] UI `v0.9.4` examples, testing, and release review: keep examples,
  testing guide, reference checklist, and the retrospective roadmap here; make
  `index.md` a link-only page.

- [x] UI local link and quality verification: after the version-only refactor,
  verify internal links, verify no `docs/docs/ui` Markdown files remain outside
  `index.md` and `v0.X.Y/`, verify no version page links to a future version,
  run `make -C docs quality`, `git -C docs diff --check`, and root
  `git diff --check`. `bus lint` remains blocked in this sandbox by restricted
  Codex runtime/network access unless permissions are granted.

- [x] Reorganize UI framework docs by document type: move loose topic pages under `docs/docs/ui/` into typed subdirectories such as architecture, guides, reference, and examples while preserving the `/ui/` landing page; update navigation, prev/index/next links, and cross-page Markdown links; verify no stale UI links remain; run docs `make quality` and `git diff --check`.

- [x] UI lint batch 01: run `bus lint` for `docs/docs/ui/architecture.md`, `component-catalog.md`, `component-reference.md`, `components.md`, `components/action-bar.md`, `components/action.md`, `components/ai-approvals.md`, and `components/ai-attachment-list.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 02: run `bus lint` for `docs/docs/ui/components/ai-composer.md`, `ai-drop-controller.md`, `ai-markdown.md`, `ai-message.md`, `ai-model-select.md`, `ai-panel.md`, `ai-review-status.md`, and `ai-thread-isolation.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 03: run `bus lint` for `docs/docs/ui/components/ai-thread-list.md`, `apiurl-resolver.md`, `app-shell.md`, `assistant-shell.md`, `browser-open.md`, `button.md`, `cli-runtime-flags.md`, and `client-log.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 04: run `bus lint` for `docs/docs/ui/components/close-guard.md`, `component.md`, `credential-login-card.md`, `css-bundle.md`, `data-table.md`, `date-input.md`, `declarative-renderer.md`, and `disposer.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 05: run `bus lint` for `docs/docs/ui/components/drop-zone.md`, `effect.md`, `element.md`, `empty-state.md`, `error-banner.md`, `error-host.md`, `evidence-link.md`, and `evidence-preview.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 06: run `bus lint` for `docs/docs/ui/components/evidence-url-resolver.md`, `field.md`, `filter-toolbar.md`, `form.md`, `fragment.md`, `icon-button.md`, `icon.md`, and `image-gallery.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 07: run `bus lint` for `docs/docs/ui/components/input.md`, `link-button.md`, `loading-state.md`, `menu.md`, `metric-card.md`, `panel.md`, `password-input.md`, and `portal-shell.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 08: run `bus lint` for `docs/docs/ui/components/projection-detail.md`, `props.md`, `provider-error.md`, `raw-html.md`, `record-list.md`, `resource.md`, `result-panel.md`, and `runtime-config.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 09: run `bus lint` for `docs/docs/ui/components/select.md`, `session.md`, `sidebar-nav.md`, `sidebar-shell.md`, `split-layout.md`, `status-pill.md`, `submit-state.md`, and `summary-item.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 10: run `bus lint` for `docs/docs/ui/components/surface-card.md`, `tabs.md`, `template.md`, `terminal-approval-prompt.md`, `terminal-input-box.md`, `terminal-output-view.md`, `terminal-session-adapter.md`, and `terminal-session-panel.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 11: run `bus lint` for `docs/docs/ui/components/text-area.md`, `text-input.md`, `text-table.md`, `text.md`, `timeline.md`, `v-node.md`, `concepts/action.md`, and `concepts/collection.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 12: run `bus lint` for `docs/docs/ui/concepts/component.md`, `concepts/effect.md`, `concepts/node.md`, `concepts/resource.md`, `concepts/shell.md`, `concepts/state.md`, `declarative-documents.md`, and `design-system.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] UI lint batch 13: run `bus lint` for `docs/docs/ui/examples.md`, `index.md`, `portal-modules.md`, `reference.md`, `rendering.md`, and `testing.md`; fix every actionable finding in those files; rerun this exact batch until clean; verify docs `make quality` and `git diff --check`.

- [x] Update the public `bus-dev` module reference for active-versus-terminal development task status reporting: include `status` in the `bus dev work` and `bus dev task` controller command lists, explain that `bus dev work status`/`bus dev task status` separates active queued/claimed/running work from historical done/failed/blocked/canceled ledger counts, mention that JSON includes explicit `active` and `terminal` totals, keep the wording end-user/operator focused, verify with `make quality` and `git diff --check`, and close this item.

- [x] Update public `bus-integration-dev-task` docs for isolated task worktrees: document workspace-recipient mapping, read-only workspace dependency mounts, writable recipient task worktrees, `.gitmodules` dependency links, and the updated placeholder/help surface; verify with `bus lint`.

- [x] Refresh compose-backed local AI platform module docs end to end: review every Bus module invoked by the root `compose.yaml` local AI platform stack, align `docs/modules/bus-*.md` with the currently implemented command flags, environment variables, JWT scopes, PostgreSQL/event backends, container/Docker/Codex routing, and portal/API endpoints; preserve existing in-progress edits; run `bus lint` on the changed docs pages; and verify the docs change set.

- [x] Lint and refine the public UpCloud, billing, Stripe, usage, VM, container, event, auth, and operator module docs end to end with `bus lint`; fix actionable end-user documentation findings; add a public UpCloud + Stripe setup tutorial under `docs/docs/integration`; link it from docs navigation and related pages; and verify docs quality.

- [x] Refine public billing, LLM hosting, container, usage, and portal module docs end to end: document what end users and operators need to know about account setup, billing setup, Stripe-backed payments, catalogs, quotas, LLM access, container access, usage metering, terminal/portal access, scopes, storage, and safe deployment; remove SDD-style ownership/meta-status language from those public pages; keep remaining engineering work in module `PLAN.md` or private SDD pages; verify docs quality.

- [x] Restructure public API provider docs into short semantic sections: document each endpoint and each documented command-line option under its own meaningful subheading; avoid endpoint lists followed by long paragraphs; keep repeated JWT/account/billing rules in shared short sections; verify readability and docs quality.

- [x] Remove remaining SDD-style module ownership constraints from public module docs: rewrite visible module descriptions and overview paragraphs that say internals "must not", "do not belong here", or are "planned" into end-user/operator descriptions of available APIs, commands, configuration, and deployment boundaries; preserve architectural constraints in matching `sdd/docs/modules/*` pages; verify docs quality.

- [x] Remove module-development meta status from public portal docs end to end: rewrite `docs/modules/bus-portal.md`, `docs/modules/bus-portal-auth.md`, `docs/modules/bus-portal-ai.md`, and `docs/modules/bus-portal-accounting.md` as end-user/operator module references that explain purpose, usage, configuration, and security boundaries without refactor/migration/PLAN-style readiness language; preserve implementation status in module `PLAN.md` or private SDD only; update docs guidance to prevent recurrence; and verify docs quality.

- [x] Refine public source-package pricing docs so the rendered page and generated docs data do not expose internal cost-pool details, ChatGPT/Cursor/human-labour assumptions, or `bus` exclusion mechanics; keep only buyer-facing generated estimates, quote caveats, module rows, timestamp, and sources; verify docs quality.
- [x] Refresh source-package pricing docs so generated prices are current estimates from the pricing data generator, explain the date-based human-labour and fixed operating-cost assumptions, remove unsupported discount/package claims, update the purchasing FAQ, and verify docs quality.
- [x] Refresh the public docs direction for the current BusDK platform: describe BusDK as a self-hostable AI product platform with CLI, API providers, events, portals, VM/container runtime, billing/operator tooling, and auditable business-data modules; add end-user deployment/data-control guidance; keep the tone documentation-focused rather than commercial landing copy; verify the docs site after editing.
- [x] Add public end-user documentation for the new `bus-work` skeleton: document the planned generic `bus work` durable work-stream UX, recipient syntax, fan-out behavior, ids/refs, worker loop, config/auth boundary, and relationship to `bus run` and `bus dev`.
- [x] Document the planned `bus dev task` delegated development workflow for end users in the public `bus-dev` module reference: keep the page clear that the feature is planned, describe the short task CLI, recipient syntax, current-repository default, multi-recipient fan-out, task/work ids, files/attachments, auth/host behavior, and generic worker model without exposing private implementation contracts.
- [x] Enforce no-information-loss migration rule for this plan: when implementation-heavy content moves from `docs/docs` to `sdd/docs`, preserve the full technical content in SDD pages and leave concise end-user-facing summaries or pointers in public docs instead of deleting substance.
- [x] Allow dual-page audience refinement for the same topic where useful: keep/refine `docs/docs/*` for end users and keep/refine corresponding `sdd/docs/*` for implementers/developers, with information preserved across the pair.
- [x] Move developer-maintainer workflow documentation out of public docs: migrate `docs/docs/implementation/developer-module-workflow.md` to `sdd/docs/implementation/` and replace the public page with a short end-user-facing note (or remove from public IA) so `docs` does not describe module implementation runtime coverage/e2e status.
- [x] Move BFL formula-integration implementation contract out of end-user module docs: migrate implementation-specific sections from `docs/docs/modules/bus-bfl-workbook-formula-delegation.md` into `sdd/docs/modules/bus-bfl.md` (or `sdd/docs/implementation/`), then rewrite the public page as a concise operator guide focused on user-visible flags and outcomes only.
- [x] Remove implementation-readiness tracking from public CLI design docs: move the `Development state` contract in `docs/docs/cli/command-structure.md` (completeness/planned-next/blockers/e2e status) into `sdd/docs/cli/` and keep public CLI docs behavior-focused for end users.
- [x] Remove private-SDD dependency from public docs body content: replace `Module SDD` / `bus-*-SDD` references across `docs/docs/**/*.md` with end-user docs links or neutral wording so public docs remain self-contained after SDD privatization.
- [x] Remove public references to private SDD index from overview/FAQ/module index pages (`docs/docs/overview/index.md`, `docs/docs/faq/index.md`, `docs/docs/modules/index.md`) and keep only end-user navigation paths.
- [x] Remove redundant public SDD navigation duplication: delete the `Software Design Documents` section from `docs/docs/_data/nav.yml` so the public sidebar keeps only end-user CLI/module navigation.
- [x] Re-verify public audience-boundary policy after nav cleanup: ensure `docs/docs/` has no direct private-SDD links and retains only neutral mentions of private implementation specs.
