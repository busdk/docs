---
title: bus integration dev task
description: Bridge Bus development task events to provider-neutral container runs.
---

## Overview

`bus integration dev task` connects `bus dev task` streams to container-backed
agent execution. The worker claims `bus.dev.task.created` events for a
recipient, starts one provider-neutral container run, publishes container output
as task messages, and closes or fails the task from the container exit code.

The worker uses the Bus Events API and the same container request contract as
[bus containers](./bus-containers). Local Docker execution is provided by
[bus integration docker](./bus-integration-docker); cloud execution can use
other container integrations behind the same Events contract.

## Usage

Before starting this worker, run a Bus Events API, start a container
integration that accepts the requested profile, and provide `BUS_API_TOKEN`
with `dev:task:claim`, `dev:task:reply`, and `container:run`. For local
testing, `bus-integration-docker` can provide the `codex` profile.

```sh
export BUS_API_TOKEN="<token-with-dev-task-and-container-scopes>"
bus-integration-dev-task \
  --events-url http://127.0.0.1:8081 \
  --recipient bus-dev \
  --container-profile codex
```

`--command-json` sets the command sent to the container as a JSON array. The
worker expands `{prompt}`, `{text}`, `{body}`, and `{work_ref}` placeholders.

```sh
bus-integration-dev-task \
  --events-url http://127.0.0.1:8081 \
  --recipient bus-dev \
  --container-profile codex \
  --command-json '["codex","exec","--skip-git-repo-check","{prompt}"]'
```

## Local Compose

The BusDK superproject includes `compose.dev-task-docker.yaml` for local
testing with Docker Desktop:

```sh
docker compose -f compose.dev-task-docker.yaml up --build -d
docker compose -f compose.dev-task-docker.yaml exec testing-agent sh
```

Inside the testing shell, create a task and watch the task reference printed by
the `task new` command:

```sh
cd /workspace/bus-dev
go run ./cmd/bus-dev task new @bus-dev "Show the Codex CLI version."
go run ./cmd/bus-dev task watch <printed-task-ref> --timeout 5m
```

The default compose command runs `codex --version`, so a successful task output
includes `codex-cli`. For live `codex exec` testing, configure
`BUS_DEV_TASK_COMMAND_JSON`, `BUS_DOCKER_CODEX_HOME_HOST`,
`BUS_DOCKER_CODEX_HOME_WRITABLE=true`, and `BUS_DOCKER_CODEX_WORKSPACE_HOST`
before starting compose.

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
