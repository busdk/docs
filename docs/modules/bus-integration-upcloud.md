---
title: bus-integration-upcloud — UpCloud event integration
description: bus-integration-upcloud is the event-driven UpCloud worker for Bus VM and container workflows.
---

## Run The UpCloud Worker

Deploy and verify the worker that handles Bus VM and container events through
UpCloud. VM means virtual machine. The worker listens to Bus Events, operates
UpCloud resources, and publishes response events for cloud-neutral API
providers such as `bus-api-provider-vm` and `bus-api-provider-containers`.

Use this page as the production runbook. The full flag and environment
reference is in [bus-integration-upcloud option reference](./bus-integration-upcloud-reference.md).

### How It Works

The Bus Events API is the HTTP event service provided by
`bus-api-provider-events`. The UpCloud worker receives request events,
performs UpCloud API actions, and publishes correlated response events. A
correlated response event carries the same request identifier so the caller can
match the response to the original request.

A request/reply worker is a long-running process that listens for request
events and publishes matching response events. Account isolation means users
can see and control only resources owned by their own Bus account.

For container execution, UpCloud owns VM lifecycle only. SSH means Secure
Shell. `bus-integration-ssh-runner` owns SSH keys, known-hosts handling,
script execution, and foreground command output.

## Prerequisites

### Environment

Run the worker on a Linux host or container with a POSIX shell. The host must
reach the configured Bus Events API URL and `https://api.upcloud.com/1.3`.
When a container runner has only a private IP address,
`bus-integration-upcloud` must reach it for SSH readiness probes and
`bus-integration-ssh-runner` must reach it for SSH execution.

The examples use systemd for production service management. Other supervisors
are supported when they provide the same basics: inject secrets outside Git,
restart on failure, run from a stable working directory, and capture stderr
logs.

For systemd deployments, the operator needs root or `sudo` access to create
the selected `/etc/systemd/system/bus-integration-upcloud-*.service`, set environment-file
permissions, run `systemctl`, and read `journalctl`. For systemd, the default
environment-file ownership is `root:root` with mode `0600` because systemd
reads it before starting the service. For non-systemd supervisors, make the
file readable only by the supervisor or service user that reads it.
Privileged examples below assume a root shell. If you are not root, prefix
`systemctl`, service-file writes, and permission changes with `sudo`.

Required command-line tools are the Bus binaries listed below and `curl` for
HTTP readiness checks. On systemd hosts, the production procedure also uses
`systemctl`, `journalctl`, `install`, `ls`, `getent`, `groupadd`, `useradd`,
and `id`. If the service user and group are pre-created by packaging, skip the
user/group creation commands.

Systemd prerequisite checklist:

- `bus` user and group exist, or the operator can create them.
- `/var/lib/bus` is writable by the `bus` service user.
- `/usr/local/bin/bus-integration-upcloud` points to the matching release binary.
- `/etc/bus` is a root-owned configuration directory.
- The selected mode-specific environment file is `root:root` with mode `0600`.

### Version Pinning

Use one BusDK release set for these components:

- `bus-integration-upcloud`
- `bus-integration-ssh-runner`
- `bus-api-provider-events`
- `bus-api-provider-vm`
- `bus-api-provider-containers`
- `bus-vm`
- `bus-containers`

For release images or packages, use the same release tag for each service. For
source deployments, pin and deploy one exact superproject checkout. Do not mix
an older UpCloud worker with newer Events, VM, or container providers.

Install the matching release binaries, packages, or service images before
using this runbook. Installation method is deployment-specific; the
requirement here is that every BusDK component comes from the same release set.
Operators using release artifacts should start from the BusDK release or
package source used by their deployment, for example
[BusDK releases](https://github.com/busdk/busdk/releases), and install all
required BusDK binaries from the same release tag.

Verify command availability before deployment:

```sh
bus-integration-upcloud --help
bus-integration-ssh-runner --help
bus auth --help
bus operator --help
bus events listen --help
bus vm --help
bus containers --help
```

Success means each command prints help and exits successfully.

For an existing deployment, verify the deployed release tag with your package,
image, or service
metadata. A simple service-environment convention is to set the same
`BUSDK_RELEASE` value in each Bus service environment file:

```sh
grep '^BUSDK_RELEASE=' /etc/bus/*.env
```

Success means every printed value is the same release tag, for example
`BUSDK_RELEASE=v0.0.123`.

### URLs

Set `BUS_API_BASE_URL` to the public Bus API base URL used by `bus vm` and
`bus containers`, for example `https://example.test`.
`BUS_API_BASE_URL` is used by verification commands, not by
`bus-integration-upcloud`.

Set `BUS_EVENTS_API_URL` to the Bus Events API collection URL including
`/api/v1/events`, for example `https://example.test/api/v1/events`.
`BUS_EVENTS_API_URL` is consumed by `bus-integration-upcloud` through
`--events-url` or the matching environment default.
Avoid a trailing slash. `BUS_API_BASE_URL` and `BUS_EVENTS_API_URL` normally
share the same origin in production, but they may differ when the Events API is
served from a separate host. If a reverse proxy rewrites paths, configure
`BUS_EVENTS_API_URL` to the externally reachable post-rewrite collection path
that clients actually call.

### Startup Order And Preflight Service Checks

For a new shell session, set `BUS_API_BASE_URL` and `BUS_EVENTS_API_URL`
before the service checks:

```sh
export BUS_API_BASE_URL="https://example.test"
export BUS_EVENTS_API_URL="https://example.test/api/v1/events"
```

For cold deployment startup, start `bus-api-provider-events` before the
UpCloud worker. Start `bus-api-provider-vm` and
`bus-api-provider-containers` after the UpCloud worker so public API providers
do not become active before request/reply workers are available. If a process
supervisor starts public API providers earlier, their readiness may stay
unhealthy until the UpCloud worker connects.

For VM-only operation, use this order:

1. `bus-api-provider-events`
2. `bus-integration-upcloud`
3. `bus-api-provider-vm`

For container operation, use this order:

1. `bus-api-provider-events`
2. `bus-integration-ssh-runner`
3. `bus-integration-upcloud`
4. `bus-api-provider-containers`

Verify provider command availability:

```sh
bus-api-provider-events --help
bus-api-provider-vm --help
bus-api-provider-containers --help
```

Success means each provider command prints help and exits successfully. If a
command is missing, install the matching BusDK release binary before
continuing.

Verify the Events API is reachable before starting the worker:

```sh
bus events listen --api-url "$BUS_EVENTS_API_URL" --name bus.vm.status.response --no-follow
```

Success returns an empty replay or existing matching events without a
connection error. The event name is only a replay filter in this check; it
does not require a VM deployment. If VM or container API providers are already
started, verify their public API service is reachable:

```sh
curl -fsS "$BUS_API_BASE_URL/readyz"
```

Success means HTTP status 2xx. If the provider returns a non-2xx not-ready
response before the worker connects, that is acceptable only before startup;
connection refusal, DNS failure, or TLS failure must be fixed before
continuing.

Use service names matching the binary names when installing these as
long-running services. See
[bus-api-provider-events](./bus-api-provider-events.md),
[bus-api-provider-vm](./bus-api-provider-vm.md),
[bus-api-provider-containers](./bus-api-provider-containers.md), and
[bus-integration-ssh-runner](./bus-integration-ssh-runner.md) for the provider
commands and options.

### Tokens And Credentials

Do not commit `BUS_API_TOKEN`, `UPCLOUD_TOKEN`, SSH keys, or local environment
files. This repository is public; secrets must stay in operator-controlled
secret storage.

`BUS_API_TOKEN` is read directly by `bus-integration-upcloud` and used to
access the Bus Events API. `SERVICE_OR_USER_JWT` is only a local shell helper
used in examples before exporting `BUS_API_TOKEN`.

#### Required Production Token

For normal VM and end-user container events, `BUS_API_TOKEN` must contain a
Bus API JSON Web Token (JWT) with audience `ai.hg.fi/api`. The recommended
production default is the narrowest API token that matches the public API
events the worker processes.

Default production choice: use one service-issued, narrow-scoped
API-audience token per worker mode.

Use these public API token variants for `BUS_API_TOKEN`:

- VM-only worker: `ai.hg.fi/api` with `vm:read vm:write`.
- Container worker: `ai.hg.fi/api` with `container:read container:run container:delete`.

Plan token rotation before running this as a service. If `BUS_API_TOKEN`
expires, replace the secret in the environment file and restart the service.
Use a service-issued token for long-running workers when the deployment
supports it; use a user token only for operator-controlled short-lived runs.
The operator command requires an active operator/admin account or service
context that is allowed to issue API-audience service tokens.

Create a VM-only service-issued API token through operator tooling:

```sh
bus operator token --format token issue \
  --subject bus-integration-upcloud \
  --audience ai.hg.fi/api \
  --scope 'vm:read vm:write'
```

Create a container-only service-issued API token through operator tooling:

```sh
bus operator token --format token issue \
  --subject bus-integration-upcloud \
  --audience ai.hg.fi/api \
  --scope 'container:read container:run container:delete'
```

Success prints only the token string on stdout. A permission failure means the
operator account or service context cannot issue tokens for the requested
audience or scopes.

#### Smoke-Test User Tokens

Use the `bus auth token` examples in this subsection only for smoke tests or
operator-controlled short-lived runs. They are not the recommended production
service-token path.

Before creating end-user API tokens, complete the normal `bus auth` login and
one-time password verification flow and confirm the user is approved:

```sh
bus auth login --email user@example.com
bus auth verify --email user@example.com --otp '<one-time-password-from-login-flow>'
bus auth status
```

See [bus-auth](./bus-auth.md) for the full registration and approval flow.

Create an approved user API token for VM-only smoke tests:

```sh
bus auth token --scope 'vm:read vm:write'
```

Create an approved user API token for container-only smoke tests:

```sh
bus auth token --scope 'container:read container:run container:delete'
```

#### UpCloud Token

`UPCLOUD_TOKEN` must come from a deployment secret, local secret store, or
untracked environment file.

Use the least-privilege UpCloud credential boundary supported by the
deployment. VM-only workers need access to the configured VM. Container
workers need access to runner server, network, and storage operations.
Destructive delete permissions are required only for runner cleanup modes. Use
the current [UpCloud API documentation](https://developers.upcloud.com/1.3/)
and account documentation for provider-side role names.

Verify VM credentials with the VM-only one-shot diagnostic before enabling a VM
worker:

```sh
bus-integration-upcloud --provider upcloud --check-vm-status --vm-name "$UPCLOUD_VM_NAME"
```

Success prints one JSON VM status response.

For container-only deployments with an existing runner, verify that the token
can read the runner as an UpCloud server:

```sh
bus-integration-upcloud --provider upcloud --check-vm-status --vm-name "$UPCLOUD_CONTAINER_RUNNER_NAME"
```

Success prints one JSON server status response. If the runner is created on
demand and does not exist yet, the first disposable container run is the
credential preflight for create, network attach, storage, and cleanup actions.

### Optional Diagnostic Tools

Troubleshooting examples use `journalctl` on systemd hosts, `curl` for HTTP
checks, `nc` for TCP connectivity probes, and `ssh` for optional manual SSH
checks. TCP means
Transmission Control Protocol. Run TCP and SSH probes from the same network
location as the UpCloud worker.

## Deploy The Worker With Systemd

Recommended default path: deploy one systemd service per worker mode. Use a
VM-only service for VM lifecycle events, a container service for container
runner events, and a separate protected administration service only when the
deployment needs internal runner administration. Protected administration is
out of scope for this public VM/container runbook; it applies only to internal
runner operations such as protected runner start/delete with `container:admin`.
Use the [option reference](./bus-integration-upcloud-reference.md) before
deploying that separate mode. Use foreground commands only as smoke tests or
as the command body for a non-systemd supervisor.

Choose one mode before copying commands:

- VM-only: use `bus-integration-upcloud-vm.service` and `/etc/bus/bus-integration-upcloud-vm.env`.
- Container-only: use `bus-integration-upcloud-containers.service` and `/etc/bus/bus-integration-upcloud-containers.env`.

For the shell commands below, run exactly one of these snippets.

VM-only:

```sh
SELECTED_SERVICE=bus-integration-upcloud-vm
SELECTED_ENV_FILE=bus-integration-upcloud-vm.env
```

Container-only:

```sh
SELECTED_SERVICE=bus-integration-upcloud-containers
SELECTED_ENV_FILE=bus-integration-upcloud-containers.env
```

### Before You Start

`SERVICE_OR_USER_JWT` is the local shell variable used below before exporting
`BUS_API_TOKEN`. In production, set it from a service-issued token or secret
manager, not from the smoke-test `bus auth token` examples.

Final gate before running the worker:

- Required services and preflight checks above have passed.
- `SERVICE_OR_USER_JWT` is created or injected with the required audience and scopes.
- `UPCLOUD_TOKEN` is injected from a secret manager or untracked environment file.
- Target VM or runner names are set in the selected `ExecStart=` command.

For VM-only production operation, inject a VM service token:

```sh
SERVICE_OR_USER_JWT="$(bus operator token --format token issue --subject bus-integration-upcloud --audience ai.hg.fi/api --scope 'vm:read vm:write')"
```

For container production operation, inject a container service token:

```sh
SERVICE_OR_USER_JWT="$(bus operator token --format token issue --subject bus-integration-upcloud --audience ai.hg.fi/api --scope 'container:read container:run container:delete')"
```

Validate the token before writing it to the service environment:

```sh
BUS_API_TOKEN="$SERVICE_OR_USER_JWT" bus events listen --api-url "$BUS_EVENTS_API_URL" --name bus.readiness.probe --no-follow
```

Success means the Events API accepts the token. Then write the same token value
as `BUS_API_TOKEN` in the selected mode-specific environment file, for example
`/etc/bus/bus-integration-upcloud-vm.env` or
`/etc/bus/bus-integration-upcloud-containers.env`. The startup shell must fail
closed when either token variable is missing.

### Configure Environment

Choose either shell exports or a service-manager environment file. Do not copy
shell `export` syntax into a systemd `EnvironmentFile`; systemd files must
contain direct `KEY=value` lines as shown below.

For VM-only deployments:

```sh
: "${SERVICE_OR_USER_JWT:?set from service-issued token or secret manager; use bus auth token only for smoke tests}"
: "${UPCLOUD_TOKEN:?set from an operator-controlled secret manager}"
export BUS_API_TOKEN="$SERVICE_OR_USER_JWT"
export BUS_API_BASE_URL="https://example.test"
export BUS_EVENTS_API_URL="https://example.test/api/v1/events"
export UPCLOUD_TOKEN
export UPCLOUD_VM_NAME="ai-platform-gpu"
```

For container deployments:

```sh
: "${SERVICE_OR_USER_JWT:?set from service-issued token or secret manager; use bus auth token only for smoke tests}"
: "${UPCLOUD_TOKEN:?set from an operator-controlled secret manager}"
export BUS_API_TOKEN="$SERVICE_OR_USER_JWT"
export BUS_API_BASE_URL="https://example.test"
export BUS_EVENTS_API_URL="https://example.test/api/v1/events"
export UPCLOUD_TOKEN
export UPCLOUD_CONTAINER_RUNNER_NAME="ai-platform-container-runner"
export UPCLOUD_CONTAINER_PRIVATE_NETWORK_NAME="ai-platform-private-fi-hel2"
export UPCLOUD_CONTAINER_SSH_KEYS="/var/lib/bus/.ssh/bus_runner.pub"
```

Success means the shell exits before starting the worker if required secrets
are missing.

### Production Systemd Service

Recommended production default: run the worker under systemd or another
service supervisor. The service should stay running and subscribed to Bus
Events. There is no startup success banner; the first successful VM or
container API check is authoritative.

For systemd deployments, save one of the following unit bodies to the selected
service path, such as `/etc/systemd/system/bus-integration-upcloud-vm.service`
or `/etc/systemd/system/bus-integration-upcloud-containers.service`, and adjust
paths for the target host. The examples are mutually exclusive unless you
intentionally deploy separate VM and container services.
Before starting the service, replace the literal `ExecStart=` URL, VM name,
runner name, and binary path with values for this deployment.

Follow these systemd steps in order.

Step 1: create the service user and working directory if they do not already
exist:

```sh
getent group bus >/dev/null || groupadd --system bus
id bus >/dev/null 2>&1 || useradd --system --gid bus --home-dir /var/lib/bus --shell /usr/sbin/nologin bus
install -d -m 0750 -o bus -g bus /var/lib/bus
```

For container deployments, install the SSH public key used when creating the
runner. In the command below, `./bus_runner.pub` is the public key from the SSH
key pair already configured for `bus-integration-ssh-runner`; the matching
private key must be available to the SSH runner before container execution can
succeed:

```sh
install -d -m 0700 -o bus -g bus /var/lib/bus/.ssh
install -m 0644 -o bus -g bus ./bus_runner.pub /var/lib/bus/.ssh/bus_runner.pub
```

Step 2: install the release binary at the path used by the unit. In the command below,
`./bus-integration-upcloud` means the worker binary extracted from the matching
BusDK release archive in the current directory. If a package or container
image already installed the binary, skip this command and keep `ExecStart=`
aligned with the installed path:

```sh
install -m 0755 ./bus-integration-upcloud /usr/local/bin/bus-integration-upcloud
test -x /usr/local/bin/bus-integration-upcloud
```

Do not create or start the systemd unit until this check succeeds.

Step 3: create the environment file path. Replace the filename with the
mode-specific name selected above when running separate services.

```sh
install -d -m 0750 -o root -g bus /etc/bus
install -m 0600 -o root -g root /dev/null "/etc/bus/$SELECTED_ENV_FILE"
```

Step 4: write the unit content to
the selected service file.

```sh
${EDITOR:-vi} "/etc/systemd/system/$SELECTED_SERVICE.service"
```

Choose exactly one unit body.

For container deployments:

Before saving this unit, replace `https://example.test/api/v1/events` and
`ai-platform-container-runner` with this deployment's Events API URL and runner
name. Keep `EnvironmentFile=` aligned with the selected container environment
file.

```ini
[Unit]
Description=Bus UpCloud integration worker
After=network-online.target bus-api-provider-events.service bus-integration-ssh-runner.service
Wants=network-online.target

[Service]
User=bus
WorkingDirectory=/var/lib/bus
EnvironmentFile=/etc/bus/bus-integration-upcloud-containers.env
ExecStart=/usr/local/bin/bus-integration-upcloud --provider upcloud --events-url https://example.test/api/v1/events --container-runner-name ai-platform-container-runner
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

For VM-only deployments:

Before saving this unit, replace `https://example.test/api/v1/events` and
`ai-platform-gpu` with this deployment's Events API URL and VM name. Keep
`EnvironmentFile=` aligned with the selected VM environment file.

```ini
[Unit]
Description=Bus UpCloud integration worker
After=network-online.target bus-api-provider-events.service
Wants=network-online.target

[Service]
User=bus
WorkingDirectory=/var/lib/bus
EnvironmentFile=/etc/bus/bus-integration-upcloud-vm.env
ExecStart=/usr/local/bin/bus-integration-upcloud --provider upcloud --events-url https://example.test/api/v1/events --vm-name ai-platform-gpu
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

These units use literal `ExecStart=` values to avoid relying on systemd
environment expansion in command arguments. If your configuration manager
generates units, generate these literal values from the same source as the
environment file.

Systemd reads `EnvironmentFile=` as the service manager before starting the
process, so `root:root` with mode `0600` is expected for systemd. Non-systemd
supervisors may need the file readable by the service user instead. It must
contain `BUS_API_TOKEN` directly:

For VM-only service files:

```dotenv
BUSDK_RELEASE=v0.0.123
BUS_API_TOKEN=<api-audience-jwt-with-vm-scopes>
UPCLOUD_TOKEN=<upcloud-token-from-secret-manager>
```

For container service files:

```dotenv
BUSDK_RELEASE=v0.0.123
BUS_API_TOKEN=<api-audience-jwt-with-container-scopes>
UPCLOUD_TOKEN=<upcloud-token-from-secret-manager>
UPCLOUD_CONTAINER_PRIVATE_NETWORK_NAME=ai-platform-private-fi-hel2
UPCLOUD_CONTAINER_SSH_KEYS=/var/lib/bus/.ssh/bus_runner.pub
```

Do not copy placeholder values such as `<api-audience-jwt-with-vm-scopes>` or
`<upcloud-token-from-secret-manager>` literally. Replace them with real values
from the deployment secret manager. Write exactly one of the shown `KEY=value`
blocks, with real secret values, into
the selected environment file before checking permissions or starting the
service.

```sh
${EDITOR:-vi} "/etc/bus/$SELECTED_ENV_FILE"
```

Verify the final permissions:

```sh
ls -l "/etc/bus/$SELECTED_ENV_FILE"
```

Expected result: the file is owned by `root:root` and has mode `0600`.

For non-systemd deployments, configure the equivalent restart, logging,
working-directory, and secret-injection behavior in the local supervisor. The
supervisor must provide an equivalent log source to `journalctl`, such as
container logs, a process-manager log file, or centralized service logs.

Reload systemd and start the service:

```sh
systemctl daemon-reload
systemctl start "$SELECTED_SERVICE"
systemctl status "$SELECTED_SERVICE" --no-pager
```

Success means `systemctl status` reports `Active: active (running)` for
the selected service. Enable it for boot only after the manual start succeeds:

```sh
systemctl enable "$SELECTED_SERVICE"
```

View logs after starting the service with
`journalctl -u "$SELECTED_SERVICE"`.

### First Verification

Check the worker log immediately after startup:

```sh
journalctl -u "$SELECTED_SERVICE" -n 50 --no-pager
```

Success means the log has no repeated Events API connection errors,
authentication errors, UpCloud credential errors, or
`ssh response listener` errors after startup. The worker currently has no
dedicated success banner; the reliable proof is the first successful VM or
container request. Run the mode-specific success check immediately after this
log check: [VM-Only Deployment](#vm-only-deployment) or
[Container-Only Deployment](#container-only-deployment).

You can also check Events API reachability from the same host:

```sh
bus events listen --api-url "$BUS_EVENTS_API_URL" --name bus.vm.status.response --no-follow
```

Success returns an empty replay or existing matching events without a
connection error. The event name is only a replay filter in this check; it
does not require a VM deployment.

After the VM or container API provider starts, verify its HTTP readiness
endpoint is reachable:

```sh
curl -fsS "$BUS_API_BASE_URL/readyz"
```

Success means HTTP status 2xx. After the worker starts, a non-2xx readiness
response means the API service is still not ready. Connection refusal, DNS
failure, or TLS failure means the API service or reverse proxy is not ready.

## Troubleshooting

### Mismatched BusDK Release Set

Symptom: providers and integrations start, but events time out or response
shapes do not match.

Check the installed release tags, image tags, package versions, or pinned
source commits for every required component listed in
[Version Pinning](#version-pinning).

Expected result: all required BusDK components come from one release set.

Corrective action: redeploy the mismatched component from the same release tag
or source checkout as the rest of the Bus deployment.

### Expired Or Invalid Token

Symptom: the Events API returns 401.

Check:

```sh
bus events listen --api-url "$BUS_EVENTS_API_URL" --name bus.vm.status.response --no-follow
```

Expected result: the command connects without an authentication error.

Corrective action: issue or inject a new token with the correct audience and
scopes. Use `ai.hg.fi/api` for user-visible VM/container events and
`ai.hg.fi/internal` only for protected runner administration.

### Missing Scope

Symptom: VM, container, runner, or SSH events are denied with 403 or an
authorization error.

Check the token scopes against the requested operation:

- VM status requires `vm:read`.
- VM start or stop requires `vm:write`.
- Container status requires `container:read`.
- Container runs require `container:run`.
- Owned container deletion requires `container:delete`.
- Protected runner administration requires `container:admin`.
- SSH runner script execution requires `ssh:run` on the SSH runner side.

Corrective action: request the narrowest token containing the missing scope.

### Events API Unreachable

Symptom: listener startup or `bus events listen` fails with connection errors.

Check:

```sh
bus events listen --api-url "$BUS_EVENTS_API_URL" --name bus.vm.status.response --no-follow
```

Expected result: the command returns an empty replay or matching events without
a connection error.

Corrective action: verify `BUS_EVENTS_API_URL`, TLS termination, firewall
rules, and that `bus-api-provider-events` is running. TLS means Transport
Layer Security, the security layer used by HTTPS.

### UpCloud Maintenance Timeout

Symptom: VM or runner startup waits until timeout while UpCloud reports a
transient state.

Check:

```sh
bus-integration-upcloud \
  --provider upcloud \
  --check-vm-status \
  --vm-name "$UPCLOUD_VM_NAME"
```

Expected result: the command prints the current VM state.

Corrective action: if the cloud operation is expected to take longer, increase
the relevant timeout. Otherwise inspect the UpCloud server state and resolve
the provider-side maintenance or pending operation.

### SSH Readiness Timeout

Symptom: container runs fail while waiting for SSH readiness.

Define these placeholders before manual probes:

- `RUNNER_HOST` is the runner IP address or host discovered from UpCloud.
- `RUNNER_USER` is one of the configured SSH username candidates, commonly
  `root` or `ubuntu`.

Check TCP port 22 from the same network location as the worker:

```sh
nc -vz "$RUNNER_HOST" 22
```

Expected result: TCP connects successfully.

If direct SSH is allowed for the operator, check SSH with the same key material
used by `bus-integration-ssh-runner`:

```sh
ssh "$RUNNER_USER@$RUNNER_HOST" true
```

Corrective action: verify private-network routing, firewall rules,
`UPCLOUD_CONTAINER_SSH_TARGET`, SSH username candidates, and that the SSH
runner has the private key matching the public key used to create the runner.

### Runner Delete Timeout

Symptom: protected runner delete waits until timeout.

Check the runner state with the container provider or UpCloud status tools.
Then compare the state with the configured delete-ready and transient states in
the option reference.

Expected result: the runner reaches a delete-ready state, normally `stopped`,
or a configured transient state that the worker can poll through.

Corrective action: enable stop-before-delete when the provider requires a stop
first, adjust timeout only when the cloud operation is legitimately slow, and
disable storage deletion only when the disk must be preserved for inspection.

## Success Check

### VM-Only Deployment

Verify only the VM provider path:

```sh
bus vm --api-url "$BUS_API_BASE_URL" status --format json
```

Success returns JSON containing the configured UpCloud VM state. For this
worker path, the response must include a string state field and identify the
provider or runtime as UpCloud. If the JSON only contains an `error` field,
treat it as a failed verification. If it fails with 401 or 403, use the token
and scope troubleshooting sections. If it times out, check Events API
reachability and UpCloud maintenance state.

Minimal valid shape:

```json
{"status":{"state":"ready","provider":"upcloud"}}
```

### Container-Only Deployment

Verify container status. This is a readiness check for account isolation and
provider request/reply wiring; it does not prove runner creation, SSH dispatch,
or cleanup:

```sh
bus containers --api-url "$BUS_API_BASE_URL" status --format json
```

Success returns account-scoped JSON for the requesting account only. For this
worker path, the response must include a container status collection or a
runner/runtime status object, and it must not include runs owned by another
account. If the JSON only contains an `error` field, treat it as a failed
verification. If it fails with 401 or 403, check token audience and
`container:read`. If it times out, verify Events API reachability and that the
UpCloud worker is running.

Minimal valid shape:

```json
{"items":[]}
```

Optional billable smoke test:

This command may create or start UpCloud runner resources and can incur cloud
cost. Expected cleanup behavior is that disposable workload state is removed
after the run, while runner VM/storage cleanup follows the configured runner
delete policy.

The `codex` container profile must already be configured in the container API
provider or deployment profile catalog. Use a profile that exists in your
deployment if the name differs. Profiles are configured in the container API
provider deployment; see
[bus-api-provider-containers](./bus-api-provider-containers.md).

Run it only when you intentionally want to verify real container execution:

```sh
bus containers --api-url "$BUS_API_BASE_URL" run --profile codex -- sh -c 'printf BUS_CONTAINER_OK'
```

Success returns a completed run response whose stdout contains
`BUS_CONTAINER_OK`. The Events API should show a correlated SSH script request
and response during the run. If the run fails before the runner starts, check
container scopes and runner configuration. If it fails while waiting for SSH,
use the SSH readiness troubleshooting path. If cleanup fails, use the runner
delete troubleshooting path.
