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
listener retry/readiness helper, and a host registration surface for grouping
multiple workers with one shared Events API client. The command or service that
uses the host owns concurrent worker lifetime and cancellation. It does not own
cloud APIs, SSH transport, Podman scripts, container runtime behavior,
credentials, or HTTP controllers. Those concerns stay in the module that owns
the provider or transport domain.

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

### Listener Retry And Readiness

Workers that use Events request/reply should not depend on startup ordering.
`RunWorker` can consume `ListenerRetryOptions` to reconnect after stream EOF or
network failure with bounded backoff. Required listeners can publish readiness
state through `ListenerReadiness`; readiness is false until the listener has
observed connectivity and false again after a retryable failure.

Standalone integrations can read the shared environment contract:

```bash
BUS_EVENTS_LISTENER_RETRY=1
BUS_EVENTS_LISTENER_RETRY_MIN=1s
BUS_EVENTS_LISTENER_RETRY_MAX=30s
BUS_EVENTS_LISTENER_REQUIRED=1
BUS_EVENTS_TOKEN_REFRESH=0
```

With static tokens, 401/403 authorization failures fail fast by default. A
future token provider can opt into refresh/reissue by enabling token refresh
and supplying refreshed credentials at the command boundary.

`bus-integration-upcloud` is one example of the intended boundary: the worker
listens for cloud-neutral VM/container request events, but UpCloud API calls
and container-runner behavior remain in `bus-integration-upcloud`. Generic SSH
execution remains in `bus-integration-ssh-runner`, and usage storage/business
logic remains in `bus-integration-usage`.

### Sources

- [bus-integration README](../../../bus-integration/README.md)
- [bus-events](./bus-events.md)
- [bus-integration-upcloud](./bus-integration-upcloud.md)
- [bus-integration-ssh-runner](./bus-integration-ssh-runner.md)
- [bus-integration-usage](./bus-integration-usage.md)
