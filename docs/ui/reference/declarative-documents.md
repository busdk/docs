---
title: Declarative UI documents
description: JSON and YAML document format for rendering BusDK UI apps and samples through bus-ui.
---

## Purpose

Declarative UI documents give humans and agents a compact way to describe a
BusDK UI without writing Go first. A document can render a sample screen, define
a component fixture, describe a small local tool, or serve as a reviewable
handoff from product design to implementation.

The document format is not a replacement for Go product modules. Product
modules still own DTO adapters, view models, provider clients, permission
rules, and workflow behavior. The document format is the serializable view
layer: it describes component trees, static sample data, bindings, actions,
resources, and effects using the same component catalog that Go code uses.
Renderer targets, host shells, output formats, and mount contexts are supplied
by the command, portal host, local app host, or test harness rather than stored
inside the UI document.

## Command Shape

From the BusDK superproject root, install `bus-ui` from the module before
running these commands:

```sh
cd bus-ui
make install
```

The default install location is `$(HOME)/.local/bin/bus-ui`; ensure
`$(HOME)/.local/bin` is on `PATH`, or run that installed path explicitly.

Then run the command from the directory that contains `sample.yml`, or pass a
relative or absolute path to a document stored elsewhere. Save a UI document as
`sample.yml` or choose one of the complete documents in
[UI framework examples](../examples/). The framework command contract treats that
document path as render input:

```sh
bus-ui sample.yml
```

That shorthand is equivalent to rendering the document to HTML on stdout. The
long form is useful when callers want explicit output modes:

```sh
bus-ui render sample.yml --format html
bus-ui render sample.yml --format json
bus-ui render sample.yml --output sample.html
bus-ui validate sample.yml
```

`--format html` emits deterministic HTML. `--format json` emits the normalized
component tree for tests and review. Validation prints schema and component
diagnostics without rendering.

## Document Shape

A UI document has a version, metadata, optional sample data, optional action,
resource, and effect definitions, and one root component. Most documents only
need data, actions, and a view; resources and effects appear when the UI needs
external data or browser lifecycle behavior.

| Field | Required | Contract |
| --- | --- | --- |
| `version` | yes | Must be `bus-ui/v1`; unknown versions fail validation. |
| `metadata` | no | Object with public strings such as `title`; defaults to `{}`. |
| `data` | no | JSON/YAML object used as binding root; defaults to `{}`. |
| `actions` | no | Map of action tokens to action objects; defaults to `{}`. |
| `resources` | no | Map of resource names to resource objects; defaults to `{}`. |
| `effects` | no | Map of effect names to effect objects; defaults to `{}`. |
| `view` | yes | Root component node with `kind`, optional `props`, `children`, and `slots`. |

```yaml
version: bus-ui/v1
metadata:
  title: Save draft
data:
  draft:
    title: Evidence note
actions:
  save:
    type: post
    target: { base: module, path: /draft/save }
    payload:
      title: { bind: draft.title }
resources: {}
effects: {}
view:
  kind: Panel
  props:
    title: Draft
  children:
    - kind: Field
      props: { label: Title }
      children:
        - kind: TextInput
          props:
            name: title
            value: { bind: draft.title }
    - kind: Button
      props:
        label: Save
        action: save
        variant: primary
```

The same document can be written as JSON. YAML is preferred for hand-authored
samples because it is easier to read in reviews. JSON is useful for generated
fixtures and API exchange.

## Component Node

Every component node uses the same basic shape:

```yaml
kind: Button
props:
  label: Save
  variant: primary
  action: save
children: []
slots: {}
when: { bind: canSave }
repeat: null
```

`kind` must name a catalog component. `props` are component-specific values.
`children` are ordered child nodes. `slots` are named children for components
that need structured regions, such as `header`, `nav`, `body`, `footer`, or
`actions`. `when` conditionally renders a node from bound data. `repeat` renders
a node once per item in a bound collection.

The renderer should reject unknown component kinds, unknown required action
tokens, invalid prop types, unsafe raw HTML without an explicit trust reason,
and bindings that cannot be resolved.

## Data Binding

Bindings read from the document `data` object or from a product-provided view
model. They should be simple and deterministic. A binding path such as
`notes[0].title` or `activeNote.status` reads data; it should not execute
arbitrary expressions.

Formatters should be named and testable. Examples include date formatting,
currency formatting, fixed decimal formatting, status label mapping, and safe
artifact URL resolution. Product modules can register product-specific
formatters, but a document should still validate when the formatter is unknown
by reporting a clear diagnostic.

## Actions

Actions are named separately from components so they can be reviewed and tested.
An action describes intent, method, target, payload binding, confirmation
policy, and expected result handling. Components refer to actions by name.

Action entries accept `type` values `get`, `post`, `link`, and `submit`.
`type` defaults to `post` when omitted. `target` is required for `get`, `post`,
`link`, and `submit` unless a Go runtime handler owns routing. `payload`
defaults to `{}`. `confirm` is optional and may include public `title`,
`summary`, and `variant` values. Unknown action fields, unresolved targets,
invalid type values, or payload bindings that cannot be resolved fail
validation.

Targets can be literal paths in standalone samples, but portal-module documents
should prefer host-resolved targets. A target such as `{ base: module, path:
"/review" }` means "resolve this path under the current mounted module base."
Literal `/modules/<id>/...` paths are mainly for fixtures that intentionally
test a concrete mounted path.

```yaml
actions:
  archive:
    type: post
    target:
      base: module
      path: /archive
    payload:
      note_id: { bind: row.id }
    confirm:
      title: Archive note?
      variant: warning
```

The renderer should emit stable action tokens. The Go/WASM runtime maps those
tokens to typed handlers. Server-rendered forms may use the same action
definition to produce native `method` and `action` attributes.

Keep actions small. A file upload, AI send, approval decision, archive button,
or container-run submit should all use the same action shape. Product-specific
meaning belongs in the registered handler, not in a new component-specific
action language.

## Resources And Effects

Resources name external data or media without fetching it by themselves. They
cover provider endpoints, upload targets, evidence previews, artifact links,
and background data sources. Components and actions refer to resources by name
so host path resolution, auth headers, and test fakes stay centralized.

Effects describe lifecycle behavior around resources. Polling, event streams,
drop handling, resize behavior, close guards, and client logging should be
modeled as effects with explicit start, apply, error, and dispose behavior.
Documents should prefer named effects over inline scripts or ad hoc browser
callbacks.

Resource entries require `base` and `path`, and accept optional `query` and
`headers`. `base` is `module`, `portal`, or a named host resolver. `query`
defaults to `{}`. `headers` defaults to `{}` and must contain only public
header names allowed by the host.

Effects are keyed by name and require `type` plus the fields required by that
type. `type` values are `polling`, `event-stream`, `drop`, `resize`,
`close-guard`, and `log`. Polling requires `resource`, positive `interval`,
`apply`, and `dispose`. Event streams require `resource`, `apply`, and
`dispose`. `apply` names a registered runtime reducer/callback. `dispose`
names a registered disposer. Omitted optional fields use the component default
documented on the matching effect reference page.

```yaml
resources:
  notes:
    base: module
    path: /api/notes
    query:
      status: review
effects:
  notes_refresh:
    type: polling
    resource: notes
    interval: 30s
    apply: notes.applyRefresh
    dispose: stop-notes-refresh
```

Unknown resource names, invalid bases, missing required effect fields, invalid
durations, and unresolved disposer names fail validation.

Complete documents for notes, auth, assistant, terminal, and evidence
workflows are maintained in [UI framework examples](../examples/).

## Slots

Slots keep complex components readable. A shell can have `nav`, `body`, and
`assistant` slots. A data table can have `toolbar`, `empty`, and `rowActions`
slots. A result panel can have `actions` and `details` slots.

```yaml
kind: AssistantShell
slots:
  business:
    kind: Panel
    props:
      title: Workspace
    children:
      - kind: Text
        props:
          value: Review generated files before approval.
  assistant:
    kind: AIPanel
    props:
      activeThread: { bind: ai.activeThread }
      threads: { bind: ai.threads }
```

Slots are still component children. They only add names where positional
children would be ambiguous.

## Safety

Declarative documents are data, not code. They should not execute shell
commands, arbitrary JavaScript, Go templates, or untrusted expressions.

`RawHTML` requires an explicit `trusted: true` flag and a `reason`. Product
modules should prefer sanitized Markdown or structured components. Runtime
config fields must be public. Validation should warn or fail when a field name
suggests a secret, token, password, private key, or credential.

Links must use safe schemes by default. External links should add safe target
and referrer attributes. File and artifact links should go through resolver
components so provider authorization remains authoritative.

## Renderer Outputs

The renderer should support at least these outputs:

- HTML for server rendering and samples;
- normalized JSON for review and tests;
- component inventory for documentation;
- validation diagnostics for command-line and editor feedback.

Later render targets can use the same document to mount a Go/WASM app. The
document describes the tree and actions; the host supplies runtime context,
provider clients, and registered action handlers.

## Use In Tests

Declarative documents make good fixtures. A module can keep `testdata/*.yml`
files for important UI states, render them through the same `bus-ui` renderer,
and assert stable HTML or normalized JSON. This gives agents a clear artifact
to update when the UI changes and reduces the need for broad browser e2e tests.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../examples/">Examples</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../../modules/bus-ui)
- [UI component catalog](./component-catalog)
- [UI framework examples](../examples/)
