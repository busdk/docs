---
title: bus-run
description: "bus run executes user-defined prompts, pipelines, and scripts with agentic support via the bus-agent library; no built-in developer workflows and no dependency on bus-dev. Optional bux shorthand for bus run."
---

## `bus-run` — run user-defined prompts, pipelines, and scripts

### Synopsis

`bus run [-h] [-V] [-v] [-q] [-C <dir>] [-o <file>] [--agent <cursor|codex|gemini|claude>] [--color <auto|always|never>] [--no-color] ( <token> [<token> ...] | set | context | list | pipeline | action | script ) [options]`

**Run:** `bus run <token> [<token> ...]` — Execute one or more user-defined prompt actions, script actions, or pipeline names.

Tokens are resolved and pipeline names are expanded to a flat step sequence. The final sequence is normalized by merging repeated step names in first-appearance order, then run with stop-on-first-failure.

All agent execution uses the [bus-agent](./bus-agent) library. There are no built-in developer operations (no plan, work, spec, e2e, commit, or init).

Management subcommands keep defaults and local definitions organized. Use **`set`** to persist bus-run defaults (agent, model, output-format, timeout) via [bus-preferences](./bus-preferences). Use **`context`** to print the resolved prompt-variable catalog as sorted `KEY=VALUE` lines. Use **`list`** to print runnable tokens and expansions without running steps. Use **`pipeline`** to define, list, or preview pipelines from `.bus/run/<NAME>.yml` or `bus-run.pipeline.<name>`. Use **`action`** for prompt actions in `.bus/run/<NAME>.txt`, and **`script`** for script actions in `.bus/run/<NAME>.sh`, `.bat`, or `.ps1`.

Global **`bus run --help`** shows usage, states that runnable tokens are user-defined only (no built-in operations or pipelines), and directs you to **`bus run list`**, **`bus run pipeline list`**, **`bus run action list`**, and **`bus run script list`** to discover available tokens. No agent or script is run to produce help. **`bus run list`** prints a unified catalog of every runnable token in the current context (directory-local and preference pipelines, prompt actions, script actions) with source and, for pipelines, the normalized expanded step sequence; it does not execute any step.

Directory-local content is under the effective working directory (project root); no Git is required. Paths and the working directory are resolved relative to the current directory unless you set `-C` / `--chdir`. Diagnostics and agent output go to stderr; deterministic results (list, context, pipeline list, action list, script list) go to stdout.

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus run` is an end-user module for running your own prompts, pipelines, and scripts.

It does not implement developer workflows. There are no built-in operations like plan, work, spec, e2e, triage, stage, or commit, and no dependency on [bus dev](./bus-dev).

Agent execution is provided by the [bus-agent](./bus-agent) Go library so runtime selection, prompt templating, and timeout handling stay consistent across BusDK.

You define prompts (`.bus/run/<name>.txt`), pipelines (`.bus/run/<name>.yml` or preference `bus-run.pipeline.<name>`), and scripts (`.bus/run/<name>.sh`, `.bat`, or `.ps1`), then run them by name with `bus run <name>` or by chaining tokens.

For normative behavior and edge cases, see the [module SDD](../sdd/bus-run).

For a practical `.bus` file that combines `run` with `dev` and `agent` commands in one sequence, see [`.bus` getting started — multiple commands together](../cli/bus-script-files-multi-command-getting-started).

From **BusDK v0.0.26** onward, `bus run` can use Codex through the shared `bus-agent` runtime layer (`--agent codex`, `BUS_RUN_AGENT=codex`, `BUS_AGENT=codex`, or preferences). Codex CLI sign-in works with a ChatGPT Plus subscription (and other eligible ChatGPT plans), so prompt and pipeline runs can use subscription-based Codex access. Gemini and Claude runtime paths are available but are still in development and not yet fully end-to-end verified.

**Shorthand: `bux`.** You can add a short alias or wrapper so that `bux` invokes `bus run`, similar to how `npx` is used with `npm`. For example, define a shell alias `alias bux='bus run'` or install a small script named `bux` that runs `bus run "$@"`. Then `bux my-pipeline` or `bux my-action` runs the same as `bus run my-pipeline` or `bus run my-action`. The BusDK install does not create `bux` by default; adding it is optional and left to the user or their environment.

### Commands

**`bus run <token> [<token> ...]`** — Run one or more user-defined steps. Each token is a prompt action name, script action name, or pipeline name. Pipeline names expand to a sequence of prompt and script actions; there are no built-in operations or built-in pipelines. After full expansion, bus-run normalizes the final sequence by merging repeated step names so each name appears once in first-appearance order, then runs the normalized sequence. The first non-zero exit stops the run and becomes the process exit code. When any token resolves to directory-local content, `.bus/run/` is read from the effective working directory (project root); no Git is required. If the project root does not exist or is not accessible, exit 1. Takes the per-directory lock.

**`bus run set agent <runtime>`** — Set the bus-run persistent default agent (`bus-run.agent`) via the bus-preferences library. `<runtime>` must be one of `cursor`, `codex`, `gemini`, or `claude`. Invalid value → exit 2.

**`bus run set model <value>`** — Set the bus-run default model (`bus-run.model`). **`bus run set output-format <ndjson|text>`** — Set the bus-run default output format (`bus-run.output_format`). **`bus run set timeout <duration>`** — Set the bus-run default timeout (`bus-run.timeout`). Each writes only the corresponding `bus-run.*` key. Invalid value → exit 2.

**`bus run context`** — Print the full prompt-variable catalog and current resolved values (one `KEY=VALUE` line per variable, sorted by key) to stdout. Use this when authoring prompt templates or scripts so you can see the same variables the tool injects. Uses the effective working directory to derive catalog values; no Git required. If the effective working directory does not exist or is not accessible, exit 1. Does not take the per-directory lock.

**`bus run list`** — Print every runnable token available in the current context and what each executes, without running any agent, script, or other step. When the effective working directory does not exist or is not accessible, exit 1 with a clear message (same as **bus run context**). When the project root is accessible, output includes directory-local pipelines (source path and normalized expanded step sequence), directory-local prompt actions (`.bus/run/<NAME>.txt`), directory-local script actions (source and platform variants), and preference pipelines (source key and expanded step sequence). Each entry includes token name, type (pipeline, action prompt, or action script), short description or source, and for pipelines the normalized expanded step sequence. Output format is stable and parseable. Does not take the per-directory lock.

**`bus run pipeline set repo NAME TOKEN...`** — Write or overwrite `.bus/run/NAME.yml` under the project root. Takes the lock and exits 1 if the root is missing or not writable.

**`bus run pipeline unset repo NAME`** — Remove `.bus/run/NAME.yml` if present; exit 0 if absent.

**`bus run pipeline set prefs NAME TOKEN...`** and **`bus run pipeline unset prefs NAME`** — Manage preference pipelines under `bus-run.pipeline.NAME`.

**`bus run pipeline list [all|repo|prefs]`** — Print deterministic pipeline listings.

**`bus run pipeline preview TOKEN...`** — Resolve and expand tokens, apply the same normalization as runnable invocations, print normalized step names, and exit without running prompts/scripts.

**`bus run action set NAME`** — Read content from stdin until EOF and write `.bus/run/NAME.txt`; stdin must be non-empty (empty → exit 2). **`bus run action unset NAME`** — Remove `.bus/run/NAME.txt` if present; exit 0 if absent. **`bus run action list`** — Print available directory-local prompt actions (from `.bus/run/`) by name.

**`bus run script set NAME [--platform=unix|windows|windows-ps1|both]`** — Write `.bus/run/NAME.sh` (unix), `.bus/run/NAME.bat` (windows), and/or `.bus/run/NAME.ps1` (windows-ps1) from stdin; set the executable bit on `.sh` (chmod failure → exit 1). **`bus run script unset NAME [--platform=...]`** — Remove the selected script variant(s); exit 0 if absent. **`bus run script list`** — Print available directory-local scripts (from `.bus/run/`) by name with variant and enabled/disabled status.

### User-defined extensions (`.bus/run/`)

User-defined content lives under **`.bus/run/`** at the project root (effective working directory). Discovery is limited to that directory; paths must stay inside the project root (symlinks that point outside the project root are refused). No Git is required.

**Prompt action:** a file **`.bus/run/<name>.txt`** is a UTF-8 prompt template using `{{VARIABLE}}` placeholders. When you invoke the token `<name>`, the tool loads that file, substitutes the prompt-variable catalog (e.g. `DOCS_BASE_URL`, `WORKDIR_ROOT`, `PROJECT_NAME`; see **bus run context**), and invokes the agent with the rendered text via the bus-agent library. Missing or unresolved placeholders cause the command to fail (exit 2) before any agent run.

**Pipeline:** a file **`.bus/run/<name>.yml`** must be a YAML sequence of strings only. Each string is a token resolved with the same rules as command-line tokens; pipelines can reference other pipelines and actions. Invalid YAML or non-string scalars cause exit 2. Cycles and expansion limits are detected and reported with exit 2.

**Script action:** **`.bus/run/<name>.sh`** (non-Windows) or **`.bus/run/<name>.bat`** or **`.bus/run/<name>.ps1`** (Windows) runs as a script when you invoke the token `<name>`. On non-Windows the `.sh` file must have at least one execute bit set; otherwise the script action is disabled and invoking the name yields exit 2. On Windows, when both `.bat` and `.ps1` exist for the same name, the tool uses `.ps1`. The tool runs `.sh` via exec of the file path (shebang respected) or a fixed shell; on Windows it runs `.bat` via `cmd.exe /C` and `.ps1` via PowerShell (e.g. `powershell.exe -NoProfile -ExecutionPolicy Bypass -File <path>`). Scripts run with the project root (effective working directory) as the working directory and receive the prompt-variable catalog as environment variables; these override any existing variables of the same name. Use **bus run context** to see the exact KEY=VALUE set your scripts will see.

**Quick start for `.bus/run/`.** In your project root, keep runnable items in `.bus/run/`:

```text
.bus/run/
  summarize-plan.txt
  lint-unix.sh
  daily-check.yml
```

Create and use them:

```bash
cat <<'EOF' | bus run action set summarize-plan
Summarize open work items for {{PROJECT_NAME}} from {{WORKDIR_ROOT}}.
EOF
cat <<'EOF' | bus run script set lint-unix --platform=unix
#!/usr/bin/env sh
set -eu
make check
EOF
bus run pipeline set repo daily-check summarize-plan lint-unix
bus run list
bus run pipeline preview daily-check
bus run --agent codex --timeout 20m daily-check
```

Use `bus run context` to inspect the prompt/script variables that `.txt` and script actions receive.

Name grammar: names must start with a letter and contain only lowercase ASCII letters, digits, hyphens, and underscores. The same name cannot be used for more than one type (e.g. both a prompt and a pipeline); that ambiguity yields exit 2.

**Token resolution.** When you pass tokens to `bus run`, resolution order is:
1. Directory-local prompt (`.bus/run/<name>.txt`)
2. Directory-local script (non-Windows `.sh`; Windows `.ps1` if present, else `.bat`)
3. Directory-local pipeline (`.bus/run/<name>.yml`)
4. Preference pipeline (`bus-run.pipeline.<name>`)

There are no built-in operations or built-in pipelines. Unknown tokens, cycles, and expansion-limit failures exit 2 before any step runs.

After expansion succeeds, bus-run merges repeated step names in first-appearance order. This normalized sequence is what runs and what `pipeline preview` prints.

Example normalization: `bus run my-step my-step my-step` normalizes to one `my-step` step. `bus run my-pipeline my-pipeline my-pipeline` expands first, then repeated step names in the final sequence are merged so each step runs once.

**Prompt variable catalog.** The following variables are available in prompt templates and are injected as environment variables into script actions. Use **bus run context** to print the full catalog and current values (one `KEY=VALUE` per line, sorted by key).

| Variable | Description | Source |
|----------|-------------|--------|
| `DOCS_BASE_URL` | Base URL for documentation | `BUS_RUN_DOCS_BASE_URL` (default `https://docs.busdk.com`), trailing slash trimmed |
| `WORKDIR_ROOT` | Absolute path to the effective working directory (project root) | Effective workdir after `-C`/`--chdir` |
| `PROJECT_NAME` | Base name of the effective working directory | Base name of the project root path |

**Per-directory lock.** Only one run (or one directory-writing management command) operates on a given directory at a time. Commands that take the lock: **bus run** with one or more tokens, **pipeline set repo**, **action set**, **script set**, **pipeline unset repo**, **action unset**, and **script unset** when removing directory-local files. Commands that do not take the lock: **list**, **pipeline list**, **pipeline preview**, **action list**, **script list**, **context**, **set** (preferences only), **pipeline unset prefs**, and **pipeline set prefs**. A second invocation that would need the lock for the same directory waits until the first exits.

### Global flags

These flags apply to all subcommands and match the [standard global flags](../cli/global-flags). Flags can appear in any order before the subcommand, and a lone `--` ends flag parsing.

`-h` and `--help` print help to stdout and exit 0. Help states that Bus Run has no built-in operations or pipelines and points you to `bus run list`, `bus run pipeline list`, `bus run action list`, and `bus run script list` for discovery. `-V` and `--version` print the tool name and version and exit 0.

`-v` and `--verbose` increase diagnostic output on stderr and can be repeated, for example `-vv`. `-q` and `--quiet` suppress normal results and keep only errors. Quiet and verbose cannot be combined; that is usage error exit 2.

`-C <dir>` and `--chdir <dir>` change the effective working directory. `-o <file>` and `--output <file>` redirect normal output to a file, while diagnostics still go to stderr; if both output and quiet are set, quiet wins. `--color <auto|always|never>` controls color on stderr, and `--no-color` is the same as `--color=never`.

`--agent <runtime>` selects the runtime for this invocation only. Valid values are `cursor`, `codex`, `gemini`, and `claude`. This overrides `BUS_RUN_AGENT`, `BUS_AGENT`, and persistent preference defaults.

### Agent runtime selection

Subcommands that invoke an agent (when a token resolves to a prompt action) use the [bus-agent](./bus-agent) library and one of its supported runtimes: Cursor CLI, Codex, Gemini CLI, and Claude CLI. Resolution order: (1) **`--agent`** for that invocation; (2) **`BUS_RUN_AGENT`** (bus-run session default); (3) **`BUS_AGENT`** (shared session default); (4) **bus-run persistent preference** (`bus-run.agent`); (5) **bus-agent persistent preference** (`bus-agent.runtime`); (6) **first available** runtime in the effective order. Set bus-run’s default with **`bus run set agent <runtime>`** or `bus preferences set bus-run.agent <runtime>`. At the start of each agent step, the tool prints to stderr which agent and model are in use. Invalid runtime name or missing selected runtime yields a clear error and exit 2 or 1; the diagnostic includes the canonical installation URL for the runtime when it is missing.

### Preference settings (bus-run namespace)

Preferences that affect `bus run` are stored via the [bus-preferences](./bus-preferences) library under the **`bus-run`** namespace only. **Bus run only ever writes `bus-run.*` keys.**

| Key | Description |
|-----|-------------|
| `bus-run.agent` | Bus-run default agent runtime. Set with `bus run set agent <runtime>`. |
| `bus-run.model` | Bus-run default model. Set with `bus run set model <value>`. |
| `bus-run.output_format` | Bus-run default output format (`ndjson` or `text`). Set with `bus run set output-format <ndjson|text>`. |
| `bus-run.timeout` | Bus-run default timeout (e.g. `60m`). Set with `bus run set timeout <duration>`. |
| `bus-run.pipeline.<name>` | User-defined pipeline: a JSON array of tokens. Set with **`bus run pipeline set prefs <name> TOKEN...`** or `bus preferences set bus-run.pipeline.<name> '<json array>'`. Unset with **`bus run pipeline unset prefs <name>`**. |

### Examples

```bash
bus run list
bus run context
bus run pipeline list
cat <<'EOF' | bus run action set summarize-plan
Summarize open work items for {{PROJECT_NAME}} from {{WORKDIR_ROOT}}.
EOF
cat <<'EOF' | bus run script set lint-unix --platform=unix
#!/usr/bin/env sh
set -eu
make check
EOF
bus run pipeline set repo daily-check summarize-plan lint-unix
bus run pipeline preview daily-check
bus run summarize-plan lint-unix
bus run --agent codex --timeout 20m daily-check
```

### Files

`bus run` does not read or write workspace accounting datasets. It uses the effective working directory as the project root; `.bus/run/` is under that directory. No Git is required. To enforce a single run per directory, it uses an exclusive lock file (e.g. `.bus-run.lock`) in the effective operation directory; the lock is released when the command exits. No bus-run-specific config file is required; configuration is via flags, environment, and bus-preferences. User-defined pipelines are read from bus-preferences (keys `bus-run.pipeline.<name>`) when resolving tokens; directory-local definitions are read from `.bus/run/` only. Paths under `.bus/run/` must resolve inside the project root; symlinks that point outside the project root are refused.

### Exit status and errors

Exit code `0` means success. Exit code `1` means execution failed, such as agent failure or timeout, missing or non-executable selected runtime, script execution failure, unavailable default runtime, lock-acquisition failure, or inaccessible required working directory.

Exit code `2` means invalid usage, such as unknown tokens or subcommands, invalid flags, invalid pipeline definitions or names, recursion or expansion-limit failures, ambiguous names across definitions, invalid name grammar, empty stdin for `action set`, or invoking a disabled script action.

Deterministic command results (`list`, `context`, `pipeline list`, `action list`, `script list`) go to stdout. Diagnostics and errors go to stderr.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus run --help
run --help

# same as: bus run -V
run -V

# inspect project-local definitions in .bus/run/
run list
run context
run pipeline set repo daily-check summarize-plan lint-unix
run pipeline preview daily-check
run summarize-plan lint-unix
run --agent codex --timeout 20m daily-check
```


### Development state

**Value promise.** Run user-defined prompt actions, script actions, and pipelines by name with a single entrypoint; list and help show every available token without running; no built-in developer workflows and no dependency on [bus-dev](./bus-dev).

**Use cases.** [Orphan modules](../implementation/development-status#orphan-modules) — not mapped to a documented use case.

**Completeness.** 60% — User can define/list/set/unset and run script tokens and pipelines with stop-on-first-failure; context, list, pipeline preview, and management commands verified by tests; prompt run verified with stub agent only (runtime/model on stderr).

**Use case readiness.** Orphan (not mapped): 60% — Define/list/set/unset and run script token and pipeline; stop-on-first-failure, path escape, ambiguity, disabled script, expansion limits verified; prompt run stub-only.

**Current.** Help and version in `internal/run/run_test.go` and `tests/e2e_bus_run.sh`. Global flags in `internal/cli/flags_test.go`, `internal/run/run_test.go`, and `tests/e2e_bus_run.sh` (`-C`, `-o`, `-q`, `-v`, `--`, `--color`, `-f`, quiet+verbose invalid, unknown format, invalid color, `--output`, quiet wins). Context and catalog in `internal/catalog/catalog_test.go`, `internal/run/run_test.go`, and `tests/e2e_bus_run.sh`; list exit 1 when workdir inaccessible in `internal/run/run_test.go` and e2e. Name grammar in `internal/name/name_test.go`. Template render and unresolved placeholder in `internal/template/render_test.go`. Token resolution, expansion, cycle, ambiguity, and expansion limits in `internal/expand/expand_test.go`; path/symlink escape in `internal/pathsafe/pathsafe_test.go` and e2e; lock lifecycle in `internal/lock/lock_test.go`. Pipeline/action/script list, set repo/prefs, unset, action set empty stdin → exit 2, run script token, set agent/model in `tests/e2e_bus_run.sh`. Stop-on-first-failure in `internal/run/run_test.go` (TestRun_stopOnFirstFailure) and e2e; disabled script and ambiguous token in `run_test.go` and e2e. Pipeline preview and normalized repeated steps in `run_test.go` and e2e. Prompt step runtime/model on stderr (stub agent) in `internal/run/run_test.go` (TestRun_promptStepPrintsRuntimeModelToStderr) and e2e.

**Planned next.** Align agent and script output with SDD (agent/script output to stdout for piping; diagnostics on stderr) per FR-RUN-007a (PLAN.md). Document script execution method for .sh, .bat, and .ps1 in README or user-facing docs per FR-RUN-018 (PLAN.md).

**Blockers.** None known.

**Depends on.** [bus-agent](./bus-agent) (all agent runs), [bus-preferences](./bus-preferences) (read/write `bus-run.*` only).

**Used by.** None (end-user module).

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-agent">bus-agent</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-shell">bus-shell</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [BusDK — installation and overview](https://busdk.com/)
- [Module SDD: bus-run](../sdd/bus-run)
- [`.bus` getting started — multiple commands together](../cli/bus-script-files-multi-command-getting-started)
- [Module SDD: bus-agent](../sdd/bus-agent)
- [Module SDD: bus-preferences](../sdd/bus-preferences)
- [bus-preferences CLI reference](./bus-preferences)
- [bus-agent CLI reference](./bus-agent)
- [CLI: Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
- [Gemini CLI — install](https://geminicli.com/)
- [Cursor CLI — overview and install](https://cursor.com/docs/cli/overview)
- [Claude Code — get started / install](https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started)
- [Codex CLI — install](https://developers.openai.com/codex/cli/)
- [OpenAI Help Center: Using Codex with your ChatGPT plan](https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan)
