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

Local Spark workers were started for those two core facade slices, but several
new App Server workers began accepting messages and then completing turns
without any assistant response or diff. A Bus infrastructure task was opened as
`task-4eb87d0bfa61` to diagnose the local-dev App Server worker turn delivery
or session/tool-path failure before more product worker dispatch is trusted.
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
