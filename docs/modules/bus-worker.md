---
title: bus-worker
description: "bus worker will manage durable worker identities, profiles, and worker-home context for Bus."
---

## `bus-worker` — worker identities

`bus worker` is the Bus CLI/module for durable worker identities. It owns
concepts such as worker ids, profiles, capabilities, worker-home references,
registered groups/status, active-work views, and long-lived notes or memory
references.

The current design direction assumes those worker homes are Git-backed. That
serves two related Bus use cases:

- workers need their own durable repositories for `AGENTS.md`, memo logs, and
  other worker-local context
- Bus needs locally managed Git repositories for mirrored development sources
  so work can continue even when an upstream such as GitHub is temporarily
  unavailable
- the same repository infrastructure can also back human-facing content stores
  such as a shared Markdown wiki

The first worker registry stores `worker_home_ref` as a non-secret logical
reference. The preferred shape is:

```text
repos://workers/<worker-id>
```

That reference resolves through the repo module family to a repository record
whose kind is `worker-home`. Related refs use the same topology:
`repos://sources/<project-id>` for source mirrors and `repos://tasks/<task-id>`
for task-context repositories. `bus-worker` stores only the identity-owned
worker-home ref; `bus-repos` owns user-facing repo semantics,
`bus-integration-repos` owns provisioning/sync, and `bus-api-provider-repos`
owns API/controller exposure.

The current architecture direction is:

- `bus-task` owns generic task threads and assignment references
- `bus-agent` owns runtime/provider execution adapters
- `bus-worker` owns durable worker identity and worker-specific context
- the repo module family owns repository provisioning, sync, and API surfaces

The first direct `bus-worker` binary can create/list/show workers, create/list/show
groups, and print registered status snapshots. Live active-work telemetry and
worker-home provisioning remain planned follow-up work.

## Worker Template Summaries

Worker identity templates live in the environment catalog at
`.bus/worker/templates.json`. Each template should include a short `summary`
for quick selection and a longer `description` for operator guidance. Operators
should discover template ids with `bus workers template list` and inspect one
template with `bus workers template show <template-ref>` instead of guessing
provider model ids or composing ad hoc profile names.

For deep research, treat the profile as a workflow rather than a separate
template id: use `claude-fable-5` as the lead/synthesis worker, use
`claude-haiku-4-5` for parallel extraction and log/source triage, use
`claude-sonnet-5` or `codex-55` for implementation follow-through, and use
`codex-55-high` or `claude-opus-4-8` for hard review. The source-backed
rationale is recorded in
[`worker-template-model-selection`](../research/worker-template-model-selection).
