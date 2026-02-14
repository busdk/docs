---
title: bus-api
description: Bus API provides a local REST JSON API over the BusDK workspace in the selected root.
---

## bus-api

### Name

`bus api` — local REST JSON API gateway for BusDK workspaces.

### Synopsis

`bus api [global flags] [serve | openapi | version]`  
`bus-api [global flags] [serve | openapi | version]`

With no subcommand, `bus api` runs **serve**. Global flags follow [CLI command naming](../cli/command-naming) and the [standard global flags](../cli/global-flags); the workspace root is set with `-C` / `--chdir` and is used as the API’s working context.

Serve (default):

`bus-api serve [--listen <addr>] [--port <n>] [--token <string>] [--token-bytes <n>] [--base-path <path>] [--cors-origin <origin>] ... [--tls-cert <file>] [--tls-key <file>] [--read-only] [--enable-module <name> ...] [global flags]`

`bus-api openapi` — Print the OpenAPI document (JSON) to stdout.  
`bus-api version` — Print the tool name and version to stdout and exit 0.

### Description

Command names follow [CLI command naming](../cli/command-naming). Bus API provides a local REST JSON API over the BusDK workspace in the selected root. When you start the server, it serves a CRUD API over the workspace datasets by delegating all dataset semantics to the [bus-data](./bus-data) library (Table Schema, Data Package, CSV operations, mutation policies, and validation). No Bus module CLI is ever executed; the server calls only Go libraries. The API supports the same operations as bus-data — row CRUD, schema and resource mutation, package and validation — so that system administrators and tools can manage tables and schemas over HTTP and maintain custom data outside of Bus domain modules. Optional operation gating (e.g. `--read-only`) lets you start a restricted API when needed; by default all operations are enabled.

Intended users are system administrators, developers, and tools that integrate with BusDK via HTTP. The server binds to localhost by default and prints a **capability URL** that includes an unguessable random path prefix. Clients must use that full URL to access the API; requests outside the prefix return 404. The server can optionally serve HTTPS when you supply certificate and key via `--tls-cert` and `--tls-key`; in many deployments TLS is handled by a reverse proxy in front of the API. User accounts, session management, and OAuth are out of scope for this module. To support change detection without polling, the API exposes an event stream: clients can subscribe to a long-lived stream and receive events whenever mutations are performed through the API (row create/update/delete, schema changes, resource and package changes). Events are emitted only for mutations that occur via this API instance.

Domain modules (e.g. bus-accounts) can expose their data through the API when enabled with `--enable-module`. Module endpoints live under `/{token}/v1/modules/{module}/...` and are served by the module’s Go library only. The [bus-api SDD](../sdd/bus-api) defines the full API contract, security model, and integration points.

### Commands

**`serve`** (default) — Start the HTTP server. The effective workspace root is the current directory or the directory given by `-C` / `--chdir`. The server generates an unguessable token (unless you pass `--token`), binds to the address and port given by `--listen` and `--port`, and prints the capability base URL to **stdout**. All diagnostics and logs go to **stderr**. You must use the printed URL (including the token path segment) for every API request; there is no separate login or session. The server does not mutate workspace data until a mutating endpoint is called. If the workspace root is not readable, startup fails with a deterministic diagnostic and a non-zero exit code.

**`openapi`** — Emit the OpenAPI 3.1 document (JSON) to stdout. The document describes the versioned API paths and models the token path prefix so clients can generate bindings. No server is started. Diagnostics go to stderr.

**`version`** — Print the tool name and version to stdout and exit 0. Other flags and arguments are ignored when version is requested.

### Serve flags

These flags apply only to `serve`. They can appear in any order before or after the subcommand name.

- **`--listen <addr>`** — Bind address. Default `127.0.0.1`. The server listens only on this address; use an explicit non-loopback address only when you intend the API to be reachable from other hosts.
- **`--port <n>`** — Port number. Default `0` (choose a free port). The printed capability URL includes the actual port in use.
- **`--token <string>`** — Use this token instead of generating one. Useful for scripts or tests that need a stable URL. If omitted, a random token is generated.
- **`--token-bytes <n>`** — Length of the generated token in bytes when `--token` is not set. Default `32` (256 bits of entropy).
- **`--base-path <path>`** — Path prefix template. Default `/{token}/v1`. All API endpoints are rooted under this prefix with the token substituted.
- **`--cors-origin <origin>`** — Allow the given CORS origin. Repeatable to allow multiple origins. Default: none (CORS disabled).
- **`--tls-cert <file>`** — Path to the TLS certificate file. When provided together with `--tls-key`, the server serves HTTPS instead of HTTP on the same listen address and port.
- **`--tls-key <file>`** — Path to the TLS private key file. When provided together with `--tls-cert`, the server serves HTTPS.
- **`--read-only`** — Disable all mutating endpoints. When set, create/update/delete and schema or package mutation requests return 403. By default all operations are enabled.
- **`--enable-module <name>`** — Enable the module with the given identifier (e.g. `accounts` for bus-accounts). Repeatable. Only enabled modules are mounted under `/{token}/v1/modules/{module}/...`. When no `--enable-module` is given, no module endpoints are exposed.

### Global flags

These flags apply to all subcommands and match the [standard global flags](../cli/global-flags). They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are passed to the subcommand.

- **`-h`**, **`--help`** — Print help to stdout and exit 0. Other flags and arguments are ignored when help is requested.
- **`-V`**, **`--version`** — Print the tool name and version to stdout and exit 0.
- **`-v`**, **`--verbose`** — Send verbose diagnostics to stderr. You can repeat the flag (e.g. `-vv`) to increase verbosity. Verbose output does not change what is written to stdout.
- **`-q`**, **`--quiet`** — Suppress normal command result output. When quiet is set, only errors go to stderr. Exit codes are unchanged. You cannot combine `--quiet` with `--verbose`; doing so is invalid usage (exit 2).
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective workspace root. All dataset and schema paths are resolved relative to this directory. The server treats this as the filesystem security boundary and rejects path traversal outside it. If the directory does not exist or is not accessible, the command exits with code 1.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of stdout. For `serve`, the capability URL is still printed to stdout unless you redirect it; for `openapi`, the document is written to the file when this flag is set. Errors and diagnostics still go to stderr.
- **`--color <mode>`** — Control colored output on stderr. `<mode>` must be `auto`, `always`, or `never`. Invalid value is usage error (exit 2).
- **`--no-color`** — Same as `--color=never`.

Command results (capability URL, OpenAPI JSON, version) are written to stdout when produced. Diagnostics and logs are written to stderr.

### Using the API

After starting the server with `bus api serve` (or `bus-api serve`), use the capability URL printed to stdout as the base for all requests. For example if the server prints `http://127.0.0.1:38472/abc123def/v1`, then:

- **Health:** `GET {base}/healthz` returns `{ "status": "ok" }`.
- **OpenAPI:** `GET {base}/openapi.json` returns the OpenAPI document from the running server.
- **Events:** `GET {base}/events` returns a Server-Sent Events stream of mutation events (row create/update/delete, schema changes, resource and package changes). Events are emitted only for mutations performed through this API instance. Optional query parameters `resource` and `type` filter the stream.
- **Resources:** `GET {base}/resources` returns a deterministically ordered list of workspace resources.
- **Package:** `GET {base}/package` returns `datapackage.json` when present (404 otherwise). `PATCH {base}/package` applies a merge patch (delegates to bus-data).
- **Schema:** `GET {base}/resources/{name}/schema` returns the Table Schema for a resource. Schema mutation is available via `PATCH {base}/resources/{name}/schema` (merge patch) and via fine-grained endpoints: `POST .../schema/fields`, `PATCH .../schema/fields/{field}`, `DELETE .../schema/fields/{field}`, `PUT .../schema/primaryKey`, `POST .../schema/foreignKeys`, `DELETE .../schema/foreignKeys/{index}`. All delegate to bus-data semantics.
- **Rows:** `GET {base}/resources/{name}/rows` supports query parameters such as `row`, `key`, `filter`, `column`, and `include_formula_source`. Single-row read uses `GET {base}/resources/{name}/row/{pk}` where `{pk}` is the percent-encoded JSON array of primary key values in schema order.
- **Validation:** `POST {base}/resources/{name}/validate` returns a validation report for a single resource; `POST {base}/validate` returns a workspace-wide validation report.
- **Mutate:** `POST {base}/resources/{name}/rows`, `PATCH {base}/resources/{name}/row/{pk}`, and `DELETE {base}/resources/{name}/row/{pk}` perform row add, update, and delete subject to schema constraints and update/delete policies. Resource add/remove/rename and package patch also delegate to bus-data. When `--read-only` is in effect, all mutating endpoints return 403.

All mutation operations are atomic and leave the workspace unchanged on failure. Error responses use a stable JSON shape with at least `code`, and when applicable `resource`, `field` or `fields`, and `row` or `rowKey`. The [bus-api SDD](../sdd/bus-api) specifies the full HTTP API surface and error contract.

### OpenAPI document

You can obtain the OpenAPI document in two ways. From the CLI without starting a server, run `bus-api openapi`; the JSON is printed to stdout (or to the file given by `--output`). From a running server, request `GET /{token}/v1/openapi.json` using the capability base URL. The document is valid OpenAPI 3.1 and describes the versioned API paths and the token path prefix so clients can discover and generate bindings.

### Security and binding

By default the server binds only to `127.0.0.1` and is reachable from the local machine. To listen on a non-loopback interface you must set `--listen` explicitly. The random token in the capability URL is treated as a bearer capability: anyone who has the full URL can access the API. The server does not implement user accounts, sessions, or stored credentials. All filesystem paths are confined to the workspace root; path traversal outside that root is rejected. When you supply `--tls-cert` and `--tls-key`, the server serves HTTPS on the same address and port; otherwise it serves HTTP. Many deployments use an external reverse proxy or load balancer for TLS and keep the API on HTTP behind it.

### Exit status and errors

- **0** — Success. For `serve`, the server is running until interrupted; for `openapi` and `version`, the command completed and wrote result to stdout (or `--output`).
- **1** — Execution failure: workspace root not readable or not accessible, or TLS files missing/invalid when HTTPS is requested.
- **2** — Invalid usage: unknown subcommand, invalid flag value (e.g. invalid `--listen` or `--port`), or conflicting flags (e.g. `--quiet` and `--verbose`).

Error messages are written to stderr. When the workspace root does not exist or is not readable, startup fails with a clear diagnostic and exit code 1.

### Development state

The server runs and can serve workspace data; current work is wiring all endpoints to the [bus-data](./bus-data) library only (no CLI invocation). [bus-sheets](./bus-sheets) embeds this API in-process for the spreadsheet UI. Planned next: full bus-data integration for resources, package, schema, rows, and validation; workspace root as security boundary and workspace-level lock; stable JSON error shape and 403 when read-only; serve flags (base-path, CORS, TLS, enable-module); OpenAPI and e2e tests. Implement [bus-data](./bus-data) and [bus-bfl](./bus-bfl) first. See [Development status](../implementation/development-status).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-data">bus-data</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-api](../sdd/bus-api)
- [bus-data CLI reference](./bus-data)
- [Standard global flags](../cli/global-flags)
- [OpenAPI Specification (OAS) 3.1](https://spec.openapis.org/oas/v3.1.0.html)
