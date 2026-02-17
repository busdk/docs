---
title: "bus-run — end-user runner for prompts, pipelines, and scripts (SDD)"
description: "Bus Run is an end-user module that runs user-defined prompts, pipelines, and scripts with agentic execution via the bus-agent library; no built-in developer workflows and no dependency on bus-dev."
---

## bus-run — end-user runner for prompts, pipelines, and scripts

### Introduction and Overview

Bus Run is an end-user module that lets users run their own prompts, pipelines, and scripts through a single entry point, with agentic execution provided by the [bus-agent](./bus-agent) Go library. It has no built-in developer workflows (no init, commit, plan, work, spec, e2e, triage, or stage) and no dependency on [bus-dev](./bus-dev). Bus Run is intended for end users who want to define and execute custom prompts, pipeline sequences, and scripts in a directory (under `.bus/run/`) or via preferences; all agent execution is delegated to bus-agent. Bus Run does not require or use Git; the effective working directory is the project root. so that runtime selection, prompt templating, and timeout handling stay consistent across BusDK.

The problem it solves is giving end users a simple, script-friendly way to run custom AI-assisted workflows and scripts without the complexity or scope of bus-dev. Users define prompts (`.bus/run/<name>.txt`), pipelines (`.bus/run/<name>.yml` or preference `bus-run.pipeline.<name>`), and scripts (`.bus/run/<name>.sh`, `.bat`, or `.ps1`), then invoke them by name with `bus run <name>` or by chaining multiple tokens in one invocation. The tool expands pipeline tokens into a flat sequence of runnable steps (prompt actions and script actions only), normalizes the final sequence by merging repeated step names so each name appears once in first-appearance order, runs that normalized sequence in order with stop-on-first-failure, and uses the bus-agent library for every agent invocation.

Scope and boundaries are explicit. Bus Run operates on user-defined content only. It does not implement or reference any bus-dev operations. It does not operate on workspace accounting datasets. It does not execute Git commands and never requires Git; discovery and project root are based solely on the effective working directory. End users who only need to run their own prompts and scripts use `bus run`; contributors working inside BusDK module repositories may use `bus dev` for developer workflows, and the two modules do not depend on each other.

The intended users are end users (including script and automation authors) who want to run custom prompts and scripts with optional agent support. The document’s purpose is to serve as the single source of truth for implementation and review; the audience includes human reviewers and implementation agents.

Out of scope for this SDD: implementing bus-dev workflows, Git execution, workspace dataset I/O, and any behavior that would require a dependency on bus-dev.

### Goals

G-RUN-001 End-user runner for user-defined content only. Provide a single `bus run` command that executes only user-defined prompts, pipelines, and scripts. No built-in developer operations (no plan, work, spec, e2e, triage, stage, commit, init).

G-RUN-002 Agent execution via bus-agent. All agent runtime execution MUST go through the bus-agent Go library. Bus Run MUST NOT implement its own agent runner and MUST NOT depend on bus-dev. Runtime selection, prompt templating, timeout, and output handling follow the bus-agent contract.

G-RUN-003 Directory-local and preference-based definitions. Users MAY define prompts, pipelines, and scripts under the effective working directory in `.bus/run/` (directory-local) or in preferences under the `bus-run` namespace. Discovery and token resolution are deterministic and documented; no Git is required.

G-RUN-004 Determinism and script-friendliness. Pipeline expansion, token resolution, and execution order MUST be deterministic. Exit codes and stdout/stderr usage MUST follow BusDK CLI conventions so scripts and automation can rely on `bus run` behavior.

### Non-goals

NG-RUN-001 No bus-dev dependency. Bus Run MUST NOT import or invoke bus-dev. It MUST NOT implement or reference bus-dev operations, built-in pipelines, or the `.bus/dev/` directory.

NG-RUN-002 No built-in developer workflows. No init, commit, stage, plan, work, spec, e2e, or triage. No built-in pipelines (snapshot, refresh, round, cycle, iterate). No AGENTS.md or PLAN.md lifecycle. No Git operations.

NG-RUN-003 No workspace dataset operations. Bus Run does not read or write workspace CSV, schemas, or datapackage.json for bookkeeping.

NG-RUN-004 No Git execution. Bus Run must never execute Git commands.

### Requirements

FR-RUN-001 CLI integration and naming. The binary MUST be named `bus-run` and MUST be invoked through the dispatcher as `bus run [global-flags] <operation> [operation ...]`. Operations are: one or more runnable tokens (user-defined prompt action, script action, or pipeline name), or the management subcommands **set**, **context**, **pipeline**, **action**, and **script**. Acceptance criteria: the dispatcher routes `bus run <token>`, `bus run <token> <token>`, and `bus run pipeline list` (etc.) to the same binary.

FR-RUN-002 Runnable tokens only. A runnable token is either a user-defined prompt action (directory-local `.bus/run/<NAME>.txt`), a user-defined script action (directory-local `.bus/run/<NAME>.sh`, `.bus/run/<NAME>.bat`, or `.bus/run/<NAME>.ps1`), or a pipeline name (directory-local `.bus/run/<NAME>.yml` or preference `bus-run.pipeline.<name>`). Pipeline names expand to a sequence of runnable steps (prompt actions and script actions); there are no built-in operations or built-in pipelines. Acceptance criteria: the only executable steps are user-defined prompt actions and script actions; pipeline tokens expand to such steps only; unknown token yields exit 2.

FR-RUN-003 Pipeline expansion and final-sequence normalization before execution. All pipeline tokens MUST be expanded into a flat sequence of runnable steps (prompt actions and script actions) before any step runs. After expansion succeeds, the implementation MUST normalize the final sequence by merging repeated step names so each step name appears once in first-appearance order. Execution MUST proceed over the normalized sequence, one step at a time, with stop-on-first-failure. Acceptance criteria: expansion and normalization are deterministic and testable; `my-step my-step my-step` normalizes to one `my-step`; normalized sequence runs in order; first non-zero exit stops the run and is the process exit code.

FR-RUN-003a Pipeline preview without execution. The implementation MUST provide a preview command `bus run pipeline preview TOKEN...` that uses the same token resolution, expansion, validation, and duplicate-merge normalization as `bus run <token...>`, prints the normalized final sequence to stdout in a deterministic format (one step name per line), and exits without executing any prompt action or script action. Acceptance criteria: preview output matches exactly the sequence that `bus run <token...>` would execute; no agent invocation or script execution occurs in preview mode.

FR-RUN-004 Project root and directory-local discovery. The tool MUST use the effective working directory (after `-C`/`--chdir` if present) as the project root. The tool MUST NOT require or use Git. Directory-local content (prompts, pipelines, scripts) lives under `<project-root>/.bus/run/`. When the effective working directory does not exist or is not accessible, commands that need it (run with a token that resolves to directory-local content, context, or pipeline/action/script management that writes under `.bus/run/`) MUST exit with a clear diagnostic and exit code 1. Acceptance criteria: project root is the effective workdir; `.bus/run/` is `<project-root>/.bus/run/`; no Git is invoked or required; missing or inaccessible workdir yields exit 1.

FR-RUN-005 Directory-local extension directory. User-defined prompts, pipelines, and scripts live under `<project-root>/.bus/run/`, where project root is the effective working directory. Prompt actions: `<project-root>/.bus/run/<NAME>.txt`. Pipeline definitions: `<project-root>/.bus/run/<NAME>.yml` (strict YAML sequence of string scalars). Script actions: `<project-root>/.bus/run/<NAME>.sh` (non-Windows), `<project-root>/.bus/run/<NAME>.bat` or `<project-root>/.bus/run/<NAME>.ps1` (Windows; when both .bat and .ps1 exist for the same NAME, .ps1 is used). File discovery MUST be restricted to the project root; resolved paths MUST remain inside the project root (symlinks that escape MUST be refused). Acceptance criteria: only `.bus/run/` under project root is considered; symlink escape yields exit 2; no `.bus/dev/` or bus-dev paths are read.

FR-RUN-006 Prompt-template rendering. Prompt actions (embedded or from `.bus/run/<NAME>.txt`) that use placeholders MUST use `{{VARIABLE}}` syntax. Bus Run MUST use the bus-agent library’s template renderer (or a contract-compatible implementation) so that missing or unresolved placeholders cause the command to fail before any agent invocation (exit 2). Acceptance criteria: unit tests cover missing/unresolved variables; agent is never invoked when substitution fails.

FR-RUN-007 Dependence on bus-agent. The implementation MUST depend on the bus-agent Go library for all agent invocations. Bus Run MUST use bus-agent’s runner interface, template renderer, runtime detection, and installation references. Model, output format, and timeout are configurable via flags or environment; resolution order MUST follow a documented bus-run-specific order (e.g. `--agent`, then `BUS_RUN_AGENT`, then `BUS_AGENT`, then `bus-run.agent`, then `bus-agent.runtime`, then first available). Acceptance criteria: bus-run imports and uses bus-agent for every agent run; run-config is configurable and resolution order is documented.

FR-RUN-008 Agent runtimes. The implementation MUST use bus-agent’s supported runtimes (Cursor CLI, Codex, Gemini CLI, Claude CLI). The active runtime MUST be selectable via a documented flag (e.g. `--agent cursor|codex|gemini|claude`) and via bus-run persistent preferences (`bus-run.agent`) written through the [bus-preferences](./bus-preferences) Go library. Acceptance criteria: user can select any of the four runtimes; invalid runtime yields exit 2; bus-run only writes `bus-run.*` preference keys.

FR-RUN-009 Set and context subcommands. The implementation MUST provide **bus run set agent \<runtime\>**, **bus run set model \<value\>**, **bus run set output-format \<ndjson|text\>**, and **bus run set timeout \<duration\>**, each writing only the corresponding `bus-run.*` key via the bus-preferences library (no shell-out to `bus preferences`). The implementation MUST provide **bus run context**, which prints the full prompt-variable catalog and current resolved values (one `KEY=VALUE` line per variable, sorted by key) to stdout; context uses the effective working directory to derive catalog values and does not require Git. When the effective working directory does not exist or is not accessible, context MUST exit with code 1. Acceptance criteria: set subcommands persist only bus-run keys; context output is deterministic and script-friendly; context does not require Git; inaccessible workdir yields exit 1.

FR-RUN-010 Prompt variable catalog. Bus Run MUST define a prompt-variable catalog used for rendering directory-local prompt templates and for environment injection into script actions. At minimum: `DOCS_BASE_URL` (configurable via `BUS_RUN_DOCS_BASE_URL`, default `https://docs.busdk.com`), and workdir-derived values: `WORKDIR_ROOT` (absolute path to the effective working directory) and `PROJECT_NAME` (base name of that directory). The catalog MUST be documented in this SDD; **bus run context** MUST print all catalog variables. Acceptance criteria: catalog is fixed and documented; context output matches catalog; scripts receive same variables as env with override semantics.

FR-RUN-011 Pipeline recursion and expansion limits. The tool MUST detect pipeline cycles (including indirect) and MUST exit with code 2 and a clear diagnostic that includes the cycle path. The tool MUST enforce a maximum expansion depth or expanded-token limit; exceeding it MUST yield exit 2. All expansion errors MUST occur before any agent invocation or script execution. Acceptance criteria: cycle detection is deterministic; expansion limit yields exit 2; no side effects when expansion fails.

FR-RUN-012 User-defined name grammar. Pipeline, action, and script names MUST obey a single grammar: lowercase ASCII letters a–z, digits 0–9, hyphen, underscore; MUST start with a letter. Invalid or reserved names MUST yield exit 2. Acceptance criteria: name validation is shared and testable; invalid names yield exit 2 before any write.

FR-RUN-013 Pipeline management. The implementation MUST provide **bus run pipeline set repo NAME TOKEN...** (write or overwrite `.bus/run/NAME.yml` as a YAML sequence of scalar strings), **bus run pipeline unset repo NAME** (remove file if present; exit 0 if absent), **bus run pipeline set prefs NAME TOKEN...** (write `bus-run.pipeline.NAME` as JSON array via bus-preferences), **bus run pipeline unset prefs NAME** (remove key if present; exit 0 if absent), **bus run pipeline list [all|repo|prefs]** (deterministic listing, lexicographic by name then source), and **bus run pipeline preview TOKEN...** (deterministic normalized sequence preview with no execution; see FR-RUN-003a). Acceptance criteria: repo pipelines are YAML sequences; prefs pipelines use bus-preferences; list is deterministic; preview uses the same expansion and normalization logic as runnable invocations.

FR-RUN-014 Action management. **bus run action set NAME** MUST read content from stdin until EOF and write `.bus/run/NAME.txt`; create `.bus/run` if missing; stdin MUST be non-empty (empty stdin → exit 2). **bus run action unset NAME** MUST remove `.bus/run/NAME.txt` if present; exit 0 if absent. **bus run action list** MUST print available directory-local prompt actions (from `.bus/run/`) deterministically by name. Acceptance criteria: action set requires non-empty stdin; ambiguity with pipeline or script for same NAME yields exit 2 before write.

FR-RUN-015 Script management. **bus run script set NAME [--platform=unix|windows|windows-ps1|both]** MUST write `.bus/run/NAME.sh` (unix), `.bus/run/NAME.bat` (windows), and/or `.bus/run/NAME.ps1` (windows-ps1) from stdin; when writing `.sh`, set the executable bit (chmod failure → exit 1). **bus run script unset NAME [--platform=...]** MUST remove the selected variant(s); exit 0 if absent. **bus run script list** MUST print available directory-local scripts (from `.bus/run/`) by name with variant and enabled/disabled status. Script actions are enabled only when the file meets the platform executable requirement (e.g. execute bit on `.sh`; .bat and .ps1 are enabled when the file exists and is readable). Acceptance criteria: script set supports platform including windows-ps1; list shows enabled/disabled and .ps1 variant; ambiguity with pipeline or action for same NAME yields exit 2.

FR-RUN-016 Token resolution and ambiguity. There are no built-in operations or @-prefix semantics. A token resolves with deterministic precedence: (1) directory-local prompt (`.bus/run/<NAME>.txt`), (2) directory-local script (platform-selected: non-Windows uses `.sh`; Windows uses `.ps1` if present, else `.bat`), (3) directory-local pipeline (`.bus/run/<NAME>.yml`), (4) preference pipeline (`bus-run.pipeline.<name>`). It is a usage error (exit 2) if the same NAME is defined in more than one of prompt, script, directory pipeline, or prefs pipeline. Having both `.sh` and `.bat` for the same NAME, or both `.bat` and `.ps1`, or all three, is allowed (one script action, platform variants). After resolution and expansion, repeated step names are merged as defined in FR-RUN-003. Acceptance criteria: resolution order is deterministic; on Windows .ps1 is preferred over .bat when both exist; ambiguity yields exit 2 before any run.

FR-RUN-017 Working-directory lock. At most one `bus run` invocation that operates on a given directory (run with one or more tokens, or pipeline/action/script set or generate) MAY run at a time for that directory. The tool MUST acquire an exclusive lock on the effective operation directory before running any runnable step or any management command that writes to `.bus/run/`, MUST release the lock when the process exits, and MUST remove the lock file (e.g. `.bus-run.lock`) when the lock is released. Subcommands that only read (pipeline list, pipeline preview, action list, script list, context) or that only write preferences (set) do not require the lock. The effective operation directory is the project root (effective working directory). Acceptance criteria: two concurrent runs targeting the same directory serialize; lock is released on exit; lock file is removed after release; list/preview/context/set do not block.

FR-RUN-018 Script action execution. Script actions run with the project root (effective working directory) as the working directory and receive the prompt-variable catalog as environment variables (injected values override existing same-named vars). `.sh` runs via exec of the file path (shebang respected) or a fixed shell. On Windows, `.bat` runs via `cmd.exe /C` and `.ps1` runs via PowerShell (e.g. `powershell.exe -NoProfile -ExecutionPolicy Bypass -File <path>` or the platform’s PowerShell executable; exact invocation is implementation-defined and MUST be documented). Acceptance criteria: scripts receive catalog as env; working directory is project root; execution method is documented for all three variants.

NFR-RUN-001 Determinism. Output and exit codes MUST be deterministic for the same inputs and working-directory state.

NFR-RUN-002 No execution of arbitrary code except as defined. The only permitted execution is: the configured agent runtime (via bus-agent) for prompt actions, and directory-local scripts under `.bus/run/<NAME>.sh`, `.bus/run/<NAME>.bat`, or `.bus/run/<NAME>.ps1` under the path and executable constraints in this SDD. Acceptance criteria: no execution of content other than .bus/run prompt-driven agent runs and .bus/run scripts.

NFR-RUN-003 Hermetic testability. Tests MUST be hermetic: no network, no real agent CLI; agent invocation tested via stubbed executable or mocked bus-agent. Acceptance criteria: unit tests run without network and without real agent.

NFR-RUN-004 No user configuration outside project. Bus Run MUST NOT edit any user configuration outside the project working directory. Acceptance criteria: no code path writes outside the effective workdir for config.

### System Architecture

Bus Run is a thin CLI that delegates to the bus-agent library for all agent execution and uses a small set of packages for project-root resolution, token resolution, and pipeline expansion.

High-level components:

- **CLI layer.** Parses global flags (including BusDK-standard `-C`, `-o`, `-v`, `-q`, `--help`, `--version`) and the operation: either one or more runnable tokens (for `bus run token [token ...]`) or a management subcommand (set, context, pipeline, action, script). For run, tokens are resolved and pipelines expanded to a flat sequence of prompt and script actions before any step runs, then normalized by merging repeated step names so each name appears once in first-appearance order. The CLI resolves the effective working directory (project root) and, for agent-invoking steps, the agent runtime via bus-run resolution order (e.g. `--agent`, `BUS_RUN_AGENT`, `BUS_AGENT`, `bus-run.agent`, `bus-agent.runtime`, first available). For run and directory-writing management, the CLI acquires the per-directory lock before proceeding.

- **Project root.** The effective working directory (after `-C`/`--chdir`) is the project root; no Git is used. Used for `.bus/run/` discovery and for context/prompt variable derivation (WORKDIR_ROOT, PROJECT_NAME).

- **Token resolution and pipeline expansion.** Resolves each token to a runnable step (prompt action or script action) or expands a pipeline to a sequence of such steps. Precedence: directory-local prompt, directory-local script, directory-local pipeline, prefs pipeline. Cycle detection and expansion limits apply. No built-in operations or built-in pipelines. After expansion, repeated step names are merged in first-appearance order to produce the final runnable sequence.

- **bus-agent library.** All agent execution goes through bus-agent: prompt rendering, runtime selection, timeout, output capture/streaming. Bus Run supplies the prompt text (from directory-local `.txt` or inline) and variables; bus-agent performs the invocation.

- **Subcommand handlers.** Run (execute normalized sequence step by step), set (write bus-run preferences), context (print catalog), pipeline/action/script (management). Management commands that write to `.bus/run/` take the per-directory lock. The `pipeline preview` handler resolves and normalizes exactly like run, then prints and exits without execution.

Data flow: user invokes `bus run <tokens>` or `bus run <management>`; CLI parses and resolves; for run, tokens are expanded and normalized to final steps; for each prompt step, handler loads template, renders with catalog, calls bus-agent; for each script step, handler runs script with catalog as env; diagnostics to stderr, results per BusDK conventions. `pipeline preview` follows the same parse/resolve/expand/normalize path and emits the final step list without execution.

### Key Decisions

KD-RUN-001 No bus-dev dependency. Bus Run is a separate module so end users can run custom prompts and scripts without pulling in developer workflows or bus-dev code. Implementation MUST NOT import bus-dev.

KD-RUN-002 Same extension pattern as bus-dev, different directory. User-defined prompts, pipelines, and scripts follow the same conceptual pattern (prompt `.txt`, pipeline `.yml`, script `.sh`/`.bat`/`.ps1`) but live under `.bus/run/` and use the `bus-run.*` preference namespace so there is no overlap with `.bus/dev/` or `bus-dev.*`.

KD-RUN-003 Agent execution via bus-agent only. Bus Run does not implement an agent runner; it always uses the bus-agent Go library. This keeps runtime selection, backends, and diagnostics in one place and allows bus-run to stay small and focused.

KD-RUN-004 Single-instance per directory via lock. To avoid concurrent edits to `.bus/run/` and concurrent agent runs in the same directory, one run or directory-writing management at a time per directory; second invocation blocks until the first exits.

### Component Design and Interfaces

**Dispatcher.** The `bus` dispatcher invokes the `bus-run` binary with the remaining arguments after `run`: global flags and either runnable tokens or a management subcommand. For `bus run token [token ...]`, the binary expands pipeline tokens to a flat sequence of prompt and script actions, then runs each step in order and stops on first failure.

**Run entrypoint.** The program exposes a single entrypoint `Run(args []string, workdir string, stdout, stderr io.Writer) int`. `main` passes `os.Args[1:]`, effective working directory, and writers, and exits with the returned code.

**bus-agent integration.** Bus Run calls the bus-agent library’s runner interface with: selected runtime (or resolution delegated to bus-agent with bus-run caller context), prompt text (rendered from directory-local template and catalog), workdir, timeout, output mode. Bus Run does not implement the runner; it is a caller of bus-agent.

**Project root.** The effective working directory (after `-C`/`--chdir`) is the project root; no Git. Used for `.bus/run/` discovery and for catalog derivation (`WORKDIR_ROOT`, `PROJECT_NAME`).

**Working-directory lock.** For run (with at least one token) and for pipeline set repo, action set, script set (and unset when removing directory-local files), the implementation acquires an exclusive lock keyed by the effective operation directory (project root). Lock is released when the process exits; the lock file (e.g. `.bus-run.lock`) MUST be removed when the lock is released. List, context, set (preferences only), and pipeline/action/script unset that only remove prefs do not take the lock.

**Prompt variable catalog (minimal).** Variables available for prompt templates and script env:

| Variable       | Description                    | Source |
|----------------|--------------------------------|--------|
| `DOCS_BASE_URL` | Base URL for documentation     | `BUS_RUN_DOCS_BASE_URL` (default `https://docs.busdk.com`), trailing slash trimmed |
| `WORKDIR_ROOT` | Absolute path to the effective working directory (project root) | Effective workdir after `-C`/`--chdir` |
| `PROJECT_NAME` | Base name of the effective working directory | Derived from project root path |

Additional variables MAY be added in this SDD or in the implementation and MUST be documented and printed by **bus run context**.

### Command Surface

**Invocation.** `bus run [global-flags] ( <token> [<token> ...] | set | context | pipeline | action | script )`.

**bus run \<token\> [\<token\> ...]** — Resolve each token (prompt action, script action, or pipeline name). Expand pipelines to a flat sequence of prompt and script actions, then normalize the final sequence by merging repeated step names so each name appears once in first-appearance order. Execute the normalized sequence in order; stop on first non-zero exit. When any token resolves to directory-local content, `.bus/run/` is read from the effective working directory (project root); no Git is required. If the project root does not exist or is not accessible, exit 1. Takes the per-directory lock.

**bus run set agent \<runtime\>** — Set `bus-run.agent` via bus-preferences. `<runtime>` must be one of `cursor`, `codex`, `gemini`, `claude`. Invalid value → exit 2.

**bus run set model \<value\>** — Set `bus-run.model` via bus-preferences. Invalid value → exit 2.

**bus run set output-format \<ndjson|text\>** — Set `bus-run.output_format` via bus-preferences. Invalid value → exit 2.

**bus run set timeout \<duration\>** — Set `bus-run.timeout` via bus-preferences. Invalid value → exit 2.

**bus run context** — Print the prompt-variable catalog and resolved values (one `KEY=VALUE` per line, sorted by key) to stdout. Uses the effective working directory to derive catalog values; no Git required. If the effective working directory does not exist or is not accessible, exit 1. Does not take the lock.

**bus run pipeline set repo NAME TOKEN...** — Write `.bus/run/NAME.yml` as a YAML sequence of scalar strings under the project root (effective workdir). Takes lock. If the project root does not exist or is not writable, exit 1.

**bus run pipeline unset repo NAME** — Remove `.bus/run/NAME.yml` if present; exit 0 if absent.

**bus run pipeline set prefs NAME TOKEN...** — Write `bus-run.pipeline.NAME` as JSON array via bus-preferences. Does not take lock.

**bus run pipeline unset prefs NAME** — Remove preference key if present; exit 0 if absent.

**bus run pipeline list [all|repo|prefs]** — Print pipelines and their source; lexicographic by name then source. Stdout.

**bus run pipeline preview TOKEN...** — Resolve and expand tokens with the same rules as `bus run <token...>`, normalize the final sequence by merging repeated step names in first-appearance order, print one normalized step per line to stdout, and exit without executing prompt or script steps.

**bus run action set NAME** — Read stdin to EOF, write `.bus/run/NAME.txt`; non-empty stdin required; creates `.bus/run` if missing. Takes lock. Fails with exit 2 if pipeline or script with same NAME exists.

**bus run action unset NAME** — Remove `.bus/run/NAME.txt` if present; exit 0 if absent.

**bus run action list** — Print directory-local prompt action names (from `.bus/run/`) to stdout. Deterministic order.

**bus run script set NAME [--platform=unix|windows|windows-ps1|both]** — Write `.bus/run/NAME.sh` (unix), `.bus/run/NAME.bat` (windows), and/or `.bus/run/NAME.ps1` (windows-ps1) from stdin; set executable bit on `.sh`. Takes lock. Fails with exit 2 if pipeline or action with same NAME exists.

**bus run script unset NAME [--platform=...]** — Remove selected script variant(s); exit 0 if absent.

**bus run script list** — Print directory-local script names (from `.bus/run/`) with variant and enabled/disabled status to stdout.

### I/O Conventions

Stdout: Reserved for deterministic command results (e.g. context KEY=VALUE output, pipeline list, pipeline preview output, action list, script list). Agent and script output may be streamed to stderr when the run is interactive or script-friendly as documented.

Stderr: Diagnostics, progress, and human-readable agent or script output. At the start of each agent-invoking step, the tool SHOULD print to stderr which agent runtime and model are in use (when provided by bus-agent).

### Exit Codes

- **0** — Success.
- **1** — Execution failure: agent run failed, timeout, selected runtime not found or not executable, script execution failed, lock acquisition failed.
- **2** — Invalid usage: unknown token, unknown subcommand, invalid flag, invalid pipeline definition or name, pipeline recursion or expansion limit, ambiguity (same name in multiple definitions), invalid name grammar, empty stdin for action set, disabled script invoked.

### Error Handling and Resilience

- **Effective working directory missing or inaccessible:** When a command needs the project root (run with directory-local token, context, or pipeline/action/script set or unset that touches `.bus/run/`) and the effective working directory does not exist or is not accessible, exit 1 with a clear message. Bus Run does not require Git.
- **Selected agent not installed:** When the user has selected an agent and it is not in PATH, surface bus-agent’s diagnostic and exit 1; include installation URL from bus-agent.
- **No agent available:** When resolution would use “first available” and no runtime is available, exit with clear diagnostic and exit 1, directing the user to install or enable at least one supported agent.
- **Pipeline expansion errors:** Unknown token, cycle, expansion limit exceeded, invalid YAML or invalid preference JSON → exit 2 before any agent or script run. The same rule applies to `pipeline preview`.
- **Lock acquisition failure:** Exit 1 with a clear message when the per-directory lock cannot be acquired.

All error messages MUST be written to stderr.

### Data Design

- **Working-directory lock file.** Exclusive lock keyed by the effective operation directory (e.g. `<effective-dir>/.bus-run.lock`). Implemented with an exclusive file lock; released when the process exits. The lock file MUST be removed when the lock is released so no stale file remains. Used for run and for pipeline/action/script set (writes to `.bus/run/` only).

- **Directory-local extension directory.** `.bus/run/` at the project root (effective working directory). Only `<NAME>.txt`, `<NAME>.yml`, `<NAME>.sh`, `<NAME>.bat`, `<NAME>.ps1` are considered. Paths must resolve inside the project root; symlinks that escape are refused. On Windows, when both .bat and .ps1 exist for the same NAME, .ps1 is used.

- **Preferences.** Bus Run reads and writes only the `bus-run` namespace via the bus-preferences library: `bus-run.agent`, `bus-run.model`, `bus-run.output_format`, `bus-run.timeout`, `bus-run.pipeline.<name>`. No shell-out to `bus preferences`.

- No workspace datasets; no Git is used or required. No dependency on bus-dev or `.bus/dev/`.

### Assumptions and Dependencies

AD-RUN-001 Project root is the effective working directory. The tool uses the effective working directory (after `-C`/`--chdir`) as the project root for `.bus/run/` discovery and catalog derivation. No Git is required or used. If the effective working directory does not exist or is not accessible when needed, the tool fails with exit 1.

AD-RUN-002 Agent runtime availability. Prompt actions require the chosen agent runtime (Cursor, Codex, Gemini, or Claude) to be installed and in PATH when those steps run. Resolution order is documented; missing selected runtime yields exit 1 with diagnostic.

AD-RUN-003 bus-agent dependency. Bus Run depends on the bus-agent Go module for all agent execution. If bus-agent is unavailable or its interface changes incompatibly, prompt actions cannot run; bus-run does not implement a fallback runner.

AD-RUN-004 bus-preferences dependency. Persistent preferences (agent, model, timeout, output_format, pipelines) are read and written via the bus-preferences library.

AD-RUN-005 Operating environment. Linux and macOS for primary support; Windows for script actions (.bat, .ps1) and cross-platform behavior where documented.

### Testing Strategy

- **Unit tests.** Project-root resolution (effective workdir, no Git), token resolution, pipeline expansion (including cycle detection and expansion limit), final-sequence normalization (duplicate step merge in first-appearance order), name grammar, prompt rendering (missing/unresolved placeholder → exit 2), and run sequence (stop-on-first-failure) MUST have unit tests. Tests MUST be hermetic: no network, no real agent; stub agent in PATH or mock bus-agent.

- **Management command tests.** Pipeline/action/script set and unset, list output determinism, preview output determinism and non-execution, ambiguity detection (same NAME in two definition types → exit 2), and preference read/write via bus-preferences.

- **Lock tests.** Two concurrent runs (or run and directory-writing management) for the same directory run one after the other; lock released on exit and lock file removed after release. List, context, and set (prefs only) do not take the lock.

- **Fixture directory.** At least one test uses a fixture directory (no Git required) with `.bus/run/*` files to verify discovery, resolution order, and script env injection.

### Traceability to BusDK Spec

- Bus Run follows BusDK CLI conventions for flags, stdout/stderr, and exit codes. It does not execute Git (no exception like bus-dev).
- Module structure: implemented as a thin CLI that depends on bus-agent and bus-preferences; no dependency on bus-dev.
- Testing: hermetic, no network, deterministic; agent behavior tested via stubs or mocks.

### Glossary and Terminology

- **Prompt action:** A user-defined runnable step whose prompt is loaded from `.bus/run/<NAME>.txt`, rendered with the prompt variable catalog, and executed via the bus-agent library.
- **Script action:** A user-defined runnable step implemented by `.bus/run/<NAME>.sh` (non-Windows) or `.bus/run/<NAME>.bat` or `.bus/run/<NAME>.ps1` (Windows; .ps1 preferred when both exist); with executable bit requirements per platform for .sh; receives the catalog as environment variables.
- **Directory-local:** Content under `<project-root>/.bus/run/`, where project root is the effective working directory. Bus Run never requires Git; discovery is workdir-based only.
- **Pipeline:** A named sequence of tokens (each token resolves to a prompt action, script action, or another pipeline) stored in `.bus/run/<NAME>.yml` (directory-local) or in preference `bus-run.pipeline.<name>`. Pipelines expand to a flat sequence of prompt and script actions only; repeated step names are then merged so each appears once in first-appearance order.
- **Token:** A single positional argument after `bus run`: a user-defined prompt action name, script action name, or pipeline name. No built-in operations or built-in pipelines.
- **Runnable step:** After expansion and normalization, each step is either a prompt action or a script action. Execution runs these in order with stop-on-first-failure.
- **bus-run namespace:** Preference keys under `bus-run.*` (agent, model, output_format, timeout, pipeline.<name>). Written only by bus-run via the bus-preferences library.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-dev">bus-dev</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-agent">bus-agent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-agent module SDD](./bus-agent)
- [bus-preferences module SDD](./bus-preferences)
- [BusDK Software Design Document (SDD)](../sdd)
- [CLI tooling and workflow](../cli/index)
- [Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
- [Module repository structure and dependency rules](../implementation/module-repository-structure)
- [End user documentation: bus-run CLI reference](../modules/bus-run)

### Document control

Title: bus-run module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-RUN`  
Version: 2026-02-17  
Status: Draft  
Last updated: 2026-02-17  
Owner: BusDK development team  
