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

`pkg/uikit/ai_panel_helpers.go` provides shared AI panel helper logic for
resolving active-thread header titles and producing standard approval action
lists, deterministic approval-item view-models, and reusable header-props
composition.

`pkg/uikit/ai_polling.go` provides shared AI polling/event orchestration
helpers for model-option normalization, active-thread resolution, delta-turn
state tracking, and bounded message-buffer retention.

`pkg/uikit/moneyfmt.go` provides shared money formatting helpers for currency
symbol mapping, fixed two-decimal numeric formatting, and deterministic
currency fallback rendering when locale-specific formatters are unavailable.

`pkg/uikit/numeric.go` and `pkg/uikit/format_locale_js.go` provide shared
numeric parsing and WASM locale-aware money/date-time formatting helpers.

`pkg/uikit/ai_http.go` provides shared JSON HTTP request helpers for GET and
POST+decode workflows.

`pkg/uikit/action_dispatch.go` provides generic reusable action-dispatch
primitives for UI action routing without module-specific branching logic.
`pkg/uikit/ai_action_router.go` adds a reusable AI action-router coordinator
that combines deterministic action logging/target description with shared
handler dispatch.

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

`pkg/uikit/app_state.go` provides reusable generic UI app-state structs for
panel layout dimensions and AI panel session state, including default-state
constructors and polling activity helper logic.

`pkg/uikit/app_state_reducers.go` provides reusable app-state reducer helpers
for applying AI status snapshots into panel state and for applying panel resize
mode changes into layout dimensions.

`pkg/uikit/ai_drop_service.go` and `pkg/uikit/ai_drop_service_js.go` provide
interface-based dropped-path/file import services that wrap shared import
orchestration with pluggable import/upload callbacks.

`pkg/uikit/ai_api_client.go` provides a typed interface-based AI API client
that wraps shared gateway POST calls behind stable method names for common AI
panel operations.

`pkg/uikit/ai_events.go` provides shared AI event parsing helpers for
thread/turn extraction and assistant message fragment extraction from event
payloads.
`pkg/uikit/ai_models.go` provides shared canonical AI gateway wire-model
payload types for status/events/threads/history/attachments.
`pkg/uikit/ai_refresh.go` provides shared AI polling refresh orchestration
that applies status/thread/history/event updates into mutable UI state with
configurable callbacks for event logging and message application behavior.

`pkg/uikit/ai_event_apply.go` provides a reusable AI event-batch apply
coordinator with callback hooks for delta/final text application and
turn/thread/process lifecycle transitions.

`pkg/uikit/ai_poll_api.go` provides reusable AI polling API-path helpers for
status/thread/history/event fetches through a shared gateway client.

`pkg/uikit/ledger_routes.go` provides shared route parsing/building helpers for
transaction and line-detail navigation in day-book/general-ledger style UIs.
`pkg/uikit/subroute.go` and `pkg/uikit/subroute_js.go` provide shared
location-hash to normalized subroute helpers for hash-routed WASM frontends.
`pkg/uikit/ai_ui_constants.go` provides shared constant keys for AI action
names, AI DOM data-attributes, AI element IDs, event names, keyboard keys, and
reusable selector fragments so consumers avoid hardcoded string literals in
event/action wiring.
`pkg/uikit/callbacks_js.go` provides shared callback retention and reusable
`addEventListener` wiring helpers for WASM event registration with panic-safe
recovery hooks, plus a swappable event-target adapter interface and default
`js.Value` implementation.

`pkg/uikit/ai_markdown_js.go` provides shared WASM helper
`CurrentAIMarkdownOptionsFromLocation` for deriving markdown options from the
current browser location query.

`pkg/uikit/ai_import_js.go` provides shared WASM helpers for dropped-file byte
reading, multipart upload, and reusable drop import orchestration.
`pkg/uikit/ai_upload.go` provides a reusable upload coordinator for dropped
content that centralizes status/error parsing and delegates response decoding.
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
event wiring.

`pkg/uikit/assets.go` and `pkg/uikit/assets/uikit.css` provide embedded CSS
tokens and classes for shared visual behavior.

## Feature Inventory (flat)

- `Escape`
- `Attrs`
- `Classes`
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
- `RefreshAIState`
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
- `PanelLayoutState`
- `NewDefaultPanelLayoutState`
- `AIPanelSessionState`
- `NewDefaultAIPanelSessionState`
- `AIPanelSessionState.PollActive`
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
- `CurrencySymbol`
- `FormatFixed2`
- `FormatCurrencyFallback`
- `ParseNumeric`
- `FormatLocaleMoney`
- `FormatLocaleDateTime`
- `BuildAIThreadItems`
- `BuildAIAttachmentRefs`
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
- `ConsoleLog`
- `ClosestElement`
- `IsInsideSelector`
- `CurrentSubroute`
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
- `NewWASMClientLogger`
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
