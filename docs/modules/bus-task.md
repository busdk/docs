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
bus task start --profile codex-spark --model gpt-5.3-codex-spark --reasoning-effort high --sandbox write @bus-dev "Fix the scheduler"
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
  `gpt-oss:120b` and hosted names such as `gpt-5.3-codex-spark` are accepted as
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

Durable worker identity, specialization, long-lived notes/memo behavior, and
worker-specific context files belong outside the task/thread protocol.
`bus-agent` owns provider-neutral runtime and App Server helpers, not durable
human or AI worker identity. If Bus exposes worker identity UX such as listing
configured workers, active work, profiles, and statistics, that should be a
first-class worker-facing module/API contract that follows the normal Bus CLI
and integration architecture. `bus-task` records assignment and claim
references to those workers, but it does not own the worker identity lifecycle.

### Codex Spark Workers

For the common Spark-quota path, create a profile such as `codex-spark` in the
selected remote by adding a non-secret `worker_profiles` entry to
`.bus/remote/config.json` or the user `remote/config.json` read by
[`bus remote`](./bus-remote). If one environment should prefer that profile by
default, add `default_worker_profile` to the matching `environments` entry.
Before using the profile, make sure the referenced credential label or source
already exists on the worker host, for example the Codex ChatGPT subscription
auth source behind `codex-chatgpt-subscription`:

```json
{
  "remotes": [
    {
      "id": "hosted-codex",
      "kind": "bus-events",
      "url": "https://events.example.invalid",
      "worker_profiles": {
        "codex-spark": {
          "model": "gpt-5.3-codex-spark",
          "reasoning_effort": "high",
          "auth_mode": "chatgpt-subscription",
          "credential_source": {
            "kind": "os-credential-label",
            "ref": "codex-chatgpt-subscription"
          }
        }
      }
    }
  ],
  "environments": [
    {
      "id": "env-dev-hg-codex",
      "name": "dev-hg",
      "remote_id": "hosted-codex",
      "default_worker_profile": "codex-spark"
    }
  ]
}
```

Then start the task against that profile. Use `--sandbox full` only for
dedicated disposable worker containers where the container is the isolation
boundary:

```bash
bus task start --environment dev-hg @bus-dev "Implement the change"
bus task start --profile codex-spark --model gpt-5.3-codex-spark --reasoning-effort high --sandbox full @bus-dev "Implement the change"
```

Then confirm the worker lane picked up the task and kept the Spark profile in
its metadata:

```bash
bus task status --watch
bus task monitor --format json
```

For the common `dev-hg` SSH-Docker readiness check in this superproject, use
the reusable operator-gated wrapper:

```bash
scripts/test-ssh-docker-spark-smoke.sh
```

The wrapper defaults to `codex-spark`, `gpt-5.3-codex-spark`,
`chatgpt-subscription`, the pullable worker image
`ghcr.io/busdk/bus-integration-task:latest`, and a read-only prompt. Use
`--image`, `--local-tag`, `--install-image`, or `--build-image` when the smoke
should prove a specific local image or recover from remote registry pull
failure. The common recovery path is:

```bash
scripts/test-ssh-docker-spark-smoke.sh --install-image
```

That keeps the remote runtime image as
`ghcr.io/busdk/bus-integration-task:latest`, but ships the local source tag
`bus-integration-task:local-image-smoke` unless `--local-tag` overrides it.

For a disposable ground-up local proof that avoids the full local Compose
stack, use:

```bash
scripts/test-local-task-events-proof.sh
```

That script starts `bus-api-provider-events` directly from source with the
memory backend, creates one task, marks it ready, and prints list/show/monitor
evidence. Treat it as explicit disposable proof, not as the durable local
worker environment used for normal development.

For the next ground-up rung, use:

```bash
scripts/test-local-host-worker-smoke.sh
```

That smoke keeps the disposable source-run Events API but launches the worker
directly on the host through `BUS_DEV_WORKER_LAUNCHER` and
`scripts/local-task-host-worker-launcher.sh` instead of depending on
`docker compose run`. Its default backend is `self-test`, so it validates
local worker claim and terminal flow deterministically before a real local
Spark attempt with `gpt-5.3-codex-spark`.

In Codex terms, `--sandbox full` maps to `danger-full-access`; the Bus CLI uses
the shorter worker-context name.
