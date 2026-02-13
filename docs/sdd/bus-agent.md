---
title: bus-agent — Software Design Document
description: Design spec for the BusDK agent runner: shared abstraction for Cursor, Codex, Gemini, Claude; prompt templating, timeout handling, script-safe execution; no bookkeeping or workflow logic.
---

## bus-agent

### Introduction and Overview

Bus Agent provides the shared, provider-agnostic agent runner layer for BusDK. It exists to centralize the mechanics of invoking external agent runtimes (Cursor CLI, Codex, Gemini CLI, Claude CLI, and future backends) behind a single deterministic Go library contract, so other modules can integrate agentic workflows without duplicating runtime-specific command building, detection, configuration, prompt templating, timeout handling, and output normalization. Bus Agent is library-first and may optionally expose a thin CLI wrapper for diagnostics and development (for example: detect enabled runtimes, render a prompt template, run an agent with a provided prompt, and format agent NDJSON into readable text). Bus Agent contains no bookkeeping logic and no repository workflow logic: it is an execution substrate used by modules such as `bus-dev` and by future end-user features in `bus` or other modules that want AI assistance while keeping workflow semantics in their own SDDs.

Scope boundaries are strict. Bus Agent does not decide “what work to do”; it only provides a safe, testable way to run an agent with a prompt and a working directory under explicit constraints. Bus Agent does not execute Git, does not read or write BusDK workspace datasets, and does not implement module-specific prompts like “commit”, “work”, “spec”, or “e2e”. Those belong to higher-level modules such as [bus-dev](./bus-dev), which depend on Bus Agent for the runtime layer.

The intended users are implementors of modules that need agentic workflows (for example bus-dev) and, when the optional CLI is present, developers running diagnostics. The document's purpose is to serve as the single source of truth for the agent runner abstraction; the audience includes human reviewers and implementation agents. Out of scope for this SDD: workflow semantics, Git execution, workspace dataset I/O, provider SDKs, and any network I/O performed by this module.

### Goals

G-AGT-001 Shared agent runner abstraction. Provide a single Go library contract that can invoke multiple external agent runtimes with consistent behavior across BusDK.

G-AGT-002 Deterministic prompt templating. Provide deterministic prompt-template rendering with strict “no unresolved placeholders” guarantees so callers never invoke an agent with ambiguous prompt text.

G-AGT-003 Modular backends. Support multiple agent runtimes via a backend interface so adding/removing providers does not change caller semantics.

G-AGT-004 Script-safe operation. Provide a non-interactive, headless-friendly execution mode suitable for CI and automation, with deterministic exit codes and clear diagnostics.

G-AGT-005 Hermetic testability. Make the runner testable without real agents by stubbing executables in PATH and feeding deterministic output.

### Non-goals

NG-AGT-001 No workflow semantics. Bus Agent does not define module workflows (no “do the work”, no “refine MDC”, no “commit”), and does not embed module-specific prompts.

NG-AGT-002 No Git execution. Bus Agent must never execute Git commands. Any Git-based workflows live outside this module (e.g. `bus-dev`).

NG-AGT-003 No bookkeeping or workspace dataset operations. Bus Agent does not read or write workspace CSV, schemas, or `datapackage.json`.

NG-AGT-004 No provider SDK integration. Bus Agent does not embed LLM provider SDKs or call remote model APIs directly; it invokes external CLIs only.

NG-AGT-005 No hidden network behavior. Bus Agent itself performs no network operations; if the selected external agent CLI performs network I/O, that is outside Bus Agent’s direct control and must be governed by caller policy and agent configuration.

### Requirements

FR-AGT-001 Library-first integration. The module MUST provide a Go package that other modules import directly to run agents and render prompts. Acceptance criteria: another module can select a backend, render a prompt template, run an agent, and receive a structured result without shelling out itself.

FR-AGT-002 Backend-agnostic runner contract. The library MUST expose a single runner interface that is independent of any specific agent runtime. Acceptance criteria: the same call site can switch between Cursor, Codex, Gemini, and Claude backends without changing workflow semantics.

FR-AGT-003 Supported runtimes. The implementation MUST include at least four backends: Cursor CLI, Codex CLI, Gemini CLI, and Claude CLI. Acceptance criteria: all four can be selected; each backend implements the same interface; each backend has documented executable name(s) used for detection.

FR-AGT-004 Runtime detection. The library MUST be able to detect which backends are enabled by checking whether the backend’s CLI executable exists in PATH and is executable. When listing available runtimes (e.g. for a detect command), the order of the list MUST be the same effective order used for automatic default selection (user-configured order if present, otherwise alphabetical by runtime ID), so that the first runtime in the list is the one that would be selected when no explicit or preference override is set. Acceptance criteria: callers can list enabled runtimes in effective default order; the first item in the list is the would-be-selected agent when no override is given; tests can control PATH to simulate 0/1/many enabled runtimes.

FR-AGT-005 Runtime selection resolution. The library MUST provide a deterministic resolution function that selects the active runtime by consulting sources in a fixed order. When the caller is **bus-dev**, the order is: (1) explicit per-call selection (e.g. `--agent`), (2) `BUS_DEV_AGENT` (bus-dev only), (3) `BUS_AGENT`, (4) bus-dev persistent preference (e.g. `bus-dev.agent` read via bus-preferences), (5) bus-agent persistent preference `bus-agent.runtime` (read via bus-preferences), (6) first available runtime in the effective order. When the caller is **bus-agent** or any other caller that does not supply bus-dev context, the order is: (1) explicit per-call selection, (2) `BUS_AGENT`, (3) `bus-agent.runtime`, (4) first available runtime in the effective order. The implementation MUST depend on the bus-preferences Go library for persistent preferences; it MUST NOT implement its own preferences file or path. Default run-config values (model, output format, timeout) MUST also be read from bus-preferences when not overridden by flags or environment (see Data Design). The set of available runtimes is the set of enabled runtimes (executable found in PATH) minus any user-disabled runtimes, or restricted to user-enabled runtimes when an enable list is configured (see FR-AGT-005a). When multiple runtimes are available and resolution reaches the final step, the automatic default MUST be the first runtime in the effective order: either the user-specified order (FR-AGT-005a) or, when no order is specified, alphabetical by runtime ID (e.g. claude, codex, cursor, gemini). Acceptance criteria: same available set and same configuration yield the same choice; invalid runtime name yields a usage-style error; persistent preferences are read from bus-preferences only; resolution order is documented and testable.

FR-AGT-005a Agent order and enable/disable. The library MUST support optional user configuration so that (1) the user can specify the order in which available agents are considered for the automatic default (first available in that order is used), and (2) the user can disable specific runtimes (exclude them from the available set) or enable only a subset (so that only those runtimes are considered available). When an order is not specified, the default order over available runtimes MUST be alphabetical by runtime ID. When no enable/disable configuration is present, all enabled runtimes (found in PATH) are available. Configuration MAY be via environment variables, via the [bus-preferences](./bus-preferences) library when it exposes order/enable/disable, or both; the resolution order between them MUST be documented. Acceptance criteria: callers can pass or configure an ordered list of runtime IDs for automatic default; callers can pass or configure a disable list (runtimes to exclude) or an enable list (only these runtimes count as available); alphabetical default order is deterministic and documented.

FR-AGT-005b Disabled-agent skip and warning. At each step of resolution (FR-AGT-005), if the runtime indicated by that step is disabled by user configuration (excluded from the available set per FR-AGT-005a), the implementation MUST NOT select that runtime. It MUST print a warning to stderr that the configured runtime is disabled and resolution is continuing with the next source. Resolution then continues as if that source had not been set. This applies to every source: per-call selection (e.g. `--agent`), environment variables, and preferences. Unknown or malformed runtime names remain invalid usage (exit 2); a known but disabled runtime triggers warning and fall-through only. Acceptance criteria: when any config source names a disabled runtime, tests verify a warning is emitted and the next source is used; when all sources name disabled runtimes or none are set and no runtime is available, resolution fails with a clear diagnostic.

FR-AGT-006 Prompt-template rendering contract. Prompt templates MUST support `{{VARIABLE}}` placeholders. Rendering MUST be deterministic. Missing required variables MUST fail before any agent invocation with an error categorized as invalid usage. Any unresolved `{{...}}` token remaining after substitution MUST fail before invocation with an invalid-usage error. Acceptance criteria: unit tests cover missing variable, unresolved placeholder, repeated placeholder replacement, and a “no placeholders” pass-through case.

FR-AGT-007 Timeout enforcement. The runner MUST support timeouts per invocation and return a deterministic error when the timeout is exceeded. Acceptance criteria: tests can simulate a long-running stub executable and verify timeout handling and exit code mapping.

FR-AGT-008 Output capture and streaming. The runner MUST support (1) capturing stdout/stderr for structured results, and (2) optional streaming/forwarding of agent output to caller-provided writers. Acceptance criteria: callers can run in “capture-only” mode in tests and “stream-to-stderr” in CLI usage.

FR-AGT-009 Output normalization hooks. The library MUST support an optional output formatter layer (e.g. NDJSON-to-text) that can be applied per backend or per invocation. Acceptance criteria: Cursor-style NDJSON output can be formatted deterministically by a library function; callers can disable formatting and receive raw output.

FR-AGT-010 Installation URL mapping. The module MUST provide a canonical mapping from runtime to installation reference string for diagnostics. Acceptance criteria: when a runtime is selected but missing, callers can show a deterministic message including the correct install reference.

FR-AGT-011 Selected runtime and model reporting. The library MUST provide the caller with the selected runtime identifier and, when the backend can determine it, the model name or identifier in use for that invocation. This information MUST be available after resolution and before or upon starting execution so that consuming modules (e.g. bus-dev) can print which internal agent and model are being used at the start of each agent step. Backends that do not expose a model identifier (e.g. CLI does not report it) MAY report an empty or default model string; the runtime identifier MUST always be present. Acceptance criteria: callers can obtain (runtime ID, model string) for the active invocation; bus-dev can print this to stderr at the start of plan/work/spec/e2e steps.

FR-AGT-012 Set preference subcommands (CLI). If the CLI is implemented, it MUST provide a dedicated set subcommand for each bus-agent preference key, using the [bus-preferences](./bus-preferences) Go library (no shell-out to `bus preferences`). The subcommands MUST be: `bus agent set runtime <runtime>`, `bus agent set model <value>`, `bus agent set output-format <value>`, `bus agent set timeout <duration>`, each writing the corresponding key in Data Design (`bus-agent.runtime`, `bus-agent.model`, `bus-agent.output_format`, `bus-agent.timeout`). Invalid value for a given subcommand MUST yield exit 2. Acceptance criteria: running `bus agent set runtime gemini` persists `bus-agent.runtime`; a subsequent run without overrides uses that default; invalid value yields exit 2.

NFR-AGT-001 Determinism. Given the same inputs, PATH state, and stubbed agent output, the runner MUST produce consistent exit codes and diagnostics. Acceptance criteria: repeated test runs are stable.

NFR-AGT-002 Security boundary. The module MUST NOT execute arbitrary code from repository content. The only permitted external execution is the selected agent CLI executable. Acceptance criteria: no execution of repo scripts; no “shell=true” execution; argument lists are constructed explicitly.

NFR-AGT-003 Hermetic tests. Tests MUST not require network and MUST not require real agent CLIs. Acceptance criteria: all tests run with stub executables in PATH.

NFR-AGT-004 Cross-platform. Behavior and tests MUST run on Linux and macOS. Acceptance criteria: no platform-specific assumptions left unspecified.

NFR-AGT-005 No user configuration outside project. The module MUST NOT edit any user configuration outside the project working directory (the workdir passed to the runner). Bus-agent and its callers (e.g. bus-dev) MAY set environment variables and command-line options for the child agent process; they MUST NOT create, modify, or delete files outside the project working directory for the purpose of configuration or instruction discovery. Acceptance criteria: no code path writes to paths outside the given workdir for configuration or instruction setup; tests verify that only workdir-scoped paths are touched when enabling instruction discovery.

NFR-AGT-006 Repo file changes additive only. When the module (or a caller such as bus-dev applying the same contract) creates or modifies files inside the repository to enable instruction discovery or runtime adapter support, changes MUST be additive only: existing user content MUST NOT be removed or rewritten. The only permitted exception is the legacy Cursor rule file at `.cursor/rules/{bus-NAME}.mdc` (where the name matches the module or repo context), which MAY be replaced or migrated as part of standardizing on AGENTS.md. Any other repo-local file creation or merge MUST use append-only Bus-owned blocks with explicit markers so that user content remains intact. Acceptance criteria: repo-local file creation or merge uses append-only Bus-owned blocks with clear markers; existing user content is never deleted or overwritten except for the documented .cursor/rules/{bus-NAME}.mdc exception; behavior is testable.

FR-AGT-013 AGENTS.md as canonical instruction source. The module MUST treat AGENTS.md at the repository root as the canonical, vendor-neutral project instruction source for agent runs. Instruction discovery MUST follow a root-to-cwd layering model: instructions are sought from the repository root (e.g. root AGENTS.md) and, where the runtime supports directory-scoped instructions, from ancestor directories toward the current working directory. Where supported by the runtime, "closest wins" semantics apply for that scope (instruction from the directory closest to cwd takes precedence for overlapping scope). Acceptance criteria: the runner and each backend are configured so the agent receives project instructions from AGENTS.md when present; discovery order and precedence are documented and consistent across runtimes; callers (e.g. bus-dev) can rely on the same contract for commit, work, spec, and e2e workflows.

FR-AGT-014 Per-runtime instruction adapter. For each supported runtime (Codex, Cursor, Gemini CLI, Claude Code), the implementation MUST apply a documented adapter strategy that enables AGENTS.md (or equivalent) with a strong preference for per-invocation flags and environment variables; repo-local file creation or merge is used only when necessary to achieve equivalent instruction loading. When repo-local files are created or merged, content MUST be preserved via append-only Bus-owned blocks with explicit markers; existing user content MUST NOT be modified or removed except for the legacy `.cursor/rules/{bus-NAME}.mdc` file per NFR-AGT-006. The exact knobs (flags, environment variables, working directory) and any allowed repo-local files per runtime are specified in the "Project instructions (AGENTS.md) and per-runtime adapters" subsection under Component Design. Acceptance criteria: each runtime adapter documents and implements the exact flags, env, and workdir listed there; when repo-local files are used, implementation uses append-only Bus-owned blocks and tests verify markers and non-removal of user content.

FR-AGT-015 Fallback when AGENTS.md missing or over limit. When AGENTS.md is missing, too large for the runtime's context or command limits, or conflicts with runtime-specific limits, the implementation MUST apply a deterministic fallback: the agent run MUST still proceed with the caller-provided prompt and any instruction content that fits (e.g. truncated or omitted AGENTS.md with a clear boundary), and MUST NOT fail the run solely because AGENTS.md is absent or over limit unless the caller explicitly requires AGENTS.md. The implementation MUST document the fallback behavior (proceed without, truncate with marker, or warn and proceed) and apply it consistently. Acceptance criteria: behavior when AGENTS.md is missing is documented and testable; behavior when size exceeds a documented limit is deterministic; no silent failure; tests cover missing and over-size cases.

### System Architecture

Bus Agent is a library-first module with an optional thin CLI wrapper.

High-level components:

* **Template renderer.** Deterministic renderer for `{{VARIABLE}}` placeholders with strict pre-invocation validation (FR-AGT-006).
* **Backend interface.** A small interface implemented by each runtime backend (Cursor/Codex/Gemini/Claude) to provide executable discovery, command construction, and any backend-specific environment defaults.
* **Runner.** The core executor that applies selection resolution, builds the command, sets workdir and environment, enforces timeout, and routes output to capture/stream handlers.
* **Formatters (optional).** Pure functions to normalize agent output (e.g. NDJSON-to-text) without depending on external processes.
* **CLI (optional).** A minimal binary `bus-agent` invoked via dispatcher as `bus agent …` when included, intended for diagnostics and development rather than business workflows.

Data flow: caller (e.g. `bus-dev`) builds a prompt template + variables → renderer produces final prompt or fails → selection resolves runtime per FR-AGT-005 (explicit, then env and preferences in documented order, then first available; disabled runtimes trigger warning and fall-through per FR-AGT-005b) → runner executes external CLI with prompt in a workdir under timeout → output is captured/streamed and optionally formatted → caller interprets result according to its own workflow rules.

### Key Decisions

KD-AGT-001 External runtime execution only. Agent invocations use external CLIs rather than embedded provider SDKs, keeping Bus Agent small and keeping provider auth/config outside BusDK.

KD-AGT-002 Library owns the “how”, not the “what”. Bus Agent standardizes execution, templating, and output, while higher-level modules own the workflow prompts and policies.

KD-AGT-003 Deterministic, strict templating. Fail fast if templates are not fully resolved to prevent accidental ambiguous prompts.

KD-AGT-004 Stub-first testing strategy. All runtime behavior is tested via stub executables, not real agents.

KD-AGT-005 Installation references are defined here. The runtime-to-URL table in this SDD is the single source of truth for diagnostics when a runtime is missing; consuming modules (e.g. bus-dev) use the Bus Agent library and thus the same references.

### Component Design and Interfaces

Interface IF-AGT-001 (Runner entrypoint). The library exposes a runner entrypoint similar to:

* Inputs: selected runtime (optional), prompt text or (template + variables), workdir, timeout, output mode (capture/stream), optional formatter, optional agent order and enable/disable configuration (per FR-AGT-005a).
* Outputs: exit code, raw stdout/stderr, a typed error category (usage vs execution failure vs timeout), and the resolved runtime identifier and model string (per FR-AGT-011) so callers can report which agent and model are in use.

Interface IF-AGT-002 (Backend). Each backend provides:

* Runtime ID (e.g. `cursor`, `codex`, `gemini`, `claude`)
* Executable detection (names to check in PATH)
* Command line construction from a run request (prompt source, output format flags, model env/flags, non-interactive flags if supported)
* Installation reference string for diagnostics (FR-AGT-010)

**Runtime installation references.** When the selected runtime is not installed or not in PATH, callers MUST direct the user to the canonical installation URL for that runtime. The following table is the single source of truth for those URLs; the implementation MUST use the appropriate URL in the diagnostic when the runtime cannot be found or executed.

| Runtime    | Canonical installation URL |
| ---------- | --------------------------- |
| Gemini CLI | https://geminicli.com/ |
| Cursor CLI | https://cursor.com/docs/cli/overview |
| Claude CLI | https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started |
| Codex      | https://developers.openai.com/codex/cli/ |

Interface IF-AGT-003 (Template renderer). Provide:

* `Render(template string, vars map[string]string) (string, error)`
* Strict validation: missing or unresolved placeholders are invalid usage (FR-AGT-006)

Interface IF-AGT-004 (Formatter). Provide:

* `Format(runtime, rawStdout, rawStderr) (formattedText string, err error)` or a simpler pure function per format.

**Project instructions (AGENTS.md) and per-runtime adapters.** AGENTS.md at the repository root is the canonical, vendor-neutral instruction source (FR-AGT-013). Instruction discovery uses root-to-cwd layering; where a runtime supports directory-scoped instructions, "closest wins" applies for that scope. The adapter strategy prefers per-invocation flags and environment variables; repo-local file creation or merge is used only as a last resort, with append-only Bus-owned blocks and no removal or rewrite of existing user content (NFR-AGT-006), except that `.cursor/rules/{bus-NAME}.mdc` MAY be replaced or migrated. When AGENTS.md is missing, too large, or over runtime limits, deterministic fallback applies per FR-AGT-015 (proceed with caller prompt and any content that fits; do not fail solely due to AGENTS.md).

Per-runtime behavior:

| Runtime | Working directory | Environment / flags | Repo-local files (last resort only) | Notes |
| --------| -----------------|----------------------|--------------------------------------|-------|
| **Codex** | Child process cwd set to repo root (or caller workdir) so native AGENTS.md discovery runs in project. | Set `CODEX_HOME` to a repo-local directory (e.g. `<workdir>/.codex` or `<workdir>/tmp/codex`) so no global state is used or mutated; all state and caches remain inside the repository working directory. Per-run config overrides only when needed to tune instruction discovery or size limits. | None required when workdir is repo root and CODEX_HOME is repo-local; native AGENTS.md discovery applies. | Rely on native AGENTS.md discovery by controlling child process workdir; avoid global Codex config. |
| **Cursor** | Invoke from repository root (or set child cwd to repo root) so Cursor's native AGENTS.md loading applies. | No global configuration edits. Do not write to user-level Cursor config. | When stricter enforcement is required, add Bus-owned rule files under `.cursor/rules/` in an additive way only; do not touch existing user rules. **Exception:** the legacy file `.cursor/rules/{bus-NAME}.mdc` MAY be replaced or migrated as part of standardization (e.g. merged into AGENTS.md and removed). | Prefer native AGENTS.md loading from repo root; additive Bus rules only; document the legacy MDC exception. |
| **Gemini CLI** | Child process cwd set to repo root (or caller workdir). | Per-run environment or flag-based system-instruction injection only as fallback when repo-local config is undesirable for a given workflow. | Add or merge a repo-local `.gemini/settings.json` that configures context file discovery to prefer or include AGENTS.md (e.g. via context.fileName or equivalent). Use `.geminiignore` to control scan scope so the agent does not ingest excessive context from subdirectories. Merge must be additive; use Bus-owned markers and do not remove or rewrite existing user content. | Prefer repo-local .gemini/settings.json + .geminiignore; fallback to per-run system instruction when needed. |
| **Claude Code** | Child process cwd set to repo root (or caller workdir). | **Preferred:** inject AGENTS.md content via command-line system prompt append on each run, with clear safeguards for command length and size limits (truncate or warn per FR-AGT-015). | **Last resort:** create or append a clearly marked Bus-owned block in `CLAUDE.md` that imports or references `@AGENTS.md`. Strict rule: no existing CLAUDE.md content is modified or removed; only append Bus-owned block. | Prefer non-mutating CLI system prompt; repo-level CLAUDE.md shim only when necessary, append-only. |

The table above is the single source of truth for which knobs (workdir, env, flags) and which repo-local files each backend may use. Tests MUST verify that repo-local file changes are append-only and use Bus-owned markers where applicable, and that the legacy `.cursor/rules/{bus-NAME}.mdc` exception is the only case where user content may be replaced or removed.

### Command Surface

This module MAY expose a thin CLI as `bus agent` primarily for diagnostics and development. If implemented, it MUST remain minimal and library-backed and MUST provide the following commands: **detect**, **set**, **render**, **run**, **format**.

* **`bus agent detect [-1|--first]`** — List available runtimes in the same effective order used for automatic default selection (user-configured order if present, otherwise alphabetical by runtime ID), so the first line is the runtime that would be selected for `bus agent run` when no `--agent` or preference override is set. One runtime identifier per line. With `-1` or `--first`, output only that default runtime as a single line; if no runtime is available, exit with code 1.
* **`bus agent set runtime <runtime>`** — Set `bus-agent.runtime` (e.g. `cursor`, `gemini`) via the [bus-preferences](./bus-preferences) Go library. **`bus agent set model <value>`** — Set `bus-agent.model` (default when unset: `auto`). **`bus agent set output-format <ndjson|text>`** — Set `bus-agent.output_format` (default when unset: `text`). **`bus agent set timeout <duration>`** — Set `bus-agent.timeout` (e.g. `60m`). Each uses the bus-preferences library directly (no shell-out to `bus preferences`). Invalid value yields exit 2.
* **`bus agent render (--template <file> | --text <text>) --var KEY=VALUE [--var KEY=VALUE ...]`** — Render a prompt template with the supplied variables and print the result to stdout. Exactly one of `--template` or `--text` is required. If a required variable is missing or any `{{...}}` token remains after substitution, the command MUST fail with invalid usage (exit 2) and MUST NOT run any external process.
* **`bus agent run [--agent <runtime>] [--timeout <duration>] [--workdir <dir>] (--prompt <file> | --text <text>)`** — Run the selected agent runtime with a prompt and stream its output. Exactly one of `--prompt` or `--text` is required. Which runtime is used is determined by the resolution order (FR-AGT-005): for the bus-agent CLI, (1) `--agent`, (2) `BUS_AGENT`, (3) `bus-agent.runtime` from bus-preferences, (4) first available in the effective order; at any step, if the configured runtime is disabled, the tool prints a warning to stderr and continues with the next source. Effective working directory for the agent is the current directory unless `--workdir` is set. The run is subject to a timeout (default or `--timeout`, e.g. `30s`, `5m`). At the start of the run, the CLI MUST print to stderr which agent and model are in use (per FR-AGT-011). Output is streamed in a script-safe, non-interactive manner. If the selected runtime is not installed or not in PATH, the command MUST fail with a clear diagnostic and the canonical installation URL for that runtime (exit 1).
* **`bus agent format [--runtime <runtime>]`** — Read raw agent output (e.g. NDJSON) from stdin and write formatted, human-readable text to stdout. Use `--runtime <runtime>` to select the formatter for the given backend; if omitted, the tool may use a default or infer from the input (behavior documented in CLI help).

If the CLI is not implemented initially, all functionality remains available via the Go library and the CLI surface is considered out of scope for the first milestone.

### I/O Conventions

Library: callers control where output goes via provided writers and capture buffers.

CLI (if implemented): stdout is reserved for command results (e.g. detect list, rendered prompt, formatted output). stderr is reserved for diagnostics, progress, and agent stream output. When both `--output` and `--quiet` are used, quiet wins: no output is written to the output file. All paths and the effective working directory are resolved relative to the current directory unless `-C` / `--chdir` is set; if the `--chdir` directory does not exist or is not accessible, the command MUST exit with code 1.

### Exit Codes (CLI, if implemented)

* **0** — Success.
* **1** — Execution failure: agent run failed, timeout exceeded, selected runtime not found or not executable, could not execute the agent CLI, or no runtime available when using `detect --first`. When the selected runtime is missing, the tool MUST include the canonical installation URL for that runtime in the diagnostic.
* **2** — Invalid usage: unknown command or flag, missing required argument (e.g. `--template` or `--text` for render, `--prompt` or `--text` for run), unresolved template placeholder, invalid runtime name, invalid `set` value, or invalid `--timeout` or path.

Template rendering failures (missing variable, unresolved `{{...}}`) MUST occur before any external execution and always result in exit 2.

### Error Handling

* **Missing selected runtime executable:** Return execution failure (exit 1) with a diagnostic that includes the runtime’s canonical installation URL (FR-AGT-010). Do not run any external process.
* **No runtime available when using `detect --first`:** Exit 1 with a clear diagnostic; when automatic default selection is requested for `run` and no runtime is available, exit with a clear failure that lists supported runtimes and install references.
* **Disabled runtime in a config source (FR-AGT-005b):** Print a warning to stderr and continue resolution with the next source; do not select the disabled runtime.
* **Template rendering failures (missing variable, unresolved `{{...}}`):** Invalid usage (exit 2); MUST occur before any external execution.
* **Invalid usage (unknown command or flag, missing required argument, invalid runtime name, invalid `set` value, invalid `--timeout` or path):** Exit 2 with a clear message.

### Data Design

Bus Agent does not own a persistent preferences file or path. The persistent default agent and run-config defaults (model, output format, timeout) are stored in user-level preferences and read via the [bus-preferences](./bus-preferences) Go library; the user sets them with the bus preferences CLI (e.g. `bus preferences set bus-agent.runtime gemini`).

**Environment variables for runtime selection.** `BUS_AGENT` is the session preference for the default agent when using the bus-agent CLI or when no module-specific override applies; its value MUST be one of `cursor`, `codex`, `gemini`, or `claude`. When the caller is bus-dev, the library also consults `BUS_DEV_AGENT` (bus-dev-only session preference) before `BUS_AGENT`; see FR-AGT-005. These variables are read by the library during resolution; the library does not set them.

**Preference keys.** The following preference keys under the `bus-agent` namespace are used:

| Key | Description |
|-----|-------------|
| `bus-agent.runtime` | Default agent runtime when no per-call or session override is set (e.g. `cursor`, `gemini`). |
| `bus-agent.model` | Default model (e.g. for Cursor). When unset, the default value MUST be `auto`. Overridable by environment (e.g. `CURSOR_AGENT_MODEL`). |
| `bus-agent.output_format` | Default output format. Valid values: **`ndjson`** (raw structured output from the agent), **`text`** (human-readable; NDJSON formatted to text). When unset, the default value MUST be `text`. Overridable by environment (e.g. `CURSOR_AGENT_OUTPUT_FORMAT`). |
| `bus-agent.timeout` | Default run timeout as a duration string (e.g. `60m`). Overridable by `CURSOR_AGENT_TIMEOUT` or `--timeout`. |

The library MUST expose helpers such as `GetDefaultRuntime(ctx)`, `SetDefaultRuntime(ctx, id)`, `GetDefaultRunConfig(ctx)`, and `SetDefault*` so that callers and the CLI can read and write these values via the bus-preferences library without resolving the preferences file path themselves. The CLI uses these helpers when resolving the runtime and building run config for `run`. All other configuration is via call parameters and environment variables as chosen by the caller. The module does not own workspace datasets or repo-local context files; those remain the responsibility of higher-level modules.

### Assumptions and Dependencies

AD-AGT-001 External agent CLIs are installed by the user and available in PATH when used. If a selected runtime's executable is missing, the runner fails with a clear diagnostic and the installation reference from the table above; callers do not fall back silently.

AD-AGT-002 Linux and macOS are supported platforms. If the runtime is used on an unsupported platform, behavior and test coverage are not guaranteed.

AD-AGT-003 The module is built and tested in a hermetic environment with stubbed executables. Tests that rely on real agent CLIs or network are out of scope for the standard test suite (NFR-AGT-003).

AD-AGT-004 bus-preferences dependency. Bus Agent depends on the [bus-preferences](./bus-preferences) Go library for reading (and optionally writing) the persistent default agent and run-config defaults (model, output format, timeout). The bus-preferences library defines where those preferences are stored (user-level preferences file); bus-agent uses the library and does not read or write the preferences file directly. If bus-preferences is unavailable or the library interface changes incompatibly, resolution step (3) (persistent preference) is skipped and resolution falls through to the automatic default; run-config defaults fall back to implementation-defined defaults. Tests may stub the bus-preferences dependency to control the persistent preference without touching the real preferences file.

### Testing Strategy

* **Unit tests:** template rendering contract; selection resolution ordering; PATH-based detection; command construction per backend; timeout logic; formatter behavior; instruction-adapter knobs (workdir, env, flags) per runtime; fallback behavior when AGENTS.md is missing or over size limit (FR-AGT-015).
* **Stub-exec tests:** place stub agent executables in a temporary PATH that emit deterministic output and exit codes; verify runner capture/stream behavior and exit code mapping.
* **Repo-local file tests:** when a backend creates or merges repo-local files for instruction discovery, verify append-only Bus-owned blocks and that existing user content is not removed or rewritten (NFR-AGT-006); verify the only exception is .cursor/rules/{bus-NAME}.mdc.
* **Cross-platform considerations:** avoid shell-dependent quoting; pass argv arrays; ensure temp PATH handling works on macOS/Linux.

### Traceability to BusDK Spec

Bus Agent aligns with BusDK’s library-first, deterministic, non-interactive principles and exists to reduce duplication across modules by centralizing agent runtime mechanics. [bus-dev](./bus-dev) depends on Bus Agent for the agent runner: bus-dev's requirements for runner abstraction (FR-DEV-005), supported runtimes (FR-DEV-005a), selection and detection (FR-DEV-005b, FR-DEV-005d), agent order and enable/disable (FR-AGT-005a), disclosure of selected agent and model on each step (FR-DEV-005e), and installation references are satisfied by importing and using the Bus Agent library. Bus Agent’s FR-AGT-011 (selected runtime and model reporting) enables bus-dev to print which internal agent and model are in use at the start of each agent step. bus-dev uses the same instruction model (AGENTS.md as canonical source, per-runtime adapters, and file-change invariants per FR-AGT-013, FR-AGT-014, NFR-AGT-005, NFR-AGT-006) for its developer workflows (commit, work, spec, e2e) so the agent instruction contract is shared across modules and can be implemented and tested consistently. bus-dev retains workflow-specific behavior (embedded prompts for commit, work, spec, e2e; repository and module resolution; Gemini repository-local rules per FR-DEV-005c), which is out of scope for Bus Agent. Workflow semantics, prompts, and any module-specific policies remain defined in each consuming module's SDD.

### Glossary and Terminology

* **Runtime/backend:** A specific external agent CLI integration (Cursor/Codex/Gemini/Claude).
* **Enabled runtime:** A runtime whose executable is found in PATH and is executable.
* **Available runtime:** A runtime that is eligible for automatic default selection. By default this is the set of enabled runtimes; it can be restricted by user configuration (disable list excludes runtimes, enable list restricts to a subset). See FR-AGT-005a.
* **Agent order:** Optional user-configured ordering of runtime IDs. When set, the automatic default is the first available runtime in this order; when not set, the order is alphabetical by runtime ID.
* **Prompt template:** A UTF-8 string containing `{{VARIABLE}}` placeholders rendered deterministically before invocation.
* **Formatter:** A pure transformation of raw agent output into readable, normalized text.
* **Installation reference:** The canonical URL for installing a given runtime, used in diagnostics when the runtime is not found (see Runtime installation references under Component Design; FR-AGT-010).
* **BUS_AGENT:** Environment variable for session default agent (value: `cursor`, `codex`, `gemini`, or `claude`). Consulted during resolution when no explicit per-call selection is given; used by both bus-agent CLI and bus-dev (after BUS_DEV_AGENT when caller is bus-dev). See FR-AGT-005.
* **BUS_DEV_AGENT:** Environment variable for bus-dev-only session default agent. Consulted only when the caller is bus-dev, before BUS_AGENT. See FR-AGT-005.
* **AGENTS.md:** The canonical, vendor-neutral project instruction file at the repository root per the [AGENTS.md](https://agents.md/) convention. Bus-agent and bus-dev treat it as the single source of project instructions; per-runtime adapters enable it via workdir, env, flags, or (last resort) repo-local file merges with append-only Bus-owned blocks. See FR-AGT-013, FR-AGT-014.
* **Bus-owned block:** A contiguous block of content in a repo-local file (e.g. CLAUDE.md, .gemini/settings.json) that is added by BusDK (bus-agent or bus-dev) with an explicit marker so it can be identified and updated without touching existing user content. All such changes are append-only; user content is never removed or rewritten (except the legacy .cursor/rules/{bus-NAME}.mdc exception).
* **Instruction discovery:** The process by which an agent runtime learns project instructions (e.g. from AGENTS.md). Bus-agent uses root-to-cwd layering and "closest wins" where supported; adapters are documented per runtime in the "Project instructions (AGENTS.md) and per-runtime adapters" subsection.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-api">bus-api</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [BusDK Software Design Document (SDD)](../sdd)
- [bus-preferences module SDD](./bus-preferences)
- [bus-dev module SDD](./bus-dev)
- [End user documentation: bus-agent CLI reference](../modules/bus-agent)
- [Module repository structure and dependency rules](../implementation/module-repository-structure)
- [Gemini CLI — install](https://geminicli.com/)
- [Cursor CLI — overview and install](https://cursor.com/docs/cli/overview)
- [Claude Code — get started / install](https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started)
- [Codex CLI — install](https://developers.openai.com/codex/cli/)

### Document control

Title: bus-agent module SDD
Project: BusDK
Document ID: `BUSDK-MOD-AGENT`
Version: 2026-02-13
Status: Draft
Last updated: 2026-02-13
Owner: BusDK development team
