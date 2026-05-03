---
title: bus-containers — AI Platform container runner client
description: bus containers starts, lists, checks, and deletes AI Platform container runs owned by the current account.
---

## `bus-containers` — AI Platform container runner client

`bus containers` is the domain client for public AI Platform container-runner
APIs. It owns the client library for container status and user-owned container
run lifecycle operations.

Use it when an approved Bus account has access to non-persistent container
workloads. Container runs are owned by the account in the bearer token. They
are suitable for isolated jobs and hosted Codex-style workloads where usage is
metered and limited by the account plan.

### Common tasks

Before running container commands, authenticate with `bus auth` and request a
token that includes the container scopes enabled for your account:

```sh
bus auth token --scope "container:read container:run container:delete billing:read"
```

The token must be an AI Platform bearer JWT. By default, `bus auth token` saves
the normal Bus API token to `~/.config/bus/auth/api-token` or
`${BUS_CONFIG_DIR}/auth/api-token`, and `bus containers` reads that file
automatically. Use `--token-file`, `BUS_AI_TOKEN`, or `BUS_API_TOKEN` only when
automation needs an explicit override. Literal token values are not accepted on
the command line. The service must use the JWT `sub` account UUID as the owner
and must not trust a client-supplied account ID.

```bash
bus containers status
bus containers run --profile codex -- sh -c 'printf OK'
bus containers runs
bus containers delete run_123
```

`status` should show the runner state returned by the API, such as a ready or
starting status. `run` should return a run identifier and final command output
or a structured run result owned by the current account. `runs` should include
that run until retention or deletion removes it. Replace `run_123` with the run
identifier returned by `bus containers run`; deletion should return success
only for a run owned by the account in the bearer token. Another account's run
must return an authorization or not-found response.

If billing is required and missing, or if a quota is exhausted, the server
returns setup or upgrade guidance before starting the container work.

### Options

`--help` and `--version` print command help or version information.

`--api-url <url>` selects the deployment API origin, not the
`/api/v1/containers` path itself; the CLI appends container endpoint paths. By
default the CLI uses the configured Bus AI/API base URL, typically
`BUS_AI_API_URL` or `BUS_API_BASE_URL`, and otherwise the deployment default.
Override it for local compose with
`--api-url "http://127.0.0.1:${LOCAL_AI_PLATFORM_PORT:-8080}"`.
`--token-file <path>` reads the bearer token from a file. `--timeout
<duration>` sets the HTTP timeout as a Go duration such as `30s`, `2m`, or
`120s`; use a value longer than the expected container run duration for
foreground runs.

`--chdir <dir>`, `--output <file>`, `--format <json|text|tsv>`, `--quiet`,
`--color <auto|always|never>`, and `--no-color` provide the common Bus CLI
output and working-directory controls.

`run --profile <name>` selects a run profile. `run --timeout-seconds <n>` sets
the per-run timeout sent to the API. `--` ends Bus option parsing before the
container command.

### API ownership

`bus-containers` owns the client/library for `/api/v1/containers/status` and
`/api/v1/containers/runs*`. `bus-status` may show container runner status as
part of an aggregate view, but it should call the `bus-containers` Go library.

### User-owned delete

End-user deletion is per run:

```text
DELETE /api/v1/containers/runs/{run_id}
```

This is separate from internal infrastructure cleanup endpoints such as runner
administration. A normal user must be able to delete only runs owned by the
account in the bearer token.

### Billing And Quotas

Container run creation can be protected by billing entitlement checks. Accepted
container runs are recorded as usage. Successful runs can be counted as
`bus_container_runtime_seconds`, allowing plans to define minute, hour, day,
week, month, or total runtime limits.

The CLI does not make billing decisions locally. It displays the API error and
guidance returned by the server, such as `bus billing setup` or an upgrade
recommendation.

### Local Compose

The BusDK superproject `compose.yaml` exposes the local containers API through
nginx at `http://127.0.0.1:${LOCAL_AI_PLATFORM_PORT:-8080}/api/v1/containers`.
Inside the stack's `testing-agent` container, `bus containers run --profile
codex -- sh -lc 'printf OK'` uses the local API token written by
`bus-operator-token` and executes through the Events router and Docker worker.

Start the stack from the superproject root, then run the check inside
`testing-agent`:

```sh
docker compose up --build -d
docker compose exec -T testing-agent sh -lc \
  'cd /workspace/bus-containers && go run ./cmd/bus-containers run --profile codex -- sh -lc "printf OK"'
```

For developer-task Docker checks, `compose.dev-task-docker.yaml` builds the
local Codex image and runs `bus containers run --profile codex -- codex
--version` from `/workspace/bus-containers`:

```sh
docker compose -f compose.dev-task-docker.yaml up --build -d
docker compose -f compose.dev-task-docker.yaml exec -T testing-agent sh -lc \
  'cd /workspace/bus-containers && go run ./cmd/bus-containers run --profile codex -- codex --version'
```

A successful run returns JSON with exit code `0` and Codex CLI version output
in stdout.

### Using from `.bus` files

Inside a `.bus` file, write the module target without the `bus` prefix:

```bus
# same as: bus containers run --profile codex -- sh -lc 'printf OK'
containers run --profile codex -- sh -lc 'printf OK'
```

### Sources

- [bus-api-provider-containers](./bus-api-provider-containers)
- [bus-billing](./bus-billing)
