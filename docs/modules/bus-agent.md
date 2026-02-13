---
title: bus agent — diagnostics and development helper for the agent runner
description: CLI reference for bus agent: detect enabled runtimes, render prompt templates, run an agent with a prompt, format NDJSON output; for diagnostics and development only.
---

## bus-agent

### Name

`bus agent` — diagnostics and development helper for the BusDK agent runner layer.

### Synopsis

`bus agent [-h] [-V] [-v] [-q] [-C <dir>] [-o <file>] [--color <auto|always|never>] [--no-color] <command> [options]`

Commands: **`detect`**, **`render`**, **`run`**, **`format`**. These operations are intended for diagnostics and development (for example, checking which agent runtimes are available, testing prompt templates, or formatting raw agent output). They do not implement business workflows; higher-level modules such as [bus dev](./bus-dev) use the same agent runner via the library and provide workflow-specific behavior (commit, work, spec, e2e).

`bus agent detect` — list agent runtimes that are enabled (executable found in PATH).  
`bus agent render (--template <file> | --text <text>) --var KEY=VALUE [--var KEY=VALUE ...]` — render a prompt template with the given variables and fail if any `{{PLACEHOLDER}}` remains unresolved.  
`bus agent run [--agent <runtime>] [--timeout <duration>] [--workdir <dir>] (--prompt <file> | --text <text>)` — run the selected agent with the given prompt and stream output in a deterministic, script-safe way.  
`bus agent format [--runtime <runtime>]` — read raw agent output (e.g. NDJSON) from stdin and write formatted, human-readable text to stdout.

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus agent` is a thin CLI on top of the BusDK agent runner library. The runner centralizes how external agent runtimes (Cursor CLI, Codex, Gemini CLI, Claude CLI) are invoked so that other modules can use a single, deterministic contract for templating, timeout handling, and output capture. This CLI exposes that contract for diagnostics and development: you can see which runtimes are enabled, render a template without running an agent, run an agent with a prompt under explicit timeout and workdir, and format raw agent output for readability. The tool does not execute Git, does not read or write workspace datasets, and does not define workflow semantics; those belong to modules such as [bus dev](./bus-dev), which depend on the agent runner library. All paths and the working directory are resolved relative to the current directory unless you set `-C` / `--chdir`. Command results go to stdout; diagnostics and progress go to stderr.

### Commands

**`detect`** — List the agent runtimes that are currently enabled. A runtime is enabled if its CLI executable is found in PATH and is executable. Output is one runtime identifier per line (e.g. `cursor`, `codex`, `gemini`, `claude`) in a deterministic order. Use this to verify that at least one runtime is available before running workflow commands in [bus dev](./bus-dev), or to confirm which runtime will be chosen when no explicit selection is given.

**`render`** — Render a prompt template with the supplied variables and print the result to stdout. You must supply either `--template <file>` (path to a UTF-8 file containing the template) or `--text <text>` (the template string). Variables are passed with `--var KEY=VALUE`; you can repeat `--var` for multiple keys. Templates use `{{VARIABLE}}` placeholders. Rendering is deterministic; every placeholder must be supplied. If a required variable is missing or any `{{...}}` token remains after substitution, the command fails with invalid usage (exit 2) and no external process is run. Use this to test template expansion or to produce a final prompt for inspection before passing it to `bus agent run`.

**`run`** — Run the selected agent runtime with a prompt and stream its output. You must supply either `--prompt <file>` (path to a UTF-8 file whose contents are the prompt) or `--text <text>` (the prompt string). The effective working directory for the agent is the current directory unless you set `--workdir <dir>`. The run is subject to a timeout; use `--timeout <duration>` (e.g. `30s`, `5m`) or rely on the default. Which runtime is used is determined by `--agent <runtime>` (one of `cursor`, `codex`, `gemini`, `claude`); if omitted, the same resolution order as in [bus dev](./bus-dev) applies (explicit selection, then session preference, then automatic default from enabled runtimes). Output is streamed in a script-safe, non-interactive manner. If the selected runtime is not installed or not in PATH, the command fails with a clear diagnostic and the canonical installation URL for that runtime.

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

### Agent runtimes and installation

The agent runner supports four runtimes: **Gemini CLI**, **Cursor CLI**, **Claude CLI**, and **Codex**. Each is a separate external CLI; Bus Agent does not embed provider SDKs or call model APIs directly. When a selected runtime is not installed or not in PATH, the tool reports that on stderr and directs you to the canonical installation reference for that runtime. Those references are:

- **Gemini CLI** — https://geminicli.com/
- **Cursor CLI** — https://cursor.com/docs/cli/overview
- **Claude CLI** — https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started
- **Codex** — https://developers.openai.com/codex/cli/

Runtime selection for `bus agent run` follows the same rules as in [bus dev](./bus-dev): explicit `--agent` for the invocation, then session preference (e.g. environment variable if supported), then automatic default from the set of enabled runtimes in a documented preference order. Invalid runtime names produce a usage error (exit 2).

### Files

`bus agent` does not read or write workspace datasets, schemas, or `datapackage.json`. It may read prompt template files or prompt files when you pass `--template` or `--prompt`. Configuration is via flags and environment only; the module does not own repository or workspace state.

### Exit status and errors

- **0** — Success.
- **1** — Execution failure: agent run failed, timeout exceeded, selected runtime not found or not executable, or could not execute the agent CLI.
- **2** — Invalid usage: unknown command or flag, missing required argument (e.g. `--template` or `--text` for render), unresolved template placeholder, invalid runtime name, or invalid `--timeout` or path.

Template rendering failures (missing variable, unresolved `{{...}}`) occur before any external execution and always result in exit 2. When the selected runtime is missing, the tool exits with code 1 and includes the canonical installation URL for that runtime in the diagnostic.

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
- [bus-dev CLI reference](./bus-dev)
- [CLI: Global flags](../cli/global-flags)
- [Gemini CLI — install](https://geminicli.com/)
- [Cursor CLI — overview and install](https://cursor.com/docs/cli/overview)
- [Claude Code — get started / install](https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started)
- [Codex CLI — install](https://developers.openai.com/codex/cli/)
