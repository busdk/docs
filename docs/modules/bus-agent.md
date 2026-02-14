---
title: bus agent — diagnostics and development helper for the agent runner
description: CLI reference for bus agent: detect enabled runtimes, render prompt templates, run an agent with a prompt, format NDJSON output; for diagnostics and development only.
---

## bus-agent

### Name

`bus agent` — diagnostics and development helper for the BusDK agent runner layer.

### Synopsis

`bus agent [-h] [-V] [-v] [-q] [-C <dir>] [-o <file>] [--color <auto|always|never>] [--no-color] <command> [options]`

Commands: **`detect`**, **`set`**, **`render`**, **`run`**, **`format`**. These operations are intended for diagnostics and development (for example, checking which agent runtimes are available, testing prompt templates, or formatting raw agent output). They do not implement business workflows; higher-level modules such as [bus dev](./bus-dev) use the same agent runner via the library and provide workflow-specific behavior (commit, work, spec, e2e).

`bus agent detect [-1|--first]` — list available agent runtimes (first is the default); with `-1` or `--first`, output only the default runtime.  
`bus agent set runtime <runtime>` — set the default agent (e.g. `cursor`, `gemini`) via the bus-preferences Go library.  
`bus agent set model <value>` — set the default model (default when unset is `auto`).  
`bus agent set output-format <ndjson|text>` — set the default output format (default when unset: `text`).  
`bus agent set timeout <duration>` — set the default run timeout (e.g. `60m`).  
`bus agent render (--template <file> | --text <text>) --var KEY=VALUE [--var KEY=VALUE ...]` — render a prompt template with the given variables and fail if any `{{PLACEHOLDER}}` remains unresolved.  
`bus agent run [--agent <runtime>] [--timeout <duration>] [--workdir <dir>] (--prompt <file> | --text <text>)` — run the selected agent with the given prompt and stream output in a deterministic, script-safe way.  
`bus agent format [--runtime <runtime>]` — read raw agent output (e.g. NDJSON) from stdin and write formatted, human-readable text to stdout.

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus agent` is a thin CLI on top of the BusDK agent runner library. The runner centralizes how external agent runtimes (Cursor CLI, Codex, Gemini CLI, Claude CLI) are invoked so that other modules can use a single, deterministic contract for templating, timeout handling, and output capture. This CLI exposes that contract for diagnostics and development: you can see which runtimes are enabled, render a template without running an agent, run an agent with a prompt under explicit timeout and workdir, and format raw agent output for readability. The tool does not execute Git, does not read or write workspace datasets, and does not define workflow semantics; those belong to modules such as [bus dev](./bus-dev), which depend on the agent runner library. All paths and the working directory are resolved relative to the current directory unless you set `-C` / `--chdir`. Command results go to stdout; diagnostics and progress go to stderr.

### Commands

**`detect`** — List the agent runtimes that are currently available. A runtime is available if its CLI executable is found in PATH and is executable and not disabled by user configuration. Output is one runtime identifier per line, in the same effective order used for automatic default selection (user-configured order if present, otherwise alphabetical by runtime ID), so the first line is always the runtime that would be selected for `bus agent run` when no `--agent` or preference override is set. Use this to verify that at least one runtime is available before running workflow commands in [bus dev](./bus-dev), or to see at a glance which agent would be used by default. With **`--first`** (or **`-1`**), output only that default runtime as a single line; if no runtime is available, the command exits with code 1. Scripts can use `bus agent detect --first` to obtain the default agent ID without parsing the full list.

**`render`** — Render a prompt template with the supplied variables and print the result to stdout. You must supply either `--template <file>` (path to a UTF-8 file containing the template) or `--text <text>` (the template string). Variables are passed with `--var KEY=VALUE`; you can repeat `--var` for multiple keys. Templates use `{{VARIABLE}}` placeholders. Rendering is deterministic; every placeholder must be supplied. If a required variable is missing or any `{{...}}` token remains after substitution, the command fails with invalid usage (exit 2) and no external process is run. Use this to test template expansion or to produce a final prompt for inspection before passing it to `bus agent run`.

**`run`** — Run the selected agent runtime with a prompt and stream its output. You must supply either `--prompt <file>` (path to a UTF-8 file whose contents are the prompt) or `--text <text>` (the prompt string). The effective working directory for the agent is the current directory unless you set `--workdir <dir>`. The run is subject to a timeout; use `--timeout <duration>` (e.g. `30s`, `5m`) or rely on the default. Which runtime is used is determined by the resolution order: `--agent`, then `BUS_AGENT`, then `bus-agent.runtime`, then first available in the effective order (see Agent runtimes and installation below). If a configured runtime is disabled, the tool prints a warning and uses the next source. At the start of the run, the tool prints to stderr which agent and model are in use. Output is streamed in a script-safe, non-interactive manner. If the selected runtime is not installed or not in PATH, the command fails with a clear diagnostic and the canonical installation URL for that runtime.

**`set`** — Set a bus-agent persistent preference via the [bus-preferences](./bus-preferences) Go library (no shell-out to `bus preferences`). The CLI provides a dedicated subcommand for each key: **`bus agent set runtime <runtime>`** (e.g. `cursor`, `gemini`), **`bus agent set model <value>`** (default when unset: `auto`), **`bus agent set output-format <ndjson|text>`** (default when unset: `text`), **`bus agent set timeout <duration>`** (e.g. `60m`). Each writes the corresponding key in the table under Preference settings below. Invalid value yields exit 2.

**`format`** — Read raw agent output from stdin and write formatted text to stdout. This is useful when you have captured NDJSON or other backend-specific output and want human-readable text. Use `--runtime <runtime>` to select the formatter for the given backend (e.g. Cursor-style NDJSON). If the runtime is omitted, the tool may use a default or infer from the input where possible; see `bus agent format --help` for the current behavior.

### Global flags

These flags apply to all subcommands. They match the [standard global flags](../cli/global-flags) shared by BusDK modules. They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are passed to the subcommand.

- **`-h`**, **`--help`** — Print help to stdout and exit 0. Other flags and arguments are ignored when help is requested.
- **`-V`**, **`--version`** — Print the tool name and version to stdout and exit 0.
- **`-v`**, **`--verbose`** — Send verbose progress and diagnostics to stderr. You can repeat the flag (e.g. `-vv`) to increase verbosity. Verbose output does not change what is written to stdout or to the file given by `--output`.
- **`-q`**, **`--quiet`** — Suppress normal command result output. When quiet is set, only errors go to stderr. Exit codes are unchanged. You cannot combine `--quiet` with `--verbose`; doing so is invalid usage (exit 2).
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective working directory. All paths and the agent run directory are resolved from this directory. If it does not exist or is not accessible, the command exits with code 1.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of stdout. The file is created or truncated. Errors and diagnostics still go to stderr. If both `--output` and `--quiet` are used, quiet wins: no output is written to the file.
- **`--color <mode>`** — Control colored output on stderr. `<mode>` must be `auto`, `always`, or `never`. Invalid value is usage error (exit 2).
- **`--no-color`** — Same as `--color=never`.

Command results (e.g. detect list, rendered prompt, formatted output) are written to stdout. Diagnostics, progress, and agent stream output are written to stderr unless otherwise documented for a subcommand.

### Project instructions (AGENTS.md)

The agent runner treats **AGENTS.md** at the repository root as the canonical, vendor-neutral source of project instructions for each run. Instruction discovery follows a root-to-cwd layering model; where a runtime supports directory-scoped instructions, the one closest to the current working directory takes precedence for that scope. The runner prefers per-invocation flags and environment variables to enable AGENTS.md; it uses repo-local file creation or merge only when necessary, and when it does, it never removes or rewrites your existing content — changes are additive only, with clearly marked Bus-owned blocks. The only exception is the legacy Cursor rule file at `.cursor/rules/{bus-NAME}.mdc`, which may be replaced or migrated as part of standardizing on AGENTS.md. If AGENTS.md is missing or too large for the runtime's limits, the run still proceeds with the prompt you supplied and any instruction content that fits; the runner does not fail solely because AGENTS.md is absent or over limit. The full contract (per-runtime knobs, allowed repo-local files, and fallback behavior) is defined in the [module SDD](../sdd/bus-agent); the list below summarizes how each runtime is configured.

**Codex.** The child process runs with its working directory set to the project (repo root or your chosen workdir). `CODEX_HOME` is set to a repo-local directory so no global state is used or mutated; all state and caches stay inside the repository. AGENTS.md is discovered natively by Codex when the workdir is the repo root; no repo-local file changes are required.

**Cursor.** The agent is invoked from the repository root so Cursor's native AGENTS.md loading applies. No global Cursor configuration is edited. When stricter enforcement is needed, Bus may add Bus-owned rule files under `.cursor/rules/` in an additive way only; existing user rules are not touched. The legacy file `.cursor/rules/{bus-NAME}.mdc` may be replaced or migrated (e.g. merged into AGENTS.md and removed) as part of standardization.

**Gemini CLI.** Repo-local `.gemini/settings.json` can be added or merged to configure context discovery to prefer or include AGENTS.md; `.geminiignore` controls scan scope. Merges are additive with Bus-owned markers; your existing content is never removed or rewritten. Per-run environment or flag-based system-instruction injection is used only as a fallback when repo-local config is undesirable.

**Claude Code.** The preferred approach is to inject AGENTS.md via command-line system prompt append on each run (with safeguards for command length and size). If that is not possible, a last-resort compatibility shim is to create or append a clearly marked Bus-owned block in `CLAUDE.md` that imports or references `@AGENTS.md`; existing CLAUDE.md content is never modified or removed.

### Agent runtimes and installation

The agent runner supports four runtimes: **Gemini CLI**, **Cursor CLI**, **Claude CLI**, and **Codex**. Each is a separate external CLI; Bus Agent does not embed provider SDKs or call model APIs directly. When a selected runtime is not installed or not in PATH, the tool reports that on stderr and directs you to the canonical installation reference for that runtime. Those references are:

- **Gemini CLI** — https://geminicli.com/
- **Cursor CLI** — https://cursor.com/docs/cli/overview
- **Claude CLI** — https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started
- **Codex** — https://developers.openai.com/codex/cli/

Runtime selection for `bus agent run` uses this order (same logic as [bus dev](./bus-dev) when it delegates to the bus-agent library, but without bus-dev-only sources): (1) **`--agent`** for that invocation, (2) **`BUS_AGENT`** (session default), (3) **`bus-agent.runtime`** from [bus-preferences](./bus-preferences), (4) **first available** runtime in the effective order. When multiple agents are available and no earlier source is set, the order is alphabetical by runtime ID unless you configure a different order; you can also disable or enable specific agents (see Agent order and enable/disable below). At any step, if the configured runtime is **disabled** by user configuration, the tool prints a warning to stderr and continues with the next source instead of selecting it. Invalid runtime names produce a usage error (exit 2).

### Preference settings (bus-preferences)

Default settings for the agent runner are read and written through the [bus-preferences](./bus-preferences) Go library (user-level preferences file). Session default can also be set with **`BUS_AGENT`** (e.g. `export BUS_AGENT=gemini`); it is consulted after `--agent` and before persistent preferences. The CLI uses these values when resolving the runtime and building run config for `run` when you do not pass `--agent` or a session env.

| Key | Description |
|-----|-------------|
| `bus-agent.runtime` | Default agent runtime when no `--agent` or `BUS_AGENT` is set (e.g. `cursor`, `gemini`). |
| `bus-agent.model` | Default model (e.g. for Cursor). When unset, the default is `auto`. Overridable by `CURSOR_AGENT_MODEL`. |
| `bus-agent.output_format` | Default output format. Valid values: **`ndjson`** (raw structured output), **`text`** (human-readable; NDJSON formatted to text). When unset, the default is `text`. Overridable by `CURSOR_AGENT_OUTPUT_FORMAT`. |
| `bus-agent.timeout` | Default run timeout as a duration string (e.g. `60m`). Overridable by `CURSOR_AGENT_TIMEOUT` or `--timeout`. |

Set preferences with **`bus agent set runtime <runtime>`**, **`bus agent set model <value>`**, **`bus agent set output-format <value>`**, or **`bus agent set timeout <duration>`** (e.g. `bus agent set runtime gemini`), or with the [bus preferences](./bus-preferences) CLI (e.g. `bus preferences set bus-agent.runtime gemini`). Inspect with `bus preferences get bus-agent.runtime`. The bus-agent CLI uses the bus-preferences Go library directly; it does not shell out to `bus preferences`. The bus-agent library exposes helpers such as `GetDefaultRuntime`, `SetDefaultRuntime`, `GetDefaultRunConfig`, and `SetDefault*` so that callers and the CLI can read and write these values without touching the preferences file path.

### Agent order and enable/disable

When multiple agent runtimes are available (CLI found in PATH) and no persistent or session preference is set, the automatic default is chosen from that set in a deterministic order. By default the order is alphabetical by runtime ID (e.g. claude, codex, cursor, gemini); the first available runtime in that order is used.

You can change which agent is used first by configuring the order: supply an ordered list of runtime IDs so that the first available runtime in that list becomes the automatic default. You can also disable specific runtimes (exclude them from the available set) or enable only a subset (so that only those runtimes are considered available). Configuration is via environment variables or, when supported, [bus-preferences](./bus-preferences); the exact variable names and format are documented in the [module SDD](../sdd/bus-agent) (FR-AGT-005a). For example, you might set an order so that `gemini` is tried first, then `cursor`, and disable `codex` and `claude` for the session.

### Files

`bus agent` does not read or write workspace datasets, schemas, or `datapackage.json`. It may read prompt template files or prompt files when you pass `--template` or `--prompt`. The default agent and run-config defaults (model, output format, timeout) are read from user-level preferences via the [bus-preferences](./bus-preferences) Go library; the user sets them with the [bus preferences](./bus-preferences) CLI (e.g. `bus preferences set bus-agent.runtime gemini`). The module does not own the preferences file — bus-preferences owns it — so configuration for persistent defaults is through [bus preferences](./bus-preferences); flags and environment still override for the session or single invocation. When the runner enables AGENTS.md for a runtime that requires repo-local config (e.g. Gemini or Claude), it may create or merge files only under the additive, Bus-owned rules described in [Project instructions (AGENTS.md)](#project-instructions-agentsmd) and in the [module SDD](../sdd/bus-agent); it never edits user configuration outside the project working directory.

### Exit status and errors

- **0** — Success.
- **1** — Execution failure: agent run failed, timeout exceeded, selected runtime not found or not executable, could not execute the agent CLI, or no runtime available when using `detect --first`.
- **2** — Invalid usage: unknown command or flag, missing required argument (e.g. `--template` or `--text` for render), unresolved template placeholder, invalid runtime name, invalid `set` value, or invalid `--timeout` or path.

Template rendering failures (missing variable, unresolved `{{...}}`) occur before any external execution and always result in exit 2. When the selected runtime is missing, the tool exits with code 1 and includes the canonical installation URL for that runtime in the diagnostic.

### Development state

Detect, render, run, and format work today; e2e tests cover detect and run. Planned next: alphabetical backend order and default output format `text`; order and enable/disable configuration; AGENTS.md discovery with root-to-cwd “closest wins”; per-runtime instruction adapters; deterministic fallback when AGENTS.md is missing or over-size. Default agent selection will use [bus-config](./bus-config) (GetDefaultAgent / SetDefaultAgent). See [Development status](../implementation/development-status).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-dev">bus-dev</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bfl">bus-bfl</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-agent](../sdd/bus-agent)
- [bus-preferences CLI reference](./bus-preferences)
- [bus-dev CLI reference](./bus-dev)
- [CLI: Global flags](../cli/global-flags)
- [Gemini CLI — install](https://geminicli.com/)
- [Cursor CLI — overview and install](https://cursor.com/docs/cli/overview)
- [Claude Code — get started / install](https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started)
- [Codex CLI — install](https://developers.openai.com/codex/cli/)
