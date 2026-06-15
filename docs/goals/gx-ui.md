# GX/UI Node-First Refactor Handoff

## Goal

This goal tracks the GX/UI architecture refactor that moves BusDK frontend
code away from string-first UI composition and toward typed Go/GX render
trees.

The target architecture is:

> `bus-gx` owns the source syntax, compiler, render tree, safe HTML rendering,
> browser/runtime primitives, and low-level tests. `bus-ui` owns reusable
> component families, public UI facades, compatibility adapters, CSS hooks,
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
- compatibility wrappers remain only as deprecated migration aliases or
  clearly named `...HTML` string-boundary helpers.

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

Compatibility code may remain when it is explicitly deprecated, tested as
legacy behavior, and not used by current product/default docs as the normal
path.

Before calling the goal complete, run a fresh audit across at least:

```bash
git grep -nE 'pkg/uikit|Checked|NodeChecked|BodyHTML|HeadHTML|MainHTML|ui\.Unsafe|ui\.VRaw|TrustedMarkdownHTML|strings\.Replace|slot|post-render' \
  -- bus-ui bus-portal bus-portal-auth bus-portal-ai bus-portal-accounting bus-portal-notes docs busdk.com
```

Then classify every hit as one of:

- accepted compatibility/deprecated API;
- internal test coverage for compatibility;
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
- compatibility adapters;
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
