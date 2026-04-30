---
title: bus-integration-upcloud option reference
description: Complete command option reference for the UpCloud event integration worker.
---

## `bus-integration-upcloud` Option Reference

Flags take precedence over environment variables. Environment variables take
precedence over the hardcoded defaults listed below. Boolean environment values
accept `1`, `true`, `yes`, `on`, `0`, `false`, `no`, and `off`; invalid
boolean environment values fall back to the hardcoded default.

### `--help`

Optional. Prints help and exits. Default is off.

### `--self-test`

Optional. Runs an in-memory worker check and exits. Default is off. It does
not require Events API or UpCloud credentials.

### `--check-vm-status`

Optional. Prints one VM status response through the selected provider and
exits. Default is off. With `--provider upcloud`, `UPCLOUD_TOKEN` and a VM
name are required.

### `--once`

Optional. Processes one event and exits. Default is off. Use for diagnostics,
not long-running production workers.

### `--events-url <url>`

Required for event-listener mode. Defaults to `BUS_EVENTS_API_URL`. The value
must be the Bus Events API collection URL including `/api/v1/events`.

### `--provider <static|upcloud>`

Optional. Defaults to `BUS_UPCLOUD_PROVIDER` or `static`. Accepted values are
`static` and `upcloud`. Any other value fails with `unsupported provider`.

### `--upcloud-api-url <url>`

Optional. Defaults to `UPCLOUD_API_BASE_URL` or
`https://api.upcloud.com/1.3`. Use this only for a compatible UpCloud API
endpoint.

### `--vm-name <name-or-uuid>`

Required for UpCloud VM status/start/stop. Defaults to `UPCLOUD_VM_NAME`.
Accepts an UpCloud server name or UUID.

### `--container-runner-name <name-or-uuid>`

Required for UpCloud container workflows. Defaults to
`UPCLOUD_CONTAINER_RUNNER_NAME`. Accepts an UpCloud server name or UUID.

### `--container-codex-image <image>`

Optional. Defaults to `UPCLOUD_CONTAINER_CODEX_IMAGE` or
`docker.io/library/alpine:3.20`. Used when a run request selects
`profile=codex` without an explicit image.

### `--container-zone <zone>`

Optional. Defaults to `UPCLOUD_CONTAINER_ZONE` or `fi-hel2`. Used when creating
the runner.

### `--container-plan <plan>`

Optional. Defaults to `UPCLOUD_CONTAINER_PLAN` or `CLOUDNATIVE-1xCPU-4GB`.
Used when creating the runner.

### `--container-os <template>`

Optional. Defaults to `UPCLOUD_CONTAINER_OS` or
`Ubuntu Server 24.04 LTS (Noble Numbat)`. Used when creating the runner OS
disk.

### `--container-os-storage-size <gb>`

Optional. Defaults to `UPCLOUD_CONTAINER_OS_STORAGE_SIZE` or `0`. Units are
gigabytes. `0` leaves the provider default.

### `--container-network-mode <private|public>`

Optional. Defaults to `UPCLOUD_CONTAINER_NETWORK_MODE` or `private`. Accepted
values are `private` and `public`. Other values fail with `unsupported
container network mode`.

### `--container-private-network <name-or-uuid>`

Required when `--container-network-mode private` creates a runner. Defaults to
`UPCLOUD_CONTAINER_PRIVATE_NETWORK_NAME` or
`ai-platform-private-<container-zone>`. Accepts an UpCloud network name or
UUID.

### `--container-private-ip <ipv4>`

Optional. Defaults to `UPCLOUD_CONTAINER_PRIVATE_IP`. When set, requests that
private IPv4 address for the runner NIC.

### `--container-ssh-keys <paths>`

Required when creating a new runner. Defaults to `UPCLOUD_CONTAINER_SSH_KEYS`.
The value is a space-separated list of SSH public key file paths.

### `--container-ssh-target <user@host>`

Optional. Defaults to `UPCLOUD_CONTAINER_SSH_TARGET`. When set, skips address
discovery and probes the supplied SSH target.

### `--container-ssh-users <users>`

Optional. Defaults to `UPCLOUD_CONTAINER_USERNAME_CANDIDATES` or `root ubuntu`.
The value is a space-separated list of usernames tried during SSH target
discovery.

### `--container-run-network <mode>`

Optional. Defaults to `UPCLOUD_CONTAINER_RUN_NETWORK` or `slirp4netns`. Passed
to Podman for disposable container runs. Podman is the container runtime used
inside the runner.

### `--container-run-tmpfs-size <size>`

Optional. Defaults to `UPCLOUD_CONTAINER_RUN_TMPFS_SIZE` or `1g`. Passed to
Podman as the temporary work directory size.

### `--container-run-read-only`

Optional boolean flag. Defaults to `UPCLOUD_CONTAINER_RUN_READ_ONLY` or true.
When enabled, disposable containers get a read-only root filesystem and should
write temporary data only to configured writable mounts such as the workdir
tmpfs. Set `UPCLOUD_CONTAINER_RUN_READ_ONLY=0` only for images that require a
writable root filesystem.

### `--container-run-user <user>`

Optional. Defaults to `UPCLOUD_CONTAINER_RUN_USER`. When set, runs the
disposable container as that user.

### `--container-run-workdir <path>`

Optional. Defaults to `UPCLOUD_CONTAINER_RUN_WORKDIR` or `/workspace`. Passed
to Podman as the container working directory.

### `--container-run-timeout <duration>`

Optional. Defaults to `UPCLOUD_CONTAINER_RUN_TIMEOUT` or `30m`. Durations use
Go duration syntax such as `30s`, `5m`, or `1h`; integer environment values
are interpreted as seconds.

### `--container-start-timeout <duration>`

Optional. Defaults to `UPCLOUD_CONTAINER_START_TIMEOUT` or `10m`. This bounds
runner create/start/bootstrap. Durations use Go duration syntax; integer
environment values are seconds.

### `--runner-dns-servers <ip,ip>`

Optional. Defaults to `BUS_RUNNER_DNS_SERVERS`. Use a comma-separated list of
DNS server IP addresses. Empty disables DNS override.

### `--runner-netplan-mode <mac-match>`

Optional. Defaults to `BUS_RUNNER_NETPLAN_MODE` or `mac-match`. `mac-match`
matches the provider-discovered NIC MAC address. This is the only production
safe mode. `bus-integration-ssh-runner` rejects unsupported modes with
`unsupported runner netplan mode`. In `mac-match` mode, a missing discovered
MAC fails with `runner netplan mode mac-match requires interface MAC` instead
of guessing an interface.

### `--runner-apply-netplan`

Optional boolean flag. Defaults to `BUS_RUNNER_APPLY_NETPLAN` or false.
Enable only when runner bootstrap should render and apply netplan before
package installation.

### `--runner-delete-stop-first`

Optional boolean flag. Defaults to `BUS_RUNNER_DELETE_STOP_FIRST` or true.
When true, delete first stops the runner if it is not already in a
delete-ready state.

### `--runner-delete-ready-states <states>`

Optional. Defaults to `BUS_RUNNER_DELETE_READY_STATES` or `stopped`. Use
comma-separated generic lifecycle states. Production-safe value is `stopped`.
Other values are accepted as strings, but misspelled or provider-unmapped
states will not match and can make deletion wait until
`--runner-delete-timeout`.

### `--runner-transient-states <states>`

Optional. Defaults to `BUS_RUNNER_TRANSIENT_STATES` or `maintenance,pending`.
Use comma-separated generic lifecycle states that should be polled through.
Production-safe values include `maintenance` and `pending`. Other values are
accepted as strings, but misspelled or provider-unmapped states will not match
and may produce a faster delete failure instead of a retry.

### `--runner-delete-timeout <duration>`

Optional. Defaults to `BUS_RUNNER_DELETE_TIMEOUT` or `10m`. Durations use Go
duration syntax; integer environment values are seconds.

### `--runner-delete-poll-interval <duration>`

Optional. Defaults to `BUS_RUNNER_DELETE_POLL_INTERVAL` or `5s`. Durations use
Go duration syntax; integer environment values are seconds.

### `--runner-delete-storage`

Optional boolean flag. Defaults to `BUS_RUNNER_DELETE_STORAGE` or true. When
true, runner storage is deleted with the runner. This is destructive for the
runner disk. Set `BUS_RUNNER_DELETE_STORAGE=0` or omit this flag when the disk
must be preserved for inspection.

### `--runner-ssh-ready-timeout <duration>`

Optional. Defaults to `BUS_RUNNER_SSH_READY_TIMEOUT` or `10m`. This bounds the
provider-state and SSH TCP readiness wait. Durations use Go duration syntax;
integer environment values are seconds.

### `--runner-ssh-ready-poll-interval <duration>`

Optional. Defaults to `BUS_RUNNER_SSH_READY_POLL_INTERVAL` or `5s`. Durations
use Go duration syntax; integer environment values are seconds.

## Sources

- [bus-integration-upcloud runbook](./bus-integration-upcloud)
