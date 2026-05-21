---
title: bus integration podman
description: Run Bus container backend events against local or rootless Podman.
---

## Overview

`bus integration podman` is the Podman runtime integration worker. It handles the
`bus.podman.*` Events namespace and is normally used behind
[bus integration containers](./bus-integration-containers), which translates the
public `bus.containers.*` contract to a selected backend such as `bus.podman.*`.

The module also provides Go helpers for rootless Podman bootstrap and run
scripts. Cloud modules that need Podman on remote nodes should reuse those
helpers instead of constructing Podman shell scripts themselves.

## Usage

Before starting this worker, run a Bus Events API and export `BUS_API_TOKEN`
for every process that publishes or listens on the event path. With the
default `bus.podman.*` backend prefix, the Podman worker listens for request
events and publishes response events, so the token must include `events:send`
and `events:listen`. If the same token is reused for the provider-neutral
router, the containers API provider, or `bus containers`, include
`container:read`, `container:run`, `container:delete`, and `container:admin`
for the protected public `bus.containers.*` events.

Podman must be installed locally, or `--podman-bin`/`PODMAN_BIN` must point to
the executable.

For a local memory-backed Events API, start:

```sh
BUS_EVENTS_JWT_SECRET=not-a-secret-local-development-hs256-key \
bus-api-provider-events --addr 127.0.0.1:8081 --events-backend memory
```

Mint `BUS_API_TOKEN` with the same HS256 secret plus Events scopes. The
container scopes in this example let the same token exercise the full router
and API-provider path; a standalone Podman backend on the default unprotected
prefix only needs the Events scopes unless the deployment protects
`bus.podman.*` with a custom ACL:

```sh
mkdir -p ./local
BUS_AUTH_HS256_SECRET=not-a-secret-local-development-hs256-key \
bus operator token issue --local \
  --subject podman-worker-local \
  --audience ai.hg.fi/api \
  --scope 'events:send events:listen container:read container:run container:delete container:admin' \
  --ttl 12h \
  --format token > ./local/podman-worker.token
```

Run a local Podman worker:

```sh
export BUS_API_TOKEN="$(cat ./local/podman-worker.token)"
bus-integration-podman \
  --provider podman \
  --events-url http://127.0.0.1:8081 \
  --event-prefix bus.podman
```

Run the provider-neutral router in a separate terminal or service with the same
`BUS_API_TOKEN`, Events URL, and backend prefix:

```sh
export BUS_API_TOKEN="$(cat ./local/podman-worker.token)"
bus-integration-containers \
  --provider events \
  --events-url http://127.0.0.1:8081 \
  --backend-event-prefix bus.podman
```

To verify through the public CLI, run the containers API provider in a third
terminal against the same Events API:

```sh
export BUS_API_TOKEN="$(cat ./local/podman-worker.token)"
bus-api-provider-containers \
  --addr 127.0.0.1:8080 \
  --backend events \
  --events-url http://127.0.0.1:8081
```

Use `--provider static` only for deterministic help/self-test checks. Use
`--provider podman` for real container runs; it calls the executable selected
by `--podman-bin` or `PODMAN_BIN`, defaulting to `podman`.

Verify local behavior without a real Podman host:

```sh
bus-integration-podman --self-test
bus-integration-podman --events --format json
```

The self-test prints `bus-integration-podman self-test OK`, and the event
metadata includes `bus.podman.run.request`.

For the full router path, start both long-running workers and then send a
public container run through the containers API:

```sh
export BUS_AI_API_URL=http://127.0.0.1:8080
export BUS_API_TOKEN="$(cat ./local/podman-worker.token)"
bus containers run --profile codex -- sh -lc 'printf OK'
```

The `codex` profile is resolved by the Podman worker from
`--container-codex-image` or `PODMAN_CONTAINER_CODEX_IMAGE`, defaulting to
`docker.io/library/alpine:3.20`. A working router plus Podman backend returns a
successful run response containing `OK`; the router maps the public
`bus.containers.run.request` to `bus.podman.run.request`.

## Events

The default Events API ACL protects public `bus.containers.*` events with
container domain scopes and leaves the backend `bus.podman.*` prefix as a
deployment-local integration prefix. For the default backend prefix, listening
uses `events:listen` and publishing uses `events:send`. If an operator adds a
specific ACL for `bus.podman.*`, grant the domain scopes mapped by that
deployment instead.

| Direction | Event                                  | Default Events scope |
|-----------|----------------------------------------|----------------------|
| listens   | `bus.podman.status.request`            | `events:listen`      |
| sends     | `bus.podman.status.response`           | `events:send`        |
| listens   | `bus.podman.run.request`               | `events:listen`      |
| sends     | `bus.podman.run.response`              | `events:send`        |
| listens   | `bus.podman.delete.request`            | `events:listen`      |
| sends     | `bus.podman.delete.response`           | `events:send`        |
| listens   | `bus.podman.runner.status.request`     | `events:listen`      |
| sends     | `bus.podman.runner.status.response`    | `events:send`        |
| listens   | `bus.podman.runner.start.request`      | `events:listen`      |
| sends     | `bus.podman.runner.start.response`     | `events:send`        |
| listens   | `bus.podman.runner.delete.request`     | `events:listen`      |
| sends     | `bus.podman.runner.delete.response`    | `events:send`        |

## Safety

Podman can still mutate local host state and pull/run arbitrary images. Deploy
this worker only in trusted runtime environments and rely on Bus API/Event
authorization to restrict who may publish run and runner lifecycle requests.

### Using from `.bus` files

Inside a `.bus` file, write the module target without the `bus` prefix:

```bus
# same as: bus integration podman --provider podman --events-url "$BUS_EVENTS_API_URL" --event-prefix bus.podman
integration podman --provider podman --events-url "$BUS_EVENTS_API_URL" --event-prefix bus.podman
```

The shell or service that runs the `.bus` file still needs `BUS_API_TOKEN` with
the same Events permissions as the equivalent CLI command.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-integration-ollama">bus integration ollama</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-integration-postgres">bus integration postgres</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus integration containers](./bus-integration-containers)
- [bus api provider containers](./bus-api-provider-containers)
- [bus api provider events](./bus-api-provider-events)
- [Podman documentation](https://podman.io/docs)
