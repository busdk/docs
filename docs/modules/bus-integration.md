---
title: bus-integration — integration runtime helpers
description: bus-integration provides shared Events API worker-loop, publisher, and request/reply helpers for Bus integration modules.
---

## Overview

`bus-integration` provides shared runtime helpers for Bus integration workers.
It is a library-only module used by `bus-integration-*` services that listen to
Bus Events, publish correlated responses, or compose request/reply flows through
the Events API.

The module owns generic integration runtime behavior: Events API worker-loop
setup, response-event publishing adapters, request/reply correlation, and a
host registration surface for grouping multiple workers with one shared Events
API client. The command or service that uses the host owns concurrent worker
lifetime and cancellation. It does not own cloud APIs, SSH transport, Podman scripts,
container runtime behavior, credentials, or HTTP controllers. Those concerns
stay in the module that owns the provider or transport domain.

## How Integrations Use It

An integration worker calls `RunWorker` with an Events API client, event names,
consumer-group settings, and a handler. The handler receives the incoming
event and a `Publisher` that can emit zero or more response events.

Request/reply integrations use `Requester` when they need to publish a request
event and wait for a response event with the same correlation ID. The helper
keeps pending requests in memory, routes responses by correlation ID, and
returns either the response payload, a response error, or a timeout.

Integration binaries can expose `WorkerRegistration` values. A host command can
run one or more registrations in the same process, while each
`bus-integration-*` module can still keep its standalone binary entrypoint.

`bus-integration-upcloud` is the current example of the intended boundary: the
worker listens for cloud-neutral VM/container request events, but UpCloud API
calls and container-runner behavior remain in `bus-integration-upcloud`.
Generic SSH execution remains in `bus-integration-ssh-runner`.

### Sources

- [bus-integration README](../../../bus-integration/README.md)
- [bus-events](./bus-events.md)
- [bus-integration-upcloud](./bus-integration-upcloud.md)
- [bus-integration-ssh-runner](./bus-integration-ssh-runner.md)
