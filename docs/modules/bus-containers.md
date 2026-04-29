---
title: bus-containers — AI Platform container runner client
description: bus containers starts, lists, checks, and deletes AI Platform container runs owned by the current account.
---

## `bus-containers` — AI Platform container runner client

`bus containers` is the domain client for public AI Platform container-runner
APIs. It owns the client library for container status and user-owned container
run lifecycle operations.

### Common tasks

```bash
bus containers status
bus containers run --profile codex -- sh -c 'printf OK'
bus containers runs
bus containers delete run_123
```

The token must be an AI Platform bearer JWT, usually obtained through
`bus-auth`. By default the CLI reads the normal Bus API token from
`~/.config/bus/auth/api-token` or `${BUS_CONFIG_DIR}/auth/api-token`.
`--token-file`, `BUS_AI_TOKEN`, and `BUS_API_TOKEN` override that default.
Literal token values are not accepted on the command line. The service must use
the JWT `sub` account UUID as the owner and must not trust a client-supplied
account ID.

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
