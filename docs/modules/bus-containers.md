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

```bash
bus containers status
bus containers run --profile codex -- sh -c 'printf OK'
bus containers runs
bus containers delete run_123
```

The token must be an AI Platform bearer JWT, usually obtained through
`bus auth`. By default the CLI reads the normal Bus API token from
`~/.config/bus/auth/api-token` or `${BUS_CONFIG_DIR}/auth/api-token`.
`--token-file`, `BUS_AI_TOKEN`, and `BUS_API_TOKEN` override that default.
Literal token values are not accepted on the command line. The service must use
the JWT `sub` account UUID as the owner and must not trust a client-supplied
account ID.

Request a token with the container scopes enabled for your account:

```sh
bus auth token --scope "container:read container:run container:delete billing:read"
```

If billing is required and missing, or if a quota is exhausted, the server
returns setup or upgrade guidance before starting the container work.

### Options

`--help` and `--version` print command help or version information.

`--api-url <url>` selects the containers API base URL. `--token-file <path>`
reads the bearer token from a file. `--timeout <duration>` sets the HTTP
timeout.

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

### Sources

- [bus-api-provider-containers](./bus-api-provider-containers)
- [bus-billing](./bus-billing)
