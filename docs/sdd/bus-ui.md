---
title: bus-ui — reusable UI primitives and AI UI components (SDD)
description: Software design for bus-ui as the shared deterministic UI component module for BusDK WASM frontends.
---

# bus-ui — reusable UI primitives and AI UI components (SDD)

## Introduction and Overview

`bus-ui` is the shared UI module for BusDK frontends. It owns deterministic
HTML component rendering, shared CSS tokens, and reusable AI interface
components that multiple modules consume. It does not contain module business
logic, accounting logic, routing, or API policy.

The module is used by WASM frontends such as `bus-ledger` to keep generic UI
structure out of feature modules. Feature modules compose module-specific views
by calling `bus-ui` primitives.

## Requirements

FR-UI-001 Deterministic HTML output. Component helpers must render attributes
in stable order and escape user-provided text values.

FR-UI-002 Reusable primitives. Core controls (button, panel, message, text
input, textarea, alert, empty-state) must be reusable without coupling to one
module layout.

FR-UI-003 Shared AI controls. Generic AI panel controls must be provided as
reusable components: icon action buttons, message bubbles, thread list rows,
header composition, status strip, sign-in prompt, approvals section, model
selector, footer status/meta block, attachment chips, and composer block.

FR-UI-004 Deterministic AI inline markdown rendering. Shared rendering for
assistant text must support explicit options for inline code, markdown links,
autolinks, bold, and italic, with safe escaping and deterministic transform
behavior.

FR-UI-005 Approval card formatting. Shared formatting for approval requests
must parse normalized fields from nested JSON payloads and render clear
command/cwd/path/reason blocks with deterministic HTML structure.

FR-UI-006 Shared attachment size formatting. Attachment byte-size formatting
must be deterministic and reusable across modules.

FR-UI-008 Shared attachment composition helpers. Attachment reference
normalization, user-message attachment section composition, and attachment list
rendering must be reusable across modules.

FR-UI-007 No module business logic. The module must not depend on accounting
rules, ledger projection rules, period-lock rules, or module-specific dataset
contracts.

## System Architecture

`bus-ui` has three layers. The utility layer (`Escape`, `Attrs`, `Classes`)
provides deterministic HTML primitives. The component layer builds reusable
HTML snippets and AI UI blocks from plain structs and values. The asset layer
embeds shared CSS for these primitives and exports it for frontend integration.

The module is pure rendering logic. Runtime event handling, request lifecycles,
and workspace-specific policy stay in consuming modules.

## Component Design and Interfaces

`pkg/uikit/uikit.go` provides base deterministic rendering helpers.
`pkg/uikit/html_builder.go` provides a reusable deterministic HTML builder for
composable element rendering (`OpenTag`, `ElementText`, `TD`, `TH`) so modules
can replace repeated `WriteString` concatenation with reusable tag helpers.
`pkg/uikit/html_nodes.go` provides function-style node composition helpers so
modules can write table/layout structures with props-first components (`Tr`,
`Td`, `Th`) and define their own reusable components using the same primitives
and deterministic attribute rendering (`Props`, `P`, `El`) using direct
`Tag(attrs, children...)` element helpers.
`pkg/uikit/table_helpers.go` provides shared `TextTable` composition so modules
can render standard header+row tables without duplicating local table assembly.

`pkg/uikit/components.go` provides generic and AI-specific components:
`Button`, `Panel`, `MessageBubble`, `TextInput`, `TextArea`, `ErrorBanner`,
`EmptyState`, `AIIconActionButton`, `AIMessage`, `AIThreadList`,
`AIThreadTitleByID`, `AIHeader`, `AIStatus`, `AILoginPrompt`,
`AIApprovalsSection`, `AIModelSelect`,
`AIFooterMeta`, `AIAttachmentList`, and `AIComposer`.

`pkg/uikit/ai_markdown.go` provides shared inline AI markdown rendering via
`RenderAIMessageTextWithOptions` and `RenderAIMessageText`. The caller supplies
the href resolver callback, so module-specific routing stays outside `bus-ui`.

`pkg/uikit/ai_helpers.go` provides shared `FormatAIApprovalCardHTML`,
`FormatAttachmentSize`, `NormalizeAIAttachmentRefs`,
`ComposeUserMessageWithAttachments`, `RenderAIAttachments`, and
`StripTrailingLineRef`, `NormalizeAILocalFileReference`,
`ResolveAIMessageHref`, and `StringMapValue`.

`pkg/uikit/ai_chat_buffer.go` and `pkg/uikit/ai_adapters.go` provide shared
assistant message-buffer mutation helpers and reusable adapter helpers for
thread metadata and attachment metadata conversion into shared UI types.

`pkg/uikit/ai_thread_state.go` and `pkg/uikit/ai_stream_filters.go` provide
shared helpers for thread attachment-key derivation, typed attachments
snapshots, and assistant stream final/delta method classification and duplicate
final-skip predicate handling.

`pkg/uikit/ai_actions.go` provides shared action-dispatch utility helpers for
AI thread-buffer initialization, normalized thread activation, and attachment
removal by index, plus reusable thread-selection and turn-start success state
transition reducers.
`pkg/uikit/ai_action_handlers_js.go` provides shared WASM AI action-handler
building blocks for approval-response dispatch and attachment-remove dispatch,
so module action controllers can reuse canonical DOM-target parsing and API
call choreography.
`pkg/uikit/ai_actions_panel.go` and `pkg/uikit/ai_actions_panel_js.go` provide
shared send/model action helpers for panel draft+DOM input extraction and
model-set lifecycle updates.
`pkg/uikit/ai_actions_panel.go` also provides shared send-action lifecycle
orchestration (`ExecuteAISendAction`) so module action handlers can keep only
module-specific route/context sourcing.
`pkg/uikit/ai_action_controller_js.go` provides reusable AI panel action
controller orchestration (`AIActionController`) for DOM action routing and
shared action lifecycles (toggle/login/send/thread/model/approval/attachment).
`pkg/uikit/ai_thread_actions.go` provides shared thread lifecycle action
helpers for new/select/archive flows and shared panel+conversation active-thread
state application so module controllers can keep only module-specific rename
prompt policies.
`pkg/uikit/ai_thread_rename_js.go` provides shared rename-thread lifecycle
execution with injectable prompt behavior for module-specific UX prompts.
`pkg/uikit/ai_turn_start.go` provides shared turn-start payload/context
composition and reusable execution helper that applies shared panel/conversation
state transitions after successful turn creation.
`pkg/uikit/ai_drop_state.go` provides shared dropped-attachment state helpers
for deterministic bucket initialization, append behavior, and user-visible error
message formatting.
`pkg/uikit/ai_drop_controller_js.go` provides shared drop-controller wiring
(`AIDropController`) that owns common dropped-path/file import flows
(recover-to-reporter handling, shared state transitions, and optional rerender
callbacks) so module code only provides route/policy configuration.

`pkg/uikit/ai_panel_helpers.go` provides shared AI panel helper logic for
resolving active-thread header titles and producing standard approval action
lists, deterministic approval-item view-models, and reusable header-props
composition.

`pkg/uikit/ai_polling.go` provides shared AI polling/event orchestration
helpers for model-option normalization, active-thread resolution, delta-turn
state tracking, and bounded message-buffer retention.
`pkg/uikit/ai_poll_api.go` also provides a consolidated poll API helper
(`FetchAIPoll`) so frontends can fetch status, threads, and event deltas in a
single request when the backend supports `v1/ai/poll`.

`pkg/uikit/moneyfmt.go` provides shared money formatting helpers for currency
symbol mapping, fixed two-decimal numeric formatting, and deterministic
currency fallback rendering when locale-specific formatters are unavailable.

`pkg/uikit/numeric.go` and `pkg/uikit/format_locale_js.go` provide shared
numeric parsing, near-zero detection, and WASM locale-aware money/date-time
formatting helpers, including shared non-zero amount + currency formatting.
`pkg/uikit/field_formatter_js.go` provides shared locale-aware field display
formatting (`LocaleFieldFormatter`) for generic money/date/account/id rendering
rules used by module presenters.
`pkg/uikit/format_account.go` provides a shared account-code label formatter
for deterministic account/ref display composition across modules.

`pkg/uikit/ai_http.go` provides shared JSON HTTP request helpers for GET and
POST+decode workflows.
`pkg/uikit/browser_open.go` provides shared cross-platform browser opener
helpers for module CLI startup hooks so OS opener mapping is implemented once
and reused by modules.
`pkg/uikit/assistant_shell_page.go` provides shared static-shell page
composition for "business pane + toggleable AI pane" module UIs so modules can
reuse one root shell and attach business-specific view content. The shared
shell keeps the AI pane as a right-side split panel in open state for
consistent module UX.

`pkg/uikit/action_dispatch.go` provides generic reusable action-dispatch
primitives for UI action routing without module-specific branching logic.
`pkg/uikit/ai_action_router.go` adds a reusable AI action-router coordinator
that combines deterministic user-action logging/target description with shared
handler dispatch, with info-level logs for action visibility in server logs.

`pkg/uikit/logger.go` and `pkg/uikit/logger_js.go` provide a generic logger
interface and reusable client logger implementation, including a WASM-specific
constructor that composes console logging with asynchronous server forwarding.

`pkg/uikit/error_reporter.go` provides a reusable interface-based error
reporting abstraction that composes logging, UI error presentation, clear
operations, and panic-to-message recovery handling.
`pkg/uikit/runtime_helpers.go` adds reusable panic-recovery helpers that bridge
`recover()` semantics to `ErrorReporter` and provide a panic-safe async wrapper
for frontend event handlers.

`pkg/uikit/gateway_client.go` provides an interface-based reusable HTTP gateway
client with pluggable path resolver and shared JSON GET/POST decoding behavior.

`pkg/uikit/polling.go` provides a reusable generic polling-cycle helper that
captures before/after snapshots around a poll function and reports whether
observable state changed.

`pkg/uikit/component_hooks.go` provides a minimal Go-style function-component
runtime with reusable render context and hooks (`UseState`, `UseRef`,
`UseMemo`) for composable deterministic HTML rendering without a virtual DOM.
`pkg/uikit/vdom.go`, `pkg/uikit/vdom_component_hooks.go`, and
`pkg/uikit/vdom_dom_js.go` provide a reusable virtual DOM model (`VNode`),
function-component VDOM rendering (`RenderVNodeComponent`), and a WASM mount
adapter (`VDOMMount`) that incrementally patches DOM nodes (keyed by reserved
`key` attribute in `VEl`) instead of replacing root `innerHTML` on each
state-driven re-render.
`pkg/uikit/vtemplate.go` and `pkg/uikit/vtemplate_js.go` provide a compiled
template runtime for low-allocation rerenders: define static shape once
(`TemplateNode`/`Tpl(...)`), keep dynamic values in reusable slot arrays
(`TemplateValues`), mount once, then update only bound text/attribute slots
(`TemplateMount.RenderValues`) on each state change. Consumers can call
`TemplateMount.Invalidate` when some other renderer replaces root DOM content,
so the next template render remounts bindings safely. The template model also
supports static trusted raw children (`TRaw`) for fixed SVG/icon payloads.

`pkg/uikit/app_state.go` provides reusable generic UI app-state structs for
panel layout dimensions and AI panel session state, including default-state
constructors and polling activity helper logic, plus a reusable
`AIConversationState` that centralizes generic thread/message/attachment/
approval/runtime tracking for AI-enabled WASM frontends.

`pkg/uikit/app_state_reducers.go` provides reusable app-state reducer helpers
for applying AI status snapshots into panel state and for applying panel resize
mode changes into layout dimensions.

`pkg/uikit/ai_drop_service.go` and `pkg/uikit/ai_drop_service_js.go` provide
interface-based dropped-path/file import services that wrap shared import
orchestration with pluggable import/upload callbacks.
`pkg/uikit/ai_drop_actions_js.go` provides shared drop-action helpers for
drop-target visual state and path/file import state transitions.
`pkg/uikit/ai_href_resolver.go` provides shared resolver composition helper for
module app-route policy + evidence-link mapping.
`pkg/uikit/evidence_helpers.go` provides shared evidence URL resolver building,
embeddable evidence extension policy, and generic selected-line lookup helper.

`pkg/uikit/ai_api_client.go` provides a typed interface-based AI API client
that wraps shared gateway POST calls behind stable method names for common AI
panel operations.
`pkg/uikit/ai_runtime_js.go` provides a shared runtime service container
(`AIRuntime`) that centralizes gateway/API/logger/error/drop service wiring for
WASM modules with module-specific options.
It also provides a profile-oriented constructor (`NewAIRuntimeProfile`) for
module bootstrap wiring without local runtime wrapper constructors.
`pkg/uikit/app_scaffold_js.go` provides a shared WASM app scaffold
(`WASMAppScaffold`) that wraps common runtime logger/error-reporter/callback
retention and panic-safe async wiring helpers for module app bootstrap code.
It also provides wiring lifecycle tracking and teardown (`TrackDispose`,
`DisposeAll`) so modules can explicitly unbind listeners/timers in reusable
hosts and tests.
`pkg/uikit/uikittest/*` provides reusable test doubles and fixtures for module
WASM tests (gateway/API stubs and deterministic HTTP/location helpers) so
frontend modules avoid duplicating identical scaffolding in local test files.
`pkg/uikit/projection_models.go` provides shared typed list/detail projection
payload contracts for ledger-style frontends, and
`pkg/uikit/projection_query.go` provides reusable JSON-over-HTTP list/detail
query-client scaffolding so modules keep only endpoint path/mode policy local.
It also provides route-policy-first construction through
`ProjectionQueryRoutePolicy` and `NewProjectionQueryClientForRoutes` so modules
can avoid local wrapper factories around shared query client setup.
`pkg/uikit/projection_list_panel.go` provides reusable projection list-panel
mode/header/row/title-action view-model helpers over shared projection payloads.
`pkg/uikit/projection_detail_presenter.go` provides reusable projection detail
field/line/evidence presenters and line-summary compatibility fallback logic.
`pkg/uikit/split_controller_js.go` provides reusable split-controller helpers
for route selection parsing and AI panel/message render-prop adaptation so
module controllers can keep only dataset-specific projection wiring.
`pkg/uikit/split_layout.go` provides reusable split shell visibility/class/style
primitives and root composition helpers so modules only provide child panel
renderers.

`pkg/uikit/ai_events.go` provides shared AI event parsing helpers for
thread/turn extraction and assistant message fragment extraction from event
payloads.
`pkg/uikit/ai_models.go` provides shared canonical AI gateway wire-model
payload types for status/events/threads/history/attachments.
`pkg/uikit/ai_refresh.go` provides shared AI polling refresh orchestration
that applies status/thread/history/event updates into mutable UI state with
configurable callbacks for event logging and message application behavior.
It also exposes interface-based host orchestration (`AIRefreshHost`,
`RefreshAIHost`) so frontend modules can pass state through stable interfaces
instead of rebuilding refresh-state transfer logic locally.
`pkg/uikit/ai_refresh_host_state.go` provides a reusable state-backed
`AIRefreshHost` adapter for panel/conversation pointer wiring.
`pkg/uikit/ai_refresh_callbacks.go` provides reusable default callback
construction (`AIRefreshCallbacksForConversation`) for conversation-bound delta
and final message application.

`pkg/uikit/ai_event_apply.go` provides a reusable AI event-batch apply
coordinator with callback hooks for delta/final text application and
turn/thread/process lifecycle transitions.

`pkg/uikit/ai_poll_api.go` provides reusable AI polling API-path helpers for
status/thread/history/event fetches through a shared gateway client, including
consolidated `v1/ai/poll` fetch support (`FetchAIPoll`).

`pkg/uikit/ledger_routes.go` provides shared route parsing/building helpers for
transaction and line-detail navigation in day-book/general-ledger style UIs.
`pkg/uikit/subroute.go` and `pkg/uikit/subroute_js.go` provide shared
location-hash to normalized subroute helpers for hash-routed WASM frontends.
`pkg/uikit/globals_js.go` provides shared browser global accessors
(`GlobalAccessor`, `SetGlobalAccessor`, `GlobalRoot`, `GlobalDocument`,
`GlobalWindow`, `GlobalLocation`, `GlobalConsole`, `GlobalPrompt`,
`GlobalIntl`, `GlobalDateCtor`, `GlobalNumberCtor`,
`GlobalUint8ArrayCtor`, `GlobalElementMatchesFn`) and
`CurrentGlobalSubroute` convenience helper. WASM code paths should consume
global values only through this accessor layer so unit tests can replace
providers deterministically. Event wiring helpers now return explicit dispose
callbacks (`WireAIPanelEvents`, `RegisterAIDropZoneHandlers`,
`WireSplitResize`) and compose with shared lifecycle helpers (`Dispose`,
`OnceDispose`, `ChainDisposers`) for deterministic teardown ownership.
global behavior deterministically.
Composition boundaries may read these accessors directly, but reusable unit
logic should receive dependencies via constructor parameters or function
arguments instead of reading globals internally.
`pkg/uikit/ai_ui_constants.go` provides shared constant keys for AI action
names, AI DOM data-attributes, AI element IDs, event names, keyboard keys, and
reusable selector fragments so consumers avoid hardcoded string literals in
event/action wiring.
`pkg/uikit/callbacks_js.go` provides shared callback retention and reusable
`addEventListener` wiring helpers for WASM event registration with panic-safe
recovery hooks, plus a swappable event-target adapter interface and default
`js.Value` implementation.
`pkg/uikit/ai_callback_registry_js.go` provides shared callback-registry state
for retained listeners and delegated AI action-click handler storage.
`pkg/uikit/view_mount_ai_js.go` provides shared AI-preserving view mount logic
that rebinds action handlers while preserving output scroll behavior.
`pkg/uikit/icons.go` provides shared SVG path constants for common action icons
used by module panels through shared icon render helpers.

`pkg/uikit/ai_markdown_js.go` provides shared WASM helper
`CurrentAIMarkdownOptionsFromLocation` for deriving markdown options from the
current browser location query.

`pkg/uikit/ai_import_js.go` provides shared WASM helpers for dropped-file byte
reading, multipart upload, and reusable drop import orchestration.
`pkg/uikit/ai_upload.go` provides a reusable upload coordinator for dropped
content that centralizes status/error parsing and delegates response decoding.
`pkg/uikit/ai_drop_decode.go` provides reusable canonical decoding for AI drop
upload responses into `AIAttachment` payloads.
`pkg/uikit/ai_panel_render.go` provides a reusable AI panel composition
renderer that assembles thread-list mode and active-thread mode from shared
component primitives.

`pkg/uikit/ai_wasm_logger_js.go`, `pkg/uikit/wasm_dom_js.go`,
`pkg/uikit/ai_drop_paths_js.go`, `pkg/uikit/wasm_class_js.go`,
`pkg/uikit/ai_debug_js.go`, `pkg/uikit/wasm_runtime_js.go`,
`pkg/uikit/client_log_js.go`, and `pkg/uikit/wasm_split_resize_js.go` provide
reusable WASM helpers for frontend logging, DOM traversal glue, drag-drop path
extraction, class toggling on selector targets, AI event debug logging,
panic-safe goroutine wrapper behavior, client-log forwarding, and split-resize
event wiring. `wasm_dom_js.go` also provides null-safe DOM attribute reads so
event/action handlers do not propagate js `<null>`/`<undefined>` sentinels.
`pkg/uikit/client_log_http.go` provides a reusable server-side HTTP handler for
frontend log payload ingestion (`ServeClientLogAPI`) with level-based sink
routing.
`pkg/uikit/server_logger.go` provides reusable server-side logging primitives
with shared quiet/verbosity behavior and optional duplicate-line compression
(`ServerLogger`).
`pkg/uikit/server_helpers.go` provides reusable server-side capability-token,
token-path routing, listener URL, and static-asset serving helpers used by
multiple module servers.
`pkg/uikit/lifecycle_window_js.go` provides reusable browser lifecycle close
wiring (`WireWindowCloseLifecycle`) for deterministic `beforeunload`/`pagehide`
teardown binding in module bootstrap code.
`pkg/uikit/ai_event_wiring_js.go` provides shared AI panel event-wiring
orchestration for hash navigation, action dispatch, model changes, draft-input
sync, Enter-to-send, and poll scheduling, including an optional poll-specific
render callback hook for consumers that can patch a narrower subtree than full
page render. Hash-route and hashchange render callbacks are executed through an
async-safe path to avoid blocking network I/O in synchronous DOM callbacks.
The same wiring supports info-level user action logs for route navigation and
dismiss interactions.
`pkg/uikit/error_host_js.go` and `pkg/uikit/error_reporter_js.go` provide
reusable DOM error-host rendering and DOM-backed error reporter construction.
Default-icon error host rendering uses compiled-template mount updates with
reusable slot values (dismiss action and message text), while explicit custom
icon overrides keep a direct rendering fallback path.
`pkg/uikit/mounted_text_view_js.go` provides reusable mounted text-view helpers
for deterministic single-slot text sections (for example error/info paragraphs)
with explicit invalidate and render operations.

`pkg/uikit/assets.go` and `pkg/uikit/assets/uikit.css` provide embedded CSS
tokens and classes for shared visual behavior, including app-level light/dark
theme tokens with automatic `prefers-color-scheme` detection (`--bus-ui-app-*`).
The same shared stylesheet now includes common `panel`/`btn`/`ai-*` class
definitions used by the shared AI panel renderer so modules can get
`bus-ledger`-parity AI visuals without module-local CSS duplication.

## Feature Inventory (flat)

- `Escape`
- `Attrs`
- `Classes`
- `HTMLBuilder`
- `HTMLBuilder.Raw`
- `HTMLBuilder.Text`
- `HTMLBuilder.OpenTag`
- `HTMLBuilder.CloseTag`
- `HTMLBuilder.Element`
- `HTMLBuilder.ElementText`
- `HTMLBuilder.TD`
- `HTMLBuilder.TH`
- `HTMLBuilder.String`
- `Node`
- `Props`
- `P`
- `Txt`
- `Unsafe`
- `El`
- `A`
- `Aside`
- `Body`
- `ButtonTag`
- `Div`
- `H1`
- `H2`
- `H3`
- `Header`
- `IFrame`
- `Li`
- `Nav`
- `PTag`
- `Section`
- `Span`
- `Svg`
- `Path`
- `Table`
- `THead`
- `TBody`
- `Ul`
- `Tr`
- `Td`
- `Th`
- `TdText`
- `ThText`
- `ButtonVariant`
- `ButtonSize`
- `ButtonProps`
- `Button`
- `PanelProps`
- `Panel`
- `MessageRole`
- `MessageProps`
- `MessageBubble`
- `TextInput`
- `TextArea`
- `ErrorBanner`
- `EmptyState`
- `AIIconActionButton`
- `AIMessage`
- `AIRespondingMessage`
- `AIThreadItem`
- `AIThreadMeta`
- `AIThreadList`
- `AIThreadTitleByID`
- `AIAttachmentItem`
- `AIAttachmentMeta`
- `AIHeaderProps`
- `AIHeader`
- `AIStatus`
- `AILoginPrompt`
- `AIModelSelect`
- `AIFooterMeta`
- `AIApprovalAction`
- `AIApprovalItem`
- `AIApprovalCard`
- `AIAttachment`
- `AIStatusResponse`
- `AIEventResponseItem`
- `AIEventsResponse`
- `AIThreadsResponse`
- `AIHistoryResponse`
- `AIRefreshState`
- `AIRefreshCallbacks`
- `AIRefreshHost`
- `RefreshAIState`
- `RefreshAIHost`
- `AIRefreshCallbacksForConversation`
- `AIApprovalsSection`
- `AIAttachmentList`
- `AIComposer`
- `AIMarkdownOptions`
- `AIMarkdownDefaults`
- `RenderAIMessageText`
- `RenderAIMessageTextWithOptions`
- `AIMarkdownOptionsFromQuery`
- `EventThreadID`
- `EventTurnID`
- `StreamSourceForMethod`
- `AssistantTextFragmentsForMethod`
- `AIEventEntry`
- `AIEventApplyCallbacks`
- `ApplyAIEventBatch`
- `IsAIThreadStatusIdle`
- `FetchAIStatus`
- `FetchAIThreads`
- `FetchAIHistory`
- `FetchAIEvents`
- `SelectedEntryIndex`
- `SelectedLineIndex`
- `CurrentListMode`
- `NormalizeSubrouteFromHash`
- `RouteForTx`
- `RouteForTxLine`
- `CloseRouteForMode`
- `FormatAIApprovalCardHTML`
- `FormatAttachmentSize`
- `AIAttachmentRef`
- `AIChatMessage`
- `ToString`
- `ErrorString`
- `ActionHandler`
- `DispatchAction`
- `AIActionRouter`
- `HandleAIAction`
- `Logger`
- `ConsoleSink`
- `ForwardSink`
- `ClientLogger`
- `NewClientLogger`
- `ErrorReporter`
- `ErrorPresenter`
- `ErrorClearer`
- `PanicStringer`
- `BasicErrorReporter`
- `NewBasicErrorReporter`
- `URLResolver`
- `GatewayClient`
- `HTTPGatewayClient`
- `NewHTTPGatewayClient`
- `WithExpectedStatus`
- `RunPollingCycle`
- `Component`
- `RenderCtx`
- `RenderRuntime`
- `NewRenderRuntime`
- `RenderComponent`
- `RenderCtx.Child`
- `UseState`
- `Ref`
- `UseRef`
- `UseMemo`
- `PanelLayoutState`
- `NewDefaultPanelLayoutState`
- `AIPanelSessionState`
- `NewDefaultAIPanelSessionState`
- `AIPanelSessionState.PollActive`
- `AIConversationState`
- `NewDefaultAIConversationState`
- `AIStatusSnapshot`
- `ApplyAIStatusSnapshot`
- `ApplyPanelResize`
- `StringMapValue`
- `AIThreadAttachmentKey`
- `CurrentAIAttachments`
- `AppendAIOutputChunk`
- `ApplyFinalAssistantMessage`
- `AppendAIUserMessage`
- `LastAssistantMessage`
- `NormalizeAssistantText`
- `IsAssistantDeltaMethod`
- `IsFinalAssistantMethod`
- `ShouldSkipFinalAssistantMessage`
- `EnsureAIThreadBuffer`
- `ActivateAIThread`
- `RemoveAttachmentAt`
- `ApplyThreadSelection`
- `ApplyTurnStartSuccess`
- `ApplyThreadCreateSuccess`
- `ApplyThreadArchiveSuccess`
- `ApplyThreadRename`
- `ResolveAIHeaderTitle`
- `DefaultAIApprovalActions`
- `BuildAIApprovalItems`
- `BuildAIHeaderProps`
- `AIPanelRenderProps`
- `RenderAIPanel`
- `MergeAIModelOptions`
- `ResolveStatusActiveThread`
- `ResolveThreadsActiveThread`
- `RecordAIDeltaTurnState`
- `ClearAITurnState`
- `TrimMessagesByThread`
- `AIAPIClient`
- `DefaultAIAPIClient`
- `NewDefaultAIAPIClient`
- `AIDropPathService`
- `DefaultAIDropPathService`
- `NewDefaultAIDropPathService`
- `MultipartUploadFunc`
- `AIUploadDecodeFunc`
- `UploadAIDroppedContent`
- `DecodeAIDropUploadAttachments`
- `CurrencySymbol`
- `FormatFixed2`
- `FormatCurrencyFallback`
- `ParseNumeric`
- `IsZeroNumeric`
- `NormalizeFieldKey`
- `FormatLocaleMoney`
- `FormatLocaleCurrency`
- `FormatAmountWithCurrency`
- `FormatLocaleDateTime`
- `BuildAIThreadItems`
- `BuildAIAttachmentRefs`
- `BuildAIAttachmentRefsFromWire`
- `NormalizeAIAttachmentRefs`
- `ComposeUserMessageWithAttachments`
- `RenderAIAttachments`
- `StripTrailingLineRef`
- `NormalizeAILocalFileReference`
- `ResolveAIMessageHref`
- `CurrentAIMarkdownOptionsFromLocation`
- `LogAIDebugEvent`
- `PostJSONDecode`
- `GetJSONDecode`
- `OpenURLInBrowser`
- `BrowserOpenCommandForOS`
- `GenerateCapabilityToken`
- `TokenPathSuffix`
- `TokenURLFromListener`
- `ListenTCP`
- `ServeStaticWithIndexFallback`
- `ContentTypeForName`
- `ConsoleLog`
- `ClosestElement`
- `IsInsideSelector`
- `BindOnClickBySelector`
- `CurrentSubroute`
- `GlobalDocument`
- `GlobalLocation`
- `CurrentGlobalSubroute`
- `DescribeJSElement`
- `SummarizeDataTransfer`
- `AIDropZoneOptions`
- `RegisterAIDropZoneHandlers`
- `CollectAIDroppedPaths`
- `IsLikelyAIDroppedPathCandidate`
- `ReadDroppedFileBytes`
- `UploadFileMultipart`
- `ImportDroppedPaths`
- `ImportDroppedFiles`
- `AIDropFileService`
- `DefaultAIDropFileService`
- `NewDefaultAIDropFileService`
- `FirstTruthyElementByID`
- `ParseAIApprovalTarget`
- `SetClassOnSelector`
- `GoSafe`
- `RecoverToReporter`
- `GoSafeWithReporter`
- `RetainCallback`
- `AddEventListener`
- `EventTarget`
- `JSEventTarget`
- `NewJSEventTarget`
- `AIPanelEventWiringOptions`
- `WireAIPanelEvents`
- `DOMErrorHostOptions`
- `ClearDOMErrorHost`
- `SetDOMErrorHost`
- `NewDOMErrorReporter`
- `DOMAttrAIAction`
- `DOMAttrThreadID`
- `DOMAttrThreadTitle`
- `DOMAttrAttachmentIndex`
- `DOMAttrUIAction`
- `ElementIDAIInput`
- `ElementIDAIModel`
- `ElementIDAIModelHeader`
- `ElementIDAIModelFooter`
- `AIActionToggle`
- `AIActionLogin`
- `AIActionSend`
- `AIActionNewThread`
- `AIActionSelectThread`
- `AIActionArchiveThread`
- `AIActionRenameThread`
- `AIActionInterrupt`
- `AIActionSetModel`
- `AIActionDismissError`
- `AIActionRemoveAttachment`
- `AIActionApprove`
- `EventHashChange`
- `EventClick`
- `EventChange`
- `EventInput`
- `EventKeyDown`
- `KeyEnter`
- `SelectorAIAction`
- `SelectorDismissErr`
- `SelectorHashRoute`
- `ForwardClientLog`
- `ClientLogHandler`
- `ServeClientLogAPI`
- `NewWASMClientLogger`
- `ServerLogSink`
- `ServerLoggerOptions`
- `ServerLogger`
- `NewServerLogger`
- `SplitResizeState`
- `WireSplitResize`
- `CSS`
- `CSSMust`
- `bus-ui css`
- `bus-ui version`
- `bus-ui help`

## Data Design

`bus-ui` owns no workspace datasets and no persisted runtime state. Inputs are
plain values, structs, and optional JSON payloads for approval formatting.
Outputs are deterministic HTML fragments and CSS text.

## Assumptions and Dependencies

`bus-ui` depends only on Go standard library packages. It is consumed by
frontend modules but does not import module-specific packages.

Consumers provide module-specific context such as link resolution behavior,
thread state, and action handlers.

## Glossary and Terminology

Reusable component means a rendering primitive with no module business rules.
Deterministic HTML means stable escaping and stable attribute ordering for the
same inputs. AI UI component means a generic assistant-interface block that is
not tied to one module’s data model.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-timeline">bus-timeline</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vat">bus-vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module page](../modules/bus-ui)
- [bus-ledger SDD](./bus-ledger)

### Document control

Title: bus-ui module SDD  
Project: BusDK  
Document identifier: sdd/bus-ui  
Version: 1  
Status: Draft  
Last updated: 2026-02-27  
Owner: BusDK maintainers
