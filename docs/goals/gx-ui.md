# GX/UI Node-First Refactor Handoff

## Goal

This goal tracks the GX/UI architecture refactor that moves BusDK frontend
code away from string-first UI composition and toward typed Go/GX render
trees.

The target architecture is:

> `bus-gx` owns the source syntax, compiler, render tree, safe HTML rendering,
> browser/runtime primitives, and low-level tests. `bus-ui` owns reusable
> component families, public UI facades, CSS hooks,
> mount/runtime helpers, portal integration surfaces, and UI test harnesses.
> Product modules compose typed `gx.Node` trees through public facade packages
> and serialize only at explicit render edges.

The preferred public component APIs are simple names such as `ui.Name`,
`assistantui.Name`, `terminalui.Name`, and `uiportal.Name`. They should return
`gx.Node` or typed values that carry `gx.Node` fields. String serialization
belongs at explicit boundaries such as `ui.RenderHTML(...)` or
`gx.RenderHTML(...)`.

This handoff exists so another conversation can continue the refactor without
reconstructing the June 2026 remote supervisor memos, Codex threads, and
worktree state from scratch.

## Why This Matters

The original UI-library work mixed several architectural eras:

- low-level GX source and render-tree work in `bus-gx`;
- reusable but string-first helpers in `bus-ui/pkg/uikit`;
- package facades that often exposed `Checked` or `NodeChecked` helper names;
- product modules that inserted pre-rendered strings through `BodyHTML`,
  `HeadHTML`, `MainHTML`, slot replacement, `strings.Replace`, or
  post-render insertion;
- docs and website pages that taught old compatibility helpers as if they
  were the current API.

That made the UI stack harder to reason about. A component could appear to be
node-first while internally rendering string HTML and parsing or wrapping it
back into a node-shaped value. Product modules also had to understand too much
about shell internals, raw HTML slots, runtime script insertion, and uikit
compatibility surfaces.

The refactor goal is a decoupled architecture:

- `bus-gx` provides typed, safe primitives.
- `bus-ui` provides public reusable UI components and runtime facades.
- product modules use public UI facades, not `pkg/uikit` internals.
- HTML strings are produced only at explicit render boundaries.
- `pkg/uikit` is removed as a product/backing implementation layer; behavior
  moves into public node-first packages or deliberate non-compatibility
  internal packages.
- string boundaries remain only where intentionally part of the new design,
  such as clearly named `...HTML` helpers.

## Definition Of Done

The active/default product and documentation paths should not use these as the
normal architecture:

- `pkg/uikit` imports in product/adopter modules;
- `*Checked` or `*NodeChecked` as preferred public/default APIs;
- string-returning component APIs where a node-first facade should exist;
- `BodyHTML`, `HeadHTML`, or `MainHTML` as normal shell slots;
- broad raw HTML helpers such as `ui.Unsafe`, `ui.VRaw`, or direct downstream
  `gx.TrustedMarkdownHTML` use;
- parser bridges that convert rendered component HTML back into nodes;
- slot replacement, `strings.Replace`, or post-render insertion for normal
  composition;
- public docs that teach compatibility helpers as the primary API.

Compatibility code should not remain merely for unpublished/internal-only
backward compatibility. `pkg/uikit`, `*Checked` compatibility wrappers, and old
string-first aliases are deletion targets unless a specific behavior is moved
into the new public architecture or a deliberate internal implementation
package with a non-compatibility purpose.

Use a throwaway deletion/build-exclusion probe as the authoritative compiler
sequencing gate before treating the goal as nearly complete: remove or build-exclude
`bus-ui/pkg/uikit` and `bus-ui/pkg/uikit/uikittest`, run `go test ./...` in
`bus-ui`, then run `go test ./...` across every `go.mod` user of
`github.com/busdk/bus-ui` or `github.com/busdk/bus-gx`. Convert compiler
failures into tasks split by owner: core `bus-ui` implementation still backed
by `uikit`, adopter imports/usages, test harness replacement, docs/examples or
catalog residue, and genuinely deferred/out-of-scope items. Do not promote the
deletion probe until all required replacement tasks are accepted and the full
dependency-user matrix passes. Use the full static/module inventory, not the
next deletion-probe compiler failure alone, as the scope and ETA denominator.

### 2026-06-16 Full-Surface Inventory Rebaseline

This section is the canonical quota-aware remaining-work inventory from the
BusDK primary checkout after `bus-ui` `424029e`, docs `d8f500f`, and BusDK
`da680bc`. The deletion/build-exclusion probe now sequences the next compiler
blocker; it is not the whole backlog or ETA denominator.

Inventory method:

- preferred low-token refresh: from the BusDK root, run
  `python3 scripts/gx-ui-inventory-audit.py` for compact counts or add
  `--show-files` for bounded file lists;
- module denominator: `rg -n "github\.com/busdk/bus-gx|github\.com/busdk/bus-ui" projects/busdk -g go.mod`;
- refined production audit: `rg -l '"github\.com/busdk/bus-ui/pkg/uikit"|\buikit\.[A-Z_]' projects/busdk --glob '*.go' --glob '!**/*_test.go' --glob '!**/.bus/**' --glob '!**/vendor/**' --glob '!**/pkg/uikit/**' --glob '!**/examples/**'`;
- refined test audit: same pattern over `*_test.go`, excluding `.bus`,
  `vendor`, `pkg/uikit`, and examples;
- docs audit: same package/API pattern over Markdown files;
- owner-facade audit: same pattern over `bus-ui/pkg` production files, with
  `pkg/uikit` itself excluded;
- deletion sequencing probe: throwaway worktree
  `/private/tmp/bus-ui-full-surface-probe-20260616` at `bus-ui` `424029e`,
  moved `pkg/uikit` to `pkg/uikit.disabled`, then ran
  `GOCACHE=/private/tmp/bus-ui-gocache-full-surface-probe go test ./...`.

Counts from this rebaseline:

- dependency-derived modules in scope: 11 (`bus-ui`, `bus-chat`,
  `bus-factory`, `bus-gateway`, `bus-inspection`, `bus-ledger`,
  `bus-portal`, `bus-portal-accounting`, `bus-portal-ai`,
  `bus-portal-auth`, `bus-portal-notes`);
- known remaining core production rows: 3 implementation/probe rows below,
  across 2 `bus-ui/pkg/ui` production files still importing/calling
  `pkg/uikit` after the accepted WASM global-helper slice;
- known remaining adopter/user production rows: 11 rows below, across 4
  modules with refined production hits (`bus-chat`, `bus-factory`,
  `bus-inspection`, `bus-ledger`);
- production-clean by refined `uikit` call/import audit but still in the
  dependency denominator: `bus-gateway`, `bus-portal`,
  `bus-portal-accounting`, `bus-portal-ai`, `bus-portal-auth`,
  `bus-portal-notes`;
- tests/docs/examples-only rows: 29 refined test files, 30 Markdown files,
  `bus-ui/examples`, and the old `pkg/uikit/uikittest` harness package;
- deferred/out-of-scope rows: local replace hydration gaps listed below
  (`bus-dev`, `bus-data`, `bus-preferences`, `bus-accounts`) until a hydrated
  dependency-user matrix is rerun.

Current deletion sequencing probe result: with `pkg/uikit` moved aside in
`/private/tmp/bus-ui-uikit-deletion-probe-surface`, `go test ./...` advances
beyond `pkg/ui/ui.go` and now stops first in examples/test-harness setup:
`examples/completedapis/render_test.go` imports
`github.com/busdk/bus-ui/pkg/uikit/uikittest`, and
`examples/testing/uikittest_example_test.go` imports
`github.com/busdk/bus-ui/pkg/uikit`. The compact static production audit after
the WASM global-helper slice reports 2 owner facade production files and 34
production adopter/core files. The remaining production core rows are the
visible JS/WASM facades below; do not treat raw example/test probe failures as
adopter-ready production work.

Known remaining core rows:

| row | target files | source files | behavior invariants | DoD / readiness |
|---|---|---|---|---|
| core-1 | `pkg/ui/navigation_primitives.go`, `pkg/ui/navigation_primitives_gx_adapter.go`, `pkg/ui/navigation_primitives_gx_generated.go`, `pkg/ui/shell_navigation_status.go`, `pkg/ui/ui.go` | `pkg/uikit/navigation_primitives.go`, `pkg/uikit/navigation_primitives_gx_adapter.go`, `pkg/uikit/navigation_primitives_gx_generated.go`, `pkg/uikit/navigation_primitives_test.go` | menu, tabs, navigation props/events/errors, href validation, dispatch helpers, `DOMAttrUIValue`, compiled GX markup and legacy trigger-HTML splice behavior | accepted / promoted in `bus-ui` `fba4f79`; worker `gx-ui-core-ui-navigation-primitives-spark-20260616a` false-actived after one exact prompt, so supervisor used the reviewed worker-owned small-chunk exception path and promoted the resulting patch. Primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check HEAD^`, scoped no-`uikit` audit for `pkg/ui/navigation_primitives*.go`, and scoped alias audit proving menu/tabs/navigation symbols are gone from `pkg/ui/shell_navigation_status.go` / `pkg/ui/ui.go`. |
| core-2 | `pkg/ui/status_surfaces.go`, `pkg/ui/status_surfaces_node.go`, `pkg/ui/status_primitives_gx_adapter.go`, `pkg/ui/status_primitives_gx_generated.go`, `pkg/ui/shell_navigation_status.go`, `pkg/ui/ui.go` | `pkg/uikit/status_surfaces.go`, `pkg/uikit/status_surfaces_node.go`, `pkg/uikit/status_primitives_gx_adapter.go`, `pkg/uikit/status_primitives_gx_generated.go`, existing `pkg/ui` empty-state/provider-error helpers | loading/result/error/status validation, status constants, status-pill node and HTML parity, result-panel completed-status rejection, compiled GX markup, and node-first public `StatusPill`/`LoadingState`/`ResultPanel`/`ErrorBanner` facades | accepted / promoted in `bus-ui` `df51293`; implemented with `scripts/gx-ui-symbol-family-skeleton.py` plus focused review instead of worker churn. Primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for new status files, and scoped alias audit proving status symbols are gone from `pkg/ui/shell_navigation_status.go` / `pkg/ui/ui.go`. File-level inventory remains unchanged until core-4 removes the parent import. |
| core-3 | `pkg/ui/split_layout.go`, `pkg/ui/split_layout_gx_adapter.go`, `pkg/ui/ui.go`, `pkg/ui/split_projection_facade.go` | `pkg/uikit/split_layout.go`, `pkg/uikit/split_layout_gx_adapter.go`, existing split projection facade aliases | split pane constants/state, resize math, semantic and legacy split layout render behavior, GX adapter render behavior, node-first public `SplitLayout` facade, and value parity for split defaults | accepted / promoted in `bus-ui` `0c882f3`; implemented with `scripts/gx-ui-symbol-family-skeleton.py` plus focused review. Primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for new split files, scoped alias audit proving split symbols are gone from `pkg/ui/ui.go`, `pkg/ui/shell_navigation_status.go`, and `pkg/ui/split_projection_facade.go`. |
| core-4 | `pkg/ui/shell_navigation_status.go`, `pkg/ui/sidebar_navigation.go`, `pkg/ui/ui.go` | already-moved shell/navigation/status files | final shell/navigation/status aliases and import removal; `ErrShellNavRequired` owned by sidebar/shell package code | accepted / promoted in `bus-ui` `0c882f3`; `pkg/ui/shell_navigation_status.go` was deleted after navigation, status, split-layout, and shell error ownership moved into package-owned files. Static audit dropped to 6 owner facade production files and 38 production adopter/core files. Fresh deletion/build-exclusion probe still pending to name the next compiler-derived blocker. |
| core-5 | `pkg/ui/html_primitives.go`, `pkg/ui/html_nodes.go`, `pkg/ui/html_builder.go`, `pkg/ui/vdom.go`, `pkg/ui/ui.go` | `pkg/uikit/uikit.go`, `pkg/uikit/html_nodes.go`, `pkg/uikit/html_builder.go`, `pkg/uikit/vdom.go` | escaping, attrs/classes, node/string behavior, element helpers, VDOM helpers | accepted / promoted in `bus-ui` `90d4ada`; implemented with `scripts/gx-ui-symbol-family-skeleton.py`. Compile feedback proved `Node` ownership is coupled to render runtime, so this landed with core-7. Primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for new HTML/runtime files. |
| core-6 | `pkg/ui/icon_css_primitives.go`, `pkg/ui/icons.go`, `pkg/ui/icon_nodes.go`, `pkg/ui/assets/uikit.css`, `pkg/ui/ui.go` | `pkg/uikit/assets.go`, `pkg/uikit/icons.go`, `pkg/uikit/icon_nodes.go`, `pkg/uikit/assets/uikit.css` | CSS bundle output/options, icon constants, SVG path icon node rendering | accepted / promoted in `bus-ui` `4ac070f`; implemented with `scripts/gx-ui-symbol-family-skeleton.py` plus focused review. Primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped alias audit proving icon/CSS symbols are gone from `pkg/ui/ui.go`, and scoped no-`uikit` audit for new icon/CSS files except the literal embedded asset name `assets/uikit.css`. Hydrated deletion/build-exclusion probe from `/private/tmp/bus-ui-uikit-deletion-probe-icon-css` still stops at `pkg/ui/ui.go:9:8`, which now represents the remaining core-8 panel/surface/metric aliases. |
| core-7 | `pkg/ui/component_hooks.go`, `pkg/ui/vdom_component_hooks.go`, `pkg/ui/mount_gx.go`, `pkg/ui/action_dispatch.go`, `pkg/ui/runtime_facade.go`, `pkg/ui/control_primitives.go`, `pkg/ui/ui.go` | `pkg/uikit/component_hooks.go`, `pkg/uikit/vdom_component_hooks.go`, `pkg/uikit/mount_gx.go`, `pkg/uikit/action_dispatch.go`; existing package-owned mounted-app/lifecycle code in `pkg/ui/runtime_facade.go` | render runtime hooks, `UseState`, `UseRef`, `UseEffect`, `UseMemo`, component/node/VDOM render helpers, GX root render errors, generic action dispatch, `ControlLogSink` ownership | accepted / promoted in `bus-ui` `90d4ada`; landed together with core-5 because `Node` and render context ownership compile as one boundary. Existing mounted-app constructors stayed in `runtime_facade.go`; copied GX helpers were trimmed to avoid duplicate constructors. |
| core-8 | `pkg/ui/surface_card_primitives.go`, `pkg/ui/surface_card_primitives_node.go`, `pkg/ui/surface_card_primitives_gx_adapter.go`, `pkg/ui/surface_card_primitives_gx_generated.go`, `pkg/ui/data_evidence_records_surface.go`, `pkg/ui/action_controls.go`, `pkg/ui/ui.go` | `pkg/uikit/surface_primitives.go`, `pkg/uikit/surface_primitives_node.go`, `pkg/uikit/surface_primitives_gx_adapter.go`, `pkg/uikit/surface_primitives_gx_generated.go`, `pkg/uikit/control_primitives.go` for `IconActionButton` reference only | panel, surface-card, and metric-card checked HTML plus node-first behavior; typed slot ordering; legacy raw slot splicing; density/typography classes; heading validation; metric status validation; nested-surface rejection; `IconActionButton` should use the already-owned `pkg/ui/action_controls.go` implementation | accepted / promoted in `bus-ui` `7d6a3d1`; implemented with `scripts/gx-ui-symbol-family-skeleton.py` plus focused merge/prune around accepted local surface helpers. Primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for surface-card files and `pkg/ui/ui.go`, static audit, and hydrated deletion/build-exclusion probe. The probe advanced beyond `pkg/ui/ui.go` and now stops at examples/test-harness imports, while static production audit names the remaining four JS/WASM owner facades. |
| core-9 | `pkg/ui/callbacks_js.go`, `pkg/ui/runtime_facade_js_wasm.go`, `pkg/ui/runtime_facade_js_wasm_test.go` | `pkg/uikit/callbacks_js.go` | JS event target, callback retention, listener registration | accepted / promoted in `bus-ui` `1c44c1b`; implemented with `scripts/gx-ui-symbol-family-skeleton.py` plus focused test conversion from pointer-alias parity to local behavior/compile assertions. Primary native checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for moved callback files, static audit, and hydrated deletion/build-exclusion probe. `GOOS=js GOARCH=wasm go test ./pkg/ui` is not yet a clean proof surface because remaining core-10/core-11 facades still fail first (`ai_drop_facade_js_wasm.go` generic aliases under go1.22 and missing `GlobalUint8ArrayCtor` ownership); keep JS/WASM compile proof as part of the later combined core WASM gate. |
| core-10 | `pkg/ui/globals_js.go`, `pkg/ui/wasm_dom_js.go`, `pkg/ui/view_mount_js.go`, `pkg/ui/api_url_js.go`, `pkg/ui/subroute.go`, `pkg/ui/subroute_js.go`, deleted `pkg/ui/wasm_facade_js_wasm.go` | `pkg/uikit/globals_js.go`, `pkg/uikit/wasm_dom_js.go`, `pkg/uikit/view_mount_js.go`, `pkg/uikit/api_url_js.go`, `pkg/uikit/subroute.go`, `pkg/uikit/subroute_js.go`; existing local `pkg/ui/runtime_gateway_facade.go` `ResolveAPIURL` | global accessors including `GlobalUint8ArrayCtor`, API URL, click binding, closest element, DOM attrs, scroll-preserving mount, current subroute normalization | accepted / promoted in `bus-ui` `dd210ad`; implemented with explicit source copies plus focused review. Primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for moved WASM/global files, static audit, and hydrated deletion/build-exclusion probe. `GOOS=js GOARCH=wasm go test ./pkg/ui` now advances past missing `GlobalUint8ArrayCtor` and stops only at core-11 `ai_drop_facade_js_wasm.go` generic alias issues under Go 1.22. |
| core-11 | `pkg/ui/ai_drop_facade_js_wasm.go` | `pkg/uikit/ai_drop*`, `pkg/uikit/dropzone*`, upload/drop helpers | AI path/file drop services, JS file reader, multipart upload, drop-zone handlers, visual state | planning table required; depends on existing upload/drop primitives |
| core-12 | `pkg/ui/split_projection_facade.go` | `pkg/uikit/app_state.go`, `pkg/uikit/app_state_reducers.go`, `pkg/uikit/projection_models.go`, `pkg/uikit/projection_query.go`, `pkg/uikit/ledger_routes.go`; split layout state helper dependency is already owned by core-3 | projection DTO JSON shape, panel layout state/defaults, panel resize reducer, route policy, route helpers, generic query client defaults, HTTP status/not-found behavior | accepted / promoted in `bus-ui` `cd4fc20`; implementation moved DTO/query/route/reducer behavior into package-owned `pkg/ui` code with behavior/JSON parity tests instead of alias identity. Primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for `pkg/ui/split_projection_facade.go`, and deletion probe advancement to `pkg/ui/ui.go:9:8`. |
| core-13 | `pkg/ui/split_projection_facade_js_wasm.go` | `pkg/uikit/projection_list_panel.go`, `pkg/uikit/projection_detail*`, `pkg/uikit/split_controller_js.go` | locale formatting, line summary, split resize wiring, detail presenter | planning table recommended; likely coupled to Ledger adopter |
| core-14 | `pkg/ui` owner audit and `pkg/uikit`/`pkg/uikit/uikittest` deletion probe | all accepted replacement files | no production `pkg/ui` backing import/call to `pkg/uikit`; old package is not retained as compatibility layer | final core truth gate: refined production audit clean or every remaining hit explicitly deferred, then hydrated deletion/build-exclusion probe and dependency-user matrix |

Known remaining adopter/user production rows:

| row | module | target files | current need | dependency/readiness |
|---|---|---|---|---|
| adopter-1 | `bus-factory` | `internal/serve/business_view.go` | replace direct node/table/panel/icon composition with public `ui` facades | depends on core-5, core-6, core-8, and existing table primitives |
| adopter-2 | `bus-factory` | `internal/serve/server.go`, `internal/serve/browser_runtime.go` | replace server/runtime/resource/assistant shell calls with public facades | adapter-only after runtime/assistant/resource facades are confirmed; server helper parity must be probed |
| adopter-3 | `bus-factory` | `internal/serve/ai.go`, `ai_thread_isolation.go`, `ai_acp_status.go`, `ai_go_diagnostics.go` | replace AI DTO/helper aliases with public `assistantui`/`ui` APIs | planning table required; likely mechanical after core rows are clean |
| adopter-4 | `bus-chat` | `internal/serve/ai.go` | replace AI chat/event/thread DTOs and terminal session helpers | planning table required; likely public `assistantui`/`terminalui` facade check first |
| adopter-5 | `bus-chat` | `internal/serve/ai_appserver.go` | replace AI event/model extraction helpers | adapter-only if public AI helpers already exist; otherwise core facade gap |
| adopter-6 | `bus-chat` | `internal/serve/ai_workspace_locks.go` | replace AI isolation status/branch/worktree helpers | planning table required against assistantui owned helpers |
| adopter-7 | `bus-inspection` | `internal/ui/wasm/app.go`, `internal/ui/wasm/view.go` | replace wasm app/view composition with public `ui` facades | depends on core-5/core-6/core-10 and shell/surface rows |
| adopter-8 | `bus-ledger` | `internal/server/ai*.go`, `internal/server/logging.go`, `internal/server/server.go` | replace server AI/runtime/logging helpers | planning table required; likely public `assistantui`/runtime facades |
| adopter-9 | `bus-ledger` | `internal/ui/wasm/app.go`, `app_context.go`, `frontend_errors.go`, `ledger_controller.go` | replace WASM app runtime/action/resource helpers | depends on core-9/core-10/core-11 |
| adopter-10 | `bus-ledger` | `internal/ui/wasm/ledger_view.go`, `view_split_root.go`, `split_resize.go` | replace split layout/root composition helpers | depends on core-3/core-12/core-13 |
| adopter-11 | `bus-ledger` | `internal/ui/wasm/list_rows.go`, `detail_helpers.go`, `view_detail_panel.go`, `view_line_panel.go`, `view_list_panel.go`, `ledger_projection_presenter.go`, `table_status_surfaces.go` | replace ledger projection/list/detail/status surface helpers | depends on core-2, core-8, core-12, core-13 |

Tests/docs/examples-only rows:

| row | files | classification | DoD |
|---|---|---|---|
| test-1 | 29 refined `*_test.go` files outside `pkg/uikit` and examples | test-only parity/harness residue | update after corresponding production rows land; do not count as production backlog |
| test-2 | `bus-ui/examples/completedapis`, `bus-ui/examples/testing` | example/catalog residue | update when core facade rows are clean; examples should teach public packages only |
| test-3 | `pkg/uikit/uikittest` and tests importing it | test harness replacement | move/delete harness behavior into public test packages only after production facades are owned |
| docs-1 | 30 Markdown files with `pkg/uikit`/`uikit.` references | docs/plan residue | batch docs cleanup after production API is stable; avoid teaching deprecated APIs |

Automation feasibility:

| work pattern / rows | classification | smallest useful tool shape | quota call |
|---|---|---|---|
| static inventory after every accepted slice (`core-14`, adopter/test/docs counts) | deterministic tool/codemod candidate | temporary Go or shell audit runner that emits module denominator, production/test/docs hit counts, owner-facade files, and next deletion-probe failure without source dumps | build first if more than one more inventory refresh is needed; low cost and replaces repeated manual `rg` accounting |
| alias-block removal from facade files after a symbol family is owned (`core-1` through `core-4`, parts of `core-5` through `core-8`) | deterministic tool/codemod candidate after explicit source-map input | `scripts/gx-ui-symbol-family-skeleton.py` now handles the smallest explicit symbol-list path: report/remove named alias lines from listed facade files after copying listed sources; always run `gofmt` and scoped audit after `--apply` | use for core-2/core-3 before another implementation worker; the dry-run for core-2 correctly identified the status-surface source copies and alias removals |
| package/import rewrites from `uikit` to `ui`/`assistantui`/`terminalui` in adopters (`adopter-1` through `adopter-11`) | semi-mechanical with generated patch skeleton plus human review | AST import rewriter plus symbol allowlist that rewrites package selectors only for already-owned public symbols and emits unresolved selectors as a table | useful after core rows land; do not use before facade availability is proven |
| moving symbol-family implementation files from `pkg/uikit` into `pkg/ui` (`core-1` through `core-3`, likely `core-5` through `core-8`) | semi-mechanical with generated patch skeleton plus human review | `scripts/gx-ui-symbol-family-skeleton.py` copies explicitly listed source files to package-owned target files and rewrites `package uikit` to the requested target package; compile errors remain for focused human/worker review | core-1 proved the manual exception tax is real, so core-2/core-3 should start from this helper dry-run/apply path instead of another false-active worker loop |
| parity/nil-check tests after aliases become real functions (`core-1` through `core-13`) | semi-mechanical with generated patch skeleton plus human review | test skeleton generator from symbol lists: create behavior/nil/validation checks using existing neighboring tests as fixtures; never generate unknown GX intrinsic names without path preflight | useful for scaffolding, but human review keeps behavior assertions meaningful |
| deletion probe and scoped no-`uikit` audits (`core-4`, `core-14`, final adopter gates) | deterministic tool/codemod candidate | audit runner that creates/reuses a throwaway worktree, moves `pkg/uikit`, runs bounded `go test`, and prints only setup proof, first failure, and counts | worth building before the next several probe cycles if runtime cost stays low |
| source-map row generation from `rg`/AST/go-list output (remaining core/adopter rows) | semi-mechanical planning aid | generator that maps `uikit.Symbol` selectors to source files and markdown table rows, marking missing paths as desired-new or unresolved | useful now for planning-only rows; should not implement code by itself |
| API ownership decisions for render runtime, WASM globals, AI drop, split projection, and Ledger/Factory behavior (`core-7`, `core-10` through `core-13`, adopters with behavior-rich helpers) | reasoning-heavy/manual | no bulk rewrite until the source-map table names owner package, behavior invariants, and facade availability | use planning/source-map review first; no model escalation for implementation until simplified patch still fails for reasoning |

Minimum-token tooling plan: create at most one temporary audit/inventory runner
before more implementation dispatch if the next manual refresh would repeat
three or more commands. Defer patch-generation tooling until the current
shell/navigation/status family proves that symbol-list alias removal and file
copy skeletons will be reused across multiple rows. Do not build a large
framework; every tool should live as a disposable local script or small Go
command, accept explicit file/symbol inputs, print compact tables, and leave
human review plus normal tests as the acceptance gate.

Quota-aware dispatch ranking:

1. Keep production core first: source-map the four remaining JS/WASM owner
   facades named by static audit (`ai_drop_facade_js_wasm.go` and
   `split_projection_facade_js_wasm.go`) before adopter implementation.
2. Use the raw deletion probe's examples/test-harness failure as a queued
   test/docs row, not as the production sequencing denominator.
3. If a source map advances into another known owner facade, prefer planning-only
   source-map tables for the remaining core rows before implementation. Use
   `gpt-5.5` only for hard source-map/planning ambiguity; implementation stays
   Mini/small-chunk unless a simplified patch fails for reasoning/API shape.
4. Keep adopter implementation parked until core owner rows are clean or the
   fresh probe/audit explicitly scopes a row as adopter-ready.

### 2026-06-15 Deletion Probe Rebaseline

The first operational deletion/build-exclusion probe is
`task-e2649c2e9b54`, worker
`gx-ui-uikit-deletion-probe-mini-20260615a`, branch
`codex/gx-ui-uikit-deletion-probe-20260615a`. It is a throwaway truth gate,
not a product deletion branch.

The probe derived the expected dependency-user denominator from `go.mod`
imports: `bus-ui` itself plus `bus-chat`, `bus-factory`, `bus-gateway`,
`bus-inspection`, `bus-ledger`, `bus-portal`, `bus-portal-notes`,
`bus-portal-ai`, `bus-portal-accounting`, and `bus-portal-auth`. The initial
worker tree needed supervisor-side hydration of accepted/pushed submodule
pins and local `replace` dependencies before test output became meaningful.
Future deletion probes should hydrate the owner module's local `replace` graph
up front before interpreting `go test ./...` failures.

After `bus-ui/pkg/uikit` and `bus-ui/pkg/uikit/uikittest` were made
unavailable, the first real product failures were core `bus-ui` failures, not
only adopter imports:

| owner | module | package/file | first missing symbol/import | classification | likely replacement | active/deferred | recommended task slice |
|---|---|---|---|---|---|---|---|
| `bus-ui` | `bus-ui` | `cmd/bus-ui/run.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `bus-ui` implementation still backed by `uikit` | moved CLI catalog/CSS behavior into public `pkg/ui` and `pkg/uicatalog` | accepted | accepted in `bus-ui` `c122e1e` (`task-0625544ef5a8`) |
| `bus-ui` | `bus-portal-notes` | `bus-ui/pkg/assistantui/assistantui_ai_facade.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `assistantui` facade still backed by `uikit` | AI DTO/helpers/panel render/client-script implementation moved into `pkg/assistantui`; node-first `RenderAIPanel` plus explicit `RenderAIPanelHTML` boundary | accepted / matrix advanced | implementation accepted in `bus-ui` `17dddd5` (`task-6c8988b9e1cc`); post-assistantui deletion rerun `task-a1f0c7192d7f` proves `pkg/assistantui` passes and the matrix advances beyond this blocker |
| `bus-ui` | `bus-portal-ai` | `bus-ui/pkg/assistantui/assistantui_ai_facade.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `assistantui` facade still backed by `uikit` | same assistantui rewrite | accepted / matrix advanced | implementation accepted in `bus-ui` `17dddd5` (`task-6c8988b9e1cc`); post-assistantui deletion rerun `task-a1f0c7192d7f` proves `pkg/assistantui` passes and the matrix advances beyond this blocker |
| `bus-ui` | `bus-portal-accounting` | `bus-ui/pkg/assistantui/assistantui_ai_facade.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `assistantui` facade still backed by `uikit` | same assistantui rewrite | accepted / matrix advanced | implementation accepted in `bus-ui` `17dddd5` (`task-6c8988b9e1cc`); post-assistantui deletion rerun `task-a1f0c7192d7f` proves `pkg/assistantui` passes and the matrix advances beyond this blocker |
| `bus-ui` | `bus-portal-auth` | `bus-ui/pkg/assistantui/assistantui_ai_facade.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `assistantui` facade still backed by `uikit` | same assistantui rewrite | accepted / matrix advanced | implementation accepted in `bus-ui` `17dddd5` (`task-6c8988b9e1cc`); post-assistantui deletion rerun `task-a1f0c7192d7f` proves `pkg/assistantui` passes and the matrix advances beyond this blocker |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/action_resource_facade.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `pkg/ui` browser resource transport still backed by `uikit` | move browser resource client/fetch/multipart/provider-error/navigation transport into `pkg/ui` or a non-compatibility internal implementation owned by `pkg/ui` | accepted / matrix advanced | non-browser action/resource core accepted in `bus-ui` `8f60089` (`task-230be2211c0e`); browser resource transport accepted in `bus-ui` `a798a55` (`task-5d6bc8d3c941`); post-browser deletion rerun `task-73873cbf5a10` proves the matrix advances beyond `pkg/ui/action_resource_facade.go` |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/ai_upload_facade.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `pkg/ui` AI upload helper still backed by `uikit` | move `MultipartUploadFunc`, `AIUploadDecodeFunc`, upload response/error handling, and focused behavior tests into `pkg/ui` without uikit parity aliases | accepted / matrix advanced | implementation accepted in `bus-ui` `8540b42` (`task-d07e3b6f8355`); hydrated post-AI-upload module probe `task-4b39fa3069a7` proved the matrix advances beyond `pkg/ui/ai_upload_facade.go` and now stops at `pkg/ui/cli_server_facade.go:8:8` |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/cli_server_facade.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `pkg/ui` CLI/server/browser-open helper facade still backed by `uikit` | move CLI flag/runtime helpers, server logger/client-log/static/token helpers, and browser-open URL validation/launcher selection into `pkg/ui` with focused direct behavior tests | accepted / matrix advanced | implementation accepted in `bus-ui` `cad6590` (`task-b7d461e781f7`); post-CLI/server deletion rerun `task-b5a6128474d0` proved the matrix advances beyond `pkg/ui/cli_server_facade.go` and now stops at `pkg/ui/data_evidence.go:7:8` |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/data_evidence.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `pkg/ui` data/evidence facade still backed by `uikit` aliases | table-map dense/text tables, summary-item and record-list helpers, evidence links/previews, projection detail, provider error, timeline, and image gallery helpers from `pkg/uikit` into `pkg/ui` or a non-compatibility internal owner with focused direct behavior tests | accepted / matrix advanced | all named children accepted through timeline in `bus-ui` `8a42131`; hydrated deletion/build-exclusion probe `task-47b955f185b1` advanced beyond `pkg/ui/data_evidence.go` and now stops at `pkg/ui/form_controls.go:9:8` |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/form_controls.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `pkg/ui` node-first form/control facade formerly backed by `uikit` | move `Form`, `Field`, `Input`, `TextArea`, `SubmitControl`, `Select`, `FileInput`, and `DropZone` node-first implementations into `pkg/ui` or a non-compatibility internal owner with focused direct behavior tests | accepted / matrix advanced | Parent split completed through the final form-controls alias/probe row. Accepted child slices moved control/button, input/select/text area, form/field, submit control, file input, dropzone/drop policy, and final aliases into `pkg/ui`; final primary `bus-ui` `e0c5a45` passed `go test ./pkg/ui`, `go test ./...`, `git diff --check`, and scoped no-`uikit` audit for `pkg/ui/form_controls*.go`. Hydrated deletion/build-exclusion probe from `/private/tmp/bus-ui-uikit-deletion-probe-20260616` advanced beyond `pkg/ui/form_controls.go` to `pkg/ui/control_uikit_bridge.go:5:2`. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/form_controls.go`, `pkg/ui/ui.go`, form/control helper files | `pkg/uikit` helper ownership hidden behind form-controls aliases | prerequisite for form/control facade; `pkg/ui` needed package-owned control/button/drop helper surface for a mechanical move | source-map and patch-target table for `ControlProps` validation, button classes/render helpers, `appendDescribedBy`, input/select/file/drop props, and drop policy helpers formerly in `pkg/uikit/control_primitives.go`, `action_primitives.go`, `form_primitives.go`, `input_primitives.go`, `components.go`, and `dropzone_fc021.go` | accepted / planning used, non-counting | supervisor source map `logs/worker-output/gx-ui-form-controls-helper-source-map-20260616a.md` split the blocker into control/button primitives, input/select/text area, form/field, submit control, file input/dropzone, final alias removal, and deletion probe. All resulting form-controls child rows and the final form-controls alias/probe row are accepted/matrix-advanced, so this prerequisite planning row is archived/non-counting and must not be scanned as active backlog. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/control_primitives.go`, `pkg/ui/button_primitives.go`, `pkg/ui/ui.go` | `ControlProps`, button helpers still aliased from `pkg/uikit` | form-controls child: shared control/button primitive ownership | move `ControlProps`, control validation/errors, callback validation, `ButtonProps`, `ButtonVariant`, `ButtonSize`, `buttonClasses`, `renderButtonElement`, `ButtonChecked`, and `ButtonNodeChecked` into `pkg/ui` without `pkg/uikit` wrappers | accepted | worker `gx-ui-form-controls-control-button-mini-20260616a` (`task-b98838ca4806`) stayed clean after hard gate/source reads/exact nudge, so supervisor used the reviewed worker-owned exception path in the stopped worker tree; worker commit `7f100cd` promoted to primary `bus-ui` `459f252`; checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, and scoped audit proving new control/button files do not import or call `pkg/uikit`; remaining bridge conversions are only for not-yet-moved link/icon/event/submit/auth boundaries while later children drain aliases |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/form_controls_input.go`, `pkg/ui/ui.go` | `InputProps`, `TextAreaProps`, `SelectProps` still aliased from `pkg/uikit` | form-controls child: input/select/text area ownership | move `InputType`, `InputProps`, `TextAreaProps`, `SelectOption`, `SelectProps`, input errors, and checked/node helpers into `pkg/ui` | accepted | Mini worker `gx-ui-form-controls-input-select-mini-20260616a` (`task-3331264155fc`) passed module materialization on `bus-ui` `459f252` and produced source-read evidence, but stayed clean after the exact patch-target nudge and was stopped as execution-path failure; supervisor then used the reviewed worker-owned exception path in that stopped worker tree. Worker commit `1c1647d` promoted to primary `bus-ui` `3bdf79a`; checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for the new input/select files, and scoped alias audit for moved input/select symbols in `pkg/ui/ui.go`. `pkg/ui/control_uikit_bridge.go` was unchanged; it remains only for not-yet-moved link/icon/event/submit/auth boundaries, and input/select added no bridge conversions. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/form_controls_form.go`, `pkg/ui/ui.go` | `FormProps`, `FieldProps`, form/field helpers still aliased from `pkg/uikit` | form-controls child: form/field ownership | move `FormMethod`, `FormProps`, `FieldControlRenderer`, `FieldControlNodeRenderer`, `FieldProps`, form/field errors, `ValidateFormMethod`, `ValidateFormAction`, `ValidateFormTarget`, `DispatchFormSubmit`, `FormChecked`, `FormNodeChecked`, `FieldChecked`, `FieldNodeChecked`, and `appendDescribedBy` into `pkg/ui` | accepted | task `task-ae3fd6ffcb7c`; first create `gx-ui-form-controls-form-field-mini-20260616a` targeted `local` and did not materialize in the live `local-dev` pool. Corrected Mini worker `gx-ui-form-controls-form-field-mini-20260616b` materialized on `bus-ui` `3bdf79a`, passed the hard gate, produced assistant/source-read JSONL evidence, then stayed clean after the exact patch-target nudge and was stopped as execution-path failure; supervisor used the reviewed worker-owned exception path in that stopped tree. Worker commit `c89fc23` promoted to primary `bus-ui` `aeb397c`; checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for new form/field files, and scoped alias audit for moved form/field symbols in `pkg/ui/ui.go`. `pkg/ui/control_uikit_bridge.go` grew only to convert local `FieldProps`/`FormSubmitEvent` at the still-unmoved FilterToolbar boundary and still keeps existing link/icon/event/submit/auth conversions; final form-controls alias/probe must drain or justify those remaining bridge conversions. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/form_controls_submit.go`, `pkg/ui/ui.go` | `SubmitState`, `SubmitControlProps`, submit helpers still aliased from `pkg/uikit` | form-controls child: submit control ownership | move submit state constants/errors, `SubmitControlProps`, transition helpers, `SubmitControlChecked`, and `SubmitControlNodeChecked` into `pkg/ui` after button primitives exist | accepted | task `task-0081a3385a02`; worker `gx-ui-form-controls-submit-mini-20260616a` materialized on `local-dev` at `bus-ui` `aeb397c`, produced assistant/source-read evidence, and then the reviewed worker-owned exception path landed worker commit `d6d7a3d`, promoted to primary `bus-ui` `2710ae3`. Checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for new submit files, scoped alias audit in `pkg/ui/ui.go`, and bridge audit proving `toUIKitSubmitControlProps` / submit bridge calls are gone. `pkg/ui/control_uikit_bridge.go` shrank by removing the submit-control bridge; remaining bridge boundaries are still the not-yet-moved link/icon/event/auth/filter-toolbar conversions plus file/dropzone until that child lands. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/form_controls_file_input.go`, `pkg/ui/ui.go` | `FileInputProps`, file-input render helpers, and accepted-types attr helper still aliased from `pkg/uikit` | form-controls child: file input ownership | move `FileInputProps`, file-input accessible-name/render behavior, `DropAcceptedTypesAttr`, `FileInputChecked`, and `FileInputNodeChecked` into `pkg/ui` | accepted | task `task-d0f8d61e1103`; worker `gx-ui-form-controls-file-input-mini-20260616a` materialized on `local-dev` at `bus-ui` `2710ae3`, passed the hard gate, produced assistant/source-read evidence, then stayed clean and used the reviewed worker-owned exception path. Worker commit `5ac6dc7` promoted to primary `bus-ui` `080064c`; checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for new file-input files, scoped alias audit in `pkg/ui/ui.go`, and facade audit proving `uikit.FileInputNodeChecked` is gone from `pkg/ui/form_controls.go`. `pkg/ui/control_uikit_bridge.go` was unchanged; no file-input boundary existed there. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/form_controls_dropzone*.go`, `pkg/ui/form_controls_file_input.go`, `pkg/ui/ui.go` | drop-zone props, DTOs, policy helpers, and node render helpers still aliased from `pkg/uikit` | form-controls child: dropzone/drop-policy ownership | move `DropSource`, drop DTO/policy types, `NormalizeDropSource`, `AcceptDropItems`, `DecodeDropItems`, `CollectDropItemsFromReader`, `DropZoneChecked`, and `DropZoneNodeChecked` into `pkg/ui` after file input lands | accepted | task `task-57649838f029`; worker `gx-ui-form-controls-dropzone-policy-mini-20260616a` materialized on `local-dev` at `bus-ui` `080064c`, produced assistant/source-read evidence, then used the reviewed worker-owned exception path. Worker commit `a1326bc` promoted to primary `bus-ui` `e0c5a45`; checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for dropzone/file-input files, scoped alias audit in `pkg/ui/ui.go`, and facade audit proving `uikit.DropZoneNodeChecked` is gone from `pkg/ui/form_controls.go`. `pkg/ui/control_uikit_bridge.go` was unchanged; no dropzone bridge boundary remains. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/form_controls.go`, `pkg/ui/ui.go` | final form-controls `pkg/uikit` import/aliases | form-controls child: final alias removal and truth gate | rewrite `Form`, `Field`, `Input`, `TextArea`, `SubmitControl`, `Select`, `FileInput`, and `DropZone` to call local helpers; remove the `pkg/uikit` import and any now-owned aliases from `pkg/ui/ui.go`; rerun hydrated deletion/build-exclusion probe | accepted / matrix advanced | Final gate passed after dropzone in primary `bus-ui` `e0c5a45`: `GOCACHE=/private/tmp/bus-ui-gocache-final-form go test ./pkg/ui`, `GOCACHE=/private/tmp/bus-ui-gocache-final-form go test ./...`, `git diff --check`, and scoped audit found no `pkg/uikit|uikit\.` in `pkg/ui/form_controls*.go`. Hydrated deletion/build-exclusion probe from isolated worktree `/private/tmp/bus-ui-uikit-deletion-probe-20260616` advanced beyond `pkg/ui/form_controls.go` and now stops at `pkg/ui/control_uikit_bridge.go:5:2`. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/control_uikit_bridge.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `pkg/ui` control/action/auth bridge formerly backed by `uikit` conversions | drain `control_uikit_bridge.go` without compatibility wrappers by moving remaining link/icon/event controls, filter toolbar, and credential login card ownership into `pkg/ui`; then rerun deletion probe | accepted / matrix advanced | Parent split completed through the final bridge removal/probe row. Accepted child slices moved link/icon/event controls, filter toolbar, credential login card, and then deleted the remaining `control_uikit_bridge.go`; primary `bus-ui` `4089eae` passed `go test ./pkg/ui`, `go test ./...`, `git diff --check`, and bridge audit because `pkg/ui/control_uikit_bridge.go` no longer exists. Hydrated deletion/build-exclusion probe from `/private/tmp/bus-ui-uikit-deletion-probe-control-20260616` advanced beyond `pkg/ui/control_uikit_bridge.go` to `pkg/ui/portal_launcher_empty_state.go:12:2`. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/control_uikit_bridge.go`, `pkg/ui/action_controls.go`, focused tests | `LinkButton`, `IconButton`, and `EventBar` helpers still call through `pkg/uikit` | control bridge child: link/icon/event controls | move `LinkButtonProps`, `LinkButton`, `LinkButtonChecked`, `LinkButtonNodeChecked`, `IconButtonProps`, `IconButton`, `IconButtonChecked`, `IconButtonNodeChecked`, `EventBarAction`, `EventBarProps`, `EventBar`, `EventBarChecked`, and `EventBarNodeChecked` into `pkg/ui` using local `ControlProps`, `ButtonProps`, `ButtonVariant`, `ButtonSize`, and `IconProps` | accepted | task `task-117954a1c9e9`; worker `gx-ui-control-bridge-link-icon-event-mini-20260616a` materialized on `local-dev` at `bus-ui` `e0c5a45`, passed the hard gate/source reads, then stayed product-clean after the exact patch-target nudge except for `PLAN.md`; supervisor used the reviewed worker-owned exception path in that worker tree. Worker commit `b1240bc` promoted to primary `bus-ui` `e705ae9`; checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, and scoped audit proving no link/icon/event `uikit.` calls remain in `pkg/ui/control_uikit_bridge.go` or the new action-controls file. `pkg/ui/control_uikit_bridge.go` shrank by removing the link/icon/event props, wrappers, and converters; remaining bridge boundaries are filter toolbar and credential login card before final bridge/probe. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/control_uikit_bridge.go`, `pkg/ui/filter_toolbar.go`, focused tests | `FilterToolbar` helpers still call through `pkg/uikit` | control bridge child: filter toolbar | move `FilterToolbarResetHandler`, `FilterToolbarResetEvent`, `FilterToolbarProps`, filter toolbar errors, checked/node helpers, and submit/reset dispatch helpers into `pkg/ui` using local form/field/button helpers | accepted | task `task-81d979cfc3bd`; worker `gx-ui-control-bridge-filter-toolbar-mini-20260616a` materialized on `local-dev` at `bus-ui` `e705ae9`, produced assistant/source-read JSONL evidence, then stayed clean after the exact nudge until the reviewed worker-owned exception path landed the patch. Worker commit `e45e2ba` promoted to primary `bus-ui` `bcfa01b`; checks passed in worker and primary with explicit `GOCACHE`: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, and scoped audit proving no moved filter-toolbar `uikit.` calls remain in `pkg/ui/control_uikit_bridge.go` or `pkg/ui/filter_toolbar.go`. `pkg/ui/control_uikit_bridge.go` shrank by removing filter-toolbar props, wrappers, and converters; remaining bridge boundary is credential login card before final bridge/probe. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/control_uikit_bridge.go`, `pkg/ui/credential_login_card.go`, `pkg/ui/ui.go`, focused tests | `CredentialLoginCard` helpers still call through `pkg/uikit` | control bridge child: credential login card | move `CredentialLoginCardProps`, credential login checked/node helpers, and required credential card render/config helpers into `pkg/ui` using local form/field/input/button helpers | accepted | task `task-531fd1c915ba`; worker `gx-ui-control-bridge-credential-card-mini-20260616a` materialized on `local-dev` at `bus-ui` `bcfa01b`, produced assistant/source-read JSONL evidence, then stayed clean after the exact patch-target nudge until the reviewed worker-owned exception path landed the patch. Worker commit `147ea2e` promoted to primary `bus-ui` `45a34bc`; checks passed in worker and primary with explicit `GOCACHE`: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, focused credential login card render/dispatch/validation tests, and scoped audit proving credential card conversions and `uikit.CredentialLoginCard*` calls are gone from `pkg/ui/control_uikit_bridge.go` and `pkg/ui/*.go`. `pkg/ui/control_uikit_bridge.go` now contains only generic `uikit` conversion residue for the final bridge/probe child. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/control_uikit_bridge.go`, `pkg/ui/ui.go` if needed | final control bridge `pkg/uikit` import/calls | control bridge child: final bridge removal and truth gate | delete `control_uikit_bridge.go` if empty or reduce it only to fresh compiler-derived non-bridge work, then rerun hydrated deletion/build-exclusion probe | accepted / matrix advanced | task `task-7b1f74354f22`; worker `gx-ui-control-bridge-final-probe-mini-20260616a` materialized on `local-dev` at `bus-ui` `45a34bc`, proved the remaining helper symbols were isolated to `pkg/ui/control_uikit_bridge.go`, deleted that file, and committed `605d46f`, promoted to primary `bus-ui` `4089eae`. Worker and primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`; scoped bridge audit succeeds because `pkg/ui/control_uikit_bridge.go` no longer exists. Hydrated deletion/build-exclusion probe from `/private/tmp/bus-ui-uikit-deletion-probe-control-20260616` advanced beyond `pkg/ui/control_uikit_bridge.go` and now stops at `pkg/ui/portal_launcher_empty_state.go:12:2`. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/portal_launcher_empty_state.go`, likely `pkg/ui/shell_navigation_status.go` and `pkg/ui/ui.go` | `github.com/busdk/bus-ui/pkg/uikit` | core `pkg/ui` portal launcher/status surface facade still backed by `uikit` status aliases | move portal launcher empty-state rendering onto package-owned `pkg/ui` empty-state/status surface helpers first; then rerun deletion probe to name whether broader loading/result/error/shell aliases are next | accepted / matrix advanced | Empty-state ownership accepted in `bus-ui` `4c8aa07`; hydrated deletion/build-exclusion probe from `/private/tmp/bus-ui-uikit-deletion-probe-portal-empty-20260616` advanced beyond `pkg/ui/portal_launcher_empty_state.go` and now stops at `pkg/ui/runtime_facade.go:8:8`. Broader shell/navigation/loading/result/error aliases are not the current compiler-named blocker. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/portal_launcher_empty_state.go`, `pkg/ui/status_empty_state.go`, `pkg/ui/shell_navigation_status.go`, focused tests | `EmptyStateProps`, `EmptyStateNodeChecked`, and portal empty-state render still routed through `pkg/uikit` | portal/status child: empty-state ownership | move empty-state props/render helpers into `pkg/ui`, update `PortalLauncherEmptyState` to call local helpers, remove only empty-state aliases from `shell_navigation_status.go`, and add focused render/validation/action tests | accepted | task `task-4458c3b6b8e9`; worker `gx-ui-portal-launcher-empty-state-mini-20260616a` materialized on `local-dev` at `bus-ui` `4089eae`, produced assistant/source-read evidence, then stayed clean after the exact patch-target nudge, so supervisor used the reviewed worker-owned exception path in that worker tree. Worker commit `45259a3` promoted to primary `bus-ui` `4c8aa07`. Checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped audit proving no `pkg/uikit|uikit\.` in portal/status-empty-state files, and scoped alias audit proving no empty-state `uikit` aliases remain in `pkg/ui/shell_navigation_status.go` or `pkg/ui/ui.go`. Deletion probe follows immediately. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/runtime_facade.go`, `pkg/ui/runtime_facade_test.go`, `pkg/ui/ui.go` runtime aliases | `github.com/busdk/bus-ui/pkg/uikit` | core `pkg/ui` mounted runtime facade still backed by `uikit` | move `MountedApp`, `MountApp`, `NewMountedApp`, `NewMountedNodeApp`, `NewMountedGXApp`, `NewMountedGXNodeApp`, `RenderDOMErrorBannerHTML`, `NormalizeDOMErrorDismissAction`, `OnceDispose`, and `ChainDisposers` into `pkg/ui` using existing local render/runtime/GX helpers, without moving unrelated WASM/browser runtime surfaces | accepted / matrix advanced | Worker `gx-ui-runtime-facade-mini-20260616a` (`task-67f4539fc133`) produced source-read evidence, then an interrupted partial patch; supervisor used the reviewed worker-owned small-chunk exception path in that worker tree. Worker commit `2dba35e` was promoted to primary `bus-ui` `d70b316`. Checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, and scoped audit proving no `pkg/uikit|uikit\.` remains in `pkg/ui/runtime_facade.go` or its behavior tests. Hydrated deletion/build-exclusion probe from `/private/tmp/bus-ui-uikit-deletion-probe-runtime-20260616` advanced beyond `pkg/ui/runtime_facade.go` and now stops at `pkg/ui/runtime_gateway_facade.go:8:8`. Refreshed static production audit shows 9 known remaining core `pkg/ui` rows plus 12 parked adopter/probe follow-ups. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/callbacks_js.go`, deleted `pkg/ui/runtime_facade_js_wasm.go`, focused js/wasm tests | `pkg/uikit/callbacks_js.go` | core `pkg/ui` JS/WASM runtime event facade formerly backed by `uikit` | move `EventTarget`, `JSEventTarget`, callback retention, event listener, and JS event target helpers into `pkg/ui` with behavior/compile tests | accepted / matrix advanced | Accepted in primary `bus-ui` `1c44c1b`; the source-map preflight corrected stale earlier hints and proved all moved symbols came from `pkg/uikit/callbacks_js.go`. Checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for `callbacks_js.go` and `runtime_facade_js_wasm_test.go`, compact static audit, and hydrated deletion/build-exclusion probe. Static production audit dropped to 3 owner facade files and 35 production adopter/core files. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/runtime_gateway_facade.go`, `pkg/ui/gateway_http.go`, focused tests | `pkg/uikit` import/calls visible in production static audit; first compiler blocker after runtime facade | core `pkg/ui` gateway runtime facade still backed by `uikit` | source-map runtime API URL and gateway client helpers; move `URLResolver`, gateway client types, `NewHTTPGatewayClient`, and `ResolveAPIURL` into `pkg/ui` with focused native tests | accepted / matrix advanced | Worker `gx-ui-runtime-gateway-facade-mini-20260616a` (`task-aefd0bf53c0c`) materialized on `local-dev` at `bus-ui` `d70b316`, passed the hard gate, produced source-read evidence, then needed an exact patch-target nudge because `HTTPGatewayClient` also required tiny JSON helpers from `pkg/uikit/ai_http.go` and `StringMapValue` behavior from `pkg/uikit/ai_helpers.go`. Worker commit `dbc63e8` was promoted to primary `bus-ui` `1617e17`. Checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, and scoped audit proving no `pkg/uikit|uikit\.` remains in runtime gateway files. Hydrated deletion/build-exclusion probe from `/private/tmp/bus-ui-uikit-deletion-probe-runtime-gateway-20260616` advanced beyond `pkg/ui/runtime_gateway_facade.go` and now stops at `pkg/ui/shell_evidence_facade.go:14:2`. Refreshed static production audit shows 8 known remaining core `pkg/ui` rows plus 12 parked adopter/probe follow-ups. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/globals_js.go`, `wasm_dom_js.go`, `view_mount_js.go`, `api_url_js.go`, `subroute*.go`, deleted `pkg/ui/wasm_facade_js_wasm.go` | `pkg/uikit` import/calls visible in production static audit | core `pkg/ui` WASM DOM/global facade formerly backed by `uikit` | source-map JS global access, DOM attribute helpers, click binding, closest element, API URL, subroute helpers, and mount-with-scroll preservation helpers; move to `pkg/ui` with JS/WASM checks | accepted / matrix advanced | Accepted in primary `bus-ui` `dd210ad`; checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, scoped no-`uikit` audit for moved WASM/global files, compact static audit, and hydrated deletion/build-exclusion probe. Static production audit dropped to 2 owner facade files and 34 production adopter/core files. `GOOS=js GOARCH=wasm go test ./pkg/ui` now advances past `GlobalUint8ArrayCtor` and stops at core-11 AI drop generic alias ownership. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/ai_drop_facade_js_wasm.go` | `pkg/uikit` import/calls visible in production static audit | core `pkg/ui` AI drop JS/WASM facade still backed by `uikit` | source-map AI drop controller, JS file reader, drop services, file-byte reader, multipart upload, import/drop-zone handlers, and visual target helpers; move to `pkg/ui` only after shared upload/drop primitives are package-owned | queued / known future core | Static production audit after the post-empty-state deletion probe found this future core row. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/split_projection_facade.go` | `pkg/uikit` import/calls visible in production static audit | core `pkg/ui` split projection/query facade still backed by `uikit` | source-map panel/split layout state, projection response DTOs, route policy, and generic projection query client; move to `pkg/ui` with native tests | queued / known future core | Static production audit after the post-empty-state deletion probe found this future core row. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/split_projection_facade_js_wasm.go` | `pkg/uikit` import/calls visible in production static audit | core `pkg/ui` split projection JS/WASM facade still backed by `uikit` | source-map locale formatter, split resize state/wiring, projection line summary, and projection detail presenter; move to `pkg/ui` with js/wasm checks | queued / known future core | Static production audit after the post-empty-state deletion probe found this future core row. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/shell_evidence_facade.go`, `pkg/ui/evidence_url_resolver.go`, `pkg/ui/runtime_api_url.go`, `pkg/ui/shell_asset_helpers.go`, focused tests | `pkg/uikit` import/calls visible in production static audit; first compiler blocker after runtime gateway | core `pkg/ui` shell/evidence URL facade still backed by `uikit` | source-map shell asset URL validation/resolution and evidence URL resolver helpers; move to `pkg/ui` with URL-safety and resolver tests | accepted / matrix advanced | Mini worker `gx-ui-shell-evidence-facade-mini-20260616a` (`task-7da50b0904d9`) materialized on `local-dev` at `bus-ui` `1617e17`, produced assistant/source-read evidence, then stayed clean after the exact patch-target nudge, so supervisor used the reviewed worker-owned small-chunk exception path in that worker tree. Worker commit `d1c2004` promoted to primary `bus-ui` `952b323`. Checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, and scoped no-`uikit` audit for shell-evidence/runtime URL resolver files. Hydrated deletion/build-exclusion probe from `/private/tmp/bus-ui-uikit-deletion-probe-shell-evidence-20260616` advanced beyond `pkg/ui/shell_evidence_facade.go` and now stops at `pkg/ui/shell_navigation_status.go:8:8`. Refreshed static production audit shows 7 known remaining core `pkg/ui` rows plus 12 parked adopter/probe follow-ups. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/shell_navigation_status.go` | `pkg/uikit` import/calls visible in production static audit; first compiler blocker after shell evidence | core `pkg/ui` shell/navigation/status facade still backed by `uikit` | split table-first before implementation: shell/page, shell action panel, sidebar/navigation, menu/tabs/navigation, loading/result/error/status surfaces, split layout, then final alias removal/probe | active / split enumerated | Hydrated deletion/build-exclusion probe after shell evidence now stops at `pkg/ui/shell_navigation_status.go:8:8`. Source-map worker `gx-ui-shell-navigation-status-source-map-mini-20260616a` (`task-5122db1afe98`) passed the hard module/path gate on `bus-ui` `952b323`, read the verified source files, and proved this parent is multiple mechanical children. Parent is not matrix-advanced until `pkg/ui/shell_navigation_status.go` drops `pkg/uikit` and the hydrated deletion/build-exclusion probe advances. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/shell_action_panel.go`, `pkg/ui/shell_navigation_status.go`, `pkg/ui/ui.go`, focused tests | `ShellActionPanel*` aliases still routed through `pkg/uikit` | shell/navigation child: shell action panel ownership | move `ShellActionPanelProps`, `ShellActionPanelControl`, `ShellActionPanelCheckedProps`, `ShellActionPanel`, `ShellActionPanelNodeChecked`, `ShellActionPanelChecked`, `ShellActionPanelHTML`, and shell action panel errors into package-owned `pkg/ui` files using `pkg/uikit/shell_action_panel.go` and `pkg/uikit/shell_action_panel_render.go`; remove only shell-action-panel aliases from `shell_navigation_status.go`; update facade parity in `pkg/ui/ui_test.go` | accepted / promoted | Mini worker `gx-ui-shell-action-panel-mini-20260616a` (`task-225b72fab626`) materialized on `local-dev` at `bus-ui` `952b323`, passed the hard gate, produced a real diff after one exact patch-target nudge, and committed `0a1174e`. Promoted to primary `bus-ui` `35e0e67`. Primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check HEAD^`, scoped audit proving no `pkg/uikit|uikit\.` in the new action-panel files, and scoped audit proving no `uikit.ShellActionPanel` / `uikit.ErrShellActionPanel` aliases remain in `pkg/ui/shell_navigation_status.go` or `pkg/ui/ui.go`. Parent remains active until the remaining shell/navigation children land and the final deletion probe advances beyond `pkg/ui/shell_navigation_status.go`. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/shell_page.go`, `pkg/ui/shell_navigation_status.go`, `pkg/ui/ui.go`, focused tests | `AppShell*`, `PageShell*`, shell constants/errors still routed through `pkg/uikit` | shell/navigation child: app/page shell ownership | move `AppShellProps`, `PageShellProps`, default shell asset constants, shell validation errors, `AppShell`, `AppShellChecked`, `PageShellNodeChecked`, `PageShellChecked`, `PageShell`, and page-shell GX adapter helpers into `pkg/ui` without duplicating already-owned shell asset URL helpers | accepted / promoted | Mini worker `gx-ui-shell-page-mini-20260616a` (`task-6d9d0f8b357f`) materialized on `local-dev` at `bus-ui` `35e0e67`, produced assistant/source-read evidence, then stayed clean after the exact patch-target nudge, so supervisor used the reviewed worker-owned small-chunk exception path in that worker tree. Worker commit `9c023f9` promoted to primary `bus-ui` `eba3e6c`. Checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check HEAD^`, scoped audit proving no `pkg/uikit|uikit\.` in `pkg/ui/shell_page.go` or its tests, and scoped audit proving app/page/default-shell/error aliases are gone from `pkg/ui/shell_navigation_status.go` and `pkg/ui/ui.go`. Parent remains active until the remaining shell/navigation children land and the final deletion probe advances beyond `pkg/ui/shell_navigation_status.go`. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/sidebar_navigation.go`, `pkg/ui/shell_navigation_status.go`, `pkg/ui/ui.go`, focused tests | `SidebarShell*`, `SidebarNav*`, and sidebar navigation errors still routed through `pkg/uikit` | shell/navigation child: sidebar shell/navigation ownership | move sidebar shell/nav props, checked/node helpers, dispatch, validation errors, and render helpers from `pkg/uikit/sidebar_shell.go` into `pkg/ui`; remove corresponding aliases from `shell_navigation_status.go` and common facade aliases where owned | accepted / promoted | Mini worker `gx-ui-shell-sidebar-mini-20260616a` (`task-f3b93650b7b7`) materialized on `local-dev` at `bus-ui` `eba3e6c`, produced assistant/source-read evidence, then stayed clean after the exact patch-target nudge; supervisor used the reviewed worker-owned small-chunk exception path in that worker tree and committed `cd67394`. Promoted to primary `bus-ui` `424029e`. Checks passed in worker and primary: `go test ./pkg/ui`, `go test ./...`, `git diff --check HEAD^`, scoped audit proving no `pkg/uikit|uikit\.` in `pkg/ui/sidebar_navigation.go` or its tests, and scoped audit proving no sidebar `uikit` aliases remain in `pkg/ui/shell_navigation_status.go` or `pkg/ui/ui.go`. Parent remains active until menu/tabs/navigation, status surfaces, split layout, and final alias-removal/probe land. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/navigation_primitives.go`, `pkg/ui/navigation_primitives_gx_adapter.go`, `pkg/ui/navigation_primitives_gx_generated.go`, `pkg/ui/shell_navigation_status.go`, `pkg/ui/ui.go`, focused tests | `Menu*`, `Tabs*`, `Navigation*`, navigation events/errors still routed through `pkg/uikit` | shell/navigation child: menu/tabs/navigation ownership | move `MenuItem*`, `MenuProps`, `TabsProps`, `NavigationProps`, click events/handlers, checked/node helpers, dispatch helpers, `ValidateNavigationHref`, `DOMAttrUIValue`, compiled GX helpers, and navigation validation errors from `pkg/uikit/navigation_primitives*.go` into `pkg/ui` | accepted / promoted | Accepted in `bus-ui` `fba4f79`. Source-map/prompt artifact `logs/worker-prompts/gx-ui-core-ui-navigation-primitives-source-map-20260616a.md` named exact files, symbols, behavior invariants, checks, and automation classification. Primary checks passed: `go test ./pkg/ui`, `go test ./...`, `git diff --check HEAD^`, focused dispatch/href/splice validation tests, scoped no-`uikit` audit for new navigation files, and scoped alias audit for `uikit.Menu|uikit.Tabs|uikit.Navigation|uikit.ValidateNavigationHref`. Parent remains active until status surfaces, split layout, and final alias/probe land. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/status_surfaces.go`, `pkg/ui/shell_navigation_status.go`, `pkg/ui/ui.go`, focused tests | loading/result/error/status surface aliases still routed through `pkg/uikit` | shell/navigation child: loading/result/error/status surface ownership | move `StatusSurfaceStatus`, status constants/errors, `LoadingStateProps`, `ResultPanelProps`, `ErrorBannerProps`, `LoadingStateChecked`, `LoadingStateNodeChecked`, `ResultPanelChecked`, `ResultPanelNodeChecked`, `ErrorBannerChecked`, `ErrorBannerNodeChecked`, and supporting status-surface render/validation helpers from `pkg/uikit/status_surfaces.go` and `status_surfaces_node.go` into `pkg/ui` | queued / after action panel unless deletion matrix reorders | `EmptyState`/`StatusPill` are already partially owned by earlier portal/status work and common `ui.go`; this child must shrink only the still-aliased loading/result/error/status surface family and update `ui.go` only for symbols it owns. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/split_layout.go`, `pkg/ui/shell_navigation_status.go`, `pkg/ui/ui.go`, focused tests | `SplitLayout*` aliases still routed through `pkg/uikit` | shell/navigation child: split layout ownership | move split layout constants/errors, `SplitLayoutVM`, `SplitLayoutState`, `SplitLayoutPaneProps`, `SplitLayoutProps`, node/checked helpers, resize/state helpers, render root helpers, and GX adapter helpers from `pkg/uikit/split_layout.go` and `split_layout_gx_adapter.go` into `pkg/ui` | queued / after smaller shell-navigation children | Keep split layout separate because the source map shows an independent state/render boundary. DoD includes resize/state/render tests and scoped audit for `uikit.SplitLayout|uikit.SplitPane|uikit.NormalizeSplitLayoutState|uikit.ApplySplitLayoutResize`. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/shell_navigation_status.go`, `pkg/ui/ui.go` | final shell/navigation/status `pkg/uikit` import/aliases | shell/navigation child: final alias removal and truth gate | after all shell-navigation children land, remove the remaining `pkg/uikit` import/aliases from `pkg/ui/shell_navigation_status.go`, update any drained common aliases in `pkg/ui/ui.go`, then rerun hydrated deletion/build-exclusion probe and static production audit | queued / final probe child | Parent row advances only when the deletion probe gets past `pkg/ui/shell_navigation_status.go` and the static production audit rebaselines the next known core rows. Adopter lanes stay parked until that probe/audit completes. |
| `bus-ui` | `bus-ui` | `bus-ui/pkg/ui/ui.go` | `pkg/uikit` import/calls visible in production static audit | core `pkg/ui` common primitive facade still backed by `uikit` | split table-first by primitive family: common HTML helpers, component/render runtime aliases, CSS/icons, DOM element helpers, status/surface/card/split aliases, `RenderGXNode`, and generic `DispatchAction`; re-audit after each accepted core slice because other rows may drain part of this file | queued / known future core parent | Static production audit after the post-empty-state deletion probe found this future core parent. |
| environment | `bus-factory` | `internal/serve/server.go` | `github.com/busdk/bus-dev` local replace missing | deferred/out of scope | hydrate `bus-dev`, then rerun probe | deferred | environment hydration only |
| environment | `bus-gateway` | `internal/server/state_store.go` | `github.com/busdk/bus-data` local replace missing | deferred/out of scope | hydrate `bus-data`, then rerun probe | deferred | environment hydration only |
| environment | `bus-inspection` | `internal/server/state_store.go` | `github.com/busdk/bus-data` local replace missing | deferred/out of scope | hydrate `bus-data`, then rerun probe | deferred | environment hydration only |
| environment | `bus-ledger` | `internal/server/server.go` | `github.com/busdk/bus-preferences` local replace missing | deferred/out of scope | hydrate `bus-preferences`, then rerun probe | deferred | environment hydration only |
| environment | `bus-chat` | `internal/cli/flags.go` | `github.com/busdk/bus-preferences` local replace missing | deferred/out of scope | hydrate `bus-preferences`, then rerun probe | deferred | environment hydration only |
| environment | `bus-portal` | `cmd/bus-portal/main.go` | `github.com/busdk/bus-accounts` local replace missing | deferred/out of scope | hydrate `bus-accounts`, then rerun probe | deferred | environment hydration only |

Post-CLI rerun: after `bus-ui` `c122e1e` was accepted and pinned in BusDK
`0343706`, worker `gx-ui-uikit-deletion-rerun-after-cli-mini-20260615a`
reran the throwaway deletion probe with `docs` `d901e71` and local
`bus-ui` replacements `bus-gx`, `bus-help`, and `bus-update` hydrated. The
matrix advanced past `cmd/bus-ui/run.go`: `go test ./...` no longer stops on
the CLI/catalog/CSS path. The first core blocker is now
`pkg/assistantui/assistantui_ai_facade.go:7:2` importing
`github.com/busdk/bus-ui/pkg/uikit`, which fails setup for `cmd/bus-ui`,
examples, `pkg/assistantui`, `pkg/terminalui`, `pkg/ui`, and the moved
`uikit.disabled/uikittest` test package. No deletion diff was promoted.

The current 13-slice adopter backlog is therefore provisional. It must not be
reported as final or adopter-only until the deletion probe is rerun with the
remaining local replace dependencies hydrated and the goal inventory is
updated from the full compiler-derived matrix. Immediate critical path now
starts with the core `bus-ui`/`assistantui` implementation slices above,
because compatibility shims inside `pkg/ui` and `pkg/assistantui` currently
hide real `pkg/uikit` dependencies from downstream adopter tests.

Assistantui core reroute implementation: `bus-ui` `17dddd5`
(`task-6c8988b9e1cc`, worker
`gx-ui-core-assistantui-ai-facade-uikit-removal-mini-20260615c`) accepted the
assistantui AI facade implementation slice. It moved the AI DTOs, helper
reducers, client script asset, js/wasm render-props adapter, and panel render
implementation into `pkg/assistantui`; kept the primary `RenderAIPanel` API
node-first; and made `RenderAIPanelHTML` the explicit string boundary. Worker
evidence: scoped `pkg/assistantui` `pkg/uikit` audit clean, `go test
./pkg/assistantui`, and `go test ./...` in `bus-ui`.

Post-assistantui deletion rerun: worker
`gx-ui-uikit-deletion-rerun-after-assistantui-mini-20260615c`
(`task-a1f0c7192d7f`) reran the throwaway deletion/build-exclusion probe on
BusDK `4f50204`, `bus-ui` `17dddd5`, and docs `06b2289`, with local
`bus-gx`, `bus-help`, and `bus-update` replacements hydrated at the pinned
SHAs. With `pkg/uikit` and `pkg/uikit/uikittest` moved out of the build,
`go test ./...` proved `pkg/assistantui` passes and the matrix advances past
`assistantui_ai_facade.go`. The first remaining owner-module blocker is now
`pkg/ui/action_resource_facade.go:8:8` importing
`github.com/busdk/bus-ui/pkg/uikit`, failing setup for `cmd/bus-ui`, examples,
`pkg/terminalui`, `pkg/ui`, and the moved `uikit.disabled/uikittest` package.
The worker restored the throwaway deletion state and left its worktree clean.

Action/resource core implementation: `bus-ui` `8f600896`
(`task-230be2211c0e`, worker
`gx-ui-core-ui-action-resource-core-spark-20260615d`) accepted the non-browser
action/resource core slice. It moved `ActionState`, action/result DTOs, result
constructors, resource request/client interfaces, gateway dispatch, validation,
and focused tests into `pkg/ui`; kept the existing component
`ui.ProviderError` API untouched by preserving `ProviderErrorResult` for
result construction; and removed temporary `ActionStatus*Const` compatibility
names. Worker and supervisor evidence: `go test ./pkg/ui`, `go test ./...`,
`git diff --check`, no direct `pkg/uikit` import in
`pkg/ui/action_resource_effect.go`, and no `func ProviderError(...) Result`.

Post-action/resource deletion rerun: worker
`gx-ui-uikit-deletion-rerun-after-action-resource-mini-20260615a`
(`task-2551cd20e12c`) reran the throwaway deletion/build-exclusion probe on
BusDK `86c2e24`, `bus-ui` `8f60089`, and docs `e340f7b`, with local
`bus-gx`, `bus-help`, and `bus-update` replacements hydrated at the pinned
SHAs. With `pkg/uikit` and `pkg/uikit/uikittest` moved out of the build,
`go test ./...` proved `cmd/bus-ui/run.go` and
`pkg/assistantui/assistantui_ai_facade.go` stay past their old blockers, but
the matrix still stops at `pkg/ui/action_resource_facade.go:6:8` importing
`github.com/busdk/bus-ui/pkg/uikit`. The remaining core blocker is now the
browser resource transport aliases/client helpers still backed by `uikit`.
The worker restored the throwaway deletion state and left its worktree clean.

Browser resource transport implementation: `bus-ui` `a798a556`
(`task-5d6bc8d3c941`, worker
`gx-ui-core-ui-browser-resource-transport-spark-20260615a`) accepted the
browser transport slice. It moved browser resource client/fetch request and
response handling, multipart payload support, provider error payload helpers,
and navigation helpers into `pkg/ui`; deleted the remaining action resource
facade alias files; and added focused `pkg/ui` tests. Worker and supervisor
evidence: `go test ./pkg/ui`, `go test ./...`, `git diff --check`, and a
scoped touched-file audit with no `pkg/uikit` import in the new browser
transport files. A host/toolchain `GOOS=js GOARCH=wasm go test ./pkg/ui`
control failed because the local Go install could not resolve `syscall/js`,
so that is recorded as environment proof gap rather than product failure.

Post-browser deletion rerun: worker
`gx-ui-uikit-deletion-rerun-after-browser-resource-mini-20260615a`
(`task-73873cbf5a10`) reran the throwaway deletion/build-exclusion probe on
BusDK `d928c9a`, `bus-ui` `a798a55`, and docs `6fe2449`, with local
`bus-gx`, `bus-help`, and `bus-update` replacements hydrated at the pinned
SHAs. With `pkg/uikit` and `pkg/uikit/uikittest` moved out of the build,
`go test ./...` proved the matrix advances beyond
`pkg/ui/action_resource_facade.go`. The first remaining owner-module blocker
is now `pkg/ui/ai_upload_facade.go:3:8` importing
`github.com/busdk/bus-ui/pkg/uikit`. The worker restored the throwaway
deletion state and left its worktree clean.

AI upload core implementation: `bus-ui` `8540b422`
(`task-d07e3b6f8355`, worker
`gx-ui-core-ui-ai-upload-module-spark-20260616c`) accepted the AI upload slice.
It moved `MultipartUploadFunc`, `AIUploadDecodeFunc`, upload response handling,
JSON error extraction, raw-body fallback, logging, and focused behavior tests
into `pkg/ui`, removing the `pkg/uikit` alias dependency without adding a
compatibility wrapper. Worker and supervisor evidence: `go test ./pkg/ui`,
`go test ./...`, `git diff --check`, and scoped no-`pkg/uikit`/`uikit.` audit
for `pkg/ui/ai_upload_facade.go` and `pkg/ui/ai_upload_facade_test.go`.

Post-AI-upload deletion rerun status: `task-2830eedeed16`, worker
`gx-ui-uikit-deletion-rerun-after-ai-upload-spark-20260616a`, did not produce a
valid compiler matrix. It proved the BusDK worktree was pinned at `b1fe2bf`,
but the required submodules were uninitialized placeholders and GitHub SSH
hydration failed. Treat this as a worker materialization/local-reference
hydration issue, not a product compiler row. Active follow-up
`task-4b39fa3069a7` must rerun the post-AI-upload deletion probe only on a
hydrated BusDK/bus-ui substrate or repair the materialization path first. Do
not start adopter implementation from the post-AI-upload state until that
truth gate names the next matrix row.

Hydrated post-AI-upload module probe: worker
`gx-ui-post-ai-upload-bus-ui-module-probe-spark-20260616b`
(`task-4b39fa3069a7`) reran the throwaway deletion/build-exclusion probe from a
hydrated `bus-ui` module-root substrate at `bus-ui` `8540b42`. With
`pkg/uikit` and `pkg/uikit/uikittest` moved out of the build, `go test ./...`
proved the matrix advances beyond `pkg/ui/ai_upload_facade.go`. The first
remaining owner-module blocker is now `pkg/ui/cli_server_facade.go:8:8`
importing `github.com/busdk/bus-ui/pkg/uikit`, failing setup for `cmd/bus-ui`,
examples, `pkg/terminalui`, and `pkg/ui`. The worker restored the throwaway
deletion state and left its worktree clean.

CLI/server core implementation: `bus-ui` `cad6590`
(`task-b7d461e781f7`; worker
`gx-ui-core-ui-cli-server-facade-spark-20260616b`) accepted the CLI/server
facade slice. The implementation moved CLI runtime, browser-open URL
validation/launcher selection, server logger, client-log HTTP, and server
helper behavior into `pkg/ui` with direct tests, leaving no `pkg/uikit`
alias import in `pkg/ui/cli_server_facade.go`. The post-CLI/server deletion
rerun `task-b5a6128474d0` disabled `pkg/uikit` and `pkg/uikit/uikittest`,
ran `go test ./...`, restored the deletion state, and left its worktree clean.
That hydrated probe proved the matrix advances beyond
`pkg/ui/cli_server_facade.go`; the first remaining owner-module blocker is now
`pkg/ui/data_evidence.go:7:8` importing
`github.com/busdk/bus-ui/pkg/uikit`.

Data/evidence parent blocker: `pkg/ui/data_evidence.go` is broad enough to
track as a parent compiler-derived blocker with explicit child implementation
slices. Child slices count as implementation progress only; the parent row is
not matrix-advanced until `pkg/ui/data_evidence.go` no longer imports
`pkg/uikit` and a hydrated deletion/build-exclusion probe advances beyond it.
Known child slices are:

- tables: dense table and text table types, checked/string/node helpers, and
  generated/adapter render helpers; accepted in `bus-ui` `4db9621`
  (`task-c3b890074557`);
- records surface primitives: minimal `pkg/ui` ownership/export surface needed
  before records/summary can be mechanical, including `SurfaceDensity`,
  `SurfaceTypography`, surface attr validation/helpers, and summary
  badge/status helper ownership; accepted in `bus-ui` `5fcc7a2`
  (`task-f50c7b42b0ba`);
- summary item: `SummaryItemProps`, `SummaryItemChecked`, `SummaryItem`,
  `SummaryItemNodeChecked`, `SummaryItemNode`, and compiled summary-item
  helpers; accepted in `bus-ui` `73e2180`
  (`task-1bdbf523eee1`, supervisor-reviewed execution exception after repeated
  clean/no-diff Mini implementation attempts);
- record list: `RecordListItem`, `RecordListProps`, `RecordListItemSummary`,
  `RecordListChecked`, `RecordList`, `RecordListNodeChecked`,
  `RecordListNode`, and compiled record-list helpers; accepted in `bus-ui`
  `28cdbca` (`task-aa9789a46524`, supervisor-reviewed worker-owned execution
  exception after the Mini lane stayed clean/no-diff);
- evidence: evidence link and evidence preview helpers; accepted in `bus-ui`
  `0f86ae9` (`task-53e82acad2c3`);
- provider error: FC-007 public-safe provider error types, validation,
  redaction, checked/string/node helpers, and compiled render support;
  accepted in `bus-ui` `bff66d6` (`task-227713f52b65`);
- projection detail: FC-020 projection detail types, diagnostics, checked
  result, preview media policy, checked/string/node helpers, and compiled
  render support; accepted in `bus-ui` `5e05955` (`task-31ecd90bb3a0`);
- timeline: timeline types, checked/string/node helpers; accepted in `bus-ui`
  `8a42131` (`task-fd8cb1036793`, supervisor-reviewed worker-owned execution
  exception after the Mini lane stayed clean/no-diff);
- image gallery: image gallery types, validation, checked/string/node helpers;
  accepted in `bus-ui` `ca10596` (`task-96efd1e7f76e`).

Worker `gx-ui-core-ui-data-evidence-spark-20260616a` was stopped as
false-active after no hard-gate/table/diff evidence. Worker
`gx-ui-core-ui-data-evidence-tables-records-spark-20260616a`
(`task-b0e85f067b63`) proved the module-root hard gate and produced a
table/record source map, but was stopped after the implementation turn produced
no diff. Next dispatch should split tighter, starting with a table-only slice,
before any implementation model escalation.

Table-only child implementation: `bus-ui` `4db9621`
(`task-c3b890074557`; worker
`gx-ui-core-ui-data-evidence-tables-only-spark-20260616a`) accepted the dense
and text table subset. The worker moved table types, node-first helpers, and
compiled table render support into `pkg/ui`, removed table `uikit` aliases from
`pkg/ui/data_evidence.go` and `pkg/ui/ui.go`, and preserved the public
node-first behavior expected by `pkg/ui` tests. Primary `bus-ui` verification:
`go test ./pkg/ui`, `go test ./...`, `git diff --check HEAD~1..HEAD`, and the
scoped table-symbol `uikit` audit all passed. The parent
`pkg/ui/data_evidence.go` row remains active because records, evidence
links/previews, projection/provider, timeline, and image gallery children still
need to move before the deletion probe can advance beyond this compiler
blocker.

Records child attempt: worker
`gx-ui-core-ui-data-evidence-records-only-spark-20260616a`
(`task-4c21e99ba4d1`) proved the populated `bus-ui` module root at
`4db9621` and produced a records/summary source map, but produced no
implementation diff after the implementation proceed plus one exact
patch-target nudge. It was parked and the task was closed no-diff/superseded.
The records/summary child remains unfinished. Next records action should be a
tighter supervisor-planned patch target or relaunch, not implementation model
escalation, unless a simplified patch still fails from reasoning complexity.

Records/summary Mini retries:
`gx-ui-core-ui-data-evidence-records-summary-mini-20260616a` stayed clean after
the direct records/summary retry and one exact patch-target nudge.
`gx-ui-core-ui-data-evidence-records-summary-mini-20260616b` passed the
module-root hard gate and produced direct source-map evidence, but also stayed
clean after one exact nudge. Its useful finding was a concrete prerequisite:
records/summary needs minimal package-owned `pkg/ui` surface primitives before
the move can be mechanical, specifically `SurfaceDensity`,
`SurfaceTypography`, surface attr validation/helpers, and summary badge/status
helper ownership. Count that prerequisite as an explicit core child slice next
to records/summary, not as hidden backlog inside a broad records row. Do not
relaunch records/summary implementation until the prerequisite has a
direct-file patch table and either lands or is proven unnecessary by a
supervisor-level plan. If the ownership/API shape remains ambiguous after that
table, use a GPT-5.5 planning/source-map pass for the prerequisite only, then
delegate the simplified implementation to the proved Mini path.
After `5fcc7a2`, worker `gx-ui-records-summary-mini-20260616c`
(`task-e65eff738028`) materialized on the correct base and produced real
source-map reads, but stayed clean after one exact patch-target nudge. Split
the remaining records/summary child into summary-item first, then record-list
on top, rather than relaunching the broad prompt again.
Summary-item child attempt:
`gx-ui-summary-item-mini-20260616a` (`task-92add2acd3f1`) materialized on
accepted base `bus-ui` `5fcc7a2`, proved real source-map reads, and received
one exact patch-target nudge, but remained clean while resolving `gx.Node`
versus local facade node ownership and status-pill/helper ownership. It was
parked as no-diff implementation work. Do not relaunch summary-item
implementation until a supervisor-owned source-map/patch-target table names
the exact owner for node type, status-pill/helper symbols, file targets, alias
removals, and focused tests. Use GPT-5.5 only for that planning/source-map
step if the ownership table is not obvious, then delegate the mechanical
implementation back to the proved Mini path.
The owner table was written at
`logs/worker-prompts/gx-ui-core-ui-data-evidence-summary-item-owner-table-20260616a.md`.
Follow-up worker `gx-ui-summary-item-mini-20260616b`
(`task-3405eea35c59`) materialized on base `bus-ui` `5fcc7a2`, acknowledged
the owner table, and produced source-read evidence from the correct worktree,
but remained clean after an explicit implementation-start message. It was
stopped as no-diff. The summary-item child remains unfinished and should not be
counted as active implementation until the next attempt either carries a
literal patch target that can be applied mechanically or uses a different
execution path with proof that it can write files.
Literal patch target
`logs/worker-prompts/gx-ui-core-ui-data-evidence-summary-item-literal-patch-mini-20260616a.md`
was then dispatched through `gx-ui-summary-item-literal-mini-20260616a`
(`task-1bdbf523eee1`). The worker materialized the correct base and produced
live source-read evidence, but still left the worktree clean after repeated
checkpoints and was stopped. The supervisor then used a narrow execution-path
exception in the stopped worker-owned worktree, applied the already-specified
literal patch, reviewed/promoted it to the primary `bus-ui` checkout, and
amended a render-test fixture to use a GX-supported `span` element instead of
an unsupported generic inline tag. Summary item is accepted in `bus-ui`
`73e2180`; primary-tree verification passed with `go test ./pkg/ui`,
`go test ./...`, `git diff --check HEAD~1 HEAD`, and scoped audits proving no
`pkg/uikit`/`uikit.` use in the new summary-item files and no
`SummaryItem`-backed `uikit` alias remains in `pkg/ui/data_evidence.go` or
`pkg/ui/ui.go`. The parent `pkg/ui/data_evidence.go` row remains active
because record list, projection detail, and timeline children still need to
move before the deletion probe can advance beyond this compiler blocker.

Record-list child implementation: `bus-ui` `28cdbca`
(`task-aa9789a46524`) accepted the record-list subset. The Mini worker
materialized the correct `bus-ui` module root at base `73e2180` and produced
source-map evidence, but stayed clean after the exact patch-target nudge. The
supervisor used the same narrow worker-owned execution exception, moved
`RecordListItem`, `RecordListProps`, `RecordListItemSummary`,
`RecordListChecked`, `RecordList`, `RecordListNodeChecked`,
`RecordListNode`, and compiled/node record-list helpers into `pkg/ui`, and
removed only the record-list `uikit` aliases from `pkg/ui/data_evidence.go`.
Primary-tree verification passed with `go test ./pkg/ui`, `go test ./...`,
`git diff --check HEAD~1 HEAD`, and scoped audits proving no
`pkg/uikit`/`uikit.` use in the new record-list files and no record-list-backed
`uikit` alias remains in `pkg/ui/data_evidence.go` or `pkg/ui/ui.go`. The
parent `pkg/ui/data_evidence.go` row remains active because projection detail
and timeline children still need to move before the deletion probe can advance
beyond this compiler blocker.

Projection-detail child implementation: `bus-ui` `5e05955`
(`task-31ecd90bb3a0`; worker
`gx-ui-projection-detail-mini-20260616a`) accepted the FC-020 projection-detail
subset. The Mini worker materialized on base `28cdbca`, passed the
write-capability gate, produced the implementation diff after one exact nudge,
and was stopped after supervisor review. The implementation moved projection
detail types, diagnostics, checked result, preview media policy,
checked/string/node helpers, and compiled render support into `pkg/ui`, and
removed the projection-detail `uikit` aliases from `pkg/ui/data_evidence.go`.
Primary-tree verification passed with `go test ./pkg/ui`, `go test ./...`,
`git diff --check HEAD~1 HEAD`, and scoped audits proving no
`pkg/uikit`/`uikit.` use in the new projection-detail files and no
projection-detail-backed `uikit` alias remains in `pkg/ui/data_evidence.go` or
`pkg/ui/ui.go`. The parent `pkg/ui/data_evidence.go` row remains active until
the hydrated deletion/build-exclusion probe advances beyond this compiler
blocker.

Timeline child implementation: `bus-ui` `8a42131`
(`task-fd8cb1036793`; worker `gx-ui-timeline-mini-20260616a`) accepted the
timeline subset. The Mini worker materialized on base `5e05955`, passed the
hard gate and source-map reads, but stayed clean/no-diff after the exact patch
nudge, so the supervisor used the reviewed worker-owned execution exception in
the stopped worker tree. The implementation moved timeline types,
checked/string/node helpers, raw-HTML compatibility fallback, and direct tests
into `pkg/ui`, removed the remaining `pkg/uikit` alias import from
`pkg/ui/data_evidence.go`, and removed the `TimelineNodeChecked` facade alias
from `pkg/ui/ui.go`. Primary-tree verification passed with `go test ./pkg/ui`,
`go test ./...`, `git diff --check HEAD~1 HEAD`, and scoped audits proving no
`pkg/uikit`/`uikit.` use in the new timeline files, no timeline-backed `uikit`
alias remains in `pkg/ui/data_evidence.go` or `pkg/ui/ui.go`, and
`pkg/ui/data_evidence.go` no longer imports `pkg/uikit`. The parent
`pkg/ui/data_evidence.go` row remains active only for the hydrated
deletion/build-exclusion probe, which must run before any adopter refill.

Post-data/evidence deletion rerun: worker
`gx-ui-uikit-deletion-probe-mini-20260616a` (`task-47b955f185b1`) verified the
hydrated probe substrate on `bus-ui` `8a42131`. Local replace siblings
`bus-update`, `bus-gx`, `bus-help`, `bus-dev`, `bus-data`, `bus-preferences`,
and `bus-accounts` were present. The worker produced hydration evidence but
stalled before the throwaway move/test/restore step, so the supervisor ran the
probe directly in the worker-owned worktree, moved `pkg/uikit` out of the
build, ran `go test ./...`, and restored the tree clean. The first remaining
setup failure is now `pkg/ui/form_controls.go:9:8` importing
`github.com/busdk/bus-ui/pkg/uikit`, failing setup for `cmd/bus-ui`, examples,
`pkg/terminalui`, `pkg/ui`, and the moved
`pkg/uikit.__disabled_for_probe__/uikittest` package. This proves the matrix
advances beyond `pkg/ui/data_evidence.go`; adopter lanes remain parked until
the form-controls blocker lands and the next deletion probe names the matrix
state.

Evidence child implementation: `bus-ui` `0f86ae9`
(`task-53e82acad2c3`; worker
`gx-ui-core-ui-data-evidence-evidence-only-spark-20260616a`) accepted the
FC-018 evidence link and FC-019 evidence preview subset. The worker moved
evidence types/constants, link and preview checked helpers, node-first helpers,
and preview policy helpers into `pkg/ui`, removed evidence `uikit` aliases from
`pkg/ui/data_evidence.go`, and preserved the public node-first behavior
expected by `pkg/ui` tests. Primary `bus-ui` verification: `go test ./pkg/ui`,
`go test ./...`, `git diff --check HEAD~1..HEAD`, and the scoped
data-evidence evidence-symbol `uikit` audit all passed. The broader
`shell_evidence_facade.go` resolver aliases remain out of scope for this
parent blocker. The parent `pkg/ui/data_evidence.go` row remains active because
records/summary, projection/provider, and timeline children still need to move
before the deletion probe can advance beyond this compiler blocker.

Image-gallery child implementation: `bus-ui` `ca10596`
(`task-96efd1e7f76e`; worker
`gx-ui-core-ui-data-evidence-image-gallery-only-spark-20260616c`) accepted the
FC-022 image-gallery subset. The worker moved image-gallery types,
diagnostics, validation, string render helpers, and node-first helpers into
`pkg/ui`, removed image-gallery `uikit` aliases from
`pkg/ui/data_evidence.go` and `pkg/ui/ui.go`, and preserved the public
node-first behavior expected by `pkg/ui` tests. Primary `bus-ui`
verification: `go test ./pkg/ui`, `go test ./...`,
`git diff --check HEAD~1..HEAD`, and the scoped image-gallery alias audit all
passed. The parent `pkg/ui/data_evidence.go` row remains active because
records/summary, projection detail, and timeline children still
need to move before the deletion probe can advance beyond this compiler
blocker.

Provider-error child implementation: `bus-ui` `bff66d6`
(`task-227713f52b65`; worker
`gx-ui-core-ui-data-evidence-provider-error-only-spark-20260616a`) accepted the
FC-007 provider-error subset. The worker moved public-safe provider-error
types, validation, redaction, checked/string/node helpers, and compiled render
support into `pkg/ui`, removed provider-error `uikit` aliases from
`pkg/ui/data_evidence.go`, and preserved the public behavior expected by
`pkg/ui` tests. Primary `bus-ui` verification: `go test ./pkg/ui`,
`go test ./...`, `git diff --check HEAD~1..HEAD`, and the scoped provider
alias audit all passed. The parent `pkg/ui/data_evidence.go` row remains
active because records/summary, projection detail, and timeline children still
need to move before the deletion probe can advance beyond this compiler
blocker.

Projection/provider broad attempt:
`gx-ui-core-ui-data-evidence-projection-provider-spark-20260616a`
(`task-13b3df79049f`) materialized a populated `bus-ui` module checkout at
`ca10596` and produced session JSONL source-map evidence, but remained clean
after one exact patch-target nudge and repeated wrong-path tool calls. It was
stopped as false-active implementation work. The former projection/provider
row is split into provider-error and projection-detail children; provider-error
was accepted in `bus-ui` `bff66d6`, so projection detail remains unfinished.

Timeline child attempt:
`gx-ui-core-ui-data-evidence-timeline-only-spark-20260616a`
(`task-f912eb9d264e`) materialized a populated `bus-ui` module checkout at
`0f86ae9`, but produced no assistant hard-gate/source-map output and no diff
after the initial prompt plus one exact patch-target nudge. It was closed
no-diff/superseded. The timeline child remains unfinished and should be
relaunched with a tighter supervisor-planned patch target before any
implementation model escalation.

Timeline retry:
`gx-ui-core-ui-data-evidence-timeline-only-spark-20260616b`
(`task-004ed7d427ba`) also materialized `bus-ui` at `0f86ae9`, but stayed
clean and produced no assistant hard-gate/source-map output or diff; its logs
showed tool/path and regex errors. It was closed no-diff/superseded. Timeline
remains unfinished; the next attempt should avoid globs/regex-heavy discovery
or first diagnose the worker command path.

Image gallery child attempt:
`gx-ui-core-ui-data-evidence-gallery-only-spark-20260616a`
(`task-48782bcc6e1a`) materialized `bus-ui` at `0f86ae9`, but stayed clean and
produced no assistant hard-gate/source-map output or diff after the initial
prompt plus one exact patch-target nudge. Its App Server logs showed duplicate
`workdir` tool argument and missing-file tool-router errors. This failed
attempt is superseded by the accepted image-gallery child `ca10596`; more
same-shape implementation workers should be parked when they repeat
tool-router failures.

Image gallery alternate-runtime attempt:
`task-6219bd0a2c51` tried to keep the same already-scoped gallery patch target
while changing execution path. `codex-direct` was rejected by the local Workers
API as an unsupported runner pair. `bus-agent-runtime` with `--prompt-file`
failed before materialization because the prompt file was not in its allowed
roots. `bus-agent-runtime` with inline prompt materialized `bus-ui` at
`0f86ae9`, but routed `gpt-5.3-codex-spark` to the local
OpenAI-compatible endpoint `127.0.0.1:11434`, which refused the connection.
No patch was produced. This failed attempt is superseded by the accepted
image-gallery child `ca10596`; the reusable lesson is to prove the worker path
with direct session JSONL and diff/test evidence before counting it active.

Before calling the goal complete, run a fresh repository-wide audit across all
BusDK modules that apps may use, including at least:

```bash
git grep -nE 'pkg/uikit|Checked|NodeChecked|BodyHTML|HeadHTML|MainHTML|ui\.Unsafe|ui\.VRaw|TrustedMarkdownHTML|strings\.Replace|slot|post-render' \
  -- bus-ui bus-portal bus-portal-auth bus-portal-ai bus-portal-accounting bus-portal-notes bus-factory bus-gateway bus-inspection bus-ledger bus-chat docs busdk.com
```

Then classify every hit as one of:

- intentional new public/internal implementation;
- test harness that still needs replacement;
- vendor or generated content to ignore;
- stale docs;
- active code that still needs refactoring.

## Module Ownership

`bus-gx` owns:

- GX source syntax and compiler behavior;
- intrinsic element allowlists and safe attributes;
- render-tree types;
- HTML rendering;
- low-level trusted leaf boundaries;
- browser/runtime primitives and low-level test utilities.

`bus-ui` owns:

- reusable components in `pkg/ui`;
- public assistant, terminal, and portal facades;
- temporary migration adapters only while behavior is being moved out of
  `pkg/uikit`; unpublished/internal-only compatibility is not a reason to keep
  old packages or aliases;
- CSS hooks;
- mount/runtime helpers;
- portal integration surfaces;
- UI test harnesses and docs for reusable components.

Product modules own product-specific routing, authorization, provider
behavior, business object semantics, billing, model execution, secrets, and
product-specific handlers. They should compose UI through `bus-ui` facades
instead of depending on `pkg/uikit` or raw shell slots.

## Evidence Sources

The main remote Codex thread for this goal is:

```text
019eb0e6-b207-7c30-9998-d7d16214e9a6
```

The exact short `UI library` Codex threads from June 12 are archived fork or
worker lanes. They are part of the history, but they are not the full
supervisor story.

On `nor-agent`, useful Codex state is split across:

- `~/.codex/state_5.sqlite` for thread metadata;
- `~/.codex/logs_2.sqlite` for low-level streaming telemetry;
- `~/.codex/sessions/**/rollout-*.jsonl` for practical transcript content.

The final June 14 worker wave around `019ec74*` had transcript JSONL files
even when the state DB query did not return matching thread rows. Use both
SQLite and session JSONL files when reconstructing context.

Remote supervisor memos under:

```text
~/git/busdk/agent-supervisor/logs/
```

are the most compact source for accepted/promoted state, rejected worker
attempts, and branch/worktree meaning.

## Accepted Architecture Work

The June 2026 remote memos record these accepted phases as already promoted
into canonical module `develop` branches:

- `bus-gx` document/head intrinsics for `html`, `head`, `body`, `title`,
  `meta`, and `link`;
- `bus-gx` description-list intrinsics for semantic `dl`, `dt`, and `dd`;
- `bus-gx` form `enctype` support for multipart upload forms;
- `bus-gx` safe typed script-node support;
- `bus-gx` trusted markdown/article HTML leaf support with corrected raw
  literal tests;
- `bus-ui` node-first shell/navigation/status facades;
- `bus-ui` node-first form/control facades;
- `bus-ui` node-first data/evidence/display facades, including later
  ProjectionDetail support after the `bus-gx` `dl` intrinsic unblocker;
- `bus-ui` assistant and terminal node-first facades;
- `bus-ui` AppShell and terminal architecture promotion;
- `bus-ui` typed deferred script/head helpers;
- `bus-ui` trusted markdown/article public boundary;
- `bus-ui` `SubmitControl` node-first facade;
- `bus-portal` node-first framework and portal shell adoption;
- `bus-portal-auth` typed deferred script adoption;
- `bus-portal-ai` render composition and typed script/head adoption;
- `bus-portal-accounting` node-first render path adoption;
- `bus-portal-notes` trusted reader and review-panel node-first cleanup;
- docs and SDD notes for deferred script/head-node behavior.

The remote conflict repair on 2026-06-14 pushed the current canonical state:

- `bus-ui develop` at `2a7beda`;
- `bus-portal-notes develop` at `0a01711`;
- `docs develop` at `dd55b02`;
- `sdd develop` at `e0b190d`;
- BusDK superproject `develop` at `3e09443`;
- remote supervisor `nor-develop` at `e604168`.

The stale `bus-ui` rebase conflict was resolved by aborting the duplicate
rebase. `bus-ui` was then clean on `develop`, `git diff --check
origin/develop..HEAD` passed, `/usr/local/go/bin/go test ./...` passed, and
`git push origin develop` advanced the remote from `c0c6d08` to `2a7beda`.

## Final Audit Wave

The final June 14 audit found remaining old-architecture residue and split it
into focused workers:

- `019ec74a-f07c-7832-9cf2-fe6fa5f81a7b`, `AI portal private NodeChecked
  cleanup`: created `/private/tmp/bus-portal-ai-nodechecked-cleanup` on
  `codex/ai-portal-private-nodechecked-cleanup`, verified the hits were
  private helper names, but applied no code before hitting the usage limit.
- `019ec74b-2005-7453-9ff8-9352c209efb5`, `Notes review raw UI cleanup`:
  created `/private/tmp/bus-portal-notes-review-raw-cleanup` on
  `codex/notes-review-raw-cleanup`, changed
  `notes_reader_review_render.go`, passed `gofmt`, `git diff --check`, and a
  banned-added-line scan, but its module test run hit surrounding baseline
  compile errors and it reported accidental canonical checkout dirt before
  the path correction.
- `019ec74b-51dd-7270-9e35-e09b92e85be6`, `Notes shell slot replacement
  cleanup`: produced a broader in-progress
  `/private/tmp/bus-portal-notes-shell-slots` worktree. The shell paths moved
  toward typed GX node composition, `bus gx fmt --check` and `git diff
  --check` had passed, but tests still failed on a missing `ResultPanel`
  marker and the worker hit the usage limit before committing.
- `019ec74b-7ec8-7591-98b6-0935fd8bf891`, `Adopter tests remove uikit
  imports`: identified remaining test imports and missing public
  runtime/resource-client facades, but did not create a patch before the
  usage limit.
- `019ec74b-ee6b-72d3-b074-a65c63729ef8`, `Assistant UI public API cleanup`:
  produced commit `402cfa9` in
  `/private/tmp/bus-ui-assistantui-api-cleanup`, passed focused/full tests and
  `git diff --check`, and remains a real review/promotion candidate unless a
  later canonical change supersedes it.
- `019ec74c-1af5-7910-b80f-8676de101989`, `UI portal shell API cleanup`:
  created no files, no tests, and no commit before the usage limit.
- `019ec74c-517e-7373-8edd-8abfbf7585ed`, `GX UI docs old API cleanup`:
  changed no files before the usage limit. It reported remaining public docs
  hits in `busdk.com/docs/gx-ui/**`, `docs/docs/products/gx-ui.md`,
  `docs/docs/modules/bus-ui.md`, and some Bus UI leaf pages. Vendor hits under
  `sdd/vendor/**` should be ignored.

## Current Remote Git State

After the 2026-06-14 cleanup audit, many old contained or patch-equivalent
branches were removed from `nor-agent`. The cleanup intentionally used only:

- non-force `git worktree remove` for clean, contained worktrees;
- non-force `git branch -d` for contained local branches;
- `git branch -D` only after `git log --cherry-pick --right-only --no-merges
  develop...branch` showed no unique patches.

The filtered submodule state dropped substantially:

- `docs` no longer showed UI branch/worktree residue.
- `bus-gx` no longer showed UI branch/worktree residue.
- `bus-portal` no longer showed UI branch/worktree residue.
- `bus-ui` dropped from 27 worktrees and 31 branches to 6 worktrees and
  5 branches.

Remaining state is not routine pruning; it needs review or archival decisions.

### Remaining `bus-ui` Items

Current local re-audit at `2026-06-15 12:54 EEST` found the old branch/worktree
items from this section no longer present in the primary `bus-ui` checkout.
`/private/tmp/bus-ui`, `/private/tmp/bus-ui-terminalui-node-first`,
`/private/tmp/bus-ui-assistantui-api-cleanup`, and
`/private/tmp/bus-ui-script-helper` are gone. The primary module has only
`develop`, `main`, origin remotes, and the accepted
`remotes/worker/gx-ui-action-resource-facade-20260615a` ref.

The previous `codex/assistantui-public-api-cleanup` item is resolved:
`402cfa9` is already an ancestor of both local `bus-ui/develop` and
`origin/develop`. The remaining active `bus-ui` work is not branch pruning; it
is the two core facade tasks:

- `task-646c27a30fb6`: complete the public `pkg/terminalui`
  terminal/container runtime facade.
- `task-84d0842bbbff`: complete the public `pkg/ui`
  runtime/server/CLI/WASM helper facades.

### Remaining Website Docs Items

Current local re-audit found `busdk.com` clean on `develop` with no local
GX/UI docs branches or extra worktrees. The earlier
`codex/gx-ui-node-first-docs` branch work is represented in `develop` and
`origin/develop` by the current GX/UI docs commits, including `7e0a54b`
(`Refine GX/UI docs navigation`). There is no remaining local website-docs
promotion branch to review in this checkout.

### Remaining Portal Adopter Items

The old local adopter branches listed in earlier audits are no longer present
in the primary module checkouts. `bus-portal-ai`, `bus-portal-accounting`, and
`bus-portal-notes` are clean on `develop` with only origin remotes. `bus-portal-auth`
keeps one archival branch, `codex/leaked-auth-primary-20260615a`, with two
unique pre-review commits from the earlier primary-checkout leak; accepted
Auth cleanup is instead `edad787` on `develop`, so the leak branch is evidence,
not a promotion candidate.

Current adopter cleanup is therefore tracked by task/work items rather than
old local branches:

- `bus-portal-ai`: active cleanup remains open as `task-25bee17f4cd1`; the
  retry worker has a partial dirty submodule diff that is not accepted.
- `bus-portal`: active cleanup remains open as `task-62c09a117f80`.
- `bus-portal-notes`: runtime/reducer cleanup is tracked as
  `task-fe70fd4546fd`.

### Remaining BusDK Root Items

The BusDK root still has several old non-contained superproject pin branches
with unique commits, plus dirty contained evidence worktrees. They mostly
record old docs/site pointer states. Review them after the module branches are
classified so pointer branches can be deleted with confidence.

Several GX/UI Bus worker runtime product worktrees remain dirty under
`.bus/services/workers/runtime/gx-ui-*/product-worktree`. Some correspond to
accepted lanes whose commits were already cherry-picked into primary modules;
some correspond to rejected or partial lanes, such as the dirty AI retry
submodule diff. They are evidence/cleanup inventory, not current promotion
candidates, and should be archived or explicitly discarded only after recorded
classification.

The local `2026-06-15 13:04 EEST` `bus workers prune-report` classified all
GX/UI runtime product worktrees as `active/refuse`; none are pruneable while
their workers remain cataloged as active. Source inspection classified the
current evidence like this:

- Accepted/evidence-only lanes:
  - `gx-ui-ui-action-resource-spark-20260615a` points at accepted
    `bus-ui` commit `de5b75a`.
  - `gx-ui-terminalui-spark-20260615b` has the same subject and stat shape as
    accepted `bus-ui` commit `de8fdd6`; `gx-ui-terminalui-spark-20260615a`
    is the older superseded attempt.
  - `gx-ui-uiportal-spark-20260615a` has the same subject and stat shape as
    accepted `bus-ui` commit `8b8ceb3`.
  - `gx-ui-accounting-uikit-spark-20260615b` has the same subject and stat
    shape as accepted `bus-portal-accounting` commit `e5eac44`;
    `gx-ui-accounting-uikit-spark-20260615a` is an older narrower attempt.
  - `gx-ui-auth-uikit-spark-20260615b` is superseded by accepted
    `bus-portal-auth` commit `edad787`; `gx-ui-auth-uikit-spark-20260615a`
    still contains the earlier leaked/partial uncommitted Auth diff.
  - `gx-ui-notes-slots-spark-20260615b` is superseded by accepted
    `bus-portal-notes` commit `727d868`; `gx-ui-notes-slots-spark-20260615a`
    still contains the earlier uncommitted slot-replacement attempt.
- Active unfinished lanes:
  - `gx-ui-terminal-runtime-facade-spark-20260615a` and
    `gx-ui-runtime-facade-spark-20260615a` are clean but produced no useful
    assistant output before Spark quota exhaustion; they remain the core
    post-reset priority.
  - `gx-ui-ai-uikit-spark-20260615a` and `gx-ui-ai-uikit-spark-20260615b`
    contain uncommitted `bus-portal-ai/pkg/aiportal/actions.go`,
    `terminal_runtime.go`, and `wasm_runtime_js.go` diffs from rejected/partial
    attempts. Keep as cautionary evidence until the terminal facade exists.
  - `gx-ui-portal-uikit-spark-20260615a` contains the rejected wrapper-layer
    Portal attempt in `internal/cli`, `internal/run`, `internal/server`, and
    `internal/ui/wasm`; `gx-ui-portal-uikit-spark-20260615b` is the clean
    retry lane that should continue only after the `pkg/ui` helper facade
    lands.

At `2026-06-15 13:08 EEST`, the stale accepted/superseded workers were stopped
through `bus workers stop --environment local-dev` while preserving their
worktrees and branches as evidence: Accounting `a`/`b`, Auth `a`/`b`, Notes
shell slots `a`/`b`, TerminalUI `a`/`b`, UI action/resource, UIPortal, Portal
first attempt, and AI first attempt. Individual `bus workers status <id>
--environment local-dev` calls report these workers as `stopped`, but bulk
`bus workers list` and `bus workers prune-report` still showed several of them
as active immediately afterward. Until that projection mismatch is fixed or
catches up, treat individual worker status as the lifecycle source of truth and
do not prune from `prune-report` output alone.

At `2026-06-15 13:13 EEST`, the two remaining open superseded task threads
were closed: `task-1a7b83afdf83` (Accounting first attempt, superseded by
accepted `task-48bad54789fe`/`e5eac44`) and `task-4b5c8c140b68` (Auth first
attempt/leak evidence, superseded by accepted `task-25f66a4e0036`/`edad787`).
Accepted tasks for action/resource, TerminalUI, UIPortal, Accounting retry,
Auth retry, and Notes shell cleanup were already closed. The open GX/UI board
is now limited to actual unfinished work plus the Notes runtime task.

At `2026-06-15 13:15 EEST`, the five remaining open GX/UI task threads were
seeded with post-reset supervisor guidance:

- `task-646c27a30fb6`: exact `pkg/terminalui` runtime facade scope and DoD.
- `task-84d0842bbbff`: exact `pkg/ui` CLI/server/WASM helper facade scope and
  DoD.
- `task-25bee17f4cd1`: AI cleanup must wait for accepted/pinned core facades
  and must not import `pkg/terminalruntime` or hide `pkg/uikit` behind local
  aliases.
- `task-62c09a117f80`: Portal cleanup must wait for the accepted/pinned
  `pkg/ui` helper facade and must not use local wrapper files to hide `uikit`.
- `task-fe70fd4546fd`: Notes runtime cleanup should dispatch after the core
  `pkg/ui` facade is sufficient and should stay production-focused.

At `2026-06-15 13:18 EEST`, `gx-ui-notes-runtime-spark-20260615a` was created
for `task-fe70fd4546fd` with `gpt-5.3-codex-spark`, module
`bus-portal-notes`, branch `codex/gx-ui-notes-runtime-cleanup-20260615a`, and
`no_initial_message=true`. Its individual status reached `running`/`ready`.
Do not message it until the core `pkg/ui` facade is accepted and pinned.

At `2026-06-15 13:25 EEST`, the dirty AI retry worker
`gx-ui-ai-uikit-spark-20260615b` was stopped and preserved as evidence because
its module worktree still contained the rejected partial `actions.go`,
`terminal_runtime.go`, and `wasm_runtime_js.go` diff. A clean replacement,
`gx-ui-ai-uikit-spark-20260615c`, was created for `task-25bee17f4cd1` with
`no_initial_message=true` on branch `codex/gx-ui-ai-uikit-cleanup-20260615c`.
Its individual status reached `running`/`ready`, and its `bus-portal-ai` module
worktree is clean.

The intentionally remaining live GX/UI product workers after this cleanup are:

- `gx-ui-terminal-runtime-facade-spark-20260615a`
  (`task-646c27a30fb6`);
- `gx-ui-runtime-facade-spark-20260615a` (`task-84d0842bbbff`);
- `gx-ui-ai-uikit-spark-20260615c` (`task-25bee17f4cd1`);
- `gx-ui-portal-uikit-spark-20260615b` (`task-62c09a117f80`);
- `gx-ui-notes-runtime-spark-20260615a` (`task-fe70fd4546fd`).

`agents/worker` shows many `worker/*` branches and worktrees, but these are
worker identity checkouts at the shared `Initialize worker identity` commit.
Remote `AGENTS.md` says worker identity checkouts under
`.bus/services/workers/runtime/*/worker-identity` are durable supervisor
evidence, not disposable scratch. Do not prune those as part of this GX/UI
cleanup unless the operator approves a separate retention-policy task.

## 2026-06-15 Local Supervisor Update

The local re-audit found that adopter cleanup was blocked by a missing
`bus-ui/pkg/ui` public action/resource facade. Product modules such as
`bus-portal-auth`, `bus-portal-accounting`, and `bus-portal-ai` needed action
state, resource request/result, browser/WASM fetch, multipart upload, and
result-helper primitives that were available only through `pkg/uikit` or only
partially exposed through `pkg/ui`.

That core-library dependency has now been accepted locally:

- `bus-ui` `de5b75a`, `ui: expose action resource facade`, adds the public
  `pkg/ui` action/resource facade used by adopter cleanup workers;
- `bus-ui` `de8fdd6`, `terminalui: mark checked wrappers as migration shims`,
  marks terminal `*Checked`/`*NodeChecked` helpers as deprecated migration
  wrappers and adds parity coverage for node-first and HTML-boundary outputs;
- `bus-ui` `8b8ceb3`, `uiportal: enforce node-first portal shell wrapper
  parity`, adds uiportal compatibility parity coverage and records the
  preferred node-first APIs in `PLAN.md`;
- `bus-portal-notes` `727d868`, `notes: compose shell surfaces with gx nodes`,
  removes normal-path string slot replacement from the active Notes shell/page
  composition and renders through node-first `ui.AppShell`/`ui.RenderHTML`.
- `bus-portal-auth` `edad787`, `authportal: use ui action resource facades`,
  removes active production `pkg/uikit` imports from requested Auth UI/runtime
  files and verifies normal package tests plus WASM compile-only output.
- `bus-portal-accounting` `e5eac44`, `accountingportal: use ui action
  resource facades`, removes active production `pkg/uikit` imports from the
  requested Accounting action/resource/browser/WASM files and verifies normal
  package tests plus WASM compile-only output.

These accepted commits are pinned by local BusDK superproject commits through
`8c3e154`. They are local until pushed.

The public `pkg/ui` action/resource facade acceptance criteria were:

- expose the stable action/resource runtime surface through `pkg/ui` without
  requiring Go 1.23 generic type aliases;
- avoid name conflicts with existing UI component facades such as
  `ui.ProviderError`;
- include missing constants/helpers already needed by adopters, such as
  `ResourceMethodPost`, `ResourceMethodUpload`, `ButtonGhost`, action state
  and `RunAction`, resource clients/results, multipart payloads, and WASM
  resource fetch helpers;
- prove the facade with focused `pkg/ui` tests before rebasing adopter
  cleanup workers.

Local Spark workers were started for these current slices:

- `bus-ui` terminalui public node-first API;
- `bus-ui` uiportal public node-first API;
- `bus-ui` `pkg/ui` action/resource facade;
- `bus-portal-notes` shell/page slot replacement;
- `bus-portal-auth` active `pkg/uikit` import cleanup;
- `bus-portal-accounting` active `pkg/uikit` import cleanup.

After the core facade landed, fresh local Spark workers were also started for:

- `bus-portal-ai` active `pkg/uikit` import cleanup;
- `bus-portal` active `pkg/uikit` import cleanup.

The first local AI and Portal retry attempts were rejected during review. The
AI attempt mixed `terminalui` facade aliases with `terminalruntime` internals
and made `pkg/aiportal` compile-broken. The Portal attempt mostly moved
`pkg/uikit` imports into local wrapper files and also failed to compile. Clean
Spark retry workers were then launched on new branches with narrower
instructions: keep code compiling, do not hide `uikit` behind local wrappers,
and document exact missing public facades instead of forcing broken rewrites.

A later audit showed the clean AI/Portal retry lanes still need additional
core `bus-ui` public facade work before adopter cleanup can finish cleanly:

- `pkg/terminalui` needs a complete terminal/container runtime facade for
  stream result/transport/request/reader, resource client, lifecycle, and
  error symbols so `bus-portal-ai` can leave `pkg/uikit` without importing or
  mixing `terminalruntime` internals incorrectly.
- `pkg/ui` needs public runtime/server/CLI/WASM helper facades for Portal
  helpers such as global CLI flag parsing, immediate/serve output writers,
  browser open, token/static/server helpers, client log/server logger helpers,
  and JS/WASM helpers such as document/location/API URL/gateway client/mount
  helpers.
- `bus-portal-notes` still has production `pkg/uikit` dependencies in
  `runtime_reducer.go`, `runtime.go`, and `view_models.go`. This was not part
  of the accepted shell/page slot cleanup and is now tracked separately as
  `task-fe70fd4546fd`.

The local `2026-06-15 13:00 EEST` source re-audit narrowed the remaining
production ownership further:

- `bus-portal-ai/pkg/aiportal/actions.go` should move action/resource/result
  usage to the public `pkg/ui` facade that already exists.
- `bus-portal-ai/pkg/aiportal/terminal_runtime.go` and
  `bus-portal-ai/pkg/aiportal/wasm_runtime_js.go` still depend on terminal and
  container stream/resource types and helpers through `pkg/uikit`; they should
  wait for the `pkg/terminalui` runtime facade instead of importing
  `pkg/terminalruntime` directly.
- `bus-portal/internal/cli/flags.go`, `internal/run/run.go`,
  `internal/server/server.go`, `internal/server/logging.go`,
  `internal/ui/wasm/app.go`, and `internal/ui/wasm/launcher.go` still depend on
  `pkg/uikit` for CLI, server/static/token, logging, browser-open, runtime URL,
  gateway, global document/location, and mount helpers; they should migrate to
  `pkg/ui` only after those helpers are public there.
- `bus-portal-notes/runtime_reducer.go`, `runtime.go`, and `view_models.go`
  remain the only Notes production files with active `pkg/uikit` dependencies
  outside stylesheet URL strings. Notes tests still use `uikit`/`uikittest`,
  but the immediate adopter DoD is production cleanup plus focused tests.

A follow-up local `2026-06-15 13:29 EEST` file-level audit found the same
active production residue, plus expected test-only and stylesheet URL hits.
The active production files still needing adopter cleanup are:

- `bus-portal-ai/pkg/aiportal/actions.go`;
- `bus-portal-ai/pkg/aiportal/terminal_runtime.go`;
- `bus-portal-ai/pkg/aiportal/wasm_runtime_js.go`;
- `bus-portal/internal/cli/flags.go`;
- `bus-portal/internal/run/run.go`;
- `bus-portal/internal/server/logging.go`;
- `bus-portal/internal/server/server.go`;
- `bus-portal/internal/ui/wasm/app.go`;
- `bus-portal/internal/ui/wasm/launcher.go`;
- `bus-portal-notes/runtime_reducer.go`;
- `bus-portal-notes/runtime.go`;
- `bus-portal-notes/view_models.go`.

`bus-portal/pkg/portal/contract.go` still contains the
`assets/uikit.css` URL string and is not itself an architecture blocker.
Notes render/runtime tests still import `uikit` or `uikittest`; migrate them
only after the production path and core facades are settled.

A broader pre-reset DoD-pattern audit at `2026-06-15 13:38 EEST` added these
post-core cleanup candidates:

- Adopter tests still import or call `pkg/uikit`/`uikittest` in
  `bus-portal` (`internal/server/server_test.go`, `pkg/portal/framework_test.go`,
  `module_test.go`, `uiportal_test.go`), `bus-portal-auth`
  (`browser_client_test.go`, `e2e_fake_provider_test.go`, `module_test.go`,
  `mountedapp_test.go`), `bus-portal-ai` (`actions_test.go`,
  `mountedapp_test.go`, `terminal_runtime_test.go`, `ui_prep_artifact_test.go`),
  `bus-portal-accounting` (`module_test.go`, `mountedapp_test.go`), and
  `bus-portal-notes` (`notes_filter_toolbar_render_test.go`,
  `notes_page_surfaces_render_test.go`, `render_gx_test.go`, `runtime_test.go`).
  Treat these as a separate test-harness migration wave after production
  adopter cleanup.
- `bus-portal-accounting/pkg/accountingportal/wasm_app_js.go` still uses
  public `ui.ErrorBannerChecked` and `ui.StatusPillChecked` in production
  WASM rendering. This is not a direct `pkg/uikit` import, but it should be
  converted to the plain node-first `pkg/ui` helpers plus an explicit render
  boundary after the immediate `pkg/uikit` production imports are gone.
- Public docs still need a final post-API audit. `busdk.com/PLAN.md` keeps
  open GX/UI website items to replace primary `*Checked` examples and stop
  teaching `pkg/uikit` as the long-term path; `docs/docs/ui/**` still contains
  older versioned pages that mention `pkg/uikit`, `BodyHTML`, and checked
  helpers. Some are legitimate migration/history notes, but they need a
  final classification pass after code APIs settle.
- `bus-ui` itself still contains many `*Checked`, `*NodeChecked`, `BodyHTML`,
  and `pkg/uikit` references. Current accepted architecture treats those as
  internal implementation, deprecated migration wrappers, or compatibility
  tests unless a public/default API or current docs page teaches them as the
  preferred path. Do not spend adopter-worker time removing internal
  compatibility coverage before the product modules are clean.

Current core worker guidance should keep the core slices separate. At
`2026-06-15 13:46 EEST`, the operator approved switching the two core lanes to
`gpt-5.4-mini` instead of waiting for the `gpt-5.3-codex-spark` quota reset.
The active core workers are now
`gx-ui-terminal-runtime-facade-mini-20260615a` for `task-646c27a30fb6` and
`gx-ui-runtime-facade-mini-20260615a` for `task-84d0842bbbff`. The previous
Spark core workers are superseded evidence unless a later supervisor
explicitly reopens them.

At `2026-06-15 13:58 EEST`, the TerminalUI core lane was accepted and promoted:
worker commit `640ca05` became primary `bus-ui` commit `74650fd`, `Add
terminalui runtime facade exports`. It adds the public `pkg/terminalui`
resource kind/method/client aliases, normalize/validate helpers, terminal
stream transport/lifecycle/result aliases, container lifecycle aliases,
shared terminal/container error sentinels, focused facade tests, and
`FEATURES.md`/`sdd/docs/modules/bus-ui.md` documentation. Supervisor
verification on the promoted primary checkout passed `git diff --check
HEAD~1..HEAD`, `go test ./pkg/terminalui -count=1`, and `go test ./...`.

At `2026-06-15 14:10 EEST`, the `pkg/ui` runtime facade lane was accepted and
promoted. Worker commits `34d9cf0` and `b95d1ac` became primary `bus-ui`
commits `0a457ed`, `Expose public ui runtime facades`, and `12e5cdf`, `Remove
completed ui facade plan item`. The accepted work exposes the Portal-needed
public `pkg/ui` facade for CLI/global flag helpers, immediate/serve output
writers, browser-open helpers, capability-token/static/listener helpers,
server logger/client-log helpers, gateway/API URL helpers, WASM browser-global
and mount helpers, and the Portal launcher empty-state helper, with focused
tests plus `FEATURES.md`, `docs/docs/modules/bus-ui.md`, and
`sdd/docs/modules/bus-ui.md` updates. Supervisor verification on the promoted
primary checkout passed `git diff --check HEAD~2..HEAD`,
`go test ./pkg/ui -count=1`, and `go test ./... -count=1`. A js/wasm compile
probe could not be completed because this host's Go install currently fails
`go list syscall/js`; the same failure reproduces on the pre-existing
`pkg/uikit` WASM package, so treat that as a host/toolchain proof gap rather
than a patch-specific regression.

Both core facade lanes are now accepted locally and pinned in `bus-ui`.
AI, Portal, and Notes adopter production cleanup may resume against those
public facade commits.

Keep the core slices separate:

- For `task-646c27a30fb6`, accepted locally as `bus-ui` commit `74650fd`.
  Follow-up adopter work may consume this public `pkg/terminalui` surface, but
  do not reopen this lane unless review later finds a regression.
- The accepted TerminalUI scope owned only `bus-ui/pkg/terminalui/**` plus
  focused `bus-ui` docs/features/tests needed by module guidance. The
  `2026-06-15 13:35 EEST` source audit found that `pkg/terminalui` already
  exposes the terminal input/resize/close request builders,
  container-run request/effect builders, terminal stream effect builder, SSE
  decoder, and AI terminal event/session builders. The remaining facade gap is
  the public names downstream AI still uses directly from `pkg/uikit`:
  `ResourceKind`, `ResourceMethod`, `ResourceClient`, `ResultResourceClient`,
  `NormalizeResourceRequest`, `ValidateResourceRequest`,
  `ValidateResourcePath`, `ValidateResourceBase`,
  `TerminalStreamRequest`, `TerminalStreamReader`,
  `TerminalStreamTransport`, `TerminalStreamLifecycle`,
  `TerminalStreamResult`, the `TerminalStreamLifecycle*` constants,
  `ContainerRunLifecycle`, the `ContainerRunLifecycle*` constants, and the
  shared terminal/container errors such as `ErrTerminalStreamSessionRequired`,
  `ErrTerminalStreamTransportRequired`, `ErrTerminalStreamReaderRequired`,
  `ErrTerminalStreamAborted`, `ErrTerminalStreamReconnect`,
  `ErrTerminalStreamDecode`, `ErrTerminalRuntimeInvalidDimensions`,
  `ErrContainerRunProfileRequired`, and `ErrContainerRunArgsInvalid`. Do not
  change `bus-portal-ai` in this worker.
- For `task-84d0842bbbff`, accepted locally as `bus-ui` commits `0a457ed` and
  `12e5cdf`. Follow-up adopter work may consume this public `pkg/ui` surface,
  but do not reopen this lane unless review later finds a regression.
- The accepted `pkg/ui` scope owned only `bus-ui/pkg/ui/**` plus focused
  `bus-ui` docs/features/tests needed by module guidance. It re-exported or
  wrapped the public helper contracts needed by Portal from `pkg/uikit`:
  `GlobalCLIFlags`,
  `ParseGlobalCLIFlags`, `ValidateGlobalCLIFlags`,
  `WriteImmediateCLIOutput`, `ResolveServeOutputWriter`, `OpenURLInBrowser`,
  browser-open types/errors/helpers, capability-token/static/content-type
  helpers (`GenerateCapabilityToken`, `ListenTCP`, `TokenURLFromListener`,
  `TokenPathSuffix`, `ServeStaticWithIndexFallback`, `ContentTypeForName`),
  server logger/client-log helpers (`ServerLogger`, `ServerLoggerOptions`,
  `ClientLogHandler`, `ServeClientLogAPI`), browser globals
  (`GlobalDocument`, `GlobalLocation` and any existing accessor types needed
  by tests), runtime API URL helpers (`ResolveAPIURL`, and WASM `APIURL` if
  needed), gateway client helpers (`URLResolver`, `GatewayClient`,
  `HTTPGatewayClient`, `NewHTTPGatewayClient`), WASM DOM/mount helpers
  (`ViewMountOptions`, `MountHTMLWithScrollPreservation`,
  `BindOnClickBySelector`, `ClosestElement`, `DOMAttributeString`), and the
  empty-state render helper needed by Portal launcher error fallback. Avoid a
  module-local Portal wrapper layer.
- Only after those facades are accepted and pinned should AI, Portal, and
  Notes adopter workers continue production import cleanup.

The Mini workers reached `running`/`ready` with clean worker-owned worktrees,
but create-time prompts did not appear as recorded worker messages. The
supervisor therefore sent explicit `bus workers message` start instructions to
both Mini workers after recording exact product-worktree guardrails in their
task threads. Continue by verifying actual assistant responses, diffs, commits,
and tests before treating either lane as accepted.

Earlier local Spark workers for those two core facade slices had accepted
messages and then completed turns without any assistant response or diff. A
Bus infrastructure task was opened as `task-4eb87d0bfa61` to diagnose the
local-dev App Server worker turn delivery or session/tool-path failure if the
same symptom reappears.
Follow-up diagnosis found the immediate cause in the affected workers'
Codex session logs: each silent turn reached `GPT-5.3-Codex-Spark`
rate-limit telemetry with `primary.used_percent=100.0` and no assistant
message. The local 5-hour Spark bucket reset shown in the session was
`2026-06-15 16:20:50 EEST`. The worker-infra task remains useful for making
this surface as an actionable rate-limit failure instead of a misleading
"completed without assistant response" status, but GX/UI product workers should
not be expected to make progress on `gpt-5.3-codex-spark` until capacity is
available again or the operator approves a different model.

The first terminalui, Notes, and Auth workers accidentally touched primary
checkout paths. The Auth worker also committed two changes on primary
`bus-portal-auth/develop` before detection. The leaked patches were preserved
as supervisor coordination artifacts, a backup branch was kept for the Auth
leak, and the primary module checkouts were restored clean. Continuation
workers must receive the exact worker product-worktree path and must verify
they are editing inside `.bus/services/workers/runtime/<worker>/product-worktree`
before any product edit.

## Next Work Queue

The next supervisor should proceed in this order:

1. Finish the newly identified core `bus-ui` facade dependencies:
   `pkg/terminalui` terminal/container runtime aliases and `pkg/ui`
   runtime/server/CLI/WASM helper facades.
2. Resume Spark worker turns after the `GPT-5.3-Codex-Spark` primary bucket
   resets, or after the operator approves a different model. Keep
   `task-4eb87d0bfa61` open as an infrastructure cleanup item to project
   quota/no-assistant turns as actionable failures.
3. Continue and review the active adopter cleanup workers for
   `bus-portal-ai` and `bus-portal`. Auth and Accounting are accepted locally;
   AI and Portal remain unfinished after rejected compile-broken/wrapper-only
   attempts and should run against the completed core facades.
4. Dispatch `task-fe70fd4546fd` for the `bus-portal-notes` runtime/reducer
   `pkg/uikit` cleanup after the core `pkg/ui` facade is confirmed sufficient.
5. Re-audit canonical code and docs for the definition-of-done patterns.
   Use the audit to decide whether `uiportal`, adopter tests, and docs cleanup
   need fresh focused workers.
6. Classify remaining evidence refs/worktrees: the Auth leak branch and the
   dirty GX/UI Bus runtime product worktrees. Archive useful diffs before
   deletion or explicit discard.
7. Only after module state is settled, prune old BusDK root pointer branches
   whose target module commits are promoted, superseded, or intentionally
   discarded.

## Post-Reset Execution Runbook

Use this exact order after the `gpt-5.3-codex-spark` reset at
`2026-06-15 16:20:50 EEST` unless the operator approves a different model
before then:

1. Verify individual status for the five live workers, not only bulk list:
   `gx-ui-terminal-runtime-facade-spark-20260615a`,
   `gx-ui-runtime-facade-spark-20260615a`,
   `gx-ui-ai-uikit-spark-20260615c`,
   `gx-ui-portal-uikit-spark-20260615b`, and
   `gx-ui-notes-runtime-spark-20260615a`.
   The dirty AI retry `gx-ui-ai-uikit-spark-20260615b` is stopped by
   individual status and should be treated as preserved evidence even if a
   stale bulk `workers list` projection still shows it as running.
2. Message the two core `bus-ui` workers first:
   - terminal runtime facade worker on `task-646c27a30fb6`;
   - UI helper facade worker on `task-84d0842bbbff`.
   Require each worker to restate its product worktree path under
   `.bus/services/workers/runtime/<worker>/product-worktree`, its module root,
   and its exact write scope before editing.
3. Review and accept core facade output before adopter messages:
   - inspect diffs in the worker-owned `bus-ui` worktrees;
   - verify focused tests and `git diff --check`;
   - run or request `bus-ui` module checks appropriate to the changed files;
   - commit/promote accepted module commits, then pin BusDK and supervisor
     submodule pointers before starting adopter cleanup from those facades.
4. Message adopter workers only after the needed core facade commits are
   accepted and pinned into the worker-visible BusDK state:
   - AI waits for both `pkg/terminalui` and `pkg/ui`;
   - Portal waits for `pkg/ui`;
   - Notes waits for `pkg/ui`.
5. Re-audit production `pkg/uikit` usage after adopter output:
   `rg -n "github.com/busdk/bus-ui/pkg/uikit|uikit\\." --glob '*.go'
   --glob '!**/*_test.go' bus-portal/internal bus-portal/pkg
   bus-portal-ai/pkg bus-portal-notes/*.go`.
   Asset URL strings such as `/assets/uikit.css` are not production API
   imports and should not block this refactor.
6. Keep `task-4eb87d0bfa61` open until worker projections correctly surface
   Spark quota/no-assistant turns and until bulk list/prune projections agree
   with individual worker lifecycle status after stops.

## 2026-06-15 14:25 Local Acceptance Update

The operator approved using `gpt-5.4-mini` for the remaining GX/UI work. The
supervisor replaced the stale adopter Spark lanes with Mini workers on the
accepted BusDK `50bbbb2` / `bus-ui` `12e5cdf` base.

The Notes runtime adopter cleanup is now accepted locally:

- worker `gx-ui-notes-runtime-mini-20260615a`, task `task-fe70fd4546fd`;
- worker commit `c46f1e31c239cc568ee2179a32497e66f56b4cab`;
- promoted primary `bus-portal-notes` commit `ab71e8b`, `notes portal: use ui
  facade in runtime`;
- scoped files: `runtime.go`, `runtime_reducer.go`, and `view_models.go`;
- verification on promoted primary: `git diff --check HEAD~1..HEAD`, scoped
  production `pkg/uikit`/`uikit.` search with no hits, and `go test ./...`.

This removes active production `pkg/uikit` dependencies from the immediate
Notes runtime/reducer/view-model scope. Notes test-harness `uikit` usage
remains part of the later test migration wave.

During review, the Notes worker surfaced a small remaining `pkg/ui` facade
polish gap: `pkg/ui` exposes `SubmitState` and `SubmitStateIdle`, but not
`SubmitStateWorking`, `SubmitStateSuccess`, or `SubmitStateError`, so the
accepted Notes patch uses typed `ui.SubmitState("...")` literals for those
states. Treat exporting those constants as a small core follow-up, not as a
reason to reject the production import cleanup.

## 2026-06-15 14:35 Core Facade Polish Acceptance

The small core `pkg/ui` facade polish gap is now accepted locally:

- worker `gx-ui-ui-facade-polish-mini-20260615a`, task `task-6ae19b0f6440`;
- worker commit `b4204108aadc560acdd0808d99fe149437e31cc6`;
- promoted primary `bus-ui` commit `c0d42e1`, `Add pkg/ui facade parity
  aliases`;
- BusDK pin commit `6543e3b`, `Pin ui facade parity aliases`;
- exported aliases: `ui.DOMAttrUIAction`, `ui.SubmitStateWorking`,
  `ui.SubmitStateSuccess`, `ui.SubmitStateError`, and
  `ui.CSSBundleCSSChecked`;
- verification on promoted primary: `git diff --check HEAD~1..HEAD`,
  `go test ./pkg/ui -count=1`, and `go test ./... -count=1`.

Portal and AI adopter workers should now replace local workarounds with these
public facades before their cleanup branches are accepted. In particular,
Portal should call `ui.CSSBundleCSSChecked(ui.CSSBundleOptions{})` directly
instead of unwrapping `ui.CSSBundleChecked` output, and AI should use
`ui.DOMAttrUIAction` instead of local `"data-ui-action"` literals.

## 2026-06-15 15:35 Adopter Acceptance Update

The Portal adopter cleanup is now accepted locally:

- worker `gx-ui-portal-uikit-mini-20260615a`, task `task-62c09a117f80`;
- worker commits `f856f28278b6d12719281bdf72a2265679758de0` and
  `10e0e45cd9aa5979a85a763f7249c840bd46bc61`;
- promoted primary `bus-portal` commits `da62db3`, `Switch bus-portal to
  public ui facade`, and `f001470`, `Use public ui CSS bundle helper`;
- BusDK pin commit `423dab0`, `Pin portal ui facade cleanup`;
- verification on promoted primary: `git diff --check HEAD~2..HEAD`, a
  scoped production `pkg/uikit`/`uikit.` audit with only accepted
  `/assets/uikit.css` URL/test hits, `go test ./internal/cli ./internal/run
  ./internal/server ./pkg/portal`, and `go test ./...`.

The AI adopter cleanup has been accepted in three partial slices against the
public `pkg/ui` and `pkg/terminalui` facades:

- `gx-ui-ai-actions-mini-20260615c`, task `task-25bee17f4cd1`, worker commit
  `19064061e170348d710517776fa074869c34bf53`, promoted primary
  `bus-portal-ai` commit `1535b38`, `Switch ai portal actions to ui facade`,
  and BusDK pin `a5c018d`;
- `gx-ui-ai-wasm-actions-mini-20260615d`, task `task-25bee17f4cd1`, worker
  commits `b72781d` and `84ca48e`, promoted primary `bus-portal-ai` commits
  `53063a4`, `Switch AI wasm actions to ui facade`, and `5815812`, `Finish
  aiportal ui facade aliases`, and BusDK pin `bfdeef8`;
- `gx-ui-ai-terminal-generic-mini-20260615f`, task `task-25bee17f4cd1`, worker
  diff committed in the worker worktree as `09a4eb7`, promoted primary
  `bus-portal-ai` commit `469cc43`, `Switch AI terminal generic runtime to ui
  facade`, and BusDK pin `cf6af05`.

Each promoted AI slice passed its promoted-primary `git diff --check` range,
`go test ./pkg/aiportal`, and `go test ./...`. The AI task remains open only
for terminal/container-specific helper migration in
`pkg/aiportal/terminal_runtime.go` and the terminal sections of
`pkg/aiportal/wasm_runtime_js.go`. Earlier broad AI retry attempts are
rejected cautionary evidence because they broke terminal resource path
semantics, including double-prefixed paths such as
`/api/v1/terminal/terminal/<id>/input`.

The next AI worker should be narrow: remove the remaining production
`pkg/uikit` import from `bus-portal-ai/pkg/aiportal/terminal_runtime.go` and
`wasm_runtime_js.go` by using public `pkg/terminalui` and `pkg/ui` symbols,
while preserving the existing terminal resource request model and tests. Do
not import `pkg/terminalruntime` directly, do not hide `uikit` behind a local
alias or wrapper layer, and do not change terminal request base/path behavior
unless the existing tests prove the change.

## 2026-06-15 15:50 Core Parity And AI Retry

The core `pkg/terminalui` request-parity blocker is now accepted locally:

- worker `gx-ui-terminalui-request-parity-mini-20260615a`, task
  `task-def97c1ed2fc`;
- worker commit `0628683f095d013d975aeb5f1bb60fcbe7c4bf42`;
- promoted primary `bus-ui` commit `def9a2f`, `Align terminal request
  builders with uikit contract`;
- BusDK pin commit `cf230a7`, `Pin terminalui request parity`;
- verification on promoted primary: `git diff --check HEAD~1..HEAD`,
  `go test ./pkg/terminalui -count=1`, `go test ./pkg/terminalruntime
  -count=1`, and `go test ./... -count=1`.

That patch restores public `terminalui` helper parity for the accepted old
terminal request contract: input and resize paths stay under
`/sessions/<id>/input` and `/sessions/<id>/resize`, close stays
`DELETE /sessions/<id>`, and container runs keep the accepted `/runs` request
model. This was required before the AI adopter could remove its last
production `pkg/uikit` references without changing provider paths.

The AI terminal/container cleanup has been retried on the fresh core base with
worker `gx-ui-ai-terminal-container-mini-20260615h`, task
`task-25bee17f4cd1`, branch `codex/gx-ui-ai-terminal-container-20260615h`.
Its preflight base is BusDK product-worktree `cf230a7`, `bus-ui` `def9a2f`,
and `bus-portal-ai` `469cc43`. The worker initially almost diagnosed a stale
base by checking BusDK commit `cf230a7` from the supervisor root instead of
the Bus-managed product-worktree root; the supervisor corrected the lane and
updated internal guidance so future fresh-base preflights name the exact repo
root for each SHA check.

The AI task remains open until this worker or a follow-up removes the
remaining production `pkg/uikit`/`uikit.` references from
`pkg/aiportal/terminal_runtime.go` and the terminal/container sections of
`pkg/aiportal/wasm_runtime_js.go`, with tests preserving terminal path
normalization, resource kind/base behavior, and container run projections.

## 2026-06-15 16:10 Core Result Parity And AI Probe Gate

The core `pkg/terminalui` result-parity blocker is now accepted locally:

- worker `gx-ui-terminalui-result-parity-mini-20260615a`, task
  `task-ad726c335fb7`;
- worker commit `032ec840ac8d6d73f521bfde5e4cd1ebfa41f0f9`;
- promoted primary `bus-ui` commit `2244b59`, `Add terminalui result facade
  parity`;
- exported public terminal facade surface: `ResultKind`,
  `ResultKindSuccess`, `ResultKindValidationError`,
  `ResultKindProviderError`, `ResultKindNavigate`, `ResultKindNoop`,
  `FieldError`, `Success`, `ValidationError`, `ProviderError`, and
  `Navigate`;
- verification on promoted primary: `git diff --check HEAD~1..HEAD`,
  `go test ./pkg/terminalui -count=1`, `go test ./pkg/terminalruntime
  -count=1`, and `go test ./... -count=1`;
- `bus lint pkg/terminalui/terminalui.go
  pkg/terminalui/terminalui_runtime_facade_test.go` reported the test file
  clean and one pre-existing `RenderHTML` error-swallowing finding in
  `pkg/terminalui/terminalui.go`, unchanged from the previous commit and not
  part of the result-parity acceptance.

Before resuming AI terminal/container implementation, run a bounded facade
parity probe against exactly:

- `bus-portal-ai/pkg/aiportal/terminal_runtime.go`;
- `bus-portal-ai/pkg/aiportal/wasm_runtime_js.go`;
- `bus-portal-ai/pkg/aiportal/terminal_runtime_test.go`.

The probe must list every remaining `uikit`, `terminalruntime`, terminal
request/result/effect/client, and test-fake symbol needed by the migration and
classify each symbol as one of: public `terminalui` equivalent exists; public
`ui` equivalent exists; explicit adapter needed in adopter; or missing public
core facade. Do not resume implementation until the table has no missing
public core facade entries, or until those entries are split into narrow
`bus-ui` parity tasks. The active worker
`gx-ui-ai-terminal-container-mini-20260615h` has unaccepted edits from before
this result-parity patch, including a reflection bridge; that diff should be
reworked or discarded by the worker after a fresh-base preflight, not promoted.

## 2026-06-15 16:59 Core Stream Behavior Parity

The core terminal stream behavior blocker is now accepted locally:

- worker `gx-ui-terminalui-stream-parity-mini-20260615a`, task
  `task-b74c66938ab3`;
- worker commit `53c19969b23beb5bc2a08dc4ff169c51cc369573`,
  `terminalruntime stream parity`;
- promoted primary `bus-ui` commit `96713ab`, `terminalruntime stream parity`;
- restored public `terminalruntime`/`terminalui` stream behavior:
  `TerminalStreamEffect.Done()` closes on clean close, abort, and terminal
  lifecycle completion; `MaxReconnects` and `ReconnectOnClose` preserve the
  old `pkg/uikit` reconnect/attempt loop; `Abort` keeps abort-channel close
  concurrency-safe; `StartEffect` preserves old synchronous validation and
  provider-error projections for invalid stream requests and missing
  transports;
- focused tests now cover close/abort `Done()` behavior, recoverable open
  error retry, EOF reconnect with incremented attempts, synchronous
  `StartEffect` validation/error projection, and the public `pkg/terminalui`
  facade alias exposing `Done()`;
- verification on promoted primary: `git diff --check HEAD~1..HEAD`,
  `go test ./pkg/terminalruntime -count=1`, `go test ./pkg/terminalui
  -count=1`, and `go test ./... -count=1`.

The AI terminal/container adopter cleanup may now resume from a fresh BusDK
base that pins `bus-ui` at `96713ab` or later. The previous unaccepted AI
worker diff remains useful only as a reference for explicit `ui`/`terminalui`
adapter implementation; adopter tests must continue to assert the old
`Done()`/reconnect behavior rather than weakening expectations around the
public facade.

## 2026-06-15 18:20 Final AI Terminal/Container Cleanup Accepted

The final AI terminal/container adopter cleanup is now accepted, promoted, and
the task thread is closed:

- worker `gx-ui-ai-terminal-runtime-onefile-spark-20260615o`, task
  `task-25bee17f4cd1`;
- worker commit `ee8650c33fbf98a8a2a6d037f3ec105f82cd3716`,
  `Migrate AI terminal runtime to public UI facades`;
- promoted primary `bus-portal-ai` commit
  `2f4f8068b490254599236b5188bc9cfeac984411`;
- BusDK pin commit `9f0a2e7dd17ff37c296db32e22b3cf4364886b91`;
- supervisor pointer commit `0e229d51cfb53a766e943f059e89e1ea5d5270ea`.

The accepted patch removes the final scoped production `pkg/uikit` dependency
from `bus-portal-ai/pkg/aiportal/terminal_runtime.go` and
`bus-portal-ai/pkg/aiportal/wasm_runtime_js.go` by using public `pkg/ui` for
generic action/resource/browser helpers and public `pkg/terminalui` for
terminal/container stream and effect types. The scoped tests in
`terminal_runtime_test.go` now use public `ui` and `terminalui` types.

The adopter keeps the accepted provider behavior while using the new public
facades:

- terminal create/input/resize/close paths remain under `/sessions`;
- terminal stream behavior continues to protect `Done()` close/abort and
  reconnect attempt invariants from the core stream-parity patch;
- container run requests remain `POST /api/v1/containers/runs`;
- the public terminal facade's current `/container/run` helper output is
  adapted in the adopter before provider prefixing, rather than changing the
  provider contract or importing `pkg/terminalruntime` directly.

Acceptance checks on the promoted primary module passed:

- `git diff --check HEAD~1..HEAD`;
- scoped no-legacy audit for `pkg/uikit`, `uikit.`, and `terminalruntime` in
  `terminal_runtime.go`, `terminal_runtime_test.go`, and
  `wasm_runtime_js.go`;
- production-only `pkg/aiportal` audit has no direct `pkg/uikit` or `uikit.`
  hits outside tests and accepted asset URL strings;
- `go test ./pkg/aiportal -count=1`;
- `go test ./... -count=1`.

WASM proof has a named verifier-host exception. On the supervisor host,
`/usr/local/go/bin/go` reports `go version go1.26.3 darwin/arm64`, and
`GOOS=js GOARCH=wasm go env GOROOT GOOS GOARCH GOEXPERIMENT` reports
`/usr/local/go`, `js`, `wasm`, and an empty experiment value. However,
`GOOS=js GOARCH=wasm go list std` fails broadly across standard library
packages, including `syscall/js`, so local WASM failure is not classified as
product failure. Route any future WASM proof for this slice to a known-good
worker/host/toolchain before reopening product work.

After this acceptance, `bus-portal-ai/pkg/aiportal` has no production direct
`pkg/uikit` import or `uikit.` reference. Test-only `uikit`/`uikittest` usage
elsewhere remains classification work, not an app-readiness blocker unless a
specific production migration depends on it.

Current source audit after this promotion still finds production direct
`pkg/uikit` imports outside the completed immediate Portal/Auth/Accounting/AI
lanes. The remaining broad follow-up surfaces are:

- `bus-factory/internal/serve` and `bus-factory/internal/run`;
- `bus-gateway/internal/run`, `bus-gateway/internal/server`, and
  `bus-gateway/internal/ui`;
- `bus-inspection/internal/cli`, `bus-inspection/internal/run`,
  `bus-inspection/internal/server`, and `bus-inspection/internal/ui/wasm`;
- `bus-ledger/internal/run`, `bus-ledger/internal/server`, and
  `bus-ledger/internal/ui/wasm`;
- `bus-chat/internal/cli`, `bus-chat/internal/run`, and
  `bus-chat/internal/serve`.

Treat those as separate future slices. They are not evidence that the final AI
terminal/container lane remains open.

## 2026-06-15 18:35 Repo-Wide Production Inventory Refresh

The post-AI repo-wide production audit expanded the remaining GX/UI backlog
from the original Portal/AI/Notes lanes to five additional module families.
The audit command was:

```bash
rg -l '"github.com/busdk/bus-ui/pkg/uikit"' bus-factory bus-gateway bus-inspection bus-ledger bus-chat bus-portal-notes -g'*.go' -g'!*_test.go'
```

`bus-portal-notes` now has no production direct `pkg/uikit` hit in that audit.
The remaining production inventory is:

| Module family | Files/symbol patterns | Production vs test/docs | App-readiness criticality | Expected public facade | Behavior invariants | Milestone status | Probe/task refs |
|---|---|---|---|---|---|---|---|
| `bus-factory` | `internal/serve/ai_thread_isolation.go`, `ai_acp_status.go`, `ai.go`, `business_view.go`, `browser_runtime.go`, `server.go`, `ai_go_diagnostics.go`; production direct `pkg/uikit` imports and `uikit.` calls remain. Previous CLI run hit in `internal/run/run.go` is accepted. | Production normal path. | App-readiness follow-up, especially AI assistant and server/runtime paths. | `pkg/ui` for server/browser runtime/business primitives and CSS helpers; `assistantui` for isolation/panel render surfaces, AI script/model/event/render-props, and DTO/helper parity from accepted AI Slice A/B; `terminalui` for terminal session snapshots; possibly missing public ACP/status + Go diagnostics DTOs if those must leave `pkg/uikit`. | Token/static URL behavior, AI thread/session DTO shape, browser runtime action/resource semantics, generated HTML boundary behavior, asset URL strings, provider path/status values. CLI output, quiet/output routing, and serve URL writer handling were preserved by the accepted run slice. | Probe completed. CLI run cleanup accepted through `task-4490557f6e5a` with worker commit `782967ffa5ea54fc465e8a3b7a36e3ab20eed18f` and primary `bus-factory` commit `4d8b554`. Ready implementation slices: server helper swap, browser runtime request/action swap, business view rewrite to public primitives, terminal-session adapter swap, isolation adapter rewrite, AI panel script/model/event/render-props swap, and DTO/helper swap against accepted assistantui facade slices. Full cleanup still needs a narrow decision/probe for ACP/status and Go diagnostics DTO ownership. | `task-41453d68fdbb`, replacement worker `gx-ui-factory-uikit-probe-mini-20260615b`; implementation `task-4490557f6e5a`, worker `gx-ui-factory-run-cli-spark-20260615a`. Spark worker `gx-ui-factory-uikit-probe-spark-20260615a` failed without an accepted table and was stopped. Core AI Slice A accepted via `task-ad933078fd5d`; Slice B accepted via `task-cac06aa451fc`. |
| `bus-gateway` | `internal/run/admin.go`, `internal/run/run.go`, `internal/server/service_manager.go`, `admin_cli.go`, `bootstrap.go`, `server.go`, `internal/ui/view.go`; previous production direct `pkg/uikit` imports and `uikit.` calls. | Production normal path. | Accepted app-readiness cleanup for gateway CLI/server/UI shell. | `pkg/ui` for CLI/server/static/token/logging, node-first UI primitives, and CSS/icon helper parity from `bus-ui` `7fb0b0b`. | CLI output, serve writer/browser-open behavior, token generation and token URL/path suffix behavior, static/index fallback, client-log API behavior, TCP listener behavior, immediate admin output, UI render boundaries. | Accepted through implementation task `task-8250eab4d97e`. Worker `gx-ui-gateway-uikit-impl-spark-20260615a` committed `517a996d78b6092f2c8299082f3f4eb7f99ac8dc`; primary `bus-gateway` promoted commit `444170c`. Primary verification passed `git diff --check HEAD~1..HEAD`, scoped no production `pkg/uikit`/`uikit.` audit except accepted `assets/uikit.css` route/assertion strings, and `go test ./... -count=1`. | Probe `task-f9b8df62aa16` accepted/closed; implementation `task-8250eab4d97e` accepted. Core unblocker `task-d1f1d1b26dd5` accepted as `bus-ui` `7fb0b0b`. |
| `bus-inspection` | `internal/ui/wasm/view.go`, `internal/ui/wasm/app.go`; production direct `pkg/uikit` imports and many WASM/view `uikit.` calls remain. Previous CLI/server hits in `internal/run/run.go`, `internal/cli/flags.go`, and `internal/server/server.go` are accepted. | Production normal path. | App-readiness follow-up for inspection WASM app/view. | `pkg/ui` for already-exported browser/global/mount helpers, CSS/icon helper parity from `bus-ui` `7fb0b0b`, runtime mount/callback lifecycle/DOM error-host parity from `bus-ui` `72c9537`, file/dropzone/multipart parity from `bus-ui` `98233a3`, and split/projection/layout parity from `bus-ui` `ae3f147`; `MessageBubble` and broader route/parse/format cleanup remain deferred unless adopter work proves them critical. | JS/WASM document/location/gateway/action/resource behavior, drag/drop upload, render boundaries, form submit serialization, scroll preservation. CLI flag validation, immediate/serve output, browser-open, token/static/client-log behavior were preserved by the accepted CLI/server slice. | Probe completed. CLI/server cleanup accepted through `task-913d9997450a` with worker commit `7561208fbd966a7759d16070148fa5868e7fa246` and primary `bus-inspection` commit `fc2e3f4`. Remaining active work is the WASM/app-view cleanup against accepted runtime/mount/error-host, file/dropzone, and split/projection/layout facades. Deferred `MessageBubble` and broader route/parse/format cleanup should not be counted in the active backlog without a task ref/DoD. | Probe `task-430c894ddc6d`, worker `gx-ui-inspection-uikit-probe-spark-20260615a`; implementation `task-913d9997450a`, worker `gx-ui-inspection-cli-server-spark-20260615a`; core WASM probe `task-c359cfa15ffa`; WASM Slice 1.1 accepted via `task-5f133b387382`; Slice 1.2 via `task-dbef5c874510`; Slice 1.3 via `task-1676ddcd3333`. |
| `bus-ledger` | `internal/server/ai_thread_isolation.go`, `ai.go`, `ai_runtime_config.go`, `logging.go`, `server.go`, and many `internal/ui/wasm/*` files including control helpers, app context, ledger controller, split root, list/detail/line panels, projection presenter, and resize helpers. Previous CLI run hit in `internal/run/run.go` is accepted. | Production normal path. | High app-readiness follow-up because ledger has broad AI/projection/WASM rendering contracts. | `pkg/ui` for narrow server/logging/status surfaces, runtime/error/disposal parity from `bus-ui` `72c9537`, file/dropzone/multipart parity from `bus-ui` `98233a3`, and split/projection/layout parity from `bus-ui` `ae3f147`; `assistantui` shared script/model/event/render-props/panel render helpers from `bus-ui` `de62c59`/`76a58af` plus DTO/helper parity from `bus-ui` `963f391`; broader parsing/formatting/route helpers, `MessageBubble`, and extra table/status/detail presenter cleanup remain deferred unless adopter implementation proves them critical. | Token/static/client-log behavior, AI isolation and event/model catalog semantics, projection list/detail route and evidence action IDs, split pane state/resize, render runtime/recovery, numeric parsing/formatting, row/link/icon behavior. CLI output, serve URL writer handling, and webview-open callback behavior were preserved by the accepted run slice. | Probe completed. CLI run cleanup accepted through `task-c7559f496730` with worker commit `61468bffc933f04caa69fde99ec61bf26cfaf966` and primary `bus-ledger` commit `1485e9a`. Small server/status slices, AI Slice A/B swaps, runtime/mount/error-host swaps, file/dropzone swaps, and split/projection/layout swaps remain ready to implement against accepted facades. Deferred parsing/formatting/route, `MessageBubble`, and extra table/status/detail presenter cleanup should not be counted in the active backlog without a task ref/DoD. | Probe `task-9df1a15c7232`, worker `gx-ui-ledger-uikit-probe-spark-20260615a`; implementation `task-c7559f496730`, worker `gx-ui-ledger-run-cli-spark-20260615a`; core AI Slice A accepted via `task-ad933078fd5d`; Slice B via `task-cac06aa451fc`; core WASM Slice 1.1 accepted via `task-5f133b387382`; Slice 1.2 via `task-dbef5c874510`; Slice 1.3 via `task-1676ddcd3333`. |
| `bus-chat` | `internal/serve/ai.go`, `ai_workspace_locks.go`, `ai_appserver.go`; production direct `pkg/uikit` imports and AI-service `uikit.` calls remain. Previous CLI/server hits in `internal/cli/flags.go`, `internal/run/run.go`, and `internal/serve/server.go` are accepted, with only accepted CSS asset strings left in the server shell. | Production normal path. | App-readiness follow-up for chat AI panel/wire DTOs and service state. | `terminalui` covers some terminal DTOs; `assistantui` covers AI panel event/model catalog helpers, panel render props/rendering, and thread/status/poll/history DTO/helper parity through accepted AI Slice A/B. Message buffer/history behavior should be handled as explicit adopter adapter work unless a concrete missing core facade is found. | Lock/isolation payload shape, event filtering/model candidates, `/v1/ai/*` JSON fields, persisted `ai-state.json`, prompt/message normalization. CLI output, token-gated server routing, `/assets/uikit.css`, AI panel client script contract, and client-log behavior were preserved by the accepted CLI/server slice. | Probe completed. CLI/server cleanup accepted through `task-aa8c4e804ea9` with worker commit `356f15e425d89e60743e8472721c4029151d33d5` and primary `bus-chat` commit `d696d2c`. Remaining active work is the AI panel script/model/event/render-props and DTO/helper swap in the three AI service files. Message buffer/history behavior remains adopter-scope unless implementation proves a missing public core facade. | Probe `task-068f261597cf`, worker `gx-ui-chat-uikit-probe-spark-20260615a`; implementation `task-aa8c4e804ea9`, worker `gx-ui-chat-cli-server-spark-20260615a`; core AI probe `task-f3a1a044b53a`; core AI Slice A accepted via `task-ad933078fd5d`; Slice B accepted via `task-cac06aa451fc`. |

Backlog/ETA language must now be tied to this inventory. After each accepted
lane, refresh the repo-wide production audit before saying GX/UI cleanup is
closed. If a surface is deferred out of the active milestone, keep it named in
this table instead of rediscovering it during closeout.

### Active Implementation Slice Queue

Velocity and backlog reporting should count these implementation-sized slices
once a module row has been probed. Keep completed slices in the queue long
enough to make partial-row progress obvious, then collapse them into the row
summary after the next audit.

| Slice | Scoped files | Facade dependencies | Behavior invariants | DoD checks | State |
|---|---|---|---|---|---|
| Core CLI/catalog/CSS uikit removal | `bus-ui/cmd/bus-ui/run.go`, `cmd/bus-ui/run_test.go`, catalog/CSS implementation files as needed | Public `pkg/ui`, `pkg/uicatalog`, or a new non-compatibility internal implementation package; must not call `pkg/uikit`. | Component catalog schema/output, CSS bundle themes/options, CLI stdout/stderr/error behavior. | Deletion-probe rerun reaches past `cmd/bus-ui`; focused command/catalog/CSS tests; `go test ./...` in `bus-ui`; no production `pkg/uikit` import in scoped core files. | Accepted in `bus-ui` `c122e1e` from worker `gx-ui-core-cli-catalog-uikit-removal-mini-20260615b`; tests reported: `go test ./cmd/bus-ui`, `go test ./...`. |
| Core assistantui AI facade implementation | `bus-ui/pkg/assistantui/assistantui_ai_facade.go`, `assistantui_ai_facade_js.go`, related tests | Move AI DTO/helper/client-script/render behavior into `pkg/assistantui` or non-compatibility internal implementation; primary render API remains node-first with explicit HTML boundary names only where intended. | AI thread/status/event/history DTO shape, model candidate extraction, isolation path/branch names, attachment refs, client script output, panel render semantics. | Focused `go test ./pkg/assistantui`; deletion-probe rerun no longer fails downstream modules through `assistantui_ai_facade.go`; no production `pkg/uikit` import in assistantui facade files. | Accepted / matrix advanced in `bus-ui` `17dddd5` from worker `gx-ui-core-assistantui-ai-facade-uikit-removal-mini-20260615c`; post-assistantui deletion rerun `task-a1f0c7192d7f` proved `pkg/assistantui` passes with `pkg/uikit` unavailable and named `pkg/ui/action_resource_facade.go` as the next core blocker. |
| Core ui action/resource facade implementation | `bus-ui/pkg/ui/action_resource_facade.go`, `action_resource_effect.go`, browser resource transport implementation/tests | Move action/resource state/result DTOs, clients, and helper constructors out of `pkg/uikit`; browser/fetch/multipart transport is the remaining compiler blocker. Do not keep alias wrappers to the deleted package. | Action/result status and field error shape, resource kind/client interfaces, helper validation and result-kind behavior; browser fetch request/response semantics, multipart payload fields, provider-error redaction, navigation decode, unsafe URL rejection. | `go test ./pkg/ui`; `go test ./...` in `bus-ui`; scoped no-production `pkg/uikit` audit for touched `pkg/ui` files; follow-up deletion-probe rerun advances beyond `pkg/ui/action_resource_facade.go`. | Non-browser core accepted in `bus-ui` `8f60089` from worker `gx-ui-core-ui-action-resource-core-spark-20260615d`; post-core deletion rerun `task-2551cd20e12c` proved the matrix still stops at `pkg/ui/action_resource_facade.go:6:8` because browser transport aliases still import `pkg/uikit`. Active follow-up `task-5d6bc8d3c941`, worker `gx-ui-core-ui-browser-resource-transport-spark-20260615a`, moves browser resource transport into `pkg/ui`. |
| Core ui form/control helper source-map | `bus-ui/pkg/ui/form_controls.go`, `pkg/ui/ui.go`, new or existing `pkg/ui/form_controls*.go` helper files; source references in `pkg/uikit/control_primitives.go`, `action_primitives.go`, `form_primitives.go`, `input_primitives.go`, `components.go`, `dropzone_fc021.go`, `file_input_gx_adapter.go`, `dropzone_node.go` | Package-owned `pkg/ui` implementations for form/control helpers instead of `pkg/uikit` alias wrappers. | Control validation/error semantics, button class/render behavior, form/field aria-describedby behavior, input/select value and callback validation, file-input accessible-name checks, drop-zone source/policy/accepted-type normalization. | Planning artifact first: exact symbol/owner table, target file list, child implementation order, focused tests, and alias-removal list. Implementation DoD later: `go test ./pkg/ui`, `go test ./...`, scoped no-`uikit` audit for `pkg/ui/form_controls*.go`, and deletion-probe rerun advances beyond `pkg/ui/form_controls.go`. | Planning complete; implementation children queued. Broad implementation worker `gx-ui-form-controls-mini-20260616a` (`task-1fd5203ad807`) passed hard gate/write proof/source-map reads but stayed clean after the exact patch nudge; planning worker `gx-ui-form-controls-source-map-mini-20260616a` was stopped for empty `bus-ui` materialization; supervisor source map `logs/worker-output/gx-ui-form-controls-helper-source-map-20260616a.md` enumerates the child order. |
| Factory CLI run helpers | `bus-factory/internal/run/run.go` | Accepted `pkg/ui` CLI helpers (`WriteImmediateCLIOutput`, `ResolveServeOutputWriter`). | Help/version output, quiet/output routing, serve URL writer behavior, exit codes. | Scoped no-`uikit` audit, `go test ./internal/run -count=1`, `go test ./... -count=1`. | Accepted via `task-4490557f6e5a`, worker `782967f`, primary `4d8b554`. |
| Factory server shell helpers | `bus-factory/internal/serve/server.go` | Accepted `pkg/ui` token/static/client-log/listener/CSS helpers and `assistantui` panel shell helpers. | Token URL/path suffixes, static/index fallback, client-log API, listener URL, AI panel script/render boundary. | Checked-boundary table, scoped no-`uikit` audit for file, focused server tests, full module tests. | Active, ready. |
| Factory browser runtime/action resources | `bus-factory/internal/serve/browser_runtime.go` | Accepted public `pkg/ui` action/resource/effect facade. | Resource method/path/kind preservation, runtime API config, action result semantics. | Symbol/behavior table, focused browser-runtime tests or package tests, full module tests. | Active, ready. |
| Factory business view primitives | `bus-factory/internal/serve/business_view.go` | Public `pkg/ui` node primitives, CSS/icon helpers, split layout checked helpers. | Generated HTML boundary behavior, split layout classes/styles, action IDs, panel/table markup semantics. | Checked-boundary table, focused render tests if available, scoped no-`uikit` audit, full module tests. | Active, ready. |
| Factory AI service DTO/render swaps | `bus-factory/internal/serve/ai.go`, `ai_thread_isolation.go` | Accepted `assistantui` Slice A/B and `terminalui` terminal DTO/public helpers. | AI thread/session DTO shape, model candidates, event filtering, isolation branch/worktree naming, terminal approval/session snapshots. | Facade table, focused AI/server tests, full module tests. | Active, ready except terminal ownership should follow accepted terminal DTO probe if it changes canonical package. |
| Factory ACP/status and diagnostics DTO ownership | `bus-factory/internal/serve/ai_acp_status.go`, `ai_go_diagnostics.go` | Unclear: likely `assistantui` typed DTO helpers if promoted out of `pkg/uikit`. | ACP status JSON fields, verification/review state, Go diagnostic path/line/column/message/kind. | Read-only table naming canonical public owner and behavior tests, then split implementation if no missing facade remains. | Probe-needed. |
| Chat AI service DTO/panel cleanup | `bus-chat/internal/serve/ai.go`, `ai_workspace_locks.go`, `ai_appserver.go` | Accepted `assistantui` Slice A/B and `terminalui` DTO/helpers where applicable. | `/v1/ai/*` JSON fields, event filtering, model candidates, lock/isolation payloads, terminal approvals/session snapshots, persisted `ai-state.json`. | Symbol/behavior table, scoped no-`uikit` audit over three files, focused serve tests, full module tests. | Active, ready; message buffer/history remains adopter adapter unless a missing facade appears. |
| Ledger server/status helper cleanup | `bus-ledger/internal/server/server.go`, `logging.go` | Accepted `pkg/ui` token/static/client-log/listener/CSS/logger helpers. | Token/static/client-log behavior, logging fields, listener URL and route handling. | Checked-boundary table, scoped no-`uikit` audit for files, focused server tests, full module tests. | Active, ready. |
| Ledger AI server DTO/panel cleanup | `bus-ledger/internal/server/ai.go`, `ai_runtime_config.go`, `ai_thread_isolation.go` | Accepted `assistantui` Slice A/B and `terminalui` DTO/helpers where applicable. | AI isolation, event/model catalog semantics, terminal approval/session snapshots, runtime config defaults. | Symbol/behavior table, focused server/AI tests, full module tests. | Active, ready except terminal ownership should follow accepted terminal DTO probe if it changes canonical package. |
| Ledger WASM runtime/app context | `bus-ledger/internal/ui/wasm/app.go`, `app_context.go`, `frontend_errors.go`, `ledger_controller.go` | Accepted `pkg/ui` runtime/mount/error-host, file/dropzone, split/projection facades plus `assistantui` AI panel helpers. | Global access boundaries, render recovery, error forwarding, callback/disposer semantics, AI refresh/drop lifecycle. | Facade/behavior table, native tests, scoped no-`uikit` audit for files, WASM proof or named toolchain exception. | Active, ready. |
| Ledger WASM split/projection view | `bus-ledger/internal/ui/wasm/control_helpers.go`, `split_resize.go`, `view_split_root.go`, `view_list_panel.go`, `list_rows.go`, `view_detail_panel.go`, `view_line_panel.go`, `detail_helpers.go`, `ledger_projection_presenter.go`, `ledger_view.go`, `table_status_surfaces.go` | Accepted `pkg/ui` split/projection/layout, checked boundary, node primitives, icon/CSS helpers. | Split pane state/resize, route/evidence action IDs, projection list/detail DTO semantics, table/status/render boundaries. | Checked-boundary table by file group, focused tests if present, scoped no-`uikit` audit, full module tests, WASM proof or named exception. | Active, broad; split into two or more workers if table is large. |
| Ledger parsing/formatting/routes/MessageBubble extras | Ledger WASM helper/view files as discovered after the main WASM slices. | Unclear or deferred public ownership for parse/format route helpers, `MessageBubble`, and extra table/detail presenter cleanup. | Numeric parse/format, route/close-route behavior, message markup. | Probe DoD naming exact symbols, owner, and whether app-readiness requires them now. | Deferred/probe-needed; do not count active unless promoted to a task ref. |
| Inspection WASM app runtime/drop cleanup | `bus-inspection/internal/ui/wasm/app.go` | Accepted `pkg/ui` runtime/mount/error-host and file/dropzone/multipart facades. | Document/location/gateway/action/resource behavior, upload bytes/content type, drop class toggling, scroll preservation, error reporting. | Symbol/behavior table, scoped no-`uikit` audit for `app.go`, native tests, WASM proof or named exception. | Active, ready. |
| Inspection WASM view/render cleanup | `bus-inspection/internal/ui/wasm/view.go` | Accepted `pkg/ui` CSS/icon and public node/checked-boundary helpers; `MessageBubble` deferred unless critical. | Render output boundaries, form control IDs/names, table/status/panel behavior, admin/config views. | Chunked checked-boundary tables by view category, scoped no-`uikit` audit for `view.go`, native tests, WASM proof or named exception. | Active, broad; split by view category before implementation. |

### Core Facade Split From The Inventory

Accepted core parity:

- `task-d1f1d1b26dd5`, worker
  `gx-ui-core-css-icons-spark-20260615a`: accepted and promoted as
  `bus-ui` commit `7fb0b0be5e1d801b14c80593dbed4041c0cea258`
  (`ui: expose css icon facade aliases`). It adds public `pkg/ui` aliases for
  `CSSMust`, `SVGPathIcon`, and legacy sidebar/panel icon paths
  (`IconDocPath`, `IconHomePath`, `IconBookPath`, `IconInboxPath`,
  `IconLinePath`, `IconPortalPath`). Supervisor verification on the primary
  `bus-ui` checkout: `git diff --check HEAD~1..HEAD`,
  `go test ./pkg/ui -count=1`, and `go test ./... -count=1`.
- `task-5f133b387382`, worker
  `gx-ui-core-wasm-runtime-lifecycle-spark-20260615a`: accepted and promoted
  from worker commit `6b39b8d1c502a2194a3369a4c527d47374ed21fd` as primary
  `bus-ui` commit `72c9537` (`ui: add slice 1.1 public runtime/mount
  facade`). It adds public `pkg/ui` runtime mount, mounted app, GX root,
  DOM error banner, error-dismiss action, disposer, event target,
  event-listener, and callback retention facade parity. Supervisor
  verification on the primary `bus-ui` checkout: `git diff --check
  HEAD~1..HEAD`, `go test ./pkg/ui -count=1`, and `go test ./... -count=1`.
- `task-ad933078fd5d`, worker
  `gx-ui-core-ai-control-plane-spark-20260615a`: accepted and promoted from
  worker commits `dc6b57d424e362e146a9535a6ee9ca373b54bb87` plus correction
  commit `ca61e3e` as primary `bus-ui` commits `de62c59` and `76a58af`
  (`assistantui: add control-plane AI helper facade aliases` and
  `assistantui: make AI panel facade node first`). It adds public
  `assistantui` control-plane parity for AI panel client script, default
  model options, event/method helpers, model extraction, panel render props,
  core panel DTO aliases, js/wasm panel-prop building, node-first
  `RenderAIPanel`, and explicit string boundary `RenderAIPanelHTML`.
  Supervisor review rejected the first string-returning render facade and
  required node-first API shape before acceptance. Supervisor verification on
  the primary `bus-ui` checkout: `git diff --check HEAD~2..HEAD`,
  `go test ./pkg/assistantui -count=1`, and `go test ./... -count=1`.
- `task-cac06aa451fc`, worker
  `gx-ui-core-ai-dto-helper-spark-20260615a`: accepted and promoted from
  worker commit `778c5ec3f8ffc830b1faad62cc15203b3f92d6ca` as primary
  `bus-ui` commit `963f391` (`assistantui: expose AI DTO helper facade
  parity`). It adds public `assistantui` DTO/helper parity for AI thread
  metadata, status, event, thread/history/poll responses, attachments, Go
  diagnostics, turn-start context, thread items, attachment refs, working
  thread state, thread rename, turn-start payloads, isolation branch/worktree
  helpers, and default AI panel/conversation state. Supervisor verification on
  the primary `bus-ui` checkout: `git diff --check HEAD~1..HEAD`,
  `go test ./pkg/assistantui -count=1`, `go test ./pkg/uikit -count=1`, and
  `go test ./... -count=1`.
- `task-dbef5c874510`, worker
  `gx-ui-core-wasm-file-dropzone-spark-20260615a`: accepted and promoted from
  worker commit `21acfda0b0703aec3ec577e48048631b0c915416` as primary
  `bus-ui` commit `98233a3` (`ui: expose wasm AI drop upload facade parity`).
  It adds public `pkg/ui` parity for WASM AI file/dropzone import helpers,
  dropped file readers, AI drop controller/service types, multipart upload,
  AI dropped-content upload/decode behavior, drop-zone handler wiring, and
  drop-target visual state helpers. Supervisor verification on the primary
  `bus-ui` checkout: `git diff --check HEAD~2..HEAD`,
  `go test ./pkg/ui -count=1`, `go test ./pkg/uikit -count=1`, and
  `go test ./... -count=1`.
- `task-1676ddcd3333`, worker
  `gx-ui-core-wasm-split-projection-spark-20260615a`: accepted and promoted
  from worker commit `78610c75c597b830f457088c914917c35f14b88b` as primary
  `bus-ui` commit `ae3f147` (`ui: expose wasm split projection facade
  parity`). It adds public `pkg/ui` split/projection/layout parity for panel
  and split layout state, resize helpers, projection list/detail DTOs,
  projection query client factories, route helpers, locale formatter,
  projection presenter, and JS split-resize wiring. Supervisor verification on
  the primary `bus-ui` checkout: `git diff --check HEAD~2..HEAD`,
  `go test ./pkg/ui -count=1`, `go test ./pkg/uikit -count=1`, and
  `go test ./... -count=1`.

WASM-targeted test execution remains a named supervisor-host verifier gap for
these slices. On this host, `GOOS=js GOARCH=wasm go test ./pkg/ui -count=1`
fails before product compilation with `package syscall/js is not in std`, and
the control `GOOS=js GOARCH=wasm go list std` fails broadly across standard
library packages under `/usr/local/go`. Native checks and scoped review are
the acceptance evidence until a known-good JS/WASM verifier host is available.

Core facade work now split by completed probes:

- `task-f3a1a044b53a`, core assistant/AI facade probe: accepted as a
  read-only table. Critical Slice A, public `assistantui` control-plane
  facade for render props, panel render path, model/event catalogs, and the AI
  panel client script, is accepted through `task-ad933078fd5d`. Critical
  Slice B, public DTO/helper parity for thread/status/poll/history/message/
  event behavior, is accepted through `task-cac06aa451fc`. Critical Slice C,
  canonical terminal DTO ownership/alias strategy, is accepted as a no-change
  decision through `task-b042d7fd4405`: terminal/session/event/approval DTOs
  are canonically owned by `terminalruntime` and surfaced through
  `terminalui`, while AI thread-isolation DTOs remain surfaced through
  `assistantui`. Slice D is non-critical contract
  hardening and migration docs for token/action registry behavior. The
  completed Factory probe still leaves a concrete decision on ACP/status plus
  Go diagnostics DTO parity if those wire types should no longer depend on
  `pkg/uikit`.
- `task-c359cfa15ffa`, core WASM/runtime/form/table facade probe: accepted as
  a read-only table. Critical Slice 1.1, `pkg/ui` runtime mount, callback
  lifecycle, and DOM error-host facade parity, is accepted through
  `task-5f133b387382`. Critical Slice 1.2, WASM file I/O/dropzone/multipart
  facade parity, is accepted through `task-dbef5c874510`. Critical Slice 1.3,
  split runtime, projection-list, and related layout facade parity, is
  accepted through `task-1676ddcd3333`. Deferred cleanup is broader
  route/parse/format helper exports plus `MessageBubble` parity once adopter
  work proves exact needs.

## Safety Rules For Continuation

Do not edit product code in the primary checkout as a supervisor shortcut.
Use workers or isolated module worktrees for implementation. Direct edits to
goal docs, memos, and coordination artifacts are acceptable supervisor work.

When committing nested repository work, commit in this order:

1. owning module, such as `docs`, `bus-ui`, `busdk.com`, or an adopter module;
2. BusDK superproject submodule pointer;
3. supervisor root `projects/busdk` pointer when it changes.

Do not remove dirty worktrees or worker identity checkouts without explicit
review. Use `git worktree remove` and `git worktree prune`, not ad hoc
filesystem deletion, for reviewed clean worktrees.
