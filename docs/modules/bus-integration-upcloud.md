---
title: bus-integration-upcloud — UpCloud event integration
description: bus-integration-upcloud is the event-driven UpCloud worker for Bus VM and container workflows.
---

## `bus-integration-upcloud` — UpCloud event integration

`bus-integration-upcloud` is the event-driven worker for UpCloud-specific VM
and container operations. It listens for cloud-neutral Bus Events and emits
correlated result/status events.

This module must not expose UpCloud-specific REST APIs. REST controllers belong
in cloud-neutral API provider modules.

### Current Status

The module implements the reusable worker, Bus Events API worker mode,
response-event contract, deterministic static provider, and real UpCloud HTTP
API provider. It can handle VM status/start/stop and create or start the
configured container runner. UpCloud still owns the container bootstrap and
Podman scripts, but generic SSH transport is delegated to the independent
`bus-integration-ssh-runner` worker through Bus Events.

For local development, run the static provider against a Bus Events API:

```sh
bus-integration-upcloud --events-url "$BUS_EVENTS_API_URL" --api-token "$BUS_API_TOKEN"
```

`BUS_API_TOKEN` is a normal Bus API JWT with audience `ai.hg.fi/api`. It
must include the domain scopes for the events this worker listens to and emits,
such as `vm:read`, `vm:write`, `container:read`, `container:run`, and
`container:delete`. Internal runner lifecycle events also require
`container:admin` when the containers provider exposes
`/api/internal/containers/runner` through the Events backend.
If that token is issued by `bus-api-provider-auth` as an internal service token,
set `BUS_AUTH_INTERNAL_TOKEN_TTL_SECONDS` long enough for the expected
VM/container operation lifetime or rotate/restart the worker before token
expiry.

For real UpCloud VM lifecycle calls, use the `upcloud` provider:

```sh
bus-integration-upcloud \
  --provider upcloud \
  --events-url "$BUS_EVENTS_API_URL" \
  --api-token "$BUS_API_TOKEN" \
  --upcloud-token "$UPCLOUD_TOKEN" \
  --vm-name "$UPCLOUD_VM_NAME" \
  --container-runner-name "$UPCLOUD_CONTAINER_RUNNER_NAME"
```

Use `--check-vm-status` for a one-shot diagnostic that prints VM status and
exits instead of listening for events. Real credentials must come from local
environment variables, deployment secrets, or untracked operator configuration;
do not commit them to the BusDK superproject.

When UpCloud returns `SERVER_STATE_ILLEGAL` or reports the configured VM or
runner in maintenance during start, the worker treats that as transient. It
polls until the server leaves maintenance or the bounded operation timeout
expires, then returns a clear maintenance timeout error.

For container execution, configure runner creation and target selection with
environment variables or the matching command flags. Common settings are
`UPCLOUD_CONTAINER_SSH_KEYS` for public key files used when creating a runner,
`UPCLOUD_CONTAINER_SSH_TARGET=user@host` for an explicit target, and
`UPCLOUD_CONTAINER_USERNAME_CANDIDATES` for discovered runner addresses. Runner
shape and network selection use `UPCLOUD_CONTAINER_ZONE`,
`UPCLOUD_CONTAINER_PLAN`, `UPCLOUD_CONTAINER_OS`,
`UPCLOUD_CONTAINER_NETWORK_MODE`, and
`UPCLOUD_CONTAINER_PRIVATE_NETWORK_NAME`. Private-key loading and known_hosts
validation are configured on the separate SSH runner process.

Optional DNS/netplan bootstrap is configured through generic runner variables,
not through UpCloud-specific container logic:

```bash
BUS_RUNNER_DNS_SERVERS=1.1.1.1,8.8.8.8
BUS_RUNNER_NETPLAN_MODE=mac-match
BUS_RUNNER_APPLY_NETPLAN=1
```

When enabled, UpCloud discovers the private runner NIC MAC address and passes it
as generic `network_bootstrap` data to `bus-integration-ssh-runner`. The SSH
runner applies netplan before the package-install/bootstrap script. Other
providers can omit this data or provide their own bootstrap config.

Runner deletion is also policy-driven:

```bash
BUS_RUNNER_DELETE_STOP_FIRST=1
BUS_RUNNER_DELETE_READY_STATES=stopped
BUS_RUNNER_TRANSIENT_STATES=maintenance,pending
BUS_RUNNER_DELETE_TIMEOUT=10m
BUS_RUNNER_DELETE_POLL_INTERVAL=5s
BUS_RUNNER_DELETE_STORAGE=1
```

UpCloud maps its provider states into generic lifecycle states and the generic
policy decides when to stop, wait, retry, and delete. UpCloud still performs the
actual provider API stop/delete calls.

For container execution, run `bus-integration-ssh-runner` against the same Bus
Events API or host both UpCloud and SSH-runner registrations with
`bus-integration`. UpCloud sends `bus.ssh.script.run.request` events and waits
for correlated `bus.ssh.script.run.response` events.

To avoid startup-order coupling with the Events API, the worker supports the
shared integration listener retry environment: `BUS_EVENTS_LISTENER_RETRY`,
`BUS_EVENTS_LISTENER_RETRY_MIN`, `BUS_EVENTS_LISTENER_RETRY_MAX`,
`BUS_EVENTS_LISTENER_REQUIRED`, and `BUS_EVENTS_TOKEN_REFRESH`.

The worker also handles protected runner administration events:
`bus.containers.runner.status.request`,
`bus.containers.runner.start.request`, and
`bus.containers.runner.delete.request`. These operate on the configured runner
only and are intended for internal service cleanup/startup flows.

### Sources

- [bus-integration-upcloud README](../../../bus-integration-upcloud/README.md)
- [bus-integration-ssh-runner](./bus-integration-ssh-runner.md)
