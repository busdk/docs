---
title: bus integration docker
description: Run Bus container events against local Docker Desktop or another trusted Docker Engine.
---

## Overview

`bus integration docker` runs local Docker containers for the provider-neutral
Bus container API. Operators use it in development and live testing stacks when
`bus containers run` or `/api/v1/containers/runs` should execute through Docker
Desktop on macOS instead of a cloud runner.

The worker connects to the Bus Events API and publishes correlated response
events. In composed deployments, run it behind
[bus integration containers](./bus-integration-containers) with
`--event-prefix bus.docker` so the provider-neutral router owns the
public `bus.containers.*` contract. Standalone compatibility mode can still
consume public `bus.containers.*` events directly.

Access to the Docker socket can control the host Docker daemon. Run this worker
only in trusted local environments and do not expose it to untrusted tenants.

## Usage

Before starting this worker, run a Bus Events API, provide `BUS_API_TOKEN` with
`container:read`, `container:run`, `container:delete`, and `container:admin`,
and make the Docker Engine socket available through `DOCKER_HOST` or
`/var/run/docker.sock`. The configured image, such as
`docker.io/library/alpine:3.20`, must be pullable or already present locally.
When using `--event-prefix bus.docker`, also run
`bus-integration-containers --backend-event-prefix bus.docker` so public
container events are routed to this backend prefix.

```sh
export BUS_API_TOKEN="<token-with-container-scopes>"
bus-integration-docker \
  --provider docker \
  --events-url http://127.0.0.1:8081 \
  --event-prefix bus.docker \
  --container-codex-image docker.io/library/alpine:3.20
```

`--provider static` performs deterministic self-test behavior. `--provider
docker` talks to `DOCKER_HOST`, defaulting to `unix:///var/run/docker.sock`.
When a container request uses `profile=codex`, the worker resolves the image
from `--container-codex-image` or `DOCKER_CONTAINER_CODEX_IMAGE`.

For local Codex task execution, `--codex-home-host-path` can mount a host Codex
home into the container as `/root/.codex`. It is read-only by default. Trusted
live `codex exec` sessions that need to create Codex session state must opt in
with `--codex-home-writable` or `BUS_DOCKER_CODEX_HOME_WRITABLE=true`. The
workspace mount is configured separately with `--codex-workspace-host-path` and
is mounted read-write into `/workspace` by default.

Leave `--event-prefix` unset only when the Docker worker is intentionally
consuming public container events directly. When `bus-integration-containers`
is active, set `--event-prefix` to the same backend prefix configured on the
router.

## Local Compose

The BusDK superproject includes `compose.dev-task-docker.yaml` for local
testing. Run these commands from the superproject root:

```sh
cd /path/to/busdk
docker compose -f compose.dev-task-docker.yaml up --build -d
docker compose -f compose.dev-task-docker.yaml exec testing-agent sh
```

Inside the testing shell, `bus containers run --profile codex` reaches the
provider-neutral containers API, which emits public container events. The
`bus-integration-containers` router forwards them to
`bus.docker.*` backend events consumed by this Docker worker.

```sh
cd /workspace/bus-containers
go run ./cmd/bus-containers --timeout 120s run --profile codex -- sh -lc 'printf OK'
```

A successful run prints JSON with `"exit_code": 0` and `"stdout": "OK"`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-integration-database">bus integration database</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-integration-inference">bus integration inference</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus api provider containers](./bus-api-provider-containers)
- [bus integration containers](./bus-integration-containers)
- [bus containers](./bus-containers)
- [bus events](./bus-events)
- [Docker Engine API](https://docs.docker.com/reference/api/engine/)
