---
title: UI component reference
description: Index of dedicated BusDK UI concept, component, and runtime block reference pages.
---

## Reference Index

Every reusable UI concept, component, and runtime block has a dedicated page. Each page is intentionally small: purpose, exact inputs, boundary, one example, and links back to the compact catalog.

## Core Concepts

- [Node](../concepts/node) - Deterministic render tree.
- [Component](../concepts/component) - Reusable UI function.
- [Shell](../concepts/shell) - Page-level slot owner.
- [Collection](../concepts/collection) - Repeated data surface.
- [State](../concepts/state) - Visible UI status.
- [Action](../concepts/action) - User-triggered command.
- [Resource](../concepts/resource) - External data or media boundary.
- [Effect](../concepts/effect) - Lifecycle behavior.

## Foundation

- [`Text`](../components/text) - Escaped scalar text node.
- [`RawHTML`](../components/raw-html) - Audited trusted HTML fragment.
- [`Element`](../components/element) - Generic HTML element.
- [`Fragment`](../components/fragment) - Child group without a wrapper element.
- [`Props`](../components/props) - Deterministic attribute map.
- [`VNode`](../components/v-node) - Virtual DOM node shared by server and Go/WASM rendering.
- [`Component`](../components/component) - Reusable function from props and slots to nodes.
- [`Template`](../components/template) - Static tree with dynamic slots.
## Shells And Layout

- [`AppShell`](../components/app-shell) - Standard local application frame.
- [`PortalShell`](../components/portal-shell) - Portal-mounted feature frame.
- [`SidebarShell`](../components/sidebar-shell) - Collapsible multi-view shell.
- [`SidebarNav`](../components/sidebar-nav) - Sidebar navigation list.
- [`SplitLayout`](../components/split-layout) - Resizable pane layout.
- [`AssistantShell`](../components/assistant-shell) - Business surface with assistant pane.
- [`Panel`](../components/panel) - Bounded titled work surface.
- [`SurfaceCard`](../components/surface-card) - Repeated or grouped card surface.
- [`MetricCard`](../components/metric-card) - Compact dashboard metric.
## Navigation, Action, And Forms

- [`Button`](../components/button) - Native command button.
- [`IconButton`](../components/icon-button) - Icon-only command button.
- [`LinkButton`](../components/link-button) - Safe link with button styling.
- [`ActionBar`](../components/action-bar) - Ordered command group.
- [`Menu`](../components/menu) - Bounded option menu.
- [`Tabs`](../components/tabs) - Sibling view switcher.
- [`StatusPill`](../components/status-pill) - Compact semantic status.
- [`Icon`](../components/icon) - Shared SVG icon.
- [`Form`](../components/form) - Native form wrapper.
- [`Field`](../components/field) - Labeled form control wrapper.
- [`Input`](../components/input) - Generic typed input.
- [`TextInput`](../components/text-input) - Single-line text field.
- [`PasswordInput`](../components/password-input) - Password or token field.
- [`DateInput`](../components/date-input) - Date input field.
- [`TextArea`](../components/text-area) - Multiline text field.
- [`Select`](../components/select) - Native bounded option set.
- [`FilterToolbar`](../components/filter-toolbar) - Compact filter surface.
- [`SubmitState`](../components/submit-state) - Busy submit feedback.
## Data Display

- [`TextTable`](../components/text-table) - Simple deterministic table.
- [`DataTable`](../components/data-table) - Dense records table.
- [`RecordList`](../components/record-list) - Repeated non-tabular records.
- [`SummaryItem`](../components/summary-item) - Title/meta/detail summary row.
- [`Timeline`](../components/timeline) - Ordered event history.
- [`EmptyState`](../components/empty-state) - Visible absence state.
- [`LoadingState`](../components/loading-state) - Visible loading state.
- [`ResultPanel`](../components/result-panel) - Operation result surface.
- [`ErrorBanner`](../components/error-banner) - Recoverable error alert.
## Actions, Resources, And Effects

- [`RuntimeConfig`](../components/runtime-config) - Safe public runtime config.
- [`APIURLResolver`](../components/apiurl-resolver) - Mounted API path resolver.
- [`Session`](../components/session) - Safe browser session view.
- [`Action`](../components/action) - Stable user-triggered command.
- [`Resource`](../components/resource) - External data or media contract.
- [`Effect`](../components/effect) - Background or browser lifecycle behavior.
- [`CredentialLoginCard`](../components/credential-login-card) - Generic credential entry surface.
- [`ProviderError`](../components/provider-error) - Safe provider failure surface.
- [`ClientLog`](../components/client-log) - Browser diagnostic channel.
- [`ErrorHost`](../components/error-host) - Runtime error host.
- [`CloseGuard`](../components/close-guard) - Active-work close protection.
- [`Disposer`](../components/disposer) - Lifecycle cleanup callback.
## Assistant

- [`AIPanel`](../components/ai-panel) - Assistant workbench surface.
- [`AIThreadList`](../components/ai-thread-list) - Assistant thread list.
- [`AIMessage`](../components/ai-message) - Role-specific assistant message.
- [`AIMarkdown`](../components/ai-markdown) - Safe assistant Markdown renderer.
- [`AIModelSelect`](../components/ai-model-select) - Assistant model picker.
- [`AIAttachmentList`](../components/ai-attachment-list) - Assistant attachment chips.
- [`AIComposer`](../components/ai-composer) - Assistant draft input.
- [`AIApprovals`](../components/ai-approvals) - Pending approval list.
- [`AIReviewStatus`](../components/ai-review-status) - Review-before-apply status.
- [`AIThreadIsolation`](../components/ai-thread-isolation) - Assistant work isolation display.
- [`AIDropController`](../components/ai-drop-controller) - Assistant drop intake controller.
## Terminal

- [`TerminalSessionPanel`](../components/terminal-session-panel) - Complete terminal surface.
- [`TerminalOutputView`](../components/terminal-output-view) - Streamed output view.
- [`TerminalInputBox`](../components/terminal-input-box) - Terminal stdin controls.
- [`TerminalApprovalPrompt`](../components/terminal-approval-prompt) - Command approval prompt.
- [`TerminalSessionAdapter`](../components/terminal-session-adapter) - Event-to-terminal adapter.
## Evidence And Media

- [`EvidenceURLResolver`](../components/evidence-url-resolver) - Safe evidence URL builder.
- [`EvidenceLink`](../components/evidence-link) - Evidence open/download link.
- [`EvidencePreview`](../components/evidence-preview) - Safe evidence preview.
- [`ProjectionDetail`](../components/projection-detail) - Ledger-like evidence detail.
- [`DropZone`](../components/drop-zone) - File/path intake surface.
- [`ImageGallery`](../components/image-gallery) - Linked image gallery.
## CLI And Tooling

- [`CSSBundle`](../components/css-bundle) - Shared CSS token bundle.
- [`CLIRuntimeFlags`](../components/cli-runtime-flags) - Standard CLI flag behavior.
- [`BrowserOpen`](../components/browser-open) - Open local app URL.
- [`DeclarativeRenderer`](../components/declarative-renderer) - JSON/YAML UI renderer.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./component-catalog">Component catalog</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./declarative-documents">Declarative UI documents</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component catalog](./component-catalog)
- [UI building block reference](./components)
- [bus-ui module reference](../../modules/bus-ui)
