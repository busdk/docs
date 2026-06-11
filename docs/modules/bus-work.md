---
title: bus-work
description: "bus-work is a deprecated generic Bus Events-backed work-stream command; new task/thread and worker orchestration belongs in bus-task and bus-worker."
---

## `bus-work` — deprecated generic work streams

`bus-work` provides the older generic `bus work ...` CLI for durable work
streams over Bus Events. It can create work, claim the next item, show or watch
stream events, append messages, and close, fail, or block work through
`bus.work.*` events.

This module is deprecated. It is implemented and tested, but current BusDK
task/worker flows do not use it. Use [`bus-task`](./bus-task) for current
bidirectional task threads, messages, attachments, task lifecycle, worker
metadata, and multi-remote task launch. Use [`bus-worker`](./bus-worker) and
the `bus workers ...` command family for durable worker identity, status, logs,
attach, pause/resume, assignment, and environment-aware worker control.

Keep `bus-work` only for old clients or tests that still need the historical
generic executor-independent `bus.work.*` queue protocol. Do not add new agent
launch, worker identity, worker profile, attachment, or multi-remote
orchestration features here unless the product direction is explicitly
reopened.

Typical compatibility commands:

```bash
bus work new @worker-a "Review this document"
bus work --remote localhost next --json
bus work show 123
bus work say 123.1 "Use the attached statement."
bus work close 123.1 "Done."
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-task">bus-task</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
