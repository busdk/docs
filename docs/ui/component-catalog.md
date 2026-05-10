---
title: UI component catalog
description: Complete catalog of reusable BusDK UI framework building blocks and their intended usage.
---

## Catalog Model

The component catalog is the shared vocabulary for BusDK UI apps. Each block
must be available to Go callers and to declarative JSON/YAML UI documents where
that makes sense. A block should be small, deterministic, and useful outside a
single product module.

Rows define reusable contracts. Product modules depend on catalog rows through
the public `bus-ui` module surface instead of copying local one-off code.
Component names map to declarative `kind` values and to Go component types,
constructors, or helper functions under the `github.com/busdk/bus-ui/pkg/uikit`
API.

The catalog uses five common fields: `kind` names the component or runtime
block; `purpose` explains when to use it; `inputs` describes the props, slots,
or view-model shape; `output` describes the rendered or runtime result; and
`tests` names the behavior that should be covered by unit tests. Availability
is current for the documented framework contract; compatibility adapters may
keep older helper names while exposing the same catalog behavior.

## Core Vocabulary

| Concept | Covers | Rule |
| --- | --- | --- |
| `Node` | Escaped text, trusted fragments, elements, props, virtual nodes, templates. | Rendering must be deterministic and inspectable. |
| `Component` | Reusable functions from props, slots, and view-model data to nodes. | Components do not own product authority or provider policy. |
| `Shell` | Page and app frames such as portal, sidebar, assistant, and split layouts. | A shell owns slots and chrome; product modules provide content. |
| `Collection` | Tables, lists, timelines, galleries, summaries, and repeated records. | Collections receive projected rows/items and expose state slots. |
| `State` | Empty, loading, busy, warning, error, result, and status surfaces. | State is visible and testable, not hidden inside local scripts. |
| `Action` | Submit, click, approve, archive, send, stop, upload, and provider-job starts. | Actions use stable tokens and typed handlers. |
| `Resource` | API endpoints, artifact URLs, evidence previews, upload targets, and provider data. | Resources centralize path resolution, auth, decoding, and fake clients. |
| `Effect` | Polling, event streams, close guards, drops, resize, logging, and cleanup. | Effects have explicit start, apply, error, and dispose behavior. |

## Foundation Components

| Kind | Purpose | Inputs | Output | Tests |
| --- | --- | --- | --- | --- |
| `Text` | Render untrusted scalar content. | String or scalar value. | Escaped text node. | Escapes HTML-sensitive characters. |
| `RawHTML` | Carry audited trusted HTML at narrow boundaries. | Trusted HTML string plus reason. | Unescaped HTML fragment. | Use is explicit and absent from unsafe paths. |
| `Element` | Generic HTML element. | Tag, attributes, children. | Deterministic element HTML or `VNode`. | Stable attribute order and escaped tag/attrs. |
| `Fragment` | Group children without a semantic wrapper. | Children. | Concatenated children or virtual fragment. | Child order is stable. |
| `Props` | Shared attribute map. | Key/value attributes. | Deterministic attribute string. | Empty keys and empty values are handled predictably. |
| `VNode` | App-level virtual DOM node. | Tag, props, children, text, raw HTML, key. | Deterministic HTML and mountable virtual tree. | Key extraction, text escaping, child order. |
| `Component` | Function component with render context. | Render runtime, props, child slots. | HTML or `VNode` subtree. | Hook state remains scoped and stable. |
| `Template` | Low-allocation static tree with dynamic slots. | Static nodes, dynamic text slots, dynamic attribute slots. | Rendered HTML or mounted update target. | Slot bounds, escaping, update behavior. |

## Shell And Layout Components

| Kind | Purpose | Inputs | Output | Tests |
| --- | --- | --- | --- | --- |
| `AppShell` | Standard application page frame. | Title, body slot, nav slot, runtime config, asset URLs. | Full app layout. | Asset links, title, body slot, no duplicated shell markup. |
| `PortalShell` | Portal-mounted feature module frame. | Host context, module title, nav items, body slot. | Portal-compatible module page. | Canonical paths and host-provided assets. |
| `SidebarShell` | Collapsible multi-view local or portal app shell. | Header, app icon, collapsed state, nav slot, body slot. | Sidebar layout with content region. | Active state, collapse classes, tooltips, link support. |
| `SidebarNav` | Navigation list inside a sidebar. | Items with label, href, icon, active state. | Stable nav links/buttons. | Sorting when required, active item, accessible labels. |
| `SplitLayout` | List/detail/evidence or pane-based work surface. | Pane slots, widths, resize mode. | Responsive split panes. | Stable CSS variables and resize constraints. |
| `AssistantShell` | Business pane with toggleable assistant pane. | Business slot, AI slot, width, header options. | App shell with assistant panel controls. | Toggle, resize, open state, preserved content. |
| `Panel` | Bounded titled work surface. | Title, body slot, attributes. | Section with shared panel classes. | Title escaping and body placement. |
| `SurfaceCard` | Repeated or grouped card-like surface. | Body slot, attributes. | Article with card styling. | Class composition and child preservation. |
| `MetricCard` | Compact dashboard metric. | Title, value, detail. | Panel-style metric block. | Escaping and readable value/detail output. |

## Navigation And Action Components

| Kind | Purpose | Inputs | Output | Tests |
| --- | --- | --- | --- | --- |
| `Button` | Command button. | Label, variant, size, icon, action attrs, disabled state. | Native button with shared classes. | Variant classes, accessible names, action attrs. |
| `IconButton` | Compact icon-only command. | Icon, aria label, title, action attrs, variant. | Button with icon and no visible label. | Requires accessible label/title. |
| `LinkButton` | Link with command affordance. | Href, label, icon, variant, target policy. | Anchor styled as button. | Safe link attrs and href escaping. |
| `ActionBar` | Group related commands. | Ordered actions, alignment, density. | Stable button group. | Order, disabled/destructive state, wrapping. |
| `Menu` | Bounded option set. | Trigger, items, selected item, actions. | Accessible menu/listbox pattern. | Keyboard and selected-state tests. |
| `Tabs` | Switch between sibling views. | Tab labels, href/action, active tab. | Tablist or nav links. | Active tab and accessible roles. |
| `StatusPill` | Inline status marker. | Label, semantic status, attrs. | Span with status classes. | Status class and text. |
| `Icon` | Shared SVG icon. | Icon name/path, title policy. | SVG node. | Known icon renders expected path. |

## Form Components

| Kind | Purpose | Inputs | Output | Tests |
| --- | --- | --- | --- | --- |
| `Form` | Native form wrapper. | Method, action, body slot, attributes. | Form with shared classes. | Enter-submit compatibility and attrs. |
| `Field` | Labeled control wrapper. | Label, control slot, hint, error. | Label/control structure. | Label text and control association. |
| `Input` | Generic typed input. | Type, name, value, placeholder, attrs. | Input element with shared classes. | Type/value/name escaping and file value omission. |
| `TextInput` | Single-line text value. | Name, value, placeholder, attrs. | Text input. | Placeholder and value handling. |
| `PasswordInput` | Password or token input. | Name, value, placeholder, attrs. | Password input. | Does not leak value in diagnostics. |
| `DateInput` | Date selector. | Name, value, attrs. | Date input. | Stable name/value output. |
| `TextArea` | Multiline text. | Name, value, placeholder, rows, attrs. | Textarea. | Escapes value and sets rows. |
| `Select` | Bounded option set. | Name, options, selected/disabled flags. | Select with option children. | Selected and disabled option handling. |
| `FilterToolbar` | Compact data filtering surface. | Field slots, submit/reset actions. | Responsive toolbar form. | Wrapping, action tokens, query names. |
| `SubmitState` | Busy/disabled submit feedback. | Working flag, labels, target action. | Button or result status. | Prevents duplicate action and preserves label. |

## Data Display Components

| Kind | Purpose | Inputs | Output | Tests |
| --- | --- | --- | --- | --- |
| `TextTable` | Simple deterministic table. | Headers, row nodes. | Table with thead/tbody. | Header cells and row order. |
| `DataTable` | Dense records with actions/status. | Columns, rows, row actions, selection, empty state. | Responsive data table. | Cell escaping, actions, empty/loading states. |
| `RecordList` | Repeated non-tabular records. | Items, row renderer, empty state. | List or article collection. | Item order and empty state. |
| `SummaryItem` | Title/meta/detail row with badge. | Title, meta, detail, badge. | Article summary row. | Badge and text escaping. |
| `Timeline` | Event or audit history. | Timeline items with body and attrs. | Vertical event list. | Item order and status classes. |
| `EmptyState` | Explain absence of content. | Message, optional action. | Muted paragraph or panel. | Message escaping and optional action. |
| `LoadingState` | Indicate active loading/work. | Message, progress, busy flag. | Loading panel or inline state. | Busy attributes and text. |
| `ResultPanel` | Summarize operation result. | Status, title, summary, detail, actions. | Result/status surface. | Semantic status and safe details. |
| `ErrorBanner` | Present recoverable error. | Message, dismiss action, attrs. | Alert block. | Escaping and dismiss action token. |

## Actions, Resources, And Effects

| Kind | Purpose | Inputs | Output | Tests |
| --- | --- | --- | --- | --- |
| `RuntimeConfig` | Publish safe public config. | Public keys, URLs, feature flags. | JSON script or mounted config object. | Refuses or omits sensitive fields. |
| `APIURLResolver` | Resolve relative API paths. | Current location, base path, endpoint path. | Canonical URL string. | Prefix rewriting and query preservation. |
| `Session` | Represent and apply browser session state. | Storage adapter, credential state, bearer/CSRF policy, expiry. | Safe session view model and request headers. | Missing session, stale CSRF, under-scoped session, redaction. |
| `Action` | Dispatch one user-triggered command. | Token, handler, method, payload binding, busy/result/error state. | Typed handler call, native form, or request invocation. | Duplicate prevention, disabled state, success/error transitions. |
| `Resource` | Resolve and fetch external data or media. | URL resolver, request method, payload/upload fields, expected status. | Typed response, provider error, artifact URL, or upload result. | Status handling, invalid JSON, bad file, path safety, no secret logging. |
| `Effect` | Own background or browser lifecycle behavior. | Trigger, resource, parser/apply callback, abort/disposer policy. | Polling, event-stream, drop, resize, close-guard, or log lifecycle. | Cleanup, abort, malformed payloads, reconnect/error display. |
| `CredentialLoginCard` | Generic credential login surface. | Labels, form attrs, username/password names, submit label. | Login panel with fields. | Labels, form action, no inline scripts. |
| `ProviderError` | Safe provider failure surface. | Title, status, summary, request ID, safe details. | Error/result block. | No raw secret payloads. |
| `ClientLog` | Browser-to-server diagnostic channel. | App name, level, message, endpoint. | Structured log request. | Level filtering and redaction. |
| `ErrorHost` | Dismissible runtime error display. | Current error, clear action. | Alert host. | Report/clear/recover behavior. |
| `CloseGuard` | Protect active or unsaved work. | Working flags, draft flags, message. | beforeunload/native close decision. | Blocks only when needed. |
| `Disposer` | Own browser listeners and callbacks. | Disposer callbacks. | Idempotent cleanup chain. | Double-call safety and callback release. |

## Assistant Components

| Kind | Purpose | Inputs | Output | Tests |
| --- | --- | --- | --- | --- |
| `AIPanel` | Full assistant workbench panel. | Threads, active thread, messages, approvals, model, attachments, terminal state. | Assistant aside/panel. | Thread/list/detail states and active work marker. |
| `AIThreadList` | Select/archive assistant threads. | Thread items, select action, archive action. | Thread list with activity badges. | Active/working state and action attrs. |
| `AIMessage` | Render user/assistant/system message. | Role, rendered message HTML, attrs. | Message bubble. | Role classes and safe message renderer usage. |
| `AIMarkdown` | Render assistant text safely. | Text, options, href resolver. | Sanitized message HTML. | Code, emphasis, path links, escaping. |
| `AIModelSelect` | Model option picker. | Current model, options. | Select control. | Selected option and auto fallback. |
| `AIAttachmentList` | Draft attachment chips. | Attachment labels, size labels, remove action. | Attachment list. | Remove index and size labels. |
| `AIComposer` | Draft input and send/stop actions. | Textarea, send button, interrupt button, disabled state. | Composer block. | Send/stop action attrs and disabled state. |
| `AIApprovals` | Pending approval cards. | Structured approval map/items. | Approval section. | Decision actions and request IDs. |
| `AIReviewStatus` | Review-before-apply state. | Changed files, verification, status. | Status strip and review cards. | File summaries and verification result. |
| `AIThreadIsolation` | Show worktree/branch ownership. | Owner, branch, worktree, conflict state. | Isolation status card. | Active/conflict presentation. |
| `AIDropController` | Import dropped paths/files. | Drop services, active thread, log callback. | Attachment updates and errors. | Path/file import success and failures. |

## Terminal Components

| Kind | Purpose | Inputs | Output | Tests |
| --- | --- | --- | --- | --- |
| `TerminalSessionPanel` | Complete embedded terminal surface. | State, command, cwd, session IDs, output, input, approval, exit, error. | Terminal panel. | State classes, metadata, approval/input rendering. |
| `TerminalOutputView` | Streamed stdout/stderr output. | Output chunks and empty text. | Output list with stream labels. | Stream normalization and empty output. |
| `TerminalInputBox` | Stdin input and stop/send actions. | Value, placeholder, send/exit actions, disabled flags. | Textarea plus controls. | Disabled state and action attrs. |
| `TerminalApprovalPrompt` | Command approval request. | Title, summary, decision actions. | Approval card. | Button variants and action tokens. |
| `TerminalSessionAdapter` | Convert events into terminal view model. | AI events and approval map. | `TerminalSessionPanel` props. | Lifecycle, exit status, stderr/stdout, approval waits. |

Container-run UI is not a separate architecture. Model it as `Form` +
`Action` + `Resource` + `ResultPanel`, and add `TerminalSessionPanel` only when
the run produces an interactive or streamed command session.

## Evidence And Media Components

| Kind | Purpose | Inputs | Output | Tests |
| --- | --- | --- | --- | --- |
| `EvidenceURLResolver` | Build safe evidence URLs. | API URL resolver, evidence endpoint, path. | Resolved artifact URL. | Path escaping and endpoint joining. |
| `EvidenceLink` | Open/download evidence artifact. | Href, label, icon, target policy. | Safe link/action. | `target`, `rel`, and href safety. |
| `EvidencePreview` | Inline embeddable evidence preview. | Evidence path, preview URL, metadata. | Iframe/image/object fallback. | Embeddable checks and fallback text. |
| `ProjectionDetail` | Ledger-like detail evidence presenter. | Detail view model and evidence list. | Detail panel with evidence actions. | Single/multiple evidence cases. |
| `DropZone` | File/path intake surface. | Title, copy, input slot, actions. | Drop area. | Labels, actions, input placement. |
| `ImageGallery` | Visual media collection. | Items with href, src, alt, caption. | Figure gallery. | Alt text, caption, safe link attrs. |

## CLI And Tooling Components

| Kind | Purpose | Inputs | Output | Tests |
| --- | --- | --- | --- | --- |
| `CSSBundle` | Emit shared CSS tokens and classes. | None or theme name. | CSS bytes. | Contains expected component classes. |
| `CLIRuntimeFlags` | Standard CLI behavior. | Args, output/quiet/verbose/color/chdir flags. | Parsed flags and remaining args. | Conflicts, output file, chdir, help/version. |
| `BrowserOpen` | Open local app URL. | URL and OS. | Browser command or opener result. | OS command mapping. |
| `DeclarativeRenderer` | Render JSON/YAML UI document. | UI document file and renderer options. | HTML, component tree, or validation diagnostics. | Schema validation and deterministic render. |

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./components">Building blocks</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./component-reference">Component reference</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../modules/bus-ui)
- [bus-portal module reference](../modules/bus-portal)
