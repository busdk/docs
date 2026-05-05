---
title: bus integration dev task
description: Bridge Bus development task events to steerable development workers.
---

## Overview

`bus integration dev task` connects `bus dev work` / `bus dev task` streams to development
workers. The worker claims `bus.dev.task.created` events for one recipient,
publishes task progress, and closes or fails the task from the selected backend
result.

The default local backend is `codex-appserver`, which runs Codex through the
shared [bus agent](./bus-agent) App Server integration. While the child Codex
session runs, the task stream is the parent control plane: `bus dev work say`
steers the active turn, approval requests are emitted as
`bus.dev.task.approval.requested`, and `bus dev work approve` sends decisions
back to the pending app-server request. The `container` backend is still
available for provider-neutral one-shot execution through [bus containers](./bus-containers).

## Usage

Before starting this worker, run a Bus Events API and provide `BUS_API_TOKEN`
with `events:send`, `events:listen`, `dev:task:read`, `dev:task:send`,
`dev:task:reply`, and `dev:task:claim`. For the default
`--agent-backend codex-appserver`, `codex app-server` and Codex
authentication/configuration must be available in the worker environment. For
`--agent-backend container`, also start a container integration that accepts the
requested profile and grant `container:run`; local testing can use
`bus-integration-docker` for the `codex` profile.

```sh
export BUS_API_TOKEN="<token-with-dev-task-and-container-scopes>"
bus-integration-dev-task \
  --events-url http://127.0.0.1:8081 \
  --recipient bus-dev \
  --agent-backend codex-appserver \
  --container-profile codex
```

`--workspace-root` makes the worker run tasks from the addressed module
repository. With `--workspace-root /workspace`, a task addressed to `@bus-dev`
runs from `/workspace/bus-dev`, while `@bus-integration-docker` runs from
`/workspace/bus-integration-docker`.

Stack-managed workers keep claiming additional matching tasks for their
recipient after each task completes, so parallel local work does not require
manual restarts. The containers are still disposable: remove and recreate them
freely because durable coordination is in Bus Events and task file changes are
kept in the recipient-owned Git worktree and promoted commit path, not in
container-local storage. Use `--once` and `--idle-timeout` only for temporary
one-shot workers.

`--workspace-recipient` names the recipient that maps to `--workspace-root`
itself instead of a child repository. In the BusDK local task stack this is
configured as `busdk`, so tasks addressed to `@busdk` intentionally edit the
superproject root while normal module tasks keep their own recipient
repository.

`--agent-backend codex-appserver` keeps a running session addressable by task
reference. Use `bus dev work watch <ref>` to see approval request ids, then
answer with:

```sh
bus dev work approve bus-dev#1.1 7 accept_for_session
```

The approval decision must be `accept`, `accept_for_session`, `decline`, or
`cancel`.

`--worktree` runs each task in an isolated Git worktree. The container receives
the workspace as a read-only dependency view and receives write access only to
the task worktree. When the workspace is a Git superproject with `.gitmodules`,
the worker creates task-local dependency links so relative module dependencies
resolve through the read-only workspace instead of becoming writable.
After a successful task container run, the trusted bridge can stage and commit
worktree changes with `--commit`, then promote the task branch back to the
primary checkout with a conservative fast-forward merge. Dirty or
non-fast-forward primary checkouts fail safely. The generated checkout leaf is
unique per task, which avoids Git worktree metadata collisions for repeated or
concurrent tasks addressed to the same module.

`--command-json` sets the command sent to the container as a JSON array. The
worker expands `{prompt}`, `{text}`, `{body}`, `{work_ref}`, `{recipient}`,
`{module}`, `{main_repo_path}`, `{repo_path}`, `{worktree_path}`, `{branch}`,
`{worktree_branch}`, `{base_branch}`, and `{create_branch}` placeholders.
`{repo_path}` points at the isolated worktree when `--worktree` is enabled.
`{branch}` comes from task metadata and is defaulted by `bus dev work start` or `bus dev task new` to
the current Git branch when possible.

```sh
bus-integration-dev-task \
  --events-url http://127.0.0.1:8081 \
  --recipient bus-dev \
  --agent-backend container \
  --container-profile codex \
  --workspace-root /workspace \
  --command-json '["codex","exec","--skip-git-repo-check","{prompt}"]'
```

Use `--pre-command-json` and `--post-command-json` for repository-local hooks
around the main command. Use `--commit` for the normal local isolated-worktree
path so task containers edit files only and the bridge handles Git metadata,
staging, and commit creation:

```sh
bus-integration-dev-task \
  --events-url http://127.0.0.1:8081 \
  --recipient bus-dev \
  --agent-backend container \
  --container-profile codex \
  --workspace-root /workspace \
  --worktree \
  --command-json '["codex","exec","--skip-git-repo-check","{prompt}"]' \
  --commit
```

Remote Git push is intentionally not part of the default isolated-worktree task
container path because the task container does not own writable Git metadata for
the shared workspace. The default local compose setup commits locally in the
bridge and does not push.

## Local Compose

The BusDK superproject includes `compose.dev-task-docker.yaml` for local
testing with Docker Desktop:

The default compose command for real local use runs `codex exec` in an isolated
worktree for the addressed module repository, then the bridge stages and
commits successful changes before fast-forward promotion. The workspace remains
the read-only dependency view, while the addressed repository worktree is the
only writable mount for the task container. This consumes ChatGPT-backed Codex
quota. Smoke tests override `BUS_DEV_TASK_COMMAND_JSON` to
`["codex","--version"]` and `BUS_DEV_TASK_COMMIT=false` so they do not consume
quota or create commits.

```sh
BUS_DEV_TASK_COMMAND_JSON='["codex","--version"]' \
BUS_DEV_TASK_COMMIT=false \
docker compose -f compose.dev-task-docker.yaml up --build -d
docker compose -f compose.dev-task-docker.yaml exec testing-agent sh
```

Inside the testing shell, create a task and watch the task reference printed by
the `task new` command:

```sh
cd /workspace/bus-dev
go run ./cmd/bus-dev task new --new-branch work/codex-version @bus-dev "Show the Codex CLI version."
go run ./cmd/bus-dev task watch <printed-task-ref> --timeout 5m
```

Successful smoke output includes the container stdout from `codex --version`
and a completed task status. A timeout or failed container run leaves the task
with a failed status and prints the failure message in `task watch`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-integration-database">bus integration database</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-integration-docker">bus integration docker</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus dev](./bus-dev)
- [bus containers](./bus-containers)
- [bus integration docker](./bus-integration-docker)
- [bus events](./bus-events)
