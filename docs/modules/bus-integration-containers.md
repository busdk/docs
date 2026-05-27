---
title: bus integration containers
description: Route provider-neutral Bus container events to Docker, Podman, or another backend runtime integration.
---

## Overview

`bus integration containers` is the provider-neutral container integration
router. It handles the public `bus.containers.*` Events contract and forwards
each request to one configured backend event prefix such as
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

For a local memory-backed Events API, start:

```sh
BUS_EVENTS_JWT_SECRET=not-a-secret-local-development-hs256-key \
bus-api-provider-events --addr 127.0.0.1:8081 --events-backend memory
```

For local testing, mint a reusable service token file with:

```sh
mkdir -p ./local
BUS_AUTH_HS256_SECRET=not-a-secret-local-development-hs256-key \
bus operator token issue --local \
  --subject container-router-local \
  --audience ai.hg.fi/api \
  --scope 'container:read container:run container:delete container:admin events:send events:listen' \
  --ttl 12h \
  --format token > ./local/container-router.token
```

The container scopes authorize protected `bus.containers.*` and default
`bus.docker.*` events. The broad `events:send` and `events:listen` scopes are
needed only for unprotected backend prefixes such as the default `bus.podman.*`
example below, or for custom backend prefixes without an Events API ACL rule.
Production deployments should use the normal service-token flow, grant only the
scopes required by the selected backend prefix, and expose the resulting
`BUS_API_TOKEN` to every Events API client process: backend worker, router,
containers API provider, and test command.

In the first terminal or service, run the matching Docker worker with the same
backend prefix. `bus-integration-docker` must be installed or run from its
module checkout, and the process must have permission to access the Docker
daemon through `DOCKER_HOST` or `/var/run/docker.sock`:

```sh
export BUS_API_TOKEN="$(cat ./local/container-router.token)"
bus-integration-docker \
  --provider docker \
  --events-url http://127.0.0.1:8081 \
  --event-prefix bus.docker
```

For Podman, use the same pattern with a Podman backend prefix:

```sh
export BUS_API_TOKEN="$(cat ./local/container-router.token)"
bus-integration-podman \
  --provider podman \
  --events-url http://127.0.0.1:8081 \
  --event-prefix bus.podman
```

Then set the router `--backend-event-prefix` to `bus.podman` instead of
`bus.docker`.

In the second terminal or service, run the router:

```sh
export BUS_API_TOKEN="$(cat ./local/container-router.token)"
bus-integration-containers \
  --provider events \
  --events-url http://127.0.0.1:8081 \
  --backend-event-prefix bus.docker \
  --request-timeout 30m
```

In a third terminal with the same token, start the containers API provider
against the same Events API:

```sh
export BUS_API_TOKEN="$(cat ./local/container-router.token)"
bus-api-provider-containers \
  --addr 127.0.0.1:8080 \
  --backend events \
  --events-url http://127.0.0.1:8081
```

Then verify routing from a fourth terminal:

```sh
export BUS_AI_API_URL=http://127.0.0.1:8080
export BUS_API_TOKEN="$(cat ./local/container-router.token)"
bus-containers run --profile codex -- sh -lc 'printf OK'
```

The response should contain `OK`; that proves the public
`bus.containers.run.request` reached the configured backend prefix and returned
through the router.

`--provider static` returns deterministic responses for self-tests.
`--provider events` forwards public requests through Bus Events and waits for
the backend response with the original correlation ID.

## Event Mapping

| Public request event                     | Backend request suffix     |
|------------------------------------------|----------------------------|
| `bus.containers.status.request`          | `status.request`           |
| `bus.containers.run.request`             | `run.request`              |
| `bus.containers.input.request`           | `input.request`            |
| `bus.containers.delete.request`          | `delete.request`           |
| `bus.containers.runner.status.request`   | `runner.status.request`    |
| `bus.containers.runner.start.request`    | `runner.start.request`     |
| `bus.containers.runner.delete.request`   | `runner.delete.request`    |

With `--backend-event-prefix bus.docker`, a public
`bus.containers.run.request` becomes
`bus.docker.run.request`, and the router waits for
`bus.docker.run.response` before publishing
`bus.containers.run.response`.

Live task input follows the same pattern. A public
`bus.containers.input.request` becomes
`bus.docker.input.request`, and the router returns
`bus.containers.input.response` after the backend publishes the correlated
backend response.

When this router is active, backend workers consume backend-prefixed events
such as `bus.docker.*` or `bus.podman.*`. The public `bus.containers.*` events
stay on the provider-neutral side of the router.

## Local Compose

The superproject `compose.yaml` uses this routing layout:

```text
bus-api-provider-containers
  -> bus.containers.* public events
  -> bus-integration-containers
  -> bus.docker.* backend events
  -> bus-integration-docker
```

Start it from the superproject root:

```sh
docker compose -f compose.yaml --profile dev-task up --build -d
docker compose -f compose.yaml --profile dev-task ps
docker compose -f compose.yaml --profile dev-task exec testing-agent sh
```

Inside the testing shell, run a direct Codex-profile container check:

```sh
cd /workspace/bus-containers
go run ./cmd/bus-containers run --profile codex -- codex --version
```

The command should return a successful run response with exit code `0` and
stdout from the Codex CLI. That proves the public `bus.containers.run.request`
reached the configured Docker backend prefix and returned through the router.

The root `compose.yaml` local AI Platform stack uses the same router shape for
`bus containers run --profile codex`, while nginx exposes the containers API at
`/api/v1/containers/*` and the protected runner API at
`/api/internal/containers/*`.

### Using from `.bus` files

Inside a `.bus` file, write the module target without the `bus` prefix:

```bus
# same as: bus integration containers --events-url "$BUS_EVENTS_API_URL" --backend-event-prefix bus.docker
integration containers --events-url "$BUS_EVENTS_API_URL" --backend-event-prefix bus.docker
```

The shell or service that runs the `.bus` file still needs `BUS_API_TOKEN` with
the same Events permissions as the equivalent CLI command.

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
