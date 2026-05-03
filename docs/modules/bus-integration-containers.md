---
title: bus integration containers
description: Route provider-neutral Bus container events to Docker, Podman, or another backend runtime integration.
---

## Overview

`bus integration containers` is the provider-neutral container integration
router. It owns the public `bus.containers.*` Events contract and forwards each
request to one configured backend event prefix such as
`bus.docker` or `bus.podman`.

Use this module when a deployment needs one stable container event contract for
`bus-api-provider-containers`, `bus-containers`, and developer task automation,
while keeping Docker, Podman, UpCloud, SSH, and future runtime logic in separate
integration modules.

## Usage

Run the router against a backend worker. Bus Events must already be running and
reachable at the `--events-url` used by both processes. Start the backend
worker and the router concurrently in separate terminals or services; both
commands are long-running workers.

Use a token issued through `bus operator token` or the deployment's normal
service-token flow with `container:read`, `container:run`, `container:delete`,
and `container:admin` scopes:

In the first terminal or service, run the matching Docker worker with the same
backend prefix:

```sh
bus-integration-docker \
  --provider docker \
  --events-url http://127.0.0.1:8081 \
  --event-prefix bus.docker
```

In the second terminal or service, run the router:

```sh
export BUS_API_TOKEN="<service-token-with-container-scopes>"
bus-integration-containers \
  --provider events \
  --events-url http://127.0.0.1:8081 \
  --backend-event-prefix bus.docker \
  --request-timeout 30m
```

`--provider static` returns deterministic responses for self-tests.
`--provider events` forwards public requests through Bus Events and waits for
the backend response with the original correlation ID.

## Event Mapping

| Public request event                     | Backend request suffix     |
|------------------------------------------|----------------------------|
| `bus.containers.status.request`          | `status.request`           |
| `bus.containers.run.request`             | `run.request`              |
| `bus.containers.delete.request`          | `delete.request`           |
| `bus.containers.runner.status.request`   | `runner.status.request`    |
| `bus.containers.runner.start.request`    | `runner.start.request`     |
| `bus.containers.runner.delete.request`   | `runner.delete.request`    |

With `--backend-event-prefix bus.docker`, a public
`bus.containers.run.request` becomes
`bus.docker.run.request`, and the router waits for
`bus.docker.run.response` before publishing
`bus.containers.run.response`.

Do not run backend workers on the public `bus.containers.*` events when this
router is active. Backends should consume backend-prefixed events so the router
is the only owner of the public provider-neutral contract.

## Local Compose

The superproject `compose.dev-task-docker.yaml` uses this routing layout:

```text
bus-api-provider-containers
  -> bus.containers.* public events
  -> bus-integration-containers
  -> bus.docker.* backend events
  -> bus-integration-docker
```

Start it from the superproject root:

```sh
docker compose -f compose.dev-task-docker.yaml up --build -d
docker compose -f compose.dev-task-docker.yaml ps
docker compose -f compose.dev-task-docker.yaml exec testing-agent sh
```

Inside the testing shell, run a direct container check:

```sh
go run ./bus-containers/cmd/bus-containers run --profile codex -- sh -lc 'printf OK'
```

The command should return a successful run response containing `OK`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-integration-codex">bus integration codex</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-integration-database">bus integration database</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus api provider containers](./bus-api-provider-containers)
- [bus integration docker](./bus-integration-docker)
- [bus integration podman](./bus-integration-podman)
- [bus events](./bus-events)
