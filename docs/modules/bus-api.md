---
title: bus-api
description: Bus API provides a local REST JSON API over the BusDK workspace in the selected root.
---

## `bus-api` — local REST JSON API gateway for BusDK workspaces

### Synopsis

`bus api [global flags] [serve | openapi | version]`  
`bus-api [global flags] [serve | openapi | version]`

With no subcommand, `bus api` runs **serve**. Global flags follow [CLI command naming](../cli/command-naming) and the [standard global flags](../cli/global-flags); the workspace root is set with `-C` / `--chdir` and is used as the API’s working context.

Serve (default):

`bus-api serve [--listen <addr>] [--port <n>] [--token <string>] [--token-bytes <n>] [--base-path <path>] [--cors-origin <origin>] ... [--tls-cert <file>] [--tls-key <file>] [--read-only] [--provider <id> ...] [--enable-module <name> ...] [--route-config <file>] [global flags]`

`bus-api openapi` — Print the OpenAPI document (JSON) to stdout.  
`bus-api version` — Print the tool name and version to stdout and exit 0.

### Description

Command names follow [CLI command naming](../cli/command-naming).

Bus API provides a local REST JSON API over the selected BusDK workspace root.
On startup, it serves CRUD/validation endpoints over datasets by delegating semantics to [bus-data](./bus-data), and it can dispatch configured HTTP routes to provider events through `bus-events`.

No module CLI is executed; server calls Go libraries directly.
Default bind is localhost and server prints a capability URL with random token path.
Requests outside token prefix return `404`.

`--read-only` can restrict mutating endpoints.
`--provider` controls explicit built-in provider allowlisting for module endpoints.
`--route-config` configures HTTP method/path dispatch to request/reply events and provider capability declarations.
`--enable-module` can expose module adapter endpoints under `/{token}/v1/modules/{module}/...` when matching providers are allowlisted.
For built-in adapters, module resource ownership is explicit and library-based for all built-ins. Data-owning modules resolve paths through their Go path APIs (including reports through `bus-reports/path`); modules without owned datasets return empty module resource lists.
For complete API contract and security model, see [Module reference: bus-api](../modules/bus-api).

### Commands

**`serve`** (default) — Start the HTTP server. The effective workspace root is the current directory or the directory given by `-C` / `--chdir`. The server generates an unguessable token (unless you pass `--token`), binds to the address and port given by `--listen` and `--port`, and prints the capability base URL to **stdout**. All diagnostics and logs go to **stderr**. You must use the printed URL (including the token path segment) for every API request; there is no separate login or session. The server does not mutate workspace data until a mutating endpoint is called. If the workspace root is not readable, startup fails with a deterministic diagnostic and a non-zero exit code.

**`openapi`** — Emit the OpenAPI 3.1 document (JSON) to stdout. The document describes the versioned API paths and models the token path prefix so clients can generate bindings. No server is started. Diagnostics go to stderr.

**`version`** — Print the tool name and version to stdout and exit 0. Other flags and arguments are ignored when version is requested.

### Serve flags

Serve-specific flags are `--listen <addr>` (default `127.0.0.1`), `--port <n>` (default `0`, auto-choose), `--token <string>`, `--token-bytes <n>`, `--base-path <path>` (default `/{token}/v1`), repeatable `--cors-origin <origin>`, `--tls-cert <file>` with `--tls-key <file>` for HTTPS, `--read-only` to block mutating endpoints, repeatable `--provider <id>` for explicit built-in provider allowlisting, repeatable `--enable-module <name>` (`all` for allowlisted built-ins), and `--route-config <file>` for HTTP-to-event mapping plus provider capabilities.

### Global flags

Standard global flags are supported; see [Standard global flags](../cli/global-flags).
`--quiet` and `--verbose` are mutually exclusive.
Command results go to stdout (or `--output`), diagnostics/logs to stderr.

### Using the API

After starting `bus api serve`, use printed capability URL as base for all requests.
If base is `http://127.0.0.1:38472/abc123def/v1`, common endpoints include `GET {base}/healthz`, `GET {base}/openapi.json`, `GET {base}/events` (SSE mutation stream), `GET {base}/diagnostics` (route-dispatch diagnostics), `GET {base}/resources`, `GET/PATCH {base}/package`, `GET/PATCH {base}/resources/{name}/schema` (and related schema subpaths), row CRUD under `{base}/resources/{name}/...`, and validation endpoints `POST {base}/resources/{name}/validate` and `POST {base}/validate`.

Mutation operations are atomic and leave workspace unchanged on failure.
Error responses use stable JSON shape.

When module adapters are enabled, module endpoints are mounted under `/{token}/v1/modules/{module}/...`.
For full endpoint matrix and error contracts, see [Module reference: bus-api](../modules/bus-api).

### OpenAPI document

You can obtain the OpenAPI document in two ways. From the CLI without starting a server, run `bus-api openapi`; the JSON is printed to stdout (or to the file given by `--output`). From a running server, request `GET /{token}/v1/openapi.json` using the capability base URL. The document is valid OpenAPI 3.1 and describes the versioned API paths and the token path prefix so clients can discover and generate bindings.

### Security and binding

Default bind is `127.0.0.1` (local machine only).
Non-loopback bind must be set explicitly with `--listen`.
Capability URL token is treated as bearer capability.

Server does not implement user/session auth.
Filesystem paths are confined to workspace root.
Use `--tls-cert` + `--tls-key` for HTTPS, or terminate TLS in reverse proxy.

### Exit status and errors

Exit code `0` means success. For `serve`, success means the server is running until interrupted. For `openapi` and `version`, success means the command completed and wrote output to stdout (or `--output`).

Exit code `1` means execution failure, such as unreadable workspace root or missing/invalid TLS files when HTTPS is requested. Exit code `2` means invalid usage, such as unknown subcommand, invalid flag values (for example invalid `--listen` or `--port`), or conflicting flags like `--quiet` and `--verbose`.

Error messages are written to stderr. When the workspace root does not exist or is not readable, startup fails with a clear diagnostic and exit code 1.

### Examples

```bash
bus api serve --port 8080 --token-bytes 32
bus api serve --read-only --enable-module accounts --enable-module journal
bus api openapi --output ./out/openapi.json
bus api version
```


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus api serve --read-only --port 8080
api serve --read-only --port 8080

# same as: bus api openapi --output ./out/openapi.json
api openapi --output ./out/openapi.json
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-data">bus-data</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module reference: bus-api](../modules/bus-api)
- [bus-data CLI reference](./bus-data)
- [Standard global flags](../cli/global-flags)
- [OpenAPI Specification (OAS) 3.1](https://spec.openapis.org/oas/v3.1.0.html)
