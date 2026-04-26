---
title: bus agent — diagnostics and development helper for the agent runner
description: "CLI reference for bus agent: detect enabled runtimes, render prompt templates, run an agent with a prompt, format NDJSON output; for diagnostics and development only."
---

## `bus-agent` — diagnostics and development helper for the BusDK agent runner layer

### Synopsis

`bus agent [-h] [-V] [-v] [-q] [-C <dir>] [-o <file>] [--color <auto|always|never>] [--no-color] <command> [options]`

Commands: **`detect`**, **`set`**, **`render`**, **`run`**, **`format`**. These operations are intended for diagnostics and development (for example, checking which agent runtimes are available, testing prompt templates, or formatting raw agent output). They do not implement business workflows; higher-level modules such as [bus dev](./bus-dev) use the same agent runner via the library and provide workflow-specific behavior (commit, work, spec, e2e).

`bus agent detect [-1|--first]` — list available agent runtimes; with `-1` or `--first`, output only the configured default runtime.  
`bus agent set runtime <runtime>` — set the default agent (e.g. `cursor`, `codex`, `codex:local`, `gemini`) via the bus-preferences Go library.  
`bus agent set model <value>` — set the default model (default when unset is `auto`).  
`bus agent set model-reasoning-effort <minimal|low|medium|high|xhigh>` — set default model reasoning effort (for runtimes that support it).  
`bus agent set model-verbosity <low|medium|high>` — set default model verbosity (for runtimes that support it).  
`bus agent set model-reasoning-effort-for-model <model> <minimal|low|medium|high|xhigh>` — set model-specific reasoning effort override.  
`bus agent set model-verbosity-for-model <model> <low|medium|high>` — set model-specific verbosity override.  
`bus agent set output-format <ndjson|text>` — set the default output format (default when unset: `text`).  
`bus agent set timeout <duration>` — set the default run timeout (e.g. `60m`).  
`bus agent render (--template <file> | --text <text>) --var KEY=VALUE [--var KEY=VALUE ...]` — render a prompt template with the given variables and fail if any {% raw %}`{{PLACEHOLDER}}`{% endraw %} remains unresolved.  
`bus agent run [--agent <runtime>] [--timeout <duration>] [--workdir <dir>] (--prompt <file> | --text <text>)` — run the selected agent with the given prompt and stream output in a deterministic, script-safe way.  
`bus agent format [--runtime <runtime>]` — read raw agent output (e.g. NDJSON) from stdin and write formatted, human-readable text to stdout.

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus agent` is a thin CLI on top of the BusDK agent runner library.

The runner centralizes how external runtimes (Cursor CLI, Codex, Gemini CLI, Claude CLI) are invoked.
The runtime token `codex:local` selects the Codex backend in local mode (`--oss`).
Codex-specific argument behavior and setup guidance are documented in [Codex CLI reference and argument patterns](../references/codex-cli).
Modules share one deterministic contract for templating, timeout handling, and output capture.

This CLI exposes that contract for diagnostics and development:
detect runtimes, render templates, run an agent with explicit timeout/workdir, and format raw output.

The module also provides a reusable Go app-server integration package for local
assistant sessions. The package is engine-oriented so additional app-server
engines can be added later while callers keep the same lifecycle, event, and
approval interfaces.

The tool does not execute Git, does not read or write workspace datasets, and does not define workflow semantics. Workflow behavior belongs to modules such as [bus dev](./bus-dev).

Paths are resolved relative to the current directory unless you set `-C` / `--chdir`. Command results go to stdout; diagnostics and progress go to stderr.

For a practical `.bus` file that combines `agent` with `dev` and `run` commands in one sequence, see [`.bus` getting started — multiple commands together](../cli/bus-script-files-multi-command-getting-started).

From **BusDK v0.0.26** onward, `bus agent` includes Codex runtime support in the standard runtime set.
Gemini and Claude integrations are still in-progress and not yet fully verified by end-to-end coverage.

### Commands

**`detect`** — List currently available agent runtimes. A runtime is available when its CLI executable is in `PATH`, executable, and not disabled by configuration.

Output is one runtime ID per line. This command shows what is available, but it does not choose a runtime for you.

With **`--first`** (or **`-1`**), output only the configured default runtime. If no default is configured, the command exits 1 and prints the detected runtime options, the supported runtime options that were not detected, and an example command such as `bus agent set runtime codex`.

**`render`** — Render a prompt template with the supplied variables and print the result to stdout. You must supply either `--template <file>` (path to a UTF-8 file containing the template) or `--text <text>` (the template string). Variables are passed with `--var KEY=VALUE`; you can repeat `--var` for multiple keys. Templates use {% raw %}`{{VARIABLE}}`{% endraw %} placeholders. Rendering is deterministic; every placeholder must be supplied. If a required variable is missing or any {% raw %}`{{...}}`{% endraw %} token remains after substitution, the command fails with invalid usage (exit 2) and no external process is run. Use this to test template expansion or to produce a final prompt for inspection before passing it to `bus agent run`.

**`run`** — Run the selected agent runtime with a prompt and stream output.

Supply either `--prompt <file>` or `--text <text>`. Agent working directory defaults to the current directory unless you set `--workdir <dir>`. Timeout comes from `--timeout <duration>` or defaults.

Runtime resolution order is: `--agent`, `BUS_AGENT`, then `bus-agent.runtime`. If none is configured, the tool exits 1 and prints setup guidance instead of silently selecting Cursor, Codex, Gemini, Claude, or any other runtime.

At start, bus-agent prints the active agent and model to stderr. If the selected runtime is missing from `PATH`, the command exits with a clear diagnostic and installation URL.

**`set`** — Set a bus-agent persistent preference via the [bus-preferences](./bus-preferences) Go library (no shell-out to `bus preferences`). The CLI provides a dedicated subcommand for each key: **`bus agent set runtime <runtime>`** (e.g. `cursor`, `codex:local`, `gemini`), **`bus agent set model <value>`** (default when unset: `auto`), **`bus agent set model-reasoning-effort <minimal|low|medium|high|xhigh>`**, **`bus agent set model-verbosity <low|medium|high>`**, **`bus agent set model-reasoning-effort-for-model <model> <minimal|low|medium|high|xhigh>`**, **`bus agent set model-verbosity-for-model <model> <low|medium|high>`**, **`bus agent set output-format <ndjson|text>`** (default when unset: `text`), **`bus agent set timeout <duration>`** (e.g. `60m`). Each writes the corresponding key in the table under Preference settings below. Invalid value yields exit 2.

**`format`** — Read raw agent output from stdin and write formatted text to stdout. This is useful when you have captured NDJSON or other backend-specific output and want human-readable text. Use `--runtime <runtime>` to select the formatter for the given backend (e.g. Cursor-style NDJSON). If the runtime is omitted, the tool may use a default or infer from the input where possible; see `bus agent format --help` for the current behavior.

### Global flags

Standard global flags are supported; see [Standard global flags](../cli/global-flags).
`--quiet` and `--verbose` are mutually exclusive (usage error `2`).
Normal command results go to stdout (or `--output`), diagnostics to stderr.

### Project instructions (AGENTS.md)

The runner treats root `AGENTS.md` as canonical project instruction source.
It uses runtime-specific mechanisms to load those instructions with additive, non-destructive behavior.
If `AGENTS.md` is missing or too large, execution still proceeds with best-effort prompt content.
Per-runtime implementation details are documented in [Module reference: bus-agent](../modules/bus-agent).

### Agent runtimes and installation

Supported runtimes: **Gemini CLI**, **Cursor CLI**, **Claude CLI**, and **Codex**.
Each runtime is an external CLI binary; bus-agent does not embed provider SDKs.
When selected runtime is missing from `PATH`, command exits with clear install guidance.

Install references: Gemini CLI (<https://geminicli.com/>), Cursor CLI (<https://cursor.com/docs/cli/overview>), Claude CLI (<https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started>), and Codex CLI (<https://developers.openai.com/codex/cli/>).
For Codex-specific argv details (`--oss`, `--model`, `-c model_reasoning_effort=...`, `-c model_verbosity=...`, workdir and add-dir handling), use [Codex CLI reference and argument patterns](../references/codex-cli).

Runtime selection order for `bus agent run`:
`--agent`, then `BUS_AGENT`, then `bus-agent.runtime` from [bus-preferences](./bus-preferences). When none is configured, run `bus agent detect` to inspect available runtimes, then choose one with `bus agent set runtime <runtime>`.

Invalid runtime names return usage error (`2`).

### Preference settings (bus-preferences)

Default settings are read/written through the [bus-preferences](./bus-preferences) Go library.
Session default can also be set with `BUS_AGENT`.

| Key | Description |
|-----|-------------|
| `bus-agent.runtime` | Default agent runtime when no `--agent` or `BUS_AGENT` is set (e.g. `cursor`, `codex:local`, `gemini`). |
| `bus-agent.model` | Default model (e.g. for Cursor). When unset, the default is `auto`. Overridable by `CURSOR_AGENT_MODEL`. |
| `bus-agent.model_reasoning_effort` | Default reasoning effort for runtimes that support it (Codex: `minimal`, `low`, `medium`, `high`, `xhigh`). Overridable by `BUS_AGENT_MODEL_REASONING_EFFORT`. |
| `bus-agent.model_verbosity` | Default verbosity for runtimes that support it (Codex: `low`, `medium`, `high`). Overridable by `BUS_AGENT_MODEL_VERBOSITY`. |
| `bus-agent.model_reasoning_effort_for_model.<model>` | Per-model reasoning effort override, used when resolved model matches `<model>`. |
| `bus-agent.model_verbosity_for_model.<model>` | Per-model verbosity override, used when resolved model matches `<model>`. |
| `bus-agent.output_format` | Default output format. Valid values: **`ndjson`** (raw structured output), **`text`** (human-readable; NDJSON formatted to text). When unset, the default is `text`. Overridable by `CURSOR_AGENT_OUTPUT_FORMAT`. |
| `bus-agent.timeout` | Default run timeout as a duration string (e.g. `60m`). Overridable by `CURSOR_AGENT_TIMEOUT` or `--timeout`. |

Set preferences with `bus agent set ...` subcommands or with [bus preferences](./bus-preferences).
Inspect current value with `bus preferences get <key>`.

### Default selection

Bus does not silently choose a default agent runtime from detected tools. When no `--agent`, `BUS_AGENT`, or `bus-agent.runtime` preference is set, commands that need a runtime exit 1 and print which runtimes are available, which supported runtimes were not detected, and how to choose a default.

### Examples

```bash
bus agent detect
bus agent set runtime codex
bus agent detect --first
bus agent render --text "Module={{MODULE}} Ticket={{TICKET}}" \
  --var MODULE=bus-books \
  --var TICKET=FR-1234
bus agent run --agent codex --timeout 15m \
  --workdir ./bus-books \
  --text "Review PLAN.md and propose the next three tasks."
```

### Files

`bus agent` does not read or write workspace datasets, schemas, or `datapackage.json`. It may read prompt template files or prompt files when you pass `--template` or `--prompt`. The default agent and run-config defaults (model, output format, timeout) are read from user-level preferences via the [bus-preferences](./bus-preferences) Go library; the user sets them with the [bus preferences](./bus-preferences) CLI (e.g. `bus preferences set bus-agent.runtime gemini`). The module does not own the preferences file — bus-preferences owns it — so configuration for persistent defaults is through [bus preferences](./bus-preferences); flags and environment still override for the session or single invocation. When the runner enables AGENTS.md for a runtime that requires repo-local config (e.g. Gemini or Claude), it may create or merge files only under the additive, Bus-owned rules described in [Project instructions (AGENTS.md)](#project-instructions-agentsmd) and in the [module reference](../modules/bus-agent); it never edits user configuration outside the project working directory.

### Exit status and errors

Exit code `0` means success. Exit code `1` means execution failure, such as agent run failure, timeout, missing runtime binary, or no runtime available for `detect --first`. Exit code `2` means invalid usage, such as unknown command/flag, missing required argument, unresolved template placeholder, invalid runtime name, invalid `set` value, or invalid timeout/path.

Template rendering failures (missing variable, unresolved {% raw %}`{{...}}`{% endraw %}) occur before any external execution and always result in exit 2. When the selected runtime is missing, the tool exits with code 1 and includes the canonical installation URL for that runtime in the diagnostic.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# runtime diagnostics and explicit run
agent detect --first
agent run --agent codex --timeout 15m --workdir ./bus-books --text "Summarize open TODO items."

# render a deterministic prompt from inline variables
agent render --text "Module={{MODULE}} Ticket={{TICKET}}" --var MODULE=bus-books --var TICKET=FR-1234

# set default runtime for future runs
agent set runtime codex
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-dev">bus-dev</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-run">bus-run</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module reference: bus-agent](../modules/bus-agent)
- [Codex CLI reference and argument patterns](../references/codex-cli)
- [`.bus` getting started — multiple commands together](../cli/bus-script-files-multi-command-getting-started)
- [bus-preferences CLI reference](./bus-preferences)
- [bus-dev CLI reference](./bus-dev)
- [CLI: Global flags](../cli/global-flags)
- [Gemini CLI — install](https://geminicli.com/)
- [Cursor CLI — overview and install](https://cursor.com/docs/cli/overview)
- [Claude Code — get started / install](https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started)
- [Codex CLI — install](https://developers.openai.com/codex/cli/)
- [OpenAI Help Center: Using Codex with your ChatGPT plan](https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan)
