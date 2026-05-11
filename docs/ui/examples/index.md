---
title: UI framework examples
description: Concrete BusDK UI document examples for portal, assistant, terminal, and evidence workflows.
---

## Example Documents

These examples show complete YAML documents that can be used as samples,
fixtures, or implementation sketches. Product modules may generate equivalent
documents from Go view models; handwritten YAML is useful when a human or agent
needs to review the screen shape before code exists.

The document describes the UI tree and named actions, resources, and effects.
Output format, portal versus local shell selection, host paths, asset URLs, and
mount behavior come from the renderer command, portal host, local app host, or
test harness.

## Notes Review List

This portal-mounted notes view combines a shell, filter toolbar, data table,
row actions, and safe status labels. The document keeps provider policy out of
the UI: visibility, permission, and review decisions come from the notes view
model and provider APIs.

```yaml
version: bus-ui/v1
metadata:
  title: Notes review
data:
  filters:
    q: evidence
    status: review
  notes:
    - id: note-1
      title: Evidence gate follow-up
      module: bus-integration-dev-task
      status: review
      author: agent-ui
    - id: note-2
      title: UI framework simplification
      module: bus-ui
      status: published
      author: supervisor
actions:
  search:
    type: submit
    method: GET
    target: { base: module, path: / }
  approve:
    type: post
    target: { base: module, path: /review/approve }
    payload:
      note_id: { bind: row.id }
  archive:
    type: post
    target: { base: module, path: /archive }
    payload:
      note_id: { bind: row.id }
resources:
  notes:
    base: module
    path: /api/notes
effects: {}
view:
  kind: PortalShell
  props:
    title: Notes
  slots:
    body:
      kind: Panel
      props:
        title: Review queue
      children:
        - kind: FilterToolbar
          props:
            action: search
          children:
            - kind: Field
              props: { label: Search }
              children:
                - kind: TextInput
                  props:
                    name: q
                    value: { bind: filters.q }
            - kind: Field
              props: { label: Status }
              children:
                - kind: Select
                  props:
                    name: status
                    selected: { bind: filters.status }
                    options:
                      - { value: review, label: Review }
                      - { value: published, label: Published }
        - kind: DataTable
          props:
            rows: { bind: notes }
            columns:
              - { key: title, label: Note }
              - { key: module, label: Module }
              - { key: author, label: Author }
              - { key: status, label: Status, component: StatusPill }
            rowActions:
              - { label: Approve, action: approve, variant: primary }
              - { label: Archive, action: archive, variant: secondary }
```

## Auth Sign-In

The auth example uses reusable form and result components, while account
eligibility, CSRF validation, waitlist state, and billing decisions remain
provider/API behavior.

```yaml
version: bus-ui/v1
metadata:
  title: Account access
data:
  account:
    status: signed-out
    guidance: Enter email and one-time code.
actions:
  request_otp:
    type: post
    target: { base: module, path: /otp/request }
  verify_otp:
    type: post
    target: { base: module, path: /otp/verify }
view:
  kind: PortalShell
  props:
    title: Account
  children:
    - kind: CredentialLoginCard
      props:
        usernameLabel: Email
        passwordLabel: One-time code
        requestAction: request_otp
        submitAction: verify_otp
    - kind: ResultPanel
      props:
        status: { bind: account.status }
        title: Access status
        summary: { bind: account.guidance }
```

## Assistant Workbench

Assistant workflows are normal UI documents with an assistant shell and stable
actions. The model selection, send, and interrupt actions are still plain
`Action` entries.

```yaml
version: bus-ui/v1
metadata:
  title: AI workbench
data:
  ai:
    activeThread: thread-1
    model: gpt-5.4
    threads:
      - { id: thread-1, title: UI review, working: true }
    messages:
      - { role: user, text: Review the UI framework docs. }
      - { role: assistant, text: I found duplicate runtime concepts. }
actions:
  send:
    type: post
    target: { base: module, path: /ai/send }
  interrupt:
    type: post
    target: { base: module, path: /ai/interrupt }
  set_model:
    type: post
    target: { base: module, path: /ai/model }
resources:
  ai_events:
    base: module
    path: /api/ai/events
effects:
  ai_stream:
    type: event-stream
    resource: ai_events
    apply: ai.applyEvent
view:
  kind: AssistantShell
  slots:
    business:
      kind: Panel
      props:
        title: Work item
      children:
        - kind: Text
          props:
            value: Review generated changes before applying them.
    assistant:
      kind: AIPanel
      props:
        activeThread: { bind: ai.activeThread }
        model: { bind: ai.model }
        threads: { bind: ai.threads }
        messages: { bind: ai.messages }
        sendAction: send
        interruptAction: interrupt
        setModelAction: set_model
```

## Terminal Session

Terminal UI uses the same model. Starting or stopping a command is an action,
the session endpoint is a resource, and streaming output is an effect.

```yaml
version: bus-ui/v1
metadata:
  title: Terminal session
data:
  terminal:
    state: running
    command: make test
    cwd: /workspace/bus-ui
    output:
      - { stream: stdout, text: "=== RUN   TestActionResourceEffect" }
      - { stream: stdout, text: "--- PASS: TestActionResourceEffect" }
actions:
  send_input:
    type: post
    target: { base: module, path: /terminal/input }
  stop:
    type: post
    target: { base: module, path: /terminal/stop }
resources:
  terminal_events:
    base: module
    path: /api/terminal/events
effects:
  terminal_stream:
    type: event-stream
    resource: terminal_events
    apply: terminal.appendOutput
view:
  kind: TerminalSessionPanel
  props:
    state: { bind: terminal.state }
    command: { bind: terminal.command }
    cwd: { bind: terminal.cwd }
    output: { bind: terminal.output }
    submitAction: send_input
    exitAction: stop
```

## Evidence Detail

Evidence UI keeps path authorization in provider APIs. The UI document receives
safe display metadata and uses resource-backed links and previews.

```yaml
version: bus-ui/v1
metadata:
  title: Evidence detail
data:
  document:
    title: Invoice 2026-04
    status: available
    preview: /api/evidence/invoice-2026-04.pdf/preview
    download: /api/evidence/invoice-2026-04.pdf/download
actions:
  open_evidence:
    type: link
    target: { bind: document.preview }
  download_evidence:
    type: link
    target: { bind: document.download }
resources:
  evidence_preview:
    base: module
    path: /api/evidence/invoice-2026-04.pdf/preview
view:
  kind: Panel
  props:
    title: { bind: document.title }
  children:
    - kind: StatusPill
      props:
        label: { bind: document.status }
        status: success
    - kind: EvidencePreview
      props:
        previewURL: { bind: document.preview }
        title: { bind: document.title }
    - kind: ActionBar
      props:
        actions:
          - { label: Open, action: open_evidence, variant: secondary }
          - { label: Download, action: download_evidence, variant: primary }
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../reference/declarative-documents">Declarative UI documents</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../guides/portal-modules">Portal modules</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Declarative UI documents](../reference/declarative-documents)
- [UI component reference](../reference/component-reference)
- [bus-ui module reference](../../modules/bus-ui)
