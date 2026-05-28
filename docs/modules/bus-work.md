---
title: bus-work
description: "bus-work is a historical skeleton for an earlier generic work-stream command; new task/thread and worker orchestration lives in bus-task."
---

## `bus-work` — historical skeleton

`bus-work` was started as a generic durable work-stream module. That direction
is currently superseded by [`bus-task`](./bus-task), whose `bus task` interface
more clearly describes bidirectional agentic task threads with messages,
status, attachments, worker metadata, and multi-remote worker launch control.

Do not build new task/thread or worker orchestration features in `bus-work` for
now. Use `bus-task`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-task">bus-task</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
