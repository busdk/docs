---
title: bus preferences — user-level preference storage
description: Set, get, list, and unset user-level BusDK preferences in a namespaced key-value file outside any workspace; no Git or network.
---

## `bus-preferences` — user-level, cross-workspace preference storage for BusDK

### Synopsis

`bus preferences [global flags] <command> [<args>]`

Commands: **`set`**, **`set-json`**, **`get`**, **`unset`**, **`list`**.

`bus preferences set <key> <value>` — store a string value for `<key>`.  
`bus preferences set-json <key> <json>` — store an arbitrary JSON value for `<key>`.  
`bus preferences get <key>` — print the value for `<key>` to stdout.  
`bus preferences unset <key>` — remove `<key>` if present.  
`bus preferences list [<prefix>]` — list all keys, optionally filtered by key prefix, in sorted order.

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus preferences` manages user-level BusDK preferences in one local file.
The file is outside any workspace repository and is not accounting data.

Use it for cross-workspace defaults and runtime options (for example default runtime/tool choices or output preferences).
Modules can read and write values under their own key namespaces.

The store is a namespaced key-value map with dot-separated keys.
`bus preferences` enforces key grammar and value storage only; modules define meaning of their own keys.
The module performs no Git or network operations.

### Commands

**`set <key> <value>`** — Store `<value>` as a JSON string for `<key>`.
Creates the preferences file if needed.
Invalid key returns exit code `2`.

**`set-json <key> <json>`** — Store arbitrary JSON value for `<key>`.
`<json>` must be valid JSON.
Invalid JSON or key returns exit code `2`.

**`get <key>`** — Print value for `<key>` to stdout.
String values print as raw string; other values print as canonical JSON.
Missing key returns non-zero with concise stderr message.
Invalid key returns exit code `2`.

**`unset <key>`** — Remove `<key>` if present.
Returns `0` even when key is already absent.
Invalid key returns exit code `2`.

**`list [<prefix>]`** — List keys in sorted deterministic order.
With `<prefix>`, only matching key paths are listed.
Output format is line-oriented: `key=<canonical-json>`.
Invalid prefix returns exit code `2`.

### Where the preferences file lives

The preferences file path is resolved in this order:

If the environment variable **`BUS_PREFERENCES_PATH`** is set, that path is used exactly. Otherwise, on Windows the default path is **`%APPDATA%\BusDK\preferences.json`**. On Unix-like systems, the default is **`$XDG_CONFIG_HOME/busdk/preferences.json`**, or **`~/.config/busdk/preferences.json`** when `XDG_CONFIG_HOME` is not set.

The directory is created automatically on first write.
All consumers should use this same resolution so every BusDK tool reads the same file.

### Key-path grammar

Keys are dot-separated paths.
Each segment may contain only lowercase letters (`a-z`), digits (`0-9`), hyphens (`-`), and underscores (`_`).
Uppercase characters are not allowed.

Invalid keys (for example empty segment, disallowed characters, or leading/trailing dot) are rejected with usage error `2`.

Recommended convention: first segment is module namespace (for example `bus-agent`, `bus-dev`, `bus`), then module-defined subkeys.
For example `bus-agent.runtime` and `bus-dev.ui.theme`.

### Global flags

Standard global flags are supported; see [Standard global flags](../cli/global-flags).
`--quiet` and `--verbose` are mutually exclusive (usage error `2`).
`--output` writes normal command output to file.
Diagnostics and errors always go to stderr.

### Examples

Set a string preference and read it back:

```bash
bus preferences set bus-agent.runtime gemini
bus preferences get bus-agent.runtime
bus preferences set bus-run.default-script send-feedback
```

Store a JSON object for a module that expects structured options:

```bash
bus preferences set-json bus-dev.ui '{"theme":"dark","density":"compact"}'
bus preferences get bus-dev.ui
```

List all keys under the `bus-dev` namespace:

```bash
bus preferences list bus-dev
bus preferences list bus-run
```

Remove a preference:

```bash
bus preferences unset bus-agent.runtime
bus preferences unset bus-run.default-script
```

### Files

The module reads and writes exactly one user-level preferences file at the resolved path above.
The file is JSON with reserved `version` and `values` map.
Writes are atomic (temp file + rename).
The module does not read/write workspace files or network resources.

### Security and secrets

Preferences may contain runtime defaults and local behavior settings.
They are **not** for secrets.
Do not store passwords, API keys, or credentials in this file.
Use OS credential store or external secret manager for sensitive values.

### Exit status and errors

Exit code `0` means success; for `unset`, this includes the case where the key was already absent. Exit code `1` means execution failure, such as unreadable or unwritable preferences file path. Exit code `2` means invalid usage, such as invalid key path or invalid JSON for `set-json`, and prints a deterministic message to stderr.

When `get` is called for a key that is not present, the command exits with a non-zero status and a concise error on stderr. Error messages are always on stderr.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus preferences set bus-agent.runtime openai
preferences set bus-agent.runtime openai

# same as: bus preferences set-json bus-dev.ui '{"theme":"light","density":"comfortable"}'
preferences set-json bus-dev.ui '{"theme":"light","density":"comfortable"}'

# same as: bus preferences list bus-agent
preferences list bus-agent
```


### Development state

**Value promise:** Store and retrieve user-level preferences (e.g. default agent runtime, output format) so [bus-agent](./bus-agent) and other CLI callers get consistent defaults across invocations without workspace-specific config.

**Use cases:** [Developer module workflow](../implementation/development-status#developer-module-workflow).

**Completeness:** 70% (Broadly usable) — get, set, set-json, unset, and list verified by e2e; key-path and format behavior test-backed.

**Use case readiness:** Developer module workflow: 70% — get, set, set-json, unset, list verified; key-path validation for list would complete.

**Current:** get/set/set-json/unset/list and global-flag behavior are test-verified.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-preferences](../sdd/bus-preferences).

**Planned next:** Key-path validation for list; canonical JSON for get/list; unit tests for path resolution (BUS_PREFERENCES_PATH, XDG, Windows).

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-agent](./bus-agent) and the CLI read preferences for agent and output settings.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-config">bus-config</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-data">bus-data</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-preferences](../sdd/bus-preferences)
- [Workspace configuration](../data/workspace-configuration)
- [Standard global flags](../cli/global-flags)
