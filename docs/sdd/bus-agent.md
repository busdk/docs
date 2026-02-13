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

FR-AGT-004 Runtime detection. The library MUST be able to detect which backends are enabled by checking whether the backend’s CLI executable exists in PATH and is executable. Acceptance criteria: callers can list enabled runtimes; tests can control PATH to simulate 0/1/many enabled runtimes.

FR-AGT-005 Runtime selection resolution. The library MUST provide a deterministic resolution function that selects the active runtime based on (1) explicit per-call selection, then (2) an optional session preference (environment variable), then (3) persistent preference from [bus-preferences](./bus-preferences) (read via the bus-preferences Go library), then (4) an automatic default chosen from the set of available runtimes in a deterministic order. The implementation MUST depend on the bus-preferences Go library for step (3); it MUST NOT implement its own preferences file or path for the persistent default agent. Default run-config values (model, output format, timeout) MUST also be read from bus-preferences when not overridden by flags or environment (see Data Design for the preference keys). The set of available runtimes is the set of enabled runtimes (executable found in PATH) minus any user-disabled runtimes, or restricted to user-enabled runtimes when an enable list is configured (see FR-AGT-005a). When multiple runtimes are available and no explicit or preference selection is given, the automatic default MUST be the first runtime in the effective order: either the user-specified order (FR-AGT-005a) or, when no order is specified, alphabetical by runtime ID (e.g. claude, codex, cursor, gemini). Acceptance criteria: same available set and same configuration yield the same automatic choice; invalid selection yields a usage-style error; persistent preference is read from bus-preferences only.

FR-AGT-005a Agent order and enable/disable. The library MUST support optional user configuration so that (1) the user can specify the order in which available agents are considered for the automatic default (first available in that order is used), and (2) the user can disable specific runtimes (exclude them from the available set) or enable only a subset (so that only those runtimes are considered available). When an order is not specified, the default order over available runtimes MUST be alphabetical by runtime ID. When no enable/disable configuration is present, all enabled runtimes (found in PATH) are available. Configuration MAY be via environment variables, via the [bus-preferences](./bus-preferences) library when it exposes order/enable/disable, or both; the resolution order between them MUST be documented. The default agent (which runtime to use when no override is given) is always read from bus-preferences (FR-AGT-005 step (3)); order and enable/disable may be read from bus-preferences if the bus-preferences library provides them, otherwise from environment or call parameters. Acceptance criteria: callers can pass or configure an ordered list of runtime IDs for automatic default; callers can pass or configure a disable list (runtimes to exclude) or an enable list (only these runtimes count as available); alphabetical default order is deterministic and documented.

FR-AGT-006 Prompt-template rendering contract. Prompt templates MUST support `{{VARIABLE}}` placeholders. Rendering MUST be deterministic. Missing required variables MUST fail before any agent invocation with an error categorized as invalid usage. Any unresolved `{{...}}` token remaining after substitution MUST fail before invocation with an invalid-usage error. Acceptance criteria: unit tests cover missing variable, unresolved placeholder, repeated placeholder replacement, and a “no placeholders” pass-through case.

FR-AGT-007 Timeout enforcement. The runner MUST support timeouts per invocation and return a deterministic error when the timeout is exceeded. Acceptance criteria: tests can simulate a long-running stub executable and verify timeout handling and exit code mapping.

FR-AGT-008 Output capture and streaming. The runner MUST support (1) capturing stdout/stderr for structured results, and (2) optional streaming/forwarding of agent output to caller-provided writers. Acceptance criteria: callers can run in “capture-only” mode in tests and “stream-to-stderr” in CLI usage.

FR-AGT-009 Output normalization hooks. The library MUST support an optional output formatter layer (e.g. NDJSON-to-text) that can be applied per backend or per invocation. Acceptance criteria: Cursor-style NDJSON output can be formatted deterministically by a library function; callers can disable formatting and receive raw output.

FR-AGT-010 Installation URL mapping. The module MUST provide a canonical mapping from runtime to installation reference string for diagnostics. Acceptance criteria: when a runtime is selected but missing, callers can show a deterministic message including the correct install reference.

FR-AGT-011 Selected runtime and model reporting. The library MUST provide the caller with the selected runtime identifier and, when the backend can determine it, the model name or identifier in use for that invocation. This information MUST be available after resolution and before or upon starting execution so that consuming modules (e.g. bus-dev) can print which internal agent and model are being used at the start of each agent step. Backends that do not expose a model identifier (e.g. CLI does not report it) MAY report an empty or default model string; the runtime identifier MUST always be present. Acceptance criteria: callers can obtain (runtime ID, model string) for the active invocation; bus-dev can print this to stderr at the start of plan/work/spec/e2e steps.

NFR-AGT-001 Determinism. Given the same inputs, PATH state, and stubbed agent output, the runner MUST produce consistent exit codes and diagnostics. Acceptance criteria: repeated test runs are stable.

NFR-AGT-002 Security boundary. The module MUST NOT execute arbitrary code from repository content. The only permitted external execution is the selected agent CLI executable. Acceptance criteria: no execution of repo scripts; no “shell=true” execution; argument lists are constructed explicitly.

NFR-AGT-003 Hermetic tests. Tests MUST not require network and MUST not require real agent CLIs. Acceptance criteria: all tests run with stub executables in PATH.

NFR-AGT-004 Cross-platform. Behavior and tests MUST run on Linux and macOS. Acceptance criteria: no platform-specific assumptions left unspecified.

### System Architecture

Bus Agent is a library-first module with an optional thin CLI wrapper.

High-level components:

* **Template renderer.** Deterministic renderer for `{{VARIABLE}}` placeholders with strict pre-invocation validation (FR-AGT-006).
* **Backend interface.** A small interface implemented by each runtime backend (Cursor/Codex/Gemini/Claude) to provide executable discovery, command construction, and any backend-specific environment defaults.
* **Runner.** The core executor that applies selection resolution, builds the command, sets workdir and environment, enforces timeout, and routes output to capture/stream handlers.
* **Formatters (optional).** Pure functions to normalize agent output (e.g. NDJSON-to-text) without depending on external processes.
* **CLI (optional).** A minimal binary `bus-agent` invoked via dispatcher as `bus agent …` when included, intended for diagnostics and development rather than business workflows.

Data flow: caller (e.g. `bus-dev`) builds a prompt template + variables → renderer produces final prompt or fails → selection resolves runtime (per-call, then session, then persistent from bus-preferences library, then automatic default from available runtimes) → runner executes external CLI with prompt in a workdir under timeout → output is captured/streamed and optionally formatted → caller interprets result according to its own workflow rules.

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

### Command Surface

This module MAY expose a thin CLI as `bus agent` primarily for diagnostics. If implemented, it MUST remain minimal and library-backed.

Potential operations (optional, minimal set):

* `bus agent detect` — list enabled runtimes detected in PATH.
* `bus agent render --template <file>|--text <text> --var KEY=VALUE ...` — render a template deterministically and fail on unresolved placeholders.
* `bus agent run [--agent <runtime>] [--timeout <dur>] [--workdir <dir>] (--prompt <file>|--text <text>)` — run an agent and stream output in a deterministic, script-safe manner. At the start of the run, the CLI MUST print to stderr the selected runtime identifier and model (per FR-AGT-011) so that users and scripts see which agent and model are in use.
* `bus agent format [--runtime <runtime>]` — format raw agent output (e.g. NDJSON) read from stdin to readable text on stdout.

If the CLI is not implemented initially, all functionality remains available via the Go library and the CLI surface is considered out of scope for the first milestone.

### I/O Conventions

Library: callers control where output goes via provided writers and capture buffers.

CLI (if implemented): stdout is reserved for command results (e.g. detect list, rendered prompt, formatted output). stderr is reserved for diagnostics and progress.

### Exit Codes (CLI, if implemented)

* 0: success
* 1: execution failure (agent failed, timeout, could not exec)
* 2: invalid usage (unknown runtime, missing required args, template unresolved)

### Error Handling

* Missing selected runtime executable: return execution failure with a diagnostic that includes the runtime’s install reference string.
* No enabled runtime when automatic selection is requested: return a clear failure that lists supported runtimes and install references.
* Template rendering failures (missing/unresolved placeholders): invalid usage, and MUST occur before any external execution.

### Data Design

Bus Agent does not own a persistent preferences file or path. The persistent default agent and run-config defaults (model, output format, timeout) are stored in user-level preferences and read via the [bus-preferences](./bus-preferences) Go library; the user sets them with the bus preferences CLI (e.g. `bus preferences set bus-agent.default_runtime gemini`). The following preference keys under the `bus-agent` namespace are used:

| Key | Description |
|-----|-------------|
| `bus-agent.default_runtime` | Default agent runtime when no per-call or session override is set (e.g. `cursor`, `gemini`). |
| `bus-agent.model` | Default model (e.g. for Cursor). Overridable by environment (e.g. `CURSOR_AGENT_MODEL`). |
| `bus-agent.output_format` | Default output format. Overridable by environment (e.g. `CURSOR_AGENT_OUTPUT_FORMAT`). |
| `bus-agent.timeout` | Default run timeout as a duration string (e.g. `60m`). Overridable by `CURSOR_AGENT_TIMEOUT` or `--timeout`. |

The library MUST expose helpers such as `GetDefaultRuntime(ctx)`, `SetDefaultRuntime(ctx, id)`, `GetDefaultRunConfig(ctx)`, and `SetDefault*` so that callers and the CLI can read and write these values via the bus-preferences library without resolving the preferences file path themselves. The CLI uses these helpers when resolving the runtime and building run config for `run`. All other configuration is via call parameters and environment variables as chosen by the caller. The module does not own workspace datasets or repo-local context files; those remain the responsibility of higher-level modules.

### Assumptions and Dependencies

AD-AGT-001 External agent CLIs are installed by the user and available in PATH when used. If a selected runtime's executable is missing, the runner fails with a clear diagnostic and the installation reference from the table above; callers do not fall back silently.

AD-AGT-002 Linux and macOS are supported platforms. If the runtime is used on an unsupported platform, behavior and test coverage are not guaranteed.

AD-AGT-003 The module is built and tested in a hermetic environment with stubbed executables. Tests that rely on real agent CLIs or network are out of scope for the standard test suite (NFR-AGT-003).

AD-AGT-004 bus-preferences dependency. Bus Agent depends on the [bus-preferences](./bus-preferences) Go library for reading (and optionally writing) the persistent default agent and run-config defaults (model, output format, timeout). The bus-preferences library defines where those preferences are stored (user-level preferences file); bus-agent uses the library and does not read or write the preferences file directly. If bus-preferences is unavailable or the library interface changes incompatibly, resolution step (3) (persistent preference) is skipped and resolution falls through to the automatic default; run-config defaults fall back to implementation-defined defaults. Tests may stub the bus-preferences dependency to control the persistent preference without touching the real preferences file.

### Testing Strategy

* **Unit tests:** template rendering contract; selection resolution ordering; PATH-based detection; command construction per backend; timeout logic; formatter behavior.
* **Stub-exec tests:** place stub agent executables in a temporary PATH that emit deterministic output and exit codes; verify runner capture/stream behavior and exit code mapping.
* **Cross-platform considerations:** avoid shell-dependent quoting; pass argv arrays; ensure temp PATH handling works on macOS/Linux.

### Traceability to BusDK Spec

Bus Agent aligns with BusDK’s library-first, deterministic, non-interactive principles and exists to reduce duplication across modules by centralizing agent runtime mechanics. [bus-dev](./bus-dev) depends on Bus Agent for the agent runner: bus-dev's requirements for runner abstraction (FR-DEV-005), supported runtimes (FR-DEV-005a), selection and detection (FR-DEV-005b, FR-DEV-005d), agent order and enable/disable (FR-AGT-005a), disclosure of selected agent and model on each step (FR-DEV-005e), and installation references are satisfied by importing and using the Bus Agent library. Bus Agent’s FR-AGT-011 (selected runtime and model reporting) enables bus-dev to print which internal agent and model are in use at the start of each agent step. bus-dev retains workflow-specific behavior (embedded prompts for commit, work, spec, e2e; repository and module resolution; Gemini repository-local rules per FR-DEV-005c), which is out of scope for Bus Agent. Workflow semantics, prompts, and any module-specific policies remain defined in each consuming module's SDD.

### Glossary and Terminology

* **Runtime/backend:** A specific external agent CLI integration (Cursor/Codex/Gemini/Claude).
* **Enabled runtime:** A runtime whose executable is found in PATH and is executable.
* **Available runtime:** A runtime that is eligible for automatic default selection. By default this is the set of enabled runtimes; it can be restricted by user configuration (disable list excludes runtimes, enable list restricts to a subset). See FR-AGT-005a.
* **Agent order:** Optional user-configured ordering of runtime IDs. When set, the automatic default is the first available runtime in this order; when not set, the order is alphabetical by runtime ID.
* **Prompt template:** A UTF-8 string containing `{{VARIABLE}}` placeholders rendered deterministically before invocation.
* **Formatter:** A pure transformation of raw agent output into readable, normalized text.
* **Installation reference:** The canonical URL for installing a given runtime, used in diagnostics when the runtime is not found (see Runtime installation references under Component Design; FR-AGT-010).

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
