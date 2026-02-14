---
title: bus-preferences — user-level, cross-workspace preferences (SDD)
description: Bus Preferences owns user-level, cross-workspace preference storage for BusDK via an extensible, namespaced key-value configuration file.
---

## bus-preferences — user-level, cross-workspace preferences

### Introduction and Overview

Bus Preferences owns user-level BusDK configuration stored in a dedicated preferences file located in the user’s config directory (platform-appropriate; e.g. XDG on Linux/macOS and AppData on Windows). The preferences file is explicitly not part of any workspace repository and is not used to store accounting data or workspace configuration. Instead, it stores optional defaults and runtime/UX preferences that apply across invocations and contexts, such as default tool selections, output formatting defaults, and module-specific user preferences. Bus Preferences is designed to be extensible without coupling: it provides a generic namespaced key-value store (similar in spirit to Git’s global configuration), where any BusDK module may persist and read its own preferences under its own namespace without bus-preferences needing knowledge of those modules or introducing dependencies on them. Bus Preferences is library-first and exposes a thin CLI surface for deterministic inspection and mechanical updates; it performs no Git or network operations.

Scope boundaries are strict. Bus Preferences owns only the user-level preferences file and its access semantics. It does not own [workspace configuration](../data/workspace-configuration) (e.g. `datapackage.json`), master data, domain datasets, or any domain validation rules. It does not interpret module semantics or enforce module-specific schemas beyond key-path and storage invariants; each consumer module documents and validates its own preference keys and values. The intended users are developers integrating BusDK modules and end users running the `bus preferences` CLI. This document is the single source of truth for implementation and review; the audience includes human reviewers and implementation agents.

### Requirements

FR-PRF-001 User-level preferences storage. The module MUST define and own a user-level preferences file stored outside repositories in a deterministic location. Acceptance criteria: the library resolves the same path for all consumers on a given machine/user; the file persists across process invocations; the file is not created in the workspace.

FR-PRF-002 Namespaced, extensible key-value model. The module MUST support storing arbitrary module-specific preferences under namespaced keys without requiring bus-preferences to know those modules. Acceptance criteria: a module can set and read keys under its namespace without any code changes in bus-preferences; unknown namespaces are accepted.

FR-PRF-003 Deterministic read/write behavior. The module MUST read and write the preferences file deterministically and atomically. Acceptance criteria: writes are atomic (temp file + rename); encoding is canonical so the same in-memory content yields byte-for-byte identical output; listing keys returns a deterministic order.

FR-PRF-004 Non-invasive operation. The module MUST not perform Git or network operations. Acceptance criteria: commands and library functions only read and write the preferences file at the resolved location.

FR-PRF-005 CLI surface for mechanical management. The module MUST provide a CLI surface to set, get, unset, and list preferences deterministically. Acceptance criteria: `set` creates the file as needed; `get` exits non-zero when the key is missing; `list` returns keys in sorted order; invalid usage yields exit code 2 with a deterministic message.

FR-PRF-006 Library-first integration. The module MUST provide a Go package that other modules can import to read and write preferences. The library MUST not import other BusDK domain modules. Acceptance criteria: a module can depend only on the bus-preferences Go package to persist and read its preferences.

NFR-PRF-001 Key-path validation. The module MUST validate preference keys against a canonical key-path grammar to avoid ambiguity and ensure cross-platform safety. Acceptance criteria: invalid keys are rejected with deterministic usage error and exit code 2.

NFR-PRF-002 No secrets by design. The module SHOULD document that preferences are not intended for secrets and SHOULD provide guidance for consumers to avoid storing credentials. Acceptance criteria: documentation explains that secrets belong in OS credential storage or external secret managers, not in preferences.

NFR-PRF-003 Performance. Read and write operations MUST complete in time acceptable for interactive CLI use. Acceptance criteria: get/set/list against the preferences file complete without perceptible delay under normal file size; no blocking network or external process calls.

NFR-PRF-004 Scalability. The storage model is a single file; document size is bounded by practical limits. Acceptance criteria: the design and documentation state that the preferences file is the only store and that unbounded growth is a consumer responsibility to avoid.

NFR-PRF-005 Maintainability. Key-path grammar and namespacing conventions MUST be documented so that new consumers can add preferences without changing bus-preferences code. Acceptance criteria: key-path rules and namespace convention are specified in this SDD and in the module’s user-facing documentation.

### System Architecture

Bus Preferences is a small CLI module with a Go library that resolves the user-level preferences path (IF-PRF-001, FR-PRF-001), loads and validates the preferences document, and performs atomic, deterministic updates (FR-PRF-003). Consumer modules import the library (IF-PRF-003, FR-PRF-006) to store and retrieve values under their own namespaces (FR-PRF-002). The CLI (IF-PRF-002) satisfies FR-PRF-005 for mechanical management. Bus Preferences remains agnostic of consumer semantics: it only provides generic operations and does not depend on or validate against other module definitions. Key-path validation (IF-PRF-004) satisfies NFR-PRF-001. The `bus` dispatcher and other modules MAY read preferences to apply defaults, but preference use is always optional and must not replace auditable workspace configuration for domain-critical behavior.

### Key Decisions

KD-PRF-001 Separate ownership for user-level preferences. User-level preferences are owned by bus-preferences to keep workspace configuration ownership (e.g. `datapackage.json`) separate and to avoid coupling workspace semantics with per-user behavior.

KD-PRF-002 Namespaces over schemas. The store is schema-light and namespace-based: bus-preferences enforces only key-path and encoding invariants, while consumer modules define and validate their own keys and values. This prevents dependency edges from bus-preferences to other modules.

KD-PRF-003 Canonical JSON document with reserved metadata. The file format is JSON with a reserved metadata envelope and a generic map of key paths to JSON values to allow typed values when needed while keeping the storage model simple and extensible.

### Component Design and Interfaces

#### Interface IF-PRF-001 (preferences file location)

Satisfies FR-PRF-001. The library resolves the user-level preferences file path as follows:

1. If `BUS_PREFERENCES_PATH` environment variable is set, use that exact path.
2. Else on Windows, use `%APPDATA%\BusDK\preferences.json`.
3. Else on Unix-like systems, use `$XDG_CONFIG_HOME/busdk/preferences.json`, falling back to `~/.config/busdk/preferences.json`.

The resolved directory MUST be created as needed on write. Consumers MUST use the library rather than re-implement path resolution.

#### Interface IF-PRF-002 (CLI)

Satisfies FR-PRF-005. The module is invoked under the dispatcher as `bus preferences ...` and follows BusDK conventions for deterministic output and diagnostics.

Commands:

- `bus preferences set <key> <value>`  
  Sets `<key>` to a string value (stored as JSON string).

- `bus preferences set-json <key> <json>`  
  Sets `<key>` to an arbitrary JSON value (object/array/string/number/bool/null), validated as JSON.

- `bus preferences get <key>`  
  Prints the value to stdout. If the stored value is a JSON string, prints the raw string (no quotes). Otherwise prints canonical JSON.

- `bus preferences unset <key>`  
  Removes `<key>` if it exists; exits 0 whether or not it existed.

- `bus preferences list [<prefix>]`  
  Lists all keys (optionally filtered by prefix match on key-path segments) in lexicographic order. Output is deterministic; the default output is line-oriented `key=<canonical-json>`.

Key-path validation failures and invalid JSON for `set-json` MUST exit with code 2.

Usage examples:

```bash
bus preferences set bus-agent.runtime gemini
bus preferences set-json bus-dev.ui '{"theme":"dark","density":"compact"}'
bus preferences get bus-agent.runtime
bus preferences list bus-dev
bus preferences unset bus-agent.runtime
```

#### Interface IF-PRF-003 (Go library)

Satisfies FR-PRF-006. The module exposes a Go package that provides at least:

* `Get(ctx, key) (value json.RawMessage, ok bool, err error)`
* `GetString(ctx, key) (string, ok bool, err error)`
* `SetString(ctx, key, value string) error`
* `SetJSON(ctx, key, raw json.RawMessage) error`
* `Unset(ctx, key) error`
* `List(ctx, prefix string) (items []Item, err error)` where `Item` includes `Key string` and `Value json.RawMessage`

The library enforces key-path validation, canonical encoding, deterministic ordering, and atomic writes. The library MUST not import consumer modules and MUST not require compile-time knowledge of module namespaces.

#### Interface IF-PRF-004 (key-path grammar)

Satisfies NFR-PRF-001. Keys are canonical “paths” using dot-separated segments:

* Grammar (informal): `segment("." segment)*`
* Segment allowed characters: `a-z`, `0-9`, `-`, `_` (lowercase only)
* Recommended convention: first segment is a module namespace (e.g. `bus-agent`, `bus-dev`, `bus`), followed by module-defined subkeys (e.g. `runtime`, `ui.theme`).

Keys MUST be treated as case-sensitive at the storage layer; the CLI and library MUST reject keys containing uppercase characters to maintain a single canonical form.

### Data Design

The preferences file is a JSON document with an envelope and a values map:

```json
{
  "version": 1,
  "values": {
    "bus-agent.runtime": "gemini",
    "bus-dev.ui": { "theme": "dark" }
  }
}
```

Rules:

* `version` is reserved for migration.
* `values` is a map from validated key paths to JSON values.
* Writes MUST serialize JSON canonically:

  * Object keys sorted lexicographically at every object level.
  * Stable indentation and newline rules (implementation-defined but fixed).
* Updates MUST be atomic and resilient against partial writes.

bus-preferences does not define schemas for the contents of `values` beyond key-path validation. Each consumer module defines its own semantics and validation for the keys it uses.

### Assumptions and Dependencies

Bus Preferences assumes a writable user-level config directory exists (or can be created) and that filesystem permissions control access. Impact if false: writes fail with a clear error; the module does not fall back to an alternate location. The module depends on the `bus` dispatcher for invocation conventions but does not depend on other BusDK modules. Impact if the dispatcher is absent: the CLI is not invoked as `bus preferences`; the library remains usable. Consumer modules depend on bus-preferences to persist cross-invocation defaults; those modules remain responsible for validating preference values and defining precedence rules between flags, environment variables, and stored preferences. Impact if a consumer misuses the API: invalid or conflicting values are a consumer bug; bus-preferences does not enforce module-specific semantics.

### Glossary and Terminology

**Preferences file:** the user-level JSON file owned by bus-preferences, stored in the platform config directory (or at `BUS_PREFERENCES_PATH` when set), containing the `version` envelope and the `values` map. Resolved by IF-PRF-001.

**User-level preferences:** configuration stored outside repositories that applies across invocations and contexts for a single user/machine; stored in the preferences file.

**Namespace:** the first key-path segment conventionally matching a module or subsystem (e.g. `bus-agent`, `bus-dev`), used to prevent key collisions.

**Key-path:** the canonical dot-separated identifier used to store and retrieve a preference value.

### Security Considerations

Preferences are user-local and may include sensitive operational defaults (paths, toggles), but they are not intended to store secrets. The documentation MUST advise consumers not to store credentials in preferences and to use OS credential storage or external secret managers for secrets. File access is controlled by filesystem permissions; the module should create directories/files with user-only permissions where supported.

### Observability and Logging

Commands print results to stdout and deterministic diagnostics to stderr. The library returns deterministic error messages for invalid keys, invalid JSON, and I/O failures.

### Error Handling and Resilience

* Missing key on `get` results in a non-zero exit code and a concise error on stderr.
* Invalid key-path or invalid JSON for `set-json` exits with code 2.
* Atomic write strategy prevents corruption on interruption.
* If the file is malformed JSON, commands fail deterministically with a parse error and a non-zero exit code.

### Testing Strategy

* Unit tests for key-path validation and canonical encoding.
* Command-level tests that set/get/unset/list in a temporary config directory using `BUS_PREFERENCES_PATH`.
* Tests for deterministic output ordering and atomic write behavior (e.g. write + reload + compare bytes).

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and a Go library.

### Migration/Rollout

Not Applicable initially. The `version` field enables future migrations. If migrating from an older location or format, the library MAY implement a deterministic one-time migration strategy documented in release notes.

### Risks

* Unbounded extensibility may lead to inconsistent consumer conventions. This is mitigated by enforcing a strict key grammar and encouraging module namespaces and documented keys.
* Storing non-string JSON values may complicate consumer parsing. This is mitigated by providing string-first convenience APIs (`GetString`/`SetString`) and keeping typed JSON optional.

---

### Sources

* [Layout principles](../layout/layout-principles)
* [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration)
* [bus-config module SDD](./bus-config)
* [bus module SDD](./bus)

### Document control

Title: bus-preferences module SDD
Project: BusDK
Document ID: `BUSDK-MOD-PRF`
Version: 2026-02-13
Status: Draft
Last updated: 2026-02-13
Owner: BusDK development team
