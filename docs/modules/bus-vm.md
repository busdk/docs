---
title: bus-vm — AI Platform VM status client
description: bus vm reads the AI Platform VM/runtime lifecycle status with a Bus auth token.
---

## `bus-vm` — AI Platform VM status client

`bus vm` is the domain client for the AI Platform VM/runtime API. It owns the
client library for `GET /api/v1/vm/status`. Use it when you need the GPU
runtime lifecycle state directly.

### Common task

Authenticate first with `bus auth`. The auth-service session must be verified
and approved before the API token request can succeed; confirm that with
`bus auth status`, then request a token that includes the VM status scope
enabled for your account:

```sh
export BUS_AUTH_API_URL=https://api.example.test/api/v1/auth
bus auth login --email user@example.com
bus auth verify --email user@example.com --otp <otp-from-email>
bus auth status
bus auth token --scope "vm:read"
```

`bus auth token` saves the API token in the default Bus auth token file used by
`bus vm`. Point `bus vm` at the matching AI Platform API origin:

```bash
bus vm --api-url https://api.example.test status
```

The token must be an AI Platform bearer JWT, usually obtained through
`bus auth`. By default the CLI reads the normal Bus API token from
`~/.config/bus/auth/api-token` or `${BUS_CONFIG_DIR}/auth/api-token`.
`--token-file`, `BUS_AI_TOKEN`, and `BUS_API_TOKEN` override that default.
Literal token values are not accepted on the command line. The token subject is
the account UUID used by the AI Platform.

### API ownership

`bus-vm` owns the VM API client. `bus-status` may show VM state as part of an
aggregate status view, but it should call the `bus-vm` Go library instead of
owning this HTTP endpoint.

### Options

Use `--api-url` to target another AI Platform deployment. Use `--token-file`,
`BUS_AI_TOKEN`, `BUS_API_TOKEN`, or the default `bus auth` session for bearer
tokens. Literal token values are not accepted on the command line. Use
`--format json`, `--format text`, or `--format tsv` to select output.

`--help` and `--version` print command help or version information.
`--chdir <dir>`, `--output <file>`, `--quiet`, `--color <auto|always|never>`,
`--no-color`, and `--timeout <duration>` provide common Bus CLI
working-directory, output, color, and HTTP timeout controls.

### Examples

```bash
bus vm status --format text
bus vm --api-url https://ai.hg.fi --token-file /run/secrets/bus-api-token status
```

A successful status call exits 0 and prints the current runtime state in the
selected format. Text output includes whether the runtime is ready, starting,
stopped, or unavailable according to the provider response.

### Local Compose

The BusDK superproject `compose.yaml` exposes the local VM status API through
nginx at `http://127.0.0.1:${LOCAL_AI_PLATFORM_PORT:-8080}/api/v1/vm/status`.
The stack uses the static VM provider, so this local command should report
provider `static` without starting a real runtime:

```sh
cd /path/to/busdk
docker compose up --build -d
export BUS_API_TOKEN="$(docker compose exec -T testing-agent cat /root/.config/bus/auth/api-token)"
bus vm --api-url "http://127.0.0.1:${LOCAL_AI_PLATFORM_PORT:-8080}" status
```
