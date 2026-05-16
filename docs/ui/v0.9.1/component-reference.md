---
title: UI component reference
description: Index of dedicated BusDK UI concept, component, and runtime block reference pages.
---

## Reference Index

Every reusable UI concept, component, and runtime block has a dedicated page.
This page is the canonical linked index for those pages.

## Design References

- [UI design system](../v0.2.0/design-system)
- [GX source tools](../v0.1.2/source-tools)
- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Versioned Concepts

- [Node](../v0.1.1/node) - Deterministic render tree.
- [Component](../v0.1.4/component) - Reusable Bus UI invocation.
- [Shell](../v0.2.6/shell) - Page-level slot owner.
- [Collection](../v0.3.6/collection) - Repeated data surface.
- [State](../v0.3.8/state) - Visible UI status.
- [Expression children](../v0.1.5/expression-children) - Go expression children inside markup bodies.
- [Callback props](../v0.1.6/callback-props) - Function props passed as Go values.
- [Resource](../v0.4.1/resource) - External data or media boundary.
- [Go WASM frontend runtime](../v0.1.7/lifecycle) - Go WebAssembly mount lifecycle.

## Core v0.1.1 Foundation

- [`Shared interfaces`](../v0.1.1/interfaces) - Go `Node`, `Renderer`, and default render function contracts.
- [`Text`](../v0.1.1/text) - Escaped scalar text node.
- [`Element`](../v0.1.1/element) - Generic HTML element.
- [`Fragment`](../v0.1.1/fragment) - Child group without a wrapper element.
- [`Props`](../v0.1.1/props) - Deterministic attribute map.
- [`VNode`](../v0.1.1/v-node) - Normalized node form for deterministic HTML rendering and tests.

## Core v0.1.2-v0.1.5 GX And Components

- [GX source tools](../v0.1.2/) - Parser, formatter, linter, and source diagnostics.
- [GX compiler](../v0.1.3/) - Generated Go output.
- [Component calls](../v0.1.4/) - Uppercase tags and typed props.
- [Component composition](../v0.1.5/) - Component body markup and children.

## Later Core Contracts

- [Callback props](../v0.1.6/) - Function callback props.
- [Go WASM frontend runtime](../v0.1.7/) - Go WebAssembly mount and update runtime.
- [Runtime diagnostics](../v0.1.8/) - Mount, render, and callback diagnostics.
- [Core test helpers](../v0.1.10/) - Test support for Core render and callback contracts.

## Library: Common Shells

- [`AppShell`](../v0.2.6/app-shell) - Standard local application frame.
- [`SidebarShell`](../v0.2.6/sidebar-shell) - Collapsible multi-view shell.

## Library: Layouts

- [`SidebarNav`](../v0.2.5/sidebar-nav) - Sidebar navigation list.
- [`SplitLayout`](../v0.2.5/split-layout) - Resizable pane layout.

## Library: Surfaces

- [`Panel`](../v0.2.4/panel) - Bounded titled work surface.
- [`SurfaceCard`](../v0.2.4/surface-card) - Repeated or grouped card surface.
- [`MetricCard`](../v0.2.4/metric-card) - Compact dashboard metric.

## Library: Navigation

- [`LinkButton`](../v0.2.2/link-button) - Safe link with button styling.
- [`Menu`](../v0.2.3/menu) - Bounded option menu.
- [`Tabs`](../v0.2.3/tabs) - Sibling view switcher.

## Library: Event Controls

- [`Button`](../v0.2.2/button) - Native event button.
- [`IconButton`](../v0.2.2/icon-button) - Icon-only event button.
- [`EventBar`](../v0.2.2/event-bar) - Ordered event group.

## Library: Icons

- [`Icon`](../v0.2.1/icon) - Shared SVG icon.

## Library: Forms

- [`Form`](../v0.3.1/form) - Native form wrapper.
- [`Field`](../v0.3.2/field) - Labeled form control wrapper.
- [`Input`](../v0.3.3/input) - Generic typed input.
- [`TextInput`](../v0.3.3/text-input) - Single-line text field.
- [`PasswordInput`](../v0.3.3/password-input) - Password or token field.
- [`DateInput`](../v0.3.3/date-input) - Date input field.
- [`TextArea`](../v0.3.3/text-area) - Multiline text field.
- [`Select`](../v0.3.3/select) - Native bounded option set.
- [`FilterToolbar`](../v0.3.2/filter-toolbar) - Compact filter surface.
- [`SubmitState`](../v0.3.4/submit-state) - Busy submit feedback.

## Library: Tables

- [`TextTable`](../v0.3.5/text-table) - Simple deterministic table.
- [`DataTable`](../v0.3.5/data-table) - Dense records table.

## Library: Lists

- [`RecordList`](../v0.3.6/record-list) - Repeated non-tabular records.
- [`SummaryItem`](../v0.3.6/summary-item) - Title/meta/detail summary row.

## Library: Timelines

- [`Timeline`](../v0.3.7/timeline) - Ordered event history.

## Library: Status Surfaces

- [`StatusPill`](../v0.3.8/status-pill) - Compact semantic status.
- [`EmptyState`](../v0.3.8/empty-state) - Visible absence state.
- [`LoadingState`](../v0.3.8/loading-state) - Visible loading state.
- [`ResultPanel`](../v0.3.8/result-panel) - Operation result surface.
- [`ErrorBanner`](../v0.3.8/error-banner) - Recoverable error alert.

## Library: Runtime Config

- [`RuntimeConfig`](../v0.4.2/runtime-config-component) - Safe public runtime config.

## Library: API URLs

- [`APIURLResolver`](../v0.4.2/apiurl-resolver) - Mounted API path resolver.

## Library: Session

- [`Session`](../v0.4.3/session-component) - Safe browser session view.

## Library: Credentials

- [`CredentialLoginCard`](../v0.4.4/credential-login-card) - Generic credential entry surface.

## Library: Provider Errors

- [`ProviderError`](../v0.4.5/provider-error-component) - Safe provider failure surface.

## Library: Assistant

- [`AssistantShell`](../v0.5.1/assistant-shell) - Business surface with assistant pane.
- [`AIPanel`](../v0.5.1/ai-panel) - Assistant workbench surface.
- [`AIThreadList`](../v0.5.2/ai-thread-list) - Assistant thread list.
- [`AIMessage`](../v0.5.2/ai-message) - Role-specific assistant message.
- [`AIMarkdown`](../v0.5.2/ai-markdown) - Safe assistant Markdown renderer.
- [`AIModelSelect`](../v0.5.4/ai-model-select) - Assistant model picker.
- [`AIAttachmentList`](../v0.5.3/ai-attachment-list) - Assistant attachment chips.
- [`AIComposer`](../v0.5.3/ai-composer) - Assistant draft input.
- [`AIApprovals`](../v0.5.5/ai-approvals) - Pending approval list.
- [`AIReviewStatus`](../v0.5.5/ai-review-status) - Review-before-apply status.
- [`AIThreadIsolation`](../v0.5.5/ai-thread-isolation) - Assistant work isolation display.
- [`AIDropController`](../v0.5.3/ai-drop-controller) - Assistant drop intake controller.

## Library: Terminal

- [`TerminalSessionPanel`](../v0.6.1/terminal-session-panel) - Complete terminal surface.
- [`TerminalOutputView`](../v0.6.2/terminal-output-view) - Streamed output view.
- [`TerminalInputBox`](../v0.6.2/terminal-input-box) - Terminal stdin controls.
- [`TerminalApprovalPrompt`](../v0.6.3/terminal-approval-prompt) - Command approval prompt.
- [`TerminalSessionAdapter`](../v0.6.4/terminal-session-adapter) - Event-to-terminal adapter.

## Library: Evidence

- [`EvidenceURLResolver`](../v0.7.1/evidence-url-resolver) - Safe evidence URL builder.
- [`EvidenceLink`](../v0.7.1/evidence-link) - Evidence open/download link.
- [`EvidencePreview`](../v0.7.2/evidence-preview-component) - Safe evidence preview.
- [`ProjectionDetail`](../v0.7.3/projection-detail-component) - Ledger-like evidence detail.

## Library: File Drops

- [`DropZone`](../v0.8.1/drop-zone) - File/path intake surface.

## Library: Image Gallery

- [`ImageGallery`](../v0.8.2/image-gallery-component) - Linked image gallery.

## CLI And Tooling

- [`CSSBundle`](../v0.4.6/css-bundle) - Shared CSS token bundle.
- [`CLIRuntimeFlags`](../v0.4.6/cli-runtime-flags) - Standard CLI flag behavior.
- [`BrowserOpen`](../v0.4.6/browser-open) - Open local app URL.
- [`WASM app acceptance`](../v0.1.11/wasm-app) - Trusted Go WebAssembly app acceptance path.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core](../v0.1.1/)
- [Bus UI module baseline](../v0.2.0/)
- [UI implementation roadmap](../)
- [UI component map](./component-map)
- [bus-ui module reference](../../modules/bus-ui)
