---
title: bus-task
description: "bus task manages generic task threads and worker orchestration over Bus Events, including local and cloud worker profiles."
---

## `bus-task` — task threads and workers

`bus task` is the generic task/thread interface. A task is a bidirectional
collaboration thread with messages, status transitions, optional attachments,
worker/participant metadata, and launch evidence. It is for humans, scripts,
services, and AI agents; the protocol itself is not strictly AI-related.

Common commands:

```bash
bus task start --profile codex-spark --model GPT-5.3-Codex-Spark --reasoning-effort high --sandbox full @bus-dev "Fix the scheduler"
bus task new @support "Investigate this issue"
bus task status --watch
bus task monitor --format json
bus task say 1.1 "Use the shared storage API"
bus task reopen --write-scope run/task.go 1.1 "Retry with this scope"
```

Worker selection uses Bus-level names:

- `--profile NAME` selects a non-secret worker profile from the selected
  remote or environment.
- `--model MODEL` requests the provider/App Server model. Local names such as
  `gpt-oss:120b` and hosted names such as `GPT-5.3-Codex-Spark` are accepted as
  strings and interpreted by the selected backend/profile.
- `--reasoning-effort VALUE` requests model effort such as `high`.
- `--sandbox read|write|full` selects the Bus worker sandbox. For Codex App
  Server, these map to Codex `read-only`, `workspace-write`, and
  `danger-full-access`.
- `--backend NAME` selects a worker backend. The normal current backend is
  `codex-appserver`.
- `--args-json JSON` passes a non-secret backend argv fragment. For Codex App
  Server this becomes Codex argv.

Use `--remote ID` or `--environment ID` to select where workers run. A single
batch can assign recipients across configured local, ssh-docker, hosted, and
API-key-capable remotes while preserving per-remote profile and capacity
metadata.

Secrets are never stored in task Events or repository remote config. Worker
profiles carry only non-secret credential source references and labels.

Durable AI worker identity, specialization, long-lived notes/memo behavior, and
agent-specific context files belong outside the task/thread protocol.
`bus-agent` is the candidate owner because it already owns provider-neutral
runtime and App Server helpers, but persistent worker identity needs an
explicit `bus-agent` contract extension or a dedicated agent-identity module.
`bus-task` records assignment and claim references to those workers, but it
does not own the AI agent identity lifecycle.

### Codex Spark Workers

For the common Spark-quota path, create a profile such as `codex-spark` in the
selected remote/environment and start work with:

```bash
bus task start --profile codex-spark --model GPT-5.3-Codex-Spark --reasoning-effort high --sandbox full @bus-dev "Implement the change"
```

`--sandbox full` is appropriate for dedicated disposable worker containers
where the container is the isolation boundary. In Codex terms it maps to
`danger-full-access`; the Bus CLI uses the shorter worker-context name.
