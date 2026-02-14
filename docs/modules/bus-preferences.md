---
title: bus preferences — user-level preference storage
description: Set, get, list, and unset user-level BusDK preferences in a namespaced key-value file outside any workspace; no Git or network.
---

## `bus-preferences` — user-level, cross-workspace preference storage for BusDK

### Synopsis

`bus preferences [-h] [-V] [-v] [-q] [-C <dir>] [-o <file>] [--color <auto|always|never>] [--no-color] <command> [<args>]`

Commands: **`set`**, **`set-json`**, **`get`**, **`unset`**, **`list`**.

`bus preferences set <key> <value>` — store a string value for `<key>`.  
`bus preferences set-json <key> <json>` — store an arbitrary JSON value for `<key>`.  
`bus preferences get <key>` — print the value for `<key>` to stdout.  
`bus preferences unset <key>` — remove `<key>` if present.  
`bus preferences list [<prefix>]` — list all keys, optionally filtered by key prefix, in sorted order.

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus preferences` owns user-level BusDK configuration stored in a single preferences file on your machine. That file lives outside any workspace repository and is not used for accounting data or [workspace configuration](../data/workspace-configuration) (such as `datapackage.json`). Instead it holds optional defaults and runtime preferences that apply across invocations and contexts: for example default tool selections, output formatting defaults, or module-specific options that you want to persist once and reuse everywhere. Other BusDK modules may read and write preferences under their own namespaces so that behavior stays consistent without you re‑specifying the same options in every workspace.

The store is a generic namespaced key-value file. Each key is a dot-separated path; the first segment is typically a module namespace (e.g. `bus-agent`, `bus-dev`) and the rest are module-defined subkeys. Bus preferences does not interpret what those keys mean — it only enforces a canonical key grammar and stores values. Individual modules document and validate the preference keys they use. The module performs no Git or network operations; it only reads and writes the preferences file at a deterministic location.

### Commands

**`set <key> <value>`** — Set `<key>` to the string `<value>`. The value is stored as a JSON string. The preferences file is created if it does not exist. If the key is invalid (see Key-path grammar below), the command exits with code 2.

**`set-json <key> <json>`** — Set `<key>` to an arbitrary JSON value. `<json>` must be valid JSON (object, array, string, number, boolean, or null). The module validates the input as JSON before writing. Invalid JSON or an invalid key yields exit code 2.

**`get <key>`** — Print the stored value for `<key>` to stdout. If the stored value is a JSON string, the raw string is printed without surrounding quotes. For other JSON types, canonical JSON is printed. If the key is missing, the command exits with a non-zero status and a concise error on stderr. Invalid key exits with code 2.

**`unset <key>`** — Remove `<key>` from the preferences file if it exists. Exits 0 whether or not the key was present. Invalid key exits with code 2.

**`list [<prefix>]`** — List all stored keys in lexicographic order. If `<prefix>` is given, only keys whose path matches the prefix are listed. Output is deterministic and line-oriented: each line is `key=<canonical-json>`. Invalid prefix (e.g. invalid key grammar) exits with code 2.

### Where the preferences file lives

The preferences file path is resolved in this order:

1. If the environment variable **`BUS_PREFERENCES_PATH`** is set, that path is used exactly.
2. On Windows, the default is **`%APPDATA%\BusDK\preferences.json`**.
3. On Unix-like systems, the default is **`$XDG_CONFIG_HOME/busdk/preferences.json`**, or **`~/.config/busdk/preferences.json`** if `XDG_CONFIG_HOME` is not set.

The directory for the file is created automatically when you first write a preference. All consumers should use this same resolution so that every BusDK tool sees the same file; the [module SDD](../sdd/bus-preferences) defines the contract for implementations.

### Key-path grammar

Keys are dot-separated paths. Each segment may contain only lowercase letters (`a-z`), digits (`0-9`), hyphens (`-`), and underscores (`_`). Uppercase characters are not allowed so that keys have a single canonical form. Invalid keys (e.g. empty segment, disallowed character, or leading/trailing dot) are rejected with a usage error and exit code 2.

The recommended convention is to use the first segment as a module namespace (e.g. `bus-agent`, `bus-dev`, `bus`) and the rest as module-defined subkeys. For example `bus-agent.runtime` and `bus-dev.ui.theme` keep different modules’ preferences from colliding. Bus preferences does not enforce what namespaces mean; it only enforces the key grammar and storage invariants.

### Global flags

These flags apply to all subcommands and match the [standard global flags](../cli/global-flags). They can appear in any order before the command. A lone `--` ends flag parsing; any following tokens are passed to the subcommand.

- **`-h`**, **`--help`** — Print help to stdout and exit 0. Other flags and arguments are ignored when help is requested.
- **`-V`**, **`--version`** — Print the tool name and version to stdout and exit 0.
- **`-v`**, **`--verbose`** — Send verbose diagnostics to stderr. You can repeat the flag (e.g. `-vv`) to increase verbosity. Verbose output does not change what is written to stdout.
- **`-q`**, **`--quiet`** — Suppress normal command result output. When quiet is set, only errors go to stderr. Exit codes are unchanged. You cannot combine `--quiet` with `--verbose`; doing so is invalid usage (exit 2).
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective working directory. For `bus preferences` this mainly affects any module that might resolve paths relative to the current directory; the preferences file itself is always at the resolved user-level path above.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of stdout. The file is created or truncated. Errors and diagnostics still go to stderr.
- **`--color <mode>`** — Control colored output on stderr. `<mode>` must be `auto`, `always`, or `never`. Invalid value is usage error (exit 2).
- **`--no-color`** — Same as `--color=never`.

Command results (e.g. `get` output or `list` lines) are written to stdout when produced. Diagnostics and errors are written to stderr.

### Examples

Set a string preference and read it back:

```bash
bus preferences set bus-agent.runtime gemini
bus preferences get bus-agent.runtime
```

Store a JSON object for a module that expects structured options:

```bash
bus preferences set-json bus-dev.ui '{"theme":"dark","density":"compact"}'
```

List all keys under the `bus-dev` namespace:

```bash
bus preferences list bus-dev
```

Remove a preference:

```bash
bus preferences unset bus-agent.runtime
```

### Files

The module reads and writes exactly one file: the user-level preferences file at the path resolved as described above. That file is a JSON document with a reserved `version` field and a `values` map from key paths to JSON values. Writes are atomic (temp file and rename) so that an interrupted write does not corrupt the file. The module does not read or write workspace files, Git state, or any network resource.

### Security and secrets

Preferences are stored in a user-local file and may contain operational defaults (paths, toggles, chosen runtimes). They are **not** intended for secrets. Do not store passwords, API keys, or other credentials in preferences. Use your operating system’s credential store or an external secret manager for sensitive values. The preferences file is created with user-only permissions where supported; access is controlled by filesystem permissions.

### Exit status and errors

- **0** — Success. For `unset`, exit 0 even if the key was already absent.
- **1** — Execution failure: the preferences file could not be read or written (e.g. directory not writable, disk error).
- **2** — Invalid usage: invalid key path, invalid JSON for `set-json`, or other usage error. A deterministic message is printed to stderr.

When `get` is called for a key that is not present, the command exits with a non-zero status and a concise error on stderr. Error messages are always on stderr.

### Development state

**Value:** Store and retrieve user-level preferences (e.g. default agent runtime, output format) so bus-agent and other CLI callers get consistent defaults across invocations without workspace-specific config.

**Use cases:** [Developer module workflow](../implementation/development-status#developer-module-workflow).

**Completeness:** 70% (Broadly usable) — get, set, set-json, unset, and list verified by e2e; key-path and format behavior test-backed.

**Use case readiness:** Developer module workflow: 70% — get, set, set-json, unset, list verified; key-path validation for list would complete.

**Current:** E2e script `tests/e2e_bus_preferences.sh` proves help, version, invalid color/format and quiet+verbose (exit 2), chdir and terminator, get (missing key exit 1), set and set-json, unset, list with prefix, and that quiet suppresses stdout. Unit tests in `internal/run/run_test.go`, `pkg/preferences/store_test.go`, and `keys_test.go` cover run and store.

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
