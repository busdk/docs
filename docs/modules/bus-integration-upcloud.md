---
title: bus-integration-upcloud — UpCloud event integration
description: bus-integration-upcloud is the event-driven UpCloud worker for Bus VM and container workflows.
---

## `bus-integration-upcloud` — UpCloud event integration

`bus-integration-upcloud` is the event-driven worker for UpCloud-specific VM
and container operations. It listens for cloud-neutral Bus Events and emits
correlated result/status events.

Use this integration when a Bus deployment should control UpCloud VMs or a
configured UpCloud container runner through Bus Events. User-facing HTTP APIs
remain available through modules such as `bus-api-provider-vm` and
`bus-api-provider-containers`; this process is the UpCloud worker behind those
event flows.

The worker supports Bus Events API mode, a deterministic static provider for
local checks, and the real UpCloud HTTP API provider. It handles VM
status/start/stop and can create, start, or clean up the configured container
runner. Generic SSH transport is handled by
`bus-integration-ssh-runner` through Bus Events.

For local development, run the static provider against a Bus Events API:

```sh
bus-integration-upcloud --events-url "$BUS_EVENTS_API_URL"
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
  --vm-name "$UPCLOUD_VM_NAME" \
  --container-runner-name "$UPCLOUD_CONTAINER_RUNNER_NAME"
```

### Command Options

`--help` prints command help and exits.

`--self-test` runs a deterministic in-memory worker self-test and exits.

`--check-vm-status` prints one VM status response through the selected provider
and exits instead of opening the Events listener.

`--once` processes one event and exits.

`--events-url <url>` sets the Bus Events API base URL. It defaults to
`BUS_EVENTS_API_URL`.

`--provider <static|upcloud>` selects the backend. `static` is for local tests;
`upcloud` calls the UpCloud HTTP API.

`--upcloud-api-url <url>` sets the UpCloud API base URL. It defaults to
`UPCLOUD_API_BASE_URL` or the public UpCloud API.

`--vm-name <name-or-uuid>` selects the UpCloud VM used for VM runtime events.
It defaults to `UPCLOUD_VM_NAME`.

`--container-runner-name <name-or-uuid>` selects the UpCloud server used as the
container runner. It defaults to `UPCLOUD_CONTAINER_RUNNER_NAME`.

`--container-codex-image <image>` sets the container image used for
`profile=codex`. It defaults to `UPCLOUD_CONTAINER_CODEX_IMAGE` or Alpine.

`--container-zone <zone>` sets the UpCloud zone for runner creation. It
defaults to `UPCLOUD_CONTAINER_ZONE`.

`--container-plan <plan>` sets the UpCloud plan for runner creation. It
defaults to `UPCLOUD_CONTAINER_PLAN`.

`--container-os <template>` sets the UpCloud OS template for runner creation.
It defaults to `UPCLOUD_CONTAINER_OS`.

`--container-os-storage-size <gb>` sets the runner OS disk size. It defaults to
`UPCLOUD_CONTAINER_OS_STORAGE_SIZE`; zero leaves the provider default.

`--container-network-mode <private|public>` selects runner networking. It
defaults to `UPCLOUD_CONTAINER_NETWORK_MODE`.

`--container-private-network <name-or-uuid>` selects the private network for
private runner creation. It defaults to `UPCLOUD_CONTAINER_PRIVATE_NETWORK_NAME`.

`--container-private-ip <ipv4>` requests a specific private IPv4 address for
the runner. It defaults to `UPCLOUD_CONTAINER_PRIVATE_IP`.

`--container-ssh-keys <paths>` gives space-separated SSH public key files used
when creating a runner. It defaults to `UPCLOUD_CONTAINER_SSH_KEYS`.

`--container-ssh-target <user@host>` sets an explicit runner SSH target and
skips address discovery. It defaults to `UPCLOUD_CONTAINER_SSH_TARGET`.

`--container-ssh-users <users>` gives space-separated usernames to try during
target discovery. It defaults to `UPCLOUD_CONTAINER_USERNAME_CANDIDATES`.

`--container-run-network <mode>` sets the Podman network mode for disposable
runs. It defaults to `UPCLOUD_CONTAINER_RUN_NETWORK`.

`--container-run-tmpfs-size <size>` sets the tmpfs size for disposable
container work directories. It defaults to `UPCLOUD_CONTAINER_RUN_TMPFS_SIZE`.

`--container-run-read-only` runs containers with a read-only root filesystem.
It defaults to `UPCLOUD_CONTAINER_RUN_READ_ONLY` and is enabled by default.

`--container-run-user <user>` sets the optional user inside the disposable
container. It defaults to `UPCLOUD_CONTAINER_RUN_USER`.

`--container-run-workdir <path>` sets the disposable container working
directory. It defaults to `UPCLOUD_CONTAINER_RUN_WORKDIR`.

`--container-run-timeout <duration>` sets the maximum foreground container run
duration. It defaults to `UPCLOUD_CONTAINER_RUN_TIMEOUT`.

`--container-start-timeout <duration>` sets the maximum runner start/bootstrap
duration. It defaults to `UPCLOUD_CONTAINER_START_TIMEOUT`.

`--runner-dns-servers <ip,ip>` sets optional DNS servers for provider-driven
runner netplan bootstrap. It defaults to `BUS_RUNNER_DNS_SERVERS`.

`--runner-netplan-mode <mac-match>` sets the safe interface matching mode for
runner netplan bootstrap. It defaults to `BUS_RUNNER_NETPLAN_MODE`.

`--runner-apply-netplan` enables provider-driven netplan before package
installation. It defaults to `BUS_RUNNER_APPLY_NETPLAN`.

`--runner-delete-stop-first` stops the runner before delete when required by
provider state. It defaults to `BUS_RUNNER_DELETE_STOP_FIRST`.

`--runner-delete-ready-states <states>` sets comma-separated generic states
that are safe to delete. It defaults to `BUS_RUNNER_DELETE_READY_STATES`.

`--runner-transient-states <states>` sets comma-separated generic states that
are retried while deleting. It defaults to `BUS_RUNNER_TRANSIENT_STATES`.

`--runner-delete-timeout <duration>` sets the maximum runner delete lifecycle
wait. It defaults to `BUS_RUNNER_DELETE_TIMEOUT`.

`--runner-delete-poll-interval <duration>` sets the runner delete lifecycle
poll interval. It defaults to `BUS_RUNNER_DELETE_POLL_INTERVAL`.

`--runner-delete-storage` deletes runner storage with the runner. It defaults
to `BUS_RUNNER_DELETE_STORAGE`.

`--runner-ssh-ready-timeout <duration>` sets the maximum wait for provider
state and SSH TCP readiness. It defaults to `BUS_RUNNER_SSH_READY_TIMEOUT`.

`--runner-ssh-ready-poll-interval <duration>` sets the runner SSH readiness
poll interval. It defaults to `BUS_RUNNER_SSH_READY_POLL_INTERVAL`.

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

Before UpCloud publishes bootstrap or foreground container run events to the SSH
runner, it waits for the runner to reach a usable provider state and then polls
SSH TCP connectivity on the discovered or explicit target addresses. Configure
this bounded wait with `BUS_RUNNER_SSH_READY_TIMEOUT` and
`BUS_RUNNER_SSH_READY_POLL_INTERVAL`. Connection refused, timeout, and no-route
errors are treated as temporary until the configured timeout expires.

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
