---
title: bus-worker
description: "bus worker will manage durable worker identities, profiles, and worker-home context for Bus."
---

## `bus-worker` — worker identities

`bus worker` is the planned Bus CLI for durable worker identities. It is meant
to own concepts such as worker ids, profiles, capabilities, worker-home
repositories, active-work views, and long-lived notes or memory references.

This module is still a skeleton. The current architecture direction is:

- `bus-task` owns generic task threads and assignment references
- `bus-agent` owns runtime/provider execution adapters
- `bus-worker` will own durable worker identity and worker-specific context

Until the concrete CLI contract lands, treat this page as a scope marker rather
than a completed command reference.
