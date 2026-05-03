---
title: bus integration podman
description: Run Bus container backend events against local or rootless Podman.
---

## Overview

`bus integration podman` is the Podman runtime integration worker. It owns the
`bus.podman.*` Events namespace and is normally used behind
[bus integration containers](./bus-integration-containers), which translates the
public `bus.containers.*` contract to a selected backend such as `bus.podman.*`.

The module also provides Go helpers for rootless Podman bootstrap and run
scripts. Cloud modules that need Podman on remote nodes should reuse those
helpers instead of constructing Podman shell scripts themselves.

## Usage

Prerequisites:

- Bus Events API is reachable through `--events-url`.
- Podman is installed locally or `--podman-bin`/`PODMAN_BIN` points to the
  executable.
- `BUS_API_TOKEN` is set to a service token with `container:read`,
  `container:run`, `container:delete`, and `container:admin` scopes.

Run a local Podman worker:

```sh
export BUS_API_TOKEN="<service-token-with-container-scopes>"
bus-integration-podman \
  --provider podman \
  --events-url http://127.0.0.1:8081 \
  --event-prefix bus.podman
```

Run the provider-neutral router in a separate terminal or service with the same
`BUS_API_TOKEN`, Events URL, and backend prefix:

```sh
bus-integration-containers \
  --provider events \
  --events-url http://127.0.0.1:8081 \
  --backend-event-prefix bus.podman
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

## Events

| Direction | Event                                  | Scope              |
|-----------|----------------------------------------|--------------------|
| listens   | `bus.podman.status.request`            | `container:read`   |
| sends     | `bus.podman.status.response`           | `container:read`   |
| listens   | `bus.podman.run.request`               | `container:run`    |
| sends     | `bus.podman.run.response`              | `container:run`    |
| listens   | `bus.podman.delete.request`            | `container:delete` |
| sends     | `bus.podman.delete.response`           | `container:delete` |
| listens   | `bus.podman.runner.status.request`     | `container:admin`  |
| sends     | `bus.podman.runner.status.response`    | `container:admin`  |
| listens   | `bus.podman.runner.start.request`      | `container:admin`  |
| sends     | `bus.podman.runner.start.response`     | `container:admin`  |
| listens   | `bus.podman.runner.delete.request`     | `container:admin`  |
| sends     | `bus.podman.runner.delete.response`    | `container:admin`  |

## Safety

Podman can still mutate local host state and pull/run arbitrary images. Deploy
this worker only in trusted runtime environments and rely on Bus API/Event
authorization to restrict who may publish run and runner lifecycle requests.

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
- [Podman documentation](https://podman.io/docs)
