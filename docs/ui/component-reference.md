---
title: UI component reference
description: Practical reference for every reusable BusDK UI component and runtime building block.
---

## How To Read This Reference

Each entry names the reusable building block, the shape of data it expects, and
the point where product-specific meaning belongs. Components should receive
screen-ready values from the owning module. Runtime blocks should use
`Action`, `Resource`, and `Effect` as the shared boundary even when an older
helper name remains as a compatibility adapter.

The [component catalog](./component-catalog) is the compact index of every
component and runtime block. The public API source is the
[bus-ui module reference](../modules/bus-ui); the tables below describe the
contract a caller needs when composing Go components or declarative documents.
`Required` names the minimum data needed to render or run the block. `Optional`
lists common extension fields. `Defaults and constraints` records the behavior
that callers can rely on.

## Contract Tables

### Foundation Contracts

| Component | Required | Optional | Defaults and constraints |
| --- | --- | --- | --- |
| `Text` | `value` | Formatter name. | Escapes untrusted scalar values. |
| `RawHTML` | `html`, `reason` | Sanitizer label. | Only audited trusted HTML; never provider text by default. |
| `Element` | `tag`, `children` | `attrs`, `key`. | Stable attribute order; generic HTML only. |
| `Fragment` | `children` | `key`. | Adds no wrapper; preserves child order. |
| `Props` | Attribute key/value pairs. | Boolean or empty attributes. | Deterministic output; invalid keys are rejected or omitted. |
| `VNode` | Node kind and content. | `key`, attrs, children. | Server HTML and Go/WASM mounting use the same tree. |
| `Component` | Render function and props. | Slots, render runtime. | Component state stays UI-local. |
| `Template` | Static tree and dynamic slots. | Dynamic attrs, reusable values. | Slot bounds and escaping are deterministic. |

### Shell And Layout Contracts

| Component | Required | Optional | Defaults and constraints |
| --- | --- | --- | --- |
| `AppShell` | Title and body slot. | Nav, runtime config, asset URLs. | Local app frame; no product policy. |
| `PortalShell` | Host context, title, body slot. | Nav items, module metadata. | Paths and assets come from the host. |
| `SidebarShell` | Header/nav/body slots. | Icon, collapsed state. | Stable content region and collapse classes. |
| `SidebarNav` | Ordered nav items. | Icons, active state, href/action. | Accessible labels remain available in compact mode. |
| `SplitLayout` | Pane slots. | Widths, resize mode. | Uses stable CSS variables for pane sizing. |
| `AssistantShell` | Business and assistant slots. | Width, header options. | Preserves content while assistant visibility changes. |
| `Panel` | Title and body. | Actions, attrs. | Escapes title and keeps body placement stable. |
| `SurfaceCard` | Body. | Header, footer, attrs. | Repeated item surface; no nested page shell. |
| `MetricCard` | Title and value. | Detail, status. | Compact dashboard value display. |

### Navigation, Action, And Form Contracts

| Component | Required | Optional | Defaults and constraints |
| --- | --- | --- | --- |
| `Button` | Label or accessible icon label. | Variant, size, icon, `data-ui-action`, disabled. | Native button; stable action attributes. |
| `IconButton` | Icon and accessible label. | Title, variant, action. | No visible label; accessible name is mandatory. |
| `LinkButton` | Href and label. | Icon, variant, target policy. | Escapes href and applies safe link attrs. |
| `ActionBar` | Ordered actions. | Alignment, density. | Preserves order and wraps predictably. |
| `Menu` | Trigger and items. | Selected item, actions. | Bounded choices with accessible roles. |
| `Tabs` | Labels and active item. | Hrefs or action tokens. | Active state is visible and deterministic. |
| `StatusPill` | Label and semantic status. | Attrs. | Status class comes from a bounded semantic set. |
| `Icon` | Icon name or path. | Title policy. | Shared SVG paths; no product-local icon copies. |
| `Form` | Method, action, body. | Attrs, validation state. | Native form behavior and Enter-submit remain available. |
| `Field` | Label and control. | Hint, error. | Label/control association is stable. |
| `Input` | Type and name. | Value, placeholder, attrs. | File values are not echoed. |
| `TextInput` | Name. | Value, placeholder, attrs. | Single-line escaped value. |
| `PasswordInput` | Name. | Placeholder, attrs. | Does not expose values in diagnostics. |
| `DateInput` | Name. | Value, attrs. | Date value is rendered deterministically. |
| `TextArea` | Name. | Value, placeholder, rows. | Escapes multiline content. |
| `Select` | Name and options. | Selected and disabled flags. | Selected state is explicit. |
| `FilterToolbar` | Field slots and submit action. | Reset action, density. | Compact wrapping filter form. |
| `SubmitState` | Target action and working flag. | Labels, result text. | Prevents duplicate submit while busy. |

### Data Display Contracts

| Component | Required | Optional | Defaults and constraints |
| --- | --- | --- | --- |
| `TextTable` | Headers and rows. | Row attrs. | Deterministic table with header cells. |
| `DataTable` | Columns and rows. | Row actions, selection, empty/loading slots. | Product module owns columns and row values. |
| `RecordList` | Items and row renderer. | Empty slot. | Preserves item order. |
| `SummaryItem` | Title. | Meta, detail, badge. | Escapes text and badge content. |
| `Timeline` | Ordered items. | Status, metadata. | Event order is caller-defined. |
| `EmptyState` | Message. | Action. | Explains absence without hidden logic. |
| `LoadingState` | Message or busy flag. | Progress. | Uses visible busy state. |
| `ResultPanel` | Status and title. | Summary, detail, actions. | Safe result details only. |
| `ErrorBanner` | Message. | Dismiss action, attrs. | Recoverable alert with escaped text. |

### Runtime Contracts

| Block | Required | Optional | Defaults and constraints |
| --- | --- | --- | --- |
| `RuntimeConfig` | Public config keys. | Feature flags, public URLs. | Rejects or omits sensitive fields. |
| `APIURLResolver` | Base path and endpoint path. | Query params. | Preserves mounted module prefixes. |
| `Session` | Storage adapter and credential state. | Bearer/CSRF policy, expiry. | Redacts secrets and exposes safe display state. |
| `Action` | Token and handler. | Method, payload binding, state. | Tokens use stable `data-ui-action` values. |
| `Resource` | Method and resolved path. | Payload, upload fields, expected status. | Centralizes auth, decoding, and fake clients. |
| `Effect` | Trigger and lifecycle handler. | Resource, parser, disposer. | Explicit start, apply, error, and cleanup behavior. |
| `CredentialLoginCard` | Field labels and submit action. | Form attrs, hints. | Provider policy stays in auth APIs. |
| `ProviderError` | Title/status/summary. | Request ID, safe details. | No raw secret payloads. |
| `ClientLog` | App name, level, message. | Endpoint, metadata. | Applies level filtering and redaction. |
| `ErrorHost` | Current error. | Clear action. | Dismissible and recoverable. |
| `CloseGuard` | Active/unsaved flags. | Message, callbacks. | Blocks only when work would be lost. |
| `Disposer` | Cleanup callback. | Chained callbacks. | Idempotent cleanup. |

### Assistant, Terminal, Evidence, And Tooling Contracts

| Component | Required | Optional | Defaults and constraints |
| --- | --- | --- | --- |
| `AIPanel` | Threads, active thread, messages. | Approvals, model, attachments, terminal state. | Assistant workbench; provider policy stays external. |
| `AIThreadList` | Thread items and select action. | Archive action. | Shows active and working state. |
| `AIMessage` | Role and content. | Attrs. | Role classes and safe renderer output. |
| `AIMarkdown` | Text. | Options, href resolver. | Sanitized output only. |
| `AIModelSelect` | Current model and options. | Fallback option. | Selected option is deterministic. |
| `AIAttachmentList` | Attachment labels. | Size, remove action. | Remove action carries stable index. |
| `AIComposer` | Draft input and send action. | Interrupt action, disabled state. | Send/stop actions remain stable. |
| `AIApprovals` | Approval items and decisions. | Request metadata. | Decision actions include request IDs. |
| `AIReviewStatus` | Changed files and status. | Verification detail. | Review state is visible. |
| `AIThreadIsolation` | Owner/worktree/branch. | Conflict state. | Git policy is displayed, not enforced here. |
| `AIDropController` | Drop service and active thread. | Log callback. | Converts drops to attachment updates or safe errors. |
| `TerminalSessionPanel` | State, command, output. | Input, approval, exit, error. | Complete terminal surface. |
| `TerminalOutputView` | Output chunks. | Empty text. | Normalizes stream labels. |
| `TerminalInputBox` | Value and send action. | Stop/exit actions, disabled state. | Textarea plus stable controls. |
| `TerminalApprovalPrompt` | Title and decision actions. | Summary. | Explicit command approval card. |
| `TerminalSessionAdapter` | Events and approval map. | Session metadata. | Converts raw events to terminal props. |
| `EvidenceURLResolver` | Evidence endpoint and path. | API resolver. | Escapes and joins paths safely. |
| `EvidenceLink` | Href and label. | Icon, target policy. | Applies safe link attributes. |
| `EvidencePreview` | Preview URL and metadata. | Fallback text. | Embeds only safe preview types. |
| `ProjectionDetail` | Detail view model and evidence list. | Selected line. | Product owns ledger semantics. |
| `DropZone` | Title or label. | Input slot, actions. | Intake surface only; validation stays product-owned. |
| `ImageGallery` | Items with `src` and `alt`. | Captions, links. | Images are content, not decoration. |
| `CSSBundle` | Theme or default token set. | None. | Emits shared classes and tokens. |
| `CLIRuntimeFlags` | Args. | Output, quiet, verbose, color, chdir. | Standard command behavior. |
| `BrowserOpen` | URL and OS. | Opener override. | Uses supported OS opener mapping. |
| `DeclarativeRenderer` | Document path or data. | Output format, validation mode. | Emits HTML, normalized tree, inventory, or diagnostics. |

## Foundation

`Text` renders untrusted scalar values as escaped text. Use it for labels,
messages, cell values, captions, and any provider text that has not already
been sanitized.

`RawHTML` carries audited trusted HTML with an explicit reason. Use it only for
framework-owned static fragments, sanitized Markdown, or compatibility
boundaries where structured nodes cannot represent the content.

`Element` renders a generic HTML element from a tag, attributes, and children.
Use it when no named component exists and the element is still generic.

`Fragment` groups children without adding a wrapper element. Use it for slots
or conditional rendering where the parent owns the semantic structure.

`Props` stores deterministic HTML attributes. Use it for shared helpers that
must render stable attributes for snapshots, samples, and server output.

`VNode` is the virtual DOM node used by app-level components. Use it when the
same tree should render as server HTML, mount in Go/WASM, and remain
inspectable in unit tests.

`Component` is a reusable function from props, slots, and render context to a
node tree. Keep component state local and UI-specific; product workflow state
belongs in the product view model.

`Template` describes static trees with dynamic slots. Use it for hot paths such
as frequently refreshed rows, compact status blocks, and terminal output frames.

## Shells And Layout

`AppShell` is the standard page frame for a local app. It receives title,
navigation, body, runtime config, and asset URLs.

`PortalShell` is the feature-module frame for portal-mounted pages. It receives
host context, module title, navigation items, and the product body slot.

`SidebarShell` creates a collapsible multi-view shell. Use it for local tools
and portal modules that need stable navigation beside a dense work surface.

`SidebarNav` renders the sidebar navigation list. Items carry labels, hrefs or
actions, icons, active state, and accessible names.

`SplitLayout` divides the screen into resizable work panes such as list/detail,
detail/evidence, or product/assistant regions.

`AssistantShell` places a product workflow next to a toggleable assistant pane.
Use it when the assistant is a working companion, not the whole screen.

`Panel` is a bounded titled work surface. Use it for tool regions, settings,
forms, and focused detail sections.

`SurfaceCard` is a repeated or grouped content surface. Use it for record
cards, summaries, and compact grouped information.

`MetricCard` displays one compact dashboard metric with a title, value, and
detail text.

## Navigation And Actions

`Button` renders a native command button with variant, size, optional icon,
action attributes, and disabled state.

`IconButton` renders an icon-only command. It must have an accessible label or
title because there is no visible text label.

`LinkButton` renders a safe link with button styling. Use it for navigation,
open/download commands, and external links with command affordance.

`ActionBar` groups related commands in stable order. It should keep destructive
actions visually distinct and preserve wrapping behavior on narrow screens.

`Menu` renders a bounded option set from a trigger, items, selected item, and
actions. Use it for compact choices where a select is not the right visual
shape.

`Tabs` switches between sibling views. Use links when tabs navigate and action
tokens when tabs change mounted UI state.

`StatusPill` renders a compact status label. Product modules provide the label
and semantic status; the component owns classes and accessible markup.

`Icon` renders a shared SVG icon path with title policy. Use shared icons for
common commands instead of product-local SVG copies.

## Forms

`Form` wraps native form behavior. Use it when Enter-submit, method, action,
and browser form semantics should remain available.

`Field` associates a label, control, hint, and error. Use it for every visible
form control.

`Input` is the generic typed input. Use it for specialized input types that do
not need a named helper.

`TextInput` renders a single-line text field.

`PasswordInput` renders a password or token field. Values must not leak into
diagnostics or generated public config.

`DateInput` renders a date input with deterministic name and value output.

`TextArea` renders multiline text with stable escaping and row configuration.

`Select` renders a bounded option set with selected and disabled option states.

`FilterToolbar` composes compact filter fields and submit/reset actions for
tables, lists, and search surfaces.

`SubmitState` renders busy or disabled submit feedback. It prevents duplicate
submission and preserves the visible command label.

## Data Display

`TextTable` renders a simple deterministic table from headers and row nodes.
Use it for compact, stable tabular output.

`DataTable` renders dense records with columns, rows, row actions, selection,
and empty/loading state. Product modules own columns and row values.

`RecordList` renders repeated non-tabular records. Use it when rows need
summary layout rather than table cells.

`SummaryItem` renders a title, metadata, detail text, and optional badge.

`Timeline` renders ordered event or audit history. Items should already be
projected into safe display text by the product module.

`EmptyState` explains that content is absent and may include a recovery action.

`LoadingState` shows active loading or work-in-progress state.

`ResultPanel` summarizes an operation result with status, title, summary,
details, and actions.

`ErrorBanner` presents a recoverable error with optional dismiss action.

## Actions, Resources, And Effects

`RuntimeConfig` publishes safe public configuration to server-rendered or
mounted apps. It must not include secrets, credentials, private customer data,
or raw tokens.

`APIURLResolver` resolves module-relative provider paths against the current
host and mounted base path.

`Session` represents browser session state, bearer/CSRF behavior, expiry, and
safe identity display.

`Action` dispatches one user-triggered command by stable token. Use it for
submit, click, approve, archive, upload, send, stop, and provider-job starts.

`Resource` resolves and fetches external data or media. Use it for provider
endpoints, uploads, artifact links, evidence previews, and provider request
adapters.

`Effect` owns background or browser lifecycle behavior. Use it for polling,
event streams, file drops, resize, close guards, logging, and cleanup.

`CredentialLoginCard` renders a generic credential entry surface. The auth
module supplies labels, field names, action targets, and provider state.

`ProviderError` renders a safe provider failure surface with status, summary,
request ID, and approved detail fields.

`ClientLog` sends browser diagnostics to an enabled host endpoint with level
filtering and redaction.

`ErrorHost` renders and clears runtime errors without product modules copying
local alert markup.

`CloseGuard` protects active or unsaved work through explicit close decisions.

`Disposer` owns listener, timer, callback, and mounted-resource cleanup. It
must be safe to call more than once.

## Assistant

`AIPanel` is the full assistant workbench surface with threads, active
messages, approvals, model selection, attachments, and terminal state.

`AIThreadList` renders selectable and archivable assistant threads with active
and working markers.

`AIMessage` renders user, assistant, and system messages with role classes and
safe message content.

`AIMarkdown` renders assistant text through the shared safe Markdown policy.

`AIModelSelect` renders available model options and the current selection.

`AIAttachmentList` renders draft attachment chips with size labels and remove
actions.

`AIComposer` renders the assistant draft input plus send and interrupt actions.

`AIApprovals` renders pending approval cards and routes decisions through
typed actions.

`AIReviewStatus` renders changed-file summaries, verification state, and
review-before-apply status.

`AIThreadIsolation` shows active worktree, branch, owner, and conflict state.

`AIDropController` converts dropped files or paths into attachment updates and
safe errors.

## Terminal

`TerminalSessionPanel` renders the complete embedded terminal surface:
metadata, streamed output, input, approval, exit status, and errors.

`TerminalOutputView` renders stdout and stderr chunks with stream labels and
empty output text.

`TerminalInputBox` renders stdin input plus send and stop or exit actions.

`TerminalApprovalPrompt` renders an explicit command approval request with
decision buttons.

`TerminalSessionAdapter` converts assistant or provider events into
`TerminalSessionPanel` props.

## Evidence And Media

`EvidenceURLResolver` builds safe evidence and artifact URLs from a resolver,
endpoint, and path.

`EvidenceLink` renders safe open or download links with target and referrer
policy.

`EvidencePreview` renders an embeddable preview when the artifact type is safe
and a fallback when it is not.

`ProjectionDetail` presents ledger-like detail evidence. Product modules own
the record semantics; the component owns the evidence surface.

`DropZone` renders file and path intake UI with labels, input slots, and
actions.

`ImageGallery` renders linked image thumbnails with alt text and captions.

## CLI And Tooling

`CSSBundle` emits shared CSS tokens and component classes.

`CLIRuntimeFlags` implements standard command-line behavior for UI tooling:
output, quiet, verbose, color, working directory, help, and version.

`BrowserOpen` opens a local app URL through the current operating system.

`DeclarativeRenderer` renders and validates JSON/YAML UI documents as HTML,
normalized component trees, inventories, or diagnostics.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./component-catalog">Component catalog</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./declarative-documents">Declarative UI documents</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component catalog](./component-catalog)
- [UI building block reference](./components)
- [bus-ui module reference](../modules/bus-ui)
