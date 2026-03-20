---
title: bus-ui — reusable UI component module for BusDK frontends
description: Shared deterministic HTML/CSS component helpers and reusable AI UI rendering primitives for BusDK WASM frontends.
---

## `bus-ui` — reusable UI component module for BusDK frontends

### Synopsis

`bus ui [global flags] [css | version | help]`  
`bus-ui [css | version | help]`

### Description

`bus-ui` provides shared UI building blocks for BusDK frontend modules. It
owns deterministic HTML escaping and attribute ordering helpers, reusable core
controls, shared CSS tokens, generic authentication surfaces, generic form
surfaces, shared download/link actions, reusable summary and metric cards,
generic timeline and gallery renderers, and generic AI interface components.

The module also owns generic assistant text rendering and generic approval-card
formatting so module frontends can keep only workspace-specific behavior and
action wiring in their local code. It also provides shared reusable AI runtime
state objects (`AIPanelSessionState`, `AIConversationState`) so modules avoid
duplicating generic assistant state models, plus interface-based AI refresh
host orchestration (`AIRefreshHost`) for clean state integration boundaries.
It also provides a reusable AI drop-controller (`NewAIDropController`) that
centralizes dropped-path/file import lifecycle wiring for assistant panels.
It also provides a reusable WASM app-scaffold (`WASMAppScaffold`) for generic
logger/error/callback retention and panic-safe async helper wiring.
The app scaffold also tracks explicit wiring teardown callbacks so modules can
dispose listeners/timers deterministically in reusable hosts and tests.
For module test suites, it also provides reusable testkit helpers under
`pkg/uikit/uikittest` (gateway/API stubs and deterministic fixture builders).
For ledger-style frontends, it also provides shared projection DTO contracts
and a reusable JSON-over-HTTP projection query client scaffold.
For AI-enabled frontends, it also provides a reusable AI action controller for
DOM action routing and shared panel action lifecycles.
It also provides a shared Codex model catalog (`DefaultAICodexModelOptions`)
and recursive payload model extraction (`ExtractAIModelCandidates`) so host
modules can show complete model dropdown options, including `gpt-5.4`.
It also provides a shared AI event-method catalog
(`IsKnownAIEventMethod`) so host modules can recognize stable warning, plan,
approval, and terminal-interaction event families without keeping separate
module-local allowlists in sync.
It also provides a shared AI timeline adapter
(`NormalizeAITimelineEvent`, `BuildAITimeline`) so host modules can convert raw
backend event streams into stable message, command, diff, warning, plan, and
approval timeline rows without reimplementing event parsing locally.
It also provides a shared approval-response helper
(`ExecuteAIApprovalRespond`) that sends one approval decision and then refreshes
AI poll state through the same shared reconciliation path used by background
polling, so host modules do not need separate local approval-state cleanup.
It also provides shared review-before-apply presentation primitives
(`AIReviewStatusStrip`, `AIDiffSummaryCard`, `AIVerificationResultBlock`) so
host modules can render a consistent status strip, changed-file summary, and
verification block for coding workflows without inventing local review cards.
It also provides shared per-thread AI activity-state helpers
(`IsAIThreadWorking`, `SetAIThreadWorking`, `BuildAIWorkingThreadState`) so
host modules can keep a stable "AI working" marker in thread lists and avoid
showing the responding placeholder on reopened threads that are no longer the
active worker.
It also provides shared window-close guard wiring
(`BuildAIWindowCloseGuardState`, `WireWindowCloseGuardLifecycle`) so modules can
block browser close while AI work is still active or local draft work is still
unfinished, while also exposing one shared explicit close-attempt path for
native wrappers and tests. The shared AI panel browser client also publishes
the same close-guard bindings (`busUIWindowCloseGuardState`,
`busUIAttemptWindowClose`) for plain HTML/JavaScript hosts such as
`bus-factory`, so downstream modules do not need a separate module-local
beforeunload implementation.
It also provides one shared committed-draft normalization rule
(`NormalizeAICommittedDraft`) and matching composer event wiring so AI text
areas keep raw trailing spaces while focused and only trim on intentional blur
or send.
It also provides shared per-thread workspace/git isolation status helpers
(`AIThreadIsolationStatus`, `BuildAIIsolationBranchName`,
`BuildAIIsolationWorktreePath`, `AIThreadIsolationCard`) so host modules can
surface active isolated scope ownership and deterministic lock conflicts
through one reusable AI panel block instead of inventing separate thread-lock
cards.
It also provides shared in-app terminal primitives
(`TerminalSessionPanel`, `TerminalOutputView`, `TerminalInputBox`,
`TerminalApprovalPromptCard`) so modules can embed a consistent command session
surface with streamed output, input controls, error state, exit metadata, and
approval affordances without inventing separate terminal cards.
It also provides a shared terminal-session snapshot adapter
(`AITerminalSession`, `BuildAITerminalSession`) so host modules can derive one
deterministic command-session view from raw AI events plus pending approvals
and feed that same structure into polling responses and panel rendering.
For ledger-style detail views, it also provides a shared projection detail
presenter that can render the same evidence surface in both transaction detail
and line detail, including PDF preview plus deterministic open/download
controls, while falling back to visible document metadata and actions when
inline preview is unavailable and to a document list when multiple evidence
files are linked.
The module also includes reusable WASM event wiring and DOM error-host helpers
so module frontends do not reimplement common browser wiring patterns.
Those wiring helpers now return disposer callbacks for explicit lifecycle
ownership (`WireAIPanelEvents`, `RegisterAIDropZoneHandlers`,
`WireSplitResize`). The shared error host also uses the same reusable alert and
button styling contract as other `bus-ui` surfaces, with centered content and a
standard right-side dismiss control, so downstream modules get a readable
dismissible error banner without module-local CSS fixes.
It also provides shared callback-registry state (`AICallbackRegistry`), shared
AI-preserving mount behavior (`MountAIPreservedView`), shared standard table
composition (`TextTable`), and shared locale-aware field value formatting
(`LocaleFieldFormatter`) so module-level view code can stay focused on domain
composition.
For multi-view WASM frontends, it also provides a reusable collapsible
left-rail shell (`SidebarShell`) and matching sidebar navigation component
(`SidebarNav`) so modules can group view-specific panels behind one consistent
BusDK navigation pattern instead of inventing separate local sidebars. The
shared sidebar shell is attached to the window edge, supports icon-only
collapse with tooltip copy, and lets modules expose an app icon that opens the
rail on small screens.
For token-gated local portals, it also provides a reusable credential login
card (`CredentialLoginCard`) so modules can share the same labeled username
and password surface instead of assembling separate auth panels locally.
It also provides reusable form-surface primitives (`Field`, `Select`, typed
`Input` helpers, and a semantic form wrapper (`Form`) so local portal modules
can keep generic fields, selectors, Enter-submit behavior, and download
actions out of module-local view code. Shared auth surfaces such as
`CredentialLoginCard` now render through that same form primitive, so
downstream login screens and admin/data-entry views can submit naturally with
the Enter key instead of module-local key handling. It also provides reusable content primitives
(`SurfaceCard`, `MetricCard`, `Timeline`, `ImageGallery`) so modules can share
one visual language for summary cards, event history, and photo collections
instead of duplicating markup and CSS hooks.
For CLI modules that open local UI servers, it also provides shared
cross-platform app-style web shell opener helpers (`OpenURLInBrowser`,
`BrowserOpenCommandForOS`) so modules do not duplicate OS command mapping.
It also provides a reusable virtual DOM runtime (`VNode`,
`RenderVNodeComponent`, `VDOMMount`) so state updates can re-run component
functions and patch DOM incrementally instead of replacing full `innerHTML`.
For low-allocation hot paths, it also provides a compiled template API
(`Tpl(...)`, `TemplateValues`, `TemplateMount`) that mounts once and updates
only pre-bound text/attribute slots.

### Commands

`css` prints embedded shared CSS, `version` prints module version information,
and `help` prints usage text.

### Examples

```bash
bus ui css
bus ui version
bus-ui help
```

### Using from `.bus` files

```bus
ui css
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-timeline">bus-timeline</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vat">bus-vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui reference](../modules/bus-ui)
