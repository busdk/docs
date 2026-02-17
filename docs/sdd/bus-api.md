---
title: bus-api — REST API gateway for workspace data (SDD)
description: Bus API provides a local REST JSON API gateway for BusDK workspaces.
---

## bus-api — REST API gateway for workspace data

### Introduction and Overview

Bus API provides a local REST JSON API gateway for BusDK workspaces. When started, it serves a CRUD API over the BusDK data files in the selected workspace root by delegating all dataset semantics to the [bus-data](./bus-data) Go library (Table Schema, Data Package, CSV operations, mutation policies, and validation). Every dependency on another Bus module — bus-data, bus-bfl, or any domain module such as bus-accounts — is satisfied only by calling that module’s Go library; the server never executes any Bus module CLI. The API supports the same operations as bus-data — including row CRUD, schema mutation (field add/remove/rename, schema patch, primary and foreign key changes), package and resource management — so that system administrators and tools can manage tables and schemas directly over HTTP, and create or maintain custom data outside of Bus domain modules. Operations can be gated by feature flags or modes (e.g. `--read-only`) so that a restricted API can be started when needed; by default all operations are enabled. Bus API also exposes bus-modules so that domain modules such as bus-accounts can provide correct access to their data through their Go library: the API delegates to bus-data for generic workspace resources and to module libraries for module-owned data and semantics.

Intended users are system administrators, developers, and tools that integrate with BusDK via HTTP. The document’s purpose is to define the API contract, security model, and integration points so that implementors and reviewers have a single source of truth. The server serves HTTP by default. Optional HTTPS is supported via SSL command-line parameters when the operator supplies certificate and key. In many deployments TLS is handled by an external service (e.g. reverse proxy or load balancer) in front of the API. Out of scope for this module: user accounts, session management, OAuth, and distributed deployment.

By default, `bus-api` binds only to localhost and prints a capability-style URL that includes an unguessable random path prefix. Clients must know that URL to access the API. This keeps the MVP simple while still preventing accidental access by unrelated local processes.

Bus API can expose formula-projected views when [bus-data](./bus-data) is configured to evaluate formula fields; formula semantics come from [bus-data](./bus-data)’s integration with [bus-bfl](./bus-bfl) (including range resolution through [bus-data](./bus-data)’s deterministic range resolver). Bus API also outputs an OpenAPI document so clients can discover and generate client bindings for the HTTP surface. To support change detection, the API exposes an event stream: clients can subscribe to a long-lived stream and receive events whenever mutations are performed through the API (row create/update/delete, schema changes, or resource and package changes). Events are emitted only for mutations that occur via this API instance, so that tools and UIs can react to CSV and schema changes without polling.

### Requirements

#### Functional Requirements

FR-API-001 Local API server. The module MUST provide a command that starts an HTTP server which serves a REST JSON API over the workspace in the selected root directory. Acceptance criteria: starting the server succeeds without configuration in a workspace that has readable datasets and returns non-zero with a deterministic diagnostic if the workspace root is not readable.

FR-API-002 Capability URL with randomness. On startup, the server MUST generate an unguessable random token and MUST require all API requests to be scoped under a path prefix containing that token. Acceptance criteria: the server prints a full base URL that includes the token and a port, requests outside the token prefix return 404 (or equivalent), and the token is at least 128 bits of entropy by default.

FR-API-003 Safe default binding. The server MUST bind to `127.0.0.1` by default and MUST NOT listen on non-loopback interfaces unless explicitly requested. Acceptance criteria: without flags, the server is reachable only from localhost, and a non-loopback bind requires an explicit `--listen` flag.

FR-API-004 Workspace root and path safety. The server MUST treat the workspace root as the filesystem security boundary and MUST prevent path traversal outside that root. Acceptance criteria: all filesystem paths accepted by the API are workspace-relative, attempts to escape the root are rejected deterministically, and the server never reads or writes outside the selected root.

FR-API-005 bus-data as the authoritative engine. All dataset, schema, and package operations MUST be implemented by calling the [bus-data](./bus-data) Go library only; the module MUST NOT shell out to, exec, or otherwise invoke the bus-data CLI or any other Bus module CLI. Acceptance criteria: all CRUD and validation outcomes match [bus-data](./bus-data) library behavior for the same inputs, including formula projection and range resolution; no code path executes an external bus-data or bus-* process.

FR-API-006 Resource discovery. The API MUST expose endpoints to list resources available in the workspace and to retrieve the workspace `datapackage.json` when present. Acceptance criteria: resource listing is deterministic, ordered, and reflects `datapackage.json` when it exists; if no data package exists, listing still works by discovering tables with beside-the-table schemas using [bus-data](./bus-data) conventions.

FR-API-007 CRUD operations. The API MUST support create, read, update, and delete operations over table rows, subject to [bus-data](./bus-data) schema constraints and `busdk.update_policy` / `busdk.delete_policy`. Acceptance criteria: add/update/delete are rejected when policies forbid them and accepted only when allowed; all mutations are validated and are atomic (no partial writes).

FR-API-008 Formula-projected reads. The API MUST support read operations that return projected values for formula-enabled fields without writing back to CSV, and MUST provide an opt-in mode to include formula source alongside computed values. Acceptance criteria: default reads return computed values, opt-in mode returns computed values plus a non-colliding representation of the source, and stored CSV is unchanged.

FR-API-009 Validation endpoints. The API MUST expose endpoints that validate (a) a single resource and (b) the full workspace package, returning deterministic diagnostics. Acceptance criteria: validation returns stable machine-readable error objects and stable ordering of multiple errors.

FR-API-010 OpenAPI output. The module MUST provide (a) a CLI command to print the OpenAPI document and (b) an HTTP endpoint to fetch it from a running server. Acceptance criteria: the OpenAPI document is valid OpenAPI 3.1, describes the versioned API paths, and models the token path prefix using OpenAPI server variables or an equivalent mechanism.

FR-API-011 Embedded runtime assets. The binary MUST embed everything needed to serve the API and the OpenAPI document. Acceptance criteria: `bus-api` starts and serves OpenAPI without requiring external template files, a generated directory, or runtime downloads.

FR-API-012 Schema and resource mutation. The API MUST expose schema and resource mutation operations that delegate to the [bus-data](./bus-data) Go library only (no CLI invocation), so that the same capabilities provided by the bus-data library (schema field add/remove/rename, schema patch, primary and foreign key changes, resource add/remove/rename, package patch) are available over HTTP. Acceptance criteria: mutating endpoints call the bus-data library for correctness; behavior matches bus-data for the same inputs; destructive or integrity-sensitive operations respect the same force and dry-run semantics as bus-data where applicable. Fine-grained schema field and key operations are exposed as dedicated REST endpoints as specified in the HTTP API Surface section.

FR-API-013 Module exposure. The API MUST expose bus-modules so that domain modules (e.g. bus-accounts) can provide access to their data and semantics through their Go library only; the server MUST NOT invoke any Bus module CLI. Acceptance criteria: the server delegates requests to registered module backends by calling their Go APIs in-process; module code provides handlers or resource views for module-owned data; the API surface for module-provided endpoints is documented and stable.

FR-API-014 Event stream for change detection. The API MUST expose an endpoint that allows clients to subscribe to a stream of events describing changes to workspace data performed through the API. Events MUST be emitted for (a) row create, update, and delete (CSV changes) and (b) schema changes (field add/remove/rename, primary or foreign key changes, schema patch) and (c) resource and package changes (resource add/remove/rename, package patch). Acceptance criteria: clients can open a long-lived connection to the event stream and receive exactly one event per successful mutating request, in request order; each event is machine-readable with a stable type and payload shape; events are emitted only for mutations performed via this API instance (no filesystem watchers); the OpenAPI document describes the event endpoint and event payloads.

#### Non-Functional Requirements

NFR-API-001 Deterministic responses. For the same workspace state and the same sequence of requests, responses MUST be deterministic in content and ordering. Acceptance criteria: JSON object key ordering is stable, arrays are ordered deterministically, and error payloads are stable and comparable in tests.

NFR-API-002 No hidden background work. The server MUST NOT mutate workspace data without an explicit API request and MUST NOT run filesystem watchers by default. Acceptance criteria: no writes occur after startup until a mutating endpoint is called; the event stream is driven solely by mutating API requests in this process and does not require background filesystem watchers.

NFR-API-003 Concurrency safety. The server MUST prevent concurrent write corruption. Acceptance criteria: all mutating operations obtain a workspace-level lock (or equivalent deterministic lock strategy) and either serialize writers or reject concurrent writes with a deterministic “busy” error.

NFR-API-004 Minimal authentication surface. The MVP MUST rely on loopback binding + capability URL token and MUST NOT implement accounts, sessions, OAuth, cookies, or stored credentials. Acceptance criteria: no secrets are written to disk by default, and the token is not logged except as part of the startup URL that the user explicitly receives.

NFR-API-005 Operation gating via feature flags. The server MUST support gating operations (e.g. read-only mode) via configuration or flags so that a restricted API can be started. By default all operations MUST be enabled. Acceptance criteria: when a restriction is enabled (e.g. `--read-only`), mutating endpoints return a deterministic error (e.g. 403); with default configuration, all supported operations are available.

NFR-API-006 Maintainability. The module MUST be library-first with a thin CLI wrapper, and MUST reuse BusDK standard global flags where applicable.

NFR-API-007 Library-only integration with Bus modules. Every dependency on another Bus module (bus-data, bus-bfl, bus-accounts, or any other bus-* module) MUST be satisfied by calling that module’s Go library only. The bus-api process MUST NOT execute, shell out to, or invoke the CLI binary of bus-data, bus-bfl, or any other Bus module. Acceptance criteria: no code path runs `exec`, `os/exec`, or equivalent to start a bus-* process; all integration is in-process library calls; tests and code review can verify the constraint.

NFR-API-008 Performance. The server MUST remain responsive for local use on typical workspace datasets. Acceptance criteria: health and read endpoints respond within a documented timeout under normative load; no unbounded in-memory growth for listing resources or reading rows within the scope of a single request; event delivery to subscribers does not block the mutating request.

NFR-API-009 Scalability. The module targets a single workspace per server instance. Acceptance criteria: the design does not assume distributed deployment or multi-tenant sharing; scaling is by running additional instances bound to different workspace roots.

NFR-API-010 Reliability. The server MUST fail requests deterministically without corrupting workspace data. Acceptance criteria: any request that fails leaves the workspace unchanged; error responses are stable and include sufficient context for diagnosis.

### System Architecture

Bus API is an HTTP gateway that delegates to [bus-data](./bus-data) for workspace data and to bus-module libraries for module-owned data, satisfying FR-API-001, FR-API-005, FR-API-006, FR-API-007, FR-API-012, FR-API-013, and FR-API-014. The **HTTP layer** parses requests, validates path parameters, enforces workspace-root confinement (FR-API-004), applies operation gating (NFR-API-005), and routes to the appropriate backend. The **workspace engine** is [bus-data](./bus-data): it handles CSV, Table Schema and Data Package descriptors, schema and resource mutation, mutation policies, foreign keys, and formula projection. Formula evaluation is exposed through [bus-data](./bus-data)’s integration with [bus-bfl](./bus-bfl) (FR-API-008). **Module backends** are Go libraries (e.g. bus-accounts) that register with the server and provide handlers or resource views for their data; the server delegates module-scoped requests to them by in-process library calls only (no CLI execution; NFR-API-007). The **event stream** is an in-process fan-out: when a mutating request succeeds, the server emits one or more mutation events to all connected event subscribers. Events are not persisted; delivery is best-effort to current subscribers only. The **OpenAPI generator** is embedded and emits an OpenAPI 3.1 document describing the stable API surface including the event endpoint (FR-API-010, FR-API-014).

### Key Decisions

KD-API-001 bus-data is the authority for workspace data (FR-API-005). Bus API never re-implements schema parsing, validation, mutation, or formula rules for generic workspace resources; it delegates to [bus-data](./bus-data) for correctness and consistency. Module-owned data is served by module backends (FR-API-013), which use their own Go libraries and may call bus-data where appropriate.

KD-API-008 Library-only integration (NFR-API-007). All integration with Bus modules is via their Go libraries. bus-api never executes the CLI of bus-data, bus-bfl, or any other bus-* module; doing so would violate the library-only contract and would make correctness, testing, and process boundaries harder to guarantee.

KD-API-002 Capability URL instead of auth (NFR-API-004). The initial security model is “localhost + unguessable path prefix”, not accounts or tokens stored on disk.

KD-API-003 Stable, versioned HTTP surface. The HTTP API is versioned under `/v1/` to allow future evolution without breaking clients.

KD-API-004 OpenAPI-first discoverability (FR-API-010). The module always ships an OpenAPI document so clients can be generated and validated.

KD-API-005 HTTP by default, optional HTTPS via SSL parameters. The server listens for HTTP by default. When the operator provides SSL command-line parameters (certificate and key), the server MAY listen for HTTPS instead. TLS is often terminated by an external service (reverse proxy, load balancer); the module supports optional in-process HTTPS for deployments that need it.

KD-API-006 Full bus-data parity with optional gating. The API exposes the same operations as bus-data (row CRUD, schema and resource mutation, package and validation), so that system administrators and tools can manage workspace data over HTTP and create custom data outside of Bus domain modules. Operations can be restricted by feature flags or modes (e.g. `--read-only`); by default everything is enabled.

KD-API-007 Module exposure via Go library. Bus-modules are exposed through bus-api so that domain modules (e.g. bus-accounts) can provide correct access to their data in code using their Go library only (NFR-API-007). The server delegates to module backends for module-owned resources by in-process library calls. Module endpoints use the path-based layout `/{token}/v1/modules/{module}/...`, and which modules are enabled is controlled by configuration or CLI flags (e.g. `--enable-module`). Module backends implement `http.Handler`; the server strips the path prefix and forwards the request (see IF-API-003).

KD-API-009 Events only for API-originated mutations (FR-API-014). The event stream is driven solely by mutating requests handled by this API instance. The server does not run filesystem watchers by default and does not emit events for changes made to the workspace by other processes or by direct file edits; clients that need to detect external changes must poll or use a separate mechanism.

### Component Design and Interfaces

#### IF-API-001 Go library interface (server core)

The module exposes a Go package that can be used by other Go programs to embed the Bus API server.

Normative shape (names illustrative, not mandatory):

* `type Server struct { … }`
* `func NewServer(root string, opt Options) (*Server, error)`
* `func (s *Server) Serve(l net.Listener) error`
* `func (s *Server) Handler() http.Handler`

`Options` includes:

* `ListenAddr`, `Port` (0 allowed for “pick free port”)
* `Token` (optional; if empty, generated randomly)
* `APIVersion` (default `v1`)
* `CORS` (disabled by default)
* `Locks` strategy (default: workspace write lock)
* `TLSCertFile`, `TLSKeyFile` (optional; when both set, serve HTTPS instead of HTTP)
* `ReadOnly` or operation flags (optional; when set, mutating endpoints return 403; default: all operations enabled)
* `ModuleBackends` or equivalent (optional; list of registered module backends that provide handlers or resource views for module-owned data)
* `ModulesEnabled` or equivalent (optional; list of module identifiers to enable; only backends in this list are mounted under `/{token}/v1/modules/{module}/...`. When empty or unset, no module endpoints are exposed.)
* `EventBufferSize` or equivalent (optional; maximum number of events to buffer per subscriber when delivery is slower than production; when full, behavior is implementation-defined — drop oldest, drop newest, or back-pressure. Default is documented and finite.)

#### IF-API-004 Event stream

The API exposes a long-lived event stream so that clients can detect changes to workspace data (CSV rows and schemas) performed through the API (FR-API-014). Transport: Server-Sent Events (SSE). Endpoint: `GET /{token}/v1/events`. Response: `Content-Type: text/event-stream`. Each event is a single SSE message; the `data` payload is a single line of UTF-8 JSON conforming to the mutation event payload shape below. Events are emitted in the order mutating requests complete; exactly one event (or one event per logical change when a single request causes multiple changes) is emitted per successful mutation. Optional query parameters: `resource` (filter by resource name), `type` (filter by event type prefix). Unsupported query values are ignored; filtering is best-effort and may be implemented server-side or documented as client-filtered. Connection lifecycle: the server keeps the connection open until the client disconnects or the server shuts down; no persistence or replay of events. Subscribers receive only events that occur after they connect.

Mutation event payload shape (stable JSON object; key order is deterministic for tests):

* `type` (string, required): Event type. Values include `resource.rows.created`, `resource.rows.updated`, `resource.rows.deleted`, `resource.schema.changed`, `resource.added`, `resource.removed`, `resource.renamed`, `package.changed`. New types may be added in future versions; clients MUST ignore unknown types.
* `resource` (string, optional): Resource name (table name) when the event is resource-scoped.
* `rowKey` (array of values, optional): Primary key of the affected row in schema primaryKey order, for row events; omitted for schema or package events.
* `summary` (string, optional): Short human-readable summary of the change; for diagnostics only, not for machine logic.
* Additional properties MAY be present for extensibility; clients MUST not rely on them for correctness.

The Go server core MUST provide a way to publish mutation events (e.g. a callback or channel) that is invoked after each successful mutating operation so that the HTTP layer can fan out to all active SSE connections.

#### IF-API-002 Module CLI

The module exposes `bus-api` as a CLI entry point (and is also expected to be runnable via the dispatcher as `bus api …`).

Global flags follow BusDK conventions (not repeated here verbatim), including `--help`, `--version`, and `-C/--chdir` for selecting workspace root.

Commands:

* `bus-api serve` (default if no command is provided)

  * Starts the server, prints the capability base URL to stdout, writes diagnostics to stderr.
* `bus-api openapi`

  * Prints the OpenAPI document (JSON) to stdout.
* `bus-api version`

  * Prints version info.

Serve flags (module-specific):

* `--listen <addr>` default `127.0.0.1`
* `--port <n>` default `0` (auto)
* `--token <string>` optional (for tests / scripted reuse); if absent, generated
* `--token-bytes <n>` default `32` (256 bits)
* `--base-path <path>` default `/{token}/v1`
* `--cors-origin <origin>` repeatable; default none
* `--tls-cert <file>` optional; path to TLS certificate file; when provided together with `--tls-key`, serve HTTPS instead of HTTP
* `--tls-key <file>` optional; path to TLS private key file; when provided together with `--tls-cert`, serve HTTPS instead of HTTP
* `--read-only` forces all mutating endpoints to return 403 (NFR-API-005); by default all operations are enabled
* `--enable-module <name>` repeatable; enables the module with the given identifier (e.g. `accounts` for bus-accounts). Only enabled modules are mounted; when no `--enable-module` is given, no module endpoints are exposed.

#### IF-API-003 Module backends

Bus-modules expose their data through bus-api by implementing a backend contract (Go interface) and registering with the server. The API is path-based: module-provided endpoints live under `/{token}/v1/modules/{module}/...`, where `{module}` is a stable, lowercase module identifier (e.g. `accounts` for bus-accounts). Which modules are exposed is controlled by configuration or CLI: only modules explicitly enabled (e.g. via `ModulesEnabled` in `Options` or repeatable `--enable-module <name>`) are mounted; when none are enabled, no module paths are served. Modules implement `http.Handler` (or `http.HandlerFunc`). The server mounts each enabled backend at `/{token}/v1/modules/{module}/` and forwards requests; the handler receives the request with that prefix stripped so it sees only the module-relative path. The module uses its own Go library (and the bus-data library where appropriate) to serve the response. All integration is library-only; no Bus module CLI is ever executed (NFR-API-007). The OpenAPI document MUST describe the combined surface including module-provided paths for all enabled backends (FR-API-013).

### HTTP API Surface (v1)

All endpoints are rooted under the capability prefix:

`/{token}/v1/...`

Core endpoints:

* `GET /{token}/v1/healthz` → `{ "status": "ok" }`
* `GET /{token}/v1/openapi.json` → OpenAPI document
* `GET /{token}/v1/events` → Server-Sent Events stream of mutation events (FR-API-014). Query params (optional): `resource`, `type`. Each event is one SSE message; `data` is a single line of JSON with keys `type`, `resource` (optional), `rowKey` (optional), `summary` (optional). Event types: `resource.rows.created`, `resource.rows.updated`, `resource.rows.deleted`, `resource.schema.changed`, `resource.added`, `resource.removed`, `resource.renamed`, `package.changed`.
* `GET /{token}/v1/resources` → list of resources (deterministically ordered)
* `GET /{token}/v1/package` → `datapackage.json` as stored (404 if absent)
* `PATCH /{token}/v1/package` → apply merge patch (delegates to `bus-data` semantics)
* `GET /{token}/v1/resources/{name}/schema` → Table Schema JSON
* `PATCH /{token}/v1/resources/{name}/schema` → apply schema merge patch (delegates to bus-data; subject to operation gating)
* Fine-grained schema field and key operations (delegate to bus-data library; request/response bodies mirror library parameters and support optional `force` and `dry_run` where applicable):
  * `POST /{token}/v1/resources/{name}/schema/fields` — add field (body: field descriptor; optional default, description, rdfType, etc.)
  * `PATCH /{token}/v1/resources/{name}/schema/fields/{field}` — rename field or set type/format/constraints/missing-values (body specifies change; query or body may include `force` where the library allows)
  * `DELETE /{token}/v1/resources/{name}/schema/fields/{field}` — remove field (optional `force`; refused if integrity would be violated)
  * `PUT /{token}/v1/resources/{name}/schema/primaryKey` — set primary key (body: array of field names in order)
  * `POST /{token}/v1/resources/{name}/schema/foreignKeys` — add foreign key (body: fields, reference resource, reference fields; mirrors bus-data foreign-key add)
  * `DELETE /{token}/v1/resources/{name}/schema/foreignKeys/{index}` — remove foreign key by index
* `POST /{token}/v1/resources/{name}/validate` → validation report
* `POST /{token}/v1/validate` → workspace validation report

Resource and package mutation (subject to operation gating): resource add/remove/rename and package patch are supported; they delegate to bus-data (FR-API-012).

Row operations (resource-oriented). Single-row operations use the path segment `.../row/{pk}` (singular). Multi-row read uses `.../rows` (plural) with query parameters so that the contract is deterministic: one path shape for one row, another for multiple rows.

* `GET /{token}/v1/resources/{name}/rows`

  * Multi-row read. Query: `row`, `key`, `filter`, `column`, `include_formula_source` (mirrors bus-data library table-read semantics). For primary-key selection, use repeated `key` query params in schema primaryKey order (e.g. `?key=val1&key=val2` for composite keys).
* `GET /{token}/v1/resources/{name}/row/{pk}`

  * Single-row read. `{pk}` is the percent-encoded JSON array of primary key values in schema primaryKey order (single-column primary key uses a one-element array, e.g. `["p-001"]`).
* `POST /{token}/v1/resources/{name}/rows` (add row)
* `PATCH /{token}/v1/resources/{name}/row/{pk}` (update row, only if allowed)
* `DELETE /{token}/v1/resources/{name}/row/{pk}` (delete row, only if allowed)

Module-provided endpoints (FR-API-013). The API exposes bus-modules so that domain modules (e.g. bus-accounts) provide access to their data via their Go library. Module endpoints are path-based at `/{token}/v1/modules/{module}/...` (e.g. `/{token}/v1/modules/accounts/...` for bus-accounts). Only modules explicitly enabled via configuration or `--enable-module` are mounted; with none enabled, no module paths are served. Each backend implements `http.Handler` and receives requests with the capability and module prefix stripped (module-relative path). The OpenAPI document describes the combined surface for all enabled module backends.

All mutation endpoints are subject to operation gating (NFR-API-005); when restrictions such as `--read-only` are enabled, they return 403. When allowed, they MUST be atomic and MUST return deterministic error payloads. The normative error body shape for 4xx and 5xx responses includes at least: a stable machine-readable `code` string, `resource` (resource name when applicable), `field` or `fields` (field names when applicable), and `row` or `rowKey` (row identifier when applicable). Additional properties MAY be present for diagnostics; key ordering in JSON MUST be stable so that tests can compare payloads deterministically.

### Data Design

Bus API does not introduce new on-disk data formats. It operates purely on the workspace datasets and metadata managed by [bus-data](./bus-data) (CSV tables, beside-the-table schemas, and `datapackage.json`). The module does not own persistent storage for API state: the server is stateless aside from the workspace files it reads and writes through [bus-data](./bus-data). Mutation events are not persisted; they are emitted in-process to connected event-stream subscribers only and are lost when the connection closes or the server stops. Not Applicable: API-owned databases, caches, or session stores; all persistent data lives in the workspace.

### Assumptions and Dependencies

AD-API-001 bus-data library. The module depends on the [bus-data](./bus-data) Go library for all dataset, schema, and package operations. Integration is library-only (NFR-API-007): bus-api never invokes the bus-data CLI or any other Bus module CLI. If the library’s public API or error contracts change, bus-api must update its integration so that CRUD and validation outcomes remain consistent and deterministic.

AD-API-002 bus-bfl (transitive). Formula projection and validation are provided by [bus-data](./bus-data), which depends on the [bus-bfl](./bus-bfl) Go library. bus-api does not call bus-bfl directly; formula behavior is entirely delegated to bus-data. Neither bus-api nor bus-data invokes the bus-bfl CLI; the dependency is library-only.

AD-API-003 Workspace on local filesystem. The selected workspace root is assumed to be a readable (and, for mutations, writable) directory on the local filesystem. The server does not support remote or network-mounted workspaces; if the root is missing or inaccessible, startup fails with a deterministic diagnostic.

AD-API-004 Go runtime. The module is built and run with a supported Go toolchain. Build and test environments assume a stable Go version as defined by the BusDK project.

AD-API-005 Single process. Concurrency safety (NFR-API-003) is defined for a single server process. Multi-instance or multi-process sharing of the same workspace is out of scope unless explicitly designed later; impact of false assumption: undefined behavior or data corruption if multiple writers access the same workspace.

### Glossary and Terminology

**Capability URL:** The full base URL printed at startup that includes the random token and port. Possession of this URL is treated as the sole authorization to access the API in the MVP.

**Token:** The unguessable random path segment generated at startup and required in the path prefix of every request. It provides capability-style access control without stored credentials.

**Workspace root:** The filesystem directory selected as the API’s working context (e.g. via `-C` / `--chdir`). All dataset and schema paths are resolved relative to this root; the server MUST NOT read or write outside it.

**Resource:** A named tabular dataset in the workspace, as defined in the data package or discovered via beside-the-table schema conventions. In the API, resources are identified by name in path segments (e.g. `GET /{token}/v1/resources/{name}/schema`).

**Row / primary key (pk):** A single row in a resource’s table, identified by the schema’s primary key. Single-row endpoints use the path segment `.../row/{pk}`; `{pk}` is the percent-encoded JSON array of primary key values in schema primaryKey order (single-column primary key uses a one-element array). Multi-row read uses `GET .../rows` with query parameters (e.g. repeated `key` in primaryKey order).

**Module backend:** A bus-module Go library (e.g. bus-accounts) that registers with the bus-api server and provides handlers or resource views for module-owned data. The server delegates requests for that module’s URL space to the backend by calling its Go API in-process; the module uses its own library and may call bus-data. No CLI of any Bus module is ever executed (FR-API-013, NFR-API-007).

**Library-only integration:** The requirement that bus-api (and, for module backends, any Bus module) integrate with other Bus modules solely by calling their Go libraries, never by executing their CLI binaries or subprocesses. See NFR-API-007 and KD-API-008.

**Event stream:** A long-lived HTTP response (Server-Sent Events) at `GET /{token}/v1/events` that delivers mutation events to the client. Events are emitted only when mutations are performed through this API instance (row CRUD, schema or resource or package changes). See FR-API-014 and IF-API-004.

**Mutation event:** A machine-readable JSON object pushed over the event stream describing a single change to workspace data (CSV or schema). It includes at least `type`, and optionally `resource`, `rowKey`, and `summary`. Used for change detection without polling.

### Security Considerations

The server binds to loopback only by default (FR-API-003) and serves HTTP by default. When the operator supplies `--tls-cert` and `--tls-key`, the server serves HTTPS on the same listen address and port. In many deployments TLS is terminated by an external service (reverse proxy, load balancer) and the API runs HTTP behind it; optional in-process HTTPS is for operators who need it. The random token in the URL is treated as a bearer capability: anyone who has the full URL can access the API. The server must never serve files outside the workspace root and must reject path traversal attempts (FR-API-004). Request logging, if enabled, must avoid printing the token by default (e.g. log paths with the token redacted).

### Observability and Logging

Startup prints only the capability base URL to stdout. Diagnostics and logs go to stderr. Default logs SHOULD omit timestamps to keep outputs stable in tests; timestamps MAY be enabled explicitly.

### Error Handling and Resilience

Invalid usage exits with code 2 and a concise usage error. Runtime request failures return appropriate HTTP statuses with deterministic JSON error bodies conforming to the shape specified in the HTTP API Surface section. Any filesystem or validation failure must leave the workspace unchanged (NFR-API-010).

### Testing Strategy

Unit tests MUST cover token path gating, workspace-root confinement, deterministic JSON ordering, and OpenAPI document validity. Integration tests MUST start the server with fixed `--token` and fixed `--port`, run CRUD and validation requests against a fixture workspace, and verify on-disk results match the equivalent [bus-data](./bus-data) library operations (library-only integration; no CLI invocation). End-to-end tests MUST execute the running `bus-api serve` process through `curl` so the real HTTP surface is verified from outside the process boundary. These `curl` E2E checks MUST use the printed capability base URL, MUST verify that requests outside the token prefix fail deterministically, and MUST verify successful and failing CRUD, schema mutation, and validation calls against fixture workspace data. Event-stream E2E checks MUST use `curl` streaming mode against `GET /{token}/v1/events` and verify that a subscribed client receives exactly one event (or the documented set of events) per successful mutating request, with payload shape conforming to IF-API-004, and that events are not emitted for failed or read-only requests. Concurrency tests MUST assert that two concurrent write requests serialize or reject deterministically without corrupting CSV files.

### Deployment and Operations

Not Applicable. The module ships as a single embedded binary intended for local use.

### Migration/Rollout

Not Applicable. The module is additive; it does not change dataset formats.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-data">bus-data</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [BusDK Software Design Document (SDD)](https://docs.busdk.com/sdd)
- [bus-data SDD](./bus-data)
- [bus-bfl SDD](./bus-bfl)
- [Standard global flags](https://docs.busdk.com/cli/global-flags)
- [curl documentation](https://curl.se/docs/)
- [OpenAPI Specification (OAS) 3.1](https://spec.openapis.org/oas/v3.1.0.html)

### Document control

Title: bus-api module SDD
Project: BusDK
Document ID: `BUSDK-MOD-API`
Version: 2026-02-13
Status: Draft
Last updated: 2026-02-18
Owner: BusDK development team