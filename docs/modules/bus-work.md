---
title: bus-work
description: "bus-work is a deprecated historical module; its old command implementation has been removed and new task/thread and worker orchestration belongs in bus-task and bus-worker."
---

## `bus-work` — removed historical work-stream command

`bus-work` is a deprecated historical module. The old `bus work ...` command
implementation has been removed from the module checkout because current BusDK
task/worker flows do not use it.

Use [`bus-task`](./bus-task) for current bidirectional task threads, messages,
attachments, task lifecycle, worker metadata, and multi-remote task launch. Use
[`bus-worker`](./bus-worker) and the `bus workers ...` command family for
durable worker identity, status, logs, attach, pause/resume, assignment, and
environment-aware worker control.

The removed command implemented a generic executor-independent `bus.work.*`
queue protocol. That code remains available in Git history if an audit or
restoration task needs it. The Events API may keep `bus.work.*` authorization
compatibility separately while old external usage is audited.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-task">bus-task</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
