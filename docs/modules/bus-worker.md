---
title: bus-worker
description: "bus worker will manage durable worker identities, profiles, and worker-home context for Bus."
---

## `bus-worker` — worker identities

`bus worker` is the planned Bus CLI for durable worker identities. It is meant
to own concepts such as worker ids, profiles, capabilities, worker-home
repositories, active-work views, and long-lived notes or memory references.

The current design direction assumes those worker homes are Git-backed. That
serves two related Bus use cases:

- workers need their own durable repositories for `AGENTS.md`, memo logs, and
  other worker-local context
- Bus needs locally managed Git repositories for mirrored development sources
  so work can continue even when an upstream such as GitHub is temporarily
  unavailable
- the same repository infrastructure can also back human-facing content stores
  such as a shared Markdown wiki

The likely future substrate for that repository infrastructure is a dedicated
Git module family such as `bus-git`, `bus-api-provider-git`, and
`bus-integration-git`, while `bus-worker` remains focused on worker identity
and worker-home ownership.

This module is still a skeleton. The current architecture direction is:

- `bus-task` owns generic task threads and assignment references
- `bus-agent` owns runtime/provider execution adapters
- `bus-worker` will own durable worker identity and worker-specific context

Until the concrete CLI contract lands, treat this page as a scope marker rather
than a completed command reference.
