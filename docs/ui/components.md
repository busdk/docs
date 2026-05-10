---
title: UI building block reference
description: Reference for generic BusDK UI components, runtime helpers, and app-building primitives.
---

## Foundation

Foundation blocks produce deterministic HTML and component trees.

`Node` is a trusted HTML fragment type. Use `Txt` for escaped text, `Unsafe`
only for audited trusted HTML, `Props`/`P` for attributes, and `El` plus tag
helpers for simple elements.

`VNode` is the app-level virtual DOM node. Use `VText` for escaped text, `VRaw`
for trusted fragments, and `VEl` for elements with deterministic attributes,
children, and optional keys.

`HTMLBuilder` is useful when a component needs streaming-style assembly while
still escaping text and ordering attributes through shared helpers.

Component hooks and `RenderRuntime` provide small local UI state, refs, memo
values, child component slots, and `VNode` component rendering. Use them for
UI-local state, not product business state.

Compiled template nodes and `TemplateValues` provide static tree definitions
with dynamic text and attribute slots for hot paths.

## Shells And Layout

Page shell components define the durable application frame. A product module
should not build full-page boilerplate by hand when a shared shell exists.

`SidebarShell` creates a multi-view app shell with collapsible navigation.
`SidebarNav` renders stable navigation items, active state, icon-only collapsed
mode, tooltips, and link support.

The portal page shell should provide canonical module base paths, CSS asset
links, runtime config, navigation slots, and a main content slot. Feature
modules provide product content; the host provides chrome and route context.

The assistant shell renders a business pane beside a toggleable AI pane. It is
for local apps that need a normal product workflow plus an AI assistant or
terminal companion.

Split-layout primitives divide list, detail, evidence, and line-detail regions.
They should expose stable CSS variables and resize hooks rather than product
modules inventing local resize scripts.

`Panel`, `SurfaceCard`, `MetricCard`, and summary item blocks group content.
Use panels for bounded tool regions, cards for repeated records or summaries,
and metric cards for compact dashboard values.

## Navigation And Actions

`Button` renders primary, secondary, danger, and ghost actions in small, medium,
or large sizes. Buttons may include an icon and may be icon-only when an
accessible label or title is provided.

`LinkButton` renders link-shaped commands with the same shared button styling.
Use it for safe navigation, artifact open/download actions, and external links
that need command affordance.

Icon helpers render shared SVG paths and icon links. Product modules should
reuse shared icons for common commands such as open, download, home, document,
inbox, archive, rename, send, stop, and close.

Action dispatch maps stable action strings to typed handlers. Product modules
should expose generic attributes such as `data-ui-action` or shared AI action
attributes and route those tokens through Go handlers instead of attaching
inline JavaScript.

Action bars group related commands. They should keep destructive actions
visually distinct and preserve stable button order so tests can assert the
available operations for a state.

## Forms

`Form` wraps native form behavior with shared classes. Use it when Enter-submit
semantics and browser form behavior are useful.

`Field` wraps labels and control bodies. Form controls should always be labeled.

`Input`, `TextInput`, `PasswordInput`, `DateInput`, `TextArea`, and `Select`
provide the generic input surface. Product modules configure names, values,
placeholders, selected options, disabled state, validation hints, and actions.

Filter toolbar components should compose fields, selects, search inputs, date
ranges, and action buttons in a compact row that wraps predictably on smaller
screens.

Submit-busy, disabled, validation, and provider-error states should be
represented in the view model, then rendered through generic form/status
components. Product modules should not copy local scripts just to disable a
button during submit.

## Dense Data

`TextTable` renders simple deterministic tables from headers and row nodes. The
framework table family should cover sortable headers, selected rows, compact
metadata cells, status cells, row actions, empty state, and loading state.

List and summary components render repeated records where a table is too rigid.
`SummaryItem` covers a title, metadata, detail, and badge. Product modules can
project records into generic list rows while keeping business-specific labels
in their own view models.

`StatusPill` renders inline status labels. Status tag variants should map to
semantic meanings such as neutral, working, success, warning, danger, and muted.

`EmptyState`, `ErrorBanner`, result panels, and loading panels make absence,
failure, and background work visible without each module inventing its own
markup.

## Provider And Session Helpers

API URL helpers resolve provider routes relative to the current portal or local
app path. They should feed the same resource contract used by forms, uploads,
evidence links, previews, and background refreshes.

Bearer session, CSRF, credential login, and provider-error helpers should be
generic. The auth product module decides labels, scopes, and provider policy;
the shared helpers provide forms, storage/request mechanics, safe failure
presentation, and test seams.

Provider/session runtime should use the same `Action`, `Resource`, and
`Effect` model as the rest of the framework. A credential login submit, JSON
request, file upload, token refresh, and provider status refresh are not
separate app architectures; they are actions or effects operating on resources.
Product modules configure endpoint paths, labels, scopes, permission copy, and
provider DTO projection.

Existing provider clients can remain as compatibility adapters when they expose
the same resource behavior. The reusable framework boundary is the resource
contract, not the concrete helper name used by an older module.

Runtime config components should render public configuration only. Secrets,
tokens, private customer data, and raw credentials must not be embedded in
public config blocks or client logs.

## Assistant Workbench

AI workbench blocks are reusable because many BusDK apps supervise AI work.
They include thread lists, message bubbles, markdown rendering for assistant
text, model selectors, footer metadata, draft normalization, attachment chips,
drop controllers, turn start/interrupt/model actions, polling adapters, and
activity markers.

Approval components render structured pending approvals and route decisions
through typed action handlers. Review components render changed-file summaries,
verification results, and status strips before apply-like actions.

Thread isolation components surface active worktree or branch ownership and
conflict states. They should show enough context for supervision without moving
Git policy into the UI framework.

Close-guard helpers block browser close when AI work, pending approvals,
unsent attachments, or local drafts would be lost.

## Terminal Sessions

Terminal session blocks embed command-like workflows inside a UI.
`TerminalSessionPanel` combines state, command metadata, working directory,
session/process identifiers, output chunks, pending approval, stdin input, exit
status, and errors.

`TerminalOutputView` renders stdout/stderr chunks with stream labels and empty
state. `TerminalInputBox` renders text input plus send/stop actions.
`TerminalApprovalPromptCard` renders approval requests with explicit action
buttons.

The AI terminal adapter converts raw assistant events and pending approval
state into a deterministic terminal-session view model. Product modules should
feed this view model into the generic panel rather than parsing terminal events
inside render functions.

## Evidence, Files, And Media

Evidence helpers resolve safe artifact URLs, decide whether a path can be
embedded, and select related line/detail records. Product modules own document
authorization and path semantics; `bus-ui` owns generic open/download/preview
presentation.

Projection detail presenters render document evidence for ledger-like detail
views. They should support inline preview when safe, visible document metadata
when preview is unavailable, and a list of linked evidence files when multiple
documents exist.

`DropZone` renders upload/drop surfaces. Drop services convert dropped paths or
files into typed attachments. Product modules decide accepted file types,
upload routes, validation, and resulting workflow state.

`ImageGallery` renders linked image thumbnails with captions. Use it for
inspected media, evidence collections, and visual review surfaces where images
are actual content rather than decoration.

## Lifecycle And Diagnostics

`Dispose`, `OnceDispose`, and `ChainDisposers` define deterministic ownership
for listeners, timers, retained callbacks, and mounted resources.

`WASMAppScaffold` owns common Go/WASM wiring: error reporter lookup, logger
lookup, retained callbacks, disposer tracking, panic-safe async execution, and
shared AI refresh.

Client and server loggers should use explicit levels and keep normal command
output separate from diagnostics. Browser logs should be routed through shared
client-log endpoints when the host enables them.

Polling helpers are `Effect` variants that run refresh cycles with guard
conditions, snapshot comparison, and error handling. Product modules configure
the resource and state application; the framework owns repeatable lifecycle
behavior.

Event stream helpers are also `Effect` variants with typed parsing, explicit
abort/disposer ownership, session header injection, and pure parser tests.
Container-run UI is an `Action` plus `Resource` plus result state. Add a
terminal session panel only when the run produces interactive or streamed
command I/O; provider APIs still own authorization and execution policy.

## Test Helpers

`uikittest` provides fake resources, AI API clients, HTTP response helpers,
deterministic fixture builders, and browser-value helpers where WASM tests need
them. Product modules should depend on these fakes instead of hand-writing
local copies for every action flow.

Renderer tests should verify semantic states: escaped output, stable action
tokens, visible labels, accessibility attributes, expected classes, safe links,
and absence of inline scripts or unsafe HTML where the product contract forbids
them.

The [UI component catalog](./component-catalog) is the compact vocabulary for Go
code and declarative JSON/YAML documents. The
[UI component reference](./component-reference) gives practical guidance for
each component and runtime block, while [UI framework examples](./examples)
show complete documents that combine those blocks.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./rendering">Rendering model</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./component-catalog">Component catalog</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../modules/bus-ui)
- [bus-portal module reference](../modules/bus-portal)
